# Status Report Template

Every status report is a TLDR plus tables. No prose paragraphs, no doc-by-doc summaries.

```markdown
# <Project> — Status as at <YYYY-MM-DD>

**TLDR:** <One sentence: where the project actually is.> <One sentence: the single
largest unbuilt piece.> <One sentence: the recommended next move.>

## Workstreams

| Workstream | State | Evidence | Blocked by |
|---|---|---|---|
| Auth & tenancy | Done | `app/Policies/`, 24 passing tests | — |
| Billing | In flight | #142, #147 open; `BillingService` stubbed | — |
| Reporting | Not started | no code, no issues | Billing schema |
| Go-to-market | Deliberately last | — | Sequenced, not slipped |

## Open issues that are actually already built

| Issue | Why it can close |
|---|---|
| #118 "Add rate limiting" | `bootstrap/app.php:41` — `throttle:api` already applied |

## Stale planning docs

| Doc | Last touched | Why it is stale |
|---|---|---|
| `documentation/03-planning/02-triage.md` | 2026-03-11 | Counts predate 30+ issues closed since |

## Recommended next move

<One paragraph, at most. Name the specific issue or file to start with.>
```

## Rules for filling it in

- **Evidence column is mandatory.** A file path, an issue number, or a test count. "Looks done" is not evidence.
- **Grep the code before writing "not started".** Planning docs lie; the repo does not.
- **Check issue dates against `gh issue list`** rather than trusting a triage doc's totals.
- **Separate environmental blockers from code blockers** — only one of them is fixed by working harder.
- **A closed milestone is not a finished phase** if issues were moved out of it.
