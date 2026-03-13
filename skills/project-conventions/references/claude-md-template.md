# CLAUDE.md — [Project Name]

> This file is a **living document**. Claude updates it automatically whenever a correction,
> preference, better pattern, or gotcha is discovered during work. Last updated: [Date]

---

## Project Overview

**Name:** [Project Name]
**Type:** [Laravel package / SaaS / API / CLI / fullstack]
**Purpose:** [One sentence — what it does and for whom]
**Repo:** [URL if applicable]

---

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Language | PHP | 8.2+ | |
| Framework | Laravel | 11.x / 12.x | |
| Database | [PostgreSQL / MySQL / SQLite] | | |
| Cache | [Redis / file] | | |
| Queue | [Redis / database / sync] | | |
| Frontend | [Livewire / Inertia / Blade / API only] | | |
| Testing | [Pest / PHPUnit] | | |
| Auth | [Laravel Auth / Keycloak / SSO] | | |

---

## Architecture

### Key Patterns

- [e.g., Service Provider pattern for package registration]
- [e.g., Contracts in `src/Contracts/`, implementations in `src/Services/`]
- [e.g., Actions in `src/Actions/` — one class, one `handle()` method]

### Directory Structure

```
src/
├── Contracts/      ← Interfaces
├── Traits/         ← Reusable traits
├── Actions/        ← Single-responsibility actions
├── Models/         ← Eloquent models
├── Http/
│   ├── Controllers/
│   └── Requests/
└── [Package]ServiceProvider.php
```

### Database

- **Primary key:** [UUID / auto-increment]
- **Migrations:** Always reversible — `down()` must be implemented
- **Naming:** snake_case tables, snake_case columns
- [Any other DB-specific rules]

---

## DO / DON'T

- ✅ DO [rule]
- ❌ DON'T [rule]
- ✅ DO [rule]
- ❌ DON'T [rule]

---

## Preferences

### Code Style

- [e.g., Type hints on all method signatures]
- [e.g., Return types declared explicitly]
- [e.g., No unused imports]

### Testing

- [e.g., Pest with `it()` and `describe()` blocks]
- [e.g., Use `RefreshDatabase` trait, not `DatabaseTransactions`]
- [e.g., Test file mirrors src structure: `tests/Unit/Actions/DoSomethingActionTest.php`]

### Git

- [e.g., Conventional commits: feat:, fix:, docs:, refactor:]
- [e.g., Branch naming: feature/short-description, fix/issue-number]

### Laravel-Specific

- [e.g., Use Form Requests for all validation — never validate in controller]
- [e.g., Use Eloquent scopes for reusable query logic]
- [e.g., Config values via `config()` helper, never `env()` directly in code]

---

## Gotchas

> Add gotchas here as they're discovered during work.

<!-- Example format:
> **Gotcha:** PostgreSQL `uuid-ossp` extension must be enabled before using
> `DB::raw('uuid_generate_v4()')`. Use `InteractsWithUuid` trait instead.
-->

---

## External Integrations

| Service | Purpose | Auth Method | Notes |
|---|---|---|---|
| [Keycloak] | [SSO / Auth] | [OIDC] | [Any gotchas] |
| [Redis] | [Cache + Queue] | [No auth local] | [Prod needs password] |

---

## Environment Variables

Key variables this project needs — document here as they're added:

```env
APP_NAME=
APP_ENV=
DB_CONNECTION=
DB_HOST=
DB_PORT=
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
# Add project-specific vars below
```

---

## Changelog

Track significant updates to this file:

| Date | Change |
|---|---|
| [Date] | Initial CLAUDE.md created |
| | |
