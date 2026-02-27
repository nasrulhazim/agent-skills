---
name: php-best-practices
metadata:
  compatible_agents: [claude-code]
  tags: [php, best-practices, refactoring, rector, modernization]
description: >
  PHP modernization, refactoring, code review, and standards enforcement assistant for
  PHP 8.2+ projects. Use this skill whenever the user wants to modernize legacy PHP code,
  refactor messy classes or controllers, review code for smells and anti-patterns, enforce
  PSR-12 and strict typing standards, or integrate Rector for automated upgrades. Triggers
  for requests like "modernize my PHP code", "refactor this controller", "review this class
  for code smells", "enforce strict types", "suggest Rector rules", "upgrade to PHP 8.2
  features", "replace this array with a DTO", "decompose this fat controller", or "help me
  write better PHP". Also triggers for Malay requests like "tolong review code PHP ni",
  "refactor class ni", "nak upgrade ke PHP 8.2", "code ni messy, tolong clean up",
  "macam mana nak pakai enum dalam PHP", or "nak buang code smell dalam project ni".
  Assumes Rector is already installed in the project as a baseline.
---

# PHP Best Practices

A comprehensive methodology for modernizing, refactoring, and enforcing quality standards
in PHP 8.2+ codebases. Covers language feature adoption, refactoring patterns, code smell
detection, PSR-12 compliance, and Rector-driven automated upgrades.

## Command Reference

| Command | Description |
|---|---|
| `/php modernize` | Upgrade code to use PHP 8.2+ features — enums, readonly, match, named args, null-safe operator, intersection types, DNF types |
| `/php refactor` | Apply refactoring patterns — extract method/class, replace conditional with polymorphism, introduce parameter object, decompose fat controllers |
| `/php review` | Detect code smells and anti-patterns, suggest concrete refactoring steps with before/after examples |
| `/php standards` | Enforce PSR-12, strict types, type coverage, return types, PHPDoc discipline |

---

## 1. `/php modernize` — Adopt PHP 8.2+ Features

Analyze the user's code and identify opportunities to use modern PHP features. Always show
before/after comparisons. Read `references/php82-features.md` for the full feature catalog.

### Modernization Checklist

| Feature | When to Suggest |
|---|---|
| Enums | Constants used as status/type values, stringly-typed state |
| Readonly properties | Properties set once in constructor, never mutated |
| Readonly classes | All properties are readonly — promote to readonly class |
| Named arguments | Functions with many parameters, boolean flags, optional params |
| Match expressions | Switch statements that return values or assign to a variable |
| Null-safe operator | Chained method calls with null checks at each step |
| Intersection types | Value must satisfy multiple type constraints |
| DNF types | Complex union + intersection type combinations |
| First-class callable syntax | `Closure::fromCallable()` or `[$this, 'method']` patterns |
| Constants in traits | Shared constants across trait users |
| Fibers | Cooperative multitasking, async-like patterns without full async framework |

### Workflow

1. Read the file or class the user provides
2. Identify all modernization opportunities, grouped by feature
3. Present each as a before/after diff with a one-line explanation
4. If Rector can automate the change, suggest the specific Rector rule
5. Warn about any breaking changes (e.g., enum vs constant backward compatibility)

---

## 2. `/php refactor` — Apply Refactoring Patterns

Analyze code structure and apply proven refactoring patterns. Read
`references/refactoring-catalog.md` for the full pattern catalog with examples.

### Common Refactoring Triggers

| Smell | Refactoring |
|---|---|
| Method > 20 lines | Extract Method |
| Class > 300 lines | Extract Class |
| 3+ params of same type passed together | Introduce Parameter Object / DTO |
| Switch/if-else on type field | Replace Conditional with Polymorphism |
| Controller > 1 action or > 50 lines | Decompose Fat Controller |
| Deep inheritance tree with override bloat | Replace Inheritance with Composition |
| Repeated inline calculations | Extract Method or Introduce Explaining Variable |
| Method accesses another object's data more than its own | Move Method |

### Workflow

1. Identify the dominant smell in the code
2. Name the refactoring pattern to apply
3. Show the step-by-step transformation (intermediate steps, not just final result)
4. Verify the refactored code preserves behavior
5. Suggest tests to add if none exist for the refactored area

### Fat Controller Decomposition

Fat controllers are the most common Laravel anti-pattern. Decompose using:

1. **Extract Form Request** — validation logic moves to a FormRequest class
2. **Extract Action/Service** — business logic moves to an Action or Service class
3. **Extract Resource/Transformer** — response shaping moves to an API Resource
4. **Extract Event + Listener** — side effects (email, notification, logging) move to events
5. **Single Action Controller** — if a controller has one complex action, use `__invoke()`

