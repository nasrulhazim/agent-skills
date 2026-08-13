# Livewire Testing Patterns

Complete reference for testing Livewire v3 components with Pest — component rendering, state
management, user interactions, events, file uploads, Flux UI components, and wire:navigate.

---

## Basic Component Testing

### Rendering

```php
use Livewire\Livewire;
use App\Livewire\Dashboard;

it('renders successfully', function () {
    Livewire::test(Dashboard::class)
        ->assertStatus(200);
});

it('renders with initial data', function () {
    Livewire::test(Dashboard::class)
        ->assertSee('Welcome back')
        ->assertDontSee('Error');
});
```

### Passing Parameters

```php
use App\Livewire\ProjectDetail;
use App\Models\Project;

it('receives a project model', function () {
    $project = Project::factory()->create(['name' => 'Acme']);

    Livewire::test(ProjectDetail::class, ['project' => $project])
        ->assertSee('Acme');
});
```

### Testing with Authentication

```php
it('shows user-specific content', function () {
    $user = User::factory()->create(['name' => 'Sarah']);

    Livewire::actingAs($user)
        ->test(ProfileCard::class)
        ->assertSee('Sarah');
});
```

---

## State Assertions

### assertSet / assertNotSet

```php
it('initializes with default values', function () {
    Livewire::test(CreateProject::class)
        ->assertSet('name', '')
        ->assertSet('description', '')
        ->assertSet('isPublic', false);
});
```

### assertViewHas

```php
it('passes computed data to the view', function () {
    Project::factory()->count(5)->create();

    Livewire::test(ProjectList::class)
        ->assertViewHas('projects', function ($projects) {
            return $projects->count() === 5;
        });
});
```

### Testing Computed Properties

```php
it('computes the full name', function () {
    Livewire::test(ProfileEditor::class)
        ->set('firstName', 'John')
        ->set('lastName', 'Doe')
        ->assertSet('fullName', 'John Doe');
});
```

---

## User Interactions

### Setting Properties

```php
it('updates state when property is set', function () {
    Livewire::test(SearchBar::class)
        ->set('query', 'Laravel')
        ->assertSet('query', 'Laravel')
        ->assertSee('Results for: Laravel');
});
```

### Calling Methods

```php
it('increments the counter', function () {
    Livewire::test(Counter::class)
        ->assertSet('count', 0)
        ->call('increment')
        ->assertSet('count', 1)
        ->call('increment')
        ->assertSet('count', 2);
});
```

### Toggle

```php
it('toggles visibility', function () {
    Livewire::test(Sidebar::class)
        ->assertSet('isOpen', false)
        ->toggle('isOpen')
        ->assertSet('isOpen', true);
});
```

### Form Submission

```php
it('creates a project via form', function () {
    $user = User::factory()->create();

    Livewire::actingAs($user)
        ->test(CreateProject::class)
        ->set('name', 'New Project')
        ->set('description', 'A great project')
        ->set('visibility', 'public')
        ->call('save')
        ->assertHasNoErrors();

    expect(Project::where('name', 'New Project')->exists())->toBeTrue();
});
```

---

## Validation Testing

### assertHasErrors / assertHasNoErrors

```php
it('validates required fields', function () {
    Livewire::test(CreateProject::class)
        ->set('name', '')
        ->call('save')
        ->assertHasErrors(['name' => 'required']);
});

it('validates multiple rules', function () {
    Livewire::test(CreateProject::class)
        ->set('name', 'ab')           // min:3
        ->set('budget', -100)          // min:0
        ->set('email', 'not-an-email') // email
        ->call('save')
        ->assertHasErrors([
            'name' => 'min',
            'budget' => 'min',
            'email' => 'email',
        ]);
});

it('accepts valid input', function () {
    Livewire::test(CreateProject::class)
        ->set('name', 'Valid Project Name')
        ->set('description', 'A proper description')
        ->call('save')
        ->assertHasNoErrors();
});
```

### Real-Time Validation

```php
it('validates on blur', function () {
    Livewire::test(CreateProject::class)
        ->set('name', '')
        ->call('validateOnly', 'name')
        ->assertHasErrors(['name']);
});
```

---

## Event Testing

### Dispatching Events

```php
it('dispatches event after save', function () {
    $user = User::factory()->create();

    Livewire::actingAs($user)
        ->test(CreateProject::class)
        ->set('name', 'New Project')
        ->call('save')
        ->assertDispatched('project-created');
});

it('dispatches event with parameters', function () {
    Livewire::actingAs(User::factory()->create())
        ->test(CreateProject::class)
        ->set('name', 'Test')
        ->call('save')
        ->assertDispatched('project-created', function ($event, $params) {
            return $params['name'] === 'Test';
        });
});

it('does not dispatch event on validation failure', function () {
    Livewire::test(CreateProject::class)
        ->set('name', '')
        ->call('save')
        ->assertNotDispatched('project-created');
});
```

