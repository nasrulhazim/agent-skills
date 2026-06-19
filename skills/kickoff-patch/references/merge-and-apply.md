# Merge & Apply

The mechanics of turning a detected baseline → latest delta into a reviewed, applied patch.
This is the engine behind `/kickoff patch` (apply) and `/kickoff check` (dry-run only).

A patch is **never a blind overwrite**. Every modified file is a **3-way merge** (when the
original-version base is available) with three inputs — or a **2-way comparison** (§1.5)
when the base can't be obtained:

| Slot | Meaning | Where it comes from |
|------|---------|---------------------|
| `THEIRS` | the stub as it ships at **latest** | the **required local install** — `$KICKOFF/stubs/<path>` (`source-of-truth.md` §0) |
| `BASE` | the stub as it shipped at the project's **detected baseline** version | a git tag via `$BASE_DIR/stubs/<path>` — only when a git source exists (`source-of-truth.md` §1); **absent → 2-way** (§1.5) |
| `MINE` | the project's current file (may have local edits) | the target project working tree |

`$BASE_TAG` comes from `detect-and-version.md` (marker file, or fingerprint + user
confirm). The **latest** is the locally-installed kickoff and `$BASE_DIR` acquisition is in
`source-of-truth.md` (local install required; base from a git tag when available, else
2-way). Categories come from `patch-map.md`.

---

## 0. Prepare the trees

Resolve once, reuse for every file. The **latest** tree is the local install (required);
the **base** tree exists only in 3-way mode.

```sh
# $KICKOFF    = REQUIRED local kickoff install = THEIRS/latest  (source-of-truth.md §0)
# $BASE_DIR   = base-version tree (stubs + src), or UNSET in 2-way mode (source-of-truth.md §1)
# $PROJECT    = target project root
# $BASE_TAG / $LATEST_TAG = versions (detect-and-version.md / source-of-truth.md §0)

THEIRS_DIR="$KICKOFF"            # theirs = the install directly; $THEIRS_DIR/stubs/... is latest
# 3-way needs a base tree; 2-way runs when source-of-truth.md §1 couldn't produce one:
[ -d "${BASE_DIR:-/nonexistent}/stubs" ] && MODE=3way || MODE=2way
echo "merge mode: $MODE"
```

The install's `stubs/` needs no extraction — read it in place. `$BASE_DIR` comes from
`source-of-truth.md` §1 (git archive of `$BASE_TAG`, or a shallow base-tag clone). In
**2-way mode** skip the base entirely and jump to §1.5.

> NOTE: stub paths are **relative to `stubs/`** but land at the **project root**
> (e.g. `stubs/app/...` → `$PROJECT/app/...`, `stubs/routes/web.php` → `$PROJECT/routes/web.php`).
> `composer.json` is **NOT** a stub — it is rewritten imperatively (see §6). Skip it here.

---

## 1. The 3-way merge procedure (per file)

For each candidate stub path `P` (relative to `stubs/`), the three concrete files are:

```
base=$BASE_DIR/stubs/$P      theirs=$THEIRS_DIR/stubs/$P      mine=$PROJECT/$P
```

Decision table — evaluate top to bottom, first match wins:

| Condition | Outcome | Action |
|-----------|---------|--------|
| `theirs` absent, `base` present | upstream **deleted** the stub | report `[upstream-removed]`, ask before deleting `mine` (never auto-delete) |
| `base` absent, `theirs` present | upstream **added** a new stub | if `mine` absent → `[new-file]` copy; if `mine` present → treat as 3-way with empty base |
| `base` == `theirs` (byte-identical) | upstream unchanged this version range | `[skipped: no upstream change]` — never touch |
| `mine` absent | upstream changed, project never had it | `[new-file]` — copy `theirs` → `mine` |
| `mine` == `base` (byte-identical) | upstream changed, **project untouched** | `[fast-forward]` — copy `theirs` → `mine`, no merge needed |
| `mine` == `theirs` | project already at latest content | `[skipped: already current]` |
| else (all three differ) | upstream changed **and** project changed | `[3-way merge]` → §1.2 |

Compute the equality checks cheaply with hashes:

```sh
h() { [ -f "$1" ] && shasum -a 256 "$1" | cut -d' ' -f1 || echo MISSING; }
hb=$(h "$base"); ht=$(h "$theirs"); hm=$(h "$mine")
[ "$hb" = "$ht" ] && echo skip            # upstream unchanged
[ "$hm" = "$hb" ] && echo fast-forward    # "project-unchanged-from-base" => safe FF
[ "$hm" = "$ht" ] && echo already-current
```

