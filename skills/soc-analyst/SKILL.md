---
name: soc-analyst
metadata:
  compatible_agents: [claude-code]
  tags: [security, soc, vulnerability, incident-response, owasp, mitre, remediation, hardening, agnostic]
description: >
  Senior SOC Analyst skill — stack-agnostic security operations for any web
  application. Auto-detects the project stack (Laravel/PHP, Node.js/Express,
  Python/Django/Flask/FastAPI, Ruby/Rails, Go, Rust, Java/Spring, .NET) then
  triages security alerts by severity (P1-P4) with MITRE ATT&CK categorization,
  investigates suspicious activity by tracing attack paths and correlating
  events, performs incident response with containment and eradication, actively
  remediates vulnerabilities in code (SQL injection, XSS, CSRF, insecure
  deserialization, auth bypass, file upload flaws, command injection, path
  traversal, SSRF, mass assignment), hardens applications proactively (security
  headers, rate limiting, input validation, dependency audit, secrets rotation),
  and generates incident reports with post-mortem documents. Use this skill
  whenever the user asks to analyze security issues, fix vulnerabilities,
  investigate incidents, harden their application, or audit for threats —
  including requests like "check for security vulnerabilities", "fix the SQL
  injection", "investigate this suspicious activity", "harden my app", "run a
  security audit", "triage this alert", "check dependencies for CVEs", "semak
  keselamatan code ni", "betulkan vulnerability ni", "nak harden app ni",
  "tolong investigate security issue ni", "audit keselamatan project ni", or
  "fix security issues". Works with any web framework and language.
---

# Senior SOC Analyst

Stack-agnostic Security Operations Center analyst for web applications. Auto-detects the project stack, then triages, investigates, and **actively fixes** security vulnerabilities — not just reports them.

## Command Reference

| Command | Phase | Description |
|---|---|---|
| `/soc triage` | Triage | Scan codebase/logs, assess severity (P1-P4), categorize with MITRE ATT&CK |
| `/soc investigate` | Investigation | Deep-dive a finding — trace attack path, correlate events, identify root cause |
| `/soc respond` | Incident Response | Contain active incidents, eradicate threats, recover operations |
| `/soc remediate` | Remediation | Fix vulnerabilities in code — patch files, show before/after diffs |
| `/soc harden` | Hardening | Proactive security improvements with hardening scorecard |
| `/soc report` | Reporting | Generate security audit reports, incident reports, post-mortems |

---

## Trigger Detection

Activate this skill when the user:
- Explicitly asks for a security audit, vulnerability scan, or penetration test
- Asks to fix a specific vulnerability (SQL injection, XSS, CSRF, etc.)
- Reports a security incident or suspicious activity
- Asks to harden their application
- Mentions OWASP, MITRE ATT&CK, CVE, or security compliance
- Says: "check security", "fix vulnerability", "harden app", "investigate incident"
- Says (BM): "semak keselamatan", "betulkan vulnerability", "harden app", "investigate security issue"

---

## Pre-flight: Stack Detection

Before running any command, detect the project stack. Check for these files in order:

| Indicator File(s) | Stack | Dependency Audit Command |
|---|---|---|
| `composer.json` + `artisan` | Laravel/PHP | `composer audit` |
| `composer.json` (no artisan) | PHP (Symfony, etc.) | `composer audit` |
| `package.json` + `next.config.*` | Next.js | `npm audit` / `yarn audit` |
| `package.json` + `nuxt.config.*` | Nuxt.js | `npm audit` / `yarn audit` |
| `package.json` (Express/Fastify/Nest) | Node.js | `npm audit` / `yarn audit` / `pnpm audit` |
| `requirements.txt` / `pyproject.toml` / `Pipfile` | Python | `pip audit` / `safety check` |
| `manage.py` + `settings.py` | Django | `pip audit` |
| `Gemfile` | Ruby/Rails | `bundle audit check --update` |
| `go.mod` | Go | `govulncheck ./...` |
| `Cargo.toml` | Rust | `cargo audit` |
| `pom.xml` / `build.gradle` | Java/Spring | `mvn dependency-check:check` / `gradle dependencyCheckAnalyze` |
| `*.csproj` / `*.sln` | .NET | `dotnet list package --vulnerable` |

