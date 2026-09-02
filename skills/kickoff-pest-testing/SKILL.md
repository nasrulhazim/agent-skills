---
name: kickoff-pest-testing
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, pest, testing, livewire, kickoff]
description: >
  Comprehensive Pest PHP testing skill for Laravel projects on the Kickoff baseline —
  auto-detects models, controllers, services, and Livewire components then scaffolds matching
  Pest test files with proper assertions, factories, and database testing patterns. Supports
  feature tests with actingAs(), API endpoint tests, Livewire::test() component testing,
  Spatie Permission role-based helpers, architecture testing (extending Kickoff baseline),
  suite performance (seeder placement, Xdebug/pcov, Test Impact Analysis) and coverage gap
  analysis. Use this skill whenever the user asks to write tests, generate test files, scaffold
  test suites, check test coverage, speed up a slow suite, or create architecture rules —
  including: "write tests for this model", "test this controller", "generate feature tests",
  "add Livewire tests", "scaffold Pest tests", "check test coverage", "the test suite is slow",
  "set up TIA", "add arch tests", "test this API endpoint", "tulis test untuk model ni",
  "buat feature test", "tambah test untuk controller", "scaffold test suite", "semak coverage",
  "buat arch test", "test suite lambat", or "test Livewire component ni". Assumes Pest is
  already installed with arch testing configured (Kickoff baseline).
---

# Pest Testing Skill (Kickoff baseline)

Auto-detect Laravel application components and scaffold production-quality Pest test files —
feature tests, unit tests, Livewire component tests, API tests, and architecture rules. Designed
for projects using the Kickoff baseline where Pest and arch testing are pre-configured.

> **Naming:** this skill is `kickoff-pest-testing`, not `pest-testing`, because Laravel Boost's
> `boost:install --skills` writes its own `pest-testing` skill into `.claude/skills/` and would
> silently overwrite this one. Boost's covers Pest 4 syntax generically; this one covers
> scaffolding, the Kickoff arch-test baseline and suite performance. They are complementary —
> load both.

## Command Reference

| Command | Description |
|---|---|
| `/test generate` | Auto-detect target (model/controller/service/component) and scaffold matching Pest tests |
| `/test feature` | Generate feature tests with HTTP assertions, authentication, and database checks |
| `/test unit` | Generate unit tests for isolated logic (services, actions, value objects) |
| `/test coverage-check` | Analyse existing tests and report coverage gaps with suggested test stubs |

---

## 1. `/test generate` — Auto-Detect & Scaffold

### Step 1: Identify the Target

Scan the file or class the user references and classify it:

| Signal | Classification | Test Location |
|---|---|---|
| `extends Model` | Eloquent Model | `tests/Feature/Models/` |
| `extends Controller` or route handler | Controller | `tests/Feature/Http/Controllers/` |
| Class in `app/Services/` | Service | `tests/Unit/Services/` |
| Class in `app/Actions/` | Action | `tests/Unit/Actions/` |
| `extends Component` (Livewire) | Livewire Component | `tests/Feature/Livewire/` |
| Route with `api` prefix or `api.php` | API Endpoint | `tests/Feature/Api/` |
| Class in `app/Policies/` | Policy | `tests/Feature/Policies/` |
| Blade view only | View | `tests/Feature/Views/` |
| `extends Mailable` | Mail | `tests/Feature/Mail/` |
| `extends Notification` | Notification | `tests/Feature/Notifications/` |
| `extends Job` or `implements ShouldQueue` | Job | `tests/Feature/Jobs/` |

### Step 2: Read Related Source Files

Before generating tests, read:

1. The target class itself
2. Its factory (if model — check `database/factories/`)
3. Related form requests (if controller — check `app/Http/Requests/`)
4. Related policies (if controller — check `app/Policies/`)
5. Route definitions (if controller — check `routes/web.php` or `routes/api.php`)
6. Related Livewire component (if view references `wire:` directives)

### Step 3: Generate Test File

Use the patterns from `references/pest-patterns.md`. Every generated test file must:

- Use `declare(strict_types=1);` at the top
- Import all classes explicitly (no inline class strings)
- Use `it()` syntax, not `test()` — BDD style
- Group related tests with `describe()` blocks
- Include `beforeEach()` for shared setup
- Use factories with states, not manual attribute arrays
- Assert both happy path and error/validation cases

### Step 4: Generate Missing Factories

If the model lacks a factory, generate one at `database/factories/{Model}Factory.php` with
sensible defaults using Faker.

---

## 2. `/test feature` — Feature Tests

### Authentication Patterns

```php
use App\Models\User;

beforeEach(function () {
    $this->user = User::factory()->create();
});

it('requires authentication', function () {
    $this->get(route('dashboard'))
        ->assertRedirect(route('login'));
});

it('allows authenticated users to access the dashboard', function () {
    $this->actingAs($this->user)
        ->get(route('dashboard'))
        ->assertOk();
});
```

### Database Assertions

```php
it('creates a new project', function () {
    $this->actingAs($this->user)
        ->post(route('projects.store'), [
            'name' => 'New Project',
            'description' => 'A test project',
        ])
        ->assertRedirect(route('projects.index'));

    $this->assertDatabaseHas('projects', [
        'name' => 'New Project',
        'user_id' => $this->user->id,
    ]);
});

it('soft deletes a project', function () {
    $project = Project::factory()->for($this->user)->create();

    $this->actingAs($this->user)
        ->delete(route('projects.destroy', $project))
        ->assertRedirect();

    $this->assertSoftDeleted($project);
});
```

### Spatie Permission Role-Based Tests

```php
use Spatie\Permission\Models\Role;

beforeEach(function () {
    $this->admin = User::factory()->create();
    $this->admin->assignRole('admin');

    $this->member = User::factory()->create();
    $this->member->assignRole('member');
});

it('allows admins to access user management', function () {
    $this->actingAs($this->admin)
        ->get(route('admin.users.index'))
        ->assertOk();
});

it('denies members access to user management', function () {
    $this->actingAs($this->member)
        ->get(route('admin.users.index'))
        ->assertForbidden();
});

it('allows users with specific permission', function () {
    $this->member->givePermissionTo('view-reports');

    $this->actingAs($this->member)
        ->get(route('reports.index'))
        ->assertOk();
});
```

### Validation Tests

```php
describe('validation', function () {
    it('requires a name', function () {
        $this->actingAs($this->user)
            ->post(route('projects.store'), [
                'name' => '',
            ])
            ->assertSessionHasErrors('name');
    });

    it('requires name to be unique', function () {
        Project::factory()->create(['name' => 'Existing']);

        $this->actingAs($this->user)
            ->post(route('projects.store'), [
                'name' => 'Existing',
            ])
            ->assertSessionHasErrors('name');
    });

    it('rejects names longer than 255 characters', function () {
        $this->actingAs($this->user)
            ->post(route('projects.store'), [
                'name' => str_repeat('a', 256),
            ])
            ->assertSessionHasErrors('name');
    });
});
```

### API Endpoint Tests

```php
use Laravel\Sanctum\Sanctum;

beforeEach(function () {
    $this->user = User::factory()->create();
    Sanctum::actingAs($this->user);
});

it('lists resources as paginated JSON', function () {
    Project::factory()->count(25)->for($this->user)->create();

    $this->getJson(route('api.projects.index'))
        ->assertOk()
        ->assertJsonStructure([
            'data' => [['id', 'name', 'description', 'created_at']],
            'meta' => ['current_page', 'last_page', 'per_page', 'total'],
        ])
        ->assertJsonCount(15, 'data');
});

it('returns 422 for invalid input', function () {
    $this->postJson(route('api.projects.store'), [])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['name']);
});

it('returns 404 for non-existent resource', function () {
    $this->getJson(route('api.projects.show', 999))
        ->assertNotFound();
});

it('prevents accessing another user resources', function () {
    $otherProject = Project::factory()->create();

    $this->getJson(route('api.projects.show', $otherProject))
        ->assertForbidden();
});
```

---

## 3. `/test unit` — Unit Tests

Unit tests isolate logic from the framework. Place them in `tests/Unit/`.

