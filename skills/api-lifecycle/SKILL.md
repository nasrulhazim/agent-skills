---
name: api-lifecycle
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, api, openapi, sanctum, rest]
description: >
  Complete API lifecycle management for Laravel applications — from OpenAPI design through
  governance and security hardening. Covers seven phases: design (OpenAPI 3.1 spec generation
  via interview), develop (controller/request/resource scaffolding with Sanctum/Passport auth),
  test (Pest API test generation with contract testing), deploy (versioned deployment with
  feature flags and zero-downtime migration), docs (auto-generated documentation with
  Scribe/Scramble), govern (breaking change detection, deprecation policy, API review), and
  security (OWASP API Top 10, input validation, rate limiting tiers). Use this skill whenever
  the user asks to design an API, generate OpenAPI specs, scaffold API endpoints, write API
  tests, deploy API versions, generate API documentation, review API changes, or harden API
  security — including requests like "design a REST API for X", "scaffold CRUD endpoints",
  "generate Pest tests for my API", "set up API versioning", "check my API for breaking
  changes", "generate API docs", "secure my API", or "review my API design". Also triggers
  for Malay requests like "reka bentuk API untuk X", "buat ujian API", "jana dokumentasi API",
  "semak keselamatan API saya", or "sediakan endpoint CRUD". Compatible with Laravel 10/11
  projects using Sanctum, Passport, Scribe, and Scramble.
---

# API Lifecycle Manager

A seven-phase methodology for designing, building, testing, deploying, documenting, governing,
and securing production-ready REST APIs in Laravel — anchored on OpenAPI 3.1 as the single
source of truth.

## Command Reference

| Command | Phase | Description |
|---|---|---|
| `/api design` | Design | Interview + generate OpenAPI 3.1 spec |
| `/api develop` | Develop | Scaffold controllers, requests, resources from OpenAPI |
| `/api test` | Test | Generate Pest API tests + contract tests |
| `/api deploy` | Deploy | Versioned deployment, feature flags, zero-downtime |
| `/api docs` | Documentation | Auto-generate docs via Scribe/Scramble |
| `/api govern` | Governance | Breaking change detection, deprecation, review |
| `/api security` | Security | OWASP API Top 10 audit + hardening |

---

## 1. `/api design` — OpenAPI Spec Generation

### 1.1 API Discovery Interview

Ask the user for the following in **three blocks**, one at a time:

**Block 1 — API Identity**
- What is the API name and purpose? (one sentence)
- Who are the consumers? (SPA, mobile app, third-party, internal service)
- What authentication method? (Sanctum for SPA/mobile, Passport for third-party, API keys)
- What base URL / server environments? (local, staging, production)

**Block 2 — Resources & Operations**
- List the primary resources (e.g., users, orders, products)
- For each resource: which CRUD operations are needed?
- Are there any non-CRUD actions? (e.g., approve, publish, archive)
- What relationships exist between resources? (belongs-to, has-many, many-to-many)

**Block 3 — Behaviour & Constraints**
- Versioning strategy: URI-based (`/api/v1/`) or header-based (`Accept: application/vnd.app.v1+json`)?
- Pagination style: cursor-based or offset-based? Default page size?
- Filtering and sorting requirements?
- Rate limiting tiers? (public vs authenticated vs admin)
- Error response format: RFC 7807 Problem Details or custom?

If the user already provided context, extract what you can and only ask for what is missing.

### 1.2 Generate OpenAPI 3.1 Specification

Read `references/openapi-template.md` for the base template structure.

Generate a complete OpenAPI 3.1 YAML specification with:

- `info` block with title, description, version, contact, license
- `servers` for each environment
- `paths` for every resource and operation identified
- `components/schemas` for request bodies, response bodies, error objects
- `components/securitySchemes` for the chosen auth method
- `components/parameters` for reusable query parameters (pagination, filtering, sorting)
- Proper HTTP status codes: 200, 201, 204, 400, 401, 403, 404, 409, 422, 429, 500
- RFC 7807 error response schema (if selected)
- Pagination envelope schema

