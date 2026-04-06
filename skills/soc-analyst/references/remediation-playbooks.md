# Remediation Playbooks — Multi-Stack Fix Procedures

Read this file when remediating vulnerabilities. Each playbook provides multi-stack before/after code (Laravel/PHP, Node.js/Express, Python/Django/Flask, Ruby/Rails) and tests to prevent regression.

---

## 1. SQL Injection

#### Laravel/PHP

**Before (Vulnerable)**

```php
$users = DB::select("SELECT * FROM users WHERE email = '$request->email'");
$results = User::whereRaw("name LIKE '%{$request->search}%'")->get();
```

**After (Remediated)**

```php
$users = DB::select("SELECT * FROM users WHERE email = ?", [$request->email]);
$results = User::whereRaw("name LIKE ?", ['%' . $request->search . '%'])->get();
$orders = Order::where('status', $request->validated('status'))->get();
```

**Pest Test**

```php
it('prevents SQL injection in search', function () {
    User::factory()->create(['name' => 'Alice']);

    $response = $this->actingAs(User::factory()->create())
        ->get('/users?search=' . urlencode("' OR 1=1 --"));

    $response->assertOk();
    expect($response->json('data'))->toBeEmpty();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
app.get('/users', (req, res) => {
  db.query(`SELECT * FROM users WHERE email = '${req.query.email}'`);
});
```

**After (Remediated)**

```js
app.get('/users', (req, res) => {
  db.query('SELECT * FROM users WHERE email = $1', [req.query.email]);
});
```

**Jest Test**

```js
test('prevents SQL injection in search', async () => {
  const res = await request(app).get("/users?email=' OR 1=1 --");
  expect(res.status).toBe(200);
  expect(res.body.data).toHaveLength(0);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django
User.objects.raw(f"SELECT * FROM users WHERE email = '{email}'")

# Flask + SQLAlchemy
db.engine.execute(f"SELECT * FROM users WHERE email = '{email}'")
```

**After (Remediated)**

```python
# Django — use ORM or parameterized raw
User.objects.filter(email=email)
User.objects.raw("SELECT * FROM users WHERE email = %s", [email])

# Flask + SQLAlchemy
db.session.execute(text("SELECT * FROM users WHERE email = :email"), {"email": email})
```

**pytest Test**

```python
def test_prevents_sql_injection(client, db):
    response = client.get("/users?email=' OR 1=1 --")
    assert response.status_code == 200
    assert len(response.json["data"]) == 0
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
User.where("email = '#{params[:email]}'")
```

**After (Remediated)**

```ruby
User.where(email: params[:email])
User.where("email = ?", params[:email])
```

**RSpec Test**

```ruby
it "prevents SQL injection in search" do
  get "/users", params: { email: "' OR 1=1 --" }
  expect(response).to have_http_status(:ok)
  expect(JSON.parse(response.body)["data"]).to be_empty
end
```

### Best Practice

- Always use parameterized queries or ORM methods — never interpolate user input into SQL strings
- When raw queries are unavoidable, pass bindings as a separate argument
- Validate and constrain input before it reaches any query layer

---

## 2. Cross-Site Scripting (XSS)

#### Laravel/PHP

**Before (Vulnerable)**

```php
<p>{!! $user->bio !!}</p>
<input value="{!! old('name') !!}">
```

**After (Remediated)**

```php
<p>{{ $user->bio }}</p>
<input value="{{ old('name') }}">
<!-- If HTML is required, sanitize before storage -->
<div>{!! clean($comment->body) !!}</div>
```

**Pest Test**

```php
it('escapes user input in profile display', function () {
    $user = User::factory()->create(['bio' => '<script>alert("xss")</script>']);

    $response = $this->actingAs($user)->get('/profile/' . $user->id);

    $response->assertOk();
    $response->assertDontSee('<script>', false);
    $response->assertSee('&lt;script&gt;');
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
res.send(`<p>${user.bio}</p>`);
```

**After (Remediated)**

```js
import escape from 'escape-html';
res.send(`<p>${escape(user.bio)}</p>`);
// Or use a templating engine with auto-escaping (EJS, Handlebars)
```

**Jest Test**

```js
test('escapes user input in profile display', async () => {
  await createUser({ bio: '<script>alert("xss")</script>' });
  const res = await request(app).get('/profile/1');
  expect(res.text).not.toContain('<script>');
  expect(res.text).toContain('&lt;script&gt;');
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django template with |safe filter
{{ user.bio|safe }}

# Flask with Markup
return Markup(f"<p>{user.bio}</p>")
```

**After (Remediated)**

```python
# Django — default auto-escaping (just remove |safe)
{{ user.bio }}

# Flask/Jinja2 — auto-escaping is on by default; avoid Markup() on user input
return render_template("profile.html", bio=user.bio)
```

