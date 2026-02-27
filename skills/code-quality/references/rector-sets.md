# Rector Set Lists & Rule Reference

Complete reference for Rector rule sets, PHP version migration, Laravel-specific rules,
dead code removal, type declarations, and custom rule creation. Read this file when
suggesting or applying Rector rules for code modernisation.

---

## Rector Configuration Structure

```php
<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/app',
        __DIR__ . '/config',
        __DIR__ . '/database',
        __DIR__ . '/routes',
        __DIR__ . '/tests',
    ])
    ->withSkip([
        __DIR__ . '/app/Generated',
        __DIR__ . '/app/Legacy',
    ])
    ->withPhpSets(php83: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
    );
```

---

## Prepared Sets (Quick Configuration)

The `withPreparedSets()` method provides curated collections of rules. Use these as the
primary way to configure Rector.

| Parameter | Purpose | Impact |
|---|---|---|
| `deadCode: true` | Remove unreachable and unused code | Medium — removes dead methods, params, conditions |
| `codeQuality: true` | Simplify logic, improve readability | Medium — simplifies ifs, combines assignments |
| `typeDeclarations: true` | Add return types, property types, param types | High — adds type safety throughout |
| `earlyReturn: true` | Convert nested ifs to early returns | Low — readability improvement |
| `naming: true` | Improve variable and method naming | Low — renames based on type |
| `privatization: true` | Make methods/properties private where possible | Medium — tightens visibility |
| `instanceof: true` | Improve instanceof checks | Low — code clarity |
| `carbon: true` | Migrate Carbon v1 to v2/v3 | Depends on usage |

### Recommended Starting Configuration

```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withPhpSets(php83: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
    );
```

---

## PHP Version Migration Sets

These sets modernise PHP syntax to take advantage of newer language features.

### `withPhpSets(php83: true)`

Applies all rules from PHP 5.3 through PHP 8.3. Key transformations per version:

### PHP 7.4 Rules

| Rule | Before | After |
|---|---|---|
| `ArrowFunctionRector` | `function ($x) use ($y) { return $x + $y; }` | `fn ($x) => $x + $y` |
| `TypedPropertyRector` | `/** @var string */ private $name;` | `private string $name;` |
| `NullCoalescingAssignmentRector` | `$x = $x ?? 'default';` | `$x ??= 'default';` |
| `ArraySpreadInsteadOfArrayMergeRector` | `array_merge($a, $b)` | `[...$a, ...$b]` |

**Example transformation:**

```php
// Before
class UserService
{
    /** @var UserRepository */
    private $repository;

    /** @var LoggerInterface */
    private $logger;

    public function __construct(UserRepository $repository, LoggerInterface $logger)
    {
        $this->repository = $repository;
        $this->logger = $logger;
    }

    public function getActive()
    {
        return array_filter($this->repository->all(), function ($user) {
            return $user->isActive();
        });
    }
}

// After
class UserService
{
    private UserRepository $repository;

    private LoggerInterface $logger;

    public function __construct(UserRepository $repository, LoggerInterface $logger)
    {
        $this->repository = $repository;
        $this->logger = $logger;
    }

    public function getActive(): array
    {
        return array_filter($this->repository->all(), fn ($user) => $user->isActive());
    }
}
```

### PHP 8.0 Rules

| Rule | Before | After |
|---|---|---|
| `ConstructorPromotionRector` | Constructor + property + assignment | `public function __construct(private string $name)` |
| `MatchExpressionRector` | `switch` with returns | `match ($x) { ... }` |
| `NullsafeOperatorRector` | `$a !== null ? $a->b() : null` | `$a?->b()` |
| `UnionTypesRector` | `@param string\|int` PHPDoc | `string\|int` native union |
| `MixedTypeRector` | No type hint | `mixed` where appropriate |
| `NamedArgumentRector` | Positional arguments | Named arguments for clarity |

**Example transformation:**

```php
// Before
class OrderService
{
    private OrderRepository $repository;
    private LoggerInterface $logger;

    public function __construct(OrderRepository $repository, LoggerInterface $logger)
    {
        $this->repository = $repository;
        $this->logger = $logger;
    }

    public function getLabel(string $status): string
    {
        switch ($status) {
            case 'pending':
                return 'Awaiting Payment';
            case 'paid':
                return 'Paid';
            case 'shipped':
                return 'Shipped';
            default:
                return 'Unknown';
        }
    }
}

// After
class OrderService
{
    public function __construct(
        private OrderRepository $repository,
        private LoggerInterface $logger,
    ) {
    }

    public function getLabel(string $status): string
    {
        return match ($status) {
            'pending' => 'Awaiting Payment',
            'paid' => 'Paid',
            'shipped' => 'Shipped',
            default => 'Unknown',
        };
    }
}
```

