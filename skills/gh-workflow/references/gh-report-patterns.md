# GitHub Report Patterns

## HTML Template System

All HTML reports follow a consistent dark theme with GitHub-inspired styling. The base template:

### Base CSS Variables

```css
:root {
  --bg-primary: #0d1117;
  --bg-secondary: #161b22;
  --bg-tertiary: #21262d;
  --border: #30363d;
  --text-primary: #e6edf3;
  --text-secondary: #8b949e;
  --text-muted: #484f58;
  --accent-blue: #58a6ff;
  --accent-green: #3fb950;
  --accent-red: #f85149;
  --accent-purple: #bc8cff;
  --accent-orange: #d29922;
  --accent-yellow: #e3b341;
}
```

### Badge Colours by Status

```css
.badge-open { background: #238636; color: #fff; }
.badge-closed { background: #da3633; color: #fff; }
.badge-merged { background: #8957e5; color: #fff; }
.badge-draft { background: #30363d; color: #8b949e; }
.badge-critical { background: #b60205; color: #fff; }
.badge-high { background: #d93f0b; color: #fff; }
.badge-medium { background: #fbca04; color: #000; }
.badge-low { background: #0e8a16; color: #fff; }
```

## Report Generation Helper Script

Create a reusable script for generating reports:

```bash
#!/bin/bash
# gh-report.sh — Generate GitHub reports
# Usage: ./gh-report.sh [repo|multi|project|contributor] [format] [since]

TYPE="${1:-repo}"
FORMAT="${2:-md}"
SINCE="${3:-$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)}"
OUTPUT_DIR="./reports"
mkdir -p "$OUTPUT_DIR"

case "$TYPE" in
  repo)
    REPO="${REPO:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner')}"
    FILENAME="repo-activity-$(date +%Y%m%d)"
    ;;
  multi)
    FILENAME="multi-repo-$(date +%Y%m%d)"
    ;;
  project)
    FILENAME="project-$(date +%Y%m%d)"
    ;;
  contributor)
    FILENAME="contributors-$(date +%Y%m%d)"
    ;;
esac

echo "Generating $TYPE report in $FORMAT format since $SINCE..."
echo "Output: $OUTPUT_DIR/$FILENAME.$FORMAT"
```

## Scheduled Report via GitHub Actions

Create a workflow that generates and commits reports on a schedule:

```yaml
# .github/workflows/weekly-report.yml
name: Weekly Report

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9am UTC
  workflow_dispatch:

permissions:
  contents: write
  issues: read
  pull-requests: read

jobs:
  generate-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate report
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          REPO="${{ github.repository }}"
          SINCE=$(date -d '7 days ago' +%Y-%m-%d)
          mkdir -p reports

          # Gather metrics
          ISSUES_OPENED=$(gh issue list --repo "$REPO" --state all --search "created:>=$SINCE" --json number --jq '. | length')
          ISSUES_CLOSED=$(gh issue list --repo "$REPO" --state closed --search "closed:>=$SINCE" --json number --jq '. | length')
          PRS_MERGED=$(gh pr list --repo "$REPO" --state merged --search "merged:>=$SINCE" --json number --jq '. | length')

          cat > "reports/weekly-$(date +%Y%m%d).md" <<EOF
          # Weekly Report — $(date +%Y-%m-%d)

          | Metric | Count |
          |---|---|
          | Issues Opened | $ISSUES_OPENED |
          | Issues Closed | $ISSUES_CLOSED |
          | PRs Merged | $PRS_MERGED |
          EOF

      - name: Commit report
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add reports/
          git diff --staged --quiet || git commit -m "chore: add weekly report $(date +%Y-%m-%d)"
          git push
```

## Multi-Repo Report with Charts (HTML)

For visual HTML reports, use inline SVG charts:

### Bar Chart Helper

```html
<div class="chart">
  <div class="bar-group" data-label="frontend">
    <div class="bar" style="width: 65%; background: var(--accent-blue);">13 issues</div>
  </div>
  <div class="bar-group" data-label="backend">
    <div class="bar" style="width: 85%; background: var(--accent-green);">17 issues</div>
  </div>
  <div class="bar-group" data-label="api-gateway">
    <div class="bar" style="width: 35%; background: var(--accent-purple);">7 issues</div>
  </div>
</div>

<style>
.chart { margin: 1.5rem 0; }
.bar-group { display: flex; align-items: center; margin: 0.5rem 0; }
.bar-group::before { content: attr(data-label); width: 120px; font-size: 0.85rem; color: var(--text-secondary); }
.bar { height: 28px; border-radius: 4px; display: flex; align-items: center; padding: 0 10px; font-size: 0.8rem; color: #fff; min-width: 60px; transition: width 0.5s ease; }
</style>
```

