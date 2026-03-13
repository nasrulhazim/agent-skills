# API Test Patterns for Pest

Complete Pest API test patterns for Laravel REST APIs. Read this file when
generating tests via `/api test` or adding test coverage to existing endpoints.

---

## Test File Structure

Every API resource gets its own test file at `tests/Feature/Api/V1/{Resource}Test.php`.

```php
<?php

use App\Models\User;
use App\Models\Order;
use App\Models\Product;

use function Pest\Laravel\{getJson, postJson, putJson, patchJson, deleteJson, actingAs};

beforeEach(function () {
    $this->user = User::factory()->create();
    $this->admin = User::factory()->admin()->create();
    $this->otherUser = User::factory()->create();
});
```

---

## CRUD Endpoint Tests

### Index (List) Endpoint

```php
describe('GET /api/v1/orders', function () {
    it('returns paginated orders for authenticated user', function () {
        Order::factory()->count(20)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(15, 'data') // default per_page
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'attributes' => [
                            'status',
                            'total',
                            'notes',
                            'created_at',
                            'updated_at',
                        ],
                        'relationships',
                        'links' => ['self'],
                    ],
                ],
                'links' => ['first', 'last', 'prev', 'next'],
                'meta' => ['current_page', 'from', 'last_page', 'path', 'per_page', 'to', 'total'],
            ]);
    });

    it('only returns orders belonging to the authenticated user', function () {
        Order::factory()->count(3)->for($this->user, 'customer')->create();
        Order::factory()->count(5)->for($this->otherUser, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(3, 'data');
    });

    it('returns empty data array when no orders exist', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(0, 'data')
            ->assertJsonPath('meta.total', 0);
    });

    it('respects custom per_page parameter', function () {
        Order::factory()->count(20)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?per_page=5')
            ->assertOk()
            ->assertJsonCount(5, 'data')
            ->assertJsonPath('meta.per_page', 5);
    });

    it('caps per_page at maximum of 100', function () {
        Order::factory()->count(5)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?per_page=500')
            ->assertOk()
            ->assertJsonPath('meta.per_page', 100);
    });

    it('returns correct pagination links on page 2', function () {
        Order::factory()->count(30)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?page=2')
            ->assertOk()
            ->assertJsonPath('meta.current_page', 2)
            ->assertJsonPath('links.prev', fn ($prev) => $prev !== null);
    });
});
```

### Store (Create) Endpoint

```php
describe('POST /api/v1/orders', function () {
    it('creates an order with valid data', function () {
        $product = Product::factory()->create(['price' => 29.99]);

        $payload = [
            'customer_id' => $this->user->id,
            'items' => [
                [
                    'product_id' => $product->id,
                    'quantity' => 2,
                    'unit_price' => 29.99,
                ],
            ],
            'notes' => 'Please gift wrap',
        ];

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated()
            ->assertJsonPath('data.type', 'orders')
            ->assertJsonPath('data.attributes.status', 'pending')
            ->assertJsonPath('data.attributes.notes', 'Please gift wrap');

        $this->assertDatabaseHas('orders', [
            'customer_id' => $this->user->id,
            'status' => 'pending',
            'notes' => 'Please gift wrap',
        ]);
    });

    it('creates an order with multiple items', function () {
        $products = Product::factory()->count(3)->create();

        $payload = [
            'customer_id' => $this->user->id,
            'items' => $products->map(fn ($p) => [
                'product_id' => $p->id,
                'quantity' => 1,
                'unit_price' => $p->price,
            ])->toArray(),
        ];

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', $payload)
            ->assertCreated();

        $this->assertDatabaseCount('order_items', 3);
    });

    it('creates an order without optional notes', function () {
        $product = Product::factory()->create();

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [
                    ['product_id' => $product->id, 'quantity' => 1, 'unit_price' => 10.00],
                ],
            ])
            ->assertCreated()
            ->assertJsonPath('data.attributes.notes', null);
    });

    it('returns Location header with created resource URL', function () {
        $product = Product::factory()->create();

        $response = actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [
                    ['product_id' => $product->id, 'quantity' => 1, 'unit_price' => 10.00],
                ],
            ]);

        $response->assertCreated();
        $response->assertHeader('Location');
    });
});
```

### Show (Read) Endpoint

