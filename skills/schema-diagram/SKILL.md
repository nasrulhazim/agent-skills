---
name: schema-diagram
metadata:
  compatible_agents: [claude-code]
  tags: [erd, database, schema, documentation, diagram, react-flow, architecture]
description: >
  Generates a self-contained interactive ERD document from a Laravel project's live database —
  a single standalone HTML file with domain-coloured table cards, foreign-key edges anchored to
  the actual columns, search across tables and columns, a per-table inspector showing both
  directions of every relation, and a committed JSON schema payload that makes schema drift
  reviewable in a diff. Use this skill whenever the user asks to draw, generate, refresh or
  document a database schema — "generate an ERD", "buat ERD", "draw the database diagram",
  "visualise my schema", "document the database", "lukis rajah pangkalan data", "update the
  ERD", "refresh the schema diagram", "erd dah lapuk", "diagram untuk database", "show table
  relationships", "map my tables to domains", or "what references this table". Reads the live
  schema by introspection, never by parsing migrations. Does NOT cover designing or writing
  migrations (`project-laravel`), domain boundary discovery (`project-ddd`), or the wider docs
  tree (`project-docs`).
---

# Schema diagram

Produces one file: `docs/03-architecture/03-database-erd.html`. It opens off a filesystem, on
a plane, with no network and no toolchain — and it draws every table, column, index and
foreign key in the database.

## The shape of it

| Piece | Lives in | Needs | Committed |
|---|---|---|---|
| Schema extractor | `app/Support/Erd/ErdSchema.php` + `app/Console/Commands/GenerateErdCommand.php` | A migrated database | — |
| Domain map | `app/Support/Erd/ErdDomains.php` | **A human** | — |
| Payload | `docs/03-architecture/erd-schema.json` | — | **Yes** |
| Diagram app | `resources/js/erd/` (React Flow island) | — | — |
| Coverage tests | `tests/Feature/Docs/ErdDomainCoverageTest.php` | — | — |
| Document | `docs/03-architecture/03-database-erd.html` | Node | **Yes** |
| Companion page | `docs/03-architecture/03-database-erd.md` | — | **Yes** |

```bash
php artisan docs:erd    # database -> JSON   (needs a DB, no Node)
npm run build:erd       # JSON     -> HTML   (needs Node, no DB)
```

The split is the design. Either half runs alone, and the committed JSON means the document
rebuilds on a machine that has never seen the database.

## The three rules

**1. Read the database, never the migrations.** Migrations are the instructions; only the
database is the result. A mature project's migration folder is full of column changes, index
swaps, renames and drops whose net effect is exactly what a parser gets wrong — silently.

**2. Every table gets a domain, assigned by a person.** A prefix heuristic mis-files tables and
gives no sign that it did. The generator refuses to write when the map has a gap in either
direction. That friction is the feature; do not add a `default =>` arm to make it pass.

**3. Commit both outputs.** The JSON so schema drift shows up in a pull request diff. The HTML
so a reader needs nothing but a browser.

## Workflow

### 1. Confirm the ground

```bash
php artisan migrate:status | tail -5     # is the schema at head?
```

A diagram of a half-migrated schema is worse than none. But **do not migrate someone's dev
database to build a document** — that is a side effect they did not ask for, and it can be
destructive. Build in a throwaway instead, and drop it:

```bash
mysql -e "CREATE DATABASE erd_tmp"
DB_DATABASE=erd_tmp php artisan migrate --force
DB_DATABASE=erd_tmp php artisan docs:erd
mysql -e "DROP DATABASE erd_tmp"
```

Say plainly in the summary that you did this and that their database is untouched. The About
panel records the migration head it was read at, so the document proves its own provenance.

### 2. Build the domain map first

This is the only part that takes judgement, and everything else is mechanical once it exists.
Read `references/domain-map.md`. Draft it from the code, then correct it by hand:

```bash
ls database/migrations | sed 's/^[0-9_]*//;s/\.php$//' | sort
ls app/Models
```

Aim for 8–14 domains named after the **product's own nouns** — never layers. Framework and
package tables (`cache`, `jobs`, `sessions`, `media`, `telescope_*`) all go in one `system`
domain that starts switched off.

Show the user the proposed map before writing it. Getting `deployment_mail_sandboxes` filed
under Data Services rather than Deployment is a decision they own.

### 3. Scaffold the extractor

`references/schema-extractor.md` has both PHP files verbatim. Copy them, then run:

```bash
php artisan docs:erd
```

It will fail listing unmapped tables. That is the gate working — fill them in and re-run.

### 4. Scaffold the diagram app

`references/diagram-app.md` (seven modules) and `references/diagram-styles.md` (the
stylesheet). Copy verbatim, then change exactly two things: `PRODUCT` in `ErdBoard.jsx` and
`About.jsx`, and the brand faces at the top of `erd.css`.

Rewrite the **prose in `About.jsx`** for the product. It is the only writing in the document
and the first thing anyone reads.

### 5. Build and check

```bash
npm i @xyflow/react @dagrejs/dagre react react-dom
npm i -D @vitejs/plugin-react vite
npm run build:erd
open docs/03-architecture/03-database-erd.html
```

Verify before calling it done — see the checklist below.

### 6. Write the companion page

