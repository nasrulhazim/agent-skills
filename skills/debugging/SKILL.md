---
name: debugging
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, debugging, triage, root-cause, incident]
description: >
  Systematic debugging and error recovery for Laravel and PHP projects — a five-step
  triage that goes reproduce, localise, reduce, fix, guard. Covers reading a stack trace
  properly, bisecting with git, isolating a failure to the smallest reproducer, telling a
  symptom apart from a root cause, and closing every fix with a regression test. Includes
  Laravel-specific traps: N+1 masked as a timeout, queue jobs failing silently on the wrong
  connection, cache and config caches serving stale values, Livewire state desync, and
  eloquent/model events firing in unexpected order. Use this skill whenever the user reports
  something broken, failing, flaky, slow-then-erroring, or behaving differently in production
  than locally — including "this test is flaky", "why is this failing", "debug this error",
  "it works locally but not on staging", "find the root cause", "this exception makes no
  sense", "the queue job never runs", "bisect this regression", "kenapa error ni",
  "tolong debug", "test ni kejap pass kejap fail", "cari punca sebenar", "jalan kat local
  tapi tak jalan kat production", or "job queue tak jalan". Pairs with kickoff-pest-testing
  for the regression test and log-monitor for production-log-driven investigations.
---

# Debugging and Error Recovery

A bug report names a **symptom**. Your job is the **cause**. The gap between them is where
most wasted debugging time lives — patching the path the ticket names, while every sibling
caller stays broken.

## Command Reference

| Command | Description |
|---|---|
| `/debug triage` | Run the five-step triage on a reported failure |
| `/debug reproduce` | Build the smallest reliable reproducer |
| `/debug bisect` | Find the commit that introduced a regression |
| `/debug flaky` | Diagnose a test that passes and fails without code changes |
| `/debug guard` | Write the regression test that locks the fix in |

---

## When to Use

- Something throws, returns the wrong value, or silently does nothing
- A test is flaky — passes alone, fails in the suite, or fails one run in ten
- Behaviour differs between local, staging and production
- A regression appeared and nobody knows which change caused it
- An exception's message and its actual cause do not match
- A queued job, scheduled command or event listener never runs

**Do not** use this skill to add features, refactor, or "clean up while I'm in here". A debug
session ends when the bug is fixed and guarded, not when the file looks nicer.

---

## The Five-Step Triage

Never skip a step. Steps 1 and 2 are where the answer actually is; steps 3–5 are mechanical.

### Step 1: Reproduce

**You have not started debugging until the failure happens on demand.**

- Get the exact input: the request payload, the user, the tenant, the record ID, the time
- Reproduce it in the cheapest environment that still fails — a Pest test beats `tinker`,
  `tinker` beats clicking through the UI
- If it only fails in production, capture the difference: `php artisan about`, the `.env`
  keys that differ, the queue/cache drivers, the PHP version, the data volume

```bash
php artisan tinker --execute="dd(App\Models\Order::find(1234)->total());"
```

If you cannot reproduce it, say so plainly and stop. A fix for a bug you never saw fail is
a guess wearing a diff.

### Step 2: Localise

Read the stack trace from the **bottom up** — the deepest frame in *your* code is the
suspect, not the framework frame that finally threw.

```bash
# What actually changed?
git log --oneline -20 -- app/Services/BillingService.php
git blame -L 40,60 app/Services/BillingService.php
```

**Every caller, not just the reported one:**

```bash
grep -rn "calculateTotal" app/ tests/
```

If four callers route through one function, the bug is probably in the function. One guard
there is a smaller diff than four guards in the callers — and it fixes the three nobody
reported yet.

**Bisect when the trace is not enough:**

```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-tag>
git bisect run ./vendor/bin/pest --filter=OrderTotalTest
git bisect reset
```

### Step 3: Reduce

Cut the reproducer down until every remaining line is load-bearing.

- Strip middleware, then auth, then the HTTP layer entirely — does the service still fail?
- Replace the database record with a hand-built model instance
- Replace the real dependency with a stub returning the exact value

When you can no longer delete a line without the failure disappearing, the remaining lines
**are** the bug.

### Step 4: Fix — at the root

| Symptom fix | Root fix |
|---|---|
| `if ($x === null) return;` in the controller | Why is `$x` null? Fix the source or make the type honest |
| `try { … } catch (\Throwable) {}` | Handle the specific exception, or let it throw |
| `->where('deleted_at', null)` added at the call site | Model is missing `SoftDeletes` |
| Retry the job three more times | The job is not idempotent |
| `sleep(1)` before the assertion | The test is racing a queued job — use `Queue::fake()` |

State what the root cause **is** in one sentence before you edit. If you cannot, you are
still in step 2.

### Step 5: Guard

**A fix without a failing-then-passing test is not finished.**

1. Write the test first, watch it fail with the original bug present
2. Apply the fix, watch it pass
3. Revert the fix once, confirm the test fails again — this proves the test guards the bug
   and not something incidental

```php
it('does not double-charge when the webhook is replayed', function () {
    $order = Order::factory()->paid()->create();

    handleWebhook($order, $payload);
    handleWebhook($order, $payload);   // replay

    expect($order->fresh()->charges)->toHaveCount(1);
});
```

Use the `kickoff-pest-testing` skill for the test's shape, factories and assertions.

---

---

## Companion: graphify

`graphify` builds a persistent, queryable knowledge graph of a codebase — tree-sitter AST
parsing for code plus semantic extraction for docs. It answers structural questions far faster
than grepping, and it is installed by default with this toolkit.

