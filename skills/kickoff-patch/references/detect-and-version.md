# Detect & Version — Is this a Kickoff project, and which version did it start from?

`/kickoff` must answer two questions before it can patch anything:

1. **Detection** — does this project descend from CleaniqueCoders Kickoff at all?
2. **Baseline version** — which Kickoff tag was it scaffolded from? (the 3-way merge `base`)

There is **no version marker in scaffolded projects today** (composer.json is rewritten
in code, `kickoff` never appears in composer.lock, no link back). So baseline is *inferred*
via a hybrid of feature-fingerprinting + git-date heuristic, then **confirmed by the user**.
After the first successful patch we **stamp a marker** so every future run is deterministic.

---

## 1. Detection Markers

A project is Kickoff-based if it is a Laravel app (`artisan` in root) **and** matches at
least one Kickoff-specific marker.

**Do not re-implement detection here** — the canonical marker table, local-FS checks,
GitHub-API checks, and false-positive guards already live in
`skills/project-sync/references/detection-markers.md`. `/kickoff` reuses that logic verbatim.

Quick recap of the strongest signals (see that file for the full table + commands):

| Signal | Where | Confidence |
|---|---|---|
| `cleaniquecoders/traitify` in `composer.json` require | `require` keys | High |
| `support/helpers.php` in Composer `autoload.files` | `autoload.files[]` (written by `StartCommand::setupComposer`) | High |
| `app/Models/Base.php` exists | file | High |
| `config/access-control.php` exists | file | Medium |
| `stubs/stubs/*.stub` generator templates (`enum.stub`, `model.stub`, `policy.stub`, `pest.stub`, `migration.create.stub`, `helper.stub`) | dir — **nested** `stubs/stubs/`, copied verbatim into scaffolded projects | Medium |
| `routes/web/` split (`_.php`, `auth.php`, `administration.php`, `security.php`, `media.php`, `notifications.php`, `pages.php`, `support.php`) loaded from `routes/web.php` | dir | Medium |
| Initial git commit subject is exactly **`Kickoff project setup`** | `git log` | High — see §3 |

> The scaffolder makes **one** commit (`gitCommit('Kickoff project setup', …)` in
> `src/StartCommand.php`) at the end of setup — not per-step. That single commit's date is
> the anchor for the git-date heuristic.

