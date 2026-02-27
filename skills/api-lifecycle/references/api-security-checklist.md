# API Security Checklist — OWASP API Top 10

Complete security checklist with Laravel-specific mitigations for each OWASP API Security risk.
Read this file when running `/api security` or hardening an existing API.

---

## API1:2023 — Broken Object Level Authorization (BOLA)

The most common API vulnerability. Occurs when an API endpoint allows access to objects
belonging to other users by manipulating the object ID.

### What to Check

- [ ] Every endpoint that takes a resource ID verifies the authenticated user owns/can access that resource
- [ ] Policies registered for all models used in API endpoints
- [ ] Controller actions use `$this->authorize()` or `authorizeResource()` in constructor
- [ ] Nested resources verify parent ownership (e.g., `/users/{user}/orders/{order}` checks user owns order)
- [ ] No direct database queries bypass model scoping

### Laravel Mitigations

**Policy-based authorization:**

```php
// app/Policies/OrderPolicy.php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->customer_id
            || $user->hasRole('admin');
    }

    public function update(User $user, Order $order): bool
    {
        return $user->id === $order->customer_id;
    }

    public function delete(User $user, Order $order): bool
    {
        return $user->id === $order->customer_id
            && $order->status === 'pending';
    }
}
```

**Global scope for multi-tenant apps:**

```php
// app/Models/Scopes/TenantScope.php
class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if (auth()->check()) {
            $builder->where('tenant_id', auth()->user()->tenant_id);
        }
    }
}

// app/Models/Order.php
protected static function booted(): void
{
    static::addGlobalScope(new TenantScope());

    static::creating(function (Order $order) {
        $order->tenant_id = auth()->user()->tenant_id;
    });
}
```

**Controller authorization pattern:**

```php
class OrderController extends Controller
{
    public function __construct()
    {
        $this->authorizeResource(Order::class, 'order');
    }

    // Each method is automatically checked against the policy
}
```

---

## API2:2023 — Broken Authentication

Weak authentication mechanisms that allow attackers to compromise tokens, keys, or passwords.

### What to Check

- [ ] Tokens have an expiry time configured
- [ ] Password reset endpoints are rate limited
- [ ] Login endpoint has brute force protection
- [ ] Tokens are not exposed in URLs or logs
- [ ] Logout invalidates the token server-side
- [ ] Token rotation on privilege escalation (e.g., password change)
- [ ] No sensitive data in JWT payload (if using JWTs)

### Laravel Mitigations

**Sanctum token expiry:**

```php
// config/sanctum.php
return [
    'expiration' => 60 * 24, // 24 hours in minutes
    'token_prefix' => '',
];
```

**Login with rate limiting:**

```php
// app/Http/Controllers/Api/AuthController.php
class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        // Rate limit login attempts
        $key = 'login:' . $request->ip() . ':' . $request->input('email');
        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'type' => 'https://httpstatuses.com/429',
                'title' => 'Too Many Requests',
                'status' => 429,
                'detail' => "Too many login attempts. Try again in {$seconds} seconds.",
            ], 429);
        }

        if (! Auth::attempt($request->only('email', 'password'))) {
            RateLimiter::hit($key, 300); // Lock for 5 minutes
            return response()->json([
                'type' => 'https://httpstatuses.com/401',
                'title' => 'Unauthorized',
                'status' => 401,
                'detail' => 'Invalid credentials.',
            ], 401);
        }

        RateLimiter::clear($key);

        $token = $request->user()->createToken(
            'api-token',
            ['*'],
            now()->addHours(24)
        );

        return response()->json([
            'data' => [
                'token' => $token->plainTextToken,
                'expires_at' => $token->accessToken->expires_at->toIso8601String(),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        // Revoke the current token
        $request->user()->currentAccessToken()->delete();

        return response()->json(null, 204);
    }
}
```

**Token rotation on password change:**

```php
public function changePassword(Request $request): JsonResponse
{
    $request->validate([
        'current_password' => ['required', 'current_password'],
        'password' => ['required', 'confirmed', Password::defaults()],
    ]);

    $request->user()->update([
        'password' => Hash::make($request->input('password')),
    ]);

    // Revoke all tokens except the current one
    $request->user()->tokens()
        ->where('id', '!=', $request->user()->currentAccessToken()->id)
        ->delete();

    return response()->json(['message' => 'Password changed successfully.']);
}
```

---

## API3:2023 — Broken Object Property Level Authorization

API exposes object properties that the user should not be able to read or write.

### What to Check

- [ ] Models define `$fillable` explicitly (never use `$guarded = []`)
- [ ] Models define `$hidden` for sensitive fields
- [ ] API Resources only expose intended fields
- [ ] Form Requests validate every field (no `$request->all()` passed to create/update)
- [ ] Admin-only fields not writable via public endpoints
- [ ] Internal fields (cost, margin, internal notes) hidden from API responses

