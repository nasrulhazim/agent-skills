---
name: livewire-flux
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, livewire, flux, alpine, components]
description: >
  Livewire 4 + Flux UI component scaffolder and pattern guide for Laravel projects. Generates
  Livewire components using Flux UI primitives — forms, data tables, modals, notifications,
  file uploads with Spatie Media Library, and role-gated UI with Spatie Permission. Supports
  both full-class and Volt single-file components. Use this skill whenever the user asks to
  create a Livewire component, build a form, scaffold a data table, add a modal, wire up file
  uploads, or integrate Spatie packages with Livewire — including: "buat Livewire form untuk
  user", "create a data table component", "scaffold CRUD with Livewire", "tambah modal delete
  confirmation", "buat file upload guna Media Library", "wire up role-based UI", "tolong buat
  component pakai Flux", "generate Volt component", or "I need a Livewire page with filters
  and sorting". Also triggers when the user mentions Flux UI components, Livewire patterns,
  or asks about best practices for reactive Laravel UIs. Assumes Livewire 4 and Flux are
  already installed with dark mode support.
---

# Livewire 4 + Flux UI Component Scaffolder

Scaffold production-ready Livewire 4 components using Flux UI primitives — never raw Alpine
when Flux already has a component. Covers forms, data tables, modals, notifications, file
uploads, and Spatie package integrations.

## Kickoff Baseline

This skill assumes the project already has:

- Laravel 11+
- Livewire 4 installed and configured
- Flux UI installed with dark mode support
- Tailwind CSS 4+

If the user hasn't set these up yet, point them to the official installation docs before
proceeding.

---

## Command Reference

| Command / Request | Description |
|---|---|
| `/livewire component <Name>` | Scaffold a Livewire component (full-class or Volt) |
| `/livewire form <Model>` | Generate a Flux-based form for a model with validation |
| `/livewire table <Model>` | Generate a data table with sorting, filtering, pagination |
| `/livewire patterns` | Show Livewire 4 + Flux best practices and anti-patterns |

---

## 1. Component Scaffolding

### 1.1 Full-Class Components

When the user asks for a component, generate both the class and Blade view.

**Class file** (`app/Livewire/{Name}.php`):

```php
<?php

namespace App\Livewire;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;

#[Layout('components.layouts.app')]
#[Title('Page Title')]
class UserIndex extends Component
{
    public function render()
    {
        return view('livewire.user-index');
    }
}
```

**Blade view** (`resources/views/livewire/{name}.blade.php`):

```blade
<div>
    {{-- Content using Flux components --}}
</div>
```

### 1.2 Volt Single-File Components

When the user requests Volt or a simpler component, use single-file format:

```php
<?php

use Livewire\Volt\Component;

new class extends Component {
    public string $name = '';

    public function save(): void
    {
        // ...
    }
}; ?>

<div>
    <flux:input wire:model="name" label="Name" />
    <flux:button wire:click="save">Save</flux:button>
</div>
```

Place Volt components in `resources/views/pages/` for automatic route registration,
or `resources/views/livewire/` for embedded use.

### 1.3 Choosing Between Full-Class and Volt

| Use Case | Recommendation |
|---|---|
| Full page with complex logic | Full-class component |
| Simple interactive widget | Volt single-file |
| Reusable across multiple pages | Full-class component |
| Quick prototype / admin page | Volt single-file |
| Needs form object | Full-class component |

---

## 2. Form Generation (`/livewire form`)

### 2.1 Form Object Pattern

Always use Livewire Form Objects for forms with more than two fields:

```php
<?php

namespace App\Livewire\Forms;

use Livewire\Form;
use Livewire\Attributes\Validate;
use App\Models\User;

class UserForm extends Form
{
    #[Validate('required|string|max:255')]
    public string $name = '';

    #[Validate('required|email|unique:users,email')]
    public string $email = '';

    #[Validate('nullable|string|max:20')]
    public string $phone = '';

    #[Validate('required|in:admin,editor,viewer')]
    public string $role = 'viewer';

    #[Validate('boolean')]
    public bool $is_active = true;

    public function setUser(User $user): void
    {
        $this->name = $user->name;
        $this->email = $user->email;
        $this->phone = $user->phone ?? '';
        $this->role = $user->roles->first()?->name ?? 'viewer';
        $this->is_active = $user->is_active;
    }

    public function store(): User
    {
        $this->validate();

        return User::create($this->except('role'));
    }

    public function update(User $user): User
    {
        $this->validate();

        $user->update($this->except('role'));

        return $user;
    }
}
```

### 2.2 Flux Form View

Use Flux components for every form element — never raw HTML inputs:

```blade
<div>
    <form wire:submit="save">
        <div class="space-y-6">
            <flux:input
                wire:model="form.name"
                label="Full Name"
                placeholder="Enter full name"
                description="As it appears on official documents."
            />

            <flux:input
                wire:model="form.email"
                label="Email Address"
                type="email"
                placeholder="user@example.com"
            />

            <flux:input
                wire:model="form.phone"
                label="Phone Number"
                type="tel"
                placeholder="+60 12-345 6789"
            />

            <flux:select wire:model="form.role" label="Role" placeholder="Select a role">
                <flux:select.option value="admin">Admin</flux:select.option>
                <flux:select.option value="editor">Editor</flux:select.option>
                <flux:select.option value="viewer">Viewer</flux:select.option>
            </flux:select>

            <flux:checkbox
                wire:model="form.is_active"
                label="Active"
                description="Inactive users cannot log in."
            />

            <flux:textarea
                wire:model="form.bio"
                label="Bio"
                placeholder="Tell us about yourself..."
                rows="4"
            />

            <div class="flex items-center gap-4">
                <flux:button type="submit" variant="primary">
                    Save
                </flux:button>
                <flux:button variant="ghost" href="{{ route('users.index') }}">
                    Cancel
                </flux:button>
            </div>
        </div>
    </form>
</div>
```

### 2.3 Component Class with Form Object

```php
<?php

namespace App\Livewire;

use App\Livewire\Forms\UserForm;
use App\Models\User;
use Livewire\Component;
use Livewire\Attributes\Layout;

#[Layout('components.layouts.app')]
class UserCreate extends Component
{
    public UserForm $form;

    public function save(): void
    {
        $user = $this->form->store();

        $this->redirect(route('users.show', $user), navigate: true);

        session()->flash('message', 'User created successfully.');
    }

    public function render()
    {
        return view('livewire.user-create');
    }
}
```

### 2.4 Edit Variant

```php
<?php

namespace App\Livewire;

use App\Livewire\Forms\UserForm;
use App\Models\User;
use Livewire\Component;
use Livewire\Attributes\Layout;

#[Layout('components.layouts.app')]
class UserEdit extends Component
{
    public UserForm $form;
    public User $user;

    public function mount(User $user): void
    {
        $this->user = $user;
        $this->form->setUser($user);
    }

    public function save(): void
    {
        $this->form->update($this->user);

        $this->redirect(route('users.show', $this->user), navigate: true);

        session()->flash('message', 'User updated successfully.');
    }

    public function render()
    {
        return view('livewire.user-edit');
    }
}
```

---

## 3. Data Table Generation (`/livewire table`)

### 3.1 Table Component Class