The key safety test is **"project-unchanged-from-base"** = `hm == hb`. Only then is a
fast-forward (plain copy of `theirs`) safe, because the user never edited that file.

### 1.2 Performing the merge (git-based — preferred)

`git merge-file` does an in-place diff3 merge and exits non-zero on conflict:

```sh
# Work on a copy so a conflicted result never lands in the project tree:
work=$(mktemp); cp "$mine" "$work"
# git merge-file <current> <base> <other>  -> writes merged result into <current>
if git merge-file -L "project (yours)" -L "kickoff $BASE_TAG (base)" -L "kickoff $LATEST_TAG (theirs)" \
       "$work" "$base" "$theirs"; then
    STATUS="[3-way merge]"      # clean — $work holds merged content, apply on approval
else
    STATUS="[conflict]"         # $work now contains <<<<<<< ======= >>>>>>> markers
fi
```

- Clean (exit 0): `$work` is the merged file. Stage it for the category's apply set.
- Conflict (exit >0): `$work` contains standard conflict markers. **Surface the markers
  in the preview and require explicit resolution** — never auto-apply a conflicted file.
  Offer: edit-now / keep-mine / take-theirs / skip.

### 1.3 Non-git fallback (diff3)

If `git` is unavailable, GNU `diff3` produces the same merge:

```sh
# -m = merge to stdout with markers; exit 0 clean, 1 = conflicts present
if diff3 -m "$mine" "$base" "$theirs" > "$work"; then
    STATUS="[3-way merge]"
else
    STATUS="[conflict]"   # $work has <<<<<<< / ||||||| / ======= / >>>>>>> markers
fi
```

`diff3 -m mine base theirs` mirrors `git merge-file current base other` (order:
**mine, base, theirs**). Both leave conflict markers in `$work`.

### 1.5 Two-way fallback mode (no base tree)

When `$BASE_DIR` was not produced (offline **and** a dist-only install — `source-of-truth.md`
§1c), there is no base, so the `hm == hb` safety test is impossible. Compare **mine vs theirs**
only, and lean on tiers (`patch-map.md`) to decide:

| Condition | Outcome | Action |
|-----------|---------|--------|
| `theirs` present, `mine` absent | upstream has a file the project lacks | `[new-file]` — offer to add |
| `mine` == `theirs` | identical | `[skipped: already current]` |
| `mine` != `theirs`, Tier C (project-owned) | the project's own file | `[skipped: project-owned]` |
| `mine` != `theirs`, Tier A/B (kickoff-owned) | drift — **can't tell who changed it** | `[differs: review]` — show the diff; user picks take-theirs / keep-mine / merge-by-hand |

2-way can't auto-fast-forward kickoff changes (no base to prove the project never edited the
file), so every kickoff-owned difference is a manual review. Suppress project-owned noise with
the tiers, and use the version stamp/fingerprint (`detect-and-version.md`) to hint which side
likely changed. **Always tell the user 2-way mode is active** and recommend a `--prefer-source`
install (or going online once) for a precise 3-way next time.

---

## 2. Category-grouped preview report

Walk every stub path, classify with §1, and bucket by the categories defined in
`patch-map.md` (packages / menu / config / UI components / layouts / routes / bin /
CI / docs / docker / env / CLAUDE.md). Render a markdown report. `/kickoff check`
stops here (dry-run); `/kickoff patch` continues to the approval loop.

Each line is tagged `[fast-forward]` / `[3-way merge]` / `[conflict]` / `[new-file]` /
`[upstream-removed]` / `[skipped: ...]`, with per-category counts and a header summary.

