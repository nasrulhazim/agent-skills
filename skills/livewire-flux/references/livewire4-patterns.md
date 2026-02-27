# Livewire 4 Patterns Reference

Core patterns for Livewire 4 — reactive properties, computed properties, form objects,
file uploads, lazy loading, polling, events, navigation, URL query params, teleport,
and persist.

---

## Reactive Properties

### Public Properties

Public properties are automatically reactive. Changes sync between PHP and the browser.

```php
class Counter extends Component
{
    public int $count = 0;

    public function increment(): void
    {
        $this->count++;
    }
}
```

### Property Attributes

```php
use Livewire\Attributes\Validate;
use Livewire\Attributes\Url;
use Livewire\Attributes\Locked;
use Livewire\Attributes\Session;
use Livewire\Attributes\Modelable;

class Example extends Component
{
    #[Validate('required|string|max:255')]
    public string $name = '';           // Validated on update

    #[Url]
    public string $search = '';          // Synced to URL query string

    #[Url(as: 'q')]
    public string $query = '';           // Custom URL parameter name

    #[Locked]
    public int $userId;                  // Cannot be modified from frontend

    #[Session]
    public string $theme = 'dark';       // Persisted in session across requests

    #[Modelable]
    public string $value = '';           // Allows parent component to bind via wire:model
}
```

### Wire Model Modifiers

```blade
{{-- Default: syncs on form submit or action --}}
<flux:input wire:model="name" />

{{-- Live: syncs on every input event --}}
<flux:input wire:model.live="search" />

{{-- Debounced: syncs after delay --}}
<flux:input wire:model.live.debounce.300ms="search" />

{{-- Blur: syncs when field loses focus --}}
<flux:input wire:model.blur="email" />

{{-- Throttle: max sync rate --}}
<flux:input wire:model.live.throttle.500ms="value" />

{{-- Number: cast to number --}}
<flux:input wire:model.number="quantity" type="number" />

{{-- Fill: pre-fill from old() on page load --}}
<flux:input wire:model.fill="name" />
```

---

## Computed Properties

Use `#[Computed]` to cache expensive operations within a single request lifecycle.
They are automatically cached and only recalculated when accessed after being invalidated.

```php
use Livewire\Attributes\Computed;

class UserDashboard extends Component
{
    public string $search = '';

    #[Computed]
    public function users()
    {
        return User::query()
            ->when($this->search, fn ($q) => $q->where('name', 'like', "%{$this->search}%"))
            ->with('roles', 'media')
            ->latest()
            ->paginate(15);
    }

    #[Computed]
    public function totalUsers(): int
    {
        return User::count();
    }

    #[Computed]
    public function roles()
    {
        return Role::pluck('name', 'id');
    }

    public function render()
    {
        return view('livewire.user-dashboard');
        // Access in Blade: $this->users, $this->totalUsers, $this->roles
    }
}
```

**In Blade:**

```blade
<p>Total: {{ $this->totalUsers }}</p>

@foreach ($this->users as $user)
    <div wire:key="user-{{ $user->id }}">{{ $user->name }}</div>
@endforeach
```

### Computed with Cache

```php
// Cache across requests (persistent cache)
#[Computed(persist: true)]
public function expensiveData()
{
    return ExpensiveService::calculate();
}

// Cache with TTL
#[Computed(persist: true, seconds: 3600)]
public function hourlyStats()
{
    return Stats::forLastHour();
}
```

---

## Form Objects

Encapsulate form logic, validation, and data transformation in a dedicated class.

```php
<?php

namespace App\Livewire\Forms;

use Livewire\Form;
use Livewire\Attributes\Validate;
use App\Models\Post;

class PostForm extends Form
{
    #[Validate('required|string|max:255')]
    public string $title = '';

    #[Validate('required|string|min:50')]
    public string $body = '';

    #[Validate('required|exists:categories,id')]
    public ?int $category_id = null;

    #[Validate('array|max:5')]
    public array $tags = [];

    #[Validate('boolean')]
    public bool $is_published = false;

    public function setPost(Post $post): void
    {
        $this->title = $post->title;
        $this->body = $post->body;
        $this->category_id = $post->category_id;
        $this->tags = $post->tags->pluck('id')->toArray();
        $this->is_published = $post->is_published;
    }

    public function store(): Post
    {
        $this->validate();

        $post = Post::create($this->except('tags'));
        $post->tags()->sync($this->tags);

        return $post;
    }

    public function update(Post $post): Post
    {
        $this->validate();

        $post->update($this->except('tags'));
        $post->tags()->sync($this->tags);

        return $post;
    }
}
```

