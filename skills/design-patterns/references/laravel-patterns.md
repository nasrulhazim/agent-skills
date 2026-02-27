# Laravel-Specific Patterns

Patterns that are idiomatic to Laravel or the PHP ecosystem, with production-ready
code examples. These complement the GoF patterns in `pattern-catalog.md`.

---

## Action Classes

**When to use:** A single-purpose business operation that can be called from controllers,
commands, jobs, or tests. Keeps controllers thin and business logic reusable.

**Package:** `cleaniquecoders/laravel-action` provides scaffolding and conventions.

```php
// Install
// composer require cleaniquecoders/laravel-action

// Generate
// php artisan make:action CreateOrderAction

namespace App\Actions;

use App\DTOs\CreateOrderData;
use App\Models\Order;
use Illuminate\Support\Facades\DB;

class CreateOrderAction
{
    public function __construct(
        private readonly GenerateOrderNumberAction $generateNumber,
        private readonly CalculateOrderTotalAction $calculateTotal,
    ) {}

    public function execute(CreateOrderData $data): Order
    {
        return DB::transaction(function () use ($data) {
            $order = Order::create([
                'customer_id' => $data->customerId,
                'order_number' => $this->generateNumber->execute(),
                'notes' => $data->notes,
                'status' => 'pending',
            ]);

            foreach ($data->items as $item) {
                $order->items()->create([
                    'product_id' => $item->productId,
                    'quantity' => $item->quantity,
                    'unit_price' => $item->unitPrice,
                ]);
            }

            $order->update([
                'total' => $this->calculateTotal->execute($order),
            ]);

            event(new OrderCreated($order));

            return $order->load('items');
        });
    }
}

// Usage in controller — thin controller, fat action
class OrderController extends Controller
{
    public function store(
        StoreOrderRequest $request,
        CreateOrderAction $action,
    ): JsonResponse {
        $data = CreateOrderData::fromRequest($request);
        $order = $action->execute($data);

        return OrderResource::make($order)
            ->response()
            ->setStatusCode(201);
    }
}

// Usage in artisan command
class CreateTestOrderCommand extends Command
{
    protected $signature = 'order:create-test';

    public function handle(CreateOrderAction $action): int
    {
        $data = CreateOrderData::fromArray([
            'customer_id' => 1,
            'items' => [
                ['product_id' => 1, 'quantity' => 2, 'unit_price' => 5000],
            ],
        ]);

        $order = $action->execute($data);
        $this->info("Created order: {$order->order_number}");

        return self::SUCCESS;
    }
}
```

**Key rules for Actions:**
- One public method: `execute()` (or `handle()` if using `laravel-action` conventions)
- Accept a DTO or primitive types — never a Request object directly
- Return the result — never return a response
- Can call other Actions (composition)
- Can be injected via constructor (auto-resolved by container)

**Pest test:**

```php
use App\Actions\CreateOrderAction;
use App\DTOs\CreateOrderData;
use App\Models\Order;
use App\Models\Product;
use App\Models\Customer;

it('creates an order with items', function () {
    $customer = Customer::factory()->create();
    $product = Product::factory()->create(['price' => 5000]);

    $data = CreateOrderData::fromArray([
        'customer_id' => $customer->id,
        'items' => [
            ['product_id' => $product->id, 'quantity' => 2, 'unit_price' => 5000],
        ],
    ]);

    $order = app(CreateOrderAction::class)->execute($data);

    expect($order)
        ->toBeInstanceOf(Order::class)
        ->status->toBe('pending')
        ->items->toHaveCount(1)
        ->total->toBe(10000);
});

it('dispatches OrderCreated event', function () {
    Event::fake([OrderCreated::class]);

    $data = CreateOrderData::fromArray([...]);
    app(CreateOrderAction::class)->execute($data);

    Event::assertDispatched(OrderCreated::class);
});
```

---

## Service Classes