### PHP 8.1 Rules

| Rule | Before | After |
|---|---|---|
| `ReadonlyPropertyRector` | `private string $name` (never reassigned) | `private readonly string $name` |
| `EnumRector` | Class with constants | `enum` where appropriate |
| `IntersectionTypesRector` | PHPDoc intersection | Native `A&B` |
| `FiberRector` | Callback patterns | Fiber where beneficial |
| `FirstClassCallableRector` | `[$this, 'method']` | `$this->method(...)` |

### PHP 8.2 Rules

| Rule | Before | After |
|---|---|---|
| `ReadonlyClassRector` | Class with all readonly props | `readonly class` |
| `ConstantTypesRector` | Constants without types | Typed constants |

### PHP 8.3 Rules

| Rule | Before | After |
|---|---|---|
| `TypedClassConstantsRector` | `const NAME = 'value';` | `const string NAME = 'value';` |
| `DynamicClassConstFetchRector` | `$class::{$const}` | Modern constant fetch |

---

## Laravel-Specific Rules

Rector has a dedicated Laravel set via `driftingly/rector-laravel`:

```bash
composer require --dev driftingly/rector-laravel
```

### Configuration

```php
use RectorLaravel\Set\LaravelSetList;

return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withSets([
        LaravelSetList::LARAVEL_110,
    ]);
```

### Available Laravel Sets

| Set | Purpose |
|---|---|
| `LaravelSetList::LARAVEL_90` | Migrate to Laravel 9 patterns |
| `LaravelSetList::LARAVEL_100` | Migrate to Laravel 10 patterns |
| `LaravelSetList::LARAVEL_110` | Migrate to Laravel 11 patterns |
| `LaravelSetList::LARAVEL_ARRAY_STR_FUNCTIONS_TO_STATIC_CALL` | `array_*` and `str_*` to `Arr::` / `Str::` |
| `LaravelSetList::LARAVEL_FACADE_ALIASES_TO_FULL_NAMES` | Short facade aliases to full class names |
| `LaravelSetList::LARAVEL_LEGACY_FACTORIES_TO_CLASSES` | Legacy `$factory->define()` to class factories |
| `LaravelSetList::LARAVEL_ELOQUENT_MAGIC_METHOD_TO_QUERY_BUILDER` | `User::where()` magic to `User::query()->where()` |

### Key Laravel Rules

**Factories migration:**

```php
// Before (Laravel 7 style)
$factory->define(User::class, function (Faker $faker) {
    return [
        'name' => $faker->name(),
        'email' => $faker->unique()->safeEmail(),
    ];
});

// After (Laravel 8+ class-based)
class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
        ];
    }
}
```

**Helper to facade:**

```php
// Before
$value = array_get($data, 'key.nested');
$slug = str_slug('Hello World');

// After
$value = Arr::get($data, 'key.nested');
$slug = Str::slug('Hello World');
```

**Magic method to query builder:**

```php
// Before — uses __callStatic magic
$users = User::where('active', true)->get();

// After — explicit query builder (better for static analysis)
$users = User::query()->where('active', true)->get();
```

---

## Dead Code Removal

The `deadCode: true` prepared set includes these rules:

| Rule | What It Removes |
|---|---|
| `RemoveUnusedPrivateMethodRector` | Private methods never called within the class |
| `RemoveUnusedPrivatePropertyRector` | Private properties never read |
| `RemoveUnusedConstructorParamRector` | Constructor params not assigned or used |
| `RemoveDeadConditionAboveReturnRector` | Conditions before an unconditional return |
| `RemoveDeadIfForeachForRector` | Empty if/foreach/for blocks |
| `RemoveDeadInstanceOfRector` | `instanceof` checks that are always true |
| `RemoveDeadReturnRector` | Return statements after a return |
| `RemoveDeadTryCatchRector` | Try/catch with empty catch, no side effects in try |
| `RemoveDoubleAssignRector` | Assigning a variable twice with no usage between |
| `RemoveParentCallWithoutParentRector` | `parent::method()` when parent doesn't define it |
| `RemoveEmptyClassMethodRector` | Methods with empty bodies (except abstract/interface) |

**Example transformation:**

