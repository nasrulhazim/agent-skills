# Document Templates

Section templates for each of the 10 research documents. Copy and adapt these skeletons.

---

## README.md Template

```markdown
# [Project Name] — Deep Research & Analysis

> A senior software engineer's comprehensive study of `[vendor/project]` — [one-line purpose]
> — with the goal of building a more robust, SaaS-ready alternative.

## Document Index

| # | Document | Focus |
|---|----------|-------|
| 01 | [Architecture Overview](./01-architecture-overview.md) | High-level system architecture, component map, data flow |
| 02 | [Core Workflow](./02-core-workflow.md) | End-to-end pipeline, command orchestration |
| 03 | [Core Engine Deep Dive](./03-core-engine-deep-dive.md) | The heart — algorithms, filtering, resolution |
| 04 | [Output System](./04-output-system.md) | Output generation — JSON, HTML, files |
| 05 | [Frontend Architecture](./05-frontend-architecture.md) | Web UI components, JS modules, CSS |
| 06 | [Configuration System](./06-configuration-system.md) | Schema, options, validation |
| 07 | [Deployment & Distribution](./07-deployment-distribution.md) | Docker, CI/CD, packaging |
| 08 | [Testing & Quality](./08-testing-quality.md) | Test suite, static analysis, code standards |
| 09 | [Limitations & Gaps](./09-limitations-gaps.md) | Current weaknesses, missing features |
| 10 | [SaaS Opportunity](./10-saas-opportunity.md) | Product vision, architecture, pricing |

## Quick Stats

| Metric | Value |
|--------|-------|
| Version | [x.y.z] |
| Language | [PHP 8.x / Node / Go / etc.] |
| Core Dependencies | [List 3-5 main deps] |
| Test Framework | [PHPUnit / Pest / Jest / etc.] |
| Static Analysis | [PHPStan / ESLint / etc.] |
| Lines of Source | [~N,NNN] |
| Lines of Tests | [~N,NNN] |

## What is [Project]?

[2-3 paragraphs explaining what this project does, who uses it, and how it works at a high level.]

## Why Study This?

[2-3 bullets explaining the motivation for this research — building something better, understanding patterns, etc.]
```

---

## 01 — Architecture Overview Template

Required sections:

1. **System Context** — System context diagram showing external systems, this system, and consumers
2. **Component Architecture** — Internal module graph with relationships
3. **Directory Structure Map** — File tree with purpose annotations per directory
4. **Data Flow Architecture** — Input → Processing stages → Output pipeline
5. **Class Dependency Graph** — Key classes with inheritance and composition
6. **Technology Stack** — Grouped by layer (backend, frontend, build, quality, deploy)
7. **Key Design Decisions** — Table: Decision / Choice / Rationale

---

## 02 — Core Workflow Template

Required sections:

1. **Entry Point** — Full sequence diagram showing the complete workflow
2. **Arguments & Options** — All CLI args, API params, or config inputs
3. **Processing Phases** — Numbered phases with color-coded flow
4. **Error Handling Strategy** — Error types and recovery paths
5. **Incremental/Partial Mode** — How filtered or partial execution works
6. **System Lifecycle** — State diagram of the full lifecycle

---

## 03 — Core Engine Deep Dive Template

Required sections:

1. **Overview** — What this engine does and why it's the heart of the system
2. **Configuration Flags** — Every flag that affects behaviour
3. **Main Algorithm** — The primary algorithm with every decision point
4. **Sub-Algorithms** — Supporting algorithms called by the main one
5. **Data Processing Pipeline** — Filtering and transformation stages
6. **Data Model** — Entity relationships
7. **Edge Cases** — Boundary conditions and special handling

---

## 04 — Output System Template

Required sections:

1. **Builder Pattern Overview** — Class hierarchy diagram
2. **Each Builder's Flow** — Separate flowchart per output type
3. **Output File Structure** — Generated file tree
4. **Output Schema/Format** — JSON schema, HTML structure, or file format details
5. **Execution Timeline** — Gantt chart of builder phases

---

## 05 — Frontend Architecture Template

Required sections:

1. **Overview** — Server-rendered vs SPA, framework choice
2. **Component Architecture** — Init sequence, responsibility map
3. **Component Details** — Each component's flow diagram
4. **Event Handling Patterns** — Common patterns across components
5. **Build Pipeline** — Source → Loaders → Plugins → Output
6. **State Management** — localStorage, URL hash, or state store schema

---

## 06 — Configuration System Template

Required sections:

1. **Full Schema Map** — Mindmap of every option
2. **Validation Flow** — Parse → Validate → Error handling
3. **Configuration Precedence** — File → Env → CLI override order
4. **Category Explanations** — Each group of options explained
5. **Minimal Example** — Simplest working config
6. **Full Example** — Every option demonstrated

---

## 07 — Deployment & Distribution Template

Required sections:

1. **Distribution Methods** — All consumption methods
2. **Container Architecture** — Docker multi-stage build
3. **CI/CD Pipeline** — Full workflow diagram
4. **Test Matrix** — Version combinations
5. **Deployment Architecture** — Typical production setup
6. **Comparison Table** — Method / Effort / Automation / Scalability / Cost

---

## 08 — Testing & Quality Template

Required sections:

1. **Test Suite Overview** — File count, line count, method count
2. **Coverage Map** — Mindmap of what's tested per module
3. **Testing Patterns** — Patterns used and benefits
4. **Quality Gates** — Local → CI → Merge pipeline
5. **Static Analysis Config** — Tool configurations
6. **Coverage Gaps** — What's NOT tested (critical section)

---

## 09 — Limitations & Gaps Template

Required sections:

1. **Architecture Limitations** — Mindmap of all limitations
2. **Scalability Issues** — Current approach → Problem mapping
3. **Feature Gap Analysis** — Comparison with competitors
4. **Detailed Limitation Catalogue** — Each limitation with diagram
5. **UX Limitations** — Web UI, config, operations gaps
6. **Technical Debt Table** — Area / Issue / Impact
7. **Comparison Matrix** — Full feature comparison table

---

## 10 — SaaS Opportunity Template

Required sections:

1. **Vision** — One paragraph product vision
2. **Market Positioning** — Quadrant chart
3. **Target Personas** — Mindmap of user segments
4. **Proposed Architecture** — Full SaaS system design
5. **Data Model** — Multi-tenant ER diagram
6. **Build Pipeline Redesign** — Event-driven architecture
7. **Feature Roadmap** — Gantt chart with phases
8. **Pricing Strategy** — Tier comparison
9. **Competitive Advantages** — Why choose this
10. **Technology Stack** — Recommended stack
11. **Migration Path** — From existing tool to SaaS
12. **Revenue Projections** — Chart with assumptions
13. **Key Risks** — Risk / Probability / Impact / Mitigation table
14. **Summary** — 2-3 paragraph product pitch
