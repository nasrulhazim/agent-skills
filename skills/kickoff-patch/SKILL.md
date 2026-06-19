---
name: kickoff-patch
metadata:
  compatible_agents: [claude-code]
  tags: [kickoff, laravel, patch, upgrade, baseline, 3-way-merge, scaffolding, cleaniquecoders]
description: >
  Brings a Laravel project that was scaffolded from CleaniqueCoders Kickoff up to the
  latest Kickoff baseline. Detects which Kickoff version a project started from (no
  marker exists — uses feature fingerprinting plus a git-date heuristic, then asks you
  to confirm), reads the latest Kickoff from the REQUIRED local install
  (composer global require cleaniquecoders/kickoff) and the original-version base from a
  git tag when available, and performs a category-grouped 3-way merge (base = original
  Kickoff, theirs = latest Kickoff, mine = your files) — falling back to a 2-way compare
  when the base cannot be obtained, never a blind overwrite. Patches
  packages, vendor:publish tags, navigation menu, config, Livewire and Blade components,
  layouts and theme, routes, bin scripts, CI workflows, docs, docker, and .env.example
  keys, while protecting project-owned code, .env, product config, and custom routes.
  Previews every change and applies only what you approve per category, then stamps a
  version marker so future runs are deterministic. Use this skill whenever the user
  wants to patch, update, or upgrade a Kickoff-based project to the latest Kickoff, see
  what drifted from the current Kickoff baseline, or pull new Kickoff packages, menu
  items, settings, UI fixes, or components into an existing project — including "patch
  my kickoff project", "update to latest kickoff", "bring this project up to date with
  kickoff", "what changed in kickoff", "check kickoff drift", "kickoff patch", "sync the
  kickoff baseline", "update kickoff scaffolding", "run /kickoff patch", "patch project
  kickoff aku", "update ke kickoff terbaru", "apa yang lain dengan kickoff latest",
  "tengok apa dah berubah dalam kickoff", "kemaskini baseline kickoff", "naik taraf
  project ikut kickoff terkini", "tarik package atau menu baru dari kickoff", or "check
  drift kickoff". Assumes the target project was scaffolded from CleaniqueCoders Kickoff
  — works alongside project-sync (which handles CLAUDE.md convention merging) and
  project-laravel (Kickoff conventions enforcer). Works on ANY Kickoff-based Laravel
  project, not a specific one.
---

# Kickoff Patch — Bring a Kickoff-based project up to the latest baseline

