# Dashboard HTML Template

Self-contained HTML file with all CSS/JS inline. Data is embedded as a `<script>` tag.
No external JavaScript dependencies. Google Fonts loaded via `<link>`.

## Data Embedding

Embed the JSON data from `ai-portfolio-data.json` as a compact inline script:

```html
<script>
const DATA = { ...compact JSON here... };
</script>
```

Use Python to generate the HTML with embedded data:

```python
import json, re

with open('ai-portfolio-data.json') as f:
    data = json.load(f)
compact = json.dumps(data, separators=(',',':'))

# Insert into HTML template
html = TEMPLATE.replace('__DATA_PLACEHOLDER__', compact)
```

## Fonts

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=JetBrains+Mono:wght@400;500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
```

## CSS Variables (Design System)

```css
:root {
  /* Dark theme (default) */
  --bg: #0B1120;
  --bg2: #111827;
  --bg3: #1F2937;
  --bg4: #374151;
  --fg: #F9FAFB;
  --fg2: #D1D5DB;
  --fg3: #9CA3AF;

  /* Accent palette */
  --amber: #F59E0B;
  --green: #10B981;
  --blue: #3B82F6;
  --purple: #8B5CF6;
  --cyan: #06B6D4;
  --pink: #EC4899;

  /* Medals */
  --gold: #FFD700;
  --silver: #C0C0C0;
  --bronze: #CD7F32;

  /* Layout */
  --radius: 12px;
  --radius-sm: 8px;
  --max-w: 1200px;

  /* Fonts */
  --font-display: 'Space Grotesk', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --font-body: 'Inter', system-ui, sans-serif;
}

[data-theme="light"] {
  --bg: #F9FAFB; --bg2: #FFFFFF; --bg3: #F3F4F6; --bg4: #E5E7EB;
  --fg: #111827; --fg2: #374151; --fg3: #6B7280;
}
```

## Typography Rules

Keep text readable — no font below `0.8rem`. Recommended sizes:

| Element | Size | Font |
|---------|------|------|
| Body text | `1rem` | `--font-body` |
| Section titles | `2rem` | `--font-display` |
| Stat card values | `2.25rem` | `--font-display` |
| Stat card labels | `1rem` | `--font-body` |
| Table headers | `0.85rem` | `--font-mono` |
| Table cells | `0.95rem` | `--font-body` |
| Chart labels | `0.95rem` | `--font-mono` |
| Tags/badges | `0.85rem` | `--font-mono` |
| Heatmap labels | `0.75rem` | `--font-mono` |
| Footer | `1rem` | `--font-body` |

Line height: `1.8` on body.

## Section Templates

### 1. Hero Header

**IMPORTANT:** Hero stats MUST be dynamic — set `data-count` from `DATA.aggregates`
via JavaScript at runtime. Never hardcode numbers in the HTML.

```html
<section class="hero">
  <div class="container">
    <h1><span class="gradient-text">AI-Powered Development</span><br>Portfolio Dashboard</h1>
    <p class="subtitle" id="heroSubtitle">Human + AI collaboration</p>
    <div class="hero-stats">
      <!-- 4 stat boxes — data-count set from DATA via JS -->
      <div class="hero-stat">
        <div class="number" id="heroProjects" data-count="0">0</div>
        <div class="label">Projects</div>
      </div>
      <!-- ... Total Commits, AI-Assisted Commits, AI Tools -->
    </div>
  </div>
</section>
```

```javascript
// Set hero stats from data BEFORE count-up animation
document.getElementById('heroSubtitle').textContent =
  'Human + AI collaboration across ' + agg.total_projects + ' projects';
document.getElementById('heroProjects').dataset.count = agg.total_projects;
document.getElementById('heroCommits').dataset.count = agg.total_commits;
document.getElementById('heroAI').dataset.count = agg.total_co_authored;
document.getElementById('heroTools').dataset.count =
  Object.keys(agg.ai_tools_summary || {}).length || 1;
