---
name: code-quality
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, phpstan, pint, rector, quality]
description: >
  PHP and Laravel code quality toolchain — static analysis with Larastan/PHPStan, code style
  enforcement with Pint, automated refactoring with Rector, baseline management for legacy
  codebases, and CI pipeline integration via GitHub Actions. Use this skill whenever the user
  asks to check code quality, fix linting errors, run static analysis, modernise PHP code,
  set up CI quality gates, manage PHPStan baselines, configure Pint presets, or apply Rector
  rules. Triggers for requests like "run quality check", "fix my code style", "analyse with
  larastan", "update phpstan baseline", "modernise my PHP code", "set up CI for quality",
  "check code quality", "pint tak jalan", "nak fix phpstan error", "setup rector", "betulkan
  code style", "tambah quality gate dalam CI", or "baseline phpstan untuk legacy code".
  Assumes Laravel Kickoff as the baseline — PHPStan, Pint, Rector, and GitHub Actions CI
  are already configured. This skill extends and customises that baseline.
---

# Code Quality Toolchain

Static analysis, code style enforcement, automated refactoring, and CI quality gates for
Laravel projects. Built on top of Laravel Kickoff's existing PHPStan, Pint, Rector, and
GitHub Actions configuration.

## Command Reference

| Command | Description |
|---|---|
| `/quality check` | Run Larastan analysis, interpret errors, suggest fixes |
| `/quality fix` | Auto-fix Pint violations with explanations of what changed |
| `/quality baseline` | Generate or update PHPStan baseline for legacy code |
| `/quality rector` | Suggest and apply Rector rules for code modernisation |
| `/quality ci` | Extend GitHub Actions CI with custom quality gates |

---

## Kickoff Baseline

Laravel Kickoff projects ship with these tools pre-configured:

| Tool | Config File | Purpose |
|---|---|---|
| PHPStan / Larastan | `phpstan.neon` | Static analysis |
| Laravel Pint | `pint.json` | Code style (PSR-12 / Laravel preset) |
| Rector | `rector.php` | Automated refactoring |
| GitHub Actions | `.github/workflows/ci.yml` | CI pipeline |

This skill **extends** that baseline — it does not replace it. Always read the existing
config files before suggesting changes. Never overwrite without confirming with the user.

---

## 1. `/quality check` — Larastan Analysis

### Step 1: Run Analysis

```bash
./vendor/bin/phpstan analyse --memory-limit=512M
```

If a baseline exists (`phpstan-baseline.neon`), PHPStan automatically excludes baselined
errors. Only new errors are reported.

### Step 2: Interpret Errors

For each error, explain:

1. **What** the error means in plain language
2. **Why** PHPStan flags it (type safety, missing return, undefined method, etc.)
3. **How** to fix it with a concrete code change

### Common Error Patterns

| Error Pattern | Meaning | Fix |
|---|---|---|
| `Parameter #1 $x expects string, int given` | Type mismatch in function call | Cast or validate the input type |
| `Call to an undefined method` | Method does not exist on the resolved type | Add `@method` PHPDoc or fix the class reference |
| `Property $x has no type declaration` | Missing property type | Add typed property: `public string $x;` |
| `Method should return X but returns Y` | Return type mismatch | Fix return value or widen the return type |
| `Access to an undefined property` | Property not declared on the class | Declare the property or add `@property` PHPDoc |
| `Dead catch — Throwable is never thrown` | Catching an exception that cannot occur | Remove the dead catch or fix the try block |
| `If condition is always true/false` | Redundant conditional logic | Simplify the condition or remove dead code |

### Step 3: Suggest Fixes

Present fixes grouped by file. For each fix:

```
File: app/Services/PaymentService.php:42
Error: Parameter #1 $amount expects int, string given

Current:
    $this->charge($request->input('amount'));

Fix:
    $this->charge((int) $request->input('amount'));

Explanation: Request input returns string|null. Cast to int before passing
to charge() which expects an integer parameter.
```

### Error Levels

