# Code Smell Catalog

Detection heuristics and remedies for common PHP code smells. Use this reference when
performing `/php review` to identify and fix quality issues.

---

## Long Method

A method that tries to do too much. Hard to understand, test, and maintain.

### Detection Heuristics

- Method body exceeds 20 lines of logic (excluding blank lines and comments)
- Method has more than 2 levels of indentation
- You see comments separating "sections" within the method
- Method name includes "and" (e.g., `validateAndSave`, `fetchAndTransform`)

### Example

```php
// SMELL — 40+ lines, multiple responsibilities
public function processRegistration(Request $request): JsonResponse
{
    // Validate input
    $validator = Validator::make($request->all(), [
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:8|confirmed',
        'company' => 'required|string',
        'plan' => 'required|in:basic,pro,enterprise',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    // Create user
    $user = new User();
    $user->name = $request->name;
    $user->email = $request->email;
    $user->password = Hash::make($request->password);
    $user->save();

    // Create company
    $company = new Company();
    $company->name = $request->company;
    $company->owner_id = $user->id;
    $company->save();

    // Setup subscription
    $plan = Plan::where('slug', $request->plan)->first();
    $subscription = new Subscription();
    $subscription->user_id = $user->id;
    $subscription->plan_id = $plan->id;
    $subscription->starts_at = now();
    $subscription->ends_at = now()->addMonth();
    $subscription->save();

    // Send emails
    Mail::to($user)->send(new WelcomeEmail($user));
    Mail::to('admin@example.com')->send(new NewRegistration($user));

    // Log
    activity()->log("New registration: {$user->email}");

    return response()->json(['user' => $user, 'subscription' => $subscription], 201);
}
```

### Remedy

Apply **Extract Method** for each logical section. Consider **Extract Class** if methods
group into a cohesive responsibility (e.g., subscription setup becomes a `SubscriptionService`).

---

## Large Class (God Class)

A class that knows too much and does too much. Violates Single Responsibility Principle.

### Detection Heuristics

- Class exceeds 300 lines
- Class has more than 10 public methods
- Class has more than 7 dependencies (constructor parameters)
- Class name is vague: `Manager`, `Handler`, `Processor`, `Service` (without qualifier)
- Multiple unrelated groups of methods in one class

### Example

```php
// SMELL — UserService does everything user-related
class UserService
{
    public function register(array $data): User { /* ... */ }
    public function login(string $email, string $password): ?User { /* ... */ }
    public function logout(User $user): void { /* ... */ }
    public function resetPassword(string $email): void { /* ... */ }
    public function updateProfile(User $user, array $data): User { /* ... */ }
    public function uploadAvatar(User $user, UploadedFile $file): string { /* ... */ }
    public function deleteAccount(User $user): void { /* ... */ }
    public function sendVerificationEmail(User $user): void { /* ... */ }
    public function verifyEmail(string $token): bool { /* ... */ }
    public function calculateLoyaltyPoints(User $user): int { /* ... */ }
    public function exportUserData(User $user): array { /* ... */ }
    public function importUsers(string $csvPath): int { /* ... */ }
    public function generateReport(string $period): Report { /* ... */ }
    public function syncWithCrm(User $user): void { /* ... */ }
}
```

### Remedy

Extract focused classes by responsibility:

| Extracted Class | Methods |
|---|---|
| `AuthService` | `register`, `login`, `logout` |
| `PasswordResetService` | `resetPassword` |
| `ProfileService` | `updateProfile`, `uploadAvatar` |
| `EmailVerificationService` | `sendVerificationEmail`, `verifyEmail` |
| `AccountService` | `deleteAccount`, `exportUserData` |
| `UserImportService` | `importUsers` |
| `LoyaltyService` | `calculateLoyaltyPoints` |
| `UserReportService` | `generateReport` |
| `CrmSyncService` | `syncWithCrm` |

Or use the **Action pattern**: one class per operation (e.g., `RegisterUserAction`,
`ResetPasswordAction`).

---

## Feature Envy

A method that uses data from another object more than from its own class.

### Detection Heuristics

- Method accesses 3+ properties/methods of another object
- Method has no `$this->` references, only uses its parameters
- Method could be moved to the parameter's class without adding dependencies

### Example

```php
// SMELL — this method envies the Product class
class PriceCalculator
{
    public function calculateFinalPrice(Product $product): float
    {
        $base = $product->getBasePrice();
        $discount = $product->getDiscount();
        $tax = $product->getTaxRate();
        $shipping = $product->getShippingWeight() * 0.50;

        $discountedPrice = $base * (1 - $discount / 100);
        $withTax = $discountedPrice * (1 + $tax / 100);

        return $withTax + $shipping;
    }
}
```

### Remedy

**Move Method** to the class whose data it uses:

```php
class Product
{
    public function calculateFinalPrice(): float
    {
        $discountedPrice = $this->basePrice * (1 - $this->discount / 100);
        $withTax = $discountedPrice * (1 + $this->taxRate / 100);
        $shipping = $this->shippingWeight * 0.50;

        return $withTax + $shipping;
    }
}
```

