# Incident Report Templates — Security Documentation

Read this file when generating security reports with `/soc report`. Choose the appropriate template based on the reporting context.

---

## Template 1: Security Audit Report

Use this after running `/soc triage` or `/soc harden` to document a full security scan.

```markdown
# Security Audit Report

**Application:** [Application Name]
**Audited By:** SOC Analyst (Claude Code)
**Date:** [YYYY-MM-DD]
**Scope:** [Full application / Specific module / API only]
**Stack:** [Detected stack and version — e.g., Laravel 12 / PHP 8.4, Express 5 / Node 22, Django 5.1 / Python 3.12]

---

## Executive Summary

[2-3 sentences summarizing the security posture, number of findings by severity, and overall risk level.]

**Risk Level:** [Critical / High / Medium / Low]
**Total Findings:** [N]

| Severity | Count |
|---|---|
| P1 — Critical | [N] |
| P2 — High | [N] |
| P3 — Medium | [N] |
| P4 — Low | [N] |

---

## Findings Summary

| # | Finding | Severity | Category | Affected File(s) | MITRE ATT&CK | Status |
|---|---|---|---|---|---|---|
| 1 | [Short description] | P1 | [OWASP category] | [file:line] | [T-ID] | [Open/Fixed] |
| 2 | [Short description] | P2 | [OWASP category] | [file:line] | [T-ID] | [Open/Fixed] |

---

## Detailed Findings

### Finding 1: [Title]

**Severity:** P1 — Critical
**Category:** [OWASP category]
**MITRE ATT&CK:** [Technique ID — Name]
**Affected Files:** [file paths with line numbers]

**Description:**
[What the vulnerability is and where it exists.]

**Impact:**
[What an attacker could achieve by exploiting this.]

**Evidence:**
```
// Vulnerable code (use the project's language)
[code snippet]
```

**Remediation:**
```
// Fixed code (use the project's language)
[code snippet]
```

**Status:** [Open / Fixed / Accepted Risk]

---

## Hardening Scorecard

[Include scorecard from hardening-checklist.md if /soc harden was run]

---

## Recommendations

1. **Immediate (P1):** [Action items for critical findings]
2. **Short-term (P2):** [Action items for high findings]
3. **Medium-term (P3-P4):** [Action items for medium/low findings]
4. **Ongoing:** [Recurring security practices to adopt]
```

---

## Template 2: Incident Report

Use this when documenting a security incident (active or recently resolved).

```markdown
# Security Incident Report

**Incident ID:** [INC-YYYY-NNN]
**Application:** [Application Name]
**Reported By:** SOC Analyst (Claude Code)
**Date Detected:** [YYYY-MM-DD HH:MM UTC]
**Date Resolved:** [YYYY-MM-DD HH:MM UTC / Ongoing]
**Severity:** [P1 / P2 / P3 / P4]
**Status:** [Investigating / Contained / Eradicated / Recovered / Closed]

---

## Executive Summary

[2-3 sentences: what happened, what was the impact, what was done about it.]

---

## Timeline

| Time (UTC) | Event |
|---|---|
| [YYYY-MM-DD HH:MM] | [First indicator of compromise / alert triggered] |
| [YYYY-MM-DD HH:MM] | [Investigation started] |
| [YYYY-MM-DD HH:MM] | [Root cause identified] |
| [YYYY-MM-DD HH:MM] | [Containment actions taken] |
| [YYYY-MM-DD HH:MM] | [Fix deployed] |
| [YYYY-MM-DD HH:MM] | [Monitoring confirmed resolution] |

---

## Impact Assessment

**Data Affected:** [What data was exposed/modified/lost]
**Users Affected:** [Number and scope of affected users]
**Systems Affected:** [Which systems/services were impacted]
**Business Impact:** [Revenue, reputation, compliance implications]

---

## Attack Vector

**MITRE ATT&CK Technique:** [T-ID — Name]
**Attack Path:**
1. [Step 1: How attacker gained initial access]
2. [Step 2: What attacker did next]
3. [Step 3: How attacker achieved their objective]

**Entry Point:** [URL/endpoint/file that was exploited]
**Vulnerability Exploited:** [Specific vulnerability and its location in code]

---

## Root Cause Analysis

[Detailed explanation of why the vulnerability existed and how it was exploited.]

**Contributing Factors:**
- [Factor 1: e.g., Missing input validation on endpoint X]
- [Factor 2: e.g., No rate limiting on authentication]
- [Factor 3: e.g., Debug mode enabled in production]

---

## Response Actions

### Containment
- [ ] [Action 1: e.g., Disabled compromised endpoint]
- [ ] [Action 2: e.g., Revoked all active sessions]
- [ ] [Action 3: e.g., Blocked attacker IP]

### Eradication
- [ ] [Action 1: e.g., Patched SQL injection in UserController:45]
- [ ] [Action 2: e.g., Removed web shell from storage/]
- [ ] [Action 3: e.g., Rotated all API keys and secrets]

### Recovery
- [ ] [Action 1: e.g., Deployed fix to production]
- [ ] [Action 2: e.g., Restored affected data from backup]
- [ ] [Action 3: e.g., Re-enabled affected services]

---

## Lessons Learned

1. **What went well:** [Aspects of the response that worked]
2. **What could improve:** [Gaps in detection, response, or prevention]
3. **Action items:**
   - [ ] [Preventive measure 1 — owner — due date]
   - [ ] [Preventive measure 2 — owner — due date]
   - [ ] [Preventive measure 3 — owner — due date]
```

