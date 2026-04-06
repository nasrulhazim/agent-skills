# Remediation Playbooks — Laravel/PHP Fix Procedures

Read this file when remediating vulnerabilities. Each playbook provides before/after code, Laravel-specific implementation, and a Pest test to prevent regression.

---

## 1. SQL Injection

### Before (Vulnerable)

```php
// Raw query with string interpolation
$users = DB::select("SELECT * FROM users WHERE email = '$request->email'");

// Unparameterized whereRaw
$results = User::whereRaw("name LIKE '%{$request->search}%'")->get();

// Concatenated DB::raw
$orders = Order::whereRaw("status = '" . $request->status . "'")->get();
```

### After (Remediated)

```php
// Parameterized query
$users = DB::select("SELECT * FROM users WHERE email = ?", [$request->email]);

// Parameterized whereRaw with bindings
$results = User::whereRaw("name LIKE ?", ['%' . $request->search . '%'])->get();

// Use Eloquent instead of raw
$orders = Order::where('status', $request->validated('status'))->get();
```

### Laravel Best Practice

- Always use Eloquent query builder over raw queries
- When `whereRaw()` is unavoidable, always pass bindings as second argument
- Use Form Request validation to constrain input before it reaches queries
- Replace `DB::unprepared()` with prepared alternatives

### Verification

1. Run the query with a payload like `' OR 1=1 --` — it should return no results or error safely
2. Check that bindings appear in query log (`DB::enableQueryLog()`)

### Pest Test

```php
it('prevents SQL injection in search', function () {
    User::factory()->create(['name' => 'Alice']);

    $response = $this->actingAs(User::factory()->create())
        ->get('/users?search=' . urlencode("' OR 1=1 --"));

    $response->assertOk();
    expect($response->json('data'))->toBeEmpty();
});
```

---

## 2. Cross-Site Scripting (XSS)

### Before (Vulnerable)

```php
// Blade: unescaped output
<p>{!! $user->bio !!}</p>
<input value="{!! old('name') !!}">
<div>{!! $comment->body !!}</div>
```

### After (Remediated)

```php
// Option A: Use escaped output (preferred)
<p>{{ $user->bio }}</p>
<input value="{{ old('name') }}">

// Option B: If HTML is required, sanitize before storage
use Sterilize\Sanitizer; // or a similar HTML purifier
<div>{!! clean($comment->body) !!}</div>

// Option C: Use strip_tags for plain text
<p>{{ strip_tags($user->bio) }}</p>
```

### Laravel Best Practice

- Default to `{{ }}` (escaped) — only use `{!! !!}` when HTML rendering is explicitly required
- If HTML rendering is needed, sanitize on **input** (before storage) using a library like `mews/purifier`
- Add Content-Security-Policy header via middleware to mitigate impact of any XSS

### CSP Middleware

```php
// app/Http/Middleware/SecurityHeaders.php
public function handle(Request $request, Closure $next): Response
{
    $response = $next($request);

    $response->headers->set('Content-Security-Policy', "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'");
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-Frame-Options', 'DENY');
    $response->headers->set('X-XSS-Protection', '0');
    $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');

    return $response;
}
```

### Pest Test

```php
it('escapes user input in profile display', function () {
    $user = User::factory()->create([
        'bio' => '<script>alert("xss")</script>',
    ]);

    $response = $this->actingAs($user)->get('/profile/' . $user->id);

    $response->assertOk();
    $response->assertDontSee('<script>', false);
    $response->assertSee('&lt;script&gt;');
});
```

---

## 3. CSRF Protection

### Before (Vulnerable)

```php
// Overly broad CSRF exclusion
class VerifyCsrfToken extends Middleware
{
    protected $except = [
        'api/*',           // Too broad — excludes all API routes
        'payment/callback',
    ];
}

// Form missing @csrf
<form method="POST" action="/transfer">
    <input name="amount" value="1000">
    <button>Send</button>
</form>
```

### After (Remediated)

```php
// Narrow CSRF exclusion — only true external webhooks
class VerifyCsrfToken extends Middleware
{
    protected $except = [
        'webhooks/stripe',    // Verified by Stripe signature
        'webhooks/github',    // Verified by GitHub HMAC
    ];
}

// Form with CSRF token
<form method="POST" action="/transfer">
    @csrf
    <input name="amount" value="1000">
    <button>Send</button>
</form>
```

