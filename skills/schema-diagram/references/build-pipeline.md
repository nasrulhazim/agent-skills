# Build pipeline

Two commands, deliberately split so neither needs the other's toolchain.

```bash
php artisan docs:erd    # database -> docs/03-architecture/erd-schema.json   (needs a migrated DB)
npm run build:erd       # JSON     -> docs/03-architecture/03-database-erd.html  (needs Node only)
```

Both outputs are committed. The JSON because a diff on it is a readable record of what the
schema did between releases; the HTML because the whole point is a file someone can open
without a toolchain.

## Why one standalone file

Self-contained is the entire requirement. The document lives in `docs/`, gets opened straight
off a filesystem, attached to an email, or read on a machine with no network. So:

- **React, React Flow and dagre are inlined.** No CDN, no import map.
- **The schema is inlined too.** From `file://` every request is cross-origin, so a `fetch()`
  of the sibling JSON is refused — the payload rides in a `<script type="application/json">`.
- **The CSS is inlined**, and references no external host — no webfont fetch, no image URL.
- **A `<noscript>` block** says what the document is and points at the JSON, because a diagram
  of this size genuinely needs JavaScript and a blank page explains nothing.

Two escapes matter. `</script` inside the bundle must be broken (`<\/script`) or it closes the
tag it sits in; in the JSON, escaping `<` as `\u003c` is a plain string escape and stays valid
JSON.

Expect roughly **1 MB** for a hundred-table schema. That is the price of a document that still
opens in five years.

## Dependencies

```bash
npm i @xyflow/react @dagrejs/dagre react react-dom
npm i -D @vitejs/plugin-react vite
```

`package.json`:

```json
{
  "scripts": {
    "build:erd": "node resources/js/erd/build.mjs"
  }
}
```

The build calls Vite's JS API with `configFile: false`, so it is independent of the app's own
`vite.config.js` and cannot be broken by a change to the app's bundling.

## `resources/js/erd/build.mjs`

```js
/*
 * Bundles the ERD island and the schema payload into ONE standalone HTML file.
 *
 * Self-contained is the whole requirement. The document lives in `docs/`, gets
 * opened straight off a filesystem, attached to a mail, or read on a machine
 * with no network — so nothing may be fetched at runtime. React, React Flow and
 * dagre are inlined; the schema is inlined too, because from `file://` every
 * request is cross-origin and a fetch of the sibling JSON is refused.
 *
 *   php artisan docs:erd   -> docs/03-architecture/erd-schema.json  (needs a database)
 *   npm run build:erd      -> docs/03-architecture/03-database-erd.html  (needs node)
 */

import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import react from '@vitejs/plugin-react';
import { build } from 'vite';

const here = fileURLToPath(new URL('.', import.meta.url));
const root = resolve(here, '../../..');
const schemaPath = join(root, 'docs/03-architecture/erd-schema.json');
const outPath = join(root, 'docs/03-architecture/03-database-erd.html');

const PRODUCT = 'Acme';

const schema = readFileSync(schemaPath, 'utf8');
const stats = JSON.parse(schema).stats;
const out = mkdtempSync(join(tmpdir(), 'erd-'));

await build({
    configFile: false,
    root,
    logLevel: 'warn',
    plugins: [react()],
    define: { 'process.env.NODE_ENV': '"production"' },
    build: {
        outDir: out,
        emptyOutDir: true,
        cssCodeSplit: false,
        minify: true,
        lib: {
            entry: join(here, 'index.jsx'),
            name: 'Erd',
            formats: ['iife'],
            fileName: () => 'erd.js',
            cssFileName: 'erd',
        },
        rollupOptions: {
            output: { assetFileNames: 'erd.[ext]' },
        },
    },
});

const js = readFileSync(join(out, 'erd.js'), 'utf8');
const css = readFileSync(join(out, 'erd.css'), 'utf8');

rmSync(out, { recursive: true, force: true });

// `</script` would close the tag it sits in. In the JSON that is a plain
// escape of a character that only ever appears inside a string value; in the
// bundle the sequence can only occur inside a string or a regex, where the
// backslash is inert.
const inlineJson = schema.replace(/</g, '\\u003c');
const inlineJs = js.replace(/<\/script/g, '<\\/script');

const html = `<!doctype html>
<html lang="en" data-theme="dark">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="dark light">
<meta name="description" content="Interactive entity-relationship diagram of the ${PRODUCT} database: ${stats.tables} tables, ${stats.columns} columns, ${stats.relations} foreign keys.">
<title>${PRODUCT} — Database ERD</title>
<!--
  GENERATED FILE — do not edit by hand.

    php artisan docs:erd    re-read the schema from the database
    npm run build:erd       rebuild this document

  Source: resources/js/erd/. Data: docs/03-architecture/erd-schema.json.
-->
<style>${css}</style>
</head>
<body>
<div id="erd-root"><div class="erd-loading">Drawing ${stats.tables} tables…</div></div>
<noscript>
  <div class="erd-noscript">
    <h1>${PRODUCT} — Database ERD</h1>
    <p>This document draws ${stats.tables} tables, ${stats.columns} columns and
    ${stats.relations} foreign keys as an interactive diagram, which needs
    JavaScript. Everything it renders is inlined in this file — nothing is
    fetched — so enabling JavaScript is the only requirement.</p>
    <p>The same data, without the diagram, is in
    <code>docs/03-architecture/erd-schema.json</code>.</p>
  </div>
</noscript>
<script type="application/json" id="erd-schema">${inlineJson}</script>
<script>${inlineJs}</script>
</body>
</html>
`;

writeFileSync(outPath, html);

const kb = (Buffer.byteLength(html) / 1024).toFixed(0);

console.log(
    `docs/03-architecture/03-database-erd.html — ${kb} KB, ` +
        `${stats.tables} tables / ${stats.columns} columns / ${stats.relations} relations`
);
```

## A dev loop

The production build minifies, which makes a stack trace useless. Keep a second script that
writes an unminified `_dev.html` next to the real document, and `.gitignore` it:

```js
// Same as build.mjs, with:
//   define: { 'process.env.NODE_ENV': '"development"' }
//   build.minify: false
//   outPath: docs/03-architecture/_dev.html
```

```gitignore
docs/03-architecture/_dev.html
```

## CI

Rebuild only on the pipeline that already has Node; the coverage gate is what runs everywhere.

```yaml
- name: ERD domain coverage
  run: php artisan docs:erd --check

- name: ERD is current
  run: |
    npm ci
    npm run build:erd
    git diff --exit-code docs/03-architecture/03-database-erd.html
```

The second step catches the pull request that regenerated the JSON and forgot the HTML — the
failure mode that leaves a document confidently showing last month's schema.

## Regenerating after a migration

1. `php artisan migrate`
2. `php artisan docs:erd` — fails if a new table has no domain. Add it to `ErdDomains::TABLES`.
3. `npm run build:erd`
4. Commit both `erd-schema.json` and `03-database-erd.html`.

Step 2 failing is the system working. Do not add a `default =>` arm to make it pass.
