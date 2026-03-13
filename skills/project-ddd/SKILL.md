---
name: project-ddd
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, ddd, domain-driven-design, architecture, refactor, modules, bounded-context]
description: >
  Pragmatic Domain-Driven Design for Laravel projects — business-first, not academic. Helps restructure
  Laravel apps from default flat structure into domain-based organisation with clear bounded contexts,
  domain layers (Models, Events, Contracts, Value Objects), application layers (Actions, Jobs, Services),
  and infrastructure layers (Registrars, Exports, Integrations). Focuses on what matters to the business:
  reducing OPEX through maintainable code, increasing velocity through clear ownership, and enabling
  teams to work independently on bounded contexts. Includes domain discovery interview, migration planner,
  scaffolding, service provider wiring, autoloading config, and architecture test updates. Use this skill
  whenever the user asks to restructure a Laravel app into domains, apply DDD, organise by business context,
  migrate to modular structure, or says "restructure app guna DDD", "nak buat domain-based structure",
  "organise code ikut business domain", "migrate to DDD", "buat bounded context", "refactor monolith to
  domains", "nak modular structure", "domain layer untuk module ni", "how to structure my Laravel app
  by domains", or "tolong susun code ikut domain". Assumes Laravel Kickoff as baseline — works alongside
  project-laravel conventions.
---

# Domain-Driven Design — Pragmatic Laravel

Restructure Laravel applications into domain-based organisation. Business objectives first —
increase revenue, reduce OPEX, ship faster. Not academic DDD, but practical domain separation
that your team can maintain.

## Philosophy

> "Kita orang meniaga nak increase sales, kurangkan OPEX. Bukan nak berfilasuf pasal kod."

This skill applies DDD where it creates real business value:

- **Clear ownership** — each domain maps to a business capability, team knows what they own
- **Independent velocity** — domains can evolve without breaking each other
- **Reduced OPEX** — less accidental complexity, faster onboarding, fewer cross-cutting bugs
- **Business alignment** — code structure mirrors how the business actually works

## Command Reference

| Command | Description |
|---|---|
| `/project-ddd discover` | Interview to identify bounded contexts from business processes |
| `/project-ddd plan` | Generate migration plan from flat Laravel to domain structure |
| `/project-ddd scaffold` | Scaffold a new domain with all layers |
| `/project-ddd migrate` | Move existing code into domain structure (guided, step-by-step) |
| `/project-ddd wire` | Create/update domain service providers and autoloading |
| `/project-ddd test` | Update architecture tests for DDD structure |
| `/project-ddd audit` | Check existing domain structure for violations |

---

## 1. `/project-ddd discover` — Domain Discovery

### Purpose

Identify bounded contexts by interviewing the user about their **business processes**, not
their code structure.

### Interview Questions

Ask in this order:

1. **What does your business do?** (one sentence)
2. **What are the main things your users do?** (list activities/workflows)
3. **What are your revenue streams?** (what gets you paid)
4. **What teams or roles exist?** (who owns what)
5. **What external systems do you integrate with?** (payments, email, SMS, APIs)
6. **What are your biggest pain points right now?** (what breaks, what's slow)

### Output

Produce a **Domain Map** table:

```markdown
## Domain Map

| Domain | Business Capability | Key Models | Owner | Priority |
|---|---|---|---|---|
| Identity | User auth, roles, profiles | User, Role, Team | Core | High |
| Billing | Subscriptions, invoicing | Plan, Subscription, Invoice | Revenue | High |
| Catalogue | Products, pricing, inventory | Product, Category, Price | Revenue | Medium |
| Fulfilment | Orders, shipping, tracking | Order, Shipment, Tracking | Ops | Medium |
| Notification | Alerts, emails, SMS | Channel, Template, Delivery | Support | Low |
| Shared | Base models, common traits | Base, Activity, Setting | Core | — |
```

Rules:
- Always include a **Shared** domain for cross-cutting concerns
- Priority is based on **business impact**, not code complexity
- Each domain should map to a real business capability, not a technical concept
- If a "domain" is just a CRUD wrapper, it probably belongs inside another domain

---

## 2. `/project-ddd plan` — Migration Plan

### Purpose

Generate a step-by-step migration plan to move from flat Laravel to domain structure.

### Step 1: Analyse Current Structure

Read the project's current `app/` directory and categorise:
- Models and their relationships
- Controllers and which models they touch
- Jobs, Events, Listeners and their domain affinity
- Services, Actions and their responsibilities

### Step 2: Generate Migration Plan

Produce a numbered task list grouped by domain:

```markdown
## Migration Plan

### Phase 1: Foundation
- [ ] Task 1: Scaffold src/ directories and configure autoloading
- [ ] Task 2: Move Shared domain models (Base, Activity, Setting)

### Phase 2: Core Domains
- [ ] Task 3: Move [Domain] domain layer (Models, Events, Contracts)
- [ ] Task 4: Move [Domain] application layer (Jobs, Services, Actions)
- [ ] Task 5: Move [Domain] infrastructure layer (Registrars, Exports)

### Phase 3: Supporting Domains
- [ ] Task 6: Move [Domain] domain (Models, Jobs, webhook handlers)
- [ ] Task 7: Move remaining shared infrastructure

### Phase 4: Wiring
- [ ] Task 8: Create domain service providers and clean up AppServiceProvider
- [ ] Task 9: Update architecture tests for DDD structure

### Phase 5: Verification
- [ ] Task 10: Clean up empty directories, full verification
```

Rules:
- **Shared domain first** — everything depends on it
- **High-priority domains next** — business-critical paths
- **One domain at a time** — never move two domains simultaneously
- **Tests must pass after each task** — no big-bang migration
- Each task should be a single commit

---

## 3. `/project-ddd scaffold` — Scaffold Domain

### Purpose

Create a new domain directory structure with all layers.

### Interview

Ask the user:
1. **Domain name** (PascalCase, e.g., `Billing`, `DomainManagement`)
2. **Key models** (what entities live here)
3. **Has events?** (domain events the business cares about)
4. **Has contracts?** (interfaces for external dependencies)
5. **Has jobs?** (async work — processing, syncing)
6. **Has actions?** (use-case classes following cleaniquecoders/laravel-action)

### Generated Structure

```
src/
└── Domain/
    └── {DomainName}/
        ├── Domain/
        │   ├── Models/
        │   │   └── {Model}.php
        │   ├── Events/
        │   │   └── {Model}Created.php
        │   ├── Contracts/
        │   │   └── {Model}Repository.php
        │   └── ValueObjects/
        │       └── {ValueObject}.php
        ├── Application/
        │   ├── Actions/
        │   │   └── Create{Model}.php
        │   ├── Jobs/
        │   │   └── Process{Model}.php
        │   └── Services/
        │       └── {DomainName}Service.php
        ├── Infrastructure/
        │   ├── Registrars/
        │   │   └── {DomainName}Registrar.php
        │   └── Providers/
        │       └── {DomainName}ServiceProvider.php
        └── Presentation/
            ├── Controllers/
            │   └── {Model}Controller.php
            └── Resources/
                └── {Model}Resource.php
```

### Layer Rules

| Layer | Contains | Depends On | DO NOT |
|---|---|---|---|
| Domain | Models, Events, Contracts, VOs | Nothing (pure) | Import from Application/Infrastructure |
| Application | Actions, Jobs, Services | Domain only | Import from Infrastructure/Presentation |
| Infrastructure | Providers, Registrars, Exports | Domain + Application | Contain business logic |
| Presentation | Controllers, Resources, Requests | Application | Contain business logic |

### Code Templates

#### Domain Service Provider

```php
<?php

namespace Src\Domain\{DomainName}\Infrastructure\Providers;

use Illuminate\Support\ServiceProvider;

class {DomainName}ServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Bind contracts to implementations
    }

    public function boot(): void
    {
        // Register domain event listeners, routes, etc.
    }
}
```

#### Action Class (using cleaniquecoders/laravel-action)

```php
<?php

namespace Src\Domain\{DomainName}\Application\Actions;

use CleaniqueCoders\LaravelAction\Action;

class Create{Model} extends Action
{
    public function execute(array $data): {Model}
    {
        return {Model}::create($data);
    }
}
```

---

## 4. `/project-ddd migrate` — Guided Migration

### Purpose

Move existing code from flat `app/` into domain structure, one step at a time.

### Process

For each migration task:

1. **Show what will move** — list files and their destination
2. **Move files** — relocate with namespace updates
3. **Update references** — fix imports across the codebase
4. **Update autoloading** — adjust `composer.json` PSR-4 mapping
5. **Run tests** — verify nothing broke
6. **Commit** — one commit per task

### Namespace Mapping

| From (flat) | To (domain) |
|---|---|
| `App\Models\{Model}` | `Src\Domain\{Domain}\Domain\Models\{Model}` |
| `App\Events\{Event}` | `Src\Domain\{Domain}\Domain\Events\{Event}` |
| `App\Contracts\{Contract}` | `Src\Domain\{Domain}\Domain\Contracts\{Contract}` |
| `App\Actions\{Action}` | `Src\Domain\{Domain}\Application\Actions\{Action}` |
| `App\Jobs\{Job}` | `Src\Domain\{Domain}\Application\Jobs\{Job}` |
| `App\Services\{Service}` | `Src\Domain\{Domain}\Application\Services\{Service}` |
| `App\Http\Controllers\{Ctrl}` | `Src\Domain\{Domain}\Presentation\Controllers\{Ctrl}` |
| `App\Http\Resources\{Res}` | `Src\Domain\{Domain}\Presentation\Resources\{Res}` |

### Autoloading Update

After scaffolding `src/`, update `composer.json`:

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Src\\": "src/"
        }
    }
}
```

Then run `composer dump-autoload`.

### Critical Rules

- **Never move and refactor at the same time** — move first, refactor later
- **Keep app/ working** — migration is incremental, app/ and src/ coexist
- **Shared domain has no business logic** — only base classes, traits, and utilities
- **Models keep their table names** — DDD is about code organisation, not database changes
- **Tests pass after every move** — if they don't, fix before proceeding

---

## 5. `/project-ddd wire` — Service Provider Wiring

### Purpose

Create or update domain service providers and register them in the app.

### What It Does

1. Generate `{DomainName}ServiceProvider` for each domain under `src/`
2. Register all domain providers in `bootstrap/providers.php` (Laravel 11+) or `config/app.php`
3. Clean up `AppServiceProvider` — move domain-specific bindings to domain providers
4. Wire up domain event listeners in domain providers

### Provider Registration (Laravel 11+)

```php
// bootstrap/providers.php
return [
    App\Providers\AppServiceProvider::class,
    // Domain providers
    Src\Domain\Identity\Infrastructure\Providers\IdentityServiceProvider::class,
    Src\Domain\Billing\Infrastructure\Providers\BillingServiceProvider::class,
    Src\Domain\Catalogue\Infrastructure\Providers\CatalogueServiceProvider::class,
];
```

---

## 6. `/project-ddd test` — Architecture Tests

### Purpose

Update Pest architecture tests to enforce DDD boundaries.

### Generated Tests

```php
// tests/Architecture/DomainTest.php

