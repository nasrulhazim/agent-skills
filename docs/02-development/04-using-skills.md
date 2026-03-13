# Using Skills

How to install, invoke, and get the most out of
Agent Skills in your projects.

## Installation Methods

### Global Install (Recommended)

Installs all skills to `~/.claude/skills/` so
they are available in every project.

```bash
# Remote
curl -fsSL \
  https://raw.githubusercontent.com/\
nasrulhazim/agent-skills/main/install.sh \
  | bash

# Local clone
git clone \
  https://github.com/nasrulhazim/agent-skills.git
cd agent-skills
bash install.sh
```

### Per-Project Install

Copy a single skill into a specific project:

```bash
cp -r skills/pest-testing \
  /path/to/project/.claude/skills/
```

Per-project skills override global skills of the
same name.

### Updating Skills

Re-run the installer to update all skills:

```bash
cd agent-skills
git pull
bash install.sh
```

Existing skill files are overwritten on reinstall.

---

## Invoking Skills

Skills are invoked as slash commands in Claude Code.
Type the command in your Claude Code session.

### Skill Command Quick Reference

#### Development & Quality

| Command | What It Does |
| --- | --- |
| `/project-laravel` | Enforce Kickoff conventions |
| `/test generate` | Generate Pest test files |
| `/test coverage` | Analyse test coverage gaps |
| `/quality check` | Run PHPStan + Pint + Rector |
| `/quality baseline` | Manage PHPStan baseline |
| `/php modernize` | Upgrade to PHP 8.2+ |
| `/php refactor` | Refactor code smells |
| `/pattern suggest` | Suggest design patterns |
| `/pattern implement` | Implement a pattern |
| `/livewire form` | Scaffold Livewire form |
| `/livewire table` | Scaffold data table |

#### Project Lifecycle

| Command | What It Does |
| --- | --- |
| `/docs scaffold` | Scaffold SDLC docs |
| `/docs spec` | Generate product spec |
| `/docs roadmap` | Generate roadmap |
| `/docs health` | Docs health report |
| `/requirements srs` | Generate SRS document |
| `/requirements stories` | Generate user stories |
| `/roadmap` | Generate visual roadmap |
| `/api design` | Design OpenAPI spec |
| `/api scaffold` | Scaffold controllers |
| `/faq-generator` | Generate multi-audience FAQs |

#### Deployment & Ops

| Command | What It Does |
| --- | --- |
| `/ci-cd pipeline` | Build CI/CD pipeline |
| `/ci-cd docker` | Dockerise Laravel app |
| `/git commit` | Conventional commit |
| `/git release` | Prepare release |
| `/git hooks` | Set up git hooks |
| `/gh-workflow` | GitHub CLI automation |
| `/package scaffold` | Scaffold Laravel package |
| `/package release` | Publish to Packagist |
| `/log-monitor` | Analyse production logs |

#### Research & Analytics

| Command | What It Does |
| --- | --- |
| `/repo-research` | Deep codebase analysis |
| `/dev-summary` | Multi-repo commit stats |

#### Business & Design

| Command | What It Does |
| --- | --- |
| `/sales pricing` | Calculate pricing |
| `/sales quotation` | Generate quotation |
| `/sales marketing` | Marketing copy |
| `/logo` | Design SVG logo system |
| `/logo-designer` | Professional logo with style control |
| `/courseware-builder` | Interactive HTML courseware |

#### Meta

| Command | What It Does |
| --- | --- |
| `/self-update` | Auto-update CLAUDE.md |
| `/project-sync` | Sync CLAUDE.md across projects |
| `/project-inventory` | Discover Claude Code projects |

---

## Skill Categories Explained

### Development & Quality Skills

Skills for writing, testing, and reviewing code.
Best used during active development.

- **project-laravel** — Enforces Kickoff.my
  conventions: UUID models, Base class extension,
  Spatie packages, strict typing
- **pest-testing** — Auto-detects models,
  controllers, and Livewire components, then
  scaffolds matching Pest test files
- **code-quality** — Runs PHPStan, Pint, and
  Rector in sequence; manages baselines for
  legacy codebases