**When to use:** Orchestrate multiple actions, repositories, or external services.
A service is a coordinator — it delegates, not implements.

**Difference from Action:** Actions are single-purpose. Services orchestrate multiple
actions and may hold more complex workflow logic.

```php
namespace App\Services;

use App\Actions\CreateOrderAction;
use App\Actions\ProcessPaymentAction;
use App\Actions\SendOrderConfirmationAction;
use App\Contracts\Repositories\InventoryRepository;
use App\DTOs\CheckoutData;
use App\DTOs\CheckoutResult;
use App\Exceptions\InsufficientStockException;

class CheckoutService
{
    public function __construct(
        private readonly InventoryRepository $inventory,
        private readonly CreateOrderAction $createOrder,
        private readonly ProcessPaymentAction $processPayment,
        private readonly SendOrderConfirmationAction $sendConfirmation,
    ) {}

    public function checkout(CheckoutData $data): CheckoutResult
    {
        // Step 1: Verify stock
        foreach ($data->items as $item) {
            if (! $this->inventory->hasStock($item->productId, $item->quantity)) {
                throw new InsufficientStockException($item->productId);
            }
        }

        // Step 2: Create order
        $order = $this->createOrder->execute($data->toOrderData());

        // Step 3: Process payment
        $payment = $this->processPayment->execute(
            orderId: $order->id,
            amount: $order->total,
            method: $data->paymentMethod,
            token: $data->paymentToken,
        );

        // Step 4: Reserve inventory
        foreach ($data->items as $item) {
            $this->inventory->reserve($item->productId, $item->quantity, $order->id);
        }

        // Step 5: Send confirmation (queued — non-blocking)
        $this->sendConfirmation->execute($order);

        return new CheckoutResult(
            order: $order,
            payment: $payment,
            success: true,
        );
    }
}

// Service Provider — no interface needed unless you have multiple implementations
// Laravel auto-resolves concrete classes with type-hinted constructor dependencies
```

---

## Data Transfer Objects (DTOs)

**When to use:** Transfer data between layers (request to action, action to response)
with type safety and validation. Decouples your business logic from HTTP concerns.

```php
namespace App\DTOs;

use App\Http\Requests\StoreOrderRequest;
use Illuminate\Http\Request;

class CreateOrderData
{
    /**
     * @param  array<OrderItemData>  $items
     */
    public function __construct(
        public readonly int $customerId,
        public readonly array $items,
        public readonly ?string $notes = null,
        public readonly ?string $couponCode = null,
    ) {}

    public static function fromRequest(StoreOrderRequest $request): static
    {
        return new static(
            customerId: $request->integer('customer_id'),
            items: collect($request->input('items'))->map(
                fn (array $item) => OrderItemData::fromArray($item),
            )->all(),
            notes: $request->input('notes'),
            couponCode: $request->input('coupon_code'),
        );
    }

    public static function fromArray(array $data): static
    {
        return new static(
            customerId: $data['customer_id'],
            items: collect($data['items'])->map(
                fn (array $item) => OrderItemData::fromArray($item),
            )->all(),
            notes: $data['notes'] ?? null,
            couponCode: $data['coupon_code'] ?? null,
        );
    }
}

class OrderItemData
{
    public function __construct(
        public readonly int $productId,
        public readonly int $quantity,
        public readonly int $unitPrice,
    ) {}

    public static function fromArray(array $data): static
    {
        return new static(
            productId: $data['product_id'],
            quantity: $data['quantity'],
            unitPrice: $data['unit_price'],
        );
    }

    public function total(): int
    {
        return $this->quantity * $this->unitPrice;
    }
}
```

**Key rules for DTOs:**
- All properties are `readonly`
- Factory methods: `fromRequest()`, `fromArray()`, `fromModel()`
- No business logic — only data shape and factory methods
- Can have computed getters (like `total()` above) that derive from their own data
- Use PHP 8.2 `readonly` classes when all properties are readonly

---

## Value Objects

