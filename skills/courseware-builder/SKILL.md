---
name: courseware-builder
metadata:
  compatible_agents:
    - claude-code
    - laravel-cloud
  tags:
    - courseware
    - interactive
    - html
    - teaching
    - slides
    - animation
    - diagram
    - tutorial
    - training
description: >
  Interactive HTML courseware builder — turns any technical topic, flow, or process into a
  CD-Courseware-style interactive slide deck with animated diagrams, step-by-step simulation,
  syntax-highlighted code examples, and key points panels. Use this skill whenever the user wants
  to create teaching materials, interactive slides, animated flow diagrams, or step-by-step
  technical walkthroughs — even if they say "buatkan slides untuk topik X", "jadikan courseware",
  "buat interactive tutorial", or "create a lesson on X". Also triggers for "convert my diagram
  to interactive slides" or "build a visual walkthrough for my training".
---

# Courseware Builder

Transform any technical topic into a self-contained interactive HTML courseware file — CD-Courseware-style with animated flow diagrams, step-by-step simulation, syntax-highlighted code examples, and key points panels. Zero external dependencies (except optional Google Fonts CDN).

---

## Phase 1 — Topic Discovery Interview

Ask the user conversationally in **one message** for the following:

1. **Topic** — what are we teaching?
2. **Target audience** — beginners, intermediate, advanced? developers, managers, students?
3. **Language preference** — BM / EN / mixed
4. **Existing outline** — does the user already have a flow, diagram, or step list?
5. **Code language/framework** — PHP, JS, Python, Laravel, etc.
6. **Actors** — who/what is involved in the flow? (e.g. user, server, browser, database)

**Skip this phase** if the user already provided a complete flow, diagram, or step breakdown in their request. Extract the answers from what they gave and confirm before proceeding.

Example interview prompt:

> Nak buat courseware untuk topik apa? Beritahu saya:
> - Topik apa (e.g. "OAuth2 Authorization Code Flow")
> - Untuk siapa (beginner/intermediate/advanced)
> - Bahasa (BM/EN/campur)
> - Ada outline/diagram sedia ada?
> - Bahasa code (PHP/JS/Python/etc.)
> - Siapa actors dalam flow ni? (user, server, browser, db, etc.)

---

## Phase 2 — Content Architecture

Map the topic into **6–12 steps**. Each step must include:

| Field | Description | Rules |
|-------|-------------|-------|
| `title` | Short action phrase | Max 5 words, starts with verb |
| `desc` | What happens + why it matters | 2–3 sentences |
| `actors` | Entities involved in this step | Pick from: `user`, `server`, `browser`, `keycloak`, `gateway`, `db`, `queue`, `external` |
| `points` | Key takeaways | 3–5 items, each typed as `info` / `warn` / `danger` / `success` |
| `code` | Relevant code snippet | Include filename as comment, syntax-highlight via CSS spans |
| `activeStep` | 0-indexed node position | Which node in the flow diagram to highlight |

Refer to `references/step-templates.md` for detailed schema, actor definitions, point type conventions, and content writing guide.

### Architecture Output

Present the step map as a numbered list for user review before generating HTML:

```
Step 1: [title] — [1-line desc] — actors: [list] — active node: [n]
Step 2: ...
```

Wait for user confirmation or adjustments before proceeding to Phase 3.

---

## Phase 3 — Generate HTML Courseware

Generate a **single self-contained HTML file** with zero external dependencies (except optional Google Fonts CDN link).

### Layout Structure

```
┌─────────────────────────────────────────────────────┐
│ HEADER: [brand-left] [course-title-center] [n/N-right] │
├──────────────┬──────────────────────────────────────┤
│  LEFT PANEL  │           RIGHT PANEL                │
│  (330px)     │                                      │
│              │  ┌──────────────────────────────┐    │
│  Step Badge  │  │     FLOW DIAGRAM              │    │
│  Title       │  │  (animated nodes + arrows)    │    │
│  Description │  │                                │    │
│  Actor Tags  │  └──────────────────────────────┘    │
│  Key Points  │  ┌──────────────────────────────┐    │
│              │  │     CODE PANEL                │    │
│              │  │  (syntax highlighted)         │    │
│              │  └──────────────────────────────┘    │
├──────────────┴──────────────────────────────────────┤
│ FOOTER: [◀ Prev] [● ● ● ● ●] [Next ▶] [▶ Simulate] │
│         [═══════════ progress bar ═══════════════]   │
└─────────────────────────────────────────────────────┘
```

