# Security Hardening Checklist — Web Applications

Read this file when running `/soc harden` to systematically improve the security posture of any web application.

---

## 1. Environment Configuration

| # | Check | Priority |
|---|---|---|
| 1.1 | Debug mode disabled in production | P1 |
| 1.2 | Environment set to production | P1 |
| 1.3 | Application secret key is set and rotated | P1 |
| 1.4 | Environment/secret files excluded from version control | P1 |
| 1.5 | Example/template env files contain no real secrets | P2 |
| 1.6 | Application URL uses HTTPS | P2 |
| 1.7 | Logging configured for production (rotation, appropriate level) | P3 |

<details>
<summary><strong>Stack-Specific Notes — Environment Configuration</strong></summary>

**Laravel/PHP**
- 1.1: Read `.env` — set `APP_DEBUG=false`
- 1.2: Read `.env` — set `APP_ENV=production`
- 1.3: Run `php artisan key:generate --show` to check; `php artisan key:generate` to set
- 1.4: Ensure `.env` is in `.gitignore`
- 1.5: Read `.env.example` and replace real values with placeholders
- 1.6: Set `APP_URL=https://...` in `.env`
- 1.7: Read `config/logging.php` — use `stack` or `daily` channel, not `single` in production

**Node.js/Express**
- 1.1: Ensure `NODE_ENV=production`; remove or disable any `debug: true` flags in config
- 1.2: Set `NODE_ENV=production` in environment
- 1.3: Verify `SESSION_SECRET` or `JWT_SECRET` is set in environment and is a strong random value
- 1.4: Ensure `.env` is in `.gitignore`; use `dotenv` only in development
- 1.5: Check `.env.example` for leaked secrets
- 1.6: Set app base URL to `https://` in config; enforce in reverse proxy
- 1.7: Use a structured logger (e.g., `winston`, `pino`) with log rotation and appropriate log level (`info` or `warn` in production)

**Python/Django**
- 1.1: In `settings.py`, set `DEBUG = False`
- 1.2: Use a production settings module (e.g., `settings/production.py`) or set `DJANGO_SETTINGS_MODULE` appropriately
- 1.3: Verify `SECRET_KEY` is set via environment variable and is a strong random value; never commit it
- 1.4: Ensure `.env` and any local settings files are in `.gitignore`
- 1.5: Check `env.example` or `settings/local.py.example` for leaked secrets
- 1.6: Set `SECURE_SSL_REDIRECT = True` and use HTTPS in `ALLOWED_HOSTS`
- 1.7: Configure `LOGGING` dict in settings — use `RotatingFileHandler` or external log aggregation

**Ruby/Rails**
- 1.1: Ensure `config.consider_all_requests_local = false` in `config/environments/production.rb`
- 1.2: Set `RAILS_ENV=production`
- 1.3: Verify `SECRET_KEY_BASE` is set via `credentials.yml.enc` or environment variable; run `rails secret` to generate
- 1.4: Ensure `config/master.key` and `.env` are in `.gitignore`
- 1.5: Check any example config files for leaked secrets
- 1.6: Set `config.force_ssl = true` in `config/environments/production.rb`
- 1.7: Configure `config.log_level = :info` in production; use `lograge` gem for structured logging

</details>

---

## 2. Security Headers

| # | Check | Priority |
|---|---|---|
| 2.1 | Content-Security-Policy set | P2 |
| 2.2 | Strict-Transport-Security set | P2 |
| 2.3 | X-Content-Type-Options set | P2 |
| 2.4 | X-Frame-Options set | P2 |
| 2.5 | Referrer-Policy set | P3 |
| 2.6 | Permissions-Policy set | P3 |
| 2.7 | X-XSS-Protection disabled (set to `0`; CSP supersedes it) | P4 |

<details>
<summary><strong>Stack-Specific Notes — Security Headers Middleware</strong></summary>

**Laravel/PHP**

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

**Node.js/Express**

