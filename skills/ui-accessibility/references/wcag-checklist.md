# WCAG 2.1 AA Checklist

Organised by principle. Each row is a criterion, what it means in a Laravel/Blade app, and
how to check it. Criteria marked **★** are the ones that fail most often in practice.

---

## 1. Perceivable

| Criterion | In practice | How to check |
|---|---|---|
| **1.1.1** Non-text Content **★** | Every image, icon and chart has a text alternative; decorative ones have `alt=""` or `aria-hidden` | `grep -rn "<img" resources/views/ \| grep -v "alt="` |
| **1.2.x** Time-based Media | Captions on video, transcript on audio | Manual |
| **1.3.1** Info and Relationships **★** | Structure is in the markup: headings, lists, `<th scope>`, `<fieldset>`/`<legend>`, `<label for>` | Disable CSS — does it still read as a document? |
| **1.3.2** Meaningful Sequence | DOM order matches reading order | Tab through; disable CSS |
| **1.3.3** Sensory Characteristics | No "click the button on the right" or "the green one" | Read the copy |
| **1.3.4** Orientation | Works in portrait and landscape | Rotate a device |
| **1.3.5** Identify Input Purpose | `autocomplete` on name, email, tel, address, cc fields | `grep -rn "type=\"email\"" resources/views/ \| grep -v autocomplete` |
| **1.4.1** Use of Colour **★** | Colour is never the only signal — errors, statuses, chart series | Grayscale the screenshot; is it still readable? |
| **1.4.3** Contrast (Minimum) **★** | 4.5:1 body text, 3:1 large text — **in both themes** | Devtools colour picker; axe |
| **1.4.4** Resize Text | Readable at 200% with no loss of content | Browser zoom to 200% |
| **1.4.5** Images of Text | Use real text, not text baked into an image | Visual scan |
| **1.4.10** Reflow **★** | No horizontal scroll at 320px wide | Devtools responsive mode at 320px |
| **1.4.11** Non-text Contrast **★** | 3:1 for borders, icons, focus rings, form outlines | Devtools; check the focus ring specifically |
| **1.4.12** Text Spacing | Survives increased line height and letter spacing | Apply the WCAG text-spacing bookmarklet |
| **1.4.13** Content on Hover/Focus | Tooltips dismissible, hoverable, and persistent | Hover a tooltip, then move onto it |

---

## 2. Operable

| Criterion | In practice | How to check |
|---|---|---|
| **2.1.1** Keyboard **★** | Every function available from the keyboard | The keyboard walk |
| **2.1.2** No Keyboard Trap **★** | Tab always moves on; Escape exits overlays | Tab through a modal |
| **2.1.4** Character Key Shortcuts | Single-key shortcuts can be turned off or remapped | Check for global key listeners |
| **2.2.1** Timing Adjustable | Session and form timeouts can be extended | Check auth and any countdown |
| **2.2.2** Pause, Stop, Hide | Auto-playing or moving content can be paused | Carousels, marquees, auto-refresh tables |
| **2.3.1** Three Flashes | Nothing flashes more than 3×/second | Visual scan |
| **2.4.1** Bypass Blocks **★** | A skip link, or landmark regions | Press Tab once on page load |
| **2.4.2** Page Titled | Unique, descriptive `<title>` per page | View the browser tab on each route |
| **2.4.3** Focus Order **★** | Focus follows the visual reading order | Tab and watch |
| **2.4.4** Link Purpose | Link text makes sense out of context | List the links — any bare "read more"? |
| **2.4.5** Multiple Ways | Nav plus search, sitemap or breadcrumbs | Site structure review |
| **2.4.6** Headings and Labels | Descriptive, not generic | Read them aloud |
| **2.4.7** Focus Visible **★** | The focus indicator is always visible | `grep -rn "outline: *none" resources/ ` |
| **2.5.1** Pointer Gestures | Multi-point or path gestures have a single-pointer alternative | Drag-and-drop, swipe-to-delete |
| **2.5.2** Pointer Cancellation | Actions fire on `up`, not `down` | Press and drag off a button |
| **2.5.3** Label in Name | The visible label is contained in the accessible name | Compare `aria-label` to the visible text |
| **2.5.4** Motion Actuation | Shake/tilt features have a UI alternative | Rare in web apps |
| **2.5.8** Target Size (AA, 2.2) | 24×24px minimum; 44×44 for primary mobile actions | Measure icon buttons and table row actions |

