---
name: logo-designer
metadata:
  compatible_agents: [claude-code]
  tags: [design, svg, logo, mascot, emblem, lettermark, icon, branding]
description: >
  Professional SVG logo designer with granular control over logo category, color palette, container
  frame, and rendering style. Produces 25 SVG concepts (5 concepts x 5 variations), interactive grid
  gallery preview on dark background, individual showcase pages on branded color background, and
  production-ready exports in dark/light modes. Supports six logo categories (mascot, emblem,
  lettermark, icon, wordmark, combination), eight color palettes (monochrome, duotone, tricolor,
  full-color, gradient, split-tone, metallic, pastel), twelve container frames (circle, squircle,
  shield, hexagon, diamond, oval, square, triangle, organic, arch, banner, frameless), and fifteen
  rendering styles (line-art, negative-space, flat, geometric, hand-drawn, minimal, detailed,
  stencil, engraving, halftone, silhouette, layered, stipple, pixel, doodle). Use this skill
  whenever the user asks to design a logo, create a mascot, build a brand mark, generate emblem,
  design lettermark, or says "design me a logo", "I need a mascot for X", "buat logo untuk",
  "reka logo", "design logo brand".
---

# Logo Designer

A professional SVG logo design system with granular control over every design dimension. Follows
a four-phase workflow: interview, exploration, refinement, and export. All output is pure SVG
with interactive HTML preview galleries.

## Entry Points

| Trigger | Action |
|---|---|
| `/logo design` | Full flow — interview then generate |
| `/logo explore [category]` | Quick 6 concepts to test direction |
| `/logo refine [concept-id]` | 6 variations of selected concept |
| `/logo export` | Production SVGs + HTML preview |
| "design a logo", "buat logo" | Full flow |
| "I need a mascot" | Full flow, pre-set category to mascot |
| "design emblem for X" | Full flow, pre-set category to emblem |

---

## Design Options Menu

When interviewing the user, present these options. User can mix and match freely.

### Logo Categories

| Category | Description | Best For |
|---|---|---|
| **Mascot** | Character-based — people, animals, cartoon figures | F&B, gaming, kids brands, sports teams |
| **Emblem** | Badge, crest, seal, stamp with enclosed elements | Government, schools, luxury, heritage brands |
| **Lettermark** | Monogram/initials stylized within a frame | Corporate, tech, personal brands |
| **Icon** | Symbol, abstract mark, object silhouette | Tech, startups, apps, SaaS |
| **Wordmark** | Custom typography/logotype, lettering-focused | Fashion, media, established brands |
| **Combination** | Icon paired with brand name | Most versatile, works across all contexts |

### Color Palettes

| Palette | Description | Characteristics |
|---|---|---|
| **Monochrome** | Single color + background | Clean, bold, versatile — like the Reka Grafix style (white on blue/dark) |
| **Duotone** | 2 colors — primary + accent | Modern, striking, good contrast |
| **Tricolor** | 3 colors — primary, secondary, accent | Balanced, distinctive, national flags style |
| **Full Color** | Multiple colors, vibrant/realistic | Playful, detailed, illustrative brands |
| **Gradient** | Linear or radial gradient fills | Modern, tech-forward, dynamic |
| **Split-tone** | Two halves in different colors | Creative, artistic, dual-concept brands |
| **Metallic** | Simulated gold/silver/bronze via gradient shades | Luxury, premium, award-style |
| **Pastel** | Soft, muted, low-saturation tones | Gentle, organic, wellness, kids brands |

### Container Frames

| Frame | Shape | Best For |
|---|---|---|
| **Circle** | Classic round frame | Universal, profile pictures, stamps |
| **Squircle** | Rounded square (iOS app icon style) | Apps, tech, modern brands |
| **Shield** | Heraldic crest/shield shape | Security, sports, heritage, authority |
| **Hexagon** | Six-sided polygon | Tech, engineering, science, beekeeping |
| **Diamond** | Rotated square/rhombus | Fashion, luxury, premium, sports |
| **Oval** | Horizontal or vertical ellipse | Classic, traditional, food brands |
| **Square** | Sharp-cornered rectangle | Corporate, structured, grid-friendly |
| **Triangle** | Pointing up or down | Dynamic, progressive, mountain/outdoor |
| **Organic** | Irregular smooth blob shape | Creative, natural, artistic brands |
| **Arch** | Doorway/window/tombstone shape | Architecture, heritage, spiritual |
| **Banner** | Ribbon/flag/pennant shape | Events, celebrations, awards |
| **Frameless** | No container — freeform silhouette | Bold, modern, editorial |

### Rendering Styles