`/kickoff patch` upgrades a Laravel project that was scaffolded from
[CleaniqueCoders Kickoff](https://github.com/cleaniquecoders/kickoff) to the current
Kickoff baseline — pulling in new packages, menu items, settings, UI fixes, components,
config, and CI changes — **without clobbering the developer's own work**. It is a
preview-first, approve-per-category merge — **3-way** when the original version is
available, **2-way** otherwise — not a file copy.

## Mental model (read this first — it determines everything)

Kickoff is **not** a Laravel skeleton you fork or a dependency you track. It is a
one-shot Symfony Console scaffolder: `kickoff start <owner> <name>` runs `laravel new`,
copies `stubs/` over the fresh app, and `composer require`s a hardcoded package set —
then **walks away**. After scaffolding there is **no link back**: `cleaniquecoders/kickoff`
never appears in `composer.lock`, and there is no version marker. Consequences:

- **Two sources of truth** define a Kickoff baseline at any version:
  1. **Files under `stubs/`** (copied 1:1 onto the project root).
  2. **Imperative logic in `src/StartCommand.php`** — the composer package list,
     `composer.json` scripts/autoload, `vendor:publish` tags, npm installs, and
     post-install artisan commands. `composer.json` is **rewritten in code**, never
     shipped as a stub, so you cannot diff a stub `composer.json`.
- **The latest baseline is the locally-installed kickoff.** The patch REQUIRES
  `cleaniquecoders/kickoff` installed globally (`composer global require
  cleaniquecoders/kickoff`) and reads its `stubs/` + `StartCommand.php` as *latest*. A
  `composer global` install is dist-based (no git tags) — it is a single version.
- **A patch is a 3-way merge** (base = original version, theirs = latest, mine = your
  files), never an overwrite. The project and Kickoff both evolve; e.g. 1.4.2 → 1.24.0 is
  ~20 versions of drift with files changed on **both** sides, so overwriting either
  direction destroys real work. The original-version **base** comes from a git tag when a
  git source exists; otherwise the patch degrades to a lower-precision **2-way** compare.
- **Version detection is inferred, then confirmed**, because no marker exists today. The
  first patch stamps a marker so every subsequent run is exact.

## Command Reference

| Command | Purpose |
|---------|---------|
| `/kickoff check [--source=<repo\|path>] [--from=<tag>]` | Dry-run: detect baseline, diff against latest Kickoff, print the category-grouped report. Writes nothing. |
| `/kickoff patch [--source=<repo\|path>] [--from=<tag>] [--to=<tag>]` | Detect → diff → preview → **approve per category** → apply (3-way merge) → re-apply imperative deltas → stamp → verify. |
| `/kickoff status` | Quick summary: is this a Kickoff project, detected baseline, latest available, and how many versions behind. |

**Precondition:** all three commands require `cleaniquecoders/kickoff` installed globally;
they abort with a `composer global require cleaniquecoders/kickoff` hint if it is missing.

- `--source` — override the kickoff source. Default: the **required local install** at
  `$(composer global config --absolute vendor-dir)/cleaniquecoders/kickoff` — its `stubs/` is
  *latest*. Point it at a local **git checkout** of kickoff (with tags) to enable precise
  **3-way** merges; a plain dist install has no tags, so the original-version base is fetched
  from the public remote when online, else the patch falls back to **2-way**.
- `--from` — override the detected baseline tag (skip inference; use when you already
  know the original version or a stamp is wrong).
- `--to` — target a specific Kickoff tag instead of the installed latest (staged upgrades;
  requires a git or remote source, since the local install only provides its installed version).

---

## The patch pipeline

Every command walks the same pipeline; `check` and `status` stop early. Each step is
backed by a reference file — **read the reference before executing that step**.

1. **Detect + resolve baseline** → `references/detect-and-version.md`
   Confirm the project descends from Kickoff (reuse `project-sync` detection markers). If
   a stamp exists (`.kickoff-version` or `composer.json` `extra.kickoff.version`), use it
   as `BASE` and skip inference. Otherwise infer with the feature-fingerprint map +
   git-date heuristic, then **ASK THE USER TO CONFIRM** the detected baseline before
   proceeding. When unsure between two adjacent tags, bias `BASE` **lower** (safe extra
   hunks, never silent skips).

2. **Require local kickoff + acquire trees** → `references/source-of-truth.md` §0–1
   **Precondition:** abort unless `cleaniquecoders/kickoff` is installed globally (tell the
   user to `composer global require` it). Its `stubs/` is `LATEST`/theirs and its installed
   version is `LATEST_TAG`. Acquire the `BASE` (original-version) tree from a git tag when a
   git source exists (`--source` checkout / `--prefer-source` install / public remote); if
   none, switch to **2-way mode**. Normalise the `${PROJECT_NAME}` / `${OWNER}` placeholders
   before diffing.

3. **Diff + classify** → `references/merge-and-apply.md` + `references/patch-map.md`
   For every stub path, compute `BASE` / `THEIRS` / `MINE` and classify per the decision
   table: `[skipped]` (no upstream change / already current / project-owned),
   `[fast-forward]` (project byte-identical to base), `[new-file]`, `[3-way merge]`, or
   `[conflict]`. The safety test is **"project-unchanged-from-base"** (`hm == hb`) — only
   then is a fast-forward safe. Use `patch-map.md` for the 3-tier safety classification
   (VERBATIM-SAFE / MODIFIED-MANAGED / PROJECT-OWNED). In **2-way mode** (no base obtained),
   compare `MINE` vs `THEIRS` only and flag kickoff-owned drift as `[differs: review]`
   (`merge-and-apply.md` §1.5).

4. **Category-grouped preview** → `references/merge-and-apply.md`
   Bucket every change by category (packages / menu / config / UI components / layouts /
   routes / bin / CI / docs / docker / env / CLAUDE.md), with per-category counts and the
   per-item tag. `/kickoff check` **stops here**.

5. **Approve per category, then apply** (`/kickoff patch` only)
   Walk categories one at a time: **yes** / **no** / **selective** / **diff**. Apply only
   approved items, on temp copies, writing to the project tree only at apply time.
   **Conflicts are never applied by a "yes"** — resolve each individually
   (edit-now / keep-mine / take-theirs / skip).

6. **Re-apply imperative deltas** → `references/merge-and-apply.md` §6 + `references/source-of-truth.md` §3
   File copies don't cover `StartCommand.php` changes. Diff the base's copy against the local
   install's (`git diff --no-index $BASE_DIR/src/StartCommand.php $KICKOFF/src/StartCommand.php`)
   and translate the delta into actions
   under the same approval: new `composer require` / `--dev`, new `vendor:publish` tags,
   `scripts`/`autoload` merges, new npm installs, new package `*:install` commands. Apply
   **only the delta since `BASE`** — never re-run the whole scaffold.

7. **Stamp + verify + hand off** → `references/detect-and-version.md` §5 + `references/merge-and-apply.md` §7
   Write the new version stamp (`.kickoff-version` + `composer.json` `extra.kickoff`) so
   the next run is deterministic. **Verify in four layers** (`merge-and-apply.md` §7):
   (a) **boot smoke-test** — `config:clear` + `artisan about` + `view:cache` (catches a
   merged file referencing a package API the installed version lacks, e.g.
   `Features::passkeys()`); (b) **run pending migrations** — the patch ships migration
   *files* but doesn't run them; `migrate:status` then `migrate`, else a patched page over
   an un-migrated table 500s; (c) **rebuild assets** — `npm run build` when `resources/js/**`
   or `resources/css/**` changed (stale bundle → `$store.sidebar undefined` etc.);
   (d) **quality gate** — `composer format` / `analyse` / `test`. **Run the test suite** —
   it's the gap detector: applied stubs (views/components/routes) routinely depend on
   project-owned code **and imperative state** the merge skipped (model scopes/methods,
   route `auth` guards, a middleware registration in `bootstrap/app.php`, an edition
   predicate, **a composer package behind a menu item that §6 never `require`d, an
   unseeded permission, a runtime `.env` key**), so red tests **and a silently-hidden
   menu item** pinpoint the missing pieces (see §7d's symptom→cause table). Suggest a commit
   message but **do not commit unless asked**. Defer CLAUDE.md / convention drift to **`project-sync`**.

---

## `/kickoff check` — dry-run

Runs steps 1–4 and prints the preview report, then stops. Writes nothing to the project.
Use it to answer "what would a patch change?" and to review drift before committing to a
patch. The imperative (packages/tags) section is reported as a summary count (it is not a
file copy — see step 6).

## `/kickoff patch` — apply

Runs the full pipeline (steps 1–7). It is the **only** command that mutates files, and
only after per-category approval. It always merges on temp copies, so an aborted or
declined patch leaves the project pristine.

## `/kickoff status` — quick summary

Runs step 1 (detect + resolve baseline, using a stamp if present) and step 2's
latest-tag resolution only, then prints: Kickoff project? · detected/confirmed baseline ·
latest available · N versions behind. No diff, no changes. Cheap orientation before a
`check` or `patch`.

---

## Safety model (hard invariants)

These are non-negotiable; they hold across every command:

- **Never touch `.env`.** Only ever merge `.env.example`, surfacing **new keys** for the
  user to copy into `.env` themselves.
- **Never blanket-overwrite `app/`.** Application code is project-owned by default
  (`[skipped: project-owned]`); only patch a path that maps to a tracked Kickoff stub,
  and only with explicit opt-in.
- **Preview before apply, approve per category.** No category is applied without an
  explicit yes; conflicts always require individual resolution.
- **Work on copies.** Merges land in temp files; the project tree changes only at apply.
- **Always dry-runnable.** `/kickoff check` proves the plan without writing anything.
- **Bias the baseline low** when version detection is ambiguous — a too-low base is safe
  (extra already-present hunks); a too-high base silently skips needed changes.
- **Warn on a dirty tree** (don't block) so the patch lands on a reviewable diff.

## Scope boundaries (don't duplicate sibling skills)

This skill patches the **code/stack** of a single Kickoff project. It deliberately does
**not** re-implement adjacent skills — defer to them instead:

| Concern | Defer to |
|---|---|
| CLAUDE.md convention merge / multi-project sync | **`project-sync`** |
| Kickoff conventions enforcement + scaffolding new code | **`project-laravel`** |
| CI/CD pipeline + Docker generation | **`ci-cd-pipeline`** |
| PHPStan / Pint / Rector config tuning | **`code-quality`** |

Detection markers are shared with `project-sync` — `kickoff-patch` reuses that logic
(see `references/detect-and-version.md` §1) rather than copying the marker table.

## Reusability

Nothing here is project-specific. `--source` defaults to the **required local install** of
`cleaniquecoders/kickoff` (the public remote is only a base-tag fallback, never the default
source of latest), so `/kickoff patch` works on **any** Laravel project scaffolded from
Kickoff — point it at the project and it detects, diffs, and patches.

---

## Reference Files

| File | Read When |
|------|-----------|
| `references/detect-and-version.md` | Confirming a project is Kickoff-based, inferring + confirming the baseline version, and stamping the version marker after a patch (steps 1, 7). |
| `references/source-of-truth.md` | The required local install as `LATEST` (precondition), acquiring the `BASE` tree from a git tag (else 2-way), the `stubs/` → project mapping, and extracting the imperative baseline from `StartCommand.php` (steps 2, 6). |
| `references/patch-map.md` | Classifying what may be touched — the category map and the 3-tier VERBATIM-SAFE / MODIFIED-MANAGED / PROJECT-OWNED safety table (step 3). |
| `references/merge-and-apply.md` | Running the 3-way merge, building the category-grouped preview, the approval loop, applying, re-applying imperative deltas, stamping, and verifying (steps 3–7). |