arch('domain layer has no infrastructure imports')
    ->expect('Src\Domain\*\Domain')
    ->not->toUse([
        'Illuminate\Support\ServiceProvider',
        'Illuminate\Http',
    ]);

arch('domain models extend base')
    ->expect('Src\Domain\*\Domain\Models')
    ->toExtend('Src\Domain\Shared\Domain\Models\Base');

arch('application layer does not import presentation')
    ->expect('Src\Domain\*\Application')
    ->not->toUse('Src\Domain\*\Presentation');

arch('infrastructure layer does not contain business logic')
    ->expect('Src\Domain\*\Infrastructure')
    ->not->toUse('Src\Domain\*\Domain\Models');

arch('controllers use actions, not models directly')
    ->expect('Src\Domain\*\Presentation\Controllers')
    ->toOnlyUse([
        'Src\Domain\*\Application',
        'Illuminate\Http',
        'Illuminate\Routing',
    ]);

arch('domain events follow naming convention')
    ->expect('Src\Domain\*\Domain\Events')
    ->toHaveSuffix('Event')
    ->orThat()
    ->toMatch('/Created|Updated|Deleted|Activated|Deactivated|Completed/');

arch('value objects are final and readonly')
    ->expect('Src\Domain\*\Domain\ValueObjects')
    ->toBeFinal()
    ->toBeReadonly();
```

---

## 7. `/project-ddd audit` — Domain Audit

### Purpose

Check existing domain structure for boundary violations and misplaced code.

### Checks

| Check | What It Looks For |
|---|---|
| Layer violations | Domain importing from Infrastructure/Presentation |
| Orphan models | Models in `app/Models/` that should be in a domain |
| Fat controllers | Controllers with business logic (should use Actions) |
| Cross-domain coupling | Domain A directly importing Domain B's models |
| Missing providers | Domains without a registered ServiceProvider |
| Shared bloat | Too many things in Shared (should be in specific domains) |

### Output Format

```markdown
## DDD Audit Report

### Violations (3)
- Domain\Billing\Domain\Models\Invoice imports from Infrastructure
- Domain\Identity uses Domain\Billing\Domain\Models\Plan directly
- AppServiceProvider still has Billing-specific bindings

### Warnings (2)
- app/Models/Legacy.php not assigned to any domain
- Shared domain has 12 models (consider splitting)

### Healthy (4 domains)
- Identity: clean boundaries
- Billing: clean boundaries
- Catalogue: clean boundaries
- Fulfilment: clean boundaries
```

---

## When NOT to Use DDD

Be honest with the user. DDD adds complexity. Skip it when:

- **Small app** (< 10 models) — flat Laravel is fine
- **Solo developer** — you already know where everything is
- **CRUD-heavy** — if 80% of your app is basic CRUD, DDD is overhead
- **Prototype/MVP** — ship first, restructure when it hurts

DDD pays off when:
- Multiple teams/devs working on the same codebase
- Business logic is complex (not just CRUD)
- Domains have genuinely different lifecycles
- You need to replace or extract parts independently

---

## Reference Files

| File | Description |
|---|---|
| [references/domain-structure.md](references/domain-structure.md) | Full directory structure template with all layers |
| [references/migration-checklist.md](references/migration-checklist.md) | Step-by-step migration checklist with verification gates |
| [references/arch-tests.md](references/arch-tests.md) | Complete Pest architecture test suite for DDD boundaries |
