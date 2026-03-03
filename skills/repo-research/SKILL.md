---
name: repo-research
metadata:
  compatible_agents: [claude-code]
  tags: [research, analysis, architecture, mermaid, documentation, saas, reverse-engineering]
description: >
  Deep repository research and analysis skill — studies any codebase end-to-end and produces
  a comprehensive research/ folder with 10 structured documents covering architecture,
  workflows, algorithms, frontend, configuration, deployment, testing, limitations, and
  SaaS opportunity analysis. Every document includes Mermaid.js diagrams (flowcharts,
  sequence diagrams, class diagrams, ER diagrams, mindmaps, Gantt charts). Use this skill
  whenever the user asks to study a repo, analyze a codebase, reverse-engineer architecture,
  create technical documentation from source, or plan a competing/improved product — including:
  "study this repo", "analyze this codebase", "reverse engineer this", "buat research pasal
  repo ni", "nak faham architecture dia", "document how this works", "study & analysis",
  "I want to build a better version of this", or "SaaS opportunity for this tool".
---

# Repository Research & Analysis

Produces a **complete research/ folder** with 10 structured documents and 50+ Mermaid diagrams
that fully explain how a codebase works — from high-level architecture down to individual
algorithms — with a SaaS opportunity analysis for building a superior product.

**Always produces all 10 documents together** — never partial output.

---

## Trigger Detection

If the user points to a specific repository or codebase, use that as the target.
If no target is specified, analyze the **current working directory**.

Before generating anything:
1. **Read CLAUDE.md** if it exists — extract project context
2. **Read README.md** — understand stated purpose
3. **Read composer.json / package.json** — understand tech stack and dependencies
4. Explore `src/`, `app/`, `lib/`, or equivalent source directories

---

## Research Process

### Phase 1: Deep Exploration (Parallel)

Launch **5 parallel exploration agents** to study the codebase concurrently:

| Agent | Focus | Key Files |
|---|---|---|
| 1 — Core Engine | Main business logic classes, algorithms, data flow | `src/`, `app/`, core modules |
| 2 — CLI / API Layer | Entry points, commands, controllers, routes | Console commands, controllers, routes |
| 3 — Configuration & Schema | Config files, validation, schemas, env vars | `config/`, schema files, `.env.example` |
| 4 — Tests & Quality | Test suite, CI/CD, static analysis, code standards | `tests/`, `phpunit.xml`, CI workflows |
| 5 — Frontend & UI | Templates, JS/CSS, build tools, UI components | `views/`, `resources/`, `webpack.config` |

**Every source file must be fully read** — no skimming. Document every public method,
constructor dependency, and configuration option.

### Phase 2: Documentation Generation

After all agents complete, produce the 10 research documents sequentially.

---

## Output Structure

```
research/
├── README.md                          # Index with document table and quick stats
├── 01-architecture-overview.md        # System context, components, data flow
├── 02-core-build-workflow.md          # End-to-end pipeline, orchestration
├── 03-core-engine-deep-dive.md        # Heart of the system — algorithms, logic
├── 04-builder-output-system.md        # How outputs are generated
├── 05-frontend-architecture.md        # UI components, JS modules, CSS
├── 06-configuration-system.md         # Schema, options, validation
├── 07-deployment-distribution.md      # Docker, CI/CD, packaging
├── 08-testing-quality.md              # Test suite, coverage, quality gates
├── 09-limitations-gaps.md             # Weaknesses, missing features, tech debt
└── 10-saas-opportunity.md             # Product vision, architecture, pricing
```

---

## 1. README.md — Research Index

Must contain:
- **Document index table** — numbered links to all 10 documents
- **Quick stats** — version, language, dependencies, LOC, test count
- **What is this project?** — 2-3 paragraph summary
- **Why study this?** — motivation for the research

---

## 2. Architecture Overview (01)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| System context (graph LR) | External systems → This system → Consumers |
| Component architecture (graph TB) | All internal modules and their relationships |
| Directory structure (graph LR) | File tree with purpose annotations |
| Data flow (flowchart TD) | Input → Processing stages → Output |
| Class dependency (classDiagram) | Key classes, interfaces, inheritance |
| Technology stack (graph TB) | Grouped by layer: backend, frontend, build, quality, deploy |

