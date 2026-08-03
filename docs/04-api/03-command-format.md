# Command Format Reference

## Command File Schema

Each command is a single markdown file at
`commands/[command-name].md`, invoked in Claude Code
as `/command-name`.

### Frontmatter (YAML — optional)

```yaml
---
description: One-line purpose shown in /help
argument-hint: <path> [--flag]
allowed-tools: Bash(git:*), Read
---
```

All frontmatter fields are optional. Commands without
frontmatter are valid — the body alone defines the
workflow.

### Body

The markdown body is the instruction executed when the
command is invoked. Supported features:

- `$ARGUMENTS` / `$1`, `$2` — user-supplied arguments
- `!command` — inline bash executed before the prompt
  runs (requires matching `allowed-tools`)
- References to skills (`Load the X skill`) and agents
  (`Delegate to the Y agent`) to compose workflows

## Namespacing

Subdirectories namespace commands:

| File | Invocation |
| --- | --- |
| `commands/docs.md` | `/docs` |
| `commands/data/analyze.md` | `/data/analyze` |

## Install Contract

`install.sh` copies `commands/[path].md` to
`~/.claude/commands/[path].md`, preserving subpaths.
Manifest entries: `commands/[path].md`. Migration
entries: `commands/old-name:commands/new-name`
(no `.md`).
