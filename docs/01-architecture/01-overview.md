# Architecture Overview

## Purpose

Claude Toolkit provides reusable Claude Code content —
skills, agents and commands — for Laravel developers.
Skills carry knowledge, agents carry roles, commands
carry workflows; agents load skills as their playbook.

## Design Principles

- **Self-contained** — each skill directory has
  everything it needs
- **Prompt-based** — content is markdown instructions,
  not executable code
- **Convention over configuration** — consistent
  structure across all content types
- **Bilingual** — trigger phrases in English and
  Bahasa Malaysia
- **Thin agents** — role personas (25–75 lines) that
  load skills; knowledge is never duplicated into agents

## Project Structure

```text
claude/
├── CLAUDE.md               ← Project conventions
├── README.md               ← Content directory
├── install.sh              ← Global installer (skills, agents, commands)
├── .claude-plugin/         ← Plugin + marketplace manifests
├── docs/                   ← SDLC documentation
├── skills/
│   └── [skill-name]/
│       ├── SKILL.md        ← Frontmatter + instructions
│       └── references/     ← Templates, patterns
├── agents/
│   └── [agent-name].md     ← Role persona (frontmatter + instructions)
└── commands/
    └── [command-name].md   ← Slash command definition
```

## Skill Anatomy

Each skill consists of:

1. **SKILL.md** — YAML frontmatter (`name`,
   `metadata`, `description`) followed by markdown
   instructions
2. **references/** — Supporting files (templates,
   patterns, checklists) as pure markdown

## Agent Anatomy

Each agent is a single markdown file with YAML
frontmatter (`name`, `color`, `description`, optional
`tools` allowlist) and a short body: role persona,
which skills to load, how to work, and rules.
Read-only roles (code-reviewer, fleet-auditor,
security-analyst) restrict `tools` to
`Read, Grep, Glob, Bash, Skill`.

## Command Anatomy

Each command is a single markdown file invoked as
`/command-name`. Frontmatter is optional.
Subdirectories namespace commands
(`commands/data/analyze.md` → `/data/analyze`).

## Categories

| Category | Skills | Purpose |
| --- | --- | --- |
| Dev & Quality | pest-testing, code-quality | Code review |
| Project Mgmt | project-docs, project-roadmap | Planning |
| Deploy & Ops | ci-cd-pipeline, git-workflow | Release |
| Research | repo-research, dev-summary | Analysis |
| Business | sales-planner, svg-logo | Non-code |

## Agent Roster

16 role agents spanning the full SDLC — see
[Using Agents](../02-development/05-using-agents.md)
for the phase-by-phase coverage map. Color clusters:
red=security, orange=quality, green=build/ship,
pink=planning/docs/business, blue=design,
cyan=audit/research, yellow=support, purple=training.
