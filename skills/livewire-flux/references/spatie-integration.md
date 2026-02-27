# Spatie Package Integration with Livewire

Patterns for integrating Spatie Permission, Spatie Media Library, and Spatie Activity Log
with Livewire 4 components and Flux UI.

---

## Spatie Permission

### Installation Assumption

This reference assumes `spatie/laravel-permission` is installed and configured with the
default `roles` and `permissions` tables.

### Role-Gated Components

#### Page-Level Authorization (Middleware)

Protect entire Livewire pages via route middleware — this is the primary access control layer:

```php
// routes/web.php
use App\Livewire\Admin\Dashboard;
use App\Livewire\Admin\UserManagement;

Route::middleware(['auth', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', Dashboard::class)->name('admin.dashboard');
    Route::get('/users', UserManagement::class)->name('admin.users');
});

// Permission-based
Route::middleware(['auth', 'permission:manage users'])->group(function () {
    Route::get('/users', UserManagement::class)->name('users.index');
});

// Multiple roles
Route::middleware(['auth', 'role:admin|super-admin'])->group(function () {
    // ...
});
```

#### Component-Level Authorization

For components that need to check permissions within their logic:

```php
<?php

namespace App\Livewire;

use Livewire\Component;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class UserManagement extends Component
{
    use AuthorizesRequests;

    public function mount(): void
    {
        // Check on mount (redundant if middleware is set, but useful as defense-in-depth)
        abort_unless(auth()->user()->hasRole('admin'), 403);
    }

    public function deleteUser(int $userId): void
    {
        // Action-level permission check
        $this->authorize('delete users');

        User::findOrFail($userId)->delete();
    }

    public function assignRole(int $userId, string $role): void
    {
        $this->authorize('manage roles');

        $user = User::findOrFail($userId);
        $user->syncRoles($role);
    }
}
```

### Role-Gated UI Sections with Blade Directives

Use `@can`, `@role`, and `@hasanyrole` directives to show/hide UI elements:

```blade
<div>
    <flux:heading size="lg">Users</flux:heading>

    {{-- Only show create button for users with permission --}}
    @can('create users')
        <flux:button variant="primary" icon="plus" :href="route('users.create')" wire:navigate>
            Add User
        </flux:button>
    @endcan

    <flux:table>
        <flux:table.columns>
            <flux:table.column>Name</flux:table.column>
            <flux:table.column>Email</flux:table.column>
            <flux:table.column>Role</flux:table.column>
            @can('edit users')
                <flux:table.column />{{-- Actions column --}}
            @endcan
        </flux:table.columns>

        <flux:table.rows>
            @foreach ($this->users as $user)
                <flux:table.row :key="$user->id">
                    <flux:table.cell>{{ $user->name }}</flux:table.cell>
                    <flux:table.cell>{{ $user->email }}</flux:table.cell>
                    <flux:table.cell>
                        <flux:badge size="sm" :color="match($user->roles->first()?->name) {
                            'admin' => 'red',
                            'editor' => 'blue',
                            default => 'zinc',
                        }">
                            {{ $user->roles->first()?->name ?? 'viewer' }}
                        </flux:badge>
                    </flux:table.cell>

                    @can('edit users')
                        <flux:table.cell>
                            <flux:dropdown position="bottom-end">
                                <flux:button variant="ghost" size="sm" icon="ellipsis-horizontal" />
                                <flux:menu>
                                    @can('edit users')
                                        <flux:menu.item icon="pencil-square" :href="route('users.edit', $user)" wire:navigate>
                                            Edit
                                        </flux:menu.item>
                                    @endcan

                                    @can('manage roles')
                                        <flux:menu.item icon="shield-check" wire:click="$dispatch('assign-role', { userId: {{ $user->id }} })">
                                            Change Role
                                        </flux:menu.item>
                                    @endcan

                                    @role('super-admin')
                                        <flux:menu.separator />
                                        <flux:menu.item icon="trash" variant="danger" wire:click="$dispatch('confirm-delete', { id: {{ $user->id }} })">
                                            Delete
                                        </flux:menu.item>
                                    @endrole
                                </flux:menu>
                            </flux:dropdown>
                        </flux:table.cell>
                    @endcan
                </flux:table.row>
            @endforeach
        </flux:table.rows>
    </flux:table>
</div>
```

