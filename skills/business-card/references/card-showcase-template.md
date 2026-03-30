# Card Showcase Template

Full-screen showcase for browsing business cards individually with CSS 3D flip animation
for front/back preview. Click the card or press spacebar to flip between front and back.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Name] — Business Card Showcase</title>
  <style>
    :root {
      --brand-bg: #3b82f6;     /* REPLACE: user's brand color */
      --brand-dark: #1e40af;   /* REPLACE: darker shade for UI elements */
      --alt-bg: #111111;
      --light-bg: #f5f5f5;
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
      margin-left: 0.75rem;
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

    /* ── Showcase Area ── */
    .showcase {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      padding: 2rem;
    }

    /* ── 3D Flip Card ── */
    .card-container {
      width: 350px;
      aspect-ratio: 7/4;
      perspective: 1000px;
      cursor: pointer;
    }
    .card-inner {
      position: relative;
      width: 100%;
      height: 100%;
      transition: transform 0.6s ease;
      transform-style: preserve-3d;
    }
    .card-container.flipped .card-inner {
      transform: rotateY(180deg);
    }
    .card-front, .card-back {
      position: absolute;
      width: 100%;
      height: 100%;
      backface-visibility: hidden;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 8px 32px rgba(0,0,0,0.25);
    }
    .card-front img, .card-back img {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }
    .card-back {
      transform: rotateY(180deg);
    }

    .flip-hint {
      position: absolute;
      bottom: -2rem;
      left: 50%;
      transform: translateX(-50%);
      font-size: 0.7rem;
      opacity: 0.5;
      white-space: nowrap;
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

    /* ── Bottom Bar ── */
    .bottom-bar {
      padding: 1rem 2rem;
      background: rgba(0,0,0,0.15);
      backdrop-filter: blur(8px);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .card-info .card-name {
      font-size: 1rem;
      font-weight: 600;
    }
    .card-info .card-meta {
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
      width: 70px;
      aspect-ratio: 7/4;
      border-radius: 6px;
      border: 2px solid rgba(255,255,255,0.1);
      cursor: pointer;
      flex-shrink: 0;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
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
      <span class="brand-title">[Name] — Business Card Showcase</span>
      <span class="counter" id="counter">1 / 12</span>
    </div>
    <div class="actions">
      <button class="btn" onclick="flipCard()">Flip</button>
      <button class="btn active" onclick="setBg('brand')" id="btn-brand">Brand</button>
      <button class="btn" onclick="setBg('dark')" id="btn-dark">Dark</button>
      <button class="btn" onclick="setBg('light')" id="btn-light">Light</button>
    </div>
  </div>

  <div class="showcase">
    <button class="nav-arrow prev" onclick="navigate(-1)">&#8592;</button>

    <div class="card-container" id="card-container" onclick="flipCard()">
      <div class="card-inner" id="card-inner">
        <div class="card-front">
          <img id="front-img" src="" alt="Front">
        </div>
        <div class="card-back">
          <img id="back-img" src="" alt="Back">
        </div>
      </div>
      <div class="flip-hint">Click or press Space to flip</div>
    </div>

    <button class="nav-arrow next" onclick="navigate(1)">&#8594;</button>
  </div>

  <div class="bottom-bar">
    <div class="card-info">
      <div class="card-name" id="card-name">Card Name</div>
      <div class="card-meta" id="card-meta">Card #01 — Minimal Left-Aligned</div>
    </div>
    <button class="download-btn" onclick="downloadCurrent()">Download SVG</button>
  </div>

  <div class="thumb-strip" id="thumb-strip">
    <!-- Thumbnails injected by JS -->
  </div>

  <div class="keyboard-hint">Arrow keys: navigate &bull; Space: flip &bull; 1/2/3: background</div>

  <script>
    // ── DATA: Replace with actual card files ──
    const cards = [
      { id: '01', name: 'Minimal Left-Aligned', file: 'card-01-minimal-left.svg', backFile: 'card-back-01.svg' },
      { id: '02', name: 'Minimal Centered', file: 'card-02-minimal-center.svg', backFile: 'card-back-01.svg' },
      // ... populate all cards
      // Set backFile to null if no back design
    ];

    let currentIndex = 0;
    let isFlipped = false;

    function showCard(index) {
      currentIndex = index;
      isFlipped = false;
      document.getElementById('card-container').classList.remove('flipped');

      const card = cards[index];
      document.getElementById('front-img').src = card.file;
      document.getElementById('front-img').alt = `Card #${card.id} — Front`;
      document.getElementById('back-img').src = card.backFile || '';
      document.getElementById('back-img').alt = card.backFile ? `Card #${card.id} — Back` : '';
      document.getElementById('card-name').textContent = `#${card.id} — ${card.name}`;
      document.getElementById('card-meta').textContent =
        `Card ${parseInt(card.id)} of ${cards.length}` + (card.backFile ? ' — has back design' : '');
      document.getElementById('counter').textContent = `${index + 1} / ${cards.length}`;

      // Hide back side if no back design
      document.querySelector('.card-back').style.visibility = card.backFile ? 'visible' : 'hidden';
      document.querySelector('.flip-hint').style.display = card.backFile ? 'block' : 'none';

      document.querySelectorAll('.thumb').forEach((t, i) => {
        t.classList.toggle('active', i === index);
      });
      const activeThumb = document.querySelector('.thumb.active');
      if (activeThumb) activeThumb.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }

    function flipCard() {
      const card = cards[currentIndex];
      if (!card.backFile) return;
      isFlipped = !isFlipped;
      document.getElementById('card-container').classList.toggle('flipped', isFlipped);
    }

    function navigate(direction) {
      let next = currentIndex + direction;
      if (next < 0) next = cards.length - 1;
      if (next >= cards.length) next = 0;
      showCard(next);
    }

    function setBg(mode) {
      document.body.className = `bg-${mode}`;
      document.querySelectorAll('.actions .btn').forEach(b => b.classList.remove('active'));
      document.getElementById(`btn-${mode}`).classList.add('active');
    }

    function downloadCurrent() {
      const card = cards[currentIndex];
      const file = isFlipped && card.backFile ? card.backFile : card.file;
      const a = document.createElement('a');
      a.href = file;
      a.download = file;
      a.click();
    }

    // ── Keyboard ──
    document.addEventListener('keydown', e => {
      if (e.key === 'ArrowLeft') navigate(-1);
      if (e.key === 'ArrowRight') navigate(1);
      if (e.key === ' ') { e.preventDefault(); flipCard(); }
      if (e.key === '1') setBg('brand');
      if (e.key === '2') setBg('dark');
      if (e.key === '3') setBg('light');
    });

    // ── Build thumbnails ──
    const strip = document.getElementById('thumb-strip');
    cards.forEach((card, i) => {
      strip.innerHTML += `
        <div class="thumb ${i === 0 ? 'active' : ''}" onclick="showCard(${i})">
          <img src="${card.file}" alt="${card.name}" loading="lazy">
        </div>
      `;
    });

    // ── Init ──
    if (cards.length > 0) showCard(0);
  </script>

</body>
</html>
```

## Notes

- **Three background modes**: Brand color (default), Dark (#111), Light (#f5f5f5)
- **Flip animation**: Click the card or press spacebar to flip between front and back
- Arrow keys for prev/next navigation, 1/2/3 for background modes
- Thumbnail strip uses 7:4 aspect ratio to match business card proportions
- If a card has no `backFile` (set to `null`), the flip hint and back face are hidden
- Download button exports the currently visible side (front or back)
- **Replace `--brand-bg`** with user's chosen brand color
- **Replace `--brand-dark`** with a darker shade for contrast
- **Replace `[Name]`** with the person's name or brand
- All SVG files must be in the same directory as this HTML file
- Card display width is 350px — proportional to a real business card