**Using in component:**

```php
class PostCreate extends Component
{
    public PostForm $form;

    public function save(): void
    {
        $post = $this->form->store();
        $this->redirect(route('posts.show', $post), navigate: true);
    }
}
```

### Real-Time Validation

```php
class PostCreate extends Component
{
    public PostForm $form;

    // Validate individual field on blur
    public function updatedFormTitle(): void
    {
        $this->form->validateOnly('title');
    }

    // Or validate all on change
    public function updated($property): void
    {
        $this->form->validate();
    }
}
```

---

## File Uploads

### Basic Upload

```php
use Livewire\WithFileUploads;
use Livewire\Attributes\Validate;

class AvatarUpload extends Component
{
    use WithFileUploads;

    #[Validate('image|max:2048')] // 2MB max
    public $photo;

    public function save(): void
    {
        $this->validate();

        $path = $this->photo->store('avatars', 'public');

        auth()->user()->update(['avatar_path' => $path]);
    }
}
```

```blade
<div>
    <flux:input wire:model="photo" label="Avatar" type="file" accept="image/*" />

    @if ($photo)
        <div class="mt-4">
            <img src="{{ $photo->temporaryUrl() }}" class="h-32 w-32 rounded-full object-cover" />
        </div>
    @endif

    <flux:button wire:click="save" variant="primary" class="mt-4">Upload</flux:button>
</div>
```

### Multiple File Upload

```php
use Livewire\WithFileUploads;

class DocumentUpload extends Component
{
    use WithFileUploads;

    #[Validate(['documents.*' => 'file|mimes:pdf,doc,docx|max:10240'])]
    public array $documents = [];

    public function removeDocument(int $index): void
    {
        unset($this->documents[$index]);
        $this->documents = array_values($this->documents);
    }

    public function save(): void
    {
        $this->validate();

        foreach ($this->documents as $document) {
            $document->store('documents', 'public');
        }

        $this->documents = [];
    }
}
```

```blade
<div>
    <flux:input wire:model="documents" label="Documents" type="file" multiple accept=".pdf,.doc,.docx" />

    @if (count($documents))
        <div class="mt-4 space-y-2">
            @foreach ($documents as $index => $doc)
                <div wire:key="doc-{{ $index }}" class="flex items-center justify-between rounded bg-zinc-100 p-2 dark:bg-zinc-800">
                    <span class="text-sm">{{ $doc->getClientOriginalName() }}</span>
                    <flux:button variant="ghost" size="sm" icon="x-mark" wire:click="removeDocument({{ $index }})" />
                </div>
            @endforeach
        </div>
    @endif
</div>
```

### Upload Progress

```blade
<div
    x-data="{ uploading: false, progress: 0 }"
    x-on:livewire-upload-start="uploading = true"
    x-on:livewire-upload-finish="uploading = false"
    x-on:livewire-upload-cancel="uploading = false"
    x-on:livewire-upload-error="uploading = false"
    x-on:livewire-upload-progress="progress = $event.detail.progress"
>
    <flux:input wire:model="photo" type="file" label="Photo" />

    <div x-show="uploading" class="mt-2">
        <div class="h-2 w-full rounded-full bg-zinc-200 dark:bg-zinc-700">
            <div class="h-2 rounded-full bg-blue-500 transition-all" :style="'width: ' + progress + '%'"></div>
        </div>
        <span class="text-xs text-zinc-500" x-text="progress + '%'"></span>
    </div>
</div>
```

---

## Lazy Loading

Load components after the initial page render for faster perceived performance.

### Lazy Component