Once detected, gather stack-specific context:

### Laravel/PHP
- Read `composer.json` for versions and packages
- Check for Sanctum/Passport/Fortify auth
- Read `.env.example`, `config/session.php`, `config/cors.php`
- Check `bootstrap/app.php` or `app/Http/Kernel.php` middleware

### Node.js (Express/Fastify/Nest)
- Read `package.json` for dependencies
- Check for `helmet`, `cors`, `express-rate-limit`, `csrf` packages
- Read `.env` handling (dotenv, config module)
- Check middleware registration

### Python (Django/Flask/FastAPI)
- Read `requirements.txt` / `pyproject.toml` for dependencies
- Check `settings.py` (Django) or app config (Flask/FastAPI)
- Look for `SECURE_*` settings (Django), `talisman` (Flask)
- Check middleware/authentication configuration

### Ruby/Rails
- Read `Gemfile` for dependencies
- Check `config/environments/production.rb` security settings
- Look for `rack-attack`, `devise`, `brakeman` gems
- Check `config/initializers/` for security configs

### Go / Rust / Java / .NET
- Read dependency manifest for versions
- Check for known security middleware/libraries
- Identify auth implementation pattern
- Review configuration files

---

## 1. `/soc triage` — Security Alert Triage

Scan the codebase and categorize all security findings.

### Steps

1. **Accept input**: The user may provide specific files, log entries, or say "scan everything"
2. **Detect stack** using Pre-flight rules above
3. **Scan the codebase** using detection patterns from `references/vulnerability-patterns.md`:
   - Select the grep patterns for the detected stack
   - Check configuration files for misconfigurations
   - Run the appropriate dependency audit command
   - Check environment files for insecure defaults
4. **Assess each finding**:
   - Assign severity: P1 (Critical), P2 (High), P3 (Medium), P4 (Low)
   - Map to MITRE ATT&CK technique using `references/mitre-attack-mapping.md`
   - Categorize by OWASP Top 10 category
   - Identify affected file(s) and line number(s)
5. **Output a triage table**:

```markdown
## Security Triage Report

**Date:** [Date]
**Stack:** [Detected stack and version]
**Scope:** [What was scanned]
**Total Findings:** [N]

| # | Finding | Severity | OWASP Category | MITRE ATT&CK | File(s) | Action |
|---|---|---|---|---|---|---|
| 1 | SQL injection in user query | P1 | A03 Injection | T1190 | src/controllers/user.js:45 | Remediate |
| 2 | Missing CSRF protection | P2 | A01 Broken Access | T1185 | templates/payment.html:12 | Remediate |
```

6. **Ask the user**: "Want me to investigate any of these deeper with `/soc investigate`, or fix them directly with `/soc remediate`?"

### Triage Priority Rules

- **P1 — Fix immediately**: RCE, SQL injection, auth bypass, data breach, exposed secrets
- **P2 — Fix within 24 hours**: XSS, CSRF, SSRF, access control bypass, mass assignment
- **P3 — Fix within 1 week**: Open redirect, info disclosure, weak crypto, missing headers
- **P4 — Fix in next sprint**: Verbose errors, minor misconfig, missing best practices

---

## 2. `/soc investigate` — Deep Investigation

Deep-dive into a specific finding or suspicious indicator.

### Steps

1. **Accept the target**: A specific finding from triage, a suspicious log entry, or a reported anomaly
2. **Trace the attack path**:
   - Follow data flow from user input (request) to vulnerable sink (query, output, command)
   - Map the full request lifecycle through the framework's routing/middleware/handler chain
   - Identify all points where input could be sanitized but isn't
3. **Correlate across the codebase**:
   - Search for the same vulnerable pattern in other files
   - Check if the vulnerability exists in other handlers, routes, or templates
   - Look for related security weaknesses that compound the risk
