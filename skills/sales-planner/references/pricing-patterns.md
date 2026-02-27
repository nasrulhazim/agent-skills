# Pricing Patterns & Financial Modelling Reference

Reusable patterns for pricing calculations, scenario planning, and quotation logic.
Read this file when handling complex pricing requests or multi-scenario financial plans.

---

## Partner Channel Calculations

### Standard Formula

```
Partner pays you:    base_price × (1 - margin)
Customer pays:       base_price  (full price)
Partner earns:       base_price × margin
```

### Example: RM 25,000 base, 30% reseller margin

```
Partner pays you:    RM 25,000 × 0.70 = RM 17,500
Customer pays:       RM 25,000
Partner earns:       RM 25,000 × 0.30 = RM 7,500
```

### Multi-tier scenario (reseller has sub-reseller)

If your reseller uses a sub-reseller, their margin must cover the sub-reseller's cut.
This is their problem to manage, not yours — you always collect from the direct partner.
Flag this risk if the user asks about multi-tier channels.

### Fronting vs Reseller distinction

| | Fronting | Reseller |
|---|---|---|
| Sales effort | None | Full |
| Technical involvement | None | Varies |
| Finance handling | Yes | Yes |
| Typical margin | 10–15% | 25–35% |
| Use case | Gov. project where vendor can't contract directly | Standard channel sales |

Fronting is common in Malaysian government projects where the actual vendor can't hold
the contract directly (Bumiputera requirement, local incorporation requirement, etc.).

---

## Government Project Pricing Patterns

### Standard Malaysian Gov. Project Structure

Government projects in Malaysia typically follow this structure:

```
Phase 1: Requirement Study / Feasibility    (10–15% of total)
Phase 2: System / Product License           (25–35% of total)
Phase 3: Integration & Customisation        (20–30% of total)
Phase 4: Training & Knowledge Transfer      (8–12% of total)
Phase 5: UAT Support & Go-Live             (5–10% of total)
Phase 6: Warranty / Post-Implementation    (12 months, ~15–20% annual)
```

### Payment Milestone Template (Gov.)

Government projects pay in milestones, not upfront. Typical structure:

| Milestone | Trigger | % |
|---|---|---|
| M1 | Letter of Award / PO received | 30% |
| M2 | System delivered / UAT started | 30% |
| M3 | UAT passed / Go-live | 30% |
| M4 | End of warranty period | 10% |

Always build this into quotations for government clients.

### GST/SST Handling

Malaysian businesses must add SST (8% as of 2024) to taxable services.
- Software licenses: taxable
- Training: taxable
- Maintenance: taxable
- Hardware resale: different rate (check with accountant)

Always show SST as a separate line item. Never quote "inclusive of SST" without showing
the breakdown — government finance teams require line-item clarity.

---

## Revenue Scenario Planning

### Core Formula

```
Revenue = (direct_sales × base_price)
        + (reseller_sales × base_price × (1 - reseller_margin))
        + (gov_projects × gov_package_total)
        + (maintenance_renewals × base_price × maintenance_rate)
```

### Scenario Matrix Template

Generate this matrix when user asks for financial planning:

| Scenario | Direct | Reseller | Gov | Total |
|---|---|---|---|---|
| Conservative | 3 | 2 | 0 | RM xxx |
| Realistic | 6 | 4 | 1 | RM xxx |
| Optimistic | 10 | 8 | 2 | RM xxx |

For each scenario, show:
1. Raw revenue number
2. Net revenue after partner margins
3. Whether it hits the user's stated target
4. Number of sales per month implied

### Recurring Revenue Projection (Year 2+)

Once customers exist, maintenance renewals create baseline revenue:

```
Year 1:  N new sales
Year 2:  N_prev × renewal_rate (% who renew) × maintenance_fee
         + new sales

Typical renewal rate for well-supported software: 70–85%
```

If the user has been selling for > 1 year, always factor in renewal revenue —
it's often ignored by developers doing financial planning.

---

## Break-Even Analysis

### Formula

```
break_even_units = monthly_fixed_costs / contribution_margin_per_unit

contribution_margin (direct)   = base_price - variable_costs_per_sale
contribution_margin (reseller) = (base_price × (1 - margin)) - variable_costs_per_sale

variable_costs_per_sale: support time, deployment effort, onboarding
  → Estimate as hours × hourly_rate if user can provide
  → Default: assume 0 for digital products if no estimate given
```