| Style | Technique | Visual Character |
|---|---|---|
| **Line-art** | Outlined strokes, clean vector lines | Elegant, technical, detailed — visible stroke paths |
| **Negative-space** | Solid cutout, background defines detail | Bold, clever, memorable — like Reka Grafix solid style |
| **Flat** | Solid color fills, no depth, minimal strokes | Modern, clean, Material Design / flat UI |
| **Geometric** | Built from basic shapes (circles, triangles, squares) | Structured, mathematical, precise |
| **Hand-drawn** | Organic lines, sketch feel, imperfect strokes | Authentic, artisan, craft, indie |
| **Minimal** | Ultra-simplified, fewest paths possible | Scalable, iconic, works at any size |
| **Detailed** | High detail, complex paths, illustrative | Premium, editorial, limited use at small sizes |
| **Stencil** | Cut-out ready, no floating islands, connected shapes | Industrial, military, street art, merch |
| **Engraving** | Parallel line patterns for depth/shading | Vintage, currency, certificate, premium |
| **Halftone** | Dot patterns for shading and texture | Retro, print, pop art, comic book |
| **Silhouette** | Pure shape outline, no internal detail | Signage, wayfinding, universal recognition |
| **Layered** | Overlapping shapes creating depth/shadow | Dynamic, dimensional, modern |
| **Stipple** | Dots for texture and tonal variation | Artistic, tattoo-style, organic |
| **Pixel** | Retro pixel-art grid style | Gaming, retro, tech-nostalgic |
| **Doodle** | Casual playful sketch, cartoon feel | Fun, approachable, kids, casual dining |

---

## Phase 0: Brand Brief Interview

### 0.1 Core Questions

Ask conversationally in one message. Extract what you can from context (CLAUDE.md, project files)
and only ask what is missing:

1. **Brand name** and optional tagline
2. **Industry / product type** (e.g. F&B, tech, education)
3. **Target audience** (who they are, age range, context)
4. **Personality keywords** (3-5: e.g. bold, playful, premium, trustworthy)
5. **Logo category** — present the 6 options, or "explore all"
6. **Color palette** — present the 8 options, or specific colors, or "you decide"
7. **Container frame** — present the 12 options, or "you decide"
8. **Rendering style** — present the 15 options, or "you decide"
9. **What to avoid** — cliches, colors, styles to skip
10. **Special elements** — props, accessories, expressions (for mascot: holding drink, waving, etc.)

### 0.2 Smart Defaults

If user doesn't specify all options, apply smart defaults based on category:

| Category | Default Palette | Default Frame | Default Style |
|---|---|---|---|
| Mascot | Monochrome | Circle | Negative-space |
| Emblem | Monochrome | Shield | Engraving |
| Lettermark | Duotone | Squircle | Flat |
| Icon | Monochrome | Circle | Minimal |
| Wordmark | Monochrome | Frameless | Flat |
| Combination | Duotone | Frameless | Flat |

### 0.3 Confirm Selections

Before generating, summarize the user's choices:

```
Category:   Mascot
Palette:    Monochrome (white on #3045C9)
Frame:      Circle
Style:      Negative-space + Line-art (both)
Subject:    Witch girl character
Variations: holding drink, waving, smiling, winking, with hat
```

Get confirmation before proceeding to Phase 1.

---

## Phase 1: Concept Exploration

### 1.1 Generate 25 SVG Concepts

Create **25 SVGs** organized as **5 concepts x 5 variations**:

**Naming:** `logo-{concept}-{variation}-{description}.svg`
- Example: `logo-01-a-witch-smile.svg` through `logo-01-e-witch-drink.svg`

**5 Concepts** = 5 meaningfully different character/design interpretations
**5 Variations per concept** = different poses, expressions, props, or detail levels

**SVG Requirements:**
- ViewBox: `0 0 200 200` (square for framed logos)
- All paths must be clean, optimized vectors
- Self-contained — no external fonts, no raster images
- Include background rect for preview (production versions will strip it)
- Apply the user's chosen palette, frame, and style consistently

**Diversity rules across the 5 concepts:**
- Concept 1-2: Closest to user's brief (safe/expected)
- Concept 3: Stylistic twist (different rendering approach)
- Concept 4: Simplified/minimal version
- Concept 5: Bold/experimental direction

**Variation rules across 5 per concept:**
- Variation A: Default pose/state
- Variation B: Action pose (holding prop, gesturing)
- Variation C: Different expression (happy, wink, serious)
- Variation D: With accessory/prop variation
- Variation E: Simplified icon version (works at 32px)

### 1.2 Build Grid Gallery Preview

Create `preview-gallery.html` — dark background grid showing all 25 concepts.

Read `references/gallery-grid-template.md` for the HTML template.

**Gallery requirements:**
- Dark background (default) matching Reka Grafix showcase style
- 5 columns x 5 rows grid layout
- Each cell shows the SVG centered on dark card
- Row headers showing concept name
- Column headers showing variation type (A-E)
- Click to select → highlights with brand color border
- Dark/light mode toggle
- Concept grouping — visually separate the 5 concept rows

### 1.3 Build Individual Showcase Pages

Create `showcase.html` — individual logo showcase on branded color background.

Read `references/individual-showcase-template.md` for the HTML template.

