---
name: erd
description: Generate, refresh or verify the interactive database ERD document
---

# /erd Command

Drives the `schema-diagram` skill. Load it first — it carries the templates, the traps and the
verification checklist:

```
Skill: schema-diagram
```

## Subcommands

| Command | Does |
|---|---|
| `/erd` | Detects what exists and picks the right path below |
| `/erd init` | Scaffolds the whole toolchain into a project that has none |
| `/erd generate` | `php artisan docs:erd` — reads the live database into the JSON payload |
| `/erd build` | `npm run build:erd` — bundles the JSON into the standalone HTML |
| `/erd refresh` | Generate + build + stage both outputs. The everyday command after a migration |
| `/erd check` | `php artisan docs:erd --check` — domain coverage gate, writes nothing |
| `/erd domains` | Review or extend the domain map without touching anything else |
| `/erd verify` | Open the built document and walk the skill's verification checklist |

## `/erd` with no argument

1. Does `app/Support/Erd/ErdSchema.php` exist?
   - **No** → this is `/erd init`. Confirm with the user before scaffolding.
   - **Yes** → continue.
2. Is the database at head? `php artisan migrate:status | tail -5`
   - Behind → **do not migrate their database.** Build in a throwaway, drop it afterwards, and
     say so in the summary. A diagram of a half-migrated schema is worse than none, but a
     surprise migration is worse than both.
3. Run `/erd refresh`.

## `/erd init`

Do not scaffold silently — this writes ~10 files and adds four npm dependencies.

1. Confirm the target docs path (default `docs/03-architecture/`).
2. **Draft the domain map and show it to the user before writing it.** This is the only part
   that takes judgement; everything after is mechanical. Aim for 8–14 domains named after the
   product's own nouns, with framework tables in one `system` domain.
3. Copy the extractor, the domain map, the React Flow island and the stylesheet from the
   skill's reference files.
4. Set `PRODUCT` in `ErdBoard.jsx` and `About.jsx`; set the brand faces in `erd.css`.
5. Rewrite the prose in `About.jsx` for this product — it is the first thing anyone reads.
6. Install deps, generate, build, verify.
7. Write the companion `docs/03-architecture/03-database-erd.md` — the HTML is not reviewable
   in a PR, does not render on GitHub, and does not appear in a grep.
8. Add `tests/Feature/Docs/ErdDomainCoverageTest.php` so the map fails the suite, not the
   reader.

## `/erd refresh`

```bash
php artisan docs:erd     # fails if a new table has no domain
npm run build:erd
php artisan test --filter=ErdDomainCoverage
git add docs/03-architecture/erd-schema.json docs/03-architecture/03-database-erd.html
```

If step one fails on an unmapped table, that is the gate working. Propose a domain for each
missing table, get agreement, add it to `ErdDomains::TABLES`, and re-run. Never add a
`default =>` arm to make it pass.

**Both files must be staged.** Regenerating the JSON and forgetting the HTML leaves a document
confidently showing last month's schema.

## `/erd verify`

Walk the skill's checklist in a real browser. Two rules before trusting anything you see:

- **Zero edges with perfect cards** means a node was given `width`/`height` rather than
  `initialWidth`/`initialHeight`. There is no error message for this.
- **Take a screenshot before asserting in JS.** An unpainted tab throttles `ResizeObserver` and
  `rAF`, so a healthy page reports as broken — with exactly the symptoms of the bug above.

## Rules

- Read the database by introspection. Never parse `database/migrations`.
- Never migrate a database you were not asked to migrate. Use a throwaway and drop it.
- Commit both `erd-schema.json` and `03-database-erd.html`.
- The document must stay self-contained: no CDN, no webfont fetch, no runtime `fetch()`.
- Report what changed: tables added, removed, and relations gained or lost since the last
  committed JSON — `git diff docs/03-architecture/erd-schema.json` answers this cheaply.
