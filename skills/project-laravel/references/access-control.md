# Access Control Conventions

## Rules

1. **Config-driven permissions** — define in `config/access-control.php`
2. **Permission format** — `module.action.target` (e.g., `invoice.view.any`)
3. **Use Spatie Permission** — `spatie/laravel-permission` package
4. **Policies for authorisation** — standard CRUD methods
5. **Middleware for route protection** — `permission:` and `role:` middleware
6. **Seed permissions from config** — consistent across environments

## Permission Naming Format

```
{module}.{action}.{target}

Examples:
- invoice.view.any
- invoice.view.own
- invoice.create.any
- invoice.update.any
- invoice.update.own
- invoice.delete.any
- invoice.delete.own
- user.manage.any
- setting.update.any
```

## Access Control Config

```php
<?php

// config/access-control.php

return [
    'roles' => [
        'super-admin',
        'admin',
        'user',
    ],

    'permissions' => [
        'invoice' => [
            'view.any',
            'view.own',
            'create.any',
            'update.any',
            'update.own',
            'delete.any',
            'delete.own',
        ],
        'user' => [
            'view.any',
            'create.any',
            'update.any',
            'delete.any',
            'manage.any',
        ],
        'setting' => [
            'view.any',
            'update.any',
        ],
    ],
];
```

## Permission Seeder

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class AccessControlSeeder extends Seeder
{
    public function run(): void
    {
        // Create roles
        foreach (config('access-control.roles') as $roleName) {
            Role::firstOrCreate(['name' => $roleName]);
        }

        // Create permissions
        foreach (config('access-control.permissions') as $module => $actions) {
            foreach ($actions as $action) {
                Permission::firstOrCreate([
                    'name' => "{$module}.{$action}",
                ]);
            }
        }

        // Assign all permissions to super-admin
        $superAdmin = Role::findByName('super-admin');
        $superAdmin->syncPermissions(Permission::all());
    }
}
```

## Policy Template

```php
<?php

namespace App\Policies;

use App\Models\Invoice;
use App\Models\User;

class InvoicePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('invoice.view.any');
    }

    public function view(User $user, Invoice $invoice): bool
    {
        return $user->hasPermissionTo('invoice.view.any')
            || ($user->hasPermissionTo('invoice.view.own') && $invoice->user_id === $user->id);
    }

    public function create(User $user): bool
    {
        return $user->hasPermissionTo('invoice.create.any');
    }

    public function update(User $user, Invoice $invoice): bool
    {
        return $user->hasPermissionTo('invoice.update.any')
            || ($user->hasPermissionTo('invoice.update.own') && $invoice->user_id === $user->id);
    }

    public function delete(User $user, Invoice $invoice): bool
    {
        return $user->hasPermissionTo('invoice.delete.any')
            || ($user->hasPermissionTo('invoice.delete.own') && $invoice->user_id === $user->id);
    }
}
```

## Controller Authorisation

```php
public function index()
{
    $this->authorize('viewAny', Invoice::class);

    return view('invoices.index', [
        'invoices' => Invoice::paginate(),
    ]);
}

public function store(StoreInvoiceRequest $request)
{
    $this->authorize('create', Invoice::class);

    $invoice = (new CreateInvoice)
        ->user($request->user())
        ->number($request->input('number'))
        ->amount($request->input('amount'))
        ->execute();

    return redirect()->route('invoices.show', $invoice);
}
```

## Route Middleware

```php
// Single permission
Route::get('/invoices', [InvoiceController::class, 'index'])
    ->middleware('permission:invoice.view.any');

// Role-based
Route::middleware(['role:admin'])->group(function () {
    Route::resource('users', UserController::class);
});
```

## User Model Setup

```php
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasRoles;
    // ...
}
```

## DO / DON'T

- ✅ DO define permissions in `config/access-control.php`
- ✅ DO use `module.action.target` format
- ✅ DO use policies for model-level authorisation
- ✅ DO seed permissions from config (not hardcoded in seeder)
- ✅ DO distinguish `.any` vs `.own` for granular access
- ❌ DON'T hardcode permission names in controllers
- ❌ DON'T skip policy checks — always authorise
- ❌ DON'T use Gate closures when a Policy is more appropriate
- ❌ DON'T create permissions outside of the config file