### Role Assignment Component

```php
<?php

namespace App\Livewire;

use App\Models\User;
use Livewire\Component;
use Livewire\Attributes\On;
use Spatie\Permission\Models\Role;
use Livewire\Attributes\Computed;

class RoleAssigner extends Component
{
    public bool $showModal = false;
    public ?int $userId = null;
    public string $selectedRole = '';

    #[Computed]
    public function roles()
    {
        return Role::pluck('name', 'id');
    }

    #[On('assign-role')]
    public function openModal(int $userId): void
    {
        $user = User::findOrFail($userId);
        $this->userId = $user->id;
        $this->selectedRole = $user->roles->first()?->name ?? '';
        $this->showModal = true;
    }

    public function save(): void
    {
        $this->authorize('manage roles');

        $user = User::findOrFail($this->userId);
        $user->syncRoles($this->selectedRole);

        $this->showModal = false;
        $this->dispatch('$refresh');

        Flux::toast("Role updated for {$user->name}.");
    }

    public function render()
    {
        return view('livewire.role-assigner');
    }
}
```

```blade
<div>
    <flux:modal wire:model="showModal">
        <div class="space-y-6">
            <flux:heading size="lg">Assign Role</flux:heading>

            <flux:select wire:model="selectedRole" label="Role">
                @foreach ($this->roles as $id => $name)
                    <flux:select.option :value="$name">{{ ucfirst($name) }}</flux:select.option>
                @endforeach
            </flux:select>

            <div class="flex justify-end gap-3">
                <flux:button variant="ghost" wire:click="$set('showModal', false)">Cancel</flux:button>
                <flux:button variant="primary" wire:click="save">Save Role</flux:button>
            </div>
        </div>
    </flux:modal>
</div>
```

### Navigation with Role-Based Visibility

```blade
<flux:sidebar>
    <flux:navlist>
        <flux:navlist.group heading="Main">
            <flux:navlist.item icon="home" :href="route('dashboard')" wire:navigate>
                Dashboard
            </flux:navlist.item>

            @can('view users')
                <flux:navlist.item icon="users" :href="route('users.index')" wire:navigate>
                    Users
                </flux:navlist.item>
            @endcan

            @can('view reports')
                <flux:navlist.item icon="chart-bar" :href="route('reports.index')" wire:navigate>
                    Reports
                </flux:navlist.item>
            @endcan
        </flux:navlist.group>

        @role('admin|super-admin')
            <flux:navlist.group heading="Administration" expandable>
                <flux:navlist.item icon="cog-6-tooth" :href="route('admin.settings')" wire:navigate>
                    Settings
                </flux:navlist.item>
                <flux:navlist.item icon="shield-check" :href="route('admin.roles')" wire:navigate>
                    Roles & Permissions
                </flux:navlist.item>
            </flux:navlist.group>
        @endrole
    </flux:navlist>
</flux:sidebar>
```

---

## Spatie Media Library

### Installation Assumption

This reference assumes `spatie/laravel-medialibrary` is installed. Models use the
`InteractsWithMedia` trait and implement `HasMedia`.

### Model Setup

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class Post extends Model implements HasMedia
{
    use InteractsWithMedia;

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('featured_image')
            ->singleFile();

        $this->addMediaCollection('gallery')
            ->acceptsMimeTypes(['image/jpeg', 'image/png', 'image/webp']);

        $this->addMediaCollection('documents')
            ->acceptsMimeTypes(['application/pdf', 'application/msword']);
    }

    public function registerMediaConversions(?Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(150)
            ->height(150)
            ->sharpen(10);

        $this->addMediaConversion('preview')
            ->width(800)
            ->height(600);
    }
}
```

### File Upload Component with Media Library

```php
<?php

namespace App\Livewire;

use App\Models\Post;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\Attributes\Validate;
use Flux\Flux;

