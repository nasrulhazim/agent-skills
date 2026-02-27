# GoF Pattern Catalog — PHP & Laravel

Full catalog of Gang of Four patterns adapted for modern PHP 8.2+ and Laravel.
Each pattern includes: when to use, structure, Laravel-idiomatic implementation, and tests.

---

## Creational Patterns

### Factory Pattern

**When to use:** You need to create objects without specifying the exact class. The creation
logic is complex or varies based on input.

**Laravel context:** Notification channels, payment gateways, export formats, anything where
the concrete class is determined at runtime.

```php
// Interface
namespace App\Contracts;

interface NotificationSender
{
    public function send(string $recipient, string $message): void;
}

// Concrete implementations
namespace App\Notifications\Channels;

use App\Contracts\NotificationSender;

class SmsSender implements NotificationSender
{
    public function __construct(
        private readonly TwilioClient $client,
    ) {}

    public function send(string $recipient, string $message): void
    {
        $this->client->messages->create($recipient, [
            'body' => $message,
        ]);
    }
}

class EmailSender implements NotificationSender
{
    public function __construct(
        private readonly Mailer $mailer,
    ) {}

    public function send(string $recipient, string $message): void
    {
        $this->mailer->to($recipient)->send(new GenericMessage($message));
    }
}

class WhatsAppSender implements NotificationSender
{
    public function __construct(
        private readonly WhatsAppClient $client,
    ) {}

    public function send(string $recipient, string $message): void
    {
        $this->client->sendMessage($recipient, $message);
    }
}

// Factory
namespace App\Notifications;

use App\Contracts\NotificationSender;
use InvalidArgumentException;

class NotificationSenderFactory
{
    public function __construct(
        private readonly SmsSender $sms,
        private readonly EmailSender $email,
        private readonly WhatsAppSender $whatsapp,
    ) {}

    public function make(string $channel): NotificationSender
    {
        return match ($channel) {
            'sms' => $this->sms,
            'email' => $this->email,
            'whatsapp' => $this->whatsapp,
            default => throw new InvalidArgumentException("Unknown channel: {$channel}"),
        };
    }
}

// Service Provider registration
use App\Notifications\NotificationSenderFactory;

$this->app->singleton(NotificationSenderFactory::class);

// Usage in controller or action
class SendNotificationAction
{
    public function __construct(
        private readonly NotificationSenderFactory $factory,
    ) {}

    public function execute(User $user, string $message): void
    {
        $sender = $this->factory->make($user->preferred_channel);
        $sender->send($user->contact, $message);
    }
}
```

**Pest test:**

```php
it('creates the correct sender for each channel', function (string $channel, string $expected) {
    $factory = app(NotificationSenderFactory::class);
    expect($factory->make($channel))->toBeInstanceOf($expected);
})->with([
    ['sms', SmsSender::class],
    ['email', EmailSender::class],
    ['whatsapp', WhatsAppSender::class],
]);

it('throws for unknown channel', function () {
    $factory = app(NotificationSenderFactory::class);
    $factory->make('pigeon');
})->throws(InvalidArgumentException::class);
```

---

### Builder Pattern

**When to use:** Object construction involves many optional parameters, or you need to
build complex objects step by step. Fluent API makes construction readable.

**Laravel context:** Report generation, complex query building, configuration objects,
multi-step form data assembly.

