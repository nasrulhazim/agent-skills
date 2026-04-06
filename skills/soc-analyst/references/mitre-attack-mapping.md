# MITRE ATT&CK Mapping — Web Application Techniques

Read this file when triaging or investigating security findings to categorize them using the MITRE ATT&CK framework. This mapping focuses on techniques most relevant to web applications across any stack.

---

## Initial Access

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1190 | Exploit Public-Facing Application | SQL injection, RCE, file upload exploits, deserialization attacks against application routes | Unusual query strings, POST bodies with injection payloads, 500 errors from malformed input |
| T1078 | Valid Accounts | Credential stuffing, compromised API tokens, leaked environment credentials | Multiple failed logins from diverse IPs, successful login from unusual location, API usage patterns change |
| T1133 | External Remote Services | Exposed admin panels, debug tools, or monitoring dashboards in production | Access to debug/admin routes from external IPs (e.g., `/telescope`, `/admin`, `/debug`, `/_profiler`, `/graphiql`) |

### Stack-Specific Exposure Points

| Stack | Common Exposed Services |
|---|---|
| Laravel | Telescope (`/telescope`), Horizon (`/horizon`), Nova, Debugbar (`/_debugbar`) |
| Django | Debug toolbar, admin (`/admin/`), Silk profiler |
| Rails | Web console, Active Admin, Sidekiq dashboard |
| Express/Node | GraphiQL, Swagger UI, Bull Board, debug endpoints |
| Spring Boot | Actuator endpoints (`/actuator/*`), H2 console |
| .NET | Swagger UI, Elmah, Hangfire dashboard |

---

## Execution

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1059.004 | Unix Shell | Command injection via shell execution functions (`exec`, `system`, `subprocess`, `child_process`, `os/exec`) | Shell metacharacters in request parameters (`;`, `|`, `&&`, backticks, `$()`) |
| T1059.007 | JavaScript | Stored/reflected XSS executing in victim browsers | `<script>` tags in database fields, event handlers in user input (`onload=`, `onerror=`) |
| T1203 | Exploitation for Client Execution | XSS payloads delivered via stored content (comments, profiles, messages) | JavaScript in user-generated content fields, encoded script payloads |

### Stack-Specific Command Execution Risks

| Stack | Dangerous Functions |
|---|---|
| PHP | `exec()`, `shell_exec()`, `system()`, `passthru()`, `popen()`, `proc_open()`, backticks |
| Node.js | `child_process.exec()`, `child_process.spawn({shell:true})`, `eval()` |
| Python | `os.system()`, `subprocess.call(shell=True)`, `eval()`, `exec()` |
| Ruby | `` `backticks` ``, `system()`, `exec()`, `%x{}`, `IO.popen()`, `Kernel.open()` |
| Go | `exec.Command()` with shell, `os/exec` with unsanitized args |
| Java | `Runtime.exec()`, `ProcessBuilder` with shell, OGNL/SpEL injection |

---

## Persistence

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1505.003 | Web Shell | Malicious file uploaded via upload vulnerability, placed in public/static directories | New executable files in upload directories, files containing `eval()`, `base64_decode()`, `exec()` |
| T1098 | Account Manipulation | Mass assignment or direct DB manipulation to escalate privileges, create admin accounts | Unexpected role/permission changes in users table, new admin accounts |
| T1136 | Create Account | Attacker creates privileged account via exposed registration, mass assignment, or direct DB access | New accounts with elevated roles, accounts created outside normal registration flow |
| T1053.003 | Cron / Scheduled Tasks | Malicious scheduled task, cron job, or background worker injected | New or modified cron entries, unexpected scheduled commands, modified task scheduler config |

### Stack-Specific Web Shell Patterns

| Stack | Shell Extension / Pattern |
|---|---|
| PHP | `.php` files with `eval()`, `base64_decode()`, `assert()` |
| Node.js | `.js` files with `child_process`, reverse shell connections |
| Python | `.py` files with `subprocess`, `os.system()`, pickled objects |
| Ruby | `.rb` files with `system()`, ERB template injection |
| Java | `.jsp`/`.war` files with `Runtime.exec()` |
| .NET | `.aspx`/`.ashx` files with `Process.Start()` |

---

## Privilege Escalation

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1548 | Abuse Elevation Control | IDOR to access admin resources, bypassing authorization middleware/guards, role manipulation | Access to admin routes by non-admin users, authorization failures followed by success |
| T1068 | Exploitation for Privilege Escalation | Exploiting deserialization, template injection, or framework vulnerability for elevated access | Serialized objects in requests, SSTI payloads, unusual class instantiations in logs |

---

## Defense Evasion

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1562.001 | Disable or Modify Tools | Disabling CSRF protection, removing auth middleware, enabling debug mode in production | Changes to middleware/security config, debug mode enabled in production env |
| T1070.001 | Clear Logs | Clearing or modifying application log files | Log file truncation, gaps in log timeline, missing entries for known events |
| T1027 | Obfuscated Files or Information | Base64-encoded payloads, hex-encoded scripts in uploaded files, encoded eval chains | Encoded execution functions in uploaded files, hex/base64 strings in request bodies |