### Listening to Events

```php
it('refreshes project list when project is created', function () {
    $projects = Project::factory()->count(3)->create();

    Livewire::test(ProjectList::class)
        ->assertSee($projects[0]->name)
        ->dispatch('project-created')
        ->assertSee($projects[0]->name); // Still rendered after refresh
});
```

### Browser Events

```php
it('dispatches browser event for toast notification', function () {
    Livewire::actingAs(User::factory()->create())
        ->test(CreateProject::class)
        ->set('name', 'Test Project')
        ->call('save')
        ->assertDispatched('notify', function ($event, $params) {
            return $params['type'] === 'success'
                && str_contains($params['message'], 'created');
        });
});
```

---

## File Upload Testing

### Single File Upload

```php
use Livewire\Livewire;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

it('uploads an avatar', function () {
    Storage::fake('public');

    $file = UploadedFile::fake()->image('avatar.jpg', 200, 200);

    Livewire::actingAs(User::factory()->create())
        ->test(AvatarUpload::class)
        ->set('photo', $file)
        ->call('save')
        ->assertHasNoErrors();

    Storage::disk('public')->assertExists('avatars/' . $file->hashName());
});
```

### Multiple File Upload

```php
it('uploads multiple attachments', function () {
    Storage::fake('public');

    $files = [
        UploadedFile::fake()->image('photo1.jpg'),
        UploadedFile::fake()->image('photo2.jpg'),
        UploadedFile::fake()->create('document.pdf', 500),
    ];

    Livewire::actingAs(User::factory()->create())
        ->test(AttachmentUpload::class)
        ->set('files', $files)
        ->call('save')
        ->assertHasNoErrors();

    expect(Attachment::count())->toBe(3);
});
```

### File Validation

```php
it('rejects files that are too large', function () {
    $file = UploadedFile::fake()->image('huge.jpg')->size(5120); // 5MB

    Livewire::test(AvatarUpload::class)
        ->set('photo', $file)
        ->call('save')
        ->assertHasErrors(['photo' => 'max']);
});

it('only accepts image files', function () {
    $file = UploadedFile::fake()->create('malware.exe', 100);

    Livewire::test(AvatarUpload::class)
        ->set('photo', $file)
        ->call('save')
        ->assertHasErrors(['photo' => 'image']);
});
```

### Temporary Upload Preview

```php
it('shows preview after upload', function () {
    $file = UploadedFile::fake()->image('avatar.jpg');

    Livewire::test(AvatarUpload::class)
        ->set('photo', $file)
        ->assertSet('photo', function ($photo) {
            return $photo !== null;
        })
        ->assertSee('Preview'); // Component shows preview state
});
```

---

## Flux UI Component Testing

Flux UI renders Blade components. Test their behaviour through the Livewire component that
uses them — do not test Flux internals.

### Modal Dialogs

```php
it('opens the delete confirmation modal', function () {
    $project = Project::factory()->create();

    Livewire::actingAs(User::factory()->create())
        ->test(ProjectDetail::class, ['project' => $project])
        ->call('confirmDelete')
        ->assertSet('showDeleteModal', true)
        ->assertSee('Are you sure');
});

it('deletes project when modal is confirmed', function () {
    $project = Project::factory()->create();

    Livewire::actingAs(User::factory()->create())
        ->test(ProjectDetail::class, ['project' => $project])
        ->call('confirmDelete')
        ->call('delete')
        ->assertDispatched('project-deleted');

    $this->assertModelMissing($project);
});
```

### Dropdown and Select Inputs

```php
it('filters by status via dropdown', function () {
    Project::factory()->create(['status' => 'active', 'name' => 'Active Project']);
    Project::factory()->create(['status' => 'archived', 'name' => 'Old Project']);

    Livewire::test(ProjectList::class)
        ->set('statusFilter', 'active')
        ->assertSee('Active Project')
        ->assertDontSee('Old Project');
});
```

### Toast Notifications

```php
it('shows success toast after creating project', function () {
    Livewire::actingAs(User::factory()->create())
        ->test(CreateProject::class)
        ->set('name', 'My Project')
        ->call('save')
        ->assertDispatched('notify', function ($event, $params) {
            return $params['type'] === 'success';
        });
});
```

### Tabs

```php
it('switches tab content', function () {
    Livewire::test(ProjectSettings::class, ['project' => Project::factory()->create()])
        ->assertSee('General Settings')     // Default tab
        ->set('activeTab', 'members')
        ->assertSee('Team Members')
        ->assertDontSee('General Settings');
});
```