```php
// Before
class InvoiceService
{
    private string $unusedProperty;
    private LoggerInterface $logger;

    public function __construct(
        private InvoiceRepository $repository,
        string $unusedParam,
        LoggerInterface $logger,
    ) {
        $this->logger = $logger;
    }

    public function calculate(Invoice $invoice): float
    {
        $total = $invoice->getTotal();

        if ($total > 0) {
            // This condition is checked but result not used
        }

        return $total;
    }

    private function unusedHelper(): void
    {
        // Never called
    }
}

// After
class InvoiceService
{
    private LoggerInterface $logger;

    public function __construct(
        private InvoiceRepository $repository,
        LoggerInterface $logger,
    ) {
        $this->logger = $logger;
    }

    public function calculate(Invoice $invoice): float
    {
        return $invoice->getTotal();
    }
}
```

---

## Type Declaration Rules

The `typeDeclarations: true` prepared set includes:

| Rule | What It Adds |
|---|---|
| `AddReturnTypeDeclarationBasedOnParentClassMethodRector` | Return types matching parent class |
| `TypedPropertyFromAssignsRector` | Property types inferred from assignments |
| `TypedPropertyFromStrictConstructorRector` | Property types from constructor |
| `AddClosureVoidReturnTypeWhereNoReturnRector` | `: void` on closures with no return |
| `ReturnTypeFromReturnNewRector` | Return type when method returns `new X()` |
| `ReturnTypeFromStrictBoolReturnExprRector` | `: bool` when returning bool expressions |
| `ReturnTypeFromStrictNativeCallRector` | Return types from native PHP functions |
| `ReturnTypeFromStrictNewArrayRector` | `: array` when returning arrays |
| `ReturnTypeFromStrictScalarReturnExprRector` | Scalar return types from expressions |
| `AddVoidReturnTypeWhereNoReturnRector` | `: void` on methods with no return |
| `ParamTypeFromStrictTypedPropertyRector` | Param types from typed properties |

**Example transformation:**

```php
// Before
class UserService
{
    private $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function isActive($user)
    {
        return $user->active === true;
    }

    public function create($data)
    {
        return new User($data);
    }

    public function delete($user)
    {
        $this->repository->remove($user);
    }

    public function names()
    {
        return ['admin', 'editor', 'viewer'];
    }
}

// After
class UserService
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function isActive(User $user): bool
    {
        return $user->active === true;
    }

    public function create(array $data): User
    {
        return new User($data);
    }

    public function delete(User $user): void
    {
        $this->repository->remove($user);
    }

    public function names(): array
    {
        return ['admin', 'editor', 'viewer'];
    }
}
```

---

## Early Return Rules

The `earlyReturn: true` prepared set converts nested conditions to guard clauses:

| Rule | What It Does |
|---|---|
| `ChangeAndIfToEarlyReturnRector` | Nested `if` with `&&` to early returns |
| `ChangeOrIfContinueToMultiContinueRector` | `if (a \|\| b) continue` to multiple guards |
| `ChangeNestedForeachIfsToEarlyContinueRector` | Nested foreach ifs to continue |
| `ChangeNestedIfsToEarlyReturnRector` | Deeply nested ifs to guard clauses |
| `PreparedValueToEarlyReturnRector` | Prepared value pattern to early return |
| `ReturnBinaryOrToEarlyReturnRector` | Binary or to early return |

**Example transformation:**

```php
// Before
public function process(Order $order): string
{
    $result = 'unknown';

    if ($order->isPaid()) {
        if ($order->hasItems()) {
            if ($order->isVerified()) {
                $result = 'ready';
            } else {
                $result = 'pending_verification';
            }
        } else {
            $result = 'empty';
        }
    } else {
        $result = 'unpaid';
    }

    return $result;
}

// After
public function process(Order $order): string
{
    if (! $order->isPaid()) {
        return 'unpaid';
    }

    if (! $order->hasItems()) {
        return 'empty';
    }

    if (! $order->isVerified()) {
        return 'pending_verification';
    }

    return 'ready';
}
```

---

## Code Quality Rules

The `codeQuality: true` prepared set simplifies and cleans up code:

| Rule | What It Does |
|---|---|
| `SimplifyIfReturnBoolRector` | `if (x) return true; return false;` to `return x;` |
| `CombinedAssignRector` | `$x = $x + 1;` to `$x += 1;` |
| `SimplifyEmptyCheckOnDominatingNarrowingRector` | Redundant empty checks after type narrowing |
| `SimplifyBoolIdenticalTrueRector` | `$x === true` to `$x` (when already bool) |
| `ForToForeachRector` | `for ($i = 0; ...)` to `foreach` where appropriate |
| `InlineIfToExplicitIfRector` | Ternary to explicit if for complex expressions |
| `ExplicitBoolCompareRector` | Explicit comparisons for clarity |
| `StrlenZeroToIdenticalEmptyStringRector` | `strlen($x) === 0` to `$x === ''` |

