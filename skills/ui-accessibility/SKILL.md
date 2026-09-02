---
name: ui-accessibility
metadata:
  compatible_agents: [claude-code]
  tags: [accessibility, a11y, wcag, livewire, flux, blade, ui, keyboard, screen-reader]
description: >
  WCAG 2.1 AA accessibility for Laravel, Livewire and Flux UI interfaces — auditing existing
  screens and building new ones that work with a keyboard, a screen reader and at 200% zoom.
  Covers semantic HTML over div soup, accessible names and labels, colour contrast in both
  light and dark mode, visible focus and logical focus order, keyboard traps, modal and
  dropdown focus management, form errors announced rather than only coloured, live regions
  for Livewire's asynchronous updates, reduced-motion support, and touch target sizing. Use
  this skill whenever the user asks to audit or fix accessibility, mentions WCAG, screen
  readers, keyboard navigation, colour contrast, focus states, ARIA, or alt text, or is
  building a form, modal, dropdown, table or data view that people must be able to operate
  without a mouse — including "is this accessible", "run an a11y audit", "check contrast",
  "add ARIA labels", "make this keyboard navigable", "fix the focus states", "screen reader
  support", "WCAG compliance", "semak aksesibiliti", "boleh guna keyboard tak", "tambah
  label untuk screen reader", "warna ni cukup kontras ke", or "buat form ni accessible".
  Pairs with livewire-flux for the component implementation and frontend-design for the
  aesthetic direction.
---

# UI Accessibility

Accessibility is not a pass at the end. It is semantic HTML, a real label, a visible focus
ring and enough contrast — decisions made while the component is written, when they cost
nothing.

**The 80% rule:** most real accessibility failures in a Laravel app come from five things —
a `<div>` used as a button, a form input with no associated label, an icon-only control with
no accessible name, invisible or removed focus styles, and text below contrast minimum in
dark mode. Fix those five and you have fixed most of what a real user hits.

## Command Reference

| Command | Description |
|---|---|
| `/a11y audit` | Audit a page or component against WCAG 2.1 AA |
| `/a11y keyboard` | Walk the keyboard path — focus order, traps, visible focus |
| `/a11y contrast` | Check colour contrast in light and dark mode |
| `/a11y forms` | Audit labels, error association and announcement |
| `/a11y livewire` | Audit async updates — live regions, loading and focus after re-render |
| `/a11y fix` | Apply the fixes, in severity order |

---

## When to Use

- Building any form, modal, dropdown, tab set, table or data view
- Auditing an existing screen before launch or a compliance review
- A government, education, healthcare or enterprise deliverable where WCAG 2.1 AA is contractual
- Someone reports they cannot use a feature with a keyboard or a screen reader
- Adding dark mode — contrast that passes in light mode routinely fails in dark

**Do not** treat an automated checker's clean report as a pass. Automated tools catch roughly
a third of WCAG failures. The keyboard walk in section 3 catches most of the rest, and it
takes two minutes.

---

## 1. Semantics First

Every ARIA attribute you add is a correction for markup that should have been semantic. The
first rule of ARIA is not to use ARIA.

```blade
{{-- ❌ Not focusable, not activatable by keyboard, not announced as a control --}}
<div class="btn" wire:click="save">Save</div>

{{-- ✅ Focusable, Enter and Space work, announced as "Save, button" --}}
<button type="button" wire:click="save">Save</button>
```

| Instead of | Use | You get for free |
|---|---|---|
| `<div class="btn">` | `<button>` | Focus, Enter/Space, role, disabled state |
| `<div onclick>` navigating | `<a href>` | Focus, Enter, right-click, open in new tab |
| `<div class="heading">` | `<h1>`–`<h6>` | Screen reader heading navigation |
| `<div class="list">` | `<ul>` / `<ol>` / `<li>` | "List, 5 items" announced |
| Styled `<div>` grid | `<table>` with `<th scope>` | Row/column announcement while navigating cells |
| Custom checkbox `<div>` | `<input type="checkbox">` | State, keyboard, form submission |
| `<div>` sections | `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>` | Landmark navigation |

One `<h1>` per page. Heading levels descend without skipping — `<h2>` then `<h3>`, never
`<h2>` then `<h4>` because the size looked right. Size is CSS; level is structure.

---

