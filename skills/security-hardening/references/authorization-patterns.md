# Laravel Authorization Patterns

Authorization is the category that produces the most severe findings in Laravel apps, and
the one most often "handled" by a check that does not actually run.

## The rule

> **Authentication** answers *who are you*. **Authorization** answers *may you touch this
> specific record*. Route model binding answers neither — it only proves the row exists.

Every route that accepts an identifier needs an ownership or permission check on the
resolved record.

---

## Policies — the default choice

```php
// app/Policies/InvoicePolicy.php
class InvoicePolicy
{
    public function view(User $user, Invoice $invoice): bool
    {
        return $user->tenant_id === $invoice->tenant_id;
    }

    public function update(User $user, Invoice $invoice): bool
    {
        return $user->tenant_id === $invoice->tenant_id
            && $user->can('invoice.update')
            && $invoice->status !== InvoiceStatus::Paid;
    }
}
```

```php
// Controller — one line, non-optional
public function update(UpdateInvoiceRequest $request, Invoice $invoice)
{
    $this->authorize('update', $invoice);
    // …
}
```

Alternatives that enforce it structurally:

```php
// Route middleware
Route::put('/invoices/{invoice}', [InvoiceController::class, 'update'])
    ->middleware('can:update,invoice');

// Whole resource
public function __construct()
{
    $this->authorizeResource(Invoice::class, 'invoice');
}
```

`authorizeResource` is the strongest option: it fails closed for every action, including the
ones added later by someone who forgot.

---

## Form Requests

Put record-level authorization here when the check needs the validated input:

```php
class UpdateInvoiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('invoice'));
    }
}
```

**Trap:** a Form Request whose `authorize()` returns `true` unconditionally is a security
hole wearing the shape of a control. Either return a real check or delete the method and
authorize in the controller — never leave a `return true;` that looks like it did something.

---

## `Gate::before` — the superadmin footgun

```php
// ❌ Every policy below this is now dead code in tests and in production
Gate::before(fn (User $user) => $user->hasRole('super-admin') ? true : null);
```

Consequences:

1. One compromised super-admin account owns every record in every tenant.
2. Your policies are never exercised when you test as an admin, so their bugs stay hidden
   until a normal user hits them.

If you keep it: scope it (`if ($ability !== 'delete')`), require a second factor for the role,
log every action taken under the bypass, and **write policy tests as a non-admin user**.

---

## Multi-tenancy

Scope at the model, not at every call site — call sites get forgotten.

```php
protected static function booted(): void
{
    static::addGlobalScope('tenant', function (Builder $query) {
        if ($tenantId = auth()->user()?->tenant_id) {
            $query->where('tenant_id', $tenantId);
        }
    });

    static::creating(function (self $model) {
        $model->tenant_id ??= auth()->user()?->tenant_id;
    });
}
```

Then audit for escapes:

```bash
grep -rn "withoutGlobalScope" app/
```

Every hit needs a comment justifying it. A background job or console command legitimately runs
without a user — that path must set the tenant explicitly, not drop the scope and hope.

**Never** rely on `where('tenant_id', $request->tenant_id)` — the request is attacker-controlled.

---

## Livewire

A Livewire component's public methods are **public endpoints**. Anyone can call
`deleteInvoice(999)` from the console regardless of what the Blade template renders.

```php
class InvoiceEditor extends Component
{
    public Invoice $invoice;

    public function mount(Invoice $invoice): void
    {
        $this->authorize('update', $invoice);   // gate entry
        $this->invoice = $invoice;
    }

    public function delete(): void
    {
        $this->authorize('delete', $this->invoice);   // gate the action too
        $this->invoice->delete();
    }
}
```

Rules:

- Authorize in `mount()` **and** in every state-changing method. `mount()` alone does not
  protect a method invoked later with different state.
- Public properties are client-writable. Never keep `$isAdmin`, `$price` or `$tenantId` as a
  plain public property — derive them server-side.
- `@can` in the template hides the button. It does not protect the method.

---

## API tokens (Sanctum)

```php
$token = $user->createToken('mobile', ['invoice.read'])->plainTextToken;

Route::middleware(['auth:sanctum', 'ability:invoice.read'])
    ->get('/invoices', [InvoiceController::class, 'index']);
```

- Abilities are least-privilege — a read client never gets a write ability.
- Tokens expire (`config/sanctum.php` `expiration`) and are revocable.
- Ability checks are **in addition to** policies, never instead of them.

---

## Tests that prove authorization exists

Authorization without a negative test is unverified. The positive case passes even when the
check is missing.

```php
it('denies cross-tenant access', function () {
    $theirs = Invoice::factory()->for(Tenant::factory())->create();

    actingAs($this->user)
        ->get("/invoices/{$theirs->id}")
        ->assertForbidden();          // ← the assertion that matters
});

it('denies a user without the permission', function () {
    $invoice = Invoice::factory()->for($this->tenant)->create();

    actingAs($this->viewer)
        ->put("/invoices/{$invoice->id}", ['total' => 1])
        ->assertForbidden();
});

it('denies a guest', function () {
    $invoice = Invoice::factory()->create();

    $this->get("/invoices/{$invoice->id}")->assertRedirect('/login');
});
```

**Every protected resource needs all three**: wrong tenant, insufficient permission, and
unauthenticated. Use the `kickoff-pest-testing` skill for factory and suite conventions.

---

## Audit script

```bash
echo "Controller actions:  $(grep -rn 'public function' app/Http/Controllers/ | grep -v '__construct' | wc -l)"
echo "Authorization calls: $(grep -rn 'authorize(\|Gate::\|->can(' app/Http/Controllers/ | wc -l)"
echo "Policies:            $(ls app/Policies/ 2>/dev/null | wc -l)"
echo "Models:              $(ls app/Models/ | wc -l)"
echo
echo "Scope escapes:"; grep -rn "withoutGlobalScope" app/ || echo "  none"
echo "Gate bypasses:";  grep -rn "Gate::before" app/Providers/ || echo "  none"
echo "Blank authorize():"; grep -rn -A2 "public function authorize" app/Http/Requests/ | grep "return true" || echo "  none"
```

Models without policies, and controller actions outnumbering authorization calls, are the
findings list.
