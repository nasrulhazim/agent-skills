# HTML Roadmap Patterns

CSS skeletons and layout patterns based on roadmaps produced across Nasrul's projects.
Pick the closest match to the project type, then customise colors and fonts.

---

## Pattern A: Dark Professional (Warung POS, SaaS, B2B)

Used for: Laravel SaaS, POS, B2B tools, platforms

```css
:root {
  --bg: #0a0a0f;
  --surface: #111118;
  --border: #1e1e2e;
  --accent: #F59E0B;        /* amber — swap to brand color */
  --accent-dim: #78350F;
  --text: #e0e0e0;
  --muted: #6b7280;
  --green: #10B981;
  --blue: #3B82F6;
  --purple: #8B5CF6;
  --red: #F43F5E;
}

body { background: var(--bg); color: var(--text); font-family: 'Syne', sans-serif; }

/* Header */
.header {
  background: linear-gradient(135deg, #0d1117, #1a1a2e);
  border-bottom: 2px solid var(--accent);
  padding: 2.5rem 3rem;
}
.header h1 {
  font-size: clamp(2rem, 4vw, 3.5rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}
.header h1 span { color: var(--accent); }

/* Tech stack pills */
.stack-pills { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 1rem; }
.pill {
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.12);
  color: var(--muted);
  font-size: 11px;
  font-family: 'DM Mono', monospace;
  padding: 4px 10px;
  border-radius: 100px;
}

/* Phase cards */
.phase {
  background: var(--surface);
  border: 1px solid var(--border);
  border-left: 4px solid var(--accent);
  border-radius: 12px;
  padding: 1.75rem 2rem;
  margin-bottom: 1.5rem;
}
.phase-number {
  font-family: 'DM Mono', monospace;
  font-size: 11px;
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}
.phase h2 {
  font-size: 1.375rem;
  font-weight: 700;
  margin: 0.25rem 0 0.5rem;
}
.phase-goal {
  font-size: 0.875rem;
  color: var(--muted);
  font-style: italic;
  margin-bottom: 1.25rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}

/* Task checkboxes */
.tasks { display: flex; flex-direction: column; gap: 4px; }
.task { display: flex; align-items: flex-start; gap: 10px; padding: 5px 0; font-size: 0.875rem; }
.task-check {
  width: 16px; height: 16px; min-width: 16px;
  border: 2px solid var(--accent);
  border-radius: 3px; margin-top: 2px;
  transition: background 0.15s;
}

/* Category color coding */
.task.infra .task-check    { border-color: var(--blue); }
.task.backend .task-check  { border-color: var(--green); }
.task.frontend .task-check { border-color: var(--purple); }
.task.test .task-check     { border-color: var(--red); }
.task.deploy .task-check   { border-color: var(--accent); }

/* Milestone callout */
.milestone {
  margin-top: 1rem;
  padding: 0.75rem 1rem;
  background: rgba(245, 158, 11, 0.08);
  border: 1px solid rgba(245, 158, 11, 0.2);
  border-radius: 8px;
  font-size: 0.8125rem;
  color: var(--accent);
}
.milestone::before { content: '🏁 Milestone: '; font-weight: 600; }

/* MVP scope grid */
.scope-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
.scope-in, .scope-out {
  padding: 1.5rem;
  border-radius: 12px;
  background: var(--surface);
  border: 1px solid var(--border);
}
.scope-in { border-top: 3px solid var(--green); }
.scope-out { border-top: 3px solid var(--muted); }
.scope-in h3 { color: var(--green); margin-bottom: 1rem; }
.scope-out h3 { color: var(--muted); margin-bottom: 1rem; }
.scope-item { font-size: 0.875rem; padding: 4px 0; }
.scope-in .scope-item::before { content: '✅ '; }
.scope-out .scope-item::before { content: '❌ '; }
```

---

## Pattern B: Dark Dramatic (Games, Lawan-Balik)

Used for: game dev, action projects, dramatic visual impact

Key differences from Pattern A:
```css
:root {
  --accent: #ff4444;        /* red — or team color */
  --accent-glow: rgba(255,68,68,0.3);
}

/* Glow effects */
.phase { box-shadow: 0 0 0 1px rgba(255,68,68,0.1); }
.phase:hover { box-shadow: 0 0 20px rgba(255,68,68,0.1); }

/* Header with radial glow */
.header::before {
  content: '';
  position: absolute; inset: 0;
  background: radial-gradient(ellipse at 30% 50%, rgba(255,68,68,0.08), transparent 60%);
  pointer-events: none;
}

/* Phase numbers large and bold */
.phase-number { font-size: 3rem; font-weight: 900; opacity: 0.15; position: absolute; right: 1.5rem; }
```

---

## Pattern C: Warm Organic (Lifestyle, Habit apps, Amalkan)

Used for: habit trackers, lifestyle apps, Islamic/Ramadhan themed

