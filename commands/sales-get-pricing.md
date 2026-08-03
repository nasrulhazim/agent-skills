---
name: sales-get-pricing
description: Get pricing information for products/services based on scenario
---

# /sales-get-pricing Command

Get comprehensive pricing information based on the scenario specified.

## Usage

```
/sales-get-pricing [scenario]
```

## Behavior

1. **Find product config**: Look for `product-config.md` in the current project, or use defaults from `~/.claude/sales-reference.md`

2. **Parse scenario**: Understand what pricing the user needs:
   - `license` / `base` / `standard` → Base product pricing
   - `with [addon]` → Base + specific add-on
   - `via [channel]` → Partner channel pricing
   - `partner comparison` → All partner channels side by side
   - `[customer-type]` → Package pricing (sme, enterprise, government)
   - `full project` → Complete project breakdown

3. **Calculate and format**: Apply margins, calculate totals, format output

## Output Destination

1. Create directory `docs/sales-kit/` if it doesn't exist.
2. Write the full formatted output to `docs/sales-kit/pricing.md`.
3. Display a brief confirmation:
   ```
   Pricing saved to docs/sales-kit/pricing.md
   ```

## Scenario Patterns

### Direct Sales

- `/sales-get-pricing license` → Base license price
- `/sales-get-pricing base` → Same as license
- `/sales-get-pricing with monitoring` → License + monitoring add-on
- `/sales-get-pricing with ELK and training` → Multiple add-ons

### Partner Channels

- `/sales-get-pricing via referrer` → 10% margin calculation
- `/sales-get-pricing via affiliate` → 20% margin calculation
- `/sales-get-pricing via reseller` → 30% margin calculation
- `/sales-get-pricing via fronting` → 15% fee calculation
- `/sales-get-pricing partner comparison` → All channels side by side

### Project-Based

- `/sales-get-pricing sme` → SME package
- `/sales-get-pricing enterprise` → Enterprise package
- `/sales-get-pricing government` → Government package
- `/sales-get-pricing government full project` → Full scope breakdown

### Custom

- `/sales-get-pricing for 10 users with SSO` → Custom calculation
- `/sales-get-pricing project worth RM 200k via fronting` → Partner split

## Output Format

### Direct Pricing

```markdown
## PRICING: [Product Name]

**Base License:** [currency] [amount]

**Includes:**
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Add-ons Available:**

| Add-on | Price |
|--------|-------|
| [Add-on 1] | [currency] [amount] |
| [Add-on 2] | [currency] [amount] |

**Maintenance (Year 2+):** [currency] [amount]/year
```

### Partner Pricing

```markdown
## PARTNER PRICING: [Channel Type]

| | |
|---|---|
| **Channel** | [Type] |
| **Margin** | [X]% |
| **Role** | [Description] |

| | Amount |
|---|---|
| Customer Pays | [currency] [amount] |
| Partner Keeps | [currency] [amount] (X%) |
| You Receive | [currency] [amount] |

**Partner Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]

**Your Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]
```

### Partner Comparison

```markdown
## PARTNER CHANNEL COMPARISON

| Channel | Margin | Partner Get | You Receive |
|---------|--------|-------------|-------------|
| Direct | - | - | [amount] |
| Referrer | 10% | [amount] | [amount] |
| Affiliate | 20% | [amount] | [amount] |
| Reseller | 30% | [amount] | [amount] |
| Fronting | 15% | [amount] | [amount] |
```

## Configuration Reference

The command reads from `product-config.md`:

```yaml
# Required
product_name: "Product Name"
currency: "MYR"
base_price: 25000

# Optional - Add-ons
addons:
  - name: "Monitoring"
    price: 25000
  - name: "Training"
    price: 5000
    unit: "per day"

# Optional - Partner margins
channels:
  referrer: 10
  affiliate: 20
  reseller: 30
  fronting: 15

# Optional - Maintenance
maintenance:
  price: 5000
  unit: "yearly"
  starts: "Year 2"
```

## Examples

**User**: `/sales-get-pricing license`

**Response**:

```markdown
## PRICING: CloudDesk

**Plan:** Professional
**Price:** USD 299/month (per workspace)

**Includes:**
- Unlimited agents
- Unlimited tickets
- Email + live chat channels
- Knowledge base
- SLA management
- API access

**Add-ons Available:**

| Add-on | Price |
|--------|-------|
| AI Auto-Triage | USD 99/month |
| Phone Channel | USD 149/month |
| Advanced Analytics | USD 79/month |

**Annual Billing:** USD 249/month (save 17%)
```

**User**: `/sales-get-pricing via reseller`

**Response**:

```markdown
## PARTNER PRICING: Reseller

| | |
|---|---|
| **Channel** | Reseller |
| **Margin** | 30% |
| **Role** | Full sales cycle, they close deal |

| | Amount |
|---|---|
| Customer Pays | USD 299/month |
| Partner Keeps | USD 89.70/month (30%) |
| You Receive | USD 209.30/month |

**Partner Responsibilities:**
- Full sales cycle
- L1 support (if trained)
- Account management

**Your Responsibilities:**
- Provide platform access
- Technical support/escalation
- Product updates

**MAP:** Cannot sell below USD 249/month
```

**User**: `/sales-get-pricing with AI and phone`

**Response**:

```markdown
## PRICING: CloudDesk + Add-ons

| Item | Monthly (USD) |
|------|---------------|
| Professional Plan | 299 |
| AI Auto-Triage | 99 |
| Phone Channel | 149 |
| **TOTAL** | **547** |

**Annual Billing:** USD 457/month (save 17%)
**Annual Total:** USD 5,484/year
```

**User**: `/sales-get-pricing partner comparison`

**Response**:

```markdown
## PARTNER CHANNEL COMPARISON

**Base:** USD 299/month

| Channel | Margin | Partner Get | You Receive |
|---------|--------|-------------|-------------|
| Direct | - | - | $299/mo |
| Referrer | 10% | $29.90/mo | $269.10/mo |
| Affiliate | 20% | $59.80/mo | $239.20/mo |
| Reseller | 30% | $89.70/mo | $209.30/mo |
| Fronting | 15% | $44.85/mo | $254.15/mo |
```