---

## Template 3: Post-Mortem Document

Use this for blameless post-mortems after resolving a security incident.

```markdown
# Post-Mortem: [Incident Title]

**Date:** [YYYY-MM-DD]
**Authors:** SOC Analyst (Claude Code), [team members]
**Status:** [Draft / Final]
**Severity:** [P1 / P2 / P3 / P4]

---

## Summary

[One paragraph: what happened, when, how long it lasted, what the impact was.]

**Duration:** [Start time] to [End time] ([N hours/minutes])
**Impact:** [Quantified impact — users affected, data exposed, downtime]
**Detection:** [How the incident was discovered — alert, user report, audit]

---

## Timeline

All times in UTC.

| Time | Event | Actor |
|---|---|---|
| HH:MM | [Event description] | [System/Person] |
| HH:MM | [Event description] | [System/Person] |

---

## Contributing Factors

This is a blameless post-mortem. We focus on systemic issues, not individual actions.

1. **[Factor]:** [Explanation of how this contributed]
2. **[Factor]:** [Explanation of how this contributed]
3. **[Factor]:** [Explanation of how this contributed]

---

## What Went Well

- [Positive aspect 1]
- [Positive aspect 2]
- [Positive aspect 3]

## What Went Poorly

- [Issue 1]
- [Issue 2]
- [Issue 3]

## Where We Got Lucky

- [Lucky break 1 — something that limited impact but wasn't by design]
- [Lucky break 2]

---

## Action Items

| # | Action | Priority | Owner | Due Date | Status |
|---|---|---|---|---|---|
| 1 | [Specific, measurable action] | P1 | [Name] | [Date] | [Open] |
| 2 | [Specific, measurable action] | P2 | [Name] | [Date] | [Open] |
| 3 | [Specific, measurable action] | P3 | [Name] | [Date] | [Open] |

---

## Follow-Up Schedule

- [ ] **[Date + 1 week]:** Review P1 action items completion
- [ ] **[Date + 2 weeks]:** Review P2 action items completion
- [ ] **[Date + 1 month]:** Full post-mortem review, close remaining items
```

---

## Template 4: Vulnerability Report

Use this for detailed documentation of a single vulnerability.

```markdown
# Vulnerability Report: [Vulnerability Title]

**Report ID:** [VULN-YYYY-NNN]
**Application:** [Application Name]
**Reported By:** SOC Analyst (Claude Code)
**Date:** [YYYY-MM-DD]
**Severity:** [P1 / P2 / P3 / P4]
**CVSS Score:** [If applicable]
**Status:** [Open / Fixed / Accepted Risk / Won't Fix]

---

## Vulnerability Details

**Type:** [OWASP category — e.g., A03:2021 Injection]
**MITRE ATT&CK:** [T-ID — Name]
**CWE:** [CWE-ID — Name, if applicable]
**Affected Component:** [file:line]
**Introduced:** [Commit hash / date if known]

---

## Description

[Clear explanation of the vulnerability — what it is, where it exists, and why it's dangerous.]

---

## Reproduction Steps

1. [Step 1: Setup required]
2. [Step 2: Specific request or action]
3. [Step 3: Expected vs actual result]

**Proof of Concept:**
```
[HTTP request, curl command, or code snippet that demonstrates the vulnerability]
```

---

## Impact Analysis

**Confidentiality:** [High / Medium / Low / None] — [Explanation]
**Integrity:** [High / Medium / Low / None] — [Explanation]
**Availability:** [High / Medium / Low / None] — [Explanation]

**Worst-Case Scenario:**
[What could an attacker achieve with full exploitation?]

---

## Affected Code

```
// Vulnerable code at [file:line] (use the project's language)
[code snippet]
```

---

## Fix

```
// Remediated code (use the project's language)
[code snippet]
```

**Changes Made:**
- [Change 1: What was changed and why]
- [Change 2: What was changed and why]

---

## Verification

1. [How to verify the fix works — test command or manual check]
2. [Regression test added — file path and description]

**Regression Test:**
```
[Test code using the project's test framework — Pest, Jest, pytest, RSpec, etc.]
```

---

## Related Findings

- [Any other vulnerabilities discovered during investigation]
- [Similar patterns found elsewhere in the codebase]

---

## References

- [OWASP link]
- [CWE link]
- [MITRE ATT&CK link]
- [Framework-specific documentation]
```
