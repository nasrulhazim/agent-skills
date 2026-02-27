# Support Workflow — Agent Skills

## Issue Intake

All support requests go through GitHub Issues.
Use the issue templates provided:

- **Bug Report** — skill not working as expected
- **Feature Request** — new skill or enhancement
- **Question** — usage or how-to

## Triage Flow

```text
New Issue Opened
      |
      v
Is it a duplicate? -- Yes --> Close, link original
      | No
      v
Apply severity label (P1-P4)
      |
      v
Assign to milestone or backlog
      |
      v
Respond within SLA window (see 03-sla.md)
      |
      v
Implement fix -> PR -> merge -> close issue
```

## Labels

| Label | Meaning |
| --- | --- |
| `bug` | Confirmed defect in a skill |
| `enhancement` | New skill or improvement |
| `question` | Usage question |
| `duplicate` | Already reported |
| `wontfix` | Out of scope or by design |
| `good first issue` | For new contributors |
| `P1` through `P4` | Severity (see SLA doc) |

## Response Guidelines

- Always acknowledge within the SLA window, even
  if just to say "investigating"
- Use labels before commenting
- If closing as `wontfix`, explain why briefly
  and respectfully
- Link related issues or PRs when available

## Escalation

If an issue requires changes to the skill format
or CLAUDE.md conventions, escalate to a discussion
before committing to a fix direction.
