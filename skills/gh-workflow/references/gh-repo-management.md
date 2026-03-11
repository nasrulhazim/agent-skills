# GitHub Repository Management

## Repository Creation Patterns

### Laravel Package

```bash
# Create from Spatie skeleton
gh repo create cleaniquecoders/my-package \
  --template spatie/package-skeleton-laravel \
  --public \
  --clone \
  --description "A Laravel package for X"

# After cloning, run the configure script
cd my-package
php configure.php
```

### Laravel Application

```bash
gh repo create my-org/my-app \
  --template laravel/laravel \
  --private \
  --clone \
  --description "My Laravel application"
```

### Empty Repository with README

```bash
gh repo create my-org/my-project \
  --public \
  --clone \
  --description "Project description" \
  --add-readme
```

## Repository Settings

### Full Setup Script

```bash
REPO="owner/repo"

# Set description and homepage
gh repo edit "$REPO" --description "Description" --homepage "https://example.com"

# Enable squash merge only
gh repo edit "$REPO" \
  --enable-squash-merge \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge

# Enable features
gh repo edit "$REPO" --enable-issues --enable-wiki=false --enable-discussions

# Set topics
gh api "repos/$REPO/topics" --method PUT \
  --field names='["laravel","php","api","package"]'

# Set default branch
gh api "repos/$REPO" --method PATCH --field default_branch=main
```

### Branch Protection

```bash
REPO="owner/repo"
BRANCH="main"

gh api "repos/$REPO/branches/$BRANCH/protection" \
  --method PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

### Remove Branch Protection

```bash
gh api "repos/$REPO/branches/$BRANCH/protection" --method DELETE
```

## Team Management (Organisation)

```bash
ORG="my-org"

# List teams
gh api "orgs/$ORG/teams" --jq '.[] | "\(.slug) \(.permission)"'

# Create a team
gh api "orgs/$ORG/teams" --method POST \
  --field name="backend" \
  --field description="Backend developers" \
  --field privacy="closed"

# Add repo to team
gh api "orgs/$ORG/teams/backend/repos/$ORG/my-repo" --method PUT \
  --field permission="push"

# Add member to team
gh api "orgs/$ORG/teams/backend/memberships/username" --method PUT \
  --field role="member"

# List team members
gh api "orgs/$ORG/teams/backend/members" --jq '.[].login'
```

## Collaborator Management

```bash
REPO="owner/repo"

# List collaborators
gh api "repos/$REPO/collaborators" --jq '.[] | "\(.login) \(.role_name)"'

# Add collaborator
gh api "repos/$REPO/collaborators/username" --method PUT --field permission="push"

# Remove collaborator
gh api "repos/$REPO/collaborators/username" --method DELETE

# Check if user is a collaborator
gh api "repos/$REPO/collaborators/username" 2>/dev/null && echo "Yes" || echo "No"
```

## Deploy Keys

```bash
REPO="owner/repo"

# List deploy keys
gh api "repos/$REPO/keys" --jq '.[] | "\(.id) \(.title) read_only:\(.read_only)"'

# Add a deploy key (read-only)
gh api "repos/$REPO/keys" --method POST \
  --field title="deploy-server" \
  --field key="$(cat ~/.ssh/deploy_key.pub)" \
  --field read_only=true

# Remove a deploy key
gh api "repos/$REPO/keys/12345" --method DELETE
```

## Webhooks

```bash
REPO="owner/repo"

# List webhooks
gh api "repos/$REPO/hooks" --jq '.[] | "\(.id) \(.config.url) \(.active)"'

# Create a webhook
gh api "repos/$REPO/hooks" --method POST --input - <<'EOF'
{
  "config": {
    "url": "https://example.com/webhook",
    "content_type": "json",
    "secret": "webhook-secret-here"
  },
  "events": ["push", "pull_request"],
  "active": true
}
EOF

# Test a webhook (sends a ping)
gh api "repos/$REPO/hooks/12345/pings" --method POST

# Delete a webhook
gh api "repos/$REPO/hooks/12345" --method DELETE
```

## Repository Insights

```bash
REPO="owner/repo"

# Traffic — page views (requires push access)
gh api "repos/$REPO/traffic/views" --jq '.views[] | "\(.timestamp | split("T")[0]) views:\(.count) uniques:\(.uniques)"'

# Traffic — clones
gh api "repos/$REPO/traffic/clones" --jq '.clones[] | "\(.timestamp | split("T")[0]) clones:\(.count) uniques:\(.uniques)"'

# Referral sources
gh api "repos/$REPO/traffic/popular/referrers" --jq '.[] | "\(.referrer) count:\(.count) uniques:\(.uniques)"'

# Popular content
gh api "repos/$REPO/traffic/popular/paths" --jq '.[] | "\(.path) count:\(.count) uniques:\(.uniques)"'

# Contributor stats
gh api "repos/$REPO/stats/contributors" --jq '.[] | "\(.author.login) commits:\(.total)"'

# Code frequency (additions/deletions per week)
gh api "repos/$REPO/stats/code_frequency" --jq '.[-4:][] | "week:\(.[0]) +\(.[1]) \(.[2])"'
```

## Repository Archival

```bash
# Archive a repo (makes it read-only)
gh repo archive owner/repo --yes

# Unarchive
gh api "repos/owner/repo" --method PATCH --field archived=false
```

## Forking Workflow

```bash
# Fork and clone
gh repo fork upstream/repo --clone

# Sync fork with upstream
cd repo
gh repo sync --source upstream/repo

# Or manually
git fetch upstream
git merge upstream/main
git push origin main
```
