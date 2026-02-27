---
name: pest-testing
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, pest, testing, livewire]
description: >
  Comprehensive Pest PHP testing skill for Laravel projects — auto-detects models, controllers,
  services, and Livewire components then scaffolds matching Pest test files with proper assertions,
  factories, and database testing patterns. Supports feature tests with actingAs(), API endpoint
  tests, Livewire::test() component testing, Spatie Permission role-based helpers, architecture
  testing (extending Kickoff baseline), and coverage gap analysis. Use this skill whenever the
  user asks to write tests, generate test files, scaffold test suites, check test coverage, or
  create architecture rules — including: "write tests for this model", "test this controller",
  "generate feature tests", "add Livewire tests", "scaffold Pest tests", "check test coverage",
  "add arch tests", "test this API endpoint", "tulis test untuk model ni", "buat feature test",
  "tambah test untuk controller", "scaffold test suite", "semak coverage", "buat arch test",
  or "test Livewire component ni". Assumes Pest is already installed with arch testing configured
  (Kickoff baseline).
---

# Pest Testing Skill

Auto-detect Laravel application components and scaffold production-quality Pest test files —
feature tests, unit tests, Livewire component tests, API tests, and architecture rules. Designed
for projects using the Kickoff baseline where Pest and arch testing are pre-configured.

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

## Reference Files

| File | Read When |
|---|---|
| `references/pest-patterns.md` | Generating any Pest test — assertions, datasets, hooks, mocks |
| `references/livewire-testing.md` | Testing Livewire components, Flux UI, events, file uploads |
| `references/arch-testing.md` | Adding or extending architecture test rules |