Refer to `references/larastan-rules.md` for the full error level breakdown (0-9).
Recommend the user start at level 5 for existing projects and work up incrementally.

---

## 2. `/quality fix` — Pint Code Style

### Step 1: Preview Changes

```bash
./vendor/bin/pint --test
```

This shows what would change without modifying files.

### Step 2: Apply Fixes

```bash
./vendor/bin/pint
```

### Step 3: Explain Changes

After fixing, explain the most impactful changes. Group by rule:

```
Pint fixed 23 files:

Spacing & Alignment (14 files):
  - binary_operator_spaces: aligned = and => operators
  - no_extra_blank_lines: removed double blank lines

Imports (6 files):
  - ordered_imports: sorted use statements alphabetically
  - no_unused_imports: removed 4 unused imports

Type Declarations (3 files):
  - fully_qualified_strict_types: converted FQCN to imports
```

### Step 4: Preset Recommendations

If the user has no `pint.json` or uses the default preset, recommend a preset based on
project context. Refer to `references/pint-presets.md` for preset details and common
rule customisations.

| Context | Recommended Preset |
|---|---|
| New Laravel project | `laravel` (default) |
| Open-source package | `psr12` |
| Strict team standards | `per` with custom rules |
| Symfony-influenced | `symfony` |

---

## 3. `/quality baseline` — PHPStan Baseline Management

### When to Use

- Legacy codebase with hundreds of existing errors
- Upgrading PHPStan level (e.g., 5 to 6) without fixing all errors immediately
- Onboarding a team — prevent new errors while gradually fixing old ones

### Step 1: Generate Baseline

```bash
./vendor/bin/phpstan analyse --generate-baseline
```

This creates `phpstan-baseline.neon` containing all current errors as "accepted" — future
runs only flag new code.

### Step 2: Include Baseline in Config

Verify `phpstan.neon` includes the baseline:

```neon
includes:
    - phpstan-baseline.neon
    - vendor/larastan/larastan/extension.neon
```

### Step 3: Baseline Maintenance Plan

Present a reduction plan:

```
Current baseline: 142 errors

Recommended reduction plan:
  Week 1-2:  Fix "missing return type" errors (38 occurrences)
  Week 3-4:  Fix "undefined property" errors (27 occurrences)
  Week 5-6:  Fix "type mismatch" errors (44 occurrences)
  Week 7-8:  Fix remaining 33 errors

After each batch: regenerate baseline to lock in progress.
```

### Step 4: Regenerate After Fixes

After the user fixes a batch:

```bash
./vendor/bin/phpstan analyse --generate-baseline
```

Compare the before/after counts. Celebrate progress.

### Baseline Anti-Patterns

| Anti-Pattern | Why It's Bad | Instead |
|---|---|---|
| Baseline everything and forget | Errors accumulate silently | Schedule regular reduction sprints |
| Never baseline, fix everything now | Blocks feature work for days | Baseline and reduce incrementally |
| Baseline + lower the level | Hides problems at two layers | Keep level, use baseline only |
| Committing baseline changes without review | May silently accept new errors | Require PR review for baseline changes |

---

## 4. `/quality rector` — Code Modernisation

### Step 1: Audit Current Config

Read `rector.php` and identify which rule sets are active. Refer to
`references/rector-sets.md` for the full catalogue.

### Step 2: Suggest Rules

Based on the project's PHP version and codebase patterns, suggest relevant rule sets:

```php
// rector.php
use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/app',
        __DIR__ . '/config',
        __DIR__ . '/database',
        __DIR__ . '/routes',
        __DIR__ . '/tests',
    ])
    ->withPhpSets(php83: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
    );
```

### Step 3: Dry Run

Always dry-run first:

```bash
./vendor/bin/rector process --dry-run
```

Present the proposed changes grouped by rule:

