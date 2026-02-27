# Rector Rules Reference

Rector rule sets, configuration patterns, and custom rule creation for PHP modernization.
Use this reference when configuring Rector or suggesting automated upgrades.

---

## Core Rule Sets

### PHP Version Upgrade Sets

Upgrade syntax to take advantage of newer PHP features.

```php
use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPhpSets(php82: true);
```

Key rules activated by PHP 8.2 set:

| Rule | What It Does |
|---|---|
| `ReadonlyPropertyRector` | Adds `readonly` to properties set only in constructor |
| `ReadonlyClassRector` | Promotes classes to `readonly` when all properties are readonly |
| `ConstantInTraitRector` | Allows constants in traits (PHP 8.2 syntax) |
| `Php82NullableToUnionTypeRector` | Converts `?Type` to `Type\|null` where appropriate |

Previous version sets (also activated with `php82: true`):

| Rule | PHP Version | What It Does |
|---|---|---|
| `MatchExpressionRector` | 8.0 | Converts simple switch to match expression |
| `NullsafeOperatorRector` | 8.0 | Converts null-check chains to `?->` |
| `MixedTypeRector` | 8.0 | Adds `mixed` type where no type exists |
| `NamedArgumentRector` | 8.0 | Named args for boolean/null params (conservative) |
| `FirstClassCallableRector` | 8.1 | Converts `Closure::fromCallable()` to `...` syntax |
| `ReadonlyPropertyRector` | 8.1 | Adds `readonly` modifier |
| `EnumFromConstantsRector` | 8.1 | Suggests enum conversion for constant groups |

---

### Dead Code Removal

Remove code that is never executed or serves no purpose.

```php
return RectorConfig::configure()
    ->withDeadCodeLevel(0) // start at 0, increase gradually
    ->withPreparedSets(deadCode: true);
```

Key rules:

| Rule | What It Removes |
|---|---|
| `RemoveUnusedPrivateMethodRector` | Private methods never called within the class |
| `RemoveUnusedPrivatePropertyRector` | Private properties never read |
| `RemoveUnusedConstructorParamRector` | Constructor params not assigned to properties or used |
| `RemoveDeadConditionAboveReturnRector` | Dead code above unconditional return |
| `RemoveUnusedVariableAssignRector` | Variables assigned but never used |
| `RemoveEmptyClassMethodRector` | Empty methods with no body |
| `RemoveDeadTryCatchRector` | Try-catch where catch does nothing |
| `RemoveParentCallWithoutParentRector` | `parent::method()` when parent has no such method |
| `RemoveDuplicatedIfReturnRector` | Duplicate if-return blocks |

---

### Type Declarations

Add missing type hints to parameters, return types, and properties.

```php
return RectorConfig::configure()
    ->withTypeCoverageLevel(0) // start at 0, increase gradually
    ->withPreparedSets(typeDeclarations: true);
```

Key rules:

| Rule | What It Adds |
|---|---|
| `AddReturnTypeDeclarationFromUsageRector` | Infers return type from actual returns |
| `ParamTypeByMethodCallTypeRector` | Infers param type from how the method is called |
| `PropertyTypeFromStrictSetterGetterRector` | Infers property type from typed setter/getter |
| `ReturnTypeFromReturnNewRector` | Adds return type when method returns `new ClassName()` |
| `AddVoidReturnTypeWhereNoReturnRector` | Adds `void` return type when method returns nothing |
| `TypedPropertyFromStrictConstructorRector` | Types properties based on constructor assignment |
| `ReturnTypeFromStrictTypedCallRector` | Return type from calling a typed method |

---

### Code Quality

Improve code readability and reduce complexity.

```php
return RectorConfig::configure()
    ->withCodeQualityLevel(0)
    ->withPreparedSets(codeQuality: true);
```

Key rules:

