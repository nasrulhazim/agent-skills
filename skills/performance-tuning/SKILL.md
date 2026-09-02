---
name: performance-tuning
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, performance, n-plus-one, indexing, caching, queues, profiling]
description: >
  Measure-first performance work for Laravel applications — diagnosing slow endpoints,
  queries and pages, then fixing them in order of actual impact. Covers baselining before
  any change, N+1 detection and eager loading, database indexing strategy and EXPLAIN
  reading, pagination and chunking for large result sets, caching tiers and safe
  invalidation, moving work to queues, trimming Livewire payloads and polling, and
  front-end asset and image budgets. Every finding carries a number: query count,
  milliseconds, payload bytes or memory. Use this skill whenever the user reports something
  slow, wants to profile or optimise, asks about indexes, caching or N+1 queries, or needs
  a page or API endpoint to hit a latency target — including "this page is slow", "optimise
  this query", "why is this endpoint taking 4 seconds", "find the N+1", "should I add an
  index here", "add caching", "reduce the payload", "the dashboard takes forever",
  "profile this", "laman ni lambat", "kenapa query ni lambat", "tolong optimize", "nak
  tambah index", "guna cache macam mana", or "endpoint ni makan masa". Never optimise
  blind — pairs with debugging for root-causing and code-quality when the fix is a refactor.
---

# Performance Tuning

Performance work without a baseline is decoration. Every change in this skill is bracketed
by a measurement before and the same measurement after, and reported as both numbers.

**The order matters.** Roughly 80% of Laravel slowness is database access, 15% is work done
synchronously that should be queued, and 5% is everything else. Work the list in that order
rather than starting with the interesting problem.

## Command Reference

| Command | Description |
|---|---|
| `/perf baseline` | Capture the current numbers for a slow path before changing anything |
| `/perf queries` | Find N+1s, missing indexes and unbounded result sets |
| `/perf cache` | Design a caching tier and its invalidation |
| `/perf queue` | Move synchronous work off the request |
| `/perf frontend` | Livewire payload, asset and image budgets |
| `/perf report` | Baseline → change → result, with remaining bottlenecks ranked |

---

## When to Use

- A page, endpoint or job is slow enough that someone complained
- A latency or throughput target has to be met before launch
- Load has grown and something that used to be fine no longer is
- A query, report or export times out
- Memory exhaustion on a job or command

**Do not** use this skill to optimise something nobody measured. "This looks like it could be
slow" is not a finding — it is a guess with a diff attached. If the path is not slow, say so
and stop.

---

## 1. Baseline — before anything else

You cannot claim an improvement without a number to improve on.

```php
// Query count and time for a single path
DB::enableQueryLog();
$start = microtime(true);

$result = $service->run();

dump([
    'queries' => count(DB::getQueryLog()),
    'ms'      => round((microtime(true) - $start) * 1000),
    'memory'  => round(memory_get_peak_usage(true) / 1048576, 1) . 'MB',
]);
```

```bash
# Endpoint-level, repeatable
curl -o /dev/null -s -w "%{time_total}s\n" https://app.test/dashboard

# What the app thinks it is
php artisan about
```

Record: **query count, wall-clock ms, peak memory, response bytes.** Capture them against
realistic data volume — a seeder with 20 rows hides every N+1 in the codebase.

| Instrument | Use for |
|---|---|
| `DB::listen()` / `getQueryLog()` | Query count and the actual SQL — start here, always |
| Laravel Debugbar | Local per-request breakdown |
| Telescope | Local/staging request history after the fact |
| Pulse | Production-safe aggregates: slow queries, slow jobs, slow requests |
| `EXPLAIN` | Whether a query uses an index |
| Browser devtools | Front-end only — TTFB separates server from client |

---

## 2. Queries — where the time actually is

### N+1

The single most common Laravel performance bug. A page issuing 400 queries is not a database
problem; it is a missing `with()`.

```php
// ❌ 1 + N queries
$orders = Order::all();
foreach ($orders as $order) {
    echo $order->customer->name;      // one query each
}

// ✅ 2 queries
$orders = Order::with('customer')->get();

// ✅ Nested, and only the columns needed
$orders = Order::with(['customer:id,name', 'items.product:id,title'])->get();

// ✅ Aggregates without loading the relation
$orders = Order::withCount('items')->withSum('items', 'total')->get();
```

Catch them automatically in local and CI:

```php
// AppServiceProvider::boot()
Model::preventLazyLoading(! app()->isProduction());
```

That one line turns every N+1 into an exception in development. Add it before hunting
manually.

### Unbounded result sets

```php
// ❌ Loads every row into memory
$users = User::all();

// ✅ Page it
$users = User::paginate(25);

// ✅ Stream it for a job or export
User::chunkById(1000, fn ($chunk) => $chunk->each(...));
User::lazyById()->each(...);           // generator, constant memory
```

