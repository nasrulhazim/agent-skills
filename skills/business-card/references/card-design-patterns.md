# Business Card SVG Design Patterns

Code patterns and layout templates for SVG business cards. Use these as structural references
when generating card concepts — adapt colors, fonts, and content to the user's brief.

## Card Skeletons

### Horizontal Card (Standard 3.5" x 2")

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <!-- Background -->
  <rect width="1050" height="600" fill="#ffffff"/>
  <!-- Safe zone guide (remove in production) -->
  <!-- <rect x="30" y="30" width="990" height="540" fill="none" stroke="#ccc" stroke-dasharray="4"/> -->
  <!-- Content within safe zone (30px inset from all edges) -->
</svg>
```

### Vertical Card (Portrait 2" x 3.5")

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 1050">
  <rect width="600" height="1050" fill="#ffffff"/>
  <!-- Safe zone: 30px inset -->
  <!-- Content area: x=30, y=30, width=540, height=990 -->
</svg>
```

---

## Layout Patterns

### Minimal Left-Aligned

Clean, modern layout with information left-aligned and logo bottom-right.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#ffffff"/>

  <!-- Name -->
  <text x="60" y="180" font-family="system-ui, -apple-system, sans-serif"
        font-size="34" font-weight="700" fill="#111111">Nasrul Hazim</text>

  <!-- Title -->
  <text x="60" y="215" font-family="system-ui, -apple-system, sans-serif"
        font-size="16" font-weight="400" fill="#666666">Senior Software Engineer</text>

  <!-- Divider line -->
  <line x1="60" y1="240" x2="200" y2="240" stroke="#3b82f6" stroke-width="2"/>

  <!-- Contact details -->
  <text x="60" y="310" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">+60 12-345 6789</text>
  <text x="60" y="335" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">nasrul@cleaniquecoders.com</text>
  <text x="60" y="360" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">cleaniquecoders.com</text>

  <!-- Company name (bottom-left) -->
  <text x="60" y="540" font-family="system-ui, -apple-system, sans-serif"
        font-size="14" font-weight="600" fill="#333333">CleaniqueCoders</text>

  <!-- Logo placeholder (bottom-right) -->
  <rect x="900" y="490" width="80" height="80" rx="8" fill="#f0f0f0" stroke="#ddd" stroke-width="1"/>
  <text x="940" y="538" font-family="system-ui, sans-serif"
        font-size="10" fill="#999" text-anchor="middle">LOGO</text>
</svg>
```

### Corporate Centered

Formal, structured layout with centered elements and clear hierarchy.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#ffffff"/>

  <!-- Logo (top-center) -->
  <rect x="485" y="50" width="80" height="80" rx="8" fill="#f0f0f0" stroke="#ddd" stroke-width="1"/>

  <!-- Name (centered) -->
  <text x="525" y="200" font-family="system-ui, -apple-system, sans-serif"
        font-size="32" font-weight="700" fill="#111111" text-anchor="middle">Nasrul Hazim</text>

  <!-- Title -->
  <text x="525" y="230" font-family="system-ui, -apple-system, sans-serif"
        font-size="16" font-weight="400" fill="#666666" text-anchor="middle">Senior Software Engineer</text>

  <!-- Horizontal divider -->
  <line x1="425" y1="260" x2="625" y2="260" stroke="#3b82f6" stroke-width="1.5"/>

  <!-- Contact in two columns -->
  <text x="350" y="310" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444" text-anchor="end">+60 12-345 6789</text>
  <text x="700" y="310" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444" text-anchor="start">nasrul@cleaniquecoders.com</text>
  <text x="525" y="340" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444" text-anchor="middle">cleaniquecoders.com</text>

  <!-- Company (bottom-center) -->
  <text x="525" y="540" font-family="system-ui, -apple-system, sans-serif"
        font-size="15" font-weight="600" fill="#333333" text-anchor="middle">CleaniqueCoders Sdn Bhd</text>
</svg>
```

### Creative Split

