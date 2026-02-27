# Orchestra Testbench Patterns for Package Testing

## TestCase Base Class

Every package test suite needs a base TestCase that extends Orchestra Testbench:

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Tests;

use Orchestra\Testbench\TestCase as Orchestra;
use Vendor\PackageName\PackageNameServiceProvider;

class TestCase extends Orchestra
{
    protected function setUp(): void
    {
        parent::setUp();

        // Shared setup for all tests — run factories, seeders, etc.
    }

    /**
     * Register package service providers.
     */
    protected function getPackageProviders($app): array
    {
        return [
            PackageNameServiceProvider::class,
        ];
    }

    /**
     * Register package aliases/facades.
     */
    protected function getPackageAliases($app): array
    {
        return [
            'PackageName' => \Vendor\PackageName\Facades\PackageName::class,
        ];
    }

    /**
     * Define environment setup.
     */
    protected function getEnvironmentSetUp($app): void
    {
        // Use SQLite in-memory for testing
        config()->set('database.default', 'testing');
        config()->set('database.connections.testing', [
            'driver' => 'sqlite',
            'database' => ':memory:',
            'prefix' => '',
        ]);

        // Set package-specific config for testing
        config()->set('package-name.enabled', true);
    }

    /**
     * Load package migrations for testing.
     */
    protected function defineDatabaseMigrations(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
    }
}
```

---

## Pest.php Configuration

```php
<?php

declare(strict_types=1);

use Vendor\PackageName\Tests\TestCase;

/*
|--------------------------------------------------------------------------
| Test Case
|--------------------------------------------------------------------------
|
| The closure passed to `uses()` binds the TestCase to all tests in
| the specified directory. Feature tests get the full Testbench
| application; Unit tests run without the framework.
|
*/

uses(TestCase::class)->in('Feature');
```

---

## Environment Setup Patterns

### Setting Application Config

```php
protected function getEnvironmentSetUp($app): void
{
    // Database
    config()->set('database.default', 'testing');
    config()->set('database.connections.testing', [
        'driver' => 'sqlite',
        'database' => ':memory:',
        'prefix' => '',
    ]);

    // Application config
    config()->set('app.key', 'base64:' . base64_encode(random_bytes(32)));

    // Package config overrides for testing
    config()->set('package-name.table_name', 'package_items');
    config()->set('package-name.enabled', true);
}
```

### Using MySQL/PostgreSQL for Testing

When SQLite is insufficient (JSON columns, full-text search, etc.):

```php
protected function getEnvironmentSetUp($app): void
{
    config()->set('database.default', 'mysql');
    config()->set('database.connections.mysql', [
        'driver' => 'mysql',
        'host' => env('DB_HOST', '127.0.0.1'),
        'port' => env('DB_PORT', '3306'),
        'database' => env('DB_DATABASE', 'package_testing'),
        'username' => env('DB_USERNAME', 'root'),
        'password' => env('DB_PASSWORD', ''),
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix' => '',
    ]);
}
```

---

## Migration Handling

### Loading Package Migrations

```php
protected function defineDatabaseMigrations(): void
{
    $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
}
```

### Loading Laravel Core Migrations (Users Table, etc.)

When your package needs the `users` table or other Laravel defaults:

```php
protected function defineDatabaseMigrations(): void
{
    // Load Laravel's default migrations (creates users, password_resets, etc.)
    $this->loadLaravelMigrations();

    // Load package migrations
    $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
}
```

### Running Migrations in setUp

```php
protected function setUp(): void
{
    parent::setUp();

    // Alternatively, run specific migration files
    $this->artisan('migrate', ['--database' => 'testing'])->run();
}
```

### Using RefreshDatabase Trait

For tests that need a clean database state per test:

```php
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(TestCase::class, RefreshDatabase::class)->in('Feature');
```

---

## Factory Support

### Defining Factories for Package Models

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Vendor\PackageName\Models\PackageModel;

class PackageModelFactory extends Factory
{
    protected $model = PackageModel::class;

    public function definition(): array
    {
        return [
            'name' => fake()->words(3, true),
            'description' => fake()->sentence(),
            'is_active' => true,
            'meta' => [],
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }

    public function withMeta(array $meta): static
    {
        return $this->state(fn (array $attributes) => [
            'meta' => $meta,
        ]);
    }
}
```

### Connecting Factory to Model

In the package model, use the `HasFactory` trait and specify the factory:

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Vendor\PackageName\Database\Factories\PackageModelFactory;

