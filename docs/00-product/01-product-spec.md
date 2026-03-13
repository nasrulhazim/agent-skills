# Product Specification — Agent Skills

> **Status:** Draft
> **Version:** 0.1
> **Author:** Nasrul Hazim
> **Last Updated:** 2026-03-14

## Problem Statement

Laravel developers and solo founders using Claude Code
lack structured, reusable skill definitions for common
workflows — testing, code quality, deployment,
documentation, and project planning. Each new project
requires re-prompting the same patterns from scratch.

## Goals

- Provide a comprehensive collection of Claude Code
  skills covering the full SDLC
- Enable one-command installation of all skills globally
- Maintain compatibility with Laravel Cloud Skills
  ecosystem

## Non-Goals

Things explicitly out of scope for this version:

- Runtime execution engine (skills are prompt-based,
  not executable code)
- GUI or web interface for skill management
- Non-Claude AI agent support

## Target Users

| User | Description | Need |
| --- | --- | --- |
| Laravel Dev | PHP devs using Laravel + Claude | Testing, quality, deploy |
| Solo Founder | Indie devs building products | Business planning skills |
| Pkg Author | Devs publishing to Packagist | Scaffolding and releases |

## Key Features

### Skill Collection

25 skills covering development, lifecycle, deployment,
research, business, and meta categories.

**Acceptance Criteria:**

- [ ] Each skill has a valid SKILL.md with YAML
  frontmatter
- [ ] Each skill has a references/ directory with
  supporting templates

### Global Installation

One-command install via `install.sh` to
`~/.claude/skills/`.

**Acceptance Criteria:**

- [ ] `curl | bash` remote install works
- [ ] Local clone + `bash install.sh` works
- [ ] Skills are available globally in Claude Code
  after install

### Kickoff.my Baseline Integration

Skills assume the Kickoff.my bootstrap stack
(Livewire 4, Pest, PHPStan, Rector, Pint).

**Acceptance Criteria:**

- [ ] Skills reference Kickoff patterns where
  applicable
- [ ] No conflicts with Kickoff's default configuration

## Constraints

| Type | Constraint |
| --- | --- |
| Technical | Markdown-only, YAML frontmatter |
| Platform | Claude Code slash commands |
| Integration | Laravel Cloud Skills ecosystem |

## Success Metrics

| Metric | Baseline | Target | Measurement |
| --- | --- | --- | --- |
| Skill count | 25 | 30+ | `skills/*/SKILL.md` |
| Install rate | — | 100% | Manual test |
| Adoption | 0 | 50+ stars | GitHub stars |

## Minimum Viable Version

The MVP must include:

- All 25 current skills with valid frontmatter
- Working `install.sh` script
- Root README with skills directory

The MVP may exclude:

- Automated testing of skill definitions
- Version pinning per skill
- Skill dependency resolution

## Open Questions

| Question | Owner | Due | Status |
| --- | --- | --- | --- |
| Cloud Skills extra metadata? | Nasrul | TBD | Open |
| Independent skill versioning? | Nasrul | TBD | Open |

## Revision History

| Version | Date | Author | Changes |
| --- | --- | --- | --- |
| 0.1 | 2026-02-28 | Nasrul Hazim | Initial draft |