4. **Identify root cause**:
   - Is it a missing validation? Wrong function? Misconfiguration? Design flaw?
   - Check git blame to understand when and why the vulnerable code was introduced
5. **Assess blast radius**:
   - What data could an attacker access from this entry point?
   - What other systems or services could be reached?
   - Are there privilege escalation paths from this vulnerability?
6. **Document using MITRE ATT&CK kill chain**:
   - Initial Access → Execution → Persistence → Privilege Escalation → Impact
7. **Output an investigation report**:

```markdown
## Investigation Report

**Finding:** [Title]
**Stack:** [Detected stack]
**Severity:** [P1-P4]
**MITRE ATT&CK:** [Technique chain]

### Attack Path
1. Attacker sends [request] to [endpoint]
2. Input reaches [function] at [file:line] without [sanitization]
3. [Vulnerability] allows attacker to [action]

### Root Cause
[Explanation of why the vulnerability exists]

### Blast Radius
- [Data/systems at risk]
- [Privilege escalation paths]

### Related Findings
- [Other instances of the same pattern]

### Recommendation
[Specific fix with code reference]
```

---

## 3. `/soc respond` — Incident Response

Handle active security incidents through containment, eradication, and recovery.

### Steps

1. **Determine incident phase** and act accordingly:

### Phase 1: Identification
- Confirm the incident is real (not a false positive)
- Determine scope: what systems, data, and users are affected
- Classify severity using triage rules

### Phase 2: Containment (Immediate)

Apply containment actions appropriate to the detected stack:

| Scenario | Containment Action |
|---|---|
| Compromised endpoint | Disable the route, return 503, or add maintenance mode |
| Compromised credentials | Revoke all active sessions/tokens, invalidate API keys |
| Active exploitation | Block attacker IP via middleware, WAF, or firewall rule |
| Data exfiltration | Disable affected API endpoints, revoke access tokens |
| Web shell / backdoor | Remove the file, check for persistence mechanisms |
| Compromised admin account | Force password reset, revoke sessions, disable 2FA temporarily |

**Stack-specific containment examples:**

<details>
<summary>Laravel/PHP</summary>

```php
// Emergency: Disable a route
Route::any('/compromised-endpoint', fn () => abort(503, 'Under maintenance'));

// Revoke all sessions
DB::table('sessions')->truncate();

// Block IP via middleware
public function handle(Request $request, Closure $next): Response
{
    $blockedIps = cache()->get('blocked_ips', []);
    if (in_array($request->ip(), $blockedIps)) { abort(403); }
    return $next($request);
}
```
</details>

<details>
<summary>Node.js/Express</summary>

```javascript
// Emergency: Disable a route
app.all('/compromised-endpoint', (req, res) => res.status(503).send('Under maintenance'));

// Revoke all sessions (Redis store)
const redisClient = req.app.get('redisClient');
await redisClient.flushDb();

// Block IP via middleware
const blockedIps = new Set(await cache.get('blocked_ips') || []);
app.use((req, res, next) => {
    if (blockedIps.has(req.ip)) return res.status(403).end();
    next();
});
```
</details>

<details>
<summary>Python/Django</summary>

```python
# Emergency: Disable a view
from django.http import HttpResponse
def compromised_view(request):
    return HttpResponse('Under maintenance', status=503)

# Revoke all sessions
from django.contrib.sessions.models import Session
Session.objects.all().delete()

# Block IP via middleware
class BlockIPMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
    def __call__(self, request):
        blocked = cache.get('blocked_ips', [])
        if request.META.get('REMOTE_ADDR') in blocked:
            return HttpResponseForbidden()
        return self.get_response(request)
```
</details>

### Phase 3: Eradication
- Fix the vulnerability using `/soc remediate` workflow
- Remove any artifacts left by the attacker (web shells, unauthorized accounts, modified files)
- Check git status for unauthorized file changes
- Rotate all potentially compromised secrets (app keys, API keys, database passwords)

