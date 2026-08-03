---
name: sales-get-quotation
description: Generate quotation breakdowns by customer type or custom requirements
---

# /sales-get-quotation Command

Generate quotation templates and breakdowns.

## Usage

```
/sales-get-quotation [customer-type]
/sales-get-quotation for [custom requirements]
```

## Output Destination

1. Create directory `docs/sales-kit/` if it doesn't exist.
2. Write the full formatted output to `docs/sales-kit/quotation.md`.
3. Display a brief confirmation:
   ```
   Quotation saved to docs/sales-kit/quotation.md
   ```

## Customer Types

| Type | Description |
|------|-------------|
| `sme` / `basic` | Small/medium enterprise, basic package |
| `sme-plus` | SME with monitoring/add-ons |
| `enterprise` | Enterprise package |
| `government` / `gov` | Government standard |
| `government-full` | Government full scope |
| `custom` | Custom based on requirements |

## Output Format

```markdown
## QUOTATION: [Package Name]

| | |
|---|---|
| **Customer** | [Customer type/name] |
| **Date** | [Current date] |
| **Valid** | 30 days |

| No | Description | Amount |
|----|-------------|--------|
| 1 | [Line item 1] | [amount] |
| 2 | [Line item 2] | [amount] |
| 3 | [Line item 3] | [amount] |
| | **TOTAL** | **[total]** |

**Optional Add-ons:**

| Add-on | Price |
|--------|-------|
| [Add-on 1] | [amount] |
| [Add-on 2] | [amount] |

**Terms:**
- [Term 1]
- [Term 2]

**Notes:**
- [Note 1]
- [Note 2]
```

## Configuration Reference

The command reads from `product-config.md`:

```yaml
# Quotation Templates
quotation_templates:
  - name: "SME Basic"
    customer_type: "sme"
    line_items:
      - description: "Product License"
        price: 25000
    total: 25000
    notes:
      - "Deployment included"
      - "1 year support included"

  - name: "Enterprise Full"
    customer_type: "enterprise"
    line_items:
      - description: "Product License"
        price: 25000
      - description: "Monitoring Integration"
        price: 25000
      - description: "Customization"
        price_min: 10000
        price_max: 25000
      - description: "Training (3 days)"
        price: 15000
    total_min: 75000
    total_max: 90000

# Default terms
quotation_terms:
  - "Prices quoted in MYR"
  - "Valid for 30 days"
  - "50% upon confirmation, 50% upon completion"
  - "Warranty: 3 months from deployment"

# Default notes
quotation_notes:
  - "Deployment included"
  - "1 year updates & support included"
  - "Maintenance Year 2+: 20% of license fee"
```

## Examples

**User**: `/sales-get-quotation sme`

**Response**:

```markdown
## QUOTATION: SME Basic

| | |
|---|---|
| **Customer** | SME / Small Team |
| **Date** | 2026-02-02 |
| **Valid** | 30 days |

| No | Description | Amount |
|----|-------------|--------|
| 1 | DataPulse License | 35,000 |
| | **TOTAL (MYR)** | **35,000** |

**Includes:**
- Up to 10 data connectors
- Unlimited dashboards
- 5 user seats
- Remote setup
- 1 year updates & support

**Optional Add-ons:**

| Add-on | Price |
|--------|-------|
| Additional Connectors Pack | 15,000 |
| Training (per day) | 6,000 |
| Custom Dashboard Templates | 8,000 - 15,000 |

**Terms:**
- Prices quoted in MYR
- Valid for 30 days
- Full payment upon confirmation

**Notes:**
- Maintenance Year 2+: MYR 7,000/year
```

**User**: `/sales-get-quotation enterprise`

**Response**:

```markdown
## QUOTATION: Enterprise Package

| | |
|---|---|
| **Customer** | Enterprise |
| **Date** | 2026-02-02 |
| **Valid** | 30 days |

| No | Description | Amount |
|----|-------------|--------|
| 1 | DataPulse License | 45,000 |
| 2 | Advanced Connectors Pack | 18,000 |
| 3 | Customization (Branding + SSO) | 15,000 |
| 4 | Training (2 days) | 12,000 |
| | **TOTAL (MYR)** | **90,000** |

**Includes:**
- Unlimited data connectors
- Unlimited dashboards & users
- White-label branding
- SSO integration
- Remote deployment
- 1 year updates & priority support

**Optional Add-ons:**

| Add-on | Price |
|--------|-------|
| 12 Months Dedicated Support | 72,000 - 120,000 |
| Data Migration | 15,000 - 40,000 |
| Additional Training | 6,000/day |

**Terms:**
- Prices quoted in MYR
- Valid for 30 days
- 50% upon confirmation, 50% upon completion

**Notes:**
- Maintenance Year 2+: MYR 7,000/year
```

