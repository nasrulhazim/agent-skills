# Flux UI Component Patterns

Comprehensive reference for Flux UI components used in Livewire applications. Always prefer
Flux components over raw HTML — they handle dark mode, accessibility, and consistent styling
automatically.

---

## Form Components

### Input

```blade
{{-- Basic --}}
<flux:input wire:model="name" label="Name" />

{{-- With all options --}}
<flux:input
    wire:model="email"
    label="Email Address"
    type="email"
    placeholder="user@example.com"
    description="We'll never share your email."
    icon="envelope"
    required
/>

{{-- Clearable --}}
<flux:input wire:model.live="search" placeholder="Search..." icon="magnifying-glass" clearable />

{{-- With prefix/suffix --}}
<flux:input wire:model="price" label="Price">
    <x-slot:prefix>RM</x-slot:prefix>
</flux:input>

{{-- Password with toggle --}}
<flux:input wire:model="password" label="Password" type="password" viewable />

{{-- Disabled / Readonly --}}
<flux:input wire:model="code" label="Code" readonly />
<flux:input wire:model="locked" label="Locked" disabled />
```

### Select

```blade
{{-- Basic --}}
<flux:select wire:model="role" label="Role" placeholder="Choose a role">
    <flux:select.option value="admin">Admin</flux:select.option>
    <flux:select.option value="editor">Editor</flux:select.option>
    <flux:select.option value="viewer">Viewer</flux:select.option>
</flux:select>

{{-- Searchable (for long lists) --}}
<flux:select wire:model="country" label="Country" searchable placeholder="Select country">
    <flux:select.option value="MY">Malaysia</flux:select.option>
    <flux:select.option value="SG">Singapore</flux:select.option>
    <flux:select.option value="ID">Indonesia</flux:select.option>
    {{-- ... --}}
</flux:select>

{{-- Multiple --}}
<flux:select wire:model="permissions" label="Permissions" multiple placeholder="Select permissions">
    <flux:select.option value="create">Create</flux:select.option>
    <flux:select.option value="read">Read</flux:select.option>
    <flux:select.option value="update">Update</flux:select.option>
    <flux:select.option value="delete">Delete</flux:select.option>
</flux:select>

{{-- With groups --}}
<flux:select wire:model="category" label="Category" placeholder="Select category">
    <flux:select.group heading="Content">
        <flux:select.option value="post">Post</flux:select.option>
        <flux:select.option value="page">Page</flux:select.option>
    </flux:select.group>
    <flux:select.group heading="Media">
        <flux:select.option value="image">Image</flux:select.option>
        <flux:select.option value="video">Video</flux:select.option>
    </flux:select.group>
</flux:select>
```

### Checkbox

```blade
{{-- Single --}}
<flux:checkbox wire:model="agree" label="I agree to the terms" />

{{-- With description --}}
<flux:checkbox
    wire:model="is_active"
    label="Active"
    description="Inactive users cannot log in."
/>

{{-- Group --}}
<flux:checkbox.group wire:model="notifications" label="Notifications">
    <flux:checkbox value="email" label="Email" />
    <flux:checkbox value="sms" label="SMS" />
    <flux:checkbox value="push" label="Push" />
</flux:checkbox.group>
```

### Radio

```blade
<flux:radio.group wire:model="plan" label="Plan">
    <flux:radio value="free" label="Free" description="Up to 5 projects" />
    <flux:radio value="pro" label="Pro" description="Unlimited projects" />
    <flux:radio value="team" label="Team" description="Unlimited projects + team features" />
</flux:radio.group>
```

### Textarea

```blade
<flux:textarea
    wire:model="description"
    label="Description"
    placeholder="Enter a description..."
    rows="4"
/>

{{-- With character count --}}
<flux:textarea wire:model="bio" label="Bio" rows="3" maxlength="500" />
```

### File Upload

```blade
{{-- Basic file input --}}
<flux:input wire:model="avatar" label="Avatar" type="file" accept="image/*" />

{{-- Multiple files --}}
<flux:input wire:model="documents" label="Documents" type="file" multiple />
```

For file uploads with preview and Spatie Media Library, see `spatie-integration.md`.

### Switch / Toggle

```blade
<flux:switch wire:model.live="darkMode" label="Dark Mode" />

<flux:switch
    wire:model.live="is_published"
    label="Published"
    description="Make this post visible to the public."
/>
```

---

## Buttons