---

## 3. Understandable

| Criterion | In practice | How to check |
|---|---|---|
| **3.1.1** Language of Page | `<html lang="en">` — and `lang="ms"` where the content is Malay | View source |
| **3.1.2** Language of Parts | `lang` on any inline foreign-language passage | Mixed-language pages |
| **3.2.1** On Focus | Focusing something never changes context | Tab through a form |
| **3.2.2** On Input | Changing a value never auto-submits or navigates unannounced | Change a `<select>` |
| **3.2.3** Consistent Navigation | Nav is in the same place on every page | Compare routes |
| **3.2.4** Consistent Identification | The same function is labelled the same way throughout | Compare "Delete"/"Remove"/"Trash" usage |
| **3.3.1** Error Identification **★** | Errors are identified in text, not colour alone | Submit an invalid form |
| **3.3.2** Labels or Instructions **★** | Every input has a label; formats are explained before they are needed | Review each form |
| **3.3.3** Error Suggestion | The message says how to fix it, not just that it is wrong | Read the validation messages |
| **3.3.4** Error Prevention | Confirmation, reversal or review for legal, financial and data-deletion actions | Destructive flows |

---

## 4. Robust

| Criterion | In practice | How to check |
|---|---|---|
| **4.1.2** Name, Role, Value **★** | Every control has an accessible name and exposes its state | axe; inspect the accessibility tree |
| **4.1.3** Status Messages **★** | Async status announced via `aria-live` or `role="status"` / `role="alert"` | Trigger a Livewire save and listen |

---

## Fast Audit Greps

```bash
# Images without alt
grep -rn "<img" resources/views/ | grep -v "alt="

# Focus removed
grep -rn "outline: *none\|outline:none" resources/ tailwind.config.js

# Clickable non-buttons
grep -rn "wire:click\|@click\|onclick" resources/views/ | grep -E "<(div|span)"

# Inputs with placeholder but no label nearby
grep -rn "placeholder=" resources/views/ | head -30

# Positive tabindex
grep -rn 'tabindex="[1-9]' resources/views/

# Missing lang
grep -rn "<html" resources/views/ | grep -v "lang="

# Icon buttons with no accessible name
grep -rn "<button" resources/views/ -A2 | grep -B1 "x-icon\|<svg" | grep -v "aria-label\|sr-only"
```

---

## Severity for Reporting

| Severity | Meaning | Examples |
|---|---|---|
| **Blocker** | A user cannot complete the task at all | Keyboard trap; control unreachable by Tab; unlabelled required field |
| **Critical** | Task possible but seriously impaired | No visible focus; icon buttons with no name; errors announced only by colour |
| **Major** | Significant friction | Illogical focus order; missing skip link; contrast below 4.5:1 |
| **Minor** | Polish | Generic link text; missing `autocomplete`; heading level skipped |

Report each finding with the exact `file:line`, the criterion number, and the concrete fix —
never "improve accessibility here".

---

## Testing Tools

```bash
npx @axe-core/cli http://localhost:8000 --tags wcag2a,wcag2aa
npx pa11y http://localhost:8000 --standard WCAG2AA
npx lighthouse http://localhost:8000 --only-categories=accessibility --view
```

Screen readers: **VoiceOver** (macOS, `Cmd+F5`; rotor `Ctrl+Opt+U`), **NVDA** (Windows,
free), **TalkBack** (Android), **VoiceOver** (iOS).

Automated tools find roughly a third of failures. The keyboard walk, a 200% zoom pass and a
two-minute screen reader spot check find most of the rest.
