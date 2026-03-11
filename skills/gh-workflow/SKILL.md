---
name: gh-workflow
metadata:
  compatible_agents: [claude-code]
  tags: [github, gh-cli, issues, pull-requests, actions, releases, repository, labels, secrets, projects, reports]
description: >
  GitHub CLI (gh) workflow automation for repository management, issue tracking, pull request
  workflows, GitHub Actions debugging, GitHub Projects (multi-repo boards with custom fields,
  views, and workflows), label management, secrets handling, and advanced API operations.
  Complements git-workflow by covering GitHub-specific operations via the gh CLI.
  Trigger: "create issue", "list PRs", "check workflow status", "manage labels", "set up repo",
  "manage secrets", "gh api", "review PR", "merge PR", "create release with assets",
  "debug actions", "fork repo", "create project", "manage project board", "add to project",
  "project status", "generate report", "repo report", "activity report", "contributor report".
  BM: "buat issue", "senarai PR", "semak status workflow",
  "urus label", "sediakan repo", "urus secrets", "semak PR", "gabung PR", "buat release",
  "debug actions", "fork repo", "buat project", "urus project board", "tambah ke project",
  "status project", "jana laporan", "laporan repo", "laporan aktiviti".
---

# GitHub CLI Workflow

Automate GitHub operations — from issue tracking to release management — using the `gh` CLI. Assumes `gh auth login` has been completed.

## Command Reference

| Command | Description |
|---|---|
| `/gh issue` | Create, list, search, triage, and close issues |
| `/gh pr` | Create PRs, request reviews, check status, merge |
| `/gh actions` | List, trigger, watch, and debug workflow runs |
| `/gh repo` | Create, clone, fork repos; manage settings and visibility |
| `/gh release` | Create releases with assets, manage downloads |
| `/gh labels` | Scaffold and sync label sets across repositories |
| `/gh secrets` | Manage repository and environment secrets and variables |
| `/gh project` | Create and manage GitHub Projects — boards, custom fields, views, multi-repo tracking |
| `/gh report` | Generate repository and project reports in HTML, JSON, or Markdown format |
| `/gh api` | Raw GitHub API calls for advanced operations |

---

## 1. `/gh issue` — Issue Management

Create, list, search, and triage GitHub issues.

### Create an Issue

```bash
gh issue create \
  --title "Bug: login fails with SSO" \
  --body "$(cat <<'EOF'
## Description
Login fails when using SSO provider.

## Steps to Reproduce
1. Click "Login with SSO"
2. Complete SSO flow
3. Redirected back with 500 error

## Expected Behaviour
User should be logged in and redirected to dashboard.

## Environment
- Laravel 12.x
- PHP 8.4
- Production
EOF
)" \
  --label "bug,priority:high" \
  --assignee "@me"
```

### List and Filter Issues

```bash
# List open issues assigned to me
gh issue list --assignee "@me" --state open

# Search issues with filters
gh issue list --label "bug" --state open --limit 50

# Search across repos with query
gh search issues "login SSO" --repo owner/repo --state open

# JSON output for scripting
gh issue list --json number,title,labels,assignees --jq '.[] | "\(.number) \(.title)"'
```

### Triage Workflow

```bash
# Add labels to an issue
gh issue edit 123 --add-label "priority:high,bug"

# Assign an issue
gh issue edit 123 --add-assignee "username"

# Add to a milestone
gh issue edit 123 --milestone "v2.0"

# Add a comment
gh issue comment 123 --body "Investigating — likely related to #120"

# Close with reason
gh issue close 123 --reason "completed" --comment "Fixed in #125"
```

### Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.yml`:

```yaml
name: Bug Report
description: Report a bug or unexpected behaviour
labels: ["bug", "triage"]
body:
  - type: textarea
    id: description
    attributes:
      label: Description
      description: What happened?
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: How can we reproduce this?
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Behaviour
      description: What should have happened?
    validations:
      required: true
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Critical (app unusable)
        - High (major feature broken)
        - Medium (workaround exists)
        - Low (cosmetic / minor)
    validations:
      required: true
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: "PHP version, Laravel version, OS, browser, etc."
```

Create `.github/ISSUE_TEMPLATE/feature_request.yml`:

```yaml
name: Feature Request
description: Suggest a new feature or improvement
labels: ["enhancement"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem
      description: What problem does this solve?
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      description: How should this work?
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      description: What other approaches did you consider?
```

See `references/gh-issue-patterns.md` for advanced search queries and bulk operations.

---

## 2. `/gh pr` — Pull Request Workflow

Create, review, check status, and merge pull requests.

### Create a Pull Request

```bash
# Basic PR creation
gh pr create \
  --title "feat(auth): add SSO login support" \
  --body "$(cat <<'EOF'
## Summary
- Add SSO authentication via SAML 2.0
- Support Azure AD and Okta providers
- Auto-provision users on first login

## Test plan
- [ ] SSO login flow with Azure AD
- [ ] SSO login flow with Okta
- [ ] User auto-provisioning
- [ ] Fallback to standard login

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" \
  --reviewer "teammate1,teammate2" \
  --label "feature" \
  --milestone "v2.0"

# Create draft PR
gh pr create --title "wip: SSO support" --draft

# Create PR targeting a specific base branch
gh pr create --base develop --title "feat: SSO support"
```

### Review Workflow

```bash
# View PR details
gh pr view 42

# View PR diff
gh pr diff 42

# Check PR status (CI checks, reviews)
gh pr checks 42

# List review comments
gh api repos/{owner}/{repo}/pulls/42/comments --jq '.[] | "\(.path):\(.line) \(.body)"'

# Approve a PR
gh pr review 42 --approve --body "LGTM — tested locally"

# Request changes
gh pr review 42 --request-changes --body "Please fix the SQL injection in UserController"

# Add a comment
gh pr comment 42 --body "Can we add a test for the edge case in line 45?"
```

