# Refactoring Catalog

Step-by-step refactoring patterns with before/after PHP code examples. Use this reference
when applying `/php refactor` or suggesting improvements during `/php review`.

---

## Extract Method

**When:** A method is too long, or a code fragment can be grouped together with a descriptive name.

**Heuristic:** Method exceeds 20 lines, or you see a comment explaining what a block does
(the comment should be the method name instead).

```php
// BEFORE
class InvoiceService
{
    public function generateInvoice(Order $order): Invoice
    {
        // Calculate totals
        $subtotal = 0;
        foreach ($order->items as $item) {
            $subtotal += $item->price * $item->quantity;
            if ($item->discount > 0) {
                $subtotal -= $item->price * $item->quantity * ($item->discount / 100);
            }
        }
        $tax = $subtotal * 0.08;
        $total = $subtotal + $tax;

        // Build line items
        $lineItems = [];
        foreach ($order->items as $item) {
            $lineItems[] = new LineItem(
                description: $item->name,
                quantity: $item->quantity,
                unitPrice: $item->price,
                discount: $item->discount,
                total: $item->price * $item->quantity * (1 - $item->discount / 100),
            );
        }

        // Create invoice
        $invoice = new Invoice(
            number: $this->generateInvoiceNumber(),
            date: now(),
            lineItems: $lineItems,
            subtotal: $subtotal,
            tax: $tax,
            total: $total,
        );

        // Send notification
        Mail::to($order->customer->email)->send(new InvoiceGenerated($invoice));
        event(new InvoiceCreated($invoice));

        return $invoice;
    }
}
```

```php
// AFTER — each block becomes a focused method
class InvoiceService
{
    public function generateInvoice(Order $order): Invoice
    {
        $subtotal = $this->calculateSubtotal($order);
        $tax = $this->calculateTax($subtotal);
        $lineItems = $this->buildLineItems($order);

        $invoice = new Invoice(
            number: $this->generateInvoiceNumber(),
            date: now(),
            lineItems: $lineItems,
            subtotal: $subtotal,
            tax: $tax,
            total: $subtotal + $tax,
        );

        $this->notifyCustomer($order->customer, $invoice);

        return $invoice;
    }

    private function calculateSubtotal(Order $order): float
    {
        return collect($order->items)->sum(function (OrderItem $item): float {
            $lineTotal = $item->price * $item->quantity;
            return $lineTotal * (1 - $item->discount / 100);
        });
    }

    private function calculateTax(float $subtotal): float
    {
        return $subtotal * 0.08;
    }

    private function buildLineItems(Order $order): array
    {
        return collect($order->items)->map(fn (OrderItem $item) => new LineItem(
            description: $item->name,
            quantity: $item->quantity,
            unitPrice: $item->price,
            discount: $item->discount,
            total: $item->price * $item->quantity * (1 - $item->discount / 100),
        ))->all();
    }

    private function notifyCustomer(Customer $customer, Invoice $invoice): void
    {
        Mail::to($customer->email)->send(new InvoiceGenerated($invoice));
        event(new InvoiceCreated($invoice));
    }
}
```

---

## Extract Class

**When:** A class has too many responsibilities, or a group of fields/methods naturally belong together.

**Heuristic:** Class exceeds 300 lines, or you can identify a coherent subset of fields that
are always used together.

```php
// BEFORE — User class doing too much
class User extends Model
{
    public function getFullName(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    public function getInitials(): string
    {
        return strtoupper($this->first_name[0] . $this->last_name[0]);
    }

    public function getFullAddress(): string
    {
        return implode(', ', array_filter([
            $this->address_line_1,
            $this->address_line_2,
            $this->city,
            $this->state,
            $this->postcode,
            $this->country,
        ]));
    }

    public function isInState(string $state): bool
    {
        return $this->state === $state;
    }

    public function calculateShippingZone(): string
    {
        return match ($this->state) {
            'Sabah', 'Sarawak' => 'east_malaysia',
            default => 'west_malaysia',
        };
    }

    public function formatPostcode(): string
    {
        return str_pad($this->postcode, 5, '0', STR_PAD_LEFT);
    }
}
```