class PostMediaUpload extends Component
{
    use WithFileUploads;

    public Post $post;

    #[Validate('nullable|image|max:5120')] // 5MB
    public $featuredImage;

    #[Validate(['gallery.*' => 'image|max:5120'])]
    public array $gallery = [];

    #[Validate(['documents.*' => 'file|mimes:pdf,doc,docx|max:10240'])]
    public array $documents = [];

    public function mount(Post $post): void
    {
        $this->post = $post;
    }

    public function saveFeaturedImage(): void
    {
        $this->validate(['featuredImage' => 'required|image|max:5120']);

        $this->post
            ->addMedia($this->featuredImage->getRealPath())
            ->usingFileName($this->featuredImage->getClientOriginalName())
            ->toMediaCollection('featured_image');

        $this->featuredImage = null;

        Flux::toast('Featured image uploaded.');
    }

    public function saveGallery(): void
    {
        $this->validate(['gallery.*' => 'image|max:5120']);

        foreach ($this->gallery as $image) {
            $this->post
                ->addMedia($image->getRealPath())
                ->usingFileName($image->getClientOriginalName())
                ->toMediaCollection('gallery');
        }

        $this->gallery = [];

        Flux::toast(count($this->gallery) . ' images added to gallery.');
    }

    public function saveDocuments(): void
    {
        $this->validate(['documents.*' => 'file|mimes:pdf,doc,docx|max:10240']);

        foreach ($this->documents as $doc) {
            $this->post
                ->addMedia($doc->getRealPath())
                ->usingFileName($doc->getClientOriginalName())
                ->toMediaCollection('documents');
        }

        $this->documents = [];

        Flux::toast('Documents uploaded.');
    }

    public function removeMedia(int $mediaId): void
    {
        $this->post->media()->findOrFail($mediaId)->delete();

        Flux::toast('File removed.');
    }

