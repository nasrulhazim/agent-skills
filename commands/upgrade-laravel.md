# Laravel 12 to Laravel 13 Upgrade Assistant

You are a specialized assistant for upgrading Laravel from version 12 to version 13.

## Step 1: Identify Upgrade Type

**CRITICAL**: Before any upgrade, determine if this is an APPLICATION or PACKAGE.

### Detection Checklist

| Check | Application | Package |
|-------|-------------|---------|
| `composer.json` type field | `"type": "project"` | `"type": "library"` |
| Has `public/index.php` | Yes | No |
| Has `app/Http/` directory | Yes | No |
| Has `src/` directory | No | Yes |
| Uses `PackageServiceProvider` | No | Usually |
| Published on Packagist | Rarely | Yes |

### Quick Detection Commands

```bash
# Check composer.json type
grep '"type"' composer.json

# Check for application indicators
ls public/index.php 2>/dev/null && echo "APPLICATION" || echo "Might be PACKAGE"

# Check for package indicators
ls src/ 2>/dev/null && echo "Might be PACKAGE" || echo "Might be APPLICATION"
```

## Step 2: Assess Current State

Run these commands to understand what needs changing:

```bash
# Check current Laravel version
composer show laravel/framework | grep versions

# Check PHP version
php -v

# Check for CSRF middleware references
grep -r "VerifyCsrfToken\|ValidateCsrfToken" app/ config/ routes/ --include="*.php" 2>/dev/null

# Check for cache serialization (objects in cache)
grep -r "Cache::put\|Cache::forever\|Cache::remember" app/ --include="*.php" 2>/dev/null

# Check for queue event listeners
grep -r "JobAttempted\|QueueBusy\|exceptionOccurred" app/ --include="*.php" 2>/dev/null

# Check for model boot with nested instantiation
grep -r "static function boot" app/ --include="*.php" 2>/dev/null

# Check for custom cache store implementations
grep -r "implements Store" app/ --include="*.php" 2>/dev/null

# Check for custom queue driver implementations
grep -r "implements Queue" app/ --include="*.php" 2>/dev/null

# Check for pagination view references
grep -r "pagination::default\|pagination::simple-default" app/ resources/ --include="*.php" --include="*.blade.php" 2>/dev/null

# Check for Manager extend() usage
grep -r "->extend(" app/ --include="*.php" 2>/dev/null

# Check for Str factory usage in tests
grep -r "createUuidsUsing\|createUlidsUsing\|createRandomStringsUsing" tests/ --include="*.php" 2>/dev/null

# Check for Js::from() usage
grep -r "Js::from(" app/ resources/ --include="*.php" --include="*.blade.php" 2>/dev/null

# Check for Container::call with nullable class params
grep -r "app()->call\|Container::call\|->call(" app/ --include="*.php" 2>/dev/null

# Check for password reset subject assertions
grep -r "Reset Password Notification" tests/ --include="*.php" 2>/dev/null

# Check for domain route registration
grep -r "->domain(" routes/ --include="*.php" 2>/dev/null
```

## Step 3: Follow the Correct Workflow

### For Applications

1. **Update `composer.json` dependencies**
2. **Run `composer update`**
3. **Update CSRF middleware references**
4. **Configure cache serializable classes (if needed)**
5. **Update queue event listeners (if needed)**
6. **Update pagination views (if needed)**
7. **Fix any other breaking changes found in assessment**
8. **Clear caches and run tests**

### For Packages

1. **Update `composer.json` version constraints** (support both 12 and 13)
2. **Update any framework class references**
3. **Update CI matrix to test both versions**
4. **Run tests against both Laravel 12 and 13**

---

## Breaking Changes Reference

### HIGH IMPACT

### 1. Dependency Updates

Update `composer.json`:

**For Applications:**
```json
{
  "require": {
    "laravel/framework": "^13.0",
    "laravel/boost": "^2.0",
    "laravel/tinker": "^3.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^13.0",
    "pestphp/pest": "^5.0"
  }
}
```

**For Packages (support both versions):**
```json
{
  "require": {
    "illuminate/support": "^12.0 || ^13.0"
  },
  "require-dev": {
    "orchestra/testbench": "^10.0 || ^11.0",
    "phpunit/phpunit": "^11.0 || ^12.0 || ^13.0",
    "pestphp/pest": "^3.0 || ^4.0 || ^5.0"
  }
}
```

### 2. CSRF Middleware Renamed to PreventRequestForgery