```php
// AFTER — address concerns extracted to a value object
readonly class Address
{
    public function __construct(
        public string $line1,
        public ?string $line2,
        public string $city,
        public string $state,
        public string $postcode,
        public string $country = 'Malaysia',
    ) {}

    public function full(): string
    {
        return implode(', ', array_filter([
            $this->line1,
            $this->line2,
            $this->city,
            $this->state,
            $this->formattedPostcode(),
            $this->country,
        ]));
    }

    public function isInState(string $state): bool
    {
        return $this->state === $state;
    }

    public function shippingZone(): string
    {
        return match ($this->state) {
            'Sabah', 'Sarawak' => 'east_malaysia',
            default => 'west_malaysia',
        };
    }

    public function formattedPostcode(): string
    {
        return str_pad($this->postcode, 5, '0', STR_PAD_LEFT);
    }
}

class User extends Model
{
    public function getFullName(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }

    public function getInitials(): string
    {
        return strtoupper($this->first_name[0] . $this->last_name[0]);
    }

    public function address(): Address
    {
        return new Address(
            line1: $this->address_line_1,
            line2: $this->address_line_2,
            city: $this->city,
            state: $this->state,
            postcode: $this->postcode,
            country: $this->country,
        );
    }
}
```

---

## Introduce Parameter Object

**When:** Three or more parameters are frequently passed together, or a method has too many
parameters making it hard to read.

```php
// BEFORE — loose parameters passed everywhere
class ReportGenerator
{
    public function generate(
        string $startDate,
        string $endDate,
        string $format,
        bool $includeCharts,
        ?string $title,
        ?string $subtitle,
    ): Report {
        $this->validate($startDate, $endDate);
        $data = $this->fetchData($startDate, $endDate);
        return $this->buildReport($data, $format, $includeCharts, $title, $subtitle);
    }

    private function validate(string $startDate, string $endDate): void { /* ... */ }
    private function fetchData(string $startDate, string $endDate): array { /* ... */ }
    private function buildReport(
        array $data,
        string $format,
        bool $includeCharts,
        ?string $title,
        ?string $subtitle,
    ): Report { /* ... */ }
}
```

```php
// AFTER — parameter object encapsulates related data
readonly class ReportConfig
{
    public function __construct(
        public CarbonImmutable $startDate,
        public CarbonImmutable $endDate,
        public ReportFormat $format = ReportFormat::Pdf,
        public bool $includeCharts = false,
        public ?string $title = null,
        public ?string $subtitle = null,
    ) {}

    public function dateRange(): string
    {
        return "{$this->startDate->format('Y-m-d')} to {$this->endDate->format('Y-m-d')}";
    }

    public function validate(): void
    {
        if ($this->startDate->isAfter($this->endDate)) {
            throw new InvalidArgumentException('Start date must be before end date');
        }
    }
}

class ReportGenerator
{
    public function generate(ReportConfig $config): Report
    {
        $config->validate();
        $data = $this->fetchData($config);
        return $this->buildReport($data, $config);
    }

    private function fetchData(ReportConfig $config): array { /* ... */ }
    private function buildReport(array $data, ReportConfig $config): Report { /* ... */ }
}
```

---

## Replace Conditional with Polymorphism

**When:** A switch/if-else chain checks a type field and performs different behavior based on it.

```php
// BEFORE — switch on type in multiple places
class NotificationService
{
    public function send(Notification $notification): void
    {
        switch ($notification->type) {
            case 'email':
                $this->mailer->send(
                    $notification->recipient,
                    $notification->subject,
                    $notification->body,
                );
                break;
            case 'sms':
                $this->smsGateway->sendMessage(
                    $notification->phone,
                    $notification->body,
                );
                break;
            case 'push':
                $this->pushService->notify(
                    $notification->deviceToken,
                    $notification->title,
                    $notification->body,
                );
                break;
            case 'webhook':
                Http::post($notification->webhookUrl, [
                    'event' => $notification->event,
                    'payload' => $notification->body,
                ]);
                break;
            default:
                throw new UnsupportedNotificationTypeException($notification->type);
        }
    }

    public function getIcon(Notification $notification): string
    {
        return match ($notification->type) {
            'email' => 'mail',
            'sms' => 'message-square',
            'push' => 'bell',
            'webhook' => 'globe',
        };
    }
}
```