**Naming conventions (enforce on every path):**
- Plural nouns for collections: `/api/v1/orders` not `/api/v1/order`
- Kebab-case for multi-word: `/api/v1/order-items` not `/api/v1/orderItems`
- Nested resources max 2 levels: `/api/v1/orders/{order}/items`
- No verbs in paths: use HTTP methods instead

### 1.3 Present Design Output

Save the spec as `openapi.yaml`. Present it and ask:
"Review the spec. Want to adjust any resources, add fields, or change behaviour? Once confirmed,
I can scaffold the Laravel code with `/api develop`."

---

## 2. `/api develop` — Laravel Scaffolding from OpenAPI

### 2.1 Pre-flight Checks

Before scaffolding, verify:
- An `openapi.yaml` exists in the project (or user provides one)
- Laravel version (10 or 11) — check `composer.json`
- Auth package installed (Sanctum or Passport)

### 2.2 Generate Per-Resource Files

For each resource in the OpenAPI spec, generate:

| File | Location | Purpose |
|---|---|---|
| Controller | `app/Http/Controllers/Api/V1/{Resource}Controller.php` | RESTful actions |
| Form Request (Store) | `app/Http/Requests/Api/V1/Store{Resource}Request.php` | Create validation |
| Form Request (Update) | `app/Http/Requests/Api/V1/Update{Resource}Request.php` | Update validation |
| API Resource | `app/Http/Resources/Api/V1/{Resource}Resource.php` | Response transformation |
| Resource Collection | `app/Http/Resources/Api/V1/{Resource}Collection.php` | Paginated collection |
| Policy | `app/Policies/{Resource}Policy.php` | Authorization |
| Migration | `database/migrations/{timestamp}_create_{table}_table.php` | Database schema |
| Model | `app/Models/{Resource}.php` | Eloquent model |

### 2.3 Controller Pattern

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreOrderRequest;
use App\Http\Requests\Api\V1\UpdateOrderRequest;
use App\Http\Resources\Api\V1\OrderCollection;
use App\Http\Resources\Api\V1\OrderResource;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\QueryBuilder\QueryBuilder;

class OrderController extends Controller
{
    public function __construct()
    {
        $this->authorizeResource(Order::class, 'order');
    }

    public function index(Request $request): OrderCollection
    {
        $orders = QueryBuilder::for(Order::class)
            ->allowedFilters(['status', 'customer_id', 'created_at'])
            ->allowedSorts(['created_at', 'total', 'status'])
            ->allowedIncludes(['customer', 'items'])
            ->paginate($request->input('per_page', 15))
            ->appends($request->query());

        return new OrderCollection($orders);
    }

    public function store(StoreOrderRequest $request): JsonResponse
    {
        $order = Order::create($request->validated());

        return (new OrderResource($order))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Order $order): OrderResource
    {
        return new OrderResource($order->load(['customer', 'items']));
    }

    public function update(UpdateOrderRequest $request, Order $order): OrderResource
    {
        $order->update($request->validated());

        return new OrderResource($order->fresh());
    }

    public function destroy(Order $order): JsonResponse
    {
        $order->delete();

        return response()->json(null, 204);
    }
}
```

### 2.4 Form Request Pattern

```php
<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Handled by Policy
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'exists:customers,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:999'],
            'items.*.unit_price' => ['required', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(
            response()->json([
                'type' => 'https://httpstatuses.com/422',
                'title' => 'Unprocessable Entity',
                'status' => 422,
                'detail' => 'The given data was invalid.',
                'errors' => $validator->errors()->toArray(),
            ], JsonResponse::HTTP_UNPROCESSABLE_ENTITY)
        );
    }
}
```

### 2.5 API Resource Pattern

```php
<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

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
                'updated_at' => $this->updated_at->toIso8601String(),
            ],
            'relationships' => [
                'customer' => new CustomerResource($this->whenLoaded('customer')),
                'items' => OrderItemResource::collection($this->whenLoaded('items')),
            ],
            'links' => [
                'self' => route('api.v1.orders.show', $this->id),
            ],
        ];
    }
}
```

### 2.6 Authentication Setup

**Sanctum (SPA / First-party mobile):**

```php
// routes/api.php
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    Route::apiResource('orders', OrderController::class);
});

