# Schema extractor — `php artisan docs:erd`

Reads the **live database** into the JSON payload the diagram renders. Two classes and one
command; no third-party package.

## Why introspection, never a migration parse

The migrations are the *instructions*; only the database is the *result*. A mature project's
migration folder is full of column changes, index swaps, renames and drops whose net effect is
exactly what a parser gets wrong — and it gets them wrong silently, which is the worst kind of
wrong for a document people trust.

The cost is that generating needs a migrated database. That is why the JSON is committed: the
HTML can then be rebuilt on any machine with Node and no database at all, and a diff on the
JSON is a readable record of what the schema did between releases, which a 1 MB generated HTML
file is not.

## The payload

```
{
  "generated_at":   ISO-8601,
  "driver":         "mysql" | "pgsql" | "sqlite" | …,
  "migration_head": last dated migration applied,
  "domains":        { key: { label, color, description } },
  "tables":         [ { name, domain, columns[], foreign_keys[], indexes[], morphs[] } ],
  "stats":          { tables, columns, relations }
}
```

Per column: `name`, `type`, `nullable`, `pk`, `fk`, `unique`.
Per foreign key: `columns[]`, `table`, `references[]`, `on_delete`.
Per index: `name`, `columns[]`, `unique`, `primary`.
`morphs[]` holds the *prefix* of each `x_type` + `x_id` pair — reported, never drawn.

## Traps this code exists to survive

| Trap | What happens | The fix in the code |
|---|---|---|
| `Schema::getTables()` on Laravel 13 returns every table on the **server** | A dev machine running several projects on one MySQL daemon reports ~1500 tables | Filter every row on `$table['schema']` |
| Filtering that on `getDatabaseName()` **breaks SQLite** | SQLite's schema is `main` while its database name is the *file path*, so nothing matches and the suite sees an empty schema rather than a failure | Filter on `Schema::getCurrentSchemaName()`. One code path — `build()` delegates to `tableNames()` so the two can never drift |
| `migration.repository->getRan()` ends on a sentinel | `9999_12_31_*` or an undated `spatie/laravel-settings` migration becomes the "head" | Keep only `YYYY_MM_DD_HHMMSS_` names, drop `9999_`, sort, take the last |
| MySQL reports `bigint(20) unsigned` | Type column becomes noise | Strip `unsigned`; strip the width on `int` family only — `varchar(255)`'s width matters |
| Polymorphic columns | An arrow to one table would be a claim the schema does not make | Detect the `_type`/`_id` pair, emit it in `morphs[]`, draw no edge |
| A table with no foreign keys | Reads as an island | It may be related in Eloquent only. Say so in the About panel — do not invent edges |

## `app/Support/Erd/ErdSchema.php`