`chunkById` over `chunk` — plain `chunk` skips rows when the underlying set changes mid-pass.

### Indexes

An index earns its keep on columns used in `WHERE`, `JOIN`, `ORDER BY` and `GROUP BY`.

```php
Schema::table('orders', function (Blueprint $table) {
    $table->index('status');                       // filtered on
    $table->index(['tenant_id', 'created_at']);    // composite: filter + sort
});
```

Read `EXPLAIN` before and after:

```sql
EXPLAIN SELECT * FROM orders WHERE tenant_id = 5 ORDER BY created_at DESC LIMIT 25;
```

| `type` column | Meaning |
|---|---|
| `const` / `eq_ref` / `ref` | Index used. Good. |
| `range` | Index used for a range. Usually fine. |
| `index` | Full index scan — better than `ALL`, still reading everything |
| `ALL` | Full table scan. This is the finding. |

**Composite index column order is left-to-right prefix.** An index on
`(tenant_id, created_at)` serves `WHERE tenant_id = ?` and
`WHERE tenant_id = ? ORDER BY created_at`, but **not** `WHERE created_at > ?` alone.

Indexes are not free: every one slows writes and consumes space. Add the index the query
plan asks for, not one per column.

### Other query wins

| Problem | Fix |
|---|---|
| `SELECT *` on a wide table | `select(['id', 'name', 'total'])` |
| Counting by loading | `->count()`, never `count($model->items)` after loading |
| `whereHas` on a large relation | `whereIn` on a sub-select, or denormalise a counter |
| Repeated identical query in a loop | Hoist it out, or cache for the request |
| `orderBy` on an unindexed expression | Store the computed value in a column and index it |

---

## 3. Caching

Cache the expensive and stable. Caching a cheap query buys nothing and adds an invalidation
bug.

```php
// Request-scoped: same value used several times in one request
$settings = once(fn () => Setting::all()->keyBy('key'));

// Short TTL for a hot read
$stats = Cache::remember("tenant:{$id}:stats", now()->addMinutes(5),
    fn () => $this->computeStats($id));

// Forever + explicit invalidation on write
$config = Cache::rememberForever("tenant:{$id}:config",
    fn () => Config::forTenant($id));
```

| Tier | Use for | Invalidate by |
|---|---|---|
| `once()` / static | Same value read repeatedly in one request | End of request |
| `Cache::remember` + short TTL | Dashboards, counts, aggregates | Time |
| `rememberForever` | Config, reference data, rarely-changing lookups | Model event on write |
| `config:cache` / `route:cache` / `view:cache` | Always, in production | Deploy |

**Invalidation is the hard part and the dangerous part:**

```php
// Model event — invalidate where the write happens, not at every read site
protected static function booted(): void
{
    static::saved(fn (self $m) => Cache::forget("tenant:{$m->tenant_id}:config"));
    static::deleted(fn (self $m) => Cache::forget("tenant:{$m->tenant_id}:config"));
}
```

**Never cache across an authorization or tenant boundary.** A cache key without the tenant or
user in it will eventually serve one customer another's data. That is not a performance bug,
it is a security incident — see `security-hardening`.

---

## 4. Queues — take the work off the request

If the user does not need the result to render the response, it does not belong in the
request.

```php
// ❌ 3 seconds of the user's time spent on things they never see
Mail::to($user)->send(new WelcomeMail($user));
$this->generateReport($order);
$this->notifySlack($order);

// ✅
SendWelcomeMail::dispatch($user);
GenerateReport::dispatch($order)->onQueue('reports');
NotifySlack::dispatch($order)->afterCommit();
```

| Rule | Why |
|---|---|
| `afterCommit()` on jobs dispatched inside a transaction | Otherwise the worker can pick it up before the row exists |
| Jobs must be idempotent | Retries are guaranteed to happen eventually |
| Pass IDs, never whole models | The payload is serialised; a fat model is a fat queue |
| Separate queues by latency need | A 40-minute export must not sit in front of a password reset |
| Set `$timeout` and `$tries` explicitly | Defaults are rarely right for either fast or slow jobs |

Verify the worker is actually consuming what you dispatch — a job on a connection Horizon is
not watching sits unclaimed forever (see `debugging`).

---

## 5. Livewire

Every Livewire request round-trips the component's public state. That state is the payload.

| Problem | Fix |
|---|---|
| Whole Eloquent model as a public property | Hold the ID; load in `render()` or a computed property |
| Large collection as a public property | Use `#[Computed]` — not serialised into the payload |
| `wire:poll` at default 2s on a heavy component | Lengthen the interval, or use `wire:poll.visible` |
| Every keystroke hitting the server | `wire:model.live.debounce.400ms`, or plain `wire:model` |
| A heavy component blocking first paint | `#[Lazy]` with a placeholder |
| Re-rendering an unchanged expensive subtree | `wire:key` on list items; split the component |

