# User Story Patterns

Comprehensive guide to writing user stories, acceptance criteria, story mapping, and estimation.
Read this file when generating user stories via `/req stories`.

---

## Story Format

### Standard Template

```
As a [role]
I want to [action/goal]
So that [benefit/value]
```

### Examples

```
As a system administrator
I want to create new user accounts with role assignments
So that new employees can access the system with appropriate permissions

As a finance manager
I want to export monthly reports as PDF
So that I can attach them to the board meeting documents

As a customer
I want to reset my password via email
So that I can regain access to my account without contacting support
```

### Common Mistakes to Avoid

| Mistake | Bad Example | Good Example |
|---|---|---|
| No real user role | As a user... | As a warehouse operator... |
| Implementation detail in story | As a user, I want a React dropdown... | As a user, I want to select my department from a list... |
| No clear benefit | ...so that I can click the button | ...so that I can submit my leave request quickly |
| Too large (epic disguised as story) | As a user, I want to manage my account | Split into: update profile, change password, enable 2FA, etc. |
| Too small (task disguised as story) | As a dev, I want to add a database column | This is a task, not a user story |

---

## INVEST Criteria

Every good user story should satisfy the INVEST criteria:

| Criteria | Description | Check Question |
|---|---|---|
| **I** — Independent | Can be developed and delivered in any order | Does this story depend on another being done first? |
| **N** — Negotiable | Details can be discussed between dev and stakeholder | Is the "how" flexible, or is it locked to one solution? |
| **V** — Valuable | Delivers value to the user or business | Would the user notice or care if this was removed? |
| **E** — Estimable | Team can estimate the effort | Does the team understand enough to give a size? |
| **S** — Small | Can be completed within one sprint | Can this be done in 1–5 days? |
| **T** — Testable | Can be verified through acceptance criteria | Can you write a concrete test for this? |

### Applying INVEST — Worked Example

**Original story (fails INVEST):**
```
As a user, I want to manage all aspects of my profile including personal info,
avatar, notification preferences, security settings, and connected accounts
so that my account is configured correctly.
```

**Problems:** Not Small (too many things), Not Independent (lumps everything together).

**Split into INVEST-compliant stories:**
```
US-001: As a user, I want to update my personal information (name, phone, address)
        so that my contact details stay current.

US-002: As a user, I want to upload a profile avatar
        so that my colleagues can recognise me in the system.

US-003: As a user, I want to configure my notification preferences (email, push, SMS)
        so that I only receive alerts I care about.

US-004: As a user, I want to change my password and enable 2FA
        so that my account remains secure.

US-005: As a user, I want to connect/disconnect third-party accounts (Google, GitHub)
        so that I can use SSO for faster login.
```

---

## Acceptance Criteria Patterns

### Given/When/Then (Gherkin) Format

This is the preferred format. Each criterion is a concrete scenario.

```
Scenario: Successful login with valid credentials
  Given I am on the login page
  And I have a registered account with email "ahmad@example.com"
  When I enter my email and correct password
  And I click the "Log In" button
  Then I should be redirected to the dashboard
  And I should see a welcome message with my name
  And my last login timestamp should be updated

Scenario: Failed login with wrong password
  Given I am on the login page
  And I have a registered account with email "ahmad@example.com"
  When I enter my email and an incorrect password
  And I click the "Log In" button
  Then I should see an error message "Invalid email or password"
  And the failed attempt counter should increment by 1
  And I should remain on the login page

Scenario: Account lockout after 5 failed attempts
  Given I am on the login page
  And I have failed to login 4 times
  When I enter my email and an incorrect password for the 5th time
  And I click the "Log In" button
  Then my account should be locked for 30 minutes
  And I should see a message "Account locked. Try again in 30 minutes."
  And an email notification should be sent to my registered email
```

### Checklist Format (Simpler Alternative)

Use when Gherkin feels too heavy for straightforward stories.

```
Acceptance Criteria:
- [ ] User can enter email and password on login form
- [ ] System validates credentials against user store
- [ ] Successful login redirects to dashboard with welcome message
- [ ] Failed login shows generic error "Invalid email or password"
- [ ] Account locks after 5 consecutive failed attempts for 30 minutes
- [ ] Locked account receives email notification
- [ ] Session expires after 120 minutes of inactivity
- [ ] Login event is recorded in audit log
```

### Rule-Based Format

