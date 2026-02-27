# SRS Template — IEEE 830 Simplified

Full Software Requirements Specification template. Based on IEEE 830 structure, simplified
for practical use in real projects. Read this file when generating an SRS via `/req spec`.

---

## Document Header

```markdown
# Software Requirements Specification

**Project:** [Project Name]
**Version:** [1.0 Draft / 1.0 / 1.1 etc.]
**Date:** [YYYY-MM-DD]
**Author:** [Name / Team]
**Status:** [Draft / Review / Approved]

## Revision History

| Version | Date       | Author | Changes                  |
|---------|------------|--------|--------------------------|
| 0.1     | YYYY-MM-DD | Name   | Initial draft            |
| 1.0     | YYYY-MM-DD | Name   | Approved by stakeholders |
```

---

## Section 1 — Introduction

```markdown
## 1. Introduction

### 1.1 Purpose

Describe the purpose of this SRS and the intended audience.

> This document specifies the software requirements for [System Name]. It is intended for
> the development team, project stakeholders, and QA team to use as the authoritative
> reference for what the system must do.

### 1.2 Scope

Define the software product by name, explain what it will do and what it will not do.

> **Product Name:** [Name]
> **Description:** [One paragraph describing the system]
> **Benefits:** [Key benefits to the user / organisation]
> **Objectives:** [Business objectives this system supports]

### 1.3 Definitions, Acronyms, and Abbreviations

| Term   | Definition                                          |
|--------|-----------------------------------------------------|
| SRS    | Software Requirements Specification                 |
| PDPA   | Personal Data Protection Act 2010 (Malaysia)        |
| MAMPU  | Malaysian Administrative Modernisation and Management Planning Unit |
| SSO    | Single Sign-On                                      |
| API    | Application Programming Interface                   |
| [Term] | [Definition — add project-specific terms here]      |

### 1.4 References

| # | Document                          | Version | Source          |
|---|-----------------------------------|---------|-----------------|
| 1 | [Related spec or standard]        | x.x     | [URL or path]   |
| 2 | [API documentation]               | x.x     | [URL or path]   |
| 3 | [Regulatory document]             | x.x     | [URL or path]   |

### 1.5 Overview

Brief overview of the rest of this document — what each section covers.
```

---

## Section 2 — Overall Description

```markdown
## 2. Overall Description

### 2.1 Product Perspective

Describe the context: is this a new system, a replacement, an extension of an existing
system? How does it fit into the larger ecosystem?

> [System Name] is a [new / replacement / extension] system that [relationship to existing
> systems]. It interfaces with [list external systems].

#### System Context Diagram

```
                    +------------------+
                    |   [System Name]  |
                    +--------+---------+
                             |
            +----------------+----------------+
            |                |                |
    +-------v------+  +-----v------+  +------v-------+
    | External     |  | Database   |  | Third-party  |
    | System A     |  | Server     |  | API          |
    +--------------+  +------------+  +--------------+
```

### 2.2 Product Functions

High-level summary of the major functions the system will perform.

- **F1: [Function name]** — [Brief description]
- **F2: [Function name]** — [Brief description]
- **F3: [Function name]** — [Brief description]
- **F4: [Function name]** — [Brief description]
- **F5: [Function name]** — [Brief description]

### 2.3 User Classes and Characteristics

| User Class     | Description                           | Frequency of Use | Technical Level |
|----------------|---------------------------------------|-------------------|-----------------|
| Administrator  | Manages system config, users, roles   | Daily             | High            |
| Regular User   | Uses core features day-to-day         | Daily             | Medium          |
| Manager        | Views reports, approves workflows     | Weekly            | Low-Medium      |
| External API   | Machine-to-machine integration        | Continuous        | N/A             |

### 2.4 Operating Environment

| Aspect          | Specification                                     |
|-----------------|---------------------------------------------------|
| Server OS       | [e.g., Ubuntu 22.04 LTS]                         |
| Runtime         | [e.g., PHP 8.2+ / Node 20+ / Python 3.11+]      |
| Database        | [e.g., MySQL 8.0 / PostgreSQL 16]                |
| Web Server      | [e.g., Nginx / Apache / Caddy]                   |
| Client Browser  | [e.g., Chrome 120+, Firefox 120+, Safari 17+]    |
| Mobile          | [e.g., responsive web / native iOS+Android]      |
| Hosting         | [e.g., AWS / Azure / on-premise / VPS]           |

### 2.5 Design and Implementation Constraints

- [Framework constraint: e.g., must use Laravel 11]
- [Language constraint: e.g., UI must support BM and EN]
- [Compliance: e.g., must comply with PDPA 2010]
- [Integration: e.g., must integrate with existing HR system via REST API]
- [Budget: e.g., hosting cost must not exceed RM X/month]

### 2.6 Assumptions and Dependencies

**Assumptions:**
- Users have internet access with minimum 1 Mbps bandwidth
- Client will provide test data within 2 weeks of project kick-off
- Existing database schema documentation is accurate and up-to-date

**Dependencies:**
- Third-party payment gateway API availability
- Client's SSO/LDAP server for authentication integration
- Government API endpoints for data verification (if applicable)
```

