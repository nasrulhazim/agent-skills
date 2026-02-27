# Agent Skills

A collection of Claude Code skills for Laravel developers, solo founders, and package authors — targeting the [Laravel Cloud Skills](https://skills.laravel.cloud) ecosystem.

## Skills Directory

### Development & Quality

| Skill | Description |
|---|---|
| [pest-testing](skills/pest-testing/) | Pest PHP test generator with Livewire, arch testing, and factory patterns |
| [code-quality](skills/code-quality/) | PHPStan + Pint + Rector workflow automation |
| [php-best-practices](skills/php-best-practices/) | PHP 8.2+ modernization, refactoring, and code review |
| [design-patterns](skills/design-patterns/) | PHP & Laravel design patterns with decision matrix |
| [livewire-flux](skills/livewire-flux/) | Livewire 4 + Flux UI component patterns |

### Project Lifecycle

| Skill | Description |
|---|---|
| [project-docs](skills/project-docs/) | Full SDLC documentation toolchain |
| [project-requirements](skills/project-requirements/) | SRS, user stories, proposals, and wireframes |
| [roadmap-generator](skills/roadmap-generator/) | Phase-based roadmap in Markdown + styled HTML |
| [api-lifecycle](skills/api-lifecycle/) | Full API lifecycle — design through governance |

### Deployment & Ops

| Skill | Description |
|---|---|
| [ci-cd-pipeline](skills/ci-cd-pipeline/) | GitHub Actions + Docker workflow automation |
| [package-dev](skills/package-dev/) | Laravel package scaffolding, testing, and release |

### Business & Design

| Skill | Description |
|---|---|
| [sales-planner](skills/sales-planner/) | Pricing, quotations, marketing copy, and financial planning |
| [svg-logo-system](skills/svg-logo-system/) | SVG logo system design with multi-platform export |

### Meta

| Skill | Description |
|---|---|
| [self-update](skills/self-update/) | Auto-update CLAUDE.md with corrections, preferences, and gotchas |

## Installation

### Quick Install (all skills)

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

### Manual Install (single skill)

```bash
# Copy a skill directory into your project's .claude/skills/ folder
cp -r skills/pest-testing /path/to/your-project/.claude/skills/
```

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

## Skill Structure

Each skill follows this structure:

```
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

## Contributing

1. Follow the existing skill structure and frontmatter format
2. Include `metadata` with `compatible_agents` and `tags` in frontmatter
3. Add reference files for templates and patterns
4. Include trigger phrases in both English and Bahasa Malaysia where appropriate

## License

MIT
