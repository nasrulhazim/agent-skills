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

## Tenancy Is Not Authorisation

**A capability permission is not a tenancy scope, and `App\Policies\*` does not supply one
either.** There are **no global scopes** in the Kickoff baseline — a typical policy method is a
bare `$user->can('resource.create.item')` with no organisation check. Passing the policy proves
a user may do the *kind* of thing; it never proves they may do it to **this row**.

So every list and every lookup must scope itself. The failure is severe and quiet:

```php
// WRONG — passes the same `can:viewAny` middleware as its correctly-scoped neighbour,
// and happily resolves another tenant's row from a client-supplied uuid.
$provider = InfraProvider::where('uuid', $uuid)->firstOrFail();
```

In one real case that pattern let a caller name another tenant's provider uuid and have the
application open an SSH session **with their decrypted credentials** against a host typed into
the form.

Route every lookup through **one scoped finder** so ownership cannot be remembered at five call
sites and forgotten at the sixth:

```php
private function findProvider(string $uuid): InfraProvider
{
    return InfraProvider::query()
        ->where('organization_id', current_organization()->id)
        ->where('uuid', $uuid)
        ->firstOrFail();
}
```

- **Never** resolve a client-supplied uuid with a bare `where('uuid', …)`.
- A page that is "obviously internal" is not exempt — the page next to it usually is scoped,
  which is exactly why the gap goes unnoticed.
- When a guard's whole job is to say "no", write the test that proves it says no. A guard that
  never fires is indistinguishable from one that never runs.

### Per-tenant uniqueness

**`is_default` — and any "exactly one row carries this flag" rule — is per-tenant, so the reset
must be too.**

```php
// WRONG — a cross-tenant write. One tenant saving a default silently clears
// every other organisation's choice, and the platform catalogue's too.
NodeBootstrapTemplate::whereKeyNot($id)->update(['is_default' => false]);

// RIGHT — the scope it is unique *within*, written into the query.
NodeBootstrapTemplate::query()
    ->where('organization_id', $template->organization_id)
    ->whereKeyNot($template->id)
    ->update(['is_default' => false]);
```

### Pin the guard on non-default guards

**A surface authenticating on a guard other than `web` must pin the guard it checks permissions
against.** Browser routes run on `web`, but an API, MCP or token surface authenticating on
`sanctum` (or Passport) evaluates a bare `$user->can(...)` under *that* guard — where the user
has no permissions. Everything denies, superadmin included, and the failure reads as a
misconfigured role rather than a guard mismatch.

```php
// Pin the guard, and fail closed on an unknown permission.
$user->hasPermissionTo($ability, 'web');
```

Related, for custom Spatie models: pin `guard_name` to `web` in the constructor of both
`App\Models\Role` and `App\Models\Permission`, since a guardless fresh instance resolves its
guard from the request's *current* default.

### Audit the denial outside the transaction

An audited **denial** must be written **outside** the transaction that performs the check.
Throwing from inside rolls the audit record back along with the (empty) write set — losing the
evidence in precisely the case it exists for. Return the failing result out of
`DB::transaction()`, write the audit, then throw.

## DO / DON'T

- ✅ DO define permissions in `config/access-control.php`
- ✅ DO use `module.action.target` format
- ✅ DO use policies for model-level authorisation
- ✅ DO seed permissions from config (not hardcoded in seeder)
- ✅ DO distinguish `.any` vs `.own` for granular access
- ✅ DO route every tenant-owned lookup through a single scoped finder
- ✅ DO pin the guard (`hasPermissionTo($ability, 'web')`) on non-`web` surfaces
- ✅ DO write the audit record for a denial outside the transaction it describes
- ❌ DON'T hardcode permission names in controllers
- ❌ DON'T skip policy checks — always authorise
- ❌ DON'T treat a passing policy as proof of tenant ownership
- ❌ DON'T resolve a client-supplied uuid with a bare `where('uuid', …)`
- ❌ DON'T write a "only one row may carry this flag" reset without its tenant scope
- ❌ DON'T use Gate closures when a Policy is more appropriate
- ❌ DON'T create permissions outside of the config file
