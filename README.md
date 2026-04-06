# Agent Skills

[![Latest Version](https://img.shields.io/github/v/release/nasrulhazim/agent-skills?style=flat-square)](https://github.com/nasrulhazim/agent-skills/releases)
[![License](https://img.shields.io/github/license/nasrulhazim/agent-skills?style=flat-square)](LICENSE)

A collection of Claude Code skills for Laravel developers, solo founders, and package authors —
targeting the [Laravel Cloud Skills](https://skills.laravel.cloud) ecosystem.

## Skills Directory

<details open>
<summary><strong>Development & Quality</strong> (6 skills)</summary>

| Skill | Description |
|---|---|
| [project-laravel](skills/project-laravel/) | Kickoff Laravel conventions enforcer and code scaffolder |
| [pest-testing](skills/pest-testing/) | Pest PHP test generator with Livewire, arch testing, and factory patterns |
| [code-quality](skills/code-quality/) | PHPStan + Pint + Rector workflow automation |
| [php-best-practices](skills/php-best-practices/) | PHP 8.2+ modernization, refactoring, and code review |
| [design-patterns](skills/design-patterns/) | PHP & Laravel design patterns with decision matrix |
| [livewire-flux](skills/livewire-flux/) | Livewire 4 + Flux UI component patterns |

</details>

<details>
<summary><strong>Project Management</strong> (9 skills)</summary>

| Skill | Description |
|---|---|
| [project-api](skills/project-api/) | Full API lifecycle — design through governance |
| [project-conventions](skills/project-conventions/) | Auto-update CLAUDE.md with corrections, preferences, and gotchas |
| [project-ddd](skills/project-ddd/) | Pragmatic DDD — domain discovery, migration planning, and boundary enforcement |
| [project-docs](skills/project-docs/) | Full SDLC documentation toolchain |
| [project-faq](skills/project-faq/) | Multi-audience FAQ generator by stakeholder persona |
| [project-inventory](skills/project-inventory/) | Discover and inventory all Claude Code projects with HTML dashboard |
| [project-requirements](skills/project-requirements/) | SRS, user stories, proposals, and wireframes |
| [project-roadmap](skills/project-roadmap/) | Phase-based roadmap in Markdown + styled HTML |
| [project-sync](skills/project-sync/) | Sync CLAUDE.md conventions across multiple Kickoff projects |

</details>

<details>
<summary><strong>Deployment & Ops</strong> (6 skills)</summary>

| Skill | Description |
|---|---|
| [ci-cd-pipeline](skills/ci-cd-pipeline/) | GitHub Actions + Docker workflow automation |
| [git-workflow](skills/git-workflow/) | Conventional commits, branching, release automation, and git hooks |
| [gh-workflow](skills/gh-workflow/) | GitHub CLI automation — issues, PRs, Projects, Actions debugging |
| [package-dev](skills/package-dev/) | Laravel package scaffolding, testing, and release |
| [log-monitor](skills/log-monitor/) | Production log analysis, error triage, and GitHub issue creation |
| [soc-analyst](skills/soc-analyst/) | Senior SOC analyst — security triage, investigation, remediation, and hardening |

</details>

<details>
<summary><strong>Research & Analytics</strong> (2 skills)</summary>

| Skill | Description |
|---|---|
| [repo-research](skills/repo-research/) | Deep codebase analysis with structured research documents and diagrams |
| [dev-summary](skills/dev-summary/) | Multi-repo development stats, timelines, and contributor analytics |

</details>

<details>
<summary><strong>Business & Design</strong> (5 skills)</summary>

| Skill | Description |
|---|---|
| [business-card](skills/business-card/) | SVG business card designer with print-ready export |
| [sales-planner](skills/sales-planner/) | Pricing, quotations, marketing copy, and financial planning |
| [svg-logo-system](skills/svg-logo-system/) | SVG logo system design with multi-platform export |
| [logo-designer](skills/logo-designer/) | Professional SVG logo designer with granular category and style control |
| [courseware-builder](skills/courseware-builder/) | Interactive HTML courseware builder with animated diagrams |

</details>

## Installation

<details open>
<summary><strong>Quick Install (all skills)</strong></summary>

```bash
# Remote — install all skills via curl
curl -fsSL https://raw.githubusercontent.com/nasrulhazim/agent-skills/main/install.sh | bash
```

```bash
# Local — clone and install
git clone https://github.com/nasrulhazim/agent-skills.git
cd agent-skills
bash install.sh
```

Skills are installed to `~/.claude/skills/` and available globally in Claude Code.

</details>

<details>
<summary><strong>Manual Install (single skill)</strong></summary>

```bash
# Copy a skill directory into your project's .claude/skills/ folder
cp -r skills/pest-testing /path/to/your-project/.claude/skills/
```

</details>

## Documentation

Full SDLC documentation is available in the [`docs/`](docs/) directory:

| Section | Contents |
|---|---|
| [Product](docs/00-product/) | Specification, requirements, roadmap |
| [Architecture](docs/01-architecture/) | Design overview, patterns, ADRs |
| [Development](docs/02-development/) | Getting started, workflows, testing |
| [Using Skills](docs/02-development/04-using-skills.md) | Installation, commands, tips |
| [Deployment](docs/03-deployment/) | Publishing and release process |
| [API Reference](docs/04-api/) | Skill format schema and contracts |
| [Support](docs/05-support/) | FAQ, triage, SLA, deprecation |

## Kickoff.my Baseline

Many skills assume the [Kickoff.my](https://kickoff.my) bootstrap stack:

- Livewire 4 + Flux UI
- Pest (with arch testing)
- PHPStan / Larastan
- Rector
- Laravel Pint
- GitHub Actions CI
- Spatie Permission, Activity Log, Media Library

Skills build on top of this baseline rather than re-scaffolding what Kickoff already provides.

<details>
<summary><strong>Skill Structure</strong></summary>

Each skill follows this structure:

```text
skills/[skill-name]/
├── SKILL.md              # Skill definition (YAML frontmatter + instructions)
└── references/           # Reference files (templates, patterns, examples)
    ├── template-a.md
    └── patterns-b.md
```

### SKILL.md Frontmatter

```yaml
---
name: skill-name
metadata:
  compatible_agents: [claude-code]
  tags: [tag1, tag2]
description: >
  Multi-line description with trigger phrases...
---
```

</details>

<details>
<summary><strong>Contributing</strong></summary>

1. Follow the existing skill structure and frontmatter format
2. Include `metadata` with `compatible_agents` and `tags` in frontmatter
3. Add reference files for templates and patterns
4. Include trigger phrases in both English and Bahasa Malaysia where appropriate

</details>

## License

MIT