```css
:root {
  --paper: #f5f0e8;
  --paper-warm: #ede6d6;
  --ink: #1a1410;
  --gold: #c9963a;
  --green: #2d6a4f;
  --muted: #8a7d6b;
  --border: #d4c9b0;
}

body {
  background: var(--paper);
  color: var(--ink);
  font-family: 'DM Sans', sans-serif;
}

/* Notebook grid lines */
body::before {
  content: '';
  position: fixed; inset: 0;
  background-image:
    repeating-linear-gradient(0deg, transparent, transparent 59px, var(--border) 60px),
    repeating-linear-gradient(90deg, transparent, transparent 59px, var(--border) 60px);
  opacity: 0.2;
  z-index: 0; pointer-events: none;
}

/* Header brand — serif font */
.brand { font-family: 'Amiri', serif; font-size: 72px; font-weight: 700; }
.brand span { color: var(--gold); }

/* Phase cards — paper style */
.phase {
  background: white;
  border: 1px solid var(--border);
  border-left: 4px solid var(--gold);
  border-radius: 4px;    /* less rounded = more paper-like */
  box-shadow: 2px 2px 8px rgba(0,0,0,0.06);
}
```

---

## Full HTML Shell

Use this skeleton for all roadmap HTML files:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Project] — Product Roadmap</title>
  <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    /* === Insert pattern CSS here === */

    .wrap { max-width: 960px; margin: 0 auto; padding: 3rem 2rem 5rem; }
    .section-title {
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--muted);
      margin: 3rem 0 1.25rem;
    }
    .footer {
      margin-top: 4rem;
      padding: 1.5rem;
      text-align: center;
      font-family: 'DM Mono', monospace;
      font-size: 11px;
      color: var(--muted);
      border-top: 1px solid var(--border);
    }
  </style>
</head>
<body>

  <!-- HEADER -->
  <div class="header">
    <div class="wrap">
      <div class="header-badge">PRODUCT ROADMAP</div>
      <h1>[Project <span>Name</span>]</h1>
      <p>[Tagline]</p>
      <div class="stack-pills">
        <span class="pill">Laravel 12</span>
        <span class="pill">Livewire 4</span>
        <!-- add stack pills -->
      </div>
    </div>
  </div>

  <div class="wrap">

    <!-- PHASES -->
    <div class="section-title">Development Phases</div>

    <div class="phase">
      <div class="phase-number">PHASE 0</div>
      <h2>Foundation</h2>
      <p class="phase-goal">Project setup, infrastructure, skeleton</p>
      <div class="tasks">
        <div class="task infra"><div class="task-check"></div>Task 1</div>
        <div class="task backend"><div class="task-check"></div>Task 2</div>
        <!-- more tasks -->
      </div>
      <div class="milestone">Skeleton app deployed and accessible</div>
    </div>

    <div class="phase">
      <div class="phase-number">PHASE 1 — MVP</div>
      <h2>[Core feature name]</h2>
      <p class="phase-goal">[What user can do after this phase]</p>
      <div class="tasks">
        <!-- tasks -->
      </div>
      <div class="milestone">Definition of Done: [one sentence]</div>
    </div>

    <!-- more phases -->

    <!-- MVP SCOPE -->
    <div class="section-title">MVP Scope</div>
    <div class="scope-grid">
      <div class="scope-in">
        <h3>In Scope ✅</h3>
        <div class="scope-item">Feature A</div>
        <div class="scope-item">Feature B</div>
      </div>
      <div class="scope-out">
        <h3>Out of Scope ❌</h3>
        <div class="scope-item">Feature C (v2)</div>
      </div>
    </div>

  </div><!-- /.wrap -->

  <div class="footer">
    [PROJECT NAME] · [Stack] · [Company] · [Year]
  </div>

</body>
</html>
```

---

## Task Category Classes

Assign CSS classes to tasks for color-coded dot/checkbox:

| Class | Meaning | Example tasks |
|---|---|---|
| `.infra` | Infrastructure, DevOps | Docker, CI/CD, deploy, DNS |
| `.backend` | Server-side logic | Models, migrations, actions, API |
| `.frontend` | UI, Livewire, Blade | Components, CSS, forms |
| `.test` | Testing | Pest tests, coverage |
| `.deploy` | Release, shipping | Version tag, publish, launch |
| `.integration` | Third-party | Payment gateway, SSO, webhooks |

---

## Live Status Badge (Header)

Animated pulsing dot — shows project is "alive":

```css
.header-badge {
  display: inline-flex; align-items: center; gap: 8px;
  background: rgba(245,158,11,0.1);
  border: 1px solid rgba(245,158,11,0.25);
  color: #F59E0B;
  font-family: 'DM Mono', monospace;
  font-size: 11px; letter-spacing: 0.1em;
  padding: 5px 12px; border-radius: 100px;
  margin-bottom: 1rem;
}
.header-badge::before {
  content: '';
  width: 6px; height: 6px; border-radius: 50%;
  background: currentColor;
  animation: pulse 2s infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.2; }
}
```
