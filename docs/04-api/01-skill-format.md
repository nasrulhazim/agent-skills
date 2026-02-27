# Skill Format Reference

## SKILL.md Schema

### Frontmatter (YAML)

```yaml
---
name: skill-name           # Required. kebab-case
metadata:                   # Required
  compatible_agents: [claude-code]  # Required
  tags: [tag1, tag2, tag3]  # Required
description: >              # Required. Use >
  Single paragraph description.
  Include trigger phrases in English and BM.
---
```

### Field Rules

| Field | Required | Type | Notes |
| --- | --- | --- | --- |
| `name` | Yes | string | kebab-case, match dir |
| `metadata.compatible_agents` | Yes | list | `[claude-code]` |
| `metadata.tags` | Yes | list | At least one tag |
| `description` | Yes | string | Use `>` scalar |

### Body (Markdown)

The markdown body after frontmatter contains the
skill instructions. Structure varies per skill but
typically includes:

- Command reference table
- Step-by-step workflows
- Decision logic and conditionals
- Reference Files table (mandatory, at end of file)

## Reference File Contract

- **Location:** `references/` subdirectory within
  the skill
- **Format:** Pure markdown, no YAML frontmatter
- **Naming:** kebab-case
  (e.g., `pest-patterns.md`)
- **Paths:** Referenced relative to skill directory

## Install Contract

The `install.sh` script copies each
`skills/[name]/` directory to
`~/.claude/skills/[name]/`, preserving the
internal structure.