```blade
{{-- Variants --}}
<flux:button variant="primary">Save</flux:button>
<flux:button variant="filled">Default</flux:button>
<flux:button variant="outline">Cancel</flux:button>
<flux:button variant="ghost">Dismiss</flux:button>
<flux:button variant="danger">Delete</flux:button>
<flux:button variant="subtle">Less emphasis</flux:button>

{{-- Sizes --}}
<flux:button size="xs">Tiny</flux:button>
<flux:button size="sm">Small</flux:button>
<flux:button>Default</flux:button>
<flux:button size="lg">Large</flux:button>

{{-- With icons --}}
<flux:button icon="plus">Add User</flux:button>
<flux:button icon="trash" variant="danger" icon-trailing="arrow-right">Delete All</flux:button>

{{-- Icon-only --}}
<flux:button icon="pencil-square" variant="ghost" size="sm" />

{{-- As link --}}
<flux:button :href="route('users.create')" wire:navigate variant="primary" icon="plus">
    New User
</flux:button>

{{-- Loading state --}}
<flux:button type="submit" variant="primary" wire:loading.attr="disabled">
    <span wire:loading.remove>Save</span>
    <span wire:loading>Saving...</span>
</flux:button>

{{-- Button group --}}
<flux:button.group>
    <flux:button>Left</flux:button>
    <flux:button>Center</flux:button>
    <flux:button>Right</flux:button>
</flux:button.group>
```

---

## Modals

```blade
{{-- Triggered by Livewire property --}}
<flux:modal wire:model="showCreateModal">
    <div class="space-y-6">
        <flux:heading size="lg">Create User</flux:heading>

        <flux:input wire:model="form.name" label="Name" />
        <flux:input wire:model="form.email" label="Email" type="email" />

        <div class="flex justify-end gap-3">
            <flux:button variant="ghost" wire:click="$set('showCreateModal', false)">
                Cancel
            </flux:button>
            <flux:button variant="primary" wire:click="save">
                Create
            </flux:button>
        </div>
    </div>
</flux:modal>

{{-- Triggered by button directly --}}
<flux:modal.trigger name="delete-confirm">
    <flux:button variant="danger" icon="trash">Delete</flux:button>
</flux:modal.trigger>

<flux:modal name="delete-confirm">
    <div class="space-y-6">
        <flux:heading size="lg">Confirm Delete</flux:heading>
        <flux:text>This action cannot be undone.</flux:text>

        <div class="flex justify-end gap-3">
            <flux:button variant="ghost" x-on:click="$flux.modal.close('delete-confirm')">
                Cancel
            </flux:button>
            <flux:button variant="danger" wire:click="delete">
                Delete
            </flux:button>
        </div>
    </div>
</flux:modal>

{{-- Flyout (slide-in panel) --}}
<flux:modal wire:model="showFilters" variant="flyout">
    <flux:heading size="lg">Filters</flux:heading>
    {{-- filter fields --}}
</flux:modal>
```

---

## Dropdowns & Menus

```blade
{{-- Action dropdown on table rows --}}
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
        <flux:menu.item icon="trash" variant="danger" wire:click="confirmDelete({{ $user->id }})">
            Delete
        </flux:menu.item>
    </flux:menu>
</flux:dropdown>

{{-- Dropdown with groups --}}
<flux:dropdown>
    <flux:button icon="funnel">Filter</flux:button>
    <flux:menu>
        <flux:menu.group heading="Status">
            <flux:menu.item wire:click="$set('status', 'active')">Active</flux:menu.item>
            <flux:menu.item wire:click="$set('status', 'inactive')">Inactive</flux:menu.item>
        </flux:menu.group>
        <flux:menu.group heading="Role">
            <flux:menu.item wire:click="$set('role', 'admin')">Admin</flux:menu.item>
            <flux:menu.item wire:click="$set('role', 'user')">User</flux:menu.item>
        </flux:menu.group>
    </flux:menu>
</flux:dropdown>
```

---

## Notifications / Toasts

```php
// In Livewire component — using Flux toast
use Flux\Flux;

public function save(): void
{
    $this->form->store();
    Flux::toast('User created successfully.');
}

public function delete(): void
{
    $this->user->delete();
    Flux::toast(
        text: 'User deleted.',
        variant: 'danger',
    );
}

// With heading
Flux::toast(
    heading: 'Success',
    text: 'Changes have been saved.',
    variant: 'success',
);

// Warning
Flux::toast(
    text: 'This action is irreversible.',
    variant: 'warning',
);
```

