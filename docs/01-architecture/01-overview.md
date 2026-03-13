# Architecture Overview

## Purpose

Agent Skills provides a collection of reusable Claude
Code skill definitions for Laravel developers. Each
skill is a self-contained prompt with supporting
reference material.

## Design Principles

- **Self-contained** — each skill directory has
  everything it needs
- **Prompt-based** — skills are markdown instructions,
  not executable code
- **Convention over configuration** — consistent
  structure across all skills
- **Bilingual** — trigger phrases in English and
  Bahasa Malaysia

## Project Structure

```text
agent-skills/
├── CLAUDE.md               ← Project conventions
├── README.md               ← Skills directory
├── install.sh              ← Global installer
├── docs/                   ← SDLC documentation
└── skills/
    └── [skill-name]/
        ├── SKILL.md        ← Frontmatter + instructions
        └── references/     ← Templates, patterns
```

## Skill Anatomy

Each skill consists of:

1. **SKILL.md** — YAML frontmatter (`name`,
   `metadata`, `description`) followed by markdown
   instructions
2. **references/** — Supporting files (templates,
   patterns, checklists) as pure markdown

## Categories

| Category | Skills | Purpose |
| --- | --- | --- |
| Dev & Quality | pest-testing, code-quality | Code review |
| Project Mgmt | project-docs, project-roadmap | Planning |
| Deploy & Ops | ci-cd-pipeline, git-workflow | Release |
| Research | repo-research, dev-summary | Analysis |
| Business | sales-planner, svg-logo | Non-code |