    public function render()
    {
        return view('livewire.post-media-upload', [
            'existingFeatured' => $this->post->getFirstMedia('featured_image'),
            'existingGallery' => $this->post->getMedia('gallery'),
            'existingDocuments' => $this->post->getMedia('documents'),
        ]);
    }
}
```

### Media Upload Blade View

```blade
<div class="space-y-8">
    {{-- Featured Image --}}
    <flux:card>
        <flux:heading size="lg">Featured Image</flux:heading>

        @if ($existingFeatured)
            <div class="mt-4 flex items-center gap-4">
                <img src="{{ $existingFeatured->getUrl('thumb') }}" class="h-24 w-24 rounded object-cover" />
                <div>
                    <flux:text>{{ $existingFeatured->file_name }}</flux:text>
                    <flux:text class="text-sm text-zinc-500">{{ $existingFeatured->human_readable_size }}</flux:text>
                    <flux:button variant="ghost" size="sm" icon="trash" wire:click="removeMedia({{ $existingFeatured->id }})" class="mt-1">
                        Remove
                    </flux:button>
                </div>
            </div>
        @endif

        <div class="mt-4">
            <flux:input wire:model="featuredImage" type="file" label="Upload New Featured Image" accept="image/*" />

            @if ($featuredImage)
                <div class="mt-2">
                    <img src="{{ $featuredImage->temporaryUrl() }}" class="h-32 rounded object-cover" />
                </div>
            @endif

            <flux:button wire:click="saveFeaturedImage" variant="primary" size="sm" class="mt-2"
                :disabled="! $featuredImage">
                Upload
            </flux:button>
        </div>
    </flux:card>

    {{-- Gallery --}}
    <flux:card>
        <flux:heading size="lg">Gallery</flux:heading>

        @if ($existingGallery->isNotEmpty())
            <div class="mt-4 grid grid-cols-4 gap-4">
                @foreach ($existingGallery as $media)
                    <div wire:key="gallery-{{ $media->id }}" class="group relative">
                        <img src="{{ $media->getUrl('thumb') }}" class="h-24 w-full rounded object-cover" />
                        <flux:button
                            variant="danger"
                            size="xs"
                            icon="x-mark"
                            wire:click="removeMedia({{ $media->id }})"
                            class="absolute right-1 top-1 opacity-0 group-hover:opacity-100"
                        />
                    </div>
                @endforeach
            </div>
        @endif

        <div class="mt-4">
            <flux:input wire:model="gallery" type="file" label="Add Gallery Images" accept="image/*" multiple />

            @if (count($gallery))
                <div class="mt-2 grid grid-cols-4 gap-2">
                    @foreach ($gallery as $index => $image)
                        <img wire:key="preview-{{ $index }}" src="{{ $image->temporaryUrl() }}" class="h-20 w-full rounded object-cover" />
                    @endforeach
                </div>
            @endif

            <flux:button wire:click="saveGallery" variant="primary" size="sm" class="mt-2"
                :disabled="! count($gallery)">
                Upload Gallery
            </flux:button>
        </div>
    </flux:card>

    {{-- Documents --}}
    <flux:card>
        <flux:heading size="lg">Documents</flux:heading>

        @if ($existingDocuments->isNotEmpty())
            <div class="mt-4 space-y-2">
                @foreach ($existingDocuments as $media)
                    <div wire:key="doc-{{ $media->id }}" class="flex items-center justify-between rounded-lg bg-zinc-50 p-3 dark:bg-zinc-800">
                        <div class="flex items-center gap-3">
                            <flux:badge color="blue" size="sm">{{ strtoupper($media->extension) }}</flux:badge>
                            <div>
                                <a href="{{ $media->getUrl() }}" target="_blank" class="text-sm font-medium hover:underline">
                                    {{ $media->file_name }}
                                </a>
                                <flux:text class="text-xs text-zinc-500">{{ $media->human_readable_size }}</flux:text>
                            </div>
                        </div>
                        <flux:button variant="ghost" size="sm" icon="trash" wire:click="removeMedia({{ $media->id }})" />
                    </div>
                @endforeach
            </div>
        @endif

        <div class="mt-4">
            <flux:input wire:model="documents" type="file" label="Upload Documents" accept=".pdf,.doc,.docx" multiple />
            <flux:button wire:click="saveDocuments" variant="primary" size="sm" class="mt-2"
                :disabled="! count($documents)">
                Upload Documents
            </flux:button>
        </div>
    </flux:card>
</div>
```

### Displaying Media in Tables

```blade
<flux:table.cell>
    @if ($user->hasMedia('avatar'))
        <img src="{{ $user->getFirstMediaUrl('avatar', 'thumb') }}" class="h-8 w-8 rounded-full object-cover" />
    @else
        <flux:avatar size="sm" :name="$user->name" />
    @endif
</flux:table.cell>
```

### Eager Loading Media (Avoid N+1)

Always eager load media when displaying in lists:

```php
#[Computed]
public function posts()
{
    return Post::query()
        ->with('media')  // Eager load all media
        ->latest()
        ->paginate(15);
}
```

---

## Spatie Activity Log

### Installation Assumption

This reference assumes `spatie/laravel-activitylog` is installed. Models use the
`LogsActivity` trait.

### Model Setup

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Post extends Model
{
    use LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logOnly(['title', 'body', 'is_published', 'category_id'])
            ->logOnlyDirty()
            ->dontSubmitEmptyLogs()
            ->setDescriptionForEvent(fn (string $eventName) => "Post was {$eventName}");
    }
}
```

### Activity Log Livewire Component

```php
<?php

namespace App\Livewire;

use Livewire\Component;
use Livewire\WithPagination;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Url;
use Livewire\Attributes\Layout;
use Spatie\Activitylog\Models\Activity;

#[Layout('components.layouts.app')]
class ActivityLog extends Component
{
    use WithPagination;

    #[Url]
    public string $search = '';

    #[Url]
    public string $logName = '';

    #[Url]
    public string $event = '';

    public function updatedSearch(): void
    {
        $this->resetPage();
    }

    #[Computed]
    public function activities()
    {
        return Activity::query()
            ->with('causer', 'subject')
            ->when($this->search, fn ($q) => $q
                ->where('description', 'like', "%{$this->search}%")
            )
            ->when($this->logName, fn ($q) => $q
                ->where('log_name', $this->logName)
            )
            ->when($this->event, fn ($q) => $q
                ->where('event', $this->event)
            )
            ->latest()
            ->paginate(20);
    }

    #[Computed]
    public function logNames()
    {
        return Activity::distinct()->pluck('log_name')->filter();
    }

    #[Computed]
    public function events()
    {
        return Activity::distinct()->pluck('event')->filter();
    }

    public function render()
    {
        return view('livewire.activity-log');
    }
}
```