**Example transformation:**

```php
// Before
public function hasDiscount(Order $order): bool
{
    if ($order->discount > 0) {
        return true;
    }

    return false;
}

public function applyFee(float $amount): float
{
    $amount = $amount + 10.0;
    $amount = $amount * 1.08;

    return $amount;
}

// After
public function hasDiscount(Order $order): bool
{
    return $order->discount > 0;
}

public function applyFee(float $amount): float
{
    $amount += 10.0;
    $amount *= 1.08;

    return $amount;
}
```

---

## Skipping Rules and Paths

### Skip Specific Rules

```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withPreparedSets(deadCode: true, typeDeclarations: true)
    ->withSkip([
        // Skip a rule globally
        \Rector\DeadCode\Rector\ClassMethod\RemoveEmptyClassMethodRector::class,

        // Skip a rule for specific files
        \Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturnRector::class => [
            __DIR__ . '/app/Http/Controllers/*',
        ],

        // Skip entire directories
        __DIR__ . '/app/Generated',
        __DIR__ . '/database/migrations',
    ]);
```

### Skip Specific Files

```php
->withSkip([
    __DIR__ . '/app/Providers/AppServiceProvider.php',
    __DIR__ . '/config/app.php',
])
```

---

## Running Rector

### Basic Usage

```bash
# Dry run — show proposed changes without applying
./vendor/bin/rector process --dry-run

# Apply changes
./vendor/bin/rector process

# Process specific path
./vendor/bin/rector process app/Services

# Process single file
./vendor/bin/rector process app/Services/PaymentService.php

# Use a specific config file
./vendor/bin/rector process --config=rector-strict.php
```

### Post-Rector Workflow

Always run these tools after Rector:

```bash
# 1. Apply Rector changes
./vendor/bin/rector process

# 2. Fix code style (Rector may break formatting)
./vendor/bin/pint

# 3. Verify no new PHPStan errors
./vendor/bin/phpstan analyse

# 4. Run tests to catch behaviour changes
php artisan test
```

### CI Integration

```yaml
  rector:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          coverage: none
      - name: Install dependencies
        run: composer install --no-interaction --prefer-dist
      - name: Check Rector
        run: ./vendor/bin/rector process --dry-run
```

This fails the CI if any Rector rule would make a change — ensuring all code is already
modernised before merging.

---

## Custom Rule Creation

### Basic Custom Rule

```php
<?php

declare(strict_types=1);

namespace App\Rector;

use PhpParser\Node;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;

final class ForbidDdRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Remove dd() and dump() calls — they should never be committed',
            [
                new CodeSample(
                    <<<'CODE_SAMPLE'
dd($user);
dump($data);
CODE_SAMPLE
                    ,
                    <<<'CODE_SAMPLE'
// dd() and dump() removed
CODE_SAMPLE
                ),
            ],
        );
    }

    public function getNodeTypes(): array
    {
        return [FuncCall::class];
    }

    public function refactor(Node $node): ?int
    {
        if (! $node instanceof FuncCall) {
            return null;
        }

        if (! $node->name instanceof Name) {
            return null;
        }

        $functionName = $this->getName($node->name);

        if (! in_array($functionName, ['dd', 'dump', 'ray'], true)) {
            return null;
        }

        return \PhpParser\NodeVisitor::REMOVE_NODE;
    }
}
```

### Register Custom Rule

```php
// rector.php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withRules([
        \App\Rector\ForbidDdRector::class,
    ])
    ->withPreparedSets(deadCode: true, codeQuality: true);
```

---

## Migration Recipes

### PHP 7.4 to 8.0 Migration

```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withPhpSets(php80: true);
```

Key changes applied: constructor promotion, match expressions, nullsafe operator, union
types, named arguments.

### PHP 8.0 to 8.3 Migration

```php
return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withPhpSets(php83: true);
```

Additional changes: readonly properties, enums, readonly classes, typed constants.

### Laravel 9 to Laravel 11 Migration

```php
use RectorLaravel\Set\LaravelSetList;

return RectorConfig::configure()
    ->withPaths([__DIR__ . '/app'])
    ->withSets([
        LaravelSetList::LARAVEL_100,
        LaravelSetList::LARAVEL_110,
        LaravelSetList::LARAVEL_ARRAY_STR_FUNCTIONS_TO_STATIC_CALL,
        LaravelSetList::LARAVEL_LEGACY_FACTORIES_TO_CLASSES,
        LaravelSetList::LARAVEL_ELOQUENT_MAGIC_METHOD_TO_QUERY_BUILDER,
    ]);
```