```markdown
# Kickoff patch preview — myapp
Baseline 1.4.2  →  latest 1.24.0   (20 versions of drift)
Source: local install @ 1.24.0 (composer global)   ·   base 1.4.2 via git tag

Summary: 14 fast-forward · 9 three-way · 3 conflict · 6 new · 31 skipped

## config            [2 ff · 1 merge · 1 conflict]
  [fast-forward]  config/permission.php
  [fast-forward]  config/media-library.php
  [3-way merge]   config/auditing.php          (clean — review below)
  [conflict]      config/app.php               ⚠ you edited 'providers'; upstream added 2

## menu / navigation [1 merge]
  [3-way merge]   resources/views/.../sidebar.blade.php   (clean)

## UI components     [3 new · 1 ff]
  [new-file]      resources/views/flux/main.blade.php
  [fast-forward]  resources/views/components/app-logo.blade.php

## routes            [1 conflict]
  [conflict]      routes/web.php               ⚠ both added routes near line 40

## bin               [2 ff]
  [fast-forward]  bin/install
  [fast-forward]  bin/deploy

## docs              [4 skipped]
  [skipped: no upstream change]  docs/01-getting-started/...

## env               [1 merge]
  [3-way merge]   .env.example                 (clean — placeholders preserved)

## packages          (imperative — see §6, not a file copy)
  + 5 new composer require, +1 require-dev, +3 vendor:publish tags  (vs 1.4.2)

## CLAUDE.md         → deferred to /project-sync (convention merge)
```

For every `[conflict]` and (optionally) every `[3-way merge]`, offer to show the unified
diff or the marked-up merge result inline before the user decides.

---

## 3. Approval loop (apply mode)

`/kickoff patch` walks categories **one at a time**. Per category the user answers:

- **yes** — apply every non-conflict item in this category.
- **no** — skip the whole category.
- **selective** — apply only chosen files (offer the per-file list).
- **diff** — show diffs for this category, then re-ask.

Then apply only approved items: fast-forward = copy `theirs`→`mine`; clean 3-way =
copy merged `$work`→`mine`. **Conflicts are never applied by a yes** — each conflicted
file is resolved individually (edit-now / keep-mine / take-theirs / skip) before its
merged content is written.

### Safety rules (hard invariants)

- **Never touch `.env`.** Only ever merge `.env.example`; surface new keys so the user
  copies them into `.env` themselves. (Stamp/placeholder logic in StartCommand only
  rewrites `.env.example` too.)
- **Never blanket-overwrite `app/`.** Application code under `app/` is project-owned;
  default to `[skipped: project-owned]` unless it maps to a tracked Kickoff stub and the
  user opts in. Show, never assume.
- **Always dry-runnable.** `/kickoff check` runs §0–§2 and prints the report but writes
  nothing. `/kickoff patch` is the only path that mutates files, and only after approval.
- **Work on copies.** Merges happen in `$work` temp files; the project tree changes only
  at apply time, so an aborted/declined patch leaves the project pristine.
- **Clean tree recommended.** Warn (don't block) if `git status` in `$PROJECT` is dirty,
  so the patch lands on a reviewable diff.

---

## 4. Apply

For each approved item write the resolved content to `$PROJECT/$P`:

```sh
mkdir -p "$(dirname "$PROJECT/$P")"
cp "$RESOLVED" "$PROJECT/$P"   # $RESOLVED = $theirs (ff/new) or $work (merged)
```

Preserve executable bits for `bin/*` (`chmod +x`). After file application, run the
imperative re-apply (§6), then stamp (§5) and verify (§7).

---

## 5. Stamp the new version

After a successful apply, record the new baseline so the **next** patch detects it
cleanly. `detect-and-version.md` §5 is the canonical stamp spec — follow it exactly:
write **both** locations, with `.kickoff-version` (a JSON object) as the authoritative
artifact (the file wins on conflict). Keep `baseline` frozen from the first patch; only
bump `version` to the tag just applied.

```sh
# baseline is frozen once set (the originally-detected tag) — preserve it on re-patch:
FROZEN=$( [ -f "$PROJECT/.kickoff-version" ] && jq -r '.baseline // empty' "$PROJECT/.kickoff-version" )
FROZEN=${FROZEN:-$BASE_TAG}

# 1) Authoritative: .kickoff-version JSON at project root.
cat > "$PROJECT/.kickoff-version" <<JSON
{
  "version": "$LATEST_TAG",
  "baseline": "$FROZEN",
  "patched_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "github.com/cleaniquecoders/kickoff",
  "tool": "kickoff-patch"
}
JSON

# 2) Mirror into composer.json extra.kickoff (preserve other extra.* keys):
tmp=$(mktemp)
jq --arg v "$LATEST_TAG" --arg b "$FROZEN" \
   '.extra.kickoff = {version:$v, baseline:$b}' \
   "$PROJECT/composer.json" > "$tmp" && mv "$tmp" "$PROJECT/composer.json"
```

Suggested commit message (do **not** commit unless the user asks):

```
chore(kickoff): patch baseline 1.4.2 → 1.24.0

Applied Kickoff upstream changes: config, menu, UI components, routes, bin.
+5 composer require, +3 vendor:publish tags. Stamped .kickoff-version.
```

---

## 6. Post-apply: re-apply imperative (non-file) changes

Many Kickoff changes live in `src/StartCommand.php`, **not** in `stubs/`. These are not
file copies — they are commands. Detect them by diffing `StartCommand.php` between the
two tags, then apply the delta with composer/npm/artisan **under the same per-category
approval** (category = `packages`).

```sh
# base ($BASE_DIR, source-of-truth §1) vs the local install (latest):
git diff --no-index "$BASE_DIR/src/StartCommand.php" "$KICKOFF/src/StartCommand.php"
# 2-way mode (no $BASE_DIR): instead compare the project's composer.json require set vs the
# install's StartCommand package arrays (source-of-truth.md §3) and add only what's missing.
```

The diff cleanly reveals the delta — e.g. between 1.20.0 and 1.24.0 it shows `+5` new
`require` packages (`artisan-runner`, `config-backup`, `config-sso`, `config-webhook`,
`mcp-kit`), **no** `require-dev` change, and new `--tag=...` vendor:publish lines. Trust
the actual array diff, not Kickoff's own dry-run count strings (those are off-by-one vs
the real `$require`/`$requireDev` arrays). Extract from these blocks:

