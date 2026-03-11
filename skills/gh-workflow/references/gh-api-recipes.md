# GitHub API Recipes

## Authentication Check

```bash
# Check current auth status
gh auth status

# Check token scopes
gh auth token | gh api -H "Authorization: token $(cat -)" user --jq '.login'

# Simpler — just check who you are
gh api user --jq '.login'
```

## REST API Patterns

### Pagination

```bash
# Automatically paginate through all results
gh api repos/{owner}/{repo}/issues --paginate --jq '.[].title'

# Manual pagination with per_page
gh api "repos/{owner}/{repo}/issues?per_page=100&page=1" --jq '.[].title'

# Count total items
gh api repos/{owner}/{repo}/issues --paginate --jq '. | length'
```

### Filtering with jq

```bash
# Select specific fields
gh api repos/{owner}/{repo} --jq '{name, stars: .stargazers_count, forks: .forks_count}'

# Filter arrays
gh api repos/{owner}/{repo}/issues --jq '[.[] | select(.labels[].name == "bug")]'

# Sort results
gh api repos/{owner}/{repo}/issues --jq 'sort_by(.created_at) | reverse | .[0:5]'

# Group by
gh api repos/{owner}/{repo}/issues --jq 'group_by(.state) | map({state: .[0].state, count: length})'
```

### Error Handling

```bash
# Check response status
gh api repos/{owner}/{repo} 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Repository not found or no access"
fi

# Get response headers (rate limit info)
gh api repos/{owner}/{repo} --include 2>&1 | head -20
```

## GraphQL Queries

### Repository Overview

```bash
gh api graphql -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      name
      description
      stargazerCount
      forkCount
      primaryLanguage { name }
      licenseInfo { name }
      defaultBranchRef { name }
      issues(states: OPEN) { totalCount }
      pullRequests(states: OPEN) { totalCount }
      releases(first: 1, orderBy: {field: CREATED_AT, direction: DESC}) {
        nodes { tagName publishedAt }
      }
    }
  }
' -f owner="owner" -f name="repo"
```

### PR with Review Status

```bash
gh api graphql -f query='
  query($owner: String!, $name: String!, $number: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $number) {
        title
        state
        mergeable
        reviewDecision
        reviews(first: 10) {
          nodes {
            author { login }
            state
            body
          }
        }
        statusCheckRollup {
          state
          contexts(first: 20) {
            nodes {
              ... on CheckRun {
                name
                conclusion
                status
              }
            }
          }
        }
      }
    }
  }
' -f owner="owner" -f name="repo" -F number=42
```

### Organisation Dashboard

```bash
gh api graphql -f query='
  query($org: String!) {
    organization(login: $org) {
      repositories(first: 50, orderBy: {field: PUSHED_AT, direction: DESC}) {
        nodes {
          name
          pushedAt
          isPrivate
          defaultBranchRef {
            target {
              ... on Commit {
                statusCheckRollup { state }
              }
            }
          }
          issues(states: OPEN) { totalCount }
          pullRequests(states: OPEN) { totalCount }
        }
      }
    }
  }
' -f org="my-org" --jq '.data.organization.repositories.nodes[] |
  "\(.name) | PRs: \(.pullRequests.totalCount) | Issues: \(.issues.totalCount) | CI: \(.defaultBranchRef.target.statusCheckRollup.state // "N/A")"'
```

### Search Issues Across Repos

```bash
gh api graphql -f query='
  query($query: String!) {
    search(query: $query, type: ISSUE, first: 20) {
      issueCount
      nodes {
        ... on Issue {
          title
          number
          repository { nameWithOwner }
          labels(first: 5) { nodes { name } }
          createdAt
        }
      }
    }
  }
' -f query="org:my-org is:open label:bug"
```

## Automation Scripts

### Daily Standup Report