The CSRF middleware has been renamed and enhanced with request-origin verification via `Sec-Fetch-Site` header.

**Before (Laravel 12):**
```php
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;

->withoutMiddleware([VerifyCsrfToken::class]);
```

**After (Laravel 13):**
```php
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery;

->withoutMiddleware([PreventRequestForgery::class]);
```

Also update middleware configuration API calls:
```php
->preventRequestForgery(...)  // New configuration method
```

**Search & Replace Commands:**
```bash
# Find all references
grep -rn "VerifyCsrfToken\|ValidateCsrfToken" app/ config/ routes/ tests/ --include="*.php"

# Replace in files (macOS)
find . -name "*.php" -not -path "./vendor/*" -exec sed -i '' \
  's/VerifyCsrfToken/PreventRequestForgery/g; s/ValidateCsrfToken/PreventRequestForgery/g' {} \;

# Replace use statements
find . -name "*.php" -not -path "./vendor/*" -exec sed -i '' \
  's/use Illuminate\\Foundation\\Http\\Middleware\\VerifyCsrfToken/use Illuminate\\Foundation\\Http\\Middleware\\PreventRequestForgery/g' {} \;
```

---

### MEDIUM IMPACT

### 3. Cache `serializable_classes` Configuration

Default cache configuration now includes `serializable_classes` set to `false` for security hardening.

If your application stores PHP objects in cache, add to `config/cache.php`:

```php
'serializable_classes' => [
    App\Data\CachedDashboardStats::class,
    App\Support\CachedPricingSnapshot::class,
],
```

If you don't store objects in cache, no action needed.

---

### LOW IMPACT

### 4. Cache Prefixes and Session Cookie Names

Default prefixes changed from underscores to hyphens. Session cookie uses `Str::snake()` instead of `Str::slug()`.

**Before (Laravel 12):**
```
myapp_cache_
myapp_database_
myapp_session
```

**After (Laravel 13):**
```
myapp-cache-
myapp-database-
my_app_session
```

**Fix:** Set explicit values in `.env` to preserve previous behavior:
```env
CACHE_PREFIX=myapp_cache_
REDIS_PREFIX=myapp_database_
SESSION_COOKIE=myapp_session
```

### 5. Cache Contract: `touch()` Method

Cache contracts now include a `touch()` method. Custom cache store implementations must add:

```php
public function touch($key, $seconds);
```

### 6. Container::call() and Nullable Class Defaults

`Container::call()` now respects nullable class parameter defaults.

**Before (Laravel 12):**
```php
$container->call(function (?Carbon $date = null) {
    return $date;  // Returns Carbon instance (auto-resolved)
});
```

**After (Laravel 13):**
```php
$container->call(function (?Carbon $date = null) {
    return $date;  // Returns null (respects default)
});
```

### 7. Eloquent: Model Booting and Nested Instantiation

Creating model instances during model boot now throws `LogicException`.

**Before (Laravel 12) - Allowed:**
```php
protected static function boot()
{
    parent::boot();
    (new static())->getTable();  // Was allowed
}
```

**After (Laravel 13) - Throws Exception:**
```php
// Move outside boot cycle
public function getTableName()
{
    return $this->getTable();
}
```

### 8. Eloquent: Polymorphic Pivot Table Name Generation

Polymorphic pivot table names using custom pivot classes are now pluralized. Explicitly define table names:

```php
class CustomPivot extends Pivot
{
    protected $table = 'custom_pivots';
}
```

### 9. Eloquent: Collection Model Serialization Restores Relations

Eager-loaded relations now persist after serialization/deserialization (queued jobs). Adjust code if it relied on relations being absent after deserialization.

### 10. Database: MySQL DELETE with JOIN, ORDER BY, LIMIT

Laravel now generates full `DELETE ... JOIN` queries including `ORDER BY` and `LIMIT` for MySQL. Previously these clauses were silently ignored. Review delete queries with joins.

### 11. HTTP Client: Response::throw() and throwIf() Signatures

Method signatures now declare callback parameters:

```php
public function throw($callback = null);
public function throwIf($condition, $callback = null);
```

Update custom response class overrides to match.

### 12. Queue: JobAttempted Event Exception Payload

**Before (Laravel 12):**
```php
$event->exceptionOccurred;  // boolean
```

**After (Laravel 13):**
```php
$event->exception;  // Exception object or null
```

**Migration:**
```php
// Before
if ($event->exceptionOccurred) { ... }

// After
if ($event->exception !== null) { ... }
```

### 13. Queue: QueueBusy Event Property Rename

