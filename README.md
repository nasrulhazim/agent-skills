# Claude Toolkit

[![Latest Version](https://img.shields.io/github/v/release/nasrulhazim/claude?style=flat-square)](https://github.com/nasrulhazim/claude/releases)
[![License](https://img.shields.io/github/license/nasrulhazim/claude?style=flat-square)](LICENSE)

A complete Claude Code toolkit — **skills**, **agents** and **commands** — for Laravel developers, solo founders, and package authors. Skills target the [Laravel Cloud Skills](https://skills.laravel.cloud) ecosystem.

- **Skills** carry knowledge and method — loaded on demand by trigger phrases or `/name`.
- **Agents** are role personas (code reviewer, QA engineer, DevOps engineer, …) that load the matching skills as their playbook and can be delegated to or fanned out in parallel.
- **Commands** are workflow entry points invoked as slash commands.

## Skills Directory

<details open>
<summary><strong>Development & Quality</strong> (7 skills)</summary>

| Skill | Description |
|---|---|
| [project-laravel](skills/project-laravel/) | Kickoff Laravel conventions enforcer and code scaffolder |
| [kickoff-patch](skills/kickoff-patch/) | Patch a Kickoff-based project to the latest Kickoff baseline via category-grouped 3-way merge |
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

## Agents Directory

20 role agents — thin personas that load the skills above as their playbook, covering the full SDLC (see [Using Agents](docs/02-development/05-using-agents.md) for the coverage map). Reviewer, auditor and security roles are restricted to read-only tools.

| Agent | Role |
|---|---|
| [software-architect](agents/software-architect.md) | System/module design, DDD boundaries, API design, ADRs, architectural review |
| [database-engineer](agents/database-engineer.md) | Schema, migrations, indexing, integrity, backups, multi-tenant data isolation |
| [laravel-developer](agents/laravel-developer.md) | Implements features end-to-end — models, Actions, Livewire/Flux, policies, tests |
| [api-engineer](agents/api-engineer.md) | REST API design & build — versioning, Resources, auth/scopes, rate limits, OpenAPI |
| [code-reviewer](agents/code-reviewer.md) | Read-only Laravel code review — Kickoff conventions, patterns, security, test gaps |
| [qa-engineer](agents/qa-engineer.md) | Test strategy (QA) + writes and repairs Pest tests until green (QC) |
| [performance-engineer](agents/performance-engineer.md) | Measure-first optimisation — N+1, indexes, caching, queues, Livewire payloads |
| [package-maintainer](agents/package-maintainer.md) | Package scaffolding, dependency bumps, Testbench, releases — parallel-safe |
| [devops-engineer](agents/devops-engineer.md) | CI/CD, Docker, deployments, GitHub administration, release automation |
| [upgrade-specialist](agents/upgrade-specialist.md) | Laravel/Livewire/PHP upgrades and Kickoff baseline patching |
| [tech-writer](agents/tech-writer.md) | SDLC docs, roadmaps, FAQs, release notes, READMEs |
| [business-analyst](agents/business-analyst.md) | SRS, user stories, wireframes, proposals (BM/EN), pricing |
| [project-manager](agents/project-manager.md) | Roadmaps, GitHub milestones/boards, sprints, risk & scope, multi-repo status |
| [brand-designer](agents/brand-designer.md) | SVG logo systems, wordmarks, business cards, brand assets |
| [ui-designer](agents/ui-designer.md) | UI/UX design and Livewire+Flux implementation, accessibility audits |
| [support-analyst](agents/support-analyst.md) | Ticket triage with SLA awareness, production log analysis |
| [security-analyst](agents/security-analyst.md) | Defensive security audits, dependency advisories, incident investigation |
| [penetration-tester](agents/penetration-tester.md) | Authorized offensive testing — local/staging only, scoped, minimal-impact |
| [fleet-auditor](agents/fleet-auditor.md) | Read-only sweeps across many repos — drift, inventory, statistics |
| [courseware-developer](agents/courseware-developer.md) | Interactive HTML courseware and training decks |

## Commands Directory

| Command | Purpose |
|---|---|
| [/analyze-repo](commands/analyze-repo.md) | Repository analysis assistant |
| [/design-logo](commands/design-logo.md) | Design an SVG logo system |
| [/docs](commands/docs.md) | Documentation management |
| [/sales](commands/sales.md) | All-in-one sales — config, pricing, marketing, quotation |
| [/sales-create-config](commands/sales-create-config.md) | Create a product-config.md interactively |
| [/sales-get-marketing](commands/sales-get-marketing.md) | Marketing copy — taglines, pitches, social posts |
| [/sales-get-pricing](commands/sales-get-pricing.md) | Pricing by scenario |
| [/sales-get-quotation](commands/sales-get-quotation.md) | Generate a quotation |
| [/upgrade-laravel](commands/upgrade-laravel.md) | Laravel 12 → 13 upgrade assistant |
| [/upgrade-livewire](commands/upgrade-livewire.md) | Livewire 3 → 4 upgrade assistant |

## Installation

<details open>
<summary><strong>Quick Install (everything)</strong></summary>

```bash
# Remote — install all skills, agents and commands via curl
curl -fsSL https://raw.githubusercontent.com/nasrulhazim/claude/main/install.sh | bash
```

```bash
# Local — clone and install
git clone https://github.com/nasrulhazim/claude.git
cd claude
bash install.sh
```

Content is installed to `~/.claude/skills/`, `~/.claude/agents/` and `~/.claude/commands/` and available globally in Claude Code.

Useful flags:

```bash
bash install.sh --dry-run              # preview without writing
bash install.sh --only pest-testing   # install a single skill, agent or command
```

</details>

<details>
<summary><strong>Plugin Marketplace</strong></summary>

```bash
# In Claude Code
/plugin marketplace add nasrulhazim/claude
/plugin install claude-toolkit@claude
```

Use either the installer **or** the plugin — installing both duplicates the content in your setup.

</details>

<details>
<summary><strong>Manual Install (single item)</strong></summary>

```bash
# Copy a skill directory into your project's .claude/skills/ folder
cp -r skills/pest-testing /path/to/your-project/.claude/skills/

# Or a single agent / command
cp agents/code-reviewer.md /path/to/your-project/.claude/agents/
cp commands/docs.md /path/to/your-project/.claude/commands/
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
<summary><strong>Repository Structure</strong></summary>

```text
claude/
├── .claude-plugin/       # Plugin + marketplace manifests
├── skills/[skill-name]/
│   ├── SKILL.md          # Skill definition (YAML frontmatter + instructions)
│   └── references/       # Reference files (templates, patterns, examples)
├── agents/[agent-name].md      # Role agent definitions
├── commands/[command-name].md  # Slash command definitions
├── install.sh            # Installer (remote or local mode)
├── generate-manifest.sh  # Regenerates manifest.txt
├── manifest.txt          # Type-prefixed file list for remote installs
└── migrations.txt        # Rename/removal mappings applied by the installer
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

### Agent Frontmatter

```yaml
---
name: agent-name
color: orange              # semantic: red=security, orange=quality, green=build/ship,
                           # pink=docs/business, blue=design, cyan=audit, yellow=support
description: Use this agent when...   # third-person, trigger-oriented
tools: Read, Grep, Glob, Bash, Skill  # optional allowlist; omit for all tools
---
```

</details>

<details>
<summary><strong>Contributing</strong></summary>

1. Follow the existing structure and frontmatter format for each content type
2. Skills: include `metadata` with `compatible_agents` and `tags`; add reference files for templates and patterns
3. Agents: thin role personas (25–75 lines) that load skills — no duplicated skill content
4. Include trigger phrases in both English and Bahasa Malaysia where appropriate
5. Run `bash generate-manifest.sh` before committing; record renames in `migrations.txt`

</details>

## License

MIT