---

## Data Clumps

Groups of data items that always appear together — in parameter lists, field sets, or
method signatures.

### Detection Heuristics

- Same 3+ parameters appear in multiple method signatures
- Fields like `$startDate` and `$endDate` always travel together
- Arrays with the same keys passed between functions

### Example

```php
// SMELL — date range passed as two params everywhere
class ReportService
{
    public function salesReport(string $startDate, string $endDate): array { /* ... */ }
    public function inventoryReport(string $startDate, string $endDate): array { /* ... */ }
    public function customerReport(string $startDate, string $endDate): array { /* ... */ }
    public function exportCsv(string $startDate, string $endDate, string $type): string { /* ... */ }
}
```

### Remedy

**Introduce Parameter Object**:

```php
readonly class DateRange
{
    public function __construct(
        public CarbonImmutable $start,
        public CarbonImmutable $end,
    ) {
        if ($start->isAfter($end)) {
            throw new InvalidArgumentException('Start must be before end');
        }
    }

    public function days(): int
    {
        return $this->start->diffInDays($this->end);
    }

    public function contains(CarbonImmutable $date): bool
    {
        return $date->between($this->start, $this->end);
    }
}

class ReportService
{
    public function salesReport(DateRange $period): array { /* ... */ }
    public function inventoryReport(DateRange $period): array { /* ... */ }
    public function customerReport(DateRange $period): array { /* ... */ }
    public function exportCsv(DateRange $period, ReportType $type): string { /* ... */ }
}
```

---

## Primitive Obsession

Using primitive types (strings, integers, arrays) instead of small objects for domain concepts.

### Detection Heuristics

- Email addresses stored as `string` with validation scattered across the codebase
- Money amounts as `float` without currency
- Phone numbers as `string` with formatting logic duplicated
- Status values as `string` instead of enums
- Configuration passed as `array` instead of typed config objects

### Example

```php
// SMELL — primitives everywhere
class UserService
{
    public function createUser(
        string $name,
        string $email,      // no guarantee it's valid
        string $phone,      // no format enforcement
        float $balance,     // which currency? cents or dollars?
        string $role,       // any string accepted
    ): User {
        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {  // validation repeated
            throw new InvalidArgumentException('Invalid email');
        }
        // ...
    }
}
```

### Remedy

Create **value objects** for domain concepts:

```php
readonly class Email
{
    public function __construct(public string $value)
    {
        if (! filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidArgumentException("Invalid email: {$value}");
        }
    }

    public function domain(): string
    {
        return substr($this->value, strpos($this->value, '@') + 1);
    }

    public function __toString(): string
    {
        return $this->value;
    }
}

readonly class Money
{
    public function __construct(
        public int $cents,
        public string $currency = 'MYR',
    ) {}

    public function dollars(): float
    {
        return $this->cents / 100;
    }

    public function add(self $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new CurrencyMismatchException();
        }
        return new self($this->cents + $other->cents, $this->currency);
    }
}

enum UserRole: string
{
    case Admin = 'admin';
    case Editor = 'editor';
    case Viewer = 'viewer';
}

class UserService
{
    public function createUser(
        string $name,
        Email $email,
        PhoneNumber $phone,
        Money $balance,
        UserRole $role,
    ): User {
        // No scattered validation — value objects enforce their own rules
    }
}
```

---

## Switch Statements (Type-Based Branching)

Switch or if-else chains that branch on a type field, repeated across multiple methods.

### Detection Heuristics

- Same switch/match on the same field appears in 2+ places
- Adding a new type requires changing multiple files
- Switch cases grow every time a new variant is added

### Example

```php
// SMELL — type switch repeated in multiple places
class ShapeCalculator
{
    public function area(array $shape): float
    {
        return match ($shape['type']) {
            'circle' => pi() * $shape['radius'] ** 2,
            'rectangle' => $shape['width'] * $shape['height'],
            'triangle' => 0.5 * $shape['base'] * $shape['height'],
        };
    }

    public function perimeter(array $shape): float
    {
        return match ($shape['type']) {
            'circle' => 2 * pi() * $shape['radius'],
            'rectangle' => 2 * ($shape['width'] + $shape['height']),
            'triangle' => $shape['a'] + $shape['b'] + $shape['c'],
        };
    }

    public function draw(array $shape): string
    {
        return match ($shape['type']) {
            'circle' => "Drawing circle with radius {$shape['radius']}",
            'rectangle' => "Drawing {$shape['width']}x{$shape['height']} rectangle",
            'triangle' => "Drawing triangle with base {$shape['base']}",
        };
    }
}
```

### Remedy

**Replace Conditional with Polymorphism**:

```php
interface Shape
{
    public function area(): float;
    public function perimeter(): float;
    public function draw(): string;
}

readonly class Circle implements Shape
{
    public function __construct(public float $radius) {}

    public function area(): float { return pi() * $this->radius ** 2; }
    public function perimeter(): float { return 2 * pi() * $this->radius; }
    public function draw(): string { return "Drawing circle with radius {$this->radius}"; }
}

readonly class Rectangle implements Shape
{
    public function __construct(public float $width, public float $height) {}

    public function area(): float { return $this->width * $this->height; }
    public function perimeter(): float { return 2 * ($this->width + $this->height); }
    public function draw(): string { return "Drawing {$this->width}x{$this->height} rectangle"; }
}
```

---

## Parallel Inheritance Hierarchies

Every time you add a subclass to one hierarchy, you must add a corresponding subclass
to another.

### Detection Heuristics

- Two class hierarchies that mirror each other (e.g., `Order` / `OrderProcessor`,
  `Payment` / `PaymentValidator`)
- Adding a new type requires creating 2+ new classes in lock step
- Subclass names share prefixes (e.g., `CreditCardPayment` and `CreditCardPaymentValidator`)

### Example

```php
// SMELL — parallel hierarchies
abstract class Payment { /* ... */ }
class CreditCardPayment extends Payment { /* ... */ }
class BankTransferPayment extends Payment { /* ... */ }
class EwalletPayment extends Payment { /* ... */ }

abstract class PaymentValidator { /* ... */ }
class CreditCardPaymentValidator extends PaymentValidator { /* ... */ }
class BankTransferPaymentValidator extends PaymentValidator { /* ... */ }
class EwalletPaymentValidator extends PaymentValidator { /* ... */ }
```

### Remedy

Merge the parallel hierarchy by moving validation into the payment class itself, or use
a strategy pattern:

```php
interface Payment
{
    public function validate(): ValidationResult;
    public function process(): PaymentResult;
}

readonly class CreditCardPayment implements Payment
{
    public function __construct(
        private string $cardNumber,
        private string $expiry,
        private string $cvv,
        private Money $amount,
    ) {}

    public function validate(): ValidationResult
    {
        // validation logic lives here — no separate validator needed
    }

    public function process(): PaymentResult { /* ... */ }
}
```

---

## Lazy Class

A class that doesn't do enough to justify its existence. Often the result of over-engineering
or a refactoring that removed too much.

### Detection Heuristics

- Class has only 1-2 methods
- Class is a thin wrapper that delegates everything to another class
- Class was created "just in case" but never grew
- Removing the class and inlining its logic would not increase complexity

### Example

```php
// SMELL — class adds no value
class StringHelper
{
    public static function truncate(string $text, int $length): string
    {
        return Str::limit($text, $length);
    }
}

// Usage
$short = StringHelper::truncate($title, 50);
// Could just be: $short = Str::limit($title, 50);
```

### Remedy

**Inline Class** — move the method to its caller or use the underlying utility directly.
Delete the lazy class.

Exception: keep the class if it serves as a domain-specific abstraction that may grow,
or if it provides a seam for testing.

---

## Speculative Generality

Code designed for future requirements that never materialized. Adds complexity without value.

### Detection Heuristics

- Abstract classes with only one concrete subclass
- Interfaces implemented by only one class (and not used for testing)
- Parameters or methods that are never used
- "Framework" code in application layer (custom event buses, plugin systems) with one user
- Classes named with `Abstract`, `Base`, or `Generic` prefix but no actual variation

### Example

```php
// SMELL — over-engineered for imaginary future needs
interface PaymentGatewayInterface
{
    public function charge(Money $amount): PaymentResult;
    public function refund(string $transactionId): RefundResult;
    public function subscribe(Plan $plan): SubscriptionResult;
    public function cancelSubscription(string $subscriptionId): bool;
    public function getTransactionHistory(DateRange $period): array;
    public function setWebhookUrl(string $url): void;
}

// Only one implementation exists
class StripePaymentGateway implements PaymentGatewayInterface
{
    // implements everything, half the methods are never called
}
```

### Remedy

Remove the interface if there is only one implementation and no testing need. Keep it simple
until a second implementation actually materializes:

```php
// GOOD — concrete class, extract interface later if needed
class StripeGateway
{
    public function charge(Money $amount): PaymentResult { /* ... */ }
    public function refund(string $transactionId): RefundResult { /* ... */ }
}
```

Follow YAGNI (You Aren't Gonna Need It). Extract an interface when:
- A second implementation appears
- You need it for test doubles
- You're defining a contract for a package boundary

---

## Severity Guide

Use this when prioritizing review findings:

| Severity | Criteria | Examples |
|---|---|---|
| **High** | Causes bugs, security issues, or data loss | `@` error suppression, raw SQL in controllers, `mixed` types hiding null access |
| **Medium** | Hurts maintainability, slows development | God class, long methods, feature envy, data clumps |
| **Low** | Style or minor readability issues | Lazy class, speculative generality, redundant PHPDoc |

Always present High severity issues first. Low severity issues can be noted but should
not block progress.
