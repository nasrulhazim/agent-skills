# Frontend Conventions

## Stack

| Technology | Version | Purpose |
|---|---|---|
| TailwindCSS | v4 | Utility-first CSS framework |
| Alpine.js | v3 | Lightweight JS framework for interactivity |
| Tippy.js | Latest | Tooltips and popovers |
| Vite | Latest | Build tool and dev server |
| Livewire | v4 | Server-driven reactive components |
| Flux UI | Latest | Livewire component library |

## TailwindCSS v4

TailwindCSS v4 uses CSS-based configuration (no `tailwind.config.js`):

```css
/* resources/css/app.css */
@import "tailwindcss";

@theme {
    --color-primary: #3b82f6;
    --color-secondary: #6366f1;
    --font-sans: 'Inter', sans-serif;
}
```

### Key Differences from v3

- No `tailwind.config.js` — configuration is in CSS via `@theme`
- No `@tailwind base/components/utilities` — use `@import "tailwindcss"`
- Custom colours defined in `@theme` block
- Content detection is automatic

## Alpine.js

Use Alpine for lightweight client-side interactivity:

```html
<!-- Toggle visibility -->
<div x-data="{ open: false }">
    <button @click="open = !open">Toggle</button>
    <div x-show="open" x-transition>Content</div>
</div>

<!-- Form state -->
<form x-data="{ submitting: false }" @submit="submitting = true">
    <button :disabled="submitting" type="submit">
        <span x-show="!submitting">Submit</span>
        <span x-show="submitting">Processing...</span>
    </button>
</form>
```

## Tippy.js Tooltips

```html
<button x-data x-tooltip="'Click to save'">
    Save
</button>
```

## Vite Configuration

```js
// vite.config.js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
            ],
            refresh: true,
        }),
    ],
});
```

## Blade Layout

```html
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @fluxAppearance
</head>
<body class="min-h-screen bg-white dark:bg-zinc-800">
    <flux:sidebar>
        <!-- Navigation -->
    </flux:sidebar>

    <flux:main>
        {{ $slot }}
    </flux:main>

    @fluxScripts
</body>
</html>
```

## Component Patterns

### Flux UI Components

Prefer Flux UI components over raw HTML for consistency:

```html
<!-- Button -->
<flux:button variant="primary">Save</flux:button>

<!-- Input -->
<flux:input wire:model="name" label="Name" />

<!-- Modal -->
<flux:modal name="confirm-delete">
    <flux:heading>Confirm Delete</flux:heading>
    <flux:text>Are you sure you want to delete this item?</flux:text>
    <div class="flex gap-2 mt-4">
        <flux:button variant="danger" wire:click="delete">Delete</flux:button>
        <flux:modal.close>
            <flux:button variant="ghost">Cancel</flux:button>
        </flux:modal.close>
    </div>
</flux:modal>
```

### Livewire Integration

See the `livewire-flux` skill for detailed Livewire + Flux patterns.

## Asset Building

```bash
# Development (with HMR)
npm run dev

# Production build
npm run build
```

## DO / DON'T

- ✅ DO use TailwindCSS v4 CSS-based config (`@theme`)
- ✅ DO use Flux UI components for forms, modals, buttons
- ✅ DO use Alpine.js for client-side interactivity
- ✅ DO use `@vite()` directive for assets
- ✅ DO support dark mode via Tailwind's `dark:` variant
- ❌ DON'T create a `tailwind.config.js` — v4 uses CSS config
- ❌ DON'T use jQuery or vanilla JS when Alpine suffices
- ❌ DON'T inline styles — use Tailwind utility classes
- ❌ DON'T mix Flux UI with raw HTML form elements