### Merge Strategies

```bash
# Squash merge (recommended for feature branches)
gh pr merge 42 --squash --delete-branch

# Merge commit
gh pr merge 42 --merge --delete-branch

# Rebase merge
gh pr merge 42 --rebase --delete-branch

# Auto-merge when checks pass
gh pr merge 42 --squash --auto --delete-branch
```

### PR Status and Listing

```bash
# List open PRs
gh pr list --state open

# List PRs needing my review
gh pr list --search "review-requested:@me"

# List my PRs across all states
gh pr list --author "@me" --state all

# JSON output for scripting
gh pr list --json number,title,state,reviewDecision \
  --jq '.[] | "\(.number) [\(.state)] \(.title) — \(.reviewDecision)"'

# Check if current branch has a PR
gh pr status
```

See `references/gh-pr-patterns.md` for review checklists and merge policies.

---

## 3. `/gh actions` — GitHub Actions Management

List, trigger, watch, and debug workflow runs.

### List Workflow Runs

```bash
# List recent runs
gh run list --limit 10

# List runs for a specific workflow
gh run list --workflow ci.yml --limit 10

# List failed runs
gh run list --status failure --limit 10

# JSON output
gh run list --json databaseId,name,status,conclusion,headBranch \
  --jq '.[] | "\(.databaseId) \(.name) \(.status) \(.conclusion) \(.headBranch)"'
```

### Watch and Debug Runs

```bash
# Watch a run in progress
gh run watch 12345

# View run details
gh run view 12345

# View failed step logs
gh run view 12345 --log-failed

# View full logs
gh run view 12345 --log

# Download run artifacts
gh run download 12345
```

### Trigger Workflows

```bash
# Trigger a workflow_dispatch event
gh workflow run deploy.yml

# Trigger with inputs
gh workflow run deploy.yml \
  --field environment=staging \
  --field version=1.2.3

# Trigger on a specific branch
gh workflow run ci.yml --ref feature/sso
```

### Re-run Failed Jobs

```bash
# Re-run all failed jobs
gh run rerun 12345 --failed

# Re-run entire workflow
gh run rerun 12345
```

### List Available Workflows

```bash
# List all workflows
gh workflow list

# View workflow definition
gh workflow view ci.yml
```

See `references/gh-actions-patterns.md` for debugging strategies and artifact management.

---

## 4. `/gh repo` — Repository Management

Create, clone, fork repositories and manage settings.

### Create a Repository

```bash
# Create a public repo
gh repo create my-package --public --clone \
  --description "A Laravel package for X"

# Create from template
gh repo create my-app --template laravel/laravel --public --clone

# Create private repo
gh repo create my-private-app --private --clone

# Create under an organisation
gh repo create my-org/my-package --public --clone
```

### Clone and Fork

```bash
# Clone a repo
gh repo clone owner/repo

# Fork a repo (creates fork and clones it)
gh repo fork owner/repo --clone

# Fork without cloning
gh repo fork owner/repo --clone=false
```

### Repository Settings

```bash
# Update description and homepage
gh repo edit --description "New description" --homepage "https://example.com"

# Change visibility
gh repo edit --visibility public

# Enable/disable features
gh repo edit --enable-issues --enable-wiki=false

# Set default branch
gh api repos/{owner}/{repo} --method PATCH --field default_branch=main

# Enable squash merge only
gh repo edit \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false

# Delete branch on merge
gh repo edit --delete-branch-on-merge
```

### Branch Protection Rules

```bash
# Set branch protection on main
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
EOF

# View branch protection
gh api repos/{owner}/{repo}/branches/main/protection
```

See `references/gh-repo-management.md` for organisation-level settings and team management.

---

## 5. `/gh release` — Release Management

Full release workflow: commit, push, tag, push tag, create GitHub Release.

### Release Workflow (Step-by-step)

The standard release flow — follow these steps in order:

```bash
# Step 1 — Commit changes
# Do NOT manually update CHANGELOG.md if it's auto-generated by GitHub Actions
git add -A
git commit -m "feat(auth): add SSO login support"

# Step 2 — Push to remote
git push origin main

# Step 3 — Determine next version from latest tag
LATEST_TAG=$(git tag --sort=-v:refname | head -1)
echo "Latest tag: $LATEST_TAG"
# Decide MAJOR/MINOR/PATCH bump based on changes:
#   Breaking change → MAJOR (1.2.0 → 2.0.0)
#   New feature     → MINOR (1.2.0 → 1.3.0)
#   Bug fix         → PATCH (1.2.0 → 1.2.1)
NEW_TAG="1.3.0"  # Set the new version

# Step 4 — Create tag (bare semver, NO v prefix)
git tag -a "$NEW_TAG" -m "$NEW_TAG"

# Step 5 — Push the tag
git push origin "$NEW_TAG"

# Step 6 — Create GitHub Release with release notes
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

gh release create "$NEW_TAG" \
  --title "$NEW_TAG" \
  --notes "$(cat <<EOF
## What's New

### Added
- **SSO Authentication** — SAML 2.0 support for Azure AD and Okta
- **User Auto-provisioning** — Automatic account creation on first SSO login

### Changed
- **Login Page** — Updated UI to show SSO login option

### Fixed
- **Session Timeout** — Fixed premature session expiration after 15 minutes

**Full Changelog**: https://github.com/$REPO/compare/$LATEST_TAG...$NEW_TAG
EOF
)" \
  --latest
```

> **Important:** Tags use **bare semver** without `v` prefix: `1.2.0`, not `v1.2.0`.

> **Important:** Always include the `**Full Changelog**` compare link at the bottom of release notes.

### Auto-generate Release Notes

If you prefer GitHub's auto-generated notes instead of manual ones:

