# SDLC Templates

Templates for pre-development and post-development documentation.
Populate placeholders (wrapped in `[BRACKETS]`) from user interview or context.

## Table of Contents

- [Product Specification](#product-specification)
- [Requirements Document](#requirements-document)
- [Roadmap](#roadmap)
- [Support — FAQ](#support--faq)
- [Support — Workflow & Triage](#support--workflow--triage)
- [Support — SLA](#support--sla)
- [Support — Post-Mortem](#support--post-mortem)
- [Support — Deprecation & EOL](#support--deprecation--eol)
- [Ops Runbook](#ops-runbook)

---

## Product Specification

File: `docs/00-product/01-product-spec.md`

```markdown
# Product Specification — [Product Name]

> **Status:** Draft | In Review | Approved
> **Version:** 0.1
> **Author:** [Author]
> **Last Updated:** [Date]

## Problem Statement

[One paragraph. What pain exists, for whom, and why current solutions fall short.]

## Goals

- [Goal 1 — measurable outcome]
- [Goal 2]
- [Goal 3]

## Non-Goals

Things explicitly out of scope for this version:

- [Non-goal 1]
- [Non-goal 2]

## Target Users

| User Type | Description | Primary Need |
|---|---|---|
| [User A] | [Who they are] | [What they need] |
| [User B] | [Who they are] | [What they need] |

## Key Features

### [Feature 1 Name]

[2–3 sentences describing what it does and why it matters.]

**Acceptance Criteria:**

- [ ] [Criterion 1]
- [ ] [Criterion 2]

### [Feature 2 Name]

[Description]

**Acceptance Criteria:**

- [ ] [Criterion 1]

## Constraints

| Type | Constraint |
|---|---|
| Technical | [e.g., must run on PHP 8.2+, Laravel 11+] |
| Timeline | [e.g., MVP by Q2 2026] |
| Budget | [e.g., no paid third-party services] |
| Compliance | [e.g., PDPA compliant for Malaysian user data] |
| Integration | [e.g., must integrate with existing Keycloak SSO] |

## Success Metrics

| Metric | Baseline | Target | Measurement |
|---|---|---|---|
| [Metric 1] | [Current] | [Goal] | [How to measure] |
| [Metric 2] | — | [Goal] | [How to measure] |

## Minimum Viable Version

The MVP must include:

- [Feature/capability 1]
- [Feature/capability 2]

The MVP may exclude:

- [Deferred feature 1]
- [Deferred feature 2]

## Open Questions

| Question | Owner | Due | Status |
|---|---|---|---|
| [Question 1] | [Name] | [Date] | ⏳ Open |

## Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 0.1 | [Date] | [Author] | Initial draft |
```

---

## Requirements Document

File: `docs/00-product/02-requirements.md`

```markdown
# Requirements — [Product Name]

> **Status:** Draft | Approved
> **Version:** 0.1

## Functional Requirements

### [FR-01] [Requirement Name]

**Priority:** Must / Should / Could / Won't
**User Story:** As a [user type], I want to [action] so that [outcome].

**Acceptance Criteria:**

- [ ] [Criterion]

---

### [FR-02] [Requirement Name]

**Priority:** Must
**User Story:** As a [user type], I want to [action] so that [outcome].

**Acceptance Criteria:**

- [ ] [Criterion]

---

## Non-Functional Requirements

| ID | Category | Requirement | Priority |
|---|---|---|---|
| NFR-01 | Performance | [e.g., API response < 200ms p99] | Must |
| NFR-02 | Security | [e.g., All endpoints require authentication] | Must |
| NFR-03 | Scalability | [e.g., Support 1,000 concurrent users] | Should |
| NFR-04 | Accessibility | [e.g., WCAG 2.1 AA] | Should |
| NFR-05 | Availability | [e.g., 99.9% uptime] | Should |

## Dependencies

| Dependency | Type | Version | Notes |
|---|---|---|---|
| [Laravel] | Framework | 11.x / 12.x | [notes] |
| [Keycloak] | External service | 24.x | [notes] |

## Assumptions

- [Assumption 1]
- [Assumption 2]
```

---

## Roadmap

File: `docs/00-product/03-roadmap.md`

```markdown
# Roadmap — [Product Name]

> **Last Updated:** [Date]
> **Maintained by:** [Owner]

## Phase Summary

| Phase | Version | Target | Status |
|---|---|---|---|
| Alpha | v0.1 | [Q1 2026] | 🔵 Planned |
| Beta | v0.2 | [Q2 2026] | 🔵 Planned |
| General Availability | v1.0 | [Q3 2026] | 🔵 Planned |

## Version Table

| Version | Milestone | Target | Status | Key Deliverables |
|---|---|---|---|---|
| v0.1 | Alpha | [Date] | 🔵 Planned | [Feature A, Feature B] |
| v0.2 | Beta | [Date] | 🔵 Planned | [Feature C, Bug fixes] |
| v1.0 | GA | [Date] | 🔵 Planned | [Full feature set, Docs, SLA] |

**Status Legend:** 🟢 Done · 🟡 In Progress · 🔵 Planned · 🔴 Blocked · ⚫ Cancelled

---

## Gantt Chart

```mermaid
gantt
  title [Product Name] Roadmap
  dateFormat YYYY-MM-DD
  section Alpha
    [Feature A]        :[start], [end]
    [Feature B]        :[start], [end]
  section Beta
    [Feature C]        :[start], [end]
    Bug fixes          :[start], [end]
  section GA
    Documentation      :[start], [end]
    Production release :[start], [end]
```

---

## GitHub Milestones

Paste into your milestone import script:

```json
[
  {
    "title": "v0.1 Alpha",
    "description": "[Milestone description]",
    "due_on": "[YYYY-MM-DDT00:00:00Z]",
    "state": "open"
  },
  {
    "title": "v0.2 Beta",
    "description": "[Milestone description]",
    "due_on": "[YYYY-MM-DDT00:00:00Z]",
    "state": "open"
  },
  {
    "title": "v1.0 GA",
    "description": "General availability release",
    "due_on": "[YYYY-MM-DDT00:00:00Z]",
    "state": "open"
  }
]
```

---

## Phase Details

### Alpha (v0.1)

**Goal:** [One sentence — what this phase proves or delivers]

**Deliverables:**

- [ ] [Feature A]
- [ ] [Feature B]
- [ ] Internal testing complete

**Exit Criteria:** [What must be true before moving to Beta]

---

### Beta (v0.2)

**Goal:** [External testing, gather feedback]

**Deliverables:**

- [ ] [Feature C]
- [ ] Bug fixes from Alpha
- [ ] Beta user onboarding

**Exit Criteria:** [e.g., Zero P1 bugs, 10 external testers signed off]

---

### General Availability (v1.0)

**Goal:** Production-ready for public use

**Deliverables:**

- [ ] Full feature set complete
- [ ] Documentation complete
- [ ] Support SLA active
- [ ] Performance benchmarks met

**Exit Criteria:** All NFRs met, docs published, support workflow live.
```

---

## Support — FAQ

File: `docs/05-support/01-faq.md`

```markdown
# Frequently Asked Questions — [Package/Product Name]

## General

### What does [Package Name] do?

[One paragraph answer.]

### What are the system requirements?

- PHP [version]+
- Laravel [version]+
- [Other dependencies]

### Is this package free to use?

[License details and any commercial considerations.]

---

## Installation & Setup

### How do I install [Package Name]?

```bash
composer require [org/package]
```

Then publish the config:

```bash
php artisan vendor:publish --tag=[package]-config
```

### The package installs but nothing happens. What's wrong?

Check that the service provider is registered. For Laravel 11+, it auto-registers via
package discovery. For earlier versions, add to `config/app.php`:

```php
[Org\Package\PackageServiceProvider::class]
```

### How do I configure [key setting]?

Edit `config/[package].php`:

```php
'[setting]' => env('[PACKAGE_SETTING]', '[default]'),
```

---

## Common Issues

### Error: `[Common Error Message]`

**Cause:** [Why this happens]

**Fix:**

```bash
[fix command or code]
```

### [Feature X] is not working as expected

Check the following:

1. [Step 1]
2. [Step 2]
3. If still not working, [open an issue](https://github.com/[org]/[repo]/issues)
   with your Laravel version, PHP version, and error output.

---

## Known Limitations

- [Limitation 1 — brief description and any workaround]
- [Limitation 2]

---

## Getting Help

- **GitHub Issues:** [https://github.com/[org]/[repo]/issues](link)
- **Discussions:** [https://github.com/[org]/[repo]/discussions](link)
- **Email:** [support email if applicable]
```

---

## Support — Workflow & Triage

File: `docs/05-support/02-support-workflow.md`

```markdown
# Support Workflow — [Package/Product Name]

## Issue Intake

All support requests go through GitHub Issues. Use the issue templates provided:

- **Bug Report** — unexpected behaviour
- **Feature Request** — new capability
- **Question** — usage / how-to

Direct emails and DMs are acknowledged but redirected to GitHub Issues for tracking.

## Triage Flow

```
New Issue Opened
      │
      ▼
Is it a duplicate?──Yes──► Close, link to original
      │ No
      ▼
Apply severity label (P1–P4)
      │
      ▼
Assign to milestone or backlog
      │
      ▼
Respond within SLA window (see docs/05-support/03-sla.md)
      │
      ▼
Implement fix → PR → merge → close issue
```

## Labels

| Label | Meaning |
|---|---|
| `bug` | Confirmed defect |
| `enhancement` | New feature or improvement |
| `question` | Usage question |
| `duplicate` | Already reported |
| `wontfix` | Out of scope or by design |
| `good first issue` | Suitable for new contributors |
| `P1` through `P4` | Severity (see SLA doc) |

## Response Guidelines

- Always acknowledge within the SLA window, even if just to say "investigating"
- Use the labels before commenting
- If closing as `wontfix`, explain why briefly and respectfully
- Link related issues or PRs when available
- For questions already in the FAQ, link to the answer and suggest improving the docs

## Escalation

If an issue requires architectural decisions or breaking changes, escalate to a product
discussion before committing to a fix direction.
```

---

## Support — SLA

File: `docs/05-support/03-sla.md`

```markdown
# Support SLA — [Package/Product Name]

> This SLA applies to the open-source community support provided via GitHub Issues.
> Commercial SLA terms (if applicable) are defined separately.

## Severity Levels

| Level | Label | Description | Example |
|---|---|---|---|
| P1 | Critical | Package is unusable, data loss risk, security vulnerability | Fatal error on install, auth bypass |
| P2 | High | Core feature broken, no workaround | Key command throws exception |
| P3 | Medium | Feature partially broken, workaround exists | Config option ignored |
| P4 | Low | Minor issue, cosmetic, or enhancement | Typo in error message |

## Response Targets

| Severity | First Response | Resolution Target |
|---|---|---|
| P1 | Within 24 hours | Within 72 hours |
| P2 | Within 3 business days | Within 2 weeks |
| P3 | Within 1 week | Next minor release |
| P4 | Best effort | Backlog |

> **Note:** These are targets, not guarantees. This is a solo-maintained open-source package.
> Commercial projects with stricter requirements should consider a support contract.

## Out of Scope

The following are not covered by this SLA:

- Issues caused by unsupported PHP or Laravel versions
- Third-party package conflicts
- Custom modifications to the package source
- General Laravel/PHP help unrelated to this package

## Security Vulnerabilities

Do **not** open a public GitHub Issue for security vulnerabilities.
Email: [security contact] with subject `[SECURITY] [Package Name]`.
Response within 48 hours guaranteed.
```

---

## Support — Post-Mortem

File: `docs/05-support/04-post-mortem-template.md`

```markdown
# Post-Mortem — [Incident Title]

> **Date:** [YYYY-MM-DD]
> **Severity:** P1 / P2 / P3
> **Duration:** [X hours Y minutes]
> **Author:** [Name]
> **Status:** Draft | In Review | Final

## Summary

[2–3 sentences. What happened, what was the impact, how was it resolved.]

## Timeline

All times in [timezone, e.g. MYT (UTC+8)].

| Time | Event |
|---|---|
| [HH:MM] | Incident first detected |
| [HH:MM] | Alert triggered / team notified |
| [HH:MM] | Investigation started |
| [HH:MM] | Root cause identified |
| [HH:MM] | Fix deployed |
| [HH:MM] | Incident resolved, monitoring normalised |

## Impact

- **Users affected:** [Number or percentage]
- **Services affected:** [List]
- **Data loss:** [Yes/No — details]
- **Downtime:** [Duration]

## Root Cause

[One paragraph. Be specific — not "a bug", but what line, what assumption, what condition.]

## Contributing Factors

- [Factor 1 — e.g., no alerting on this metric]
- [Factor 2 — e.g., manual deploy step was skipped]
- [Factor 3]

## What Went Well

- [Thing 1 — e.g., fast detection due to monitoring]
- [Thing 2 — e.g., rollback was quick and clean]

## What Could Be Improved

- [Improvement 1]
- [Improvement 2]

## Action Items

| Action | Owner | Due | Status |
|---|---|---|---|
| [Add monitoring for X] | [Name] | [Date] | ⏳ Open |
| [Write test for edge case] | [Name] | [Date] | ⏳ Open |
| [Update runbook step Y] | [Name] | [Date] | ⏳ Open |

## Lessons Learned

[1–2 paragraphs. What does this tell us about our systems, processes, or assumptions?]
```

---

## Support — Deprecation & EOL

File: `docs/05-support/05-deprecation.md`

```markdown
# Deprecation Notice — [Package/Feature Name]

> **Announced:** [Date]
> **End of Active Support:** [Date]
> **End of Life (EOL):** [Date]

## What Is Being Deprecated

[Clear description of what is being deprecated — package, feature, API endpoint, or version.]

## Reason

[Why this is being deprecated. Be honest: superseded by better approach, unsustainable to
maintain, breaking change required for future roadmap, etc.]

## Timeline

| Date | Event |
|---|---|
| [Date] | Deprecation announced |
| [Date] | Last minor release (bug fixes only after this point) |
| [Date] | End of active support (no new features, security fixes only) |
| [Date] | End of Life — no further updates |
| [Date] | Repository archived (if applicable) |

## Impact

Who is affected:

- Users on [version range]
- Projects using [specific feature/API]

Who is NOT affected:

- [Version X]+ users (already on new approach)

## Migration Guide

### Step 1: [Action]

```bash
[command or code change]
```

### Step 2: [Action]

Before:

```php
[old code]
```

After:

```php
[new code]
```

### Step 3: [Verify]

```bash
[verification command]
```

## Recommended Replacement

| Old | New | Notes |
|---|---|---|
| `[OldClass]` | `[NewClass]` | [Migration note] |
| `[old config key]` | `[new config key]` | [Migration note] |

## Support During Transition

Security fixes will be backported to [old version] until [EOL date].
Bug fix backports: [Yes until Date / No].

For migration assistance, open a [GitHub Discussion](https://github.com/[org]/[repo]/discussions).
```

---

## Ops Runbook

File: `docs/03-deployment/02-runbook.md`

```markdown
# Ops Runbook — [Project Name]

> **Environment:** [Production / Staging]
> **Stack:** [Laravel + MySQL + Redis on [hosting]]
> **Deployment Method:** [Manual / GitHub Actions / Docker / Kubernetes]
> **Last Updated:** [Date]

## Contacts

| Role | Name | Contact |
|---|---|---|
| Primary On-Call | [Name] | [contact] |
| Escalation | [Name] | [contact] |
| Hosting Provider | [Provider] | [support URL / phone] |

---

## Pre-Deploy Checklist

Run through this before every production deployment:

- [ ] All tests pass in CI (`green` on main branch)
- [ ] `CHANGELOG.md` or release notes updated
- [ ] Database migrations reviewed — are they backwards-compatible?
- [ ] Environment variables for new features added to `.env.example` and documented
- [ ] Dependencies updated (`composer audit` / `npm audit`) — no critical CVEs
- [ ] Maintenance mode plan confirmed (required? duration?)
- [ ] Rollback plan confirmed (see below)
- [ ] Notify stakeholders if user-visible change

---

## Deploy Steps

### 1. Enable Maintenance Mode

```bash
php artisan down --secret="[bypass-secret]"
```

### 2. Pull Latest Code

```bash
git pull origin main
```

### 3. Install Dependencies

```bash
composer install --no-dev --optimize-autoloader
npm ci && npm run build
```

### 4. Run Migrations

```bash
php artisan migrate --force
```

### 5. Clear and Warm Caches

```bash
php artisan optimize
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 6. Restart Queue Workers

```bash
php artisan queue:restart
# If using Supervisor:
sudo supervisorctl restart [queue-worker-name]:*
```

### 7. Disable Maintenance Mode

```bash
php artisan up
```

---

## Post-Deploy Verification

- [ ] Health check URL returns 200: `curl -I https://[domain]/health`
- [ ] Login flow works end-to-end
- [ ] Key feature smoke test: [describe test]
- [ ] Queue workers processing: check Horizon / logs
- [ ] Error rate normal: check [monitoring URL]
- [ ] Response times normal: check [APM URL]

> Wait **10 minutes** before declaring deploy successful.

---

## Rollback Procedure

### Quick Rollback (Code Only)

```bash
git checkout [previous-tag-or-commit]
composer install --no-dev --optimize-autoloader
php artisan optimize
php artisan up
```

### Full Rollback (With Migration Reversal)

Only if migration was destructive and data integrity requires it:

```bash
php artisan migrate:rollback --step=[n]
git checkout [previous-tag]
composer install --no-dev --optimize-autoloader
php artisan optimize
php artisan up
```

> ⚠️ Reverting migrations that dropped columns or tables may cause data loss.
> Always take a database backup before deploying migrations.

---

## Common Incidents

### 500 Errors Spike After Deploy

1. Check Laravel logs: `tail -n 200 storage/logs/laravel.log`
2. Check if migration failed: `php artisan migrate:status`
3. Check config cache is fresh: `php artisan config:cache`
4. If unresolved → rollback

### Queue Workers Not Processing

1. Check worker status: `php artisan queue:monitor`
2. Check failed jobs: `php artisan queue:failed`
3. Restart workers: `php artisan queue:restart`
4. If persistent → check Redis connection

### High Memory / CPU After Deploy

1. Check for N+1 queries in new code
2. Check Telescope or Debugbar for slow queries
3. Check OPcache: `php artisan opcache:status`

---

## Scheduled Tasks

| Command | Schedule | Purpose |
|---|---|---|
| `[artisan command]` | [cron expression] | [description] |

Verify cron is running: `php artisan schedule:list`

---

## Backup Verification

Run monthly or after major changes:

```bash
# Verify backup exists and is recent
[backup check command]

# Test restore to staging
[restore test command]
```
```