```php
use Livewire\Attributes\Lazy;

#[Lazy]
class StatsWidget extends Component
{
    #[Computed]
    public function stats()
    {
        return DB::table('orders')
            ->selectRaw('SUM(total) as revenue, COUNT(*) as count')
            ->first();
    }

    public function placeholder()
    {
        return view('livewire.placeholders.stats-widget');
    }

    public function render()
    {
        return view('livewire.stats-widget');
    }
}
```

**Placeholder view:**

```blade
{{-- livewire/placeholders/stats-widget.blade.php --}}
<div class="animate-pulse">
    <flux:card>
        <div class="h-4 w-24 rounded bg-zinc-200 dark:bg-zinc-700"></div>
        <div class="mt-2 h-8 w-16 rounded bg-zinc-200 dark:bg-zinc-700"></div>
    </flux:card>
</div>
```

### Wire Init (Load data after mount)

```php
class HeavyTable extends Component
{
    public bool $loaded = false;

    public function loadData(): void
    {
        $this->loaded = true;
    }

    #[Computed]
    public function records()
    {
        if (! $this->loaded) {
            return collect();
        }

        return Record::with('relations')->paginate(50);
    }
}
```

```blade
<div wire:init="loadData">
    @if (! $loaded)
        <p class="text-zinc-500">Loading...</p>
    @else
        {{-- render table --}}
    @endif
</div>
```

---

## Polling

Automatically refresh component data at intervals.

```blade
{{-- Refresh every 5 seconds --}}
<div wire:poll.5s>
    <p>Last updated: {{ now() }}</p>
    {{-- live data --}}
</div>

{{-- Only poll when tab is visible --}}
<div wire:poll.10s.visible>
    {{-- dashboard metrics --}}
</div>

{{-- Keep alive (minimal payload, just prevents session timeout) --}}
<div wire:poll.60s.keep-alive>
    {{-- form page --}}
</div>

{{-- Call specific method --}}
<div wire:poll.15s="refreshNotifications">
    @foreach ($this->notifications as $notification)
        {{-- ... --}}
    @endforeach
</div>
```

---

## Events

### Dispatching Events

```php
// From component class
$this->dispatch('user-created', userId: $user->id);

// To a specific component
$this->dispatch('refresh-list')->to(UserTable::class);

// To self
$this->dispatch('refresh-list')->self();

// From Blade
// <flux:button wire:click="$dispatch('show-modal', { id: 5 })">Open</flux:button>
```

### Listening for Events

```php
use Livewire\Attributes\On;

class UserTable extends Component
{
    #[On('user-created')]
    public function handleUserCreated(int $userId): void
    {
        // Refresh data or show notification
        unset($this->users); // Clear computed cache
    }

    // Listen for browser events
    #[On('echo:orders.{orderId},OrderShipped')]
    public function handleOrderShipped(): void
    {
        // Real-time via Laravel Echo
    }
}
```

### JavaScript Events

```php
// Dispatch to JavaScript
$this->dispatch('open-map', lat: 3.1390, lng: 101.6869);
```

```blade
{{-- Listen in Alpine --}}
<div x-data="{ lat: 0, lng: 0 }" @open-map.window="lat = $event.detail.lat; lng = $event.detail.lng">
    {{-- map component --}}
</div>
```

---

## Navigate (SPA Mode)

Livewire's `wire:navigate` provides SPA-like navigation without full page reloads.

### Links

```blade
{{-- Standard navigate link --}}
<a href="{{ route('users.index') }}" wire:navigate>Users</a>

{{-- Prefetch on hover --}}
<a href="{{ route('users.show', $user) }}" wire:navigate.hover>{{ $user->name }}</a>

{{-- With Flux button --}}
<flux:button :href="route('users.create')" wire:navigate variant="primary">
    Create User
</flux:button>

{{-- Flux nav items already support wire:navigate --}}
<flux:navlist.item :href="route('dashboard')" wire:navigate>Dashboard</flux:navlist.item>
```

### Programmatic Navigation

```php
// In component class
$this->redirect(route('users.index'), navigate: true);

// Or use redirectRoute
$this->redirectRoute('users.show', ['user' => $user], navigate: true);
```