**When to use:** A concept in your domain that is defined by its value, not its identity.
Two Value Objects with the same values are equal. Immutable.

**Examples:** Money, Email, PhoneNumber, Address, DateRange, Percentage.

```php
namespace App\ValueObjects;

use InvalidArgumentException;

class Money
{
    public function __construct(
        public readonly int $amount, // Always in smallest unit (cents/sen)
        public readonly string $currency = 'MYR',
    ) {
        if ($amount < 0) {
            throw new InvalidArgumentException('Money amount cannot be negative.');
        }
    }

    public function add(Money $other): static
    {
        $this->ensureSameCurrency($other);

        return new static($this->amount + $other->amount, $this->currency);
    }

    public function subtract(Money $other): static
    {
        $this->ensureSameCurrency($other);

        if ($other->amount > $this->amount) {
            throw new InvalidArgumentException('Cannot subtract more than current amount.');
        }

        return new static($this->amount - $other->amount, $this->currency);
    }

    public function multiply(int $factor): static
    {
        return new static($this->amount * $factor, $this->currency);
    }

    public function percentage(float $percent): static
    {
        return new static((int) round($this->amount * ($percent / 100)), $this->currency);
    }

    public function equals(Money $other): bool
    {
        return $this->amount === $other->amount
            && $this->currency === $other->currency;
    }

    public function greaterThan(Money $other): bool
    {
        $this->ensureSameCurrency($other);

        return $this->amount > $other->amount;
    }

    public function format(): string
    {
        $value = number_format($this->amount / 100, 2);

        return "{$this->currency} {$value}";
    }

    public function toArray(): array
    {
        return [
            'amount' => $this->amount,
            'currency' => $this->currency,
        ];
    }

    private function ensureSameCurrency(Money $other): void
    {
        if ($this->currency !== $other->currency) {
            throw new InvalidArgumentException(
                "Cannot operate on different currencies: {$this->currency} vs {$other->currency}"
            );
        }
    }
}

// Eloquent cast for Value Object
namespace App\Casts;

use App\ValueObjects\Money;
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;

class MoneyCast implements CastsAttributes
{
    public function __construct(
        private readonly string $currency = 'MYR',
    ) {}

    public function get(Model $model, string $key, mixed $value, array $attributes): ?Money
    {
        if ($value === null) {
            return null;
        }

        return new Money(
            amount: (int) $value,
            currency: $attributes["{$key}_currency"] ?? $this->currency,
        );
    }

    public function set(Model $model, string $key, mixed $value, array $attributes): array
    {
        if ($value === null) {
            return [$key => null];
        }

        if ($value instanceof Money) {
            return [
                $key => $value->amount,
                "{$key}_currency" => $value->currency,
            ];
        }

        return [$key => $value];
    }
}

// Usage on model
class Product extends Model
{
    protected function casts(): array
    {
        return [
            'price' => MoneyCast::class . ':MYR',
        ];
    }
}

// Usage
$product = Product::find(1);
$total = $product->price->multiply(3);
echo $total->format(); // "MYR 150.00"
```

**Another Value Object — Email:**

```php
namespace App\ValueObjects;

use InvalidArgumentException;

class Email
{
    public readonly string $value;

    public function __construct(string $value)
    {
        $value = strtolower(trim($value));

        if (! filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidArgumentException("Invalid email address: {$value}");
        }

        $this->value = $value;
    }

    public function domain(): string
    {
        return substr($this->value, strpos($this->value, '@') + 1);
    }

    public function equals(Email $other): bool
    {
        return $this->value === $other->value;
    }

    public function __toString(): string
    {
        return $this->value;
    }
}
```

**Pest test:**

