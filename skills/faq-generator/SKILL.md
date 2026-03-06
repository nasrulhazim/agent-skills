---
name: faq-generator
metadata:
  compatible_agents: [claude-code]
  tags: [faq, documentation, knowledge-base, multi-audience, marketing, developer, devops, support]
description: >
  Multi-audience FAQ generator that researches a codebase (and optionally related repositories)
  end-to-end, then produces categorized FAQ documents for different stakeholder perspectives:
  business/executive, marketing/sales, project manager, administrator, developer, devops, and
  end user. Use this skill whenever the user asks to create FAQs, generate a knowledge base,
  build support documentation by audience, or produce stakeholder-specific Q&A documents —
  including: "generate FAQ for my project", "create FAQ for different audiences", "buat FAQ
  untuk projek ni", "FAQ for sales team", "developer FAQ", "devops FAQ", "admin FAQ",
  "knowledge base for my product", "support FAQ", "create Q&A docs", or "FAQ by persona".
---

# Multi-Audience FAQ Generator

Researches a codebase comprehensively, then generates **7 audience-specific FAQ documents**
covering every stakeholder perspective — from C-suite executives to end users.

---

## Trigger Detection

Activate when the user asks to generate FAQs, create a knowledge base, or build
audience-specific Q&A documentation for a project.

Before generating anything:
1. **Ask for output path** — where to write the FAQ documents (default: `docs/faq`)
2. **Ask for additional repositories** — the user may have related repos (packages, ops,
   infrastructure) that should be researched alongside the main codebase
3. **Read CLAUDE.md** if it exists — extract project context, architecture, conventions
4. **Read README.md** — understand stated purpose and features
5. **Read composer.json / package.json** — understand tech stack and dependencies

---

## Interview Phase

Ask the user these questions before starting research:

**Block 1 — Scope & Output**

- Where should the FAQ documents be written? (default: `docs/faq`)
- Are there additional repositories to research? (e.g., core packages, ops/infra repos,
  reporting packages) — provide full paths
- What is the product name and company? (or auto-detect from CLAUDE.md / README.md)

**Block 2 — Audience Selection (Optional)**

- Which audiences do you need? (default: all 7)
  1. Business / Executive
  2. Marketing / Sales
  3. Project Manager
  4. Administrator
  5. Developer
  6. DevOps / Infrastructure
  7. API Consumer / End User

If the user says "all" or doesn't specify, generate all 7.

After confirming scope, proceed to research.

---

## Research Phase

### Phase 1: Deep Codebase Exploration (Parallel)

Launch **parallel exploration agents** — one per repository — to gather comprehensive
information. Each agent should study:

| Area | What to Extract |
|---|---|
| Features & capabilities | All user-facing features, toggles, config options |
| Models & data schema | Database tables, relationships, key fields |
| User roles & permissions | Role definitions, permission naming, access control |
| Workflows & lifecycles | State machines, approval flows, automation |
| Commands & CLI | Artisan/CLI commands with descriptions |
| API endpoints | REST/GraphQL routes, authentication methods |
| Configuration | Config files, environment variables, defaults |
| Deployment & infrastructure | Server requirements, deployment scripts, architecture |
| Monitoring & reporting | Health checks, metrics, reporting tiers |
| Security | Auth methods, SSO, encryption, audit trails |
| Integrations | Third-party services, external systems |
| Notifications | Email, Slack, in-app notification events |
| Background services | Queue workers, schedulers, long-running processes |
| Troubleshooting patterns | Common errors, known gotchas, debugging commands |

### Phase 2: Cross-Repository Synthesis

After all agents complete, synthesize findings into a unified knowledge map before
generating documents. Identify:
- Features that span multiple repos (e.g., monitoring across core + reporting + ops)
- Deployment details from ops repo that inform DevOps FAQ
- Package capabilities from core that inform Developer FAQ
- Business/pricing data from sales materials that inform Marketing FAQ

---

## Output Structure

```
{output_path}/
├── README.md                      # Index with audience table and usage guide
├── 01-business-executive.md       # C-suite, decision makers
├── 02-marketing-sales.md          # Sales teams, pre-sales engineers
├── 03-project-manager.md          # IT managers, project leads
├── 04-administrator.md            # System administrators
├── 05-developer.md                # Software developers
├── 06-devops.md                   # DevOps / infrastructure engineers
└── 07-api-consumer.md             # End users / API consumers
```

---

## Document Specifications

### README.md — FAQ Index

Must contain:
- **Document table** — file, audience, description for each FAQ
- **Usage section** — how these FAQs can be used (knowledge base, sales enablement,
  support reference, client documentation)
- **Last updated date**

---

### 01 — Business & Executive FAQ

**Audience:** C-suite, decision makers, organizational leaders

