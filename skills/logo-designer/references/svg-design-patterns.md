# SVG Design Patterns by Rendering Style

Code patterns and techniques for each rendering style. Use these as structural references
when generating SVG logos — adapt the actual design to the user's brief.

## Monochrome + Negative Space (Reka Grafix Style)

The signature style from the reference images. Single fill color, details carved out by
background showing through the shapes.

```svg
<!-- Negative space character in circle frame -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <!-- Circle frame -->
  <circle cx="100" cy="100" r="92" fill="#ffffff"/>
  <!-- Character shape — background color cuts through to create details -->
  <!-- Use fill-rule="evenodd" so inner shapes become transparent -->
  <path fill-rule="evenodd" fill="#3045C9" d="
    M100,8 C150.8,8 192,49.2 192,100 C192,150.8 150.8,192 100,192
    C49.2,192 8,150.8 8,100 C8,49.2 49.2,8 100,8 Z
    [character paths here — inner shapes carve out details]
  "/>
</svg>
```

**Key techniques:**
- `fill-rule="evenodd"` — overlapping paths become holes (negative space)
- Single `<path>` with compound shape — one fill color only
- Character fills 70-80% of circle area
- No strokes — all detail comes from shape cutouts
- Background color shows through to define eyes, mouth, clothing lines

## Line-Art (Outlined Strokes)

Clean vector outlines with visible stroke paths. More detailed than negative space.

```svg
<!-- Line-art character in circle frame -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <!-- Circle frame -->
  <circle cx="100" cy="100" r="92" fill="none" stroke="#ffffff" stroke-width="4"/>
  <!-- Character outlines -->
  <g fill="none" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
    <path d="[head outline]"/>
    <path d="[hair detail]"/>
    <path d="[face features]"/>
    <path d="[body/clothing]"/>
  </g>
  <!-- Solid fill areas (hair, hat) -->
  <path fill="#ffffff" d="[solid fill areas]"/>
</svg>
```

**Key techniques:**
- `fill="none"` with `stroke` — pure outline rendering
- Consistent `stroke-width` (2-3px at 200x200 viewBox)
- `stroke-linecap="round"` and `stroke-linejoin="round"` for smooth joins
- Mix outline paths with solid fill areas (e.g. hair mass)
- More detail-friendly than negative space

## Flat Design

Solid color fills with no strokes, shadows, or gradients. Clean geometric areas.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="#3045C9"/>
  <!-- Layered flat shapes — back to front -->
  <path fill="#ffffff" d="[body shape]"/>
  <path fill="#e0e7ff" d="[clothing detail — lighter tint]"/>
  <path fill="#3045C9" d="[eyes, mouth — brand color cuts through]"/>
</svg>
```

**Key techniques:**
- Multiple fill colors but no gradients
- Shapes layered back-to-front (painter's algorithm)
- Color tints/shades for depth without shadows
- Clean edges, no stroke outlines

## Geometric

Built from basic geometric primitives — circles, rectangles, triangles.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="none" stroke="#ffffff" stroke-width="3"/>
  <!-- Character built from primitives -->
  <circle cx="100" cy="85" r="30" fill="#ffffff"/>           <!-- head -->
  <rect x="75" y="110" width="50" height="45" rx="8" fill="#ffffff"/> <!-- body -->
  <circle cx="88" cy="80" r="4" fill="#3045C9"/>              <!-- eye L -->
  <circle cx="112" cy="80" r="4" fill="#3045C9"/>             <!-- eye R -->
  <ellipse cx="100" cy="92" rx="8" ry="4" fill="#3045C9"/>    <!-- mouth -->
</svg>
```

**Key techniques:**
- Use `<circle>`, `<rect>`, `<ellipse>`, `<polygon>` — not complex paths
- Mathematical precision — centered, aligned, symmetrical
- Grid-based positioning
- Minimal path curves — prefer geometric shapes

## Hand-Drawn / Sketch

Organic, imperfect lines that simulate hand illustration.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <g fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round">
    <!-- Slightly wobbly circle frame -->
    <path d="M100,10 C148,8 190,48 192,98 C194,148 154,190 104,192 C54,194 10,154 8,104 C6,54 46,12 100,10 Z"/>
    <!-- Character with organic curves -->
    <path d="[slightly imperfect hand-drawn paths]"/>
  </g>
