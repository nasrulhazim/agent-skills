# Source of Truth — Fetching Baselines & Extracting Imperative Data

A patch compares a project against Kickoff at two reference points:

- **theirs (latest)** = the **locally-installed** `cleaniquecoders/kickoff` (REQUIRED — see §0). Its `stubs/` is the latest baseline; its installed version is `$LATEST_TAG`.
- **base (original)** = the version the project was scaffolded from (detected — see `detect-and-version.md`). Obtained from a **git tag** only when a git-enabled kickoff source exists (§1). When it can't be obtained, the patch runs in **2-way mode** (`merge-and-apply.md` §1.5).

Two distinct sources make up a baseline at any version:

1. **Stubs** — files under `stubs/` that are copied 1:1 onto the project root. The *file* baseline (merged against project files).
2. **Imperative logic** — hardcoded in `src/StartCommand.php` (composer packages, `vendor:publish` tags, composer.json scripts/autoload, npm installs, post-install artisan commands). This is **never** in stubs; you translate diffs of it into `composer require` / `vendor:publish` actions.

Remote (for git-tag / base acquisition only): `https://github.com/cleaniquecoders/kickoff.git`. Tags are **bare semver, no `v` prefix** (`1.0.0` … `1.24.0`).

---

## 0. Precondition — `cleaniquecoders/kickoff` must be installed locally

`/kickoff status|check|patch` REQUIRE the package installed globally; the local install is
the source of **latest** (theirs). Abort early with instructions if it is missing.

```bash
# Discover the global install (machine-agnostic — no hardcoded path):
KICKOFF="${KICKOFF_SRC:-$(composer global config --absolute vendor-dir 2>/dev/null)/cleaniquecoders/kickoff}"

if [ ! -d "$KICKOFF/stubs" ]; then
  echo "kickoff not installed. Run:  composer global require cleaniquecoders/kickoff"
  exit 1
fi

# The installed version IS $LATEST_TAG (what new projects scaffold from):
LATEST_TAG=$(composer global show cleaniquecoders/kickoff 2>/dev/null | awk '/^versions/ {print $NF}')
echo "local kickoff: ${LATEST_TAG:-unknown} at $KICKOFF"
# Encourage being on the newest release before patching:
echo "tip: 'composer global update cleaniquecoders/kickoff' to pull the latest"
```

THEIRS = `$KICKOFF/stubs` **directly** (no git archive needed for latest). `$KICKOFF` may
also be a **git checkout** — via `--source=<path>` or a `composer global require ...
--prefer-source` install — which additionally unlocks the **base** tree (§1) for a precise
3-way merge. A plain dist install has no `.git`/tags.

---

## 1. Acquire the base (original-version) tree

Latest/theirs is already in hand from §0. For a **3-way** merge you also need **base** =
`stubs/` (and `src/StartCommand.php`) at `$BASE_TAG` — the detected original version (see
`detect-and-version.md`). Try these in order; if none works, run **2-way** (no base — see
`merge-and-apply.md` §1.5).

### 1a. From a git-enabled local kickoff (preferred — offline, no network)

If `$KICKOFF` is a git checkout (a `--source` clone, or a `--prefer-source` global install)
it has the tags. Extract the base subtree read-only (include `src` for the imperative diff):

```bash
if git -C "$KICKOFF" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$KICKOFF" fetch --tags --force 2>/dev/null
  # Only archive paths that exist at $BASE_TAG (stubs/ + src/ exist from 1.2.0 onward;
  # pre-1.2.0 tags have neither → $BASE_DIR stays empty → 2-way mode):
  paths=$(git -C "$KICKOFF" ls-tree --name-only "$BASE_TAG" | grep -E '^(stubs|src)$' | tr '\n' ' ')
  if [ -n "$paths" ]; then
    BASE_DIR=$(mktemp -d); git -C "$KICKOFF" archive "$BASE_TAG" $paths | tar -x -C "$BASE_DIR"
    # => $BASE_DIR/stubs/...  and  $BASE_DIR/src/StartCommand.php   (theirs = $KICKOFF/stubs, $KICKOFF/src/...)
  fi
fi
```