### Laravel Best Practice

- Never exclude broad patterns like `api/*` from CSRF
- For true external webhooks, verify with provider-specific signature validation instead of relying on CSRF
- For SPA, use Sanctum's `sanctum/csrf-cookie` endpoint
- Verify all `<form method="POST|PUT|PATCH|DELETE">` include `@csrf`

### Webhook Signature Verification

```php
// Instead of CSRF exclusion, verify webhook signature
public function handleStripeWebhook(Request $request): Response
{
    $signature = $request->header('Stripe-Signature');

    try {
        $event = Webhook::constructEvent(
            $request->getContent(),
            $signature,
            config('services.stripe.webhook_secret')
        );
    } catch (SignatureVerificationException $e) {
        abort(403, 'Invalid signature');
    }

    // Process event...
}
```

### Pest Test

```php
it('rejects POST requests without CSRF token', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->withoutMiddleware([\Illuminate\Foundation\Http\Middleware\VerifyCsrfToken::class])
        ->post('/transfer', ['amount' => 1000]);

    // Re-enable middleware and verify it blocks
    $response = $this->actingAs($user)
        ->post('/transfer', ['amount' => 1000]);

    $response->assertStatus(419);
});
```

---

## 4. Broken Authentication

### Before (Vulnerable)

```php
// Weak hashing
$user->password = md5($request->password);

// No rate limiting
public function login(Request $request)
{
    if (Auth::attempt($request->only('email', 'password'))) {
        return redirect('/dashboard');
    }
}

// No session regeneration
Auth::login($user);
```

### After (Remediated)

```php
// Proper hashing (Laravel default)
$user->password = Hash::make($request->password);

// Rate-limited login with session regeneration
public function login(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    $throttleKey = Str::lower($request->email) . '|' . $request->ip();

    if (RateLimiter::tooManyAttempts($throttleKey, 5)) {
        $seconds = RateLimiter::availableIn($throttleKey);
        throw ValidationException::withMessages([
            'email' => __('auth.throttle', ['seconds' => $seconds]),
        ]);
    }

    if (! Auth::attempt($request->only('email', 'password'), $request->boolean('remember'))) {
        RateLimiter::hit($throttleKey);
        throw ValidationException::withMessages([
            'email' => __('auth.failed'),
        ]);
    }

    RateLimiter::clear($throttleKey);
    $request->session()->regenerate();

    return redirect()->intended('/dashboard');
}
```

### Laravel Best Practice

- Always use `Hash::make()` — never `md5()`, `sha1()`, or `password_hash()` directly
- Apply rate limiting using `RateLimiter` (5 attempts per email+IP)
- Regenerate session after login: `$request->session()->regenerate()`
- Configure secure session settings in `config/session.php`:
  - `'secure' => true` (HTTPS only)
  - `'http_only' => true` (no JavaScript access)
  - `'same_site' => 'lax'` (or `'strict'`)

### Pest Test

```php
it('rate limits login attempts', function () {
    $user = User::factory()->create();

    for ($i = 0; $i < 5; $i++) {
        $this->post('/login', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ]);
    }

    $response = $this->post('/login', [
        'email' => $user->email,
        'password' => 'wrong-password',
    ]);

    $response->assertSessionHasErrors('email');
    expect($response->json('errors.email.0') ?? session('errors')?->first('email'))
        ->toContain('Too many');
});

it('regenerates session after login', function () {
    $user = User::factory()->create(['password' => Hash::make('password')]);
    $oldSessionId = session()->getId();

    $this->post('/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);

    expect(session()->getId())->not->toBe($oldSessionId);
});
```

---

## 5. Broken Access Control (IDOR)

### Before (Vulnerable)

```php
// No ownership check
public function show($id)
{
    $invoice = Invoice::findOrFail($id);
    return view('invoices.show', compact('invoice'));
}

// No authorization
public function update(Request $request, $id)
{
    $document = Document::findOrFail($id);
    $document->update($request->all());
}
```

### After (Remediated)

