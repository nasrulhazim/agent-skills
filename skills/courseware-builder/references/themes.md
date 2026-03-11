# Themes Reference

## Theme 1 — Dark Cyberpunk (Default)

Best for: developers, tech workshops, hackathons, advanced audiences.

### CSS Variables

```css
:root {
  /* Background */
  --bg-primary: #0a0e27;
  --bg-secondary: #131836;
  --bg-panel: #0f1335;
  --bg-card: #181d45;
  --bg-code: #0d1117;

  /* Accent */
  --accent: #00e5ff;
  --accent-glow: rgba(0, 229, 255, 0.35);
  --accent-dim: rgba(0, 229, 255, 0.10);

  /* Secondary */
  --secondary: #a855f7;
  --secondary-glow: rgba(168, 85, 247, 0.30);

  /* Text */
  --text-primary: #e2e8f0;
  --text-secondary: #94a3b8;
  --text-muted: #64748b;

  /* Borders */
  --border: rgba(0, 229, 255, 0.15);
  --border-active: rgba(0, 229, 255, 0.50);

  /* Node states */
  --node-bg: #181d45;
  --node-border: rgba(0, 229, 255, 0.25);
  --node-active-bg: #1a2555;
  --node-active-border: #00e5ff;
  --node-active-glow: 0 0 20px rgba(0, 229, 255, 0.4), 0 0 40px rgba(0, 229, 255, 0.15);
  --node-done-bg: rgba(52, 211, 153, 0.12);
  --node-done-border: #34d399;

  /* Arrow */
  --arrow-color: #334155;
  --arrow-active: #00e5ff;
  --arrow-done: #34d399;

  /* Progress bar */
  --progress-bg: #1e293b;
  --progress-fill: linear-gradient(90deg, #00e5ff, #a855f7);

  /* Button */
  --btn-bg: rgba(0, 229, 255, 0.10);
  --btn-border: rgba(0, 229, 255, 0.30);
  --btn-hover-bg: rgba(0, 229, 255, 0.20);
  --btn-text: #00e5ff;

  /* Notify toast */
  --notify-bg: rgba(0, 229, 255, 0.15);
  --notify-border: rgba(0, 229, 255, 0.40);
  --notify-text: #00e5ff;
}
```

### Google Fonts

```html
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
```

- **Headings & UI**: `Inter`, sans-serif
- **Code**: `JetBrains Mono`, monospace

---

## Theme 2 — Light Editorial

Best for: non-technical audiences, management presentations, student workshops, printed handouts.

### CSS Variables

```css
:root {
  /* Background */
  --bg-primary: #ffffff;
  --bg-secondary: #f8fafc;
  --bg-panel: #ffffff;
  --bg-card: #f1f5f9;
  --bg-code: #f8fafc;

  /* Accent */
  --accent: #2563eb;
  --accent-glow: rgba(37, 99, 235, 0.20);
  --accent-dim: rgba(37, 99, 235, 0.06);

  /* Secondary */
  --secondary: #7c3aed;
  --secondary-glow: rgba(124, 58, 237, 0.15);

  /* Text */
  --text-primary: #1e293b;
  --text-secondary: #475569;
  --text-muted: #94a3b8;

  /* Borders */
  --border: #e2e8f0;
  --border-active: #2563eb;

  /* Node states */
  --node-bg: #ffffff;
  --node-border: #e2e8f0;
  --node-active-bg: #eff6ff;
  --node-active-border: #2563eb;
  --node-active-glow: 0 0 15px rgba(37, 99, 235, 0.20), 0 4px 12px rgba(37, 99, 235, 0.10);
  --node-done-bg: #f0fdf4;
  --node-done-border: #22c55e;

  /* Arrow */
  --arrow-color: #cbd5e1;
  --arrow-active: #2563eb;
  --arrow-done: #22c55e;

  /* Progress bar */
  --progress-bg: #e2e8f0;
  --progress-fill: linear-gradient(90deg, #2563eb, #7c3aed);

  /* Button */
  --btn-bg: #eff6ff;
  --btn-border: #bfdbfe;
  --btn-hover-bg: #dbeafe;
  --btn-text: #2563eb;

  /* Notify toast */
  --notify-bg: #eff6ff;
  --notify-border: #93c5fd;
  --notify-text: #2563eb;
}
```