**pytest Test**

```python
def test_escapes_xss_in_profile(client):
    user = create_user(bio='<script>alert("xss")</script>')
    response = client.get(f"/profile/{user.id}")
    assert b"<script>" not in response.data
    assert b"&lt;script&gt;" in response.data
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
<%= raw @user.bio %>
<%= @user.bio.html_safe %>
```

**After (Remediated)**

```ruby
<%= @user.bio %>  <%# auto-escaped by default %>
<%= sanitize @user.bio %>  <%# if HTML subset is needed %>
```

**RSpec Test**

```ruby
it "escapes XSS in profile display" do
  user = create(:user, bio: '<script>alert("xss")</script>')
  get "/profile/#{user.id}"
  expect(response.body).not_to include("<script>")
  expect(response.body).to include("&lt;script&gt;")
end
```

### Best Practice

- Use the framework's default auto-escaping — never bypass it without explicit sanitization
- Add Content-Security-Policy headers to limit the impact of any XSS that slips through
- If HTML rendering is required, sanitize on input using a whitelist-based library (DOMPurify, Bleach, Loofah, mews/purifier)

---

## 3. CSRF Protection

#### Laravel/PHP

**Before (Vulnerable)**

```php
// Overly broad CSRF exclusion
protected $except = ['api/*'];

// Form missing @csrf
<form method="POST" action="/transfer">
    <input name="amount" value="1000">
</form>
```

**After (Remediated)**

```php
protected $except = ['webhooks/stripe']; // Only verified external webhooks

<form method="POST" action="/transfer">
    @csrf
    <input name="amount" value="1000">
</form>
```

**Pest Test**

```php
it('rejects POST requests without CSRF token', function () {
    $response = $this->actingAs(User::factory()->create())
        ->post('/transfer', ['amount' => 1000]);

    $response->assertStatus(419);
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
app.post('/transfer', (req, res) => {
  // No CSRF protection
  transferFunds(req.body.amount);
});
```

**After (Remediated)**

```js
import csrf from 'csurf';
const csrfProtection = csrf({ cookie: true });

app.get('/transfer', csrfProtection, (req, res) => {
  res.render('transfer', { csrfToken: req.csrfToken() });
});
app.post('/transfer', csrfProtection, (req, res) => {
  transferFunds(req.body.amount);
});
```

**Jest Test**

```js
test('rejects POST without CSRF token', async () => {
  const res = await request(app).post('/transfer').send({ amount: 1000 });
  expect(res.status).toBe(403);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django view with @csrf_exempt
@csrf_exempt
def transfer(request):
    transfer_funds(request.POST["amount"])
```

**After (Remediated)**

```python
# Django — remove @csrf_exempt; include token in template
# Template: <form method="POST">{% csrf_token %}<input name="amount"></form>
def transfer(request):
    transfer_funds(request.POST["amount"])

# Flask — use Flask-WTF
from flask_wtf import FlaskForm
class TransferForm(FlaskForm):
    amount = IntegerField('Amount')
```

**pytest Test**

```python
def test_rejects_post_without_csrf(client):
    response = client.post("/transfer", data={"amount": 1000})
    assert response.status_code == 403
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
class TransfersController < ApplicationController
  skip_before_action :verify_authenticity_token
end
```

**After (Remediated)**

```ruby
class TransfersController < ApplicationController
  # Do not skip verify_authenticity_token
  # Rails includes CSRF token automatically with form_with/form_for
end
```

**RSpec Test**

```ruby
it "rejects POST without CSRF token" do
  post "/transfer", params: { amount: 1000 }
  expect(response).to have_http_status(:unprocessable_entity)
end
```

### Best Practice

- Never disable CSRF protection broadly — only exclude endpoints verified by provider-specific signatures (webhooks)
- Use the framework's built-in CSRF token mechanism in all state-changing forms
- For SPAs, use token-based CSRF patterns (cookie-to-header or synchronizer token)

---

## 4. Broken Authentication

#### Laravel/PHP

**Before (Vulnerable)**

```php
$user->password = md5($request->password);  // Weak hash
Auth::login($user);  // No session regeneration
```

**After (Remediated)**

```php
$user->password = Hash::make($request->password);
Auth::attempt($request->only('email', 'password'));
$request->session()->regenerate();
```

**Pest Test**

```php
it('rate limits login attempts', function () {
    $user = User::factory()->create();
    for ($i = 0; $i < 5; $i++) {
        $this->post('/login', ['email' => $user->email, 'password' => 'wrong']);
    }
    $response = $this->post('/login', ['email' => $user->email, 'password' => 'wrong']);
    $response->assertSessionHasErrors('email');
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const crypto = require('crypto');
user.password = crypto.createHash('md5').update(password).digest('hex');
```

