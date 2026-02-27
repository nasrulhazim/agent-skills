# Workflows

## Creating a New Skill

1. Create the skill directory:

```bash
mkdir -p skills/my-skill/references
```

1. Create `skills/my-skill/SKILL.md` with frontmatter:

```yaml
---
name: my-skill
metadata:
  compatible_agents: [claude-code]
  tags: [relevant, tags]
description: >
  Description with trigger phrases in English and BM.
---
```

1. Add instructions below the frontmatter.

2. Add reference files to `references/` as pure markdown (no frontmatter).

3. Add a Reference Files table at the end of SKILL.md.

4. Update the root `README.md` skills directory table.

## Modifying an Existing Skill

1. Edit `skills/[name]/SKILL.md` for instruction changes.
2. Edit or add files in `skills/[name]/references/` for template/pattern changes.
3. Keep SKILL.md as the instruction layer, references as the data layer.

## Conventions Checklist

- [ ] Frontmatter field order: `name`, `metadata`, `description`
- [ ] `description` uses `>` folded scalar
- [ ] `metadata` has `compatible_agents` and `tags`
- [ ] Reference files use kebab-case naming
- [ ] Reference files have no YAML frontmatter
- [ ] SKILL.md ends with a Reference Files table
- [ ] Trigger phrases include both English and Bahasa Malaysia

## Git Workflow

Follow conventional commits:

```text
feat: add new skill for X
fix: correct frontmatter in pest-testing skill
docs: update README with new skill entry
```

See the [git-workflow skill](../../skills/git-workflow/) for full conventions.