### Laravel Mitigations

**Strict fillable on models:**

```php
class Order extends Model
{
    protected $fillable = [
        'customer_id',
        'status',
        'notes',
    ];

    protected $hidden = [
        'internal_notes',
        'cost_price',
        'margin',
        'deleted_at',
    ];

    protected $casts = [
        'total' => 'decimal:2',
        'cost_price' => 'decimal:2',
    ];
}
```

**Form Request prevents mass assignment of admin fields:**

```php
class UpdateOrderRequest extends FormRequest
{
    public function rules(): array
    {
        $rules = [
            'notes' => ['sometimes', 'string', 'max:1000'],
        ];

        // Only admins can change status
        if ($this->user()->isAdmin()) {
            $rules['status'] = ['sometimes', 'in:pending,processing,shipped,delivered,cancelled'];
        }

        return $rules;
    }
}
```

**API Resource controls visible fields:**

```php
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => 'orders',
            'attributes' => [
                'status' => $this->status,
                'total' => $this->total,
                'notes' => $this->notes,
                'created_at' => $this->created_at->toIso8601String(),
                // cost_price and margin are never exposed
                // internal_notes is never exposed
            ],
        ];
    }
}
```

---

## API4:2023 — Unrestricted Resource Consumption

API does not limit the size, number, or frequency of requests.

### What to Check

- [ ] Rate limiting configured for all API routes
- [ ] Different rate limits for public vs authenticated vs admin
- [ ] Pagination enforced with maximum page size
- [ ] File upload size limits configured
- [ ] Query complexity limits (prevent N+1 via deep includes)
- [ ] Export/report endpoints have stricter rate limits
- [ ] Bulk operation endpoints limit batch size

### Laravel Mitigations

**Tiered rate limiting:**

```php
// app/Providers/AppServiceProvider.php
public function boot(): void
{
    RateLimiter::for('api-public', function (Request $request) {
        return Limit::perMinute(30)->by($request->ip());
    });

    RateLimiter::for('api-authenticated', function (Request $request) {
        return Limit::perMinute(120)->by($request->user()->id);
    });

    RateLimiter::for('api-sensitive', function (Request $request) {
        return Limit::perMinute(5)
            ->by($request->user()->id)
            ->response(function () {
                return response()->json([
                    'type' => 'https://httpstatuses.com/429',
                    'title' => 'Too Many Requests',
                    'status' => 429,
                    'detail' => 'Rate limit exceeded for sensitive operation.',
                ], 429);
            });
    });
}
```

**Pagination max enforcement:**

```php
class OrderController extends Controller
{
    public function index(Request $request): OrderCollection
    {
        $perPage = min($request->input('per_page', 15), 100); // Max 100

        $orders = QueryBuilder::for(Order::class)
            ->allowedFilters(['status', 'customer_id'])
            ->allowedIncludes(['customer']) // Limit allowed includes
            ->paginate($perPage);

        return new OrderCollection($orders);
    }
}
```

**File upload limits:**

```php
// php.ini or .htaccess
// upload_max_filesize = 10M
// post_max_size = 12M

// Form Request validation
public function rules(): array
{
    return [
        'attachment' => ['sometimes', 'file', 'max:10240', 'mimes:pdf,doc,docx,jpg,png'],
    ];
}
```

---

## API5:2023 — Broken Function Level Authorization

User can access administrative functions by guessing the endpoint URL.

### What to Check

- [ ] Admin routes in a separate middleware group
- [ ] Role/permission checks on every admin-only action
- [ ] No admin endpoints accessible without authentication
- [ ] Middleware order is correct (auth before role check)
- [ ] Batch/bulk endpoints have admin-only access

### Laravel Mitigations

```php
// routes/api.php
Route::prefix('v1')->group(function () {
    // Public routes
    Route::get('products', [ProductController::class, 'index']);

    // Authenticated routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::apiResource('orders', OrderController::class);
    });

    // Admin-only routes
    Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
        Route::get('orders/export', [AdminOrderController::class, 'export']);
        Route::post('orders/bulk-update', [AdminOrderController::class, 'bulkUpdate']);
        Route::get('users', [AdminUserController::class, 'index']);
        Route::delete('users/{user}', [AdminUserController::class, 'destroy']);
    });
});
```

---

## API6:2023 — Unrestricted Access to Sensitive Business Flows

Sensitive operations (password reset, payment, verification) lack protection.

### What to Check

- [ ] Password reset has rate limiting and token expiry
- [ ] Email verification tokens expire
- [ ] Payment endpoints validate idempotency keys
- [ ] Account deletion requires re-authentication
- [ ] OTP/2FA codes have attempt limits
- [ ] Invitation/signup flows have CAPTCHA or rate limiting

### Laravel Mitigations