### Table with Sorting and Pagination

```php
it('sorts projects by name', function () {
    Project::factory()->create(['name' => 'Zebra']);
    Project::factory()->create(['name' => 'Alpha']);

    Livewire::test(ProjectTable::class)
        ->call('sortBy', 'name')
        ->assertSeeInOrder(['Alpha', 'Zebra']);
});

it('paginates results', function () {
    Project::factory()->count(25)->create();

    Livewire::test(ProjectTable::class)
        ->assertViewHas('projects', function ($projects) {
            return $projects->count() === 15; // Default per page
        })
        ->call('nextPage')
        ->assertViewHas('projects', function ($projects) {
            return $projects->count() === 10;
        });
});
```

---

## wire:navigate Testing

Test navigation between pages that use `wire:navigate`:

### Page Rendering After Navigation

```php
it('renders the target page', function () {
    $user = User::factory()->create();

    // Test the target route directly — Livewire handles SPA navigation
    $this->actingAs($user)
        ->get(route('projects.create'))
        ->assertOk()
        ->assertSeeLivewire(CreateProject::class);
});
```

### Testing Redirects After Actions

```php
it('redirects to project page after creation', function () {
    Livewire::actingAs(User::factory()->create())
        ->test(CreateProject::class)
        ->set('name', 'New Project')
        ->call('save')
        ->assertRedirect(route('projects.index'));
});

it('redirects with navigate', function () {
    Livewire::actingAs(User::factory()->create())
        ->test(CreateProject::class)
        ->set('name', 'New Project')
        ->call('save')
        ->assertRedirect(route('projects.show', Project::first()));
});
```

### Layout Persistence

```php
it('maintains layout state', function () {
    $user = User::factory()->create();

    // Test that the layout component renders
    $this->actingAs($user)
        ->get(route('dashboard'))
        ->assertOk()
        ->assertSee($user->name); // From layout/navigation
});
```

---

## Polling and Deferred Loading

### Testing Polling

```php
it('updates data on poll', function () {
    $project = Project::factory()->create(['status' => 'processing']);

    $component = Livewire::test(ProjectStatus::class, ['project' => $project]);

    $component->assertSee('Processing');

    // Simulate background update
    $project->update(['status' => 'complete']);

    // Simulate poll trigger
    $component->call('$refresh')
        ->assertSee('Complete');
});
```

### Testing Lazy Loading

```php
it('shows placeholder while loading', function () {
    Livewire::test(HeavyReport::class)
        ->assertSee('Loading...'); // Placeholder content
});
```

---

## Nested Component Testing

### Parent-Child Interaction

```php
it('passes updated data from parent to child', function () {
    $project = Project::factory()->create(['name' => 'Original']);

    Livewire::test(ProjectDetail::class, ['project' => $project])
        ->assertSee('Original');

    $project->update(['name' => 'Updated']);

    Livewire::test(ProjectDetail::class, ['project' => $project->fresh()])
        ->assertSee('Updated');
});
```

### Testing Components in Isolation

Always test Livewire components in isolation. Pass dependencies as parameters rather than
relying on parent components:

```php
// Test the child directly
it('renders task item with correct status', function () {
    $task = Task::factory()->create(['status' => 'done']);

    Livewire::test(TaskItem::class, ['task' => $task])
        ->assertSee('Done')
        ->assertSee($task->title);
});
```

---

## Testing Authorization in Components

```php
it('denies access to non-owners', function () {
    $owner = User::factory()->create();
    $stranger = User::factory()->create();
    $project = Project::factory()->for($owner)->create();

    Livewire::actingAs($stranger)
        ->test(EditProject::class, ['project' => $project])
        ->assertForbidden();
});

it('allows owners to edit', function () {
    $owner = User::factory()->create();
    $project = Project::factory()->for($owner)->create();

    Livewire::actingAs($owner)
        ->test(EditProject::class, ['project' => $project])
        ->assertOk();
});
```

---

## Testing Wire Actions

### wire:confirm

```php
it('requires confirmation before delete', function () {
    $project = Project::factory()->create();

    // Test that calling delete actually deletes (the wire:confirm is browser-side)
    Livewire::actingAs(User::factory()->create())
        ->test(ProjectDetail::class, ['project' => $project])
        ->call('delete');

    $this->assertModelMissing($project);
});
```

### wire:loading / wire:target

Loading states are CSS-based and cannot be directly tested in Pest. Instead, test that the
underlying action completes correctly:

```php
it('processes the action that triggers loading state', function () {
    Livewire::test(ExportReport::class)
        ->call('export')
        ->assertDispatched('export-started')
        ->assertSet('isExporting', true);
});
```