Use for business-rule-heavy stories.

```
Acceptance Criteria:

Rule: Discount calculation
- Orders above RM 1,000 receive 5% discount
- Orders above RM 5,000 receive 10% discount
- Government orders receive an additional 3% on top of volume discount
- Discounts cannot exceed 15% total
- Discount applies to subtotal before SST

Rule: Minimum order
- Minimum order value is RM 100 after discount
- Orders below minimum show message: "Minimum order is RM 100"
```

---

## Epic to Story to Task Breakdown

### Hierarchy

```
Theme (portfolio level)
  └── Epic (feature-level, spans multiple sprints)
       └── User Story (deliverable in one sprint)
            └── Task (technical work item, hours)
            └── Sub-task (atomic unit)
```

### Worked Example: User Management Module

```
EPIC: User Management
│
├── US-010: As an admin, I want to view a list of all users
│   ├── Task: Create User model and migration
│   ├── Task: Build user list API endpoint with pagination
│   ├── Task: Create user list UI component with search/filter
│   └── Task: Write feature test for user list
│
├── US-011: As an admin, I want to create a new user
│   ├── Task: Create user form with validation rules
│   ├── Task: Build create user API endpoint
│   ├── Task: Add role selection dropdown (fetch from roles table)
│   ├── Task: Send welcome email on user creation
│   └── Task: Write feature test for user creation
│
├── US-012: As an admin, I want to edit a user's details
│   ├── Task: Build edit user form (pre-populated)
│   ├── Task: Build update user API endpoint
│   ├── Task: Add change tracking (who changed what)
│   └── Task: Write feature test for user edit
│
├── US-013: As an admin, I want to deactivate a user
│   ├── Task: Add soft-delete with status toggle
│   ├── Task: Revoke active sessions on deactivation
│   ├── Task: Add deactivation reason field
│   └── Task: Write feature test for deactivation
│
└── US-014: As an admin, I want to assign roles to users
    ├── Task: Create role assignment UI (multi-select)
    ├── Task: Build role assignment API endpoint
    ├── Task: Add permission recalculation on role change
    └── Task: Write feature test for role assignment
```

### Epic Sizing Guide

| Epic Size | Number of Stories | Sprint Span | Example |
|---|---|---|---|
| Small | 3–5 stories | 1 sprint | Password reset flow |
| Medium | 5–10 stories | 1–2 sprints | User management CRUD |
| Large | 10–20 stories | 2–4 sprints | Reporting module |
| Too Large (split it) | 20+ stories | 4+ sprints | "The whole system" |

---

## Story Mapping

### What is a Story Map?

A story map arranges stories in two dimensions:
- **Horizontal (left → right):** User journey / workflow steps
- **Vertical (top → bottom):** Priority (must-have at top, nice-to-have at bottom)

### Template

```
USER JOURNEY (left to right)
─────────────────────────────────────────────────────────────────────

Activity:    Register        Login           Dashboard       Reports
             ────────        ─────           ─────────       ───────

Walking      Create account  Login w/ email  View KPI cards  View basic
Skeleton     with email      & password      and recent      report list
(MVP)                                        activity

Release 1    Email verify    Forgot          Filter by       Export to
             Social login    password        date range      PDF

Release 2    Bulk invite     SSO / OAuth     Custom          Scheduled
             Profile wizard  2FA (TOTP)      widgets         auto-email
                                             Drag-and-drop

Future       LDAP sync       Biometric       AI insights     Custom
             API key auth    Passkey         Anomaly alerts  report builder
```

### Walking Skeleton

The walking skeleton is the thinnest possible end-to-end slice that exercises the
full architecture. It should:

- Touch every layer (UI → API → business logic → database → external services)
- Be deployable and demonstrable
- Prove the architecture works before adding features
- Typically 1 story per major activity in the user journey

### How to Build a Story Map

1. **Identify user activities** (the big steps in their journey) — these become columns
2. **List tasks under each activity** — these become stories, arranged vertically by priority
3. **Draw a horizontal line** across the top — everything above is the walking skeleton (MVP)
4. **Draw release lines** — group stories into releases below the skeleton
5. **Validate** — does each release deliver a coherent, usable increment?

---

## Estimation Patterns

### T-Shirt Sizing