**After (Remediated)**

```js
const bcrypt = require('bcrypt');
user.password = await bcrypt.hash(password, 12);
// On login:
const match = await bcrypt.compare(password, user.password);
req.session.regenerate(() => { /* proceed */ });
```

**Jest Test**

```js
test('rate limits login attempts', async () => {
  for (let i = 0; i < 5; i++) {
    await request(app).post('/login').send({ email: 'a@b.com', password: 'wrong' });
  }
  const res = await request(app).post('/login').send({ email: 'a@b.com', password: 'wrong' });
  expect(res.status).toBe(429);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
import hashlib
user.password = hashlib.md5(password.encode()).hexdigest()
```

**After (Remediated)**

```python
# Django — uses PBKDF2 by default
from django.contrib.auth.hashers import make_password
user.password = make_password(password)

# Flask
from werkzeug.security import generate_password_hash, check_password_hash
user.password = generate_password_hash(password)
```

**pytest Test**

```python
def test_rate_limits_login(client):
    for _ in range(5):
        client.post("/login", data={"email": "a@b.com", "password": "wrong"})
    response = client.post("/login", data={"email": "a@b.com", "password": "wrong"})
    assert response.status_code == 429
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
user.password = Digest::MD5.hexdigest(password)
```

**After (Remediated)**

```ruby
# Use has_secure_password (bcrypt)
class User < ApplicationRecord
  has_secure_password
end
# On login:
user.authenticate(password)
reset_session  # Regenerate session
```

**RSpec Test**

```ruby
it "rate limits login attempts" do
  5.times { post "/login", params: { email: "a@b.com", password: "wrong" } }
  post "/login", params: { email: "a@b.com", password: "wrong" }
  expect(response).to have_http_status(:too_many_requests)
end
```

### Best Practice

- Always use bcrypt, Argon2, or PBKDF2 — never MD5/SHA1 for passwords
- Regenerate the session ID after successful login to prevent session fixation
- Rate-limit login attempts per email+IP combination (5 attempts max)
- Set secure cookie flags: `secure`, `httpOnly`, `sameSite`

---

## 5. Broken Access Control (IDOR)

#### Laravel/PHP

**Before (Vulnerable)**

```php
public function show($id) {
    $invoice = Invoice::findOrFail($id);  // No ownership check
    return view('invoices.show', compact('invoice'));
}
```

**After (Remediated)**

```php
public function show(Invoice $invoice) {
    $this->authorize('view', $invoice);
    return view('invoices.show', compact('invoice'));
}
```

**Pest Test**

```php
it('prevents users from viewing other users invoices', function () {
    $owner = User::factory()->create();
    $other = User::factory()->create();
    $invoice = Invoice::factory()->for($owner)->create();
    $response = $this->actingAs($other)->get('/invoices/' . $invoice->id);
    $response->assertForbidden();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
app.get('/invoices/:id', async (req, res) => {
  const invoice = await Invoice.findByPk(req.params.id);
  res.json(invoice);
});
```

**After (Remediated)**

```js
app.get('/invoices/:id', async (req, res) => {
  const invoice = await Invoice.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (!invoice) return res.status(403).json({ error: 'Forbidden' });
  res.json(invoice);
});
```

**Jest Test**

```js
test('prevents viewing other users invoices', async () => {
  const res = await request(app)
    .get(`/invoices/${otherUsersInvoice.id}`)
    .set('Authorization', `Bearer ${userToken}`);
  expect(res.status).toBe(403);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
def show_invoice(request, pk):
    invoice = Invoice.objects.get(pk=pk)  # No ownership check
    return JsonResponse(invoice.to_dict())
```

**After (Remediated)**

```python
def show_invoice(request, pk):
    invoice = get_object_or_404(Invoice, pk=pk, user=request.user)
    return JsonResponse(invoice.to_dict())
```

**pytest Test**

```python
def test_prevents_viewing_other_users_invoices(client, other_invoice):
    response = client.get(f"/invoices/{other_invoice.id}")
    assert response.status_code == 404  # or 403
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
def show
  @invoice = Invoice.find(params[:id])
end
```

**After (Remediated)**

```ruby
def show
  @invoice = current_user.invoices.find(params[:id])
end
```

**RSpec Test**

```ruby
it "prevents viewing other users invoices" do
  get "/invoices/#{other_users_invoice.id}"
  expect(response).to have_http_status(:not_found)
end
```

### Best Practice

- Always scope queries to the authenticated user or check ownership via a policy/authorization layer
- Use framework authorization primitives (policies, permissions, cancan, etc.) rather than ad-hoc checks
- Return 403 or 404 (not the resource) when access is denied — 404 avoids leaking that the resource exists

---

## 6. Mass Assignment

#### Laravel/PHP

**Before (Vulnerable)**

