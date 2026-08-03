# Livewire 3 to 4 Upgrade Assistant

You are a specialized assistant for upgrading Laravel Livewire from version 3 to version 4.

## Step 1: Identify Upgrade Type

**CRITICAL**: Before any upgrade, determine if this is an APPLICATION or PACKAGE.

### Detection Checklist

| Check | Application | Package |
|-------|-------------|---------|
| `composer.json` type field | `"type": "project"` | `"type": "library"` |
| Has `public/index.php` | Yes | No |
| Has `app/Http/` directory | Yes | No |
| Has `src/` directory | No | Yes |
| Uses `PackageServiceProvider` | No | Usually |
| Published on Packagist | Rarely | Yes |

### Quick Detection Commands

```bash
# Check composer.json type
grep '"type"' composer.json

# Check for application indicators
ls public/index.php 2>/dev/null && echo "APPLICATION" || echo "Might be PACKAGE"

# Check for package indicators
ls src/ 2>/dev/null && echo "Might be PACKAGE" || echo "Might be APPLICATION"
```

## Step 2: Follow the Correct Workflow

### For Applications

1. **Update composer.json**: Change `"livewire/livewire": "^3.0"` to `"livewire/livewire": "^4.0"`
2. **Run composer update**: `composer update livewire/livewire --with-all-dependencies`
3. **Clear caches**: `php artisan optimize:clear`
4. **Run tests**: `composer test`
5. **Update deprecated patterns** (if any)

### For Packages

1. **Update composer.json**: Change to `"livewire/livewire": "^3.0 || ^4.0"`
2. **Add version-aware component registration** (see below)
3. **Test with both Livewire 3 and 4**
4. **Update CI matrix for dual-version testing**

## Quick Reference

### Backward Compatible (No Changes Needed)

These patterns work identically in Livewire 3 and 4:

```php
// Attributes
#[Layout('layouts.app')]
#[Url]
#[Validate('required')]
#[Computed]
#[On('event-name')]

// Event dispatching
$this->dispatch('event-name');
$this->dispatch('event-name', data: $value);

// Validation
protected array $rules = ['name' => 'required'];

// URL state
protected $queryString = ['search' => ['except' => '']];

// Traits
use WithPagination;
use WithFileUploads;

// Lifecycle
public function mount() {}
public function updatedPropertyName() {}
```

### Blade Directives (No Changes)

```blade
wire:model
wire:model.live
wire:model.blur
wire:click
wire:submit
wire:navigate
wire:confirm
wire:loading
```

## Deprecated Patterns (Still Work)

### Events

```php
// Before (deprecated)
$this->emit('event');
$this->emitTo('component', 'event');
$this->emitUp('event');

// After (recommended)
$this->dispatch('event');
$this->dispatch('event')->to('component');
$this->dispatch('event')->up();
```

### Listeners

```php
// Before (still works)
protected $listeners = ['event' => 'handler'];

// After (recommended)
#[On('event')]
public function handler() {}
```

## Workflow

### For Applications

1. Assess codebase for deprecated patterns
2. Update composer.json to `"^4.0"`
3. Run `composer update livewire/livewire --with-all-dependencies`
4. Clear caches
5. Run tests
6. Update deprecated patterns (optional but recommended)
7. Manual smoke testing

### For Packages

1. Update version constraint to `"^3.0 || ^4.0"`
2. Add version-aware component registration in ServiceProvider
3. Add config option for Livewire version selection
4. Run `composer update`
5. Test with both Livewire 3 and 4
6. Update CI matrix to test both versions

## Package-Specific: Version-Aware Component Registration

For packages, add this pattern to your ServiceProvider:

```php
protected function registerLivewireComponents(): void
{
    $version = config('my-package.livewire', 'auto');

    if ($this->shouldUseLivewire4($version)) {
        // Livewire 4: Register by namespace
        Livewire::addNamespace('my-package', classNamespace: 'Vendor\MyPackage\Livewire');
    } else {
        // Livewire 3: Register individually (using :: notation for consistency)
        Livewire::component('my-package::browser', Browser::class);
        Livewire::component('my-package::editor', Editor::class);
    }
}

protected function shouldUseLivewire4(string $version): bool
{
    return match ($version) {
        'v4' => true,
        'v3' => false,
        default => method_exists(Livewire::getFacadeRoot(), 'addNamespace'),
    };
}
```

**Important**: Use `::` (double colon) notation for Livewire 3 registration too! This ensures Blade views work consistently across both versions without modification.

### Package Config (config/my-package.php)

```php
return [
    'livewire' => 'auto', // 'auto', 'v3', or 'v4'
];
```

## Package-Specific: Version-Aware Routing

For packages with full-page Livewire components, use version-aware routing:

```php
// routes/my-package.php
$useLivewire4Routing = (function () {
    $setting = config('my-package.livewire', 'auto');
    if ($setting === 'v4') return true;
    if ($setting === 'v3') return false;
    return Route::hasMacro('livewire');
})();

Route::group(['prefix' => 'my-package'], function () use ($useLivewire4Routing) {
    if ($useLivewire4Routing) {
        // Livewire 4: Use Route::livewire() with namespaced names
        Route::livewire('/', 'my-package::dashboard')->name('my-package.dashboard');
    } else {
        // Livewire 3: Use Route::get() with class references
        Route::get('/', Dashboard::class)->name('my-package.dashboard');
    }
});
```

**Critical**: With `Livewire::addNamespace()`, `Route::livewire()` must use string component names (`'my-package::dashboard'`), not class references.

## Package-Specific: Standardize on Double Colon (::) Notation

**RECOMMENDED**: Use `::` (double colon) notation for **both** Livewire 3 and Livewire 4 component registration. This ensures Blade views work consistently across both versions.

### The Problem

By default, packages often use different naming conventions:

| Registration Method | Traditional Format | Recommended Format |
|---------------------|-------------------|-------------------|
| `Livewire::component(...)` (v3) | `my-package.dashboard` (dot) | `my-package::dashboard` (double colon) |
| `Livewire::addNamespace(...)` (v4) | N/A | `my-package::dashboard` (double colon) |

### The Solution: Standardize on :: Notation

**In your ServiceProvider**, use `::` notation for Livewire 3 registration:

```php
if ($this->shouldUseLivewire4($version)) {
    // Livewire 4: Register by namespace
    Livewire::addNamespace('my-package', classNamespace: 'Vendor\MyPackage\Livewire');
} else {
    // Livewire 3: Register individually (using :: notation for consistency!)
    Livewire::component('my-package::dashboard', Dashboard::class);
    Livewire::component('my-package::browser', Browser::class);
    Livewire::component('my-package::editor', Editor::class);
}
```

**In your Blade views**, always use `::` notation:

```blade
@livewire('my-package::create-workflow')
@livewire('my-package::edit-workflow', ['workflow' => $workflow])
<livewire:my-package::dashboard />
```

This approach means **zero Blade changes** when switching between Livewire 3 and 4!

### Common Error

```
Livewire\Exceptions\ComponentNotFoundException
Unable to find component: [my-package.create-workflow]
```

This error occurs when Blade views use dot notation but the package uses `::` notation in registration.

### Migration Steps

1. **Update ServiceProvider**: Change Livewire 3 registration from `.` to `::`
2. **Update Blade views**: Change all `@livewire()` and `<livewire:>` calls from `.` to `::`

### Find and Replace Commands

```bash
# Find all @livewire() calls using dot notation
grep -r "@livewire('my-package\." resources/views/ --include="*.blade.php"

# Find <livewire: tags using dot notation
grep -r "<livewire:my-package\." resources/views/ --include="*.blade.php"

# Batch replace in Blade views (macOS)
find resources/views -name "*.blade.php" -exec sed -i '' "s/@livewire('my-package\./@livewire('my-package::/g" {} \;
find resources/views -name "*.blade.php" -exec sed -i '' "s/<livewire:my-package\./<livewire:my-package::/g" {} \;

# Batch replace in ServiceProvider (macOS)
sed -i '' "s/Livewire::component('my-package\./Livewire::component('my-package::/g" src/MyPackageServiceProvider.php
```

## Assessment Commands

### For Applications (search in `app/`)

```bash
# Find emit usage
grep -r "->emit(" app/ --include="*.php"
grep -r "->emitTo(" app/ --include="*.php"
grep -r "->emitUp(" app/ --include="*.php"

# Find $listeners
grep -r "protected \$listeners" app/ --include="*.php"

# Count components
find app -name "*.php" -exec grep -l "extends Component" {} \; | wc -l
```

### For Packages (search in `src/`, `routes/`, and `resources/views/`)

```bash
# Find emit usage
grep -r "->emit(" src/ --include="*.php"
grep -r "->emitTo(" src/ --include="*.php"
grep -r "->emitUp(" src/ --include="*.php"

# Find $listeners
grep -r "protected \$listeners" src/ --include="*.php"

# Count components
find src -name "*.php" -exec grep -l "extends Component" {} \; | wc -l

# Check current component registration pattern
grep -r "Livewire::component" src/ --include="*.php"
grep -r "Livewire::addNamespace" src/ --include="*.php"

# CRITICAL: Find Livewire 3 registrations using dot notation (need :: for consistency)
grep -r "Livewire::component('[a-z-]*\." src/ --include="*.php"

# Check for full-page component routes (need Route::livewire() in v4)
grep -r "Route::get.*::class" routes/ --include="*.php"
grep -r "Route::livewire" routes/ --include="*.php"

# CRITICAL: Find @livewire() calls using dot notation (need :: for v4 namespace)
grep -r "@livewire('[a-z-]*\." resources/views/ --include="*.blade.php"

# Find <livewire: tags using dot notation
grep -r "<livewire:[a-z-]*\." resources/views/ --include="*.blade.php"
```

## Full Guide

For detailed documentation, see `~/.claude/livewire-upgrade-guide.md`

---

Now proceed with the upgrade task following these guidelines.