```bash
# Check for unauthorized file changes
git status
git diff

# Search for web shells / backdoors (adapt patterns to your stack)
grep -rl "eval\|base64_decode\|exec\|child_process\|subprocess" .
```

### Phase 4: Recovery
- Deploy the fix to production
- Verify the fix works (run `/soc remediate` verification steps)
- Monitor for recurrence (check logs for similar patterns)
- Re-enable any disabled services
- Notify affected users if data was compromised

### Phase 5: Lessons Learned
- Generate a post-mortem using `/soc report`
- Create action items to prevent recurrence
- Update security monitoring for the attack pattern

2. **Output an incident response checklist** with checkboxes for each action taken

---

## 4. `/soc remediate` — Fix Vulnerabilities in Code

**This is the core differentiator.** The SOC analyst doesn't just report — it writes the fix.

### Steps

1. **Identify the vulnerability class** using `references/vulnerability-patterns.md`
2. **Read the affected file(s)** — understand the full context around the vulnerable code
3. **Look up the fix** in `references/remediation-playbooks.md` for the detected stack
4. **Apply the fix**:
   - Edit the file to replace vulnerable code with secure code
   - Add any required middleware, validation, or configuration
   - Create authorization guards if access control is missing
   - Add input validation if missing
5. **Show before/after** — explain what was changed and why
6. **Add regression test** — write a test using the project's testing framework that verifies the fix
7. **Run quality checks** — suggest running the project's linter/type checker after fixes

### Vulnerability Fix Quick Reference (Stack-Agnostic)

| Vulnerability | Primary Fix | Additional Hardening |
|---|---|---|
| SQL Injection | Parameterized queries / ORM | Input validation layer |
| XSS | Output encoding / auto-escaping templates | CSP header |
| CSRF | CSRF tokens / SameSite cookies | Double-submit cookie pattern |
| Broken Auth | Rate limiting, session regeneration | Password policy, MFA |
| Broken Access Control | Authorization middleware/guards | Scoped queries, RBAC |
| Mass Assignment | Allowlist fields / DTOs | Validation layer |
| Insecure Deserialization | JSON over native serialization | Type-safe parsing |
| File Upload | MIME validation, safe filenames | Store outside webroot |
| Command Injection | Safe APIs (no shell), argument escaping | Allowlist validation |
| Path Traversal | Basename extraction, storage abstraction | Filename allowlist |
| Open Redirect | Relative path validation | Host allowlist |
| SSRF | Private IP blocking, scheme validation | Domain allowlist |
| Config Misconfig | Disable debug, secure env vars | Security headers |
| Data Exposure | Hidden fields, safe logging | Encryption at rest |

### Fix Workflow Per Vulnerability

For each vulnerability found:

```
1. READ the vulnerable file
2. IDENTIFY the exact vulnerable code and its context
3. APPLY the stack-appropriate fix from remediation-playbooks.md
4. VERIFY the fix doesn't break functionality
5. WRITE a regression test using the project's test framework
6. EXPLAIN what was fixed and why
```

### Test Framework Selection

| Stack | Test Framework | Test Runner |
|---|---|---|
| Laravel/PHP | Pest / PHPUnit | `php artisan test` |
| Node.js | Jest / Vitest / Mocha | `npm test` |
| Python/Django | pytest / unittest | `pytest` / `python manage.py test` |
| Ruby/Rails | RSpec / Minitest | `bundle exec rspec` / `rails test` |
| Go | testing (stdlib) | `go test ./...` |
| Rust | built-in tests | `cargo test` |
| Java/Spring | JUnit / TestNG | `mvn test` / `gradle test` |
| .NET | xUnit / NUnit | `dotnet test` |

### Important Rules

- **Always show the diff** — the user must see what changed
- **Never break functionality** — the fix must preserve the original behavior while removing the vulnerability
- **Explain the "why"** — don't just fix, teach why it was vulnerable
- **One fix at a time** — apply and verify each fix individually, don't batch blindly
- **Test the fix** — every remediation should include a regression test in the project's test framework
- **Use idiomatic fixes** — use the framework's built-in security features, not generic workarounds

