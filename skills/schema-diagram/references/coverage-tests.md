# Coverage tests — `tests/Feature/Docs/ErdDomainCoverageTest.php`

The `docs:erd` command refuses to write when the domain map has a gap. That protects the
*document*. These tests protect the **repository** — they fail the suite on the pull request
that adds the table, when the author still knows what the table is for, rather than six weeks
later when someone opens the diagram and meets a stranger.

Two gates for the same rule is not redundancy. The command is only run by whoever is
regenerating the diagram; the suite is run by everyone.

## What each test pins

| Test | Catches |
|---|---|
| Every table has a domain | The new migration whose table nobody classified |
| No domain claims a table the schema lacks | The rename that updated the migration and not the map |
| Every domain has a label, colour and description | A domain added as a key with an empty legend entry — it renders as a blank chip |
| Every table's domain is one the map declares | A typo'd domain key, which `ErdDomains::for()` returns happily |
| The payload builds and has the right shape | A change to the extractor that breaks the document — built by a **separate toolchain that cannot fail the PHP suite**, so this is the only place the JS contract is checked from PHP |
| Polymorphic pairs are reported, not drawn | A regression that starts inventing edges for `*_type`/`*_id` |

## Running on SQLite

These run against the test database. If that is SQLite, the extractor **must** filter tables on
`Schema::getCurrentSchemaName()` and not `getDatabaseName()` — SQLite's schema is `main` while
its database name is the file path, so the wrong filter matches nothing and every one of these
tests passes against an empty schema. See `schema-extractor.md`.

## The suite

Swap the two table names in the payload test for the project's own busiest table and one of its
foreign keys — a shape assertion that names nothing real is a test that cannot fail.

```php
<?php

declare(strict_types=1);

use App\Support\Erd\ErdDomains;
use App\Support\Erd\ErdSchema;

/*
 * The ERD document groups every table by product domain, and the map that does
 * it is written by hand. A table added without an entry would be filed under
 * whatever a fallback chose — and a diagram that quietly mis-files a table is
 * worse than one that is missing it, because the reader cannot tell which
 * happened. These two tests are what make the map fail here rather than there.
 */

it('files every table in the schema under a domain', function () {
    $unmapped = ErdDomains::unmapped(ErdSchema::tableNames());

    expect($unmapped)->toBe([], sprintf(
        'Add %s to App\Support\Erd\ErdDomains::TABLES.',
        implode(', ', $unmapped)
    ));
});

it('does not claim tables the schema no longer has', function () {
    $stale = ErdDomains::stale(ErdSchema::tableNames());

    expect($stale)->toBe([], sprintf(
        'Remove %s from App\Support\Erd\ErdDomains::TABLES.',
        implode(', ', $stale)
    ));
});

it('gives every domain a label, a colour and a description', function () {
    foreach (ErdDomains::all() as $key => $domain) {
        expect($domain['label'])->not->toBeEmpty("Domain {$key} has no label.")
            ->and($domain['description'])->not->toBeEmpty("Domain {$key} has no description.")
            ->and($domain['color'])->toMatch('/^#[0-9a-f]{6}$/', "Domain {$key} has no usable colour.");
    }
});

it('uses only domains that the map declares', function () {
    $declared = array_keys(ErdDomains::all());
    $offenders = [];

    foreach (ErdSchema::tableNames() as $table) {
        if (! in_array(ErdDomains::for($table), $declared, true)) {
            $offenders[] = $table.' => '.var_export(ErdDomains::for($table), true);
        }
    }

    expect($offenders)->toBe([]);
});

/*
 * The payload is the document's only input, so a shape change here is a broken
 * diagram — and the diagram is built by a separate toolchain that cannot fail
 * the PHP suite.
 */
it('builds a payload the document can render', function () {
    $payload = ErdSchema::build();

    expect($payload['stats']['tables'])->toBe(count($payload['tables']))
        ->and($payload['stats']['columns'])->toBeGreaterThan(0)
        ->and($payload['stats']['relations'])->toBeGreaterThan(0)
        ->and($payload['migration_head'])->not->toBe('none');

    // Pick the busiest table in the schema and pin it to its domain.
    $table = collect($payload['tables'])->firstWhere('name', 'orders');

    expect($table)->not->toBeNull()
        ->and($table['domain'])->toBe('orders');

    $id = collect($table['columns'])->firstWhere('name', 'id');
    $uuid = collect($table['columns'])->firstWhere('name', 'uuid');

    // The project's own id convention, which the diagram draws on every card.
    expect($id['pk'])->toBeTrue()
        ->and($uuid['unique'])->toBeTrue();

    $foreign = collect($table['foreign_keys'])->firstWhere('table', 'customers');

    expect($foreign['columns'])->toBe(['customer_id'])
        ->and($foreign['references'])->toBe(['id']);
});

/*
 * `auditable_type` + `auditable_id` point at any model in the application, so
 * the diagram names the pair on the card instead of drawing an arrow that
 * would claim more than the schema does.
 */
it('reports polymorphic column pairs rather than inventing an edge for them', function () {
    $audits = collect(ErdSchema::build()['tables'])->firstWhere('name', 'audits');

    expect($audits['morphs'])->toContain('auditable')
        ->and($audits['foreign_keys'])->toBe([]);
});
```

## Wire the same gate into CI

```yaml
- name: ERD domain coverage
  run: php artisan docs:erd --check
```
