# Grid Gallery Template

Dark background grid gallery for displaying 25 logo concepts in a 5x5 layout.
Inspired by the Reka Grafix (@taufixsaleh) showcase style — logos on dark background,
organized by concept rows with variation columns.

```html
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BrandName] — Logo Concepts Grid</title>
  <style>
    :root[data-theme="dark"] {
      --bg: #111111;
      --card-bg: #1a1a1a;
      --card-hover: #222222;
      --border: #333333;
      --text: #ffffff;
      --subtext: #888888;
      --brand: #3045C9;       /* REPLACE: user's brand color */
      --selected-border: #3045C9;
    }
    :root[data-theme="light"] {
      --bg: #f5f5f5;
      --card-bg: #ffffff;
      --card-hover: #fafafa;
      --border: #e0e0e0;
      --text: #111111;
      --subtext: #666666;
      --brand: #3045C9;
      --selected-border: #3045C9;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      background: var(--bg);
      color: var(--text);
      font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
      padding: 2rem;
      transition: background 0.3s, color 0.3s;
    }

    /* ── Header ── */
    header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 2.5rem;
      flex-wrap: wrap;
      gap: 1rem;
    }
    .header-info h1 {
      font-size: 1.75rem;
      font-weight: 700;
      letter-spacing: -0.02em;
    }
    .header-info p {
      color: var(--subtext);
      font-size: 0.875rem;
      margin-top: 0.375rem;
    }
    .header-actions {
      display: flex;
      gap: 0.75rem;
      align-items: center;
    }
    .toggle-btn, .view-btn {
      background: var(--card-bg);
      border: 1px solid var(--border);
      color: var(--text);
      padding: 0.5rem 1rem;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.8rem;
      font-weight: 500;
      transition: border-color 0.15s;
    }
    .toggle-btn:hover, .view-btn:hover { border-color: var(--brand); }

    /* ── Concept Row Headers ── */
    .concept-group {
      margin-bottom: 2rem;
    }
    .concept-header {
      display: flex;
      align-items: center;
      gap: 1rem;
      margin-bottom: 0.75rem;
      padding-bottom: 0.5rem;
      border-bottom: 1px solid var(--border);
    }
    .concept-number {
      font-size: 0.7rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--brand);
      min-width: 80px;
    }
    .concept-name {
      font-size: 0.875rem;
      font-weight: 600;
      color: var(--text);
    }
    .concept-desc {
      font-size: 0.75rem;
      color: var(--subtext);
    }

    /* ── Variation Labels ── */
    .variation-labels {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 1rem;
      margin-bottom: 0.5rem;
      padding: 0 0.25rem;
    }
    .variation-labels span {
      text-align: center;
      font-size: 0.65rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      color: var(--subtext);
    }

    /* ── Grid ── */
    .concept-grid {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 1rem;
    }

    /* ── Card ── */
    .card {
      background: var(--card-bg);
      border: 2px solid var(--border);
      border-radius: 12px;
      cursor: pointer;
      transition: border-color 0.15s, transform 0.1s, background 0.15s;
      overflow: hidden;
      position: relative;
    }
    .card:hover {
      transform: translateY(-2px);
      border-color: var(--subtext);
      background: var(--card-hover);
    }
    .card.selected { border-color: var(--selected-border); }

    .card .logo-area {
      aspect-ratio: 1/1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1.25rem;
    }
    .card .logo-area img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }

    .card .card-label {
      padding: 0.5rem 0.75rem;
      border-top: 1px solid var(--border);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .card .card-label .name {
      font-size: 0.7rem;
      color: var(--subtext);
      font-weight: 500;
    }
    .card .badge {
      font-size: 0.6rem;
      background: var(--brand);
      color: #fff;
      border-radius: 4px;
      padding: 0.1rem 0.35rem;
      display: none;
      font-weight: 600;
    }
    .card.selected .badge { display: inline-block; }

    /* ── Selection Info ── */
    .selection-info {
      margin-top: 2rem;
      padding: 1.25rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 10px;
      font-size: 0.875rem;
      color: var(--subtext);
    }
    .selection-info strong { color: var(--text); }

    /* ── Responsive ── */
    @media (max-width: 768px) {
      .concept-grid { grid-template-columns: repeat(3, 1fr); }
      .variation-labels { grid-template-columns: repeat(3, 1fr); }
    }
    @media (max-width: 480px) {
      .concept-grid { grid-template-columns: repeat(2, 1fr); }
      .variation-labels { display: none; }
      body { padding: 1rem; }
    }
  </style>
</head>
<body>

  <header>
    <div class="header-info">
      <h1>[BrandName] — Logo Concepts</h1>
      <p>5 concepts &times; 5 variations = 25 options. Click to select your favourite.</p>
    </div>
    <div class="header-actions">
      <button class="toggle-btn" onclick="toggleTheme()">Light Mode</button>
    </div>
  </header>

  <div class="variation-labels">
    <span>A &mdash; Default</span>
    <span>B &mdash; Action</span>
    <span>C &mdash; Expression</span>
    <span>D &mdash; With Prop</span>
    <span>E &mdash; Simplified</span>
  </div>

  <div id="concepts-container">
    <!-- Concept groups injected by JS -->
  </div>

  <div class="selection-info" id="selection-info">
    No concept selected yet. Click a logo above to select it.
  </div>

  <script>
    // ── DATA: Replace with actual logo files ──
    // Each concept has 5 variations (a-e)
    const concepts = [
      {
        id: '01',
        name: 'Concept Name 1',
        desc: 'Brief description of this concept direction',
        variations: [
          { id: 'a', name: 'Default', file: 'logo-01-a-desc.svg' },
          { id: 'b', name: 'Action', file: 'logo-01-b-desc.svg' },
          { id: 'c', name: 'Expression', file: 'logo-01-c-desc.svg' },
          { id: 'd', name: 'With Prop', file: 'logo-01-d-desc.svg' },
          { id: 'e', name: 'Simplified', file: 'logo-01-e-desc.svg' },
        ]
      },
      // ... repeat for concepts 02-05
    ];

    let selected = null;

    function toggleTheme() {
      const html = document.documentElement;
      const isDark = html.dataset.theme === 'dark';
      html.dataset.theme = isDark ? 'light' : 'dark';
      document.querySelector('.toggle-btn').textContent = isDark ? 'Dark Mode' : 'Light Mode';
    }

    function selectCard(conceptId, variationId) {
      const key = `${conceptId}-${variationId}`;
      selected = key;
      document.querySelectorAll('.card').forEach(c => {
        c.classList.toggle('selected', c.dataset.key === key);
      });
      const concept = concepts.find(c => c.id === conceptId);
      const variation = concept.variations.find(v => v.id === variationId);
      document.getElementById('selection-info').innerHTML =
        `Selected: <strong>Concept #${concept.id} (${concept.name}) — Variation ${variation.id.toUpperCase()} (${variation.name})</strong><br>` +
        `Tell Claude: "go with concept ${concept.id} variation ${variation.id}" or "I like concept ${concept.id}, refine it"`;
    }

    // ── Render grid ──
    const container = document.getElementById('concepts-container');

    concepts.forEach(concept => {
      const group = document.createElement('div');
      group.className = 'concept-group';
      group.innerHTML = `
        <div class="concept-header">
          <span class="concept-number">Concept ${concept.id}</span>
          <span class="concept-name">${concept.name}</span>
          <span class="concept-desc">${concept.desc}</span>
        </div>
        <div class="concept-grid">
          ${concept.variations.map(v => `
            <div class="card" data-key="${concept.id}-${v.id}"
                 onclick="selectCard('${concept.id}', '${v.id}')">
              <div class="logo-area">
                <img src="${v.file}" alt="${concept.name} - ${v.name}" loading="lazy">
              </div>
              <div class="card-label">
                <span class="name">${v.id.toUpperCase()} — ${v.name}</span>
                <span class="badge">Selected</span>
              </div>
            </div>
          `).join('')}
        </div>
      `;
      container.appendChild(group);
    });
  </script>

</body>
</html>
```

## Notes

- **Dark background is the default** — matches the Reka Grafix (@taufixsaleh) showcase style.
- The `concepts` array must be populated with all 25 SVG file references (5 concepts x 5 variations).
- All SVG files must be in the same directory as this HTML file.
- Concept group headers help the user understand each direction before comparing variations.
- The 5-column layout maps to: Default, Action, Expression, With Prop, Simplified.
- On mobile, the grid collapses gracefully to 3 or 2 columns.
- **Replace all placeholder colors** (`--brand`, `--selected-border`) with the user's chosen brand color.
- Card aspect ratio is 1:1 (square) to match circular/contained logo designs.
