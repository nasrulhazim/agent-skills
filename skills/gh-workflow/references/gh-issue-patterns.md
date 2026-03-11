# GitHub Issue Patterns

## Advanced Search Queries

Use `gh search issues` for cross-repo searches and `gh issue list` for single-repo filtering.

### Search Syntax

```bash
# Issues mentioning a keyword, sorted by most recently updated
gh search issues "SSO login" --repo owner/repo --sort updated --order desc

# Issues by author
gh search issues --author "username" --repo owner/repo

# Issues created in a date range
gh search issues --created ">2026-01-01" --repo owner/repo

# Issues with no assignee (needs triage)
gh issue list --search "no:assignee" --label "status:triage"

# Issues with no labels
gh issue list --search "no:label"

# Issues not updated in 30 days (stale)
gh search issues --updated "<2026-02-01" --state open --repo owner/repo

# Issues by milestone
gh issue list --milestone "v2.0" --state open
```

### JSON Output for Scripting

```bash
# Export issues as JSON
gh issue list --json number,title,labels,assignees,createdAt,updatedAt \
  --jq '.[] | {number, title, labels: [.labels[].name], assignees: [.assignees[].login]}'

# Count issues by label
gh issue list --json labels \
  --jq '[.[].labels[].name] | group_by(.) | map({label: .[0], count: length}) | sort_by(.count) | reverse'

# Get issue body
gh issue view 123 --json body --jq '.body'
```

## Bulk Operations

### Bulk Close Stale Issues

```bash
# Close all issues with "wontfix" label
gh issue list --label "wontfix" --state open --json number --jq '.[].number' | \
  xargs -I {} gh issue close {} --reason "not planned" --comment "Closing as won't fix."

# Close issues older than 90 days with no activity
gh issue list --search "updated:<2025-12-01" --state open --json number --jq '.[].number' | \
  xargs -I {} gh issue close {} --reason "not planned" --comment "Closing due to inactivity. Reopen if still relevant."
```

### Bulk Label Issues

```bash
# Add a label to all issues matching a search
gh issue list --search "SSO" --json number --jq '.[].number' | \
  xargs -I {} gh issue edit {} --add-label "feature:sso"
```

### Bulk Transfer Issues

```bash
# Transfer issues to another repo (one at a time via API)
gh api repos/{owner}/{source}/issues/123/transfer \
  --method POST \
  --field new_repository="target-repo"
```

## Issue Templates — Config File

Create `.github/ISSUE_TEMPLATE/config.yml` to add external links and control the template chooser:

```yaml
blank_issues_enabled: false
contact_links:
  - name: Documentation
    url: https://docs.example.com
    about: Check the docs before opening an issue
  - name: Discord Community
    url: https://discord.gg/example
    about: Ask questions in our Discord server
```

## Linking Issues to PRs

Reference issues in PR descriptions to auto-close them on merge:

```markdown
## Related Issues

Closes #123
Fixes #456
Resolves #789
```

Keywords that auto-close: `close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`, `resolves`, `resolved`.

## Issue Pin and Lock

```bash
# Pin an issue (max 3 per repo)
gh api repos/{owner}/{repo}/issues/123/pin --method POST

# Lock an issue
gh api repos/{owner}/{repo}/issues/123/lock --method PUT \
  --field lock_reason="resolved"

# Unlock an issue
gh api repos/{owner}/{repo}/issues/123/lock --method DELETE
```

## Milestones

```bash
# Create a milestone
gh api repos/{owner}/{repo}/milestones --method POST \
  --field title="v2.0" \
  --field description="Major release with SSO support" \
  --field due_on="2026-06-01T00:00:00Z"

# List milestones
gh api repos/{owner}/{repo}/milestones --jq '.[] | "\(.number) \(.title) \(.open_issues)/\(.closed_issues)"'

# Close a milestone
gh api repos/{owner}/{repo}/milestones/1 --method PATCH --field state="closed"
```