### Donut Chart (SVG)

```html
<svg viewBox="0 0 100 100" width="200" height="200">
  <!-- Background circle -->
  <circle cx="50" cy="50" r="40" fill="none" stroke="#30363d" stroke-width="12"/>
  <!-- Segment: Open (green) — 60% -->
  <circle cx="50" cy="50" r="40" fill="none" stroke="#3fb950" stroke-width="12"
    stroke-dasharray="150.8 251.3" stroke-dashoffset="0" transform="rotate(-90 50 50)"/>
  <!-- Segment: Closed (red) — 30% -->
  <circle cx="50" cy="50" r="40" fill="none" stroke="#f85149" stroke-width="12"
    stroke-dasharray="75.4 251.3" stroke-dashoffset="-150.8" transform="rotate(-90 50 50)"/>
  <!-- Segment: Draft (grey) — 10% -->
  <circle cx="50" cy="50" r="40" fill="none" stroke="#30363d" stroke-width="12"
    stroke-dasharray="25.1 251.3" stroke-dashoffset="-226.2" transform="rotate(-90 50 50)"/>
  <!-- Center text -->
  <text x="50" y="48" text-anchor="middle" fill="#e6edf3" font-size="14" font-weight="700">42</text>
  <text x="50" y="60" text-anchor="middle" fill="#8b949e" font-size="7">total</text>
</svg>
```

## JSON Report Schema

Standardised JSON schema for all report types:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "report_type": { "type": "string", "enum": ["repo-activity", "multi-repo", "project-board", "contributor"] },
    "generated_at": { "type": "string", "format": "date-time" },
    "period": {
      "type": "object",
      "properties": {
        "from": { "type": "string", "format": "date" },
        "to": { "type": "string", "format": "date" }
      }
    },
    "repository": { "type": "string" },
    "repositories": { "type": "array", "items": { "type": "string" } },
    "summary": { "type": "object" },
    "details": { "type": "array" }
  },
  "required": ["report_type", "generated_at", "period", "summary"]
}
```

## Combining Reports

Generate all three formats at once:

```bash
REPO="owner/repo"
SINCE="2026-03-01"
OUTPUT_DIR="./reports"
BASE="repo-activity-$(date +%Y%m%d)"

# 1. Generate JSON first (single source of truth)
# [gather data and write JSON as shown in SKILL.md]

# 2. Convert JSON to Markdown
jq -r '
  "# Repository Activity Report\n",
  "**Repository:** \(.repository)",
  "**Period:** \(.period.from) to \(.period.to)\n",
  "| Metric | Count |",
  "|---|---|",
  "| Issues Opened | \(.summary.issues_opened) |",
  "| Issues Closed | \(.summary.issues_closed) |",
  "| PRs Merged | \(.summary.prs_merged) |"
' "$OUTPUT_DIR/$BASE.json" > "$OUTPUT_DIR/$BASE.md"

# 3. Generate HTML from JSON (inject into template)
# [use the HTML template from SKILL.md with __REPORT_DATA__ replacement]
```

## Report Output Naming Convention

```
reports/
├── repo-activity-20260311.md
├── repo-activity-20260311.json
├── repo-activity-20260311.html
├── multi-repo-20260311.md
├── project-report-20260311.md
├── contributor-report-20260311.md
└── weekly-20260310.md
```

Pattern: `{report-type}-{YYYYMMDD}.{format}`

## Emailing Reports

Use `gh api` to create an issue with the report attached as a comment, or use a GitHub Action to send via email:

```yaml
- name: Send report via email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.MAIL_USERNAME }}
    password: ${{ secrets.MAIL_PASSWORD }}
    subject: "Weekly Report — ${{ github.repository }}"
    to: team@example.com
    from: reports@example.com
    html_body: file://reports/repo-activity.html
    attachments: reports/repo-activity.json
```