```php
class User extends Model {
    protected $guarded = [];  // Everything assignable
}
User::create($request->all());
```

**After (Remediated)**

```php
class User extends Model {
    protected $fillable = ['name', 'email', 'password'];
}
User::create($request->validated());
```

**Pest Test**

```php
it('prevents mass assignment of admin flag', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user)->put('/profile', [
        'name' => 'Updated', 'email' => $user->email, 'is_admin' => true,
    ]);
    expect($user->fresh()->is_admin)->toBeFalse();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
app.put('/profile', async (req, res) => {
  await User.update(req.body, { where: { id: req.user.id } });
});
```

**After (Remediated)**

```js
app.put('/profile', async (req, res) => {
  const { name, email } = req.body; // Destructure only allowed fields
  await User.update({ name, email }, { where: { id: req.user.id } });
});
```

**Jest Test**

```js
test('prevents mass assignment of admin flag', async () => {
  const res = await request(app)
    .put('/profile').set('Authorization', `Bearer ${token}`)
    .send({ name: 'Updated', isAdmin: true });
  const user = await User.findByPk(userId);
  expect(user.isAdmin).toBe(false);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django
User.objects.filter(pk=user.pk).update(**request.POST.dict())
```

**After (Remediated)**

```python
# Django — use a serializer or form with explicit fields
form = ProfileForm(request.POST, instance=request.user)
if form.is_valid():
    form.save()  # Only fields declared in form are saved
```

**pytest Test**

```python
def test_prevents_mass_assignment_of_admin(client, user):
    client.put("/profile", data={"name": "Updated", "is_admin": True})
    user.refresh_from_db()
    assert user.is_admin is False
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
user.update(params[:user])  # Unpermitted params
```

**After (Remediated)**

```ruby
user.update(params.require(:user).permit(:name, :email))
```

**RSpec Test**

```ruby
it "prevents mass assignment of admin flag" do
  put "/profile", params: { user: { name: "Updated", is_admin: true } }
  expect(user.reload.is_admin).to be false
end
```

### Best Practice

- Never pass raw request data directly to create/update — always whitelist allowed fields
- Use framework mechanisms: `$fillable` (Laravel), strong parameters (Rails), serializers/forms (Django), destructuring (Node.js)
- Sensitive fields like `is_admin`, `role`, `balance` should never be mass-assignable

---

## 7. Insecure Deserialization

#### Laravel/PHP

**Before (Vulnerable)**

```php
$data = unserialize($request->input('data'));
$prefs = unserialize($_COOKIE['preferences']);
```

**After (Remediated)**

```php
$data = json_decode($request->input('data'), true, 512, JSON_THROW_ON_ERROR);
// If unserialize is required, restrict allowed classes
$data = unserialize($serialized, ['allowed_classes' => [AllowedClass::class]]);
```

**Pest Test**

```php
it('rejects serialized PHP input', function () {
    $response = $this->postJson('/api/data', [
        'payload' => 'O:8:"stdClass":1:{s:4:"evil";s:4:"code";}',
    ]);
    $response->assertUnprocessable();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const data = eval('(' + req.body.data + ')'); // Or node-serialize
const obj = require('node-serialize').unserialize(req.body.obj);
```

**After (Remediated)**

```js
const data = JSON.parse(req.body.data); // Safe JSON parsing only
// Validate schema with zod/joi
const validated = schema.parse(data);
```

**Jest Test**

```js
test('rejects non-JSON payloads', async () => {
  const res = await request(app).post('/api/data')
    .send({ data: '{__proto__: {isAdmin: true}}' });
  expect(res.status).toBe(422);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
import pickle
data = pickle.loads(request.data)  # Arbitrary code execution
```

**After (Remediated)**

```python
import json
data = json.loads(request.data)  # Safe JSON only
# Validate with pydantic or marshmallow
validated = MySchema().load(data)
```

**pytest Test**

```python
def test_rejects_pickle_payload(client):
    import pickle
    payload = pickle.dumps({"evil": "data"})
    response = client.post("/api/data", data=payload, content_type="application/octet-stream")
    assert response.status_code == 422
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
data = Marshal.load(params[:data])
data = YAML.unsafe_load(params[:data])
```

**After (Remediated)**

```ruby
data = JSON.parse(params[:data])
# For YAML, use safe_load
data = YAML.safe_load(params[:data], permitted_classes: [Symbol, Date])
```

**RSpec Test**

```ruby
it "rejects non-JSON payloads" do
  post "/api/data", params: { data: "\x04\bo:\bFoo" }
  expect(response).to have_http_status(:unprocessable_entity)
end
```

### Best Practice

- Never deserialize untrusted input with native serialization (unserialize, pickle, Marshal, node-serialize, eval)
- Use JSON for all data interchange — validate structure with a schema library
- If native deserialization is unavoidable, restrict to an explicit allowlist of safe classes

