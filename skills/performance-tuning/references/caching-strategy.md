# Caching Strategy

Caching trades correctness risk for speed. Take that trade deliberately, and only where the
underlying work is genuinely expensive.

**Cache last.** Fix the query, add the index, bound the result set, then measure again. A
cache over an unindexed query is two problems where there was one — and on every miss you
still pay the full cost, now with stale data as a bonus.

---

## Choosing a Tier

| Tier | Lifetime | Use for | Invalidated by |
|---|---|---|---|
| `once()` | One request | The same value computed several times in one request | Request end |
| `Cache::remember` short TTL | Seconds to minutes | Dashboards, counts, aggregates, feed pages | Time |
| `Cache::remember` long TTL | Hours | Expensive reports, external API responses | Time + manual bust |
| `rememberForever` | Until busted | Config, reference data, lookup tables | Model event |
| `config:cache`, `route:cache`, `view:cache` | Until deploy | Always, in production | Deploy |
| HTTP / CDN | Per `Cache-Control` | Public, identical-for-everyone responses | TTL, purge |

Rule of thumb: if the work takes under ~10ms, caching it costs more in complexity than it
returns in time.

---

## Key Design

A cache key is a contract. Everything the value depends on must appear in it.

```php
// ❌ Serves one tenant's data to another
Cache::remember('dashboard_stats', 300, fn () => $this->stats());

// ❌ Serves an admin's view to a normal user
Cache::remember("stats:{$tenantId}", 300, fn () => $this->stats($user));

// ✅ Every dependency is in the key
Cache::remember("stats:v2:t{$tenantId}:r{$user->role_id}:{$period}", 300,
    fn () => $this->stats($tenantId, $user->role_id, $period));
```

Checklist for every key:

- [ ] Tenant / organisation id, if the data is scoped
- [ ] User or role id, if the value differs by permission
- [ ] Every filter, sort and period that changes the result
- [ ] A version prefix (`v2:`) so a shape change does not read old values
- [ ] Locale, if the value contains translated text

**The security rule:** a cache key missing its tenant or user component will eventually serve
one customer another's data. That is a data-exposure incident, not a cache bug. See
`security-hardening`.

---

## Invalidation

Invalidate at the write, not at the read. Read sites multiply; write sites do not.

### Model events — the default

```php
protected static function booted(): void
{
    static::saved(fn (self $m) => static::bustCache($m));
    static::deleted(fn (self $m) => static::bustCache($m));
}

protected static function bustCache(self $m): void
{
    Cache::forget("tenant:{$m->tenant_id}:config");
    Cache::forget("tenant:{$m->tenant_id}:stats");
}
```

**Bulk writes skip model events.** `Model::insert()`, `upsert()` and query-builder `update()`
will not fire `saved`. Bust the cache explicitly after any bulk operation.

### Tags — when the driver supports them

```php
// Redis or Memcached only — not file or database
Cache::tags(["tenant:{$id}", 'stats'])->remember('dashboard', 300, fn () => …);
Cache::tags(["tenant:{$id}"])->flush();      // everything for one tenant
```

Tags are convenient and cost a level of indirection on every read. Use them when a single
write invalidates many unpredictable keys; use explicit `forget()` when the set is small and
known.

### Version prefix — when invalidation is hard

```php
$version = Cache::get("tenant:{$id}:version", 1);
Cache::remember("tenant:{$id}:v{$version}:stats", 3600, fn () => …);

// On write: bump instead of enumerating keys
Cache::increment("tenant:{$id}:version");
```

Old entries are never read again and expire on their own. This is the escape hatch when a
write invalidates an unbounded set of keys.

---

## Stampede Protection

When a hot key expires, every concurrent request recomputes it at once.

```php
// Only one process computes; the rest wait for it
Cache::lock("stats:{$id}:lock", 10)->block(5, function () use ($id) {
    return Cache::remember("stats:{$id}", 300, fn () => $this->compute($id));
});
```

For the hottest keys, refresh ahead of expiry from a scheduled job so a user never pays the
recompute at all.

---

## What Not to Cache

| Do not cache | Why |
|---|---|
| Anything authorization-dependent, without the identity in the key | Cross-user data exposure |
| A query that runs in under ~10ms | The lookup costs more than the work |
| Values that must be immediately consistent (balances, stock, quotas) | Stale means wrong, and wrong means a refund |
| Data with no invalidation path you can name | It will be stale forever and nobody will know |
| Whole rendered pages containing per-user content | The first viewer's page is served to everyone |

---

## Config and Route Caches

```bash
php artisan optimize         # config + route + view + event
php artisan optimize:clear   # all of the above
```

**Gotcha:** once `config:cache` has run, `env()` returns `null` outside `config/*.php`. Every
`env()` call in `app/` becomes null in production while working fine locally. Read env only
in config files, then `config('services.foo.key')` everywhere else.

---

## Verifying a Cache Actually Helps

```php
Cache::flush();

$cold = measure(fn () => $service->stats($id));   // miss
$warm = measure(fn () => $service->stats($id));   // hit

dump(['cold_ms' => $cold, 'warm_ms' => $warm]);
```

Then answer three questions in writing:

1. **Hit rate** — how often is this actually warm in production? A cache with a 5% hit rate
   costs more than it saves.
2. **Staleness window** — what is the worst-case age of a served value, and is that acceptable
   to the business?
3. **Invalidation** — which write busts this key, and is there a test proving it?

If any of the three has no answer, the cache is not ready to ship.

---

## Testing Cached Code

```php
it('caches the stats', function () {
    Cache::flush();

    DB::enableQueryLog();
    $this->service->stats($this->tenant->id);
    $cold = count(DB::getQueryLog());

    DB::flushQueryLog();
    $this->service->stats($this->tenant->id);

    expect(DB::getQueryLog())->toBeEmpty()
        ->and($cold)->toBeGreaterThan(0);
});

it('busts the cache when a setting changes', function () {
    $this->service->stats($this->tenant->id);

    Setting::factory()->for($this->tenant)->create();

    expect(Cache::has("tenant:{$this->tenant->id}:stats"))->toBeFalse();
});

it('does not serve another tenant cached stats', function () {
    $mine   = $this->service->stats($this->tenant->id);
    $theirs = $this->service->stats($this->otherTenant->id);

    expect($mine)->not->toEqual($theirs);
});
```

The third test is the one that matters. Write it for every cache on tenant-scoped data.
