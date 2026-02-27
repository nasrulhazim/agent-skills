---
name: project-requirements
metadata:
  compatible_agents: [claude-code]
  tags: [requirements, srs, proposal, user-stories, wireframe]
description: >
  Interview-driven requirements engineering toolchain — SRS documents, user stories, client
  proposals, ASCII wireframes, and traceability matrices. Use this skill whenever the user asks
  to write requirements, create an SRS, generate user stories, build a project proposal, sketch
  wireframes, or trace requirements to tests — including: "buat SRS untuk sistem ni", "tulis
  proposal untuk client", "user stories untuk projek ni", "wireframe untuk login page",
  "generate requirements spec", "write a proposal for this project", "create acceptance criteria",
  "trace my requirements", "I need a traceability matrix", or "help me with project requirements".
  Supports bilingual (BM/EN) proposals and government RFP response format for Malaysian context.
  Integrates with the sales-planner skill for pricing sections in proposals.
---

# Project Requirements

Interview-driven requirements engineering — from stakeholder discovery through traceable
specifications. Produces IEEE 830-inspired SRS documents, user stories with acceptance criteria,
client-facing proposals, ASCII wireframes, and full traceability matrices.

## How It Works

1. **Interview first** — every command starts by gathering context through structured questions
2. **Generate artefact** — produce the document using reference templates
3. **Cross-link** — connect requirements to stories, stories to tests, tests back to requirements

Always check if an existing SRS or requirements document exists before starting from scratch.
If the user pastes requirements inline, extract and structure them rather than re-asking.

---

## Command Reference

| Command | Description |
|---|---|
| `/req spec` | Interview → generate SRS document (IEEE 830 simplified) |
| `/req stories` | Generate user stories with acceptance criteria from SRS or interview |
| `/req proposal` | Client-facing project proposal with scope, timeline, pricing |
| `/req wireframe` | ASCII wireframe generation for key screens |
| `/req matrix` | Traceability matrix (requirement → story → test) |

---

## 1. `/req spec` — Software Requirements Specification

### Interview Phase

Ask questions in **four blocks**, one at a time:

**Block 1 — Project Identity**
- What is the project/system name?
- What problem does it solve? (one sentence)
- Who is the primary user? Who are secondary users?
- What is the business context? (internal tool, client project, product, government system)

**Block 2 — Functional Requirements**
- What are the 5–10 core features the system must have?
- For each feature: what does the user do, and what does the system respond with?
- Are there any workflows that span multiple features? Describe them.
- What data does the system manage? (entities, relationships at a high level)

**Block 3 — Non-Functional Requirements**
- Performance expectations? (response time, concurrent users, data volume)
- Security requirements? (authentication, authorisation, data protection, PDPA compliance)
- Availability and uptime requirements?
- Technology constraints? (hosting, framework, language, integrations)

**Block 4 — Constraints & Assumptions**
- What is the timeline? (phases, deadlines)
- What is the budget range? (if relevant)
- What existing systems must this integrate with?
- What assumptions are you making? (e.g., users have internet, data is in BM/EN)
- Any regulatory or compliance requirements? (PDPA, MAMPU, MyGov standards)

After all blocks, confirm: "Here's what I've captured — shall I generate the SRS?"

### Generate

Read `references/srs-template.md` for the full template structure.
Populate every section from interview answers.
Mark genuinely unknown fields as `> TBD — needs stakeholder decision` rather than leaving blank.
Number all requirements using the pattern `REQ-[MODULE]-[NNN]` (e.g., `REQ-AUTH-001`).

Output: `docs/srs-[project-name].md`

---

## 2. `/req stories` — User Stories with Acceptance Criteria

### Input Options

1. **From existing SRS** — parse the SRS and extract stories automatically
2. **From interview** — if no SRS exists, ask:
   - Who are the user roles/personas?
   - What are the key workflows per role?
   - What are the business rules that govern behaviour?

### Generate