```php
// AFTER — polymorphism via interface
interface NotificationChannel
{
    public function send(): void;
    public function icon(): string;
}

readonly class EmailNotification implements NotificationChannel
{
    public function __construct(
        private Mailer $mailer,
        public string $recipient,
        public string $subject,
        public string $body,
    ) {}

    public function send(): void
    {
        $this->mailer->send($this->recipient, $this->subject, $this->body);
    }

    public function icon(): string
    {
        return 'mail';
    }
}

readonly class SmsNotification implements NotificationChannel
{
    public function __construct(
        private SmsGateway $gateway,
        public string $phone,
        public string $body,
    ) {}

    public function send(): void
    {
        $this->gateway->sendMessage($this->phone, $this->body);
    }

    public function icon(): string
    {
        return 'message-square';
    }
}

readonly class PushNotification implements NotificationChannel
{
    public function __construct(
        private PushService $pushService,
        public string $deviceToken,
        public string $title,
        public string $body,
    ) {}

    public function send(): void
    {
        $this->pushService->notify($this->deviceToken, $this->title, $this->body);
    }

    public function icon(): string
    {
        return 'bell';
    }
}

// Usage — no switch needed
class NotificationService
{
    public function send(NotificationChannel $notification): void
    {
        $notification->send();
    }
}
```

---

## Move Method

**When:** A method uses data from another class more than from its own class (feature envy).

```php
// BEFORE — OrderService calculates discount using only Product data
class OrderService
{
    public function calculateDiscount(Product $product, int $quantity): float
    {
        if ($product->category === 'electronics' && $quantity >= 5) {
            return $product->price * $quantity * 0.10;
        }

        if ($product->category === 'books' && $quantity >= 10) {
            return $product->price * $quantity * 0.15;
        }

        if ($product->isOnSale && $quantity >= 3) {
            return $product->price * $quantity * $product->saleDiscount;
        }

        return 0;
    }
}
```

```php
// AFTER — discount logic lives on Product where the data is
class Product
{
    // ... existing properties ...

    public function calculateDiscount(int $quantity): float
    {
        if ($this->category === 'electronics' && $quantity >= 5) {
            return $this->price * $quantity * 0.10;
        }

        if ($this->category === 'books' && $quantity >= 10) {
            return $this->price * $quantity * 0.15;
        }

        if ($this->isOnSale && $quantity >= 3) {
            return $this->price * $quantity * $this->saleDiscount;
        }

        return 0;
    }
}

// OrderService delegates to Product
class OrderService
{
    public function calculateOrderDiscount(Order $order): float
    {
        return collect($order->items)->sum(
            fn (OrderItem $item) => $item->product->calculateDiscount($item->quantity)
        );
    }
}
```

---

## Inline Temp

**When:** A temporary variable is assigned once and only used as a simple reference to an expression.
The expression itself is just as clear.

```php
// BEFORE — unnecessary temp variable
public function isEligibleForDiscount(Order $order): bool
{
    $basePrice = $order->getBasePrice();
    return $basePrice > 1000;
}
```

```php
// AFTER — inline the expression
public function isEligibleForDiscount(Order $order): bool
{
    return $order->getBasePrice() > 1000;
}
```

**Do NOT inline** when:
- The variable name adds meaning that the expression does not convey
- The expression is complex or called multiple times
- Inlining would make the line too long

```php
// KEEP the temp — it adds clarity
$isHighValueMalaysianCustomer = $customer->country === 'MY' && $customer->totalSpent > 50000;
if ($isHighValueMalaysianCustomer) {
    $this->applyVipDiscount($order);
}
```

---

## Replace Inheritance with Composition

**When:** A subclass only uses a fraction of the parent's behavior, or the inheritance
hierarchy is becoming deep and rigid.

```php
// BEFORE — awkward inheritance
class LoggableService extends BaseService
{
    // BaseService has: log(), cache(), validateInput(), sendNotification()
    // LoggableService only needs log()

    public function processOrder(Order $order): void
    {
        $this->log("Processing order {$order->id}");
        // ... business logic ...
        $this->log("Order {$order->id} processed");
    }
}

class CachedRepository extends BaseService
{
    // Also extends BaseService just for cache()
    public function findUser(int $id): ?User
    {
        return $this->cache("user.{$id}", fn () => User::find($id));
    }
}
```

