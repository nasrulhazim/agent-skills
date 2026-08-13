---
name: project-conventions
metadata:
  compatible_agents: [claude-code]
  tags: [claude-md, preferences, self-update, living-document, conventions]
description: >
  Living document practice — Claude automatically updates CLAUDE.md whenever a user
  corrects a mistake, expresses a preference, a better pattern is discovered, or a gotcha
  is found during implementation. Use this skill whenever Claude is working inside a project
  that has a CLAUDE.md file, or whenever the user says things like "jangan guna X, pakai Y",
  "aku tak suka pattern ni", "ingat ni untuk lepas ni", "update CLAUDE.md", "catat ni",
  "tambah dalam CLAUDE.md", or any correction/preference that should persist across future
  sessions. Also triggers when Claude discovers an edge case or architectural insight worth
  preserving. The goal: CLAUDE.md should always reflect the current, correct, agreed-upon
  way of working — never let a correction live only in conversation history.
---

# Self-Update Practice

`CLAUDE.md` is a **living document**. Claude must update it immediately whenever something
worth remembering is discovered — corrections, preferences, patterns, or gotchas.

The rule: **A slightly redundant note is better than repeating a mistake.**

---

## When to Update CLAUDE.md

Update immediately when any of these occur:

| Trigger | Example |
|---|---|
| User corrects a mistake | "jangan guna MySQL, kita pakai PostgreSQL" |
| User expresses a preference | "aku tak suka pattern ni, guna cara lain" |
| Better pattern discovered during implementation | Realising a cleaner approach mid-task |
| Gotcha or edge case found | A library behaves unexpectedly, an assumption was wrong |
| Architectural decision made | "kita guna UUIDs, bukan auto-increment" |
| Naming or style preference | "method names in camelCase, not snake_case" |
| Tool or stack choice confirmed | "pakai Pest, bukan PHPUnit" |
| Testing preference confirmed | "pakai Pest describe blocks", "PHPStan level 8" |
| Deployment preference confirmed | "deploy via GitHub Actions", "Docker for staging" |

Do **not** wait until the end of the session. Update `CLAUDE.md` **as soon as** the
correction or preference is identified — then continue with the task.

---

## Update Procedure

When a trigger is detected:

1. **Apply the fix** to the current task first
2. **Read the current `CLAUDE.md`** to find the right section
3. **Insert the update** in the appropriate section:
   - Preference / style → `## Preferences` or relevant stack section
   - DO/DON'T → `## DO / DON'T`
   - Architectural → update the relevant architecture section
   - Gotcha / edge case → add under the relevant section with `> **Gotcha:**` callout
4. **Do not announce every update** unless the user asks — just do it silently and continue

---

## Format Rules

### Gotcha Format

```markdown
> **Gotcha:** PostgreSQL `uuid-ossp` extension must be enabled before using
> `DB::raw('uuid_generate_v4()')`. Prefer letting Laravel handle UUID generation
> from PHP side via `InteractsWithUuid` trait instead.
```

Use `> **Gotcha:**` for any surprise, trap, or non-obvious behaviour that could cause
a future mistake if forgotten.

### DO / DON'T Format

```markdown
## DO / DON'T

- ✅ DO use `InteractsWithUuid` trait for UUID generation
- ❌ DON'T use `DB::raw('uuid_generate_v4()')` directly
- ✅ DO write tests with Pest
- ❌ DON'T use PHPUnit syntax in this project
```

### Preference Format

State preferences as facts, not opinions:

```markdown
## Preferences

- Database: PostgreSQL (not MySQL)
- ORM: Eloquent — no raw query builders unless necessary
- Tests: Pest — BDD-style `it()` and `describe()` blocks
- Migrations: always reversible — implement `down()` properly
```

---

## Testing Preferences to Track

When the user confirms testing preferences, record under `## Testing` in CLAUDE.md:

```markdown
## Testing

- Framework: Pest (BDD-style `it()` and `describe()` blocks)
- PHPStan Level: 8 (with Larastan)
- Pint Preset: laravel
- Rector: PHP 8.2 set enabled
- Coverage: minimum 80% on critical paths
- Arch Tests: strict types enforced, no `dd()` in src/
```

Common triggers:
- User sets PHPStan level → record level and any baseline file
- User chooses Pest patterns → record `describe/it` vs flat `test()` preference
- User configures Pint → record preset choice and any custom rules
- User sets up Rector → record which rule sets are active

---

## Deployment Preferences to Track

When deployment patterns are confirmed, record under `## Deployment` in CLAUDE.md:

```markdown
## Deployment

- CI: GitHub Actions (Pint → PHPStan → Rector → Pest)
- CD: SSH deploy to VPS via `/bin/deploy.sh`
- Docker: Laravel Sail for dev, custom Dockerfile for prod
- Staging: auto-deploy on push to `staging` branch
- Production: manual trigger after staging verification
- Backup: daily via `/bin/backup.sh`
```