```php
namespace App\Builders;

use App\DTOs\ReportConfig;

class ReportBuilder
{
    private string $title = '';
    private string $format = 'pdf';
    private ?string $header = null;
    private ?string $footer = null;
    private array $columns = [];
    private array $filters = [];
    private ?string $groupBy = null;
    private string $orientation = 'portrait';
    private bool $includeCharts = false;
    private ?string $dateRange = null;

    public function title(string $title): static
    {
        $this->title = $title;

        return $this;
    }

    public function format(string $format): static
    {
        $this->format = $format;

        return $this;
    }

    public function header(string $header): static
    {
        $this->header = $header;

        return $this;
    }

    public function footer(string $footer): static
    {
        $this->footer = $footer;

        return $this;
    }

    public function columns(array $columns): static
    {
        $this->columns = $columns;

        return $this;
    }

    public function addColumn(string $name, string $label, ?string $format = null): static
    {
        $this->columns[] = compact('name', 'label', 'format');

        return $this;
    }

    public function filter(string $field, mixed $value): static
    {
        $this->filters[$field] = $value;

        return $this;
    }

    public function groupBy(string $field): static
    {
        $this->groupBy = $field;

        return $this;
    }

    public function landscape(): static
    {
        $this->orientation = 'landscape';

        return $this;
    }

    public function withCharts(): static
    {
        $this->includeCharts = true;

        return $this;
    }

    public function dateRange(string $from, string $to): static
    {
        $this->dateRange = "{$from} to {$to}";

        return $this;
    }

    public function build(): ReportConfig
    {
        if (empty($this->title)) {
            throw new \InvalidArgumentException('Report title is required.');
        }

        if (empty($this->columns)) {
            throw new \InvalidArgumentException('At least one column is required.');
        }

        return new ReportConfig(
            title: $this->title,
            format: $this->format,
            header: $this->header,
            footer: $this->footer,
            columns: $this->columns,
            filters: $this->filters,
            groupBy: $this->groupBy,
            orientation: $this->orientation,
            includeCharts: $this->includeCharts,
            dateRange: $this->dateRange,
        );
    }
}

// DTO that the builder produces
namespace App\DTOs;

class ReportConfig
{
    public function __construct(
        public readonly string $title,
        public readonly string $format,
        public readonly ?string $header,
        public readonly ?string $footer,
        public readonly array $columns,
        public readonly array $filters,
        public readonly ?string $groupBy,
        public readonly string $orientation,
        public readonly bool $includeCharts,
        public readonly ?string $dateRange,
    ) {}
}

// Usage
$config = (new ReportBuilder())
    ->title('Monthly Sales Report')
    ->format('pdf')
    ->landscape()
    ->withCharts()
    ->addColumn('date', 'Date', 'Y-m-d')
    ->addColumn('product', 'Product')
    ->addColumn('revenue', 'Revenue', 'currency')
    ->filter('status', 'completed')
    ->groupBy('product')
    ->dateRange('2026-01-01', '2026-01-31')
    ->build();
```

---

### Singleton Pattern

**When to use:** Exactly one instance of a class must exist. In Laravel, you almost
never implement Singleton yourself — use the service container instead.

**Laravel context:** Service container `singleton()` bindings. Avoid the classic
GoF singleton anti-pattern with private constructors.

```php
// DO: Use Laravel's service container
// AppServiceProvider.php
public function register(): void
{
    $this->app->singleton(MetricsCollector::class, function ($app) {
        return new MetricsCollector(
            driver: config('metrics.driver'),
            prefix: config('metrics.prefix'),
        );
    });
}

// The class itself is a normal class — no private constructor, no static instance
namespace App\Services;

class MetricsCollector
{
    private array $metrics = [];

    public function __construct(
        private readonly string $driver,
        private readonly string $prefix,
    ) {}

    public function increment(string $key, int $value = 1): void
    {
        $this->metrics[$key] = ($this->metrics[$key] ?? 0) + $value;
    }

    public function flush(): void
    {
        // Send metrics to driver
        $this->metrics = [];
    }
}

// DON'T: Classic singleton anti-pattern — hard to test, hidden dependency
class BadSingleton
{
    private static ?self $instance = null;

    private function __construct() {}

    public static function getInstance(): self
    {
        return self::$instance ??= new self();
    }
}
```

---

## Structural Patterns

### Repository Pattern

**When to use:** Decouple data access logic from business logic. Allows swapping
data sources (Eloquent, API, cache) without changing business code.

**Laravel context:** Sits between controllers/actions and Eloquent models.

