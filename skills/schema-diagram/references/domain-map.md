# Domain map — `app/Support/Erd/ErdDomains.php`

The single piece of this toolchain that cannot be generated. Everything else reads the
database; this one encodes what the tables *mean*, which only a person knows.

## Why it is written by hand

A name-prefix heuristic looks reasonable and is wrong in exactly the cases that matter. On a
real schema it files `deployment_mail_sandboxes` under Deployment rather than Data Services,
and `node_certificates` under Infrastructure rather than Networking. It does so **silently** —
the reader cannot tell a considered placement from a lucky prefix match.

So: an explicit `table => domain` map, and a build that fails when it is incomplete.

## The coverage gate

Checked in both directions, and `docs:erd` refuses to write if either is non-empty:

- **`unmapped()`** — tables in the database the map has never heard of. Without this, a new
  table lands in whatever bucket a `default =>` arm chose. A diagram that quietly mis-files a
  table is worse than one that is missing it.
- **`stale()`** — tables the map still claims that the database no longer has. Catches the
  rename that updated the migration and not the map.

The friction is the point: adding a table means spending ten seconds deciding what it *is*.
Exempt only tables a package creates outside a migration (e.g. `dragon-code/laravel-deploy-operations`
creates `operations` on first run), and name the exemption in a comment.

## Choosing the domains

Aim for **8–14 domains**. Fewer and the colour tells you nothing; more and the legend becomes
the thing you have to read first.

| Rule | Why |
|---|---|
| Name domains after the **product's own nouns**, not layers | "Billing", "Fulfilment", "Identity" — never "Models", "Pivots", "Lookups" |
| One domain per table, no overlaps | A table with two homes means the boundary is wrong; pick the one that owns its writes |
| Put framework and package tables in a single **`system`** domain | `cache`, `jobs`, `sessions`, `media`, `telescope_*` are plumbing, not the domain model |
| Default `system` to **off** in the board's initial filter | Most of those tables join to nothing and only add fog |
| Write a **one-line description** per domain | It becomes the legend tooltip and the About panel — it is the only prose in the document |

Derive the first draft from the code, then correct it by hand:

```bash
# Tables grouped by the module/namespace that owns their model
grep -rl "protected \$table\|class .* extends" app/Models | xargs grep -h "protected \$table" | sort -u

# Or start from migration filenames, which usually carry the feature name
ls database/migrations | sed 's/^[0-9_]*//;s/\.php$//' | sort
```

## Colours

Node accent and legend chip. Picked for **separation at small sizes**, not for the brand
palette — twenty tables at 20% zoom are colour blobs, and two adjacent hues make the map
useless. One domain may carry the brand accent; give it to the product's founding noun.

A tested 13-colour set, all readable on both the dark and light themes:

| Hex | Reads as | Hex | Reads as |
|---|---|---|---|
| `#8b5cf6` | violet | `#14b8a6` | teal |
| `#0ea5e9` | sky | `#a3e635` | lime |
| `#10b981` | emerald | `#f43f5e` | rose |
| `#f59e0b` | amber | `#fb923c` | orange |
| `#06b6d4` | cyan | `#d946ef` | fuchsia |
| `#6366f1` | indigo | `#facc15` | yellow |
| `#64748b` | slate — reserve for `system` | | |

Skip a hue rather than reuse one: an unassigned colour costs nothing, a duplicate costs the
reader the whole legend.

## The class

Two constants, four static methods. Copy the shape, replace the contents.

```php
<?php

declare(strict_types=1);

namespace App\Support\Erd;

/**
 * Which product domain each table belongs to, for the ERD document.
 *
 * The map is written by hand on purpose. A name-prefix heuristic mis-files
 * tables silently, which is the failure this class exists to avoid.
 *
 * Coverage is checked in both directions (see `unmapped()` / `stale()`), and
 * `GenerateErdCommand` refuses to write the document when either is non-empty.
 */
final class ErdDomains
{
    /**
     * Domain key => [label, colour, one-line description].
     *
     * Colours are the node accent and the legend chip, picked for separation at
     * small sizes rather than for the brand palette.
     *
     * @var array<string, array{label: string, color: string, description: string}>
     */
    private const DOMAINS = [
        'identity' => [
            'label' => 'Identity & Access',
            'color' => '#8b5cf6',
            'description' => 'Tenancy, users, RBAC and the audit trail.',
        ],
        'catalogue' => [
            'label' => 'Catalogue',
            'color' => '#10b981',
            'description' => 'What is for sale: products, variants, pricing and media.',
        ],
        'orders' => [
            'label' => 'Orders',
            'color' => '#f59e0b',
            'description' => 'Carts through to fulfilment — the transactional core.',
        ],
        'billing' => [
            'label' => 'Billing',
            'color' => '#facc15',
            'description' => 'Subscriptions, entitlements, payment methods and invoices.',
        ],
        // … one entry per domain …
        'system' => [
            'label' => 'Framework & Ops',
            'color' => '#64748b',
            'description' => 'Laravel and package tables — cache, queue, sessions, media, settings.',
        ],
    ];

    /**
     * @var array<string, string>
     */
    private const TABLES = [
        // Identity & Access.
        'organizations' => 'identity',
        'users' => 'identity',
        'roles' => 'identity',
        'permissions' => 'identity',
        'model_has_roles' => 'identity',
        'model_has_permissions' => 'identity',
        'role_has_permissions' => 'identity',

        // Catalogue.
        'products' => 'catalogue',
        'product_variants' => 'catalogue',

        // … every table, grouped by domain with a comment per group …

        // Framework and ops.
        'cache' => 'system',
        'cache_locks' => 'system',
        'jobs' => 'system',
        'job_batches' => 'system',
        'failed_jobs' => 'system',
        'migrations' => 'system',
        'sessions' => 'system',
        'password_reset_tokens' => 'system',
        'personal_access_tokens' => 'system',
        'media' => 'system',
        'settings' => 'system',
        'notifications' => 'system',
    ];

    /**
     * @return array<string, array{label: string, color: string, description: string}>
     */
    public static function all(): array
    {
        return self::DOMAINS;
    }

    public static function for(string $table): ?string
    {
        return self::TABLES[$table] ?? null;
    }

    /**
     * Tables present in the database that the map has never heard of.
     *
     * @param  array<int, string>  $tables
     * @return array<int, string>
     */
    public static function unmapped(array $tables): array
    {
        return array_values(array_diff($tables, array_keys(self::TABLES)));
    }

    /**
     * Tables the map still claims that the database no longer has.
     *
     * Exempt any table a package creates outside a migration — name it here
     * with the reason, so a freshly migrated database does not fail the gate.
     *
     * @param  array<int, string>  $tables
     * @return array<int, string>
     */
    public static function stale(array $tables): array
    {
        $known = array_diff(array_keys(self::TABLES), ['operations']);

        return array_values(array_diff($known, $tables));
    }
}
```

## Keeping it honest

Wire `php artisan docs:erd --check` into CI on the migrations path. The gate then fires on the
pull request that adds the table, when the author still knows what the table is for — not six
weeks later when someone opens the diagram and finds a stranger.

```yaml
- name: ERD domain coverage
  run: php artisan docs:erd --check
```
