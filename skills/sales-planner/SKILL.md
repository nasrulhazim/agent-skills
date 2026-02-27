---
name: sales-planner
metadata:
  compatible_agents: [claude-code]
  tags: [sales, pricing, quotation, marketing, financial-planning, proposal]
description: >
  Product pricing, sales, quotation, marketing copy, and financial planning assistant for
  developers and solo founders. Use this skill whenever the user wants to figure out how to
  price their product or service, generate a quotation, calculate partner/reseller margins,
  plan revenue targets, write marketing copy or elevator pitches, or build a product pricing
  config. Triggers for requests like "how much should I charge", "help me price my SaaS",
  "generate a quotation for a government project", "what should my reseller margin be",
  "write a tagline for my product", "how many sales do I need to hit RM X", "build a pricing
  framework for my product", or "help me with my sales strategy". Works with or without an
  existing product-config.md — if none exists, interviews the user first to build one.
  Compatible with the nasrulhazim/claude-sales Claude Code slash command file structure.
---

# Sales Planner

Pricing strategy, partner channel design, quotation generation, marketing copy, and financial
planning — structured around a `product-config.md` that serves as the single source of truth
for all your product's commercial details.

## How It Works

1. **With a product-config.md** — user pastes or uploads their config → generate outputs directly
2. **Without a config** — interview the user → generate a populated `product-config.md` first,
   then proceed to the requested output

Always check if a config exists before asking questions. If the user pastes pricing details
inline, extract and structure them rather than asking redundant questions.

---

## Command Reference

| Command / Request | Description |
|---|---|
| `get-pricing license` | Base product price breakdown |
| `get-pricing via reseller` | Price + margin calculation for reseller channel |
| `get-pricing via affiliate` | Price + affiliate margin |
| `get-pricing via referrer` | Price + referrer commission |
| `get-pricing government` | Government/public sector pricing package |
| `get-quotation enterprise` | Full enterprise quotation document |
| `get-quotation government` | Government project quotation with line items |
| `get-quotation sme` | SME-friendly quotation |
| `get-marketing taglines` | 5–10 tagline options |
| `get-marketing elevator pitch` | 30-second verbal pitch |
| `get-marketing social casual` | Social media post (casual tone) |
| `get-marketing social formal` | Social media post (formal/corporate tone) |
| `get-marketing social malay` | Social media post in Bahasa Malaysia |
| `get-financial plan` | Revenue scenario planning |
| `get-financial breakeven` | Break-even analysis |
| `get-proposal` | Full client-facing project proposal (scope, timeline, deliverables, pricing) |
| `setup-config` | Interview → generate product-config.md |

---

## 1. Setup — Interview to Build product-config.md

When no config exists, run this interview **in two blocks**:

### Block 1 — Product Identity

- What is your product name?
- One sentence: what does it do and who is it for?
- Is it SaaS (subscription), on-premise (license), service, or hybrid?
- What currency do you work in? (default: MYR)

### Block 2 — Pricing & Channels

- What is the base price? (one-time or monthly/annual)
- What's included in the base price?
- Do you have add-ons or optional extras? List them with approximate prices.
- Do you sell through partners? (resellers, affiliates, referrers?)
- Do you sell to government or enterprise? If yes, what does a full project look like?

After both blocks: generate `product-config.md` using the template in
`references/product-config-template.md`. Present it and confirm before proceeding to
any pricing/quotation/marketing outputs.

---

## 2. get-pricing

Read the product-config.md. Calculate and present pricing for the requested channel.

### Direct / License Pricing

Show:
- Base price with all inclusions listed
- Optional add-ons as a menu with prices
- Total range (base only vs base + all add-ons)
- Recommended starting package for a new customer

### Partner Channel Pricing

For each channel, apply the margin from config and show:

```
Base Price:        RM 25,000
Reseller Margin:   30%  (RM 7,500)
Partner Price:     RM 17,500   ← what partner pays you
Customer Price:    RM 25,000   ← what customer pays partner
Partner Earns:     RM 7,500
```