```php
// Interface
namespace App\Contracts\Repositories;

use App\Models\Order;
use Illuminate\Support\Collection;

interface OrderRepository
{
    public function find(int $id): ?Order;

    public function findOrFail(int $id): Order;

    public function getByCustomer(int $customerId): Collection;

    public function getPending(): Collection;

    public function create(array $data): Order;

    public function updateStatus(int $id, string $status): Order;
}

// Eloquent implementation
namespace App\Repositories;

use App\Contracts\Repositories\OrderRepository;
use App\Models\Order;
use Illuminate\Support\Collection;

class EloquentOrderRepository implements OrderRepository
{
    public function find(int $id): ?Order
    {
        return Order::find($id);
    }

    public function findOrFail(int $id): Order
    {
        return Order::findOrFail($id);
    }

    public function getByCustomer(int $customerId): Collection
    {
        return Order::where('customer_id', $customerId)
            ->orderByDesc('created_at')
            ->get();
    }

    public function getPending(): Collection
    {
        return Order::where('status', 'pending')
            ->with('items')
            ->orderBy('created_at')
            ->get();
    }

    public function create(array $data): Order
    {
        return Order::create($data);
    }

    public function updateStatus(int $id, string $status): Order
    {
        $order = $this->findOrFail($id);
        $order->update(['status' => $status]);

        return $order->fresh();
    }
}

// Service Provider binding
use App\Contracts\Repositories\OrderRepository;
use App\Repositories\EloquentOrderRepository;

$this->app->bind(OrderRepository::class, EloquentOrderRepository::class);

// Usage in Action class
class ProcessOrderAction
{
    public function __construct(
        private readonly OrderRepository $orders,
    ) {}

    public function execute(int $orderId): Order
    {
        $order = $this->orders->findOrFail($orderId);

        // Business logic here...

        return $this->orders->updateStatus($orderId, 'processing');
    }
}
```

**Pest test:**

```php
use App\Contracts\Repositories\OrderRepository;
use App\Models\Order;

beforeEach(function () {
    $this->repository = app(OrderRepository::class);
});

it('finds an order by id', function () {
    $order = Order::factory()->create();

    expect($this->repository->find($order->id))
        ->toBeInstanceOf(Order::class)
        ->id->toBe($order->id);
});

it('returns pending orders only', function () {
    Order::factory()->count(3)->create(['status' => 'pending']);
    Order::factory()->count(2)->create(['status' => 'completed']);

    expect($this->repository->getPending())->toHaveCount(3);
});
```

---

### Decorator Pattern

**When to use:** Add behaviour to an object dynamically without modifying its class.
Common for layering caching, logging, or rate limiting on top of a service.

**Laravel context:** Cache decorator around a repository, logging decorator around
an external API client.

```php
// The repository interface stays the same as above

// Cache decorator — wraps any OrderRepository implementation
namespace App\Repositories\Decorators;

use App\Contracts\Repositories\OrderRepository;
use App\Models\Order;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;

class CachingOrderRepository implements OrderRepository
{
    public function __construct(
        private readonly OrderRepository $inner,
        private readonly int $ttl = 300,
    ) {}

    public function find(int $id): ?Order
    {
        return Cache::remember(
            "order:{$id}",
            $this->ttl,
            fn () => $this->inner->find($id),
        );
    }

    public function findOrFail(int $id): Order
    {
        return Cache::remember(
            "order:{$id}",
            $this->ttl,
            fn () => $this->inner->findOrFail($id),
        );
    }

    public function getByCustomer(int $customerId): Collection
    {
        return Cache::remember(
            "orders:customer:{$customerId}",
            $this->ttl,
            fn () => $this->inner->getByCustomer($customerId),
        );
    }

    public function getPending(): Collection
    {
        // Don't cache pending — changes frequently
        return $this->inner->getPending();
    }

    public function create(array $data): Order
    {
        $order = $this->inner->create($data);
        Cache::forget("orders:customer:{$order->customer_id}");

        return $order;
    }

    public function updateStatus(int $id, string $status): Order
    {
        $order = $this->inner->updateStatus($id, $status);
        Cache::forget("order:{$id}");
        Cache::forget("orders:customer:{$order->customer_id}");

        return $order;
    }
}

// Service Provider — decorate the binding
use App\Contracts\Repositories\OrderRepository;
use App\Repositories\EloquentOrderRepository;
use App\Repositories\Decorators\CachingOrderRepository;

$this->app->bind(OrderRepository::class, function ($app) {
    return new CachingOrderRepository(
        inner: new EloquentOrderRepository(),
        ttl: 300,
    );
});
```

---

### Adapter Pattern

**When to use:** You need to make an incompatible interface work with your code.
Common when wrapping third-party SDKs or APIs behind your own interface.

**Laravel context:** Payment gateways, SMS providers, file storage drivers.

