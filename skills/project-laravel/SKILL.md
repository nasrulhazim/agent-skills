---
name: project-laravel
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, kickoff, conventions, scaffold, project]
description: >
  Laravel project conventions enforcer and code scaffolder for Kickoff-based projects — ensures
  all generated code follows Kickoff's opinionated conventions including UUID models extending Base,
  Enums with Contract and InteractsWithEnum, modular routes with require_all_in(), helper functions
  in support/, Spatie permission with config-driven access control, architecture test rules, and
  Docker-based local development. Covers model generation, enum creation, action classes with Builder
  pattern, route modules, helper files, and full module scaffolding. Use this skill whenever the user
  asks to scaffold code, generate models, create enums, add routes, write helpers, check conventions,
  or build new modules in a Kickoff Laravel project — including: "scaffold a new module", "generate a
  model", "create an enum", "buat model baru", "tambah enum", "scaffold module untuk users", "buat
  action class", "tambah route", "buat helper function", "check convention", "audit code ni", or
  "ikut convention kickoff". Assumes Laravel Kickoff as the baseline with all conventions pre-configured.
---

# Laravel Project Conventions

Enforce Kickoff's opinionated Laravel conventions and scaffold production-ready code that follows
all project standards — models, enums, actions, routes, helpers, permissions, and architecture rules.

## Command Reference

| Command | Description |
|---|---|
| `/project scaffold` | Scaffold a new module (model + migration + factory + seeder + policy + controller + routes + tests) |
| `/project model` | Generate a model extending Base with correct traits and conventions |
| `/project enum` | Generate an enum implementing Contract with InteractsWithEnum |
| `/project action` | Generate an action class with Builder pattern |
| `/project helper` | Generate a helper function file in support/ |
| `/project route` | Add a modular route file in routes/web/ or routes/api/ |
| `/project check` | Audit existing code against Kickoff conventions |

---

## 1. `/project scaffold` — Full Module Scaffold

### Step 1: Gather Module Info

Ask the user:
1. **Module name** (singular, e.g., `Invoice`)
2. **Fields** (name:type pairs, e.g., `title:string`, `amount:decimal`, `status:enum`)
3. **Relationships** (belongsTo, hasMany, belongsToMany)
4. **Needs API routes?** (yes/no)
5. **Needs web routes?** (yes/no — default yes)

### Step 2: Generate Files

Create the following files in order:

1. **Migration** — UUID PK, uuid column, timestamps, soft deletes (see `references/database-conventions.md`)
2. **Model** — Extends `App\Models\Base`, uses correct traits (see `references/model-conventions.md`)
3. **Factory** — Matches model fields with appropriate Faker methods (see `references/database-conventions.md`)
4. **Seeder** — Uses factory with reasonable count (see `references/database-conventions.md`)
5. **Policy** — Standard CRUD methods with Spatie permission checks (see `references/access-control.md`)
6. **Controller** — Resource controller with policy authorization (suffix "Controller")
7. **Form Request** — Store and Update request classes with validation rules
8. **Route file** — Modular route in `routes/web/` or `routes/api/` (see `references/route-conventions.md`)
9. **Pest tests** — Feature tests for all CRUD operations (delegate to pest-testing skill patterns)
10. **Permission config** — Add entries to `config/access-control.php` (see `references/access-control.md`)

### Step 3: Register

- Add seeder call to `DatabaseSeeder.php`
- Verify route file is in the correct directory (auto-loaded via `require_all_in()`)
- Add permission entries to access-control config

### Output

Display a checklist of all created files with paths.

---

## 2. `/project model` — Model Generation

### Step 1: Gather Info

Ask:
1. **Model name** (singular PascalCase)
2. **Fields** (for fillable array)
3. **Relationships** (belongsTo, hasMany, morphTo, etc.)
4. **Traits needed** (HasHashId, SoftDeletes, HasFactory, etc.)

### Step 2: Generate

Follow all conventions from `references/model-conventions.md`:

- Extend `App\Models\Base` (NEVER `Illuminate\Database\Eloquent\Model`)
- Include `HasFactory` trait
- Define `$fillable` array
- Define `$casts` array for dates, enums, booleans
- Add relationship methods with return types
- Add query scopes if applicable

### Step 3: Generate Migration

Follow `references/database-conventions.md`:
- `$table->id()` + `$table->uuid('uuid')->index()`
- All fields from model
- `$table->timestamps()` + `$table->softDeletes()` (if model uses SoftDeletes)

---

## 3. `/project enum` — Enum Generation

### Step 1: Gather Info

Ask:
1. **Enum name** (PascalCase, e.g., `InvoiceStatus`)
2. **Cases** (list of cases with values)
3. **Backing type** (string or int — default string)

### Step 2: Generate

Follow all conventions from `references/enum-conventions.md`:

- Implement `CleaniqueCoders\Traitify\Contracts\Enum`
- Use `CleaniqueCoders\Traitify\Concerns\InteractsWithEnum` trait
- Define `label(): string` method
- Define `description(): string` method
- Place in `app/Enums/` directory

---

## 4. `/project action` — Action Class Generation

### Step 1: Gather Info

Ask:
1. **Action name** (PascalCase, e.g., `CreateInvoice`)
2. **Input parameters** (what data the action needs)
3. **Return type** (Model, bool, void, etc.)

### Step 2: Generate

Follow all conventions from `references/action-conventions.md`:

- Place in `app/Actions/` directory
- Use Builder pattern with fluent setters
- Single `execute()` method
- Return typed result

---

## 5. `/project helper` — Helper Function Generation

### Step 1: Gather Info

Ask:
1. **Function name(s)**
2. **Purpose / description**
3. **Parameters and return types**

### Step 2: Generate

Follow all conventions from `references/helper-conventions.md`:

- Place in `support/` directory
- Guard EVERY function with `if (! function_exists('name'))` check
- Add PHPDoc blocks
- Keep functions pure where possible

---

## 6. `/project route` — Modular Route File

### Step 1: Gather Info

Ask:
1. **Route type** — web or api
2. **Resource name** (plural kebab-case)
3. **Controller class**
4. **Middleware** (auth, role, permission, etc.)

### Step 2: Generate

Follow all conventions from `references/route-conventions.md`:

- Create file in `routes/web/` or `routes/api/`
- Use `Route::resource()` or explicit route definitions
- Apply middleware via `->middleware()`
- Follow naming conventions

---

## 7. `/project check` — Convention Audit

### What to Check

Scan the project and report violations against all conventions:

1. **Models** — Must extend `App\Models\Base` (see `references/model-conventions.md`)
2. **Enums** — Must implement Contract, use InteractsWithEnum (see `references/enum-conventions.md`)
3. **Migrations** — Must have uuid column (see `references/database-conventions.md`)
4. **Routes** — Must be in modular files (see `references/route-conventions.md`)
5. **Helpers** — Must have `function_exists()` guard (see `references/helper-conventions.md`)
6. **Architecture** — No banned functions (see `references/architecture-rules.md`)
7. **Naming** — Controllers end in "Controller", Policies end in "Policy" (see `references/architecture-rules.md`)
8. **Directory structure** — Files in correct locations (see `references/project-structure.md`)

### Output Format

```
## Convention Audit Report

### ✅ Passing
- Models: 12/12 extend Base
- Enums: 5/5 implement Contract

### ❌ Violations
- app/Models/Legacy.php — extends Eloquent Model instead of Base
- app/Helpers/utils.php — missing function_exists() guard on format_currency()

### 💡 Suggestions
- Consider adding uuid column to legacy_table migration
```

---

## Key Conventions Summary

These conventions MUST be followed in ALL generated code:

1. **Models** — Always extend `App\Models\Base`, never `Illuminate\Database\Eloquent\Model`
2. **Enums** — Implement `CleaniqueCoders\Traitify\Contracts\Enum`, use `InteractsWithEnum`
3. **UUID PKs** — `$table->id()` + `$table->uuid('uuid')->index()` in every migration
4. **Routes** — Modular files in `routes/web/*.php`, loaded via `require_all_in()`
5. **Helpers** — In `support/` directory, guarded with `function_exists()` check
6. **Permissions** — `module.action.target` format, config-driven via `access-control.php`
7. **Architecture** — No `dd`/`dump`/`ray`, no `url()`, no raw `DB::` queries, `env()` only in config
8. **Concerns** — Traits in `app/Concerns/`, must be traits
9. **Contracts** — Interfaces in `app/Contracts/`, must be interfaces
10. **Policies** — In `app/Policies/`, suffix "Policy", standard CRUD methods
11. **Controllers** — Suffix "Controller"
12. **Composer scripts** — `composer test`, `composer format`, `composer analyse`, `composer rector`
13. **Docker** — MySQL, Redis, Mailpit, Meilisearch, MinIO

---

## Reference Files

| File | Description |
|---|---|
| `references/model-conventions.md` | Base model, UUID, traits, relationships, casts |
| `references/enum-conventions.md` | Enum contract, InteractsWithEnum, label/description methods |
| `references/action-conventions.md` | Builder pattern, Actions directory, execute() method |
| `references/route-conventions.md` | Modular routes, require_all_in, naming conventions |
| `references/helper-conventions.md` | support/ directory, function_exists guard, helper patterns |
| `references/access-control.md` | Roles, permissions, policies, middleware, config |
| `references/database-conventions.md` | UUID PKs, migrations, seeders, factories |
| `references/architecture-rules.md` | Banned functions, naming suffixes, strict rules |
| `references/project-structure.md` | Directory layout, config files, Docker, stubs |
| `references/frontend-conventions.md` | TailwindCSS v4, Alpine, Tippy, Vite |