**Before:** `$event->connection`
**After:** `$event->connectionName`

### 14. Queue Contract: New Size Inspection Methods

Custom queue drivers must implement:
- `pendingSize()`
- `delayedSize()`
- `reservedSize()`
- `creationTimeOfOldestPendingJob()`

### 15. Routing: Domain Route Registration Precedence

Routes with explicit domains now take priority before non-domain routes in matching. Review route matching if relying on previous registration order.

### 16. Scheduling: withScheduling() Registration Timing

Schedules registered via `ApplicationBuilder::withScheduling()` are now deferred until `Schedule` is resolved.

### 17. Support: Manager extend() Callback Binding

Custom driver closures via `manager->extend()` are now bound to the manager instance.

**Before:**
```php
$manager->extend('custom', function() {
    // $this was another object
});
```

**After:**
```php
$manager->extend('custom', function() {
    // $this is now the manager instance
});
```

### 18. Support: Str Factories Reset Between Tests

Custom `Str` factories (UUID, ULID, random strings) now reset during test teardown. Set factories in `setUp()`:

```php
protected function setUp(): void
{
    parent::setUp();
    Str::createUuidsUsing(fn() => '...');
}
```

### 19. Support: Js::from() Unescaped Unicode

`Js::from()` now uses `JSON_UNESCAPED_UNICODE` by default. Update test expectations for escaped Unicode sequences.

### 20. Views: Pagination Bootstrap View Names

**Before (Laravel 12):**
```
pagination::default
pagination::simple-default
```

**After (Laravel 13):**
```
pagination::bootstrap-3
pagination::simple-bootstrap-3
```

### 21. Notifications: Default Password Reset Subject

**Before:** `Reset Password Notification`
**After:** `Reset your password`

Update test assertions and translation overrides.

### 22. Notifications: Queued Notifications with Missing Models

Queued notifications now respect `#[DeleteWhenMissingModels]` attribute and `$deleteWhenMissingModels` property.

### 23. New Contract Methods

Custom implementations must add:

**Dispatcher Contract:**
```php
public function dispatchAfterResponse($command, $handler = null);
```

**ResponseFactory Contract:**
```php
public function eventStream(...);
```

**MustVerifyEmail Contract:**
```php
public function markEmailAsUnverified();
```

---

## Upgrade Checklist

Use this checklist to track progress:

- [ ] Update `composer.json` dependencies
- [ ] Update Laravel Installer globally (`composer global update laravel/installer`)
- [ ] Update CSRF middleware references to `PreventRequestForgery`
- [ ] Configure `cache.serializable_classes` if storing objects in cache
- [ ] Set explicit `CACHE_PREFIX`, `REDIS_PREFIX`, `SESSION_COOKIE` in `.env` if needed
- [ ] Update queue event listeners (`$exceptionOccurred` -> `$exception`, `$connection` -> `$connectionName`)
- [ ] Add `touch()` to custom cache store implementations
- [ ] Add new methods to custom queue driver implementations
- [ ] Fix model boot methods that create nested instances
- [ ] Explicitly set table names on custom polymorphic pivot classes
- [ ] Update pagination view references (`pagination::default` -> `pagination::bootstrap-3`)
- [ ] Update password reset subject test assertions
- [ ] Review `Manager::extend()` closures for `$this` binding changes
- [ ] Move `Str` factory setup to `setUp()` in tests
- [ ] Update custom `Response::throw()` / `throwIf()` overrides
- [ ] Review domain route registration order
- [ ] Review MySQL DELETE with JOIN queries
- [ ] Add new contract methods to custom implementations
- [ ] Clear caches: `php artisan optimize:clear`
- [ ] Run full test suite: `composer test`

---

## Package-Specific: CI Matrix for Dual Version Testing

For packages, update GitHub Actions to test both Laravel 12 and 13:

```yaml
# .github/workflows/run-tests.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        php: [8.2, 8.3, 8.4]
        laravel: [12.*, 13.*]
        include:
          - laravel: 12.*
            testbench: ^10.0
          - laravel: 13.*
            testbench: ^11.0

    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          coverage: none

      - name: Install dependencies
        run: |
          composer require "laravel/framework:${{ matrix.laravel }}" "orchestra/testbench:${{ matrix.testbench }}" --no-interaction --no-update
          composer update --prefer-dist --no-interaction

      - name: Run tests
        run: vendor/bin/pest
```

---

Now proceed with the upgrade. Start by running the detection and assessment commands, then apply changes systematically based on findings.