### Service Tests

```php
use App\Services\InvoiceCalculator;
use App\Models\Invoice;
use App\Models\InvoiceItem;

beforeEach(function () {
    $this->calculator = new InvoiceCalculator();
});

it('calculates subtotal from line items', function () {
    $invoice = Invoice::factory()
        ->has(InvoiceItem::factory()->count(3)->state([
            'quantity' => 2,
            'unit_price' => 1000, // cents
        ]))
        ->create();

    expect($this->calculator->subtotal($invoice))
        ->toBe(6000);
});

it('applies percentage discount correctly', function () {
    $invoice = Invoice::factory()
        ->has(InvoiceItem::factory()->state([
            'quantity' => 1,
            'unit_price' => 10000,
        ]))
        ->create(['discount_percent' => 10]);

    expect($this->calculator->total($invoice))
        ->toBe(9000);
});

it('never returns negative totals', function () {
    $invoice = Invoice::factory()
        ->has(InvoiceItem::factory()->state([
            'quantity' => 1,
            'unit_price' => 100,
        ]))
        ->create(['discount_percent' => 200]);

    expect($this->calculator->total($invoice))
        ->toBe(0);
});
```

### Action Tests

```php
use App\Actions\CreateTeamAction;
use App\Models\User;
use App\Models\Team;

it('creates a team and assigns the creator as owner', function () {
    $user = User::factory()->create();

    $team = (new CreateTeamAction())->execute(
        user: $user,
        name: 'Engineering',
    );

    expect($team)
        ->toBeInstanceOf(Team::class)
        ->name->toBe('Engineering')
        ->owner_id->toBe($user->id);

    expect($user->fresh()->current_team_id)->toBe($team->id);
});
```

### Value Object Tests

```php
use App\ValueObjects\Money;

it('creates from cents', function () {
    $money = Money::fromCents(1500);

    expect($money->cents())->toBe(1500);
    expect($money->dollars())->toBe(15.00);
    expect($money->formatted())->toBe('$15.00');
});

it('adds two money objects', function () {
    $a = Money::fromCents(1000);
    $b = Money::fromCents(500);

    expect($a->add($b)->cents())->toBe(1500);
});

it('prevents negative money', function () {
    Money::fromCents(-100);
})->throws(InvalidArgumentException::class);
```

---

## 4. `/test coverage-check` — Coverage Gap Analysis

### Step 1: Scan Application Code

Inventory all files in:

- `app/Models/`
- `app/Http/Controllers/`
- `app/Services/`
- `app/Actions/`
- `app/Livewire/` or `app/Http/Livewire/`
- `app/Policies/`
- `app/Jobs/`
- `app/Mail/`
- `app/Notifications/`

### Step 2: Scan Existing Tests

Map each test file to its target class. Check for:

| Check | Pass Condition |
|---|---|
| Test file exists | Corresponding test file in `tests/Feature/` or `tests/Unit/` |
| Happy path covered | At least one `assertOk()` or success assertion |
| Validation covered | `assertSessionHasErrors()` or `assertJsonValidationErrors()` for form inputs |
| Auth covered | `assertRedirect(route('login'))` or `assertUnauthorized()` for protected routes |
| Policy covered | `assertForbidden()` for policy-protected actions |
| Factory exists | `database/factories/{Model}Factory.php` exists for each model |

### Step 3: Report

```
Test Coverage Gap Report
========================

Models (8 total):
  ✓ User            — tests/Feature/Models/UserTest.php (12 tests)
  ✓ Project         — tests/Feature/Models/ProjectTest.php (8 tests)
  ✗ Invoice         — NO TEST FILE
  ✗ InvoiceItem     — NO TEST FILE
  ~ Team            — tests/Feature/Models/TeamTest.php (2 tests, missing: relationships, scopes)

Controllers (6 total):
  ✓ ProjectController  — tests/Feature/Http/Controllers/ProjectControllerTest.php (15 tests)
  ✗ InvoiceController  — NO TEST FILE
  ~ TeamController     — missing validation tests, missing policy tests

Livewire (4 total):
  ✓ CreateProject     — tests/Feature/Livewire/CreateProjectTest.php (9 tests)
  ✗ ManageTeamMembers — NO TEST FILE

Factories:
  ✗ Invoice          — database/factories/InvoiceFactory.php MISSING
  ✗ InvoiceItem      — database/factories/InvoiceItemFactory.php MISSING

Coverage: 58% of classes have test files (11/19)
Priority: Invoice, InvoiceItem, ManageTeamMembers (high usage, zero tests)
```