## 2. Accessible Names

Every interactive control needs a name a screen reader can announce. An icon is not a name.

```blade
{{-- ❌ Announced as "button" --}}
<button wire:click="delete"><x-icon name="trash" /></button>

{{-- ✅ Announced as "Delete invoice, button" --}}
<button wire:click="delete" aria-label="Delete invoice">
    <x-icon name="trash" aria-hidden="true" />
</button>

{{-- ✅ Better — visible text, hidden only visually --}}
<button wire:click="delete">
    <x-icon name="trash" aria-hidden="true" />
    <span class="sr-only">Delete invoice</span>
</button>
```

- Decorative icons get `aria-hidden="true"` so they are not announced twice.
- `alt=""` on a decorative image; a real description on an informative one; for a chart or
  diagram, describe the *finding*, not the picture.
- Never `alt="image"`, `alt="icon"`, or the filename.
- Link text must make sense out of context — screen reader users list links. "Read more"
  five times on a page is five identical links. Use "Read the Q3 report" or an `aria-label`.

```blade
{{-- Utility class every project needs --}}
<style>
.sr-only {
    position: absolute; width: 1px; height: 1px;
    padding: 0; margin: -1px; overflow: hidden;
    clip: rect(0,0,0,0); white-space: nowrap; border: 0;
}
</style>
```

Tailwind ships `sr-only` and `not-sr-only` already — use those.

---

## 3. The Keyboard Walk

**Two minutes, and it catches more than any automated tool.** Put the mouse down and Tab
through the page.

| Check | Pass condition |
|---|---|
| Every control reachable | Tab reaches every button, link, input and custom control |
| Focus is visible | You can always see where you are, in both light and dark mode |
| Order is logical | Focus follows the visual reading order, not DOM accident |
| No trap | Tab always moves on; Escape closes any overlay |
| Enter and Space | Enter activates links and buttons; Space activates buttons and checkboxes |
| Escape | Closes modals, dropdowns and popovers, and returns focus |
| Arrow keys | Move within tabs, menus, radio groups and listboxes |
| Skip link | First Tab on the page offers "Skip to main content" |

```css
/* ❌ The single most common accessibility failure in a styled app */
*:focus { outline: none; }

/* ✅ Remove it for mouse users only, and give keyboard users something visible */
:focus-visible {
    outline: 2px solid var(--focus-color, #2563eb);
    outline-offset: 2px;
    border-radius: 2px;
}
```

The focus indicator needs 3:1 contrast against its background — check it in dark mode too.

```blade
{{-- First focusable element in the layout --}}
<a href="#main" class="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-50 focus:px-4 focus:py-2 focus:bg-white focus:text-black">
    Skip to main content
</a>
…
<main id="main" tabindex="-1">…</main>
```

Never use a positive `tabindex`. `tabindex="0"` puts a custom control in natural order;
`tabindex="-1"` makes an element focusable by script only. A positive value fights the
document and breaks the moment the layout changes.

---

## 4. Forms

```blade
{{-- ✅ Label associated, error announced, invalid state exposed --}}
<div>
    <label for="email">Email address</label>

    <input
        type="email"
        id="email"
        wire:model.blur="email"
        autocomplete="email"
        required
        aria-describedby="email-hint @error('email') email-error @enderror"
        @error('email') aria-invalid="true" @enderror
    >

    <p id="email-hint" class="text-sm text-gray-600">We only use this for receipts.</p>

    @error('email')
        <p id="email-error" role="alert" class="text-sm text-red-700">{{ $message }}</p>
    @enderror
</div>
```

| Rule | Why |
|---|---|
| Every input has a `<label for>` — or `aria-label` where no visible label exists | Placeholder is **not** a label: it disappears on typing and often fails contrast |
| Errors linked with `aria-describedby` and marked `aria-invalid` | Otherwise the input is announced with no indication it failed |
| `role="alert"` on the error message | Announces the error when it appears, without moving focus |
| Never colour alone for state | Add an icon, text, or a border change — see WCAG 1.4.1 |
| `autocomplete` on personal fields | WCAG 1.3.5, and it is a real convenience win |
| `required` and `aria-required` on mandatory fields | Announced before the user commits to typing |
| Fieldset + legend for radio and checkbox groups | Otherwise the group question is never announced |
| Error summary at the top on submit, focused | On a long form, per-field errors alone leave the user hunting |

