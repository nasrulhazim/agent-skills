# Model Conventions

## Rules

1. **Always extend `App\Models\Base`** — never extend `Illuminate\Database\Eloquent\Model` directly
2. **Always use `HasFactory` trait** — factories are required for all models
3. **Define `$fillable`** — mass assignment protection is mandatory
4. **Define `$casts`** — cast dates, enums, booleans, and JSON fields
5. **Use return types** on all relationship methods
6. **Place traits (Concerns)** in `app/Concerns/` directory
7. **Use SoftDeletes** for any model that should not be permanently deleted

## Base Model

The `App\Models\Base` model provides:

- UUID attribute via `HasHashId` trait
- Common query scopes
- Standardised boot behaviour

```php
// app/Models/Base.php
namespace App\Models;

use CleaniqueCoders\Traitify\Concerns\InteractsWithHashId as HasHashId;
use Illuminate\Database\Eloquent\Model;

abstract class Base extends Model
{
    use HasHashId;
}
```

## Model Template

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class Invoice extends Base
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'number',
        'amount',
        'status',
        'issued_at',
        'due_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'status' => \App\Enums\InvoiceStatus::class,
        'issued_at' => 'datetime',
        'due_at' => 'datetime',
    ];

    // ──────────────────────────────────────
    // Relationships
    // ──────────────────────────────────────

    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(InvoiceItem::class);
    }

    // ──────────────────────────────────────
    // Scopes
    // ──────────────────────────────────────

    public function scopeOverdue($query)
    {
        return $query->where('due_at', '<', now())
            ->where('status', '!=', \App\Enums\InvoiceStatus::Paid);
    }
}
```

## Silent Failure Modes

### An undefined relation or attribute resolves to `null` — it does not error

```php
// Deployment has owner() over user_id — there is no user() relation.
// This guard silently passes EVERYTHING, forever.
if ($deployment->user?->id !== $actor->id) {
    abort(403);
}
```

Dynamic model properties are `mixed`, so PHPStan cannot see it either. The rule that catches
it: **whenever a guard's whole job is to say "no", write a test that proves it says no.** A
guard that never fires is indistinguishable from one that never runs.

The same shape appears with a column that does not exist (`$component->version` on a model
where the version lives elsewhere) — every read returns `null` and downstream code quietly
treats it as "not set".

### Traitify's `InteractsWithUser` auto-fills any column named `user_id`

`App\Models\Base` uses it, and on create it writes the authenticated user into a column
literally named `user_id`. That is correct when `user_id` means *"who made this row"* — and
wrong when it is a **scope** column. On an organisation-scoped table it silently turns every
org-wide row into a personal one.

```php
// Disable it where user_id is a scope, not an author.
// The trait's Schema::hasColumn() check then short-circuits.
protected $user_id_column = '__disabled__';
```

### `db:seed` wraps seeding in `Model::unguarded()` — and only there

A seeder can mass-assign a column that is not `#[Fillable]` when run through the artisan
command, and silently drop it when the same seeder is instantiated directly (from a test, or
from another seeder). Never let seeder logic lean on ambient unguarded state — write the
non-fillable column through `forceFill()` or the model's own method
(`markEmailAsVerified()`), and instantiate the seeder directly in its test so the difference
cannot hide.

### A factory default must land inside a visibility branch

When a model gains a two-branch visibility rule — say `organization_id` nullable **plus**
`is_system` for a shared catalogue — a factory defaulting to *neither* (no organisation,
`is_system` false) produces rows that match under neither branch. Tests then "create" records
the UI can never list. Give the factory one branch as its default and a named state for the
other:

```php
public function definition(): array
{
    return ['organization_id' => null, 'is_system' => true];   // catalogue default
}

public function forOrganization(Organization $org): static
{
    return $this->state(fn () => ['organization_id' => $org->id, 'is_system' => false]);
}
```

## DO / DON'T

- ✅ DO extend `App\Models\Base`
- ✅ DO use `HasFactory` on every model
- ✅ DO define return types on relationships
- ✅ DO cast enum fields to their enum class
- ✅ DO use SoftDeletes for business entities
- ✅ DO write a test that proves a guard denies, not only that it allows
- ✅ DO disable `InteractsWithUser` (`$user_id_column`) where `user_id` is a scope column
- ❌ DON'T extend `Illuminate\Database\Eloquent\Model` directly
- ❌ DON'T use `$guarded = []` — always use `$fillable`
- ❌ DON'T rely on a relation name without checking it exists — a typo is `null`, not an error
- ❌ DON'T let a seeder mass-assign a non-fillable column via ambient `unguarded()`
- ❌ DON'T define accessors/mutators without proper Attribute cast syntax
- ❌ DON'T put business logic in models — use Actions instead

## Relationship Patterns

```php
// BelongsTo — always include foreign key
public function category(): BelongsTo
{
    return $this->belongsTo(Category::class, 'category_id');
}

// HasMany
public function comments(): HasMany
{
    return $this->hasMany(Comment::class);
}

// BelongsToMany — define pivot table explicitly
public function tags(): BelongsToMany
{
    return $this->belongsToMany(Tag::class, 'taggables')
        ->withTimestamps();
}

// MorphMany
public function activities(): MorphMany
{
    return $this->morphMany(Activity::class, 'activitable');
}
```

## Traits (Concerns)

Custom traits live in `app/Concerns/`:

```php
// app/Concerns/HasSlug.php
namespace App\Concerns;

trait HasSlug
{
    public function initializeHasSlug(): void
    {
        $this->fillable[] = 'slug';
    }

    public static function findBySlug(string $slug): ?static
    {
        return static::where('slug', $slug)->first();
    }
}
```