```php
// Option A: Scope query to authenticated user
public function show(Invoice $invoice)
{
    // Route model binding + policy
    $this->authorize('view', $invoice);
    return view('invoices.show', compact('invoice'));
}

// Option B: Scope via relationship
public function show(Invoice $invoice)
{
    $invoice = $request->user()->invoices()->findOrFail($invoice->id);
    return view('invoices.show', compact('invoice'));
}

// With validated input
public function update(UpdateDocumentRequest $request, Document $document)
{
    $this->authorize('update', $document);
    $document->update($request->validated());
}
```

### Policy Implementation

```php
// app/Policies/InvoicePolicy.php
class InvoicePolicy
{
    public function view(User $user, Invoice $invoice): bool
    {
        return $user->id === $invoice->user_id;
    }

    public function update(User $user, Invoice $invoice): bool
    {
        return $user->id === $invoice->user_id;
    }

    public function delete(User $user, Invoice $invoice): bool
    {
        return $user->id === $invoice->user_id;
    }
}
```

### Pest Test

```php
it('prevents users from viewing other users invoices', function () {
    $owner = User::factory()->create();
    $otherUser = User::factory()->create();
    $invoice = Invoice::factory()->for($owner)->create();

    $response = $this->actingAs($otherUser)->get('/invoices/' . $invoice->id);

    $response->assertForbidden();
});
```

---

## 6. Mass Assignment

### Before (Vulnerable)

```php
// Empty guarded
class User extends Model
{
    protected $guarded = [];
}

// Using $request->all()
User::create($request->all());
$user->update($request->all());
$user->fill($request->input())->save();
```

### After (Remediated)

```php
// Explicit fillable fields
class User extends Model
{
    protected $fillable = [
        'name',
        'email',
        'password',
    ];
}

// Using validated data from Form Request
User::create($request->validated());
$user->update($request->validated());
```

### Form Request

```php
class UpdateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email,' . $this->user()->id],
        ];
        // Note: password and is_admin are NOT in rules — cannot be mass-assigned via this request
    }
}
```

### Pest Test

```php
it('prevents mass assignment of admin flag', function () {
    $user = User::factory()->create(['is_admin' => false]);

    $this->actingAs($user)->put('/profile', [
        'name' => 'Updated Name',
        'email' => $user->email,
        'is_admin' => true,
    ]);

    expect($user->fresh()->is_admin)->toBeFalse();
});
```

---

## 7. Insecure Deserialization

### Before (Vulnerable)

```php
$data = unserialize($request->input('data'));
$prefs = unserialize($_COOKIE['preferences']);
$cache = unserialize(file_get_contents($cacheFile));
```

### After (Remediated)

```php
// Use JSON instead
$data = json_decode($request->input('data'), true, 512, JSON_THROW_ON_ERROR);
$prefs = json_decode($request->cookie('preferences'), true);
$cache = json_decode(file_get_contents($cacheFile), true);

// If unserialize is absolutely required, use allowed_classes
$data = unserialize($serialized, ['allowed_classes' => [AllowedClass::class]]);
```

### Laravel Best Practice

- Never `unserialize()` user input — always use `json_decode()`
- For caching, use Laravel's Cache facade (handles serialization safely)
- For queue payloads, rely on Laravel's built-in signed serialization
- If `unserialize()` is unavoidable, restrict with `allowed_classes`
- Remove all `eval()`, `assert()` with variables, `create_function()`

### Pest Test

```php
it('handles malformed JSON input gracefully', function () {
    $response = $this->postJson('/api/data', [
        'payload' => '{"valid": "json"}',
    ]);

    $response->assertOk();
});

it('rejects serialized PHP input', function () {
    $response = $this->postJson('/api/data', [
        'payload' => 'O:8:"stdClass":1:{s:4:"evil";s:4:"code";}',
    ]);

    $response->assertUnprocessable();
});
```

---

## 8. File Upload Vulnerabilities

### Before (Vulnerable)

```php
// Trusting client filename and no MIME validation
$path = $request->file('avatar')->storeAs(
    'avatars',
    $request->file('avatar')->getClientOriginalName(),
    'public'
);
```

### After (Remediated)

```php
// Validated upload with safe filename
$request->validate([
    'avatar' => ['required', 'file', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
]);

$path = $request->file('avatar')->store(
    'avatars',    // Let Laravel generate a safe UUID filename
    's3'          // Store outside web root
);
```

### Laravel Best Practice

