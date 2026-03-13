# API Governance Patterns

Breaking change detection rules, deprecation policy templates, API review checklists,
versioning strategy comparison, and consumer notification templates.
Read this file when running `/api govern` or reviewing API changes before release.

---

## Breaking Change Detection Rules

### Definitely Breaking (Must Version Bump)

| Change | Why It Breaks | Mitigation |
|---|---|---|
| Remove an endpoint | Consumers calling it get 404 | Deprecate first, remove in next major |
| Remove a response field | Consumers reading it get null/undefined | Deprecate first, dual-return in transition |
| Rename a response field | Consumers reading old name get null | Add new field, deprecate old, remove later |
| Change a field type | Consumers parsing it may crash (string to int) | New field with new type, deprecate old |
| Add a required request field | Existing requests now fail validation | Make optional with default, or new version |
| Narrow an enum (remove values) | Consumers sending removed values get 422 | Keep accepting old values, map internally |
| Change URL path or structure | Consumers' URLs break | Redirect old path (301) + deprecate |
| Change authentication method | Existing tokens/keys stop working | Support both during transition |
| Reduce rate limits | Consumers exceeding new limits get 429 | Announce in advance, give migration time |
| Change error response structure | Consumers' error handling breaks | Keep old format, add new fields alongside |
| Change pagination format | Consumers' pagination logic breaks | New version for structural changes |
| Make a previously optional field required | Existing requests missing it now fail | Default value or new version |

### Not Breaking (Safe to Deploy)

| Change | Why It Is Safe |
|---|---|
| Add a new endpoint | Existing consumers do not call it |
| Add an optional request field | Existing requests still valid without it |
| Add a response field | Consumers should ignore unknown fields |
| Widen an enum (add values) | Existing values still work |
| Increase rate limits | Existing consumers benefit |
| Add a new error code | Consumers handle unknown errors gracefully |
| Change error message text | Consumers should not match on error text |
| Add optional query parameter | Existing requests unaffected |
| Improve performance | Faster is better for everyone |
| Fix a bug in validation | Consumers sending valid data unaffected |

### Grey Area (Evaluate Case by Case)

| Change | Consideration |
|---|---|
| Change default sort order | May affect consumers relying on implicit ordering |
| Change default page size | Consumers assuming a specific page size may break |
| Add middleware (e.g., new header required) | Depends on whether header is optional |
| Change response field from required to optional | Consumers may not handle null |

---

## Deprecation Policy Template

### Standard Deprecation Timeline

```
Phase 1 — Announce (Day 0)
  - Add Deprecation: true header to affected endpoints
  - Add Sunset header with removal date
  - Update API docs with deprecation notice
  - Send consumer notification email/webhook
  - Minimum notice period: 90 days for major changes, 30 days for minor

Phase 2 — Dual Support (Day 0 to Sunset - 14 days)
  - Both old and new behavior available
  - Log usage of deprecated features for tracking
  - Send reminder notifications at 60-day and 30-day marks

Phase 3 — Final Warning (Sunset - 14 days)
  - Send final notification to remaining consumers
  - Include migration guide link in notification
  - Log shows which consumers still use deprecated features

Phase 4 — Removal (Sunset date)
  - Remove deprecated endpoint/field
  - Return 410 Gone for removed endpoints (not 404)
  - Keep 410 response for at least 30 days after removal
```

### Deprecation Headers (RFC 8594)

```php
// app/Http/Middleware/DeprecationHeaders.php
class DeprecationHeaders
{
    /**
     * Registry of deprecated endpoints and fields.
     * Move this to a config file or database for production use.
     */
    private array $deprecations = [
        'GET /api/v1/orders' => [
            'fields' => ['status'],
            'replacement' => 'fulfillment_status',
            'sunset' => '2026-06-01',
            'docs' => 'https://docs.example.com/api/migration/v1-status-field',
        ],
        'GET /api/v1/legacy-reports' => [
            'endpoint' => true,
            'replacement' => 'GET /api/v2/reports',
            'sunset' => '2026-09-01',
            'docs' => 'https://docs.example.com/api/migration/v2-reports',
        ],
    ];

    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $path = $request->method() . ' /' . ltrim($request->path(), '/');

        if (isset($this->deprecations[$path])) {
            $dep = $this->deprecations[$path];

            $response->headers->set('Deprecation', 'true');
            $response->headers->set('Sunset', (new \DateTime($dep['sunset']))->format(\DateTime::RFC7231));
            $response->headers->set('Link', "<{$dep['docs']}>; rel=\"deprecation\"");

            // Log usage for tracking migration progress
            Log::channel('api-deprecation')->info('Deprecated endpoint used', [
                'path' => $path,
                'user_id' => $request->user()?->id,
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);
        }

        return $response;
    }
}
```

