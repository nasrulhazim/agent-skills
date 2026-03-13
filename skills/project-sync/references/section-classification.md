# Section Classification — Shared vs Project-Specific

This reference maps every section in the Kickoff CLAUDE.md template to its merge
classification. Used by the merge algorithm to determine which sections to replace
from source and which to preserve from the target project.

## Classification Rules

| Classification | Meaning |
|---------------|---------|
| **SHARED** | Replace entirely from source during sync |
| **PROJECT-SPECIFIC** | Preserve verbatim from target — never overwrite |
| **MERGE** | Combine items from both source and target (deduplicate) |
| **CONDITIONAL** | Shared subsections replaced; project-specific subsections preserved |

---

## H2 Section Map

| Section (H2) | Classification | Notes |
|--------------|---------------|-------|
| `## Project Overview` | PROJECT-SPECIFIC | Unique to each project |
| `## Common Commands` | PROJECT-SPECIFIC | May have project-specific commands |
| `## Architecture & Key Concepts` | SHARED | All subsections are shared conventions |
| `## File Organization` | SHARED | Standard Kickoff directory structure |
| `## Testing with Pest` | SHARED | Convention for all Kickoff projects |
| `## Livewire Patterns` | SHARED | Standard patterns across projects |
| `## Important Conventions` | CONDITIONAL | See subsection map below |
| `## Release Workflow` | SHARED | Standard release process |
| `## Code Quality Checklist` | SHARED | Standard quality gates |
| `## Packages` | PROJECT-SPECIFIC | Each project has different packages |
| `## Docker Services` | PROJECT-SPECIFIC | May vary per project |
| `## Environment Variables` | PROJECT-SPECIFIC | Unique per project |
| `## Quick Reference` | PROJECT-SPECIFIC | May have custom commands |
| `## Gotchas` | CONDITIONAL | See gotcha classification below |
| `## Claude Self-Update Practice` | SHARED | Standard practice |
| `## Claude Operating Principles` | SHARED | Standard principles |
| Any unlisted H2 section | PROJECT-SPECIFIC | Custom additions preserved |

---

## H3 Subsection Map — Architecture & Key Concepts

All subsections under `## Architecture & Key Concepts` are **SHARED**:

| Subsection (H3) | Classification |
|-----------------|---------------|
| `### Models - CRITICAL` | SHARED |
| `### Database Conventions` | SHARED |
| `### Enums` | SHARED |
| `### Authorization` | SHARED |
| `### Application Settings` | SHARED |
| `### Helper Functions` | SHARED |
| `### Directory Conventions` | SHARED |

---

## H3 Subsection Map — Livewire Patterns

All subsections under `## Livewire Patterns` are **SHARED**:

| Subsection (H3) | Classification |
|-----------------|---------------|
| `### Toast Notifications (Primary)` | SHARED |
| `### Confirmations` | SHARED |
| `### Page Header Pattern` | SHARED |
| `### Mail — Always Queued` | SHARED |

---

## H3 Subsection Map — Important Conventions

| Subsection (H3) | Classification | Notes |
|-----------------|---------------|-------|
| `### UI Requirements — MUST HAVE` | SHARED | |
| `### Icons — Lucide via Flux` | SHARED | |
| `### DO` | MERGE | Source items + project-only items, dedup |
| `### DON'T` | MERGE | Source items + project-only items, dedup |

---

## Gotcha Classification

Gotchas are classified by their H3 parent section under `## Gotchas`:

| Gotcha Section (H3) | Classification | Notes |
|---------------------|---------------|-------|
| `### Livewire 4` | SHARED | Standard Livewire gotchas |
| `### Flux UI` | SHARED | Standard Flux UI gotchas |
| `### TailwindCSS v4` | SHARED | Standard TailwindCSS gotchas |
| `### Forms & Grid Layout` | SHARED | Standard form gotchas |
| `### Horizon & Queues` | SHARED | Standard Horizon gotchas |
| `### BackedEnum` | SHARED | Standard enum gotchas |
| Any unlisted H3 under Gotchas | PROJECT-SPECIFIC | Project-specific gotchas preserved |

---

## Inline Gotchas

Some gotchas appear inline within shared sections (not under `## Gotchas`). These are
part of their parent section and follow the parent's classification:

| Location | Classification |
|----------|---------------|
| Gotcha inside `### Database Conventions` | SHARED (part of parent) |
| Gotcha inside `### Application Settings` | SHARED (part of parent) |
| Gotcha inside `### Toast Notifications` | SHARED (part of parent) |
| Gotcha inside `### Mail — Always Queued` | SHARED (part of parent) |
| Gotcha inside `### Icons` | SHARED (part of parent) |

---

## DO/DON'T Merge Rules

The DO and DON'T lists use **MERGE** classification — they combine items from both
source and target rather than replacing.

### Merge Procedure

1. **Parse source items** — each line starting with `- ✅ DO` or `- ❌ DON'T`
2. **Parse target items** — same format
3. **Identify source items** — items present in the source CLAUDE.md
4. **Identify project-only items** — items in target but NOT in source
5. **Build merged list**:
   - Start with all source items (in source order)
   - Append project-only items (in target order) after the source items
6. **Deduplicate** — if a project-only item has the same core meaning as a source item
   (even if worded differently), keep only the source version

### Example

**Source DO list**:
```
- ✅ DO extend App\Models\Base for all models
- ✅ DO use dual-key pattern
- ✅ DO use Pest syntax for tests
```

**Target DO list** (project has custom items):
```
- ✅ DO extend App\Models\Base for all models
- ✅ DO use Pest syntax for tests
- ✅ DO use PostgreSQL for all new tables
- ✅ DO prefix admin routes with /admin
```

**Merged result**:
```
- ✅ DO extend App\Models\Base for all models
- ✅ DO use dual-key pattern
- ✅ DO use Pest syntax for tests
- ✅ DO use PostgreSQL for all new tables
- ✅ DO prefix admin routes with /admin
```

Items from source are updated, new source items added, project-only items preserved.
