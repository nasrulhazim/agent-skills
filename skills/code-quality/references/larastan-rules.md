# Larastan Rules & PHPStan Error Reference

Comprehensive reference for Larastan/PHPStan error levels, common error patterns, fixes,
custom rule patterns, and baseline management. Read this file when interpreting PHPStan
errors or configuring analysis levels.

---

## Error Levels (0-9)

PHPStan analyses code at increasing strictness levels. Each level includes all checks from
the previous levels.

| Level | What It Checks | Recommended For |
|---|---|---|
| 0 | Basic checks — unknown classes, functions, methods called on `$this` | First-time setup |
| 1 | Possibly undefined variables, unknown magic methods, magic properties | Legacy code start |
| 2 | Unknown methods on all expressions (not just `$this`), validates PHPDocs | Minimum for new projects |
| 3 | Return types verified, wrong number of arguments | Active development |
| 4 | Dead code — always true/false conditions, unreachable branches | Growing teams |
| 5 | Argument types in function/method calls validated | **Recommended default** |
| 6 | Missing type declarations reported | Strict projects |
| 7 | Union types fully validated | Advanced type safety |
| 8 | Nullable types — method calls and property access on nullable types | Near-maximum strictness |
| 9 | Mixed type — operations on `mixed` are flagged | Maximum strictness |

### Level Progression Strategy

```
Start:    Level 5 + baseline for existing errors
Month 1:  Reduce baseline by 30%
Month 2:  Bump to level 6 + new baseline
Month 3:  Reduce level 6 baseline by 50%
Month 4:  Bump to level 7
...continue until target level reached
```

---

## Common Error Patterns and Fixes

### 1. Type Mismatch in Parameters

```
Error: Parameter #1 $amount of method charge() expects int, string given.
File:  app/Services/PaymentService.php:42
```

**Why:** PHPStan tracks types through the code flow. `$request->input()` returns
`string|array|null`, not `int`.

**Fix options:**

```php
// Option A: Cast
$this->charge((int) $request->input('amount'));

// Option B: Validate and type-hint via form request
// In PaymentRequest:
public function rules(): array
{
    return ['amount' => 'required|integer'];
}

// Then in controller — validated() returns typed data:
$this->charge($request->validated('amount'));

// Option C: Type assertion (when you're certain)
/** @var int $amount */
$amount = $request->input('amount');
$this->charge($amount);
```

### 2. Call to Undefined Method

```
Error: Call to an undefined method App\Models\User::activeSubscription().
File:  app/Http/Controllers/BillingController.php:28
```

**Why:** The method doesn't exist on the model, or it's a dynamic relationship/scope
that PHPStan can't see.

**Fix options:**

```php
// Option A: Add @method PHPDoc to the model
/**
 * @method \Illuminate\Database\Eloquent\Relations\HasOne activeSubscription()
 */
class User extends Authenticatable
{
}

// Option B: If it's a scope, use proper return type
public function scopeActive(Builder $query): Builder
{
    return $query->where('active', true);
}

// Option C: If it's a relationship, ensure it's properly declared
public function activeSubscription(): HasOne
{
    return $this->hasOne(Subscription::class)->where('active', true);
}
```

### 3. Missing Property Type Declaration

```
Error: Property App\Services\ReportService::$config has no type declaration.
File:  app/Services/ReportService.php:12
```

**Fix:**

```php
// Before
class ReportService
{
    private $config;

    public function __construct($config)
    {
        $this->config = $config;
    }
}

// After
class ReportService
{
    public function __construct(
        private readonly array $config,
    ) {
    }
}
```

### 4. Missing Return Type

```
Error: Method App\Services\OrderService::getTotal() has no return type specified.
File:  app/Services/OrderService.php:34
```

**Fix:**

```php
// Before
public function getTotal()
{
    return $this->items->sum('price');
}

// After
public function getTotal(): float
{
    return (float) $this->items->sum('price');
}
```

### 5. Access to Undefined Property

```
Error: Access to an undefined property App\Models\Order::$total_amount.
File:  app/Http/Controllers/OrderController.php:55
```

**Why:** The column exists in the database but PHPStan does not know about it.

**Fix options:**

```php
// Option A: Use an IDE helper package to generate model PHPDocs
// Run: php artisan ide-helper:models --write

// Option B: Add @property PHPDoc manually
/**
 * @property float $total_amount
 * @property string $status
 * @property \Carbon\Carbon $created_at
 */
class Order extends Model
{
}

// Option C: Use casts (Larastan reads the casts array)
protected function casts(): array
{
    return [
        'total_amount' => 'float',
    ];
}
```

### 6. Nullable Type Issues (Level 8+)

```
Error: Cannot call method format() on Carbon|null.
File:  app/Http/Controllers/UserController.php:20
```

**Fix:**

```php
// Before
return $user->email_verified_at->format('Y-m-d');

// After — null check
return $user->email_verified_at?->format('Y-m-d');

// Or — with fallback
return $user->email_verified_at?->format('Y-m-d') ?? 'Not verified';
```

### 7. Mixed Type Issues (Level 9)

```
Error: Cannot access property $name on mixed.
File:  app/Services/ApiService.php:45
```

**Fix:**

```php
// Before
$data = json_decode($response->body());
return $data->name;

// After — assert the type
/** @var object{name: string} $data */
$data = json_decode($response->body());
return $data->name;

// Or — use Laravel's fluent JSON
return $response->json('name');
```