```php
describe('GET /api/v1/orders/{order}', function () {
    it('returns a single order for the owner', function () {
        $order = Order::factory()->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $order->id)
            ->assertJsonPath('data.type', 'orders')
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'type',
                    'attributes',
                    'relationships',
                    'links',
                ],
            ]);
    });

    it('returns 404 for non-existent order', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders/99999')
            ->assertNotFound()
            ->assertJsonPath('status', 404)
            ->assertJsonPath('title', 'Not Found');
    });

    it('returns 403 when accessing another user order', function () {
        $otherOrder = Order::factory()->for($this->otherUser, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$otherOrder->id}")
            ->assertForbidden();
    });

    it('includes related resources when requested', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->has(OrderItem::factory()->count(3), 'items')
            ->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}?include=items")
            ->assertOk()
            ->assertJsonCount(3, 'data.relationships.items');
    });
});
```

### Update Endpoint

```php
describe('PUT /api/v1/orders/{order}', function () {
    it('updates an order with valid data', function () {
        $order = Order::factory()->for($this->user, 'customer')->create([
            'notes' => 'Old notes',
        ]);

        actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/orders/{$order->id}", [
                'notes' => 'Updated notes',
            ])
            ->assertOk()
            ->assertJsonPath('data.attributes.notes', 'Updated notes');

        $this->assertDatabaseHas('orders', [
            'id' => $order->id,
            'notes' => 'Updated notes',
        ]);
    });

    it('returns 403 when updating another user order', function () {
        $otherOrder = Order::factory()->for($this->otherUser, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->putJson("/api/v1/orders/{$otherOrder->id}", [
                'notes' => 'Hacked',
            ])
            ->assertForbidden();
    });

    it('returns 404 for non-existent order', function () {
        actingAs($this->user, 'sanctum')
            ->putJson('/api/v1/orders/99999', ['notes' => 'test'])
            ->assertNotFound();
    });

    it('admin can update order status', function () {
        $order = Order::factory()->for($this->user, 'customer')->create([
            'status' => 'pending',
        ]);

        actingAs($this->admin, 'sanctum')
            ->putJson("/api/v1/orders/{$order->id}", [
                'status' => 'processing',
            ])
            ->assertOk()
            ->assertJsonPath('data.attributes.status', 'processing');
    });
});
```

### Destroy (Delete) Endpoint

```php
describe('DELETE /api/v1/orders/{order}', function () {
    it('deletes a pending order', function () {
        $order = Order::factory()->for($this->user, 'customer')->create([
            'status' => 'pending',
        ]);

        actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/orders/{$order->id}")
            ->assertNoContent();

        $this->assertDatabaseMissing('orders', ['id' => $order->id]);
    });

    it('returns 409 when deleting a non-pending order', function () {
        $order = Order::factory()->for($this->user, 'customer')->create([
            'status' => 'shipped',
        ]);

        actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/orders/{$order->id}")
            ->assertConflict()
            ->assertJsonPath('status', 409);
    });

    it('returns 403 when deleting another user order', function () {
        $otherOrder = Order::factory()->for($this->otherUser, 'customer')->create([
            'status' => 'pending',
        ]);

        actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/orders/{$otherOrder->id}")
            ->assertForbidden();
    });

    it('returns 404 for non-existent order', function () {
        actingAs($this->user, 'sanctum')
            ->deleteJson('/api/v1/orders/99999')
            ->assertNotFound();
    });
});
```

---

## Authentication Tests

```php
describe('Authentication', function () {
    it('returns 401 for unauthenticated GET request', function () {
        getJson('/api/v1/orders')
            ->assertUnauthorized()
            ->assertJsonPath('status', 401)
            ->assertJsonPath('title', 'Unauthorized');
    });

    it('returns 401 for unauthenticated POST request', function () {
        postJson('/api/v1/orders', [])
            ->assertUnauthorized();
    });

    it('returns 401 for unauthenticated PUT request', function () {
        putJson('/api/v1/orders/1', [])
            ->assertUnauthorized();
    });

    it('returns 401 for unauthenticated DELETE request', function () {
        deleteJson('/api/v1/orders/1')
            ->assertUnauthorized();
    });

    it('returns 401 for expired token', function () {
        $token = $this->user->createToken('test', ['*'], now()->subHour());

        getJson('/api/v1/orders', [
            'Authorization' => "Bearer {$token->plainTextToken}",
        ])->assertUnauthorized();
    });

    it('returns 401 for revoked token', function () {
        $token = $this->user->createToken('test');
        $token->accessToken->delete(); // Revoke

        getJson('/api/v1/orders', [
            'Authorization' => "Bearer {$token->plainTextToken}",
        ])->assertUnauthorized();
    });

    it('accepts valid Sanctum token', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk();
    });
});
```

---

## Validation Tests