Ensure your layout includes the toast container:

```blade
{{-- In layouts/app.blade.php --}}
<flux:toast />
```

---

## Tables

```blade
<flux:table>
    <flux:table.columns>
        <flux:table.column sortable :sorted="$sortBy === 'name'" :direction="$sortDirection" wire:click="sort('name')">
            Name
        </flux:table.column>
        <flux:table.column sortable :sorted="$sortBy === 'email'" :direction="$sortDirection" wire:click="sort('email')">
            Email
        </flux:table.column>
        <flux:table.column>Status</flux:table.column>
        <flux:table.column />{{-- Actions --}}
    </flux:table.columns>

    <flux:table.rows>
        @forelse ($this->users as $user)
            <flux:table.row :key="$user->id">
                <flux:table.cell>{{ $user->name }}</flux:table.cell>
                <flux:table.cell>{{ $user->email }}</flux:table.cell>
                <flux:table.cell>
                    <flux:badge :color="$user->is_active ? 'green' : 'zinc'" size="sm">
                        {{ $user->is_active ? 'Active' : 'Inactive' }}
                    </flux:badge>
                </flux:table.cell>
                <flux:table.cell>
                    {{-- action dropdown --}}
                </flux:table.cell>
            </flux:table.row>
        @empty
            <flux:table.row>
                <flux:table.cell colspan="4" class="text-center text-zinc-500">
                    No users found.
                </flux:table.cell>
            </flux:table.row>
        @endforelse
    </flux:table.rows>
</flux:table>
```

---

## Badges

```blade
{{-- Colors --}}
<flux:badge color="green">Active</flux:badge>
<flux:badge color="red">Deleted</flux:badge>
<flux:badge color="yellow">Pending</flux:badge>
<flux:badge color="blue">Processing</flux:badge>
<flux:badge color="zinc">Draft</flux:badge>

{{-- Sizes --}}
<flux:badge size="sm">Small</flux:badge>
<flux:badge>Default</flux:badge>
<flux:badge size="lg">Large</flux:badge>

{{-- With icon --}}
<flux:badge color="green" icon="check-circle">Verified</flux:badge>

{{-- As removable tag --}}
<flux:badge color="blue" removable wire:click="removeTag('{{ $tag }}')">
    {{ $tag }}
</flux:badge>
```

---

## Navigation

### Sidebar Navigation

```blade
<flux:sidebar sticky stashable>
    <flux:sidebar.toggle class="lg:hidden" icon="x-mark" />

    <a href="{{ route('dashboard') }}" wire:navigate class="flex items-center gap-2 px-2">
        <x-app-logo class="size-8" />
        <flux:heading>App Name</flux:heading>
    </a>

    <flux:navlist variant="outline">
        <flux:navlist.group heading="Main" :expandable="false">
            <flux:navlist.item icon="home" :href="route('dashboard')" wire:navigate
                :current="request()->routeIs('dashboard')">
                Dashboard
            </flux:navlist.item>
            <flux:navlist.item icon="users" :href="route('users.index')" wire:navigate
                :current="request()->routeIs('users.*')">
                Users
            </flux:navlist.item>
            <flux:navlist.item icon="document-text" :href="route('posts.index')" wire:navigate
                :current="request()->routeIs('posts.*')">
                Posts
            </flux:navlist.item>
        </flux:navlist.group>

        <flux:navlist.group heading="Settings" expandable>
            <flux:navlist.item icon="cog-6-tooth" :href="route('settings.general')" wire:navigate>
                General
            </flux:navlist.item>
            <flux:navlist.item icon="shield-check" :href="route('settings.security')" wire:navigate>
                Security
            </flux:navlist.item>
        </flux:navlist.group>
    </flux:navlist>

    <flux:spacer />

    {{-- User menu at bottom --}}
    <flux:dropdown position="top-start">
        <flux:button variant="ghost" class="w-full justify-start">
            <flux:avatar size="sm" :name="auth()->user()->name" />
            <span class="truncate">{{ auth()->user()->name }}</span>
        </flux:button>
        <flux:menu>
            <flux:menu.item icon="user" :href="route('profile')" wire:navigate>Profile</flux:menu.item>
            <flux:menu.separator />
            <flux:menu.item icon="arrow-right-start-on-rectangle" wire:click="logout">Log Out</flux:menu.item>
        </flux:menu>
    </flux:dropdown>
</flux:sidebar>
```

### Top Navbar

