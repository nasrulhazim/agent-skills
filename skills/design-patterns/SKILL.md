---
name: design-patterns
metadata:
  compatible_agents: [claude-code]
  tags: [php, laravel, design-patterns, architecture, solid]
description: >
  PHP and Laravel design pattern advisor — suggests, implements, refactors, and reviews
  design patterns in your codebase. Use this skill whenever the user asks about which
  pattern to use, wants to refactor code to follow a pattern, needs a pattern implemented,
  or wants a code review focused on architecture and patterns. Triggers for requests like
  "suggest a pattern for this", "refactor this to use repository pattern", "implement the
  action pattern", "review my code architecture", "which pattern should I use here",
  "is this a good use of singleton", "how do I decouple this", "tolong suggest pattern",
  "refactor guna pattern", "review architecture code ni", "pattern mana sesuai untuk ni",
  "nak implement strategy pattern", or "code ni dah jadi god controller, macam mana nak
  fix". Covers GoF patterns adapted for PHP/Laravel, Laravel-specific patterns (Actions,
  Services, DTOs, Value Objects, Query Scopes, Form Requests, API Resources), SOLID
  principles, and anti-pattern detection. Works with cleaniquecoders/laravel-action for
  the Action pattern.
---

# Design Patterns — PHP & Laravel

Pattern advisor for PHP and Laravel projects. Suggests the right pattern for the problem,
implements it with production-ready code, refactors existing code toward better patterns,
and reviews architecture for anti-patterns.

## Command Reference

| Command | Description |
|---|---|
| `/pattern suggest` | Analyse a problem or code snippet and recommend the best pattern(s) |
| `/pattern implement` | Generate production-ready implementation of a specific pattern |
| `/pattern refactor` | Refactor existing code to follow a recommended pattern |
| `/pattern review` | Review code for anti-patterns, SOLID violations, and improvement opportunities |

---

## 1. `/pattern suggest` — Pattern Recommendation

When the user describes a problem or pastes code:

### Step 1: Identify the Problem Category

| Problem Category | Likely Patterns |
|---|---|
| Complex object creation | Factory, Builder |
| Data access / persistence | Repository |
| Cross-cutting concerns (logging, caching, auth) | Decorator, Pipeline |
| Multiple algorithms / strategies for same task | Strategy |
| Reacting to events / side effects | Observer (Event/Listener) |
| State transitions / workflows | State Machine |
| Encapsulating a business operation | Action, Command (Job) |
| Transforming data between layers | DTO, API Resource, Value Object |
| Simplifying a complex subsystem | Facade (real), Adapter |
| Validation / input processing | Form Request |
| Query composition / reuse | Query Builder Scopes |

### Step 2: Read the Decision Matrix

Read `references/decision-matrix.md` for the full mapping of problem types to patterns
with trade-offs and when-to-avoid guidance.

### Step 3: Present Recommendation

Format:

```
**Recommended:** [Pattern Name]
**Why:** [One sentence — what problem it solves in this context]
**Trade-off:** [What you give up]
**Alternative:** [Second-best option and when you'd pick it instead]
```

If multiple patterns apply (e.g., Repository + DTO), explain how they compose together.

---

## 2. `/pattern implement` — Generate Pattern Code

When the user asks to implement a specific pattern:

### Step 1: Confirm Context

Ask (only if not already clear):
- What is the domain entity / use case? (e.g., "Order processing", "User registration")
- Laravel or plain PHP?
- Any existing interfaces or base classes to follow?

### Step 2: Read Reference Files

- `references/pattern-catalog.md` — for GoF patterns adapted to PHP/Laravel
- `references/laravel-patterns.md` — for Laravel-specific patterns

### Step 3: Generate Implementation

Generate all files needed for the pattern:

| Pattern | Files Generated |
|---|---|
| Repository | Interface, Eloquent implementation, Service Provider binding |
| Action | Action class, test file (uses `cleaniquecoders/laravel-action` conventions) |
| Strategy | Interface, concrete strategies, context class |
| Observer | Event class, Listener class, EventServiceProvider registration |
| Pipeline | Pipeline stages as invokable classes, pipeline orchestrator |
| DTO | DTO class with `fromRequest()` and `fromModel()` factory methods |
| Value Object | Immutable class with validation in constructor, equality comparison |
| Factory | Interface, concrete factory, registration in Service Provider |
| Builder | Builder class with fluent API, Director class if needed |
| Decorator | Interface, base implementation, decorator(s), Provider binding |
| State Machine | State interface, concrete states, context class with transitions |

### Step 4: Show Usage

Always include a usage example showing how the pattern integrates with the rest of
the application — controller, route, test, or artisan command.

---

## 3. `/pattern refactor` — Refactor Toward Pattern

When the user pastes code that needs restructuring:

### Step 1: Analyse Current Code

Identify:
- What anti-patterns exist (God controller, fat model, etc.)
- What the code is actually doing (separate concerns)
- Which pattern(s) would improve it

### Step 2: Present Refactoring Plan

Before writing code, show the plan:

```
**Current:** [What the code does now and why it's problematic]
**Target:** [What pattern(s) to apply]
**Steps:**
1. [Extract X into Y]
2. [Create Z interface]
3. [Move logic from A to B]
**Files changed:** [List of files that will be created/modified]
```