// Unauthenticated routes
Route::prefix('v1')->group(function () {
    Route::get('products', [ProductController::class, 'index']);
});
```

**Passport (Third-party / OAuth):**

```php
// routes/api.php
Route::prefix('v1')->middleware('auth:api')->group(function () {
    Route::apiResource('orders', OrderController::class)
        ->middleware('scope:orders-read,orders-write');
});
```

### 2.7 Rate Limiting

```php
// app/Providers/AppServiceProvider.php (Laravel 11)
// or RouteServiceProvider (Laravel 10)

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;

RateLimiter::for('api', function (Request $request) {
    return match (true) {
        $request->user()?->isAdmin() => Limit::none(),
        $request->user() !== null => Limit::perMinute(120)->by($request->user()->id),
        default => Limit::perMinute(30)->by($request->ip()),
    };
});
```

### 2.8 Query Scoping

Install `spatie/laravel-query-builder` for filtering, sorting, and includes:

```php
// Scoped queries prevent users from accessing other tenants' data
$orders = QueryBuilder::for(
    Order::where('tenant_id', $request->user()->tenant_id)
)
    ->allowedFilters(['status', 'created_at'])
    ->allowedSorts(['created_at', 'total'])
    ->paginate();
```

### 2.9 Present Development Output

Present all generated files grouped by type. Ask:
"All scaffolding is generated. Run `php artisan migrate` to create tables.
Want me to generate Pest tests with `/api test`?"

---

## 3. `/api test` — Pest API Test Generation

### 3.1 Test Discovery

Read the OpenAPI spec (or scan existing controllers) to determine:
- All endpoints and HTTP methods
- Required authentication
- Validation rules from Form Requests
- Expected response structures from API Resources

### 3.2 Generate Test Files

For each resource, generate a test file at `tests/Feature/Api/V1/{Resource}Test.php`.

Read `references/api-test-patterns.md` for the complete test pattern library.

Each test file must include:

| Test Category | Tests |
|---|---|
| CRUD operations | index, store, show, update, destroy |
| Authentication | unauthenticated access returns 401, forbidden returns 403 |
| Validation | required fields, invalid types, max lengths, unique constraints |
| Error responses | 404 for missing resource, 409 for conflicts |
| Pagination | default page size, custom page size, cursor navigation |
| Filtering | valid filters, invalid filters ignored |
| Sorting | ascending, descending, default sort |
| Rate limiting | exceeding rate limit returns 429 |

### 3.3 Test Structure Pattern

```php
<?php

use App\Models\Order;
use App\Models\User;

use function Pest\Laravel\{getJson, postJson, putJson, deleteJson, actingAs};

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->admin = User::factory()->admin()->create();
});

describe('GET /api/v1/orders', function () {
    it('returns paginated orders for authenticated user', function () {
        Order::factory()->count(20)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(15, 'data')
            ->assertJsonStructure([
                'data' => [['id', 'type', 'attributes' => ['status', 'total', 'created_at']]],
                'links' => ['first', 'last', 'prev', 'next'],
                'meta' => ['current_page', 'last_page', 'per_page', 'total'],
            ]);
    });

    it('returns 401 for unauthenticated request', function () {
        getJson('/api/v1/orders')
            ->assertUnauthorized();
    });

    it('filters orders by status', function () {
        Order::factory()->for($this->user, 'customer')->create(['status' => 'pending']);
        Order::factory()->for($this->user, 'customer')->create(['status' => 'completed']);

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?filter[status]=pending')
            ->assertOk()
            ->assertJsonCount(1, 'data');
    });

    it('sorts orders by created_at descending', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?sort=-created_at')
            ->assertOk();
    });
});

