# Deprecation Policy — Agent Skills

## Process

When a skill is deprecated:

1. **Announce** — Add deprecation notice to the
   skill's SKILL.md
2. **Timeline** — Provide at least 30 days notice
   before removal
3. **Migrate** — Document the replacement skill or
   workaround
4. **Remove** — Delete the skill directory and
   update README

## Deprecation Notice Template

Add this block to the top of a deprecated SKILL.md:

```markdown
> **DEPRECATED:** This skill is deprecated
> as of [date] and will be removed in [version].
> Use [replacement-skill] instead.
> See [migration guide link].
```

## Timeline Template

| Date | Event |
| --- | --- |
| [Date] | Deprecation announced |
| [Date] | Last update (bug fixes only) |
| [Date] | Skill removed from collection |

## Version Support

| Version | Status |
| --- | --- |
| Latest | Active development |
| Previous minor | Bug fixes only |
| Older | No support |

## Migration Guidance

When deprecating a skill, always provide:

- The replacement skill name
- Key differences between old and new
- Step-by-step migration instructions