Common triggers:
- User configures CI/CD pipeline → record workflow structure
- User sets up Docker → record dev vs prod distinction
- User confirms deployment target → record server/platform details
- User establishes branching strategy → record branch → environment mapping

---

## What NOT to Record

| Skip | Reason |
|---|---|
| One-off task decisions | Don't affect future work |
| Things in Laravel / package docs | Already discoverable |
| Obvious conventions | Noise without value |
| Temporary workarounds | Mark clearly as temporary if recorded |

---

## CLAUDE.md Structure

If no `CLAUDE.md` exists in the project, create one using this structure.
Read `references/claude-md-template.md` for the full starter template.

Minimum sections for any project:

```markdown
# CLAUDE.md — [Project Name]

## Project Overview
## Stack
## Architecture
## DO / DON'T
## Preferences
## Gotchas
## Changelog (of this file)
```

---

## Where Lessons and Plans Live

**Lessons go in `CLAUDE.md`. Plans and tracking go on GitHub. Neither goes in a local file.**

| Thing | Home | Why not a local file |
|---|---|---|
| A correction, preference, gotcha | `CLAUDE.md` | It is read at the start of every session in every clone; `tasks/lessons.md` is read by nobody |
| A plan with checkable items | A GitHub issue (`- [ ]` list in the body, `gh issue edit` to tick) | Visible to the team, survives a fresh clone, links to the commits |
| The result of a piece of work | A comment on that issue, then close it | Keeps the decision next to the change |

Do **not** create a `tasks/` directory, a `todo.md`, or a `lessons.md` inside a repository. If
you find one, migrate its live content — gotchas into `CLAUDE.md`, outstanding items into
issues — and delete it.

The exception is a **multi-repo workspace** that keeps design and planning documents of its
own (see below): long-form plan documents belong there, one file per feature. Even then, the
*tracking* is still GitHub issues; the document holds the reasoning, not the checkboxes of
record.

---

## Multi-Repo Workspaces: Two CLAUDE.md Files, One Authority

When a product folder is a thin wrapper around one or more application repositories, put a
**short** `CLAUDE.md` at the workspace root whose main job is to point at the real one:

```
product/
├── CLAUDE.md               # thin: layout, where to cd, pointer to the app's CLAUDE.md
├── documentation/          # product-level docs, by context
│   ├── 01-requirements/
│   ├── 02-design/
│   └── 03-planning/        # MVP scope + tasks/ (one plan document per feature)
└── platform/
    └── product-app/        # the real application — its own git repo
        └── CLAUDE.md       # authoritative: conventions, architecture, gotchas
```

The workspace file states four things and stops:

1. **This directory is not the project** — and whether it is a git repository at all.
2. **Where the real work happens**, with the `cd` required before any composer/artisan command.
3. **A pointer**: "`platform/product-app/CLAUDE.md` is the authoritative guide. Read it before
   making changes. Do not duplicate or contradict it here — when app conventions change, update
   *that* file."
4. A handful of **non-obvious constraints** worth knowing before opening anything, each one a
   single line that links onward rather than explaining in full.

> **Gotcha:** The failure mode is a workspace file that grows into a second, competing
> conventions guide. Two files that both claim authority drift within weeks, and the reader has
> no way to tell which is current. Keep the workspace file under a screen; if a rule is about
> code, it belongs in the app's file.

---

## Housekeeping the Repository Owes Claude

- **`.gitignore` must exclude `/.claude/worktrees/`.** Agent worktrees are transient nested
  checkouts; left untracked they accumulate silently. One working project was found carrying
  over 100,000 files there.
- **`.claude/settings.local.json`** is where an allowlist converges over time. Committing it
  saves every future session the same permission prompts.
- **Skill-name collisions are silent.** If a tool in the project writes into `.claude/skills/`
  — Laravel Boost's `boost:install --skills` does, with the names `pest-testing`,
  `laravel-best-practices`, `livewire-development`, `fluxui-development`,
  `tailwindcss-development` and `configuring-horizon` — then a skill of your own sharing a name
  is overwritten with nothing to say so. Prefix yours (`kickoff-pest-testing`) rather than
  relying on copy order.

---

## Initialising CLAUDE.md for a New Project

When the user says "buat CLAUDE.md" or starts a new project without one:

1. Ask 3 questions max — don't over-interview:
   - What is this project? (name + one sentence)
   - Stack? (language, framework, DB, key packages)
   - Any immediate preferences or constraints to record?

2. Generate the file using `references/claude-md-template.md`

3. Tell the user: "CLAUDE.md dah buat. Aku akan update automatically bila ada
   corrections, preferences, atau gotchas sepanjang kita kerja."

---

## Reference Files

| File | Read When |
|---|---|
| `references/claude-md-template.md` | Creating a new CLAUDE.md from scratch |