```bash
LATEST_TAG=$(git tag --sort=-v:refname | head -1)
NEW_TAG="1.3.0"
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

gh release create "$NEW_TAG" \
  --title "$NEW_TAG" \
  --generate-notes \
  --latest

# Then append the Full Changelog link
gh release edit "$NEW_TAG" --notes "$(gh release view "$NEW_TAG" --json body --jq '.body')

**Full Changelog**: https://github.com/$REPO/compare/$LATEST_TAG...$NEW_TAG"
```

### Release with Assets

```bash
# Create release with binary assets
gh release create "$NEW_TAG" \
  --title "$NEW_TAG" \
  --generate-notes \
  dist/app.zip \
  dist/app.tar.gz

# Upload assets to existing release
gh release upload "$NEW_TAG" dist/app.zip dist/checksums.txt
```

### Pre-release

```bash
gh release create 1.3.0-beta.1 \
  --title "1.3.0 Beta 1" \
  --prerelease \
  --generate-notes
```

### Version Detection Helper

```bash
# Get the latest tag
LATEST_TAG=$(git tag --sort=-v:refname | head -1)
echo "Current version: ${LATEST_TAG:-none}"

# Parse semver components
IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_TAG"

# Calculate next versions
echo "Next PATCH: $MAJOR.$MINOR.$((PATCH + 1))"
echo "Next MINOR: $MAJOR.$((MINOR + 1)).0"
echo "Next MAJOR: $((MAJOR + 1)).0.0"

# Auto-detect bump type from commits since last tag
COMMITS=$(git log "${LATEST_TAG}..HEAD" --format="%s" 2>/dev/null)
if echo "$COMMITS" | grep -qE '!:|BREAKING CHANGE'; then
  echo "Bump: MAJOR"
elif echo "$COMMITS" | grep -q '^feat'; then
  echo "Bump: MINOR"
else
  echo "Bump: PATCH"
fi
```

### Manage Releases

```bash
# List releases
gh release list

# View a release
gh release view 1.2.0

# Download release assets
gh release download 1.2.0 --dir ./downloads

# Download specific asset
gh release download 1.2.0 --pattern "*.zip" --dir ./downloads

# Delete a release
gh release delete 1.2.0 --yes

# Edit release notes
gh release edit 1.2.0 --notes "Updated release notes"
```

### Release Notes Format

When writing release notes manually, follow this format. Always end with the Full Changelog compare link:

```markdown
## What's New

### Added
- **Feature Name** — Short description of what was added

### Changed
- **Component Name** — What changed and why

### Fixed
- **Bug Name** — What was broken and how it was fixed

**Full Changelog**: https://github.com/owner/repo/compare/PREVIOUS_TAG...NEW_TAG
```

### CHANGELOG.md Handling

**Default: skip CHANGELOG.md** — most projects auto-generate it via GitHub Actions on tag/release.

Only manually update CHANGELOG.md if the project has **no CI/CD workflow** that handles it. To check:

```bash
# Check if any workflow generates changelog
grep -rl "changelog\|CHANGELOG" .github/workflows/ 2>/dev/null

# Or check CLAUDE.md for guidance
grep -i "changelog" CLAUDE.md 2>/dev/null
```

If no CI handles it, follow the `git-workflow` skill's `/git changelog` command to update CHANGELOG.md before tagging.

---

## 6. `/gh labels` — Label Management

Scaffold and sync label sets across repositories.

### Standard Label Set

```bash
# Delete default GitHub labels first
gh label delete "bug" --yes 2>/dev/null
gh label delete "documentation" --yes 2>/dev/null
gh label delete "duplicate" --yes 2>/dev/null
gh label delete "enhancement" --yes 2>/dev/null
gh label delete "good first issue" --yes 2>/dev/null
gh label delete "help wanted" --yes 2>/dev/null
gh label delete "invalid" --yes 2>/dev/null
gh label delete "question" --yes 2>/dev/null
gh label delete "wontfix" --yes 2>/dev/null

# Type labels
gh label create "bug"           --color "D93F0B" --description "Something isn't working"
gh label create "feature"       --color "0E8A16" --description "New feature or request"
gh label create "enhancement"   --color "A2EEEF" --description "Improvement to existing feature"
gh label create "refactor"      --color "D4C5F9" --description "Code restructure without behaviour change"
gh label create "docs"          --color "0075CA" --description "Documentation only changes"
gh label create "test"          --color "BFD4F2" --description "Test coverage improvements"
gh label create "chore"         --color "EDEDED" --description "Maintenance tasks"
gh label create "breaking"      --color "B60205" --description "Breaking change"
gh label create "dependencies"  --color "0366D6" --description "Dependency updates"
gh label create "security"      --color "E4E669" --description "Security vulnerability or fix"

# Priority labels
gh label create "priority:critical" --color "B60205" --description "Must fix immediately"
gh label create "priority:high"     --color "D93F0B" --description "Fix in current sprint"
gh label create "priority:medium"   --color "FBCA04" --description "Fix in next sprint"
gh label create "priority:low"      --color "0E8A16" --description "Nice to have"

# Status labels
gh label create "status:triage"       --color "D876E3" --description "Needs triage"
gh label create "status:in-progress"  --color "0E8A16" --description "Work in progress"
gh label create "status:blocked"      --color "B60205" --description "Blocked by dependency"
gh label create "status:review"       --color "FBCA04" --description "Ready for review"
```

### Sync Labels Across Repos

To apply the same label set across multiple repositories, create a script:

```bash
REPOS=("org/repo1" "org/repo2" "org/repo3")
LABELS=(
  "bug|D93F0B|Something isn't working"
  "feature|0E8A16|New feature or request"
  "priority:high|D93F0B|Fix in current sprint"
)

for repo in "${REPOS[@]}"; do
  for entry in "${LABELS[@]}"; do
    IFS='|' read -r name color desc <<< "$entry"
    gh label create "$name" --color "$color" --description "$desc" --repo "$repo" --force
  done
done
```

### List and Export Labels

