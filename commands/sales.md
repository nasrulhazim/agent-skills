---
name: sales
description: All-in-one sales command - generate config, pricing, marketing, and quotation in one go
---

# /sales Command

All-in-one sales command that runs the full suite: config setup, pricing, marketing, and quotation generation.

## Usage

```text
/sales
/sales [customer-type]
/sales [customer-type] via [channel]
```

## Workflow

```mermaid
flowchart TD
    A["/sales command"] --> B{product-config.md exists?}
    B -- Yes --> C[Read config]
    B -- No --> D["Run /sales-create-config flow"]
    D --> C
    C --> E[Determine parameters]
    E --> F[Generate Pricing]
    F --> G["Write docs/sales-kit/pricing.md"]
    G --> H[Generate Marketing]
    H --> I["Write docs/sales-kit/marketing.md"]
    I --> J[Generate Quotation]
    J --> K["Write docs/sales-kit/quotation.md"]
    K --> L["Write docs/sales-kit/README.md"]
    L --> M[Display summary confirmation]
```

## Behavior

### Step 1 — Ensure Product Config Exists

1. Look for `product-config.md` in the current project directory.
2. If it exists, read it and proceed to Step 2.
3. If it does NOT exist, run the `/sales-create-config` flow:
   - Load `~/.claude/product-config-template.md` as structural reference
   - Gather product information interactively (same rounds as `/sales-create-config`)
   - Generate `product-config.md` in the project root
   - Then proceed to Step 2

### Step 2 — Determine Parameters

Parse the user's input to determine:

- **Customer type**: `sme`, `enterprise`, `government`, or general (default: show all available types from config)
- **Channel**: `referrer`, `affiliate`, `reseller`, `fronting`, or direct (default: direct + partner comparison)
- **Marketing style**: defaults to generating all key types (taglines, elevator pitch, one social post)

If no arguments are provided, use sensible defaults:

- Customer type: generate for the primary/default package in the config
- Channel: direct pricing + partner comparison table
- Marketing: taglines + elevator pitch + one social media post (professional style)

### Step 3 — Generate Pricing

Using the logic from `/sales-get-pricing`, generate:

1. **Base/license pricing** — always shown
2. **Package pricing** — for the specified customer type, or the default package
3. **Partner comparison table** — if channel specified, show that channel; otherwise show the full comparison table
4. **Add-ons list** — available add-ons with prices

Format output exactly as `/sales-get-pricing` does, using box-drawing characters and structured tables.

**Write to `docs/sales-kit/pricing.md`.**

### Step 4 — Generate Marketing Content

Using the logic from `/sales-get-marketing`, generate:

1. **Taglines** — primary + alternatives
2. **Elevator pitch** — 30-second pitch
3. **One social media post** — professional style by default, or casual if user specifies

Format output exactly as `/sales-get-marketing` does.

**Write to `docs/sales-kit/marketing.md`.**

### Step 5 — Generate Quotation

Using the logic from `/sales-get-quotation`, generate:

1. **Quotation** — for the specified customer type, or the default package
2. Include line items, totals, optional add-ons, terms, and notes

Format output exactly as `/sales-get-quotation` does.

**Write to `docs/sales-kit/quotation.md`.**

### Step 6 — Generate README & Summary

After all sections are generated, create directory `docs/sales-kit/` if it doesn't exist.

Write a `docs/sales-kit/README.md` index file:

```markdown
# Sales Kit: [Product Name]

Generated: YYYY-MM-DD

## Contents

| File | Description |
|------|-------------|
| [pricing.md](pricing.md) | Pricing breakdown |
| [marketing.md](marketing.md) | Marketing content |
| [quotation.md](quotation.md) | Quotation template |

---
Generated using Claude Sales Kit
```

Then display a brief confirmation listing all files written:

```text
SALES KIT COMPLETE
---

Files saved to docs/sales-kit/:
  • pricing.md        — base, packages, partner channels
  • marketing.md      — taglines, pitch, social post
  • quotation.md      — [customer-type] package breakdown
  • README.md         — index of all generated files

Need more detail? Run individual commands:
  /sales-get-pricing [scenario]
  /sales-get-marketing [type] [style]
  /sales-get-quotation [customer-type]
  /sales-create-config              (recreate config)
```

## Output Structure

Each section is written to a separate file in `docs/sales-kit/`. Terminal output is minimal — just a confirmation with file paths.

### File Output Format

Each output file is a proper Markdown document with:

- A `# Title` header at the top
- `Generated: YYYY-MM-DD` date stamp
- `Product: [Product Name]` reference
- The formatted content (box-drawing tables, sections, etc.) wrapped in code blocks for proper rendering

### Generated Files

```text
docs/sales-kit/
├── README.md         ← Index of all generated files
├── pricing.md        ← Pricing output
├── marketing.md      ← Marketing output
└── quotation.md      ← Quotation output
```

### Terminal Output

Only the summary confirmation is displayed in the terminal:

```text
SALES KIT COMPLETE
---

Files saved to docs/sales-kit/:
  • pricing.md        — base, packages, partner channels
  • marketing.md      — taglines, pitch, social post
  • quotation.md      — [customer-type] package breakdown
  • README.md         — index of all generated files
```

## Scenario Patterns

### No arguments (full default kit)

- `/sales` → Check/create config, then generate everything with defaults

### With customer type

- `/sales sme` → Kit scoped to SME package
- `/sales enterprise` → Kit scoped to enterprise package
- `/sales government` → Kit scoped to government package

### With channel

- `/sales sme via reseller` → SME kit with reseller pricing
- `/sales enterprise via affiliate` → Enterprise kit with affiliate pricing

### Quick modes

- `/sales pricing` → Only pricing section (shortcut for `/sales-get-pricing`)
- `/sales marketing` → Only marketing section (shortcut for `/sales-get-marketing`)
- `/sales quotation` → Only quotation section (shortcut for `/sales-get-quotation`)

## Configuration Reference

This command reads from the same `product-config.md` and `~/.claude/sales-reference.md` as the individual commands. All configuration keys are identical — see `/sales-get-pricing`, `/sales-get-marketing`, and `/sales-get-quotation` for details.

## Rules

- Always check for `product-config.md` first. Never skip config validation.
- Read `~/.claude/sales-reference.md` for pricing formulas, response patterns, and formatting standards.
- Use the same output formatting (box-drawing characters, table styles) as the individual commands.
- Never invent product details. Only use information from the config file.
- If the config is missing sections needed for a particular output (e.g., no marketing content defined), skip that section and note it in the summary.
- Keep each section's output identical to what the individual command would produce — this command is a runner, not a reimplementation.

## Examples

**User**: `/sales`

**Response**: Checks for config (creates if missing), then generates full kit with default customer type, direct + partner comparison pricing, taglines + pitch + professional social post, and default quotation.

**User**: `/sales enterprise`

**Response**: Full kit scoped to enterprise — enterprise pricing, marketing content, and enterprise quotation.

**User**: `/sales sme via reseller`

**Response**: SME kit with reseller channel pricing highlighted, SME marketing content, and SME quotation with reseller pricing noted.