Read `references/user-story-patterns.md` for story structure and patterns.

For each functional requirement in the SRS, generate:

```
### US-[NNN]: [Story Title]

**As a** [role]
**I want to** [action]
**So that** [benefit]

**Acceptance Criteria:**

- Given [context], when [action], then [expected result]
- Given [context], when [action], then [expected result]

**Priority:** [Must / Should / Could / Won't]
**Estimate:** [S / M / L / XL]
**Traces to:** REQ-[MODULE]-[NNN]
```

Group stories into epics. Generate a story map showing the walking skeleton.

Output: `docs/user-stories-[project-name].md`

---

## 3. `/req proposal` — Client-Facing Project Proposal

### Interview Phase

Ask in **two blocks**:

**Block 1 — Client & Project**
- Who is the client? (name, organisation, industry)
- What is the project? (one paragraph)
- Is this a response to an RFP/RFQ, or a proactive proposal?
- What language? (English / Bahasa Malaysia / Bilingual)
- Is this for government (kerajaan) or private sector (swasta)?

**Block 2 — Scope & Commercial**
- What are the major deliverables? (system, documentation, training, support)
- What is the proposed timeline? (phases with durations)
- What is the team composition? (roles, not names)
- What is the pricing model? (fixed price, T&M, hybrid)
- If pricing exists in sales-planner product-config.md, reference it directly

After both blocks, confirm scope before generating.

### Generate

Read `references/proposal-template.md` for the full template.

**For government proposals:** Use formal Bahasa Malaysia, include MAMPU/MyGov compliance
references where applicable, structure by Skop Kerja / Jadual Pelaksanaan / Kos Projek.

**For private sector proposals:** Use the client's preferred language, professional but
approachable tone.

**For bilingual proposals:** Generate both versions in a single document with clear section
dividers, or as two separate files if the user prefers.

If the user has a `product-config.md` from the sales-planner skill, pull pricing data directly
rather than asking again.

Output: `docs/proposal-[client-name]-[date].md`

---

## 4. `/req wireframe` — ASCII Wireframe Generation

### Interview Phase

Ask:
- Which screens or pages need wireframing?
- What is the platform? (web, mobile, tablet, responsive)
- What is the layout style? (dashboard, form-heavy, content-focused, wizard/stepper)
- Any specific UI components needed? (sidebar, navbar, data tables, charts)

### Generate

Produce ASCII wireframes using box-drawing characters:

```
+------------------------------------------------------------------+
|  Logo        [Dashboard]  [Users]  [Reports]     [Profile] [Log] |
+------------------------------------------------------------------+
|          |                                                        |
|  SIDEBAR |   Welcome, Ahmad                                      |
|          |                                                        |
|  > Home  |   +-------------------+  +-------------------+        |
|  > Users |   | Active Users      |  | Revenue (MTD)     |        |
|  > Roles |   |       1,247       |  |    RM 45,200      |        |
|    Perms |   +-------------------+  +-------------------+        |
|  > Audit |                                                        |
|  > Sttng |   +----------------------------------------------+    |
|          |   | Recent Activity                               |    |
|          |   |----------------------------------------------|    |
|          |   | User         | Action      | Date            |    |
|          |   | Ahmad        | Login       | 2026-02-27      |    |
|          |   | Siti         | Create User | 2026-02-27      |    |
|          |   | Muthu        | Export PDF  | 2026-02-26      |    |
|          |   +----------------------------------------------+    |
|          |                                                        |
+------------------------------------------------------------------+
|  Footer: (c) 2026 Company Name                                   |
+------------------------------------------------------------------+
```

Generate one wireframe per screen requested. Include annotations below each wireframe
explaining interactive elements, navigation flow, and data sources.

For mobile wireframes, use narrower boxes (40 chars wide).
For responsive views, show both desktop and mobile side by side.

Output: `docs/wireframes-[project-name].md`

---

## 5. `/req matrix` — Traceability Matrix

### Input

