# Enum Conventions

## Rules

1. **Implement `CleaniqueCoders\Traitify\Contracts\Enum`** — all enums must implement the Contract
2. **Use `CleaniqueCoders\Traitify\Concerns\InteractsWithEnum`** trait — provides standard methods
3. **Define `label(): string`** — human-readable label for each case
4. **Define `description(): string`** — longer description for UI tooltips / docs
5. **Use string-backed enums** by default (unless numeric IDs are needed)
6. **Place in `app/Enums/`** directory

## Enum Template

```php
<?php

namespace App\Enums;

use CleaniqueCoders\Traitify\Concerns\InteractsWithEnum;
use CleaniqueCoders\Traitify\Contracts\Enum;

enum InvoiceStatus: string implements Enum
{
    use InteractsWithEnum;

    case Draft = 'draft';
    case Sent = 'sent';
    case Paid = 'paid';
    case Overdue = 'overdue';
    case Cancelled = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::Draft => 'Draft',
            self::Sent => 'Sent',
            self::Paid => 'Paid',
            self::Overdue => 'Overdue',
            self::Cancelled => 'Cancelled',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::Draft => 'Invoice is being prepared',
            self::Sent => 'Invoice has been sent to the client',
            self::Paid => 'Payment has been received',
            self::Overdue => 'Payment is past due date',
            self::Cancelled => 'Invoice has been cancelled',
        };
    }
}
```

## InteractsWithEnum Trait

The `InteractsWithEnum` trait from `cleanique-coders/traitify` provides:

- `values(): array` — returns all case values
- `labels(): array` — returns all case labels
- `options(): array` — returns key-value pairs for dropdowns
- `toArray(): array` — serialisation support

## Using Enums in Models

```php
// In model $casts
protected $casts = [
    'status' => InvoiceStatus::class,
];

// Usage
$invoice->status; // Returns InvoiceStatus enum instance
$invoice->status->label(); // "Draft"
$invoice->status->description(); // "Invoice is being prepared"
$invoice->status = InvoiceStatus::Paid;
```

## Using Enums in Migrations

```php
// Use string column for string-backed enums
$table->string('status')->default(InvoiceStatus::Draft->value);

// DO NOT use $table->enum() — use string column with enum cast in model
```

## Using Enums in Validation

```php
use Illuminate\Validation\Rules\Enum;

'status' => ['required', new Enum(InvoiceStatus::class)],
```

## DO / DON'T

- ✅ DO implement `CleaniqueCoders\Traitify\Contracts\Enum`
- ✅ DO use `InteractsWithEnum` trait
- ✅ DO define both `label()` and `description()` methods
- ✅ DO use string-backed enums by default
- ✅ DO cast enums in the model's `$casts` property
- ❌ DON'T use `$table->enum()` in migrations — use `$table->string()`
- ❌ DON'T create enums without implementing the Contract
- ❌ DON'T hardcode enum values in validation — use `new Enum(ClassName::class)`
