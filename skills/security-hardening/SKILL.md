---
name: security-hardening
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, security, owasp, authorization, hardening, defensive]
description: >
  Proactive defensive security for Laravel applications — hardening code before it ships
  rather than investigating after it breaks. Covers the OWASP Top 10 as it actually appears
  in Laravel: broken authorization (missing policies, IDOR, tenant leakage), mass assignment,
  SQL injection through raw expressions, XSS through unescaped Blade, insecure file uploads,
  secrets in code and logs, session and cookie configuration, rate limiting, CSRF, security
  headers, and dependency vulnerabilities. Also covers hardening CI/CD workflows and server
  configuration. Use this skill whenever the user asks to review code for security issues,
  audit an application, harden a deployment, check authorization coverage, secure file
  uploads, lock down an API, or prepare for a security review — including "security review
  this", "is this secure", "audit my app", "check for vulnerabilities", "harden my Laravel
  app", "review my policies", "secure this upload", "check for IDOR", "lock down this
  endpoint", "audit my dependencies", "semak keselamatan", "audit sekuriti aplikasi",
  "code ni selamat ke", "kukuhkan aplikasi", "periksa kelemahan", or "review policy dan
  permission". Defensive only — for authorised active testing use the penetration-tester
  agent, and for incident investigation use soc-analyst and log-monitor.
---

# Security Hardening

Defensive review and hardening for Laravel applications. This skill finds and fixes
weaknesses in code you own, before they ship.

**Scope:** defensive only. Reviewing, hardening, and writing tests that prove a control
works. Active exploitation against a live target belongs to the `penetration-tester` agent
with a written scope; investigating an actual breach belongs to `soc-analyst`.

## Command Reference

| Command | Description |
|---|---|
| `/secure review` | Security-review a diff, file or module against the checklist |
| `/secure authz` | Audit authorization coverage — policies, gates, tenant scoping |
| `/secure inputs` | Audit validation, mass assignment and injection surfaces |
| `/secure uploads` | Audit file upload handling and storage |
| `/secure config` | Audit `.env`, session, cookie, headers and production config |
| `/secure deps` | Audit dependencies and CI/CD workflow permissions |

---

## When to Use

- Before merging anything touching auth, authorization, payments, uploads or tenancy
- Before a first production deploy, or before opening an app to external users
- When adding a new API surface or public endpoint
- When onboarding a codebase you did not write
- On a schedule — dependency and config drift are silent

---

## 1. Broken Authorization — the one that actually bites

Authorization failures are the most common *and* most damaging Laravel vulnerability class.
Authentication asks "who are you"; authorization asks "may you touch **this** record". Most
apps get the first right and the second wrong.

### Every route that takes an ID needs an ownership check

```php
// ❌ IDOR — any authenticated user can read any invoice
public function show(Invoice $invoice)
{
    return new InvoiceResource($invoice);
}

// ✅ Policy enforced
public function show(Invoice $invoice)
{
    $this->authorize('view', $invoice);

    return new InvoiceResource($invoice);
}
```

### Audit coverage systematically

```bash
# Every model that has a policy
ls app/Policies/

# Every controller action, and whether it authorizes
grep -rn "public function" app/Http/Controllers/ | wc -l
grep -rn "authorize\|Gate::\|can(" app/Http/Controllers/ | wc -l
```

A large gap between those two numbers is the finding.

### Laravel-specific authorization traps

| Trap | Why it fails |
|---|---|
| `Gate::before(fn ($user) => $user->isAdmin() ? true : null)` | Short-circuits **every** policy. One compromised admin account owns everything, and your policies are never exercised in tests |
| Route model binding without `authorize()` | Binding proves the record *exists*, never that the user may see it |
| `Model::withoutGlobalScopes()` | Removes tenant isolation. Search for it and justify every hit |
| Authorization in Blade only (`@can`) | Hides the button; the route is still reachable by URL |
| Livewire component with no `mount()` check | Public method = public endpoint. Authorize in `mount()`, not only in the view |
| `firstOrFail()` on an unscoped query | Returns another tenant's row and 200s |

### Multi-tenancy

```php
// ✅ Scope at the source, not the call site
protected static function booted(): void
{
    static::addGlobalScope('tenant', fn (Builder $q) =>
        $q->where('tenant_id', auth()->user()?->tenant_id)
    );
}
```

Then write the test that proves it:

```php
it('cannot read another tenant record', function () {
    $mine = Invoice::factory()->for($this->tenant)->create();
    $theirs = Invoice::factory()->for(Tenant::factory())->create();

    actingAs($this->user)->get("/invoices/{$theirs->id}")->assertForbidden();
    actingAs($this->user)->get("/invoices/{$mine->id}")->assertOk();
});
```

