# Security Hardening Checklist — Laravel Applications

Read this file when running `/soc harden` to systematically improve the security posture of a Laravel application.

---

## 1. Environment Configuration

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 1.1 | `APP_DEBUG=false` in production | Read `.env` | Set `APP_DEBUG=false` | P1 |
| 1.2 | `APP_ENV=production` in production | Read `.env` | Set `APP_ENV=production` | P1 |
| 1.3 | `APP_KEY` is set and rotated | `php artisan key:generate --show` | `php artisan key:generate` | P1 |
| 1.4 | `.env` is in `.gitignore` | Read `.gitignore` | Add `.env` to `.gitignore` | P1 |
| 1.5 | `.env.example` has no real secrets | Read `.env.example` | Replace real values with placeholders | P2 |
| 1.6 | `APP_URL` uses HTTPS | Read `.env` | Set `APP_URL=https://...` | P2 |
| 1.7 | Log channel configured properly | Read `config/logging.php` | Use `stack` or `daily` channel, not `single` in production | P3 |

---

## 2. Security Headers

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 2.1 | Content-Security-Policy set | Check response headers | Add CSP middleware (see below) | P2 |
| 2.2 | Strict-Transport-Security set | Check response headers | Add HSTS header: `max-age=31536000; includeSubDomains` | P2 |
| 2.3 | X-Content-Type-Options set | Check response headers | Add `nosniff` header | P2 |
| 2.4 | X-Frame-Options set | Check response headers | Add `DENY` or `SAMEORIGIN` header | P2 |
| 2.5 | Referrer-Policy set | Check response headers | Add `strict-origin-when-cross-origin` | P3 |
| 2.6 | Permissions-Policy set | Check response headers | Restrict camera, microphone, geolocation | P3 |
| 2.7 | X-XSS-Protection disabled | Check response headers | Set to `0` (CSP supersedes this; `1` can cause issues) | P4 |

### Security Headers Middleware

```php
// app/Http/Middleware/SecurityHeaders.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecurityHeaders
{
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        $response->headers->set('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'");
        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('X-Frame-Options', 'DENY');
        $response->headers->set('X-XSS-Protection', '0');
        $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
        $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');

        return $response;
    }
}
```