- **php-best-practices** — Modernises PHP code
  to 8.2+ features: enums, readonly, named args,
  match expressions
- **design-patterns** — Suggests and implements
  patterns (Repository, Action, Strategy, etc.)
  with a decision matrix
- **livewire-flux** — Scaffolds Livewire 4
  components using Flux UI primitives with
  Spatie integration

### Project Lifecycle Skills

Skills for planning, documenting, and managing
project scope.

- **project-docs** — Full SDLC documentation
  toolchain with scaffold, validate, and health
  commands
- **project-requirements** — Interview-driven
  SRS generation, user stories, client proposals,
  and ASCII wireframes
- **roadmap-generator** — Produces ROADMAP.md and
  styled HTML visual roadmap with phases and
  dependencies
- **api-lifecycle** — Seven-phase API management:
  design, develop, test, deploy, docs, govern,
  and security
- **faq-generator** — Generates 7 audience-specific
  FAQ documents (executive, marketing, PM, admin,
  developer, devops, end user)

### Deployment & Ops Skills

Skills for releasing, deploying, and maintaining
projects.

- **ci-cd-pipeline** — GitHub Actions CI/CD with
  Docker, staging/production deploys, and secret
  management
- **git-workflow** — Conventional commits, branch
  strategies, changelog generation, and release
  automation
- **gh-workflow** — GitHub CLI automation for
  issues, PRs, Projects, Actions debugging, and
  advanced API operations
- **package-dev** — Laravel package scaffolding
  with Pest + Orchestra Testbench, release
  workflow, and Packagist publishing
- **log-monitor** — Analyses Laravel production
  logs, categorises errors, generates reports,
  and creates prioritised GitHub issues

### Research & Analytics Skills

Skills for analysing codebases and tracking
development progress.

- **repo-research** — Deep codebase analysis
  producing 10 structured research documents
  with Mermaid diagrams and SaaS opportunity
  analysis
- **dev-summary** — Multi-repo development stats,
  commit timelines, contributor analytics, and
  HTML dashboard

### Business & Design Skills

Skills for non-code deliverables.

- **sales-planner** — Pricing calculator,
  quotation generator, reseller margins, and
  marketing copy
- **svg-logo-system** — Generates 25 logo
  concepts, wordmarks, icon marks, preview
  galleries, and export assets
- **logo-designer** — Professional SVG logo
  designer with granular control over category,
  palette, frame, and rendering style
- **courseware-builder** — Transforms technical
  topics into interactive HTML slide decks with
  animated diagrams and code examples

### Meta Skills

- **self-update** — Automatically updates
  CLAUDE.md when you correct a mistake or
  express a preference
- **project-sync** — Syncs CLAUDE.md conventions
  across multiple Kickoff-based Laravel projects
- **project-inventory** — Discovers and inventories
  all Claude Code projects with HTML portfolio
  dashboard

---

## Tips for Effective Use

### Combine Skills in Workflows

Skills work well together. A typical new project
workflow:

1. `/project-laravel` — set up conventions
2. `/docs scaffold` — scaffold documentation
3. `/requirements srs` — define requirements
4. `/roadmap` — plan phases
5. `/test generate` — scaffold test suite
6. `/quality check` — establish quality baseline
7. `/git hooks` — set up pre-commit hooks
8. `/ci-cd pipeline` — automate CI/CD

### Use Bilingual Triggers

Most skills respond to Bahasa Malaysia triggers:

- "buat test untuk model User"
- "semak kualiti kod"
- "sediakan git hooks"
- "buat roadmap untuk projek ni"
- "tulis proposal untuk client"

### Kickoff.my Baseline

Many skills assume the Kickoff.my stack:

- Livewire 4 + Flux UI
- Pest with arch testing
- PHPStan / Larastan
- Rector + Laravel Pint
- GitHub Actions CI
- Spatie Permission, Activity Log, Media Library

If your project uses a different stack, skills
still work but some generated code may need
adjustment.

### Skill Scope

Skills are **prompt-based**, not executable code.
They guide Claude Code to generate the right
output for your project. Skills read your
codebase context (models, controllers, config)
to produce relevant results.