| Rule | What It Improves |
|---|---|
| `SimplifyIfReturnBoolRector` | `if ($x) { return true; } return false;` -> `return $x;` |
| `SimplifyIfElseToTernaryRector` | Simple if/else to ternary |
| `CombinedAssignRector` | `$x = $x + 1;` -> `$x += 1;` |
| `InlineIfToExplicitIfRector` | Inline if with side effect to explicit if block |
| `SimplifyBoolIdenticalTrueRector` | `$x === true` -> `$x` |
| `SimplifyConditionRector` | Simplify redundant conditions |
| `ThrowWithPreviousExceptionRector` | Pass `$previous` exception in catch blocks |
| `ExplicitBoolCompareRector` | `if ($count)` -> `if ($count > 0)` |

---

### Naming Conventions

Enforce consistent naming across the codebase.

```php
return RectorConfig::configure()
    ->withPreparedSets(naming: true);
```

Key rules:

| Rule | What It Renames |
|---|---|
| `RenamePropertyToMatchTypeRector` | `$user` for `User` typed properties (not `$u` or `$data`) |
| `RenameParamToMatchTypeRector` | Parameters named after their type |
| `RenameVariableToMatchNewTypeRector` | `$result = new UserDTO()` -> `$userDTO = new UserDTO()` |

---

### Early Return

Reduce nesting by flipping conditions and returning early.

```php
return RectorConfig::configure()
    ->withPreparedSets(earlyReturn: true);
```

Key rules:

| Rule | What It Does |
|---|---|
| `ChangeNestedIfsToEarlyReturnRector` | Nested if blocks to guard clauses |
| `ChangeIfElseValueAssignToEarlyReturnRector` | if/else assignment to early return |
| `ChangeOrIfContinueToMultiContinueRector` | `if ($a \|\| $b) continue` to separate checks |
| `PreparedValueToEarlyReturnRector` | Variable prepared then returned to early return |
| `ReturnBinaryOrToEarlyReturnRector` | `return $a \|\| $b` to early return pattern |

```php
// BEFORE — deep nesting
public function processOrder(Order $order): ?Invoice
{
    if ($order->isValid()) {
        if ($order->hasStock()) {
            if ($order->paymentConfirmed()) {
                $invoice = $this->createInvoice($order);
                $this->sendNotification($invoice);
                return $invoice;
            }
        }
    }

    return null;
}
```

```php
// AFTER — early returns (guard clauses)
public function processOrder(Order $order): ?Invoice
{
    if (! $order->isValid()) {
        return null;
    }

    if (! $order->hasStock()) {
        return null;
    }

    if (! $order->paymentConfirmed()) {
        return null;
    }

    $invoice = $this->createInvoice($order);
    $this->sendNotification($invoice);

    return $invoice;
}
```

---

## Recommended Configuration

### Starter Config (Conservative)

For projects just starting with Rector — safe, minimal changes.

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
        __DIR__ . '/app/Providers',   // careful with service providers
        __DIR__ . '/bootstrap',
    ])
    ->withPhpSets(php82: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
    )
    ->withTypeCoverageLevel(0)
    ->withDeadCodeLevel(0)
    ->withCodeQualityLevel(0);
```

### Intermediate Config

After the starter config is clean, increase levels.

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
    ->withPhpSets(php82: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
        naming: true,
    )
    ->withTypeCoverageLevel(5)
    ->withDeadCodeLevel(5)
    ->withCodeQualityLevel(5);
```

### Aggressive Config

For greenfield projects or major modernization pushes.

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
    ->withPhpSets(php82: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
        naming: true,
    )
    ->withTypeCoverageLevel(37)
    ->withDeadCodeLevel(50)
    ->withCodeQualityLevel(34);
```

---

## Incremental Adoption Strategy

Running Rector on a legacy codebase all at once is risky. Follow this process:

### Step 1: Dry Run

```bash
vendor/bin/rector process --dry-run
```

Review the proposed changes. If too many, narrow the paths or reduce rules.

### Step 2: One Set at a Time

Apply rule sets one at a time, running tests after each:

```bash
# Round 1: dead code only
vendor/bin/rector process
php artisan test

# Round 2: add type declarations
# increase withTypeCoverageLevel to 1, run again
vendor/bin/rector process
php artisan test