---

## 8. File Upload Vulnerabilities

#### Laravel/PHP

**Before (Vulnerable)**

```php
$path = $request->file('avatar')->storeAs('avatars', $request->file('avatar')->getClientOriginalName(), 'public');
```

**After (Remediated)**

```php
$request->validate(['avatar' => ['required', 'file', 'image', 'mimes:jpg,png,webp', 'max:2048']]);
$path = $request->file('avatar')->store('avatars', 's3'); // UUID filename, non-public disk
```

**Pest Test**

```php
it('rejects non-image file uploads', function () {
    $file = UploadedFile::fake()->create('malware.php', 100);
    $response = $this->actingAs(User::factory()->create())
        ->post('/profile/avatar', ['avatar' => $file]);
    $response->assertSessionHasErrors('avatar');
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const multer = require('multer');
const upload = multer({ dest: 'public/uploads/' }); // No validation, public dir
```

**After (Remediated)**

```js
const upload = multer({
  dest: 'uploads/', // Non-public directory
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  },
});
```

**Jest Test**

```js
test('rejects non-image file uploads', async () => {
  const res = await request(app)
    .post('/profile/avatar')
    .attach('avatar', Buffer.from('<?php evil(); ?>'), 'malware.php');
  expect(res.status).toBe(400);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django
def upload(request):
    handle_uploaded_file(request.FILES['avatar'])  # No validation
```

**After (Remediated)**

```python
# Django — use FileExtensionValidator and size check
from django.core.validators import FileExtensionValidator

class AvatarForm(forms.Form):
    avatar = forms.ImageField(
        validators=[FileExtensionValidator(allowed_extensions=['jpg', 'png', 'webp'])],
    )
    # ImageField validates it's a real image via Pillow
```

**pytest Test**

```python
def test_rejects_non_image_upload(client):
    from io import BytesIO
    data = {'avatar': (BytesIO(b'<?php evil(); ?>'), 'malware.php')}
    response = client.post("/profile/avatar", data=data, content_type='multipart/form-data')
    assert response.status_code == 400
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
def upload
  File.write("public/uploads/#{params[:file].original_filename}", params[:file].read)
end
```

**After (Remediated)**

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
  validates :avatar, content_type: ['image/jpeg', 'image/png', 'image/webp'],
                     size: { less_than: 2.megabytes }
end
```

**RSpec Test**

```ruby
it "rejects non-image file uploads" do
  file = fixture_file_upload("malware.php", "application/x-php")
  post "/profile/avatar", params: { avatar: file }
  expect(response).to have_http_status(:unprocessable_entity)
