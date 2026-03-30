---
name: business-card
metadata:
  compatible_agents: [claude-code]
  tags: [design, svg, business-card, branding, print, stationery]
description: >
  SVG business card designer that takes contact details and brand preferences, then produces
  12 front design concepts with optional back designs, interactive HTML preview galleries,
  individual card showcases with front/back flip animation, and print-ready SVG exports with
  bleed area and crop marks. Supports horizontal and vertical orientations, six layout styles
  (minimal, corporate, creative, elegant, bold, tech), multiple color schemes, QR code
  placeholders, social media icons, and logo integration. Use this skill whenever the user asks
  to design a business card, create a name card, make visiting cards, or says "design business
  card", "buat kad bisnes", "create name card", "reka kad perniagaan", "design kad nama",
  "I need a business card for X".
---

# Business Card Designer

A professional SVG business card design system following a four-phase workflow: interview,
concept exploration, selection/refinement, and production export. All output is pure SVG
with interactive HTML preview galleries featuring front/back flip animation.

## Entry Points

| Trigger | Action |
|---|---|
| `/card design` | Full flow — interview then generate |
| `/card quick` | Minimal interview, smart defaults, 6 concepts |
| `/card back` | Design or redesign back of card only |
| `/card export` | Production SVGs from existing chosen design |
| "design business card", "buat kad bisnes" | Full flow |
| "create name card", "reka kad perniagaan" | Full flow |
| "I need a business card" | Full flow |
| "design kad nama" | Full flow |

---

## Design Options Menu

When interviewing the user, present these options. User can mix and match freely.

### Layout Styles

| Style | Description | Best For |
|---|---|---|
| **Minimal** | Clean whitespace, left-aligned text, no decorative elements | Tech, startups, freelancers |
| **Corporate** | Centered layout, logo prominent, structured hierarchy | Finance, consulting, enterprise |
| **Creative** | Asymmetric layout, bold color blocks, unique composition | Design agencies, artists, media |
| **Elegant** | Thin borders, refined typography, generous margins | Luxury, fashion, law firms |
| **Bold** | Large name, strong contrast, dark backgrounds | Personal brands, speakers, coaches |
| **Tech** | Monospace hints, code-bracket accents, GitHub prominence | Developers, engineers, DevOps |

### Color Schemes

| Scheme | Description | Characteristics |
|---|---|---|
| **Monochrome** | Single color + black/white | Professional, versatile, print-friendly |
| **Brand Colors** | Derived from project/brand palette | Consistent with existing identity |
| **Gradient** | Linear or radial gradient accents | Modern, tech-forward, dynamic |
| **Dark Mode** | Dark background, light text | Bold, distinctive, premium feel |
| **Light/Clean** | White background, subtle accents | Classic, safe, works everywhere |
| **Accent Pop** | Neutral base with one vibrant accent color | Eye-catching yet professional |

### Typography Emphasis

| Emphasis | Description | Effect |
|---|---|---|
| **Name-focused** | Name large (28-36px), other details smaller | Personal brand prominence |
| **Title-focused** | Role/title prominent, name secondary | Position/authority emphasis |
| **Balanced** | Equal visual weight across elements | Traditional, formal presentation |

### Card Orientation

| Orientation | Dimensions | ViewBox | Best For |
|---|---|---|---|
| **Horizontal** | 3.5" x 2" (standard) | `0 0 1050 600` | Most uses, traditional |
| **Vertical** | 2" x 3.5" (portrait) | `0 0 600 1050` | Creative, distinctive, modern |

### Back Design Options

| Back Style | Description | Best For |
|---|---|---|
| **Blank** | Empty white/colored back | Cost-effective printing |
| **Solid Color** | Single brand color fill | Clean, bold statement |
| **Pattern** | Geometric or organic SVG pattern fill | Distinctive, memorable |
| **Logo Centered** | Logo mark centered on colored background | Brand reinforcement |
| **Information** | Secondary contact details, tagline, or QR code | Maximizing card real estate |

### Special Elements

| Element | Description |
|---|---|
| **QR Code** | Placeholder rect for vCard URL (120x120px, actual QR needs external tool) |
| **Social Icons** | Row of social media icon placeholders (LinkedIn, X, GitHub, Instagram) |
| **Logo Placement** | Top-left, top-right, bottom-left, bottom-right, or centered |
| **Decorative Lines** | Horizontal dividers, accent bars, corner accents |
| **Accent Shapes** | Geometric elements (circles, triangles, diagonal cuts) |

---

## Phase 0: Contact & Brand Interview

### 0.1 Core Questions

Ask conversationally in one message. Extract what you can from context (CLAUDE.md, project files)
and only ask what is missing:

1. **Full name** and any credentials/suffix (e.g. "Dr.", "PhD", "CPA")
2. **Title / Role** (e.g. "Senior Software Engineer", "Founder & CEO")
3. **Company / Organization name**
4. **Phone number(s)** (mobile, office)
5. **Email address**
6. **Website URL**
7. **Physical address** (optional — street, city, state, zip)
8. **Social media handles** (optional — LinkedIn, X/Twitter, GitHub, Instagram)
9. **Logo file path** (if exists in project — SVG preferred)
10. **Tagline** (optional — company slogan or personal motto)
11. **Brand colors** (specific hex values, "use project colors", or "you decide")
12. **Layout style** — present the 6 options, or "you decide"
13. **Card orientation** — horizontal or vertical
14. **Back design** — present the 5 options, or "no back" / "you decide"
15. **What to avoid** — styles, colors, cliches to skip

### 0.2 Smart Defaults

If user doesn't specify all options, apply smart defaults based on industry/context:

| Industry | Default Layout | Default Scheme | Default Orientation | Default Back |
|---|---|---|---|---|
| Tech / Startup | minimal | dark mode | horizontal | solid color |
| Corporate / Finance | corporate | monochrome | horizontal | logo centered |
| Creative / Design | creative | gradient | vertical | pattern |
| Luxury / Fashion | elegant | monochrome | horizontal | solid color |
| Freelancer / Personal | bold | accent pop | horizontal | information |
| General | minimal | brand colors | horizontal | solid color |

### 0.3 Confirm Selections

Before generating, summarize the user's choices:

```
Name:        Nasrul Hazim
Title:       Senior Software Engineer
Company:     CleaniqueCoders Sdn Bhd
Phone:       +60 12-345 6789
Email:       nasrul@cleaniquecoders.com
Website:     cleaniquecoders.com
Layout:      Minimal
Scheme:      Dark Mode
Orientation: Horizontal (3.5" x 2")
Back:        Logo Centered
Colors:      #1e293b (slate-800), #3b82f6 (blue-500)
```

Get confirmation before proceeding to Phase 1.

---

## Phase 1: Concept Exploration

### 1.1 Generate 12 SVG Front Concepts

Create **12 front design concepts** as individual SVG files.

**Naming:** `card-{01-12}-{description}.svg`
- Example: `card-01-minimal-left.svg`, `card-05-bold-dark.svg`

