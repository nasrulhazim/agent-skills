# Livewire + Flux Accessibility Patterns

Flux UI handles roles, `aria-expanded`, focus trapping and Escape for its primitives. What it
cannot do is name your controls, choose your focus order, or decide what should be announced
when a request completes. That is this file.

---

## Buttons

```blade
{{-- ❌ Announced as "button" --}}
<flux:button wire:click="delete" icon="trash" />

{{-- ✅ --}}
<flux:button wire:click="delete" icon="trash" aria-label="Delete invoice" />

{{-- ✅ In-flight state announced and double-submit prevented --}}
<flux:button
    wire:click="save"
    wire:loading.attr="disabled"
    wire:target="save"
>
    <span wire:loading.remove wire:target="save">Save</span>
    <span wire:loading wire:target="save">Saving…</span>
</flux:button>
```

Every icon-only control needs a name. If several rows each have a "Delete" button, make the
name specific — `aria-label="Delete invoice INV-1042"` — otherwise a screen reader user hears
twenty identical buttons.

---

## Forms

```blade
<flux:field>
    <flux:label>Email address</flux:label>

    <flux:input
        type="email"
        wire:model.blur="email"
        autocomplete="email"
        required
    />

    <flux:description>We only use this for receipts.</flux:description>
    <flux:error name="email" />
</flux:field>
```

`flux:field` wires the label, description and error to the input with the right `for` and
`aria-describedby`. A bare `flux:input` with a `<label>` floating beside it does not — the
association is what makes it work.

### Error summary on submit

Per-field errors alone leave a user hunting on a long form.

```blade
@if ($errors->any())
    <div role="alert" tabindex="-1" wire:key="error-summary" x-init="$el.focus()">
        <h2>{{ $errors->count() }} problems need fixing</h2>
        <ul>
            @foreach ($errors->keys() as $field)
                <li><a href="#{{ $field }}">{{ $errors->first($field) }}</a></li>
            @endforeach
        </ul>
    </div>
@endif
```

### Radio and checkbox groups

```blade
<flux:fieldset>
    <flux:legend>Delivery method</flux:legend>
    <flux:radio.group wire:model="delivery">
        <flux:radio value="post" label="Post" />
        <flux:radio value="pickup" label="Pickup" />
    </flux:radio.group>
</flux:fieldset>
```

Without the legend, a screen reader announces the options but never the question.

---

## Modals

```blade
<flux:modal name="confirm-delete" class="max-w-md">
    <flux:heading size="lg">Delete this invoice?</flux:heading>

    <flux:text>This cannot be undone.</flux:text>

    <div class="flex gap-2">
        <flux:modal.close>
            <flux:button variant="ghost">Cancel</flux:button>
        </flux:modal.close>

        <flux:button variant="danger" wire:click="delete">Delete</flux:button>
    </div>
</flux:modal>
```

Flux gives you `role="dialog"`, `aria-modal`, the focus trap and Escape. Your responsibilities:

- **A heading** — it becomes the dialog's accessible name. A modal with no heading is
  announced as "dialog" and nothing else.
- **Focus lands somewhere sensible** on open — the first control, or the heading for a long
  dialog. Not the close button.
- **Focus returns to the trigger** on close. If the trigger no longer exists (you just deleted
  its row), move focus to a stable nearby element such as the table heading.
- **Destructive confirmation is the default action, not the auto-focused one** — do not put
  focus on "Delete".

---

## Dropdowns and Menus

```blade
<flux:dropdown>
    <flux:button icon-trailing="chevron-down">Actions</flux:button>

    <flux:menu>
        <flux:menu.item icon="pencil" wire:click="edit">Edit</flux:menu.item>
        <flux:menu.item icon="trash" variant="danger" wire:click="delete">Delete</flux:menu.item>
    </flux:menu>
</flux:dropdown>
```

Verify in the browser: Enter/Space opens, arrow keys move between items, Escape closes and
returns focus to the trigger, and Tab closes rather than walking through hidden items.

---

## Tables

