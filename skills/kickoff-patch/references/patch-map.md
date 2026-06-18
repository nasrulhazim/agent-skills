# Patch Map — What a Kickoff Patch May Touch

The authoritative map of every area a `/kickoff patch` may modify, with exact paths from the
real `stubs/` tree, classified by safety. A patch is a **3-way merge** (base = `stubs@original`,
theirs = `stubs@latest`, mine = project files), never a blind overwrite.

> **Live, not snapshot.** Concrete lists below are *current as of kickoff 1.24.0* and must be
> re-extracted live from the **local kickoff install** at `$KICKOFF` (its `stubs/` + `src/StartCommand.php`
> are *latest*). Two sources of truth: (a) files under `$KICKOFF/stubs/`, and (b) imperative logic
> in `$KICKOFF/src/StartCommand.php` (composer rewrite, `vendor:publish` tags, npm installs,
> post-install artisan commands). `composer.json` is **not** a stub — it is rewritten in code
> (`setupComposer()`). Only the original-version **base** tree comes from a git tag (when available).

---

## 1. Category Map

| Category | What it covers | Representative stub paths | Source | Typical change between versions |
|---|---|---|---|---|
| **composer packages** | `require` + `require-dev` package set installed after scaffold | *(no stub)* `src/StartCommand.php` → `installPackages()` | CODE | New package added (e.g. 1.23: `laravel-mcp-kit`; 1.21: `config-sso`, `config-webhook`); version constraints bumped (`livewire/livewire:^4.0`) |
| **composer scripts / autoload** | `scripts.*`, `autoload.files`, `config.allow-plugins` rewritten into `composer.json` | *(no stub)* `src/StartCommand.php` → `setupComposer()` | CODE | New script (`rector`, `lint`), changed `dev` concurrently command, autoload `support/helpers.php` |
| **vendor:publish tags** | Tags/providers published post-install (configs intentionally skipped — pre-configured configs ship as stubs) | *(no stub)* `src/StartCommand.php` → `installPackages()` publish loop | CODE | New tag per new package (`media-manager-config`, `media-manager-views`, `livewire:config`); provider added |
| **post-install artisan cmds** | `bin/install`, `key:generate`, `make:notifications-table`, `operations:install`, `mcp-kit:install`, `reload:db`, `boost:install` | *(no stub)* `src/StartCommand.php` → `runTasks()` | CODE | New install command (1.23: `mcp-kit:install`) |
| **navigation menu** | Sidebar menu tree builders + the contracts/concerns that process them | `app/Actions/Builder/Menu/{Base,Sidebar,UserManagement,Settings,AuditMonitoring,MediaManagement}.php`, `app/Actions/Builder/{Menu,MenuItem}.php`, `app/Contracts/{HeadingMenuBuilder,AuthorizedMenuBuilder}.php`, `app/Concerns/ProcessesMenuItems.php`, `support/menu.php`, `resources/views/components/layouts/app/sidebar.blade.php` | STUB | New menu group/item, collapsible behaviour (1.21), new-tab external links + icon (1.23) |
| **menu authorization gates** | Gate tree consumed by the menu/sidebar | `app/Providers/AdminServiceProvider.php` (`access.*`, `manage.*`, `mcp-kit.*`, `viewTelescope`, `viewHorizon`, `access.superadmin`) | STUB | New gate per feature (1.23: `mcp-kit.view-tasks`, `mcp-kit.manage-tasks`; 1.22: `access.artisan-runner`) |
| **config (pre-configured)** | 18 pre-tuned config files shipped as stubs (NOT published) | `config/{access-control,admin,artisan-runner,audit,blade-icons,config-backup,config-sso,config-webhook,filesystems,fortify,horizon,impersonate,laravel-media-secure,notification,permission,security,seeder,telescope}.php` | STUB | New config for new package; tuned keys (e.g. telescope exception-only watchers in 1.23) |
| **Livewire components** | Admin/security/notification Livewire classes + their views | `app/Livewire/**` (`Admin/{Roles,Settings}`, `Security/{Users,AuditTrail,RolePermissions}`, `Notifications/{Bell,Index}`, `Actions/Logout`, `Confirm`), `resources/views/livewire/**` | STUB | New component, prop/method changes, User Management overhaul (1.21) |
| **Blade x-components** | Shared `<x-…>` UI primitives | `resources/views/components/*.blade.php` (e.g. `panel`, `card`, `toast`, `empty-state`, `status-badge`, `user-menu`, `navlist-with-child`, `app-logo`, `kickoff-logo`, `breadcrumbs`, `file-upload`), `components/{card,menu,settings,layouts}/` | STUB | New component, restyle, logo refresh (1.23 single-`K` mark) |
| **layouts + theme** | App/auth shells, sidebar layout, CSS, Tailwind config, logos | `resources/views/components/layouts/app/sidebar.blade.php`, `layouts/{app,auth}.blade.php`, `layouts/auth/{card,simple,split}.blade.php`, `resources/css/app.css`, `tailwind.config.js`, logo blades | STUB | `flux:main` container standardisation (1.23), theme tokens, padding/width changes |
| **routes (split)** | Per-domain route files | `routes/web.php`, `routes/web/{_,auth,security,administration,media,notifications,pages,support}.php` | STUB | New route file, routes folded into existing file (e.g. notifications into `_.php`), gating (`can:access.artisan-runner`) |
| **bin scripts** | Ops scripts (placeholder `${PROJECT_NAME}` substituted at scaffold) | `bin/{install,deploy,backup-media,backup-app,backup-db,update-dependencies,reinstall-npm,build-fe-assets}` | STUB | New script, command corrections (1.18.x) |
| **CI / .github** | Workflows + Copilot/chatmode/instruction/prompt assets | `.github/workflows/{run-tests,lint,rector,security,update-changelog}.yml`, `.github/{copilot-instructions.md,pull_request_template.md}`, `.github/{instructions,prompts,chatmodes,ISSUE_TEMPLATE}/**` | STUB | New workflow, new instruction/prompt/chatmode file, action version bumps |
| **docs** | Numbered docs tree | `docs/{01-getting-started,02-development,03-architecture,04-deployment,05-security}/**`, `docs/adr/`, `docs/README.md`, `docs/.markdownlintrc` | STUB | New doc per feature (sso, webhooks, artisan-runner, soc2-compliance) |
| **docker + service config** | Local stack | `docker-compose.yml`, `.config/{supervisord.ini,minio.nginx.conf}` | STUB | Service image version bumps (`mysql:8.4`, `redis:alpine`, `getmeili/meilisearch:v1.12`, `minio:latest`, `axllent/mailpit`), new service/port |
| **.env keys** | Env template keys (values placeholdered/snake-cased at scaffold) | `.env.example` | STUB | New key block per feature (1.23: `MCP_KIT_*`; telescope `TELESCOPE_*`; `MINIO_*`, `MEILI_MASTER_KEY`) — **keys** matter, not values |
| **make-command templates** | `make:*` stub templates used by generators | `stubs/stubs/{model,policy,enum,pest,migration.create,helper}.stub` | STUB | New stub, template body changes |
| **CLAUDE.md** | Project conventions doc | `CLAUDE.md` | STUB | Defer merge → **`project-sync`** skill (do not re-implement here) |
| **migrations / seeders / settings** | Baseline schema + Spatie settings classes/files | `database/migrations/*`, `database/seeders/*`, `database/settings/*`, `app/Settings/*` | STUB | New baseline migration (1.23: `uuid` on `audits`; `suspended_at` on users); new seeder |