Get confirmation before proceeding.

### Step 3: Generate Refactored Code

Show each file with clear comments marking what changed and why.
Include before/after comparison for the main file (e.g., the controller that got thinner).

### Step 4: Generate Tests

For every refactored pattern, generate a Pest test that verifies the behaviour is preserved.

---

## 4. `/pattern review` — Architecture Review

When the user asks for a code review focused on patterns and architecture:

### Step 1: Scan the Codebase

Look at:
- Controllers — are they thin? Do they delegate to actions/services?
- Models — are they doing too much? Business logic in models?
- Services — are they focused (single responsibility) or god services?
- Routes — are resources RESTful?
- Tests — do they test behaviour or implementation details?

### Step 2: Check for Anti-Patterns

| Anti-Pattern | Symptoms | Recommendation |
|---|---|---|
| God Controller | Controller > 200 lines, multiple responsibilities | Extract to Actions or Service classes |
| Fat Model | Model has business logic, query logic, and validation | Extract to Actions, Scopes, Form Requests |
| Service Locator | `app()->make()` scattered everywhere | Use constructor injection |
| Premature Abstraction | Interface with only one implementation, no plan for second | Remove interface, use concrete class |
| Anaemic Domain Model | Models are just data bags, all logic in services | Move domain logic to model methods or Value Objects |
| Leaky Abstraction | Controller knows about database columns, raw queries | Use Repository or Eloquent scopes |
| God Service | Service class > 300 lines doing everything | Split by use case into Action classes |
| Config in Code | Hardcoded values that should be configurable | Extract to config files or .env |

### Step 3: Present Review

Format as a structured report:

```
## Architecture Review — [Context]

### Score: [A/B/C/D] — [One-line summary]

### Strengths
- [What's already good]

### Issues Found
1. **[SEVERITY]** [Anti-pattern name] in [file]
   - Problem: [What's wrong]
   - Fix: [Recommended pattern/action]

### Recommended Refactors (Priority Order)
1. [Highest impact change]
2. [Second highest]
3. [Third]

### Quick Wins
- [Small changes that improve things immediately]
```

---

## Pattern Categories

### Creational Patterns

| Pattern | Use When | Laravel Context |
|---|---|---|
| Factory | Need to create objects without specifying exact class | Service container bindings, notification channels |
| Builder | Complex object with many optional parameters | Query builders, mail message composition |
| Singleton | Exactly one instance needed (use sparingly) | Service container `singleton()` bindings |

### Structural Patterns

| Pattern | Use When | Laravel Context |
|---|---|---|
| Repository | Decouple data access from business logic | Eloquent repository with interface |
| Decorator | Add behaviour without modifying original class | Cache decorator around repository |
| Adapter | Make incompatible interfaces work together | Wrapping third-party APIs |
| Facade (real) | Simplify complex subsystem interface | Not Laravel's `Facade` class — actual structural pattern |

### Behavioural Patterns

| Pattern | Use When | Laravel Context |
|---|---|---|
| Strategy | Algorithm varies at runtime | Payment gateways, export formats, notification channels |
| Observer | React to events without coupling | Laravel Events + Listeners |
| Pipeline | Sequential processing with stages | Laravel Pipeline, middleware |
| Command | Encapsulate operation as object | Laravel Jobs, queued operations |
| State Machine | Object behaviour changes based on state | Order status, approval workflows |

### Laravel-Specific Patterns

| Pattern | Use When | Package/Feature |
|---|---|---|
| Action | Single-purpose business operation | `cleaniquecoders/laravel-action` |
| Service Class | Orchestrate multiple actions/repos | Plain PHP class, injected via container |
| DTO | Transfer data between layers | Plain PHP class with readonly properties |
| Value Object | Domain concept with equality by value | Immutable PHP class (Money, Email, etc.) |
| Query Scope | Reusable query constraints | Eloquent local/global scopes |
| Form Request | Validation + authorization | Laravel Form Request classes |
| API Resource | Presentation/transformation layer | Laravel API Resources + Resource Collections |

---

## SOLID Quick Reference

Apply these when suggesting or reviewing patterns:

| Principle | Check | Common Laravel Violation |
|---|---|---|
| **S** — Single Responsibility | Does this class have one reason to change? | Controller doing validation + business logic + response formatting |
| **O** — Open/Closed | Can I extend behaviour without modifying? | Switch statements that grow with new cases → use Strategy |
| **L** — Liskov Substitution | Can I swap implementations? | Repository interface methods that only work with Eloquent |
| **I** — Interface Segregation | Does the consumer use all methods? | Bloated service interface → split into focused interfaces |
| **D** — Dependency Inversion | Do I depend on abstractions? | `new ConcreteClass()` inside business logic → inject interface |

---

## Reference Files

| File | Read When |
|---|---|
| `references/pattern-catalog.md` | Implementing any GoF pattern — has full PHP/Laravel code examples |
| `references/laravel-patterns.md` | Implementing Laravel-specific patterns — Actions, Services, DTOs, etc. |
| `references/decision-matrix.md` | Deciding which pattern to use — problem-to-pattern mapping with trade-offs |