describe('POST /api/v1/orders', function () {
    it('creates an order with valid data', function () {
        $payload = [
            'customer_id' => $this->user->id,
            'items' => [
                ['product_id' => 1, 'quantity' => 2, 'unit_price' => 29.99],
            ],
        ];

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated()
            ->assertJsonPath('data.type', 'orders');
    });

    it('returns 422 with validation errors for missing required fields', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['customer_id', 'items']);
    });

    it('returns 422 when items array is empty', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items']);
    });
});
```

### 3.4 Contract Testing

Generate contract tests that validate responses against the OpenAPI spec:

```php
describe('Contract: GET /api/v1/orders', function () {
    it('matches OpenAPI schema for list response', function () {
        Order::factory()->count(3)->for($this->user, 'customer')->create();

        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders');

        $response->assertOk();

        // Validate each item matches the schema
        $data = $response->json('data');

        foreach ($data as $item) {
            expect($item)->toHaveKeys(['id', 'type', 'attributes', 'relationships', 'links']);
            expect($item['type'])->toBe('orders');
            expect($item['attributes'])->toHaveKeys(['status', 'total', 'created_at', 'updated_at']);
            expect($item['attributes']['created_at'])->toMatch('/^\d{4}-\d{2}-\d{2}T/');
        }
    });

    it('matches OpenAPI error schema for 422', function () {
        $response = actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', []);

        $response->assertUnprocessable();
        $error = $response->json();

        expect($error)->toHaveKeys(['type', 'title', 'status', 'detail', 'errors']);
        expect($error['status'])->toBe(422);
        expect($error['type'])->toBeString();
    });
});
```

### 3.5 Present Test Output

Present all test files. Ask:
"Run `php artisan test --filter=Api` to execute. Want me to add deployment setup with `/api deploy`?"

---

## 4. `/api deploy` — Versioned Deployment

### 4.1 API Versioning Strategy

**URI-based versioning (recommended for most Laravel apps):**

```
app/Http/Controllers/Api/
├── V1/
│   ├── OrderController.php
│   └── ProductController.php
└── V2/
    ├── OrderController.php    ← new version, extends or replaces V1
    └── ProductController.php
```

```php
// routes/api.php
Route::prefix('v1')->as('api.v1.')->group(function () {
    Route::apiResource('orders', Api\V1\OrderController::class);
});

Route::prefix('v2')->as('api.v2.')->group(function () {
    Route::apiResource('orders', Api\V2\OrderController::class);
});
```

**Header-based versioning (for advanced use cases):**

```php
// app/Http/Middleware/ApiVersion.php
class ApiVersion
{
    public function handle(Request $request, Closure $next): Response
    {
        $version = $request->header('Accept') === 'application/vnd.app.v2+json'
            ? 'v2'
            : 'v1';

        $request->attributes->set('api_version', $version);

        return $next($request);
    }
}
```

### 4.2 Feature Flags for API Endpoints

```php
// config/api-features.php
return [
    'v2_orders_endpoint' => env('API_FEATURE_V2_ORDERS', false),
    'bulk_operations' => env('API_FEATURE_BULK_OPS', false),
    'advanced_filtering' => env('API_FEATURE_ADVANCED_FILTER', true),
];

// Usage in controller
public function index(Request $request): OrderCollection
{
    $query = QueryBuilder::for(Order::class);

    if (config('api-features.advanced_filtering')) {
        $query->allowedFilters(['status', 'customer_id', 'date_range', 'total_min', 'total_max']);
    } else {
        $query->allowedFilters(['status', 'customer_id']);
    }

    return new OrderCollection($query->paginate());
}
```

### 4.3 Zero-Downtime Migration

When adding or changing API fields, follow this sequence:

**Step 1 — Add new fields (backward compatible):**

```php
// Migration: add new column, keep old one
Schema::table('orders', function (Blueprint $table) {
    $table->string('fulfillment_status')->nullable()->after('status');
});
```

**Step 2 — Dual-write in the model:**

```php
// app/Models/Order.php
protected static function booted(): void
{
    static::saving(function (Order $order) {
        // Write to both old and new columns during transition
        if ($order->isDirty('status')) {
            $order->fulfillment_status = match ($order->status) {
                'pending' => 'awaiting',
                'shipped' => 'in_transit',
                'delivered' => 'fulfilled',
                default => $order->status,
            };
        }
    });
}
```

**Step 3 — API resource supports both:**

```php
public function toArray(Request $request): array
{
    return [
        'attributes' => [
            'status' => $this->status, // V1 consumers still get this
            'fulfillment_status' => $this->fulfillment_status, // V2 consumers use this
        ],
    ];
}
```

**Step 4 — Remove old field after deprecation period:**

```php
// After all consumers have migrated to fulfillment_status
Schema::table('orders', function (Blueprint $table) {
    $table->dropColumn('status');
});
```

### 4.4 Deployment Checklist

```markdown
## API Version Deployment Checklist