end
```

### Best Practice

- Always validate MIME type and file extension on the server — never trust client-provided values alone
- Generate a random/UUID filename for storage — never use the original filename
- Store uploads outside the web root; serve via a controller or signed URLs
- Set a maximum file size limit

---

## 9. Command Injection

#### Laravel/PHP

**Before (Vulnerable)**

```php
exec("convert " . $request->filename . " output.png");
$output = shell_exec("ping -c 4 " . $request->host);
```

**After (Remediated)**

```php
use Illuminate\Support\Facades\Process;
$result = Process::run(['convert', $validatedFilename, 'output.png']);
// Or: $host = escapeshellarg($request->validated('host'));
```

**Pest Test**

```php
it('prevents command injection in hostname', function () {
    $response = $this->actingAs(User::factory()->admin()->create())
        ->post('/admin/ping', ['host' => '127.0.0.1; cat /etc/passwd']);
    $response->assertSessionHasErrors('host');
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const { exec } = require('child_process');
exec(`ping -c 4 ${req.body.host}`);
```

**After (Remediated)**

```js
const { execFile } = require('child_process');
execFile('ping', ['-c', '4', validatedHost]); // Array args, no shell
```

**Jest Test**

```js
test('prevents command injection in hostname', async () => {
  const res = await request(app).post('/admin/ping')
    .send({ host: '127.0.0.1; cat /etc/passwd' });
  expect(res.status).toBe(422);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
import os
os.system(f"ping -c 4 {host}")
```

**After (Remediated)**

```python
import subprocess
subprocess.run(['ping', '-c', '4', validated_host], capture_output=True)  # List args, no shell=True
```

**pytest Test**

```python
def test_prevents_command_injection(client):
    response = client.post("/admin/ping", json={"host": "127.0.0.1; cat /etc/passwd"})
    assert response.status_code == 422
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
system("ping -c 4 #{params[:host]}")
```

**After (Remediated)**

```ruby
system('ping', '-c', '4', validated_host)  # Multi-arg form, no shell
```

**RSpec Test**

```ruby
it "prevents command injection in hostname" do
  post "/admin/ping", params: { host: "127.0.0.1; cat /etc/passwd" }
  expect(response).to have_http_status(:unprocessable_entity)
end
```

### Best Practice

- Never concatenate user input into shell command strings
- Use array-based APIs that bypass shell interpretation: `execFile` (Node), `subprocess.run` with list args (Python), multi-arg `system` (Ruby), `Process::run` with array (Laravel)
- Validate input against an allowlist when possible (e.g., IP format regex)
- Consider native language alternatives to shell commands

---

## 10. Path Traversal

#### Laravel/PHP

**Before (Vulnerable)**

```php
$content = file_get_contents(storage_path('files/' . $request->filename));
```

**After (Remediated)**

```php
$filename = basename($request->validated('filename'));
$content = Storage::disk('local')->get('files/' . $filename);
```

**Pest Test**

```php
it('prevents path traversal in file download', function () {
    $response = $this->actingAs(User::factory()->create())
        ->get('/download?filename=' . urlencode('../../.env'));
    $response->assertNotFound();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const filePath = `./files/${req.query.filename}`;
res.sendFile(filePath);
```

**After (Remediated)**

```js
const path = require('path');
const safeName = path.basename(req.query.filename);
const filePath = path.join(__dirname, 'files', safeName);
// Verify resolved path is within allowed directory
if (!filePath.startsWith(path.join(__dirname, 'files'))) return res.status(403).end();
res.sendFile(filePath);
```

**Jest Test**

```js
test('prevents path traversal in file download', async () => {
  const res = await request(app).get('/download?filename=../../.env');
  expect(res.status).toBe(404);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
path = f"files/{request.GET['filename']}"
return FileResponse(open(path, 'rb'))
```

**After (Remediated)**

```python
import os
filename = os.path.basename(request.GET['filename'])
safe_path = os.path.join('files', filename)
# Verify resolved path
if not os.path.realpath(safe_path).startswith(os.path.realpath('files')):
    raise Http404
return FileResponse(open(safe_path, 'rb'))
```

**pytest Test**

```python
def test_prevents_path_traversal(client):
    response = client.get("/download?filename=../../etc/passwd")
    assert response.status_code == 404
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
send_file "files/#{params[:filename]}"
```

**After (Remediated)**

```ruby
filename = File.basename(params[:filename])
safe_path = Rails.root.join('files', filename).to_s
raise ActiveRecord::RecordNotFound unless safe_path.start_with?(Rails.root.join('files').to_s)
send_file safe_path
```

**RSpec Test**

```ruby
it "prevents path traversal in file download" do
  get "/download", params: { filename: "../../.env" }
  expect(response).to have_http_status(:not_found)
end
```

### Best Practice

- Always use `basename()` / `path.basename()` / `File.basename()` to strip directory traversal characters
- Resolve the final path and verify it stays within the intended directory
- Validate filenames against an allowlist when possible
- Never use user input in `include`/`require`/`import` statements

---

## 11. Open Redirect

#### Laravel/PHP

**Before (Vulnerable)**

```php
return redirect($request->input('next'));
```

**After (Remediated)**

```php
$next = $request->input('next', '/dashboard');
if (! Str::startsWith($next, '/') || Str::startsWith($next, '//')) {
    $next = '/dashboard';
}
return redirect($next);
```

**Pest Test**

```php
it('prevents open redirect to external domain', function () {
    $response = $this->actingAs(User::factory()->create())
        ->get('/redirect?next=' . urlencode('https://evil.com'));
    expect($response->headers->get('Location'))->not->toContain('evil.com');
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
res.redirect(req.query.next);
```

**After (Remediated)**

```js
let next = req.query.next || '/dashboard';
if (!next.startsWith('/') || next.startsWith('//')) next = '/dashboard';
res.redirect(next);
```

**Jest Test**

```js
test('prevents open redirect to external domain', async () => {
  const res = await request(app).get('/redirect?next=https://evil.com');
  expect(res.headers.location).not.toContain('evil.com');
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
return redirect(request.GET.get('next'))
```

**After (Remediated)**

```python
from django.utils.http import url_has_allowed_host_and_scheme

next_url = request.GET.get('next', '/dashboard')
if not url_has_allowed_host_and_scheme(next_url, allowed_hosts={request.get_host()}):
    next_url = '/dashboard'
return redirect(next_url)
```

**pytest Test**

```python
def test_prevents_open_redirect(client):
    response = client.get("/redirect?next=https://evil.com", follow_redirects=False)
    assert "evil.com" not in response.headers.get("Location", "")
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
redirect_to params[:next]
```

**After (Remediated)**

```ruby
next_url = params[:next]
if next_url&.start_with?('/') && !next_url.start_with?('//')
  redirect_to next_url
else
  redirect_to '/dashboard'
end
```

**RSpec Test**

```ruby
it "prevents open redirect to external domain" do
  get "/redirect", params: { next: "https://evil.com" }
  expect(response.headers["Location"]).not_to include("evil.com")
end
```

### Best Practice

- Only allow relative paths (starting with `/` but not `//`)
- If absolute URLs are needed, validate the host against an allowlist
- Use framework-provided safe redirect helpers when available (e.g., Django's `url_has_allowed_host_and_scheme`)
- Default to a safe fallback URL when validation fails

---

## 12. SSRF (Server-Side Request Forgery)

#### Laravel/PHP

**Before (Vulnerable)**

```php
$response = Http::get($request->input('url'));
```

**After (Remediated)**

```php
$request->validate(['url' => ['required', 'url', 'starts_with:https://']]);
$ip = gethostbyname(parse_url($request->validated('url'), PHP_URL_HOST));
if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false) {
    abort(422, 'URL resolves to a private IP address');
}
$response = Http::timeout(5)->get($request->validated('url'));
```

**Pest Test**

```php
it('blocks SSRF to internal addresses', function () {
    $response = $this->actingAs(User::factory()->create())
        ->post('/fetch-url', ['url' => 'http://169.254.169.254/latest/meta-data/']);
    $response->assertUnprocessable();
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
const response = await fetch(req.body.url);
```

**After (Remediated)**

```js
const { URL } = require('url');
const dns = require('dns').promises;
const parsed = new URL(req.body.url);
if (parsed.protocol !== 'https:') return res.status(422).json({ error: 'HTTPS only' });
const { address } = await dns.lookup(parsed.hostname);
if (isPrivateIP(address)) return res.status(422).json({ error: 'Private IP blocked' });
const response = await fetch(req.body.url, { signal: AbortSignal.timeout(5000) });
```

**Jest Test**

```js
test('blocks SSRF to internal addresses', async () => {
  const res = await request(app).post('/fetch-url')
    .send({ url: 'http://169.254.169.254/latest/meta-data/' });
  expect(res.status).toBe(422);
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
import requests
response = requests.get(request.data['url'])
```

**After (Remediated)**

```python
import socket, ipaddress, requests
from urllib.parse import urlparse

parsed = urlparse(request.data['url'])
if parsed.scheme != 'https':
    return JsonResponse({"error": "HTTPS only"}, status=422)
ip = socket.gethostbyname(parsed.hostname)
if ipaddress.ip_address(ip).is_private:
    return JsonResponse({"error": "Private IP blocked"}, status=422)
response = requests.get(request.data['url'], timeout=5)
```

**pytest Test**

```python
def test_blocks_ssrf_to_internal_addresses(client):
    response = client.post("/fetch-url", json={"url": "http://169.254.169.254/latest/meta-data/"})
    assert response.status_code == 422
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
response = Net::HTTP.get(URI(params[:url]))
```

**After (Remediated)**

```ruby
uri = URI.parse(params[:url])
raise "HTTPS only" unless uri.scheme == 'https'
ip = Resolv.getaddress(uri.host)
raise "Private IP blocked" if IPAddr.new(ip).private?
response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) { |h| h.get(uri) }
```

**RSpec Test**

```ruby
it "blocks SSRF to internal addresses" do
  post "/fetch-url", params: { url: "http://169.254.169.254/latest/meta-data/" }
  expect(response).to have_http_status(:unprocessable_entity)
end
```

### Best Practice

- Always validate URL scheme (allow only `https://`)
- Resolve the hostname to an IP and block private/reserved ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x, 127.x)
- Set timeouts on all outbound HTTP requests
- Use an allowlist of domains when possible

---

## 13. Sensitive Data Exposure

#### Laravel/PHP

**Before (Vulnerable)**

```php
Log::info('User login', $request->all());  // Logs passwords
class User extends Model { }  // password_hash exposed in toArray
return response()->json(['error' => $e->getMessage(), 'trace' => $e->getTrace()], 500);
```

**After (Remediated)**

```php
Log::info('User login', ['email' => $request->email, 'ip' => $request->ip()]);
class User extends Model {
    protected $hidden = ['password', 'remember_token', 'two_factor_secret'];
}
return response()->json(['error' => 'An unexpected error occurred.'], 500);
```

**Pest Test**

```php
it('does not expose password hash in API response', function () {
    $user = User::factory()->create();
    $response = $this->actingAs($user)->getJson('/api/user');
    $response->assertOk();
    $response->assertJsonMissing(['password']);
});
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
console.log('Login attempt', req.body); // Logs password
app.get('/api/user', (req, res) => res.json(user)); // Exposes passwordHash
app.use((err, req, res, next) => res.json({ error: err.message, stack: err.stack }));
```

**After (Remediated)**

```js
console.log('Login attempt', { email: req.body.email, ip: req.ip });
app.get('/api/user', (req, res) => {
  const { passwordHash, ...safe } = user.toJSON();
  res.json(safe);
});
app.use((err, req, res, next) => res.status(500).json({ error: 'An unexpected error occurred.' }));
```

**Jest Test**

```js
test('does not expose password hash in API response', async () => {
  const res = await request(app).get('/api/user').set('Authorization', `Bearer ${token}`);
  expect(res.body).not.toHaveProperty('passwordHash');
});
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
logger.info(f"Login attempt: {request.POST}")  # Logs password
return JsonResponse(model_to_dict(user))  # Exposes password hash
return JsonResponse({"error": str(e), "traceback": traceback.format_exc()}, status=500)
```

**After (Remediated)**

```python
logger.info("Login attempt", extra={"email": request.POST["email"], "ip": request.META["REMOTE_ADDR"]})
return JsonResponse(model_to_dict(user, exclude=["password", "secret_key"]))
return JsonResponse({"error": "An unexpected error occurred."}, status=500)
```

**pytest Test**

```python
def test_does_not_expose_password_in_api(client, user):
    response = client.get("/api/user")
    assert "password" not in response.json()
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
Rails.logger.info("Login: #{params.inspect}")  # Logs password
render json: user  # Exposes password_digest
render json: { error: e.message, trace: e.backtrace }, status: 500
```

**After (Remediated)**

```ruby
Rails.logger.info("Login: email=#{params[:email]} ip=#{request.remote_ip}")
render json: user, except: [:password_digest, :reset_token]
render json: { error: "An unexpected error occurred." }, status: 500
```

**RSpec Test**

```ruby
it "does not expose password hash in API response" do
  get "/api/user"
  body = JSON.parse(response.body)
  expect(body).not_to have_key("password_digest")
end
```

### Best Practice

- Never log full request payloads — log only non-sensitive fields
- Exclude sensitive fields from API serialization (hidden attributes, serializer exclusions)
- Return generic error messages in production — never expose stack traces or internal details
- Set `debug=false` / equivalent in production environments
- Filter sensitive parameters in log configuration (Rails `filter_parameters`, Django `SENSITIVE_VARIABLES`)

---

## 14. Security Misconfiguration

#### Laravel/PHP

**Before (Vulnerable)**

```env
APP_DEBUG=true
APP_ENV=production
SESSION_SECURE_COOKIE=false
```

**After (Remediated)**

```env
APP_DEBUG=false
APP_ENV=production
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
```

```php
// config/session.php
'secure' => env('SESSION_SECURE_COOKIE', true),
'http_only' => true,
'same_site' => 'lax',

// config/cors.php
'allowed_origins' => [env('APP_URL')],  // Not ['*']
```

#### Node.js (Express)

**Before (Vulnerable)**

```js
app.use(express.static('public'));
// No helmet, no secure cookies, stack traces in errors
app.use((err, req, res, next) => res.json({ error: err.stack }));
```

**After (Remediated)**

```js
const helmet = require('helmet');
app.use(helmet()); // Sets security headers (CSP, X-Frame-Options, etc.)
app.set('trust proxy', 1);
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: { secure: true, httpOnly: true, sameSite: 'lax' },
}));
// Disable Express version disclosure
app.disable('x-powered-by');
```

```env
NODE_ENV=production
SESSION_SECRET=<generated-secret>
```

#### Python (Django / Flask)

**Before (Vulnerable)**

```python
# Django settings.py
DEBUG = True
ALLOWED_HOSTS = ['*']
CORS_ALLOW_ALL_ORIGINS = True
```

**After (Remediated)**

```python
# Django settings.py
DEBUG = False
ALLOWED_HOSTS = [os.environ['ALLOWED_HOST']]
CORS_ALLOWED_ORIGINS = [os.environ['APP_URL']]
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True

# Flask
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

#### Ruby (Rails)

**Before (Vulnerable)**

```ruby
# config/environments/production.rb
config.consider_all_requests_local = true  # Shows stack traces
config.force_ssl = false
```

**After (Remediated)**

```ruby
# config/environments/production.rb
config.consider_all_requests_local = false
config.force_ssl = true
config.action_dispatch.cookies_same_site_protection = :lax

# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['APP_URL']  # Not '*'
  end
end
```

### Best Practice

- Set debug/development mode to `false`/`production` in all deployed environments
- Enable HTTPS and secure cookie flags (`secure`, `httpOnly`, `sameSite`)
- Restrict CORS origins — never use wildcard `*` in production
- Use security header middleware (Helmet for Node.js, SecurityHeaders middleware for Laravel, Django's SecurityMiddleware)
- Remove debug routes, info endpoints, and verbose error output
- Keep framework and dependencies updated — subscribe to security advisories