### Required Content
- Key design decisions table (Decision / Choice / Rationale)
- Component responsibility summary

---

## 3. Core Workflow (02)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Full sequence diagram | User → System → All components → Output |
| Arguments & options (graph LR) | CLI args or API params with defaults |
| Config loading flow (flowchart TD) | Load → Parse → Validate → Error handling |
| Orchestration order (flowchart LR) | Numbered steps with color-coded phases |
| Error handling strategy (flowchart TD) | Error types → Recovery paths |
| State diagram | System lifecycle states |

### Required Content
- Step-by-step execution flow with code references
- Incremental/partial execution explanation if applicable

---

## 4. Core Engine Deep Dive (03)

This is the **most important document** — the algorithmic heart of the system.

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Main algorithm flowchart | The core algorithm with every decision point |
| Sub-algorithm flows | Supporting algorithms called by the main one |
| Data model (erDiagram) | Entity relationships |
| State/config flags (graph LR) | Boolean flags and their effects |
| Pipeline stages (flowchart LR) | Processing pipeline with filters |

### Writing Rules
- **Every branch in the algorithm** must be documented
- **Every configuration flag** that affects behaviour must be explained
- Include **why** decisions were made, not just what happens
- Reference exact line numbers where possible

---

## 5. Output/Builder System (04)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Builder class hierarchy (classDiagram) | Abstract → Concrete implementations |
| Each builder's dump flow (flowchart TD) | Internal processing of each output type |
| Output file structure (graph TB) | Generated file tree |
| Timeline (gantt) | Execution phases with relative durations |

---

## 6. Frontend Architecture (05)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Component init flow (graph TB) | Bootstrap sequence |
| Component responsibility (mindmap) | Each component's features |
| Key component flows (flowchart TD) | Search, filter, interaction flows |
| Animation sequences (sequenceDiagram) | UI state transitions |
| Build pipeline (flowchart LR) | Source → Loaders → Plugins → Output |
| Storage schema (graph TB) | localStorage / sessionStorage keys |

Skip this document if the project has no frontend.

---

## 7. Configuration System (06)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Full config schema (mindmap) | Every option grouped by category |
| Validation flow (flowchart TD) | Parse → Validate → Error handling |
| Config precedence (flowchart TD) | File → Env → CLI override order |
| Required vs optional (graph TB) | Color-coded field importance |

### Required Content
- **Minimal example config** — simplest working configuration
- **Full-featured example config** — every option demonstrated
- Explanation of every option with type, default, and purpose

---

## 8. Deployment & Distribution (07)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Distribution methods (graph TB) | All ways the project can be consumed |
| Docker build stages (graph TB) | Multi-stage build if applicable |
| CI/CD pipeline (flowchart TD) | Full GitHub Actions / GitLab CI flow |
| Test matrix (graph TB) | Version combinations tested |
| Deployment architecture (graph TB) | Typical production setup |

### Required Content
- Deployment comparison table (Method / Effort / Automation / Scalability / Cost)

---

## 9. Testing & Quality (08)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Test coverage map (mindmap) | What's tested per module |
| Testing patterns (graph TB) | Patterns used and their benefits |
| Quality gates (flowchart LR) | Local → CI → Merge gate flow |
| Execution flow (sequenceDiagram) | Dev → Git hook → CI → Matrix |

### Required Content
- Test file inventory table (File / Lines / Methods / Focus)
- **Coverage gaps** — explicitly call out what's NOT tested

---

## 10. Limitations & Gaps (09)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Limitation mindmap | All limitations grouped by category |
| Scalability issues (graph TB) | Current approach → Problem it causes |
| Feature gap comparison (graph LR) | This project vs competitors |
| Race conditions / concurrency | Any concurrent access issues |