```bash
# List all labels
gh label list

# Export labels as JSON
gh label list --json name,color,description

# Clone labels from another repo
gh label clone source-org/source-repo --force
```

---

## 7. `/gh secrets` — Secrets and Variables Management

Manage repository secrets and variables for GitHub Actions.

### Repository Secrets

```bash
# Set a secret (interactive — prompts for value)
gh secret set API_KEY

# Set from a value
gh secret set API_KEY --body "sk-abc123"

# Set from a file
gh secret set SSH_PRIVATE_KEY < ~/.ssh/deploy_key

# Set for a specific environment
gh secret set DATABASE_URL --env production

# List secrets (values are hidden)
gh secret list

# List environment secrets
gh secret list --env production

# Delete a secret
gh secret delete API_KEY
```

### Repository Variables

```bash
# Set a variable
gh variable set APP_ENV --body "production"

# Set for a specific environment
gh variable set APP_DEBUG --body "false" --env production

# List variables
gh variable list

# Delete a variable
gh variable delete APP_ENV
```

### Common Secrets for Laravel Projects

| Secret | Purpose |
|---|---|
| `APP_KEY` | Laravel application key |
| `DB_PASSWORD` | Database password |
| `MAIL_PASSWORD` | Mail service password |
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `DEPLOY_SSH_KEY` | SSH key for deployment |
| `COMPOSER_AUTH` | Private package authentication |
| `SLACK_WEBHOOK_URL` | Slack notification webhook |

### Bulk Secrets from .env

```bash
# Set multiple secrets from .env file (skip comments and empty lines)
grep -v '^#' .env | grep -v '^$' | while IFS='=' read -r key value; do
  gh secret set "$key" --body "$value"
done
```

> **Warning:** Review your .env file before bulk-uploading. Skip keys that don't belong in CI (e.g., `APP_DEBUG`, `APP_URL`).

---

## 8. `/gh project` — GitHub Projects Management

Create and manage GitHub Projects (ProjectsV2) — kanban boards with custom fields, views, status tracking, and multi-repo issue aggregation.

### Create a Project

```bash
# Create a project for a user
gh project create --owner "@me" --title "Product Roadmap Q2 2026"

# Create a project for an organisation
gh project create --owner "my-org" --title "Sprint Board"
```

### List Projects

```bash
# List your projects
gh project list --owner "@me"

# List organisation projects
gh project list --owner "my-org"

# JSON output
gh project list --owner "@me" --format json
```

### Add Items to a Project

Add issues and PRs from **any repository** to a single project — this is how multi-repo tracking works.

```bash
# Add an issue to a project (PROJECT_NUMBER from `gh project list`)
gh project item-add PROJECT_NUMBER --owner "@me" --url https://github.com/owner/repo/issues/123

# Add a PR
gh project item-add PROJECT_NUMBER --owner "my-org" --url https://github.com/owner/repo/pull/42

# Add issues from multiple repos to the same project
gh project item-add 5 --owner "my-org" --url https://github.com/my-org/frontend/issues/10
gh project item-add 5 --owner "my-org" --url https://github.com/my-org/backend/issues/25
gh project item-add 5 --owner "my-org" --url https://github.com/my-org/api-gateway/issues/8

# Create a draft item (not linked to any repo)
gh project item-create PROJECT_NUMBER --owner "@me" --title "Research caching strategies" --body "Evaluate Redis vs Memcached"
```

### Bulk Add Issues from a Repository

```bash
# Add all open issues from a repo to a project
OWNER="my-org"
PROJECT=5
REPO="my-org/backend"

gh issue list --repo "$REPO" --state open --json url --jq '.[].url' | \
  while read -r url; do
    gh project item-add "$PROJECT" --owner "$OWNER" --url "$url"
  done

# Add issues matching a label
gh issue list --repo "$REPO" --label "priority:high" --state open --json url --jq '.[].url' | \
  while read -r url; do
    gh project item-add "$PROJECT" --owner "$OWNER" --url "$url"
  done
```

### Custom Fields

GitHub Projects supports custom fields: **Single Select**, **Text**, **Number**, **Date**, and **Iteration**.

#### Create Custom Fields

```bash
# Create a single-select field (e.g., Priority)
gh project field-create PROJECT_NUMBER --owner "@me" \
  --name "Priority" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Critical,High,Medium,Low"

# Create a text field
gh project field-create PROJECT_NUMBER --owner "@me" \
  --name "Sprint Notes" \
  --data-type "TEXT"

# Create a number field (e.g., Story Points)
gh project field-create PROJECT_NUMBER --owner "@me" \
  --name "Story Points" \
  --data-type "NUMBER"

# Create a date field
gh project field-create PROJECT_NUMBER --owner "@me" \
  --name "Due Date" \
  --data-type "DATE"

# Create an iteration field (sprints)
gh project field-create PROJECT_NUMBER --owner "@me" \
  --name "Sprint" \
  --data-type "ITERATION" \
  --iteration-duration 14 \
  --iteration-start-day "MO"
```

#### List Fields

```bash
gh project field-list PROJECT_NUMBER --owner "@me"
```

### Set Field Values on Items

```bash
# List items to get ITEM_ID
gh project item-list PROJECT_NUMBER --owner "@me" --format json

# Set status (built-in field)
gh project item-edit --project-id PROJECT_ID --id ITEM_ID \
  --field-id FIELD_ID --single-select-option-id OPTION_ID

# Using GraphQL for precise field updates (more reliable)
gh api graphql -f query='
  mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $value: ProjectV2FieldValue!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $projectId
      itemId: $itemId
      fieldId: $fieldId
      value: $value
    }) {
      projectV2Item { id }
    }
  }
' -f projectId="PROJECT_ID" -f itemId="ITEM_ID" -f fieldId="FIELD_ID" \
  -f 'value={"singleSelectOptionId": "OPTION_ID"}'
```

### Views

