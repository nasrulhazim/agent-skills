# Individual Showcase Template

Full-screen branded background showcase for browsing logos individually.
Based on the Reka Grafix (@taufixsaleh) presentation style — logo centered on solid
brand color background with navigation and download capabilities.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BrandName] — Logo Showcase</title>
  <style>
    :root {
      --brand-bg: #3045C9;     /* REPLACE: user's brand color */
      --brand-dark: #1a2a7a;   /* REPLACE: darker shade for UI elements */
      --logo-color: #ffffff;    /* REPLACE: logo fill color on brand bg */
      --alt-bg: #111111;        /* Dark background alternative */
      --light-bg: #f5f5f5;      /* Light background alternative */
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
      background: var(--brand-bg);
      color: #ffffff;
      height: 100vh;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      user-select: none;
    }

    /* ── Top Bar ── */
    .top-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 1rem 2rem;
      background: rgba(0,0,0,0.15);
      backdrop-filter: blur(8px);
      z-index: 10;
    }
    .top-bar .brand-title {
      font-size: 0.875rem;
      font-weight: 600;
      letter-spacing: 0.02em;
    }
    .top-bar .counter {
      font-size: 0.75rem;
      opacity: 0.7;
      font-variant-numeric: tabular-nums;
    }
    .top-bar .actions {
      display: flex;
      gap: 0.5rem;
    }
    .btn {
      background: rgba(255,255,255,0.15);
      border: 1px solid rgba(255,255,255,0.2);
      color: #fff;
      padding: 0.4rem 0.8rem;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.75rem;
      font-weight: 500;
      transition: background 0.15s;
    }
    .btn:hover { background: rgba(255,255,255,0.25); }
    .btn.active { background: rgba(255,255,255,0.3); border-color: rgba(255,255,255,0.5); }

    /* ── Main Showcase Area ── */
    .showcase {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      padding: 2rem;
    }
    .showcase .logo-display {
      max-width: 320px;
      max-height: 320px;
      width: 60vmin;
      height: 60vmin;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: opacity 0.3s ease;
    }
    .showcase .logo-display img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
      filter: drop-shadow(0 4px 24px rgba(0,0,0,0.15));
    }

    /* ── Navigation Arrows ── */
    .nav-arrow {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(255,255,255,0.1);
      border: 1px solid rgba(255,255,255,0.15);
      color: #fff;
      width: 48px;
      height: 48px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      font-size: 1.25rem;
      transition: background 0.15s;
    }
    .nav-arrow:hover { background: rgba(255,255,255,0.2); }
    .nav-arrow.prev { left: 2rem; }
    .nav-arrow.next { right: 2rem; }

    /* ── Bottom Info Bar ── */
    .bottom-bar {
      padding: 1rem 2rem;
      background: rgba(0,0,0,0.15);
      backdrop-filter: blur(8px);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .logo-info .logo-name {
      font-size: 1rem;
      font-weight: 600;
    }
    .logo-info .logo-meta {
      font-size: 0.75rem;
      opacity: 0.6;
      margin-top: 0.2rem;
    }
    .download-btn {
      background: rgba(255,255,255,0.9);
      color: var(--brand-bg);
      border: none;
      padding: 0.5rem 1.25rem;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.8rem;
      font-weight: 600;
      transition: background 0.15s;
    }
    .download-btn:hover { background: #ffffff; }

    /* ── Thumbnail Strip ── */
    .thumb-strip {
      display: flex;
      gap: 0.5rem;
      padding: 0.75rem 2rem;
      background: rgba(0,0,0,0.2);
      overflow-x: auto;
      scrollbar-width: thin;
      scrollbar-color: rgba(255,255,255,0.2) transparent;
    }
    .thumb {
      width: 56px;
      height: 56px;
      border-radius: 8px;
      border: 2px solid rgba(255,255,255,0.1);
      cursor: pointer;
      flex-shrink: 0;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0.35rem;
      background: rgba(255,255,255,0.05);
      transition: border-color 0.15s, background 0.15s;
    }
    .thumb:hover { border-color: rgba(255,255,255,0.3); }
    .thumb.active { border-color: #fff; background: rgba(255,255,255,0.15); }
    .thumb img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }

    /* ── Background modes ── */
    body.bg-brand { background: var(--brand-bg); }
    body.bg-dark { background: var(--alt-bg); }
    body.bg-light { background: var(--light-bg); color: #111; }
    body.bg-light .btn { color: #111; border-color: rgba(0,0,0,0.2); background: rgba(0,0,0,0.05); }
    body.bg-light .btn:hover { background: rgba(0,0,0,0.1); }
    body.bg-light .nav-arrow { color: #111; border-color: rgba(0,0,0,0.15); background: rgba(0,0,0,0.05); }
    body.bg-light .top-bar, body.bg-light .bottom-bar { background: rgba(0,0,0,0.05); }
    body.bg-light .thumb-strip { background: rgba(0,0,0,0.08); }
    body.bg-light .download-btn { background: var(--brand-bg); color: #fff; }

    /* ── Keyboard hint ── */
    .keyboard-hint {
      position: fixed;
      bottom: 0.5rem;
      right: 2rem;
      font-size: 0.65rem;
      opacity: 0.4;
    }
  </style>
</head>
<body class="bg-brand">

  <div class="top-bar">
    <div>
      <span class="brand-title">[BrandName] — Logo Showcase</span>
      <span class="counter" id="counter">1 / 25</span>
    </div>
    <div class="actions">
      <button class="btn active" onclick="setBg('brand')" id="btn-brand">Brand</button>
      <button class="btn" onclick="setBg('dark')" id="btn-dark">Dark</button>
      <button class="btn" onclick="setBg('light')" id="btn-light">Light</button>
    </div>
  </div>

  <div class="showcase">
    <button class="nav-arrow prev" onclick="navigate(-1)">&#8592;</button>
    <div class="logo-display" id="logo-display">
      <img id="main-logo" src="" alt="Logo">
    </div>
    <button class="nav-arrow next" onclick="navigate(1)">&#8594;</button>
  </div>

  <div class="bottom-bar">
    <div class="logo-info">
      <div class="logo-name" id="logo-name">Logo Name</div>
      <div class="logo-meta" id="logo-meta">Concept 1 — Variation A — Default</div>
    </div>
    <button class="download-btn" onclick="downloadCurrent()">Download SVG</button>
  </div>

  <div class="thumb-strip" id="thumb-strip">
    <!-- Thumbnails injected by JS -->
  </div>

  <div class="keyboard-hint">Arrow keys to navigate &bull; 1/2/3 to change background</div>

  <script>
    // ── DATA: Replace with actual logo files ──
    const logos = [
      { file: 'logo-01-a-desc.svg', name: 'Concept 1A', concept: '01', variation: 'A', desc: 'Default pose' },
      { file: 'logo-01-b-desc.svg', name: 'Concept 1B', concept: '01', variation: 'B', desc: 'Action pose' },
      // ... populate all 25
    ];

    let currentIndex = 0;

    function showLogo(index) {
      currentIndex = index;
      const logo = logos[index];
      document.getElementById('main-logo').src = logo.file;
      document.getElementById('main-logo').alt = logo.name;
      document.getElementById('logo-name').textContent = logo.name;
      document.getElementById('logo-meta').textContent =
        `Concept ${logo.concept} — Variation ${logo.variation} — ${logo.desc}`;
      document.getElementById('counter').textContent = `${index + 1} / ${logos.length}`;

      document.querySelectorAll('.thumb').forEach((t, i) => {
        t.classList.toggle('active', i === index);
      });

      // Scroll active thumb into view
      const activeThumb = document.querySelector('.thumb.active');
      if (activeThumb) activeThumb.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }

    function navigate(direction) {
      let next = currentIndex + direction;
      if (next < 0) next = logos.length - 1;
      if (next >= logos.length) next = 0;
      showLogo(next);
    }

    function setBg(mode) {
      document.body.className = `bg-${mode}`;
      document.querySelectorAll('.actions .btn').forEach(b => b.classList.remove('active'));
      document.getElementById(`btn-${mode}`).classList.add('active');
    }

    function downloadCurrent() {
      const logo = logos[currentIndex];
      const a = document.createElement('a');
      a.href = logo.file;
      a.download = logo.file;
      a.click();
    }

    // ── Keyboard navigation ──
    document.addEventListener('keydown', e => {
      if (e.key === 'ArrowLeft') navigate(-1);
      if (e.key === 'ArrowRight') navigate(1);
      if (e.key === '1') setBg('brand');
      if (e.key === '2') setBg('dark');
      if (e.key === '3') setBg('light');
    });

    // ── Build thumbnails ──
    const strip = document.getElementById('thumb-strip');
    logos.forEach((logo, i) => {
      strip.innerHTML += `
        <div class="thumb ${i === 0 ? 'active' : ''}" onclick="showLogo(${i})">
          <img src="${logo.file}" alt="${logo.name}" loading="lazy">
        </div>
      `;
    });

    // ── Init ──
    if (logos.length > 0) showLogo(0);
  </script>

</body>
</html>
```

## Notes

- **Three background modes**: Brand color (default), Dark (#111), Light (#f5f5f5)
- User toggles with buttons or keyboard shortcuts (1, 2, 3)
- Arrow keys for prev/next navigation
- Thumbnail strip at the bottom for quick jumping
- Download button exports the current SVG file
- **Replace all `[BrandName]`** with actual brand name
- **Replace `--brand-bg`** with user's chosen brand color
- **Replace `--brand-dark`** with a darker shade for contrast
- All SVG files must be in the same directory as this HTML file
- The `logos` array must be populated with all generated filenames
- Logo display area uses `60vmin` for responsive sizing
- Drop shadow on logos provides subtle depth against flat backgrounds
