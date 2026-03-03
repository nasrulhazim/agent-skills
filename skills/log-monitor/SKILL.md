---
name: log-monitor
metadata:
  compatible_agents: [claude-code]
  tags: [monitoring, logs, error-analysis, laravel, production, debugging, github-issues, triage]
description: >
  Production log analysis and issue tracking skill — analyzes Laravel log files
  (daily or single), categorizes errors by type and severity, generates structured
  reports (summary, error-type, todo per day and per project), creates prioritized
  GitHub issues with proper labels, and adds them to a GitHub Project board for
  unified tracking across multiple repositories. Use this skill whenever the user
  asks to analyze production logs, triage errors, monitor application health, create
  issues from log findings, or set up error tracking — including: "analyze these logs",
  "check production errors", "triage the errors", "buat report dari log ni",
  "tengok error apa dalam production", "summarize the log files", "create issues
  from logs", "monitor app health", "apa error dalam server ni", or "tolong check
  log production".
---

# Production Log Monitor & Issue Tracker

Analyzes Laravel production log files, categorizes errors, generates structured
reports, and creates GitHub issues with proper labels and project board tracking.

**Works with:** Single log files, daily log directories, or multi-project log collections.

---

## Trigger Detection

Activate when:
- User provides log files or points to a directory containing `.log` files
- User asks to analyze production errors, triage logs, or monitor app health
- User says "check log", "analyze errors", "tengok production", "apa error ni"

Before generating anything:
1. **Identify all log files** — scan the target directory for `*.log` files
2. **Detect the application** — look for Laravel log format (`[YYYY-MM-DD HH:MM:SS] environment.LEVEL:`)
3. **Check for existing reports** — avoid duplicating previous analysis
4. **Identify the GitHub repo** — check for `.git` remote if issue creation is needed

---

## Analysis Process

### Phase 1: Log Discovery

Scan the target directory and identify:
- Log file count and date range
- Total file sizes (to plan reading strategy)
- Any backup files (`.bak`, `.back.*`) that should be included

### Phase 2: Error Extraction (Parallel by file)

For each log file, extract:

| Field | Description |
|---|---|
| Timestamp | When the error occurred |
| Level | ERROR, WARNING, CRITICAL, EMERGENCY |
| Exception class | The PHP exception type |
| Message | The error message (first line) |
| Stack trace | Key files/classes involved |
| Context | User IDs, request data, SQL queries |
| Frequency | How many times this exact error appears |

**Grouping rules:**
- Same exception class + same message = same error (count occurrences)
- Same exception class + different message = separate errors
- Stack trace differences within same error = note variants

### Phase 3: Categorization

Assign each unique error to a category:

| Category | Examples |
|---|---|
| **Authentication / LDAP** | Login failures, LDAP bind errors, OAuth state mismatch |
| **Database** | Query failures, connection errors, read-only transactions, migrations |
| **IAM / Identity Sync** | Keycloak sync, AD sync, user provisioning failures |
| **Filesystem / Permissions** | Permission denied, file not found, storage issues |
| **Application Code** | Unhandled exceptions, type errors, missing classes |
| **Configuration** | Missing config, env vars, service container resolution |
| **Infrastructure** | Memory exhaustion, timeout, queue failures, cache errors |
| **Routing / HTTP** | Route not found, 404/500 errors, CORS issues |
| **External Services** | API timeouts, webhook failures, third-party errors |

### Phase 4: Severity Assessment

Assign priority based on:

| Priority | Criteria |
|---|---|
| **P1-critical** | Data loss risk, security breach, complete feature broken, affecting many users |
| **P2-high** | Feature partially broken, recurring daily, user-facing errors |
| **P3-medium** | Edge cases, non-critical failures, code bugs with workarounds |
| **P4-low** | Cosmetic, single occurrence, expected user behaviour, enhancements |

---

## Output Structure

### Per-Project Reports

```
[project-name]/
├── summary.md          # Project-level summary with daily totals and links
├── error-type.md       # Consolidated unique error types with total counts
├── todo.md             # Prioritized action items, deduplicated
├── [YYYY-MM-DD]/       # One folder per day with log entries
│   ├── summary.md      # Daily overview, entry counts, key events
│   ├── error-type.md   # Detailed error breakdown for that day
│   └── todo.md         # Action items from that day's errors
```

### Multi-Project Summary

When analyzing multiple projects, create a top-level summary:

```
summary.md              # Cross-project summary with navigation links
├── [project-a]/...
├── [project-b]/...
```

---

## Report Templates

### Project summary.md

```markdown
# [Project Name] - Log Analysis Summary

**Period:** YYYY-MM-DD to YYYY-MM-DD
**Environment:** production at /path/to/app
**Total Entries:** X (Y errors + Z warnings)

## Daily Totals

| Date | Errors | Warnings | Key Event |
|---|---|---|---|
| YYYY-MM-DD | X | Y | Brief description |

## Error Distribution

| Category | Count | % | Status |
|---|---|---|---|
| Category name | X | Y% | ACTIVE / Likely resolved |

## Links

- [Error Types](error-type.md)
- [Action Items](todo.md)
- Daily: [Feb 23](2026-02-23/summary.md) | [Feb 24](2026-02-24/summary.md) | ...
```

### Daily summary.md