> Pre-1.2.0 baselines have no `stubs/`/`src/` in the kickoff repo (the early scaffolder shipped
> only `README.md` + `configure.php`) — they correctly fall through to **2-way mode**. The §2
> fingerprint map starts at 1.5.1 anyway, so such baselines are effectively never detected.

### 1b. From the remote (public repo, no auth) — when the install is dist-only

A plain dist install has no `.git`. Shallow-clone just the base tag from GitHub:

```bash
BASE_DIR=$(mktemp -d)
git clone --depth 1 --branch "$BASE_TAG" \
  https://github.com/cleaniquecoders/kickoff.git "$BASE_DIR/clone" 2>/dev/null \
  && { mv "$BASE_DIR/clone/stubs" "$BASE_DIR/stubs"; mv "$BASE_DIR/clone/src" "$BASE_DIR/src"; }
# Sanity-check the latest on the remote (optional — confirms the local install isn't stale):
git ls-remote --tags --refs --sort=-v:refname https://github.com/cleaniquecoders/kickoff.git \
  | sed 's#.*refs/tags/##' | head -1
```

`--depth 1 --branch <tag>` resolves the tag ref; the repo is public, so no auth is needed.
(`gh release view <tag> -R cleaniquecoders/kickoff` gives the CHANGELOG section if you have `gh` auth.)

### 1c. No base obtainable → 2-way mode