---

## 2. Three-Tier Safety Classification

Per file, decide tier, then apply the rule. Tier is the *default*; the actual byte-comparison
against base (`stubs@original`) decides fast-forward vs. merge within a tier.

### Tier A — VERBATIM-SAFE (fast-forward allowed)
Kickoff-owned, rarely hand-edited. If the project file is **byte-identical to base**, fast-forward
to `theirs` silently. If it differs, demote to a 3-way merge with review.

| Area | Paths |
|---|---|
| bin scripts | `bin/*` (after re-substituting `${PROJECT_NAME}` / `${OWNER}`) |
| CI workflows & AI assets | `.github/workflows/*`, `.github/{instructions,prompts,chatmodes,ISSUE_TEMPLATE}/*`, `.github/copilot-instructions.md`, `.github/pull_request_template.md` |
| docs tree | `docs/**` |
| make-command templates | `stubs/stubs/*.stub` |
| Blade x-components (untouched) | `resources/views/components/*.blade.php` not in the project's edited set |
| Livewire views (untouched) | `resources/views/livewire/**` not edited |
| service config | `.config/supervisord.ini`, `.config/minio.nginx.conf` |
| quality config (if unedited) | `pint.json`, `phpunit.xml`, `tailwind.config.js` |

### Tier B — MODIFIED-MANAGED (always 3-way merge + per-category review)
Kickoff-owned but **commonly customised**. Never fast-forward; always merge base↔theirs↔mine and
surface conflicts for human review.