| Size | Story Points | Typical Effort | Example |
|---|---|---|---|
| **XS** | 1 | < 0.5 day | Change a label, fix a typo, update a config value |
| **S** | 2–3 | 0.5–1 day | Add a new field to an existing form with validation |
| **M** | 5 | 1–3 days | Build a CRUD screen with search and pagination |
| **L** | 8 | 3–5 days | Build a reporting module with charts, filters, export |
| **XL** | 13 | 5–10 days | Build an integration with external API + error handling + retry |
| **Too Big** | 20+ | > 10 days | Split this into smaller stories |

### Fibonacci Sequence for Story Points

```
1, 2, 3, 5, 8, 13, 21

1  = trivial (config change, text update)
2  = simple (one component, no unknowns)
3  = straightforward (small feature, well understood)
5  = moderate (multiple components, some complexity)
8  = complex (cross-cutting concern, multiple integrations)
13 = very complex (significant unknowns, research needed)
21 = epic-sized — must be split before sprint planning
```

### Estimation by Analogy

When estimating, compare to previously completed stories:

```
"User login" was a 5 — it had form, validation, API call, session management, error handling.

"Password reset" feels similar but adds email sending and token management → 8.

"Change profile photo" is simpler — just upload, resize, save → 3.
```

### Velocity-Based Sprint Planning

```
Team velocity: ~30 story points per sprint (2-week sprint, 3 developers)

Sprint capacity:
  Must-have stories:   20 points (67% of velocity)
  Should-have stories:  8 points (27% of velocity)
  Buffer:               2 points (6% for bugs / unplanned)
  Total planned:       30 points

If total backlog = 150 points:
  Estimated sprints: 150 / 30 = 5 sprints (10 weeks)
  Add 20% buffer:    6 sprints (12 weeks)
```

---

## Priority Framework (MoSCoW)

| Priority | Definition | Sprint Allocation | Example |
|---|---|---|---|
| **Must** | System is unusable without it | 60–70% of sprint | Login, core CRUD, data validation |
| **Should** | Significant value, workaround exists | 20–25% of sprint | Export to PDF, advanced search |
| **Could** | Nice-to-have, enhances experience | 5–10% of sprint | Dark mode, keyboard shortcuts |
| **Won't** | Agreed out of scope for this release | 0% | Mobile app, AI features, multi-tenancy |

### Prioritisation Questions

When a stakeholder says "everything is a must-have", ask:
- "If we could only ship 3 features next month, which 3?"
- "What would happen if this feature was delayed by 2 weeks?"
- "Is there a manual workaround users are doing today for this?"
- "Which feature would cause the most support tickets if missing?"

---

## Definition of Done (DoD)

Every user story is considered "done" when:

```
Code:
- [ ] Feature code written and self-reviewed
- [ ] Code follows project coding standards
- [ ] No new linting errors or warnings
- [ ] Unit tests written and passing
- [ ] Feature test written and passing

Review:
- [ ] Pull request created and reviewed by at least 1 team member
- [ ] Review comments addressed
- [ ] PR merged to development branch

Quality:
- [ ] Acceptance criteria verified (all scenarios pass)
- [ ] No regressions in existing tests
- [ ] Edge cases and error states handled
- [ ] Responsive design verified (if applicable)

Documentation:
- [ ] API documentation updated (if API changed)
- [ ] User-facing help text is accurate
- [ ] Release notes entry drafted

Deployment:
- [ ] Deployed to staging environment
- [ ] Smoke test passed on staging
- [ ] Database migrations run cleanly (if applicable)
```

---

## User Story Writing Checklist

Use this checklist before finalising a story:

```
Content:
- [ ] Role is a real user persona (not "user" or "system")
- [ ] Action describes what the user does (not how the system works)
- [ ] Benefit explains why this matters to the user or business
- [ ] Acceptance criteria are concrete and testable
- [ ] Edge cases are covered in acceptance criteria
- [ ] Error scenarios are specified

INVEST:
- [ ] Independent — can be built without waiting for other stories
- [ ] Negotiable — implementation approach is flexible
- [ ] Valuable — delivers real user or business value
- [ ] Estimable — team can give it a size
- [ ] Small — fits within one sprint
- [ ] Testable — QA can verify it passes or fails

Traceability:
- [ ] Traces to a requirement ID (REQ-XXX-NNN)
- [ ] Assigned to an epic
- [ ] Priority set (Must / Should / Could / Won't)
- [ ] Estimate set (S / M / L / XL or story points)
```
