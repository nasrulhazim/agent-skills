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
- Command format in skills: `/command subcommand` (e.g., `/test generate`, `/quality check`)

## Gotchas

> **Gotcha:** The `description` field in frontmatter must use `>` for multiline YAML folded scalar.
> Using `|` will preserve newlines which breaks the single-paragraph format expected by the platform.

> **Gotcha:** Reference files are read relative to the skill directory, not the project root.
> Always use paths like `references/template.md` in SKILL.md, not absolute or root-relative paths.
