# GitHub PR Patterns

## PR Review Checklist

When reviewing a PR, check:

1. **Code Quality** — Does the code follow project conventions (Pint, PHPStan)?
2. **Tests** — Are there tests? Do they cover edge cases?
3. **Security** — No SQL injection, XSS, or leaked secrets?
4. **Performance** — No N+1 queries, unnecessary loops, or memory leaks?
5. **Database** — Are migrations reversible? Any data loss risk?
6. **Breaking Changes** — Will this break existing API consumers?
7. **Documentation** — Are changes documented if user-facing?

## PR Review Workflow

### Reviewing with gh

```bash
# View PR overview
gh pr view 42

# View the diff
gh pr diff 42

# Check CI status
gh pr checks 42

# Check out PR locally for testing
gh pr checkout 42

# Run tests locally then approve
gh pr review 42 --approve --body "Tested locally — all green"

# Request changes with specific feedback
gh pr review 42 --request-changes --body "$(cat <<'EOF'
## Issues Found

1. **SQL Injection** in `UserController@search` (line 45) — use parameterized query
2. **Missing validation** in `StoreRequest` — `email` field not validated
3. **N+1 query** in `index()` — add `->with('roles')` to the query

Please fix these before merge.
EOF
)"
```

### Line-level Comments via API

```bash
# Add a review comment on a specific line
gh api repos/{owner}/{repo}/pulls/42/comments --method POST \
  --field body="This should use \`Hash::make()\` instead of \`md5()\`" \
  --field commit_id="abc123" \
  --field path="app/Http/Controllers/UserController.php" \
  --field line=45
```

## Merge Policies

### Squash Merge (Recommended)

Best for feature branches — produces a clean main branch history.

```bash
# Configure repo to only allow squash merges
gh repo edit \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge

# Squash merge with auto-delete
gh pr merge 42 --squash --delete-branch
```

### Auto-merge

Enable auto-merge to automatically merge when all checks pass:

```bash
# Enable auto-merge on a PR
gh pr merge 42 --squash --auto --delete-branch

# Disable auto-merge
gh pr merge 42 --disable-auto
```

### Required Status Checks

Configure which checks must pass before merge:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci", "tests", "phpstan"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null
}
EOF
```

## CODEOWNERS

Create `.github/CODEOWNERS` for automatic review assignment:

```
# Default owner for everything
* @team-lead

# Frontend
resources/views/ @frontend-team
resources/js/ @frontend-team
resources/css/ @frontend-team

# API
app/Http/Controllers/Api/ @api-team
routes/api.php @api-team

# Database
database/ @backend-team

# CI/CD
.github/ @devops-team

# Security-sensitive files
config/auth.php @security-team
app/Policies/ @security-team
```

## Draft PR Workflow

```bash
# Create as draft
gh pr create --title "wip: new feature" --draft

# Mark ready for review
gh pr ready 42

# Convert back to draft
gh api repos/{owner}/{repo}/pulls/42 --method PATCH --field draft=true
```

## Stacked PRs Workflow

For large features, split into stacked PRs:

```bash
# PR 1: base changes (targets main)
gh pr create --base main --title "feat(auth): add SSO model layer"

# PR 2: builds on PR 1 (targets PR 1's branch)
gh pr create --base feature/sso-models --title "feat(auth): add SSO controllers"

# PR 3: builds on PR 2
gh pr create --base feature/sso-controllers --title "feat(auth): add SSO views"
```

Merge from bottom to top. After merging PR 1, retarget PR 2 to main:

```bash
gh pr edit 43 --base main
```

## PR Metrics

```bash
# Time to merge for recent PRs
gh pr list --state merged --json number,title,createdAt,mergedAt \
  --jq '.[] | "\(.number) \(.title) Created: \(.createdAt) Merged: \(.mergedAt)"'

# PRs waiting for review
gh pr list --search "review:required" --json number,title,createdAt \
  --jq '.[] | "\(.number) \(.title) Waiting since: \(.createdAt)"'
```