| Area | Paths |
|---|---|
| composer integration (CODE-derived) | `composer.json` `scripts` / `autoload.files` / `config.allow-plugins`; the `require`/`require-dev` set (merge new packages in, keep project additions) |
| vendor:publish + post-install | publish tag list and artisan-command list from `StartCommand` (apply *new* publishes/commands only — never re-run blindly) |
| base model & user | `app/Models/Base.php`, `app/Models/User.php`, `app/Models/{Role,Permission,Notification,Audit}.php` |
| providers | `app/Providers/AdminServiceProvider.php` (gate tree), `app/Providers/AppServiceProvider.php`, `EventServiceProvider.php` |
| menu builders & helpers | `app/Actions/Builder/Menu/*`, `app/Actions/Builder/{Menu,MenuItem}.php`, `support/menu.php`, `support/helpers.php`, `app/Concerns/ProcessesMenuItems.php` |
| support helpers | `support/*.php` (`api`, `format`, `media`, `notification`, `options`, `sorter`, `str`, `user`, etc.) |
| split routes | `routes/web.php`, `routes/web/*.php` |
| sidebar / layouts / theme | `resources/views/components/layouts/app/sidebar.blade.php`, `layouts/*.blade.php`, `resources/css/app.css` |
| pre-configured configs | `config/*.php` (the 18 kickoff-owned files) — distinct from product config (Tier C) |
| quality tooling | `rector.php` |
| baseline tests | `tests/Feature/ArchitectureTest.php` |
| .env template keys | `.env.example` — merge **new keys** in; never overwrite project values |
| docker | `docker-compose.yml` (bump images; preserve project-added services/ports) |

### Tier C — PROJECT-OWNED / NEVER-TOUCH
Belongs to the developer's product. The patch must **never** write these; only read for context.

| Area | Notes |
|---|---|
| `.env` (live) | Real secrets — never touched. `.env.example` keys are Tier B; the live `.env` is never written. |
| App domain code | Models / Livewire / Actions / Jobs / Services / Events the dev added (anything not in the kickoff stub manifest) |
| Product config | `config/*.php` files the dev created (not in the 18-file kickoff set) |
| Custom routes | Route files / route entries the dev added beyond the kickoff split set |
| Business migrations & seeders | Any migration/seeder not in the kickoff baseline manifest |
| `composer.json` identity & deps | `name`, `description`, `license`, `authors`, and dev-added entries in `require`/`require-dev` — preserve verbatim while merging kickoff's additions |
| Spatie settings rows | `general_settings` / `mail_settings` / `notification_settings` DB values (managed at `/admin/settings`, not `.env`) |
| `README.md` | Project-customised (placeholders already substituted at scaffold) |
| `storage/` + uploaded media | User data — never touched |

---

## 3. Why a Blanket Overwrite Is Unsafe (g8stack evidence)

g8stack started at ~1.4.2 (Jan 2026); latest is 1.24.0 (~20 versions of drift). Files changed on
**both** sides, so overwriting either direction destroys real work:

- **`app/Models/Base.php` diverged.** Kickoff evolved it (traits, UUID/PII concerns) *and* the
  project added domain behaviour. Overwrite-theirs deletes project logic; overwrite-mine misses
  upstream fixes. → Tier B 3-way merge only.
- **`AdminServiceProvider` gate tree diverged.** Upstream added whole gate families
  (`mcp-kit.*` in 1.23, `access.artisan-runner` in 1.22) while the project added product gates.
  A blind copy drops one set, silently breaking sidebar authorization. → merge gate-by-gate.
- **Notifications routes folded into `routes/web/_.php`.** Routes that lived in a separate file
  upstream were consolidated; a path-keyed overwrite would duplicate or orphan the project's own
  route additions. → split-route merge with category review.

Therefore every Tier B file gets base↔theirs↔mine reconciliation with human approval per category,
and Tier C is read-only. Tier A fast-forwards **only** when byte-identical to base.
