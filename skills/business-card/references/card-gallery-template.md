# Card Gallery Template

Dark background grid gallery for displaying business card concepts in a responsive layout.
Cards are displayed at 7:4 aspect ratio (3.5" x 2") to match real business card proportions.

```html
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Name] — Business Card Concepts</title>
  <style>
    :root[data-theme="dark"] {
      --bg: #111111;
      --card-bg: #1a1a1a;
      --card-hover: #222222;
      --border: #333333;
      --text: #ffffff;
      --subtext: #888888;
      --brand: #3b82f6;       /* REPLACE: user's brand color */
      --selected-border: #3b82f6;
    }
    :root[data-theme="light"] {
      --bg: #f5f5f5;
      --card-bg: #ffffff;
      --card-hover: #fafafa;
      --border: #e0e0e0;
      --text: #111111;
      --subtext: #666666;
      --brand: #3b82f6;
      --selected-border: #3b82f6;
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
    .toggle-btn {
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
    .toggle-btn:hover { border-color: var(--brand); }
    .toggle-btn.active { border-color: var(--brand); background: var(--brand); color: #fff; }

    /* ── Grid ── */
    .card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 1.5rem;
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

    .card .card-preview {
      aspect-ratio: 7/4;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1.25rem;
    }
    .card .card-preview img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
      border-radius: 4px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.2);
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

    /* ── Back card overlay ── */
    .card .back-preview {
      display: none;
      aspect-ratio: 7/4;
      padding: 1.25rem;
      align-items: center;
      justify-content: center;
      border-top: 1px dashed var(--border);
    }
    .card .back-preview img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
      border-radius: 4px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.2);
    }
    .show-backs .card .back-preview { display: flex; }

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
      .card-grid { grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }
    }
    @media (max-width: 480px) {
      .card-grid { grid-template-columns: 1fr; }
      body { padding: 1rem; }
    }
  </style>
</head>
<body>

  <header>
    <div class="header-info">
      <h1>[Name] — Business Card Concepts</h1>
      <p>12 front designs. Click to select your favourite.</p>
    </div>
    <div class="header-actions">
      <button class="toggle-btn" onclick="toggleTheme()">Light Mode</button>
      <button class="toggle-btn" id="btn-backs" onclick="toggleBacks()">Show Backs</button>
    </div>
  </header>

  <div class="card-grid" id="card-grid">
    <!-- Cards injected by JS -->
  </div>

  <div class="selection-info" id="selection-info">
    No card selected yet. Click a design above to select it.
  </div>

  <script>
    // ── DATA: Replace with actual card files ──
    const cards = [
      { id: '01', name: 'Minimal Left-Aligned', file: 'card-01-minimal-left.svg', backFile: 'card-back-01.svg' },
      { id: '02', name: 'Minimal Centered', file: 'card-02-minimal-center.svg', backFile: 'card-back-01.svg' },
      // ... populate all 12 front concepts
      // Set backFile to null if no back design for that card
    ];

    let selected = null;
    let showingBacks = false;

    function toggleTheme() {
      const html = document.documentElement;
      const isDark = html.dataset.theme === 'dark';
      html.dataset.theme = isDark ? 'light' : 'dark';
      document.querySelector('.toggle-btn').textContent = isDark ? 'Dark Mode' : 'Light Mode';
    }

    function toggleBacks() {
      showingBacks = !showingBacks;
      document.body.classList.toggle('show-backs', showingBacks);
      document.getElementById('btn-backs').textContent = showingBacks ? 'Hide Backs' : 'Show Backs';
      document.getElementById('btn-backs').classList.toggle('active', showingBacks);
    }

    function selectCard(id) {
      selected = id;
      document.querySelectorAll('.card').forEach(c => {
        c.classList.toggle('selected', c.dataset.id === id);
      });
      const card = cards.find(c => c.id === id);
      document.getElementById('selection-info').innerHTML =
        `Selected: <strong>Card #${card.id} — ${card.name}</strong><br>` +
        `Tell Claude: "go with card #${card.id}" or "I like card #${card.id}, refine it"`;
    }

    // ── Render grid ──
    const grid = document.getElementById('card-grid');

    cards.forEach(card => {
      const el = document.createElement('div');
      el.className = 'card';
      el.dataset.id = card.id;
      el.onclick = () => selectCard(card.id);
      el.innerHTML = `
        <div class="card-preview">
          <img src="${card.file}" alt="Card #${card.id} — ${card.name}" loading="lazy">
        </div>
        ${card.backFile ? `
          <div class="back-preview">
            <img src="${card.backFile}" alt="Card #${card.id} — Back" loading="lazy">
          </div>
        ` : ''}
        <div class="card-label">
          <span class="name">#${card.id} — ${card.name}</span>
          <span class="badge">Selected</span>
        </div>
      `;
      grid.appendChild(el);
    });
  </script>

</body>
</html>
```

## Notes

- **Dark background is the default** — matches the design showcase aesthetic.
- The `cards` array must be populated with all 12 SVG file references.
- All SVG files must be in the same directory as this HTML file.
- Card aspect ratio is `7/4` to match the 3.5:2 business card proportion.
- For vertical cards, change aspect ratio to `4/7`.
- The "Show Backs" toggle reveals back designs below each front card.
- Set `backFile` to `null` for cards without a back design.
- On mobile, the grid collapses to a single column.
- **Replace all placeholder colors** (`--brand`, `--selected-border`) with the user's chosen brand color.