```php
// Your interface
namespace App\Contracts;

interface PaymentGateway
{
    public function charge(int $amountInCents, string $currency, string $token): PaymentResult;

    public function refund(string $transactionId, int $amountInCents): PaymentResult;
}

// Adapter for Stripe
namespace App\Adapters;

use App\Contracts\PaymentGateway;
use App\DTOs\PaymentResult;
use Stripe\StripeClient;

class StripeAdapter implements PaymentGateway
{
    public function __construct(
        private readonly StripeClient $stripe,
    ) {}

    public function charge(int $amountInCents, string $currency, string $token): PaymentResult
    {
        $charge = $this->stripe->charges->create([
            'amount' => $amountInCents,
            'currency' => $currency,
            'source' => $token,
        ]);

        return new PaymentResult(
            success: $charge->status === 'succeeded',
            transactionId: $charge->id,
            amount: $charge->amount,
            currency: $charge->currency,
        );
    }

    public function refund(string $transactionId, int $amountInCents): PaymentResult
    {
        $refund = $this->stripe->refunds->create([
            'charge' => $transactionId,
            'amount' => $amountInCents,
        ]);

        return new PaymentResult(
            success: $refund->status === 'succeeded',
            transactionId: $refund->id,
            amount: $refund->amount,
            currency: $refund->currency,
        );
    }
}

// Adapter for a different gateway (e.g., local Malaysian gateway)
namespace App\Adapters;

use App\Contracts\PaymentGateway;
use App\DTOs\PaymentResult;

class FPXAdapter implements PaymentGateway
{
    public function __construct(
        private readonly FPXClient $fpx,
    ) {}

    public function charge(int $amountInCents, string $currency, string $token): PaymentResult
    {
        // FPX uses MYR in ringgit (not cents), so we convert
        $response = $this->fpx->createPayment([
            'amount' => $amountInCents / 100,
            'bank_code' => $token,
            'reference' => uniqid('FPX-'),
        ]);

        return new PaymentResult(
            success: $response['status'] === '00',
            transactionId: $response['transaction_id'],
            amount: $amountInCents,
            currency: 'MYR',
        );
    }

    public function refund(string $transactionId, int $amountInCents): PaymentResult
    {
        // FPX doesn't support online refunds — manual process
        throw new \RuntimeException('FPX refunds must be processed manually.');
    }
}

// Service Provider — bind based on config
$this->app->bind(PaymentGateway::class, function ($app) {
    return match (config('payment.driver')) {
        'stripe' => new StripeAdapter(new StripeClient(config('payment.stripe.secret'))),
        'fpx' => new FPXAdapter(new FPXClient(config('payment.fpx'))),
        default => throw new \InvalidArgumentException('Unknown payment driver'),
    };
});
```

---

## Behavioural Patterns

### Strategy Pattern

**When to use:** Multiple algorithms can solve the same problem, and you want to
select one at runtime without conditionals scattered through your code.

**Laravel context:** Export formats, pricing calculators, discount strategies,
notification channels, search implementations.

```php
// Interface
namespace App\Contracts;

interface PricingStrategy
{
    public function calculate(float $basePrice, int $quantity): float;

    public function name(): string;
}

// Concrete strategies
namespace App\Strategies\Pricing;

use App\Contracts\PricingStrategy;

class StandardPricing implements PricingStrategy
{
    public function calculate(float $basePrice, int $quantity): float
    {
        return $basePrice * $quantity;
    }

    public function name(): string
    {
        return 'standard';
    }
}

class BulkDiscountPricing implements PricingStrategy
{
    public function calculate(float $basePrice, int $quantity): float
    {
        $discount = match (true) {
            $quantity >= 100 => 0.20,
            $quantity >= 50 => 0.15,
            $quantity >= 20 => 0.10,
            default => 0,
        };

        return ($basePrice * $quantity) * (1 - $discount);
    }

    public function name(): string
    {
        return 'bulk_discount';
    }
}

class SubscriptionPricing implements PricingStrategy
{
    public function __construct(
        private readonly float $monthlyRate,
    ) {}

    public function calculate(float $basePrice, int $quantity): float
    {
        // Subscription ignores quantity — flat monthly rate
        return $this->monthlyRate;
    }

    public function name(): string
    {
        return 'subscription';
    }
}

// Context class
namespace App\Services;

use App\Contracts\PricingStrategy;

class PricingCalculator
{
    public function __construct(
        private PricingStrategy $strategy,
    ) {}

    public function setStrategy(PricingStrategy $strategy): void
    {
        $this->strategy = $strategy;
    }

    public function calculateTotal(float $basePrice, int $quantity): float
    {
        return round($this->strategy->calculate($basePrice, $quantity), 2);
    }

    public function getStrategyName(): string
    {
        return $this->strategy->name();
    }
}

// Usage
$calculator = new PricingCalculator(new StandardPricing());

// Switch strategy based on customer type
$strategy = match ($customer->pricing_tier) {
    'bulk' => new BulkDiscountPricing(),
    'subscription' => new SubscriptionPricing($customer->monthly_rate),
    default => new StandardPricing(),
};

$calculator->setStrategy($strategy);
$total = $calculator->calculateTotal(basePrice: 100.00, quantity: 50);
```