---

## 5. `/soc harden` — Proactive Security Hardening

Systematically improve the application's security posture.

### Steps

1. **Detect stack** and select the appropriate checklist sections from `references/hardening-checklist.md`
2. **Run through all applicable categories**:
   - Environment & Secrets (all stacks)
   - Security Headers (all web stacks)
   - Authentication & Sessions (all stacks)
   - Authorization & Access Control (all stacks)
   - Input Validation (all stacks)
   - Database Security (stacks with DB)
   - Dependency Security (all stacks)
   - File System Security (all stacks)
   - Logging & Monitoring (all stacks)
   - Deployment Security (all stacks)

3. **For each category**:
   - Read the relevant configuration files and code
   - Check each item against the checklist
   - Mark as passed or failed
   - For failures, determine the stack-appropriate fix

4. **Run dependency audit** using the detected stack's command:

```bash
# PHP
composer audit

# Node.js
npm audit  # or yarn audit / pnpm audit

# Python
pip audit  # or safety check

# Ruby
bundle audit check --update

# Go
govulncheck ./...

# Rust
cargo audit

# Java
mvn dependency-check:check

# .NET
dotnet list package --vulnerable
```

5. **Output a hardening scorecard**:
   - Score per category (X/Y checks passed)
   - Overall score and percentage
   - Critical findings listed first
   - Prioritized recommendations

6. **Apply security headers** if not present — using the stack's idiomatic approach (middleware, config, etc.)

---

## 6. `/soc report` — Security Reporting

Generate structured security documents.

### Steps

1. **Determine report type** based on context:

| Context | Report Type | Template |
|---|---|---|
| After `/soc triage` or `/soc harden` | Security Audit Report | Template 1 |
| During/after incident response | Incident Report | Template 2 |
| After incident resolution | Post-Mortem | Template 3 |
| Single vulnerability deep-dive | Vulnerability Report | Template 4 |

2. **Gather data** from the current session:
   - Detected stack and version
   - Findings from triage
   - Investigation results
   - Incident timeline
   - Remediation actions taken
   - Hardening scorecard

3. **Generate the report** using templates from `references/incident-report-templates.md`

4. **Output location**: Write to `security/` directory in the project root:
   - `security/audit-report-YYYY-MM-DD.md`
   - `security/incident-INC-YYYY-NNN.md`
   - `security/post-mortem-YYYY-MM-DD.md`
   - `security/vuln-VULN-YYYY-NNN.md`

---

## Writing Rules

1. **Be specific** — always include file paths and line numbers
2. **Show evidence** — include the vulnerable code snippet
3. **Fix, don't just report** — the `/soc remediate` command writes actual code fixes
4. **Explain the "why"** — every finding should explain the risk, not just the technical flaw
5. **Bilingual support** — respond in the user's language (English or Bahasa Malaysia)
6. **Before/after** — every fix shows the vulnerable code and the remediated code
7. **Test coverage** — every fix includes a regression test in the project's test framework
8. **No false alarms** — verify findings before reporting; check if the code path is reachable
9. **Prioritize** — always output findings sorted by severity (P1 first)
10. **Use idiomatic code** — fixes must use the framework's native security features, not generic workarounds

---

## Reference Files

| File | Read When |
|---|---|
| `references/vulnerability-patterns.md` | Triaging or investigating — multi-stack detection catalog with code signatures, severity, and MITRE mapping |
| `references/remediation-playbooks.md` | Remediating — stack-specific fix procedures with before/after code and test examples |
| `references/mitre-attack-mapping.md` | Triaging or investigating — map findings to MITRE ATT&CK techniques for web applications |
| `references/hardening-checklist.md` | Hardening — stack-adaptive security checklist across 10 categories |
| `references/incident-report-templates.md` | Reporting — markdown templates for audit reports, incident reports, post-mortems, and vulnerability reports |