Always show both what the partner pays you and what they earn. Never assume the partner
passes the full discount to the customer.

### Government / Public Sector Pricing

Present the full government package breakdown as a structured table:

```
Component                    Price (MYR)
─────────────────────────────────────────
Requirement Study              15,000
Product License                40,000
Integration Services           30,000
Customisation                  20,000
Training (3 days)              15,000
─────────────────────────────────────────
Subtotal                      120,000
SST (8%)                        9,600
─────────────────────────────────────────
Total                         129,600
```

Include annual maintenance/support pricing if defined in config.

### Hourly / Retainer Pricing

For service-based or consulting engagements:

```
Hourly Rate:          RM 250/hour
Day Rate (8h):        RM 2,000/day
Monthly Retainer:     RM 8,000/month (includes 40 hours)
Overage Rate:         RM 250/hour (billed at end of month)
```

Show:
- Recommended rate based on target annual income and utilisation rate
- Retainer vs hourly comparison (break-even at X hours/month)
- Partner channel rates (apply same margin structure)

---

## 3. get-quotation

Generate a professional quotation document as a Markdown file ready to convert to PDF.

### Quotation Structure

```
QUOTATION
─────────────────────────────────────────────
Quotation No:   Q-[YYYY]-[NNN]
Date:           [Date]
Valid Until:    [Date + 30 days]

Prepared For:
  [Client Name]
  [Client Organisation]
  [Client Address]

Prepared By:
  [Your Name / Company]
  [Contact]

─────────────────────────────────────────────
SCOPE OF WORK

[Brief description of what is being quoted]

─────────────────────────────────────────────
PRICING BREAKDOWN

No.  Item                          Qty  Unit Price   Total
───  ────────────────────────────  ───  ──────────   ──────
1.   [Item]                         1   RM xx,xxx   RM xx,xxx
2.   [Item]                         1   RM xx,xxx   RM xx,xxx
...
                                         Subtotal:  RM xx,xxx
                                         SST (8%):  RM xx,xxx
                                            Total:  RM xx,xxx

─────────────────────────────────────────────
TERMS & CONDITIONS

Payment Terms:  [e.g., 50% upfront, 50% on delivery]
Delivery:       [Timeline]
Support:        [Included support period]
Validity:       This quotation is valid for 30 days.

─────────────────────────────────────────────
AUTHORISED BY

[Signature line]
[Name, Title]
[Date]
```

Ask for client name/organisation before generating if not provided. Use sequential
quotation numbers formatted as `Q-2026-001`.

---

## 4. get-marketing

Generate marketing copy using the product name, tagline, target audience, and value
proposition from product-config.md.

### Taglines

Generate 8–10 options across different angles:
- Outcome-focused ("Ship faster, break nothing")
- Problem-focused ("No more guessing your API limits")
- Audience-focused ("Built for Laravel teams who care")
- Bold/provocative ("Your competitors are already monitoring. Are you?")
- Simple/direct ("API monitoring for Laravel. Nothing more.")

### Elevator Pitch (30 seconds)

Structure: Problem → Solution → Proof → Call to action

```
[Product] solves [problem] for [audience]. Unlike [alternative],
we [key differentiator]. [Social proof or traction if available].
[Call to action].
```

### Social Media Posts

**Casual (English):**
Conversational tone, 1–3 short paragraphs, relevant emoji, hashtags at end.

**Formal/Corporate (English):**
Professional tone, no emoji, full sentences, suitable for LinkedIn.

**Bahasa Malaysia (Casual):**
Natural code-switching is fine — Malaysian devs and founders mix BM/English naturally.
Use "korang", "nak", "boleh", "bro" where appropriate. Not stiff, not formal.
Example register: "Korang dah try [Product] belum? Serius senang gila nak setup..."

---

## 5. get-financial

Financial scenario planning based on pricing config.