**Pest test:**

```php
use App\Strategies\Pricing\StandardPricing;
use App\Strategies\Pricing\BulkDiscountPricing;
use App\Services\PricingCalculator;

it('calculates standard pricing', function () {
    $calculator = new PricingCalculator(new StandardPricing());

    expect($calculator->calculateTotal(100, 5))->toBe(500.00);
});

it('applies bulk discount at 50 units', function () {
    $calculator = new PricingCalculator(new BulkDiscountPricing());

    // 50 units = 15% discount: 100 * 50 * 0.85 = 4250
    expect($calculator->calculateTotal(100, 50))->toBe(4250.00);
});

it('applies bulk discount at 100 units', function () {
    $calculator = new PricingCalculator(new BulkDiscountPricing());

    // 100 units = 20% discount: 100 * 100 * 0.80 = 8000
    expect($calculator->calculateTotal(100, 100))->toBe(8000.00);
});
```

---

### Observer Pattern (Events & Listeners)

**When to use:** When something happens and multiple parts of the system need to react,
but the thing that happened shouldn't know about all the reactors.

**Laravel context:** Laravel Events + Listeners. Use when side effects (email, log, cache
invalidation, webhook) should happen after an action but not block it.

```php
// Event
namespace App\Events;

use App\Models\Order;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class OrderCompleted
{
    use Dispatchable, SerializesModels;

    public function __construct(
        public readonly Order $order,
    ) {}
}

// Listener — send confirmation email
namespace App\Listeners;

use App\Events\OrderCompleted;
use App\Mail\OrderConfirmation;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Mail;

class SendOrderConfirmationEmail implements ShouldQueue
{
    public function handle(OrderCompleted $event): void
    {
        Mail::to($event->order->customer->email)
            ->send(new OrderConfirmation($event->order));
    }
}

// Listener — update inventory
namespace App\Listeners;

use App\Events\OrderCompleted;
use Illuminate\Contracts\Queue\ShouldQueue;

class DeductInventory implements ShouldQueue
{
    public function handle(OrderCompleted $event): void
    {
        foreach ($event->order->items as $item) {
            $item->product->decrement('stock', $item->quantity);
        }
    }
}

// Listener — notify warehouse
namespace App\Listeners;

use App\Events\OrderCompleted;
use App\Notifications\NewOrderForWarehouse;
use Illuminate\Contracts\Queue\ShouldQueue;

class NotifyWarehouse implements ShouldQueue
{
    public function handle(OrderCompleted $event): void
    {
        $event->order->warehouse->notify(new NewOrderForWarehouse($event->order));
    }
}

// EventServiceProvider
protected $listen = [
    OrderCompleted::class => [
        SendOrderConfirmationEmail::class,
        DeductInventory::class,
        NotifyWarehouse::class,
    ],
];

// Dispatch from action
class CompleteOrderAction
{
    public function execute(Order $order): Order
    {
        $order->update(['status' => 'completed', 'completed_at' => now()]);

        event(new OrderCompleted($order));

        return $order;
    }
}
```

---

### Pipeline Pattern

**When to use:** Sequential processing where each stage transforms or validates data,
and stages should be independently testable and reorderable.