```bash
# List project views
gh project view PROJECT_NUMBER --owner "@me"

# Open project in browser
gh project view PROJECT_NUMBER --owner "@me" --web
```

### Close and Delete Projects

```bash
# Close a project (marks as closed, keeps data)
gh project close PROJECT_NUMBER --owner "@me"

# Reopen
gh project close PROJECT_NUMBER --owner "@me" --undo

# Delete a project permanently
gh project delete PROJECT_NUMBER --owner "@me"
```

### Mark Items Done and Archive

```bash
# Archive an item (removes from active view, keeps in project)
gh project item-archive PROJECT_NUMBER --owner "@me" --id ITEM_ID

# Unarchive
gh project item-archive PROJECT_NUMBER --owner "@me" --id ITEM_ID --undo

# Remove an item from project entirely
gh project item-delete PROJECT_NUMBER --owner "@me" --id ITEM_ID
```

### Multi-Repo Project Workflow

A common pattern: one GitHub Project tracking work across multiple repositories.

**Setup:**

```bash
ORG="my-org"
PROJECT_TITLE="Platform Sprint Board"

# 1. Create the project
gh project create --owner "$ORG" --title "$PROJECT_TITLE"
# Note the PROJECT_NUMBER from output

PROJECT=5

# 2. Add custom fields
gh project field-create $PROJECT --owner "$ORG" \
  --name "Team" --data-type "SINGLE_SELECT" \
  --single-select-options "Frontend,Backend,DevOps,QA"

gh project field-create $PROJECT --owner "$ORG" \
  --name "Story Points" --data-type "NUMBER"

gh project field-create $PROJECT --owner "$ORG" \
  --name "Sprint" --data-type "ITERATION" \
  --iteration-duration 14 --iteration-start-day "MO"

# 3. Bulk-add open issues from all repos
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway" "$ORG/mobile-app" "$ORG/infra")

for repo in "${REPOS[@]}"; do
  echo "Adding issues from $repo..."
  gh issue list --repo "$repo" --state open --json url --jq '.[].url' | \
    while read -r url; do
      gh project item-add "$PROJECT" --owner "$ORG" --url "$url" 2>/dev/null
    done
done
```

**Daily triage — add new issues:**

```bash
ORG="my-org"
PROJECT=5
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway")

for repo in "${REPOS[@]}"; do
  # Only issues created in the last 24 hours
  gh issue list --repo "$repo" --state open --json url,createdAt \
    --jq "[.[] | select(.createdAt > \"$(date -v-1d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ)\") | .url] | .[]" | \
    while read -r url; do
      gh project item-add "$PROJECT" --owner "$ORG" --url "$url" 2>/dev/null
    done
done
```

### Tagging, Assigning, Labelling, and Commenting on Project Issues

These operations work on the **issue itself** (not the project item), so they apply regardless of which project the issue belongs to.

```bash
# Tag an issue with labels
gh issue edit 123 --repo "my-org/backend" --add-label "priority:high,bug,sprint:current"

# Remove a label
gh issue edit 123 --repo "my-org/backend" --remove-label "status:triage"

# Assign an issue
gh issue edit 123 --repo "my-org/backend" --add-assignee "dev1,dev2"

# Remove assignee
gh issue edit 123 --repo "my-org/backend" --remove-assignee "dev1"

# Set milestone
gh issue edit 123 --repo "my-org/backend" --milestone "v2.0"

# Add a comment
gh issue comment 123 --repo "my-org/backend" --body "Starting work on this — ETA Friday"

# Add a structured comment
gh issue comment 123 --repo "my-org/backend" --body "$(cat <<'EOF'
## Update — 2026-03-11

### Progress
- [x] Database schema updated
- [x] Model and migration created
- [ ] API endpoints
- [ ] Tests

### Blockers
None — on track for Friday.
EOF
)"

# Comment on a PR
gh pr comment 42 --repo "my-org/backend" --body "Tested locally — LGTM"
```

### Bulk Triage Across Repos

```bash
ORG="my-org"
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway")

# Label all untriaged issues across repos
for repo in "${REPOS[@]}"; do
  gh issue list --repo "$repo" --search "no:label" --state open --json number --jq '.[].number' | \
    while read -r num; do
      gh issue edit "$num" --repo "$repo" --add-label "status:triage"
    done
done

# Assign all unassigned high-priority issues to the on-call dev
for repo in "${REPOS[@]}"; do
  gh issue list --repo "$repo" --label "priority:high" --search "no:assignee" --json number --jq '.[].number' | \
    while read -r num; do
      gh issue edit "$num" --repo "$repo" --add-assignee "oncall-dev"
    done
done
```

### Project Status Dashboard via GraphQL

```bash
# Get project items with status, assignees, and repo — for a multi-repo overview
gh api graphql -f query='
  query($org: String!, $number: Int!) {
    organization(login: $org) {
      projectV2(number: $number) {
        title
        items(first: 100) {
          nodes {
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue { name field { ... on ProjectV2SingleSelectField { name } } }
                ... on ProjectV2ItemFieldTextValue { text field { ... on ProjectV2Field { name } } }
                ... on ProjectV2ItemFieldNumberValue { number field { ... on ProjectV2Field { name } } }
              }
            }
            content {
              ... on Issue {
                title
                number
                state
                assignees(first: 3) { nodes { login } }
                labels(first: 5) { nodes { name } }
                repository { nameWithOwner }
              }
              ... on PullRequest {
                title
                number
                state
                assignees(first: 3) { nodes { login } }
                repository { nameWithOwner }
              }
            }
          }
        }
      }
    }
  }
' -F number=5 -f org="my-org"
```

See `references/gh-project-patterns.md` for advanced project workflows, automation, and field management.

---

## 9. `/gh report` — Repository and Project Reporting

Generate reports from GitHub data in **HTML**, **JSON**, or **Markdown** format. Reports cover repository health, issue/PR activity, project board status, and contributor metrics.

