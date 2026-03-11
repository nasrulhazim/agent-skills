# HTML Template Reference

## Full HTML Boilerplate

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{COURSE_TITLE}} — Interactive Courseware</title>

  <!-- Optional: Google Fonts (only external dependency) -->
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Inter:wght@400;600;700&display=swap" rel="stylesheet">

  <style>
    /* ===== RESET ===== */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    /* ===== THEME VARIABLES (Dark Cyberpunk default) ===== */
    :root {
      --bg-primary: #0a0e27;
      --bg-secondary: #131836;
      --bg-panel: #0f1335;
      --bg-card: #181d45;
      --bg-code: #0d1117;
      --accent: #00e5ff;
      --accent-glow: rgba(0,229,255,0.35);
      --accent-dim: rgba(0,229,255,0.10);
      --secondary: #a855f7;
      --secondary-glow: rgba(168,85,247,0.30);
      --text-primary: #e2e8f0;
      --text-secondary: #94a3b8;
      --text-muted: #64748b;
      --border: rgba(0,229,255,0.15);
      --border-active: rgba(0,229,255,0.50);
      --node-bg: #181d45;
      --node-border: rgba(0,229,255,0.25);
      --node-active-bg: #1a2555;
      --node-active-border: #00e5ff;
      --node-active-glow: 0 0 20px rgba(0,229,255,0.4), 0 0 40px rgba(0,229,255,0.15);
      --node-done-bg: rgba(52,211,153,0.12);
      --node-done-border: #34d399;
      --arrow-color: #334155;
      --arrow-active: #00e5ff;
      --arrow-done: #34d399;
      --progress-bg: #1e293b;
      --progress-fill: linear-gradient(90deg, #00e5ff, #a855f7);
      --btn-bg: rgba(0,229,255,0.10);
      --btn-border: rgba(0,229,255,0.30);
      --btn-hover-bg: rgba(0,229,255,0.20);
      --btn-text: #00e5ff;
      --notify-bg: rgba(0,229,255,0.15);
      --notify-border: rgba(0,229,255,0.40);
      --notify-text: #00e5ff;
    }

    /* ===== BASE ===== */
    body {
      font-family: 'Inter', sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }

    /* ===== HEADER ===== */
    .header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px 32px;
      background: var(--bg-secondary);
      border-bottom: 1px solid var(--border);
    }
    .header .brand {
      font-weight: 700;
      color: var(--accent);
      font-size: 14px;
      letter-spacing: 2px;
      text-transform: uppercase;
    }
    .header .title {
      font-size: 18px;
      font-weight: 600;
    }
    .header .counter {
      font-size: 14px;
      color: var(--text-secondary);
      font-family: 'JetBrains Mono', monospace;
    }

    /* ===== MAIN LAYOUT ===== */
    .main {
      display: flex;
      flex: 1;
      overflow: hidden;
    }

    /* ===== LEFT PANEL ===== */
    .left-panel {
      width: 330px;
      min-width: 330px;
      padding: 28px 24px;
      background: var(--bg-panel);
      border-right: 1px solid var(--border);
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
    .step-badge {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: var(--accent-dim);
      border: 2px solid var(--accent);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 18px;
      color: var(--accent);
      font-family: 'JetBrains Mono', monospace;
    }
    .step-title {
      font-size: 22px;
      font-weight: 700;
      line-height: 1.3;
    }
    .step-desc {
      font-size: 14px;
      color: var(--text-secondary);
      line-height: 1.7;
    }

    /* Actor tags */
    .actors { display: flex; flex-wrap: wrap; gap: 8px; }
    .actor {
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
    .actor-user     { background: rgba(96,165,250,0.15);  color: #60a5fa; }
    .actor-server   { background: rgba(167,139,250,0.15); color: #a78bfa; }
    .actor-browser  { background: rgba(52,211,153,0.15);  color: #34d399; }
    .actor-keycloak { background: rgba(244,114,182,0.15); color: #f472b6; }
    .actor-gateway  { background: rgba(251,146,60,0.15);  color: #fb923c; }
    .actor-db       { background: rgba(251,191,36,0.15);  color: #fbbf24; }
    .actor-queue    { background: rgba(45,212,191,0.15);  color: #2dd4bf; }
    .actor-external { background: rgba(148,163,184,0.15); color: #94a3b8; }

    /* Key points */
    .points { display: flex; flex-direction: column; gap: 8px; }
    .point {
      padding: 10px 14px;
      border-radius: 8px;
      font-size: 13px;
      line-height: 1.5;
      border-left: 3px solid;
    }
    .point-info    { background: rgba(96,165,250,0.08);  border-color: #60a5fa; }
    .point-warn    { background: rgba(251,191,36,0.08);  border-color: #fbbf24; }
    .point-danger  { background: rgba(248,113,113,0.08); border-color: #f87171; }
    .point-success { background: rgba(52,211,153,0.08);  border-color: #34d399; }

    /* ===== RIGHT PANEL ===== */
    .right-panel {
      flex: 1;
      display: flex;
      flex-direction: column;
      padding: 24px;
      gap: 20px;
      overflow-y: auto;
    }

    /* Flow diagram container */
    .diagram {
      position: relative;
      min-height: 300px;
      background: var(--bg-secondary);
      border-radius: 12px;
      border: 1px solid var(--border);
      flex: 1;
    }

    /* Flow nodes */
    .node {
      position: absolute;
      padding: 14px 22px;
      background: var(--node-bg);
      border: 2px solid var(--node-border);
      border-radius: 10px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      z-index: 2;
      user-select: none;
    }
    .node:hover { border-color: var(--accent); }
    .node.active {
      background: var(--node-active-bg);
      border-color: var(--node-active-border);
      box-shadow: var(--node-active-glow);
      transform: scale(1.15);
      z-index: 3;
    }
    .node.done {
      background: var(--node-done-bg);
      border-color: var(--node-done-border);
    }
    .node.done::after {
      content: ' ✓';
      color: var(--node-done-border);
      font-weight: 700;
    }

    /* SVG arrows */
    .diagram svg {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 100%;
      pointer-events: none;
      z-index: 1;
    }
    .diagram svg line {
      stroke: var(--arrow-color);
      stroke-width: 2;
      transition: stroke 0.3s ease;
    }
    .diagram svg line.active { stroke: var(--arrow-active); stroke-width: 2.5; }
    .diagram svg line.done   { stroke: var(--arrow-done); }
    .diagram svg text {
      fill: var(--text-muted);
      font-size: 11px;
      font-family: 'Inter', sans-serif;
    }

    /* Packet animation dot */
    .packet {
      position: absolute;
      width: 10px;
      height: 10px;
      background: var(--accent);
      border-radius: 50%;
      box-shadow: 0 0 12px var(--accent-glow);
      z-index: 4;
      pointer-events: none;
      opacity: 0;
    }
    .packet.animate {
      opacity: 1;
      animation: packetMove var(--packet-duration, 600ms) ease-in-out forwards;
    }

    /* Code panel */
    .code-panel {
      background: var(--bg-code);
      border-radius: 10px;
      border: 1px solid var(--border);
      overflow: hidden;
    }
    .code-header {
      padding: 8px 16px;
      background: var(--bg-card);
      border-bottom: 1px solid var(--border);
      font-size: 12px;
      color: var(--text-muted);
      font-family: 'JetBrains Mono', monospace;
    }
    .code-body {
      padding: 16px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 13px;
      line-height: 1.7;
      overflow-x: auto;
      white-space: pre;
    }

    /* Syntax highlighting */
    .kw  { color: #c792ea; } /* keyword */
    .fn  { color: #82aaff; } /* function */
    .str { color: #c3e88d; } /* string */
    .cmt { color: #546e7a; } /* comment */
    .var { color: #f78c6c; } /* variable */
    .cls { color: #ffcb6b; } /* class */
    .num { color: #f78c6c; } /* number */
    .arr { color: #89ddff; } /* arrow/operator */

    /* ===== FOOTER ===== */
    .footer {
      padding: 16px 32px;
      background: var(--bg-secondary);
      border-top: 1px solid var(--border);
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .footer-controls {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 16px;
    }
    .btn {
      padding: 8px 20px;
      background: var(--btn-bg);
      border: 1px solid var(--btn-border);
      border-radius: 8px;
      color: var(--btn-text);
      font-weight: 600;
      font-size: 14px;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn:hover { background: var(--btn-hover-bg); }
    .btn:disabled { opacity: 0.4; cursor: not-allowed; }

    /* Step dots */
    .dots {
      display: flex;
      gap: 8px;
      align-items: center;
    }
    .dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      border: 2px solid var(--text-muted);
      background: transparent;
      cursor: pointer;
      transition: all 0.2s;
    }
    .dot.visited { background: var(--text-muted); }
    .dot.current {
      border-color: var(--accent);
      background: var(--accent);
      box-shadow: 0 0 8px var(--accent-glow);
    }

    /* Progress bar */
    .progress-bar {
      height: 4px;
      background: var(--progress-bg);
      border-radius: 2px;
      overflow: hidden;
    }
    .progress-fill {
      height: 100%;
      background: var(--progress-fill);
      border-radius: 2px;
      transition: width 0.4s ease;
    }

    /* ===== SLIDE-IN ANIMATION ===== */
    .slide-in {
      animation: slideIn 0.35s ease-out;
    }
    @keyframes slideIn {
      from { opacity: 0; transform: translateX(-20px); }
      to   { opacity: 1; transform: translateX(0); }
    }

    /* ===== NOTIFY TOAST ===== */
    .notify {
      position: fixed;
      top: 20px;
      right: 20px;
      padding: 12px 24px;
      background: var(--notify-bg);
      border: 1px solid var(--notify-border);
      border-radius: 10px;
      color: var(--notify-text);
      font-size: 14px;
      font-weight: 600;
      z-index: 100;
      opacity: 0;
      transform: translateY(-10px);
      transition: all 0.3s ease;
      pointer-events: none;
    }
    .notify.show {
      opacity: 1;
      transform: translateY(0);
    }
  </style>
</head>
<body>

  <!-- HEADER -->
  <div class="header">
    <div class="brand">☰ COURSEWARE</div>
    <div class="title">{{COURSE_TITLE}}</div>
    <div class="counter" id="counter">1 / N</div>
  </div>

  <!-- MAIN -->
  <div class="main">
    <!-- LEFT PANEL -->
    <div class="left-panel" id="leftPanel">
      <!-- Populated by render() -->
    </div>

    <!-- RIGHT PANEL -->
    <div class="right-panel">
      <div class="diagram" id="diagram">
        <!-- Nodes and arrows rendered by render() -->
      </div>
      <div class="code-panel">
        <div class="code-header" id="codeHeader">code</div>
        <div class="code-body" id="codeBody"></div>
      </div>
    </div>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <div class="footer-controls">
      <button class="btn" id="prevBtn" onclick="prev()">◀ Prev</button>
      <div class="dots" id="dots"></div>
      <button class="btn" id="nextBtn" onclick="next()">Next ▶</button>
      <button class="btn" id="simBtn" onclick="toggleSimulate()">▶ Simulate</button>
    </div>
    <div class="progress-bar">
      <div class="progress-fill" id="progressFill"></div>
    </div>
  </div>

  <!-- NOTIFY TOAST -->
  <div class="notify" id="notify"></div>

  <script>
    // ===== DATA (replace with actual content) =====
    const STEPS = [/* ... populated per courseware ... */];
    const NODES = [/* ... populated per courseware ... */];
    const ARROWS = [/* ... populated per courseware ... */];

    // ===== STATE =====
    let current = 0;
    let simulating = false;
    let simTimer = null;
    const visited = new Set([0]);

    // ===== ACTOR MAP =====
    const ACTOR_MAP = {
      user:     { emoji: '👤', label: 'User' },
      server:   { emoji: '🖥️', label: 'Server' },
      browser:  { emoji: '🌐', label: 'Browser' },
      keycloak: { emoji: '🔐', label: 'Keycloak' },
      gateway:  { emoji: '🚪', label: 'Gateway' },
      db:       { emoji: '🗄️', label: 'Database' },
      queue:    { emoji: '📬', label: 'Queue' },
      external: { emoji: '🌍', label: 'External' }
    };

    // ===== RENDER =====
    function render() {
      const step = STEPS[current];
      visited.add(current);

      // Counter
      document.getElementById('counter').textContent = `${current + 1} / ${STEPS.length}`;

      // Left panel
      const lp = document.getElementById('leftPanel');
      lp.innerHTML = `
        <div class="slide-in">
          <div class="step-badge">${current + 1}</div>
          <div class="step-title">${step.title}</div>
          <div class="step-desc">${step.desc}</div>
          <div class="actors">
            ${step.actors.map(a => {
              const actor = ACTOR_MAP[a] || { emoji: '❓', label: a };
              return `<span class="actor actor-${a}">${actor.emoji} ${actor.label}</span>`;
            }).join('')}
          </div>
          <div class="points">
            ${step.points.map(p =>
              `<div class="point point-${p.type}">${p.text}</div>`
            ).join('')}
          </div>
        </div>
      `;

      // Diagram nodes
      const diagram = document.getElementById('diagram');
      diagram.innerHTML = '';

      // SVG arrows
      const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      ARROWS.forEach((arrow, i) => {
        const fromNode = NODES.find(n => n.id === arrow.from);
        const toNode = NODES.find(n => n.id === arrow.to);
        if (!fromNode || !toNode) return;

        const x1 = fromNode.x + 60, y1 = fromNode.y + 22;
        const x2 = toNode.x + 60,   y2 = toNode.y + 22;

        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', x1); line.setAttribute('y1', y1);
        line.setAttribute('x2', x2); line.setAttribute('y2', y2);
        line.setAttribute('marker-end', 'url(#arrowhead)');

        // Determine arrow state
        const fromIdx = NODES.findIndex(n => n.id === arrow.from);
        const toIdx = NODES.findIndex(n => n.id === arrow.to);
        if (toIdx <= step.activeStep && fromIdx < step.activeStep) {
          line.classList.add('done');
        }
        if (toIdx === step.activeStep) {
          line.classList.add('active');
        }

        svg.appendChild(line);

        // Arrow label
        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', (x1 + x2) / 2);
        text.setAttribute('y', (y1 + y2) / 2 - 8);
        text.setAttribute('text-anchor', 'middle');
        text.textContent = arrow.label;
        svg.appendChild(text);
      });

      // Arrowhead marker
      const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
      defs.innerHTML = `
        <marker id="arrowhead" markerWidth="10" markerHeight="7"
                refX="10" refY="3.5" orient="auto" fill="var(--arrow-color)">
          <polygon points="0 0, 10 3.5, 0 7" />
        </marker>`;
      svg.prepend(defs);
      diagram.appendChild(svg);

      // Render nodes
      NODES.forEach((node, i) => {
        const el = document.createElement('div');
        el.className = 'node';
        el.style.left = node.x + 'px';
        el.style.top = node.y + 'px';
        el.textContent = node.label;
        el.onclick = () => jumpToNode(i);

        if (i === step.activeStep) el.classList.add('active');
        else if (i < step.activeStep) el.classList.add('done');

        diagram.appendChild(el);
      });

      // Code panel
      const firstLine = step.code.split('\n')[0];
      const filename = firstLine.includes('//') ? firstLine.replace(/.*\/\/\s*/, '').trim()
                     : firstLine.includes('#')  ? firstLine.replace(/.*#\s*/, '').trim()
                     : 'code';
      document.getElementById('codeHeader').textContent = filename;
      document.getElementById('codeBody').innerHTML = step.code;

      // Dots
      const dotsEl = document.getElementById('dots');
      dotsEl.innerHTML = STEPS.map((_, i) => {
        let cls = 'dot';
        if (i === current) cls += ' current';
        else if (visited.has(i)) cls += ' visited';
        return `<span class="${cls}" onclick="goTo(${i})"></span>`;
      }).join('');

      // Progress bar
      const pct = ((current + 1) / STEPS.length) * 100;
      document.getElementById('progressFill').style.width = pct + '%';

      // Button states
      document.getElementById('prevBtn').disabled = current === 0;
      document.getElementById('nextBtn').disabled = current === STEPS.length - 1;
    }

    // ===== NAVIGATION =====
    function next() {
      if (current < STEPS.length - 1) { current++; render(); }
    }
    function prev() {
      if (current > 0) { current--; render(); }
    }
    function goTo(i) {
      current = i; render();
    }
    function jumpToNode(nodeIdx) {
      const stepIdx = STEPS.findIndex(s => s.activeStep === nodeIdx);
      if (stepIdx !== -1) { current = stepIdx; render(); }
    }

    // ===== SIMULATE =====
    function toggleSimulate() {
      if (simulating) {
        stopSimulate();
      } else {
        startSimulate();
      }
    }

    function startSimulate() {
      simulating = true;
      current = 0;
      render();
      notify('▶ Simulation started');
      document.getElementById('simBtn').textContent = '⏸ Stop';

      simTimer = setInterval(() => {
        if (current < STEPS.length - 1) {
          animatePacket(() => {
            current++;
            render();
          });
        } else {
          stopSimulate();
          notify('✓ Simulation complete');
        }
      }, 900);
    }

    function stopSimulate() {
      simulating = false;
      clearInterval(simTimer);
      simTimer = null;
      document.getElementById('simBtn').textContent = '▶ Simulate';
    }

    function animatePacket(onComplete) {
      const step = STEPS[current];
      const nextStep = STEPS[current + 1];
      if (!nextStep) { onComplete(); return; }

      const fromNode = NODES[step.activeStep];
      const toNode = NODES[nextStep.activeStep];
      if (!fromNode || !toNode || step.activeStep === nextStep.activeStep) {
        onComplete();
        return;
      }

      const packet = document.createElement('div');
      packet.className = 'packet';
      const diagram = document.getElementById('diagram');
      diagram.appendChild(packet);

      const startX = fromNode.x + 60;
      const startY = fromNode.y + 22;
      const endX = toNode.x + 60;
      const endY = toNode.y + 22;

      // Animate using requestAnimationFrame
      const duration = 600;
      const startTime = performance.now();

      function tick(now) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const ease = progress < 0.5
          ? 2 * progress * progress
          : 1 - Math.pow(-2 * progress + 2, 2) / 2;

        packet.style.left = (startX + (endX - startX) * ease - 5) + 'px';
        packet.style.top = (startY + (endY - startY) * ease - 5) + 'px';
        packet.style.opacity = '1';

        if (progress < 1) {
          requestAnimationFrame(tick);
        } else {
          packet.remove();
          onComplete();
        }
      }
      requestAnimationFrame(tick);
    }

    // ===== KEYBOARD =====
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === ' ') {
        e.preventDefault();
        next();
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        prev();
      } else if (e.key === 'Enter') {
        e.preventDefault();
        toggleSimulate();
      }
    });

    // ===== NOTIFY =====
    function notify(msg) {
      const el = document.getElementById('notify');
      el.textContent = msg;
      el.classList.add('show');
      setTimeout(() => el.classList.remove('show'), 2000);
    }

    // ===== INIT =====
    render();
  </script>
</body>
</html>
```

---

## Key Function Patterns

### render() Function

The `render()` function is the core of the courseware. It is called on every state change:

1. **Update counter** — sets the `n / N` display
2. **Left panel** — rebuilds with slide-in animation wrapper:
   - Step badge (numbered circle)
   - Step title
   - Step description
   - Actor tags (mapped from actor keys to emoji + label + colour class)
   - Key points (mapped from type to colour class)
3. **Diagram** — clears and rebuilds:
   - SVG arrows with state classes (done/active)
   - Arrowhead marker definition
   - Arrow labels at midpoint
   - Node divs with position, state classes, click handlers
4. **Code panel** — extracts filename from first line comment, sets innerHTML
5. **Dots** — rebuilds step dots with current/visited/unvisited states
6. **Progress bar** — sets width percentage
7. **Button states** — disables Prev at start, Next at end

### simulate() Function with Packet Animation

The simulation auto-advances through all steps at 900ms intervals:

1. `startSimulate()` — resets to step 0, starts interval timer
2. Each tick calls `animatePacket(callback)`:
   - Creates a `.packet` div in the diagram
   - Calculates start/end coordinates from current and next node positions
   - Uses `requestAnimationFrame` for smooth 600ms eased animation
   - Removes packet and calls callback (which advances the step) on completion
3. `stopSimulate()` — clears interval, resets button text
4. Auto-stops when reaching the last step with a "Simulation complete" toast

### Keyboard Navigation Handler

```javascript
document.addEventListener('keydown', (e) => {
  switch (e.key) {
    case 'ArrowRight':
    case ' ':           // Space
      e.preventDefault();
      next();
      break;
    case 'ArrowLeft':
      e.preventDefault();
      prev();
      break;
    case 'Enter':
      e.preventDefault();
      toggleSimulate();
      break;
  }
});
```

---

## CSS Patterns

### Node Active State

```css
.node.active {
  background: var(--node-active-bg);
  border-color: var(--node-active-border);
  box-shadow: var(--node-active-glow);
  transform: scale(1.15);
  z-index: 3;
}
```

The active node scales up 15% and gets a layered glow shadow (inner bright + outer diffuse). The `z-index: 3` ensures it renders above other nodes and arrows.

### Packet Animation Keyframes

The packet animation uses `requestAnimationFrame` for smooth performance rather than CSS keyframes. The easing function used is an ease-in-out quadratic:

```javascript
const ease = progress < 0.5
  ? 2 * progress * progress                        // ease-in
  : 1 - Math.pow(-2 * progress + 2, 2) / 2;        // ease-out
```

The packet dot has a persistent glow via `box-shadow`:

```css
.packet {
  width: 10px;
  height: 10px;
  background: var(--accent);
  border-radius: 50%;
  box-shadow: 0 0 12px var(--accent-glow);
}
```

### Slide-In Transition

Applied to the left panel content wrapper on each render:

```css
.slide-in {
  animation: slideIn 0.35s ease-out;
}
@keyframes slideIn {
  from { opacity: 0; transform: translateX(-20px); }
  to   { opacity: 1; transform: translateX(0); }
}
```

The animation is 350ms with `ease-out` timing for a snappy feel. Content slides 20px from the left while fading in.

### Arrow Done/Active States

```css
.diagram svg line {
  stroke: var(--arrow-color);       /* default: dim */
  stroke-width: 2;
  transition: stroke 0.3s ease;
}
.diagram svg line.active {
  stroke: var(--arrow-active);      /* highlighted */
  stroke-width: 2.5;
}
.diagram svg line.done {
  stroke: var(--arrow-done);        /* completed: green */
}
```

Arrow state is determined in `render()` by comparing the arrow's from/to node indices against the current step's `activeStep`.

### Notify Toast

```css
.notify {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 12px 24px;
  background: var(--notify-bg);
  border: 1px solid var(--notify-border);
  border-radius: 10px;
  color: var(--notify-text);
  font-size: 14px;
  font-weight: 600;
  z-index: 100;
  opacity: 0;
  transform: translateY(-10px);
  transition: all 0.3s ease;
  pointer-events: none;
}
.notify.show {
  opacity: 1;
  transform: translateY(0);
}
```

The toast slides down 10px while fading in, auto-hides after 2000ms via `setTimeout` in the `notify()` function.
