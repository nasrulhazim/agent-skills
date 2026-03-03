# SaaS Analysis Framework

Structured framework for evaluating a codebase's potential as a SaaS product.

---

## 1. Market Positioning Analysis

### Questions to Answer

- **What problem does this solve?** — Describe the pain point in one sentence
- **Who has this problem?** — List personas with different scales (solo, team, enterprise)
- **What do they use today?** — Map the competitive landscape
- **Where's the gap?** — Identify the underserved segment
- **Why now?** — What trend makes this opportunity timely?

### Positioning Matrix

Plot competitors on two axes:
- **X-axis:** Feature richness (low → high)
- **Y-axis:** Cost (low → high)

The ideal SaaS position is usually: **high features, moderate cost** — below enterprise
pricing but above free/basic tools.

---

## 2. Target Persona Framework

### Persona Template

For each persona, define:

| Attribute | Detail |
|---|---|
| **Who** | Role, team size, industry |
| **Pain** | What frustrates them about current tools |
| **Need** | What they'd pay for |
| **Budget** | Monthly willingness to pay |
| **Channel** | How to reach them |
| **Trigger** | What event makes them look for a solution |

### Typical Segments

1. **Solo Developer** — Needs simplicity, free tier important
2. **Small Team (5-20)** — Needs collaboration, moderate pricing
3. **Mid-size Company (20-200)** — Needs governance, security, compliance
4. **Enterprise (200+)** — Needs SSO, audit, SLA, self-hosted option

---

## 3. Architecture Design Principles

### SaaS-Ready Architecture Checklist

- [ ] **Multi-tenancy** — Tenant isolation at database/row level
- [ ] **Authentication** — OAuth, SSO/SAML support
- [ ] **Authorization** — Role-based + resource-based ACL
- [ ] **API-first** — REST or GraphQL API for all operations
- [ ] **Queue-based processing** — Async jobs for heavy work
- [ ] **Object storage** — S3-compatible for artifacts
- [ ] **Search** — Full-text search engine (Meilisearch, Algolia)
- [ ] **Caching** — Redis for hot data
- [ ] **CDN** — Edge distribution for static assets
- [ ] **Monitoring** — Structured logging, metrics, health checks
- [ ] **Billing** — Stripe/Paddle integration
- [ ] **Webhook support** — Both inbound and outbound

### Data Model Patterns

**Multi-tenant with Organisation:**
```
Organisation → has many → Teams → has many → Users
Organisation → has many → Resources
```

**Token-based Auth:**
```
User → has many → API Tokens (with scopes, expiry)
```

**Audit Trail:**
```
AuditLog (who, what, when, before, after, ip)
```

---

## 4. Feature Roadmap Framework

### Phase Structure

| Phase | Name | Duration | Goal |
|---|---|---|---|
| 1 | MVP | 2-3 months | Core value proposition + auth + basic UI |
| 2 | Growth | 2-3 months | Features that drive adoption + analytics |
| 3 | Scale | 2-3 months | Performance, queue management, enterprise prep |
| 4 | Enterprise | 3-6 months | SSO, audit, self-hosted, compliance |

### MVP Feature Selection

Include ONLY features that:
1. Solve the core problem better than existing tools
2. Are required for users to trust the platform
3. Can be built in 2-3 months by a small team

Defer features that:
- Are nice-to-have but not blocking adoption
- Require complex infrastructure (SSO, multi-region)
- Only matter at scale (advanced analytics, compliance)

---

## 5. Pricing Strategy Framework

### Pricing Principles

1. **Free tier must be useful** — drives adoption and word-of-mouth
2. **Team tier must be obvious upgrade** — collaboration features as the gate
3. **Business tier adds governance** — security, compliance, custom domains
4. **Enterprise is custom** — SSO, SLA, self-hosted, dedicated support

### Pricing Anchors

Research competitor pricing and position:
- **Below** enterprise incumbents (Private Packagist at $490/mo)
- **Above** free tools (Satis at $0)
- **At** the sweet spot for teams ($29-99/mo)

### Tier Structure Template

| Feature | Free | Team | Business | Enterprise |
|---|---|---|---|---|
| Repositories | 1 | 5 | Unlimited | Unlimited |
| Users | 1 | 10 | 50 | Unlimited |
| Packages | 5 private | Unlimited | Unlimited | Unlimited |
| Webhooks | No | Yes | Yes | Yes |
| Security scan | No | No | Yes | Yes |
| Access control | No | Basic | Team-level | Fine-grained |
| Custom domain | No | No | Yes | Yes |
| SSO | No | No | No | Yes |
| SLA | No | No | No | Yes |
| Support | Community | Email | Priority | Dedicated |

---

## 6. Risk Assessment Framework

### Risk Matrix

| Risk | Probability | Impact | Score | Mitigation |
|---|---|---|---|---|
| [Description] | Low/Med/High | Low/Med/High/Critical | P×I | [Strategy] |

### Common SaaS Risks

1. **Incumbent dominance** — Established player has network effects
   - Mitigation: Target underserved segment, better UX, lower price

2. **Low conversion from free** — Users stay on free tier forever
   - Mitigation: Generous free tier builds trust, team features gate upgrade

3. **Platform risk** — Dependency on ecosystem (PHP, Composer)
   - Mitigation: Multi-ecosystem support in roadmap

4. **Security incident** — Data breach or vulnerability
   - Mitigation: SOC2, pen testing, bug bounty

5. **Self-hosted cannibalises SaaS** — Users prefer self-hosting
   - Mitigation: Feature-gate self-hosted edition, charge separately

6. **Build reliability** — Builds fail, users lose trust
   - Mitigation: Redundant workers, monitoring, auto-retry

---

## 7. Revenue Projection Framework

### Assumptions to State

- **Total addressable market** — how many potential users
- **Signup rate** — monthly new signups
- **Conversion rate** — free → paid (typical: 2-5%)
- **Churn rate** — monthly cancellations (target: <5%)
- **ARPU** — average revenue per user

### Projection Formula

```
MRR = (existing_customers × (1 - churn)) + (new_signups × conversion_rate × ARPU)
```

### Milestone Targets

| Milestone | MRR | Typical Timeline |
|---|---|---|
| First paying customer | $29+ | Month 2-3 |
| Ramen profitable | $3,000 | Month 6-9 |
| Full-time viable | $10,000 | Month 12-18 |
| Growth stage | $50,000 | Month 24-36 |

---

## 8. Migration Path Framework

### Migration Steps

1. **Import** — Accept existing config file format (backward compatible)
2. **Map** — Translate config to platform data model
3. **Verify** — Show user the mapped result before committing
4. **Sync** — Initial build to prove output matches existing
5. **Switch** — Update client configs to point to new platform
6. **Retire** — Decommission old system

### Migration Checklist

- [ ] Config file import (JSON, YAML)
- [ ] Repository source migration
- [ ] Archive/artifact migration
- [ ] Auth credential migration (secure)
- [ ] DNS/URL transition plan
- [ ] Rollback plan if migration fails
