# Pest PHP Testing Patterns

Comprehensive reference for Pest assertions, datasets, hooks, database testing, factory patterns,
and mocking strategies in Laravel projects.

---

## Core Syntax

### Test Declaration

Always use `it()` (BDD style) over `test()`:

```php
// Correct
it('creates a user with valid data', function () {
    // ...
});

// Avoid
test('creates a user with valid data', function () {
    // ...
});
```

### Grouping with describe()

```php
describe('ProjectController@store', function () {
    it('creates a project', function () { /* ... */ });
    it('validates required fields', function () { /* ... */ });
    it('requires authentication', function () { /* ... */ });
});

describe('ProjectController@update', function () {
    it('updates the project name', function () { /* ... */ });
    it('prevents non-owners from updating', function () { /* ... */ });
});
```

---

## Hooks

### beforeEach / afterEach

```php
beforeEach(function () {
    $this->user = User::factory()->create();
    $this->project = Project::factory()->for($this->user)->create();
});

afterEach(function () {
    Storage::disk('local')->deleteDirectory('test-uploads');
});
```

### beforeAll / afterAll

Use sparingly — runs once per file, not per test. Does not have access to `$this`.

```php
beforeAll(function () {
    // Seed roles/permissions once for the entire file
    // Note: this runs outside the database transaction
});
```

---

## Expectation API

### Basic Expectations

```php
expect($value)->toBe(42);                  // Strict equality (===)
expect($value)->toEqual(42);               // Loose equality (==)
expect($value)->toBeTrue();
expect($value)->toBeFalse();
expect($value)->toBeNull();
expect($value)->toBeEmpty();
expect($value)->not->toBeEmpty();
expect($value)->toBeInstanceOf(User::class);
```

### String Expectations

```php
expect($name)->toBeString();
expect($name)->toStartWith('Team');
expect($name)->toEndWith('Project');
expect($name)->toContain('keyword');
expect($name)->toMatch('/^[A-Z]/');
```

### Array / Collection Expectations

```php
expect($array)->toBeArray();
expect($array)->toHaveCount(3);
expect($array)->toContain('value');
expect($array)->toHaveKey('name');
expect($array)->toHaveKeys(['name', 'email', 'role']);

expect($collection)->toBeInstanceOf(Collection::class);
expect($collection)->toHaveCount(5);
expect($collection)->each->toBeInstanceOf(User::class);
```

### Chained Higher-Order Expectations

```php
expect($user)
    ->name->toBe('John')
    ->email->toEndWith('@example.com')
    ->is_admin->toBeFalse()
    ->teams->toHaveCount(2);
```

### Exception Expectations

```php
it('throws on invalid input', function () {
    $this->service->process(-1);
})->throws(InvalidArgumentException::class);

it('throws with specific message', function () {
    $this->service->process(-1);
})->throws(InvalidArgumentException::class, 'Amount must be positive');
```

---

## Datasets

### Inline Datasets

```php
it('validates email format', function (string $email) {
    $this->postJson(route('register'), ['email' => $email])
        ->assertJsonValidationErrors('email');
})->with([
    'missing @' => ['invalid-email'],
    'missing domain' => ['user@'],
    'spaces' => ['user @example.com'],
    'empty string' => [''],
]);
```

### Named Datasets

```php
dataset('invalid emails', [
    'missing @' => ['invalid-email'],
    'missing domain' => ['user@'],
    'double @' => ['user@@example.com'],
]);

it('rejects invalid emails', function (string $email) {
    // ...
})->with('invalid emails');
```

### Lazy Datasets

```php
dataset('users', function () {
    yield 'admin' => [fn () => User::factory()->create(['role' => 'admin'])];
    yield 'member' => [fn () => User::factory()->create(['role' => 'member'])];
});
```

### Combined Datasets

```php
it('applies role permissions correctly', function (string $role, string $route, int $status) {
    $user = User::factory()->create();
    $user->assignRole($role);

    $this->actingAs($user)
        ->get(route($route))
        ->assertStatus($status);
})->with([
    'admin can access users' => ['admin', 'admin.users.index', 200],
    'member cannot access users' => ['member', 'admin.users.index', 403],
    'admin can access settings' => ['admin', 'admin.settings', 200],
    'member cannot access settings' => ['member', 'admin.settings', 403],
]);
```

---

## Database Testing Patterns

### RefreshDatabase

Every feature test file should use `RefreshDatabase` (Pest auto-applies it via `Pest.php`).

