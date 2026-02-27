# Requirements — Agent Skills

> **Status:** Draft
> **Version:** 0.1

## Functional Requirements

### [FR-01] Skill Definition Format

**Priority:** Must
**User Story:** As a skill author, I want a
standardised format so that Claude Code can parse
and execute skills consistently.

**Acceptance Criteria:**

- [ ] SKILL.md uses YAML frontmatter with `name`,
  `metadata`, `description`
- [ ] `metadata` includes `compatible_agents` and
  `tags`
- [ ] `description` uses `>` folded scalar for
  multiline

---

### [FR-02] Reference File Support

**Priority:** Must
**User Story:** As a skill author, I want to include
reference files so that skills can access templates,
patterns, and examples.

**Acceptance Criteria:**

- [ ] Reference files stored in `references/`
  subdirectory
- [ ] Reference files are pure markdown (no
  frontmatter)
- [ ] SKILL.md includes a Reference Files table

---

### [FR-03] Global Installation

**Priority:** Must
**User Story:** As a developer, I want to install all
skills with one command so that I can start using
them immediately.

**Acceptance Criteria:**

- [ ] `install.sh` copies skills to
  `~/.claude/skills/`
- [ ] Remote install via `curl | bash` works
- [ ] Existing skills are overwritten on reinstall

---

### [FR-04] Bilingual Trigger Phrases

**Priority:** Should
**User Story:** As a Malaysian developer, I want
trigger phrases in Bahasa Malaysia so that I can
invoke skills naturally in my preferred language.

**Acceptance Criteria:**

- [ ] Each SKILL.md description includes BM trigger
  phrases
- [ ] BM triggers work alongside English triggers

---

## Non-Functional Requirements

| ID | Category | Requirement | Priority |
| --- | --- | --- | --- |
| NFR-01 | Compat | Claude Code CLI support | Must |
| NFR-02 | Portable | macOS and Linux install | Must |
| NFR-03 | Maintain | Self-contained skill dirs | Must |
| NFR-04 | Docs | SKILL.md and references/ | Should |

## Dependencies

| Dependency | Type | Version | Notes |
| --- | --- | --- | --- |
| Claude Code | Platform | Latest | Skill execution |
| Bash | Runtime | 4.0+ | For install.sh |

## Assumptions

- Users have Claude Code installed and configured
- Users have `~/.claude/` directory available for
  skill storage
- Skills are read-only at runtime (no state
  persistence)