```php
use App\ValueObjects\Money;

it('adds two money values', function () {
    $a = new Money(1000, 'MYR');
    $b = new Money(500, 'MYR');

    expect($a->add($b)->amount)->toBe(1500);
});

it('formats money correctly', function () {
    $money = new Money(12550, 'MYR');

    expect($money->format())->toBe('MYR 125.50');
});

it('prevents negative money', function () {
    new Money(-100, 'MYR');
})->throws(InvalidArgumentException::class);

it('prevents cross-currency operations', function () {
    $myr = new Money(1000, 'MYR');
    $usd = new Money(500, 'USD');

    $myr->add($usd);
})->throws(InvalidArgumentException::class, 'different currencies');
```

---

## Query Scopes

**When to use:** Reusable query constraints that keep models clean and controllers readable.
Extract complex `where` clauses into named scopes.

```php
namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    // Local scopes — called as ->pending(), ->completedBetween(), etc.

    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', 'pending');
    }

    public function scopeCompleted(Builder $query): Builder
    {
        return $query->where('status', 'completed');
    }

    public function scopeCompletedBetween(Builder $query, string $from, string $to): Builder
    {
        return $query->where('status', 'completed')
            ->whereBetween('completed_at', [$from, $to]);
    }

    public function scopeForCustomer(Builder $query, int $customerId): Builder
    {
        return $query->where('customer_id', $customerId);
    }

    public function scopeHighValue(Builder $query, int $threshold = 100000): Builder
    {
        return $query->where('total', '>=', $threshold);
    }

    public function scopeWithFullDetails(Builder $query): Builder
    {
        return $query->with(['items.product', 'customer', 'payments']);
    }

    public function scopeSearch(Builder $query, ?string $term): Builder
    {
        if (! $term) {
            return $query;
        }

        return $query->where(function (Builder $q) use ($term) {
            $q->where('order_number', 'like', "%{$term}%")
                ->orWhereHas('customer', function (Builder $q) use ($term) {
                    $q->where('name', 'like', "%{$term}%");
                });
        });
    }
}

// Usage — scopes compose naturally
$orders = Order::pending()
    ->forCustomer($customerId)
    ->highValue()
    ->withFullDetails()
    ->orderByDesc('created_at')
    ->paginate(20);

// In a controller
class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::query()
            ->forCustomer($request->user()->id)
            ->search($request->input('q'))
            ->when($request->input('status'), fn ($q, $status) => $q->where('status', $status))
            ->withFullDetails()
            ->latest()
            ->paginate($request->integer('per_page', 15));

        return OrderResource::collection($orders)->response();
    }
}
```

**Global scope — automatically applied to all queries:**

```php
namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class ActiveScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        $builder->where('is_active', true);
    }
}

// Apply on model
class Product extends Model
{
    protected static function booted(): void
    {
        static::addGlobalScope(new ActiveScope());
    }
}

// Query includes active filter automatically
Product::all(); // WHERE is_active = true

// Remove when needed
Product::withoutGlobalScope(ActiveScope::class)->get();
```

---

## Form Requests as Validation Layer

**When to use:** Every controller method that accepts user input. Form Requests separate
validation and authorization from controller logic.

```php
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Order::class);
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'integer', 'exists:customers,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
            'items.*.unit_price' => ['required', 'integer', 'min:0'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'coupon_code' => [
                'nullable',
                'string',
                Rule::exists('coupons', 'code')->where('is_active', true),
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'Order must have at least one item.',
            'items.*.product_id.exists' => 'Product #:input does not exist.',
            'items.*.quantity.max' => 'Maximum quantity per item is 999.',
        ];
    }

    /**
     * Prepare the data for validation — normalize before validating.
     */
    protected function prepareForValidation(): void
    {
        if ($this->has('coupon_code')) {
            $this->merge([
                'coupon_code' => strtoupper(trim($this->input('coupon_code'))),
            ]);
        }
    }
}

// Usage in controller — validation happens automatically before method body
class OrderController extends Controller
{
    public function store(StoreOrderRequest $request, CreateOrderAction $action): JsonResponse
    {
        // $request is already validated at this point
        $data = CreateOrderData::fromRequest($request);
        $order = $action->execute($data);

        return OrderResource::make($order)
            ->response()
            ->setStatusCode(201);
    }
}
```