### Activity Log Blade View

```blade
<div>
    <flux:heading size="xl">Activity Log</flux:heading>

    {{-- Filters --}}
    <div class="mt-6 flex flex-col gap-4 sm:flex-row">
        <div class="flex-1">
            <flux:input
                wire:model.live.debounce.300ms="search"
                placeholder="Search activities..."
                icon="magnifying-glass"
                clearable
            />
        </div>

        <flux:select wire:model.live="logName" placeholder="All Logs">
            <flux:select.option value="">All Logs</flux:select.option>
            @foreach ($this->logNames as $name)
                <flux:select.option :value="$name">{{ ucfirst($name) }}</flux:select.option>
            @endforeach
        </flux:select>

        <flux:select wire:model.live="event" placeholder="All Events">
            <flux:select.option value="">All Events</flux:select.option>
            @foreach ($this->events as $evt)
                <flux:select.option :value="$evt">{{ ucfirst($evt) }}</flux:select.option>
            @endforeach
        </flux:select>
    </div>

    {{-- Activity Timeline --}}
    <div class="mt-6 space-y-4">
        @forelse ($this->activities as $activity)
            <flux:card wire:key="activity-{{ $activity->id }}">
                <div class="flex items-start justify-between">
                    <div class="flex items-start gap-3">
                        {{-- Event icon --}}
                        @php
                            $iconMap = [
                                'created' => 'plus-circle',
                                'updated' => 'pencil-square',
                                'deleted' => 'trash',
                            ];
                            $colorMap = [
                                'created' => 'green',
                                'updated' => 'blue',
                                'deleted' => 'red',
                            ];
                        @endphp

                        <flux:badge
                            :color="$colorMap[$activity->event] ?? 'zinc'"
                            :icon="$iconMap[$activity->event] ?? 'information-circle'"
                            size="sm"
                        >
                            {{ ucfirst($activity->event ?? 'unknown') }}
                        </flux:badge>

                        <div>
                            <flux:text class="font-medium">{{ $activity->description }}</flux:text>

                            @if ($activity->causer)
                                <flux:text class="text-sm text-zinc-500">
                                    by {{ $activity->causer->name }}
                                </flux:text>
                            @endif

                            {{-- Show changed attributes --}}
                            @if ($activity->properties->has('attributes'))
                                <div class="mt-2 text-sm">
                                    <flux:text class="font-medium text-zinc-600 dark:text-zinc-400">Changes:</flux:text>
                                    <div class="mt-1 space-y-1">
                                        @foreach ($activity->properties['attributes'] as $key => $newValue)
                                            <div class="flex items-center gap-2">
                                                <flux:badge size="sm" color="zinc">{{ $key }}</flux:badge>
                                                @if ($activity->properties->has('old') && isset($activity->properties['old'][$key]))
                                                    <span class="text-red-500 line-through">{{ $activity->properties['old'][$key] }}</span>
                                                    <span>&rarr;</span>
                                                @endif
                                                <span class="text-green-600 dark:text-green-400">{{ $newValue }}</span>
                                            </div>
                                        @endforeach
                                    </div>
                                </div>
                            @endif
                        </div>
                    </div>

                    <flux:text class="text-sm text-zinc-500">
                        {{ $activity->created_at->diffForHumans() }}
                    </flux:text>
                </div>
            </flux:card>
        @empty
            <flux:card>
                <flux:text class="text-center text-zinc-500">No activities found.</flux:text>
            </flux:card>
        @endforelse
    </div>

    {{-- Pagination --}}
    <div class="mt-4">
        {{ $this->activities->links() }}
    </div>
</div>
```