- Always validate with `mimes:` or `mimetypes:` rules
- Never use `getClientOriginalName()` as the stored filename
- Use `store()` (auto UUID filename) instead of `storeAs()` with client names
- Store uploads on non-public disk (`s3`, `local`) — serve via signed URLs or controller
- Set `max:` file size limit in validation rules
- For sensitive files, serve through a controller with authorization checks

### Serving Private Files

```php
public function download(Document $document)
{
    $this->authorize('download', $document);

    return Storage::disk('s3')->download(
        $document->path,
        $document->original_name  // Safe: only used as download name, not file path
    );
}
```

### Pest Test

```php
it('rejects non-image file uploads', function () {
    $file = UploadedFile::fake()->create('malware.php', 100);

    $response = $this->actingAs(User::factory()->create())
        ->post('/profile/avatar', ['avatar' => $file]);

    $response->assertSessionHasErrors('avatar');
});

it('stores uploads with safe filenames', function () {
    Storage::fake('s3');
    $file = UploadedFile::fake()->image('photo.jpg');

    $this->actingAs(User::factory()->create())
        ->post('/profile/avatar', ['avatar' => $file]);

    $files = Storage::disk('s3')->files('avatars');
    expect($files)->toHaveCount(1);
    expect($files[0])->not->toContain('photo.jpg'); // UUID filename, not original
});
```

---

## 9. Command Injection

### Before (Vulnerable)

```php
exec("convert " . $request->filename . " output.png");
$output = shell_exec("ping -c 4 " . $request->host);
system("wc -l " . $request->file);
```

### After (Remediated)

```php
// Option A: Laravel Process class (preferred)
use Illuminate\Support\Facades\Process;

$result = Process::run([
    'convert', $validatedFilename, 'output.png',
]);

// Option B: escapeshellarg for each argument
$host = escapeshellarg($request->validated('host'));
$output = shell_exec("ping -c 4 " . $host);

// Option C: Avoid shell entirely — use PHP functions
$lineCount = count(file($validatedPath));
```

### Laravel Best Practice

- Use Laravel's `Process` facade with array syntax (no shell interpretation)
- If shell commands are unavoidable, use `escapeshellarg()` on every argument
- Never concatenate user input into command strings
- Validate input against allowlists where possible (e.g., allowed hostnames)
- Consider PHP-native alternatives to shell commands

### Pest Test

```php
it('prevents command injection in hostname', function () {
    $response = $this->actingAs(User::factory()->admin()->create())
        ->post('/admin/ping', [
            'host' => '127.0.0.1; cat /etc/passwd',
        ]);

    $response->assertSessionHasErrors('host');
});
```

---

## 10. Path Traversal

### Before (Vulnerable)

```php
$content = file_get_contents(storage_path('files/' . $request->filename));
return response()->download(storage_path('docs/' . $request->path));
include('themes/' . $request->theme . '/header.php');
```

### After (Remediated)

```php
// Use Storage facade with basename validation
$filename = basename($request->validated('filename'));  // Strips directory traversal
$content = Storage::disk('local')->get('files/' . $filename);

// Or validate against known files
$request->validate([
    'filename' => ['required', 'string', Rule::in($allowedFiles)],
]);

// For downloads, use Storage facade
return Storage::disk('local')->download('docs/' . basename($request->validated('path')));
```

### Laravel Best Practice

- Always use `basename()` to strip directory traversal characters
- Use `Storage` facade instead of raw file functions
- Validate filenames against allowlists when possible
- Never use `include`/`require` with user input
- Block `..`, `/`, `\` characters in filename validation

### Pest Test

```php
it('prevents path traversal in file download', function () {
    $response = $this->actingAs(User::factory()->create())
        ->get('/download?filename=' . urlencode('../../.env'));

    $response->assertNotFound();  // Or assertForbidden
});
```

---

## 11. Open Redirect

### Before (Vulnerable)

```php
return redirect($request->input('next'));
return redirect()->to($request->query('return_url'));
```

### After (Remediated)

```php
// Option A: Only allow relative paths
$next = $request->input('next', '/dashboard');
if (! Str::startsWith($next, '/') || Str::startsWith($next, '//')) {
    $next = '/dashboard';
}
return redirect($next);