Register in `bootstrap/app.php`:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(\App\Http\Middleware\SecurityHeaders::class);
})
```

---

## 3. Authentication & Sessions

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 3.1 | Session cookie is secure (HTTPS only) | Read `config/session.php` | Set `'secure' => env('SESSION_SECURE_COOKIE', true)` | P1 |
| 3.2 | Session cookie is HTTP-only | Read `config/session.php` | Set `'http_only' => true` | P1 |
| 3.3 | Session cookie SameSite set | Read `config/session.php` | Set `'same_site' => 'lax'` | P2 |
| 3.4 | Login is rate-limited | Check login controller/route | Add `RateLimiter` or `throttle` middleware | P1 |
| 3.5 | Session regenerated on login | Check login logic | Add `$request->session()->regenerate()` | P1 |
| 3.6 | Password reset tokens expire | Read `config/auth.php` | Set `'passwords.*.expire' => 60` (minutes) | P2 |
| 3.7 | Bcrypt/Argon2 used for passwords | Grep for `md5(`, `sha1(` | Replace with `Hash::make()` | P1 |
| 3.8 | Remember me token is secure | Check auth implementation | Use Laravel's built-in remember token (auto-rotated) | P3 |
| 3.9 | Session lifetime is reasonable | Read `config/session.php` | Set `'lifetime' => 120` (minutes), `'expire_on_close' => false` | P3 |

---

## 4. Authorization & Access Control

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 4.1 | All routes have appropriate middleware | `php artisan route:list` | Add `auth`, `verified`, role middleware | P1 |
| 4.2 | Policies exist for all models with CRUD | Check `app/Policies/` | Generate with `php artisan make:policy` | P1 |
| 4.3 | Controllers use `$this->authorize()` | Grep controllers | Add authorization checks | P1 |
| 4.4 | No `$guarded = []` on models | Grep models | Replace with explicit `$fillable` | P2 |
| 4.5 | Form Requests use `$request->validated()` | Grep controllers | Replace `$request->all()` with `$request->validated()` | P2 |
| 4.6 | Admin routes are protected | Check `routes/web.php` | Add role/permission middleware | P1 |
| 4.7 | API routes use Sanctum/auth | Check `routes/api.php` | Add `auth:sanctum` middleware | P1 |

---

## 5. Input Validation

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 5.1 | All POST/PUT/PATCH use Form Requests | Grep controllers for `Request $request` vs custom requests | Create Form Request classes | P2 |
| 5.2 | String inputs have max length | Check Form Request rules | Add `'max:255'` or appropriate limit | P2 |
| 5.3 | Email inputs validated as email | Check rules | Add `'email:rfc,dns'` rule | P3 |
| 5.4 | Numeric inputs bounded | Check rules | Add `'integer'`, `'min:0'`, `'max:...'` | P3 |
| 5.5 | File uploads have MIME validation | Check rules | Add `'mimes:jpg,png,pdf'` and `'max:...'` | P1 |
| 5.6 | No `$request->all()` in create/update | Grep for `$request->all()` | Replace with `$request->validated()` | P2 |

---

## 6. Database Security

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 6.1 | No raw queries with user input | Grep for `DB::raw(`, `whereRaw(` with `$request` | Use parameterized bindings | P1 |
| 6.2 | Database credentials via `.env` only | Check `config/database.php` | Use `env()` for all credentials | P1 |
| 6.3 | Sensitive fields encrypted | Check models for PII columns | Add `'encrypted'` cast | P2 |
| 6.4 | Soft deletes where appropriate | Check models | Add `SoftDeletes` trait for audit trail | P3 |
| 6.5 | No `DB::unprepared()` with variables | Grep for `DB::unprepared` | Use prepared queries | P1 |

---

## 7. Dependency Security

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 7.1 | No known vulnerabilities | `composer audit` | Update vulnerable packages | P1 |
| 7.2 | `roave/security-advisories` installed | Check `composer.json` | `composer require --dev roave/security-advisories:dev-latest` | P2 |
| 7.3 | Dependencies up to date | `composer outdated` | `composer update` with testing | P3 |
| 7.4 | `composer.lock` committed | Check `.gitignore` | Ensure `composer.lock` is tracked | P2 |
| 7.5 | No abandoned packages | `composer outdated` | Replace abandoned packages | P3 |
| 7.6 | NPM dependencies audited | `npm audit` | `npm audit fix` or update packages | P2 |

---

## 8. File System Security

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 8.1 | Storage directory not publicly accessible | Check web server config | Ensure `storage/` is not in webroot | P1 |
| 8.2 | Upload files stored outside webroot | Check upload logic | Use `Storage::disk('local')` or `s3` | P1 |
| 8.3 | `.env` not accessible via web | Try accessing `/.env` | Configure web server to block dotfiles | P1 |
| 8.4 | `.git` not accessible via web | Try accessing `/.git/` | Block `.git` in server config | P1 |
| 8.5 | Directory listing disabled | Check server config | Disable `Options +Indexes` | P2 |
| 8.6 | `storage/logs` not web accessible | Try accessing `/storage/logs/` | Block via server config | P1 |

---

## 9. Logging & Monitoring

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 9.1 | No passwords/tokens in logs | Grep log files for sensitive patterns | Fix logging calls to exclude sensitive data | P1 |
| 9.2 | Security events are logged | Check for auth event listeners | Add listeners for login, failed login, logout, password reset | P2 |
| 9.3 | Log files are rotated | Check `config/logging.php` | Use `daily` channel with `days` limit | P3 |
| 9.4 | Stack traces hidden in production | Check exception handler | Ensure `APP_DEBUG=false` | P1 |
| 9.5 | Failed login attempts logged | Check auth logic | Add `Log::warning` on failed attempts with IP | P2 |

---

## 10. Deployment Security

| # | Check | How to Verify | How to Fix | Priority |
|---|---|---|---|---|
| 10.1 | HTTPS enforced | Check server/middleware config | Add `\Illuminate\Http\Middleware\HandleCors` and HTTPS redirect | P1 |
| 10.2 | Server version headers hidden | Check response headers | Remove `X-Powered-By`, `Server` headers | P3 |
| 10.3 | Artisan commands restricted | Check web server config | Block access to artisan from web | P1 |
| 10.4 | Debug tools disabled | Check for Telescope/Debugbar | Disable in production `.env` | P1 |
| 10.5 | Error pages customized | Check `resources/views/errors/` | Create custom 404, 500, 503 pages (no stack traces) | P3 |
| 10.6 | CORS properly configured | Read `config/cors.php` | Restrict `allowed_origins` to known domains | P2 |
| 10.7 | Rate limiting configured | Check `RouteServiceProvider` or `AppServiceProvider` | Configure `RateLimiter::for()` for API and auth routes | P2 |

---

## Hardening Scorecard

When running `/soc harden`, output a scorecard in this format:

```markdown
## Security Hardening Scorecard

**Application:** [App Name]
**Date:** [Date]
**Overall Score:** [X] / [Total] checks passed ([Percentage]%)

| Category | Passed | Total | Score |
|---|---|---|---|
| Environment Configuration | X | 7 | X% |
| Security Headers | X | 7 | X% |
| Authentication & Sessions | X | 9 | X% |
| Authorization & Access Control | X | 7 | X% |
| Input Validation | X | 6 | X% |
| Database Security | X | 5 | X% |
| Dependency Security | X | 6 | X% |
| File System Security | X | 6 | X% |
| Logging & Monitoring | X | 5 | X% |
| Deployment Security | X | 7 | X% |

### Critical Findings (P1)
- [ ] Finding 1 — description and fix
- [ ] Finding 2 — description and fix

### High Priority (P2)
- [ ] Finding 3 — description and fix

### Recommendations
1. First thing to fix...
2. Second thing to fix...
```