</svg>
```

**Key techniques:**
- Slightly irregular curves — avoid perfect circles/straight lines
- Vary `stroke-width` slightly (2-3px range)
- `stroke-linecap="round"` for pencil-like ends
- Occasional gaps or overlaps at intersections
- Add tiny wobbles to bezier control points

## Minimal

Ultra-simplified — fewest possible paths while remaining recognizable.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="#ffffff"/>
  <!-- Entire character in 2-3 paths maximum -->
  <path fill="#3045C9" d="[single compound path for entire character]"/>
</svg>
```

**Key techniques:**
- Maximum 3-5 `<path>` elements total
- Remove all non-essential detail
- Must work at 16px — test by squinting
- Favor recognition over detail
- Often just a silhouette with 1-2 defining features

## Stencil

Cut-out ready design — no floating islands. All shapes connect to the frame or each other.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <path fill="#ffffff" fill-rule="evenodd" d="
    [outer circle path]
    [character cutout — all inner shapes connected via bridges to frame]
  "/>
</svg>
```

**Key techniques:**
- Every inner shape must connect to the outer frame via a "bridge"
- No floating/isolated shapes (would fall out if physically cut)
- Think spray paint stencil — what stays, what gets cut
- `fill-rule="evenodd"` for hole management
- Bridges add characteristic stencil aesthetic

## Engraving / Woodcut

Parallel lines create depth and shading. Inspired by currency and certificate design.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="none" stroke="#ffffff" stroke-width="2"/>
  <!-- Contour lines following the form -->
  <g fill="none" stroke="#ffffff" stroke-width="1.2">
    <path d="[contour line 1 — follows face shape]"/>
    <path d="[contour line 2 — slightly offset]"/>
    <path d="[contour line 3 — forms shading]"/>
    <!-- More lines = darker area, fewer lines = lighter -->
  </g>
  <!-- Solid areas for darkest parts -->
  <path fill="#ffffff" d="[hair mass, darkest shadows]"/>
</svg>
```

**Key techniques:**
- Parallel/contour lines at 1-1.5px stroke width
- Line density = tonal value (more lines = darker)
- Lines follow the form's contour (not just horizontal)
- Solid fills only for the very darkest areas
- Cross-hatching for mid-tones

## Halftone

Dot patterns create shading and texture. Retro print aesthetic.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <defs>
    <pattern id="halftone" width="6" height="6" patternUnits="userSpaceOnUse">
      <circle cx="3" cy="3" r="1.5" fill="#ffffff"/>
    </pattern>
  </defs>
  <circle cx="100" cy="100" r="92" fill="none" stroke="#ffffff" stroke-width="2"/>
  <!-- Solid main shape -->
  <path fill="#ffffff" d="[character outline]"/>
  <!-- Halftone shading areas -->
  <path fill="url(#halftone)" d="[shaded regions]"/>
</svg>
```

**Key techniques:**
- `<pattern>` element defines dot grid
- Vary dot size for tonal range (bigger dots = darker)
- Use multiple pattern definitions for different densities
- Solid fill for darkest areas, pattern for mid-tones
- Clean edges on character outline

## Silhouette

Pure shape — no internal detail. Relies entirely on outline recognition.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="#ffffff"/>
  <!-- Single solid shape — no internal detail -->
  <path fill="#3045C9" d="[character silhouette — outer contour only]"/>
</svg>
```

**Key techniques:**
- One path per character — outer contour only
- No eyes, no mouth, no clothing detail
- Recognizable by posture, props, hair, hat outline
- Most scalable — works at any size
- Defining props (hat, cup, tool) are critical for recognition

## Layered / Shadow

Overlapping shapes at different opacities create depth.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="92" fill="#3045C9"/>
  <!-- Shadow layer (offset, semi-transparent) -->
  <path fill="rgba(0,0,0,0.2)" transform="translate(3,3)" d="[character shape]"/>
  <!-- Main character layer -->
  <path fill="#ffffff" d="[character shape]"/>
  <!-- Highlight layer (offset, semi-transparent) -->
  <path fill="rgba(255,255,255,0.3)" d="[highlight areas]"/>
