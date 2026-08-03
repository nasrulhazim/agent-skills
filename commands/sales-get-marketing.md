---
name: sales-get-marketing
description: Get marketing copy - taglines, pitches, social media posts
---

# /sales-get-marketing Command

Generate marketing content for products/services.

## Usage

```
/sales-get-marketing [type] [style]
```

## Output Destination

1. Create directory `docs/sales-kit/` if it doesn't exist.
2. Write the full formatted output to `docs/sales-kit/marketing.md`.
3. Display a brief confirmation:
   ```
   Marketing content saved to docs/sales-kit/marketing.md
   ```

## Types

| Type | Description |
|------|-------------|
| `tagline` / `taglines` | Product taglines |
| `elevator` / `pitch` | 30-second elevator pitch |
| `social` | Social media posts |
| `value` / `roi` | Value proposition & ROI |
| `features` | Feature highlights |
| `comparison` | Competitive positioning |

## Styles (for social media)

| Style | Description |
|-------|-------------|
| `casual` | Relaxed, conversational tone |
| `professional` | Business/LinkedIn tone |
| `problem-solution` | Lead with pain point |
| `behind-the-scene` | Founder story style |
| `short` / `punchy` | Quick, impactful |

## Output Formats

### Taglines

```markdown
## TAGLINES

**Primary:**
> "[Main tagline]"

**Alternatives:**
- "[Alternative 1]"
- "[Alternative 2]"
- "[Alternative 3]"

**Usage:**

| Placement | Tagline |
|-----------|---------|
| Website hero | Primary tagline |
| Social media bio | Alternative 1 |
| Email signature | Alternative 2 |
```

### Elevator Pitch

```markdown
## ELEVATOR PITCH (30 seconds)

> "[Your pitch here - approximately 50-75 words that
> explain what the product does, who it's for, and
> why they should care. End with price point or CTA.]"

**Key Points:**
1. [Problem statement]
2. [Solution]
3. [Key differentiator]
4. [Price/CTA]
```

### Social Media

```markdown
## SOCIAL MEDIA POST: [Style]

[Post content here]

---

**Hashtags:** #hashtag1 #hashtag2 #hashtag3

**Best for:**
- [Platform 1]
- [Platform 2]

**Post time:** [time recommendation]
```

### Value Proposition / ROI

```markdown
## VALUE PROPOSITION

**Problem:**
[What pain point does this solve?]

**Solution:**
[How does the product solve it?]

**ROI Calculation:**

| Current State (Without Product) | |
|---|---|
| Hours spent on [task]/month | [X] hours |
| Hourly rate | [currency] [X] |
| Monthly cost | [currency] [X] |
| Annual cost | [currency] [X] |

| With Product | |
|---|---|
| Investment | [currency] [X] |
| Payback period | [X months] |

**Additional Benefits:**
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]
```

## Configuration Reference

The command reads from `product-config.md`:

```yaml
# Marketing Content
taglines:
  primary: "Your main tagline"
  alternatives:
    - "Alternative tagline 1"
    - "Alternative tagline 2"

elevator_pitch: |
  Your 30-second pitch goes here. Make it compelling
  and end with a clear call to action.

social_posts:
  - style: "problem-solution"
    content: |
      Your problem-solution post here...
      
  - style: "casual"
    content: |
      Your casual post here...

value_proposition:
  problem: "What problem you solve"
  solution: "How you solve it"
  roi:
    hours_saved: 20
    hourly_rate: 50
    payback_months: 24
```

## Examples

**User**: `/sales-get-marketing taglines`

**Response**:

```markdown
## TAGLINES

**Primary:**
> "Build Forms That Work For You"

**Alternatives:**
- "No-Code Forms, Pro-Level Workflows"
- "From Submission to Action, Automated"
- "Smart Forms for Growing Teams"

**Usage:**

| Placement | Tagline |
|-----------|---------|
| Website hero | Primary tagline |
| Social media bio | "No-Code Forms, Pro-Level Workflows" |
| Email signature | "From Submission to Action, Automated" |
```

**User**: `/sales-get-marketing social casual`

**Response**:

```markdown
## SOCIAL MEDIA POST: Casual

You know what's wild?

Most companies still email PDF forms around and manually
enter data into spreadsheets. In 2026.

We built FormCraft so you can drag-and-drop a form,
hook it to an approval workflow, and pipe the data
wherever it needs to go.

No developers needed. Takes 10 minutes to set up.

Try it → formcraft.io

---

**Hashtags:** #NoCode #Automation #FormBuilder #Productivity

**Best for:**
- LinkedIn
- Twitter/X
- Facebook

**Post time:** Tuesday-Thursday, 9am-11am
```

**User**: `/sales-get-marketing social professional`

**Response**:

```markdown
## SOCIAL MEDIA POST: Professional

Manual data collection costs organizations an average of
30+ hours per month in administrative overhead.

FormCraft eliminates this with no-code digital forms
that include built-in approval workflows, conditional
logic, and direct integration with your existing systems.

Deploy on your own infrastructure. One-time license.
No recurring fees. No data leaving your network.

Learn more at formcraft.io

---

**Hashtags:** #DigitalTransformation #WorkflowAutomation #Enterprise

**Best for:**
- LinkedIn
- Email newsletter

**Post time:** Monday-Wednesday, 8am-10am
```

**User**: `/sales-get-marketing elevator pitch`

**Response**:

```markdown
## ELEVATOR PITCH (30 seconds)

> "Every company has forms — intake forms, approval forms,
> feedback forms. Most still do them on paper or email.
>
> FormCraft is a no-code platform where anyone can build
> smart digital forms with built-in workflow automation.
>
> Submissions route to the right people, approvals happen
> in-app, and data flows straight into your systems.
>
> One-time license at RM 18,000, deploy on your servers,
> no recurring fees."

**Key Points:**
1. Universal problem — every company has forms
2. No-code solution — anyone can build
3. Workflow automation built in
4. On-premise, one-time pricing
```

**User**: `/sales-get-marketing roi`

**Response**:

```markdown
## VALUE PROPOSITION & ROI

**Problem:**
Teams waste hours on manual data collection — paper forms,
email chains, copy-pasting into spreadsheets. Errors slip
through, approvals stall, and nothing is trackable.

**Solution:**
FormCraft replaces manual workflows with smart digital forms
that route data automatically, trigger approvals, and sync
with your existing tools.

**ROI Calculation:**

| Current State (Manual Forms) | |
|---|---|
| Hours on data entry/month | 30 hours |
| Staff hourly rate | MYR 40 |
| Monthly cost | MYR 1,200 |
| Annual cost | MYR 14,400 |

| With FormCraft | |
|---|---|
| Investment | MYR 18,000 |
| Payback period | ~15 months |

**Additional Benefits:**
- Zero data entry errors
- Full audit trail on every submission
- Approval cycle time reduced by 60%
- Works offline — syncs when reconnected
```
