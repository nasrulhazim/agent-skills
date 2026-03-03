# GitHub Issue Templates

Templates for creating GitHub issues from log analysis findings.
Each template targets a specific error category.

---

## Generic Bug Issue

```markdown
## Summary

[1-2 sentence description of the problem discovered in production logs.]

## Error

\`\`\`
[Actual error message from logs]
\`\`\`

**[X] errors** from [start date] to [end date].

## Impact

- [What feature/functionality breaks or degrades]
- [Who is affected — users, admins, integrations]
- [Data impact — any data loss or inconsistency risk]

## Root Cause

[Known or suspected root cause based on log analysis.]

## Action Items

- [ ] [First step to fix]
- [ ] [Verification step]
- [ ] [Prevention step — monitoring, tests, etc.]

## Source

Production log analysis: `[log file name]` ([date range])
```

**Labels:** `bug`, `log-analysis`, priority label

---

## Database Issue

```markdown
## Summary

[Description of database error discovered in production logs.]

## Error

\`\`\`
SQLSTATE[XXXXX]: [Error description]
(Connection: [pgsql/mysql], SQL: [truncated query])
\`\`\`

**[X] errors** on [date], concentrated between [time range].

## Tables Affected

| Table | Operation | Count |
|---|---|---|
| `table_name` | UPDATE/INSERT/DELETE | X |

## Impact

- [What data operations failed]
- [Whether any data was lost or inconsistent]
- [Duration of the incident]

## Possible Causes

- [Cause 1 — e.g., replication failover]
- [Cause 2 — e.g., maintenance window]
- [Cause 3 — e.g., disk full]

## Action Items

- [ ] Investigate database infrastructure / replication config
- [ ] Add monitoring/alerting for [specific condition]
- [ ] Verify data integrity for affected records
- [ ] Review if any data loss occurred during the incident

## Source

Production log analysis: `[log file name]` (lines around [line number])
```

**Labels:** `bug`, `log-analysis`, `infrastructure`, priority label

---

## Authentication / LDAP Issue

```markdown
## Summary

[Description of authentication or LDAP error.]

## Error

\`\`\`
[Error message]
\`\`\`

**[X] errors** from [date range].

## Affected Users

| User/Email | Occurrences | Notes |
|---|---|---|
| user@example.com | X | [context] |

## Root Cause

[Analysis of why auth is failing — config issue, data sync, password corruption, etc.]

## Action Items

- [ ] [Specific fix for the auth issue]
- [ ] [Verification step]
- [ ] [Prevention — monitoring, alerting, etc.]

## Source

[Service class or component]: `App\Services\[ServiceName]`
```

**Labels:** `bug`, `log-analysis`, priority label

---

## Permission / Filesystem Issue

```markdown
## Summary

[Description of file permission errors causing application failures.]

## Errors

| File | Error | Count |
|---|---|---|
| `path/to/file.php` | Permission denied | X |

## Cascading Failures

[If permissions caused other errors, list the chain:]

1. `[root file]` permission denied ([X] errors)
2. Cascades into: `[dependent error]` ([Y] errors)
3. Result: [user-facing impact]

## Root Cause

[Deployment process, artisan command as wrong user, etc.]

## Action Items

- [ ] Fix file ownership: `chown -R www-data:www-data /path/to/app`
- [ ] Update deployment scripts to set correct permissions
- [ ] Verify fix — confirm no more permission errors
- [ ] [Optional] Add deployment smoke test for file readability

## Source

Production log analysis: `[log files]` ([dates])
```

**Labels:** `bug`, `log-analysis`, `infrastructure`, priority label

---

## Data Sync / Identity Issue

```markdown
## Summary

[Description of data synchronization gap between systems.]

## Error

\`\`\`
[Error message — e.g., "user not found in Keycloak"]
\`\`\`

**[X] errors** across [Y] days ([date range]).

## Affected Records

| Identifier | System A Status | System B Status | Occurrences |
|---|---|---|---|
| user@example.com | Exists | Missing | X |

## Root Cause

Data synchronization gap between [System A] and [System B].
Records exist in one system but not the other.

## Action Items

- [ ] Audit and reconcile records between both systems
- [ ] Create missing records or update mappings
- [ ] Add a reconciliation script/command for ongoing maintenance
- [ ] Consider adding user-facing messaging when sync fails

## Source

`[Service class]` calling [API endpoint or database]
```

**Labels:** `bug`, `log-analysis`, priority label

---

## Configuration Issue

```markdown
## Summary

[Description of missing or incorrect configuration.]

## Error

\`\`\`
[Error message]
\`\`\`

## Missing/Incorrect Config

| Config | Expected | Actual |
|---|---|---|
| `CONFIG_KEY` | `expected_value` | Missing / Wrong value |

## Impact

[What breaks when this config is missing]

## Action Items

- [ ] Set `CONFIG_KEY=value` in `.env`
- [ ] Verify the fix resolves the error
- [ ] Add config validation to deployment checklist

## Source

Production log: `[log file]`
```

**Labels:** `bug`, `log-analysis`, priority label (+ `infrastructure` if env/server config)

---

## Enhancement / Improvement Issue

```markdown
## Summary

[Description of suggested improvement based on log analysis patterns.]

## Observations

- [Pattern 1 observed in logs — e.g., "20,000 failed login attempts"]
- [Pattern 2 — e.g., "same user retrying 1,000 times with different case"]
- [Pattern 3 — e.g., "no rate limiting detected"]

## Suggestions

- [ ] [Improvement 1 — e.g., "Implement case-insensitive username matching"]
- [ ] [Improvement 2 — e.g., "Add rate-limiting after N failed attempts"]
- [ ] [Improvement 3 — e.g., "Add clearer error messaging"]

## Source

Production log analysis: [date range]
```

**Labels:** `enhancement`, `log-analysis`, priority label

---

## Label Setup Commands

Run these to create standard labels in a repo:

```bash
REPO="org/repo-name"
gh label create "P1-critical" --description "Critical - fix immediately" --color "B60205" -R "$REPO"
gh label create "P2-high" --description "High priority - fix this week" --color "D93F0B" -R "$REPO"
gh label create "P3-medium" --description "Medium priority - fix this sprint" --color "FBCA04" -R "$REPO"
gh label create "P4-low" --description "Low priority - backlog" --color "0E8A16" -R "$REPO"
gh label create "log-analysis" --description "Discovered from production log analysis" --color "5319E7" -R "$REPO"
gh label create "infrastructure" --description "Server, DB, deployment infrastructure" --color "006B75" -R "$REPO"
```

## Project Board Setup

```bash
# Create org-level project
gh project create --owner ORG_NAME --title "App Name - Issue Tracker"

# Add issues to project
gh project item-add PROJECT_NUMBER --owner ORG_NAME --url "https://github.com/org/repo/issues/NUMBER"
```
