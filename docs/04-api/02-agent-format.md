# Agent Format Reference

## Agent File Schema

Each agent is a single markdown file at
`agents/[agent-name].md`.

### Frontmatter (YAML)

```yaml
---
name: agent-name            # Required. kebab-case, role-titled, match filename
color: orange               # Required. Semantic (see below)
description: Use this agent when...   # Required. Third person, trigger-oriented
tools: Read, Grep, Glob, Bash, Skill  # Optional. Allowlist; omit for all tools
---
```

### Field Rules

| Field | Required | Type | Notes |
| --- | --- | --- | --- |
| `name` | Yes | string | kebab-case role title (`code-reviewer`) |
| `color` | Yes | string | One of the semantic colors below |
| `description` | Yes | string | Third person; states when to delegate; lists concrete trigger scenarios |
| `tools` | No | csv | Restrict read-only roles; omit for full access |

### Semantic Colors

| Color | Role cluster |
| --- | --- |
| red | Security |
| orange | Quality — review, testing, performance |
| green | Build & ship — develop, deploy, packages, upgrades |
| pink | Planning — architecture, docs, business |
| blue | Design — UI/UX, brand |
| cyan | Audit & research |
| yellow | Support & operations |
| purple | Training |

## Body Conventions

Keep the body thin — 25–75 lines, single responsibility:

1. **Persona line** — who the agent is and its estate context
2. **`## How to work`** — numbered steps; the FIRST step
   names which skills to load (`Load the X skill first`)
3. **`## Rules`** — 3–5 bullets: constraints, output
   format, escalation behaviour

Knowledge lives in skills; agents only carry role,
process and judgement. Never copy skill content into
an agent body.

## Tool Allowlist Contract

Read-only roles (code-reviewer, fleet-auditor,
security-analyst) declare:

```yaml
tools: Read, Grep, Glob, Bash, Skill
```

and their body must state that Bash is for read-only
inspection. Roles that write code or files omit
`tools` entirely.

## Install Contract

`install.sh` copies `agents/[name].md` to
`~/.claude/agents/[name].md`. Manifest entries:
`agents/[name].md`. Migration entries:
`agents/old-name:agents/new-name` (no `.md`).