```

Gradient background: `linear-gradient(135deg, var(--bg) 0%, #1a1040 50%, var(--bg) 100%)`
Gradient text: `linear-gradient(135deg, var(--amber), var(--pink), var(--purple))`

### 2. Executive Summary

6 stat cards in a 3x2 grid:

- Total Projects (with "N with AI" sub)
- Total Commits
- AI-Assisted Commits (with percentage sub)
- AI-Active Projects (with adoption % sub)
- Claude Models Used (list names in sub)
- Technologies (top 3 in sub)

### 3. AI Activity Heatmap

GitHub-style 365-day calendar. Full year grid even if early months are empty.

```javascript
// Fixed 365-day window ending today
const endDate = new Date();
const startDate = new Date(endDate);
startDate.setDate(startDate.getDate() - 364);
startDate.setDate(startDate.getDate() - startDate.getDay()); // Align to Sunday

// 5-level green color scale
const heatColors = ['var(--bg3)', '#0e4429', '#006d32', '#26a641', '#39d353'];

// Cell size: 14px with 3px gap
// Day labels: Mon/Wed/Fri on left
// Month labels along top
// Tooltip on hover showing date + count
```

Distribute monthly AI commits across days (weighted: 80% weekdays, 20% weekends)
with slight randomization for natural appearance.

### 4. AI Adoption Trend

SVG chart rendered inline. Two lines:

- **Amber solid line**: AI commits per month (left Y axis)
- **Green dashed line**: Cumulative projects adopted (right Y axis)
- **Green dots**: Mark when new projects started using AI
- **Hover tooltips** on all dots

Stats row below: First AI Commit date, Journey Duration, AI-Active Projects, Avg AI Commits/month.

### 5. AI Adoption Timeline (Swim Lane)

Each AI-active project as a horizontal bar from first AI commit to last commit.
Calculate left offset and width as percentage of total date range.

```javascript
const items = agg.ai_adoption_timeline;
const dates = items.flatMap(i => [i.first_ai_commit, i.last_commit]).map(d => new Date(d).getTime());
const minD = Math.min(...dates), maxD = Math.max(...dates);
// left = (first_ai - min) / range * 100
// width = (last - first_ai) / range * 100
```

### 6. Monthly Activity (Stacked Bar)

Show last 18 months. Each bar stacked: amber (AI) + muted (human).

```javascript
const recent = timeline.slice(-18);
const maxVal = Math.max(...recent.map(m => m.total));
// Bar width = total / maxVal * 100%
// AI portion = ai / total * 100% of bar
```

### 7. Projects by Category

Cards grid with `grid-template-columns: repeat(auto-fill, minmax(320px, 1fr))`.
Each card: category name + badge count + bullet list of project names with colored dots.

### 8. Organization Breakdown

Horizontal bars sorted by count descending. Each org gets a unique color from the palette.

### 9. Tech Stack Distribution

Two-column layout: horizontal bars on left, CSS donut chart on right.

```css
/* Donut via conic-gradient */
.donut {
  width: 200px; height: 200px;
  border-radius: 50%;
  background: conic-gradient(#F59E0B 0% 30%, #10B981 30% 55%, ...);
}
.donut-center {
  /* Centered circle showing total count */
  width: 120px; height: 120px;
  background: var(--bg2);
  border-radius: 50%;
}
```

### 10. AI Collaboration Leaderboard

Table with columns: Rank, Project, **AI Tools**, AI Commits, Total, AI %, Progress Bar.
Top 3 get medal emojis. Progress bar width = AI percentage.
AI Tools column shows colored badges per tool:
- Claude: `var(--amber)`, OpenCode: `var(--purple)`, Copilot: `var(--cyan)`

### 11. AI Tools Breakdown

Two-column layout: tool cards on left, CSS donut chart on right.

```javascript
const tb = agg.ai_tool_breakdown || {};
const toolColors = {'Claude':'var(--amber)','OpenCode':'var(--purple)','Copilot':'var(--cyan)'};
const tools = Object.entries(tb).filter(([,v]) => v.commits > 0);
// Each tool card shows: name, commit count, percentage bar, project count, project tags
// Donut via conic-gradient showing proportion of each tool
```

### 12. Claude Model Usage

Cards per model showing model name, project count, and tag list of project names.

### 13. Project Detail Grid

**IMPORTANT:** This section should have `class="reveal visible"` (always visible).

Interactive table with:
- **Search input**: filters by name and description
- **Category dropdown**: filters by category (needs `option { background:var(--bg2); color:var(--fg) }` for dark mode)
- **Sort buttons**: AI %, Commits, Name

Columns: Project (linked if URL exists), Category, Commits, AI, AI %, **AI Tools** (colored badges), Tech Stack (tags), Models.

Table needs explicit `color:var(--fg)` on `td` elements for dark mode compatibility.

### 14. Footer

```html
<footer class="footer">
  <div class="container">
    <p>Generated on <span id="genDate"></span></p>
    <div class="badge">&#9670; Powered by Claude Code</div>
  </div>
</footer>
```

## JavaScript Features

### Theme Toggle

```javascript
function toggleTheme() {
  const t = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
  document.documentElement.dataset.theme = t;
  localStorage.setItem('theme', t);
}
// Restore on load
const saved = localStorage.getItem('theme');
if (saved) document.documentElement.dataset.theme = saved;
```

### Count-Up Animation

```javascript
function countUp(el, target) {
  const duration = 1500;
  const start = performance.now();
  function tick(now) {
    const p = Math.min((now - start) / duration, 1);
    const ease = 1 - Math.pow(1 - p, 3); // ease-out cubic
    el.textContent = Math.round(target * ease).toLocaleString();
    if (p < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}
```

### Scroll Reveal

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      observer.unobserve(e.target);
    }
  });
}, { threshold: 0.1 });
document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
```

### Project Grid Search/Filter/Sort

```javascript
let currentSort = 'ai';
let currentDir = -1; // descending