class PackageModel extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'is_active',
        'meta',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'meta' => 'array',
    ];

    protected static function newFactory(): PackageModelFactory
    {
        return PackageModelFactory::new();
    }
}
```

### Using Factories in Tests

```php
use Vendor\PackageName\Models\PackageModel;

it('creates a model using the factory', function () {
    $model = PackageModel::factory()->create();

    expect($model)
        ->toBeInstanceOf(PackageModel::class)
        ->name->not->toBeEmpty()
        ->is_active->toBeTrue();

    $this->assertDatabaseHas('package_items', [
        'id' => $model->id,
    ]);
});

it('creates an inactive model', function () {
    $model = PackageModel::factory()->inactive()->create();

    expect($model->is_active)->toBeFalse();
});
```

---

## Testing Service Providers

### Provider Loads Correctly

```php
<?php

declare(strict_types=1);

use Vendor\PackageName\PackageName;
use Vendor\PackageName\PackageNameServiceProvider;

it('registers the service provider', function () {
    expect($this->app->getProviders(PackageNameServiceProvider::class))
        ->not->toBeEmpty();
});

it('resolves the main class from the container', function () {
    $instance = $this->app->make(PackageName::class);

    expect($instance)->toBeInstanceOf(PackageName::class);
});

it('resolves the same instance as a singleton', function () {
    $instance1 = $this->app->make(PackageName::class);
    $instance2 = $this->app->make(PackageName::class);

    expect($instance1)->toBe($instance2);
});

it('merges package config with application config', function () {
    expect(config('package-name'))->toBeArray();
    expect(config('package-name.enabled'))->toBeBool();
});
```

### Config Publishing

```php
it('publishes config file', function () {
    $this->artisan('vendor:publish', [
        '--tag' => 'package-name-config',
    ])->assertSuccessful();
});
```

---

## Testing Commands

### Command Registration

```php
use Illuminate\Console\Application as Artisan;

it('registers the install command', function () {
    $commands = Artisan::starting(function ($artisan) {});

    $this->artisan('package-name:install')
        ->assertSuccessful();
});
```

### Command Execution

```php
it('runs the install command successfully', function () {
    $this->artisan('package-name:install')
        ->expectsConfirmation('Would you like to run migrations now?', 'yes')
        ->assertSuccessful();
});

it('runs the process command with force flag', function () {
    $this->artisan('package-name:process', ['--force' => true])
        ->assertSuccessful();
});

it('shows dry run output', function () {
    $this->artisan('package-name:process', ['--dry-run' => true])
        ->expectsOutput('Dry run mode — no changes will be made.')
        ->assertSuccessful();
});
```

---

## Testing Routes

### Route Registration

```php
use Illuminate\Support\Facades\Route;

it('registers package routes', function () {
    $routes = Route::getRoutes();

    expect($routes->getByName('package-name.index'))->not->toBeNull();
    expect($routes->getByName('package-name.store'))->not->toBeNull();
    expect($routes->getByName('package-name.show'))->not->toBeNull();
});
```

### Route Responses

```php
it('returns a successful response for the index route', function () {
    $this->get(route('package-name.index'))
        ->assertOk();
});

it('applies the correct middleware', function () {
    $route = Route::getRoutes()->getByName('package-name.index');

    expect($route->middleware())->toContain('web');
});
```

### Route with Authentication

When testing routes that require authentication, create a User model stub or use
Testbench's built-in user support:

```php
use Illuminate\Foundation\Auth\User as Authenticatable;

// Create a minimal user for testing
$user = (new class extends Authenticatable {
    protected $table = 'users';
})->forceFill([
    'id' => 1,
    'name' => 'Test User',
    'email' => 'test@example.com',
]);

it('requires authentication for protected routes', function () use ($user) {
    $this->get(route('package-name.store'))
        ->assertRedirect();

    $this->actingAs($user)
        ->get(route('package-name.store'))
        ->assertOk();
});
```

---

## Testing Views

### View Existence

```php
it('loads package views', function () {
    $view = view('package-name::index');

    expect($view->getPath())->toContain('views/index');
});
```

### View Rendering

```php
it('renders the index view with data', function () {
    $view = $this->view('package-name::index', [
        'items' => collect(['Item 1', 'Item 2']),
    ]);

    $view->assertSee('Item 1');
    $view->assertSee('Item 2');
});
```

### View Components

```php
it('renders the alert component', function () {
    $view = $this->blade(
        '<x-package-name::alert type="warning">Watch out!</x-package-name::alert>'
    );

    $view->assertSee('Watch out!');
    $view->assertSee('warning');
});
```

---

## Testing Facades

```php
use Vendor\PackageName\Facades\PackageName;