```blade
<table>
    <caption class="sr-only">Invoices, sorted by date, newest first</caption>
    <thead>
        <tr>
            <th scope="col">
                <button wire:click="sortBy('reference')"
                        aria-label="Sort by reference">
                    Reference
                    <span aria-hidden="true">{{ $sort === 'reference' ? '↓' : '' }}</span>
                </button>
            </th>
            <th scope="col">Customer</th>
            <th scope="col">Total</th>
        </tr>
    </thead>
    <tbody>
        @foreach ($invoices as $invoice)
            <tr wire:key="invoice-{{ $invoice->id }}">
                <th scope="row">{{ $invoice->reference }}</th>
                <td>{{ $invoice->customer->name }}</td>
                <td>{{ $invoice->total }}</td>
            </tr>
        @endforeach
    </tbody>
</table>
```

| Rule | Why |
|---|---|
| `<caption>` describing the table and its current sort | Announced on entering the table |
| `scope="col"` and `scope="row"` | Cells are announced with their headers while navigating |
| The row's identifying cell as `<th scope="row">` | "Invoice INV-1042, Total, RM 500" instead of a bare number |
| `aria-sort` on the sorted column | State exposed, not just an arrow glyph |
| `wire:key` on every row | Livewire patches rather than replaces — focus survives |
| Never a `<div>` grid | You lose every one of the above |

Announce the result of a sort or filter:

```blade
<div aria-live="polite" class="sr-only">
    {{ $invoices->total() }} invoices, sorted by {{ $sort }}.
</div>
```

---

## Live Regions

```blade
{{-- Always present in the DOM, keyed so Livewire never replaces the node --}}
<div aria-live="polite" aria-atomic="true" class="sr-only" wire:key="status-region">
    {{ $statusMessage }}
</div>
```

- The container must exist **before** its content changes. A region created at the same moment
  as its message is frequently not announced.
- `wire:key` keeps the node across re-renders — a replaced live region is a dead live region.
- `polite` for almost everything. `assertive` interrupts whatever is being read; reserve it
  for errors and time-critical warnings.
- One or two per page. More and they compete for the same announcement queue.

---

## Loading and Async

```blade
<div wire:loading.delay wire:target="search" role="status">
    <span class="sr-only">Searching…</span>
    <flux:icon.loading aria-hidden="true" />
</div>

<div wire:loading.remove wire:target="search">
    @forelse ($results as $result)
        …
    @empty
        <p>No results for "{{ $query }}".</p>
    @endforelse
</div>
```

`wire:loading.delay` avoids a flash on fast responses. `role="status"` makes the loading state
audible rather than purely visual.

---

## Focus Preservation

The most common Livewire accessibility bug: focus vanishing mid-typing.

```blade
{{-- ✅ Stable key — Livewire patches the node instead of replacing it --}}
<flux:input
    type="search"
    wire:model.live.debounce.400ms="query"
    wire:key="search-input"
    placeholder="Search invoices"
    aria-label="Search invoices"
/>
```

After a destructive action, move focus deliberately:

```php
public function delete(Invoice $invoice): void
{
    $this->authorize('delete', $invoice);
    $invoice->delete();

    $this->status = 'Invoice deleted.';
    $this->dispatch('focus-table-heading');   // Alpine listener moves focus
}
```

Never leave focus on an element you just removed — the browser drops it to `<body>` and the
user loses their place entirely.

---

## Toasts

```blade
<div aria-live="polite" aria-atomic="true" wire:key="toasts">
    @foreach ($toasts as $toast)
        <div role="status" wire:key="toast-{{ $toast['id'] }}">
            {{ $toast['message'] }}
            <button wire:click="dismiss('{{ $toast['id'] }}')" aria-label="Dismiss notification">
                <flux:icon.x-mark aria-hidden="true" />
            </button>
        </div>
    @endforeach
</div>
```

- Never auto-dismiss a toast carrying information the user must act on.
- Auto-dismiss timing must clear WCAG 2.2.1, or provide a way to extend it.
- A toast is not a substitute for an inline error next to the field that failed.

---

## Component Review Checklist

Before shipping any Livewire or Flux component:

- [ ] Tab reaches every control, in the visual order
- [ ] Focus is visible on each one, in light and dark mode
- [ ] Escape closes any overlay and returns focus to the trigger
- [ ] Every icon-only control has an accessible name
- [ ] Every input sits inside a `flux:field` with a `flux:label`
- [ ] Errors render through `flux:error`, associated with the input
- [ ] Async results announce through a pre-existing, keyed `aria-live` region
- [ ] Loading states carry `role="status"` and `sr-only` text, not just a spinner
- [ ] Inputs and list rows have a stable `wire:key`
- [ ] Focus is moved deliberately after any action that removes the focused element
- [ ] Contrast verified in both themes on the rendered component
