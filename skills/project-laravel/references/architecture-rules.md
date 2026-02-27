# Architecture Rules

## Rules

These rules are enforced via Pest architecture tests and code review.

## Banned Functions

The following functions are **banned** from application code:

| Function | Reason | Alternative |
|---|---|---|
| `dd()` | Debug output left in code | Use proper logging or remove |
| `dump()` | Debug output left in code | Use proper logging or remove |
| `ray()` | Debug tool left in code | Use proper logging or remove |
| `env()` | Must only be used in config files | Use `config()` instead |
| `url()` | Generates non-named URLs | Use `route()` with named routes |
| `DB::raw()` | Raw queries bypass Eloquent | Use Eloquent query builder |
| `DB::select()` | Raw queries bypass Eloquent | Use Eloquent query builder |
| `DB::statement()` | Raw queries bypass Eloquent | Use Eloquent or migrations |

## Naming Conventions

| Type | Suffix | Directory | Example |
|---|---|---|---|
| Controller | `Controller` | `app/Http/Controllers/` | `InvoiceController` |
| Policy | `Policy` | `app/Policies/` | `InvoicePolicy` |
| Form Request | `Request` | `app/Http/Requests/` | `StoreInvoiceRequest` |
| Resource | `Resource` | `app/Http/Resources/` | `InvoiceResource` |
| Event | `Event` (or descriptive) | `app/Events/` | `InvoiceCreated` |
| Listener | `Listener` (or descriptive) | `app/Listeners/` | `SendInvoiceNotification` |
| Job | (descriptive) | `app/Jobs/` | `ProcessInvoicePayment` |
| Notification | `Notification` | `app/Notifications/` | `InvoicePaidNotification` |
| Middleware | (descriptive) | `app/Http/Middleware/` | `EnsureUserIsAdmin` |
| Trait | (descriptive) | `app/Concerns/` | `HasSlug` |
| Interface | (descriptive) | `app/Contracts/` | `Payable` |
| Enum | (descriptive) | `app/Enums/` | `InvoiceStatus` |
| Action | (descriptive) | `app/Actions/` | `CreateInvoice` |

## Strict Type Rules

1. **Concerns must be traits** — files in `app/Concerns/` must use `trait` keyword
2. **Contracts must be interfaces** — files in `app/Contracts/` must use `interface` keyword
3. **Models extend Base** — never extend `Illuminate\Database\Eloquent\Model` directly
4. **Enums implement Contract** — all enums implement `CleaniqueCoders\Traitify\Contracts\Enum`

## Pest Architecture Tests

```php
// tests/Architecture/ArchitectureTest.php

arch('controllers must have Controller suffix')
    ->expect('App\Http\Controllers')
    ->toHaveSuffix('Controller');

arch('policies must have Policy suffix')
    ->expect('App\Policies')
    ->toHaveSuffix('Policy');

arch('concerns must be traits')
    ->expect('App\Concerns')
    ->toBeTraits();

arch('contracts must be interfaces')
    ->expect('App\Contracts')
    ->toBeInterfaces();

arch('models must extend Base')
    ->expect('App\Models')
    ->toExtend('App\Models\Base')
    ->ignoring('App\Models\Base')
    ->ignoring('App\Models\User');

arch('enums must implement Enum contract')
    ->expect('App\Enums')
    ->toImplement('CleaniqueCoders\Traitify\Contracts\Enum');

arch('do not use dd or dump')
    ->expect(['dd', 'dump', 'ray'])
    ->not->toBeUsed();

arch('do not use env outside config')
    ->expect('env')
    ->not->toBeUsed()
    ->ignoring('config');

arch('do not use url helper')
    ->expect('url')
    ->not->toBeUsed();
```

## Composer Scripts

Every Kickoff project includes these scripts:

```json
{
    "scripts": {
        "test": "pest --parallel",
        "format": "pint",
        "analyse": "phpstan analyse",
        "rector": "rector process --dry-run"
    }
}
```

Usage:
- `composer test` — run Pest tests in parallel
- `composer format` — fix code style with Pint
- `composer analyse` — run PHPStan/Larastan analysis
- `composer rector` — preview Rector refactoring suggestions

## Code Organisation

```
app/
├── Actions/           # Business logic (Builder pattern)
├── Concerns/          # Traits (must be traits)
├── Contracts/         # Interfaces (must be interfaces)
├── Enums/             # Enums (must implement Contract)
├── Events/            # Domain events
├── Http/
│   ├── Controllers/   # Controllers (suffix Controller)
│   ├── Middleware/     # HTTP middleware
│   ├── Requests/      # Form requests (suffix Request)
│   └── Resources/     # API resources (suffix Resource)
├── Jobs/              # Queued jobs
├── Listeners/         # Event listeners
├── Models/            # Eloquent models (extend Base)
├── Notifications/     # Notification classes
├── Policies/          # Authorisation policies (suffix Policy)
└── Providers/         # Service providers
```

## DO / DON'T

- ✅ DO follow naming suffix conventions
- ✅ DO place files in the correct directory
- ✅ DO run `composer test` before committing
- ✅ DO run `composer format` to fix code style
- ❌ DON'T use banned functions in application code
- ❌ DON'T use `env()` outside of config files
- ❌ DON'T use `url()` — use `route()` with named routes
- ❌ DON'T use raw DB queries — use Eloquent
- ❌ DON'T skip architecture tests