---

## Section 3 — Specific Requirements (Functional)

This is the core of the SRS. Every functional requirement gets a unique ID.

```markdown
## 3. Specific Requirements

### 3.1 Authentication Module

#### REQ-AUTH-001: User Login

| Field          | Value                                              |
|----------------|----------------------------------------------------|
| **Priority**   | Must                                               |
| **Description**| The system shall allow registered users to log in using email and password |
| **Input**      | Email address, password                            |
| **Processing** | Validate credentials against user store, check account status, create session |
| **Output**     | Redirect to dashboard on success; error message on failure |
| **Business Rules** | - Account locks after 5 failed attempts for 30 minutes |
|                | - Password must meet complexity requirements (min 8 chars, 1 upper, 1 number) |
|                | - Session expires after 120 minutes of inactivity |

#### REQ-AUTH-002: Password Reset

| Field          | Value                                              |
|----------------|----------------------------------------------------|
| **Priority**   | Must                                               |
| **Description**| The system shall allow users to reset their password via email verification |
| **Input**      | Email address                                      |
| **Processing** | Generate time-limited reset token (60 min), send reset link via email |
| **Output**     | Confirmation message; email with reset link        |
| **Business Rules** | - Reset link expires after 60 minutes           |
|                | - Previous sessions invalidated after password change |

#### REQ-AUTH-003: Single Sign-On (SSO)

| Field          | Value                                              |
|----------------|----------------------------------------------------|
| **Priority**   | Should                                             |
| **Description**| The system shall support SSO via OAuth 2.0 / SAML for enterprise clients |
| **Input**      | SSO provider redirect                              |
| **Processing** | Validate token with identity provider, map to local user account |
| **Output**     | Authenticated session                              |
| **Business Rules** | - Auto-provision user on first SSO login        |
|                | - Map SSO groups to system roles                   |

### 3.2 User Management Module

#### REQ-USER-001: Create User

| Field          | Value                                              |
|----------------|----------------------------------------------------|
| **Priority**   | Must                                               |
| **Description**| Admin shall be able to create new user accounts    |
| **Input**      | Name, email, role, department, status               |
| **Processing** | Validate uniqueness of email, create user record, send welcome email |
| **Output**     | New user record; welcome email with temp password  |
| **Business Rules** | - Email must be unique across all accounts      |
|                | - User must be assigned at least one role          |
|                | - Welcome email includes link to set initial password |

[Continue for each requirement in each module...]
```

### Requirement ID Convention

```
REQ-[MODULE]-[NNN]

Modules (examples):
  AUTH  — Authentication & authorisation
  USER  — User management
  ROLE  — Roles & permissions
  RPT   — Reporting & analytics
  NOTIF — Notifications
  INTG  — Integrations
  WF    — Workflow & approvals
  DATA  — Data management
  SRCH  — Search
  DASH  — Dashboard
  AUDIT — Audit trail
```

### Priority Levels (MoSCoW)

| Priority | Meaning                                          |
|----------|--------------------------------------------------|
| Must     | Critical — system fails without it               |
| Should   | Important — significant value, but workaround exists |
| Could    | Nice-to-have — enhances UX but not critical      |
| Won't    | Out of scope for this version — documented for future |

---

## Section 4 — External Interface Requirements

```markdown
## 4. External Interface Requirements

### 4.1 User Interfaces

| Screen / Page     | Description                                | User Class     |
|-------------------|--------------------------------------------|----------------|
| Login Page        | Email + password form, SSO option, forgot pw | All           |
| Dashboard         | KPI cards, recent activity, quick actions  | Regular, Admin |
| User List         | Paginated table, search, filters, actions  | Admin          |
| User Form         | Create/edit user with role assignment      | Admin          |
| Report Viewer     | Date range filter, chart + table, export   | Manager, Admin |
| Profile Settings  | Edit own profile, change password, 2FA     | All            |

**General UI requirements:**
- Responsive design (desktop, tablet, mobile breakpoints)
- Minimum contrast ratio 4.5:1 (WCAG AA)
- Loading states for all async operations
- Form validation on both client and server side
- Support for Bahasa Malaysia and English UI (if bilingual)

### 4.2 Hardware Interfaces

[Describe any hardware the system interacts with — printers, scanners, biometric
readers, etc. Write "N/A" if none.]

### 4.3 Software Interfaces

| External System     | Interface Type | Purpose                        | Data Format |
|---------------------|---------------|--------------------------------|-------------|
| [Payment Gateway]   | REST API      | Process payments               | JSON        |
| [Email Service]     | SMTP / API    | Send transactional emails      | MIME / JSON |
| [SSO Provider]      | OAuth 2.0     | User authentication            | JWT         |
| [Government API]    | REST / SOAP   | Data verification              | JSON / XML  |
| [File Storage]      | S3 API        | Document storage               | Binary      |

### 4.4 Communication Interfaces

| Protocol  | Usage                          | Security       |
|-----------|--------------------------------|----------------|
| HTTPS     | All web traffic                | TLS 1.2+       |
| WSS       | Real-time notifications        | TLS 1.2+       |
| SMTP/TLS  | Email delivery                 | STARTTLS       |
| SFTP      | Batch file transfers           | SSH key auth   |
```