```php
#[Computed]
public function orders(): Collection      // not serialised into the payload
{
    return Order::with('customer:id,name')->latest()->take(25)->get();
}
```

---

## 6. Front-end

| Budget | Target |
|---|---|
| TTFB | < 200ms (server work — everything above this line) |
| Largest Contentful Paint | < 2.5s |
| Interaction to Next Paint | < 200ms |
| Cumulative Layout Shift | < 0.1 |
| Total JS, compressed | < 300KB |

- Serve modern image formats at the size actually rendered; set `width`/`height` to stop layout shift
- `loading="lazy"` on below-the-fold images
- Let Vite code-split; do not ship one bundle for every route
- Cache static assets far-future with the build hash in the filename
- Gzip/Brotli at the web server

TTFB is the only one of these this skill's earlier sections can fix. If TTFB is 1.8s, no
amount of front-end work matters — go back to section 2.

---

## Companion: ponytail

The fastest code is the code that does not run. Before adding a cache layer, a queue, a
read-replica or a denormalised counter, check the rungs above it: is the query even needed,
is an existing index enough, is there a smaller result set to ask for?

`ponytail` is installed by default with this toolkit and enforces that ordering. A caching
layer added around an unindexed query is two problems where there was one. Add the index
first, re-measure, and often the cache becomes unnecessary. If `ponytail` is absent, apply
the same ordering by hand.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This looks slow, I'll optimise it" | Looks are not a measurement. Optimising an unmeasured path spends real time on an imaginary problem and adds real risk. |
| "It's fast enough locally" | Locally you have 20 seeded rows, no network latency and a warm cache. Production has none of those. |
| "I'll add a cache, that'll fix it" | A cache over a 400-query page still issues 400 queries on every miss, and now serves stale data too. Fix the queries. |
| "Adding indexes on everything is safer" | Every index slows every write and consumes space. Add the one the query plan asks for. |
| "Eager loading everything avoids N+1" | `with()` on ten relations you do not render loads ten relations you do not render. Eager load what the view uses. |
| "The ORM is slow, I'll write raw SQL" | The ORM issues the query you asked for. Almost always the fix is the query, not the layer. |
| "I changed five things and it's faster" | You cannot report which one worked, or which one is a latent bug. Change one, measure, repeat. |
| "Caching user data with a shared key is fine, it's the same query" | Until it serves customer A's dashboard to customer B. That is a security incident, not a cache miss. |
| "Queueing it is over-engineering" | A three-second synchronous email is three seconds of every user's time and one SMTP outage from a broken checkout. |
| "We'll optimise it when it becomes a problem" | Reasonable — and it is a problem now, which is why you are reading this. It was not reasonable to skip the index at write time. |

---

## Red Flags

- An optimisation PR with no before/after numbers
- Several changes batched into one "performance" commit
- `Model::all()` or an unpaginated list endpoint
- A view iterating a collection and touching a relation inside the loop
- A cache key with no tenant or user component on per-user data
- `Cache::forever` with no invalidation path anywhere in the codebase
- An index added per column rather than per query plan
- `EXPLAIN` showing `ALL` on a table that is not tiny
- Raw SQL introduced to "speed things up" without a measured comparison
- A job dispatched inside a transaction without `afterCommit()`
- `wire:poll` on a component that runs an aggregate query
- Front-end optimisation started while TTFB is over a second
- `Model::preventLazyLoading()` disabled to make a page work

---

## Verification

- [ ] A baseline was captured before any change: query count, ms, peak memory, response bytes
- [ ] The baseline was taken against realistic data volume, not a 20-row seeder
- [ ] One change was made at a time, and each was measured independently
- [ ] The after-measurement uses the identical scenario and instrument as the baseline
- [ ] `EXPLAIN` confirms every new index is actually used by the query it was added for
- [ ] `Model::preventLazyLoading()` is on in local/CI and the suite passes with it
- [ ] Every cache key includes the tenant/user where the data is scoped
- [ ] Every cache has a stated invalidation path, and it is exercised by a test
- [ ] Correctness is unchanged: the full test suite passes after the optimisation
- [ ] The report states baseline → change → result, plus remaining bottlenecks ranked by expected impact

---

## Reference Files

| File | Read When |
|---|---|
| `references/query-optimisation.md` | Hunting N+1s, reading `EXPLAIN`, choosing indexes, handling large result sets |
| `references/caching-strategy.md` | Choosing a cache tier, writing keys, and designing invalidation that cannot leak across tenants |
