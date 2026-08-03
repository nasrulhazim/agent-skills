# CLAUDE.md — Claude Toolkit

## Project Overview

Nasrul Hazim's complete Claude Code toolkit: skills, agents and commands in one repo (`nasrulhazim/claude`). Skills are self-contained directories under `skills/` with a `SKILL.md` and optional `references/` folder; agents are single-file role personas under `agents/`; commands are single-file slash commands under `commands/`.

## Stack

- Format: Markdown with YAML frontmatter (SKILL.md, agents; frontmatter optional for commands)
- Target: Claude Code (installer + plugin marketplace) / Laravel Cloud Skills
- Baseline: Kickoff.my stack (Livewire 4, Pest, PHPStan, Rector, Pint, GitHub Actions)

## Architecture

```
.claude-plugin/               # plugin.json + marketplace.json (single plugin, source "./")
skills/
├── [skill-name]/
│   ├── SKILL.md              # YAML frontmatter + markdown instructions
│   └── references/           # Templates, patterns, examples (pure markdown, no frontmatter)
agents/[agent-name].md        # Role personas that load skills as their playbook
commands/[command-name].md    # Slash commands (subdirs allowed for namespacing)
install.sh                    # Installs all three types to ~/.claude/{skills,agents,commands}
generate-manifest.sh          # Regenerates manifest.txt (type-prefixed entries)
migrations.txt                # Rename/removal mappings (legacy skill format + type-prefixed)
```

## DO / DON'T

- ✅ DO include `metadata:` with `compatible_agents` and `tags` in every SKILL.md frontmatter
- ✅ DO include trigger phrases in both English and Bahasa Malaysia
- ✅ DO use `description: >` (multiline YAML) for the skill description field
- ✅ DO add a `## Reference Files` table at the end of every SKILL.md
- ✅ DO keep reference files as pure markdown (no YAML frontmatter)
- ✅ DO keep agents thin (25–75 lines): role persona + "load these skills" + rules — knowledge lives in skills
- ✅ DO write agent descriptions in third person, trigger-oriented ("Use this agent when/for …")
- ❌ DON'T use frontmatter in reference files — only in SKILL.md
- ❌ DON'T hardcode project-specific values in skills — keep them generic
- ❌ DON'T duplicate content between SKILL.md and reference files — SKILL.md is the instruction, references are the data
- ❌ DON'T duplicate skill content inside agents — the agent loads the skill instead

## Preferences

- Skill frontmatter field order: `name`, `metadata` (with `compatible_agents`, `tags`), `description`
- Agent frontmatter field order: `name`, `color`, `description`, `tools` (optional allowlist; omit for all tools)
- Agent colors are semantic: red=security, orange=quality/review, green=build/ship, pink=docs/business, blue=design, cyan=audit/research, yellow=support
- Read-only roles (reviewers, auditors, security) get a restricted `tools:` allowlist (`Read, Grep, Glob, Bash, Skill`)
- Reference file naming: kebab-case, descriptive (e.g., `pest-patterns.md`, `api-security-checklist.md`)
- Naming: kebab-case; skills action-oriented (`pest-testing`, not `pest`); agents role-titled (`code-reviewer`, `qa-engineer`)
- Skill grouping: related skills share a prefix (e.g., all project management skills use `project-` prefix)
- Renames: always add old→new mapping to `migrations.txt` (skills legacy `old:new`; agents/commands `type/old:type/new`, no `.md`)
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

- ✅ DO run `bash generate-manifest.sh` and update `README.md` when adding, renaming, or removing any skill, agent, or command
- ✅ DO update `migrations.txt` when renaming or removing anything
- ✅ DO bump the version in `install.sh`, `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` together when tagging a release
- ❌ DON'T rename anything without a migration entry — users will have stale copies in `~/.claude/`

## Gotchas

> **Gotcha:** The `description` field in frontmatter must use `>` for multiline YAML folded scalar.
> Using `|` will preserve newlines which breaks the single-paragraph format expected by the platform.

> **Gotcha:** Reference files are read relative to the skill directory, not the project root.
> Always use paths like `references/template.md` in SKILL.md, not absolute or root-relative paths.

> **Gotcha:** When renaming a skill directory, you must update 4 places: the directory name,
> `name:` in SKILL.md frontmatter, `manifest.txt` (regenerate), and `migrations.txt`. Missing any one
> will cause install failures or stale skill copies on user machines. Renaming an agent or command
> similarly needs the file, its `name:` frontmatter (agents), manifest regeneration, and a
> type-prefixed migration entry.

> **Gotcha:** `manifest.txt` entries are type-prefixed (`skills/…`, `agents/…`, `commands/…`) since v2.0.0.
> `install.sh` older than 2.0.0 cannot parse this manifest — remote users always fetch the latest
> installer via curl, but stale local clones must pull first.

> **Gotcha:** `install.sh` must stay Bash 3.2 compatible (macOS default). No `${var^}`, no
> associative arrays, no `mapfile`.