### Step 4: Generate Stubs

For each missing test file, offer to generate a stub with:

- `it('has correct fillable attributes')` for models
- `it('requires authentication')` for controllers
- `it('renders successfully')` for Livewire components
- Appropriate `describe()` groupings

---

## 5. Livewire Component Testing

Read `references/livewire-testing.md` for full patterns. Key principles:

- Always use `Livewire::test(ComponentClass::class)` — never string names
- Test component state with `->assertSet()` and `->assertSee()`
- Test user interactions with `->call()`, `->set()`, `->toggle()`
- Test events with `->assertDispatched()` and `->assertNotDispatched()`
- Test file uploads with `UploadedFile::fake()`
- Test Flux UI components via their rendered output

```php
use Livewire\Livewire;
use App\Livewire\CreateProject;

it('renders the create project form', function () {
    Livewire::test(CreateProject::class)
        ->assertStatus(200)
        ->assertSee('Create Project');
});

it('creates a project when form is submitted', function () {
    $this->actingAs($user = User::factory()->create());

    Livewire::test(CreateProject::class)
        ->set('name', 'My Project')
        ->set('description', 'A great project')
        ->call('save')
        ->assertHasNoErrors()
        ->assertDispatched('project-created');

    $this->assertDatabaseHas('projects', [
        'name' => 'My Project',
        'user_id' => $user->id,
    ]);
});
```

---

## 6. Architecture Testing

Read `references/arch-testing.md` for full patterns. Arch tests enforce project-wide rules
that catch issues before code review.

### Kickoff Baseline Note

Projects using the Kickoff baseline already have Pest installed with arch testing configured.
The file `tests/Arch/ArchTest.php` exists with baseline rules. Extend it — do not replace.

### Common Arch Rules to Add

```php
arch('strict types in all files')
    ->expect('App')
    ->toUseStrictTypes();

arch('no debugging statements')
    ->expect(['dd', 'dump', 'ray', 'var_dump', 'print_r'])
    ->not->toBeUsed();

arch('controllers have correct suffix')
    ->expect('App\Http\Controllers')
    ->toHaveSuffix('Controller');

arch('models extend base model')
    ->expect('App\Models')
    ->toExtend('Illuminate\Database\Eloquent\Model');

arch('no direct DB facade in controllers')
    ->expect('App\Http\Controllers')
    ->not->toUse('Illuminate\Support\Facades\DB');
```

---

## 7. Anti-Patterns to Avoid

When generating tests, never produce code that:

| Anti-Pattern | Why It Is Wrong | Correct Approach |
|---|---|---|
| Testing implementation details | Breaks on refactor, no real confidence | Test behaviour and outcomes |
| Fragile CSS/DOM selectors | `->assertSee('<div class="mt-4">')` breaks on style changes | Assert text content or component state |
| Missing factories | Manual attribute arrays duplicate schema knowledge | Use factories with states |
| Testing framework code | `it('belongsTo returns relationship')` tests Eloquent, not your code | Test business logic that uses the relationship |
| Mocking everything | Over-mocked tests pass but production breaks | Mock only external services (APIs, mail, queues) |
| No assertions | `it('runs without errors', fn() => $this->get('/'))` proves nothing | Always assert specific outcomes |
| Seed-dependent tests | Tests that require `php artisan db:seed` break in isolation | Use factories inside each test |
| Hardcoded IDs | `User::find(1)` assumes database state | Factory-create the record in the test |
| Testing private methods | Accessing privates via reflection is a smell | Test through the public interface |
| Ignoring validation | Only testing happy path misses real bugs | Always test invalid input |

---