A 1 MB generated HTML file is not readable in a pull request, does not appear in a `grep`, and
does not render on GitHub. Write `docs/03-architecture/03-database-erd.md` beside it: a link,
the four figures, the domain table with per-domain counts, what it does *not* draw, the two
regeneration commands, and a source-file table. That page is what the docs tree indexes and
what a reviewer actually reads.

### 7. Pin it with tests

`references/coverage-tests.md`. `docs:erd --check` protects the document; the suite protects
the repository — it fails on the pull request that adds the table, not six weeks later.

```yaml
- run: php artisan docs:erd --check
```

## Refreshing an existing diagram

```bash
php artisan migrate
php artisan docs:erd     # fails if a new table has no domain — add it
npm run build:erd
php artisan test --filter=ErdDomainCoverage
git add docs/03-architecture/erd-schema.json docs/03-architecture/03-database-erd.html
```

Regenerating the JSON and forgetting the HTML leaves a document confidently showing last
month's schema. Check both files are staged.

## Verify before calling it done

Open the file and confirm each of these. Every failure here renders *successfully* and is
wrong, which is why the list exists.

- [ ] **Edges exist at all.** Every card drawing perfectly with zero edges is the signature of
      a node given `width`/`height` instead of `initialWidth`/`initialHeight` — React Flow skips
      measurement, handle bounds never exist, and each edge is dropped in silence.
- [ ] **Screenshot before believing a JS assertion.** An unpainted Chrome tab throttles
      `ResizeObserver` and `rAF`, so nodes stay hidden and `fitView` never lands — a healthy
      page reports as broken, with exactly the symptoms of the bug above.
- [ ] **Edges land on rows, not corners.** In LR, a foreign key must leave the row holding it
      and arrive at the row it references. If edges anchor mid-card, handles moved without
      `useUpdateNodeInternals`.
- [ ] **Switch detail Names → Keys → All.** Edge count must not drop. An edge naming a handle
      that is no longer drawn is deleted silently.
- [ ] **The relation count in the header matches `stats.relations`** with all domains on.
- [ ] **Flip direction, then theme.** Both re-anchor and re-colour without a reload.
- [ ] **Search a column name**, not a table name. The hit's row is highlighted even at Keys.
- [ ] **Click the busiest table.** The inspector lists *Referenced by* — the half no row can
      tell you — and the numbers are non-zero.
- [ ] **The file opens from `file://`**, with the network off. No console error, no blank canvas.
- [ ] **The footer names the migration head.** That line is what tells a reader in six months
      whether to trust the picture.

## Judgement calls worth getting right

- **A table with no arrows is not an island.** Only declared foreign keys become edges; a
  relation living in an Eloquent method has nothing in the schema to draw. Say so in About
  rather than inventing edges.
- **Polymorphic pairs get a tag, never an edge.** `auditable_type` + `auditable_id` resolve at
  runtime; an arrow to any one table is a claim the schema does not make.
- **A hundred tables cannot be legible at any zoom.** That is arithmetic, not a layout defect.
  Fix what the reader meets *first* — open on the legend, and let the filters be the way in.
- **`system` starts off.** Cache, queue, sessions and Telescope are plumbing, and most of them
  join to nothing but fog.
- **Do not reach for a package.** `beyondcode/laravel-er-diagram-generator` and friends read
  Eloquent relations and emit a static image — no search, no inspector, no domains, and a
  picture that cannot answer "what references this table".

## Anti-patterns

| Don't | Do |
|---|---|
| Parse `database/migrations` | Introspect via `Schema::getTables()` |
| Infer domains from table-name prefixes | An explicit map, plus a build that fails on a gap |
| `default => 'system'` in the domain map | Let the gate fail; add the table deliberately |
| Fetch the JSON at runtime | Inline it — `file://` refuses cross-origin |
| Link a CDN or a webfont | Inline everything; declare fonts brand-first with a system fallback |
| `width`/`height` on a node | `initialWidth`/`initialHeight` — the box is seeded *and* still measured |
| Migrate the user's dev DB to build a doc | Build in a throwaway database, drop it, say so |
| `fitView` on a `setTimeout` | `useNodesInitialized` — the event, not a guess |
| Re-derive nodes when selection changes | Paint state onto the nodes already in state |
| Commit only the HTML | Commit the JSON too — it is the reviewable diff |
| Leave the HTML as the only doc | Write the companion `.md` — the HTML is not reviewable or greppable |
| Ship a static PNG/SVG "for simplicity" | It cannot answer the one question people open an ERD to ask |

## Reference Files

| File | Contents |
|---|---|
| `references/schema-extractor.md` | `ErdSchema` + `GenerateErdCommand` verbatim, the payload shape, and the five introspection traps (server-wide `getTables()`, sentinel migrations, MySQL type noise, morphs, FK-less tables) |
| `references/domain-map.md` | `ErdDomains` template, how to choose 8–14 domains, the tested 13-colour palette, and the two-way coverage gate |
| `references/diagram-app.md` | All seven `resources/js/erd/` modules verbatim, the **five silent React Flow failure modes**, the browser-throttling trap, and the interaction model |
| `references/diagram-styles.md` | `erd.css` verbatim — dark/light token blocks, node geometry that must agree with `geometry.js` |
| `references/build-pipeline.md` | `build.mjs` verbatim, why one standalone file, the two escaping traps, dependencies, dev loop, and CI |
| `references/coverage-tests.md` | The Pest suite that pins domain coverage, legend completeness, payload shape and morph handling — plus why it must filter on `getCurrentSchemaName()` to work on SQLite |
