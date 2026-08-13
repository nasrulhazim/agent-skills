# Architecture Testing Patterns

Pest architecture tests enforce project-wide structural rules. They catch violations before code
review — ensuring consistent naming, dependency direction, and code hygiene across the codebase.

---

## File Location

All architecture tests go in `tests/Arch/ArchTest.php`. Projects using the Kickoff baseline
already have this file with baseline rules. Extend it — do not replace.

---

## Strict Types Enforcement

```php
arch('all app code uses strict types')
    ->expect('App')
    ->toUseStrictTypes();

arch('all test files use strict types')
    ->expect('Tests')
    ->toUseStrictTypes();
```

---

## No Debugging Statements

```php
arch('no debugging functions in production code')
    ->expect(['dd', 'dump', 'ray', 'var_dump', 'print_r', 'exit', 'die'])
    ->not->toBeUsed();

arch('no env() calls outside config files')
    ->expect('env')
    ->not->toBeUsed()
    ->ignoring('config');
```

---

## Naming Conventions

### Suffix Rules

```php
arch('controllers have Controller suffix')
    ->expect('App\Http\Controllers')
    ->toHaveSuffix('Controller');

arch('form requests have Request suffix')
    ->expect('App\Http\Requests')
    ->toHaveSuffix('Request');

arch('policies have Policy suffix')
    ->expect('App\Policies')
    ->toHaveSuffix('Policy');

arch('events have descriptive names')
    ->expect('App\Events')
    ->not->toHaveSuffix('Event'); // e.g., OrderCreated not OrderCreatedEvent

arch('listeners have descriptive names')
    ->expect('App\Listeners')
    ->not->toHaveSuffix('Listener');

arch('jobs are named as commands')
    ->expect('App\Jobs')
    ->toHaveSuffix('Job')
    ->or->not->toHaveSuffix('Job'); // Either is fine — just be consistent

arch('middleware have descriptive names')
    ->expect('App\Http\Middleware')
    ->not->toHaveSuffix('Middleware');

arch('mail classes have descriptive names')
    ->expect('App\Mail')
    ->not->toHaveSuffix('Mail');

arch('notifications have descriptive names')
    ->expect('App\Notifications')
    ->not->toHaveSuffix('Notification');
```

### Prefix Rules

```php
arch('interfaces are prefixed or suffixed consistently')
    ->expect('App\Contracts')
    ->toBeInterfaces();

arch('abstract classes are prefixed')
    ->expect('App\Abstracts')
    ->toBeAbstract();
```

---

## Inheritance and Implementation Rules

### Model Rules

```php
arch('models extend Eloquent Model')
    ->expect('App\Models')
    ->toExtend('Illuminate\Database\Eloquent\Model');

arch('models use HasFactory trait')
    ->expect('App\Models')
    ->toUseTrait('Illuminate\Database\Eloquent\Factories\HasFactory');

arch('models are not used in Blade views')
    ->expect('App\Models')
    ->not->toBeUsedIn('resources.views');
```

### Controller Rules

```php
arch('controllers extend base Controller')
    ->expect('App\Http\Controllers')
    ->toExtend('App\Http\Controllers\Controller');

arch('controllers are not final')
    ->expect('App\Http\Controllers')
    ->not->toBeFinal();
```

### Livewire Rules

```php
arch('Livewire components extend Component')
    ->expect('App\Livewire')
    ->toExtend('Livewire\Component');
```

### Job Rules

```php
arch('jobs implement ShouldQueue')
    ->expect('App\Jobs')
    ->toImplement('Illuminate\Contracts\Queue\ShouldQueue');
```

### Mailable Rules

```php
arch('mailables extend Mailable')
    ->expect('App\Mail')
    ->toExtend('Illuminate\Mail\Mailable');

arch('mailables implement ShouldQueue')
    ->expect('App\Mail')
    ->toImplement('Illuminate\Contracts\Queue\ShouldQueue');
```

---

## Dependency Rules

### Layer Direction

Enforce that dependencies flow in one direction — outer layers depend on inner layers, never
the reverse.

```php
// Controllers can use Services, not the other way around
arch('services do not depend on controllers')
    ->expect('App\Services')
    ->not->toUse('App\Http\Controllers');

// Models should not depend on Controllers or Services
arch('models do not depend on controllers')
    ->expect('App\Models')
    ->not->toUse('App\Http\Controllers');

arch('models do not depend on services')
    ->expect('App\Models')
    ->not->toUse('App\Services');
```

### Facade Restrictions

```php
arch('no DB facade in controllers')
    ->expect('App\Http\Controllers')
    ->not->toUse('Illuminate\Support\Facades\DB');

arch('no direct HTTP client in models')
    ->expect('App\Models')
    ->not->toUse('Illuminate\Support\Facades\Http');

arch('no Cache facade in models — use repository pattern')
    ->expect('App\Models')
    ->not->toUse('Illuminate\Support\Facades\Cache');
```

### No Direct Dependencies on Third-Party in Domain

```php
arch('domain does not depend on framework directly')
    ->expect('App\Domain')
    ->not->toUse('Illuminate\Http')
    ->not->toUse('Illuminate\Routing');
```

---

## Layer Constraints