```php
// Idempotency for payment endpoints
class ProcessPaymentRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'idempotency_key' => ['required', 'string', 'uuid'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'order_id' => ['required', 'exists:orders,id'],
        ];
    }
}

class PaymentController extends Controller
{
    public function process(ProcessPaymentRequest $request): JsonResponse
    {
        // Check idempotency — return cached result if already processed
        $cacheKey = "payment:{$request->input('idempotency_key')}";
        if ($cached = Cache::get($cacheKey)) {
            return response()->json($cached);
        }

        $payment = DB::transaction(function () use ($request) {
            return Payment::create($request->validated());
        });

        $result = ['data' => new PaymentResource($payment)];
        Cache::put($cacheKey, $result, now()->addHours(24));

        return response()->json($result, 201);
    }
}
```

---

## API7:2023 — Server-Side Request Forgery (SSRF)

API fetches a remote resource based on user-supplied URL without validation.

### What to Check

- [ ] User-supplied URLs validated against allowlist
- [ ] No internal/private IP access from URL inputs
- [ ] Webhook URLs validated before storing
- [ ] Image/file URL fetching uses allowlisted domains
- [ ] DNS rebinding protection in place

### Laravel Mitigations

```php
// Validate webhook URLs
public function rules(): array
{
    return [
        'webhook_url' => [
            'required',
            'url',
            'starts_with:https://',
            function (string $attribute, mixed $value, Closure $fail) {
                $host = parse_url($value, PHP_URL_HOST);
                $ip = gethostbyname($host);

                // Block private/internal IPs
                if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false) {
                    $fail('The webhook URL must point to a public address.');
                }
            },
        ],
    ];
}
```

---

## API8:2023 — Security Misconfiguration

Debug mode, stack traces, default credentials, unnecessary HTTP methods, missing security headers.

### What to Check

- [ ] `APP_DEBUG=false` in production
- [ ] Stack traces not exposed in error responses
- [ ] Security headers set (X-Content-Type-Options, HSTS, X-Frame-Options)
- [ ] CORS configured with specific origins (not `*`)
- [ ] Unnecessary HTTP methods disabled
- [ ] Default error handler returns RFC 7807 format
- [ ] `.env` not accessible via web
- [ ] `phpinfo()` not exposed
- [ ] Directory listing disabled

### Laravel Mitigations

**Exception handler for API (Laravel 11):**

```php
// bootstrap/app.php
->withExceptions(function (Exceptions $exceptions) {
    $exceptions->shouldRenderJsonWhen(function (Request $request) {
        return $request->is('api/*') || $request->expectsJson();
    });

    $exceptions->render(function (Throwable $e, Request $request) {
        if (! $request->is('api/*')) {
            return null;
        }

        $status = match (true) {
            $e instanceof AuthenticationException => 401,
            $e instanceof AuthorizationException => 403,
            $e instanceof ModelNotFoundException => 404,
            $e instanceof ValidationException => 422,
            $e instanceof ThrottleRequestsException => 429,
            $e instanceof HttpException => $e->getStatusCode(),
            default => 500,
        };

        return response()->json([
            'type' => "https://httpstatuses.com/{$status}",
            'title' => match ($status) {
                401 => 'Unauthorized',
                403 => 'Forbidden',
                404 => 'Not Found',
                422 => 'Unprocessable Entity',
                429 => 'Too Many Requests',
                500 => 'Internal Server Error',
                default => 'Error',
            },
            'status' => $status,
            'detail' => $status === 500 && ! app()->isLocal()
                ? 'An unexpected error occurred.'
                : $e->getMessage(),
            'errors' => $e instanceof ValidationException
                ? $e->errors()
                : null,
        ], $status);
    });
})
```

**CORS configuration:**

```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', '')),
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
    'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining', 'Deprecation', 'Sunset'],
    'max_age' => 86400,
    'supports_credentials' => true,
];

// .env (production)
// CORS_ALLOWED_ORIGINS=https://app.example.com,https://admin.example.com
```

**Security headers middleware:**

```php
class ApiSecurityHeaders
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->headers->set('Cache-Control', 'no-store, no-cache, must-revalidate');
        $response->headers->set('Pragma', 'no-cache');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

        $response->headers->remove('X-Powered-By');
        $response->headers->remove('Server');

        return $response;
    }
}
```

---

## API9:2023 — Improper Inventory Management

Undocumented, unmonitored, or forgotten API endpoints.

### What to Check

- [ ] All routes documented in OpenAPI spec
- [ ] No debug/test routes in production
- [ ] Old API versions have sunset dates
- [ ] Route list matches OpenAPI spec (`php artisan route:list --path=api`)
- [ ] No orphaned routes (routes with no controller method)
- [ ] API versions inventory maintained

### Laravel Mitigations

**Route audit command:**