### 8. Dead Catch Block

```
Error: Dead catch - InvalidArgumentException is never thrown in the try block.
File:  app/Services/ImportService.php:78
```

**Fix:**

```php
// Before — catching an exception that can't be thrown
try {
    $result = Cache::get($key);
} catch (\InvalidArgumentException $e) {
    // This never executes
    return null;
}

// After — remove the dead catch
$result = Cache::get($key);
```

---

## Larastan-Specific Features

Larastan extends PHPStan with Laravel-aware analysis. These are things base PHPStan cannot
check but Larastan can.

### Model Property Analysis

Larastan reads your migration files and model `$casts` to understand column types:

```neon
# phpstan.neon
parameters:
    larastan:
        # If using sqlite for testing, set the DB connection for migration scanning
        databaseMigrationsPath:
            - database/migrations
```

### Collection Generics

Larastan understands Eloquent collection types:

```php
// Larastan knows this returns Collection<int, User>
$users = User::where('active', true)->get();

// So this is type-safe:
$users->each(function (User $user) {
    $user->notify(new WelcomeNotification());
});
```

### Request Validation Awareness

Larastan tracks validated data types when using Form Requests:

```php
class StoreOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'amount' => 'required|integer',
            'note'   => 'nullable|string',
        ];
    }
}

// Larastan knows validated() returns the right types
public function store(StoreOrderRequest $request): JsonResponse
{
    // PHPStan knows $amount is int, $note is string|null
    $amount = $request->validated('amount');
    $note = $request->validated('note');
}
```

---

## Custom Rule Patterns

### Ignoring Specific Errors

```neon
parameters:
    ignoreErrors:
        # Ignore a specific error message
        - '#Call to an undefined method Illuminate\\Database\\Eloquent\\Builder#'

        # Ignore errors in a specific file
        -
            message: '#Parameter .* expects string, int given#'
            path: app/Legacy/OldService.php

        # Ignore errors in a directory
        -
            message: '#.*#'
            paths:
                - app/Generated/*
```

### Custom PHPDoc Types

```php
/**
 * @phpstan-type OrderData array{
 *     amount: int,
 *     currency: string,
 *     items: list<array{sku: string, qty: int, price: float}>,
 *     note?: string
 * }
 */
class OrderService
{
    /**
     * @param OrderData $data
     */
    public function create(array $data): Order
    {
        // PHPStan now validates the array structure
    }
}
```

### Generic Repository Pattern

```php
/**
 * @template T of \Illuminate\Database\Eloquent\Model
 */
abstract class BaseRepository
{
    /**
     * @param class-string<T> $model
     */
    public function __construct(
        protected string $model,
    ) {
    }

    /**
     * @return T|null
     */
    public function find(int $id): ?Model
    {
        return $this->model::find($id);
    }

    /**
     * @return \Illuminate\Database\Eloquent\Collection<int, T>
     */
    public function all(): Collection
    {
        return $this->model::all();
    }
}
```

---

## PHPStan Configuration Reference

### Minimal `phpstan.neon` for Laravel

```neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app/
    level: 5
    checkMissingIterableValueType: false
```

### Recommended `phpstan.neon` for Strict Projects

```neon
includes:
    - phpstan-baseline.neon
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app/
        - config/
        - database/
        - routes/
    excludePaths:
        - app/Http/Middleware/TrustProxies.php
    level: 8
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: false
    reportUnmatchedIgnoredErrors: true
```

### Useful Extra Parameters

```neon
parameters:
    # Treat PHPDoc types as authoritative
    treatPhpDocTypesAsCertain: true

    # Report unused ignoreErrors patterns
    reportUnmatchedIgnoredErrors: true

    # Parallel processing for large codebases
    parallel:
        maximumNumberOfProcesses: 8

    # Increase memory for large projects
    # (also settable via CLI: --memory-limit=1G)
```

---

## Baseline Management

### Generate Baseline

```bash
./vendor/bin/phpstan analyse --generate-baseline
```

Creates `phpstan-baseline.neon` with all current errors grouped by file and error message.

### Baseline File Structure

```neon
# phpstan-baseline.neon (auto-generated)
parameters:
    ignoreErrors:
        -
            message: '#^Method App\\Services\\PaymentService\:\:charge\(\) has no return type specified\.$#'
            count: 1
            path: app/Services/PaymentService.php
        -
            message: '#^Property App\\Models\\Order\:\:\$total has no type declaration\.$#'
            count: 1
            path: app/Models/Order.php
```

### Tracking Baseline Reduction

After each fix batch, regenerate and compare:

```bash
# Before: count errors in baseline
grep -c 'count:' phpstan-baseline.neon

# Fix a batch of errors, then regenerate
./vendor/bin/phpstan analyse --generate-baseline

# After: count again
grep -c 'count:' phpstan-baseline.neon
```

### CI: Prevent Baseline Growth

Add a CI step that fails if the baseline grows:

```bash
# Store the error count before
BEFORE=$(grep -c 'count:' phpstan-baseline.neon || echo 0)

# Regenerate
./vendor/bin/phpstan analyse --generate-baseline

# Count after
AFTER=$(grep -c 'count:' phpstan-baseline.neon || echo 0)

if [ "$AFTER" -gt "$BEFORE" ]; then
    echo "Baseline grew from $BEFORE to $AFTER errors. Fix new errors before merging."
    exit 1
fi
```
