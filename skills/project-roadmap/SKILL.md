---
name: project-roadmap
metadata:
  compatible_agents: [claude-code]
  tags: [roadmap, project-planning, phases, html, markdown]
description: >
  Generates project roadmaps in Nasrul's exact style — always produces BOTH a ROADMAP.md
  (phase-based markdown with checkboxes, exit criteria, dependency map, and quick reference)
  AND a beautiful custom-styled HTML visual roadmap. Use this skill whenever the user asks
  for a roadmap, project plan, implementation plan, development phases, or says "buat roadmap",
  "plan for this project", "phase out the implementation", "apa first step", or "how should
  I build this". Also triggers when a CLAUDE.md exists and the user wants a matching roadmap,
  or when an existing roadmap needs updating based on new decisions. Always generates both
  files together — never just one. The HTML roadmap is styled uniquely per project type
  (not a generic template). Compatible with the nasrulhazim/claude-docs project structure.
---

# Roadmap Generator

Always produces **two files together**:
1. `ROADMAP.md` — machine-readable, Claude Code-friendly, checklist-driven
2. `[project-name]-roadmap.html` — visually styled, unique per project aesthetic

Never generate just one without the other.

---

## Trigger Detection

If a `CLAUDE.md` exists in the project, **read it first** before generating anything.
Extract: project name, stack, MVP scope, phases already decided, any constraints.

If no `CLAUDE.md` exists, interview the user — read `references/interview-guide.md`.

---

## ROADMAP.md Structure

Every `ROADMAP.md` follows this exact structure:

```markdown
# [Project Name] — Product Roadmap

> [tagline or one-liner]

---

## Phase 0 — Foundation (Week [N–N])

*[What this phase proves or sets up]*

- [ ] [Task with enough detail to act on immediately]
- [ ] [Include file paths, artisan commands, package names]
- [ ] [Deploy targets, CI/CD, infra setup here]

---

## Phase 1 — MVP (Week [N–N])

*[Core value — what the user can do after this phase]*

### 1.1 [Sub-feature]
- [ ] [Task]
- [ ] [Task — reference packages: laravel-running-number, laravel-media-secure, etc.]

### 1.2 [Sub-feature]
- [ ] [Task]

### MVP Definition of Done
> [One sentence — what the user can accomplish with MVP. No more, no less.]

---

## Phase 2 — [Name] (Week [N–N] / Month [N–N])

*[Goal of this phase]*

- [ ] [Task]

**Milestone:** [What ships at end of this phase]

---

## [More phases as needed]

---

## MVP Scope

### In ✅
- [Feature that IS in MVP]
- [Feature that IS in MVP]

### Out ❌ (v2+)
- [Feature that is NOT in MVP]
- [Feature that is NOT in MVP]

---

## Dependency Map

```
Phase 0 (Foundation)
  └── Phase 1 (MVP)
        ├── Phase 2 (Enhancement)
        │     └── Phase 3 (Growth)
        └── [Note any phases that can overlap]
```

---

## Tech Debt / Future

- [Package extraction opportunity]
- [Scalability consideration]
- [Feature deferred with reason]

---

## Quick Reference

| Command | Purpose |
|---|---|
| `php artisan [command]` | [What it does] |
| `./vendor/bin/pest` | Run test suite |
| `./vendor/bin/pest --coverage` | Tests with coverage |
```

### Task Writing Rules

Tasks must be **immediately actionable** — not vague:

| ❌ Vague | ✅ Actionable |
|---|---|
| "Setup auth" | "Laravel Breeze (Livewire stack) — auth pages" |
| "Add products" | "Product CRUD (name, image, base_price, category, is_active)" |
| "Running numbers" | "Order number via `laravel-running-number` (`ORD-YYYYMMDD-XXXXXX`)" |
| "Test it" | "Pest: `it('creates order with correct running number')` in `OrderTest`" |

