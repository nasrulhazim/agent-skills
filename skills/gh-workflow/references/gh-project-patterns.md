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

## Bulk Field Update Script

When setting up a roadmap project with many items, use a bash array to bulk-update fields efficiently:

```bash
PROJECT_ID="PVT_xxx"
PHASE_FIELD="PVTSSF_xxx"
PRIORITY_FIELD="PVTSSF_xxx"
STATUS_FIELD="PVTSSF_xxx"
START_FIELD="PVTF_xxx"
TARGET_FIELD="PVTF_xxx"

# Option IDs (from field query above)
PHASE1="option_id"
PHASE2="option_id"
HIGH="option_id"
MEDIUM="option_id"
TODO="option_id"
DONE="option_id"

# Format: item_id,phase,priority,status,start_date,target_date
declare -a ITEMS=(
  "PVTI_item1,$PHASE1,$HIGH,$DONE,2026-01-06,2026-02-14"
  "PVTI_item2,$PHASE1,$MEDIUM,$TODO,2026-03-12,2026-03-19"
  "PVTI_item3,$PHASE2,$HIGH,$TODO,2026-04-01,2026-04-15"
)

set_field() {
  local ITEM_ID=$1 FIELD_ID=$2 VALUE_KEY=$3 VALUE=$4
  gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: {
    projectId: \"$PROJECT_ID\", itemId: \"$ITEM_ID\",
    fieldId: \"$FIELD_ID\", value: { $VALUE_KEY: \"$VALUE\" }
  }) { projectV2Item { id } } }" 2>/dev/null
}

for entry in "${ITEMS[@]}"; do
  IFS=',' read -r ITEM PHASE PRIORITY STATUS START TARGET <<< "$entry"
  set_field "$ITEM" "$PHASE_FIELD" "singleSelectOptionId" "$PHASE"
  set_field "$ITEM" "$PRIORITY_FIELD" "singleSelectOptionId" "$PRIORITY"
  set_field "$ITEM" "$STATUS_FIELD" "singleSelectOptionId" "$STATUS"
  set_field "$ITEM" "$START_FIELD" "date" "$START"
  set_field "$ITEM" "$TARGET_FIELD" "date" "$TARGET"
done
```

## Roadmap Timeline View

The **Roadmap** layout shows items as horizontal bars on a timeline. Requirements:

1. **Two Date fields** on the project: `Start Date` and `Target Date`
2. **Set dates** on every item (items without dates won't appear on the timeline)
3. **Create a Roadmap view** in the web UI (views CANNOT be created via API)

### Setup Steps (Web UI)

1. Go to the project URL
2. Click `+` (New view) → select **Roadmap** layout
3. Click the gear icon in the timeline header
4. Set **Start date** field → `Start Date`
5. Set **Target date** field → `Target Date`
6. Optionally group by **Phase** for swimlane rows

### Recommended Views

| View Name | Layout | Group By | Purpose |
|-----------|--------|----------|---------|
| Kanban Board | Board | Status | Day-to-day work tracking |
| By Phase | Board | Phase | Phase-level progress |
| Roadmap | Roadmap | Phase (optional) | Timeline visualization |
| By Priority | Table | — (sort by Priority) | Prioritization review |

### API Limitations for Views

> **Important:** GitHub's GraphQL API does NOT support creating, updating, or deleting
> ProjectV2 views. The `createProjectV2View` mutation does not exist in the schema.
> Views can only be **read** via the API (`views` field on `ProjectV2`).
> All view management must be done through the GitHub web UI.

```bash
# Read existing views (read-only)
gh api graphql -f query='
  query($org: String!, $number: Int!) {
    organization(login: $org) {
      projectsV2(first: 1, query: "Product Roadmap") {
        nodes {
          views(first: 10) {
            nodes { id name layout }
          }
        }
      }
    }
  }
' -f org="my-org" -F number=8
```

## Update Project Description and README

```bash
gh api graphql -f query='
  mutation($id: ID!, $desc: String!, $readme: String!) {
    updateProjectV2(input: {
      projectId: $id
      shortDescription: $desc
      readme: $readme
    }) {
      projectV2 { id }
    }
  }
' -f id="PVT_xxx" \
  -f desc="Product development roadmap — Phase 1, Phase 2, Phase 3" \
  -f readme="# Product Roadmap\n\nTracking all development phases.\n\n| Phase | Timeline |\n|-------|----------|\n| Phase 1 | Q1 2026 |\n| Phase 2 | Q2 2026 |\n| Phase 3 | Q3-Q4 2026 |"
```

## Get Item IDs Mapped to Issue Numbers

Essential for scripting field updates — maps project item IDs to issue numbers:

```bash
gh project item-list PROJECT_NUMBER --owner "my-org" --format json | \
  python3 -c "
import json, sys
data = json.load(sys.stdin)
for item in data['items']:
    print(f\"{item['id']},{item['content']['number']},{item['content']['title']}\")
"
```

## Bulk Assign Issues

```bash
REPO="my-org/my-app"
ASSIGNEE="developer1"

# Assign a range of issues
for i in $(seq 1 23); do
  gh issue edit $i --repo "$REPO" --add-assignee "$ASSIGNEE"
done

# Assign by label
for i in $(gh issue list --repo "$REPO" --label "phase:1" --state open --json number --jq '.[].number'); do
  gh issue edit $i --repo "$REPO" --add-assignee "$ASSIGNEE"
done
```

## Create Issues and Close Done Ones

```bash
REPO="my-org/my-app"

# Create and immediately close a completed feature
URL=$(gh issue create --repo "$REPO" \
  --title "Feature Name" \
  --body "Description" \
  --label "phase:1,priority:high,effort:small" 2>&1 | grep https)

# Extract issue number and close
NUM=$(echo "$URL" | grep -o '[0-9]*$')
gh issue close "$NUM" --repo "$REPO"
```