### Revenue Plan

Ask: "What is your revenue target and timeframe?" If not given, use RM 300,000 / year.

Generate three scenarios:

**Scenario A — Direct Sales Only**
```
Target:         RM 300,000
License Price:  RM 25,000
Sales Needed:   12 direct sales (1/month)
```

**Scenario B — Mixed Channel**
```
Direct (50%):     6 sales × RM 25,000 = RM 150,000
Reseller (50%):   6 sales × RM 17,500 = RM 105,000
Gap to target:    RM 45,000
Extra needed:     2 more reseller sales
```

**Scenario C — Government / Enterprise Heavy**
```
2 gov projects × RM 129,600      = RM 259,200
Year 2 maintenance × 2 × RM 5k  = RM 10,000
Subtotal:                          RM 269,200
Direct to fill gap:                1 more direct sale
```

Always show the math explicitly — not just the result. The reasoning is the value.

### Break-Even Analysis

Ask for monthly fixed costs (hosting, tools, salary/draw, etc.).

```
Monthly Fixed Costs:   RM 5,000
Contribution Margin:   RM 25,000 (direct) or RM 17,500 (reseller)

Break-even (direct):   1 sale per 5 months
Break-even (reseller): 1 sale per 3.5 months
Annual break-even:     3 direct sales OR 4 reseller sales
```

---

## 6. get-proposal

Generate a client-facing project proposal pulling from product-config.md.

### Interview (if needed)

If client details not provided, ask:
- Client name and organisation
- Project scope (one paragraph)
- Expected timeline
- Any special requirements or compliance needs

### Proposal Structure

```
PROJECT PROPOSAL
─────────────────────────────────────────────
Prepared For:   [Client Name / Organisation]
Prepared By:    [Your Company]
Date:           [Date]
Reference:      P-[YYYY]-[NNN]

─────────────────────────────────────────────
EXECUTIVE SUMMARY

[1–2 paragraphs: problem, solution, why us]

─────────────────────────────────────────────
SCOPE OF WORK

Phase 1: [Phase name]
  - [Deliverable]
  - [Deliverable]

Phase 2: [Phase name]
  - [Deliverable]

─────────────────────────────────────────────
TIMELINE

Phase 1:  Week 1–4
Phase 2:  Week 5–8
UAT:      Week 9–10
Go-live:  Week 11

─────────────────────────────────────────────
INVESTMENT

[Pricing table from product-config.md]

─────────────────────────────────────────────
TERMS & CONDITIONS

[Standard terms]
─────────────────────────────────────────────
```

For Malaysian government proposals, support bilingual (BM/EN) output.
Output: `proposal-[client]-[date].md`

---

## Partner Channel Guide

Standard margins from the claude-sales framework. Use as defaults if not in config:

| Channel | Margin | Role |
|---|---|---|
| Referrer | 10% | Introduces a lead only, no sales involvement |
| Affiliate | 20% | Markets the product, qualifies leads |
| Reseller | 30% | Manages full sales cycle end-to-end |
| Fronting | 15% | Handles project management and finance only |

When explaining channels to the user, frame it this way: the more work the partner does,
the higher their margin. Referrers do the least → lowest margin. Resellers carry the full
sales burden → highest margin.

---

## Output Files

When generating documents, save with these names:

| Output | Filename |
|---|---|
| Product config | `product-config.md` |
| Pricing sheet | `pricing-[channel].md` |
| Quotation | `quotation-[client]-[date].md` |
| Marketing copy | `marketing-[type].md` |
| Financial plan | `financial-plan.md` |
| Proposal | `proposal-[client]-[date].md` |

All files are Markdown. Present them via `present_files` so the user can download.

---

## Reference Files

| File | Read When |
|---|---|
| `references/product-config-template.md` | Setting up a new product config, or showing the user the config schema |
| `references/pricing-patterns.md` | Complex pricing scenarios, government project structures, financial modelling |