# Round 3: add code quality
# increase withCodeQualityLevel to 1, run again
vendor/bin/rector process
php artisan test
```

### Step 3: Increase Levels Gradually

Each level adds more aggressive rules. Increase by 1-2 at a time:

```
Level 0 -> 1 -> 2 -> 5 -> 10 -> 20 -> max
```

Run tests after each level increase. If tests break, investigate the failing rule
and either fix the code or skip that specific rule.

### Step 4: Skip Problematic Rules

If a specific rule causes issues, skip it:

```php
return RectorConfig::configure()
    ->withSkip([
        \Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector::class,
        // Skip specific file for a specific rule
        \Rector\TypeDeclaration\Rector\ClassMethod\AddVoidReturnTypeWhereNoReturnRector::class => [
            __DIR__ . '/app/Models/*',
        ],
    ]);
```

---

## Custom Rector Rules

When the built-in rules don't cover your needs, create custom rules.

### Custom Rule Structure

```php
<?php

declare(strict_types=1);

namespace App\Rector;

use PhpParser\Node;
use PhpParser\Node\Expr\FuncCall;
use PhpParser\Node\Name;
use Rector\Rector\AbstractRector;
use Symplify\RuleDocGenerator\ValueObject\CodeSample\CodeSample;
use Symplify\RuleDocGenerator\ValueObject\RuleDefinition;

final class ReplaceDdWithLoggerRector extends AbstractRector
{
    public function getRuleDefinition(): RuleDefinition
    {
        return new RuleDefinition(
            'Replace dd() calls with logger()->debug()',
            [
                new CodeSample(
                    <<<'CODE_SAMPLE'
dd($variable);
CODE_SAMPLE,
                    <<<'CODE_SAMPLE'
logger()->debug('Debug output', ['variable' => $variable]);
CODE_SAMPLE,
                ),
            ],
        );
    }

    /**
     * @return array<class-string<Node>>
     */
    public function getNodeTypes(): array
    {
        return [FuncCall::class];
    }

    /**
     * @param FuncCall $node
     */
    public function refactor(Node $node): ?Node
    {
        if (! $this->isName($node, 'dd')) {
            return null;
        }

        // Replace dd() with logger()->debug()
        $loggerCall = $this->nodeFactory->createMethodCall(
            $this->nodeFactory->createFuncCall('logger'),
            'debug',
            [
                $this->nodeFactory->createArg(
                    $this->nodeFactory->createString('Debug output')
                ),
            ]
        );

        return $loggerCall;
    }
}
```

### Register Custom Rule

```php
// rector.php
return RectorConfig::configure()
    ->withRules([
        App\Rector\ReplaceDdWithLoggerRector::class,
    ]);
```

### Common Custom Rule Ideas for Laravel

| Rule | Purpose |
|---|---|
| `ReplaceDdWithLoggerRector` | Remove `dd()` / `dump()` from production code |
| `EnforceStrictTypesRector` | Add `declare(strict_types=1)` to all files |
| `ReplaceArrayConfigWithEnumRector` | Replace `'status' => 'active'` with enums |
| `EnforceFormRequestValidationRector` | Flag controllers using `$request->validate()` instead of FormRequest |
| `ReplaceHelperWithFacadeRector` | Replace `config()` helper with `Config::get()` (or vice versa, per project preference) |
| `EnforceSingleActionControllerRector` | Flag controllers with more than one public method |

---

## Rector CI Integration

### GitHub Actions

```yaml
name: Rector
on:
  pull_request:
    paths:
      - '**.php'

jobs:
  rector:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
      - run: composer install --no-progress
      - run: vendor/bin/rector process --dry-run --ansi
```

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep '\.php$' || true)

if [ -n "$CHANGED_FILES" ]; then
    vendor/bin/rector process $CHANGED_FILES --dry-run
    if [ $? -ne 0 ]; then
        echo "Rector found issues. Run 'vendor/bin/rector process' to fix."
        exit 1
    fi
fi
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Rector changes break tests | Reduce level, skip the problematic rule, fix tests |
| Too many changes at once | Process one directory at a time: `--paths app/Models` |
| Rule conflict with Laravel magic | Skip the rule for Models/Providers directories |
| Memory issues on large codebase | Process in smaller batches, increase PHP memory limit |
| Rector removes method used via magic | Add `@use` annotation or skip the rule for that class |