**Advanced: Conditional validation based on context:**

```php
class UpdateOrderRequest extends FormRequest
{
    public function rules(): array
    {
        $order = $this->route('order');

        return [
            'status' => [
                'sometimes',
                'string',
                Rule::in($this->allowedTransitions($order)),
            ],
            'notes' => ['sometimes', 'nullable', 'string', 'max:1000'],
        ];
    }

    private function allowedTransitions(Order $order): array
    {
        return match ($order->status) {
            'pending' => ['processing', 'cancelled'],
            'processing' => ['completed', 'cancelled'],
            default => [],
        };
    }
}
```

---

## API Resources as Presentation Layer

**When to use:** Transform Eloquent models into JSON responses. Decouples your database
schema from your API contract. Controls exactly what data is exposed.

```php
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'status' => $this->status,
            'total' => [
                'amount' => $this->total,
                'formatted' => 'MYR ' . number_format($this->total / 100, 2),
            ],
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'customer' => CustomerResource::make($this->whenLoaded('customer')),
            'notes' => $this->notes,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
            'completed_at' => $this->completed_at?->toISOString(),

            // Conditional fields based on user role
            'internal_notes' => $this->when(
                $request->user()?->isAdmin(),
                $this->internal_notes,
            ),

            // Include links for HATEOAS
            'links' => [
                'self' => route('api.orders.show', $this->id),
                'invoice' => $this->when(
                    $this->status === 'completed',
                    route('api.orders.invoice', $this->id),
                ),
            ],
        ];
    }
}

class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product' => ProductResource::make($this->whenLoaded('product')),
            'quantity' => $this->quantity,
            'unit_price' => [
                'amount' => $this->unit_price,
                'formatted' => 'MYR ' . number_format($this->unit_price / 100, 2),
            ],
            'line_total' => [
                'amount' => $this->quantity * $this->unit_price,
                'formatted' => 'MYR ' . number_format(($this->quantity * $this->unit_price) / 100, 2),
            ],
        ];
    }
}

// Resource Collection with pagination metadata
namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\ResourceCollection;

class OrderCollection extends ResourceCollection
{
    public $collects = OrderResource::class;

    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
            'summary' => [
                'total_orders' => $this->collection->count(),
                'total_value' => $this->collection->sum(fn ($order) => $order->total),
            ],
        ];
    }
}

// Usage in controller
class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::with(['items.product', 'customer'])
            ->forCustomer($request->user()->id)
            ->latest()
            ->paginate(15);

        return (new OrderCollection($orders))->response();
    }

    public function show(Order $order): JsonResponse
    {
        $order->load(['items.product', 'customer', 'payments']);

        return OrderResource::make($order)->response();
    }
}
```

---

## Event / Listener Pattern

**When to use:** Decouple side effects from the main action. The action dispatches an
event; listeners handle consequences independently and can be queued.

See full implementation in `pattern-catalog.md` under **Observer Pattern**.

**Key Laravel conventions:**

```php
// Event — carries the data
class OrderShipped
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public readonly Order $order,
        public readonly string $trackingNumber,
    ) {}
}

// Listener — handles one side effect, can be queued
class SendShipmentNotification implements ShouldQueue
{
    public string $queue = 'notifications';

    public function handle(OrderShipped $event): void
    {
        $event->order->customer->notify(
            new ShipmentNotification($event->order, $event->trackingNumber),
        );
    }
}

// Registration in EventServiceProvider
protected $listen = [
    OrderShipped::class => [
        SendShipmentNotification::class,
        UpdateOrderTracking::class,
        NotifyWarehouse::class,
    ],
];

// Or use event discovery (Laravel 11+)
// Events are auto-discovered from Listeners directory
```

---

## Job / Queue Pattern

