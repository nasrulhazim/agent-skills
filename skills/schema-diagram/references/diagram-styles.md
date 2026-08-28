# Diagram stylesheet — `resources/js/erd/erd.css`

The document's entire visual system in one file. It is inlined into the standalone HTML at
build time, so **nothing here may reference an external host** — no `@import`, no webfont URL,
no background image. The document has to open from a filesystem, offline, years from now.

Themes are two token blocks: `:root` is dark, `[data-theme='light']` overrides. The board
flips `data-theme` on `<html>`; every colour below resolves through a token, so nothing needs
a second rule to follow the theme.

Type is declared brand-first and degrades — name your brand faces first, then fall through to
the system stack rather than fetching a webfont. Swap `Archivo` / `IBM Plex Mono` for the
product's own faces.

Node geometry (`--erd-*` heights, `NODE_W`) must agree with `geometry.js`. If a row's height
changes here and not there, dagre lays out from stale numbers and edges anchor a few pixels
off the row they belong to.

Copy verbatim to `resources/js/erd/erd.css`.

```css
/*
 * The ERD document's own stylesheet. It is inlined into a single standalone
 * HTML file, so nothing here may reference an external host: the document has
 * to open from a filesystem, on a plane, five years from now.
 *
 * Type is declared brand-first and degrades: a machine with the brand faces
 * installed gets them, anything else falls through to the system stack rather
 * than fetching a webfont.
 */

:root {
    --erd-sans: 'Archivo', ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    --erd-mono: 'IBM Plex Mono', ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;

    --erd-ink: #080c10;
    --erd-surface: #0e141a;
    --erd-raised: #151d25;
    --erd-raised-2: #1b2530;
    --erd-line: #1e2a36;
    --erd-line-strong: #2e3d49;
    --erd-text: #e6edf3;
    --erd-text-dim: #a3b1bf;
    --erd-text-muted: #71818f;
    --erd-accent: #10b981;
    --erd-accent-soft: rgba(16, 185, 129, 0.14);
    --erd-shadow: 0 12px 32px -12px rgba(0, 0, 0, 0.75);
    --erd-grid: #16202a;

    --erd-header-h: 56px;
    --erd-rail-w: 288px;
    --erd-inspector-w: 380px;
}

[data-theme='light'] {
    --erd-ink: #eef2f6;
    --erd-surface: #ffffff;
    --erd-raised: #ffffff;
    --erd-raised-2: #f4f7fa;
    --erd-line: #dfe6ed;
    --erd-line-strong: #c3ced9;
    --erd-text: #0e141a;
    --erd-text-dim: #465563;
    --erd-text-muted: #6b7a89;
    --erd-accent: #059669;
    --erd-accent-soft: rgba(5, 150, 105, 0.12);
    --erd-shadow: 0 10px 28px -14px rgba(15, 30, 45, 0.35);
    --erd-grid: #dde5ec;
}

* {
    box-sizing: border-box;
}

html,
body,
#erd-root {
    height: 100%;
    margin: 0;
    padding: 0;
}

body {
    background: var(--erd-ink);
    color: var(--erd-text);
    font-family: var(--erd-sans);
    font-size: 14px;
    -webkit-font-smoothing: antialiased;
    overflow: hidden;
}

.erd-noscript {
    max-width: 46rem;
    margin: 12vh auto;
    padding: 0 2rem;
    line-height: 1.65;
    color: var(--erd-text-dim);
}

/* ---------------------------------------------------------------- shell -- */

.erd-app {
    display: grid;
    grid-template-rows: var(--erd-header-h) 1fr;
    height: 100%;
}

.erd-header {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0 1rem 0 1.25rem;
    background: var(--erd-surface);
    border-bottom: 1px solid var(--erd-line);
    z-index: 20;
}

.erd-brand {
    display: flex;
    align-items: center;
    gap: 0.625rem;
    font-weight: 700;
    letter-spacing: -0.01em;
    white-space: nowrap;
}

.erd-brand svg {
    width: 22px;
    height: 22px;
    flex: none;
}

.erd-brand span:last-child {
    color: var(--erd-text-muted);
    font-weight: 500;
}

.erd-stats {
    display: flex;
    gap: 1.25rem;
    margin-left: 0.5rem;
    padding-left: 1.25rem;
    border-left: 1px solid var(--erd-line);
    color: var(--erd-text-muted);
    font-size: 12px;
    white-space: nowrap;
}

.erd-stats b {
    color: var(--erd-text);
    font-variant-numeric: tabular-nums;
    font-weight: 600;
}

.erd-header-spacer {
    flex: 1;
}

.erd-body {
    display: grid;
    grid-template-columns: var(--erd-rail-w) 1fr;
    min-height: 0;
}

.erd-body[data-rail='closed'] {
    grid-template-columns: 0 1fr;
}

/*
 * The inspector is a column, not an overlay. Floated over the canvas it hid
 * the minimap and a third of the diagram, and `fitView` — which measures the
 * pane, not what is on top of it — kept framing the graph underneath the
 * panel. Taking a column means the pane really is narrower and everything
 * downstream is correct without being told about the panel.
 */
.erd-body[data-inspector='open'] {
    grid-template-columns: var(--erd-rail-w) 1fr var(--erd-inspector-w);
}

.erd-body[data-rail='closed'][data-inspector='open'] {
    grid-template-columns: 0 1fr var(--erd-inspector-w);
}

.erd-body[data-rail='closed'] .erd-rail {
    display: none;
}

/* ----------------------------------------------------------------- rail -- */

.erd-rail {
    display: flex;
    flex-direction: column;
    min-height: 0;
    background: var(--erd-surface);
    border-right: 1px solid var(--erd-line);
    overflow: hidden;
}

.erd-rail-scroll {
    overflow-y: auto;
    padding: 0.875rem 0 1.5rem;
}

.erd-section {
    padding: 0 0.875rem 1rem;
}

.erd-section + .erd-section {
    border-top: 1px solid var(--erd-line);
    padding-top: 1rem;
}

.erd-section-title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin: 0 0 0.625rem;
    color: var(--erd-text-muted);
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.09em;
    text-transform: uppercase;
}

.erd-search {
    position: relative;
}

.erd-search input {
    width: 100%;
    padding: 0.5rem 2rem 0.5rem 0.625rem;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line-strong);
    border-radius: 7px;
    color: var(--erd-text);
    font-family: var(--erd-sans);
    font-size: 13px;
}

.erd-search input:focus {
    outline: none;
    border-color: var(--erd-accent);
    box-shadow: 0 0 0 3px var(--erd-accent-soft);
}

.erd-search input::placeholder {
    color: var(--erd-text-muted);
}

.erd-search-clear {
    position: absolute;
    top: 50%;
    right: 0.375rem;
    transform: translateY(-50%);
    padding: 0.125rem 0.375rem;
    background: none;
    border: 0;
    color: var(--erd-text-muted);
    cursor: pointer;
    font-size: 15px;
    line-height: 1;
}

.erd-search-clear:hover {
    color: var(--erd-text);
}

.erd-hint {
    margin: 0.5rem 0 0;
    color: var(--erd-text-muted);
    font-size: 11.5px;
    line-height: 1.5;
}

/* --------------------------------------------------------------- chips --- */

.erd-segmented {
    display: grid;
    grid-auto-flow: column;
    grid-auto-columns: 1fr;
    gap: 2px;
    padding: 2px;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line-strong);
    border-radius: 7px;
}

.erd-segmented button {
    padding: 0.375rem 0.25rem;
    background: none;
    border: 0;
    border-radius: 5px;
    color: var(--erd-text-dim);
    cursor: pointer;
    font-family: var(--erd-sans);
    font-size: 12px;
    font-weight: 600;
}

.erd-segmented button:hover {
    color: var(--erd-text);
}

.erd-segmented button[aria-pressed='true'] {
    background: var(--erd-accent);
    color: #04120c;
}

[data-theme='light'] .erd-segmented button[aria-pressed='true'] {
    color: #ffffff;
}

.erd-domains {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.erd-domain {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    width: 100%;
    padding: 0.375rem 0.5rem;
    background: none;
    border: 0;
    border-radius: 6px;
    color: var(--erd-text-dim);
    cursor: pointer;
    font-family: var(--erd-sans);
    font-size: 12.5px;
    text-align: left;
}

.erd-domain:hover {
    background: var(--erd-raised);
    color: var(--erd-text);
}

.erd-domain[aria-pressed='false'] {
    opacity: 0.4;
}

.erd-domain[aria-pressed='true'] {
    color: var(--erd-text);
}

.erd-swatch {
    width: 9px;
    height: 9px;
    flex: none;
    border-radius: 2.5px;
    background: var(--swatch);
    box-shadow: 0 0 0 3px color-mix(in srgb, var(--swatch) 18%, transparent);
}

.erd-domain-name {
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.erd-count {
    color: var(--erd-text-muted);
    font-size: 11px;
    font-variant-numeric: tabular-nums;
}

/* --------------------------------------------------------------- button -- */

.erd-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.4rem 0.7rem;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line-strong);
    border-radius: 7px;
    color: var(--erd-text-dim);
    cursor: pointer;
    font-family: var(--erd-sans);
    font-size: 12.5px;
    font-weight: 500;
    white-space: nowrap;
}

.erd-btn:hover {
    background: var(--erd-raised-2);
    color: var(--erd-text);
}

.erd-btn[aria-pressed='true'] {
    border-color: var(--erd-accent);
    background: var(--erd-accent-soft);
    color: var(--erd-accent);
}

.erd-btn svg {
    width: 14px;
    height: 14px;
}

.erd-btn-ghost {
    background: none;
    border-color: transparent;
}

.erd-btn-block {
    width: 100%;
    justify-content: center;
}

/* --------------------------------------------------------------- canvas -- */

.erd-canvas {
    position: relative;
    min-width: 0;
    background: var(--erd-ink);
}

.react-flow__attribution {
    display: none;
}

.react-flow__node {
    font-family: var(--erd-sans);
}

.react-flow__handle {
    width: 1px;
    min-width: 1px;
    height: 1px;
    min-height: 1px;
    border: 0;
    background: transparent;
    opacity: 0;
}

.react-flow__edge-path {
    stroke-width: 1.4;
}

.react-flow__edge.is-dim .react-flow__edge-path {
    opacity: 0.12;
}

.react-flow__edge.is-lit .react-flow__edge-path {
    stroke-width: 2.4;
}

.react-flow__controls-button {
    width: 26px;
    height: 26px;
    background: var(--erd-raised);
    border-bottom: 1px solid var(--erd-line);
    fill: var(--erd-text-dim);
}

.react-flow__controls-button:hover {
    background: var(--erd-raised-2);
}

.react-flow__minimap {
    background: var(--erd-surface);
    border: 1px solid var(--erd-line);
    border-radius: 8px;
    overflow: hidden;
}

.react-flow__minimap-mask {
    fill: color-mix(in srgb, var(--erd-ink) 62%, transparent);
}

/* ----------------------------------------------------------------- node -- */

.erd-node {
    width: 100%;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line-strong);
    border-radius: 9px;
    box-shadow: var(--erd-shadow);
    overflow: hidden;
    transition: border-color 120ms, opacity 120ms;
}

.erd-node.is-dim {
    opacity: 0.22;
}

.erd-node.is-selected {
    border-color: var(--accent);
    box-shadow: 0 0 0 2px color-mix(in srgb, var(--accent) 40%, transparent), var(--erd-shadow);
}

.erd-node.is-neighbour {
    border-color: color-mix(in srgb, var(--accent) 55%, var(--erd-line-strong));
}

.erd-node-head {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.625rem;
    background: linear-gradient(180deg, color-mix(in srgb, var(--accent) 15%, var(--erd-raised)), var(--erd-raised));
    border-bottom: 1px solid var(--erd-line);
    border-left: 3px solid var(--accent);
}

.erd-node-name {
    flex: 1;
    overflow: hidden;
    color: var(--erd-text);
    font-family: var(--erd-mono);
    font-size: 12.5px;
    font-weight: 600;
    letter-spacing: -0.01em;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.erd-node-meta {
    color: var(--erd-text-muted);
    font-size: 10.5px;
    font-variant-numeric: tabular-nums;
    white-space: nowrap;
}

.erd-rows {
    display: flex;
    flex-direction: column;
}

.erd-row {
    position: relative;
    display: flex;
    align-items: center;
    gap: 0.4rem;
    height: 22px;
    padding: 0 0.625rem;
    font-family: var(--erd-mono);
    font-size: 11px;
    line-height: 1;
}

.erd-row + .erd-row {
    border-top: 1px solid color-mix(in srgb, var(--erd-line) 55%, transparent);
}

.erd-row.is-hit {
    background: var(--erd-accent-soft);
}

.erd-key {
    width: 15px;
    flex: none;
    color: var(--erd-text-muted);
    font-size: 9px;
    font-weight: 700;
    letter-spacing: 0.02em;
}

.erd-key.is-pk {
    color: #fbbf24;
}

.erd-key.is-fk {
    color: var(--erd-accent);
}

.erd-key.is-uk {
    color: #818cf8;
}

.erd-col {
    flex: 1;
    overflow: hidden;
    color: var(--erd-text-dim);
    text-overflow: ellipsis;
    white-space: nowrap;
}

.erd-row.is-key .erd-col {
    color: var(--erd-text);
}

.erd-type {
    color: var(--erd-text-muted);
    font-size: 10px;
    max-width: 42%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.erd-null {
    color: var(--erd-text-muted);
    font-size: 9px;
    opacity: 0.75;
}

.erd-row-more {
    padding: 0.25rem 0.625rem 0.375rem;
    color: var(--erd-text-muted);
    font-family: var(--erd-sans);
    font-size: 10.5px;
}

.erd-morph {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
    padding: 0.3rem 0.625rem 0.4rem;
    border-top: 1px dashed var(--erd-line-strong);
}

.erd-morph-tag {
    padding: 0.05rem 0.3rem;
    border: 1px dashed var(--erd-line-strong);
    border-radius: 4px;
    color: var(--erd-text-muted);
    font-family: var(--erd-mono);
    font-size: 9.5px;
}

/* ------------------------------------------------------------ edge label -- */

.erd-edge-label {
    padding: 0.1rem 0.375rem;
    background: var(--erd-raised-2);
    border: 1px solid var(--erd-line-strong);
    border-radius: 5px;
    color: var(--erd-text-dim);
    font-family: var(--erd-mono);
    font-size: 9.5px;
    pointer-events: none;
    white-space: nowrap;
}

.erd-edge-label b {
    color: var(--erd-text);
    font-weight: 600;
}

.erd-edge-label i {
    color: var(--erd-text-muted);
    font-style: normal;
}

/* ------------------------------------------------------------- inspector -- */

.erd-inspector {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
    background: var(--erd-surface);
    border-left: 1px solid var(--erd-line);
    overflow: hidden;
}

.erd-inspector-head {
    display: flex;
    align-items: flex-start;
    gap: 0.625rem;
    padding: 0.875rem 0.875rem 0.75rem;
    border-bottom: 1px solid var(--erd-line);
    border-left: 3px solid var(--accent);
}

.erd-inspector-title {
    flex: 1;
    min-width: 0;
}

.erd-inspector-title h2 {
    margin: 0;
    overflow: hidden;
    font-family: var(--erd-mono);
    font-size: 14px;
    font-weight: 600;
    text-overflow: ellipsis;
}

.erd-inspector-domain {
    display: inline-block;
    margin-top: 0.25rem;
    color: var(--accent);
    font-size: 11px;
    font-weight: 600;
}

.erd-inspector-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 0.875rem;
}

.erd-inspector h3 {
    margin: 1.125rem 0 0.5rem;
    color: var(--erd-text-muted);
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.09em;
    text-transform: uppercase;
}

.erd-inspector h3:first-child {
    margin-top: 0;
}

.erd-table {
    width: 100%;
    border-collapse: collapse;
    font-family: var(--erd-mono);
    font-size: 11px;
}

.erd-table td {
    padding: 0.25rem 0.375rem 0.25rem 0;
    border-bottom: 1px solid color-mix(in srgb, var(--erd-line) 60%, transparent);
    vertical-align: top;
}

.erd-table td:first-child {
    width: 16px;
}

.erd-table .erd-t-name {
    color: var(--erd-text);
}

.erd-table .erd-t-type {
    color: var(--erd-text-muted);
    text-align: right;
    white-space: nowrap;
}

.erd-rel {
    display: block;
    width: 100%;
    padding: 0.375rem 0.5rem;
    margin-bottom: 2px;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line);
    border-radius: 6px;
    color: var(--erd-text-dim);
    cursor: pointer;
    font-family: var(--erd-mono);
    font-size: 11px;
    text-align: left;
}

.erd-rel:hover {
    border-color: var(--erd-accent);
    color: var(--erd-text);
}

.erd-rel b {
    color: var(--erd-text);
    font-weight: 600;
}

.erd-rel i {
    color: var(--erd-text-muted);
    font-style: normal;
}

.erd-rel-del {
    float: right;
    padding: 0 0.25rem;
    border-radius: 3px;
    background: var(--erd-raised-2);
    color: var(--erd-text-muted);
    font-size: 9px;
    text-transform: uppercase;
}

.erd-empty {
    color: var(--erd-text-muted);
    font-size: 12px;
    font-style: italic;
}

/* ------------------------------------------------------------- table list -- */

.erd-list {
    display: flex;
    flex-direction: column;
    gap: 1px;
}

.erd-list button {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.3rem 0.5rem;
    background: none;
    border: 0;
    border-radius: 5px;
    color: var(--erd-text-dim);
    cursor: pointer;
    font-family: var(--erd-mono);
    font-size: 11.5px;
    text-align: left;
}

.erd-list button:hover {
    background: var(--erd-raised);
    color: var(--erd-text);
}

.erd-list button[aria-current='true'] {
    background: var(--erd-accent-soft);
    color: var(--erd-text);
}

.erd-list span:not(.erd-swatch):not(.erd-count) {
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.erd-list .erd-count {
    flex: none;
}

/* ------------------------------------------------------------------ misc -- */

.erd-toolbar {
    position: absolute;
    top: 0.75rem;
    left: 0.75rem;
    z-index: 10;
    display: flex;
    gap: 0.375rem;
}

.erd-loading {
    position: absolute;
    inset: 0;
    display: grid;
    place-items: center;
    color: var(--erd-text-muted);
    font-size: 13px;
}

@media (max-width: 900px) {
    .erd-body,
    .erd-body[data-inspector='open'],
    .erd-body[data-rail='closed'][data-inspector='open'] {
        grid-template-columns: 1fr;
    }

    .erd-inspector {
        position: absolute;
        inset: 0;
        z-index: 12;
    }

    .erd-rail {
        display: none;
    }

    .erd-stats {
        display: none;
    }
}

/* ----------------------------------------------------------------- about -- */

.erd-about-backdrop {
    position: absolute;
    inset: 0;
    z-index: 30;
    display: grid;
    place-items: center;
    padding: 1.5rem;
    background: color-mix(in srgb, var(--erd-ink) 78%, transparent);
    backdrop-filter: blur(3px);
    overflow-y: auto;
}

.erd-about {
    width: min(760px, 100%);
    max-height: 100%;
    display: flex;
    flex-direction: column;
    background: var(--erd-surface);
    border: 1px solid var(--erd-line-strong);
    border-radius: 14px;
    box-shadow: var(--erd-shadow);
    overflow: hidden;
}

.erd-about-head {
    padding: 1.25rem 1.5rem 1rem;
    border-bottom: 1px solid var(--erd-line);
}

.erd-about-head h1 {
    margin: 0 0 0.375rem;
    font-size: 19px;
    font-weight: 700;
    letter-spacing: -0.02em;
}

.erd-about-head p {
    margin: 0;
    color: var(--erd-text-dim);
    font-size: 13px;
    line-height: 1.6;
}

.erd-about-scroll {
    overflow-y: auto;
    padding: 1.25rem 1.5rem;
}

.erd-about-figures {
    display: flex;
    flex-wrap: wrap;
    gap: 1.75rem;
    padding-bottom: 1.25rem;
    margin-bottom: 1.25rem;
    border-bottom: 1px solid var(--erd-line);
}

.erd-about-figure b {
    display: block;
    font-size: 22px;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    letter-spacing: -0.02em;
}

.erd-about-figure span {
    color: var(--erd-text-muted);
    font-size: 11px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}

.erd-about h2 {
    margin: 0 0 0.75rem;
    color: var(--erd-text-muted);
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.09em;
    text-transform: uppercase;
}

.erd-about-domains {
    display: grid;
    gap: 0.625rem;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    margin-bottom: 1.5rem;
}

.erd-about-domain {
    display: flex;
    gap: 0.5rem;
}

.erd-about-domain .erd-swatch {
    margin-top: 0.3rem;
}

.erd-about-domain b {
    display: block;
    font-size: 12.5px;
    font-weight: 600;
}

.erd-about-domain b span {
    color: var(--erd-text-muted);
    font-weight: 500;
}

.erd-about-domain p {
    margin: 0.125rem 0 0;
    color: var(--erd-text-muted);
    font-size: 11.5px;
    line-height: 1.5;
}

.erd-about-how {
    display: grid;
    gap: 0.5rem;
    margin: 0 0 1.25rem;
    padding: 0;
    list-style: none;
}

.erd-about-how li {
    color: var(--erd-text-dim);
    font-size: 12.5px;
    line-height: 1.55;
}

.erd-about-how b {
    color: var(--erd-text);
}

.erd-about code {
    padding: 0.05rem 0.3rem;
    background: var(--erd-raised);
    border: 1px solid var(--erd-line);
    border-radius: 4px;
    font-family: var(--erd-mono);
    font-size: 11px;
}

.erd-about-foot {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.875rem 1.5rem;
    background: var(--erd-raised);
    border-top: 1px solid var(--erd-line);
}

.erd-about-meta {
    flex: 1;
    color: var(--erd-text-muted);
    font-size: 11px;
    line-height: 1.5;
}
```