```php
describe('Validation: POST /api/v1/orders', function () {
    it('requires customer_id', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'items' => [['product_id' => 1, 'quantity' => 1, 'unit_price' => 10]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['customer_id']);
    });

    it('requires items array', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items']);
    });

    it('requires at least one item', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items']);
    });

    it('validates customer_id exists', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => 99999,
                'items' => [['product_id' => 1, 'quantity' => 1, 'unit_price' => 10]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['customer_id']);
    });

    it('validates item product_id exists', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [['product_id' => 99999, 'quantity' => 1, 'unit_price' => 10]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items.0.product_id']);
    });

    it('validates quantity is at least 1', function () {
        $product = Product::factory()->create();

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [['product_id' => $product->id, 'quantity' => 0, 'unit_price' => 10]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items.0.quantity']);
    });

    it('validates quantity does not exceed 999', function () {
        $product = Product::factory()->create();

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [['product_id' => $product->id, 'quantity' => 1000, 'unit_price' => 10]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items.0.quantity']);
    });

    it('validates unit_price is not negative', function () {
        $product = Product::factory()->create();

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [['product_id' => $product->id, 'quantity' => 1, 'unit_price' => -5]],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['items.0.unit_price']);
    });

    it('validates notes max length', function () {
        $product = Product::factory()->create();

        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [
                'customer_id' => $this->user->id,
                'items' => [['product_id' => $product->id, 'quantity' => 1, 'unit_price' => 10]],
                'notes' => str_repeat('a', 1001),
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['notes']);
    });

    it('returns RFC 7807 format for validation errors', function () {
        actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', [])
            ->assertUnprocessable()
            ->assertJsonStructure([
                'type',
                'title',
                'status',
                'detail',
                'errors',
            ])
            ->assertJsonPath('type', 'https://httpstatuses.com/422')
            ->assertJsonPath('title', 'Unprocessable Entity')
            ->assertJsonPath('status', 422);
    });
});
```

---

## Error Response Tests

```php
describe('Error Responses', function () {
    it('returns RFC 7807 format for 401', function () {
        getJson('/api/v1/orders')
            ->assertUnauthorized()
            ->assertJsonStructure(['type', 'title', 'status', 'detail'])
            ->assertJsonPath('status', 401);
    });

    it('returns RFC 7807 format for 403', function () {
        $otherOrder = Order::factory()->for($this->otherUser, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$otherOrder->id}")
            ->assertForbidden()
            ->assertJsonStructure(['type', 'title', 'status', 'detail'])
            ->assertJsonPath('status', 403);
    });

    it('returns RFC 7807 format for 404', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders/99999')
            ->assertNotFound()
            ->assertJsonStructure(['type', 'title', 'status', 'detail'])
            ->assertJsonPath('status', 404);
    });

    it('returns RFC 7807 format for 409', function () {
        $order = Order::factory()->for($this->user, 'customer')->create([
            'status' => 'shipped',
        ]);

        actingAs($this->user, 'sanctum')
            ->deleteJson("/api/v1/orders/{$order->id}")
            ->assertConflict()
            ->assertJsonStructure(['type', 'title', 'status', 'detail'])
            ->assertJsonPath('status', 409);
    });

    it('does not expose stack traces in production', function () {
        app()['config']->set('app.debug', false);

        // Force an internal error
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/force-error')
            ->assertServerError()
            ->assertJsonMissing(['exception', 'file', 'line', 'trace']);
    });
});
```

---

## Pagination Tests

```php
describe('Pagination', function () {
    beforeEach(function () {
        Order::factory()->count(50)->for($this->user, 'customer')->create();
    });

    it('defaults to 15 items per page', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertJsonCount(15, 'data')
            ->assertJsonPath('meta.per_page', 15)
            ->assertJsonPath('meta.total', 50);
    });

    it('accepts custom per_page', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?per_page=10')
            ->assertOk()
            ->assertJsonCount(10, 'data')
            ->assertJsonPath('meta.per_page', 10);
    });

    it('navigates to specific page', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?page=2&per_page=10')
            ->assertOk()
            ->assertJsonCount(10, 'data')
            ->assertJsonPath('meta.current_page', 2);
    });

    it('returns last page with remaining items', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?page=4&per_page=15')
            ->assertOk()
            ->assertJsonCount(5, 'data') // 50 total, page 4 of 15 = 5 remaining
            ->assertJsonPath('meta.current_page', 4)
            ->assertJsonPath('meta.last_page', 4);
    });

    it('returns empty data for page beyond last', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?page=100')
            ->assertOk()
            ->assertJsonCount(0, 'data');
    });

    it('includes pagination links', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?page=2')
            ->assertOk()
            ->assertJsonStructure([
                'links' => ['first', 'last', 'prev', 'next'],
            ]);
    });
});
```

