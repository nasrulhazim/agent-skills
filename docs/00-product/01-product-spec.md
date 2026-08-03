# Product Specification — Claude Toolkit

> **Status:** Active
> **Version:** 0.2
> **Author:** Nasrul Hazim
> **Last Updated:** 2026-08-03

## Problem Statement

Laravel developers and solo founders using Claude Code
lack structured, reusable definitions for common
workflows — testing, code quality, deployment,
documentation, and project planning. Each new project
requires re-prompting the same patterns from scratch,
and a personal Claude setup (skills, agents, commands)
scattered across `~/.claude/` is unversioned and not
reproducible across machines.

## Goals

- Provide a complete Claude Code toolkit — skills,
  agents and commands — covering the full SDLC
- Enable one-command installation of the whole toolkit
  globally (installer or plugin marketplace)
- Keep `~/.claude/{skills,agents,commands}` fully
  reproducible from one versioned repo
- Maintain compatibility with the Laravel Cloud Skills
  ecosystem

## Non-Goals

Things explicitly out of scope for this version:

- Runtime execution engine (content is prompt-based,
  not executable code)
- GUI or web interface for toolkit management
- Non-Claude AI agent support

## Target Users

| User | Description | Need |
| --- | --- | --- |
| Laravel Dev | PHP devs using Laravel + Claude | Testing, quality, deploy |
| Solo Founder | Indie devs building products | Business planning skills |
| Pkg Author | Devs publishing to Packagist | Scaffolding and releases |

## Key Features

### Skill Collection

29 skills covering development & quality, project
management, deployment & ops, research & analytics,
and business & design. Skills carry knowledge and
method, loaded on demand.

**Acceptance Criteria:**

- [x] Each skill has a valid SKILL.md with YAML
  frontmatter
- [x] Each skill has a references/ directory with
  supporting templates

### Agent Roster

16 role agents covering the full SDLC — requirements
(business-analyst), architecture (software-architect),
design (ui-designer, brand-designer), implementation
(laravel-developer), testing & QA/QC (qa-engineer),
review (code-reviewer), security (security-analyst),
performance (performance-engineer), deployment
(devops-engineer), maintenance (upgrade-specialist),
operations (support-analyst), governance
(fleet-auditor), documentation (tech-writer), and
training (courseware-developer). Agents are thin role
personas that load skills as their playbook.

**Acceptance Criteria:**

- [x] Each agent has frontmatter (`name`, `color`,
  `description`, optional `tools`)
- [x] Read-only roles have restricted tool allowlists
- [x] Agents reference skills, never duplicate them

### Command Collection

10 slash commands as workflow entry points (repo
analysis, logo design, docs management, sales suite,
upgrade assistants).

### Global Installation

One-command install via `install.sh` to
`~/.claude/{skills,agents,commands}`, or plugin
install via the Claude Code marketplace.

**Acceptance Criteria:**

- [x] `curl | bash` remote install works
- [x] Local clone + `bash install.sh` works
- [x] `/plugin marketplace add nasrulhazim/claude`
  works
- [x] `--dry-run` and `--only <name>` flags supported

### Kickoff.my Baseline Integration

Skills and agents assume the Kickoff.my bootstrap
stack (Livewire 4, Pest, PHPStan, Rector, Pint).

**Acceptance Criteria:**

- [x] Content references Kickoff patterns where
  applicable
- [x] No conflicts with Kickoff's default configuration

## Constraints

| Type | Constraint |
| --- | --- |
| Technical | Markdown-only, YAML frontmatter |
| Installer | Bash 3.2 compatible (macOS default) |
| Platform | Claude Code (skills, agents, commands, plugin) |
| Integration | Laravel Cloud Skills ecosystem |

## Success Metrics

| Metric | Baseline | Target | Measurement |
| --- | --- | --- | --- |
| Skill count | 29 | 35+ | `skills/*/SKILL.md` |
| Agent count | 16 | 16+ | `agents/*.md` |
| Install rate | 100% | 100% | Manual test |
| Adoption | 0 | 50+ stars | GitHub stars |

## Minimum Viable Version

The MVP must include:

- All skills, agents and commands with valid format
- Working `install.sh` (all three types)
- Plugin marketplace manifests
- Root README with full content directory

The MVP may exclude:

- Automated testing of content definitions (CI)
- Version pinning per item
- Dependency resolution between items

## Open Questions

| Question | Owner | Due | Status |
| --- | --- | --- | --- |
| Cloud Skills extra metadata? | Nasrul | TBD | Open |
| Independent item versioning? | Nasrul | TBD | Open |
| Category-split plugins? | Nasrul | TBD | Open |

## Revision History

| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 0.1 | 2026-02-28 | Nasrul Hazim | Initial draft |
| 0.2 | 2026-08-03 | Nasrul Hazim | Claude Toolkit: agents + commands added, plugin packaging, installer v2 |