```php
// tests/Pest.php
uses(Tests\TestCase::class, Illuminate\Foundation\Testing\RefreshDatabase::class)->in('Feature');
uses(Tests\TestCase::class)->in('Unit');
```

### Common Database Assertions

```php
// Record exists
$this->assertDatabaseHas('users', [
    'email' => 'john@example.com',
]);

// Record does not exist
$this->assertDatabaseMissing('users', [
    'email' => 'deleted@example.com',
]);

// Record count
$this->assertDatabaseCount('users', 5);

// Soft delete
$this->assertSoftDeleted($user);
$this->assertNotSoftDeleted($user);

// Model was deleted
$this->assertModelMissing($user);

// Model exists (refreshed from DB)
$this->assertModelExists($user);
```

### Testing Eloquent Relationships

```php
it('has many projects', function () {
    $user = User::factory()
        ->has(Project::factory()->count(3))
        ->create();

    expect($user->projects)
        ->toHaveCount(3)
        ->each->toBeInstanceOf(Project::class);
});

it('belongs to a team', function () {
    $team = Team::factory()->create();
    $user = User::factory()->for($team)->create();

    expect($user->team)
        ->toBeInstanceOf(Team::class)
        ->id->toBe($team->id);
});
```

### Testing Scopes

```php
it('filters active projects', function () {
    Project::factory()->count(3)->create(['status' => 'active']);
    Project::factory()->count(2)->create(['status' => 'archived']);

    expect(Project::active()->count())->toBe(3);
});
```

### Testing Casts and Accessors

```php
it('casts settings to array', function () {
    $user = User::factory()->create([
        'settings' => ['theme' => 'dark', 'locale' => 'en'],
    ]);

    expect($user->settings)
        ->toBeArray()
        ->toHaveKey('theme', 'dark');
});

it('formats full name accessor', function () {
    $user = User::factory()->create([
        'first_name' => 'John',
        'last_name' => 'Doe',
    ]);

    expect($user->full_name)->toBe('John Doe');
});
```

---

## Factory Patterns

### Basic Factory Usage

```php
// Single model
$user = User::factory()->create();

// Multiple models
$users = User::factory()->count(5)->create();

// With specific attributes
$user = User::factory()->create([
    'name' => 'John Doe',
    'email' => 'john@example.com',
]);
```

### Factory States

```php
// In UserFactory.php
public function admin(): static
{
    return $this->state(fn (array $attributes) => [
        'role' => 'admin',
    ]);
}

public function unverified(): static
{
    return $this->state(fn (array $attributes) => [
        'email_verified_at' => null,
    ]);
}

// In test
$admin = User::factory()->admin()->create();
$unverified = User::factory()->unverified()->create();
```

### Factory Relationships

```php
// Has many
$user = User::factory()
    ->has(Project::factory()->count(3))
    ->create();

// Belongs to
$project = Project::factory()
    ->for(User::factory())
    ->create();

// Has many with specific state
$user = User::factory()
    ->has(
        Project::factory()
            ->count(2)
            ->state(['status' => 'active']),
        'projects'
    )
    ->create();

// Polymorphic
$comment = Comment::factory()
    ->for(Post::factory(), 'commentable')
    ->create();
```

### Factory Sequences

```php
$users = User::factory()
    ->count(3)
    ->sequence(
        ['role' => 'admin'],
        ['role' => 'editor'],
        ['role' => 'viewer'],
    )
    ->create();
```

### Factory Callbacks

```php
// In factory definition
public function configure(): static
{
    return $this->afterCreating(function (User $user) {
        $user->assignRole('member');
    });
}
```

---

## Mock Patterns

### Mocking External Services

```php
use App\Services\PaymentGateway;

it('processes payment through gateway', function () {
    $mock = $this->mock(PaymentGateway::class);
    $mock->shouldReceive('charge')
        ->once()
        ->with(1000, 'tok_visa')
        ->andReturn(new PaymentResult(success: true, transactionId: 'tx_123'));

    $this->actingAs($this->user)
        ->post(route('payments.store'), [
            'amount' => 1000,
            'token' => 'tok_visa',
        ])
        ->assertRedirect()
        ->assertSessionHas('success');
});
```

### Faking Laravel Services

