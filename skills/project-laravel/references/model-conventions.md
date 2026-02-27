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

## DO / DON'T

- ✅ DO extend `App\Models\Base`
- ✅ DO use `HasFactory` on every model
- ✅ DO define return types on relationships
- ✅ DO cast enum fields to their enum class
- ✅ DO use SoftDeletes for business entities
- ❌ DON'T extend `Illuminate\Database\Eloquent\Model` directly
- ❌ DON'T use `$guarded = []` — always use `$fillable`
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
