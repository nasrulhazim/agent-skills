---
name: svg-logo-system
metadata:
  compatible_agents: [claude-code]
  tags: [design, svg, logo, branding, favicon, export]
description: >
  Complete SVG logo system designer that takes a brand brief and produces 25 diverse logo concepts,
  dark/light wordmarks, icon marks, interactive HTML preview galleries, real-world mockup pages,
  and multi-platform export assets. Use this skill whenever the user asks to design a logo, create
  brand identity, generate SVG logos, build a logo system, or wants to explore logo concepts for
  a product, company, or project — even if they just say "design me a logo for X" or "I need a
  logo". Also triggers for refinement tasks like "improve my logo", "generate icon alternatives",
  or "export my logo for all platforms". For Laravel projects, auto-deploys to Blade components
  and public/ directory. Outputs follow the same file structure as the nasrulhazim/claude-design-logo
  Claude Code slash command.
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

## Phase 0: Context Extraction (CRITICAL — Always Run First)

Before any design work, extract the project's existing color scheme and conventions. **Never
hardcode default colors** — always derive from the project.

### 0.1 Check for Project Context

Scan the following sources in order of priority:

1. **CLAUDE.md** — may define brand colors, framework, frontend stack
2. **Welcome/landing page** (e.g. `resources/views/welcome.blade.php`) — extract actual CSS
   classes and color values in use (Tailwind classes like `bg-emerald-600`, `text-cyan-500`)
3. **Tailwind config** (`tailwind.config.js`) — custom color definitions
4. **Existing logo components** — check `resources/views/components/*logo*` to understand
   current structure
5. **CSS/SCSS files** — any custom brand color variables

### 0.2 Build Color Map

From the extracted context, establish:

| Variable | Source | Fallback |
|---|---|---|
| `--brand-primary` | Most prominent accent color in UI | `#059669` (emerald-600) |
| `--brand-secondary` | Secondary/complementary color | `#06B6D4` (cyan-500) |
| `--brand-accent` | Highlight/CTA color | `#10B981` (emerald-500) |
| `--dark-bg` | Dark mode background | `#18181B` (zinc-900) |
| `--light-text` | Text on dark | `#E2E8F0` (slate-200) |
| `--muted-text` | Subdued text | `#A1A1AA` (zinc-400) |

> **Lesson learned:** Never assume `#0B1120` navy or `#6366F1` indigo as defaults. Always
> check the project first. If the project uses Tailwind's emerald/cyan, the logo must match.

### 0.3 Detect Framework for Later Deployment

Check if the project is Laravel (artisan file exists), and note:
- Blade component paths (`resources/views/components/`)
- Public directory (`public/`)
- Head partial location (`resources/views/partials/head.blade.php` or layouts)
- Existing favicon files (`public/favicon.*`, `public/apple-touch-icon.png`)

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

If the user already provided context (e.g. CLAUDE.md exists with product description), extract
what you can and only ask for what's missing. If the project has a CLAUDE.md, reference it for
brand context — don't ask the user to repeat what's already documented.

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
- Dark mode first: design on the project's `--dark-bg` color (from Phase 0)
- Viewbox: `0 0 400 200` for combination marks, `0 0 200 200` for icon-only
- No raster images, no external fonts — use system fonts or pure paths
- Every concept must be self-contained and render correctly as a standalone SVG
- Use the project's color map from Phase 0 — not hardcoded defaults
- Include a background `<rect>` in concepts (for preview), but production SVGs must NOT

**Inline the fill colors** — do not rely on `currentColor` unless explicitly designing for theming.

**Performance tip:** Use `<text>` elements with `font-family="system-ui, -apple-system, sans-serif"`
for wordmarks. This is faster than crafting path-based letterforms and renders well cross-platform.

### 1.3 Build Interactive Preview Gallery

Create `preview.html` — a gallery with:
- All 25 SVG concepts displayed as cards
- Dark/light mode toggle (default: dark)
- Logo name label under each card
- Click-to-select interaction (marks the card with a border highlight)
- A "Selected" indicator showing which concept the user has clicked
- Use the project's `--brand-primary` for the selected border color

Read `references/preview-gallery-template.md` for the HTML/JS template to follow.

### 1.4 Present Phase 1 Output

