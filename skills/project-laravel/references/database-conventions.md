# Database Conventions

## Rules

1. **UUID column on every table** — `$table->id()` + `$table->uuid('uuid')->index()`
2. **Timestamps on every table** — `$table->timestamps()`
3. **SoftDeletes where appropriate** — `$table->softDeletes()`
4. **Use string columns for enums** — not `$table->enum()`
5. **Foreign keys with constrained()** — referential integrity
6. **Factories for every model** — required for testing
7. **Seeders use factories** — not manual inserts

## Migration Template

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoices', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->index();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('number')->unique();
            $table->decimal('amount', 12, 2)->default(0);
            $table->string('status')->default('draft');
            $table->timestamp('issued_at')->nullable();
            $table->timestamp('due_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoices');
    }
};
```

## Key Migration Rules

### UUID Column

Every table MUST have a uuid column:

```php
$table->id();                        // Auto-increment PK
$table->uuid('uuid')->index();       // UUID for public-facing IDs
```

### Foreign Keys

Always use `constrained()` with appropriate cascade:

```php
$table->foreignId('user_id')->constrained()->cascadeOnDelete();
$table->foreignId('category_id')->constrained()->nullOnDelete();
```

### Enum Columns

Use `string` — NOT `enum`:

```php
// ✅ Correct
$table->string('status')->default('draft');

// ❌ Wrong
$table->enum('status', ['draft', 'sent', 'paid']);
```

### Pivot Tables

```php
Schema::create('invoice_tag', function (Blueprint $table) {
    $table->id();
    $table->foreignId('invoice_id')->constrained()->cascadeOnDelete();
    $table->foreignId('tag_id')->constrained()->cascadeOnDelete();
    $table->timestamps();

    $table->unique(['invoice_id', 'tag_id']);
});
```

## Portability — Why a Green Suite Proves Nothing

Tests run on **SQLite in-memory**, the most permissive engine there is: it rebuilds the whole
table on `ALTER` and accepts orderings the production engine rejects. Anything touching
indexes, foreign keys, or column modification must be checked against the real engine before
it is called done.

```bash
# The round trip. Run it against MySQL, not SQLite.
php artisan migrate && php artisan migrate:rollback && php artisan migrate
```

### MySQL needs an index whose *leading* column backs each foreign key

Dropping a unique before creating its replacement fails with **errno 1553** — while PostgreSQL
and SQLite accept either order.

```php
// RIGHT — create the replacement first, then drop the old one.
$table->unique(['organization_id', 'slug'], 'items_org_slug_unique');
$table->dropUnique('items_slug_unique');
// ...and reverse that order in down().
```

It is about the **leading column**, not about an index merely existing. Swapping one composite
unique for another still fails if the FK column stops being leading anywhere — that FK then
needs a plain index of its own, created before the drop.

### `down()` hits errno 1553 where `up()` does not

A composite unique leading with a foreign-key column becomes the only index backing that
constraint, so MySQL refuses to drop it while the FK stands. Order: **drop the foreign key,
then the index, then the column.** This is why the round trip above must be tested rather than
reasoned about.

### MySQL and Oracle have no transactional DDL

A migration that fails halfway leaves the table half-changed *and* unrecorded, so the next
`migrate` reports a confusing "Duplicate column" instead of the real error. Guard multi-step
migrations so a partially-applied database recovers on re-run:

```php
if (! Schema::hasColumn('items', 'archived_at')) {
    Schema::table('items', fn (Blueprint $t) => $t->timestamp('archived_at')->nullable());
}
```

### `Schema::hasIndex()` is not reliable mid-migration

It has returned `false` for an index that plainly existed, silently skipping the `dropUnique()`
guarded by it — the swap reports DONE and the old index survives, visible only via
`SHOW INDEX`. Read the list and match the name yourself, case-insensitively (the drivers
disagree on casing):

```php
$existing = collect(Schema::getIndexes('items'))
    ->pluck('name')
    ->map(fn ($n) => strtolower($n));

if ($existing->contains('items_slug_unique')) {
    $table->dropUnique('items_slug_unique');
}
```

### `dropConstrainedForeignId()` guesses the conventional name

It assumes `{table}_{column}_foreign`. A migration that named its FK explicitly via
`constrained(indexName: '…')` must drop it by **that** name, or MySQL fails with errno 1091.
SQLite rebuilds the table on ALTER and passes either way.

### Engine-agnostic by default

Use Eloquent, the schema builder and the query builder for everything ordinary — they already
emit correct SQL per driver, which is the whole point of using them. Where something genuinely
is engine-specific, branch on `DB::connection()->getDriverName()` and implement each path so
the **result** is identical. Never dialect-specific syntax (`TINYINT(1)`, `AUTO_INCREMENT`,
`ENGINE=InnoDB`, `jsonb`, `ILIKE`, `::text`) outside such a branch.

## Factory Template

```php
<?php

namespace Database\Factories;

use App\Enums\InvoiceStatus;
use App\Models\Invoice;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class InvoiceFactory extends Factory
{
    protected $model = Invoice::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'number' => 'INV-' . $this->faker->unique()->numerify('####'),
            'amount' => $this->faker->randomFloat(2, 100, 10000),
            'status' => InvoiceStatus::Draft->value,
            'issued_at' => now(),
            'due_at' => now()->addDays(30),
        ];
    }

    // State methods
    public function paid(): static
    {
        return $this->state(fn () => [
            'status' => InvoiceStatus::Paid->value,
        ]);
    }

    public function overdue(): static
    {
        return $this->state(fn () => [
            'status' => InvoiceStatus::Overdue->value,
            'due_at' => now()->subDays(7),
        ]);
    }
}
```

## Seeder Template

```php
<?php

namespace Database\Seeders;

use App\Models\Invoice;
use Illuminate\Database\Seeder;

class InvoiceSeeder extends Seeder
{
    public function run(): void
    {
        Invoice::factory()
            ->count(20)
            ->create();

        Invoice::factory()
            ->paid()
            ->count(10)
            ->create();
    }
}
```

## DatabaseSeeder Registration

```php
public function run(): void
{
    $this->call([
        AccessControlSeeder::class,
        UserSeeder::class,
        InvoiceSeeder::class,
    ]);
}
```

## DO / DON'T

- ✅ DO add `uuid` column to every table
- ✅ DO use `$table->id()` for auto-increment PK
- ✅ DO use `constrained()` for foreign keys
- ✅ DO use string columns for enum values
- ✅ DO create factories with state methods
- ✅ DO seed via factories, not manual inserts
- ❌ DON'T use `$table->enum()` — use `$table->string()`
- ❌ DON'T skip timestamps or uuid columns
- ❌ DON'T use raw SQL in migrations
- ❌ DON'T forget to add `down()` method in migrations