### Components

- **Header**: Brand name left, course title center, step counter (`n / N`) right
- **Left Panel** (330px fixed):
  - Step badge (numbered circle)
  - Step title (bold heading)
  - Step description (paragraph)
  - Actor tags (colour-coded pill badges per actor)
  - Key points (colour-coded cards: info=blue, warn=amber, danger=red, success=green)
- **Right Panel** (flexible):
  - Flow diagram: all nodes always visible, active node = highlighted + scaled, completed nodes = green with ✓
  - Code panel: syntax-highlighted snippet with filename header
- **Footer**:
  - Prev / Next buttons
  - Clickable step dots (filled = visited, ring = current, empty = unvisited)
  - Progress bar (smooth transition)
  - ▶ Simulate button (auto-play all steps)

### Interactions

| Trigger | Action |
|---------|--------|
| Next / Prev buttons | Navigate steps |
| Step dot click | Jump to step |
| Node click | Jump to that node's step |
| ▶ Simulate | Auto-play at 900ms/step with packet animation along arrows |
| `→` or `Space` | Next step |
| `←` | Previous step |
| `Enter` | Start/stop simulate |

### Syntax Highlighting

CSS-only syntax highlighting via span classes — **no external libraries**:

| Class | Purpose | Example colour |
|-------|---------|----------------|
| `.kw` | Keyword | `#c792ea` (purple) |
| `.fn` | Function name | `#82aaff` (blue) |
| `.str` | String literal | `#c3e88d` (green) |
| `.cmt` | Comment | `#546e7a` (grey) |
| `.var` | Variable | `#f78c6c` (orange) |
| `.cls` | Class name | `#ffcb6b` (gold) |
| `.num` | Number | `#f78c6c` (orange) |
| `.arr` | Arrow / operator | `#89ddff` (cyan) |

### Animations

- **Slide-in**: left panel content slides in on step change (CSS `translateX` + `opacity`)
- **Node active**: scale 1.15 + glow box-shadow on active node
- **Packet animation**: a dot travels along the arrow path from source to target node during simulate
- **Progress bar**: smooth `transition: width 0.4s ease`
- **Notify toast**: brief toast message on simulate start/end

### Themes

Three built-in themes defined in `references/themes.md`:

| Theme | Audience | Default? |
|-------|----------|----------|
| **Dark Cyberpunk** | Developers, tech workshops | Yes |
| **Light Editorial** | Non-technical, management, students | No |
| **Warm Malaysian** | Community events, BM workshops | No |

Select theme based on target audience from Phase 1. User can override.

Refer to `references/html-template.md` for the complete HTML boilerplate, render function, simulate function, keyboard handler, and CSS patterns.

---

## Phase 4 — Output

### File Naming

```
{topic-slug}-courseware.html
```

Examples:
- `oauth2-auth-code-flow-courseware.html`
- `laravel-request-lifecycle-courseware.html`
- `git-branching-strategy-courseware.html`

### Quality Checklist

Before saving the file, verify:

- [ ] All steps have complete content (title, desc, actors, points, code, activeStep)
- [ ] Flow diagram renders all nodes with correct active highlighting
- [ ] Simulate auto-plays through all steps with packet animation
- [ ] Keyboard navigation works (→/Space, ←, Enter)
- [ ] Step dots are clickable and reflect current position
- [ ] Progress bar updates smoothly
- [ ] Zero external dependencies (except optional Google Fonts CDN)
- [ ] Code snippets have proper syntax highlighting
- [ ] Actor tags display with correct colours
- [ ] Key points cards show correct type styling (info/warn/danger/success)

### Delivery

Save the file and present it to the user. Include in the summary:

- Total step count
- Keyboard shortcuts reminder: `→`/`Space` = next, `←` = prev, `Enter` = simulate
- File path

---

## Reference Files

| File | Purpose |
|------|---------|
| `references/step-templates.md` | Step content schema, actor definitions, point types, writing guide |
| `references/themes.md` | CSS variables, font pairings, theme selection guide for all 3 themes |
| `references/html-template.md` | Complete HTML boilerplate, render/simulate functions, CSS patterns |