### Output Formats

| Format | Use Case | Flag |
|---|---|---|
| Markdown | README, wiki, Slack/Discord sharing | `--format md` |
| JSON | Programmatic consumption, dashboards, CI pipelines | `--format json` |
| HTML | Self-contained visual reports, email, browser viewing | `--format html` |

Default output directory: `./reports/`

### Report Types

#### 1. Repository Activity Report

Summarise issues, PRs, and releases for a single repo over a time period.

**Step 1 — Gather data:**

```bash
REPO="owner/repo"
SINCE="2026-03-01"
OUTPUT_DIR="./reports"
mkdir -p "$OUTPUT_DIR"

# Issues opened and closed
ISSUES_OPENED=$(gh issue list --repo "$REPO" --state all --search "created:>=$SINCE" --json number --jq '. | length')
ISSUES_CLOSED=$(gh issue list --repo "$REPO" --state closed --search "closed:>=$SINCE" --json number --jq '. | length')
ISSUES_OPEN=$(gh issue list --repo "$REPO" --state open --json number --jq '. | length')

# PRs merged and opened
PRS_MERGED=$(gh pr list --repo "$REPO" --state merged --search "merged:>=$SINCE" --json number --jq '. | length')
PRS_OPEN=$(gh pr list --repo "$REPO" --state open --json number --jq '. | length')

# Releases
RELEASES=$(gh release list --repo "$REPO" --json tagName,publishedAt --jq "[.[] | select(.publishedAt > \"$SINCE\")]  | length")
```

**Step 2 — Generate Markdown report:**

```bash
cat > "$OUTPUT_DIR/repo-activity.md" <<EOF
# Repository Activity Report

**Repository:** $REPO
**Period:** $SINCE to $(date +%Y-%m-%d)
**Generated:** $(date +%Y-%m-%dT%H:%M:%S)

## Summary

| Metric | Count |
|---|---|
| Issues Opened | $ISSUES_OPENED |
| Issues Closed | $ISSUES_CLOSED |
| Issues Currently Open | $ISSUES_OPEN |
| PRs Merged | $PRS_MERGED |
| PRs Currently Open | $PRS_OPEN |
| Releases | $RELEASES |

## Open Issues by Label

$(gh issue list --repo "$REPO" --state open --json labels --jq '[.[].labels[].name] | group_by(.) | map({label: .[0], count: length}) | sort_by(.count) | reverse | .[] | "| \(.label) | \(.count) |"' | sed '1i| Label | Count |\n|---|---|')

## Recently Merged PRs

$(gh pr list --repo "$REPO" --state merged --search "merged:>=$SINCE" --json number,title,author,mergedAt --jq '.[] | "- **#\(.number)** \(.title) — @\(.author.login) (\(.mergedAt | split("T")[0]))"')

## Open PRs Awaiting Review

$(gh pr list --repo "$REPO" --state open --search "review:required" --json number,title,author,createdAt --jq '.[] | "- **#\(.number)** \(.title) — @\(.author.login) (since \(.createdAt | split("T")[0]))"')
EOF
```

**Step 3 — Generate JSON report:**

```bash
cat > "$OUTPUT_DIR/repo-activity.json" <<EOF
{
  "repository": "$REPO",
  "period": {"from": "$SINCE", "to": "$(date +%Y-%m-%d)"},
  "generated_at": "$(date +%Y-%m-%dT%H:%M:%SZ)",
  "summary": {
    "issues_opened": $ISSUES_OPENED,
    "issues_closed": $ISSUES_CLOSED,
    "issues_open": $ISSUES_OPEN,
    "prs_merged": $PRS_MERGED,
    "prs_open": $PRS_OPEN,
    "releases": $RELEASES
  },
  "open_issues": $(gh issue list --repo "$REPO" --state open --json number,title,labels,assignees,createdAt),
  "merged_prs": $(gh pr list --repo "$REPO" --state merged --search "merged:>=$SINCE" --json number,title,author,mergedAt)
}
EOF
```

**Step 4 — Generate HTML report:**

