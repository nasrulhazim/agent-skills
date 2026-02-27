# PHP 8.2+ Features Reference

Comprehensive catalog of PHP 8.2+ features with before/after examples. Use this reference
when modernizing legacy PHP code or explaining new language features.

---

## Enums

Enums replace loose constants and stringly-typed status values with type-safe, IDE-friendly
enumerations.

### Basic Enum

```php
// BEFORE — string constants scattered everywhere
class Order
{
    const STATUS_PENDING = 'pending';
    const STATUS_PROCESSING = 'processing';
    const STATUS_SHIPPED = 'shipped';
    const STATUS_DELIVERED = 'delivered';
    const STATUS_CANCELLED = 'cancelled';

    public string $status;

    public function setStatus(string $status): void
    {
        $this->status = $status; // no validation, any string accepted
    }
}

$order->setStatus('pendiing'); // typo — silently accepted
```

```php
// AFTER — backed enum with type safety
enum OrderStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';
}

class Order
{
    public OrderStatus $status;

    public function setStatus(OrderStatus $status): void
    {
        $this->status = $status;
    }
}

$order->setStatus(OrderStatus::Pending); // type-safe, IDE autocomplete
```

### Enum with Methods

```php
enum OrderStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::Pending => 'Awaiting Processing',
            self::Processing => 'Being Prepared',
            self::Shipped => 'On the Way',
            self::Delivered => 'Delivered',
            self::Cancelled => 'Cancelled',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::Pending => 'yellow',
            self::Processing => 'blue',
            self::Shipped => 'indigo',
            self::Delivered => 'green',
            self::Cancelled => 'red',
        };
    }

    public function canTransitionTo(self $next): bool
    {
        return match ($this) {
            self::Pending => in_array($next, [self::Processing, self::Cancelled]),
            self::Processing => in_array($next, [self::Shipped, self::Cancelled]),
            self::Shipped => $next === self::Delivered,
            self::Delivered, self::Cancelled => false,
        };
    }
}
```

### Enum Implementing Interface

```php
interface HasLabel
{
    public function label(): string;
}

enum PaymentMethod: string implements HasLabel
{
    case CreditCard = 'credit_card';
    case BankTransfer = 'bank_transfer';
    case Ewallet = 'ewallet';

    public function label(): string
    {
        return match ($this) {
            self::CreditCard => 'Credit Card',
            self::BankTransfer => 'Bank Transfer',
            self::Ewallet => 'E-Wallet',
        };
    }
}
```

---

## Readonly Properties

Properties that are set once (typically in the constructor) and never mutated.

```php
// BEFORE — manual immutability with private + getter
class Money
{
    private int $amount;
    private string $currency;

    public function __construct(int $amount, string $currency)
    {
        $this->amount = $amount;
        $this->currency = $currency;
    }

    public function getAmount(): int
    {
        return $this->amount;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }
}
```

```php
// AFTER — readonly with constructor promotion
class Money
{
    public function __construct(
        public readonly int $amount,
        public readonly string $currency,
    ) {}
}

$price = new Money(2500, 'MYR');
echo $price->amount;    // 2500 — direct access, no getter needed
$price->amount = 3000;  // Error: Cannot modify readonly property
```

---

## Readonly Classes

When ALL properties in a class are readonly, promote the entire class to readonly.

```php
// BEFORE — readonly on each property
class UserDTO
{
    public function __construct(
        public readonly string $name,
        public readonly string $email,
        public readonly int $age,
    ) {}
}
```

```php
// AFTER — readonly class (PHP 8.2)
readonly class UserDTO
{
    public function __construct(
        public string $name,
        public string $email,
        public int $age,
    ) {}
}
```

---

## Fibers

Cooperative multitasking — suspend and resume execution without callbacks or promises.

```php
// BEFORE — nested callbacks / promise chains
function fetchUserAndOrders(int $userId, callable $callback): void
{
    fetchUser($userId, function (User $user) use ($callback) {
        fetchOrders($user->id, function (array $orders) use ($user, $callback) {
            $callback($user, $orders);
        });
    });
}
```

```php
// AFTER — fibers for sequential-looking async code
$fiber = new Fiber(function (): void {
    $userId = 42;

    // Suspend to let the event loop fetch data
    $user = Fiber::suspend(['action' => 'fetch_user', 'id' => $userId]);
    $orders = Fiber::suspend(['action' => 'fetch_orders', 'user_id' => $user->id]);

    echo "User {$user->name} has " . count($orders) . " orders.";
});

// Start the fiber
$request = $fiber->start();

// Event loop handles the actual I/O
while ($fiber->isSuspended()) {
    $result = performIO($request); // your I/O implementation
    $request = $fiber->resume($result);
}
```

---

## Named Arguments

Improve readability for functions with many parameters, optional parameters, or boolean flags.

```php
// BEFORE — positional arguments, unclear meaning
$user = new User('Ahmad', 'ahmad@example.com', null, true, false, 'Asia/Kuala_Lumpur');

setcookie('session', $value, 0, '/', '', true, true);

array_slice($array, 0, 5, true);
```

```php
// AFTER — named arguments, self-documenting
$user = new User(
    name: 'Ahmad',
    email: 'ahmad@example.com',
    phone: null,
    isAdmin: true,
    isVerified: false,
    timezone: 'Asia/Kuala_Lumpur',
);

setcookie(
    name: 'session',
    value: $value,
    path: '/',
    secure: true,
    httponly: true,
);

array_slice($array, offset: 0, length: 5, preserve_keys: true);
```