- [ ] OpenAPI spec updated for new version
- [ ] All new endpoints have Pest tests passing
- [ ] Contract tests pass against updated spec
- [ ] Rate limiting configured for new endpoints
- [ ] Feature flags set to disabled in production .env
- [ ] Database migrations are backward-compatible
- [ ] Old API version still functional (run V1 test suite)
- [ ] Changelog entry written
- [ ] Consumer notification sent (if breaking changes)
- [ ] Monitoring/alerting configured for new endpoints
- [ ] Rollback plan documented
```

---

## 5. `/api docs` — Documentation Generation

### 5.1 Detect Documentation Tool

Check `composer.json` for:
- `knuckleswtf/scribe` — Scribe (most common)
- `dedoc/scramble` — Scramble (zero-config)
- Neither — recommend installing one

### 5.2 Scribe Configuration

```php
// config/scribe.php
return [
    'title' => 'My API Documentation',
    'description' => 'REST API for the application',
    'base_url' => env('APP_URL'),
    'routes' => [
        [
            'match' => [
                'prefixes' => ['api/v1/*'],
                'domains' => ['*'],
            ],
            'apply' => [
                'headers' => [
                    'Authorization' => 'Bearer {YOUR_AUTH_TOKEN}',
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ],
            ],
        ],
    ],
    'type' => 'external_laravel',  // or 'laravel' for built-in
    'theme' => 'default',
    'try_it_out' => [
        'enabled' => true,
    ],
    'auth' => [
        'default' => true,
        'in' => 'bearer',
        'name' => 'Authorization',
        'use_value' => env('SCRIBE_AUTH_TOKEN'),
    ],
];
```

### 5.3 Controller Annotations for Scribe

```php
/**
 * List Orders
 *
 * Retrieve a paginated list of orders for the authenticated user.
 * Results can be filtered by status and sorted by date or total.
 *
 * @group Orders
 *
 * @queryParam filter[status] string Filter by order status. Example: pending
 * @queryParam filter[customer_id] integer Filter by customer. Example: 1
 * @queryParam sort string Sort field. Prefix with - for descending. Example: -created_at
 * @queryParam per_page integer Results per page (max 100). Example: 15
 * @queryParam page integer Page number. Example: 1
 *
 * @response 200 scenario="Success" {
 *   "data": [{"id": 1, "type": "orders", "attributes": {"status": "pending", "total": 59.98}}],
 *   "links": {"first": "...", "last": "...", "prev": null, "next": "..."},
 *   "meta": {"current_page": 1, "last_page": 2, "per_page": 15, "total": 20}
 * }
 * @response 401 scenario="Unauthenticated" {"type": "https://httpstatuses.com/401", "title": "Unauthorized", "status": 401, "detail": "Unauthenticated."}
 */
public function index(Request $request): OrderCollection
```

### 5.4 Scramble Setup (Zero-config alternative)

```php
// config/scramble.php
return [
    'api_path' => 'api/v1',
    'api_domain' => null,
    'info' => [
        'version' => '1.0.0',
    ],
    'servers' => null, // auto-detected from APP_URL
];
```

Scramble auto-generates OpenAPI from your code — no annotations needed. Access at `/docs/api`.

### 5.5 Changelog Generation

Generate a changelog entry for each API version:

```markdown
# API Changelog

## v1.2.0 — 2026-02-27

### Added
- `GET /api/v1/orders?filter[date_range]=2026-01-01,2026-01-31` — date range filtering
- `fulfillment_status` field on Order resource

### Changed
- Pagination default changed from 10 to 15 per page

### Deprecated
- `status` field on Order resource — use `fulfillment_status` instead (removal: v2.0.0)