**When to use:** Offload time-consuming work to background processing. Emails, PDFs,
API calls, data processing — anything that shouldn't block the HTTP response.

```php
namespace App\Jobs;

use App\Models\Report;
use App\Services\ReportGenerator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\Middleware\WithoutOverlapping;

class GenerateMonthlyReport implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public array $backoff = [30, 60, 120]; // Progressive backoff

    public function __construct(
        public readonly Report $report,
        public readonly string $month,
    ) {}

    /**
     * Queue middleware — prevent duplicate jobs for the same report.
     */
    public function middleware(): array
    {
        return [
            new WithoutOverlapping($this->report->id),
        ];
    }

    public function handle(ReportGenerator $generator): void
    {
        $this->report->update(['status' => 'generating']);

        $path = $generator->generate($this->report, $this->month);

        $this->report->update([
            'status' => 'completed',
            'file_path' => $path,
            'generated_at' => now(),
        ]);
    }

    public function failed(\Throwable $exception): void
    {
        $this->report->update([
            'status' => 'failed',
            'error' => $exception->getMessage(),
        ]);
    }
}

// Dispatch from controller
GenerateMonthlyReport::dispatch($report, '2026-01')
    ->onQueue('reports')
    ->delay(now()->addSeconds(5));

// Job chaining — run in sequence
Bus::chain([
    new GenerateMonthlyReport($report, '2026-01'),
    new EmailReportToStakeholders($report),
    new CleanupTempFiles($report),
])->onQueue('reports')->dispatch();

// Job batching — run in parallel, track progress
Bus::batch([
    new GenerateMonthlyReport($report1, '2026-01'),
    new GenerateMonthlyReport($report2, '2026-01'),
    new GenerateMonthlyReport($report3, '2026-01'),
])
    ->name('monthly-reports-jan-2026')
    ->onQueue('reports')
    ->then(fn (Batch $batch) => Log::info('All reports generated'))
    ->catch(fn (Batch $batch, \Throwable $e) => Log::error('Batch failed: ' . $e->getMessage()))
    ->dispatch();
```

---

## Pipeline Pattern (Laravel)

See full implementation in `pattern-catalog.md` under **Pipeline Pattern**.

**Quick Laravel usage:**

```php
use Illuminate\Support\Facades\Pipeline;

// Processing user input through stages
$result = Pipeline::send($userData)
    ->through([
        NormalizeInput::class,
        ValidateBusinessRules::class,
        EnrichWithDefaults::class,
        SanitizeForStorage::class,
    ])
    ->thenReturn();

// Each stage is an invokable class with handle(mixed $data, Closure $next)
```

---

## Pattern Composition Example

A real-world example showing how multiple patterns work together in a Laravel application:

```
Controller (thin)
  → Form Request (validation)
    → DTO (data transfer)
      → Action (business logic)
        → Repository (data access)
          → Model (Eloquent)
        → Event dispatch
          → Listeners (side effects — queued)
            → Jobs (heavy processing)
      → API Resource (response transformation)
```

```php
// The full flow in code:

// 1. Route
Route::post('/orders', [OrderController::class, 'store']);

// 2. Controller — orchestrates, doesn't implement
class OrderController extends Controller
{
    public function store(
        StoreOrderRequest $request,      // 3. Validation
        CreateOrderAction $action,       // 5. Business logic
    ): JsonResponse {
        $data = CreateOrderData::fromRequest($request);  // 4. DTO
        $order = $action->execute($data);

        return OrderResource::make($order)               // 8. Presentation
            ->response()
            ->setStatusCode(201);
    }
}

// 5. Action — calls repository, dispatches event
class CreateOrderAction
{
    public function __construct(
        private readonly OrderRepository $orders,  // 6. Data access
    ) {}

    public function execute(CreateOrderData $data): Order
    {
        $order = $this->orders->create($data->toArray());
        event(new OrderCreated($order));  // 7. Event → Listeners

        return $order;
    }
}
```