Group inputs properly:

```blade
<fieldset>
    <legend>Delivery method</legend>
    <label><input type="radio" name="delivery" value="post" wire:model="delivery"> Post</label>
    <label><input type="radio" name="delivery" value="pickup" wire:model="delivery"> Pickup</label>
</fieldset>
```

---

## 5. Colour and Contrast

WCAG 2.1 AA minimums:

| Content | Ratio |
|---|---|
| Body text | 4.5:1 |
| Large text (18pt / 14pt bold and above) | 3:1 |
| UI components, icons, borders, focus rings | 3:1 |
| Disabled controls | Exempt, but still make them legible |

**Check both themes.** A palette tuned in light mode routinely fails in dark — grey-on-grey
secondary text is the usual casualty. Test with the actual rendered values, not the design
file.

```bash
# Quick check while iterating
npx @adobe/leonardo-contrast-colors --help
# Or the browser: devtools → inspect an element → the contrast ratio is in the colour picker
```

**Never encode meaning in colour alone** (WCAG 1.4.1). A red border on an invalid field is
invisible to a colourblind user and to a screen reader — add the message and the icon. A
status chart needs labels or patterns, not just hues.

Respect the user's system settings:

```css
@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
        scroll-behavior: auto !important;
    }
}
```

Also support 200% zoom and 320px width without horizontal scrolling (WCAG 1.4.10) — use
relative units and let content reflow rather than fixing pixel widths.

---

## 6. Livewire and Flux

Livewire's asynchronous updates are invisible to a screen reader unless you announce them,
and re-renders can throw focus away mid-task.

```blade
{{-- Announce async results without stealing focus --}}
<div aria-live="polite" aria-atomic="true" class="sr-only">
    @if($saved) Changes saved. @endif
    @if($results) {{ count($results) }} results found. @endif
</div>

{{-- Loading state announced, not just a spinner --}}
<div wire:loading role="status">
    <span class="sr-only">Loading results…</span>
    <x-spinner aria-hidden="true" />
</div>

{{-- Disable a control while its action is in flight --}}
<button wire:click="save" wire:loading.attr="disabled" wire:target="save">
    Save
</button>
```

| `aria-live` value | Use for |
|---|---|
| `polite` | Almost everything — search results, save confirmations, counts |
| `assertive` | Errors and time-critical warnings only. It interrupts |
| `off` | Default; the region is not announced |

Live-region rules that trip people up:

- The container must exist in the DOM **before** the content changes. A region added at the
  same moment as its text is often not announced at all.
- Keep it in the DOM across re-renders — give it a `wire:key` so Livewire does not replace the
  node.
- One or two live regions per page. More and they compete.

### Focus management

```blade
{{-- Preserve focus across a re-render --}}
<input type="search" wire:model.live.debounce.400ms="query" wire:key="search-input">
```

- Give inputs a stable `wire:key` so Livewire patches rather than replaces them — a replaced
  node loses focus and the caret position mid-typing.
- When a modal opens, move focus into it; when it closes, return focus to the trigger.
- After deleting a row, move focus somewhere sensible (the next row, or the table heading) —
  never leave it on a removed element, which drops focus to `<body>`.

### Flux components

Flux UI handles roles, `aria-expanded`, focus trapping and Escape for its primitives. Your
job is the part it cannot infer:

- An accessible name on every icon-only `flux:button`
- A `flux:field` + `flux:label` pairing for every input, not a bare `flux:input`
- A title on every `flux:modal` — it becomes the dialog's accessible name
- Error text wired through Flux's error slot so it is associated, not just rendered nearby

Verify rather than assume: Tab through the rendered component and read the DOM. A component
library gets you most of the way; it does not get you all of it.

---

## 7. Auditing

```bash
# Automated — catches roughly a third of issues
npx @axe-core/cli http://localhost:8000 --tags wcag2a,wcag2aa
npx pa11y http://localhost:8000 --standard WCAG2AA
npx lighthouse http://localhost:8000 --only-categories=accessibility
```

Then do what the tools cannot:

1. **Keyboard walk** — section 3, every page. Two minutes.
2. **Zoom to 200%** — does anything overlap, clip, or need horizontal scrolling?
3. **Screen reader spot check** — VoiceOver (`Cmd+F5` on macOS) or NVDA on Windows. Tab
   through one form and one data table and listen to what is announced.
4. **Dark mode contrast** — re-check every text and border colour.
5. **Disable CSS** — the page should still read as a sensible document. If it does not, the
   markup is not semantic.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The axe scan is clean, we're accessible" | Automated tools catch about a third of WCAG failures. They cannot judge focus order, a wrong accessible name, or whether the keyboard path makes sense. |
| "Our users don't use screen readers" | You do not know that, and you never will — it is not something users announce. Keyboard-only use is also common after an injury, on a trackpad-less desk, and among power users. |
| "I'll add ARIA to make it accessible" | ARIA changes what is announced, never what works. `role="button"` on a `<div>` still does not respond to Space or receive focus. Use `<button>`. |
| "The placeholder says what the field is" | Placeholders vanish on the first keystroke, usually fail contrast, and are not reliably announced. It is not a label. |
| "We'll do accessibility in a later phase" | Retrofitting means rewriting components. Written in, it costs nothing; bolted on, it costs a sprint. |
| "The focus ring ruins the design" | Then design a better one. `outline: none` with no replacement makes the interface unusable for keyboard users — that is a bigger design failure. |
| "Red text is obviously an error" | Not to a colourblind user, and not to a screen reader. Colour is an enhancement, never the only signal. |
| "Flux handles accessibility for us" | Flux handles the primitives. It cannot supply an accessible name for your icon button or decide your focus order. Verify. |
| "It's an internal admin tool" | Staff have disabilities, and internal tools are exactly where people spend eight hours a day. |
| "The div works fine when I click it" | You are testing with a mouse. The failure is only visible when you put it down. |

---

## Red Flags

- `outline: none` or `*:focus { outline: none }` with no `:focus-visible` replacement
- `<div>` or `<span>` with `wire:click`, `onclick`, or a `.btn` class
- An icon-only button with no `aria-label` and no `sr-only` text
- `<input>` with only a `placeholder` and no `<label>`
- Error messages that are red text and nothing else
- A positive `tabindex` value
- Heading levels skipped, or several `<h1>`s on one page
- `alt="image"`, `alt="icon"`, `alt="photo"`, or an alt that is a filename
- A modal that does not trap focus, or does not return it on close
- `aria-live` added at the same moment as the content it should announce
- Livewire inputs without `wire:key`, losing focus mid-typing
- Contrast checked in light mode only
- Fixed pixel widths that break at 200% zoom
- Animation with no `prefers-reduced-motion` guard
- Touch targets under 24×24px (WCAG 2.5.8), or under 44×44px on primary mobile actions
- Any control reachable by mouse but not by Tab

---

## Verification

- [ ] Every interactive element is reachable by Tab, in a logical order
- [ ] Focus is clearly visible on every control, in **both** light and dark mode
- [ ] Escape closes every overlay and returns focus to what opened it
- [ ] No keyboard trap anywhere — Tab always moves on
- [ ] A skip link is the first focusable element and it works
- [ ] Every input has an associated label; no placeholder used as one
- [ ] Every error is linked with `aria-describedby`, marked `aria-invalid`, and announced
- [ ] Every icon-only control has an accessible name; decorative icons are `aria-hidden`
- [ ] Text meets 4.5:1 and UI components 3:1, verified in both themes
- [ ] No information conveyed by colour alone
- [ ] Headings form a single, unskipped outline with exactly one `<h1>`
- [ ] Async Livewire updates announce through a live region that pre-exists the change
- [ ] Livewire inputs carry a `wire:key` and keep focus across re-renders
- [ ] `prefers-reduced-motion` is respected
- [ ] The page works at 200% zoom and 320px wide with no horizontal scroll
- [ ] `npx @axe-core/cli --tags wcag2a,wcag2aa` reports no violations
- [ ] The keyboard walk was actually performed, not assumed — say so in the report

---

## Reference Files

| File | Read When |
|---|---|
| `references/wcag-checklist.md` | Running a full WCAG 2.1 AA audit — criterion by criterion, with the check for each |
| `references/flux-accessibility.md` | Building or fixing Livewire/Flux components — patterns for modals, dropdowns, tables, tabs and toasts |