---

## Credential Access

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1110.001 | Password Guessing | Brute force against login endpoints | High volume of failed login attempts from single IP |
| T1110.003 | Password Spraying | Common passwords tested against many accounts | Failed logins across multiple accounts within short timeframe |
| T1552.001 | Credentials in Files | Hardcoded secrets in source, `.env`/config exposed via path traversal or misconfiguration | Secrets in source code, env files accessible via web, API keys in git history |
| T1552.004 | Private Keys | Exposed application secret keys, JWT signing keys, OAuth private keys | Secret keys in git history, unencrypted key files in repository |
| T1539 | Steal Web Session Cookie | Session hijacking via XSS, insecure cookie settings (no Secure/HttpOnly/SameSite) | Session ID changes without logout, sessions used from multiple IPs simultaneously |

### Stack-Specific Credential Locations

| Stack | Common Secret Locations |
|---|---|
| Laravel/PHP | `.env` (`APP_KEY`, DB creds), `config/*.php` |
| Node.js | `.env`, `config/*.json`, `package.json` scripts |
| Python/Django | `.env`, `settings.py` (`SECRET_KEY`, DB creds), `config.yaml` |
| Ruby/Rails | `.env`, `config/credentials.yml.enc`, `config/secrets.yml`, `config/database.yml` |
| Go | `.env`, config files, hardcoded in source |
| Java/Spring | `application.properties`, `application.yml`, `.env` |
| .NET | `appsettings.json`, `web.config`, user secrets |

---

## Discovery

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1083 | File and Directory Discovery | Path traversal to enumerate files, directory listing enabled | Requests with `../` sequences, access to `/.env`, `/.git/`, `/storage/`, `/static/` |
| T1087 | Account Discovery | Enumeration of users via API endpoints, password reset timing, registration errors | Sequential ID requests to user endpoints, different response times for valid vs invalid emails |
| T1046 | Network Service Scanning | Port scanning, probing debug/admin endpoints | Rapid requests to multiple paths, access to admin/debug/monitoring routes |

---

## Collection

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1530 | Data from Cloud Storage | Accessing cloud storage buckets via misconfigured URLs or exposed signed URLs | Direct storage URL access patterns, probing of expired signed URLs |
| T1213 | Data from Information Repositories | SQL injection to dump database, IDOR to access other users' data | Large result sets in query logs, sequential access to resources by incrementing IDs |

---

## Exfiltration

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1041 | Exfiltration Over C2 Channel | Data sent to attacker via SSRF, DNS exfiltration via outbound requests | Outbound HTTP requests to unusual domains, DNS queries with encoded data subdomains |
| T1567 | Exfiltration Over Web Service | Data extracted via API endpoints, exported CSV/PDF with excessive data | Bulk data exports, API responses larger than typical, unusual export frequency |

---

## Impact

| Technique ID | Name | Web App Manifestation | Detection Indicators |
|---|---|---|---|
| T1485 | Data Destruction | SQL injection for `DROP TABLE`/`DELETE`, file system deletion via RCE | Destructive SQL in query logs, mass data loss, table/collection structure changes |
| T1486 | Data Encrypted for Impact | Ransomware via RCE, encrypting storage/upload files | Encrypted files in storage, ransom notes, unusual file extensions |
| T1565.001 | Stored Data Manipulation | SQL injection to modify records, mass assignment to alter data | Unexpected data changes, audit log discrepancies, modified financial records |
| T1499.003 | Application Exhaustion Flood | DDoS against resource-heavy endpoints (search, reports, file processing, GraphQL) | Spike in requests to specific endpoints, queue backlog, memory/CPU exhaustion |

---

## Quick Reference: Top 10 Techniques for Web Applications

| Rank | Technique | Most Common Attack Vector | Priority |
|---|---|---|---|
| 1 | T1190 — Exploit Public-Facing App | SQL injection, file upload, deserialization, SSTI | P1 |
| 2 | T1078 — Valid Accounts | Credential stuffing, leaked env secrets | P1 |
| 3 | T1059.007 — JavaScript (XSS) | Stored XSS in user content | P2 |
| 4 | T1548 — Abuse Elevation Control | IDOR, missing authorization | P1 |
| 5 | T1505.003 — Web Shell | Unrestricted file upload | P1 |
| 6 | T1098 — Account Manipulation | Mass assignment, privilege escalation | P2 |
| 7 | T1110 — Brute Force | No rate limiting on auth endpoints | P2 |
| 8 | T1552 — Unsecured Credentials | Hardcoded secrets, exposed env files | P1 |
| 9 | T1083 — File Discovery | Path traversal, directory listing | P2 |
| 10 | T1565 — Data Manipulation | SQL injection data modification | P1 |
