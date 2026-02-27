# Product Config Template

This is the schema and template for `product-config.md`.
When generating a config from an interview, populate every field.
Leave genuinely unknown fields as `# TODO` comments, not blank.

---

## Template

```markdown
# Product Config — [Product Name]

> Version: 1.0
> Last Updated: [Date]
> Currency: MYR

---

## Product Identity

name: "[Product Name]"
tagline: "[One-line value proposition]"
description: |
  [2–3 sentences. What it does, who it's for, what makes it different.]
url: "https://[product-url]"
type: "saas | license | service | hybrid"

target_audience:
  - "[Audience segment 1, e.g. Malaysian SMEs managing APIs]"
  - "[Audience segment 2, e.g. Enterprise IT teams on Laravel]"

---

## Base Pricing

base_price: [number]
unit: "one-time | monthly | annual"
currency: "MYR"

includes:
  - "[Inclusion 1, e.g. Unlimited users]"
  - "[Inclusion 2, e.g. Remote deployment]"
  - "[Inclusion 3, e.g. 1 year updates & support]"

minimum_commitment: "[e.g., 1 year | none]"

---

## Add-ons

addons:
  - name: "[Add-on 1 name]"
    description: "[What it includes]"
    price: [number]          # Use this for fixed price
    # price_min: [number]    # Use min/max for ranged pricing
    # price_max: [number]
    unit: "one-time | monthly | per-day | per-user"

  - name: "[Add-on 2 name]"
    description: "[What it includes]"
    price_min: [number]
    price_max: [number]
    unit: "one-time"

  # Add more as needed

---

## Partner Channels

channels:
  referrer:
    margin: 10    # % of base price paid to referrer on closed deal
    description: "Introduces a lead only. No sales involvement required."

  affiliate:
    margin: 20
    description: "Markets the product and qualifies leads before handoff."

  reseller:
    margin: 30
    description: "Manages the full sales cycle end-to-end."

  fronting:
    margin: 15
    description: "Handles project management and finance only. No technical involvement."

---

## Government / Enterprise Packages

packages:
  - name: "[Package Name, e.g. Government Standard]"
    target: "[Who this is for, e.g. Malaysian public sector agencies]"
    components:
      - item: "[Component 1, e.g. Requirement Study]"
        price: [number]
      - item: "[Component 2, e.g. Product License]"
        price: [number]
      - item: "[Component 3, e.g. Integration Services]"
        price: [number]
      - item: "[Component 4, e.g. Customisation]"
        price: [number]
      - item: "[Component 5, e.g. Training (3 days)]"
        price: [number]
    notes: "[Any special terms, e.g. SST applicable, delivery timeline]"

  - name: "[Package 2, e.g. Enterprise SaaS]"
    target: "[e.g. Private sector, >500 users]"
    components:
      - item: "[Component]"
        price: [number]
    notes: "[Notes]"

---

## Annual Maintenance & Support

maintenance:
  included_months: 12    # Months included with base purchase
  renewal_rate: 0.20     # % of base price per year (e.g. 0.20 = 20%)
  includes:
    - "[What maintenance covers, e.g. Bug fixes]"
    - "[Security updates]"
    - "[Minor version upgrades]"

---

## Marketing

taglines:
  - "[Tagline option 1]"
  - "[Tagline option 2]"
  - "[Tagline option 3]"

elevator_pitch: |
  [30-second pitch. Problem → Solution → Proof → CTA.]

value_propositions:
  - "[VP 1, e.g. No vendor lock-in]"
  - "[VP 2, e.g. Deploy on your own infrastructure]"
  - "[VP 3, e.g. Built for Malaysian compliance requirements]"

competitors:
  - name: "[Competitor 1]"
    differentiator: "[How you're different]"

---

## Business Context

founded: "[Year]"
stage: "pre-revenue | early | growth | mature"
monthly_fixed_costs: [number]    # MYR, for break-even calculations
revenue_target_annual: [number]  # MYR target for current year

team:
  size: [number]
  model: "solo | small-team | agency"

markets:
  primary: "[e.g. Malaysia]"
  secondary:
    - "[e.g. Singapore]"
    - "[e.g. Indonesia]"

---

## Quotation Defaults

quotation:
  validity_days: 30
  payment_terms: "[e.g. 50% upfront, 50% on delivery]"
  sst_rate: 0.08    # 8% SST for Malaysian businesses
  company_name: "[Your company name]"
  company_address: |
    [Address line 1]
    [Address line 2]
    [City, State, Postcode]
  company_contact: "[email or phone]"
  prefix: "Q"    # Quotation number prefix → Q-2026-001
```

---

## Notes on Populating the Config

**Pricing ranges** are common for services. Use `price_min` + `price_max` when the actual
price depends on scope. Always document what drives the range in the `description`.

**Government packages** should be broken into line items even if you ultimately quote a
lump sum — it gives the prospect a clear view of value and makes negotiation easier.

**Partner margins** are defaults. Individual partner agreements can override these.
Document overrides separately, not in the shared config.

**SST rate** is 8% for Malaysia as of 2024. Confirm current rate before issuing actual
quotations — this can change with budget announcements.

**Monthly fixed costs** are for internal use only in financial planning. Don't include
this in any customer-facing output.