---

## Section 5 — Non-Functional Requirements

```markdown
## 5. Non-Functional Requirements

### 5.1 Performance Requirements

| Metric                    | Target                                    |
|---------------------------|-------------------------------------------|
| Page load time            | < 2 seconds (first contentful paint)      |
| API response time         | < 500ms (95th percentile)                 |
| Concurrent users          | Support 500 simultaneous users            |
| Database query time       | < 100ms for standard queries              |
| File upload               | Support files up to 50MB                  |
| Report generation         | < 10 seconds for reports with 10K rows    |
| Search response           | < 1 second for full-text search           |

### 5.2 Safety Requirements

- System shall not delete data permanently — soft delete with 90-day retention
- Financial calculations shall use decimal precision (not floating point)
- All destructive actions require user confirmation
- Batch operations limited to 1,000 records per transaction

### 5.3 Security Requirements

| Requirement              | Specification                              |
|--------------------------|--------------------------------------------|
| Authentication           | Email/password + optional 2FA (TOTP)       |
| Password policy          | Min 8 chars, 1 uppercase, 1 number, 1 special |
| Session management       | Server-side sessions, 120-min timeout      |
| Data encryption at rest  | AES-256 for sensitive fields               |
| Data encryption in transit | TLS 1.2+ for all connections             |
| Access control           | Role-based (RBAC) with permission matrix   |
| Audit logging            | All create/update/delete actions logged    |
| PDPA compliance          | Personal data handling per PDPA 2010       |
| Input validation         | All user inputs sanitised server-side      |
| SQL injection prevention | Parameterised queries / ORM only           |
| XSS prevention           | Output encoding on all rendered content    |
| CSRF protection          | Token-based CSRF protection on all forms   |

### 5.4 Software Quality Attributes

| Attribute       | Requirement                                        |
|-----------------|----------------------------------------------------|
| Availability    | 99.5% uptime (excludes scheduled maintenance)      |
| Maintainability | Modular architecture, documented API, test coverage > 80% |
| Portability     | Docker-based deployment, environment-agnostic config |
| Scalability     | Horizontal scaling via load balancer + stateless app |
| Testability     | All business logic unit-testable, E2E test suite   |
| Usability       | New user productive within 30 minutes, no training required for basic tasks |
| Recoverability  | Daily automated backups, RPO < 24 hours, RTO < 4 hours |

### 5.5 Compliance Requirements

| Standard / Regulation     | Applicability                             |
|---------------------------|-------------------------------------------|
| PDPA 2010                 | All personal data handling                |
| MAMPU Guidelines          | Government projects only                  |
| WCAG 2.1 AA              | All user-facing interfaces                |
| OWASP Top 10             | Security baseline for all components      |
```

---

## Section 6 — Appendices

```markdown
## Appendices

### Appendix A: Glossary

| Term              | Definition                                       |
|-------------------|--------------------------------------------------|
| [Domain term]     | [Definition in project context]                  |

### Appendix B: Data Dictionary

| Entity      | Field         | Type         | Required | Description           |
|-------------|---------------|--------------|----------|-----------------------|
| User        | id            | UUID         | Yes      | Unique identifier     |
| User        | name          | String(255)  | Yes      | Full name             |
| User        | email         | String(255)  | Yes      | Login email (unique)  |
| User        | password_hash | String(255)  | Yes      | Bcrypt hashed password|
| User        | role_id       | FK(Role)     | Yes      | Primary role          |
| User        | status        | Enum         | Yes      | active/inactive/locked|
| User        | created_at    | Timestamp    | Yes      | Record creation time  |

### Appendix C: Requirement Cross-Reference

> If generating a traceability matrix separately via `/req matrix`, reference
> that document here instead of duplicating.

### Appendix D: To Be Determined (TBD) List

| # | Item                              | Owner       | Target Date |
|---|-----------------------------------|-------------|-------------|
| 1 | [Unresolved decision]             | [Person]    | [Date]      |
| 2 | [Pending stakeholder input]       | [Person]    | [Date]      |
```

---

## Usage Notes

- Every requirement MUST have a unique ID — this enables traceability via `/req matrix`
- Use MoSCoW priorities consistently — do not invent new levels
- Non-functional requirements are just as important as functional ones — never skip Section 5
- For Malaysian government projects, add a section for MAMPU compliance mapping
- Keep the SRS as a living document — update the revision history on every change
- When generating from interview, it is acceptable to mark sections as TBD if the user
  genuinely does not have the information yet — but flag them clearly