**Showcase requirements:**
- Full-screen branded background color (e.g. #3045C9 blue like Reka Grafix)
- Logo centered, white on brand color
- Navigation arrows (prev/next) to browse all 25
- Logo name and concept info below
- Download SVG button per logo
- Dark/light background toggle

### 1.4 Present Phase 1 Output

Tell the user:
- "Open `preview-gallery.html` to see all 25 concepts in a grid"
- "Open `showcase.html` to browse each logo individually on branded background"
- "Tell me which concept row (1-5) you like, or mix elements: e.g. 'concept 2 pose with concept 4 style'"

---

## Phase 2: Selection & Refinement

### 2.1 Gather Feedback

User picks a concept direction. Clarify:
- Which concept row?
- Preferred variation(s)?
- Any changes to pose, expression, detail?
- Keep same palette/frame/style or adjust?

### 2.2 Generate 6 Refined Variations

Based on selected concept, create **6 polished variations**:

| File | Description |
|---|---|
| `final-01-{name}.svg` | Primary — the hero version |
| `final-02-{name}.svg` | Action variation |
| `final-03-{name}.svg` | Expression variation |
| `final-04-{name}.svg` | With prop/accessory |
| `final-05-{name}.svg` | Simplified (works at 32px) |
| `final-06-{name}.svg` | Wordmark combination (logo + brand name) |

### 2.3 Build Refinement Preview

Update `preview-gallery.html` to show the 6 refined versions with:
- Large preview (centered, prominent)
- Size tests: 200px, 100px, 64px, 32px, 16px
- Dark background and light background comparison
- Side-by-side before/after if applicable

### 2.4 Present Phase 2 Output

Ask: "Which version is the winner? Any final tweaks before I prepare production files?"

---

## Phase 3: Production Export

### 3.1 Create Production SVG Set

From the chosen final logo, generate:

| File | Spec |
|---|---|
| `production/logo-dark.svg` | For dark backgrounds, NO bg rect |
| `production/logo-light.svg` | For light backgrounds, NO bg rect |
| `production/logo-icon-dark.svg` | Icon only, 200x200 viewBox, NO bg rect |
| `production/logo-icon-light.svg` | Icon only, 200x200 viewBox, NO bg rect |
| `production/logo-wordmark-dark.svg` | With brand name, for dark bg |
| `production/logo-wordmark-light.svg` | With brand name, for light bg |

**Production rules:**
- NO background `<rect>` — these embed into pages that provide their own bg
- Unique gradient IDs per file (avoid conflicts on same page)
- Optimized paths (remove unnecessary decimals, merge compatible paths)
- Self-contained (no external dependencies)

### 3.2 Build Final Preview Page

Create `logo-preview.html` with real-world mockup sections:

1. **Grid showcase** — all 6 finals on dark background (Reka Grafix grid style)
2. **Individual showcase** — hero logo on branded color background
3. **Size test** — 200px, 100px, 64px, 32px, 16px on dark and light
4. **Navigation mockup** — dark and light nav bar with logo
5. **Social media avatar** — circular crop at profile picture sizes
6. **Brand color palette** — swatches with hex codes

### 3.3 Export Assets Summary

Present a table of all generated files:

```
production/
  logo-dark.svg
  logo-light.svg
  logo-icon-dark.svg
  logo-icon-light.svg
  logo-wordmark-dark.svg
  logo-wordmark-light.svg
preview-gallery.html
showcase.html
logo-preview.html
```

---

## SVG Design Principles

### Monochrome Technique (Reka Grafix Reference)

The monochrome style from the reference images uses these specific techniques:

1. **Single fill color** on transparent/colored background
2. **Circle container** with consistent stroke width
3. **Character fills background** — subject occupies 70-80% of circle area
4. **Negative space for detail** — eyes, mouth, clothing defined by background showing through
5. **No outlines on monochrome negative-space** — shapes are carved, not drawn
6. **Line-art alternative** — same character with visible stroke outlines instead
7. **Consistent weight** — stroke widths scale proportionally

### SVG Optimization

- Use `<path>` with optimized `d` attributes — minimize control points
- Prefer `<circle>`, `<rect>`, `<ellipse>` over path equivalents where possible
- Group related elements with `<g>` for logical structure
- Set `fill-rule="evenodd"` for negative space designs
- ViewBox always `0 0 200 200` for icon marks
- ViewBox `0 0 400 200` for wordmark combinations

### Scalability Rules

| Size | Requirement |
|---|---|
| 200px+ | Full detail version |
| 64-100px | Reduce fine details, thicken strokes |
| 32-48px | Simplified version, remove small elements |
| 16px | Silhouette/minimal — must still be recognizable |

---

## Efficiency Rules

1. **Bulk operations** — use `sed` for color changes across multiple SVGs
2. **Template-driven** — use reference HTML templates, don't write from scratch
3. **Confirm before generating** — validate brief before producing 25 SVGs
4. **Smart grouping** — 5x5 grid is more useful than 25 random concepts
5. **Preview-first** — always provide HTML preview, don't just list SVG files

---

## Reference Files

| File | Purpose |
|---|---|
| `references/gallery-grid-template.md` | HTML template for Phase 1 grid gallery (dark bg, 5x5 layout) |
| `references/individual-showcase-template.md` | HTML template for individual logo showcase (branded bg) |
| `references/svg-design-patterns.md` | SVG code patterns for each rendering style |
