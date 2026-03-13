# FAQ Writing Patterns

Reference guide for structuring high-quality FAQ documents across different audiences.

---

## Question Phrasing Patterns

### Good Question Patterns

| Pattern | Example |
|---|---|
| **What is...** | What is G8Stack? |
| **How do I...** | How do I approve a subscription? |
| **What happens when...** | What happens when a subscription expires? |
| **Can I / Does it...** | Can it manage multiple gateway environments? |
| **What are the...** | What are the minimum server requirements? |
| **Why can't I...** | Why can't I see certain APIs in the catalogue? |
| **What is the difference between...** | What is the difference between roles and access groups? |
| **How long does...** | How long does deployment take? |

### Bad Question Patterns (Avoid)

| Pattern | Problem |
|---|---|
| Questions starting with "Yes" or "No" | Answers should explain, not just confirm |
| Overly broad questions | "Tell me everything about..." — too vague |
| Compound questions | "How do I X and also Y?" — split into two |
| Leading questions | "Isn't it true that..." — biased |

---

## Answer Structure Patterns

### Short Answer (1-2 sentences)

Use for factual, definitive answers:

```markdown
**What database does it use?**
PostgreSQL 16 for production. SQLite in-memory for testing.
```

### Structured Answer (paragraph + table/list)

Use when the answer has multiple parts:

```markdown
**What user roles are available?**
Three default roles with increasing permissions:

| Role | Access Level |
|------|-------------|
| User | Catalogue browsing, API subscription requests |
| Administrator | Full API management, subscription approval |
| Superadmin | All permissions (wildcard) |
```

### Procedural Answer (numbered steps)

Use for "How do I..." questions:

```markdown
**How do I create an API service?**
1. Go to API Management > Services > Create
2. Fill in service details (name, type, host, port, path)
3. Save as Draft
4. Submit for Approval
5. Approve the service
6. Sync to Kong (automatic if auto-sync enabled)
```

### Command Answer (with code block)

Use for technical/DevOps audiences:

```markdown
**How do I restart background services?**
```bash
supervisorctl restart g8stack:*
supervisorctl status g8stack:*
```
```

### Troubleshooting Answer (symptom → cause → fix)

Use for troubleshooting sections:

```markdown
**Users can't see APIs in the catalogue**
Check:
1. The service is published (approved + enabled)
2. The user belongs to an Access Group that includes the service's API type
3. The user has the `g8stack.access.catalogue` permission
```

---

## Section Organization

### By Topic (recommended for most audiences)

Group related questions under clear headings:

```
## Getting Started
## User Management
## API Service Management
## Troubleshooting
```

### By Task Flow (good for end users)

Order questions following the user's journey:

```
## Signing In
## Browsing the Catalogue
## Subscribing to an API
## Using Your API Key
## Managing Your Subscriptions
```

### By Frequency (good for support teams)

Most-asked questions first, edge cases last.

---

## Audience-Specific Tone Guide

| Audience | Tone | Vocabulary | Detail Level |
|---|---|---|---|
| Business/Executive | Professional, non-technical | Business terms, ROI, compliance | High-level, no code |
| Marketing/Sales | Persuasive, confident | Value propositions, comparisons | Features + benefits |
| Project Manager | Structured, risk-aware | Timeline, dependencies, governance | Planning-focused |
| Administrator | Procedural, helpful | UI paths, settings, workflows | Step-by-step |
| Developer | Technical, precise | Code, architecture, patterns | Code snippets, file refs |
| DevOps | Operations, pragmatic | Commands, configs, ports | Commands + configs |
| End User | Simple, friendly | Plain language, no jargon | Minimal, clear |

---

## Comparison Table Patterns

### Feature Comparison (for Marketing/Sales)

```markdown
| Feature | Our Product | Competitor A | Competitor B |
|---------|------------|-------------|-------------|
| Subscription workflow | Full lifecycle | Not available | Basic |
| Audit trail | Model-level | Limited | None |
```

### Tier/Plan Comparison (for Business)

```markdown
| Tier | Data Source | Setup | Best For |
|------|-----------|-------|----------|
| 1 | Basic metrics | None | POC |
| 2 | Full local | Medium | Production |
| 3 | ELK Stack | High | Enterprise |
```

---

## Common Patterns by Audience

### Business FAQ Must-Haves

- What problem does it solve?
- Is it SaaS or on-premise?
- What are the security/compliance features?
- What is the licensing model?
- What happens during disaster recovery?

### Developer FAQ Must-Haves

- What is the tech stack?
- How do I extend/customize it?
- What are the key gotchas?
- How do I run tests?
- What events can I listen to?

### DevOps FAQ Must-Haves

- What are the server requirements?
- What ports need to be open?
- How do I deploy it?
- How do I monitor it?
- How do I back it up?
- Common troubleshooting commands

### End User FAQ Must-Haves

- How do I get started?
- How do I find APIs?
- How do I get an API key?
- What do the status values mean?
- Why isn't my API call working?