```js
// middleware/securityHeaders.js
const helmet = require('helmet');

// Using helmet (recommended):
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            fontSrc: ["'self'"],
            connectSrc: ["'self'"],
            frameAncestors: ["'none'"],
            baseUri: ["'self'"],
            formAction: ["'self'"],
        },
    },
    strictTransportSecurity: { maxAge: 31536000, includeSubDomains: true },
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
    permissionsPolicy: {
        features: { camera: [], microphone: [], geolocation: [] },
    },
}));

// Or manually:
app.use((req, res, next) => {
    res.setHeader('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'");
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '0');
    res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    res.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    next();
});
```

**Python/Django**

```python
# In settings.py — Django has many built-in security header settings:
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = False  # X-XSS-Protection: 0 (let CSP handle it)
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_REFERRER_POLICY = 'strict-origin-when-cross-origin'

# For CSP and Permissions-Policy, use django-csp and custom middleware:
# pip install django-csp
CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'",)
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")
CSP_IMG_SRC = ("'self'", "data:", "https:")
CSP_FONT_SRC = ("'self'",)
CSP_CONNECT_SRC = ("'self'",)
CSP_FRAME_ANCESTORS = ("'none'",)
CSP_BASE_URI = ("'self'",)
CSP_FORM_ACTION = ("'self'",)

# Custom middleware for Permissions-Policy:
class PermissionsPolicyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response['Permissions-Policy'] = 'camera=(), microphone=(), geolocation=()'
        return response
```

Add to `MIDDLEWARE` in settings:

```python
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'csp.middleware.CSPMiddleware',
    'yourapp.middleware.PermissionsPolicyMiddleware',
    # ...
]
```

**Ruby/Rails**

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src  :self
  policy.style_src   :self, :unsafe_inline
  policy.img_src     :self, :data, :https
  policy.font_src    :self
  policy.connect_src :self
  policy.frame_ancestors :none
  policy.base_uri    :self
  policy.form_action :self
end

# config/environments/production.rb
config.force_ssl = true  # Enables HSTS automatically

# For additional headers, add middleware or use secure_headers gem:
# Gemfile: gem 'secure_headers'
# config/initializers/secure_headers.rb
SecureHeaders::Configuration.default do |config|
  config.x_content_type_options = "nosniff"
  config.x_frame_options = "DENY"
  config.x_xss_protection = "0"
  config.referrer_policy = %w[strict-origin-when-cross-origin]
  config.permissions_policy = {
    camera: [], microphone: [], geolocation: []
  }
