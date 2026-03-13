# CLAUDE.md — Agent Skills

## Project Overview

A collection of Claude Code skills for the Laravel Cloud Skills ecosystem. Each skill is a self-contained directory under `skills/` with a `SKILL.md` and optional `references/` folder.

## Stack

- Format: Markdown (SKILL.md with YAML frontmatter)
- Target: Claude Code slash commands / Laravel Cloud Skills
- Baseline: Kickoff.my stack (Livewire 4, Pest, PHPStan, Rector, Pint, GitHub Actions)

## Architecture

```
skills/
├── [skill-name]/
│   ├── SKILL.md              # YAML frontmatter + markdown instructions
│   └── references/           # Templates, patterns, examples (pure markdown, no frontmatter)
```

## DO / DON'T

- ✅ DO include `metadata:` with `compatible_agents` and `tags` in every SKILL.md frontmatter
- ✅ DO include trigger phrases in both English and Bahasa Malaysia
- ✅ DO use `description: >` (multiline YAML) for the description field
- ✅ DO add a `## Reference Files` table at the end of every SKILL.md
- ✅ DO keep reference files as pure markdown (no YAML frontmatter)
- ❌ DON'T use frontmatter in reference files — only in SKILL.md
- ❌ DON'T hardcode project-specific values in skills — keep them generic
- ❌ DON'T duplicate content between SKILL.md and reference files — SKILL.md is the instruction, references are the data

## Preferences

- Frontmatter field order: `name`, `metadata` (with `compatible_agents`, `tags`), `description`
- Reference file naming: kebab-case, descriptive (e.g., `pest-patterns.md`, `api-security-checklist.md`)
- Skill naming: kebab-case, action-oriented where possible (e.g., `pest-testing`, not `pest`)
- Skill grouping: related skills share a prefix (e.g., all project management skills use `project-` prefix)
- Skill renames: always add old→new mapping to `migrations.txt` so the installer cleans up deprecated skills
- Command format in skills: `/command subcommand` (e.g., `/test generate`, `/quality check`)
- Git tags: bare semver without `v` prefix (`1.0.0`, not `v1.0.0`)
- Package development:
  - Laravel packages: scaffold from [spatie/package-skeleton-laravel](https://github.com/spatie/package-skeleton-laravel)
  - PHP packages: scaffold from [spatie/package-skeleton-php](https://github.com/spatie/package-skeleton-php)
  - Default vendor name: `cleaniquecoders` (always ask user to confirm)
  - Package names: kebab-case, all lowercase
  - PHP: `^8.4` minimum
  - Laravel: always latest version (`^12.0`)

## DO / DON'T (continued)

- ✅ DO update `migrations.txt` when renaming or removing a skill
- ✅ DO update `manifest.txt` and `README.md` when adding, renaming, or removing skills
- ❌ DON'T rename a skill without adding migration entry — users will have stale copies in `~/.claude/skills/`

## Gotchas

> **Gotcha:** The `description` field in frontmatter must use `>` for multiline YAML folded scalar.
> Using `|` will preserve newlines which breaks the single-paragraph format expected by the platform.

> **Gotcha:** Reference files are read relative to the skill directory, not the project root.
> Always use paths like `references/template.md` in SKILL.md, not absolute or root-relative paths.

> **Gotcha:** When renaming a skill directory, you must update 4 places: the directory name,
> `name:` in SKILL.md frontmatter, `manifest.txt`, and `migrations.txt`. Missing any one
> will cause install failures or stale skill copies on user machines.