```php
<?php

declare(strict_types=1);

namespace App\Support\Erd;

use Illuminate\Database\Migrations\MigrationRepositoryInterface;
use Illuminate\Support\Facades\Schema;

/**
 * Reads the live schema into the payload the ERD document renders.
 *
 * Introspection, never a migration parse. The migrations are the instructions;
 * only the database is the result — and 134 migration files include column
 * changes, index swaps and drops whose net effect is exactly what a parser
 * would get wrong.
 *
 * One trap worth naming: on Laravel 13 `Schema::getTables()` returns every
 * table on the *server*, not the connection's own database, so a developer
 * machine running several projects on one MySQL daemon reports around fifteen
 * hundred tables. Everything here is filtered to the current schema — and the
 * filter asks `getCurrentSchemaName()`, not `getDatabaseName()`, because those
 * two disagree on SQLite: the schema is `main` while the database name is the
 * file path, so filtering on the latter matches nothing and the suite would
 * see an empty schema rather than a failure.
 */
final class ErdSchema
{
    /**
     * @return array{
     *     generated_at: string,
     *     driver: string,
     *     migration_head: string,
     *     domains: array<string, array{label: string, color: string, description: string}>,
     *     tables: array<int, array<string, mixed>>,
     *     stats: array<string, int>
     * }
     */
    public static function build(): array
    {
        $tables = [];
        $relations = 0;

        foreach (self::tableNames() as $name) {
            $table = self::table($name);
            $relations += count($table['foreign_keys']);
            $tables[] = $table;
        }

        return [
            'generated_at' => now()->toIso8601String(),
            'driver' => Schema::getConnection()->getDriverName(),
            'migration_head' => self::migrationHead(),
            'domains' => ErdDomains::all(),
            'tables' => $tables,
            'stats' => [
                'tables' => count($tables),
                'columns' => array_sum(array_map(fn (array $t): int => count($t['columns']), $tables)),
                'relations' => $relations,
            ],
        ];
    }

    /**
     * @return array<int, string>
     */
    public static function tableNames(): array
    {
        $schema = Schema::getCurrentSchemaName();
        $names = [];

        foreach (Schema::getTables() as $table) {
            if (($table['schema'] ?? $schema) !== $schema) {
                continue;
            }

            $names[] = $table['name'];
        }

        sort($names);

        return $names;
    }

    /**
     * The last migration applied to the database this was read from.
     *
     * Better provenance than the database's name, which on a developer machine
     * is whatever the connection happened to point at and says nothing about
     * whether the schema is at head. A reader comparing this document with the
     * repository can check one string.
     */
    private static function migrationHead(): string
    {
        /** @var MigrationRepositoryInterface $repository */
        $repository = app('migration.repository');

        // `getRan()` is in the order they were applied, so its last entry is
        // whichever sentinel runs last — `9999_12_31_*`, or one of the
        // spatie/laravel-settings migrations, which carry no date at all.
        // Neither says anything about how current the schema is. The newest
        // real dated migration does.
        $dated = array_filter(
            $repository->getRan(),
            fn (string $migration): bool => preg_match('/^\d{4}_\d{2}_\d{2}_\d{6}_/', $migration) === 1
                && ! str_starts_with($migration, '9999_'),
        );

        if ($dated === []) {
            return 'none';
        }

        sort($dated);

        return (string) end($dated);
    }

    /**
     * @return array<string, mixed>
     */
    private static function table(string $name): array
    {
        $indexes = Schema::getIndexes($name);

        $primary = [];
        $unique = [];

        foreach ($indexes as $index) {
            if ($index['primary']) {
                $primary = [...$primary, ...$index['columns']];

                continue;
            }

            if ($index['unique']) {
                $unique = [...$unique, ...$index['columns']];
            }
        }

        $foreignKeys = [];
        $foreignColumns = [];

        foreach (Schema::getForeignKeys($name) as $key) {
            $foreignKeys[] = [
                'columns' => $key['columns'],
                'table' => $key['foreign_table'],
                'references' => $key['foreign_columns'],
                'on_delete' => $key['on_delete'],
            ];

            $foreignColumns = [...$foreignColumns, ...$key['columns']];
        }

        $columns = [];

        foreach (Schema::getColumns($name) as $column) {
            $columns[] = [
                'name' => $column['name'],
                'type' => self::readableType($column),
                'nullable' => (bool) $column['nullable'],
                'pk' => in_array($column['name'], $primary, true),
                'fk' => in_array($column['name'], $foreignColumns, true),
                'unique' => in_array($column['name'], $unique, true),
            ];
        }

        return [
            'name' => $name,
            'domain' => ErdDomains::for($name) ?? 'system',
            'columns' => $columns,
            'foreign_keys' => $foreignKeys,
            'indexes' => array_map(fn (array $index): array => [
                'name' => $index['name'],
                'columns' => $index['columns'],
                'unique' => (bool) $index['unique'],
                'primary' => (bool) $index['primary'],
            ], $indexes),
            'morphs' => self::morphs($columns),
        ];
    }

    /**
     * Polymorphic column pairs, reported rather than drawn.
     *
     * `auditable_type` + `auditable_id` points at any model in the application,
     * so there is no edge to draw — an arrow to one table would be a claim the
     * schema does not make. Naming the pair on the node says the relation is
     * there and that its target is decided at runtime.
     *
     * @param  array<int, array<string, mixed>>  $columns
     * @return array<int, string>
     */
    private static function morphs(array $columns): array
    {
        $names = array_map(fn (array $column): string => (string) $column['name'], $columns);
        $morphs = [];

        foreach ($names as $column) {
            if (! str_ends_with($column, '_type')) {
                continue;
            }

            $prefix = substr($column, 0, -5);

            if (in_array($prefix.'_id', $names, true)) {
                $morphs[] = $prefix;
            }
        }

        return $morphs;
    }

    /**
     * @param  array<string, mixed>  $column
     */
    private static function readableType(array $column): string
    {
        $type = (string) ($column['type'] ?? $column['type_name']);

        // MySQL reports `int unsigned`; the width in `varchar(255)` matters and
        // the one in `bigint(20)` does not. Keep the parameter, drop the noise.
        $type = (string) preg_replace('/\bunsigned\b/', '', $type);
        $type = (string) preg_replace('/^(big|small|medium|tiny)?int\(\d+\)/', '$1int', $type);

        return trim((string) preg_replace('/\s+/', ' ', $type));
    }
}
```

