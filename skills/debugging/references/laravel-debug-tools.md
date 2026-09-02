# Laravel Debugging Tools

Pick the cheapest instrument that answers the question. Reach for a profiler only after
counting queries has failed to explain it.

## Counting queries (the first thing to try for anything slow)

```php
// In a test, tinker, or a temporary service provider boot()
DB::listen(fn ($q) => logger($q->sql, $q->bindings));

// Or just count
DB::enableQueryLog();
$result = $service->run();
dump(count(DB::getQueryLog()));
```

A page issuing 400 queries is an N+1, not a database problem. `with()` is the fix.

## Tinker — fastest reproduction loop

```bash
php artisan tinker
php artisan tinker --execute="dump(App\Models\Order::find(1234)->total());"
```

Good for: checking real data, calling a service in isolation, confirming a relationship.
Bad for: anything involving middleware, auth context, or the request lifecycle.

## Pest as a debugger

The best reproducer is a failing test — it is repeatable, it lives in the repo, and it
becomes the regression guard for free.

```bash
./vendor/bin/pest --filter=OrderTotalTest
./vendor/bin/pest --order-by=random --repeat=10   # flake hunting
./vendor/bin/pest --bail                          # stop at first failure
```

## Telescope — request-level history (local/staging only)

Shows requests, queries, jobs, mail, cache hits, exceptions, and their timing, after the fact.
Use when the failure already happened and you need the surrounding context.

```bash
composer require laravel/telescope --dev
php artisan telescope:install && php artisan migrate
```

**Never enable Telescope in production without pruning and auth** — it stores request payloads
including credentials.

## Pulse — production-safe aggregates

Slow queries, slow jobs, slow requests, exception counts, usage by user. Aggregated, so it is
safe to run in production where Telescope is not.

## Xdebug — step debugging

Worth the setup cost only when the control flow itself is the mystery — deep recursion,
unclear branching, framework internals. For "what is this variable", `dump()` is faster.

```bash
XDEBUG_MODE=debug php artisan test
```

Note: Xdebug makes the test suite several times slower. Use `pcov` for coverage instead.

## Logs

```bash
tail -f storage/logs/laravel.log
grep -n "OrderTotal" storage/logs/laravel.log | tail -50

# Production, structured
php artisan pail --filter="exception"
```

For production-log-driven investigation, use the `log-monitor` skill — it covers parsing,
correlation and turning findings into issues.

## Queues

```bash
php artisan queue:failed                 # what died
php artisan queue:retry <uuid>           # retry one
php artisan horizon:status
php artisan schedule:list                # is the command even registered?
```

A job that "never runs" is almost always dispatched to a connection nothing is watching.
Compare `->onConnection()` / `QUEUE_CONNECTION` against `config/horizon.php`.

## git bisect — finding the commit that did it

```bash
git bisect start
git bisect bad HEAD
git bisect good v1.4.0
git bisect run ./vendor/bin/pest --filter=OrderTotalTest
git bisect reset
```

`git bisect run` is fully automatic and finds the culprit in log₂(n) steps. Twenty commits
means about five test runs. Almost always faster than reading the diff.

## Clearing state before you conclude anything

```bash
php artisan optimize:clear   # config, route, view, event, cache — all of it
```

Run this before declaring a bug reproducible. A stale `config:cache` has cost more debugging
hours than any real bug.
