# Roadmap — Claude Toolkit

> **Last Updated:** 2026-08-03
> **Maintained by:** Nasrul Hazim

## Phase Summary

| Phase | Version | Target | Status |
| --- | --- | --- | --- |
| Foundation | 1.0 | Q1 2026 | Done |
| Expansion | 1.x | Q2 2026 | Done |
| Toolkit | 2.0 | Q3 2026 | Done |
| Quality & Ecosystem | 2.x | Q4 2026 | Planned |

## Version Table

| Version | Milestone | Target | Status | Deliverables |
| --- | --- | --- | --- | --- |
| 1.0 | Foundation | Q1 2026 | Done | Core skills |
| 1.x | Expansion | Q2 2026 | Done | 29 skills, upgrade assistants |
| 2.0 | Toolkit | Q3 2026 | Done | Agents, commands, installer v2, plugin |
| 2.x | Quality & Ecosystem | Q4 2026 | Planned | CI validation, Cloud integration |

**Status Legend:** Done · In Progress · Planned ·
Blocked · Cancelled

---

## Phase Details

### Foundation (1.0)

**Goal:** Deliver a complete, installable collection
of Claude Code skills covering the full SDLC for
Laravel developers.

**Deliverables:**

- [x] 25 skills with valid SKILL.md and references
- [x] `install.sh` script (local and remote)
- [x] Root README with skills directory
- [x] Full SDLC documentation
- [x] LICENSE file

**Exit Criteria:** All skills installed successfully,
documentation complete.

---

### Expansion (1.x)

**Goal:** Add more skills and improve quality
assurance.

**Deliverables:**

- [x] 29 skills (exceeding 20+ target)
- [x] Upgrade assistant skills (Laravel 12→13,
  Livewire 3→4, kickoff-patch)
- [ ] Skill validation script (moved to 2.x)
- [ ] GitHub Actions CI (moved to 2.x)

**Exit Criteria:** 20+ skills available. Met.

---

### Toolkit (2.0) — shipped 2026-08-03

**Goal:** One repo as the versioned source of truth
for the whole Claude Code setup.

**Deliverables:**

- [x] Repo renamed `agent-skills` → `claude`
- [x] 16 role agents covering the full SDLC
  (requirements → architecture → build → QA/QC →
  security → performance → deploy → support)
- [x] 10 slash commands
- [x] Installer v2 (type-prefixed manifest,
  `--dry-run`, `--only`)
- [x] Plugin marketplace packaging
- [x] CHANGELOG + docs refresh

**Exit Criteria:** `~/.claude/{skills,agents,commands}`
reproducible from the repo. Met.

---

### Quality & Ecosystem (2.x)

**Goal:** Automated quality gates and ecosystem
integration.

**Deliverables:**

- [ ] CI: frontmatter schema validation for skills,
  agents and commands
- [ ] CI: manifest.txt freshness check
- [ ] Laravel Cloud Skills metadata compliance
- [ ] Category-split plugins (optional)
- [ ] Contribution workflow and templates
  (`skills/_template/`)

**Exit Criteria:** CI green on all content, Cloud
Skills publishable.
