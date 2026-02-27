# Route Conventions

## Rules

1. **Modular route files** — one file per module in `routes/web/` or `routes/api/`
2. **Auto-loaded via `require_all_in()`** — no manual registration needed
3. **Use resource routes** where applicable
4. **Apply middleware explicitly** — auth, role, permission
5. **Follow Laravel naming conventions** — plural kebab-case URIs

## Directory Structure

```
routes/
├── web.php           # Bootstraps web routes, calls require_all_in()
├── api.php           # Bootstraps API routes, calls require_all_in()
├── web/
│   ├── dashboard.php
│   ├── invoices.php
│   ├── users.php
│   └── settings.php
└── api/
    ├── invoices.php
    └── users.php
```

## Bootstrap File (routes/web.php)

```php
<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Load all modular route files
require_all_in(__DIR__ . '/web');
```

## The `require_all_in()` Helper

Defined in `support/helpers.php`, this function loads all PHP files in a directory:

```php
if (! function_exists('require_all_in')) {
    function require_all_in(string $directory): void
    {
        if (! is_dir($directory)) {
            return;
        }

        foreach (glob($directory . '/*.php') as $file) {
            require $file;
        }
    }
}
```

## Web Route Template

```php
<?php

// routes/web/invoices.php

use App\Http\Controllers\InvoiceController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('invoices', InvoiceController::class);
});
```

## API Route Template

```php
<?php

// routes/api/invoices.php

use App\Http\Controllers\Api\InvoiceController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('invoices', InvoiceController::class);
});
```

## Route with Permission Middleware

```php
Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('invoices', InvoiceController::class)
        ->middleware('permission:invoice.view.any');

    Route::post('invoices/{invoice}/send', [InvoiceController::class, 'send'])
        ->name('invoices.send')
        ->middleware('permission:invoice.send.any');
});
```

## Naming Conventions

| Resource | URI | Route Name |
|---|---|---|
| Invoices | `/invoices` | `invoices.index` |
| Invoice | `/invoices/{invoice}` | `invoices.show` |
| Create | `/invoices/create` | `invoices.create` |
| Store | `/invoices` (POST) | `invoices.store` |
| Edit | `/invoices/{invoice}/edit` | `invoices.edit` |
| Update | `/invoices/{invoice}` (PUT) | `invoices.update` |
| Delete | `/invoices/{invoice}` (DELETE) | `invoices.destroy` |

## DO / DON'T

- ✅ DO create one route file per module
- ✅ DO use `Route::resource()` or `Route::apiResource()` for CRUD
- ✅ DO apply auth and permission middleware
- ✅ DO use plural kebab-case for URIs (`/invoices`, `/leave-requests`)
- ❌ DON'T define routes in `routes/web.php` directly (except the landing page)
- ❌ DON'T use closures in route files — always reference controller methods
- ❌ DON'T use `url()` helper — use `route()` with named routes