### Annual Break-Even

```
annual_fixed_costs = monthly_fixed_costs × 12
break_even_annual  = annual_fixed_costs / avg_contribution_margin
```

### Payback Period for Dev Investment

If the user spent time building the product:

```
dev_cost = dev_hours × opportunity_cost_per_hour
payback  = dev_cost / monthly_net_revenue
```

Useful for validating whether the product makes sense to continue investing in.

---

## SaaS-Specific Pricing Patterns

If product_type is "saas", use these additional patterns:

### Monthly Recurring Revenue (MRR)

```
MRR = (subscribers × monthly_fee) + (add_on_subscribers × add_on_fee)
ARR = MRR × 12
```

### Churn Impact

```
net_mrr_growth = new_mrr - churned_mrr
churn_rate     = churned_customers / total_customers_start_of_month

At 5% monthly churn: half your customers leave every ~14 months
At 1% monthly churn: half your customers leave every ~69 months

Flag this to the user if they have a SaaS product and ask about long-term revenue.
```

### Tiered SaaS Pricing (if applicable)

Common Malaysian SaaS tier pattern:

| Tier | Price/mo | Users | Features |
|---|---|---|---|
| Starter | RM 99 | Up to 5 | Core only |
| Growth | RM 299 | Up to 25 | Core + analytics |
| Business | RM 699 | Up to 100 | Full features |
| Enterprise | Custom | Unlimited | Full + SLA + dedicated support |

---

## Marketing Copy Guidelines

### Tone by Audience

| Audience | Tone | Language | Avoid |
|---|---|---|---|
| Malaysian SME owner | Warm, practical, ROI-focused | BM/EN mixed OK | Jargon, overly technical |
| Enterprise IT manager | Professional, risk-aware | Formal English | Casual language |
| Government | Formal, compliance-aware | Formal BM or EN | Casual, startup language |
| Developer community | Direct, peer-to-peer | Technical EN | Marketing fluff |
| LinkedIn (general) | Thoughtful, story-driven | English | Hard sell |

### Bahasa Malaysia Register Guide

For Malaysian SME and developer audiences, natural BM/EN code-switching is correct.
Do not write stiff formal BM — it reads as unnatural to the target audience.

**Good:** "Korang dah spent berapa jam sebulan troubleshoot API issues? [Product] bagi
korang visibility yang korang perlukan dalam 10 minit je setup."

**Avoid:** "Adakah anda menghabiskan masa yang panjang untuk menyelesaikan masalah API?"
(Too formal, reads like a government circular)

Common natural code-switches:
- "senang gila" not "sangat mudah"
- "korang" not "anda sekalian"
- "bro/sis" for peer contexts
- "setup", "deploy", "monitor" — keep English for tech terms
- "nak", "boleh", "dah" — natural BM filler words

### Elevator Pitch Formula

```
[Product] helps [specific audience] [achieve outcome / avoid pain]
without [the thing they hate about alternatives].

[One proof point: number, customer, or traction.]

[Clear next step: try it, book a demo, see pricing.]
```

Keep it under 60 words for written form. Under 90 seconds spoken.

---

## Quotation Numbering

Auto-increment format: `[prefix]-[YYYY]-[NNN]`

Examples: `Q-2026-001`, `Q-2026-002`

If user has existing quotations, ask for the last number to continue the sequence.
If unknown, start at `Q-2026-001` and note it should be reconciled with their records.

---

## Common Mistakes to Flag

When reviewing a user's existing pricing, flag these if spotted:

1. **No add-ons defined** — single-price products leave money on the table
2. **No partner margins defined** — ad-hoc partner discussions always go poorly
3. **No government package** — Malaysian gov. projects need itemised quotes
4. **Pricing in round numbers only** — RM 10,000 looks guessed; RM 9,800 looks calculated
5. **No maintenance/renewal pricing** — Year 2 revenue is often ignored completely
6. **SaaS with no churn assumption** — optimistic projections without churn are misleading
7. **No payment milestone plan** — especially critical for government projects