---

## 2. Mass Assignment

```php
// ❌ Trusting the request shape
User::create($request->all());

// ❌ Guarded-nothing plus request->all() = privilege escalation via {"is_admin":true}
protected $guarded = [];

// ✅ Explicit allow-list, validated first
User::create($request->safe()->only(['name', 'email']));
```

- Prefer `$fillable` over `$guarded`. An allow-list fails closed; a deny-list fails open the
  moment someone adds a column.
- Never pass `$request->all()` into `create()`, `update()` or `fill()`.
- `is_admin`, `role`, `tenant_id`, `user_id`, `status`, `price` and `verified_at` must never
  be fillable from a public request.

---

## 3. Injection

```php
// ❌ Interpolated user input
DB::select("SELECT * FROM users WHERE email = '$email'");
Order::whereRaw("total > {$request->min}")->get();

// ✅ Bound parameters
DB::select('SELECT * FROM users WHERE email = ?', [$email]);
Order::whereRaw('total > ?', [$request->integer('min')])->get();
```

Column and direction names cannot be bound — allow-list them instead:

```php
// ❌ orderBy($request->sort) — user controls the SQL identifier
$sort = in_array($request->sort, ['created_at', 'total'], true) ? $request->sort : 'created_at';
$dir  = $request->dir === 'asc' ? 'asc' : 'desc';
```

Audit surface:

```bash
grep -rn "whereRaw\|selectRaw\|orderByRaw\|havingRaw\|DB::raw\|DB::statement" app/
```

Every hit needs bindings or an allow-list. Also check command injection: `exec`, `shell_exec`,
`system`, `passthru`, `proc_open`, and `Process::run()` with interpolated input — use
`Process::run(['git', 'checkout', $branch])` array form.

---

## 4. XSS

```blade
{{-- ✅ Escaped by default --}}
{{ $user->bio }}

{{-- ❌ Raw — only ever for HTML you generated or sanitised server-side --}}
{!! $user->bio !!}
```

```bash
grep -rn "{!!" resources/views/ | grep -v "csrf\|method_field"
```

Every remaining hit must be sanitised (`mews/purifier` or equivalent) or provably
developer-authored. Also watch: `@json()` into a `<script>` block, `wire:ignore` regions
rendering user HTML, and Markdown rendered without an escaping configuration.

---

## 5. File Uploads

```php
// ✅ Validate type, size and extension; never trust the client filename
$request->validate([
    'avatar' => ['required', 'file', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
]);

// ✅ Framework-generated name, private disk by default
$path = $request->file('avatar')->store('avatars', 'private');
```

| Rule | Why |
|---|---|
| Validate `mimes:` **and** `max:` | Missing size limit is a denial-of-service primitive |
| Never use `getClientOriginalName()` as the stored name | Path traversal and overwrite; `../../.env` is a real payload |
| Store outside the public root | An uploaded `.php` in `public/` is remote code execution |
| Serve through a controller with `authorize()` | A guessable public URL is an IDOR on files |
| Re-encode images where practical | Strips embedded payloads and EXIF |
| Never `unzip` or extract archives from users without limits | Zip bombs and path traversal |

---

## 6. Secrets

```bash
# Committed secrets
git log --all -p -- .env | head
grep -rn "sk_live\|AKIA\|BEGIN RSA PRIVATE KEY\|password.*=.*['\"]" app/ config/ --include="*.php"

# Is .env ignored?
git check-ignore .env || echo "CRITICAL: .env is tracked"
```

- Secrets come from `.env`, read only in `config/*.php`, never `env()` outside config —
  `config:cache` makes `env()` return null in production.
- Never log a request payload wholesale. Add to `$except` in `TrimStrings`/logging middleware:
  `password`, `password_confirmation`, `token`, `secret`, `card_number`, `cvv`, `api_key`.
- A secret that reached a git history is compromised. Rotate it — do not just delete the line.
- **Exception:** `APP_KEY` cannot be casually rotated on a live app; it decrypts existing
  `encrypted:` columns and derives passkey handles. Plan a re-encryption migration.

---

## 7. Production Configuration

| Setting | Required value | Failure if wrong |
|---|---|---|
| `APP_DEBUG` | `false` | Stack traces leak `.env` contents on any error page |
| `APP_ENV` | `production` | Debug tooling and permissive defaults stay on |
| `SESSION_SECURE_COOKIE` | `true` | Session cookie sent over plaintext HTTP |
| `SESSION_HTTP_ONLY` | `true` | Session readable by any XSS payload |
| `SESSION_SAME_SITE` | `lax` or `strict` | CSRF via cross-site requests |
| `HTTPS` | enforced + HSTS | Everything above is moot |
| Telescope / Debugbar | removed or auth-gated | Full request payloads including credentials, publicly readable |

