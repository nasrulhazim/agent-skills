# Using Agents

Agents are role personas Claude Code can delegate to —
explicitly ("use the code-reviewer agent") or
automatically when a request matches an agent's
description. Each agent loads the toolkit's skills as
its playbook, so knowledge stays in one place.

## SDLC Coverage Map

The 20 agents cover every SDLC phase:

| SDLC Phase | Agent(s) | Notes |
| --- | --- | --- |
| Requirements & pre-sales | business-analyst | SRS, user stories, proposals (BM/EN), pricing |
| Planning & project management | project-manager | Roadmaps, milestones, sprints, risk/scope, multi-repo status |
| Architecture & design | software-architect | System/module design, DDD, API design, ADRs |
| Data & database | database-engineer | Schema, migrations, indexing, integrity, backups, tenant isolation |
| UI/UX design | ui-designer, brand-designer | Interfaces + brand identity |
| Implementation (backend/frontend) | laravel-developer | Features end-to-end with tests (Laravel + Livewire/Flux) |
| API design & build | api-engineer | REST, versioning, Resources, auth/scopes, rate limits, OpenAPI |
| Testing (QA/QC) | qa-engineer | Test strategy (QA) + Pest tests until green (QC) |
| Code review | code-reviewer | Read-only; Kickoff conventions, bugs, coverage gaps |
| Security (defensive) | security-analyst | Defensive audits, advisories, incident investigation |
| Security (offensive) | penetration-tester | Authorized pentest — local/staging only, scoped, minimal-impact |
| Performance | performance-engineer | Measure → fix → re-measure; N+1, caching, queues |
| Deployment & release | devops-engineer | CI/CD, Docker, VPS deploys, GitHub administration |
| Maintenance & upgrades | upgrade-specialist | Laravel/Livewire/PHP upgrades, Kickoff patching |
| Operations & support | support-analyst | Ticket triage with SLA, production log analysis |
| Governance & audit | fleet-auditor | Read-only multi-repo sweeps, drift and inventory |
| Package lifecycle | package-maintainer | ~/Packages scaffold, deps, releases — parallel-safe |
| Documentation | tech-writer | SDLC docs, roadmaps, release notes |
| Training | courseware-developer | Interactive courseware and decks |

## How to Delegate

- **Explicit:** "use the qa-engineer agent to cover
  this module" / "fan out package-maintainer across
  these 10 packages"
- **Automatic:** describe the task naturally; Claude
  matches it against agent descriptions
- **Parallel:** package-maintainer and fleet-auditor
  are designed to fan out safely across many
  repos/packages at once

## Typical Chains

- **Feature:** project-manager (plan) → business-analyst
  (requirements) → software-architect + database-engineer
  (design) → laravel-developer / api-engineer (build) →
  code-reviewer + qa-engineer (verify) → devops-engineer
  (ship)
- **Security assurance:** security-analyst (defensive
  audit) → penetration-tester (authorized, scoped
  local/staging test) → laravel-developer (fix) →
  security-analyst (re-verify)
- **Incident:** support-analyst (triage) →
  security-analyst or performance-engineer (diagnose)
  → laravel-developer (fix) → tech-writer
  (post-mortem)
- **Release:** qa-engineer (suite green) →
  devops-engineer (changelog, tag, deploy) →
  tech-writer (release notes)

## Agents vs Skills vs Commands

| Use a… | When |
| --- | --- |
| Skill | You need knowledge/method in the current session |
| Agent | You want to delegate a role-shaped task (or fan out) |
| Command | You want a repeatable workflow entry point (`/name`) |