```
Rector would apply 47 changes:

Dead Code Removal (12 changes):
  - RemoveUnusedPrivateMethodRector: 5 methods
  - RemoveDeadConditionAboveReturnRector: 4 conditions
  - RemoveUnusedConstructorParamRector: 3 params

Type Declarations (18 changes):
  - AddReturnTypeDeclarationBasedOnParentClassMethodRector: 8 methods
  - TypedPropertyFromAssignsRector: 10 properties

Early Return (9 changes):
  - ChangeAndIfToEarlyReturnRector: 9 occurrences

Code Quality (8 changes):
  - SimplifyIfReturnBoolRector: 5 occurrences
  - CombinedAssignRector: 3 occurrences
```

### Step 4: Apply

After user confirms:

```bash
./vendor/bin/rector process
```

Then immediately run Pint to fix any style issues Rector may introduce:

```bash
./vendor/bin/pint
```

And verify with PHPStan:

```bash
./vendor/bin/phpstan analyse
```

### Step 5: Review Key Changes

Highlight the most impactful transformations with before/after examples:

```
Before (app/Services/OrderService.php:67):
    public function isComplete($order)
    {
        if ($order->status === 'complete') {
            return true;
        }
        return false;
    }

After:
    public function isComplete(Order $order): bool
    {
        return $order->status === 'complete';
    }

Rules applied:
  - AddReturnTypeDeclarationBasedOnParentClassMethodRector
  - SimplifyIfReturnBoolRector
  - TypedPropertyFromAssignsRector
```

---

## 5. `/quality ci` — GitHub Actions Quality Gates

### Step 1: Audit Existing CI

Read `.github/workflows/ci.yml` (Kickoff ships one). Identify what's already there and
what's missing.

### Step 2: Extend with Quality Gates

Suggest adding dedicated quality jobs. Present as a diff against the existing workflow:

```yaml
# Add to .github/workflows/ci.yml

  phpstan:
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
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse --memory-limit=512M --error-format=github

  pint:
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
      - name: Check code style
        run: ./vendor/bin/pint --test

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

### Step 3: Error Format for GitHub

PHPStan supports `--error-format=github` which creates inline annotations on PRs.
Always recommend this format for CI:

```bash
./vendor/bin/phpstan analyse --error-format=github
```

### Step 4: Branch Protection Rules

Recommend branch protection settings:

```
Branch: main
  - Require status checks to pass:
    - phpstan
    - pint
    - rector
    - tests
  - Require PR reviews: 1
  - Dismiss stale reviews on new pushes
```

### Step 5: Caching Strategy

Add Composer cache to speed up CI runs:

```yaml
      - name: Get Composer cache directory
        id: composer-cache
        run: echo "dir=$(composer config cache-files-dir)" >> $GITHUB_OUTPUT
      - uses: actions/cache@v4
        with:
          path: ${{ steps.composer-cache.outputs.dir }}
          key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
          restore-keys: ${{ runner.os }}-composer-
```

---

## Workflow: Full Quality Pass

When the user asks for a complete quality check, run all tools in sequence:

1. **Pint** — fix style first (cleanest diffs for subsequent tools)
2. **Rector** — modernise code (may change structure)
3. **Pint again** — clean up anything Rector introduced
4. **PHPStan** — analyse the final state
5. **Report** — summarise all changes and remaining issues

```bash
./vendor/bin/pint
./vendor/bin/rector process
./vendor/bin/pint
./vendor/bin/phpstan analyse --memory-limit=512M
```

Present a summary:

```
Quality Pass Complete
=====================

Pint:     Fixed 23 files (style violations)
Rector:   Applied 47 changes (modernisation)
Pint:     Fixed 3 files (post-Rector cleanup)
PHPStan:  0 errors (level 5)

Status: All quality gates passing
```

---

## Reference Files

| File | Read When |
|---|---|
| `references/larastan-rules.md` | Interpreting PHPStan errors, choosing error levels, custom rule patterns |
| `references/pint-presets.md` | Configuring Pint presets, customising rules, .pint.json examples |
| `references/rector-sets.md` | Choosing Rector rule sets, PHP migration rules, Laravel-specific rules |
