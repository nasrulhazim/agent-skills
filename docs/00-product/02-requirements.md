# Requirements — Claude Toolkit

> **Status:** Active
> **Version:** 0.2

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

- [x] `install.sh` copies skills, agents and commands
  to `~/.claude/{skills,agents,commands}`
- [x] Remote install via `curl | bash` works
- [x] Existing items are overwritten on reinstall
- [x] `--dry-run` previews; `--only <name>` installs
  a single item

---

### [FR-04] Bilingual Trigger Phrases

**Priority:** Should
**User Story:** As a bilingual (BM/EN) developer, I want
trigger phrases in Bahasa Malaysia so that I can
invoke skills naturally in my preferred language.

**Acceptance Criteria:**

- [ ] Each SKILL.md description includes BM trigger
  phrases
- [ ] BM triggers work alongside English triggers

---

### [FR-05] Agent Definition Format

**Priority:** Must
**User Story:** As a toolkit author, I want a
standardised agent format so that Claude Code can
auto-delegate to role agents consistently.

**Acceptance Criteria:**

- [x] Agent files use YAML frontmatter with `name`,
  `color`, `description`, optional `tools`
- [x] Descriptions are third-person and
  trigger-oriented ("Use this agent when...")
- [x] Agents load skills instead of duplicating
  their content
- [x] Read-only roles restrict `tools` to
  `Read, Grep, Glob, Bash, Skill`

---

### [FR-06] Command Definition Format

**Priority:** Must
**User Story:** As a toolkit author, I want commands
as single markdown files so that workflows are
invokable as `/command-name`.

**Acceptance Criteria:**

- [x] Commands live in `commands/` as `.md` files
- [x] Subdirectories namespace commands
  (`commands/a/b.md` → `/a/b`)

---

### [FR-07] Plugin Marketplace Distribution

**Priority:** Should
**User Story:** As a user on another machine, I want
to install the toolkit via the Claude Code plugin
marketplace without cloning the repo.

**Acceptance Criteria:**

- [x] `.claude-plugin/marketplace.json` +
  `plugin.json` are valid
- [x] `/plugin marketplace add nasrulhazim/claude`
  registers the marketplace
- [x] `/plugin install claude-toolkit@claude` loads
  skills, agents and commands

---

## Non-Functional Requirements

| ID | Category | Requirement | Priority |
| --- | --- | --- | --- |
| NFR-01 | Compat | Claude Code CLI support | Must |
| NFR-02 | Portable | macOS and Linux install | Must |
| NFR-03 | Maintain | Self-contained skill dirs | Must |
| NFR-04 | Docs | SKILL.md and references/ | Should |
| NFR-05 | Compat | install.sh runs on Bash 3.2 (macOS default) | Must |

## Dependencies

| Dependency | Type | Version | Notes |
| --- | --- | --- | --- |
| Claude Code | Platform | Latest | Skill execution |
| Bash | Runtime | 3.2+ | For install.sh (macOS default) |

## Assumptions

- Users have Claude Code installed and configured
- Users have `~/.claude/` directory available for
  skill storage
- Content is read-only at runtime (no state
  persistence)