### Fixed
- Rate limit header `X-RateLimit-Remaining` now returns correct count
```

---

## 6. `/api govern` — API Governance

### 6.1 Breaking Change Detection

Read `references/api-governance-patterns.md` for the complete rule set.

Scan for these breaking changes when comparing two versions of an OpenAPI spec or codebase:

| Change Type | Breaking? | Action |
|---|---|---|
| Remove endpoint | Yes | Must deprecate first, remove in next major |
| Remove response field | Yes | Must deprecate first |
| Add required request field | Yes | Make optional with default, or new version |
| Change field type | Yes | New field + deprecate old |
| Change URL path | Yes | Redirect old path + deprecate |
| Add optional request field | No | Safe to deploy |
| Add response field | No | Safe to deploy |
| Add new endpoint | No | Safe to deploy |
| Change error message text | No | Safe (consumers should not match on text) |

### 6.2 Deprecation Policy

Generate a deprecation notice for any deprecated endpoint or field:

```php
// app/Http/Middleware/DeprecationNotice.php
class DeprecationNotice
{
    private array $deprecations = [
        'GET /api/v1/orders' => [
            'field' => 'status',
            'replacement' => 'fulfillment_status',
            'sunset' => '2026-06-01',
        ],
    ];

    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $path = $request->method() . ' ' . '/' . ltrim($request->path(), '/');
        if (isset($this->deprecations[$path])) {
            $dep = $this->deprecations[$path];
            $response->headers->set('Deprecation', 'true');
            $response->headers->set('Sunset', $dep['sunset']);
            $response->headers->set('Link', '<https://docs.example.com/migration>; rel="deprecation"');
        }

        return $response;
    }
}
```

### 6.3 API Review Checklist

Run this checklist before any API merge/release:

```markdown
## API Review Checklist

### Design
- [ ] Resource names are plural nouns
- [ ] Paths use kebab-case for multi-word segments
- [ ] No verbs in paths (use HTTP methods)
- [ ] Nested resources max 2 levels deep
- [ ] Consistent ID format across all resources

### Request/Response
- [ ] All endpoints return consistent envelope structure
- [ ] Error responses follow RFC 7807 format
- [ ] Timestamps use ISO 8601 format
- [ ] Pagination metadata included on list endpoints
- [ ] No sensitive data in responses (passwords, tokens, secrets)

### Security
- [ ] All mutating endpoints require authentication
- [ ] Authorization policies enforce ownership/tenancy
- [ ] Rate limiting configured per endpoint tier
- [ ] Input validation on every request field
- [ ] Mass assignment protection on all models

### Compatibility
- [ ] No breaking changes without version bump
- [ ] Deprecated fields have Sunset header
- [ ] New required fields have defaults or are in new version
- [ ] Backward compatibility tests pass for previous version
```

### 6.4 Consumer Notification

When breaking changes are planned, generate a notification:

```markdown
## API Breaking Change Notice

**Affected API:** Orders API v1
**Change:** The `status` field is being replaced by `fulfillment_status`
**Timeline:**
- Now: Both fields returned in responses
- 2026-04-01: `status` field marked deprecated (Deprecation header added)
- 2026-06-01: `status` field removed from responses

**Migration Steps:**
1. Update your code to read `fulfillment_status` instead of `status`
2. Update any filters using `filter[status]` to `filter[fulfillment_status]`
3. Test against the staging API: https://staging.example.com/api/v1/orders

**Questions?** Contact api-support@example.com
```

---

## 7. `/api security` — OWASP API Security Audit

### 7.1 Security Scan

Read `references/api-security-checklist.md` for the full OWASP API Top 10 checklist.

Audit the codebase for each of these categories:

| # | OWASP API Risk | What to Check |
|---|---|---|
| API1 | Broken Object Level Auth | Every endpoint checks ownership/tenancy |
| API2 | Broken Authentication | Token handling, session management |
| API3 | Broken Object Property Auth | Mass assignment, hidden fields exposed |
| API4 | Unrestricted Resource Consumption | Rate limiting, pagination limits |
| API5 | Broken Function Level Auth | Admin-only routes properly gated |
| API6 | Unrestricted Access to Sensitive Flows | Password reset, payment, etc. |
| API7 | Server-Side Request Forgery | URL inputs validated |
| API8 | Security Misconfiguration | CORS, debug mode, stack traces |
| API9 | Improper Inventory Management | Undocumented endpoints, old versions |
| API10 | Unsafe Consumption of APIs | Third-party API calls validated |

### 7.2 Laravel-Specific Security Patterns

**Mass Assignment Prevention:**

```php
// app/Models/Order.php
class Order extends Model
{
    // Explicitly list fillable fields — never use $guarded = []
    protected $fillable = [
        'customer_id',
        'status',
        'notes',
    ];

