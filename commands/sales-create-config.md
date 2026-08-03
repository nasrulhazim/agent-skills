---
name: sales-create-config
description: Create a product-config.md file interactively for use with sales commands
---

# /sales-create-config Command

Interactively create a `product-config.md` file in the current project directory.

## Usage

```
/sales-create-config
/sales-create-config [product name]
```

## Behavior

1. **Check for existing config**: Look for `product-config.md` in the current project directory. If it exists, ask the user whether to overwrite or abort.

2. **Read the template**: Load `~/.claude/product-config-template.md` as the structural reference for all sections.

3. **Gather information interactively**: Ask the user for their product details in the following order. Group related questions together to minimize back-and-forth. If a product name was provided as an argument, skip asking for it.

   **Round 1 — Core Identity**
   - Product name
   - Company name
   - Tagline
   - Website
   - Currency (default: MYR)
   - Business model: on-premise, saas, hybrid, or service

   **Round 2 — Product Details**
   - Short description (one paragraph, under 50 words)
   - Target market (primary and secondary segments)
   - Ideal customer characteristics
   - Core features (name + brief description for each)

   **Round 3 — Pricing**
   - Base price and unit (one-time, monthly, yearly, per-user)
   - What's included in the base price
   - Add-ons (name, price or price range, description)
   - Maintenance/support pricing (yearly fee, percentage, when it starts)
   - Minimum Advertised Price (MAP) if applicable

   **Round 4 — Partner Channels**
   - Ask if they use partner channels
   - If yes, confirm or customize default margins: referrer (10%), affiliate (20%), reseller (30%), fronting (15%)
   - Customize roles and responsibilities per channel if needed

   **Round 5 — Packages / Bundles**
   - Ask if they offer predefined packages
   - If yes, for each package: name, target customer, components with prices, total, optional add-ons

   **Round 6 — Marketing Content**
   - Primary tagline and alternatives
   - Elevator pitch (30-second, ~50-75 words)
   - Social media posts (offer to generate based on product details if user prefers)
   - Value proposition and ROI calculation inputs

   **Round 7 — FAQ & Quotation**
   - Common FAQs with answers and tags
   - Quotation defaults: validity period, payment terms, notes

   **Round 8 — Contact Information**
   - Email, phone, website, company name

4. **Generate the file**: Create `product-config.md` in the current project directory using the same Markdown + YAML structure as the template. Fill in all user-provided values. For any section the user skipped, omit it entirely rather than leaving placeholders.

5. **Confirm creation**: Show the user a summary of what was created and remind them of available commands:
   - `/sales-get-pricing [scenario]`
   - `/sales-get-marketing [type]`
   - `/sales-get-quotation [customer-type]`

## Rules

- Never invent product details. Only use information the user provides.
- If the user says "skip" for any section, omit that section from the output file.
- Use the exact same YAML key names and Markdown structure as `product-config-template.md` so other commands can parse it.
- Format all prices as plain numbers without currency symbols or commas in the YAML values.
- Keep the conversational tone concise — ask what's needed, don't over-explain each field.
- If the user provides partial information (e.g., only base price and features), generate the file with just those sections and let them know they can re-run or manually edit later.

## Output

The command produces a `product-config.md` file in the current project root, structured identically to the template at `~/.claude/product-config-template.md` but populated with the user's actual data.
