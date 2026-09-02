# OWASP Top 10 — Laravel Audit Checklist

One section per OWASP category, with the grep that finds it and the fix that closes it.
Work top to bottom; A01 and A03 account for most real findings.

---

## A01 — Broken Access Control

**The highest-yield category. Audit this first.**

```bash
# Coverage gap: actions vs authorization calls
grep -rn "public function" app/Http/Controllers/ | wc -l
grep -rn "authorize(\|Gate::\|->can(\|can:" app/Http/Controllers/ routes/ | wc -l

# Tenant isolation removed
grep -rn "withoutGlobalScope" app/

# Superadmin bypass
grep -rn "Gate::before" app/Providers/

# Livewire public entry points with no check
grep -rln "class .* extends Component" app/Livewire/ | xargs grep -L "authorize\|abort_unless"
```

| Finding | Fix |
|---|---|
| Action takes a bound model, no `authorize()` | Add `$this->authorize('view', $model)` |
| `@can` in Blade but no route/controller check | Move the check to the controller or route middleware |
| `withoutGlobalScopes()` | Remove it, or narrow to the one scope and justify in a comment |
| Livewire `mount()` with no check | `abort_unless(auth()->user()->can('view', $model), 403)` |
| `firstOrFail()` on unscoped query | Scope by tenant/owner before the lookup |

**Test that proves it:** a request as user B for user A's record asserts `403`.

---

## A02 — Cryptographic Failures

```bash
grep -rn "md5(\|sha1(\|base64_encode.*password\|Crypt::" app/
grep -rn "SESSION_SECURE_COOKIE\|SESSION_HTTP_ONLY\|SESSION_SAME_SITE" .env.example
```

- Passwords: `Hash::make()` / `bcrypt` only. Never `md5`, `sha1`, or reversible encryption.
- Sensitive columns: `protected $casts = ['ssn' => 'encrypted'];`
- TLS enforced, HSTS set, `SESSION_SECURE_COOKIE=true`.
- `APP_KEY` present and unique per environment — a shared key across environments means
  staging can decrypt production data.

---

## A03 — Injection

```bash
grep -rn "whereRaw\|selectRaw\|orderByRaw\|havingRaw\|DB::raw\|DB::statement\|DB::select" app/
grep -rn "exec(\|shell_exec(\|system(\|passthru(\|proc_open(\|popen(" app/
grep -rn "{!!" resources/views/ | grep -v "csrf\|method_field"
```

| Type | Fix |
|---|---|
| SQL, value position | Bindings: `whereRaw('total > ?', [$v])` |
| SQL, identifier position (column/direction) | Allow-list — bindings cannot bind identifiers |
| Shell | `Process::run(['git', 'checkout', $branch])` array form; never string interpolation |
| XSS | `{{ }}` not `{!! !!}`; sanitise if raw HTML is genuinely required |
| Mail header / LDAP / XML | Validate and encode at the boundary; disable XML external entities |

---

## A04 — Insecure Design

Not a grep — a review question set.

- Can a user reach a paid feature by manipulating a request? Enforce entitlement server-side.
- Is there a limit on quantity, size, frequency and cost of every user-initiated operation?
- Does password reset leak whether an account exists? (Return the same response either way.)
- Is there a second factor on privileged actions (role change, payout, data export)?
- What is the blast radius if one admin account is compromised? If it is "everything", that
  is the design finding.

---

## A05 — Security Misconfiguration

```bash
php artisan about
grep -n "APP_DEBUG\|APP_ENV" .env
composer show --direct | grep -i "telescope\|debugbar\|ignition"
ls -la storage/ bootstrap/cache/       # 775 max, never 777
```

| Check | Required |
|---|---|
| `APP_DEBUG` | `false` in production |
| `APP_ENV` | `production` |
| Telescope / Debugbar / Ignition | `require-dev` only, or auth-gated |
| Directory listing | Disabled at the web server |
| Default/example credentials | Removed from seeders that run in production |
| Error pages | Generic — no stack traces, no SQL, no paths |
| Security headers | CSP, `nosniff`, `Referrer-Policy`, HSTS, `X-Frame-Options` |
| `storage/` permissions | `775`, owned by the web user — never `777` |

---

## A06 — Vulnerable and Outdated Components

```bash
composer audit
npm audit --omit=dev
composer outdated --direct
php -v          # is the PHP branch still receiving security fixes?
```

Every advisory gets one of: **fixed**, or **triaged in writing** with the reason it does not
apply. An unread `composer audit` is not a passing result.

---

## A07 — Identification and Authentication Failures

```bash
grep -rn "throttle" routes/
grep -rn "RateLimiter::for" app/Providers/
```

- Login, register, password reset, OTP verify: throttled by identity **and** IP.
- Session regenerated on login (`$request->session()->regenerate()`), invalidated on logout.
- Password minimum enforced via `Password::defaults()`; enable `->uncompromised()`.
- Remember-me tokens rotated; sessions invalidated on password change.
- Timing-safe comparisons for tokens: `hash_equals()`.
- API tokens scoped (`Sanctum` abilities), expiring, and revocable.

---

## A08 — Software and Data Integrity Failures

```bash
grep -rn "unserialize(" app/
grep -rn "uses:" .github/workflows/ | grep -v "@[0-9a-f]\{40\}"   # unpinned actions
grep -rn "pull_request_target" .github/workflows/
```

- Never `unserialize()` user input — use `json_decode()`.
- Pin GitHub Actions to a full commit SHA.
- `pull_request_target` + checkout of PR head = untrusted code with your secrets. Remove it.
- Verify webhook signatures (Stripe, GitHub, etc.) before processing the payload.
- Commit `composer.lock` and `package-lock.json`; review their diffs.

---

## A09 — Security Logging and Monitoring Failures

- Log authentication success and failure, authorization denials, and privileged actions
  (role change, data export, deletion) with actor, target, IP and timestamp.
- **Never** log passwords, tokens, card numbers, or whole request payloads.
- Logs must be tamper-evident and retained long enough to investigate — a 7-day rotation
  finds nothing.
- Alert on: failed-login spikes, 403 spikes (someone is probing), new exception classes.
- Use the `log-monitor` skill for the parsing and alerting side.

---

## A10 — Server-Side Request Forgery

```bash
grep -rn "Http::get(\|file_get_contents(\|curl_init(" app/
```

Any outbound request whose URL is user-influenced needs:

- A **host allow-list**, not a deny-list
- Rejection of internal ranges: `127.0.0.0/8`, `10/8`, `172.16/12`, `192.168/16`,
  `169.254.169.254` (cloud metadata — the classic SSRF target)
- Redirects disabled or re-validated at each hop
- A timeout and a response size cap

---

## Reporting Format

```markdown
| # | Severity | Finding | Location | Fix |
|---|---|---|---|---|
| 1 | Critical | IDOR — invoice readable by any authenticated user | `InvoiceController.php:34` | Add `$this->authorize('view', $invoice)` + cross-tenant test |
| 2 | High | Mass assignment on `User::create($request->all())` | `RegisterController.php:22` | `$request->safe()->only([...])` |
```

Severity: **Critical** (data exposure / RCE / auth bypass — block the release),
**High** (exploitable with conditions), **Medium** (defence in depth),
**Low** (hygiene). Every row needs an exact `file:line` and a concrete fix, not "review this".