**Laravel context:** Laravel's `Pipeline` class. Great for multi-step data processing,
import pipelines, approval workflows.

```php
// Pipeline stages — each is an invokable class
namespace App\Pipelines\Import;

use Closure;

class ValidateHeaders
{
    public function handle(ImportContext $context, Closure $next): mixed
    {
        $required = ['name', 'email', 'phone'];
        $headers = $context->headers;

        $missing = array_diff($required, $headers);

        if (! empty($missing)) {
            $context->addError('Missing required headers: ' . implode(', ', $missing));

            return $context; // Stop pipeline
        }

        return $next($context);
    }
}

class NormalizeData
{
    public function handle(ImportContext $context, Closure $next): mixed
    {
        $context->rows = collect($context->rows)->map(function ($row) {
            return [
                'name' => trim($row['name']),
                'email' => strtolower(trim($row['email'])),
                'phone' => preg_replace('/[^0-9+]/', '', $row['phone']),
            ];
        })->toArray();

        return $next($context);
    }
}

class DeduplicateRows
{
    public function handle(ImportContext $context, Closure $next): mixed
    {
        $seen = [];
        $unique = [];

        foreach ($context->rows as $row) {
            $key = $row['email'];
            if (! isset($seen[$key])) {
                $seen[$key] = true;
                $unique[] = $row;
            } else {
                $context->addWarning("Duplicate skipped: {$row['email']}");
            }
        }

        $context->rows = $unique;

        return $next($context);
    }
}

class PersistToDatabase
{
    public function handle(ImportContext $context, Closure $next): mixed
    {
        foreach ($context->rows as $row) {
            Contact::updateOrCreate(
                ['email' => $row['email']],
                $row,
            );
        }

        $context->imported = count($context->rows);

        return $next($context);
    }
}

// Context object passed through pipeline
namespace App\Pipelines\Import;

class ImportContext
{
    public array $rows = [];
    public array $headers = [];
    public int $imported = 0;
    public array $errors = [];
    public array $warnings = [];

    public function addError(string $message): void
    {
        $this->errors[] = $message;
    }

    public function addWarning(string $message): void
    {
        $this->warnings[] = $message;
    }

    public function hasErrors(): bool
    {
        return ! empty($this->errors);
    }
}

// Usage with Laravel Pipeline
use Illuminate\Support\Facades\Pipeline;

$context = new ImportContext();
$context->headers = array_keys($csvData[0]);
$context->rows = $csvData;

$result = Pipeline::send($context)
    ->through([
        ValidateHeaders::class,
        NormalizeData::class,
        DeduplicateRows::class,
        PersistToDatabase::class,
    ])
    ->thenReturn();

if ($result->hasErrors()) {
    // Handle errors
}

echo "Imported: {$result->imported}";
```

---

### Command Pattern (Jobs & Actions)

**When to use:** Encapsulate a request or operation as an object. Allows queuing,
logging, undoing operations.

**Laravel context:** Jobs (queued commands), Action classes (synchronous commands).

```php
// As a Laravel Job (queued command)
namespace App\Jobs;

use App\Models\Invoice;
use App\Services\PdfGenerator;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class GenerateInvoicePdf implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;

    public function __construct(
        public readonly Invoice $invoice,
    ) {}

    public function handle(PdfGenerator $generator): void
    {
        $pdf = $generator->fromView('invoices.pdf', [
            'invoice' => $this->invoice->load('items', 'customer'),
        ]);

        $this->invoice->update([
            'pdf_path' => $pdf->store('invoices', 'private'),
            'pdf_generated_at' => now(),
        ]);
    }

    public function failed(\Throwable $exception): void
    {
        $this->invoice->update(['pdf_error' => $exception->getMessage()]);
    }
}

// Dispatch
GenerateInvoicePdf::dispatch($invoice)->onQueue('pdf');
```

---

### State Machine Pattern

**When to use:** An object's behaviour changes based on its internal state, and
transitions between states follow specific rules.

**Laravel context:** Order status, approval workflows, subscription lifecycle,
document publishing flow.

