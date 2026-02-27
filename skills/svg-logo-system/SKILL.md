---
name: svg-logo-system
description: >
  Complete SVG logo system designer that takes a brand brief and produces 25 diverse logo concepts,
  dark/light wordmarks, icon marks, interactive HTML preview galleries, real-world mockup pages,
  and multi-platform export assets. Use this skill whenever the user asks to design a logo, create
  brand identity, generate SVG logos, build a logo system, or wants to explore logo concepts for
  a product, company, or project — even if they just say "design me a logo for X" or "I need a
  logo". Also triggers for refinement tasks like "improve my logo", "generate icon alternatives",
  or "export my logo for all platforms". Outputs follow the same file structure as the
  nasrulhazim/claude-design-logo Claude Code slash command, so files can be dropped directly into
  an existing project.
---

# SVG Logo System Designer

A four-phase methodology for designing production-ready SVG logo systems — from brand discovery
through multi-platform export. Follows the same workflow as the `/design-logo` Claude Code slash
command and produces compatible output files.

## Entry Points

| Trigger | Start at |
|---|---|
| "design a logo", "I need a logo for X" | Phase 1 (full flow) |
| "refine my logo", "I have concepts already" | Phase 2 |
| "generate icon alternatives" | Phase 3 |
| "export my logo", "I need favicons" | Phase 4 |

---

## Phase 1: Discovery & Mass Exploration

### 1.1 Brand Discovery Interview

Ask the user for the following. Keep it conversational — one message, not a form:

- **Brand name** and optional tagline
- **Target audience** (who they are, their context)
- **Industry / product category**
- **Personality keywords** (3–5 words: e.g. bold, minimal, playful, trustworthy, cutting-edge)
- **Color direction** (specific colors, palette name, or "you decide")
- **Style preference** (abstract, lettermark, icon+wordmark, wordmark only — or "explore all")
- **What to avoid** (clichés, colors, styles)

If the user already provided context in their message, extract what you can and only ask for what's missing.

### 1.2 Generate 25 SVG Concepts

Generate exactly **25 diverse SVG logo concepts** and save them as individual `.svg` files.

**Naming:** `logo-01-conceptname.svg` through `logo-25-conceptname.svg`

**Ensure diversity across:**

| Dimension | Variants to include |
|---|---|
| Type | Icon-only mark, wordmark, combination mark, lettermark, monogram |
| Shape language | Circle, shield, hexagon, square, organic, abstract |
| Style | Geometric, typographic, symbolic, illustrative, minimal |
| Layout | Stacked, horizontal, icon-left, icon-right |
| Visual metaphor | At least 5 different metaphors relevant to the brand |

**Design constraints (enforce on every concept):**
- Dark mode first: design on navy `#0B1120` background
- Viewbox: `0 0 400 200` for combination marks, `0 0 200 200` for icon-only
- No raster images, no external fonts — embed or use system fonts, or pure paths
- Every concept must be self-contained and render correctly as a standalone SVG

**Inline the fill colors** — do not rely on `currentColor` unless explicitly designing for theming.

### 1.3 Build Interactive Preview Gallery

Create `preview.html` — a gallery with:
- All 25 SVG concepts displayed as cards
- Dark/light mode toggle (default: dark)
- Logo name label under each card
- Click-to-select interaction (marks the card with a border highlight)
- A "Selected" indicator showing which concept the user has clicked

Read `references/preview-gallery-template.md` for the HTML/JS template to follow.

### 1.4 Present Phase 1 Output

Present all 26 files (`logo-01.svg` through `logo-25.svg` + `preview.html`) using `present_files`.
Tell the user: "Open `preview.html` in your browser. Toggle dark/light mode and pick your favourite
direction. Come back and tell me the number (e.g. 'go with #12') or describe what you liked."

---

## Phase 2: Selection & Refinement

### 2.1 Gather Selection

User tells you which concept they prefer. Ask any clarifying questions needed (adjustments to
color, weight, text, etc.) before proceeding.

### 2.2 Create Four Production Variants

Based on the selected concept, produce four polished SVG files:

| File | Description |
|---|---|
| `logo-dark.svg` | Full wordmark on dark background (`#0B1120`) |
| `logo-light.svg` | Full wordmark on white background (`#FFFFFF`) |
| `logo-icon-dark.svg` | Icon mark only, dark bg, `200×200` viewBox |
| `logo-icon-light.svg` | Icon mark only, light bg, `200×200` viewBox |

Rules:
- Wordmark versions: min effective width 140px worth of content
- Icon versions: must read clearly at 80px and below
- Maintain consistent stroke weights and spacing between dark/light pairs

### 2.3 Build Comprehensive Preview Page

Create `logo-preview.html` with real-world mockup sections:

1. **Navigation bar mockup** — dark and light nav, logo at standard 32px height
2. **Desktop browser frame** — logo in browser chrome
3. **Mobile splash screen** — 375×667px, icon centered
4. **Favicon sizes** — 64px, 32px, 16px side by side (dark and light bg)
5. **Footer placement** — footer strip with logo
6. **Brand color palette** — swatches with hex codes, names

Read `references/preview-mockup-template.md` for the HTML structure.

### 2.4 Present Phase 2 Output

Present all 5 files (`logo-dark.svg`, `logo-light.svg`, `logo-icon-dark.svg`, `logo-icon-light.svg`,
`logo-preview.html`) using `present_files`. Ask: "How does this feel? Any changes to the icon,
typography, or proportions? Or ready to move to icon alternatives (Phase 3)?"

---

## Phase 3: Iteration & Icon Alternatives

### 3.1 Collect Feedback

If the user wants changes to the main logo, implement them and re-present the four production SVGs.

### 3.2 Generate Icon Alternatives (if requested or if icon needs work)

Generate **4 icon alternatives** (A through D) in both dark and light mode = 8 SVG files:

`icon-a-name-dark.svg`, `icon-a-name-light.svg`, `icon-b-name-dark.svg` ... `icon-d-name-light.svg`

Each alternative must look meaningfully different: vary shape, weight, level of detail, or metaphor.

### 3.3 Build Icon Comparison Page

Create `icon-compare.html` showing all four alternatives:
- Each shown at: 80px, 48px, 32px, 16px
- Side by side, dark and light mode
- Clear labeling (A, B, C, D)

### 3.4 Finalize

User picks the winning icon. Update `logo-icon-dark.svg` and `logo-icon-light.svg` with the chosen
alternative. Re-present the final set.

---

## Phase 4: Multi-Platform Export

### 4.1 Generate Export Manifest

Create `export/` directory with the following from the finalized SVGs:

**Favicons:**
- `favicon.svg` — copy of `logo-icon-dark.svg`
- `favicon-16x16.png` description in `_export-manifest.md` (actual PNG generation requires CLI tools)
- `favicon-32x32.png` description
- `favicon-48x48.png` description
- `favicon.ico` — note: requires `rsvg-convert` or ImageMagick

**App Icons:**
- Apple Touch: 180px, 152px, 120px, 76px
- Android/PWA: 192px, 512px, maskable 512px
- Microsoft Tile: 150px, 310px
- OpenGraph: 1200×630

**Web Manifests:**
- `site.webmanifest` — PWA manifest JSON
- `browserconfig.xml` — Microsoft tile config
- `_favicon-meta.html` — ready-to-paste HTML `<head>` meta tags

**For the manifest files:** generate these as real text/JSON files.
**For PNG exports:** generate a `_export-instructions.md` explaining which CLI tool to use
(rsvg-convert recommended, then ImageMagick, Inkscape, sharp-cli as fallbacks).

### 4.2 Laravel Integration Note

If the user mentions a Laravel project, add a `_laravel-deploy.md` with instructions for:
- Copying files to `public/`
- Updating Blade favicon meta tags
- Handling dark/light logo switching in Blade
- Breeze/Jetstream/Livewire layout locations

(Actual file deployment is done by the `/design-logo export laravel` Claude Code command —
this skill produces the assets and instructions.)

### 4.3 Present Export Output

Present all generated text/SVG files from `export/`. Tell the user the PNG files need CLI
conversion and point to `_export-instructions.md`.

---

## Output File Structure

All files should be organized to match the Claude Code command output exactly:

```
tinker/
├── logo-{01..25}-{name}.svg
├── preview.html
├── logo-dark.svg
├── logo-light.svg
├── logo-icon-dark.svg
├── logo-icon-light.svg
├── logo-preview.html
├── icon-{a..d}-{name}-{dark|light}.svg
├── icon-compare.html
└── export/
    ├── favicon.svg
    ├── site.webmanifest
    ├── browserconfig.xml
    ├── _favicon-meta.html
    ├── _export-instructions.md
    └── _laravel-deploy.md  (if Laravel project)
```

When presenting files to the user in Claude.ai, group by phase and present the HTML files first
(they're the ones the user needs to open in browser).

---

## Design Principles (Enforce Throughout)

- **Dark mode first** — start on `#0B1120`, then adapt for light
- **Size-aware** — wordmarks at 140px+, icons at 80px and below
- **Legibility** — contrast ratio must pass WCAG AA minimum
- **Simplicity scales** — fewer elements survive better at 16px
- **Self-contained SVGs** — no external dependencies
- **Consistent palette** — derive all tints/shades from the core brand colors

---

## Reference Files

- `references/preview-gallery-template.md` — HTML/JS template for Phase 1 gallery
- `references/preview-mockup-template.md` — HTML structure for Phase 2 mockup page