```php
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Http;

// Mail
Mail::fake();
// ... perform action ...
Mail::assertSent(InvoiceMail::class, function ($mail) {
    return $mail->hasTo('user@example.com');
});
Mail::assertNotSent(InvoiceMail::class);

// Notification
Notification::fake();
// ... perform action ...
Notification::assertSentTo($user, InvoiceNotification::class);
Notification::assertCount(1);

// Queue
Queue::fake();
// ... perform action ...
Queue::assertPushed(ProcessInvoice::class);
Queue::assertPushedOn('invoices', ProcessInvoice::class);

// Event
Event::fake();
// ... perform action ...
Event::assertDispatched(OrderCreated::class);
Event::assertNotDispatched(OrderCancelled::class);

// Storage
Storage::fake('s3');
// ... upload file ...
Storage::disk('s3')->assertExists('invoices/invoice-001.pdf');

// HTTP
Http::fake([
    'api.example.com/*' => Http::response(['data' => 'value'], 200),
    'failing.com/*' => Http::response(null, 500),
]);
// ... perform action ...
Http::assertSent(function ($request) {
    return $request->url() === 'https://api.example.com/users';
});
```

### Partial Mocks (Spy)

```php
$spy = $this->spy(AnalyticsService::class);

$this->actingAs($this->user)
    ->post(route('projects.store'), ['name' => 'Test']);

$spy->shouldHaveReceived('track')
    ->once()
    ->with('project_created', Mockery::type('array'));
```

### Time Manipulation

```php
use Illuminate\Support\Carbon;

it('expires invitations after 7 days', function () {
    $invitation = Invitation::factory()->create();

    Carbon::setTestNow(now()->addDays(8));

    expect($invitation->fresh()->isExpired())->toBeTrue();
});

// Alternative using travel()
it('expires invitations after 7 days', function () {
    $invitation = Invitation::factory()->create();

    $this->travel(8)->days();

    expect($invitation->fresh()->isExpired())->toBeTrue();
});
```

---

## HTTP Testing Patterns

### Response Assertions

```php
$response = $this->get('/dashboard');
$response->assertOk();                    // 200
$response->assertCreated();               // 201
$response->assertNoContent();             // 204
$response->assertRedirect();              // 3xx
$response->assertRedirect(route('home')); // Redirect to specific URL
$response->assertNotFound();              // 404
$response->assertForbidden();             // 403
$response->assertUnauthorized();          // 401
$response->assertUnprocessable();         // 422
```

### View Assertions

```php
$response->assertViewIs('projects.index');
$response->assertViewHas('projects');
$response->assertViewHas('projects', function ($projects) {
    return $projects->count() === 5;
});
```

### Session Assertions

```php
$response->assertSessionHas('success', 'Project created.');
$response->assertSessionHasErrors(['name', 'email']);
$response->assertSessionHasErrors([
    'name' => 'The name field is required.',
]);
$response->assertSessionDoesntHaveErrors();
```

### JSON Assertions

```php
$response->assertJson(['status' => 'ok']);
$response->assertJsonPath('data.name', 'John');
$response->assertJsonCount(3, 'data');
$response->assertJsonStructure([
    'data' => [
        '*' => ['id', 'name', 'email'],
    ],
]);
$response->assertJsonFragment(['name' => 'John']);
$response->assertJsonMissing(['role' => 'admin']);
```

---

## File Upload Testing

```php
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

it('uploads an avatar', function () {
    Storage::fake('public');

    $file = UploadedFile::fake()->image('avatar.jpg', 200, 200);

    $this->actingAs($this->user)
        ->post(route('profile.avatar'), ['avatar' => $file])
        ->assertRedirect();

    Storage::disk('public')->assertExists('avatars/' . $file->hashName());
});

it('rejects non-image files', function () {
    Storage::fake('public');

    $file = UploadedFile::fake()->create('document.pdf', 1024);

    $this->actingAs($this->user)
        ->post(route('profile.avatar'), ['avatar' => $file])
        ->assertSessionHasErrors('avatar');
});

it('rejects files exceeding size limit', function () {
    Storage::fake('public');

    $file = UploadedFile::fake()->image('large.jpg')->size(5120); // 5MB

    $this->actingAs($this->user)
        ->post(route('profile.avatar'), ['avatar' => $file])
        ->assertSessionHasErrors('avatar');
});
```

---

## Pest Configuration

### tests/Pest.php

```php
<?php

declare(strict_types=1);

use Illuminate\Foundation\Testing\RefreshDatabase;

uses(Tests\TestCase::class, RefreshDatabase::class)->in('Feature');
uses(Tests\TestCase::class)->in('Unit');
```

### Running Tests

```bash
# Run all tests
php artisan test

# Run specific file
php artisan test tests/Feature/Models/UserTest.php

# Run specific test by name
php artisan test --filter="creates a project"

# Run with coverage
php artisan test --coverage --min=80

# Run in parallel
php artisan test --parallel

# Run only arch tests
php artisan test tests/Arch/
```