    // Hide sensitive fields from serialization
    protected $hidden = [
        'internal_notes',
        'cost_price',
        'margin',
    ];
}
```

**SQL Injection Prevention:**

```php
// NEVER do this
Order::whereRaw("status = '{$request->status}'")->get();

// DO this — parameterized queries
Order::where('status', $request->input('status'))->get();

// For complex queries, use bindings
Order::whereRaw('total > ? AND created_at > ?', [
    $request->input('min_total'),
    $request->input('start_date'),
])->get();
```

**CORS Configuration:**

```php
// config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', 'https://app.example.com')),
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
    'exposed_headers' => ['X-RateLimit-Limit', 'X-RateLimit-Remaining', 'Deprecation', 'Sunset'],
    'max_age' => 86400,
    'supports_credentials' => true,
];
```

**Rate Limiting Tiers:**

```php
// app/Providers/AppServiceProvider.php
RateLimiter::for('api-public', function (Request $request) {
    return Limit::perMinute(30)->by($request->ip());
});

RateLimiter::for('api-authenticated', function (Request $request) {
    return Limit::perMinute(120)->by($request->user()->id);
});

RateLimiter::for('api-admin', function (Request $request) {
    return Limit::none();
});

RateLimiter::for('api-sensitive', function (Request $request) {
    return Limit::perMinute(5)->by($request->user()->id);
});
```

### 7.3 Security Headers Middleware

```php
// app/Http/Middleware/ApiSecurityHeaders.php
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

        // Remove server information
        $response->headers->remove('X-Powered-By');
        $response->headers->remove('Server');

        return $response;
    }
}
```

### 7.4 Present Security Audit

Present findings as a report:

```
API Security Audit — [Project Name]
====================================
Generated: [date]

Score: 72/100

OWASP API Top 10 Coverage:
  API1 - Object Auth         ████████████████  PASS
  API2 - Authentication      ████████████░░░░  WARN — token expiry not set
  API3 - Property Auth       ████████████████  PASS
  API4 - Resource Limits     ████████░░░░░░░░  FAIL — no rate limit on /api/v1/reports
  API5 - Function Auth       ████████████████  PASS
  API6 - Sensitive Flows     ████████████░░░░  WARN — password reset has no rate limit
  API7 - SSRF               ████████████████  PASS
  API8 - Misconfiguration    ████████░░░░░░░░  FAIL — APP_DEBUG=true in .env.example
  API9 - Inventory           ████████████░░░░  WARN — /api/v1/debug route undocumented
  API10 - Unsafe Consumption ████████████████  PASS

Critical Issues:
  1. [CRITICAL] No rate limiting on /api/v1/reports/export
  2. [HIGH] APP_DEBUG should be false in production examples
  3. [MEDIUM] Token expiry not configured — tokens live forever
  4. [LOW] /api/v1/debug route exists but not in OpenAPI spec

Recommendations:
  1. Add rate limiter 'api-sensitive' to export endpoints
  2. Set APP_DEBUG=false in .env.example
  3. Set Sanctum token expiry: 'expiration' => 60 * 24 in config/sanctum.php
  4. Remove or document /api/v1/debug route
```

---

## Reference Files

| File | Read When |
|---|---|
| `references/openapi-template.md` | Generating an OpenAPI 3.1 spec from scratch |
| `references/api-security-checklist.md` | Running a security audit or hardening APIs |
| `references/api-governance-patterns.md` | Checking for breaking changes or setting deprecation policy |
| `references/api-test-patterns.md` | Generating Pest API tests or contract tests |