---

## Filtering Tests

```php
describe('Filtering', function () {
    it('filters by status', function () {
        Order::factory()->for($this->user, 'customer')->create(['status' => 'pending']);
        Order::factory()->for($this->user, 'customer')->create(['status' => 'pending']);
        Order::factory()->for($this->user, 'customer')->create(['status' => 'shipped']);

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?filter[status]=pending')
            ->assertOk()
            ->assertJsonCount(2, 'data');
    });

    it('filters by customer_id', function () {
        $customer = User::factory()->create();
        Order::factory()->for($customer, 'customer')->create();
        Order::factory()->for($this->user, 'customer')->create();

        actingAs($this->admin, 'sanctum')
            ->getJson("/api/v1/orders?filter[customer_id]={$customer->id}")
            ->assertOk()
            ->assertJsonCount(1, 'data');
    });

    it('ignores unknown filter parameters', function () {
        Order::factory()->count(3)->for($this->user, 'customer')->create();

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?filter[unknown_field]=value')
            ->assertOk()
            ->assertJsonCount(3, 'data'); // Returns all, unknown filter ignored
    });

    it('combines multiple filters', function () {
        Order::factory()->for($this->user, 'customer')->create([
            'status' => 'pending',
        ]);
        Order::factory()->for($this->user, 'customer')->create([
            'status' => 'shipped',
        ]);

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders?filter[status]=pending&filter[customer_id]={$this->user->id}")
            ->assertOk()
            ->assertJsonCount(1, 'data');
    });
});
```

---

## Sorting Tests

```php
describe('Sorting', function () {
    it('sorts by created_at ascending', function () {
        $old = Order::factory()->for($this->user, 'customer')->create([
            'created_at' => now()->subDays(2),
        ]);
        $new = Order::factory()->for($this->user, 'customer')->create([
            'created_at' => now(),
        ]);

        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?sort=created_at')
            ->assertOk();

        $ids = collect($response->json('data'))->pluck('id')->toArray();
        expect($ids[0])->toBe($old->id);
        expect($ids[1])->toBe($new->id);
    });

    it('sorts by created_at descending with - prefix', function () {
        $old = Order::factory()->for($this->user, 'customer')->create([
            'created_at' => now()->subDays(2),
        ]);
        $new = Order::factory()->for($this->user, 'customer')->create([
            'created_at' => now(),
        ]);

        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?sort=-created_at')
            ->assertOk();

        $ids = collect($response->json('data'))->pluck('id')->toArray();
        expect($ids[0])->toBe($new->id);
        expect($ids[1])->toBe($old->id);
    });

    it('sorts by total', function () {
        Order::factory()->for($this->user, 'customer')->create(['total' => 100]);
        Order::factory()->for($this->user, 'customer')->create(['total' => 50]);
        Order::factory()->for($this->user, 'customer')->create(['total' => 200]);

        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders?sort=total')
            ->assertOk();

        $totals = collect($response->json('data'))->pluck('attributes.total')->toArray();
        expect($totals)->toBe([50, 100, 200]);
    });
});
```

---

## Rate Limiting Tests

```php
describe('Rate Limiting', function () {
    it('returns rate limit headers', function () {
        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertOk()
            ->assertHeader('X-RateLimit-Limit')
            ->assertHeader('X-RateLimit-Remaining');
    });

    it('returns 429 when rate limit exceeded', function () {
        // Simulate exceeding the rate limit
        $limiterKey = 'api-authenticated:' . $this->user->id;
        RateLimiter::hit($limiterKey, 60);

        // Hit the limit by making many requests
        for ($i = 0; $i < 121; $i++) {
            RateLimiter::hit($limiterKey);
        }

        actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders')
            ->assertTooManyRequests()
            ->assertHeader('Retry-After');
    });

    it('has stricter rate limit for unauthenticated requests', function () {
        // Public endpoints should have lower rate limits
        for ($i = 0; $i < 31; $i++) {
            RateLimiter::hit('api-public:' . request()->ip());
        }

        getJson('/api/v1/products')
            ->assertTooManyRequests();
    });
});
```

---

## Contract Tests (OpenAPI Compliance)

