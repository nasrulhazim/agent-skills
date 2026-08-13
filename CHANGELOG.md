# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com) and this project adheres to [Semantic Versioning](https://semver.org).

## [2.3.0] - 2026-08-13

### Added

- `project-status` skill — TLDR + table status report that cross-checks a project's planning
  tree against live GitHub issues **and the code**, on the rule that a planning document's
  claim is never status until the code confirms it
- `deploy-app` skill — deploy a Kickoff app via `bin/deploy` over SSH: verification checklist,
  a recovery path per failure mode, and the production traps (DB-backed settings overriding
  `.env`, host SMTP port blocks, unattended prompts exiting 0, `APP_KEY` rotation)
- `docs/02-development/06-laravel-boost-coexistence.md` — which skill names Laravel Boost owns
  and why a collision between the two is silent

### Changed

- **`pest-testing` renamed to `kickoff-pest-testing`** (migration entry included). Laravel
  Boost's `boost:install --skills` writes its own `pest-testing` into the same directory and
  had already overwritten the toolkit's copy in a live project, undetected. The two are
  complementary — Boost covers Pest syntax; this covers scaffolding, the arch-test baseline
  and suite performance
- `kickoff-pest-testing` — new sections on what a green suite does not prove (Alpine, Flux
  custom elements, deferred `wire:model`) and on suite performance (seeder placement in
  `$seeder` rather than `beforeEach`, `XDEBUG_MODE` pinning, Test Impact Analysis and pcov)
- `livewire-flux` — client-side gotchas that ship green: Flux renders `<ui-checkbox>` not a
  native input, `x-cloak` is inert without its CSS rule, a double quote anywhere in an Alpine
  attribute un-Alpines the subtree, and `description:trailing` for field help text
- `project-laravel` — `access-control.md` gains a tenancy section (a policy is not a scope;
  scoped finders; per-tenant uniqueness; pinning the guard on non-`web` surfaces);
  `database-conventions.md` gains engine-portability rules (MySQL leading-column FK indexes,
  non-transactional DDL, unreliable `hasIndex()`, the migrate/rollback/migrate round trip);
  `model-conventions.md` gains silent failure modes (null relations, Traitify's `user_id`
  auto-fill, seeder `unguarded()`, factory visibility branches)
- `code-quality` — Larastan blind spots: docblock placement above PHP attributes, casts
  declared via `casts()` being invisible, and baseline churn from generic relation annotations
- `project-conventions` — lessons belong in `CLAUDE.md` and tracking on GitHub, never in a
  local `tasks/todo.md` or `lessons.md`; the multi-repo workspace two-`CLAUDE.md` pattern; and
  the repository housekeeping Claude depends on (`/.claude/worktrees/` in `.gitignore`)
- `kickoff-patch` — records the Kickoff composer-script change (TIA no longer the default
  `test`), the new `build/php-ini` test tooling, `PASSKEYS_USER_HANDLE_SECRET` and the
  `/.claude/worktrees/` ignore rule; restores `laravel/doctor` in the package baseline

## [2.2.0] - 2026-08-03

### Added

- 4 agents completing the role coverage: `database-engineer` (DBA — schema, migrations, indexing, backups, tenant isolation), `project-manager` (roadmaps, milestones, sprints, risk/scope), `api-engineer` (REST design & build), `penetration-tester` (authorized offensive testing — local/staging only, scoped, minimal-impact) — roster is now 20

### Changed

- **Generalised the whole toolkit** — removed personal names, private product names (product suite/ticketing specifics) and machine-specific paths from all agents, skills, docs and manifests so the toolkit reads as a general-purpose Kickoff-based Laravel toolkit. The Kickoff baseline is kept (it is the toolkit's core value)
- Plugin/marketplace author set to CleaniqueCoders; personal email removed
- Docs (product spec, roadmap, using-agents coverage map) updated for the 20-agent roster

## [2.1.0] - 2026-08-03

### Added

- 3 agents completing full SDLC coverage: `software-architect` (design/ADRs), `laravel-developer` (implementation), `performance-engineer` (measure-first optimisation) — roster is now 16
- `docs/02-development/05-using-agents.md` — SDLC coverage map, delegation guide, typical agent chains
- `docs/04-api/02-agent-format.md` and `03-command-format.md` — format contracts for agents and commands

### Changed

- `qa-engineer` description now explicitly covers test strategy / QA planning alongside test writing (QC)
- Docs refreshed for the toolkit era: product spec 0.2, requirements 0.2 (FR-05/06/07 for agent/command/plugin formats, Bash 3.2 requirement), roadmap (2.0 shipped, 2.x planned), architecture overview, FAQ

## [2.0.0] - 2026-08-03

### Changed

- **BREAKING**: Repository renamed from `nasrulhazim/agent-skills` to `nasrulhazim/claude` — old URLs redirect, but update your clones: `git remote set-url origin https://github.com/nasrulhazim/claude.git`
- **BREAKING**: `manifest.txt` entries are now type-prefixed (`skills/…`, `agents/…`, `commands/…`); `install.sh` older than 2.0.0 cannot parse the new manifest (remote installs always fetch the latest installer — stale local clones must `git pull` first)
- `install.sh` rewritten as the Claude Toolkit Installer v2.0.0: installs skills, agents and commands to `~/.claude/{skills,agents,commands}`
- `migrations.txt` format extended with type-prefixed entries (`agents/old:agents/new`); legacy `old:new` skill entries still supported
- `generate-manifest.sh` now scans `skills/`, `agents/` and `commands/`

### Added

- `agents/` — 13 role agents: brand-designer, business-analyst, code-reviewer, courseware-developer, devops-engineer, fleet-auditor, package-maintainer, qa-engineer, security-analyst, support-analyst, tech-writer, ui-designer, upgrade-specialist
- `commands/` — 10 slash commands: analyze-repo, design-logo, docs, sales, sales-create-config, sales-get-marketing, sales-get-pricing, sales-get-quotation, upgrade-laravel, upgrade-livewire
- `.claude-plugin/` plugin + marketplace manifests — install via `/plugin marketplace add nasrulhazim/claude` then `/plugin install claude-toolkit@claude`
- `install.sh` flags: `--dry-run` and `--only <name>`
- This CHANGELOG

## [1.19.0] and earlier

See [GitHub releases](https://github.com/nasrulhazim/claude/releases) for the `agent-skills`-era history (1.0.0 – 1.19.0, skills only).