```markdown
# [Project Name] - YYYY-MM-DD

## Overview

- Total entries: X
- Errors: X
- Warnings: X

## Key Events

- Bullet points of what happened this day

## Error Distribution

| Error Type | Count |
|---|---|
| Error name | X |
```

### error-type.md

```markdown
# [Project Name] - Error Types - [DATE or "All Dates"]

## [Error Category]

### [Specific Error]

- **Count:** X
- **Level:** ERROR / WARNING / CRITICAL
- **Exception:** Full\Class\Name
- **Message:** Actual error message (truncated if long)
- **Affected:** Users, endpoints, or features affected
- **Stack:** Key files in stack trace
- **First seen:** YYYY-MM-DD
- **Last seen:** YYYY-MM-DD
- **Status:** Active / Resolved / Intermittent
```

### todo.md

```markdown
# [Project Name] - Action Items

## P1 - Critical

- [ ] Description of what needs to be fixed
  - Context: why this is critical
  - Affected: who/what is impacted

## P2 - High

- [ ] Description...

## P3 - Medium

- [ ] Description...

## P4 - Low

- [ ] Description...
```

---

## GitHub Issue Creation

When the user asks to create issues from findings:

### 1. Setup Labels

Create these labels in each target repo (skip if they exist):

| Label | Color | Description |
|---|---|---|
| `P1-critical` | `#B60205` | Critical - fix immediately |
| `P2-high` | `#D93F0B` | High priority - fix this week |
| `P3-medium` | `#FBCA04` | Medium priority - fix this sprint |
| `P4-low` | `#0E8A16` | Low priority - backlog |
| `log-analysis` | `#5319E7` | Discovered from production log analysis |
| `infrastructure` | `#006B75` | Server, DB, deployment infrastructure |

### 2. Create Issues

For each unique error that needs action, create a GitHub issue:

```markdown
## Summary

[1-2 sentence description of the problem]

## Error

\`\`\`
[Actual error message from logs]
\`\`\`

**[X] errors** from [date range].

## Impact

- [What breaks or degrades]
- [Who is affected]

## Affected [Users/Components]

[Table or list of specific affected items]

## Root Cause

[Known or suspected root cause]

## Action Items

- [ ] Step 1 to fix
- [ ] Step 2 to verify
- [ ] Step 3 to prevent recurrence

## Source

Production log analysis: `[log file name]` ([date range])
```

**Labels:** Always include `log-analysis` + appropriate priority label + `bug` or `enhancement` + `infrastructure` if applicable.

### 3. Create/Update Project Board

- Create a GitHub Project (org-level if multi-repo) or use existing one
- Add all created issues to the project board
- Title format: `[Org/Project] - Issue Tracker`

### 4. Label Existing Issues

When asked, also review existing unlabelled issues in the repos:
- Read each issue's title and body
- Assign appropriate priority label (P1-P4)
- Assign type label (`bug` or `enhancement`)
- Add to the project board

---

## Pattern Detection

Beyond individual errors, look for these patterns:

| Pattern | What to Look For |
|---|---|
| **Spikes** | Sudden increase in error count on specific days |
| **Recurring** | Same error appearing daily (e.g., cron jobs, sync tasks) |
| **Cascading** | One error causing a chain of other errors |
| **Time-correlated** | Errors clustered in a short time window (incident) |
| **User-correlated** | Same user triggering repeated errors (e.g., retry loops) |
| **Deployment-correlated** | Errors appearing right after a permission change or new code |
| **Resolution** | Errors that appear on some days then stop (likely fixed) |

Document patterns in the summary with a **Timeline of Events** section.

---

## Cross-Project Analysis

When analyzing multiple projects in the same ecosystem:

1. **Identify shared infrastructure issues** — same error patterns across projects (e.g., deployment permissions, LDAP/AD issues)
2. **Identify data sync gaps** — user/identity data inconsistencies between systems
3. **Identify shared recommendations** — fixes that would benefit all projects
4. Document these in the top-level `summary.md` under **Shared Infrastructure Concerns**

---

## Adapting to Log Formats

### Laravel (Primary)

```
[YYYY-MM-DD HH:MM:SS] environment.LEVEL: Message {"context"}
[stacktrace]
```

### Other Formats

If non-Laravel logs are detected, adapt the parsing:
- Look for timestamp patterns
- Identify level indicators (ERROR, WARN, INFO, DEBUG)
- Extract structured data from JSON or key=value formats
- Note the format in the report for context

---

## Writing Rules

1. **Be specific** — include actual error messages, user IDs, file paths
2. **Quantify everything** — error counts, affected users, time ranges
3. **Separate signal from noise** — expected user behaviour (wrong passwords) vs actual bugs
4. **Track resolution** — mark errors as "likely resolved" if they stop appearing
5. **Link to source** — reference specific log files and dates
6. **Prioritize actionably** — every todo item should be a clear, doable task
7. **Deduplicate across days** — same error on multiple days = one action item, not many
8. **Bilingual support** — respond in the user's language (English or Bahasa Malaysia)

---

## Reference Files

| File | Read When |
|---|---|
| `references/report-templates.md` | Starting a new analysis — get markdown templates for all report types |
| `references/error-patterns.md` | Categorizing errors — get common Laravel/PHP error patterns and their typical causes |
| `references/github-issue-templates.md` | Creating GitHub issues — get issue body templates for different error categories |