**Use it before a manual sweep whenever the question is structural.**

```bash
graphify extract .                       # build (or refresh) the graph — once per repo
graphify query "how does authentication work"
graphify path UserController InvoiceRepository   # call chain between two nodes
graphify explain app/Services/BillingService.php
```

If `graphify-out/` already exists in the target repo, treat the question as a graph query
first and fall back to file reading only for what the graph cannot answer. If `graphify` is
not installed, carry on with the normal file-reading approach — it is an accelerator, never a
prerequisite.

## Laravel-Specific Traps

These account for most of the "the code looks correct" hours in a Laravel codebase.

| Symptom | Actual cause |
|---|---|
| Endpoint times out under real data, fine with seeded data | N+1 — missing eager load. `DB::listen()` and count the queries |
| Config change has no effect | `config:cache` is stale. `php artisan config:clear` |
| Job dispatched, never runs, no error | Dispatched on a connection Horizon is not watching. Check `->onConnection()` vs `config/horizon.php` |
| Job runs old code after deploy | `queue:restart` was not run — workers hold the old class in memory |
| Scheduled command never fires | Cron is not running, or is running on more than one host |
| Test passes alone, fails in the suite | Shared state — a static, a cached config, a seeded row, or a real queue instead of `Queue::fake()` |
| Livewire property reverts after an action | Not in `$rules`/not `#[Reactive]`, or being reset by a re-render |
| Model event does not fire | `Model::withoutEvents()`, mass `update()` on the query builder, or `insert()` bypassing Eloquent |
| Policy allows something it should not | `Gate::before` superadmin short-circuit running before your policy |
| Works as admin, fails as user | Missing permission, not a code bug — check `spatie/laravel-permission` roles first |
| Wrong tenant's data appears | A query missed the global scope, or the scope was removed by `withoutGlobalScopes()` |

---

## Flaky Tests

A flaky test is a real bug about 70% of the time — usually an ordering or shared-state bug
that production will eventually hit too. Do not `->skip()` it.

```bash
./vendor/bin/pest --filter=OrderTest          # alone
./vendor/bin/pest                             # in the suite
./vendor/bin/pest --order-by=random --repeat=10
```

| Flake cause | Fix |
|---|---|
| Test order dependence | `RefreshDatabase`, and stop leaking static/singleton state |
| Time | `Carbon::setTestNow()` — never assert on `now()` |
| Randomness | Seed the faker, or assert on shape rather than value |
| Real queue / real HTTP | `Queue::fake()`, `Http::fake()`, `Mail::fake()` |
| Auto-increment ID assumptions | Assert on the model, not on `id === 1` |

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just add a null check" | A null check where the null is unexpected hides the bug and moves the crash later, into a place with less context. |
| "It's probably a caching issue" | "Probably" means you skipped step 1. Clear the cache, reproduce again, and find out. |
| "I can't reproduce it, but I know what's wrong" | Then you can reproduce it. If your theory is right, you can write the failing test that proves it. |
| "The test is just flaky" | A flaky test is a race, a shared-state leak, or a time assumption — all three are production bugs waiting for traffic. |
| "It works now, I don't know what fixed it" | Something you changed fixed it, or nothing did and it will return. Revert your changes one at a time until it breaks again. |
| "Wrapping it in try/catch stops the error" | It stops the *message*. The broken state carries on silently and surfaces somewhere less debuggable. |
| "Only one user reported it" | One report of a data-corruption bug is the same severity as a thousand. Count the blast radius, not the reporters. |
| "I'll add the regression test later" | The moment you have a reliable reproducer is the cheapest the test will ever be. Later, you would have to rebuild it from scratch. |
| "Let me refactor this while I'm here" | Now the diff contains a fix and a refactor, and if it breaks nobody knows which half did it. |

---

## Red Flags

- A fix committed with no test, and no explanation of why a test was impossible
- `catch (\Throwable $e) {}` — an empty catch, or one that only logs and continues
- A null/empty guard added at the call site rather than the source
- "Fixed" with no stated root cause in the commit message
- `sleep()` or `--retry` added to make a test pass
- The same bug fixed in three different callers in one PR
- A `->skip()` or `->markTestIncomplete()` added during a bug fix
- Debugging by editing production directly
- `dd()`, `dump()`, `ray()`, `var_dump()` or `Log::debug('here')` left in the diff
- A diff that touches files unrelated to the reported failure
- Blaming the framework, the database or the browser before reading your own stack trace

---

## Verification

Before calling a bug fixed:

- [ ] The original failure reproduces on demand (or its impossibility is documented)
- [ ] The root cause is stated in one sentence, and it is a cause, not a symptom
- [ ] Every caller of the changed function was checked, not just the reported path
- [ ] A regression test exists, and it fails when the fix is reverted
- [ ] The full test suite passes, not just the new test
- [ ] No debug output (`dd`, `dump`, `ray`, `Log::debug`) remains in the diff
- [ ] The diff contains the fix and its test — nothing else
- [ ] If the bug reached production, the blast radius is stated: who was affected, what data, over what window

---

## Reference Files

| File | Read When |
|---|---|
| `references/triage-playbook.md` | Working a live failure step by step — the questions to ask at each stage |
| `references/laravel-debug-tools.md` | Choosing an instrument — `DB::listen`, Telescope, Pulse, Xdebug, bisect, tinker |