```php
describe('Contract: Order Resource', function () {
    it('matches OpenAPI schema for single resource', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->create();

        $response = actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}");

        $response->assertOk();
        $data = $response->json('data');

        // Verify top-level structure
        expect($data)->toHaveKeys(['id', 'type', 'attributes', 'relationships', 'links']);
        expect($data['type'])->toBe('orders');
        expect($data['id'])->toBeInt();

        // Verify attributes
        $attrs = $data['attributes'];
        expect($attrs)->toHaveKeys(['status', 'total', 'notes', 'created_at', 'updated_at']);
        expect($attrs['status'])->toBeIn(['pending', 'processing', 'shipped', 'delivered', 'cancelled']);
        expect($attrs['total'])->toBeNumeric();
        expect($attrs['created_at'])->toMatch('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/');
        expect($attrs['updated_at'])->toMatch('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/');

        // Verify links
        expect($data['links'])->toHaveKey('self');
        expect($data['links']['self'])->toContain("/api/v1/orders/{$order->id}");
    });

    it('matches OpenAPI schema for collection', function () {
        Order::factory()->count(3)->for($this->user, 'customer')->create();

        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders');

        $response->assertOk();

        // Verify envelope structure
        $json = $response->json();
        expect($json)->toHaveKeys(['data', 'links', 'meta']);
        expect($json['data'])->toBeArray();
        expect($json['links'])->toHaveKeys(['first', 'last', 'prev', 'next']);
        expect($json['meta'])->toHaveKeys(['current_page', 'from', 'last_page', 'path', 'per_page', 'to', 'total']);

        // Verify each item in collection
        foreach ($json['data'] as $item) {
            expect($item)->toHaveKeys(['id', 'type', 'attributes', 'relationships', 'links']);
            expect($item['type'])->toBe('orders');
        }
    });

    it('matches OpenAPI error schema for 422', function () {
        $response = actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/orders', []);

        $response->assertUnprocessable();
        $json = $response->json();

        expect($json)->toHaveKeys(['type', 'title', 'status', 'detail', 'errors']);
        expect($json['type'])->toBeString()->toStartWith('https://');
        expect($json['title'])->toBe('Unprocessable Entity');
        expect($json['status'])->toBe(422);
        expect($json['errors'])->toBeArray();
    });

    it('matches OpenAPI error schema for 401', function () {
        $response = getJson('/api/v1/orders');

        $response->assertUnauthorized();
        $json = $response->json();

        expect($json)->toHaveKeys(['type', 'title', 'status', 'detail']);
        expect($json['status'])->toBe(401);
    });

    it('matches OpenAPI error schema for 404', function () {
        $response = actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/orders/99999');

        $response->assertNotFound();
        $json = $response->json();

        expect($json)->toHaveKeys(['type', 'title', 'status', 'detail']);
        expect($json['status'])->toBe(404);
    });
});
```

---

## Include / Relationship Tests

```php
describe('Includes', function () {
    it('includes customer when requested', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}?include=customer")
            ->assertOk()
            ->assertJsonPath('data.relationships.customer.id', $this->user->id);
    });

    it('includes items when requested', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->has(OrderItem::factory()->count(3), 'items')
            ->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}?include=items")
            ->assertOk()
            ->assertJsonCount(3, 'data.relationships.items');
    });

    it('includes multiple relationships', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->has(OrderItem::factory()->count(2), 'items')
            ->create();

        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}?include=customer,items")
            ->assertOk()
            ->assertJsonPath('data.relationships.customer.id', $this->user->id)
            ->assertJsonCount(2, 'data.relationships.items');
    });

    it('ignores disallowed includes', function () {
        $order = Order::factory()
            ->for($this->user, 'customer')
            ->create();

        // Should not fail, just ignore the disallowed include
        actingAs($this->user, 'sanctum')
            ->getJson("/api/v1/orders/{$order->id}?include=secret_data")
            ->assertOk();
    });
});
```

---

## Test Helper Traits

```php
// tests/Traits/ApiTestHelpers.php
trait ApiTestHelpers
{
    protected function authenticatedUser(array $attributes = []): User
    {
        return User::factory()->create($attributes);
    }

    protected function adminUser(array $attributes = []): User
    {
        return User::factory()->admin()->create($attributes);
    }

    protected function assertJsonApiResource(TestResponse $response, string $type): void
    {
        $response->assertJsonStructure([
            'data' => [
                'id',
                'type',
                'attributes',
                'links',
            ],
        ]);
        $response->assertJsonPath('data.type', $type);
    }

    protected function assertJsonApiCollection(TestResponse $response): void
    {
        $response->assertJsonStructure([
            'data',
            'links' => ['first', 'last', 'prev', 'next'],
            'meta' => ['current_page', 'last_page', 'per_page', 'total'],
        ]);
    }

    protected function assertRfc7807Error(TestResponse $response, int $status): void
    {
        $response->assertStatus($status);
        $response->assertJsonStructure(['type', 'title', 'status', 'detail']);
        $response->assertJsonPath('status', $status);
    }
}
```