Card divided into two color zones — brand color on the left with name/title,
white on the right with contact details.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <!-- Left half — brand color -->
  <rect x="0" y="0" width="420" height="600" fill="#1e293b"/>
  <!-- Right half — white -->
  <rect x="420" y="0" width="630" height="600" fill="#ffffff"/>

  <!-- Name (left side, white text) -->
  <text x="60" y="250" font-family="system-ui, -apple-system, sans-serif"
        font-size="30" font-weight="700" fill="#ffffff">Nasrul</text>
  <text x="60" y="290" font-family="system-ui, -apple-system, sans-serif"
        font-size="30" font-weight="700" fill="#ffffff">Hazim</text>

  <!-- Title (left side) -->
  <text x="60" y="330" font-family="system-ui, -apple-system, sans-serif"
        font-size="14" font-weight="400" fill="#94a3b8">Senior Software Engineer</text>

  <!-- Contact (right side) -->
  <text x="480" y="200" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">+60 12-345 6789</text>
  <text x="480" y="230" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">nasrul@cleaniquecoders.com</text>
  <text x="480" y="260" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#444444">cleaniquecoders.com</text>

  <!-- Company (right side, bottom) -->
  <text x="480" y="540" font-family="system-ui, -apple-system, sans-serif"
        font-size="14" font-weight="600" fill="#333333">CleaniqueCoders</text>

  <!-- Accent line at split -->
  <line x1="420" y1="100" x2="420" y2="500" stroke="#3b82f6" stroke-width="3"/>
</svg>
```

### Elegant

Thin border inset, refined typography with generous whitespace.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#ffffff"/>
  <!-- Thin border inset -->
  <rect x="25" y="25" width="1000" height="550" fill="none" stroke="#d4d4d4" stroke-width="0.75"/>

  <!-- Name (centered, prominent) -->
  <text x="525" y="230" font-family="'Georgia', 'Times New Roman', serif"
        font-size="36" font-weight="400" fill="#111111" text-anchor="middle"
        letter-spacing="3">NASRUL HAZIM</text>

  <!-- Decorative line -->
  <line x1="450" y1="255" x2="600" y2="255" stroke="#c4a35a" stroke-width="1"/>

  <!-- Title -->
  <text x="525" y="285" font-family="system-ui, -apple-system, sans-serif"
        font-size="12" font-weight="400" fill="#888888" text-anchor="middle"
        letter-spacing="2">SENIOR SOFTWARE ENGINEER</text>

  <!-- Contact (bottom, spaced) -->
  <text x="525" y="480" font-family="system-ui, -apple-system, sans-serif"
        font-size="11" fill="#666666" text-anchor="middle"
        letter-spacing="1">+60 12-345 6789  |  nasrul@cleaniquecoders.com  |  cleaniquecoders.com</text>
</svg>
```

### Bold Dark

Dark background with large name in white and accent color highlights.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#0f172a"/>

  <!-- Accent bar (left edge) -->
  <rect x="0" y="0" width="6" height="600" fill="#3b82f6"/>

  <!-- Name (large, white) -->
  <text x="60" y="200" font-family="system-ui, -apple-system, sans-serif"
        font-size="42" font-weight="800" fill="#ffffff">NASRUL HAZIM</text>

  <!-- Title (accent color) -->
  <text x="60" y="240" font-family="system-ui, -apple-system, sans-serif"
        font-size="16" font-weight="500" fill="#3b82f6">Senior Software Engineer</text>

  <!-- Contact (muted white) -->
  <text x="60" y="380" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#94a3b8">+60 12-345 6789</text>
  <text x="60" y="408" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#94a3b8">nasrul@cleaniquecoders.com</text>
  <text x="60" y="436" font-family="system-ui, -apple-system, sans-serif"
        font-size="13" fill="#94a3b8">cleaniquecoders.com</text>

  <!-- Company (bottom-right, small) -->
  <text x="990" y="550" font-family="system-ui, -apple-system, sans-serif"
        font-size="12" font-weight="600" fill="#475569" text-anchor="end">CleaniqueCoders</text>