If neither 1a nor 1b yields `$BASE_DIR/stubs` (offline **and** dist-only install), leave
`$BASE_DIR` unset. The patch then runs **2-way**: compare project files directly against the
local install's latest `stubs/`, classifying drift by tier (`patch-map.md`) + the version
stamp. Precision is lower (can't auto-distinguish "you edited" from "kickoff changed") — see
`merge-and-apply.md` §1.5. **Always report that 2-way mode is active.**

### Diff base → latest (file + imperative deltas)

```bash
# File deltas, per category (3-way mode — needs $BASE_DIR):
diff -rq "$BASE_DIR/stubs" "$KICKOFF/stubs"
# Imperative deltas (package set, publish tags, scripts) — base vs the local install:
git diff --no-index "$BASE_DIR/src/StartCommand.php" "$KICKOFF/src/StartCommand.php"
```

---

## 2. Stubs Are the File Baseline

Everything under `stubs/` maps **1:1** onto the project root. To find the project file a stub corresponds to, drop the `stubs/` prefix:

| Stub path (in kickoff) | Project path |
|---|---|
| `stubs/app/…` | `app/…` |
| `stubs/config/…` | `config/…` |
| `stubs/routes/…` | `routes/…` |
| `stubs/resources/…` | `resources/…` (views, css, js — UI components & layouts) |
| `stubs/database/…` | `database/…` |
| `stubs/bin/…` | `bin/…` (deploy/backup/install scripts) |
| `stubs/docs/…` | `docs/…` |
| `stubs/public/…` | `public/…` |
| `stubs/.github/…` | `.github/…` (CI workflows) |
| `stubs/.claude/…` | `.claude/…` |
| `stubs/.config/`, `stubs/.phpstan/` | `.config/`, `.phpstan/` |
| `stubs/CLAUDE.md` | `CLAUDE.md` (→ delegate merge to **project-sync** skill) |
| `stubs/docker-compose.yml` | `docker-compose.yml` |
| `stubs/.env.example` | `.env.example` (placeholder-substituted at scaffold — see below) |
| `stubs/.gitignore` (and nested) | `.gitignore` (restored last, post-commit) |
| `stubs/pint.json`, `stubs/rector.php`, `stubs/phpunit.xml`, `stubs/tailwind.config.js` | same name at root |

`copyStubs()` does a plain recursive copy of `stubs/` → project root (`StartCommand::copyStubs`), so the mapping is literally "strip the `stubs/` prefix."

### `stubs/stubs/` are make-command templates — NOT project files

`stubs/stubs/` (note the double nesting) ships **artisan make templates**, copied to the project's own `stubs/` dir (e.g. `stubs/model.stub` in the project). Current set (verify live):

```
enum.stub  helper.stub  migration.create.stub  model.stub  pest.stub  policy.stub
```

Treat `stubs/stubs/*` as a normal category of project files (they land in project `stubs/`), but never confuse them with the top-level stub→root mapping.

### Normalise placeholders before diffing

The scaffolder substitutes two placeholders (dollar-brace style) at scaffold time, so the project files no longer match the raw stub text. Reverse this before any 3-way merge:

| Placeholder constant | Token | Substituted with | Files affected |
|---|---|---|---|
| `PLACEHOLDER_PROJECT_NAME` | `${PROJECT_NAME}` | project name (and snake_cased for `DB_DATABASE` / `MINIO_BUCKET`) | `bin/*`, `README.md`, `.env.example` |
| `PLACEHOLDER_OWNER` | `${OWNER}` | project owner | `README.md`, `.env.example` |

When diffing, either re-inject `${PROJECT_NAME}` / `${OWNER}` into the **project** side, or substitute the **stub** side with the project's actual name/owner, so placeholder differences don't show up as spurious changes. `.env.example` also snake-cases `DB_DATABASE=${PROJECT_NAME}` and `MINIO_BUCKET=${PROJECT_NAME}` to `<snake_name>` (MySQL rejects kebab-case DB names) — account for that when comparing env lines.

---

## 3. Imperative Baseline (extracted from `StartCommand.php`)

> **All lists below are current as of 1.24.0 — re-extract from the local install's `src/StartCommand.php` before acting.** These are hardcoded in PHP, not shipped as stubs. `$KICKOFF` (the install) is the *latest* `StartCommand.php`; diff it against the **base** version's copy (from §1's `$BASE_DIR`) to know what changed:
> ```bash
> git diff --no-index "$BASE_DIR/src/StartCommand.php" "$KICKOFF/src/StartCommand.php"
> ```
> In **2-way mode** (no `$BASE_DIR`) you can't diff across versions — instead compare the project's current `composer.json` `require`/`require-dev` against the install's `$require`/`$requireDev` arrays below and offer to add only what's missing.
> Translate **added packages** → `composer require <pkg>` (dev additions → `--dev`); **added `--tag=` / `--provider=` entries** → `php artisan vendor:publish <option>`; **added artisan calls** → run them; **changed composer scripts/autoload** → 3-way merge into the project's `composer.json`.

### (a) Composer packages — `installPackages()`

**Require (prod)** — 25 packages:

```
laravel/sanctum
blade-ui-kit/blade-icons
cleaniquecoders/laravel-artisan-runner
cleaniquecoders/laravel-config-backup
cleaniquecoders/laravel-config-sso
cleaniquecoders/laravel-config-webhook
cleaniquecoders/laravel-mcp-kit
cleaniquecoders/laravel-media-secure
cleaniquecoders/traitify
diglactic/laravel-breadcrumbs
dragon-code/laravel-deploy-operations
lab404/laravel-impersonate
laravel/horizon
laravel/telescope
livewire/livewire:^4.0
livewire/flux
mallardduck/blade-lucide-icons
owen-it/laravel-auditing
predis/predis
spatie/laravel-activitylog
spatie/laravel-medialibrary
cleaniquecoders/media-manager
spatie/laravel-permission
spatie/laravel-settings
yadahan/laravel-authentication-log
```

**Require-dev** — 6 packages:

```
barryvdh/laravel-debugbar
cleaniquecoders/laravel-db-doc
driftingly/rector-laravel
laravel/boost
larastan/larastan
pestphp/pest-plugin-arch
```

Note version pins live inline (e.g. `livewire/livewire:^4.0`). When patching, compare the project's installed `composer.json` requires against this list; **add only the missing ones** — never downgrade or strip packages the project added itself.

### (b) `vendor:publish` tags / providers — `installPackages()`

Published via repeated `php artisan vendor:publish <option>`:

```
--provider="OwenIt\Auditing\AuditingServiceProvider"
--provider="Spatie\Activitylog\ActivitylogServiceProvider"
--provider="Spatie\LaravelSettings\LaravelSettingsServiceProvider"
--tag=authentication-log-config
--tag=authentication-log-migrations
--tag=blade-lucide-icons
--tag=blade-lucide-icons-config
--tag=impersonate
--tag=artisan-runner-migrations
--tag=config-backup-migrations
--tag=config-sso-migrations
--tag=config-webhook-migrations
--tag=laravel-errors
--tag=livewire:assets
--tag=media-secure-config
--tag=medialibrary-config
--tag=medialibrary-migrations
--tag=permission-config
--tag=permission-migrations
--tag=sanctum-config
--tag=telescope-migrations
--tag=livewire:config
--tag=media-manager-config
--tag=media-manager-views
```

Config publishes are intentionally limited because **pre-configured configs ship in `stubs/config`** (those come via the stub mapping, not vendor:publish). Spatie package-tools tags use the shortName (no `laravel-` prefix). Newly-added publish tags between versions usually pair with a newly-added package.

### (c) `composer.json` scripts + autoload — `setupComposer()`

`composer.json` is **not** a stub; it is rewritten in code. This block is the authoritative scripts/autoload baseline to 3-way merge into the project's existing `composer.json`:

- **autoload.files**: `["support/helpers.php"]`
- **config.allow-plugins**: `pestphp/pest-plugin: true`
- **scripts** (keys): `post-autoload-dump`, `post-update-cmd`, `post-root-package-install`, `post-create-project-cmd`, `dev`, `analyse`, `test`, `test-arch`, `test-coverage`, `format`, `lint`, `rector`. Notable values:
  - `analyse` → `@php vendor/bin/phpstan analyse`
  - `test` → `@php vendor/bin/pest`
  - `test-arch` → `@php vendor/bin/pest tests/Feature/ArchitectureTest.php`
  - `test-coverage` → `vendor/bin/pest --coverage`
  - `format` → `@php vendor/bin/pint`
  - `lint` → `@php vendor/bin/phplint`
  - `rector` → `vendor/bin/rector process`
  - `dev` → `npx concurrently` running `php artisan serve` + `queue:listen` + `pail` + `npm run dev`

Merge by key: add missing scripts, update changed Kickoff-owned scripts (with review), and **preserve any project-specific scripts** not in this list.

### (d) npm installs — `installPackages()`

```bash
npm install lodash axios tippy.js
```

(Skipped under `--skip-npm`.)

### (e) Post-install artisan commands — `runTasks()`

Run after `bin/install` + `npm run build`, under a safe-bootstrap env (`CACHE_STORE/CACHE_DRIVER/SESSION_DRIVER=array`):

```
php artisan key:generate
php artisan make:notifications-table
php artisan operations:install
php artisan mcp-kit:install --no-interaction
php artisan reload:db
```

Plus `php artisan boost:install --guidelines --skills --mcp --no-interaction` (run in the publish step). For a **patch** these are mostly one-time scaffolding; the relevant ones to re-run after adding a new package are typically the new package's own install command (e.g. a newly-added `*:install`) and any new publish tags — derive them from the `StartCommand.php` diff, don't blindly re-run all of these on an existing project.

---

## Quick recipe

```bash
# §0  REQUIRED local install = latest/theirs:
KICKOFF="${KICKOFF_SRC:-$(composer global config --absolute vendor-dir 2>/dev/null)/cleaniquecoders/kickoff}"
[ -d "$KICKOFF/stubs" ] || { echo "run: composer global require cleaniquecoders/kickoff"; exit 1; }
LATEST=$(composer global show cleaniquecoders/kickoff 2>/dev/null | awk '/^versions/{print $NF}')  # = installed version
BASE=<confirmed-baseline>                              # from detect-and-version.md

# §1  base tree: git archive if $KICKOFF is a git checkout, else shallow-clone the base tag
#     from the public remote, else leave $BASE_DIR unset → 2-way mode.

# Deltas to review (3-way mode — needs $BASE_DIR):
diff -rq "$BASE_DIR/stubs" "$KICKOFF/stubs"                                            # file deltas per category
git diff --no-index "$BASE_DIR/src/StartCommand.php" "$KICKOFF/src/StartCommand.php"   # imperative deltas
```