```bash
# List all API routes and compare against OpenAPI spec
php artisan route:list --path=api --columns=method,uri,name,action

# Look for routes not in the spec
php artisan route:list --path=api --json | jq '.[] | .uri'
```

**Remove debug routes in production:**

```php
// routes/api.php
if (app()->isLocal()) {
    Route::get('debug/routes', function () {
        return response()->json(Route::getRoutes()->getRoutes());
    });
}
```

---

## API10:2023 — Unsafe Consumption of APIs

API trusts data from third-party APIs without validation.

### What to Check

- [ ] Third-party API responses validated before use
- [ ] Timeouts configured for outgoing HTTP requests
- [ ] Circuit breaker pattern for unreliable external APIs
- [ ] SSL verification enabled for outgoing requests
- [ ] Webhook payloads validated (signature verification)
- [ ] No blind trust of external data in database queries

### Laravel Mitigations

**Safe HTTP client usage:**

```php
use Illuminate\Support\Facades\Http;

// Always set timeouts and validate responses
$response = Http::timeout(10)
    ->retry(3, 100)
    ->withHeaders([
        'Accept' => 'application/json',
    ])
    ->get('https://external-api.com/data');

if ($response->failed()) {
    Log::warning('External API request failed', [
        'status' => $response->status(),
        'url' => 'https://external-api.com/data',
    ]);
    throw new ExternalApiException('Failed to fetch data from provider.');
}

// Validate the response structure before using it
$data = $response->json();
$validated = Validator::make($data, [
    'id' => ['required', 'integer'],
    'name' => ['required', 'string', 'max:255'],
    'amount' => ['required', 'numeric', 'min:0'],
])->validate();
```

**Webhook signature verification:**

```php
class WebhookController extends Controller
{
    public function handle(Request $request): JsonResponse
    {
        $signature = $request->header('X-Webhook-Signature');
        $payload = $request->getContent();
        $secret = config('services.provider.webhook_secret');

        $expectedSignature = hash_hmac('sha256', $payload, $secret);

        if (! hash_equals($expectedSignature, $signature)) {
            Log::warning('Invalid webhook signature', [
                'ip' => $request->ip(),
            ]);
            abort(403, 'Invalid signature.');
        }

        // Process webhook safely
        $data = $request->validate([
            'event' => ['required', 'string'],
            'data.id' => ['required', 'integer'],
        ]);

        // Handle event...

        return response()->json(['received' => true]);
    }
}
```

---

## Input Validation Patterns

### Common Validation Rules for API Fields

```php
// String fields
'name' => ['required', 'string', 'min:2', 'max:255'],
'email' => ['required', 'email:rfc,dns', 'max:255'],
'phone' => ['nullable', 'string', 'regex:/^(\+?6?01)[0-46-9]-*[0-9]{7,8}$/'], // Malaysian phone
'url' => ['nullable', 'url', 'starts_with:https://'],

// Numeric fields
'quantity' => ['required', 'integer', 'min:1', 'max:9999'],
'price' => ['required', 'numeric', 'min:0', 'decimal:0,2'],
'percentage' => ['required', 'numeric', 'min:0', 'max:100'],

// Date fields
'start_date' => ['required', 'date', 'after_or_equal:today'],
'end_date' => ['required', 'date', 'after:start_date'],

// Enum fields
'status' => ['required', 'in:pending,active,completed,cancelled'],
'priority' => ['required', Rule::enum(Priority::class)], // PHP 8.1 enum

// Relationship fields
'customer_id' => ['required', 'exists:customers,id'],
'tags' => ['sometimes', 'array', 'max:10'],
'tags.*' => ['string', 'max:50'],

// File fields
'avatar' => ['sometimes', 'image', 'max:2048', 'dimensions:min_width=100,min_height=100'],
'document' => ['sometimes', 'file', 'max:10240', 'mimes:pdf,doc,docx'],

// JSON fields
'metadata' => ['sometimes', 'json'],
'settings' => ['sometimes', 'array'],
'settings.notifications' => ['sometimes', 'boolean'],
```

### Preventing Common Injection Attacks

```php
// XSS prevention — sanitize HTML in string inputs
'bio' => ['nullable', 'string', 'max:5000'],

// In the model or observer
protected static function booted(): void
{
    static::saving(function (User $user) {
        if ($user->isDirty('bio')) {
            $user->bio = strip_tags($user->bio);
        }
    });
}

// SQL injection — always use parameterized queries
// NEVER: DB::raw("WHERE name = '$name'")
// ALWAYS: ->where('name', $name)

// Path traversal — validate file paths
'file_path' => [
    'required',
    'string',
    function (string $attribute, mixed $value, Closure $fail) {
        if (str_contains($value, '..') || str_contains($value, '~')) {
            $fail('Invalid file path.');
        }
    },
],
```