```blade
<flux:navbar>
    <flux:navbar.item icon="home" :href="route('dashboard')" wire:navigate
        :current="request()->routeIs('dashboard')">
        Dashboard
    </flux:navbar.item>
    <flux:navbar.item icon="users" :href="route('users.index')" wire:navigate
        :current="request()->routeIs('users.*')">
        Users
    </flux:navbar.item>

    <flux:spacer />

    <flux:appearance />

    <flux:dropdown>
        <flux:button variant="ghost" icon="user-circle" />
        <flux:menu>
            <flux:menu.item icon="user" :href="route('profile')" wire:navigate>Profile</flux:menu.item>
            <flux:menu.separator />
            <flux:menu.item icon="arrow-right-start-on-rectangle" wire:click="logout">
                Log Out
            </flux:menu.item>
        </flux:menu>
    </flux:dropdown>
</flux:navbar>
```

---

## Dark Mode Toggle

Flux handles dark mode with the `<flux:appearance />` component. This renders a toggle
that switches between light, dark, and system modes.

```blade
{{-- Drop-in toggle (recommended) --}}
<flux:appearance />

{{-- Custom toggle button --}}
<flux:button variant="ghost" icon="moon" x-on:click="$flux.appearance = $flux.appearance === 'dark' ? 'light' : 'dark'" />

{{-- In sidebar --}}
<flux:navlist.item icon="moon" x-on:click="$flux.appearance = 'dark'">Dark Mode</flux:navlist.item>
<flux:navlist.item icon="sun" x-on:click="$flux.appearance = 'light'">Light Mode</flux:navlist.item>
```

---

## Cards & Layout Helpers

```blade
{{-- Basic card --}}
<flux:card>
    <flux:heading size="lg">Title</flux:heading>
    <flux:text>Some content here.</flux:text>
</flux:card>

{{-- Card with actions --}}
<flux:card>
    <div class="flex items-center justify-between">
        <flux:heading size="lg">Users</flux:heading>
        <flux:button variant="primary" size="sm" icon="plus" :href="route('users.create')" wire:navigate>
            Add User
        </flux:button>
    </div>
    {{-- table or content --}}
</flux:card>

{{-- Separator --}}
<flux:separator />
<flux:separator text="or" />
```

---

## Tabs

```blade
<flux:tabs wire:model="activeTab">
    <flux:tab name="general" icon="cog-6-tooth">General</flux:tab>
    <flux:tab name="security" icon="shield-check">Security</flux:tab>
    <flux:tab name="notifications" icon="bell">Notifications</flux:tab>
</flux:tabs>

<flux:tab.panel name="general">
    {{-- General settings content --}}
</flux:tab.panel>

<flux:tab.panel name="security">
    {{-- Security settings content --}}
</flux:tab.panel>

<flux:tab.panel name="notifications">
    {{-- Notification settings content --}}
</flux:tab.panel>
```

---

## Breadcrumbs

```blade
<flux:breadcrumbs>
    <flux:breadcrumbs.item :href="route('dashboard')" wire:navigate icon="home" />
    <flux:breadcrumbs.item :href="route('users.index')" wire:navigate>Users</flux:breadcrumbs.item>
    <flux:breadcrumbs.item>{{ $user->name }}</flux:breadcrumbs.item>
</flux:breadcrumbs>
```

---

## Tooltip

```blade
<flux:tooltip content="Edit this user">
    <flux:button icon="pencil-square" variant="ghost" size="sm" />
</flux:tooltip>

<flux:tooltip position="right">
    <flux:button>Hover me</flux:button>
    <flux:tooltip.content>
        <p>Rich tooltip content with <strong>formatting</strong>.</p>
    </flux:tooltip.content>
</flux:tooltip>
```

---

## Component Quick Reference

| Category | Components |
|---|---|
| Form inputs | `flux:input`, `flux:select`, `flux:checkbox`, `flux:radio`, `flux:textarea`, `flux:switch` |
| Buttons | `flux:button`, `flux:button.group` |
| Layout | `flux:card`, `flux:separator`, `flux:spacer`, `flux:heading`, `flux:text` |
| Navigation | `flux:sidebar`, `flux:navbar`, `flux:navlist`, `flux:breadcrumbs`, `flux:tabs` |
| Overlays | `flux:modal`, `flux:dropdown`, `flux:tooltip`, `flux:toast` |
| Data display | `flux:table`, `flux:badge`, `flux:avatar` |
| Appearance | `flux:appearance` (dark mode toggle) |
