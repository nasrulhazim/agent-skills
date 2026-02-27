# Skill Authoring Patterns

## Frontmatter Convention

Every SKILL.md must use this field order:

```yaml
---
name: skill-name
metadata:
  compatible_agents: [claude-code]
  tags: [tag1, tag2]
description: >
  Multiline description using folded scalar.
  Include trigger phrases in English and BM.
---
```

**Gotcha:** Use `>` (folded scalar), not `|`
(literal scalar). The platform expects a single
paragraph.

## Reference File Patterns

- **Naming:** kebab-case, descriptive
  (e.g., `pest-patterns.md`)
- **Format:** Pure markdown, no YAML frontmatter
- **Paths:** Always relative to skill directory
  (e.g., `references/template.md`)

## Command Format

Skills that expose commands use the
`/command subcommand` pattern:

```text
/test generate
/quality check
/docs scaffold
```

## Reference File Table

Every SKILL.md ends with a Reference Files table:

```markdown
## Reference Files

| File | Read When |
| --- | --- |
| `references/patterns.md` | Generating code |
| `references/template.md` | Scaffolding files |
```

## Content Separation

- SKILL.md contains **instructions** — what to do
  and when
- Reference files contain **data** — templates,
  patterns, examples
- Never duplicate content between SKILL.md and
  reference files