</svg>
```

**Key techniques:**
- Multiple copies of same shape at different offsets
- `rgba` or `opacity` for transparency layers
- Shadow offset: 2-4px down-right
- 2-3 layers typical: shadow, base, highlight
- Creates paper-cut or long-shadow effect

## Gradient Fill

Linear or radial gradients for modern, dynamic fills.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <defs>
    <linearGradient id="grad-unique-id" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3045C9"/>
      <stop offset="100%" stop-color="#60a5fa"/>
    </linearGradient>
  </defs>
  <circle cx="100" cy="100" r="92" fill="url(#grad-unique-id)"/>
  <path fill="#ffffff" d="[character shape]"/>
</svg>
```

**Key techniques:**
- **Unique gradient IDs per file** — avoid conflicts on same page
- Use `linearGradient` or `radialGradient` in `<defs>`
- 2-3 color stops maximum for clean look
- Gradient on background or on character fill (not both)
- Test at small sizes — gradients can wash out

## Pixel Art

Retro pixel grid style using aligned rectangles.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <!-- Each "pixel" is a rect on an 8x8 or 16x16 grid -->
  <g fill="#ffffff">
    <rect x="80" y="40" width="8" height="8"/>  <!-- pixel -->
    <rect x="88" y="40" width="8" height="8"/>  <!-- pixel -->
    <!-- ... more pixels forming the character -->
  </g>
</svg>
```

**Key techniques:**
- Fixed grid (8x8, 12x12, or 16x16 pixel grid within viewBox)
- Each pixel = one `<rect>` element
- No anti-aliasing or smooth curves
- `shape-rendering="crispEdges"` on the SVG element
- Character must be recognizable at the chosen pixel resolution

## Doodle

Casual, playful sketch style with cartoon proportions.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <g fill="none" stroke="#ffffff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
    <!-- Wobbly, playful outlines -->
    <path d="[slightly exaggerated character proportions]"/>
    <!-- Big head, small body (chibi proportions) -->
    <!-- Exaggerated expressions -->
  </g>
  <!-- Sparse solid fills -->
  <path fill="#ffffff" d="[hair, key features]"/>
</svg>
```

**Key techniques:**
- Exaggerated proportions (big head, big eyes)
- Imperfect but confident line work
- Mix of outline and fill
- Playful poses and expressions
- Less formal than line-art — more cartoon

---

## Container Frame Patterns

### Circle
```svg
<circle cx="100" cy="100" r="92" fill="none" stroke="#fff" stroke-width="4"/>
```

### Squircle (Rounded Square)
```svg
<rect x="12" y="12" width="176" height="176" rx="36" fill="none" stroke="#fff" stroke-width="4"/>
```

### Shield
```svg
<path fill="none" stroke="#fff" stroke-width="4"
  d="M100,12 L180,50 L180,120 C180,160 140,188 100,192 C60,188 20,160 20,120 L20,50 Z"/>
```

### Hexagon
```svg
<polygon fill="none" stroke="#fff" stroke-width="4"
  points="100,8 183,54 183,146 100,192 17,146 17,54"/>
```

### Diamond
```svg
<polygon fill="none" stroke="#fff" stroke-width="4"
  points="100,8 192,100 100,192 8,100"/>
```

### Oval
```svg
<ellipse cx="100" cy="100" rx="88" ry="72" fill="none" stroke="#fff" stroke-width="4"/>
```

### Triangle
```svg
<polygon fill="none" stroke="#fff" stroke-width="4"
  points="100,12 188,180 12,180"/>
```

### Organic Blob
```svg
<path fill="none" stroke="#fff" stroke-width="4"
  d="M120,15 C170,20 190,60 185,100 C180,145 155,185 110,190 C65,195 20,160 15,115 C10,65 55,10 120,15 Z"/>
```

### Arch
```svg
<path fill="none" stroke="#fff" stroke-width="4"
  d="M30,192 L30,80 C30,36 62,8 100,8 C138,8 170,36 170,80 L170,192 Z"/>
```

### Banner
```svg
<path fill="none" stroke="#fff" stroke-width="4"
  d="M8,40 L192,40 L180,100 L192,160 L8,160 L20,100 Z"/>
```
