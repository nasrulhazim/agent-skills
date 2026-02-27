# OpenAPI 3.1 Template for Laravel APIs

Base template for generating OpenAPI specifications from API discovery interviews.
Read this file when generating a new OpenAPI spec via `/api design`.

---

## Complete Template

```yaml
openapi: "3.1.0"
info:
  title: "{API_NAME}"
  description: |
    {API_DESCRIPTION}

    ## Authentication
    This API uses Bearer token authentication via Laravel Sanctum.
    Include your token in the Authorization header:
    `Authorization: Bearer {your-token}`

    ## Rate Limiting
    - Public endpoints: 30 requests/minute
    - Authenticated endpoints: 120 requests/minute
    - Admin endpoints: unlimited

    ## Error Format
    All errors follow RFC 7807 Problem Details format.
  version: "1.0.0"
  contact:
    name: "{CONTACT_NAME}"
    email: "{CONTACT_EMAIL}"
    url: "{CONTACT_URL}"
  license:
    name: "MIT"
    url: "https://opensource.org/licenses/MIT"

servers:
  - url: "http://localhost:8000/api"
    description: "Local development"
  - url: "https://staging.example.com/api"
    description: "Staging environment"
  - url: "https://api.example.com/api"
    description: "Production"

security:
  - bearerAuth: []

tags:
  - name: Orders
    description: "Order management endpoints"
  - name: Products
    description: "Product catalog endpoints"
  - name: Customers
    description: "Customer management endpoints"

paths:
  /v1/orders:
    get:
      operationId: listOrders
      summary: "List orders"
      description: "Retrieve a paginated list of orders for the authenticated user."
      tags: [Orders]
      parameters:
        - $ref: "#/components/parameters/PageParam"
        - $ref: "#/components/parameters/PerPageParam"
        - $ref: "#/components/parameters/SortParam"
        - name: "filter[status]"
          in: query
          description: "Filter by order status"
          required: false
          schema:
            type: string
            enum: [pending, processing, shipped, delivered, cancelled]
        - name: "filter[customer_id]"
          in: query
          description: "Filter by customer ID"
          required: false
          schema:
            type: integer
        - name: "include"
          in: query
          description: "Include related resources (comma-separated)"
          required: false
          schema:
            type: string
            example: "customer,items"
      responses:
        "200":
          description: "Paginated list of orders"
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: "#/components/schemas/OrderResource"
                  links:
                    $ref: "#/components/schemas/PaginationLinks"
                  meta:
                    $ref: "#/components/schemas/PaginationMeta"
          headers:
            X-RateLimit-Limit:
              $ref: "#/components/headers/X-RateLimit-Limit"
            X-RateLimit-Remaining:
              $ref: "#/components/headers/X-RateLimit-Remaining"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "429":
          $ref: "#/components/responses/TooManyRequests"

    post:
      operationId: createOrder
      summary: "Create an order"
      description: "Create a new order with line items."
      tags: [Orders]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/StoreOrderRequest"
            example:
              customer_id: 1
              items:
                - product_id: 10
                  quantity: 2
                  unit_price: 29.99
                - product_id: 15
                  quantity: 1
                  unit_price: 49.99
              notes: "Please gift wrap"
      responses:
        "201":
          description: "Order created successfully"
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: "#/components/schemas/OrderResource"
          headers:
            Location:
              description: "URL of the created resource"
              schema:
                type: string
                example: "/api/v1/orders/42"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "422":
          $ref: "#/components/responses/ValidationError"

  /v1/orders/{order}:
    get:
      operationId: showOrder
      summary: "Get an order"
      description: "Retrieve a single order by ID."
      tags: [Orders]
      parameters:
        - $ref: "#/components/parameters/OrderIdParam"
        - name: "include"
          in: query
          description: "Include related resources"
          required: false
          schema:
            type: string
            example: "customer,items"
      responses:
        "200":
          description: "Order details"
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: "#/components/schemas/OrderResource"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "403":
          $ref: "#/components/responses/Forbidden"
        "404":
          $ref: "#/components/responses/NotFound"

    put:
      operationId: updateOrder
      summary: "Update an order"
      description: "Update an existing order."
      tags: [Orders]
      parameters:
        - $ref: "#/components/parameters/OrderIdParam"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/UpdateOrderRequest"
            example:
              status: "processing"
              notes: "Updated delivery instructions"
      responses:
        "200":
          description: "Order updated successfully"
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    $ref: "#/components/schemas/OrderResource"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "403":
          $ref: "#/components/responses/Forbidden"
        "404":
          $ref: "#/components/responses/NotFound"
        "422":
          $ref: "#/components/responses/ValidationError"

    delete:
      operationId: deleteOrder
      summary: "Delete an order"
      description: "Delete an order. Only pending orders can be deleted."
      tags: [Orders]
      parameters:
        - $ref: "#/components/parameters/OrderIdParam"
      responses:
        "204":
          description: "Order deleted successfully"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "403":
          $ref: "#/components/responses/Forbidden"
        "404":
          $ref: "#/components/responses/NotFound"
        "409":
          $ref: "#/components/responses/Conflict"

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: "Sanctum Token"
      description: |
        Obtain a token via POST /api/v1/auth/login.
        Include in header: `Authorization: Bearer {token}`

    oauth2:
      type: oauth2
      description: "OAuth 2.0 via Laravel Passport"
      flows:
        authorizationCode:
          authorizationUrl: "https://api.example.com/oauth/authorize"
          tokenUrl: "https://api.example.com/oauth/token"
          refreshUrl: "https://api.example.com/oauth/token"
          scopes:
            orders-read: "Read orders"
            orders-write: "Create and update orders"
            products-read: "Read products"
            admin: "Full administrative access"

  parameters:
    PageParam:
      name: page
      in: query
      description: "Page number for pagination"
      required: false
      schema:
        type: integer
        minimum: 1
        default: 1
        example: 1

    PerPageParam:
      name: per_page
      in: query
      description: "Number of results per page (max 100)"
      required: false
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 15
        example: 15

    SortParam:
      name: sort
      in: query
      description: "Sort field. Prefix with - for descending order."
      required: false
      schema:
        type: string
        example: "-created_at"

    OrderIdParam:
      name: order
      in: path
      description: "Order ID"
      required: true
      schema:
        type: integer
        example: 42

  schemas:
    OrderResource:
      type: object
      properties:
        id:
          type: integer
          example: 42
        type:
          type: string
          example: "orders"
        attributes:
          type: object
          properties:
            status:
              type: string
              enum: [pending, processing, shipped, delivered, cancelled]
              example: "pending"
            total:
              type: number
              format: float
              example: 109.97
            notes:
              type: string
              nullable: true
              example: "Please gift wrap"
            created_at:
              type: string
              format: date-time
              example: "2026-02-27T10:30:00+08:00"
            updated_at:
              type: string
              format: date-time
              example: "2026-02-27T10:30:00+08:00"
        relationships:
          type: object
          properties:
            customer:
              $ref: "#/components/schemas/CustomerResource"
            items:
              type: array
              items:
                $ref: "#/components/schemas/OrderItemResource"
        links:
          type: object
          properties:
            self:
              type: string
              example: "/api/v1/orders/42"

    CustomerResource:
      type: object
      properties:
        id:
          type: integer
          example: 1
        type:
          type: string
          example: "customers"
        attributes:
          type: object
          properties:
            name:
              type: string
              example: "Ahmad bin Abdullah"
            email:
              type: string
              format: email
              example: "ahmad@example.com"

    OrderItemResource:
      type: object
      properties:
        id:
          type: integer
          example: 100
        attributes:
          type: object
          properties:
            product_id:
              type: integer
              example: 10
            quantity:
              type: integer
              example: 2
            unit_price:
              type: number
              format: float
              example: 29.99
            line_total:
              type: number
              format: float
              example: 59.98

    StoreOrderRequest:
      type: object
      required:
        - customer_id
        - items
      properties:
        customer_id:
          type: integer
          description: "ID of the customer placing the order"
          example: 1
        items:
          type: array
          minItems: 1
          description: "Line items for the order"
          items:
            type: object
            required:
              - product_id
              - quantity
              - unit_price
            properties:
              product_id:
                type: integer
                example: 10
              quantity:
                type: integer
                minimum: 1
                maximum: 999
                example: 2
              unit_price:
                type: number
                format: float
                minimum: 0
                example: 29.99
        notes:
          type: string
          maxLength: 1000
          nullable: true
          description: "Optional notes for the order"
          example: "Please gift wrap"

    UpdateOrderRequest:
      type: object
      properties:
        status:
          type: string
          enum: [pending, processing, shipped, delivered, cancelled]
          example: "processing"
        notes:
          type: string
          maxLength: 1000
          nullable: true
          example: "Updated delivery instructions"

    PaginationLinks:
      type: object
      properties:
        first:
          type: string
          example: "/api/v1/orders?page=1"
        last:
          type: string
          example: "/api/v1/orders?page=5"
        prev:
          type: string
          nullable: true
          example: null
        next:
          type: string
          nullable: true
          example: "/api/v1/orders?page=2"

    PaginationMeta:
      type: object
      properties:
        current_page:
          type: integer
          example: 1
        from:
          type: integer
          example: 1
        last_page:
          type: integer
          example: 5
        path:
          type: string
          example: "/api/v1/orders"
        per_page:
          type: integer
          example: 15
        to:
          type: integer
          example: 15
        total:
          type: integer
          example: 68

    ProblemDetails:
      type: object
      description: "RFC 7807 Problem Details"
      required:
        - type
        - title
        - status
      properties:
        type:
          type: string
          format: uri
          description: "URI reference identifying the problem type"
          example: "https://httpstatuses.com/422"
        title:
          type: string
          description: "Short human-readable summary"
          example: "Unprocessable Entity"
        status:
          type: integer
          description: "HTTP status code"
          example: 422
        detail:
          type: string
          description: "Human-readable explanation"
          example: "The given data was invalid."
        instance:
          type: string
          format: uri
          description: "URI reference for the specific occurrence"
        errors:
          type: object
          description: "Field-level validation errors"
          additionalProperties:
            type: array
            items:
              type: string
          example:
            customer_id: ["The customer id field is required."]
            items: ["The items field is required."]

  responses:
    Unauthorized:
      description: "Authentication required"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/401"
            title: "Unauthorized"
            status: 401
            detail: "Unauthenticated."

    Forbidden:
      description: "Insufficient permissions"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/403"
            title: "Forbidden"
            status: 403
            detail: "This action is unauthorized."

    NotFound:
      description: "Resource not found"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/404"
            title: "Not Found"
            status: 404
            detail: "The requested resource was not found."

    Conflict:
      description: "Resource conflict"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/409"
            title: "Conflict"
            status: 409
            detail: "Only pending orders can be deleted."

    ValidationError:
      description: "Validation failed"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/422"
            title: "Unprocessable Entity"
            status: 422
            detail: "The given data was invalid."
            errors:
              customer_id: ["The customer id field is required."]
              items: ["The items field is required."]

    TooManyRequests:
      description: "Rate limit exceeded"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ProblemDetails"
          example:
            type: "https://httpstatuses.com/429"
            title: "Too Many Requests"
            status: 429
            detail: "Rate limit exceeded. Try again in 60 seconds."
      headers:
        Retry-After:
          description: "Seconds until the rate limit resets"
          schema:
            type: integer
            example: 60
        X-RateLimit-Limit:
          $ref: "#/components/headers/X-RateLimit-Limit"
        X-RateLimit-Remaining:
          $ref: "#/components/headers/X-RateLimit-Remaining"

  headers:
    X-RateLimit-Limit:
      description: "Maximum requests per window"
      schema:
        type: integer
        example: 120

    X-RateLimit-Remaining:
      description: "Remaining requests in current window"
      schema:
        type: integer
        example: 115
```