</svg>
```

### Tech / Developer

Monospace hints, code-bracket accents, social/GitHub prominence.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#0a0a0a"/>

  <!-- Code bracket accent -->
  <text x="40" y="180" font-family="'SF Mono', 'Fira Code', 'Consolas', monospace"
        font-size="60" font-weight="300" fill="#333333">{</text>

  <!-- Name -->
  <text x="100" y="200" font-family="system-ui, -apple-system, sans-serif"
        font-size="32" font-weight="700" fill="#e2e8f0">Nasrul Hazim</text>

  <!-- Title with code syntax hint -->
  <text x="100" y="235" font-family="'SF Mono', 'Fira Code', monospace"
        font-size="14" fill="#3b82f6">// Senior Software Engineer</text>

  <!-- Contact as key-value pairs -->
  <text x="100" y="330" font-family="'SF Mono', 'Fira Code', monospace"
        font-size="12" fill="#64748b">
    <tspan x="100" dy="0">email: nasrul@cleaniquecoders.com</tspan>
    <tspan x="100" dy="22">phone: +60 12-345 6789</tspan>
    <tspan x="100" dy="22">web:   cleaniquecoders.com</tspan>
    <tspan x="100" dy="22">gh:    github.com/nasrulhazim</tspan>
  </text>

  <!-- Closing bracket -->
  <text x="40" y="520" font-family="'SF Mono', 'Fira Code', 'Consolas', monospace"
        font-size="60" font-weight="300" fill="#333333">}</text>
</svg>
```

---

## Decorative Element Patterns

### Horizontal Divider Line

```svg
<line x1="60" y1="250" x2="200" y2="250" stroke="#3b82f6" stroke-width="2"/>
```

### Full-Width Thin Divider

```svg
<line x1="60" y1="300" x2="990" y2="300" stroke="#e5e7eb" stroke-width="0.75"/>
```

### Accent Bar (Left Edge)

```svg
<rect x="0" y="0" width="6" height="600" fill="#3b82f6"/>
```

### Accent Bar (Top Edge)

```svg
<rect x="0" y="0" width="1050" height="4" fill="#3b82f6"/>
```

### Corner Accent (Top-Right Triangle)

```svg
<polygon points="950,0 1050,0 1050,100" fill="#3b82f6" opacity="0.15"/>
```

### Corner Accent (Bottom-Left Triangle)

```svg
<polygon points="0,500 0,600 100,600" fill="#3b82f6" opacity="0.15"/>
```

### Diagonal Cut

```svg
<polygon points="700,0 1050,0 1050,600 850,600" fill="#1e293b"/>
```

### Dot Pattern Background

```svg
<defs>
  <pattern id="dots" width="20" height="20" patternUnits="userSpaceOnUse">
    <circle cx="10" cy="10" r="1" fill="#e5e7eb"/>
  </pattern>
</defs>
<rect width="1050" height="600" fill="url(#dots)"/>
```

---

## Logo Placement Patterns

### Top-Left

```svg
<rect x="50" y="40" width="80" height="80" rx="8" fill="none" stroke="#ddd" stroke-width="1"/>
<!-- or inline SVG logo -->
```

### Top-Right

```svg
<rect x="920" y="40" width="80" height="80" rx="8" fill="none" stroke="#ddd" stroke-width="1"/>
```

### Bottom-Right

```svg
<rect x="920" y="480" width="80" height="80" rx="8" fill="none" stroke="#ddd" stroke-width="1"/>
```

### Centered Top

```svg
<rect x="485" y="40" width="80" height="80" rx="8" fill="none" stroke="#ddd" stroke-width="1"/>
```

---

## QR Code Placeholder

Visual placeholder for a QR code — actual QR generation needs external tools.

```svg
<!-- QR Code placeholder (120x120px) -->
<g transform="translate(880, 430)">
  <rect width="120" height="120" rx="4" fill="#f8fafc" stroke="#e2e8f0" stroke-width="1"/>
  <!-- Simulated QR pattern -->
  <rect x="10" y="10" width="25" height="25" fill="#1e293b"/>
  <rect x="85" y="10" width="25" height="25" fill="#1e293b"/>
  <rect x="10" y="85" width="25" height="25" fill="#1e293b"/>
  <rect x="42" y="42" width="36" height="36" fill="#1e293b"/>
  <!-- Label -->
  <text x="60" y="135" font-family="system-ui, sans-serif"
        font-size="8" fill="#94a3b8" text-anchor="middle">Scan for vCard</text>
</g>
```

---

## Social Media Icon Row

Simple text-based social handles with icon-like labels.

```svg
<!-- Social row (bottom of card) -->
<g font-family="system-ui, -apple-system, sans-serif" font-size="11" fill="#64748b">
  <text x="60" y="540">in /nasrulhazim</text>
  <text x="220" y="540">gh /nasrulhazim</text>
  <text x="380" y="540">x @nasrulhazim</text>
</g>
```

---

## Back Design Patterns