| Imperative change | Where in StartCommand | How to detect in the diff | How to re-apply (after approval) |
|-------------------|-----------------------|---------------------------|----------------------------------|
| New composer **require** | `installPackages()` → `$require[]` | added lines inside the `$require = [ ... ]` array | `composer require <new pkgs>` (preserve version pins like `livewire/livewire:^4.0`) |
| New **require-dev** | `installPackages()` → `$requireDev[]` | added lines in `$requireDev = [ ... ]` | `composer require --dev <new pkgs>` |
| **Removed** package | same arrays | removed lines | ask before `composer remove` (may be in use) |
| New **vendor:publish** tags | `installPackages()` → `$options[]` | added `--tag=...` / `--provider=...` lines | `php artisan vendor:publish <option>` for each new one |
| composer **scripts / autoload** delta | `setupComposer()` | changes to the `$composer['scripts']` block or `autoload.files` | merge into project `composer.json` (3-way the `scripts` + `autoload` keys), then `composer dump-autoload` |
| New **npm** installs | `installPackages()` → `runCommand('npm install ...')` | changed `npm install <pkgs>` line | `npm install <new pkgs>` |
| New **post-install artisan** cmds | `runTasks()` / boost step | new `runCommand('php artisan ...')` lines | run each new artisan command (e.g. `php artisan mcp-kit:install`, `operations:install`) with approval |

> Always extract the **live** lists from the fetched source — do not trust a snapshot.
> Concrete lists below are **current as of 1.24.0 — verify live** by re-reading
> `src/StartCommand.php` at `$LATEST_TAG`.

Current-as-of-1.24.0 anchors (verify live):
- `$require`: laravel/sanctum, blade-ui-kit/blade-icons, cleaniquecoders/laravel-artisan-runner,
  laravel-config-backup, laravel-config-sso, laravel-config-webhook, laravel-mcp-kit,
  laravel-media-secure, traitify, diglactic/laravel-breadcrumbs, dragon-code/laravel-deploy-operations,
  lab404/laravel-impersonate, laravel/horizon, laravel/telescope, livewire/livewire:^4.0,
  livewire/flux, mallardduck/blade-lucide-icons, owen-it/laravel-auditing, predis/predis,
  spatie/laravel-activitylog, spatie/laravel-medialibrary, cleaniquecoders/media-manager,
  spatie/laravel-permission, spatie/laravel-settings, yadahan/laravel-authentication-log.
- `$requireDev`: barryvdh/laravel-debugbar, cleaniquecoders/laravel-db-doc, driftingly/rector-laravel,
  laravel/boost, larastan/larastan, pestphp/pest-plugin-arch.
- npm: `lodash axios tippy.js`.
- post-install artisan (in `runTasks()`): `make:notifications-table`, `operations:install`,
  `mcp-kit:install --no-interaction`, `reload:db`, plus `boost:install --guidelines --skills --mcp`.