```bash
#!/bin/bash
# Generate a daily standup report from GitHub activity

USER=$(gh api user --jq '.login')
SINCE=$(date -v-1d +%Y-%m-%dT00:00:00Z 2>/dev/null || date -d "yesterday" +%Y-%m-%dT00:00:00Z)

echo "## Daily Standup — $(date +%Y-%m-%d)"
echo

echo "### PRs Merged"
gh search prs "author:$USER merged:>=$SINCE" --json title,repository --jq '.[] | "- [\(.repository.nameWithOwner)] \(.title)"'

echo
echo "### PRs In Review"
gh search prs "author:$USER is:open review:required" --json title,repository --jq '.[] | "- [\(.repository.nameWithOwner)] \(.title)"'

echo
echo "### Issues Closed"
gh search issues "assignee:$USER closed:>=$SINCE" --json title,repository --jq '.[] | "- [\(.repository.nameWithOwner)] \(.title)"'

echo
echo "### PRs to Review"
gh search prs "review-requested:$USER is:open" --json title,repository --jq '.[] | "- [\(.repository.nameWithOwner)] \(.title)"'
```

### Repository Health Check

```bash
#!/bin/bash
# Check repository health across an org

ORG="my-org"

gh api "orgs/$ORG/repos" --paginate --jq '.[].full_name' | while read -r repo; do
  HAS_CI=$(gh api "repos/$repo/actions/workflows" --jq '.total_count' 2>/dev/null || echo "0")
  HAS_PROTECTION=$(gh api "repos/$repo/branches/main/protection" 2>/dev/null && echo "yes" || echo "no")
  OPEN_PRS=$(gh api "repos/$repo/pulls?state=open" --jq '. | length' 2>/dev/null || echo "0")
  OPEN_ISSUES=$(gh api "repos/$repo/issues?state=open" --jq '. | length' 2>/dev/null || echo "0")

  echo "$repo | CI workflows: $HAS_CI | Branch protection: $HAS_PROTECTION | Open PRs: $OPEN_PRS | Open issues: $OPEN_ISSUES"
done
```

### Notification Management

```bash
# List unread notifications
gh api notifications --jq '.[] | "\(.subject.type): \(.subject.title) [\(.repository.full_name)]"'

# Mark all as read
gh api notifications --method PUT --field read=true

# Mark a specific thread as read
gh api notifications/threads/12345 --method PATCH

# List notifications for a specific repo
gh api "repos/{owner}/{repo}/notifications" --jq '.[] | "\(.subject.type): \(.subject.title)"'
```

### Gist Management

```bash
# Create a gist
gh gist create file.txt --desc "My gist" --public

# Create from multiple files
gh gist create file1.txt file2.txt --desc "Multi-file gist"

# List gists
gh gist list

# View a gist
gh gist view GIST_ID

# Edit a gist
gh gist edit GIST_ID

# Delete a gist
gh gist delete GIST_ID
```

## Rate Limiting

```bash
# Check rate limit
gh api rate_limit --jq '{
  core: {remaining: .rate.remaining, limit: .rate.limit, reset: (.rate.reset | strftime("%H:%M:%S"))},
  graphql: {remaining: .resources.graphql.remaining, limit: .resources.graphql.limit},
  search: {remaining: .resources.search.remaining, limit: .resources.search.limit}
}'
```

## Useful One-liners

```bash
# Get default branch name
gh api repos/{owner}/{repo} --jq '.default_branch'

# Check if repo is a fork
gh api repos/{owner}/{repo} --jq '.fork'

# Get repo size in KB
gh api repos/{owner}/{repo} --jq '.size'

# List all branches
gh api repos/{owner}/{repo}/branches --paginate --jq '.[].name'

# Get latest release version
gh api repos/{owner}/{repo}/releases/latest --jq '.tag_name'

# List all tags
gh api repos/{owner}/{repo}/tags --paginate --jq '.[].name'

# Get commit count
gh api repos/{owner}/{repo} --jq '.size'

# Check if file exists in repo
gh api "repos/{owner}/{repo}/contents/CLAUDE.md" --jq '.name' 2>/dev/null && echo "exists" || echo "not found"
```