## 8. Test File Naming Convention

| Target | Test File Path |
|---|---|
| `App\Models\User` | `tests/Feature/Models/UserTest.php` |
| `App\Http\Controllers\ProjectController` | `tests/Feature/Http/Controllers/ProjectControllerTest.php` |
| `App\Services\InvoiceCalculator` | `tests/Unit/Services/InvoiceCalculatorTest.php` |
| `App\Actions\CreateTeam` | `tests/Unit/Actions/CreateTeamTest.php` |
| `App\Livewire\CreateProject` | `tests/Feature/Livewire/CreateProjectTest.php` |
| `App\Policies\ProjectPolicy` | `tests/Feature/Policies/ProjectPolicyTest.php` |
| `App\Jobs\ProcessInvoice` | `tests/Feature/Jobs/ProcessInvoiceTest.php` |
| `App\Mail\InvoiceCreated` | `tests/Feature/Mail/InvoiceCreatedTest.php` |
| Architecture rules | `tests/Arch/ArchTest.php` (extend existing) |

---

## 9. What a Green Suite Does Not Prove

Three failure modes ship green and are only caught by driving the real page once. When a
feature's behaviour lives in Alpine or in a Flux-rendered element, the test to write is the
one that pins the **markup contract** — so a package upgrade fails CI instead of silently
returning the feature to nothing.

| Assertion | What it actually proves | What it does not |
|---|---|---|
| `assertSee('...')` | The server rendered that string | Nothing about whether the browser does anything with it — a broken Alpine expression, a selector matching zero elements, or an inert `x-cloak` all pass |
| `assertSee` on a Flux control | Flux emitted markup | That your JS can find it. Flux renders `<ui-checkbox>`, not `<input type="checkbox">` — every `input[type=checkbox]` selector matches **zero** and reports a confident, wrong answer |
| A passing test on a `wire:model`-derived counter | The server computed it | That the operator sees it — `wire:model` is deferred, so the value is a round trip behind the UI |

```php
// Pin the marker the JS depends on, so a Flux upgrade fails here and not in production.
it('renders checkboxes as the flux custom element the panel counts', function () {
    Livewire::test(AllowedComponentsPanel::class)
        ->assertSee('data-flux-checkbox', escape: false);
});
```

Related: `actingAs()` sets the user directly on the guard and bypasses session middleware, so
a feature test using it passes even when a route is missing the `web` middleware group. Session
and middleware regressions need a real login flow against a running server.

---

## 10. Suite Performance

Measure before optimising, but these three account for most of what makes a Kickoff suite slow.

### Seeders belong in `$seeder`, never in a hook

A seeder whose output is identical for every test must not run per test.

```php
// tests/TestCase.php — runs once per process as part of migrate:fresh
protected $seeder = AccessControlSeeder::class;
```

`AccessControlSeeder` costs ~645 queries and ~110ms. Called from `beforeEach` it was roughly
**half** the wall clock of a 1400-test suite — 96s down to 43s once moved. Because every test
still runs inside a transaction that rolls back, the visible state is **identical** either way:
the per-test call bought nothing. Check individual files too — a global hook does not stop nine
of them re-seeding on top of it.

### Xdebug must be pinned off

A machine with `xdebug.mode=coverage` in its ini pays roughly **3×** on every run (one file:
13.7s → 5.3s with `XDEBUG_MODE=off`). Pin it in `composer.json` so it cannot be inherited by
accident:

```json
"test": ["@putenv XDEBUG_MODE=off", "@php vendor/bin/pest"]
```

Use the **array + `@putenv`** form, not an inline `VAR=x` prefix: it keeps `@php` (so Composer
picks the PHP binary), works on Windows, and still forwards extra CLI args. And never `php -d`
— ParaTest spawns its workers without the parent's `-d` flags, so only an environment variable
reaches them.

### Test Impact Analysis is not free, and its failure mode is silent

TIA records **per-test** coverage, so it forces a coverage driver on for the whole suite before
it can skip anything.

| | Cold record | Replay |
|---|---|---|
| Xdebug | ~90 min | — |
| pcov | ~72s | ~5s |