```php
// AFTER — composition via dependency injection
readonly class OrderProcessor
{
    public function __construct(
        private Logger $logger,
    ) {}

    public function processOrder(Order $order): void
    {
        $this->logger->info("Processing order {$order->id}");
        // ... business logic ...
        $this->logger->info("Order {$order->id} processed");
    }
}

readonly class UserRepository
{
    public function __construct(
        private CacheManager $cache,
    ) {}

    public function find(int $id): ?User
    {
        return $this->cache->remember("user.{$id}", fn () => User::find($id));
    }
}
```

---

## Decompose Fat Controller (Laravel-Specific)

**When:** A Laravel controller method handles validation, business logic, side effects,
and response formatting all in one place.

```php
// BEFORE — fat controller
class OrderController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        // Validation
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'shipping_address' => 'required|string',
            'payment_method' => 'required|in:credit_card,bank_transfer,ewallet',
        ]);

        // Business logic
        $product = Product::findOrFail($validated['product_id']);

        if ($product->stock < $validated['quantity']) {
            return response()->json(['error' => 'Insufficient stock'], 422);
        }

        $order = new Order();
        $order->user_id = auth()->id();
        $order->product_id = $product->id;
        $order->quantity = $validated['quantity'];
        $order->unit_price = $product->price;
        $order->total = $product->price * $validated['quantity'];
        $order->shipping_address = $validated['shipping_address'];
        $order->payment_method = $validated['payment_method'];
        $order->status = 'pending';
        $order->save();

        $product->decrement('stock', $validated['quantity']);

        // Side effects
        Mail::to(auth()->user()->email)->send(new OrderConfirmation($order));
        event(new OrderPlaced($order));

        // Response
        return response()->json([
            'id' => $order->id,
            'total' => $order->total,
            'status' => $order->status,
            'created_at' => $order->created_at->toISOString(),
        ], 201);
    }
}
```

```php
// AFTER — decomposed into focused classes

// 1. Form Request — validation
class StoreOrderRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'product_id' => ['required', 'exists:products,id'],
            'quantity' => ['required', 'integer', 'min:1'],
            'shipping_address' => ['required', 'string'],
            'payment_method' => ['required', new Enum(PaymentMethod::class)],
        ];
    }
}

// 2. Action — business logic
class PlaceOrderAction
{
    public function execute(User $user, StoreOrderRequest $request): Order
    {
        $product = Product::findOrFail($request->validated('product_id'));
        $quantity = $request->validated('quantity');

        if ($product->stock < $quantity) {
            throw new InsufficientStockException($product, $quantity);
        }

        return DB::transaction(function () use ($user, $product, $quantity, $request) {
            $order = Order::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'quantity' => $quantity,
                'unit_price' => $product->price,
                'total' => $product->price * $quantity,
                'shipping_address' => $request->validated('shipping_address'),
                'payment_method' => PaymentMethod::from($request->validated('payment_method')),
                'status' => OrderStatus::Pending,
            ]);

            $product->decrement('stock', $quantity);

            event(new OrderPlaced($order));

            return $order;
        });
    }
}

// 3. API Resource — response formatting
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'total' => $this->total,
            'status' => $this->status->value,
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}

// 4. Listener — side effects (registered in EventServiceProvider)
class SendOrderConfirmationEmail implements ShouldQueue
{
    public function handle(OrderPlaced $event): void
    {
        Mail::to($event->order->user->email)
            ->send(new OrderConfirmation($event->order));
    }
}

// 5. Slim controller — orchestration only
class OrderController extends Controller
{
    public function store(StoreOrderRequest $request, PlaceOrderAction $action): OrderResource
    {
        $order = $action->execute($request->user(), $request);

        return new OrderResource($order);
    }
}
```

---

## Refactoring Decision Guide

Use this decision tree when reviewing code:

1. **Is the method too long?** (>20 lines) -> Extract Method
2. **Is the class too large?** (>300 lines) -> Extract Class
3. **Are params always passed together?** (3+ related params) -> Introduce Parameter Object
4. **Is there a switch/if on a type field?** -> Replace Conditional with Polymorphism
5. **Does a method envy another class's data?** -> Move Method
6. **Is inheritance used just to share a few methods?** -> Replace Inheritance with Composition
7. **Is it a fat controller?** -> Decompose Fat Controller
8. **Is a temp variable used only once trivially?** -> Inline Temp
