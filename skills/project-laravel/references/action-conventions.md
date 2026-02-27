# Action Conventions

## Rules

1. **Place in `app/Actions/`** directory
2. **Use Builder pattern** — fluent setter methods for input
3. **Single `execute()` method** — one action, one responsibility
4. **Type all parameters and return values**
5. **Keep actions focused** — one action per business operation
6. **Name descriptively** — `CreateInvoice`, `ApproveLeaveRequest`, `SendNotification`

## Action Template

```php
<?php

namespace App\Actions;

use App\Models\Invoice;
use App\Models\User;

class CreateInvoice
{
    private User $user;
    private string $number;
    private float $amount;
    private array $items = [];

    public function user(User $user): self
    {
        $this->user = $user;

        return $this;
    }

    public function number(string $number): self
    {
        $this->number = $number;

        return $this;
    }

    public function amount(float $amount): self
    {
        $this->amount = $amount;

        return $this;
    }

    public function items(array $items): self
    {
        $this->items = $items;

        return $this;
    }

    public function execute(): Invoice
    {
        $invoice = Invoice::create([
            'user_id' => $this->user->id,
            'number' => $this->number,
            'amount' => $this->amount,
            'status' => \App\Enums\InvoiceStatus::Draft,
        ]);

        foreach ($this->items as $item) {
            $invoice->items()->create($item);
        }

        return $invoice;
    }
}
```

## Usage

```php
$invoice = (new CreateInvoice)
    ->user($user)
    ->number('INV-2026-001')
    ->amount(1500.00)
    ->items([
        ['description' => 'Consulting', 'amount' => 1000.00],
        ['description' => 'Support', 'amount' => 500.00],
    ])
    ->execute();
```

## Action with Dependency Injection

```php
<?php

namespace App\Actions;

use App\Models\User;
use App\Notifications\WelcomeNotification;

class OnboardUser
{
    public function __construct(
        private readonly AssignDefaultRole $assignDefaultRole,
    ) {}

    private User $user;

    public function user(User $user): self
    {
        $this->user = $user;

        return $this;
    }

    public function execute(): void
    {
        $this->assignDefaultRole->user($this->user)->execute();

        $this->user->notify(new WelcomeNotification);
    }
}
```

## Organising Actions

For modules with many actions, use subdirectories:

```
app/Actions/
├── Invoice/
│   ├── CreateInvoice.php
│   ├── SendInvoice.php
│   ├── MarkInvoiceAsPaid.php
│   └── CancelInvoice.php
├── User/
│   ├── OnboardUser.php
│   └── DeactivateUser.php
└── AssignDefaultRole.php
```

## DO / DON'T

- ✅ DO use Builder pattern with fluent setters
- ✅ DO return typed results from `execute()`
- ✅ DO keep one business operation per action
- ✅ DO use constructor injection for dependencies
- ✅ DO organise related actions into subdirectories
- ❌ DON'T put business logic in controllers — delegate to actions
- ❌ DON'T put business logic in models — use actions
- ❌ DON'T create actions with multiple public methods (not execute)
- ❌ DON'T use static methods — instantiate and chain
