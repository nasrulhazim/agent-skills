# Laravel Package Structure Reference

## Complete Directory Structure

```
packages/vendor/package-name/
├── src/
│   ├── PackageNameServiceProvider.php
│   ├── PackageName.php                    # Main class (facade accessor)
│   ├── Facades/
│   │   └── PackageName.php
│   ├── Actions/                           # Single-purpose action classes
│   ├── Concerns/                          # Traits for shared behaviour
│   ├── Contracts/                         # Interfaces
│   ├── Events/                            # Package events
│   ├── Exceptions/                        # Package-specific exceptions
│   ├── Http/
│   │   ├── Controllers/
│   │   └── Middleware/
│   ├── Models/                            # Eloquent models
│   ├── Commands/                          # Artisan commands
│   └── Support/                           # Helper classes
├── config/
│   └── package-name.php
├── database/
│   ├── factories/
│   └── migrations/
│       └── create_package_table.php.stub
├── resources/
│   └── views/
│       └── .gitkeep
├── routes/
│   └── web.php
├── tests/
│   ├── Pest.php
│   ├── TestCase.php
│   └── Feature/
│       ├── ServiceProviderTest.php
│       └── .gitkeep
├── stubs/                                 # Publishable stubs
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── composer.json
└── phpunit.xml
```

---

## composer.json Template

```json
{
    "name": "vendor/package-name",
    "description": "A short description of the package.",
    "keywords": [
        "laravel",
        "php",
        "package-name"
    ],
    "homepage": "https://github.com/vendor/package-name",
    "license": "MIT",
    "authors": [
        {
            "name": "Author Name",
            "email": "author@example.com",
            "role": "Developer"
        }
    ],
    "require": {
        "php": "^8.4",
        "illuminate/contracts": "^12.0",
        "illuminate/support": "^12.0"
    },
    "require-dev": {
        "laravel/pint": "^1.0",
        "orchestra/testbench": "^10.0",
        "pestphp/pest": "^3.0",
        "pestphp/pest-plugin-laravel": "^3.0"
    },
    "autoload": {
        "psr-4": {
            "Vendor\\PackageName\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Vendor\\PackageName\\Tests\\": "tests/"
        }
    },
    "scripts": {
        "test": "vendor/bin/pest",
        "test-coverage": "vendor/bin/pest --coverage",
        "format": "vendor/bin/pint",
        "format-test": "vendor/bin/pint --test"
    },
    "extra": {
        "laravel": {
            "providers": [
                "Vendor\\PackageName\\PackageNameServiceProvider"
            ],
            "aliases": {
                "PackageName": "Vendor\\PackageName\\Facades\\PackageName"
            }
        }
    },
    "config": {
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true
        }
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}
```

---

## ServiceProvider Patterns

### Full-Featured ServiceProvider

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName;

use Illuminate\Support\ServiceProvider;
use Vendor\PackageName\Commands\InstallCommand;
use Vendor\PackageName\Commands\PackageCommand;

class PackageNameServiceProvider extends ServiceProvider
{
    /**
     * Register any package services.
     */
    public function register(): void
    {
        $this->mergeConfigFrom(
            __DIR__ . '/../config/package-name.php',
            'package-name'
        );

        $this->app->singleton(PackageName::class, function ($app) {
            return new PackageName(
                config('package-name')
            );
        });

        $this->app->alias(PackageName::class, 'package-name');
    }

    /**
     * Bootstrap any package services.
     */
    public function boot(): void
    {
        $this->registerPublishing();
        $this->registerCommands();
        $this->registerRoutes();
        $this->registerViews();
        $this->registerMigrations();
    }

    /**
     * Register the package's publishable resources.
     */
    protected function registerPublishing(): void
    {
        if (! $this->app->runningInConsole()) {
            return;
        }

        $this->publishes([
            __DIR__ . '/../config/package-name.php' => config_path('package-name.php'),
        ], 'package-name-config');

        $this->publishes([
            __DIR__ . '/../database/migrations/' => database_path('migrations'),
        ], 'package-name-migrations');

        $this->publishes([
            __DIR__ . '/../resources/views' => resource_path('views/vendor/package-name'),
        ], 'package-name-views');

        $this->publishes([
            __DIR__ . '/../stubs/' => base_path('stubs'),
        ], 'package-name-stubs');
    }

