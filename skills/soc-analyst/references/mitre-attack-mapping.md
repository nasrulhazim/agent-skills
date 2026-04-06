# MITRE ATT&CK Mapping — Web Application Techniques for Laravel

Read this file when triaging or investigating security findings to categorize them using the MITRE ATT&CK framework. This mapping focuses on techniques most relevant to Laravel/PHP web applications.

---

## Initial Access

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1190 | Exploit Public-Facing Application | SQL injection, RCE, file upload exploits against Laravel routes | Unusual query strings, POST bodies with injection payloads, 500 errors from malformed input |
| T1078 | Valid Accounts | Credential stuffing, compromised API tokens, leaked `.env` credentials | Multiple failed logins from diverse IPs, successful login from unusual location, API usage patterns change |
| T1133 | External Remote Services | Exposed Telescope, Horizon, Nova, or Debugbar in production | Access to `/telescope`, `/horizon`, debug routes from external IPs |

---

## Execution

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1059.004 | Unix Shell | Command injection via `exec()`, `shell_exec()`, `system()`, `Process` | Shell metacharacters in request parameters (`;`, `|`, `&&`, backticks) |
| T1059.007 | JavaScript | Stored/reflected XSS executing in victim browsers | `<script>` tags in database fields, event handlers in user input (`onload=`, `onerror=`) |
| T1203 | Exploitation for Client Execution | XSS payloads delivered via stored content (comments, profiles, messages) | JavaScript in user-generated content fields, encoded script payloads (`&#x3C;script&#x3E;`) |

---

## Persistence

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1505.003 | Web Shell | PHP file uploaded via file upload vulnerability, placed in `public/` or `storage/` | New `.php` files in upload directories, files with `eval()`, `base64_decode()`, `system()` |
| T1098 | Account Manipulation | Mass assignment to escalate privileges (`is_admin=1`), create unauthorized accounts | Unexpected role changes in users table, new admin accounts, modified `$guarded`/`$fillable` |
| T1136 | Create Account | Attacker creates admin account via exposed registration or mass assignment | New accounts with admin roles, accounts created outside normal registration flow |
| T1053.003 | Cron | Malicious Laravel scheduled task or modified `app/Console/Kernel.php` | New or modified cron entries, unexpected artisan commands in scheduler |

---

## Privilege Escalation

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1548 | Abuse Elevation Control | IDOR to access admin resources, bypassing Gates/Policies, role manipulation | Access to `/admin/*` routes by non-admin users, policy authorization failures followed by success |
| T1068 | Exploitation for Privilege Escalation | Exploiting deserialization or framework vulnerability for elevated access | Serialized PHP objects in requests, unusual class instantiations in logs |

---

## Defense Evasion

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1562.001 | Disable or Modify Tools | Disabling CSRF middleware, removing auth middleware, modifying `.env` to enable debug | Changes to `Kernel.php` middleware stack, `APP_DEBUG=true` in production |
| T1070.001 | Clear Linux Logs | Clearing or modifying `storage/logs/laravel.log` | Log file truncation, gaps in log timeline, missing entries for known events |
| T1027 | Obfuscated Files or Information | Base64-encoded payloads, hex-encoded PHP in uploaded files | `base64_decode` in uploaded files, hex strings in request bodies |

---

## Credential Access

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1110.001 | Password Guessing | Brute force against `/login`, `/api/auth/login` | High volume of failed login attempts from single IP, distributed login attempts against single account |
| T1110.003 | Password Spraying | Common passwords tested against many accounts | Failed logins across multiple accounts within short timeframe, same password hash patterns |
| T1552.001 | Credentials in Files | Hardcoded secrets in source, `.env` exposed via path traversal or misconfiguration | Secrets in `config/` PHP files, `.env` accessible via web, API keys in git history |
| T1552.004 | Private Keys | Exposed `APP_KEY`, JWT secrets, OAuth private keys | `APP_KEY` in git history, unencrypted key files in repository |
| T1539 | Steal Web Session Cookie | Session hijacking via XSS, insecure cookie settings | Session ID changes without logout, sessions used from multiple IPs simultaneously |

---

## Discovery

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1083 | File and Directory Discovery | Path traversal to enumerate files, directory listing enabled | Requests with `../` sequences, access to `/storage`, `/.env`, `/.git/` |
| T1087 | Account Discovery | Enumeration of users via API endpoints, password reset timing, registration errors | Sequential ID requests to `/api/users/1`, `/api/users/2`, different response times for valid vs invalid emails |
| T1046 | Network Service Scanning | Port scanning against the server, probing Laravel debug endpoints | Rapid requests to multiple paths, access to `/telescope`, `/_debugbar`, `/horizon` |

---

## Collection

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1530 | Data from Cloud Storage | Accessing S3 buckets via misconfigured storage URLs, exposed signed URLs | Direct S3 URL access patterns, expired but previously valid signed URLs being probed |
| T1213 | Data from Information Repositories | SQL injection to dump database, IDOR to access other users' data | Large result sets in query logs, sequential access to resources by incrementing IDs |

---

## Exfiltration

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1041 | Exfiltration Over C2 Channel | Data sent to attacker via SSRF, DNS exfiltration via vulnerable `gethostbyname()` calls | Outbound HTTP requests to unusual domains, DNS queries with encoded data subdomains |
| T1567 | Exfiltration Over Web Service | Data extracted via API endpoints, exported CSV/PDF with excessive data | Bulk data exports, API responses larger than typical, unusual export frequency |

---

## Impact

| Technique ID | Name | Laravel Manifestation | Detection Indicators |
|---|---|---|---|
| T1485 | Data Destruction | SQL injection used for `DROP TABLE`, `DELETE FROM` without WHERE | Destructive SQL in query logs, mass data loss, table structure changes |
| T1486 | Data Encrypted for Impact | Ransomware via RCE, encrypting storage files | Encrypted files in storage, ransom notes, unusual file extensions |
| T1565.001 | Stored Data Manipulation | SQL injection to modify records, mass assignment to alter data | Unexpected data changes, audit log discrepancies, modified financial records |
| T1499.003 | Application Exhaustion Flood | DDoS against resource-heavy endpoints (search, reports, file processing) | Spike in requests to specific endpoints, queue backlog, memory/CPU exhaustion |

---

## Quick Reference: Top 10 Techniques for Laravel Apps

| Rank | Technique | Most Common Attack Vector | Priority |
|---|---|---|---|
| 1 | T1190 — Exploit Public-Facing App | SQL injection, file upload, deserialization | P1 |
| 2 | T1078 — Valid Accounts | Credential stuffing, leaked `.env` | P1 |
| 3 | T1059.007 — JavaScript (XSS) | Stored XSS in user content | P2 |
| 4 | T1548 — Abuse Elevation Control | IDOR, missing policies | P1 |
| 5 | T1505.003 — Web Shell | Unrestricted file upload | P1 |
| 6 | T1098 — Account Manipulation | Mass assignment privilege escalation | P2 |
| 7 | T1110 — Brute Force | No rate limiting on auth | P2 |
| 8 | T1552 — Unsecured Credentials | Hardcoded secrets, exposed `.env` | P1 |
| 9 | T1083 — File Discovery | Path traversal | P2 |
| 10 | T1565 — Data Manipulation | SQL injection data modification | P1 |