it('resolves the facade', function () {
    expect(PackageName::getFacadeRoot())
        ->toBeInstanceOf(\Vendor\PackageName\PackageName::class);
});

it('calls methods through the facade', function () {
    $result = PackageName::doSomething('test input');

    expect($result)->not->toBeNull();
});
```

---

## Testing Events

### Dispatching Events

```php
use Illuminate\Support\Facades\Event;
use Vendor\PackageName\Events\ItemCreated;

it('dispatches an event when an item is created', function () {
    Event::fake([ItemCreated::class]);

    // Trigger the action that dispatches the event
    PackageName::createItem(['name' => 'Test']);

    Event::assertDispatched(ItemCreated::class, function ($event) {
        return $event->item->name === 'Test';
    });
});

it('does not dispatch event on validation failure', function () {
    Event::fake([ItemCreated::class]);

    try {
        PackageName::createItem(['name' => '']);
    } catch (\Exception $e) {
        // Expected
    }

    Event::assertNotDispatched(ItemCreated::class);
});
```

---

## Testing with Multiple Service Providers

When your package depends on other packages:

```php
protected function getPackageProviders($app): array
{
    return [
        \Spatie\Permission\PermissionServiceProvider::class,
        \Vendor\PackageName\PackageNameServiceProvider::class,
    ];
}
```

---

## Testing Middleware

```php
use Illuminate\Http\Request;
use Vendor\PackageName\Http\Middleware\PackageMiddleware;

it('allows requests when package is enabled', function () {
    config()->set('package-name.enabled', true);

    $request = Request::create('/test', 'GET');
    $middleware = new PackageMiddleware();

    $response = $middleware->handle($request, function ($req) {
        return response('OK');
    });

    expect($response->getContent())->toBe('OK');
});

it('rejects requests when package is disabled', function () {
    config()->set('package-name.enabled', false);

    $request = Request::create('/test', 'GET');
    $middleware = new PackageMiddleware();

    $response = $middleware->handle($request, function ($req) {
        return response('OK');
    });

    expect($response->getStatusCode())->toBe(403);
});
```

---

## Testing Jobs and Queues

```php
use Illuminate\Support\Facades\Queue;
use Vendor\PackageName\Jobs\ProcessItem;

it('dispatches a job when processing', function () {
    Queue::fake();

    PackageName::processAsync($item);

    Queue::assertPushed(ProcessItem::class, function ($job) use ($item) {
        return $job->item->id === $item->id;
    });
});

it('processes the job successfully', function () {
    $item = PackageModel::factory()->create();
    $job = new ProcessItem($item);

    $job->handle();

    expect($item->fresh()->processed_at)->not->toBeNull();
});
```

---

## GitHub Actions Workflow for Package Tests

```yaml
# .github/workflows/run-tests.yml
name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        php: [8.2, 8.3, 8.4]
        laravel: ['11.*', '12.*']
        include:
          - laravel: '11.*'
            testbench: '9.*'
          - laravel: '12.*'
            testbench: '10.*'

    name: PHP ${{ matrix.php }} - Laravel ${{ matrix.laravel }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite
          coverage: none

      - name: Install dependencies
        run: |
          composer require "laravel/framework:${{ matrix.laravel }}" "orchestra/testbench:${{ matrix.testbench }}" --no-interaction --no-update
          composer update --prefer-stable --prefer-dist --no-interaction

      - name: Run tests
        run: vendor/bin/pest
```

---

## Common Pitfalls

| Pitfall | Solution |
|---|---|
| `Class not found` errors | Ensure `autoload-dev` in composer.json points to `tests/` and run `composer dump-autoload` |
| Config not available in tests | Call `$this->mergeConfigFrom()` in `register()`, not `boot()` |
| Migrations not running | Use `defineDatabaseMigrations()` method, not manual `artisan migrate` |
| SQLite incompatibilities | Some column types (JSON, enum) behave differently — consider MySQL for complex schemas |
| Factory not found | Override `newFactory()` in the model to point to the correct factory class |
| Routes not registered | Ensure `loadRoutesFrom()` is called in `boot()` and config allows routes |
| Views not found | Check the namespace matches: `package-name::view-name` must match `loadViewsFrom()` namespace |
| Tests polluting each other | Use `RefreshDatabase` trait or `LazilyRefreshDatabase` for isolation |