### Required Content
- **Technical debt table** — Area / Issue / Impact
- **Comparison matrix** — Feature vs This Project vs Competitor A vs Competitor B
- Each limitation must explain **why it matters for a SaaS product**

---

## 11. SaaS Opportunity Analysis (10)

### Required Diagrams

| Diagram Type | Shows |
|---|---|
| Market positioning (quadrantChart) | Feature richness vs Cost matrix |
| Target personas (mindmap) | User segments with needs |
| Proposed architecture (graph TB) | Full SaaS system design |
| Data model (erDiagram) | Multi-tenant data model |
| Build pipeline redesign (flowchart TD) | Event-driven, queue-based |
| Feature roadmap (gantt) | Phase-based product roadmap |
| Pricing strategy (graph TB) | Tier comparison |
| Migration path (flowchart TD) | From existing tool → SaaS |
| Revenue projection (xychart-beta) | MRR over time |

### Required Content
- **Vision statement** — one paragraph
- **Competitive advantages** — why users should choose this over alternatives
- **Technology stack proposal** — recommended stack for the SaaS
- **Key risks & mitigations table** — Risk / Probability / Impact / Mitigation
- **Summary** — 2-3 paragraph pitch for the product

---

## Diagram Style Rules

All Mermaid diagrams must follow these rules:

1. **Use appropriate diagram type** — don't force everything into flowcharts
2. **Label every node** — no ambiguous boxes
3. **Use subgraphs** for grouping related elements
4. **Color-code** with `style` or `fill` for emphasis where useful
5. **Keep diagrams focused** — one concept per diagram, split if too complex
6. **Use consistent naming** — same component name across all diagrams
7. **Add notes** in sequence diagrams to explain non-obvious steps

### Diagram Type Selection Guide

| Need | Diagram Type |
|---|---|
| Process flow with decisions | `flowchart TD` |
| Time-ordered interactions | `sequenceDiagram` |
| Class hierarchy / interfaces | `classDiagram` |
| Database / data relationships | `erDiagram` |
| Hierarchical categorisation | `mindmap` |
| Project timeline | `gantt` |
| System states | `stateDiagram-v2` |
| Metrics / charts | `xychart-beta` |
| Comparison positioning | `quadrantChart` |

---

## Adapting to Different Project Types

The 10-document structure adapts based on project type:

| Project Type | Adapt |
|---|---|
| **CLI tool** | Doc 03 focuses on command pipeline, Doc 05 may be skipped |
| **Web framework** | Doc 03 focuses on request lifecycle, Doc 05 covers views/components |
| **Library / SDK** | Doc 03 focuses on public API surface, Doc 02 covers usage patterns |
| **API service** | Doc 03 focuses on endpoint logic, Doc 06 covers API schema |
| **Full-stack app** | All 10 documents apply fully |

Rename document titles to match the project's domain language:
- For a build tool: "Core Build Workflow" → "Build Pipeline"
- For an API: "Core Engine" → "Request Processing Engine"
- For a game: "Core Engine" → "Game Loop & State Machine"

---

## Writing Rules

1. **Read every source file completely** — no assumptions
2. **Reference exact file paths and line numbers** where relevant
3. **Explain WHY, not just WHAT** — design rationale matters
4. **Use tables for comparisons** — they're scannable
5. **Keep diagrams self-contained** — each should make sense without reading the text
6. **Write for a senior engineer** — assume competence, skip basics
7. **Be opinionated in the SaaS analysis** — this is a product brief, not a report
8. **Bilingual triggers** — support both English and Bahasa Malaysia

---

## Output Files

| File | Path |
|---|---|
| Research index | `research/README.md` |
| 10 analysis documents | `research/01-*.md` through `research/10-*.md` |

Present files via the research/README.md — it's the entry point the user opens first.

---

## Reference Files

| File | Read When |
|---|---|
| `references/document-templates.md` | Starting a new research — get section templates |
| `references/mermaid-patterns.md` | Designing diagrams — get syntax patterns and examples |
| `references/saas-analysis-framework.md` | Writing the SaaS opportunity doc — get frameworks |