Under Xdebug, Composer's default 300-second process timeout kills the record part way through,
leaving `worker-edges-*.json` and **no** `graph.json` — an unusable graph, so the next run
re-records from scratch and hits the same wall, forever. That is the whole of the "ran 30
minutes and never finished" report.

Requirements for a working TIA setup:

- `Composer\Config::disableProcessTimeout` at the head of the script
- `PHP_INI_SCAN_DIR` pointing at a directory containing a pcov ini (environment variable, not `-d`)
- TIA **opt-in** (`composer test-tia`), never the default `composer test` — it has a prerequisite
- `tests/Pest.php` may set `->filtered()`, but deliberately **not** `->locally()` or `->always()`,
  which mark TIA *enabled* and put the record cost on every local run

The graph lives in `~/.pest/tia/<project-key>/`, **not** in the repo — `pest --baseline` prints
the path, so the absence of a `.pest/` directory says nothing. TIA normalises content, so a
comment-only edit correctly yields "No affected tests found"; that is not a bug.

> **Gotcha:** pcov built **static** rather than shared has no `get_module` symbol, and PHP
> rejects it with *"Invalid library (maybe not a PHP library)"* — which reads exactly like
> "this extension does not support your PHP version" and is not that. Configure with
> `--enable-pcov=shared` and check `nm -g modules/pcov.so | grep get_module` before installing.

### SQLite-in-memory is the most permissive engine there is

A green suite is not evidence a migration is portable. Anything touching indexes, foreign keys,
or column modification needs a run against the real engine — see the database-conventions
reference in `project-laravel`.

---

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The happy path passes, that's the important one" | The happy path is what you already know works. Every production incident is an unhandled path. |
| "It's too simple to need a test" | Then the test is one line and takes thirty seconds. Cost is not the real objection. |
| "Coverage is at 85%, we're fine" | Coverage measures lines executed, not assertions made. A test with no assertion still counts. |
| "I'll add tests once the feature settles" | The feature settles when it ships, and then nobody is paid to go back. |
| "Mocking it properly takes too long" | If a unit is hard to test, that is the design telling you something. Fix the seam, not the test. |
| "The test is flaky, I'll add a retry" | A retry hides a race that production will hit at higher concurrency. Find the shared state. |
| "I tested it manually" | Manual testing is not repeatable, does not run in CI, and does not protect the next person's change. |
| "Authorization is covered — the owner can view it" | The positive case passes even when the check is missing entirely. The test that matters asserts `403` for the wrong user. |
| "Arch tests are just ceremony" | Arch tests are the only thing that catches a convention breaking in a file nobody reviewed. |

## Red Flags

- A test with no assertion, or one that only asserts `assertTrue(true)`
- `->skip()` or `->markTestIncomplete()` added during a bug fix
- `sleep()` in a test
- Assertions on `id === 1` or on auto-increment ordering
- `now()` asserted directly instead of `Carbon::setTestNow()`
- Real `Mail`, `Http`, `Queue` or `Storage` used where a fake exists
- Tests that pass alone and fail in the suite (or vice versa)
- A new endpoint with an "owner can access" test and no "other user cannot" test
- A bug fix PR with no regression test and no explanation of why one was impossible
- Factories creating dozens of rows per test when two would do

## Verification

- [ ] `./vendor/bin/pest` green on a clean checkout
- [ ] `./vendor/bin/pest --order-by=random` green — no order dependence
- [ ] Every new endpoint has a negative authorization test asserting `403`/`401`
- [ ] Every bug fix has a test that fails when the fix is reverted
- [ ] No `sleep()`, no `->skip()`, no real network or mail in the suite
- [ ] Arch tests pass and cover the new namespaces
- [ ] Suite runtime did not materially regress — if it did, say by how much and why

---

## Reference Files

| File | Read When |
|---|---|
| `references/pest-patterns.md` | Generating any Pest test — assertions, datasets, hooks, mocks |
| `references/livewire-testing.md` | Testing Livewire components, Flux UI, events, file uploads |
| `references/arch-testing.md` | Adding or extending architecture test rules |