function renderProjectGrid(filter, category) {
  let filtered = projects;
  if (filter) filtered = filtered.filter(p =>
    p.name.toLowerCase().includes(filter) ||
    (p.description || '').toLowerCase().includes(filter)
  );
  if (category) filtered = filtered.filter(p => p.category === category);

  if (currentSort === 'ai') filtered.sort((a, b) => (b.co_author_percentage - a.co_author_percentage) * currentDir);
  else if (currentSort === 'commits') filtered.sort((a, b) => (b.total_commits - a.total_commits) * currentDir);
  else if (currentSort === 'name') filtered.sort((a, b) => a.name.localeCompare(b.name) * currentDir);

  document.getElementById('projectGrid').innerHTML = filtered.map(p => `<tr>...</tr>`).join('');
}
```

## Print Styles

```css
@media print {
  [data-theme] {
    --bg: #fff; --bg2: #fff; --bg3: #f3f4f6; --bg4: #e5e7eb;
    --fg: #111; --fg2: #374151; --fg3: #6b7280;
  }
  .theme-toggle, .grid-controls { display: none !important; }
  .hero { background: none !important; }
  .hero::before { display: none; }
  .reveal { opacity: 1 !important; transform: none !important; }
}
```

## Responsive Breakpoints

- `768px`: Stat grid 3 cols -> 2 cols, hero stats 4 -> 2, tech section single column
- `480px`: Stat grid -> 1 col, reduced padding, swim lane labels narrower

## Color Palette for Charts

Use this rotating palette for bars, swim lanes, org chart, etc.:

```javascript
const COLORS = [
  '#F59E0B', '#10B981', '#3B82F6', '#8B5CF6', '#06B6D4',
  '#EC4899', '#EF4444', '#14B8A6', '#F97316', '#6366F1'
];
```