## `app/Console/Commands/GenerateErdCommand.php`

The command **refuses to write** when the domain map does not account for every table — in
either direction. See `domain-map.md` for why that gate is worth the friction.

`--check` runs the same coverage test and writes nothing, which is what CI calls.

```php
<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Support\Erd\ErdDomains;
use App\Support\Erd\ErdSchema;
use Illuminate\Console\Command;

/**
 * Writes the machine-readable schema the ERD document is drawn from.
 *
 * Two steps, deliberately split so neither needs the other's toolchain:
 *
 *   php artisan docs:erd     reads the live database  -> docs/03-architecture/erd-schema.json
 *   npm run build:erd        bundles the React Flow island into the HTML document
 *
 * The JSON is committed, so the document can be rebuilt on a machine with no
 * database, and a diff on it is a readable record of what the schema did
 * between releases — which a 700 KB generated HTML file is not.
 *
 * Refuses to write when `ErdDomains` does not account for every table. A
 * diagram that quietly files a new table under whatever a fallback chose is
 * worse than one missing it: the reader cannot tell the difference.
 */
class GenerateErdCommand extends Command
{
    protected $signature = 'docs:erd
        {--check : Verify the domain map covers the schema, and write nothing}';

    protected $description = 'Generate the ERD schema payload from the live database';

    public function handle(): int
    {
        $tables = ErdSchema::tableNames();

        if ($tables === []) {
            $this->components->error('The connection reports no tables. Run `php artisan migrate` first.');

            return self::FAILURE;
        }

        $unmapped = ErdDomains::unmapped($tables);
        $stale = ErdDomains::stale($tables);

        if ($unmapped !== []) {
            $this->components->error('These tables have no domain in App\Support\Erd\ErdDomains:');

            foreach ($unmapped as $table) {
                $this->line('  '.$table);
            }
        }

        if ($stale !== []) {
            $this->components->warn('These tables are mapped but no longer exist:');

            foreach ($stale as $table) {
                $this->line('  '.$table);
            }
        }

        if ($unmapped !== [] || $stale !== []) {
            return self::FAILURE;
        }

        if ($this->option('check')) {
            $this->components->info(sprintf('All %d tables are accounted for.', count($tables)));

            return self::SUCCESS;
        }

        $payload = ErdSchema::build();
        $path = base_path('docs/03-architecture/erd-schema.json');

        file_put_contents(
            $path,
            json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE)."\n"
        );

        $this->components->info(sprintf(
            '%d tables, %d columns, %d relations from %s at %s.',
            $payload['stats']['tables'],
            $payload['stats']['columns'],
            $payload['stats']['relations'],
            $payload['driver'],
            $payload['migration_head'],
        ));

        $this->components->twoColumnDetail('Written', 'docs/03-architecture/erd-schema.json');
        $this->components->twoColumnDetail('Next', 'npm run build:erd');

        return self::SUCCESS;
    }
}
```

## Running it

```bash
php artisan docs:erd            # writes docs/03-architecture/erd-schema.json
php artisan docs:erd --check    # coverage gate only, for CI
```

Change the output path in the command if the project's docs tree is not
`docs/03-architecture/` — the build script reads the same two paths and must agree.