**SVG Requirements:**
- Horizontal viewBox: `0 0 1050 600` (3.5" x 2" at 300dpi ratio)
- Vertical viewBox: `0 0 600 1050`
- All text as `<text>` elements with `font-family="system-ui, -apple-system, 'Segoe UI', sans-serif"`
- Self-contained — no external fonts, no raster images
- Include background `<rect>` for preview (production versions strip it)
- Safe zone: 30px inset from all edges (0.1" print margin)
- Use the user's brand colors consistently

**Text sizing guidelines (horizontal card):**
- Name: `font-size="32"` to `font-size="36"`, `font-weight="700"`
- Title/Role: `font-size="16"` to `font-size="20"`, `font-weight="400"` or `"500"`
- Contact details: `font-size="13"` to `font-size="14"`, `font-weight="400"`
- Social handles: `font-size="11"` to `font-size="13"`, `font-weight="400"`
- Company name: `font-size="14"` to `font-size="18"`, `font-weight="600"`

**Diversity rules across 12 concepts:**
- Cards 1-3: Direct interpretation of user's brief (safe/expected)
- Cards 4-6: Different layout arrangement of same information
- Cards 7-9: Stylistic twist (different color treatment, typography weight)
- Cards 10-12: Experimental/creative direction

### 1.2 Generate Back Designs (if requested)

Create **4 back design concepts** if user wants a back design:

**Naming:** `card-back-{01-04}-{description}.svg`
- Example: `card-back-01-solid-blue.svg`, `card-back-03-pattern-dots.svg`

Back designs must use the same viewBox as the front (horizontal or vertical).

### 1.3 Build Preview Gallery

Create `preview-gallery.html` — a grid gallery of all concepts.

Read `references/card-gallery-template.md` for the HTML template.

**Gallery requirements:**
- Dark background default
- 3-column responsive grid (cards are 7:4 landscape rectangles)
- Each cell shows the SVG at realistic proportions with subtle shadow
- Click to select with brand-color border highlight
- Dark/light mode toggle
- "Show Backs" toggle if back designs exist
- Card numbers and descriptions visible

### 1.4 Build Individual Showcase

Create `showcase.html` — individual card showcase with flip animation.

Read `references/card-showcase-template.md` for the HTML template.

**Showcase requirements:**
- Card displayed at realistic scale (350px wide) with subtle shadow
- CSS 3D flip animation (click or spacebar to flip between front/back)
- Navigation arrows for browsing all concepts
- Download SVG button
- Background toggle (brand color, dark, light)
- Thumbnail strip at bottom

### 1.5 Present Phase 1 Output

Tell the user:
- "Open `preview-gallery.html` to see all 12 front designs in a grid"
- "Open `showcase.html` to browse each card individually (click to flip)"
- "Tell me which card number you prefer, or describe what you like"

---

## Phase 2: Selection & Refinement

### 2.1 Gather Feedback

User picks a concept direction. Clarify:
- Which card number?
- Any changes to layout, colors, or typography?
- Adjust spacing or element positions?
- Keep same back design or change?

### 2.2 Generate 4 Refined Variations

Based on selected concept, create **4 polished variations**:

| File | Description |
|---|---|
| `final-01-{name}.svg` | Primary refined version |
| `final-02-{name}.svg` | Typography variation (different weight/size balance) |
| `final-03-{name}.svg` | Layout variation (repositioned elements) |
| `final-04-{name}.svg` | Color/style variation (different accent or treatment) |

Plus back design refinement if applicable: `final-back-{name}.svg`

### 2.3 Build Refinement Preview

Update `preview-gallery.html` to show the 4 refined versions with:
- Large preview (prominent, centered)
- Side-by-side comparison of all 4
- Front/back pair view
- Dark and light background comparison

### 2.4 Present Phase 2 Output

Ask: "Which version is the winner? Any final tweaks before I prepare print-ready files?"

---

## Phase 3: Production Export

### 3.1 Create Production SVG Set

From the chosen final card, generate:

| File | Spec |
|---|---|
| `production/card-front.svg` | Front design, NO bg rect, production-ready |
| `production/card-back.svg` | Back design (if exists), NO bg rect |
| `production/card-front-dark.svg` | Front for dark contexts (inverted if needed) |
| `production/card-front-light.svg` | Front for light contexts |
| `production/card-print-front.svg` | Print-ready: bleed area + crop marks |
| `production/card-print-back.svg` | Print-ready back: bleed area + crop marks |

**Production rules:**
- NO background `<rect>` in non-print versions
- Print versions include:
  - 0.125" bleed extension (37.5px at 300dpi each side)
  - ViewBox expanded to `0 0 1125 675` for horizontal (with bleed)
  - Thin crop marks at corners (0.5px stroke)
  - Content within trim area via `<g transform="translate(37.5, 37.5)">`
- Unique gradient/pattern IDs per file
- Optimized text elements

### 3.2 Build Final Preview Page

Create `card-preview.html` with mockup sections:

1. **Front & back side-by-side** — on dark and light backgrounds
2. **Realistic card mockup** — card with perspective shadow, slight rotation
3. **Size comparison** — card at 100%, 75%, 50% scale
4. **Print specifications** — dimensions, bleed, safe zone, color info
5. **Brand color palette** — swatches with hex codes used in the design

### 3.3 Export Assets Summary

Present a table of all generated files:

```
production/
  card-front.svg
  card-back.svg
  card-front-dark.svg
  card-front-light.svg
  card-print-front.svg        # 1125x675 with bleed + crop marks
  card-print-back.svg         # 1125x675 with bleed + crop marks
preview-gallery.html
showcase.html
card-preview.html
```

---

## Business Card Design Principles

### Typography Hierarchy

Information should follow this visual weight order:
1. **Name** — largest, boldest element (28-36px)
2. **Title / Role** — second level (16-20px)
3. **Company name** — third level if separate from title (14-18px)
4. **Contact details** — phone, email, website (12-14px)
5. **Social handles** — smallest, least prominent (11-13px)
6. **Address** — if included, smallest tier (10-12px)

### Safe Zone

Keep all critical content **30px inset** from all edges (trim line). This represents
approximately 0.1" margin at 300dpi — the standard print safety margin. Text too close
to the edge risks being cut off during trimming.

### Layout Balance

- **Left-aligned** — most readable, natural eye flow, works for most styles
- **Right-aligned** — elegant, works for creative/fashion cards
- **Centered** — formal, traditional, works for corporate cards
- **Split layout** — divide card into zones (left info / right logo, or top/bottom)

### White Space

**Overcrowding is the most common business card mistake.** A card with 6 clean lines of
information is more effective than one cramming 12 items. If the user provides too much
information, suggest moving secondary details to the back or dropping optional fields.

### Logo Integration

- Logo should be sized proportionally — typically 60-100px wide
- Common positions: top-left (corporate), bottom-right (minimal), centered-top (formal)
- If no logo exists, use the company name as the brand mark with distinctive typography
- SVG logos should be embedded inline, not as external references

### QR Code Guidelines

- Size: 120x120px minimum for reliable scanning
- Position: bottom-right corner or centered on back
- In SVG output, render as a placeholder rect with "QR" label
- Actual QR code generation requires external tools (recommend `qrencode` CLI)
- Content: usually a vCard URL or LinkedIn profile

---

## Efficiency Rules

1. **Bulk color changes via `sed`** — when changing colors across multiple SVGs, use
   `sed -i ''` in a loop, never rewrite files individually
2. **Template-driven** — use reference HTML templates, don't write from scratch
3. **Confirm before generating** — validate all contact details before producing 12 concepts
4. **Preview-first** — always provide HTML preview, don't just list SVG files
5. **QR placeholder only** — use a visual placeholder rect; actual QR generation needs
   external tools like `qrencode`

---

## Reference Files

| File | Purpose |
|---|---|
| `references/card-gallery-template.md` | HTML template for Phase 1 grid gallery (landscape card proportions) |
| `references/card-showcase-template.md` | HTML template for individual card showcase with flip animation |
| `references/card-design-patterns.md` | SVG code patterns for card layouts, typography, decorative elements |