**User**: `/sales-get-quotation government`

**Response**:

```markdown
## QUOTATION: Government Standard

| | |
|---|---|
| **Customer** | Government Agency |
| **Date** | 2026-02-02 |
| **Valid** | 30 days |

| No | Description | Amount |
|----|-------------|--------|
| 1 | DataPulse License | 35,000 |
| 2 | Advanced Connectors Pack | 15,000 |
| 3 | Training (2 days) | 12,000 |
| | **TOTAL (MYR)** | **62,000** |

**Includes:**
- Unlimited data connectors
- Unlimited dashboards & reports
- Unlimited user seats
- PDF/Excel report exports
- Remote deployment
- 1 year updates & support

**Optional Add-ons:**

| Add-on | Price |
|--------|-------|
| Annual Support (12 months) | 50,000 - 90,000 |
| Custom Connectors (per source) | 10,000 - 20,000 |
| Additional Training | 6,000/day |

**Terms:**
- Prices quoted in MYR
- Valid for 30 days
- Payment: As per government procurement process

**Notes:**
- Below RM 50,000 threshold for direct purchase
- Maintenance Year 2+: MYR 7,000/year
```

**User**: `/sales-get-quotation for 5 departments with real-time sync, SSO, and 3 days training`

**Response**:

```markdown
## QUOTATION: Custom Package

| | |
|---|---|
| **Customer** | Custom Requirements |
| **Date** | 2026-02-02 |
| **Valid** | 30 days |

**Requirements:**
- 5 departments with separate dashboards
- Real-time data sync
- SSO integration
- 3 days training

| No | Description | Amount |
|----|-------------|--------|
| 1 | DataPulse License (unlimited dashboards — covers all 5 departments) | 35,000 |
| 2 | Advanced Connectors Pack (includes real-time sync) | 15,000 |
| 3 | SSO Integration (Customization) | 12,000 |
| 4 | Training (3 days × MYR 6,000) | 18,000 |
| | **TOTAL (MYR)** | **80,000** |

**Includes:**
- Dashboards for all 5 departments
- Real-time data from connected sources
- SSO with your identity provider
- Hands-on training for each department
- Remote deployment
- 1 year updates & support

**Terms:**
- Prices quoted in MYR
- Valid for 30 days
- 50% upon confirmation, 50% upon completion

**Notes:**
- Maintenance Year 2+: MYR 7,000/year
- Additional training available at MYR 6,000/day
```

**User**: `/sales-get-quotation government-full`

**Response**:

```markdown
## QUOTATION: Government Full Implementation

| | |
|---|---|
| **Customer** | Government Agency (Full Scope) |
| **Date** | 2026-02-02 |
| **Valid** | 30 days |

| No | Description | Amount |
|----|-------------|--------|
| 1 | Requirement Study | 20,000 |
| 2 | DataPulse License | 50,000 |
| 3 | Advanced Connectors Pack (Real-time sync, Custom data pipelines, API integration) | 20,000 |
| 4 | Customization (SSO Integration, Custom Report Templates) | 25,000 |
| 5 | Deployment & Configuration | 15,000 |
| 6 | Training (3 days) | 18,000 |
| | **SUBTOTAL** | **148,000** |
| 7 | 12 Months Support (Optional) | 72,000 |
| | **GRAND TOTAL (MYR)** | **220,000** |

**Scope of Work:**

1. **Requirement Study** — Stakeholder interviews, Data source audit, Dashboard design workshop
2. **Implementation** — DataPulse deployment, Data connector configuration, Dashboard & report setup
3. **Customization** — SSO with existing IdP, Custom report templates
4. **Training & Handover** — Admin training, End-user training, Documentation

**Timeline:** 8-10 weeks

**Terms:**
- Prices quoted in MYR
- Valid for 30 days
- Payment milestones: 30% upon confirmation, 40% upon deployment, 30% upon UAT sign-off

**Notes:**
- Maintenance Year 2+: MYR 7,000/year
- Support renewal: Quote separately
```