end
```

</details>

---

## 3. Authentication & Sessions

| # | Check | Priority |
|---|---|---|
| 3.1 | Session cookie is secure (HTTPS only) | P1 |
| 3.2 | Session cookie is HTTP-only | P1 |
| 3.3 | Session cookie SameSite attribute set | P2 |
| 3.4 | Login endpoint is rate-limited | P1 |
| 3.5 | Session regenerated on login | P1 |
| 3.6 | Password reset tokens expire within a reasonable time | P2 |
| 3.7 | Strong password hashing (bcrypt/Argon2) — no MD5/SHA1 | P1 |
| 3.8 | Remember-me tokens are secure and rotated | P3 |
| 3.9 | Session lifetime is reasonable (not infinite) | P3 |

<details>
<summary><strong>Stack-Specific Notes — Authentication & Sessions</strong></summary>

**Laravel/PHP**
- 3.1: In `config/session.php` — set `'secure' => env('SESSION_SECURE_COOKIE', true)`
- 3.2: In `config/session.php` — set `'http_only' => true`
- 3.3: In `config/session.php` — set `'same_site' => 'lax'`
- 3.4: Add `throttle` middleware to login route or use `RateLimiter`
- 3.5: Call `$request->session()->regenerate()` after authentication
- 3.6: In `config/auth.php` — set `'passwords.*.expire' => 60`
- 3.7: Grep for `md5(`, `sha1(` — replace with `Hash::make()`
- 3.8: Use Laravel's built-in remember token (auto-rotated)
- 3.9: In `config/session.php` — set `'lifetime' => 120`

**Node.js/Express**
- 3.1: In `express-session` config — set `cookie: { secure: true }`
- 3.2: In `express-session` config — set `cookie: { httpOnly: true }`
- 3.3: In `express-session` config — set `cookie: { sameSite: 'lax' }`
- 3.4: Use `express-rate-limit` on login routes: `rateLimit({ windowMs: 15 * 60 * 1000, max: 10 })`
- 3.5: Call `req.session.regenerate()` after successful login
- 3.6: Set TTL on reset tokens in your database or use `jsonwebtoken` with `expiresIn`
- 3.7: Use `bcrypt` or `argon2` package — grep for `crypto.createHash('md5')` or `sha1`
- 3.8: Implement token rotation on each use; store hashed tokens
- 3.9: Set `cookie: { maxAge: 7200000 }` (ms) in session config

**Python/Django**
- 3.1: In `settings.py` — set `SESSION_COOKIE_SECURE = True`
- 3.2: In `settings.py` — set `SESSION_COOKIE_HTTPONLY = True`
- 3.3: In `settings.py` — set `SESSION_COOKIE_SAMESITE = 'Lax'`
- 3.4: Use `django-axes` or `django-ratelimit` on login views
- 3.5: Call `request.session.cycle_key()` after login (Django's `login()` does this automatically)
- 3.6: Set `PASSWORD_RESET_TIMEOUT` in settings (seconds, default 259200)
- 3.7: Django uses PBKDF2 by default; upgrade to Argon2 via `PASSWORD_HASHERS` setting
- 3.8: Django's `AbstractBaseUser` rotates session hash on password change
- 3.9: Set `SESSION_COOKIE_AGE = 7200` (seconds) in settings

**Ruby/Rails**
- 3.1: In `config/environments/production.rb` — `config.force_ssl = true` (makes cookies secure)
- 3.2: Rails cookies are HTTP-only by default
- 3.3: Set `same_site: :lax` in cookie config or session store config
- 3.4: Use `rack-attack` gem: `Rack::Attack.throttle('logins/ip', limit: 10, period: 15.minutes)`
- 3.5: Call `reset_session` then set new session after authentication
- 3.6: Set `config.reset_password_within` in Devise, or implement token expiry manually
- 3.7: Use `has_secure_password` (bcrypt via `bcrypt` gem) — grep for `Digest::MD5` or `Digest::SHA1`
- 3.8: Devise rotates remember tokens; if custom, ensure rotation on each use
- 3.9: Set `expire_after` in session store config (e.g., `expire_after: 2.hours`)

</details>

---

## 4. Authorization & Access Control

| # | Check | Priority |
|---|---|---|
| 4.1 | All routes require appropriate authentication/authorization | P1 |
| 4.2 | Authorization policies or permissions exist for all protected resources | P1 |
| 4.3 | Controllers/handlers check authorization before acting | P1 |
| 4.4 | Mass assignment protection is in place | P2 |
| 4.5 | Only validated/permitted input is used for create/update | P2 |
| 4.6 | Admin/privileged routes are protected with role checks | P1 |
| 4.7 | API routes require authentication tokens | P1 |

<details>
<summary><strong>Stack-Specific Notes — Authorization & Access Control</strong></summary>

**Laravel/PHP**
- 4.1: Run `php artisan route:list` — ensure `auth`, `verified`, and role middleware are applied
- 4.2: Check `app/Policies/` — generate with `php artisan make:policy`
- 4.3: Use `$this->authorize()` or Gate checks in controllers
- 4.4: Grep models for `$guarded = []` — replace with explicit `$fillable`
- 4.5: Use `$request->validated()` from Form Requests instead of `$request->all()`
- 4.6: Add role/permission middleware to admin routes in `routes/web.php`
- 4.7: Add `auth:sanctum` middleware to API routes in `routes/api.php`

**Node.js/Express**
- 4.1: Ensure all routes have `authenticate` middleware; list routes to verify
- 4.2: Implement role/permission checks (e.g., `casl`, `accesscontrol`, or custom middleware)
- 4.3: Add authorization checks in route handlers before processing
- 4.4: Define allowed fields explicitly when using ORM (e.g., Sequelize `fields`, Mongoose `select`)
- 4.5: Use validated body from `express-validator` or `joi` — never pass `req.body` directly to ORM
- 4.6: Add admin role-check middleware to admin routes
- 4.7: Require Bearer token (JWT or API key) on all API endpoints

**Python/Django**
- 4.1: Use `@login_required`, `@permission_required`, or DRF `permission_classes` on all views
- 4.2: Define permissions in models' `Meta.permissions` and check with `has_perm()`
- 4.3: Check `request.user.has_perm()` or use `PermissionRequiredMixin` in class-based views
- 4.4: Use `ModelForm` with explicit `fields` — never use `fields = '__all__'` on sensitive models
- 4.5: Use `form.cleaned_data` or DRF `serializer.validated_data` — never use raw `request.POST`
- 4.6: Use `@staff_member_required` or `@user_passes_test` for admin views
- 4.7: Configure DRF `DEFAULT_AUTHENTICATION_CLASSES` and `DEFAULT_PERMISSION_CLASSES`

**Ruby/Rails**
- 4.1: Use `before_action :authenticate_user!` (Devise) on all controllers; review `routes.rb`
- 4.2: Use `Pundit` policies or `CanCanCan` abilities for all models
- 4.3: Call `authorize @resource` (Pundit) or `authorize!` (CanCanCan) in controller actions
- 4.4: Use `strong_parameters` — call `params.require(:model).permit(:field1, :field2)`
- 4.5: Never use `params.permit!` — always whitelist permitted fields
- 4.6: Add admin role checks via Pundit policy or `before_action` on admin controllers
- 4.7: Use `authenticate_user!` with Devise token auth or `doorkeeper` gem for OAuth

</details>

---

## 5. Input Validation

| # | Check | Priority |
|---|---|---|
| 5.1 | All mutation endpoints validate input before processing | P2 |
| 5.2 | String inputs have maximum length constraints | P2 |
| 5.3 | Email inputs are validated with proper format checks | P3 |
| 5.4 | Numeric inputs are bounded (min/max) | P3 |
| 5.5 | File uploads are validated for type and size | P1 |
| 5.6 | Only validated/sanitized input is passed to create/update operations | P2 |

<details>
<summary><strong>Stack-Specific Notes — Input Validation</strong></summary>

**Laravel/PHP**
- 5.1: Use Form Request classes for all POST/PUT/PATCH routes
- 5.2: Add `'max:255'` (or appropriate limit) to string rules
- 5.3: Use `'email:rfc,dns'` validation rule
- 5.4: Use `'integer'`, `'min:0'`, `'max:...'` rules
- 5.5: Use `'mimes:jpg,png,pdf'` and `'max:...'` (kilobytes) rules
- 5.6: Use `$request->validated()` — grep for and eliminate `$request->all()` in create/update calls

**Node.js/Express**
- 5.1: Use `express-validator`, `joi`, or `zod` for all input routes
- 5.2: Add `.isLength({ max: 255 })` or equivalent schema constraint
- 5.3: Use `.isEmail()` with `express-validator` or `Joi.string().email()`
- 5.4: Use `.isInt({ min: 0, max: ... })` or `Joi.number().integer().min(0).max(...)`
- 5.5: Use `multer` with `fileFilter` for MIME type and `limits: { fileSize: ... }` for size
- 5.6: Only pass validated fields (e.g., `matchedData(req)` from `express-validator`)

**Python/Django**
- 5.1: Use Django Forms or DRF Serializers for all input
- 5.2: Set `max_length=255` on `CharField` in forms/serializers
- 5.3: Use `EmailField` or `EmailValidator`
- 5.4: Use `IntegerField(min_value=0, max_value=...)`
- 5.5: Use `FileField` with custom validator for content type; set `FILE_UPLOAD_MAX_MEMORY_SIZE` and `DATA_UPLOAD_MAX_MEMORY_SIZE`
- 5.6: Use `form.cleaned_data` or `serializer.validated_data` — never use raw `request.POST` or `request.data`

**Ruby/Rails**
- 5.1: Use model validations and strong parameters for all controller actions
- 5.2: Add `validates :field, length: { maximum: 255 }` to models
- 5.3: Use `validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }`
- 5.4: Use `validates :field, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: ... }`
- 5.5: Use `ActiveStorage` with `content_type` and `size` validations (or `active_storage_validations` gem)
- 5.6: Always use `params.require(:model).permit(...)` — never bypass strong parameters

</details>

---

## 6. Database Security

| # | Check | Priority |
|---|---|---|
| 6.1 | No raw/unparameterized queries with user input | P1 |
| 6.2 | Database credentials stored in environment variables only | P1 |
| 6.3 | Sensitive/PII fields encrypted at rest | P2 |
| 6.4 | Soft deletes used where audit trail is needed | P3 |
| 6.5 | No unprepared/unsafe SQL execution with dynamic values | P1 |

<details>
<summary><strong>Stack-Specific Notes — Database Security</strong></summary>

**Laravel/PHP**
- 6.1: Grep for `DB::raw(`, `whereRaw(` with `$request` — use parameterized bindings
- 6.2: Read `config/database.php` — all credentials must use `env()`
- 6.3: Add `'encrypted'` cast to sensitive model attributes
- 6.4: Add `SoftDeletes` trait to models needing audit trail
- 6.5: Grep for `DB::unprepared()` with variables — replace with prepared queries

**Node.js/Express**
- 6.1: Grep for string concatenation in SQL (e.g., `` `SELECT * FROM users WHERE id = ${id}` ``) — use parameterized queries (`?` placeholders or ORM methods)
- 6.2: Store credentials in environment variables; use `process.env.DB_*` — never hardcode in source
- 6.3: Use application-level encryption (e.g., `crypto.createCipheriv`) or ORM plugins for sensitive fields
- 6.4: Implement soft deletes with a `deleted_at` column (Sequelize: `paranoid: true`; Prisma: custom middleware)
- 6.5: Never use `sequelize.query()` or `knex.raw()` with unescaped user input

**Python/Django**
- 6.1: Grep for `.raw(` and `.extra(` with formatted strings — use parameterized queries: `Model.objects.raw('SELECT ... WHERE id = %s', [user_id])`
- 6.2: Use `os.environ` or `django-environ` for database credentials in `settings.py`
- 6.3: Use `django-encrypted-model-fields` or `django-fernet-fields` for PII columns
- 6.4: Use `django-softdelete` or add a custom `deleted_at` field with manager override
- 6.5: Never use `cursor.execute()` with f-strings or `%` formatting — always pass params tuple

**Ruby/Rails**
- 6.1: Grep for `.where("column = '#{...}'")` — use parameterized form: `.where('column = ?', value)` or `.where(column: value)`
- 6.2: Use `credentials.yml.enc` or environment variables — never hardcode in `database.yml`
- 6.3: Use `attr_encrypted` gem or Active Record Encryption (Rails 7+)
- 6.4: Add `acts_as_paranoid` gem or use `discard` gem for soft deletes
- 6.5: Never use `ActiveRecord::Base.connection.execute()` with interpolated strings

</details>

---

## 7. Dependency Security

| # | Check | Priority |
|---|---|---|
| 7.1 | No known vulnerabilities in dependencies | P1 |
| 7.2 | Security advisory tooling is installed | P2 |
| 7.3 | Dependencies are reasonably up to date | P3 |
| 7.4 | Lock file is committed to version control | P2 |
| 7.5 | No abandoned/unmaintained packages | P3 |
| 7.6 | Frontend/secondary dependencies audited | P2 |

<details>
<summary><strong>Stack-Specific Notes — Dependency Security</strong></summary>

**Laravel/PHP**
- 7.1: Run `composer audit`
- 7.2: Install `roave/security-advisories` — `composer require --dev roave/security-advisories:dev-latest`
- 7.3: Run `composer outdated` — update with testing
- 7.4: Ensure `composer.lock` is tracked in Git
- 7.5: Run `composer outdated` and check for abandoned notices
- 7.6: Run `npm audit` for frontend assets — `npm audit fix` to auto-fix

**Node.js/Express**
- 7.1: Run `npm audit` or `yarn audit`
- 7.2: Enable `npm audit` in CI; use `snyk` or `socket.dev` for deeper analysis
- 7.3: Run `npm outdated` — update with testing
- 7.4: Ensure `package-lock.json` (npm) or `yarn.lock` (Yarn) is tracked in Git
- 7.5: Run `npx depcheck` to find unused deps; check npm pages for deprecation notices
- 7.6: If using Git submodules or Go/Python sub-projects, audit those separately

**Python/Django**
- 7.1: Run `pip-audit` (install via `pip install pip-audit`) or `safety check`
- 7.2: Install `pip-audit` or `safety` — add to CI pipeline
- 7.3: Run `pip list --outdated` — update with testing
- 7.4: Ensure `requirements.txt` or `poetry.lock` / `Pipfile.lock` is tracked in Git
- 7.5: Check PyPI pages for maintenance status; use `pyup.io` for monitoring
- 7.6: Run `npm audit` if frontend assets are managed with npm

**Ruby/Rails**
- 7.1: Run `bundle audit check --update` (install via `gem install bundler-audit`)
- 7.2: Install `bundler-audit` gem; use `brakeman` for static security analysis
- 7.3: Run `bundle outdated` — update with testing
- 7.4: Ensure `Gemfile.lock` is tracked in Git
- 7.5: Check RubyGems pages for maintenance status and deprecation notices
- 7.6: Run `npm audit` or `yarn audit` if Webpacker/jsbundling-rails is used

### Dependency Audit Commands — Quick Reference

| Stack | Audit Command | Fix Command |
|---|---|---|
| Laravel/PHP | `composer audit` | `composer update [package]` |
| Node.js | `npm audit` / `yarn audit` | `npm audit fix` / `yarn upgrade` |
| Python/Django | `pip-audit` / `safety check` | `pip install --upgrade [package]` |
| Ruby/Rails | `bundle audit check --update` | `bundle update [gem]` |

</details>

---

## 8. File System Security

| # | Check | Priority |
|---|---|---|
| 8.1 | Application storage/data directories are not publicly accessible | P1 |
| 8.2 | Uploaded files stored outside the web root | P1 |
| 8.3 | Environment/secret files not accessible via web | P1 |
| 8.4 | `.git` directory not accessible via web | P1 |
| 8.5 | Directory listing disabled on web server | P2 |
| 8.6 | Log files not accessible via web | P1 |

<details>
<summary><strong>Stack-Specific Notes — File System Security</strong></summary>

**Laravel/PHP**
- 8.1: Ensure `storage/` is not in the document root; only `public/` should be web-accessible
- 8.2: Use `Storage::disk('local')` or `s3` — store outside `public/`
- 8.3: Try accessing `/.env` from browser — block dotfiles in web server config (Nginx: `location ~ /\. { deny all; }`)
- 8.4: Try accessing `/.git/` — block in server config
- 8.5: Disable `Options +Indexes` in Apache or `autoindex off` in Nginx
- 8.6: Ensure `/storage/logs/` is blocked via server config

**Node.js/Express**
- 8.1: Ensure `express.static()` only serves the intended public directory — never the project root
- 8.2: Store uploads outside the static directory; use cloud storage (S3) or a non-served path
- 8.3: Ensure `.env` is not in the static directory; add dotfile blocking if using `serve-static`
- 8.4: Do not serve the project root — keep static serving limited to `public/` or `dist/`
- 8.5: Set `dotfiles: 'deny'` in `express.static()` options
- 8.6: Store logs outside the served directory; never place log files in `public/`

**Python/Django**
- 8.1: Ensure `MEDIA_ROOT` and project directories are not served by the web server directly
- 8.2: Store uploads via `MEDIA_ROOT` outside the document root; use `django-storages` for S3
- 8.3: Configure web server to block `/settings.py`, `.env`, and dotfiles
- 8.4: Block `/.git/` in web server config
- 8.5: Disable `autoindex` in Nginx or `Options +Indexes` in Apache
- 8.6: Store logs outside web-served directories

**Ruby/Rails**
- 8.1: Only `public/` is web-served — ensure `tmp/`, `log/`, `storage/` are not exposed
- 8.2: Use Active Storage with disk service (stored in `storage/`) or cloud service (S3, GCS)
- 8.3: Block access to `config/master.key`, `.env`, and dotfiles in web server config
- 8.4: Block `/.git/` in web server config
- 8.5: Disable directory listing in web server (Nginx: `autoindex off`)
- 8.6: Ensure `/log/` is not web-accessible

</details>

---

## 9. Logging & Monitoring

| # | Check | Priority |
|---|---|---|
| 9.1 | No passwords, tokens, or secrets written to logs | P1 |
| 9.2 | Security-relevant events are logged (login, failed login, logout, password changes) | P2 |
| 9.3 | Log files are rotated and have retention limits | P3 |
| 9.4 | Stack traces and debug info hidden from end users in production | P1 |
| 9.5 | Failed authentication attempts logged with IP address | P2 |

<details>
<summary><strong>Stack-Specific Notes — Logging & Monitoring</strong></summary>

**Laravel/PHP**
- 9.1: Grep log files for sensitive patterns (passwords, tokens, keys)
- 9.2: Add listeners for `Login`, `Failed`, `Logout`, `PasswordReset` auth events
- 9.3: Use `daily` channel with `'days' => 14` in `config/logging.php`
- 9.4: Set `APP_DEBUG=false` — exceptions render generic error pages in production
- 9.5: Listen for `Illuminate\Auth\Events\Failed` and log IP via `$event->request->ip()`

**Node.js/Express**
- 9.1: Review logger calls — filter out `password`, `token`, `secret` fields before logging
- 9.2: Log authentication events in auth middleware/routes (success, failure, logout)
- 9.3: Use `winston` with `DailyRotateFile` transport or `pino` with `pino-roll`
- 9.4: Set custom error handler that returns generic messages in production: `app.use((err, req, res, next) => { res.status(500).json({ error: 'Internal Server Error' }) })`
- 9.5: Log `req.ip` on failed authentication attempts

**Python/Django**
- 9.1: Review logging calls — use Django's `SensitiveVariablesFilter` and `SensitivePostParametersFilter`
- 9.2: Use Django signals (`user_logged_in`, `user_logged_out`, `user_login_failed`) to log events
- 9.3: Use `RotatingFileHandler` or `TimedRotatingFileHandler` in `LOGGING` config
- 9.4: Set `DEBUG = False` — Django shows generic 500 pages; customize `500.html` template
- 9.5: Listen for `user_login_failed` signal and log `request.META.get('REMOTE_ADDR')`

**Ruby/Rails**
- 9.1: Use `config.filter_parameters += [:password, :token, :secret]` in `application.rb`
- 9.2: Use `Warden` callbacks or `ActiveSupport::Notifications` to log auth events
- 9.3: Use `lograge` gem; configure log rotation via `logrotate` on the server
- 9.4: Set `config.consider_all_requests_local = false` in production — customize error pages in `public/`
- 9.5: Log `request.remote_ip` on failed authentication via Warden `after_failed_fetch` callback

</details>

---

## 10. Deployment Security

| # | Check | Priority |
|---|---|---|
| 10.1 | HTTPS enforced for all traffic | P1 |
| 10.2 | Server version headers hidden (`X-Powered-By`, `Server`) | P3 |
| 10.3 | CLI/management tools not accessible from web | P1 |
| 10.4 | Debug tools and profilers disabled in production | P1 |
| 10.5 | Error pages customized (no stack traces exposed) | P3 |
| 10.6 | CORS properly configured with restricted origins | P2 |
| 10.7 | Rate limiting configured on API and authentication endpoints | P2 |

<details>
<summary><strong>Stack-Specific Notes — Deployment Security</strong></summary>

**Laravel/PHP**
- 10.1: Add HTTPS redirect middleware; use `\Illuminate\Http\Middleware\TrustProxies` behind load balancer
- 10.2: Remove `X-Powered-By` in `php.ini` (`expose_php = Off`); remove `Server` header in web server config
- 10.3: Block web access to `artisan`, `composer.json`, `composer.lock` via server config
- 10.4: Disable Telescope, Debugbar, etc. in production `.env` (`TELESCOPE_ENABLED=false`, `DEBUGBAR_ENABLED=false`)
- 10.5: Customize `resources/views/errors/` (404, 500, 503) — no stack traces
- 10.6: Read `config/cors.php` — restrict `allowed_origins` to known domains
- 10.7: Configure `RateLimiter::for()` in `AppServiceProvider` for API and auth routes

**Node.js/Express**
- 10.1: Use `app.set('trust proxy', 1)` behind reverse proxy; redirect HTTP to HTTPS in server or proxy
- 10.2: Use `app.disable('x-powered-by')` or `helmet.hidePoweredBy()`; configure reverse proxy to strip `Server`
- 10.3: Do not expose `package.json`, `node_modules/`, or admin scripts via static serving
- 10.4: Remove or conditionally load `morgan` (verbose), `swagger-ui`, or debug endpoints in production
- 10.5: Use a custom error handler that returns generic JSON/HTML — never send `err.stack` in responses
- 10.6: Use `cors` package with explicit `origin` whitelist — never use `origin: '*'` in production
- 10.7: Use `express-rate-limit` — apply stricter limits on `/auth/*` and `/api/*` routes

**Python/Django**
- 10.1: Set `SECURE_SSL_REDIRECT = True` in settings; configure HTTPS at reverse proxy
- 10.2: Configure Nginx/Apache to strip `Server` header; Django does not add `X-Powered-By`
- 10.3: Ensure `manage.py` and Django settings are not web-accessible; block in server config
- 10.4: Ensure `django-debug-toolbar` is not in `INSTALLED_APPS` in production; check `DEBUG = False`
- 10.5: Customize `templates/404.html`, `500.html` — no debug info
- 10.6: Use `django-cors-headers` — set `CORS_ALLOWED_ORIGINS` to a strict list
- 10.7: Use `django-ratelimit` or DRF's `DEFAULT_THROTTLE_RATES` for API and auth endpoints

**Ruby/Rails**
- 10.1: Set `config.force_ssl = true` in `config/environments/production.rb`
- 10.2: Configure Nginx/Apache to strip `Server` header; remove `X-Powered-By` via middleware or `secure_headers`
- 10.3: Block access to `Gemfile`, `Rakefile`, `config/` via web server config
- 10.4: Ensure `web-console`, `better_errors` are in `:development` group only in Gemfile
- 10.5: Customize `public/404.html`, `public/500.html` — no stack traces
- 10.6: Use `rack-cors` gem — set `origins` to specific allowed domains
- 10.7: Use `rack-attack` gem — configure throttles for login and API endpoints

</details>

---

## Hardening Scorecard

When running `/soc harden`, output a scorecard in this format:

```markdown
## Security Hardening Scorecard

**Application:** [App Name]
**Stack:** [e.g., Laravel, Express, Django, Rails]
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