```bash
cat > "$OUTPUT_DIR/repo-activity.html" <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Repository Activity Report</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #0d1117; color: #e6edf3; padding: 2rem; }
  .container { max-width: 960px; margin: 0 auto; }
  h1 { font-size: 1.8rem; margin-bottom: 0.5rem; color: #58a6ff; }
  h2 { font-size: 1.3rem; margin: 2rem 0 1rem; color: #8b949e; border-bottom: 1px solid #30363d; padding-bottom: 0.5rem; }
  .meta { color: #8b949e; margin-bottom: 2rem; font-size: 0.9rem; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 1rem; margin: 1.5rem 0; }
  .card { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 1.2rem; text-align: center; }
  .card .value { font-size: 2rem; font-weight: 700; color: #58a6ff; }
  .card .label { font-size: 0.8rem; color: #8b949e; margin-top: 0.3rem; }
  table { width: 100%; border-collapse: collapse; margin: 1rem 0; }
  th, td { padding: 0.6rem 1rem; text-align: left; border-bottom: 1px solid #30363d; }
  th { color: #8b949e; font-weight: 600; font-size: 0.85rem; }
  td { font-size: 0.9rem; }
  .badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: 600; background: #30363d; color: #e6edf3; margin: 1px; }
  .badge.open { background: #238636; }
  .badge.merged { background: #8957e5; }
  .badge.closed { background: #da3633; }
  ul { list-style: none; }
  ul li { padding: 0.5rem 0; border-bottom: 1px solid #21262d; font-size: 0.9rem; }
  ul li:last-child { border-bottom: none; }
  a { color: #58a6ff; text-decoration: none; }
  a:hover { text-decoration: underline; }
  .footer { margin-top: 3rem; text-align: center; color: #484f58; font-size: 0.8rem; }
</style>
</head>
<body>
<div class="container">
  <h1>Repository Activity Report</h1>
  <div class="meta" id="meta"></div>
  <div class="grid" id="summary"></div>
  <h2>Open Issues by Label</h2>
  <table id="labels-table"><thead><tr><th>Label</th><th>Count</th></tr></thead><tbody></tbody></table>
  <h2>Recently Merged PRs</h2>
  <ul id="merged-prs"></ul>
  <h2>Open PRs Awaiting Review</h2>
  <ul id="open-prs"></ul>
  <div class="footer">Generated by gh-workflow skill</div>
</div>
<script>
  // Inline the JSON data at generation time
  const data = __REPORT_DATA__;

  document.getElementById('meta').innerHTML =
    `<strong>${data.repository}</strong> &middot; ${data.period.from} to ${data.period.to} &middot; Generated ${data.generated_at}`;

  const metrics = [
    {label: 'Issues Opened', value: data.summary.issues_opened},
    {label: 'Issues Closed', value: data.summary.issues_closed},
    {label: 'Open Issues', value: data.summary.issues_open},
    {label: 'PRs Merged', value: data.summary.prs_merged},
    {label: 'Open PRs', value: data.summary.prs_open},
    {label: 'Releases', value: data.summary.releases},
  ];
  document.getElementById('summary').innerHTML = metrics.map(m =>
    `<div class="card"><div class="value">${m.value}</div><div class="label">${m.label}</div></div>`
  ).join('');

  // Labels
  const labelCounts = {};
  data.open_issues.forEach(i => i.labels.forEach(l => { labelCounts[l.name] = (labelCounts[l.name]||0)+1; }));
  const sortedLabels = Object.entries(labelCounts).sort((a,b) => b[1]-a[1]);
  document.querySelector('#labels-table tbody').innerHTML = sortedLabels.map(([name,count]) =>
    `<tr><td><span class="badge">${name}</span></td><td>${count}</td></tr>`
  ).join('');

  // Merged PRs
  document.getElementById('merged-prs').innerHTML = data.merged_prs.map(pr =>
    `<li><strong>#${pr.number}</strong> ${pr.title} — @${pr.author.login} <span class="badge merged">merged ${pr.mergedAt.split('T')[0]}</span></li>`
  ).join('');
</script>
</body>
</html>
HTMLEOF

# Replace placeholder with actual JSON data
REPORT_JSON=$(cat "$OUTPUT_DIR/repo-activity.json")
sed -i '' "s|__REPORT_DATA__|$REPORT_JSON|" "$OUTPUT_DIR/repo-activity.html" 2>/dev/null || \
  sed -i "s|__REPORT_DATA__|$REPORT_JSON|" "$OUTPUT_DIR/repo-activity.html"
```

#### 2. Multi-Repo Summary Report

For organisations tracking work across multiple repositories.

```bash
ORG="my-org"
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway" "$ORG/mobile-app")
SINCE="2026-03-01"
OUTPUT_DIR="./reports"
mkdir -p "$OUTPUT_DIR"

# Generate Markdown
{
  echo "# Multi-Repo Activity Report"
  echo ""
  echo "**Organisation:** $ORG"
  echo "**Period:** $SINCE to $(date +%Y-%m-%d)"
  echo "**Generated:** $(date +%Y-%m-%dT%H:%M:%S)"
  echo ""
  echo "## Summary"
  echo ""
  echo "| Repository | Open Issues | Closed | Open PRs | Merged PRs |"
  echo "|---|---|---|---|---|"

  for repo in "${REPOS[@]}"; do
    OPEN=$(gh issue list --repo "$repo" --state open --json number --jq '. | length')
    CLOSED=$(gh issue list --repo "$repo" --state closed --search "closed:>=$SINCE" --json number --jq '. | length')
    PR_OPEN=$(gh pr list --repo "$repo" --state open --json number --jq '. | length')
    PR_MERGED=$(gh pr list --repo "$repo" --state merged --search "merged:>=$SINCE" --json number --jq '. | length')
    echo "| $repo | $OPEN | $CLOSED | $PR_OPEN | $PR_MERGED |"
  done

  echo ""
  echo "## Critical Issues Across Repos"
  echo ""
  for repo in "${REPOS[@]}"; do
    gh issue list --repo "$repo" --label "priority:critical,priority:high" --state open \
      --json number,title,labels,assignees \
      --jq ".[] | \"- **$repo#\(.number)** \(.title) — \(if .assignees | length > 0 then \"@\" + (.assignees | map(.login) | join(\", @\")) else \"unassigned\" end)\""
  done
} > "$OUTPUT_DIR/multi-repo-report.md"
```

#### 3. Project Board Report

Generate a status report from a GitHub Project.

```bash
ORG="my-org"
PROJECT_NUMBER=5
OUTPUT_DIR="./reports"
mkdir -p "$OUTPUT_DIR"

# Fetch project data via GraphQL
PROJECT_DATA=$(gh api graphql -f query='
  query($org: String!, $number: Int!) {
    organization(login: $org) {
      projectV2(number: $number) {
        title
        shortDescription
        items(first: 100) {
          totalCount
          nodes {
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  name
                  field { ... on ProjectV2SingleSelectField { name } }
                }
              }
            }
            content {
              ... on Issue {
                title number state
                repository { nameWithOwner }
                assignees(first: 3) { nodes { login } }
                labels(first: 5) { nodes { name } }
              }
              ... on PullRequest {
                title number state
                repository { nameWithOwner }
              }
            }
          }
        }
      }
    }
  }
' -F number="$PROJECT_NUMBER" -f org="$ORG")

# Save as JSON
echo "$PROJECT_DATA" > "$OUTPUT_DIR/project-report.json"