---

## Match Expressions

Replace switch statements that return/assign values. Match is an expression (returns a value),
uses strict comparison, and throws on no match.

```php
// BEFORE — switch with return
function getStatusLabel(string $status): string
{
    switch ($status) {
        case 'pending':
            return 'Pending Review';
        case 'approved':
            return 'Approved';
        case 'rejected':
            return 'Rejected';
        default:
            throw new InvalidArgumentException("Unknown status: {$status}");
    }
}
```

```php
// AFTER — match expression
function getStatusLabel(string $status): string
{
    return match ($status) {
        'pending' => 'Pending Review',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        default => throw new InvalidArgumentException("Unknown status: {$status}"),
    };
}
```

### Match with Multiple Conditions

```php
function getHttpCategory(int $code): string
{
    return match (true) {
        $code >= 200 && $code < 300 => 'Success',
        $code >= 300 && $code < 400 => 'Redirect',
        $code >= 400 && $code < 500 => 'Client Error',
        $code >= 500 => 'Server Error',
        default => 'Unknown',
    };
}
```

---

## Null-Safe Operator

Chain method calls without null checks at each step. Short-circuits to null if any part is null.

```php
// BEFORE — defensive null checking
$country = null;
if ($user !== null) {
    $address = $user->getAddress();
    if ($address !== null) {
        $city = $address->getCity();
        if ($city !== null) {
            $country = $city->getCountry();
        }
    }
}
```

```php
// AFTER — null-safe operator
$country = $user?->getAddress()?->getCity()?->getCountry();
```

### Combined with Null Coalescing

```php
$countryName = $user?->getAddress()?->getCity()?->getCountry()?->getName() ?? 'Unknown';
```

---

## Intersection Types

A value must satisfy ALL listed types simultaneously. Useful for dependency injection where
you need an object that implements multiple interfaces.

```php
// BEFORE — PHPDoc only, no runtime enforcement
/**
 * @param Countable&Iterator $collection
 */
function processCollection($collection): void
{
    foreach ($collection as $item) {
        // works because it's Iterator
    }
    echo count($collection); // works because it's Countable
}
```

```php
// AFTER — intersection types with runtime enforcement
function processCollection(Countable&Iterator $collection): void
{
    foreach ($collection as $item) {
        // guaranteed Iterator
    }
    echo count($collection); // guaranteed Countable
}
```

---

## DNF Types (Disjunctive Normal Form)

Combine union and intersection types. Each group in parentheses is an intersection; groups
are separated by `|` (union).

```php
// Accept either (Countable AND Iterator) OR null
function processOrSkip((Countable&Iterator)|null $collection): int
{
    if ($collection === null) {
        return 0;
    }

    $count = 0;
    foreach ($collection as $item) {
        $count++;
    }

    return $count;
}
```

```php
// Accept (Stringable AND JsonSerializable) OR string
function toJson((Stringable&JsonSerializable)|string $value): string
{
    if (is_string($value)) {
        return json_encode($value);
    }

    return json_encode($value->jsonSerialize());
}
```

---

## First-Class Callable Syntax

Create closures from functions and methods using a cleaner syntax.

```php
// BEFORE — Closure::fromCallable or array syntax
$fn = Closure::fromCallable('strlen');
$fn = Closure::fromCallable([$this, 'process']);
$fn = Closure::fromCallable([self::class, 'staticMethod']);

$lengths = array_map(function (string $s): int {
    return strlen($s);
}, $strings);
```

```php
// AFTER — first-class callable syntax
$fn = strlen(...);
$fn = $this->process(...);
$fn = self::staticMethod(...);

$lengths = array_map(strlen(...), $strings);
```

### In Laravel Context

```php
// BEFORE
$users->map(function (User $user): string {
    return $user->getFullName();
});

Route::middleware(Closure::fromCallable([$this, 'authenticate']));
```

```php
// AFTER
$users->map(fn (User $user): string => $user->getFullName());

// or for simple method calls in collection pipelines:
$names = $users->map->getFullName();
```

---

## Constants in Traits

PHP 8.2 allows traits to define constants.

```php
// BEFORE — constants had to be in the class or interface
trait HasVersion
{
    // Could not define constants here before PHP 8.2
}

class Plugin
{
    use HasVersion;

    const VERSION = '1.0.0'; // had to be in the class
}
```

```php
// AFTER — constants in traits (PHP 8.2)
trait HasVersion
{
    const VERSION = '1.0.0';

    public function getVersion(): string
    {
        return self::VERSION;
    }
}

class Plugin
{
    use HasVersion;
}

echo Plugin::VERSION; // '1.0.0'
```

---

## Migration Strategy

When modernizing a codebase, apply features in this order:

1. **Strict types** — add `declare(strict_types=1)` to all files
2. **Type declarations** — parameters, return types, properties
3. **Readonly properties** — immutable data, DTOs, value objects
4. **Enums** — replace string/int constants used for state
5. **Match expressions** — replace simple switch statements
6. **Named arguments** — constructors with many params, config arrays
7. **Null-safe operator** — deep null-check chains
8. **First-class callables** — clean up Closure::fromCallable calls
9. **Intersection/DNF types** — complex type constraints
10. **Readonly classes** — promote classes where all properties are readonly