### Persisting Elements Across Navigation

```blade
{{-- Audio player that persists across page navigations --}}
@persist('player')
<div>
    <audio src="{{ $audioUrl }}" autoplay></audio>
</div>
@endpersist
```

---

## URL Query Parameters

Sync component state with URL query parameters for shareable/bookmarkable states.

```php
use Livewire\Attributes\Url;

class ProductList extends Component
{
    #[Url]
    public string $search = '';

    #[Url]
    public string $sort = 'newest';

    #[Url(as: 'cat')]                    // Custom query param name
    public string $category = '';

    #[Url(history: true)]                // Use pushState (adds to browser history)
    public int $page = 1;

    #[Url(keep: true)]                   // Keep in URL even when default value
    public string $view = 'grid';

    #[Url(except: '')]                   // Remove from URL when this value
    public string $status = '';
}
```

**Resulting URL:** `/products?search=laptop&sort=price&cat=electronics&view=grid`

---

## Teleport

Render a part of a component's template in a different place in the DOM. Useful for modals,
dropdowns, and toasts that need to break out of parent overflow constraints.

```blade
<div>
    <flux:button wire:click="$set('showModal', true)">Open</flux:button>

    @teleport('body')
        <flux:modal wire:model="showModal">
            <flux:heading size="lg">Teleported Modal</flux:heading>
            <flux:text>This modal is rendered at the body level.</flux:text>
        </flux:modal>
    @endteleport
</div>
```

Common use cases:
- Modals that need to escape `overflow: hidden` parents
- Toasts/notifications rendered at document root
- Dropdowns in scrollable containers

---

## Persist

Keep component state across page navigations using `@persist`.

```blade
{{-- In layout --}}
@persist('audio-player')
<div id="audio-player">
    <audio id="main-audio" autoplay></audio>
</div>
@endpersist
```

This is different from `#[Session]` on properties:
- `@persist` keeps the actual DOM element alive during `wire:navigate`
- `#[Session]` stores property values in the server session

---

## Lifecycle Hooks

```php
class UserProfile extends Component
{
    public function mount(User $user): void
    {
        // Called once when component is first created
        // Use for initialization, route model binding
    }

    public function hydrate(): void
    {
        // Called on every subsequent request (not initial mount)
    }

    public function updating($property, $value): void
    {
        // Before any property is updated
    }

    public function updated($property, $value): void
    {
        // After any property is updated
    }

    public function updatedSearch(): void
    {
        // After 'search' property specifically is updated
        $this->resetPage();
    }

    public function updatingSearch($value): void
    {
        // Before 'search' property is updated
    }

    public function dehydrate(): void
    {
        // Called at the end of every request (before response sent)
    }

    public function rendering(): void
    {
        // Before render() is called
    }

    public function rendered(): void
    {
        // After render() is called
    }

    public function exception($e, $stopPropagation): void
    {
        // When an exception occurs during the lifecycle
        // Call $stopPropagation() to handle gracefully
    }
}
```

---

## Authorization in Components

```php
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class PostEdit extends Component
{
    use AuthorizesRequests;

    public Post $post;

    public function mount(Post $post): void
    {
        $this->authorize('update', $post);
        $this->post = $post;
    }

    public function save(): void
    {
        $this->authorize('update', $this->post);
        // ...
    }
}
```

---

## Pattern Quick Reference

| Pattern | When to Use |
|---|---|
| `#[Computed]` | Cached query results, derived data |
| `#[Url]` | Searchable/filterable lists, shareable state |
| `#[Locked]` | IDs, values that must not be tampered with |
| `#[Lazy]` | Dashboard widgets, below-fold content |
| `#[Session]` | User preferences (theme, sidebar state) |
| `#[Validate]` | Any property that accepts user input |
| Form Objects | Forms with 3+ fields, reusable create/edit |
| `wire:navigate` | All internal links (SPA feel) |
| `@persist` | Media players, state that survives navigation |
| `@teleport` | Modals, toasts needing to escape overflow |
| `wire:poll` | Live dashboards, notification counts |
| Events | Cross-component communication |
