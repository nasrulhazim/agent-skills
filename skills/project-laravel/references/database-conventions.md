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