    /**
     * Register the package's Artisan commands.
     */
    protected function registerCommands(): void
    {
        if (! $this->app->runningInConsole()) {
            return;
        }

        $this->commands([
            InstallCommand::class,
            PackageCommand::class,
        ]);
    }

    /**
     * Register the package's routes.
     */
    protected function registerRoutes(): void
    {
        $this->loadRoutesFrom(__DIR__ . '/../routes/web.php');
    }

    /**
     * Register the package's views.
     */
    protected function registerViews(): void
    {
        $this->loadViewsFrom(__DIR__ . '/../resources/views', 'package-name');
    }

    /**
     * Register the package's migrations.
     */
    protected function registerMigrations(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
    }
}
```

### Minimal ServiceProvider (Config-Only Package)

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName;

use Illuminate\Support\ServiceProvider;

class PackageNameServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->mergeConfigFrom(
            __DIR__ . '/../config/package-name.php',
            'package-name'
        );

        $this->app->singleton(PackageName::class, function ($app) {
            return new PackageName(config('package-name'));
        });
    }

    public function boot(): void
    {
        if ($this->app->runningInConsole()) {
            $this->publishes([
                __DIR__ . '/../config/package-name.php' => config_path('package-name.php'),
            ], 'package-name-config');
        }
    }
}
```

---

## Facade Patterns

### Standard Facade

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Facades;

use Illuminate\Support\Facades\Facade;

/**
 * @method static mixed doSomething(string $input)
 * @method static self configure(array $options)
 *
 * @see \Vendor\PackageName\PackageName
 */
class PackageName extends Facade
{
    protected static function getFacadeAccessor(): string
    {
        return \Vendor\PackageName\PackageName::class;
    }
}
```

### Main Class (Facade Accessor)

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName;

class PackageName
{
    public function __construct(
        protected array $config = []
    ) {}

    public function doSomething(string $input): mixed
    {
        // Implementation
    }

    public function configure(array $options): self
    {
        $this->config = array_merge($this->config, $options);

        return $this;
    }
}
```

---

## Config File Template

```php
<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Package Name Configuration
    |--------------------------------------------------------------------------
    |
    | Configure the behaviour of the package-name package.
    |
    */

    'enabled' => env('PACKAGE_NAME_ENABLED', true),

    /*
    |--------------------------------------------------------------------------
    | Table Name
    |--------------------------------------------------------------------------
    |
    | Customise the database table name used by this package.
    |
    */

    'table_name' => 'package_table',

    /*
    |--------------------------------------------------------------------------
    | Model
    |--------------------------------------------------------------------------
    |
    | The model class to use. You can replace this with your own model
    | that extends the package's base model.
    |
    */

    'model' => \Vendor\PackageName\Models\PackageModel::class,
];
```

---

## Migration Publishing Pattern

### Using Stub Files

Name migration files with `.stub` extension so they are not auto-loaded by Laravel:

```
database/migrations/create_package_table.php.stub
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create(config('package-name.table_name', 'package_table'), function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists(config('package-name.table_name', 'package_table'));
    }
};
```

### Publishing with Timestamp

In the ServiceProvider, publish migrations with a timestamp prefix:

```php
protected function registerPublishing(): void
{
    if (! $this->app->runningInConsole()) {
        return;
    }

    // Publish migrations with timestamp
    $migrationFileName = 'create_package_table.php';
    $exists = collect(glob(database_path('migrations/*.php')))
        ->contains(fn (string $filename) => str_contains($filename, $migrationFileName));

    if (! $exists) {
        $this->publishes([
            __DIR__ . "/../database/migrations/{$migrationFileName}.stub" => database_path(
                'migrations/' . date('Y_m_d_His', time()) . "_{$migrationFileName}"
            ),
        ], 'package-name-migrations');
    }
}
```