---

## 3. `/php review` — Code Smell Detection

Scan code for smells and anti-patterns. Read `references/code-smells.md` for the full
catalog with detection heuristics.

### Review Output Format

For each issue found, present:

```
SMELL: [Name]
SEVERITY: High / Medium / Low
LOCATION: [File:Line]
DESCRIPTION: [What's wrong and why it matters]
REMEDY: [Specific refactoring to apply]
EXAMPLE: [Before/after snippet if helpful]
```

### Anti-Patterns to Flag

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| Stringly-typed code | No IDE support, typo bugs, no exhaustiveness checking | Use enums |
| Array-as-DTO | No type safety, no autocomplete, keys are magic strings | Create a proper DTO class |
| `@` error suppression | Hides real errors, makes debugging impossible | Handle errors explicitly |
| `mixed` types everywhere | Defeats static analysis, no IDE help | Add specific type declarations |
| God class | Violates SRP, impossible to test in isolation | Extract focused classes |
| Service locator / `app()` everywhere | Hidden dependencies, hard to test | Use constructor injection |
| Business logic in Blade templates | Untestable, hard to maintain | Move to view models or computed properties |
| Raw SQL in controllers | SQL injection risk, not reusable | Use Eloquent scopes or repository pattern |

### Review Workflow

1. Read the file(s) the user provides
2. Scan for all smells from the catalog
3. Prioritize: High severity first (bugs, security), then Medium (maintainability), then Low (style)
4. Present findings using the format above
5. For the top 3 issues, provide concrete refactoring steps with code

---

## 4. `/php standards` — PSR-12 & Type Safety

Enforce coding standards and type coverage across the codebase.

### Standards Checklist

| Standard | Rule |
|---|---|
| `declare(strict_types=1)` | Every PHP file, first statement after `<?php` |
| PSR-12 formatting | Braces, spacing, line length, blank lines per PSR-12 |
| Return types | Every method must have a return type — no exceptions |
| Parameter types | Every parameter must be typed |
| Property types | Every property must be typed (PHP 7.4+ typed properties) |
| PHPDoc | Only where types cannot express intent — e.g., `@template`, `@param array<string, int>`, generics |
| No `mixed` | Replace with specific types or union types |
| Null handling | Prefer null-safe operator or early returns over nested null checks |

### PHPDoc Discipline

PHPDoc is NOT a substitute for type declarations. Use PHPDoc only for:

- Generic types: `@param Collection<int, User> $users`
- Array shapes: `@param array{name: string, age: int} $data`
- Template types: `@template T`
- Deprecation notices: `@deprecated Use newMethod() instead`
- Complex return descriptions when the type alone is ambiguous

Remove PHPDoc that merely repeats the type declaration:

```php
// BAD — PHPDoc adds nothing
/** @param string $name */
public function setName(string $name): void

// GOOD — no redundant PHPDoc needed
public function setName(string $name): void
```

### Rector Integration for Standards

Suggest these Rector rule sets for standards enforcement:

- `TypeDeclarationSet` — add missing type declarations
- `DeadCodeSet` — remove unused code
- `CodingStyleSet` — enforce consistent style
- `Php82Set` — upgrade to PHP 8.2 syntax

Read `references/rector-rules.md` for the full rule catalog and custom rule creation.

---

## 5. Rector Integration

Rector is assumed to be already installed in the project. This skill helps configure and
extend it.

### Baseline Configuration

When helping with Rector setup, suggest this starter `rector.php`:

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
    ->withTypeCoverageLevel(0)
    ->withDeadCodeLevel(0)
    ->withCodeQualityLevel(0)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
        earlyReturn: true,
    );
```

### Incremental Adoption Strategy

1. Start with `--dry-run` to see what Rector would change
2. Apply one rule set at a time, run tests after each
3. Increase level numbers gradually (0 -> 1 -> 2 -> ...)
4. Commit after each successful rule set application

Read `references/rector-rules.md` for detailed rule sets and custom rule creation.

---

## Reference Files

| File | Read When |
|---|---|
| `references/php82-features.md` | Modernizing code to PHP 8.2+, explaining new features with examples |
| `references/refactoring-catalog.md` | Applying refactoring patterns, step-by-step transformations |
| `references/rector-rules.md` | Configuring Rector, choosing rule sets, writing custom rules |
| `references/code-smells.md` | Reviewing code for smells, detection heuristics, and remedies |