```php
// State interface
namespace App\StateMachines;

use App\Models\Order;

interface OrderState
{
    public function canTransitionTo(string $state): bool;

    public function process(Order $order): void;

    public function cancel(Order $order): void;

    public function complete(Order $order): void;

    public function name(): string;
}

// Concrete states
namespace App\StateMachines\OrderStates;

use App\Models\Order;
use App\StateMachines\OrderState;

class PendingState implements OrderState
{
    public function canTransitionTo(string $state): bool
    {
        return in_array($state, ['processing', 'cancelled']);
    }

    public function process(Order $order): void
    {
        $order->update([
            'status' => 'processing',
            'processed_at' => now(),
        ]);
    }

    public function cancel(Order $order): void
    {
        $order->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);
    }

    public function complete(Order $order): void
    {
        throw new \LogicException('Cannot complete a pending order. Process it first.');
    }

    public function name(): string
    {
        return 'pending';
    }
}

class ProcessingState implements OrderState
{
    public function canTransitionTo(string $state): bool
    {
        return in_array($state, ['completed', 'cancelled']);
    }

    public function process(Order $order): void
    {
        throw new \LogicException('Order is already being processed.');
    }

    public function cancel(Order $order): void
    {
        $order->update([
            'status' => 'cancelled',
            'cancelled_at' => now(),
        ]);

        // Reverse any processing side effects
        event(new OrderCancelled($order));
    }

    public function complete(Order $order): void
    {
        $order->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        event(new OrderCompleted($order));
    }

    public function name(): string
    {
        return 'processing';
    }
}

class CompletedState implements OrderState
{
    public function canTransitionTo(string $state): bool
    {
        return false; // Terminal state
    }

    public function process(Order $order): void
    {
        throw new \LogicException('Completed orders cannot be reprocessed.');
    }

    public function cancel(Order $order): void
    {
        throw new \LogicException('Completed orders cannot be cancelled. Issue a refund instead.');
    }

    public function complete(Order $order): void
    {
        throw new \LogicException('Order is already completed.');
    }

    public function name(): string
    {
        return 'completed';
    }
}

class CancelledState implements OrderState
{
    public function canTransitionTo(string $state): bool
    {
        return false; // Terminal state
    }

    public function process(Order $order): void
    {
        throw new \LogicException('Cancelled orders cannot be processed.');
    }

    public function cancel(Order $order): void
    {
        throw new \LogicException('Order is already cancelled.');
    }

    public function complete(Order $order): void
    {
        throw new \LogicException('Cancelled orders cannot be completed.');
    }

    public function name(): string
    {
        return 'cancelled';
    }
}

// State resolver — maps status string to state object
namespace App\StateMachines;

class OrderStateResolver
{
    public static function resolve(string $status): OrderState
    {
        return match ($status) {
            'pending' => new OrderStates\PendingState(),
            'processing' => new OrderStates\ProcessingState(),
            'completed' => new OrderStates\CompletedState(),
            'cancelled' => new OrderStates\CancelledState(),
            default => throw new \InvalidArgumentException("Unknown order status: {$status}"),
        };
    }
}

// Usage on the model
class Order extends Model
{
    public function state(): OrderState
    {
        return OrderStateResolver::resolve($this->status);
    }

    public function process(): void
    {
        $this->state()->process($this);
    }

    public function cancel(): void
    {
        $this->state()->cancel($this);
    }

    public function complete(): void
    {
        $this->state()->complete($this);
    }
}

// Usage
$order = Order::find(1); // status = 'pending'
$order->process();       // status → 'processing'
$order->complete();      // status → 'completed'
$order->cancel();        // throws LogicException
```

**Pest test:**

```php
use App\Models\Order;

it('transitions from pending to processing', function () {
    $order = Order::factory()->create(['status' => 'pending']);

    $order->process();

    expect($order->fresh()->status)->toBe('processing');
});

it('transitions from processing to completed', function () {
    $order = Order::factory()->create(['status' => 'processing']);

    $order->complete();

    expect($order->fresh()->status)->toBe('completed');
});

it('prevents completing a pending order', function () {
    $order = Order::factory()->create(['status' => 'pending']);

    $order->complete();
})->throws(\LogicException::class, 'Cannot complete a pending order');

it('prevents cancelling a completed order', function () {
    $order = Order::factory()->create(['status' => 'completed']);

    $order->cancel();
})->throws(\LogicException::class, 'Issue a refund instead');
```
