# Conventional Commits Reference

## Specification

Conventional Commits is a specification for adding human and machine-readable meaning to commit messages.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Rules

1. The **type** is mandatory and must be one of the allowed types
2. The **scope** is optional, enclosed in parentheses after the type
3. A `!` after the type/scope signals a breaking change
4. The **description** is mandatory, separated from the type by `: ` (colon + space)
5. The **body** is optional, separated from the description by a blank line
6. The **footer** is optional, separated from the body by a blank line
7. Footer uses `token: value` or `token #value` format

---

## Allowed Types

| Type | Purpose | SemVer Impact |
|---|---|---|
| `feat` | New feature or capability | MINOR bump |
| `fix` | Bug fix | PATCH bump |
| `docs` | Documentation only | No bump |
| `style` | Formatting, whitespace, semicolons (no logic change) | No bump |
| `refactor` | Code restructure without behaviour change | No bump |
| `perf` | Performance improvement | PATCH bump |
| `test` | Adding or updating tests | No bump |
| `build` | Build system or external dependency changes | No bump |
| `ci` | CI configuration and scripts | No bump |
| `chore` | Maintenance tasks (no production code change) | No bump |
| `revert` | Reverts a previous commit | Varies |

---

## Laravel Scope Catalog

Scopes identify the area of the codebase affected by the commit.

| Scope | Applies To |
|---|---|
| `auth` | Authentication, authorization, guards, policies, gates |
| `api` | API routes, controllers, resources, API middleware |
| `ui` | Blade views, Livewire components, Flux components, frontend assets |
| `db` | Migrations, seeders, factories, raw queries |
| `config` | Configuration files, environment variable changes |
| `test` | Test files, test utilities, test helpers |
| `ci` | GitHub Actions workflows, deployment scripts |
| `model` | Eloquent models, relationships, scopes, accessors, mutators |
| `route` | Route definitions, route groups, middleware assignment to routes |
| `middleware` | HTTP middleware classes, middleware groups |

### Scope Detection from File Paths

```
app/Models/                        → model
app/Http/Controllers/Api/          → api
app/Http/Controllers/Auth/         → auth
app/Http/Middleware/                → middleware
app/Policies/                      → auth
resources/views/                   → ui
resources/js/                      → ui
resources/css/                     → ui
database/migrations/               → db
database/seeders/                  → db
database/factories/                → db
config/                            → config
tests/                             → test
routes/api.php                     → api
routes/web.php                     → route
.github/workflows/                 → ci
```

---

## Commit Message Anatomy

### Subject Line

- Imperative mood: "add", not "added" or "adds"
- Lowercase first letter after colon
- No period at the end
- Maximum 72 characters total

### Body

- Separated from subject by a blank line
- Wrap at 80 characters
- Explain **what** changed and **why**, not how
- Use bullet points for multiple changes

### Footer

- Separated from body by a blank line
- Uses `token: value` format
- Common tokens: `BREAKING CHANGE`, `Closes`, `Refs`, `Reviewed-by`

---

## Examples

### Simple Feature

```
feat(auth): add password reset via email

Implement password reset flow using Laravel's built-in
Password Broker with custom email template.

Closes #42
```

### Bug Fix

```
fix(api): return 404 for soft-deleted resources

API endpoints were returning 500 when requesting a
soft-deleted resource. Now returns proper 404 response
with error message.

Closes #87
```

### Breaking Change with `!`

```
feat(api)!: change pagination response envelope

Pagination responses now use `meta.total` and `meta.per_page`
instead of top-level `total` and `per_page` keys.

BREAKING CHANGE: All API consumers must update their response
parsing to use the nested `meta` object for pagination data.

Closes #112
```

### Breaking Change with Footer Only

```
refactor(db): rename users table columns

Rename `name` to `full_name` and `email` to `email_address`
for clarity and consistency with the API resource schema.

BREAKING CHANGE: Database migration renames columns. Run
`php artisan migrate` after updating. Any direct column
references in queries must be updated.
```

### Documentation Change

```
docs: add API authentication guide to README

Document Bearer token authentication flow, rate limits,
and error response format for third-party integrators.
```

### Multi-scope Change

When a commit touches multiple scopes, use the primary scope:

```
feat(auth): add OAuth2 login with GitHub provider

Add GitHub OAuth2 provider using Laravel Socialite.
Includes controller, routes, and login button component.
```

If the commit is truly cross-cutting, omit the scope:

```
refactor: rename User to Account across codebase
```

### Revert

```
revert: feat(auth): add two-factor authentication

This reverts commit abc1234.

Reason: TOTP library has a critical vulnerability (CVE-2026-XXXX).
Will re-implement after upstream patch.
```

---

## Footer Patterns

### Co-Authored-By

For pair programming or AI-assisted commits:

```
feat(ui): add dark mode toggle component

Co-Authored-By: Alice Smith <alice@example.com>
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Signed-off-by

For projects requiring Developer Certificate of Origin (DCO):

```
fix(api): handle null response from external service

Signed-off-by: Bob Jones <bob@example.com>
```

### Multiple Footers

```
feat(auth): add SAML SSO integration

Implement SAML 2.0 SSO using onelogin/php-saml package.
Supports IdP-initiated and SP-initiated flows.

Closes #156
Refs #120, #134
Reviewed-by: Alice Smith <alice@example.com>
Co-Authored-By: Claude <noreply@anthropic.com>
```