Always reference specific packages from Nasrul's ecosystem where relevant:
- `cleaniquecoders/laravel-running-number` — sequential numbered IDs
- `cleaniquecoders/laravel-media-secure` — file/image uploads
- `cleaniquecoders/laravel-action` — action class scaffolding
- `cleaniquecoders/laravel-expiry` — expiry/validity logic

---

## HTML Visual Roadmap

### Core Rules

1. **Unique aesthetic per project** — read the project's theme/vibe, then design accordingly
2. **Always dark header** — project name, tagline, tech stack pills, phase count
3. **Phase cards** — vertically stacked, phase number prominent, tasks as checkboxes
4. **Color-coded task categories** — different colors per category (infra, backend, frontend, testing, release)
5. **MVP scope section** — visual In ✅ / Out ❌ grid
6. **Footer** — project name · tech stack · company · year

Read `references/html-roadmap-patterns.md` for styling patterns per project type.

### Design Selection Guide

| Project Type | Aesthetic | Font Suggestion | Color Palette |
|---|---|---|---|
| Laravel SaaS / B2B | Clean, professional | Syne + DM Mono | Amber/dark, brand color |
| Game / Gamedev | Dark, dramatic | Any bold display | Team color + dark bg |
| Habit / Lifestyle app | Warm, organic | Amiri + DM Sans | Paper/gold, green |
| Dev tool / Package | Terminal-inspired | DM Mono heavy | Dark bg, green/cyan |
| POS / Retail | Bold, practical | Syne + DM Sans | Amber + dark ink |
| API / Platform | Technical, modern | Inter + JetBrains | Blue/indigo + dark |

### Required HTML Sections (in order)

1. **Header** — project name + tagline + live status badge + tech stack pills
2. **Phase timeline** — all phases as cards
3. **MVP scope** — In ✅ / Out ❌ side by side
4. **Footer** — project · stack · year

### Task Checkboxes in HTML

Use this pattern for every task inside phase cards:

```html
<div class="task">
  <div class="task-check"></div>
  Task description here
</div>
```

CSS — unchecked box with hover effect:
```css
.task { display: flex; align-items: flex-start; gap: 10px; padding: 6px 0; }
.task-check {
  width: 16px; height: 16px; min-width: 16px;
  border: 2px solid [phase-color];
  border-radius: 3px; margin-top: 2px;
}
```

---

## Phase Naming Conventions

Use these as defaults, adjust to project:

| Phase | Default Name | Typical Duration |
|---|---|---|
| 0 | Foundation | Week 1–2 |
| 1 | MVP | Week 3–6 |
| 2 | Enhancement / Engagement | Week 7–10 / Month 3–5 |
| 3 | Growth / Polish | Month 4–6 |
| 4 | Platform / Scale | Month 7–12 |

For smaller projects (packages, tools): use fewer phases, weeks not months.
For games: use milestone names (Pre-Alpha, Alpha, Beta, RC, Launch).

---

## Updating an Existing Roadmap

When the user says "update roadmap based on new CLAUDE.md" or similar:

1. Read the updated `CLAUDE.md`
2. Identify what changed (new decisions, new scope, deferred features)
3. Update `ROADMAP.md`:
   - Move completed tasks to ~~strikethrough~~ or remove
   - Add new tasks from new decisions
   - Update phase timelines if needed
   - Update MVP scope if changed
4. Regenerate the HTML with the same aesthetic — do NOT change the design style
5. Delete the old HTML and present the new one

---

## Output Files

| File | Path |
|---|---|
| Markdown roadmap | `ROADMAP.md` (project root) |
| Visual roadmap | `[kebab-project-name]-roadmap.html` |

Present both files together via `present_files`. Always HTML first — it's what the
user opens in browser.

---

## Reference Files

| File | Read When |
|---|---|
| `references/interview-guide.md` | No CLAUDE.md exists — need to interview user |
| `references/html-roadmap-patterns.md` | Designing the HTML roadmap — CSS patterns, layouts |
