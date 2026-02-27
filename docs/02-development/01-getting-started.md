# Getting Started

## Prerequisites

- Git
- Bash 4.0+
- Claude Code CLI (for testing skills)

## Clone and Install

```bash
git clone \
  https://github.com/nasrulhazim/agent-skills.git
cd agent-skills
bash install.sh
```

Skills are copied to `~/.claude/skills/` and
available globally in Claude Code.

## Remote Install (All Skills)

```bash
curl -fsSL \
  https://raw.githubusercontent.com/nasrulhazim/agent-skills/main/install.sh \
  | bash
```

## Manual Install (Single Skill)

```bash
cp -r skills/pest-testing \
  /path/to/your-project/.claude/skills/
```

## Project Layout

```text
agent-skills/
├── CLAUDE.md           ← Project conventions
├── README.md           ← Public-facing directory
├── install.sh          ← Installer script
├── docs/               ← This documentation
└── skills/             ← All skill definitions
    └── [skill-name]/
        ├── SKILL.md
        └── references/
```

## Next Steps

- Read [CLAUDE.md](../../CLAUDE.md) for project
  conventions
- Read [Workflows](02-workflows.md) to learn how
  to create or modify skills
- Read [Architecture](../01-architecture/01-overview.md)
  for design decisions