**Kickoff-specific extras `/kickoff` may also check** (beyond project-sync's list), useful
both as detection *and* as version fingerprints (§2): presence of
`app/Actions/Builder/Menu/` builder classes, `app/Providers/AdminServiceProvider.php`,
`resources/views/flux/icon/*.blade.php` bundle.

---

## 2. Version Fingerprint Map

Map an observable marker in the project to "this feature is present from version X".
The project's baseline is **the highest version whose markers are ALL present and below
which the next version's markers are absent**.

> **current as of 1.24.0 — REGENERATE this table from the fetched Kickoff `CHANGELOG.md`
> at the latest tag.** Do not trust this snapshot blindly; the live CHANGELOG (and `git
> diff <tag>..<tag> --stat` on `stubs/`) is the source of truth. Extraction recipe at the
> end of this section.

| Fingerprint / marker (grep target) | Present from | Strength |
|---|---|---|
| `routes/web/media.php` + `Menu/MediaManagement.php` + `media.access.management` in `config/access-control.php` (media-manager integration) | **1.5.1** | strong |
| `app/Livewire/Notifications/Bell.php`, `Menu/Sidebar.php`, `Menu/Settings.php`, `welcome.blade.php` hero, `x-kickoff-logo`; **removed** `Menu/Security.php` / `VoltServiceProvider` | **1.5.0** | strong |
| `GeneralSettings`/`MailSettings`/`NotificationSettings` Spatie Settings classes (settings UI no longer writes `.env`); `support/env.php` **deleted** | **1.7.0** | strong |
| No team config in Spatie permission; legacy `layouts/app/sidebar.blade.php` **removed**; `layouts/app.blade.php` uses `<x-layouts.app.sidebar>` (dot, not `::`) | **1.8.0** | medium |
| Impersonation UI (`<x-impersonating />` in sidebar layout, 3-dot dropdown impersonate action) | **1.13.0** | medium |
| `laravel/boost` in dev deps + `boost:install` step; "max 5 table columns / 3-dot action menu" UI rules in `CLAUDE.md`; Lucide-via-Flux convention | **1.11.0** | medium |
| Laravel 13 / PHP 8.5: Base+User models use `#[Fillable]`/`#[Guarded]`/`#[Hidden]` PHP attributes; Rector `LARAVEL_130`; CI runs `pest` not `phpunit` | **1.14.0** | strong |
| SOC 2 stubs: `app/Http/Middleware/SecurityHeaders.php`, `config/security.php`, `config/fortify.php`, `app/Concerns/EncryptsPii.php` + `RedactsPiiInAudit.php`, `bin/backup-db`, `.github/workflows/security.yml`, `app/Console/Commands/PurgeExpiredDataCommand.php`, `docs/05-security/soc2-compliance.md` | **1.17.0** | strong |
| `dragon-code/laravel-deploy-operations` in deps; `operations:*` artisan + `bin/deploy` runs `php artisan operations --force` (NOTE: 1.18.0 shipped wrong `deploy-operations:*` namespace; corrected 1.18.1) | **1.18.0 / .1** | medium |
| Post-install summary + `withSafeBootstrapEnv()`; `REDIS_PASSWORD=null` default; `setupDatabase()` SQLite fallback | **1.19.x** | weak (mostly scaffolder-side) |
| Users index full Livewire (search/filters/bulk delete + bulk role assign), invite flow, Manage-Access flyout, account suspension (`suspended_at`); supersedes interim `UserIndex`/`UserPanel` | **1.21.0** | strong |
| Collapsible sidebar + icon-rail (cookie-persisted), flyout submenus, collapsible menu groups | **1.21.0** | strong |
| `cleaniquecoders/laravel-config-webhook` + `-config-backup` + `-config-sso` in deps; `admin.manage.{webhooks,config-backup,sso}` permissions | **1.21.0** | strong |
| `cleaniquecoders/laravel-artisan-runner` in deps; `can:access.artisan-runner` route gate; `admin.access.artisan-runner` permission; menu under Audit & Monitoring | **1.22.0** | strong |
| `cleaniquecoders/laravel-mcp-kit` in deps; `mcp/tasks` endpoint; MCP Gate abilities; Telescope enabled-by-default (exception watcher); refreshed single-`K` logo; `flux:main` page container (`max-w-7xl mx-auto p-6 lg:p-8`); `audits.uuid` column | **1.23.0** | strong |
| `Security/AuditTrail/Index.php` Livewire + `audit-trail/_detail.blade.php` extracted; `Security/Users/Index.php` and `Admin/Roles/Index.php` enhancements | **1.24.0** | strong |

Also useful as coarse buckets (full package set, current as of 1.24.0 — verify live from
`StartCommand::installPackages` `$require[]`):
`laravel/sanctum` → present since ~1.3.4; `laravel/horizon`+`telescope`, `spatie/laravel-activitylog`,
`-medialibrary`, `-permission`, `-settings`, `cleaniquecoders/media-manager`,
`cleaniquecoders/laravel-db-doc`; the `cleaniquecoders/laravel-*` (artisan-runner, config-backup,
config-sso, config-webhook, mcp-kit, media-secure) cluster is the **1.21–1.23 fingerprint band**.

**How to regenerate this table live** (after fetching Kickoff — see source-resolution ref):

```bash
# 1. Section headers = version timeline
grep -nE '^## ' "$KICKOFF/CHANGELOG.md"

# 2. Per-version file deltas in stubs/ — the real fingerprints
for tag in $(git -C "$KICKOFF" tag | sort -V); do
  echo "== $tag =="; git -C "$KICKOFF" diff --stat "${prev:-$tag}" "$tag" -- stubs/ src/ | tail -n +1
  prev=$tag
done

# 3. Confirm a specific marker exists at a tag
git -C "$KICKOFF" show "1.23.0:src/StartCommand.php" | grep -n 'laravel-mcp-kit'
```

Prefer **added/removed files** (`git diff --name-status A B -- stubs/`) over prose — a
deleted file (e.g. `support/env.php` gone at 1.7.0) is an unambiguous one-directional signal.

---

## 3. Git-Date Heuristic

Anchor: the date of the project's `Kickoff project setup` commit. Map it to the **latest
Kickoff tag whose release date is on-or-before** that commit date.

```bash
# In the PROJECT: find the scaffold commit date (ISO, UTC).
# Prefer the exact subject; fall back to the repo's first commit.
PROJ=/path/to/project
SETUP_DATE=$(git -C "$PROJ" log --reverse --grep='^Kickoff project setup$' \
              --format='%cI' -1)
[ -z "$SETUP_DATE" ] && SETUP_DATE=$(git -C "$PROJ" log --reverse --format='%cI' | head -1)
echo "scaffolded around: $SETUP_DATE"

# Tag dates need a GIT source. The discovered default may be the dist install (no .git):
KICKOFF="${KICKOFF_SRC:-$(composer global config --absolute vendor-dir 2>/dev/null)/cleaniquecoders/kickoff}"
if git -C "$KICKOFF" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # local checkout / --prefer-source install: tag -> creation date, sorted, pick latest <= SETUP_DATE
  git -C "$KICKOFF" for-each-ref --sort=creatordate \
      --format '%(creatordate:short) %(refname:short)' refs/tags \
    | awk -v d="${SETUP_DATE%%T*}" '$1<=d {best=$2} END{print best}'
else
  echo "dist install has no tags — use the gh-api tag-date fallback below"
fi
```

If Kickoff is resolved **remote-only** (no local clone), get tag dates without fetching all
objects via the GitHub API:

```bash
gh api repos/cleaniquecoders/kickoff/tags --jq '.[].name' | sort -V   # names
# dates (tag -> commit -> committer date):
gh api repos/cleaniquecoders/kickoff/git/refs/tags --paginate \
  --jq '.[] | [.ref, .object.sha] | @tsv'
# then per sha: gh api repos/cleaniquecoders/kickoff/commits/<sha> --jq '.commit.committer.date'
```

Caveats that make this a *hint*, not a verdict:
- A project may have been scaffolded days/weeks after a tag shipped, or with an outdated
  global `cleaniquecoders/kickoff` install → the date can point *slightly too high or low*.
- Rebases / squashes / imported history can move or erase the original commit date.
- Two tags share a date (e.g. 1.18.0–1.19.1 all on `2026-05-18`; 1.21.0/1.22.0 both
  `2026-06-12`; 1.23.0/1.24.0 both `2026-06-18`) → date alone can't disambiguate; the
  fingerprint map (§2) breaks the tie.

So: **git-date narrows the range; fingerprints pick the exact tag.**

---

## 4. Hybrid Resolution Flow

```
1. Detect (§1, via project-sync markers). Not Kickoff -> abort with explanation.

2. If a STAMP exists (§5: .kickoff-version OR composer.json extra.kickoff.version)
   -> baseline is known & authoritative. Skip inference. Go to patch.

3. git-date heuristic (§3) -> candidate WINDOW of tags (handle same-date ties).

4. Fingerprint scan (§2) over the project's actual files
   -> the highest tag whose markers are all present, newest-absent next.
   Run greps for the strong, one-directional markers first (added/removed files).

5. Reconcile date-window ∩ fingerprint result:
     - agree            -> high confidence
     - fingerprint only -> trust fingerprint (date is just a hint), flag low-ish
     - conflict / gap   -> present BOTH guesses, lowest confidence

6. ASK THE USER TO CONFIRM the detected baseline (always — even on high confidence):
     "Detected baseline: 1.21.0 (confidence: high).
      Signals: collapsible sidebar + config-* packages present; mcp-kit absent.
      Scaffold commit dated 2026-06-12. Is 1.21.0 correct? [Y / enter different tag]"
   Use the confirmed value as the 3-way-merge BASE (stubs@<baseline>).

7. After a SUCCESSFUL patch -> write the STAMP (§5) with the NEW latest version,
   so the next run is deterministic (step 2 short-circuits).
```

When unsure between two adjacent tags, **bias the baseline LOWER**: a too-low base makes the
3-way merge show a few extra (already-present) hunks the user can fast-forward, which is safe.
A too-high base can silently *skip* changes the project actually still needs.

---

## 5. Marker Stamp Scheme (write after a successful patch)

Stamp **both** locations for robustness (file is git-diff-visible & tool-agnostic; composer
extra travels with dependency metadata). The CLI reads either; on conflict the file wins
(it's the more deliberate artifact).

**a) `.kickoff-version` at project root** — small JSON, easy to grep, survives composer ops:

```json
{
  "version": "1.24.0",
  "baseline": "1.21.0",
  "patched_at": "2026-06-18T09:30:00Z",
  "source": "github.com/cleaniquecoders/kickoff",
  "tool": "kickoff-patch"
}
```

- `version` — the Kickoff tag the project is NOW aligned to (becomes the next run's BASE).
- `baseline` — the originally-detected/confirmed tag (audit trail; never overwrite once set).
- `patched_at` — UTC ISO-8601 of this patch.

**b) `composer.json` `extra.kickoff`** — same shape, nested:

```json
{
  "extra": {
    "kickoff": {
      "version": "1.24.0",
      "baseline": "1.21.0",
      "patched_at": "2026-06-18T09:30:00Z"
    }
  }
}
```

Write composer extra with `jq` (preserves formatting better than hand-editing) or via the
project's editor; do not clobber other `extra.*` keys.

**On every subsequent run:** read `version` as the merge base, compute the new latest tag,
3-way-merge `version..latest`, and on success bump `version` (move old value into nothing —
keep `baseline` frozen) and refresh `patched_at`. This makes step 2 of §4 deterministic and
removes all guessing for previously-patched projects.

> The stamp is the long-term fix for "no version marker exists today" — the FIRST patch is
> the only one that has to infer; every patch after that is exact.