### Google Fonts

```html
<link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@400;600&family=Source+Sans+3:wght@400;600;700&display=swap" rel="stylesheet">
```

- **Headings & UI**: `Source Sans 3`, sans-serif
- **Code**: `Source Code Pro`, monospace

---

## Theme 3 — Warm Malaysian

Best for: community events, BM workshops, Kelas Terbuka, casual/friendly training sessions.

### CSS Variables

```css
:root {
  /* Background */
  --bg-primary: #1a1207;
  --bg-secondary: #231a0b;
  --bg-panel: #1e1509;
  --bg-card: #2a1f0e;
  --bg-code: #151005;

  /* Accent */
  --accent: #f59e0b;
  --accent-glow: rgba(245, 158, 11, 0.30);
  --accent-dim: rgba(245, 158, 11, 0.10);

  /* Secondary */
  --secondary: #dc2626;
  --secondary-glow: rgba(220, 38, 38, 0.25);

  /* Text */
  --text-primary: #fef3c7;
  --text-secondary: #d4a574;
  --text-muted: #92703a;

  /* Borders */
  --border: rgba(245, 158, 11, 0.15);
  --border-active: rgba(245, 158, 11, 0.50);

  /* Node states */
  --node-bg: #2a1f0e;
  --node-border: rgba(245, 158, 11, 0.25);
  --node-active-bg: #352810;
  --node-active-border: #f59e0b;
  --node-active-glow: 0 0 20px rgba(245, 158, 11, 0.35), 0 0 40px rgba(245, 158, 11, 0.12);
  --node-done-bg: rgba(52, 211, 153, 0.10);
  --node-done-border: #34d399;

  /* Arrow */
  --arrow-color: #44381e;
  --arrow-active: #f59e0b;
  --arrow-done: #34d399;

  /* Progress bar */
  --progress-bg: #2a1f0e;
  --progress-fill: linear-gradient(90deg, #f59e0b, #dc2626);

  /* Button */
  --btn-bg: rgba(245, 158, 11, 0.10);
  --btn-border: rgba(245, 158, 11, 0.30);
  --btn-hover-bg: rgba(245, 158, 11, 0.20);
  --btn-text: #f59e0b;

  /* Notify toast */
  --notify-bg: rgba(245, 158, 11, 0.12);
  --notify-border: rgba(245, 158, 11, 0.40);
  --notify-text: #f59e0b;
}
```

### Google Fonts

```html
<link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;600&family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">
```

- **Headings & UI**: `Nunito`, sans-serif
- **Code**: `Fira Code`, monospace

---

## Theme Selection Guide

| Audience | Recommended Theme | Reason |
|----------|------------------|--------|
| Developers / Engineers | Dark Cyberpunk | Familiar IDE-like dark environment, reduces eye strain |
| Students (CS/IT) | Dark Cyberpunk | Engaging, modern look that matches dev tooling |
| Managers / Executives | Light Editorial | Clean, professional, easy to read on projectors |
| Non-technical staff | Light Editorial | Minimal visual noise, high contrast text |
| BM community workshops | Warm Malaysian | Warm, inviting, culturally resonant |
| Mixed / unsure | Dark Cyberpunk | Safe default with strong visual appeal |
| Print / export | Light Editorial | Best contrast for printing on paper |

### Applying a Theme

The theme is applied by setting CSS variables on `:root`. To switch themes, replace the `:root` variable block with the desired theme's variables. No other code changes needed — all components reference the CSS variables.