Only apply the **diff** (packages/tags/cmds **new since** `$BASE_TAG`), not the whole
list — the project already has everything from its baseline.

After requiring, **verify each new package actually landed** — `composer show <pkg>` and
confirm its route/menu item resolves in `route:list`. A skipped or failed `composer require`
(or a stub that only ships the package's *config/menu/permission*) leaves the feature dead:
the menu item is silently hidden by its `Route::has()` guard and nothing errors. This is the
**single most common "patch looked clean but the feature is missing"** bug — see §7d.

---

## 7. Verify & hand off

Verify in **four layers** — **boot, migrations, assets, quality gate** — before handing off.
Every layer comes from a real patch failure: a config calling a method the installed package
lacked; an un-run migration behind a patched page; a sidebar referencing an un-rebuilt JS
store; and — the most common by far — a **stub that depends on project-owned code the merge
correctly skipped** (§7d). Run the project's **test suite** as part of the gate: the patch
ships tests that encode the expected behaviour, so a red suite *is* the gap detector.

### 7a. Boot smoke-test (catches fatals a clean merge can still introduce)

A clean 3-way merge can pull in code that references an API the project's installed package
version lacks (e.g. `config/fortify.php` calling `Features::passkeys()` on an older Fortify).
Boot the framework to surface it **before** handing off:

```sh
php artisan config:clear
php artisan about                                   # or --version; a fatal here = a merged file is broken
php artisan view:cache && php artisan view:clear    # if any resources/views/** changed — compiles every Blade
php artisan route:list >/dev/null                   # routes still resolve
```
If a fatal points at a merged config/file referencing a missing method/class, the project's
package is older than the new stub expects — disable that feature or bump the package, and say so.

### 7b. Run pending migrations (the patch ships migration files but doesn't run them)

New baseline migrations arrive as **files** (e.g. `*_add_suspended_at_to_users_table`,
`*_add_uuid_to_audits_table`, a Spatie `database/settings/*` migration) — copying the file
does **not** create the column. A patched view/component that reads the new column then 500s
at runtime even though the merge looks clean. After applying, surface and run them:

```sh
php artisan migrate:status | grep -i pending     # list what the patch introduced
php artisan migrate                              # confirm first; additive nullable columns are safe
```
Run them — or, if the user declines, **say loudly** which are pending. A patched page over an
un-migrated table is the single most common post-patch 500.

### 7c. Rebuild front-end assets (when JS/CSS changed)

If the patch touched `resources/js/**`, `resources/css/**`, `tailwind.config.js`, or
`package.json`, the **source** is updated but the **compiled bundle is stale** — the change
is invisible at runtime until rebuilt (e.g. a new `Alpine.store('sidebar')` or collapsible
sidebar CSS won't apply, throwing `$store.sidebar undefined`). Rebuild:

```sh
[ -n "$(git -C "$PROJECT" diff --name-only HEAD -- package.json)" ] && (cd "$PROJECT" && npm install)
(cd "$PROJECT" && npm run build)    # recompiles resources/js + resources/css into public/build
```
`public/build/` is usually git-ignored (rebuilt at deploy), so this is a local verify step —
but skipping it makes JS/CSS patches look applied while the browser still serves the old bundle.

### 7d. Stub ↔ project-owned dependency gaps (the #1 source of post-patch 500s)

The merge applies **stub files** (views, Livewire components, routes, blade) but **never
touches PROJECT-OWNED code** — models (`app/Models`), the middleware kernel
(`bootstrap/app.php`), route guards, service providers, gates. A new stub view/component
routinely **depends on** project-owned code the project doesn't have yet: it compiles fine
but breaks at runtime. The fix is almost always **additive** — port the missing member from
the matching stub model/provider/route. Run the project's **test suite** (the patch ships
tests that encode the expected behaviour) and read failures by signature:

| Runtime symptom | Real cause | Fix |
|---|---|---|
| `Call to undefined method App\Models\X::scope()/method()` | a stub view/component calls a model scope/method (`User::active()`, `suspend()`, `status()`) the project model lacks | copy the methods from `$KICKOFF/stubs/app/Models/X.php` into the project model |
| `Class name must be a valid object or a string` (HasRelationships) | model relationship/guard mismatch — e.g. spatie `Role::withCount('users')` under the `sanctum` default guard with no pin | port the stub model's `__construct` guard pin (`$attributes['guard_name'] ??= 'web'`) + members like `isProtected()` |
| `Flux component [icon.X] does not exist` | a merged menu/view uses an unpublished Flux icon | `php artisan flux:icon X …` (or ship the icon blade in `resources/views/flux/icon`) |
| Guest gets **403** instead of a **302** login redirect; suspended user not logged out | a new stub route lacks `auth`/`verified`, or a stub middleware (`EnsureUserIsNotSuspended`) isn't registered in `bootstrap/app.php` | mirror the stub's `routes/web/*.php` guards + `bootstrap/app.php` `appendToGroup('web', …)` |
| `ERR_TOO_MANY_REDIRECTS` on `/telescope` | a project-owned route self-redirects (`Route::redirect('/telescope', config('telescope.path'))` — source path === target) | remove it; Telescope/Horizon serve their own named dashboards — guard the menu with `Route::has()` |
| SaaS-only screen visible on the on-prem edition | a menu item gated only by permission, not edition | add an edition predicate (`Edition::isSaas()`) to its visibility |
| A new menu item is **silently hidden** / its vendor route 404s (e.g. Artisan Runner) | the stub menu/config/gate/permission applied, but the **backing composer package was never installed** — file copies don't run `composer require`. The `Route::has()` guard hides the dead item, so nothing errors loudly | run §6 for that package: `composer require <pkg>` → `vendor:publish --tag=<pkg>-config/-migrations` → `php artisan migrate` (e.g. artisan-runner's `command_logs`). **Verify**: `composer show <pkg>` + the route appears in `route:list` |
| A gate that maps to a permission **denies** even for superadmin; the menu item stays hidden | the patch applied the new permission to `config/access-control.php` (a file) but the permission row was **never seeded** into the DB, so `$user->can(...)` is false | re-run the permission sync — `php artisan db:seed --class=AccessControlSeeder` (or the project's sync cmd) + `php artisan permission:cache-reset` |
| A feature toggled by `env('X_ENABLED', false)` is **off** after patch though its stub config shipped (e.g. Telescope `/telescope` 404) | the patch updates `.env.example` but **never the runtime `.env`**; the project's/platform's `.env` lacks the new key, so the `false` default wins | surface the new `.env.example` keys **loudly** for the user to set; for must-register-by-default features (a dashboard route) prefer a robust config default (`env('X_ENABLED', true)`, opt-out) over `false` |
| Mail open/click tracking is enabled but "Opened"/"Clicked" **never records** | a content-injection feature only transforms **HTML** — a test/sample/notification email sent via `Mail::raw` (plaintext) gets no pixel/link-rewrite, so it can never fire. (Also inherent: email clients proxy/block images.) | send via an HTML Mailable (e.g. `DefaultMail` + `InteractsWithMailMetadata`), not `Mail::raw`; verify the *sent* HTML contains the injected URL |

The recurring lesson: **diff the applied stubs against the project-owned code AND the imperative
state they depend on** — model members, route middleware, middleware registration, gates,
**installed composer packages (§6), seeded permissions, and runtime `.env` keys**. A clean
file merge can still leave a feature dead because a non-file dependency (a package, a seed row,
an env key) was never applied.

### 7e. Quality gate

Run the project's own quality gate **if present** (the composer scripts StartCommand writes —
see `setupComposer()`):

```sh
composer format   2>/dev/null || vendor/bin/pint
composer analyse  2>/dev/null || vendor/bin/phpstan analyse
composer test     2>/dev/null || vendor/bin/pest
```

Report results; if any layer fails, the merged code needs a fix-up — surface it,
don't silently leave a broken tree.

Finally:
- **CLAUDE.md / convention drift** is **out of scope here** — defer it to the
  sibling **`project-sync`** skill, which already does intelligent CLAUDE.md merging
  across Kickoff projects. The preview lists CLAUDE.md as `→ deferred to /project-sync`.
- Remind the user the patch is unstaged; suggest the §5 commit message but let them commit.

---

## Reference Files

| File | Purpose |
|------|---------|
| `references/detect-and-version.md` | Resolve `$BASE_TAG`: marker file / fingerprint + confirm; stamp rules |
| `references/source-of-truth.md` | Require the local install (`$LATEST_TAG`); acquire the `$BASE_DIR` tree from a git tag (else 2-way) |
| `references/patch-map.md` | Category definitions and stub-path → category mapping used by §2 |