### Deprecation Tracking

```php
// Track which consumers are still using deprecated features
// app/Console/Commands/DeprecationReport.php
class DeprecationReport extends Command
{
    protected $signature = 'api:deprecation-report';
    protected $description = 'Show usage of deprecated API features';

    public function handle(): void
    {
        $logs = collect(file(storage_path('logs/api-deprecation.log')))
            ->filter(fn ($line) => str_contains($line, 'Deprecated endpoint used'))
            ->map(fn ($line) => json_decode(
                substr($line, strpos($line, '{')),
                associative: true
            ));

        $grouped = $logs->groupBy('path');

        $this->table(
            ['Endpoint', 'Unique Users', 'Total Calls', 'Last Used'],
            $grouped->map(fn ($calls, $path) => [
                $path,
                $calls->pluck('user_id')->unique()->count(),
                $calls->count(),
                $calls->last()['timestamp'] ?? 'unknown',
            ])
        );
    }
}
```

---

## API Review Checklist

### Design Review (Before Implementation)

```markdown
## API Design Review — [Endpoint/Feature Name]

### Naming & Structure
- [ ] Resource names are plural nouns (e.g., /orders not /order)
- [ ] Path segments use kebab-case (e.g., /order-items not /orderItems)
- [ ] No verbs in paths — HTTP methods express the action
- [ ] Nested resources max 2 levels (/orders/{order}/items is OK, deeper is not)
- [ ] Consistent with existing API resource naming patterns

### HTTP Methods
- [ ] GET for reading (no side effects)
- [ ] POST for creating new resources
- [ ] PUT/PATCH for updating existing resources
- [ ] DELETE for removing resources
- [ ] No custom methods disguised as POST (e.g., POST /orders/search should be GET with query params)

### Request Design
- [ ] Required vs optional fields clearly defined
- [ ] Field names use snake_case
- [ ] Enums have sensible values (not numeric codes)
- [ ] Pagination parameters defined for list endpoints
- [ ] Filter and sort parameters defined
- [ ] File uploads use multipart/form-data

### Response Design
- [ ] Consistent envelope structure (data, links, meta)
- [ ] Timestamps in ISO 8601 format
- [ ] IDs are stable and non-sequential (or sequential with no security concern)
- [ ] Relationships use consistent nesting pattern
- [ ] No sensitive data in default responses
- [ ] Pagination metadata on all list endpoints

### Error Handling
- [ ] RFC 7807 Problem Details format
- [ ] Appropriate HTTP status codes for each error case
- [ ] Validation errors include field-level detail
- [ ] Error messages are helpful but do not leak internals
- [ ] Rate limit errors include Retry-After header
```

### Implementation Review (Before Merge)

```markdown
## API Implementation Review — [PR #XXX]

### Security
- [ ] Authentication required on all mutating endpoints
- [ ] Authorization (Policy) checks on every action
- [ ] Input validation via Form Request on every endpoint
- [ ] Mass assignment protection ($fillable defined)
- [ ] No raw SQL with user input
- [ ] Rate limiting configured
- [ ] CORS settings appropriate

### Code Quality
- [ ] Controller methods delegate to services (not fat controllers)
- [ ] Form Requests handle all validation (not inline in controller)
- [ ] API Resources transform all responses (not raw models)
- [ ] Query scoping prevents cross-tenant data access
- [ ] N+1 queries prevented (eager loading or query builder)

### Testing
- [ ] Pest tests cover all endpoints (CRUD + edge cases)
- [ ] Auth tests: unauthenticated (401), unauthorized (403)
- [ ] Validation tests: all required fields, invalid types
- [ ] Pagination tests: default size, custom size, boundary
- [ ] Error tests: 404, 409, 422, 429

### Documentation
- [ ] OpenAPI spec updated
- [ ] Scribe annotations added (if using Scribe)
- [ ] Changelog entry written
- [ ] Breaking changes flagged (if any)

### Backward Compatibility
- [ ] No existing fields removed
- [ ] No field types changed
- [ ] No new required request fields without defaults
- [ ] No URL paths changed
- [ ] Existing tests still pass
```

---

## Versioning Strategy Comparison

### URI-Based Versioning

```
/api/v1/orders
/api/v2/orders
```

| Pros | Cons |
|---|---|
| Simple to understand and implement | URL changes for every version |
| Easy to route in Laravel | Can lead to code duplication |
| Clear in logs and documentation | Harder to share code between versions |
| Easy to test different versions | More route definitions to maintain |
| Cache-friendly (different URLs) | |

**Best for:** Most Laravel applications, public APIs, APIs with infrequent breaking changes.

**Laravel implementation:**