### Feature-Based Architecture

```php
arch('feature modules are self-contained')
    ->expect('App\Features\Billing')
    ->not->toUse('App\Features\Reporting');

arch('shared kernel is used by all features')
    ->expect('App\Shared')
    ->not->toUse('App\Features');
```

### Standard Laravel Layers

```php
arch('HTTP layer only uses services and models')
    ->expect('App\Http')
    ->toOnlyUse([
        'App\Services',
        'App\Actions',
        'App\Models',
        'App\Http',
        'App\Livewire',
        'Illuminate',
        'Spatie',
    ]);

arch('actions are lean — no HTTP dependencies')
    ->expect('App\Actions')
    ->not->toUse('Illuminate\Http');
```

---

## Trait and Interface Enforcement

```php
arch('all models use SoftDeletes')
    ->expect('App\Models')
    ->toUseTrait('Illuminate\Database\Eloquent\SoftDeletes')
    ->ignoring(['App\Models\User', 'App\Models\PersonalAccessToken']);

arch('all form requests implement authorization')
    ->expect('App\Http\Requests')
    ->toHaveMethod('authorize');
```

---

## Class Characteristic Rules

```php
arch('value objects are final and readonly')
    ->expect('App\ValueObjects')
    ->toBeFinal()
    ->toBeReadonly();

arch('enums are in the Enums namespace')
    ->expect('App\Enums')
    ->toBeEnums();

arch('contracts are interfaces')
    ->expect('App\Contracts')
    ->toBeInterfaces();

arch('DTOs are final')
    ->expect('App\DataTransferObjects')
    ->toBeFinal();
```

---

## Custom Arch Rules

### No God Classes

```php
arch('controllers have at most 7 public methods')
    ->expect('App\Http\Controllers')
    ->toHaveMethod('index')   // These are optional checks
    ->not->toHaveMethod('__construct'); // Prefer method injection
```

### File Organization

```php
arch('no classes directly in app/ root')
    ->expect('App')
    ->classes()
    ->not->toBeIn('app');

arch('exceptions are in the Exceptions namespace')
    ->expect('App\Exceptions')
    ->toExtend('Exception');
```

### Security Rules

```php
arch('no raw SQL in application code')
    ->expect('App')
    ->not->toUse('Illuminate\Support\Facades\DB')
    ->ignoring([
        'App\Repositories',
        'App\Services\ReportService',
    ]);

arch('no direct file operations — use Storage facade')
    ->expect('App')
    ->not->toUse(['file_get_contents', 'file_put_contents', 'fopen', 'fwrite'])
    ->ignoring('App\Console');
```

---

## Ignoring Specific Classes

Use `->ignoring()` to exclude specific classes or namespaces from a rule:

```php
arch('strict types everywhere')
    ->expect('App')
    ->toUseStrictTypes()
    ->ignoring([
        'App\Providers',             // Generated by Laravel
        'App\Http\Kernel',           // Generated by Laravel
    ]);
```

---

## Preset Rules

Pest provides built-in presets for common rule sets:

```php
arch()->preset()->php();       // No deprecated PHP functions
arch()->preset()->security();  // No eval, exec, shell_exec, etc.
arch()->preset()->laravel();   // Laravel-specific best practices
```

### What Each Preset Checks

| Preset | Rules |
|---|---|
| `php()` | No `die`, `var_dump`, deprecated functions |
| `security()` | No `eval`, `exec`, `shell_exec`, `system`, `passthru`, `proc_open` |
| `laravel()` | Controllers extend base, models use factories, no env() outside config |

---

## Organizing Arch Tests

### Single File Approach

Keep all arch rules in `tests/Arch/ArchTest.php` for smaller projects:

```php
<?php

declare(strict_types=1);

// === Code Quality ===
arch('strict types')->expect('App')->toUseStrictTypes();
arch('no debugging')->expect(['dd', 'dump', 'ray'])->not->toBeUsed();

// === Naming ===
arch('controller suffix')->expect('App\Http\Controllers')->toHaveSuffix('Controller');

// === Dependencies ===
arch('models independent')->expect('App\Models')->not->toUse('App\Http\Controllers');

// === Presets ===
arch()->preset()->php();
arch()->preset()->security();
```

### Multi-File Approach

For larger projects, split by concern:

```
tests/Arch/
├── ArchTest.php          ← Presets + code quality
├── NamingTest.php        ← Suffix/prefix conventions
├── DependencyTest.php    ← Layer rules
└── SecurityTest.php      ← Security constraints
```

---

## Running Arch Tests

```bash
# Run all arch tests
php artisan test tests/Arch/

# Run specific arch test file
php artisan test tests/Arch/ArchTest.php

# Run with verbose output to see all rules checked
php artisan test tests/Arch/ -v
```

---

## Common Pitfalls

| Pitfall | Solution |
|---|---|
| Rule too broad, catches vendor code | Scope to `App` namespace explicitly |
| New class fails existing rule | Add to `->ignoring()` or fix the class |
| Preset conflicts with project conventions | Override specific rules after preset |
| Arch tests slow on large codebase | Run in separate CI step, cache results |
| Rule prevents valid pattern | Use `->ignoring()` for exceptions, document why |