```php
<?php

namespace App\Livewire;

use App\Models\User;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Url;
use Livewire\Attributes\Computed;

#[Layout('components.layouts.app')]
class UserTable extends Component
{
    use WithPagination;

    #[Url]
    public string $search = '';

    #[Url]
    public string $sortBy = 'created_at';

    #[Url]
    public string $sortDirection = 'desc';

    #[Url]
    public string $filterRole = '';

    #[Url]
    public int $perPage = 15;

    public function updatedSearch(): void
    {
        $this->resetPage();
    }

    public function updatedFilterRole(): void
    {
        $this->resetPage();
    }

    public function sort(string $column): void
    {
        if ($this->sortBy === $column) {
            $this->sortDirection = $this->sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            $this->sortBy = $column;
            $this->sortDirection = 'asc';
        }
    }

    #[Computed]
    public function users()
    {
        return User::query()
            ->when($this->search, fn ($q) => $q
                ->where('name', 'like', "%{$this->search}%")
                ->orWhere('email', 'like', "%{$this->search}%")
            )
            ->when($this->filterRole, fn ($q) => $q
                ->role($this->filterRole)
            )
            ->orderBy($this->sortBy, $this->sortDirection)
            ->paginate($this->perPage);
    }

    public function render()
    {
        return view('livewire.user-table');
    }
}
```

### 3.2 Table Blade View with Flux

```blade
<div>
    {{-- Filters --}}
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end">
        <div class="flex-1">
            <flux:input
                wire:model.live.debounce.300ms="search"
                placeholder="Search users..."
                icon="magnifying-glass"
            />
        </div>

        <flux:select wire:model.live="filterRole" placeholder="All Roles">
            <flux:select.option value="">All Roles</flux:select.option>
            <flux:select.option value="admin">Admin</flux:select.option>
            <flux:select.option value="editor">Editor</flux:select.option>
            <flux:select.option value="viewer">Viewer</flux:select.option>
        </flux:select>

        <flux:select wire:model.live="perPage">
            <flux:select.option value="15">15 per page</flux:select.option>
            <flux:select.option value="25">25 per page</flux:select.option>
            <flux:select.option value="50">50 per page</flux:select.option>
        </flux:select>
    </div>

    {{-- Table --}}
    <flux:table>
        <flux:table.columns>
            <flux:table.column sortable :sorted="$sortBy === 'name'" :direction="$sortDirection" wire:click="sort('name')">
                Name
            </flux:table.column>
            <flux:table.column sortable :sorted="$sortBy === 'email'" :direction="$sortDirection" wire:click="sort('email')">
                Email
            </flux:table.column>
            <flux:table.column>
                Role
            </flux:table.column>
            <flux:table.column sortable :sorted="$sortBy === 'created_at'" :direction="$sortDirection" wire:click="sort('created_at')">
                Joined
            </flux:table.column>
            <flux:table.column />
        </flux:table.columns>

        <flux:table.rows>
            @foreach ($this->users as $user)
                <flux:table.row :key="$user->id">
                    <flux:table.cell>
                        <div class="flex items-center gap-3">
                            <flux:avatar size="sm" :name="$user->name" />
                            <span class="font-medium">{{ $user->name }}</span>
                        </div>
                    </flux:table.cell>
                    <flux:table.cell>{{ $user->email }}</flux:table.cell>
                    <flux:table.cell>
                        <flux:badge size="sm" :color="$user->roles->first()?->name === 'admin' ? 'red' : 'zinc'">
                            {{ $user->roles->first()?->name ?? 'viewer' }}
                        </flux:badge>
                    </flux:table.cell>
                    <flux:table.cell>{{ $user->created_at->diffForHumans() }}</flux:table.cell>
                    <flux:table.cell>
                        <flux:dropdown position="bottom-end">
                            <flux:button variant="ghost" size="sm" icon="ellipsis-horizontal" />
                            <flux:menu>
                                <flux:menu.item icon="eye" :href="route('users.show', $user)" wire:navigate>
                                    View
                                </flux:menu.item>
                                <flux:menu.item icon="pencil-square" :href="route('users.edit', $user)" wire:navigate>
                                    Edit
                                </flux:menu.item>
                                <flux:menu.separator />
                                <flux:menu.item icon="trash" variant="danger" wire:click="$dispatch('confirm-delete', { id: {{ $user->id }} })">
                                    Delete
                                </flux:menu.item>
                            </flux:menu>
                        </flux:dropdown>
                    </flux:table.cell>
                </flux:table.row>
            @endforeach
        </flux:table.rows>
    </flux:table>

    {{-- Pagination --}}
    <div class="mt-4">
        {{ $this->users->links() }}
    </div>

    {{-- Delete Confirmation Modal --}}
    <livewire:user-delete-modal />
</div>
```