```php
// routes/api.php
Route::prefix('v1')->as('api.v1.')->group(base_path('routes/api/v1.php'));
Route::prefix('v2')->as('api.v2.')->group(base_path('routes/api/v2.php'));
```

```
routes/
├── api.php
└── api/
    ├── v1.php
    └── v2.php
```

### Header-Based Versioning

```
Accept: application/vnd.myapp.v1+json
Accept: application/vnd.myapp.v2+json
```

| Pros | Cons |
|---|---|
| Clean URLs that never change | Harder to test (need custom headers) |
| Version is metadata, not resource identity | Not visible in browser/logs by default |
| Single set of routes | Requires middleware to parse |
| Easier to share code between versions | Cache varies on Accept header |

**Best for:** APIs where URL stability is critical, internal service-to-service APIs.

**Laravel implementation:**

```php
// app/Http/Middleware/ApiVersion.php
class ApiVersion
{
    public function handle(Request $request, Closure $next): Response
    {
        $accept = $request->header('Accept', '');

        $version = match (true) {
            str_contains($accept, 'vnd.myapp.v2') => 'v2',
            str_contains($accept, 'vnd.myapp.v1') => 'v1',
            default => 'v1', // Default to latest stable
        };

        $request->attributes->set('api_version', $version);
        app()->instance('api.version', $version);

        return $next($request);
    }
}
```

### Query Parameter Versioning

```
/api/orders?version=1
/api/orders?version=2
```

| Pros | Cons |
|---|---|
| Simple to implement | Mixes versioning with query parameters |
| Easy to test | Easy to forget the parameter |
| Works with all HTTP clients | Not RESTful (version is not a filter) |

**Best for:** Rarely recommended. Use URI or header versioning instead.

### Recommended Approach for Laravel

Use **URI-based versioning** as the default. It is the most common, easiest to understand,
and works well with Laravel's routing system. Switch to header-based only if you have a
specific requirement for URL stability.

---

## Consumer Notification Templates

### Breaking Change Announcement

```markdown
Subject: [Action Required] API Breaking Change — {API_NAME} {VERSION}

Hi {CONSUMER_NAME},

We are making changes to the {API_NAME} API that will affect your integration.

**What is changing:**
{CHANGE_DESCRIPTION}

**Timeline:**
- {DATE}: Change announced (today)
- {DATE + 30 days}: Deprecation warnings active (Deprecation header added)
- {DATE + 90 days}: Old behavior removed

**What you need to do:**
1. {MIGRATION_STEP_1}
2. {MIGRATION_STEP_2}
3. {MIGRATION_STEP_3}

**Migration guide:** {DOCS_URL}
**Test against staging:** {STAGING_URL}

**Need help?**
Reply to this email or contact {SUPPORT_EMAIL}.

— {API_TEAM_NAME}
```

### Deprecation Reminder (30 Days)

```markdown
Subject: [Reminder] API Deprecation in 30 Days — {API_NAME}

Hi {CONSUMER_NAME},

This is a reminder that the following API changes take effect on {SUNSET_DATE}:

**Deprecated features:**
{LIST_OF_DEPRECATED_FEATURES}

**Your current usage:**
- {DEPRECATED_FEATURE}: {CALL_COUNT} calls in the last 30 days

**Migration guide:** {DOCS_URL}

If you have already migrated, you can ignore this notice.

— {API_TEAM_NAME}
```

### New Version Announcement

```markdown
Subject: [New] {API_NAME} {NEW_VERSION} Now Available

Hi {CONSUMER_NAME},

We have released {API_NAME} {NEW_VERSION} with the following improvements:

**New features:**
- {FEATURE_1}
- {FEATURE_2}

**Improvements:**
- {IMPROVEMENT_1}

**Migration from {OLD_VERSION}:**
- {MIGRATION_NOTE_1}
- {MIGRATION_NOTE_2}

**Documentation:** {DOCS_URL}
**Changelog:** {CHANGELOG_URL}

{OLD_VERSION} remains fully supported until {OLD_VERSION_SUNSET_DATE}.

— {API_TEAM_NAME}
```

### Incident / Outage Notification

```markdown
Subject: [Incident] {API_NAME} — {BRIEF_DESCRIPTION}

**Status:** {Investigating | Identified | Monitoring | Resolved}
**Impact:** {Description of impact on consumers}
**Start time:** {ISO 8601 timestamp}
**Affected endpoints:** {List of affected endpoints}

**Current update:**
{Latest status update}

**What you can do:**
- {Workaround if available}
- Check status page: {STATUS_PAGE_URL}
- Contact support: {SUPPORT_EMAIL}

We will provide updates every {30 minutes | 1 hour} until resolved.

— {API_TEAM_NAME}
```