### Solid Color Back

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#1e293b"/>
</svg>
```

### Logo Centered Back

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#1e293b"/>
  <!-- Logo centered -->
  <rect x="445" y="220" width="160" height="160" rx="12" fill="none" stroke="#334155" stroke-width="1"/>
  <text x="525" y="308" font-family="system-ui, sans-serif"
        font-size="12" fill="#475569" text-anchor="middle">LOGO</text>
</svg>
```

### Pattern Back (Geometric)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#1e293b"/>
  <defs>
    <pattern id="geo-pattern" width="40" height="40" patternUnits="userSpaceOnUse">
      <path d="M0,20 L20,0 L40,20 L20,40 Z" fill="none" stroke="#334155" stroke-width="0.5"/>
    </pattern>
  </defs>
  <rect width="1050" height="600" fill="url(#geo-pattern)"/>
</svg>
```

### Gradient Back

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <defs>
    <linearGradient id="back-grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1e293b"/>
      <stop offset="100%" stop-color="#0f172a"/>
    </linearGradient>
  </defs>
  <rect width="1050" height="600" fill="url(#back-grad)"/>
</svg>
```

### Information Back (QR + Tagline)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1050 600">
  <rect width="1050" height="600" fill="#1e293b"/>

  <!-- Tagline centered -->
  <text x="525" y="200" font-family="system-ui, -apple-system, sans-serif"
        font-size="18" font-weight="300" fill="#94a3b8" text-anchor="middle"
        font-style="italic">"Building software that matters"</text>

  <!-- QR code centered below -->
  <g transform="translate(465, 260)">
    <rect width="120" height="120" rx="4" fill="#f8fafc"/>
    <rect x="10" y="10" width="25" height="25" fill="#1e293b"/>
    <rect x="85" y="10" width="25" height="25" fill="#1e293b"/>
    <rect x="10" y="85" width="25" height="25" fill="#1e293b"/>
    <rect x="42" y="42" width="36" height="36" fill="#1e293b"/>
  </g>

  <!-- Website below QR -->
  <text x="525" y="420" font-family="system-ui, -apple-system, sans-serif"
        font-size="12" fill="#64748b" text-anchor="middle">cleaniquecoders.com</text>
</svg>
```

---

## Print-Ready Template (with Bleed and Crop Marks)

Print version extends the card by 0.125" (37.5px) on each side for bleed area,
and adds thin crop marks at the corners to indicate the trim line.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1125 675">
  <!-- Bleed area background (extends 37.5px beyond trim on each side) -->
  <rect width="1125" height="675" fill="#ffffff"/>

  <!-- Crop marks (0.5px thin lines at corners) -->
  <!-- Top-left -->
  <line x1="37.5" y1="0" x2="37.5" y2="18" stroke="#000" stroke-width="0.5"/>
  <line x1="0" y1="37.5" x2="18" y2="37.5" stroke="#000" stroke-width="0.5"/>
  <!-- Top-right -->
  <line x1="1087.5" y1="0" x2="1087.5" y2="18" stroke="#000" stroke-width="0.5"/>
  <line x1="1107" y1="37.5" x2="1125" y2="37.5" stroke="#000" stroke-width="0.5"/>
  <!-- Bottom-left -->
  <line x1="37.5" y1="657" x2="37.5" y2="675" stroke="#000" stroke-width="0.5"/>
  <line x1="0" y1="637.5" x2="18" y2="637.5" stroke="#000" stroke-width="0.5"/>
  <!-- Bottom-right -->
  <line x1="1087.5" y1="657" x2="1087.5" y2="675" stroke="#000" stroke-width="0.5"/>
  <line x1="1107" y1="637.5" x2="1125" y2="637.5" stroke="#000" stroke-width="0.5"/>

  <!-- Card content (translated into trim area) -->
  <g transform="translate(37.5, 37.5)">
    <!-- Standard 1050x600 card content goes here -->
    <!-- Background should extend into bleed area for full coverage -->
  </g>
</svg>
```

**Print specifications:**
- Trim size: 1050 x 600 (3.5" x 2" at 300dpi ratio)
- Bleed: 37.5px each side (0.125" at 300dpi)
- Total with bleed: 1125 x 675
- Safe zone: 30px inset from trim line (67.5px from document edge)
- Crop marks: 18px long, 0.5px stroke, positioned at trim corners