### 3.3 Delete Confirmation Modal

```php
<?php

namespace App\Livewire;

use App\Models\User;
use Livewire\Component;
use Livewire\Attributes\On;

class UserDeleteModal extends Component
{
    public bool $showModal = false;
    public ?int $userId = null;
    public string $userName = '';

    #[On('confirm-delete')]
    public function confirmDelete(int $id): void
    {
        $user = User::findOrFail($id);
        $this->userId = $user->id;
        $this->userName = $user->name;
        $this->showModal = true;
    }

    public function delete(): void
    {
        User::findOrFail($this->userId)->delete();

        $this->showModal = false;
        $this->dispatch('$refresh');
        session()->flash('message', 'User deleted successfully.');
    }

    public function render()
    {
        return view('livewire.user-delete-modal');
    }
}
```

**Modal Blade view:**

```blade
<div>
    <flux:modal wire:model="showModal">
        <div class="space-y-6">
            <flux:heading size="lg">Delete User</flux:heading>

            <p>Are you sure you want to delete <strong>{{ $userName }}</strong>? This action cannot be undone.</p>

            <div class="flex justify-end gap-3">
                <flux:button variant="ghost" wire:click="$set('showModal', false)">
                    Cancel
                </flux:button>
                <flux:button variant="danger" wire:click="delete">
                    Delete User
                </flux:button>
            </div>
        </div>
    </flux:modal>
</div>
```

---

## 4. Common Patterns

### 4.1 Flux Notifications via Livewire Events

```php
// In component class
use Flux\Flux;

public function save(): void
{
    $this->form->store();

    Flux::toast('User created successfully.');

    $this->redirect(route('users.index'), navigate: true);
}
```

### 4.2 File Upload with Spatie Media Library

See `references/spatie-integration.md` for the full pattern. Key points:

- Use `Livewire\WithFileUploads` trait
- Use `flux:input` with `type="file"` for the upload field
- Attach to Spatie Media Library in the save method
- Show preview with `$file->temporaryUrl()`

### 4.3 Role-Gated UI Sections

See `references/spatie-integration.md`. Key points:

- Use `@can` / `@role` directives in Blade
- Use middleware on routes, not component-level checks for page access
- Use `$this->authorize()` in component methods for action-level checks

### 4.4 Dark Mode with Flux

Flux handles dark mode automatically. Use Flux's built-in dark mode toggle:

```blade
<flux:navbar>
    {{-- ... nav items ... --}}
    <flux:navbar.item icon="moon" x-on:click="$flux.appearance = 'dark'" />
    <flux:navbar.item icon="sun" x-on:click="$flux.appearance = 'light'" />
</flux:navbar>
```

Or use the appearance component:

```blade
<flux:appearance />
```

### 4.5 Navigation with Flux

```blade
<flux:sidebar>
    <flux:sidebar.toggle />

    <flux:navlist>
        <flux:navlist.group heading="Main">
            <flux:navlist.item icon="home" :href="route('dashboard')" wire:navigate :current="request()->routeIs('dashboard')">
                Dashboard
            </flux:navlist.item>
            <flux:navlist.item icon="users" :href="route('users.index')" wire:navigate :current="request()->routeIs('users.*')">
                Users
            </flux:navlist.item>
        </flux:navlist.group>
    </flux:navlist>
</flux:sidebar>
```

---

## 5. Anti-Patterns (`/livewire patterns`)

### Things to NEVER Do