```bash
php artisan about        # confirm env, debug, drivers, cache state
```

### Rate limiting

```php
// Public and auth endpoints need different tiers
RateLimiter::for('login', fn (Request $r) =>
    Limit::perMinute(5)->by($r->email . $r->ip())
);
RateLimiter::for('api', fn (Request $r) =>
    Limit::perMinute(60)->by($r->user()?->id ?: $r->ip())
);
```

Login, password reset, OTP verification, registration and any expensive report endpoint must
be throttled. Throttle by identity **and** IP — IP alone is trivially rotated.

### Security headers

`Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`,
`Strict-Transport-Security`, `X-Frame-Options: DENY` (or CSP `frame-ancestors`).

---

## 8. Dependencies and CI/CD

```bash
composer audit
npm audit --omit=dev
```

GitHub Actions hardening:

- Pin actions to a commit SHA, not a moving tag — `uses: actions/checkout@<sha>`
- Set least-privilege `permissions:` at the workflow level (`contents: read` by default)
- Never use `pull_request_target` with a checkout of the PR head — that runs untrusted code
  with access to your secrets
- Secrets go in repository/environment secrets, never in workflow YAML, never `echo`ed
- Require review for workflow file changes

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's behind auth, so it's fine" | Authentication is not authorization. Every authenticated user is a potential attacker against every other user's records. |
| "The UI doesn't show that button to them" | The UI is not a security control. The route is one `curl` away. |
| "It's an internal tool" | Internal tools get exposed, get credentials phished, and hold the most sensitive data. |
| "We'll add the policies later" | Every endpoint written without one is a permanent IDOR until someone audits it — and nobody audits it. |
| "`$guarded = []` is faster to write" | It is. It also lets any request set `is_admin`. Speed of writing is not a security argument. |
| "No user would send that" | An attacker is not a user. Assume every field, header and file is hostile. |
| "The validation on the frontend handles it" | Client validation is a UX feature. It is absent from every request an attacker sends. |
| "It's just a `whereRaw`, the input is an integer" | It is an integer until someone changes the form, the API, or the caller. Bind it. |
| "We removed the secret from the repo" | It is still in the git history and in every clone. Rotate it. |
| "`composer audit` has too many false positives" | Then triage them and record the decision. Silence is not triage. |
| "Debug mode is off in production, I'm sure" | Run `php artisan about` and be sure. This one leaks the entire `.env`. |

---

## Red Flags

- A controller action taking a model and never calling `authorize()`
- `Gate::before` granting a superadmin bypass — every policy below it is untested
- `$guarded = []` combined with `$request->all()`
- `withoutGlobalScopes()` anywhere in a multi-tenant app
- `whereRaw` / `selectRaw` / `orderByRaw` with an interpolated variable
- `{!! !!}` rendering anything a user can influence
- `getClientOriginalName()` used as a storage path
- An upload path under `public/`
- `env()` called outside `config/`
- A `.env`, `*.pem`, `id_rsa` or `credentials.json` in `git status`
- `APP_DEBUG=true` in a production `.env`
- A login or password-reset route with no `throttle` middleware
- `pull_request_target` in a workflow that checks out the PR head
- A GitHub Action pinned to `@main` or `@v4` rather than a SHA
- Telescope or Debugbar in `require` rather than `require-dev`
- A security finding closed with "won't fix" and no stated risk acceptance

---

## Verification

- [ ] Every controller action taking a model calls `authorize()` or is explicitly public
- [ ] A cross-tenant / cross-user access test exists and asserts `403`, not just `200` for the owner
- [ ] No `$request->all()` reaches `create()`, `update()` or `fill()`
- [ ] Every raw SQL construct uses bindings or a validated allow-list
- [ ] Every `{!! !!}` renders sanitised or developer-authored HTML only
- [ ] Uploads validate `mimes` and `max`, store outside the public root, and are served through an authorizing controller
- [ ] `git check-ignore .env` passes; no secret appears in `git log --all -p`
- [ ] `php artisan about` confirms `APP_DEBUG=false` and `APP_ENV=production`
- [ ] Login, reset and registration routes are rate limited by identity and IP
- [ ] `composer audit` and `npm audit` reviewed — each finding fixed or triaged in writing
- [ ] Workflow `permissions:` are least-privilege and actions are SHA-pinned
- [ ] Every finding is reported with severity, the exact `file:line`, and the concrete fix

---

## Reference Files

| File | Read When |
|---|---|
| `references/laravel-owasp-checklist.md` | Running a full audit — OWASP Top 10 mapped to Laravel with the grep for each |
| `references/authorization-patterns.md` | Designing or fixing policies, gates, tenant scoping and Livewire authorization |