### Inline Activity Log for a Specific Model

Embed a compact activity timeline on a model's detail page:

```php
<?php

namespace App\Livewire;

use Livewire\Component;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Lazy;
use Spatie\Activitylog\Models\Activity;

#[Lazy]
class ModelActivityLog extends Component
{
    public string $subjectType;
    public int $subjectId;

    public function mount(string $subjectType, int $subjectId): void
    {
        $this->subjectType = $subjectType;
        $this->subjectId = $subjectId;
    }

    #[Computed]
    public function activities()
    {
        return Activity::query()
            ->where('subject_type', $this->subjectType)
            ->where('subject_id', $this->subjectId)
            ->with('causer')
            ->latest()
            ->limit(10)
            ->get();
    }

    public function placeholder()
    {
        return view('livewire.placeholders.activity-skeleton');
    }

    public function render()
    {
        return view('livewire.model-activity-log');
    }
}
```

**Usage on a detail page:**

```blade
{{-- In user-show.blade.php --}}
<flux:card>
    <flux:heading size="lg">Recent Activity</flux:heading>
    <livewire:model-activity-log
        subject-type="App\Models\User"
        :subject-id="$user->id"
    />
</flux:card>
```

### Logging Custom Activities in Livewire

```php
use Spatie\Activitylog\Facades\Activity as ActivityFacade;

public function approvePost(Post $post): void
{
    $post->update(['status' => 'approved']);

    activity()
        ->performedOn($post)
        ->causedBy(auth()->user())
        ->withProperties(['old_status' => 'pending', 'new_status' => 'approved'])
        ->log('Post approved');

    Flux::toast('Post approved.');
}
```

---

## Combined Pattern: Full CRUD with All Three Spatie Packages

A common pattern is a CRUD page that uses all three packages together:

```php
<?php

namespace App\Livewire;

use App\Models\Post;
use Livewire\Component;
use Livewire\WithPagination;
use Livewire\WithFileUploads;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Layout;
use Flux\Flux;

#[Layout('components.layouts.app')]
class PostManager extends Component
{
    use WithPagination, WithFileUploads;

    // ... properties and form logic ...

    public function save(): void
    {
        // 1. Permission check
        $this->authorize('create posts');

        // 2. Create the post
        $post = Post::create($this->form->all());

        // 3. Attach media via Spatie Media Library
        if ($this->featuredImage) {
            $post->addMedia($this->featuredImage->getRealPath())
                ->usingFileName($this->featuredImage->getClientOriginalName())
                ->toMediaCollection('featured_image');
        }

        // 4. Activity is logged automatically via LogsActivity trait

        Flux::toast('Post created.');
        $this->redirect(route('posts.index'), navigate: true);
    }

    #[Computed]
    public function posts()
    {
        return Post::query()
            ->with('media', 'roles')  // Eager load to avoid N+1
            ->latest()
            ->paginate(15);
    }

    public function render()
    {
        return view('livewire.post-manager');
    }
}
```

---

## Quick Reference

| Package | Key Trait/Interface | Common Livewire Integration |
|---|---|---|
| Permission | `HasRoles` on User model | `@can`/`@role` in Blade, `$this->authorize()` in methods |
| Media Library | `HasMedia` + `InteractsWithMedia` | `WithFileUploads` + `addMedia()` in save |
| Activity Log | `LogsActivity` | Automatic logging, display with filtered Livewire table |

### Common Gotchas

| Issue | Solution |
|---|---|
| N+1 on `$user->roles` in table | Eager load: `->with('roles')` |
| N+1 on `$post->getFirstMediaUrl()` in loop | Eager load: `->with('media')` |
| Permission check only in Blade (no server-side) | Always add `$this->authorize()` in action methods |
| Media not showing after upload | Clear computed cache: `unset($this->posts)` |
| Activity log floods with empty logs | Use `->dontSubmitEmptyLogs()` in LogOptions |
| Temp files piling up from `WithFileUploads` | Process and clear `$this->photo = null` after save |
