# Testing

## Manual Validation

Currently, skill validation is manual. Verify each skill against:

### Frontmatter Checks

- [ ] `name` field matches directory name
- [ ] `metadata.compatible_agents` is present
- [ ] `metadata.tags` is present and non-empty
- [ ] `description` uses `>` folded scalar

### Structure Checks

- [ ] `SKILL.md` exists in skill directory
- [ ] `references/` directory exists
- [ ] All referenced files in the Reference Files table exist
- [ ] Reference files have no YAML frontmatter

### Content Checks

- [ ] Trigger phrases present in English
- [ ] Trigger phrases present in Bahasa Malaysia
- [ ] Command format follows `/command subcommand` pattern
- [ ] No hardcoded project-specific values

## Running Install Test

```bash
# Test the install script
bash install.sh

# Verify skills are in place
ls ~/.claude/skills/
```

## Future: Automated Validation

Planned for v1.1 — a validation script and GitHub Actions CI that checks all skills
against the conventions defined in CLAUDE.md.