# Generate Markdown from the JSON
echo "$PROJECT_DATA" | jq -r '
  .data.organization.projectV2 as $p |
  "# Project Report: \($p.title)\n",
  "**Description:** \($p.shortDescription // "N/A")",
  "**Total Items:** \($p.items.totalCount)\n",
  "## Items by Status\n",
  ([$p.items.nodes[].fieldValues.nodes[] | select(.field.name? == "Status") | .name] | group_by(.) | map("\(.[ 0]): \(length)") | .[] | "- \(.)"),
  "\n## All Items\n",
  "| # | Title | Repo | Status | Assignees |",
  "|---|---|---|---|---|",
  ($p.items.nodes[] |
    (.fieldValues.nodes[] | select(.field.name? == "Status") | .name) as $status |
    .content |
    "| #\(.number) | \(.title) | \(.repository.nameWithOwner) | \($status // "—") | \(if .assignees then (.assignees.nodes | map(.login) | join(", ")) else "—" end) |"
  )
' > "$OUTPUT_DIR/project-report.md"
```

#### 4. Contributor Report

```bash
REPO="owner/repo"
SINCE="2026-01-01"
OUTPUT_DIR="./reports"
mkdir -p "$OUTPUT_DIR"

{
  echo "# Contributor Report"
  echo ""
  echo "**Repository:** $REPO"
  echo "**Period:** $SINCE to $(date +%Y-%m-%d)"
  echo ""
  echo "## PRs by Author"
  echo ""
  echo "| Author | Merged | Open | Reviews Given |"
  echo "|---|---|---|---|"

  # Get all PR authors
  gh pr list --repo "$REPO" --state all --search "created:>=$SINCE" --json author \
    --jq '[.[].author.login] | unique | .[]' | while read -r author; do
    MERGED=$(gh pr list --repo "$REPO" --state merged --author "$author" --search "merged:>=$SINCE" --json number --jq '. | length')
    OPEN=$(gh pr list --repo "$REPO" --state open --author "$author" --json number --jq '. | length')
    REVIEWS=$(gh api "repos/$REPO/pulls?state=all&per_page=100" --jq "[.[] | select(.requested_reviewers[]?.login == \"$author\")] | length" 2>/dev/null || echo "0")
    echo "| @$author | $MERGED | $OPEN | $REVIEWS |"
  done

  echo ""
  echo "## Issues by Assignee"
  echo ""
  gh issue list --repo "$REPO" --state all --search "created:>=$SINCE" --json assignees \
    --jq '[.[].assignees[].login] | group_by(.) | map({author: .[0], count: length}) | sort_by(.count) | reverse | .[] | "- @\(.author): \(.count) issues"'
} > "$OUTPUT_DIR/contributor-report.md"
```

See `references/gh-report-patterns.md` for HTML template customisation and scheduled report generation.

---

## 10. `/gh api` — Advanced API Operations

Use `gh api` for operations not covered by built-in commands.

### REST API

```bash
# Get repository info
gh api repos/{owner}/{repo}

# Get specific fields with jq
gh api repos/{owner}/{repo} --jq '.stargazers_count, .forks_count'

# List collaborators
gh api repos/{owner}/{repo}/collaborators --jq '.[].login'

# Add a collaborator
gh api repos/{owner}/{repo}/collaborators/username --method PUT --field permission=push

# Get rate limit status
gh api rate_limit --jq '.rate | "Remaining: \(.remaining)/\(.limit) Reset: \(.reset)"'

# Create a project comment
gh api repos/{owner}/{repo}/issues/123/comments --field body="Automated comment"
```

### GraphQL API

```bash
# Get PR review threads
gh api graphql -f query='
  query {
    repository(owner: "owner", name: "repo") {
      pullRequest(number: 42) {
        reviewThreads(first: 50) {
          nodes {
            isResolved
            comments(first: 10) {
              nodes { body author { login } }
            }
          }
        }
      }
    }
  }
'

# Get organisation repos
gh api graphql -f query='
  query($org: String!) {
    organization(login: $org) {
      repositories(first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes { name updatedAt isPrivate }
      }
    }
  }
' -f org="my-org"
```

### Paginated Requests

```bash
# Fetch all issues (handles pagination automatically)
gh api repos/{owner}/{repo}/issues --paginate --jq '.[].title'

# Fetch all PRs with specific fields
gh api repos/{owner}/{repo}/pulls --paginate \
  --jq '.[] | "\(.number) \(.title) \(.state)"'
```

### Useful API Recipes

```bash
# Get repository topics
gh api repos/{owner}/{repo}/topics --jq '.names[]'

# Set repository topics
gh api repos/{owner}/{repo}/topics --method PUT \
  --field names='["laravel","php","api"]'

# Get latest commit status
gh api repos/{owner}/{repo}/commits/main/status --jq '.state'

# List deploy keys
gh api repos/{owner}/{repo}/keys --jq '.[] | "\(.id) \(.title) \(.read_only)"'

# Get repository traffic (requires push access)
gh api repos/{owner}/{repo}/traffic/views --jq '.views[] | "\(.timestamp) \(.count)"'

# List organisation members
gh api orgs/{org}/members --paginate --jq '.[].login'
```

See `references/gh-api-recipes.md` for more GraphQL queries and automation patterns.

---

## Reference Files

| File | Read When |
|---|---|
| `references/gh-issue-patterns.md` | Creating issue templates, advanced search queries, or bulk issue operations |
| `references/gh-pr-patterns.md` | Setting up PR review workflows, merge policies, or CI-gated merges |
| `references/gh-actions-patterns.md` | Debugging workflow failures, managing artifacts, or triggering deployments |
| `references/gh-repo-management.md` | Setting up repositories, branch protection, team permissions, or org-level settings |
| `references/gh-project-patterns.md` | Managing GitHub Projects, multi-repo boards, custom fields, bulk triage, and project automation |
| `references/gh-report-patterns.md` | Generating reports in HTML/JSON/Markdown, scheduling reports, customising HTML templates |
| `references/gh-api-recipes.md` | Using `gh api` for REST/GraphQL operations, pagination, or automation scripts |
