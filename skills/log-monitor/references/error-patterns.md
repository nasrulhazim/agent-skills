# Common Error Patterns

Reference catalog of common Laravel/PHP error patterns, their typical root causes,
and recommended fixes. Use this to quickly categorize and diagnose errors found in logs.

---

## Database Errors

### SQLSTATE[25006]: Read only sql transaction

- **Cause:** PostgreSQL database is in read-only mode
- **Typical triggers:** Replica being written to, failover event, maintenance mode
- **Fix:** Check replication config, ensure app connects to primary for writes
- **Priority:** P1-critical (data writes failing)

### SQLSTATE[23505]: Unique violation

- **Cause:** Attempting to insert a duplicate value into a unique column
- **Typical triggers:** Race conditions, missing upsert logic, retry without idempotency
- **Fix:** Add upsert logic or check-before-insert, review concurrent request handling
- **Priority:** P2-high

### SQLSTATE[42S02]: Base table or view not found / ORA-00942

- **Cause:** Referenced table or view does not exist in the database
- **Typical triggers:** Missing migration, dropped view, wrong database connection
- **Fix:** Run migrations, recreate view, verify database connection config
- **Priority:** P1-critical (feature completely broken)

### ORA-01031: Insufficient privileges

- **Cause:** Oracle database user lacks required permissions
- **Typical triggers:** New table/view without GRANT, user provisioning incomplete
- **Fix:** Grant required privileges to the application database user
- **Priority:** P2-high

### Allowed memory size exhausted

- **Cause:** PHP process exceeded memory limit
- **Typical triggers:** Large query without pagination, memory leak, loading too many models
- **Fix:** Add chunking/pagination, optimize query, increase memory limit if justified
- **Priority:** P3-medium

---

## Authentication / LDAP Errors

### ldap_bind_ext(): Invalid credentials

- **Cause:** Wrong username or password for LDAP bind
- **Typical triggers:** User entering wrong password, expired credentials
- **Fix:** If service account — verify credentials. If user — expected behaviour, consider rate-limiting
- **Priority:** P4-low (user behaviour) or P1-critical (service account)

### ldap_bind_ext(): password must not contain null bytes

- **Cause:** Password argument contains null byte characters
- **Typical triggers:** Corrupted stored password, encryption/decryption error
- **Fix:** Re-set the affected password, check encryption pipeline
- **Priority:** P2-high

### ldap_modify_batch(): Server is unwilling to perform

- **Cause:** AD server refusing the requested operation
- **Typical triggers:** Password change without LDAPS, complexity policy violation, insufficient permissions
- **Fix:** Ensure LDAPS (port 636), check password policy, verify service account permissions
- **Priority:** P2-high

### AlreadyExistsException (LDAP)

- **Cause:** Attempting to create an LDAP entry that already exists
- **Typical triggers:** Resync without checking for existing entry, duplicate creation logic
- **Fix:** Add existence check before create, implement upsert pattern
- **Priority:** P3-medium

### Socialite InvalidStateException

- **Cause:** OAuth state mismatch between redirect and callback
- **Typical triggers:** Session expired, CSRF token mismatch, user navigated away and back
- **Fix:** Usually no fix needed (expected edge case). Consider longer session TTL if frequent
- **Priority:** P4-low (single occurrence) or P3-medium (frequent)

---

## Filesystem / Permission Errors

### Permission denied (file_get_contents, include, require)

- **Cause:** Web server process cannot read the file
- **Typical triggers:** Deployment as wrong user, artisan command as root, file ownership mismatch
- **Fix:** `chown -R www-data:www-data /path/to/app`, fix deployment scripts
- **Priority:** P2-high (cascading failures likely)

### Failed to open stream: No such file or directory

- **Cause:** Referenced file does not exist at the expected path
- **Typical triggers:** Missing config file, incomplete deployment, wrong path in code
- **Fix:** Verify file exists, check deployment process, verify path configuration
- **Priority:** P2-high (if config) or P3-medium (if optional file)

---

## Application / Framework Errors

### Target class [X] does not exist

- **Cause:** Laravel service container cannot resolve the requested class
- **Typical triggers:** Missing service provider, corrupted bootstrap cache, permission denied on packages.php
- **Fix:** Run `php artisan clear-compiled`, check bootstrap/cache permissions
- **Priority:** P2-high (often cascading from permission issues)

### Route [X] not defined

- **Cause:** Named route referenced in code/views does not exist
- **Typical triggers:** Missing route definition, route cache stale, typo in route name
- **Fix:** Add the route, or fix the reference. Run `php artisan route:clear`
- **Priority:** P2-high (user-facing error)

### UnhandledMatchError

- **Cause:** PHP `match` expression encountered a value with no matching arm
- **Typical triggers:** New enum value not handled, unexpected input type
- **Fix:** Add `default` arm to the match expression
- **Priority:** P3-medium

### Class "X" not found / ReflectionException

- **Cause:** PHP cannot find or autoload the requested class
- **Typical triggers:** Missing composer autoload, namespace mismatch, deleted class
- **Fix:** Run `composer dump-autoload`, verify class exists and namespace matches
- **Priority:** P2-high

---

## Infrastructure Errors

### cURL error 28: Connection timed out / Resolving timed out

- **Cause:** HTTP request to external service timed out
- **Typical triggers:** External API down, DNS issues, network connectivity problems
- **Fix:** Add retry logic, increase timeout, add circuit breaker
- **Priority:** P3-medium (intermittent) or P2-high (persistent)

### EMERGENCY: Unable to create configured logger

- **Cause:** LOG_CHANNEL environment variable missing or invalid
- **Typical triggers:** Missing .env configuration, undefined log channel
- **Fix:** Set `LOG_CHANNEL` in .env to a valid channel (e.g., `daily`, `stack`)
- **Priority:** P3-medium (logs go to emergency fallback)

### oci_connect(): undefined function

- **Cause:** Oracle PHP extension (OCI8) not loaded
- **Typical triggers:** Server restart without extension, container rebuild, missing php.ini entry
- **Fix:** Install/enable OCI8 extension, verify php.ini configuration persists
- **Priority:** P1-critical (all Oracle operations broken)

---

## Cascading Error Patterns

These errors commonly trigger chains of other errors:

| Root Error | Cascades Into |
|---|---|
| `packages.php` permission denied | Target class not found, view not found, service resolution failures |
| Database connection failure | Every database query fails, queue jobs fail, session errors |
| Missing .env file | Config errors, service container errors, undefined constants |
| OCI8 extension missing | Every Oracle query fails, all cron jobs using Oracle fail |
| LDAP connection failure | All auth failures, all sync operations fail |

When you see a cascade, **identify and report only the root cause** — don't create separate issues for each cascading error.

---

## Noise vs Signal

These are typically noise (expected behaviour, not bugs):

| Error | Why It's Noise |
|---|---|
| Invalid password (user login) | Users mistyping passwords — expected |
| Session expired / TokenMismatchException | Normal session lifecycle |
| 404 errors on known non-existent paths | Bots/crawlers probing |
| Rate limit exceeded | Rate limiting working correctly |
| Validation errors | Users submitting invalid data — expected |

**Still report these if:**
- Volume is abnormally high (possible brute force, UX problem)
- Same user retrying hundreds of times (possible UX confusion)
- Patterns suggest systemic issues (e.g., case-sensitivity confusion)
