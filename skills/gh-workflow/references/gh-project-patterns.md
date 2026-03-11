# GitHub Project Patterns

## Project Setup Checklist

When creating a new GitHub Project for a team:

1. Create the project under the org (not personal)
2. Add standard custom fields (Status, Priority, Story Points, Sprint, Team)
3. Create views: Board (kanban), Table (spreadsheet), Backlog
4. Add issues from all relevant repos
5. Set up auto-add workflows for new issues

## Standard Custom Fields

| Field | Type | Options |
|---|---|---|
| Status | Single Select | Backlog, Todo, In Progress, In Review, Done |
| Priority | Single Select | Critical, High, Medium, Low |
| Story Points | Number | — |
| Sprint | Iteration | 2-week cycles |
| Team | Single Select | Frontend, Backend, DevOps, QA |
| Due Date | Date | — |
| Effort | Single Select | XS, S, M, L, XL |

## Auto-add Workflows

GitHub Projects supports built-in automation. Configure via the project's **Workflows** tab in the web UI, or via GraphQL:

### Auto-add Issues from a Repo

```bash
# This requires the web UI or GraphQL — no direct CLI command yet
# Navigate to: Project → Settings → Workflows → Auto-add

# Via GraphQL — create an auto-add workflow
gh api graphql -f query='
  mutation($projectId: ID!, $repoId: ID!) {
    createProjectV2Workflow(input: {
      projectId: $projectId
      name: "Auto-add backend issues"
    }) {
      projectV2Workflow { id }
    }
  }
' -f projectId="PROJECT_ID" -f repoId="REPO_ID"
```

### Auto-set Status When PR Merges

In the web UI: Project → Workflows → "Pull request merged" → Set Status to "Done"

### Auto-archive Done Items

In the web UI: Project → Workflows → "Auto-archive items" → When Status is "Done" for 14 days

## Multi-Repo Sprint Planning

### Sprint Kickoff Script

```bash
ORG="my-org"
PROJECT=5
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway")

echo "=== Sprint Planning ==="
echo

# Show backlog items per repo
for repo in "${REPOS[@]}"; do
  echo "## $repo"
  gh issue list --repo "$repo" --label "status:triage" --state open \
    --json number,title,labels \
    --jq '.[] | "  #\(.number) \(.title) [\(.labels | map(.name) | join(", "))]"'
  echo
done

# Show unassigned high-priority items
echo "## Unassigned High Priority"
for repo in "${REPOS[@]}"; do
  gh issue list --repo "$repo" --label "priority:high" --search "no:assignee" --state open \
    --json number,title,url \
    --jq '.[] | "  \(.url) \(.title)"'
done
```

### Sprint Retrospective — Velocity

```bash
ORG="my-org"
REPOS=("$ORG/frontend" "$ORG/backend" "$ORG/api-gateway")
SINCE="2026-03-01"

echo "=== Sprint Velocity ==="
for repo in "${REPOS[@]}"; do
  CLOSED=$(gh issue list --repo "$repo" --state closed \
    --search "closed:>=$SINCE" --json number --jq '. | length')
  OPENED=$(gh issue list --repo "$repo" --state all \
    --search "created:>=$SINCE" --json number --jq '. | length')
  echo "$repo — Closed: $CLOSED | Opened: $OPENED"
done
```

## Linking Projects to Repos

A single project can aggregate issues from unlimited repos. The key commands:

```bash
# Add issue from any repo
gh project item-add PROJECT_NUMBER --owner "org" --url ISSUE_OR_PR_URL

# The item retains its repo context — you can filter by repo in project views
```

### Create a "Repository" Field for Filtering

Since project views can't natively group by repository, create a single-select field:

```bash
gh project field-create PROJECT_NUMBER --owner "my-org" \
  --name "Repository" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "frontend,backend,api-gateway,mobile-app,infra"
```

Then set it when adding items, or use a script to auto-detect from the issue URL.

## Project Templates

### Product Roadmap

Fields: Status, Priority, Quarter (Single Select: Q1/Q2/Q3/Q4), Theme (Single Select), Due Date
Views: Board by Status, Table sorted by Quarter, Board by Theme

### Sprint Board

Fields: Status, Priority, Story Points, Sprint (Iteration), Assignee, Team
Views: Board by Status (current sprint filter), Table (all sprints), Board by Team

### Bug Tracker

Fields: Status, Severity (Critical/High/Medium/Low), Reported By (Text), Environment (Single Select: Production/Staging/Dev)
Views: Board by Status, Table sorted by Severity, Board by Environment

## GraphQL — Get Project ID and Field IDs

Most field operations require IDs. Here's how to fetch them:

```bash
# Get project ID and all field IDs
gh api graphql -f query='
  query($org: String!, $number: Int!) {
    organization(login: $org) {
      projectV2(number: $number) {
        id
        fields(first: 20) {
          nodes {
            ... on ProjectV2Field { id name }
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
            ... on ProjectV2IterationField {
              id
              name
              configuration {
                iterations { id title startDate }
              }
            }
          }
        }
      }
    }
  }
' -F number=5 -f org="my-org"
```

## GraphQL — Update Item Field Value

```bash
# Set a single-select field (e.g., Priority = High)
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PVT_xxx"
      itemId: "PVTI_xxx"
      fieldId: "PVTSSF_xxx"
      value: { singleSelectOptionId: "option_id_here" }
    }) {
      projectV2Item { id }
    }
  }
'

# Set a number field (e.g., Story Points = 5)
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PVT_xxx"
      itemId: "PVTI_xxx"
      fieldId: "PVTF_xxx"
      value: { number: 5 }
    }) {
      projectV2Item { id }
    }
  }
'

# Set a date field
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PVT_xxx"
      itemId: "PVTI_xxx"
      fieldId: "PVTF_xxx"
      value: { date: "2026-04-01" }
    }) {
      projectV2Item { id }
    }
  }
'

# Set a text field
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PVT_xxx"
      itemId: "PVTI_xxx"
      fieldId: "PVTF_xxx"
      value: { text: "Needs design review" }
    }) {
      projectV2Item { id }
    }
  }
'
```