---

## Naming Conventions Quick Reference

| Element | Convention | Example |
|---|---|---|
| Path segments | Plural nouns, kebab-case | `/api/v1/order-items` |
| Query parameters | snake_case | `per_page`, `customer_id` |
| Request body fields | snake_case | `unit_price`, `created_at` |
| Response fields | snake_case | `line_total`, `updated_at` |
| Enum values | snake_case | `pending`, `in_transit` |
| Schema names | PascalCase | `OrderResource`, `StoreOrderRequest` |
| Operation IDs | camelCase | `listOrders`, `createOrder` |
| Tags | PascalCase plural | `Orders`, `Products` |

---

## HTTP Status Code Reference

| Code | Meaning | When to Use |
|---|---|---|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST that creates a resource |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Malformed JSON, invalid Content-Type |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | State conflict (e.g., deleting non-pending order) |
| 422 | Unprocessable Entity | Validation errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

---

## Versioning Patterns in OpenAPI

**URI-based (recommended):**

```yaml
servers:
  - url: "https://api.example.com/api"

paths:
  /v1/orders:
    # V1 endpoints
  /v2/orders:
    # V2 endpoints (when ready)
```

**Header-based:**

```yaml
servers:
  - url: "https://api.example.com/api"

paths:
  /orders:
    get:
      parameters:
        - name: Accept
          in: header
          schema:
            type: string
            enum:
              - "application/vnd.app.v1+json"
              - "application/vnd.app.v2+json"
            default: "application/vnd.app.v1+json"
```
