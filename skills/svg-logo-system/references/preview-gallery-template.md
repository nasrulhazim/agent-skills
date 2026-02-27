# Phase 1 Preview Gallery Template

Use this structure for `preview.html`. Adapt colors, card counts, and SVG paths as needed.

```html
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BrandName] — Logo Concepts</title>
  <style>
    :root[data-theme="dark"] {
      --bg: #0B1120;
      --card-bg: #161E30;
      --border: #2A3550;
      --text: #E2E8F0;
      --subtext: #94A3B8;
      --selected-border: #6366F1;
    }
    :root[data-theme="light"] {
      --bg: #F8FAFC;
      --card-bg: #FFFFFF;
      --border: #E2E8F0;
      --text: #1E293B;
      --subtext: #64748B;
      --selected-border: #6366F1;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: system-ui, -apple-system, sans-serif;
      padding: 2rem;
      transition: background 0.2s, color 0.2s;
    }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 2rem;
    }
    h1 { font-size: 1.5rem; font-weight: 600; }
    .toggle-btn {
      background: var(--card-bg);
      border: 1px solid var(--border);
      color: var(--text);
      padding: 0.5rem 1rem;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.875rem;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
      gap: 1.25rem;
    }
    .card {
      background: var(--card-bg);
      border: 2px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      cursor: pointer;
      transition: border-color 0.15s, transform 0.1s;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 1rem;
    }
    .card:hover { transform: translateY(-2px); border-color: var(--subtext); }
    .card.selected { border-color: var(--selected-border); }
    .card .logo-wrap {
      width: 100%;
      aspect-ratio: 2/1;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .card img, .card svg { max-width: 100%; max-height: 100%; }
    .card .label {
      font-size: 0.8rem;
      color: var(--subtext);
      text-align: center;
      font-weight: 500;
    }
    .card .badge {
      font-size: 0.7rem;
      background: var(--selected-border);
      color: #fff;
      border-radius: 4px;
      padding: 0.15rem 0.4rem;
      display: none;
    }
    .card.selected .badge { display: inline-block; }
    .selection-info {
      margin-top: 2rem;
      padding: 1rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      font-size: 0.875rem;
      color: var(--subtext);
    }
  </style>
</head>
<body>
  <header>
    <div>
      <h1>[BrandName] — 25 Logo Concepts</h1>
      <p style="color:var(--subtext);font-size:0.875rem;margin-top:0.25rem">
        Click a concept to select it. Toggle dark/light to preview both modes.
      </p>
    </div>
    <button class="toggle-btn" onclick="toggleTheme()">☀️ Light Mode</button>
  </header>

  <div class="grid" id="grid">
    <!-- Cards injected by JS -->
  </div>

  <div class="selection-info" id="selection-info">
    No concept selected yet. Click one above.
  </div>

  <script>
    // Replace this array with actual logo file references
    const logos = [
      { id: '01', name: 'Geometric Shield',   file: 'logo-01-geometric-shield.svg' },
      { id: '02', name: 'Wordmark Bold',       file: 'logo-02-wordmark-bold.svg' },
      // ... repeat for all 25
    ];

    let selected = null;

    function toggleTheme() {
      const html = document.documentElement;
      const isDark = html.dataset.theme === 'dark';
      html.dataset.theme = isDark ? 'light' : 'dark';
      document.querySelector('.toggle-btn').textContent = isDark ? '🌙 Dark Mode' : '☀️ Light Mode';
    }

    function selectCard(id) {
      selected = id;
      document.querySelectorAll('.card').forEach(c => {
        c.classList.toggle('selected', c.dataset.id === id);
      });
      const logo = logos.find(l => l.id === id);
      document.getElementById('selection-info').innerHTML =
        `✅ Selected: <strong>#${logo.id} — ${logo.name}</strong>. Tell Claude "go with #${logo.id}" to proceed to refinement.`;
    }

    const grid = document.getElementById('grid');
    logos.forEach(logo => {
      grid.innerHTML += `
        <div class="card" data-id="${logo.id}" onclick="selectCard('${logo.id}')">
          <div class="logo-wrap">
            <img src="${logo.file}" alt="${logo.name}" loading="lazy">
          </div>
          <div class="label">#${logo.id} — ${logo.name}</div>
          <span class="badge">Selected</span>
        </div>`;
    });
  </script>
</body>
</html>
```

## Notes
- The `logos` array in the JS should be populated with all 25 generated filenames and concept names.
- Cards use `<img>` tags pointing to the SVG files — they must be in the same directory.
- The toggle switches `data-theme` on `<html>`, which changes CSS variables globally.
- To inline SVGs instead of using `<img>`, replace `<img src="...">` with the raw SVG markup.