**Required Sections:**
- General (what is it, what problem it solves, who it's for)
- Deployment & Data Sovereignty (SaaS vs on-prem, infrastructure, cloud support)
- Security & Compliance (access control, audit trail, SSO, credential storage)
- Cost & Licensing (model, limits, what's included)
- Capabilities (multi-environment, reporting, documentation, disaster recovery)
- Integration (gateway support, monitoring, notifications)

**Tone:** Non-technical, focus on business value, ROI, risk mitigation, compliance.

---

### 02 — Marketing & Sales FAQ

**Audience:** Sales teams, pre-sales engineers, marketing

**Required Sections:**
- Positioning (one-sentence description, elevator pitch, ideal customers, verticals)
- Differentiators (comparison tables vs competitors, unique value propositions)
- Objection Handling (common objections with structured rebuttals)
- Pricing Context (what's included, add-ons, maintenance)
- Technical Quick Answers (one-liners for common pre-sales questions)

**Tone:** Persuasive, confident, backed by concrete numbers and feature lists.

**Special:** Include comparison tables (e.g., vs Kong Manager, vs alternatives).
Include quantified stats (model count, component count, event count) to demonstrate
depth and maturity.

---

### 03 — Project Manager FAQ

**Audience:** IT managers, project leads, team leads

**Required Sections:**
- Planning & Timeline (deployment time, prerequisites, required skills)
- Roles & Responsibilities (user roles, custom roles, approval chains)
- Workflows (service lifecycle, subscription lifecycle, sync process)
- Risk & Compliance (failure scenarios, data retention, change tracking)
- Maintenance & Updates (support, update procedure, scheduled tasks)
- Integration (existing systems, documentation, notifications table)

**Tone:** Structured, risk-aware, focused on planning and governance.

---

### 04 — Administrator FAQ

**Audience:** System administrators, day-to-day operators

**Required Sections:**
- User Management (creating users, access groups, SSO, roles vs groups)
- API Service Management (CRUD workflow, status effects, routes, plugins, sync states)
- Subscription Management (approval, bulk operations, extend, revoke)
- Kong Management (connectivity, sync modes, multiple environments, protected services)
- Monitoring & Reports (available reports, Horizon, request logs, CSV export)
- Common Tasks (scheduled tasks check, restart services, health check, clear caches)
- Troubleshooting (common issues with step-by-step fixes)

**Tone:** Procedural, step-by-step, includes commands and UI navigation paths.

---

### 05 — Developer FAQ

**Audience:** Software developers extending or integrating with the system

**Required Sections:**
- Architecture (tech stack, codebase structure, model hierarchy, core models table)
- Customization (override components, views, models, permissions, event listeners)
- Kong Integration (sync internals, programmatic plugin creation, ACL format, connection resolver)
- API Integration (REST endpoints, auth guards, mock API)
- Testing (framework, commands, database, factory gotchas)
- Development Workflow (dev server, code quality commands, action patterns)
- Key Gotchas (observer side-effects, API response format, naming conventions)

**Tone:** Technical, code-focused, includes code snippets and file path references.

---

### 06 — DevOps & Infrastructure FAQ

**Audience:** DevOps engineers, system engineers, infrastructure teams

**Required Sections:**
- Deployment (architecture diagram, server requirements, software stack, methods, runbook phases)
- Networking & Security (port table, SSL setup, Kong Admin security, OS differences table)
- Background Services (process table, scheduled tasks table with cron entry)
- Monitoring (tier comparison table, Tier 2 setup steps, Tier 3 setup steps, ELK requirements)
- Data Retention (retention policy table)
- Updates & Maintenance (update commands, backup checklist)
- Troubleshooting (common issues with fix commands, verification commands)
- Per-Client Deployment (client config, unique values per client)

**Tone:** Operations-focused, includes architecture diagrams (ASCII), command blocks,
configuration snippets, and port/service tables.

---

### 07 — API Consumer / End User FAQ

**Audience:** People who use the platform to discover and subscribe to APIs

**Required Sections:**
- Getting Started (what is this, how to log in, what can I do)
- API Catalogue (browsing, visibility, information available)
- Subscriptions (how to subscribe, approval time, what happens after, multiple APIs, status meanings)
- API Keys & Authentication (where to find, how to use, multiple keys, compromised key)
- Subscription Expiry & Renewal (do they expire, what happens, how to renew)
- Troubleshooting (401, 403, missing subscribe button, missing notifications)

**Tone:** Simple, non-technical, friendly, step-by-step. Assume no prior API knowledge.

---

## Writing Rules

1. **Every answer must be sourced from actual codebase research** — never fabricate features
2. **Use tables for structured data** — roles, permissions, ports, retention policies, comparisons
3. **Include commands where relevant** — artisan commands, bash commands, curl examples
4. **Use consistent terminology** — same terms across all 7 documents
5. **Each Q&A should be self-contained** — readers should not need to read other FAQs
6. **Order questions by frequency/importance** — most common questions first
7. **Include status/version info** — mention current versions, supported OS, etc.
8. **Cross-reference between documents** — if an admin FAQ mentions a DevOps setup step,
   note "see DevOps FAQ for setup details"
9. **Bilingual triggers** — support both English and Bahasa Malaysia activation phrases

---

## Adapting to Different Project Types

The 7-audience structure adapts based on project type:

| Project Type | Adapt |
|---|---|
| **SaaS product** | Business FAQ emphasizes pricing tiers, MRR. End User FAQ covers self-service |
| **On-premise enterprise** | Business FAQ emphasizes data sovereignty, compliance. DevOps FAQ is detailed |
| **Open-source library** | Skip Marketing/Sales. Developer FAQ is primary. Add Contributor FAQ |
| **Internal tool** | Skip Marketing/Sales. Focus on Admin, Developer, End User |
| **API-first product** | Developer FAQ is primary. End User FAQ covers API integration |

If fewer than 7 audiences are relevant, skip the irrelevant ones rather than generating
thin documents.

---

## Reference Files

| File | Read When |
|---|---|
| `references/faq-patterns.md` | Structuring Q&A content, question phrasing patterns |
