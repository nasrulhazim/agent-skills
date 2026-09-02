# Query Optimisation

Database access is where most Laravel latency lives. Work this file top to bottom before
looking anywhere else.

---

## Step 1 — Count the queries

```php
DB::enableQueryLog();
$result = $service->run();
$log = DB::getQueryLog();

dump(['count' => count($log)]);
collect($log)->sortByDesc('time')->take(5)->each(fn ($q) => dump($q['time'] . 'ms — ' . $q['query']));
```

Interpretation:

| Count | Reading |
|---|---|
| 1–15 | Normal for a page |
| 20–50 | Suspicious — look for a loop |
| 50+ | An N+1, almost certainly |
| Grows with row count | Definitely an N+1 |

The last row is the real test: render the page with 10 records and with 100. If the query
count grows with the data, you have found it.

---

## Step 2 — Turn N+1s into exceptions

```php
// app/Providers/AppServiceProvider.php
public function boot(): void
{
    Model::preventLazyLoading(! app()->isProduction());
    Model::preventSilentlyDiscardingAttributes(! app()->isProduction());
}
```

Now every lazy load throws in local and CI. This finds N+1s you would never have looked for.
Never disable it to make a page work — fix the eager load.

---

## Step 3 — Eager load precisely

```php
// Load only what the view renders
Order::with(['customer:id,name', 'items:id,order_id,title,total'])->get();

// Nested
Order::with('items.product.category')->get();

// Conditional — constrain the relation itself
Order::with(['items' => fn ($q) => $q->where('active', true)->limit(5)])->get();

// Counts and sums without loading rows
Order::withCount('items')->withSum('items', 'total')->get();
Order::withExists('refunds')->get();

// Already have the models? Load after the fact
$orders->load('customer');
$orders->loadMissing('customer');       // skips ones already loaded
```

**Selecting columns in `with()` requires the foreign key.** `with('customer:id,name')` works
only because `id` is there; omit it and the relation silently comes back null.

---

## Step 4 — Bound every result set

```php
User::paginate(25);                       // page it
User::simplePaginate(25);                 // no COUNT(*) — faster on huge tables
User::cursorPaginate(25);                 // constant cost at any offset

User::chunkById(1000, fn ($rows) => …);   // batch job
User::lazyById()->each(fn ($u) => …);     // generator, constant memory
```

- `chunkById` over `chunk` — plain `chunk` uses OFFSET and skips rows when the set changes
  mid-pass.
- `cursorPaginate` over `paginate` for deep pagination — `LIMIT 25 OFFSET 100000` reads
  100,025 rows.
- Enforce a maximum page size from user input: `min($request->integer('per_page', 25), 100)`.

---

## Step 5 — Read the query plan

```sql
EXPLAIN SELECT * FROM orders WHERE tenant_id = 5 AND status = 'open'
ORDER BY created_at DESC LIMIT 25;

-- MySQL 8 / PostgreSQL, with real timings
EXPLAIN ANALYZE SELECT …;
```

| `type` | Meaning | Action |
|---|---|---|
| `system`, `const`, `eq_ref` | Single row via a unique index | Ideal |
| `ref` | Index used, several rows | Good |
| `range` | Index range scan | Usually fine |
| `index` | Full index scan | Reading the whole index — narrow the query |
| `ALL` | Full table scan | **The finding.** Add an index |

Other columns worth reading: `rows` (estimated rows examined — compare it to rows returned),
`key` (which index was chosen, `NULL` means none), and `Extra` — `Using filesort` and
`Using temporary` both mean the sort or grouping is not served by an index.

---

## Step 6 — Index for the query, not the column

```php
Schema::table('orders', function (Blueprint $table) {
    $table->index(['tenant_id', 'status', 'created_at']);   // filter, filter, sort
    $table->unique(['tenant_id', 'reference']);
});
```

**Left-to-right prefix rule.** An index on `(a, b, c)` serves:

- `WHERE a = ?`
- `WHERE a = ? AND b = ?`
- `WHERE a = ? AND b = ? ORDER BY c`

It does **not** serve `WHERE b = ?` or `WHERE c = ?` alone. Column order is determined by the
query, not by intuition: equality columns first, then the range or sort column last.

### Where indexes belong

- Every foreign key (Laravel's `foreignId()->constrained()` adds one; a plain
  `unsignedBigInteger` does not)
- Columns in `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`
- `tenant_id` first in every composite index in a multi-tenant app

### Where they do not

- Low-cardinality columns alone (`is_active`, `status` with three values) — useful only as
  part of a composite
- Wide text columns — use a full-text index or a search engine
- Tables under a few thousand rows — a scan is cheaper than an index lookup
- Columns written far more often than they are read

### Cost

Each index adds write cost and disk. Adding one to a large table locks it on some engines —
use `ALGORITHM=INPLACE`, a percona-style online change, or a maintenance window. Say so in
the migration's comment.

---

## Common Patterns

### `whereHas` on a large relation

```php
// ❌ Correlated subquery per row
Order::whereHas('items', fn ($q) => $q->where('product_id', 5))->get();

// ✅ One subquery
Order::whereIn('id', OrderItem::where('product_id', 5)->select('order_id'))->get();

// ✅ Better still for a hot path: a denormalised counter, kept by a model event
Order::where('items_count', '>', 0)->get();
```

### Counting

```php
$count = $order->items()->count();     // ✅ SELECT COUNT(*)
$count = count($order->items);         // ❌ loads every row
$count = $order->items->count();       // ❌ same, if not already loaded
```

Use `withCount('items')` when rendering a list — one query for all rows.

### Aggregates in a loop

```php
// ❌ One query per order
foreach ($orders as $order) {
    $total = $order->items()->sum('total');
}

// ✅ One query total
$orders = Order::withSum('items', 'total')->get();
foreach ($orders as $order) {
    $total = $order->items_sum_total;
}
```

### Repeated identical query

```php
// ❌ Same lookup on every iteration
foreach ($rows as $row) {
    $rate = ExchangeRate::where('code', $row->currency)->first();
}

// ✅ One query, indexed in memory
$rates = ExchangeRate::pluck('rate', 'code');
foreach ($rows as $row) {
    $rate = $rates[$row->currency] ?? null;
}
```

### Existence

```php
$model->relation()->exists();      // ✅ SELECT 1 … LIMIT 1
$model->relation->isNotEmpty();    // ❌ loads the relation
```

---

## Bulk Writes

```php
// ❌ N queries, N sets of model events
foreach ($rows as $row) {
    Order::create($row);
}

// ✅ One query — note: no model events, no timestamps
Order::insert($rows);

// ✅ Upsert on a unique key
Order::upsert($rows, ['tenant_id', 'reference'], ['total', 'status']);

// ✅ Bulk update by condition
Order::where('status', 'draft')->where('created_at', '<', now()->subDays(30))
     ->update(['status' => 'expired']);
```

`insert()`, `upsert()` and query-builder `update()` bypass Eloquent events, casts and
timestamps. If a model event carries business logic (cache invalidation, audit logging), a
bulk write silently skips it. Handle the side effect explicitly, or accept the row count cost.

---

## Reporting a Query Fix

```markdown
| Path | Baseline | After | Change |
|---|---|---|---|
| GET /dashboard | 412 queries, 3180ms, 84MB | 6 queries, 190ms, 22MB | `with(['customer:id,name','items'])` + index on `(tenant_id, created_at)` |

**EXPLAIN before:** type=ALL, rows=180000, key=NULL
**EXPLAIN after:**  type=ref, rows=25, key=orders_tenant_id_created_at_index
**Remaining:** report export still 900ms — unindexed `GROUP BY` on a computed column.
```