// Option B: Validate against allowed hosts
$url = $request->input('return_url');
$parsed = parse_url($url);
if (isset($parsed['host']) && $parsed['host'] !== request()->getHost()) {
    abort(400, 'Invalid redirect URL');
}
return redirect($url);

// Option C: Use Laravel's intended() for post-login
return redirect()->intended('/dashboard');
```

### Pest Test

```php
it('prevents open redirect to external domain', function () {
    $response = $this->actingAs(User::factory()->create())
        ->get('/redirect?next=' . urlencode('https://evil.com'));

    expect($response->headers->get('Location'))->not->toContain('evil.com');
});
```

---

## 12. SSRF (Server-Side Request Forgery)

### Before (Vulnerable)

```php
$response = Http::get($request->input('url'));
$image = file_get_contents($request->avatar_url);
```

### After (Remediated)

```php
// Validate URL with scheme and host restrictions
$request->validate([
    'url' => ['required', 'url', 'starts_with:https://'],
]);

$url = $request->validated('url');
$parsed = parse_url($url);

// Block private IP ranges
$ip = gethostbyname($parsed['host']);
if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false) {
    abort(422, 'URL resolves to a private IP address');
}

$response = Http::timeout(5)->get($url);
```

### Laravel Best Practice

- Always validate URL scheme (allow only `https://`)
- Resolve hostname to IP and block private/reserved ranges
- Set timeouts on HTTP client calls to prevent slow-loris
- For webhook URLs, validate and store at configuration time, not at request time
- Use an allowlist of domains when possible

### Pest Test

```php
it('blocks SSRF to internal addresses', function () {
    $response = $this->actingAs(User::factory()->create())
        ->post('/fetch-url', [
            'url' => 'http://169.254.169.254/latest/meta-data/',
        ]);

    $response->assertUnprocessable();
});
```

---

## 13. Sensitive Data Exposure

### Before (Vulnerable)

```php
// Logging sensitive data
Log::info('User login', $request->all());

// Missing $hidden
class User extends Model
{
    // password_hash, remember_token exposed in toArray/toJson
}

// Stack trace in response
return response()->json(['error' => $e->getMessage(), 'trace' => $e->getTrace()], 500);
```

### After (Remediated)

```php
// Log only safe fields
Log::info('User login', ['email' => $request->email, 'ip' => $request->ip()]);

// Hide sensitive fields
class User extends Model
{
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_secret',
        'two_factor_recovery_codes',
    ];
}

// Generic error response
return response()->json(['error' => 'An unexpected error occurred.'], 500);
```

### Laravel Best Practice

- Always set `$hidden` on models with sensitive fields
- Never log `$request->all()` — log specific safe fields only
- Configure exception handler to hide stack traces in production (`APP_DEBUG=false`)
- Use `$casts` with `'encrypted'` for sensitive database fields
- Ensure `.env` is in `.gitignore`
- Check `config/` files reference `env()` not hardcoded values

### Pest Test

```php
it('does not expose password hash in API response', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)->getJson('/api/user');

    $response->assertOk();
    $response->assertJsonMissing(['password']);
    $response->assertJsonMissing(['remember_token']);
});
```

---

## 14. Security Misconfiguration

### Before (Vulnerable)

```env
APP_DEBUG=true
APP_ENV=production
SESSION_SECURE_COOKIE=false
```

### After (Remediated)

```env
APP_DEBUG=false
APP_ENV=production
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
```

### Configuration Checklist

```php
// config/session.php
'secure' => env('SESSION_SECURE_COOKIE', true),
'http_only' => true,
'same_site' => 'lax',

// config/cors.php — restrict origins
'allowed_origins' => [env('APP_URL')],  // Not ['*']

// config/app.php
'debug' => env('APP_DEBUG', false),  // Default to false

// Remove debug routes
// NO: Route::get('/phpinfo', fn() => phpinfo());
// NO: Route::get('/debug', fn() => dd(config()));
```

### Laravel Best Practice

- Set `APP_DEBUG=false` in production
- Remove all `dd()`, `dump()`, `var_dump()` from non-test code before deployment
- Disable Telescope and Debugbar in production
- Set secure cookie flags
- Restrict CORS origins
- Remove `phpinfo()` routes
- Configure proper error pages (404, 500) without stack traces