### Direct Migration Loading (No Publishing Needed)

For packages where migration publishing is optional:

```php
public function boot(): void
{
    $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
}
```

---

## View Publishing Pattern

### Registering Views

```php
public function boot(): void
{
    $this->loadViewsFrom(__DIR__ . '/../resources/views', 'package-name');

    if ($this->app->runningInConsole()) {
        $this->publishes([
            __DIR__ . '/../resources/views' => resource_path('views/vendor/package-name'),
        ], 'package-name-views');
    }
}
```

### Using Package Views in Blade

```blade
{{-- Use the namespaced view --}}
@include('package-name::component')

{{-- Render a package view --}}
<x-package-name::alert type="warning" />
```

---

## Route Registration Pattern

### Web Routes

```php
// routes/web.php
<?php

use Illuminate\Support\Facades\Route;
use Vendor\PackageName\Http\Controllers\PackageController;

Route::middleware(config('package-name.middleware', ['web']))
    ->prefix(config('package-name.route_prefix', 'package'))
    ->name('package-name.')
    ->group(function () {
        Route::get('/', [PackageController::class, 'index'])->name('index');
        Route::post('/', [PackageController::class, 'store'])->name('store');
        Route::get('/{id}', [PackageController::class, 'show'])->name('show');
    });
```

### API Routes

```php
// routes/api.php
<?php

use Illuminate\Support\Facades\Route;
use Vendor\PackageName\Http\Controllers\Api\PackageApiController;

Route::middleware(config('package-name.api_middleware', ['api']))
    ->prefix(config('package-name.api_prefix', 'api/package'))
    ->name('api.package-name.')
    ->group(function () {
        Route::apiResource('resources', PackageApiController::class);
    });
```

### Loading Routes in ServiceProvider

```php
protected function registerRoutes(): void
{
    if (config('package-name.routes.enabled', true)) {
        $this->loadRoutesFrom(__DIR__ . '/../routes/web.php');
    }

    if (config('package-name.api.enabled', false)) {
        $this->loadRoutesFrom(__DIR__ . '/../routes/api.php');
    }
}
```

---

## Command Registration Pattern

### Install Command

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Commands;

use Illuminate\Console\Command;

class InstallCommand extends Command
{
    protected $signature = 'package-name:install';

    protected $description = 'Install the PackageName package';

    public function handle(): int
    {
        $this->info('Installing PackageName...');

        $this->call('vendor:publish', [
            '--tag' => 'package-name-config',
        ]);

        if ($this->confirm('Would you like to run migrations now?', true)) {
            $this->call('migrate');
        }

        $this->info('PackageName installed successfully.');

        return self::SUCCESS;
    }
}
```

### Custom Package Command

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Commands;

use Illuminate\Console\Command;

class PackageCommand extends Command
{
    protected $signature = 'package-name:process
                            {--force : Force the operation}
                            {--dry-run : Show what would happen without making changes}';

    protected $description = 'Run the package processing command';

    public function handle(): int
    {
        if ($this->option('dry-run')) {
            $this->info('Dry run mode — no changes will be made.');
        }

        $this->withProgressBar($this->getItems(), function ($item) {
            // Process each item
        });

        $this->newLine();
        $this->info('Processing complete.');

        return self::SUCCESS;
    }

    private function getItems(): array
    {
        return [];
    }
}
```

---

## .gitignore Template

```
/vendor/
/node_modules/
composer.lock
.phpunit.result.cache
.phpunit.cache/
.php-cs-fixer.cache
coverage/
.idea/
.vscode/
*.swp
.DS_Store
```

**Important:** Packages must ignore `composer.lock` — only applications commit their lock file.

---

## LICENSE Template (MIT)

```
The MIT License (MIT)

Copyright (c) Vendor Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

---

## CHANGELOG.md Template

```markdown
# Changelog

All notable changes to `package-name` will be documented in this file.

## [Unreleased]

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release
```