| Anti-Pattern | Why It Breaks | Correct Pattern |
|---|---|---|
| N+1 queries in `render()` | Runs on every re-render, kills performance | Use `#[Computed]` with eager loading |
| Missing `wire:key` in loops | Livewire cannot track DOM elements, causes ghost state | Always add `wire:key="item-{{ $item->id }}"` |
| Raw Alpine `x-data` for inputs when Flux has a component | Duplicates functionality, misses dark mode, accessibility | Use `flux:input`, `flux:select`, etc. |
| Querying inside Blade `@foreach` | Hidden N+1, no caching | Query in component, pass as property |
| Public properties for large datasets | Bloats Livewire payload on every request | Use `#[Computed]` for query results |
| `wire:model` without `.live` on search inputs | Search won't fire until form submit | Use `wire:model.live.debounce.300ms` |
| Redirecting without `navigate: true` | Full page reload, loses SPA feel | `$this->redirect(url, navigate: true)` |
| Storing file uploads in public properties permanently | Memory leak, temp files pile up | Process in save method, clear after |

### Performance Checklist

Before presenting any component, verify:

1. No queries inside `render()` return — use `#[Computed]`
2. All loops have `wire:key`
3. Eager load relationships: `->with('roles', 'media')`
4. Pagination uses `WithPagination` trait, not `->get()`
5. Search inputs use `wire:model.live.debounce.300ms` (not `wire:model.live`)
6. Large lists use lazy loading: `wire:init="loadItems"`
7. No raw `<input>` or `<select>` when Flux has an equivalent

---

## 6. Volt-Specific Patterns

### Full Page Volt Component with Route

```php
<?php
// resources/views/pages/users/index.blade.php

use App\Models\User;
use Livewire\Volt\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Url;

new #[Layout('components.layouts.app')] class extends Component {
    use WithPagination;

    #[Url]
    public string $search = '';

    public function updatedSearch(): void
    {
        $this->resetPage();
    }

    #[Computed]
    public function users()
    {
        return User::query()
            ->when($this->search, fn ($q) => $q->where('name', 'like', "%{$this->search}%"))
            ->latest()
            ->paginate(15);
    }
}; ?>

<div>
    <flux:input wire:model.live.debounce.300ms="search" placeholder="Search..." icon="magnifying-glass" />

    <flux:table class="mt-4">
        <flux:table.columns>
            <flux:table.column>Name</flux:table.column>
            <flux:table.column>Email</flux:table.column>
        </flux:table.columns>
        <flux:table.rows>
            @foreach ($this->users as $user)
                <flux:table.row :key="$user->id">
                    <flux:table.cell>{{ $user->name }}</flux:table.cell>
                    <flux:table.cell>{{ $user->email }}</flux:table.cell>
                </flux:table.row>
            @endforeach
        </flux:table.rows>
    </flux:table>

    <div class="mt-4">{{ $this->users->links() }}</div>
</div>
```

### Embedded Volt Component

```php
<?php
// resources/views/livewire/stats-card.blade.php

use Livewire\Volt\Component;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Lazy;

new #[Lazy] class extends Component {
    #[Computed]
    public function count(): int
    {
        return \App\Models\User::count();
    }
}; ?>

<div>
    <flux:card>
        <flux:heading size="sm">Total Users</flux:heading>
        <flux:text class="text-3xl font-bold">{{ $this->count }}</flux:text>
    </flux:card>
</div>
```

Use `#[Lazy]` for dashboard widgets and stats cards that can load after the page.

---

## Reference Files

| File | Read When |
|---|---|
| `references/flux-components.md` | Generating any Flux UI component — forms, tables, modals, buttons, nav |
| `references/livewire4-patterns.md` | Livewire 4 reactive patterns, computed props, URL binding, events, teleport |
| `references/spatie-integration.md` | Integrating Spatie Permission, Media Library, or Activity Log with Livewire |