Present all 26 files (`logo-01.svg` through `logo-25.svg` + `preview.html`).
Tell the user: "Open `preview.html` in your browser. Toggle dark/light mode and pick your favourite
direction. Come back and tell me the number (e.g. 'go with #12') or describe what you liked."

### 1.5 Color Corrections

If the user asks to change colors after generation, **use `sed` for bulk find-and-replace** across
all SVG files in the directory. Never rewrite files one by one:

```bash
cd tinker/ && for f in logo-*.svg; do
  sed -i '' 's/#OLD_COLOR/#NEW_COLOR/g' "$f"
done
```

Also update `preview.html` selected-border color to match.

---

## Phase 2: Selection & Refinement

### 2.1 Gather Selection

User tells you which concept they prefer. Ask any clarifying questions needed (adjustments to
color, weight, text, etc.) before proceeding.

### 2.2 Create Four Production Variants

Based on the selected concept, produce four polished SVG files:

| File | Description |
|---|---|
| `logo-dark.svg` | Full wordmark, designed for dark backgrounds (NO background rect) |
| `logo-light.svg` | Full wordmark, designed for white/light backgrounds (NO background rect) |
| `logo-icon-dark.svg` | Icon mark only, `200×200` viewBox, for dark bg (NO background rect) |
| `logo-icon-light.svg` | Icon mark only, `200×200` viewBox, for light bg (NO background rect) |

> **CRITICAL:** Production SVGs must NOT include background `<rect>` elements. They will be
> embedded in Blade components, HTML pages, etc. where the surrounding context provides the
> background. Only the Phase 1 concepts include background rects for standalone preview.

Rules:
- Wordmark versions: min effective width 140px worth of content
- Icon versions: must read clearly at 80px and below
- Maintain consistent stroke weights and spacing between dark/light pairs
- Light versions should use darker fills (e.g. `--dark-bg` for text) instead of light fills
- Use unique gradient IDs per file to avoid conflicts when multiple logos appear on same page

### 2.3 Build Comprehensive Preview Page

Create `logo-preview.html` with real-world mockup sections:

1. **Navigation bar mockup** — dark and light nav, logo at standard 32px height
2. **Desktop browser frame** — logo in browser chrome
3. **Mobile splash screen** — 375×667px, icon centered
4. **Favicon sizes** — 64px, 32px, 16px side by side (dark and light bg)
5. **Footer placement** — footer strip with logo
6. **Brand color palette** — swatches with hex codes, names from the Phase 0 color map

Use the project's `--dark-bg` color (not hardcoded `#0B1120`) for all dark mockup sections.

Read `references/preview-mockup-template.md` for the HTML structure.

### 2.4 Present Phase 2 Output

Present all 5 files (`logo-dark.svg`, `logo-light.svg`, `logo-icon-dark.svg`, `logo-icon-light.svg`,
`logo-preview.html`). Ask: "How does this feel? Any changes to the icon,
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

## Phase 4: Multi-Platform Export & Deployment

### 4.1 Generate Favicons Directly (Preferred)

Check for available CLI tools in this order:

```bash
command -v rsvg-convert && command -v magick
```

**If tools are available** (preferred path), generate all assets directly:

```bash
# Generate PNGs from SVG
rsvg-convert -w 16 -h 16 favicon.svg -o /tmp/favicon-16.png
rsvg-convert -w 32 -h 32 favicon.svg -o /tmp/favicon-32.png
rsvg-convert -w 48 -h 48 favicon.svg -o /tmp/favicon-48.png
rsvg-convert -w 180 -h 180 favicon.svg -o apple-touch-icon.png

# Generate multi-size ICO
magick /tmp/favicon-16.png /tmp/favicon-32.png /tmp/favicon-48.png favicon.ico
```

**If tools are NOT available**, generate `_export-instructions.md` with CLI commands the user
can run. Recommend `brew install librsvg imagemagick` on macOS.

### 4.2 Laravel Auto-Deployment (if Laravel project detected in Phase 0)

**Do NOT just generate instructions.** Actually deploy the files:

1. **Copy favicon.svg to `public/`** — overwrite the existing one
2. **Generate favicon.ico and apple-touch-icon.png** into `public/` using CLI tools
3. **Update Blade components** — find and update these files:
   - `resources/views/components/app-logo-icon.blade.php` — replace with icon SVG inline,
     accepting `$attributes` and `class` prop. Use `currentColor` trick for the highlight layer
     so it adapts to Blade's dark mode:
     ```php
     @props(['class' => 'h-8 w-8'])
     <svg {{ $attributes->merge(['class' => $class]) }} viewBox="0 0 200 200" ...>
       <!-- gradient + main shape -->
       <path ... fill="url(#gradient-id)"/>
       <!-- highlight layer uses currentColor for theme adaptation -->
       <path ... fill="currentColor" class="text-white/10 dark:text-white/10"/>
     </svg>
     ```
   - `resources/views/components/app-logo.blade.php` — icon + app name
   - `resources/views/components/logo.blade.php` — clickable nav logo (if exists)
4. **Add favicon meta tags** to the head partial (if not already present):
   ```html
   <link rel="icon" type="image/svg+xml" href="{{ asset('favicon.svg') }}">
   <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}">
   <link rel="apple-touch-icon" href="{{ asset('apple-touch-icon.png') }}">
   ```
5. **Update hover colors** in logo.blade.php to use the brand's primary color
   (e.g. `hover:text-emerald-600 dark:hover:text-emerald-400`)

> **Lesson learned:** The old skill only generated instructions. Users expect the skill to
> actually deploy the logo into their project. Do the work, don't delegate it back.

### 4.3 Generate Web Manifests (if needed)

- `site.webmanifest` — PWA manifest JSON
- `browserconfig.xml` — Microsoft tile config

### 4.4 Present Deployment Summary

After deploying, present a summary table of what was updated:

```
| File | Change |
|---|---|
| public/favicon.svg | New lightning bolt icon |
| public/favicon.ico | Generated 16/32/48px |
| ... | ... |
```

---

## Output File Structure

All concept/preview files go in `tinker/` (the project's scratch directory):

```
tinker/
├── logo-{01..25}-{name}.svg       # Phase 1 concepts (with bg rect for preview)
├── preview.html                    # Phase 1 interactive gallery
├── logo-dark.svg                   # Phase 2 production (NO bg rect)
├── logo-light.svg
├── logo-icon-dark.svg
├── logo-icon-light.svg
├── logo-preview.html               # Phase 2 mockup page
├── icon-{a..d}-{name}-{dark|light}.svg  # Phase 3 alternatives
└── icon-compare.html               # Phase 3 comparison
```

Deployed files go directly into the project structure (Phase 4):

```
public/
├── favicon.svg                     # Icon SVG
├── favicon.ico                     # Multi-size ICO (16/32/48)
└── apple-touch-icon.png            # 180px PNG

resources/views/components/
├── app-logo-icon.blade.php         # Inline SVG Blade component
├── app-logo.blade.php              # Icon + app name
└── logo.blade.php                  # Clickable nav logo

resources/views/partials/
└── head.blade.php                  # Favicon meta tags added
```

---

## Design Principles (Enforce Throughout)

- **Project colors first** — always extract from existing codebase, never hardcode defaults
- **Dark mode first** — design on the project's dark bg, then adapt for light
- **Size-aware** — wordmarks at 140px+, icons at 80px and below
- **Legibility** — contrast ratio must pass WCAG AA minimum
- **Simplicity scales** — fewer elements survive better at 16px
- **Self-contained SVGs** — no external dependencies
- **No bg rect in production** — only concept SVGs include background for standalone preview
- **Consistent palette** — derive all tints/shades from the project's brand colors
- **Unique gradient IDs** — avoid conflicts when multiple SVGs on same page

---

## Efficiency Rules

These rules exist to avoid slow, repetitive workflows:

1. **Bulk color changes → `sed`**: When changing colors across multiple SVGs, use `sed -i ''`
   in a loop. Never rewrite files individually for a color swap.
2. **Check CLI tools early**: In Phase 4, check for `rsvg-convert` and `magick` upfront.
   Generate assets directly instead of writing instruction docs.
3. **Deploy, don't document**: For Laravel projects, actually update Blade components and
   `public/` files. Don't generate markdown instructions for the user to follow manually.
4. **Extract context once**: Do Phase 0 at the start. Don't discover mid-Phase-2 that the
   colors don't match the project.

---

## Reference Files

- `references/preview-gallery-template.md` — HTML/JS template for Phase 1 gallery
- `references/preview-mockup-template.md` — HTML structure for Phase 2 mockup page