Requires an existing SRS (`/req spec` output) and user stories (`/req stories` output).
If neither exists, ask the user to generate them first or provide requirements inline.

### Generate

Produce a full traceability matrix:

```
## Forward Traceability (Requirement → Story → Test)

| Req ID         | Requirement          | Story ID  | Story Title        | Test Case     | Status     |
|---|---|---|---|---|---|
| REQ-AUTH-001   | User login           | US-001    | Login with email   | TC-AUTH-001   | Defined    |
| REQ-AUTH-001   | User login           | US-002    | Login with SSO     | TC-AUTH-002   | Defined    |
| REQ-AUTH-002   | Password reset       | US-003    | Reset via email    | TC-AUTH-003   | Defined    |
| REQ-USER-001   | User CRUD            | US-010    | Create user        | TC-USER-001   | Defined    |
| REQ-USER-001   | User CRUD            | US-011    | Edit user profile  | TC-USER-002   | Defined    |

## Reverse Traceability (Test → Story → Requirement)

[Same data, sorted by test case]

## Coverage Summary

| Category       | Total Reqs | Covered | Uncovered | Coverage |
|---|---|---|---|---|
| Authentication | 5          | 5       | 0         | 100%     |
| User Mgmt     | 8          | 6       | 2         | 75%      |
| Reporting      | 4          | 2       | 2         | 50%      |
| **Total**      | **17**     | **13**  | **4**     | **76%**  |

## Gaps

- REQ-RPT-003 (Export to Excel) — no user story assigned
- REQ-RPT-004 (Scheduled reports) — no user story assigned
- REQ-USER-007 (Bulk import) — story exists but no test case
- REQ-USER-008 (User deactivation) — story exists but no test case
```

Flag any requirements without stories (orphaned requirements) and any stories
without requirements (scope creep risk).

Output: `docs/traceability-matrix-[project-name].md`

---

## Malaysian Context Notes

### Government Projects (Projek Kerajaan)

- Use formal Bahasa Malaysia for proposals unless English is specified
- Reference MAMPU guidelines where applicable
- Include sections for: Skop Projek, Pendekatan Pelaksanaan, Jadual Kerja, Kos Projek
- SRS may need to follow agency-specific templates — ask which agency
- Common compliance: PDPA (Personal Data Protection Act 2010), MyGov standards

### Bilingual Output

When generating bilingual documents:
- Section headers in both languages: `## Skop Projek / Project Scope`
- Body text in the primary language with key terms in both
- Technical terms can remain in English (API, database, server, deployment)
- Use natural Malaysian register — not overly formal unless it is a government document

### Common Malaysian Project Types

| Type | Malay Term | Notes |
|---|---|---|
| Government system | Sistem Kerajaan | MAMPU compliance, formal BM |
| E-commerce | E-Dagang | SSM registration, payment gateway |
| School/education | Sistem Pendidikan | MOE compliance, bilingual UI |
| Healthcare | Sistem Kesihatan | KKM compliance, PDPA critical |
| Financial | Sistem Kewangan | BNM regulations, audit trail |

---

## Output Files

When generating documents, save with these names:

| Output | Filename |
|---|---|
| SRS document | `docs/srs-[project-name].md` |
| User stories | `docs/user-stories-[project-name].md` |
| Proposal (EN) | `docs/proposal-[client]-[date].md` |
| Proposal (BM) | `docs/proposal-[client]-[date]-bm.md` |
| Wireframes | `docs/wireframes-[project-name].md` |
| Traceability matrix | `docs/traceability-matrix-[project-name].md` |

All files are Markdown. Present them via `present_files` so the user can download.

---

## Reference Files

| File | Read When |
|---|---|
| `references/srs-template.md` | Generating an SRS document, or showing the user the SRS structure |
| `references/proposal-template.md` | Generating a client proposal, government RFP response, or bilingual proposal |
| `references/user-story-patterns.md` | Writing user stories, acceptance criteria, story mapping, or estimation |
