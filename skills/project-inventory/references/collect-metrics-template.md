# Data Collection Script Template

Bash script that reads `claude-code-projects.json` and outputs `ai-portfolio-data.json`.
Uses local git for repos that exist locally, falls back to GitHub API via `gh` CLI.

## Script Structure

```bash
#!/usr/bin/env bash
# collect-ai-metrics.sh — Extract AI collaboration metrics
# Input: claude-code-projects.json (from /inventory report)
# Output: ai-portfolio-data.json

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="$SCRIPT_DIR/claude-code-projects.json"
OUTPUT="$SCRIPT_DIR/ai-portfolio-data.json"

# Validate input exists
if [[ ! -f "$INPUT" ]]; then
  echo "Error: $INPUT not found. Run /inventory report first." >&2
  exit 1
fi

# Check dependencies
for cmd in jq git python3; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required" >&2
    exit 1
  fi
done

# Check GitHub CLI (optional — enables remote repo stats)
HAS_GH=false
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  HAS_GH=true
  echo "GitHub CLI authenticated — will fetch remote repos via API"
fi
```

## GitHub API Helpers

Use these helper functions for projects without local git repos.
All AI-related data comes from a **single** search API call per repo
to stay within the 30 requests/minute search rate limit.

```bash
# Extract owner/repo from GitHub URL
gh_repo_from_url() {
  echo "$1" | sed -E 's|https?://github\.com/([^/]+/[^/]+).*|\1|' | sed 's/\.git$//'
}

# Get total commit count via pagination header
gh_get_commit_count() {
  local repo="$1"
  local header
  header=$(gh api "repos/$repo/commits?per_page=1" -i 2>/dev/null | grep -i '^link:')
  if [[ -n "$header" ]]; then
    echo "$header" | grep -oE 'page=[0-9]+' | tail -1 | cut -d= -f2
  else
    echo 1
  fi
}

# Get first/last commit dates
gh_get_first_commit_date() {
  local repo="$1" total="$2"
  gh api "repos/$repo/commits?per_page=1&page=$total" --jq '.[0].commit.author.date' 2>/dev/null
}

gh_get_last_commit_date() {
  local repo="$1"
  gh api "repos/$repo/commits?per_page=1" --jq '.[0].commit.author.date' 2>/dev/null
}

# Combined AI data — single search call for count, models, first date, monthly
gh_get_ai_data() {
  local repo="$1"
  local tmpfile
  tmpfile=$(mktemp)

  sleep 3  # Respect search rate limit (30/min)
  gh api "search/commits?q=repo:$repo+%22Co-Authored-By%22+%22Claude%22&per_page=100&sort=author-date&order=asc" \
    --jq '{total: .total_count, items: [.items[] | {date: .commit.author.date, message: .commit.message}]}' \
    2>/dev/null > "$tmpfile" || echo '{"total":0,"items":[]}' > "$tmpfile"

  GH_AI_COUNT=$(jq -r '.total // 0' "$tmpfile")
  [[ "$GH_AI_COUNT" =~ ^[0-9]+$ ]] || GH_AI_COUNT=0

  GH_FIRST_AI_DATE=$(jq -r '.items[0].date // empty' "$tmpfile")

  GH_MODELS=$(jq -r '.items[].message' "$tmpfile" 2>/dev/null \
    | grep -ioE "Co-Authored-By: Claude [^<]+" \
    | sed 's/[Cc]o-[Aa]uthored-[Bb]y: //' \
    | sed 's/[[:space:]]*$//' \
    | sort -u || true)

  GH_MONTHLY_AI=$(jq -r '.items[].date' "$tmpfile" 2>/dev/null \
    | cut -c1-7 | sort | uniq -c | awk '{printf "%s %s\n", $2, $1}' || true)

  rm "$tmpfile"
}

# Other GitHub helpers
gh_get_monthly_commits() {
  local repo="$1"
  gh api "repos/$repo/commits?per_page=100" --paginate --jq '.[].commit.author.date' 2>/dev/null \
    | cut -c1-7 | sort | uniq -c | awk '{printf "%s %s\n", $2, $1}'
}

gh_get_languages() {
  local repo="$1"
  gh api "repos/$repo/languages" --jq 'keys[]' 2>/dev/null || true
}

gh_get_authors_count() {
  local repo="$1"
  gh api "repos/$repo/contributors?per_page=100" --jq 'length' 2>/dev/null || echo 1
}
```

## Main Loop

Iterate each project. Determine source (local/github/skip), extract metrics,
write one JSON object per line to a temp JSONL file.

```bash
TEMP_JSONL=$(mktemp)
> "$TEMP_JSONL"
SEEN_REPOS=""  # Track GitHub repos to avoid duplicates

for i in $(seq 0 $((PROJECT_COUNT - 1))); do
  NAME=$(jq -r ".[$i].name" "$INPUT")
  PROJ_PATH=$(jq -r ".[$i].path" "$INPUT")
  URL=$(jq -r ".[$i].url // \"\"" "$INPUT")

  # Determine source
  if [[ -d "$PROJ_PATH/.git" ]]; then
    SOURCE="local"
  elif [[ "$HAS_GH" = true ]] && [[ "$URL" == *github.com* ]]; then
    GH_REPO=$(gh_repo_from_url "$URL")
    if echo "$SEEN_REPOS" | grep -qF "$GH_REPO"; then
      echo "  DEDUP $NAME (same repo: $GH_REPO)"
      continue
    fi
    SOURCE="github"
    SEEN_REPOS="$SEEN_REPOS $GH_REPO"
  else
    echo "  SKIP $NAME"
    continue
  fi

  # ... extract metrics based on SOURCE ...
  # ... build JSON via jq -cn ... >> "$TEMP_JSONL"
done
```

## Local Git Extraction Patterns

```bash
# Total commits
TOTAL_COMMITS=$(git -C "$PROJ_PATH" rev-list --all --count 2>/dev/null || echo 0)

# Co-authored commits (unique hashes)
CO_AUTHORED=$(git -C "$PROJ_PATH" log --all --format="COMMIT_START %H%n%b" 2>/dev/null \
  | awk '/^COMMIT_START /{hash=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*([Cc]laude|[Aa]nthropic|[Oo]pencode)/{print hash}' \
  | sort -u | wc -l | tr -d ' ')

# First/last commit dates
FIRST_COMMIT_DATE=$(git -C "$PROJ_PATH" log --all --reverse --format="%aI" 2>/dev/null | head -1)
LAST_COMMIT_DATE=$(git -C "$PROJ_PATH" log --all --format="%aI" -1 2>/dev/null)

# First AI commit date
FIRST_AI_COMMIT_DATE=$(git -C "$PROJ_PATH" log --all --reverse --format="COMMIT_START %aI%n%b" 2>/dev/null \
  | awk '/^COMMIT_START /{date=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*([Cc]laude|[Aa]nthropic|[Oo]pencode)/{print date; exit}')

# All Co-Authored-By lines to classify AI tools
ALL_COAUTHORS=$(git -C "$PROJ_PATH" log --all --format="%b" 2>/dev/null \
  | grep -ioE "Co-Authored-By: [^<]+<[^>]+>" || true)

# Claude models used
CLAUDE_MODELS_RAW=$(echo "$ALL_COAUTHORS" \
  | grep -ioE "Co-Authored-By: Claude [^<]+" \
  | sed 's/[Cc]o-[Aa]uthored-[Bb]y: //' \
  | sed 's/[[:space:]]*$//' \
  | sort -u || true)

# Detect AI tools by email pattern
AI_TOOLS=""
echo "$ALL_COAUTHORS" | grep -qi "noreply@anthropic.com" && AI_TOOLS="${AI_TOOLS}Claude,"
echo "$ALL_COAUTHORS" | grep -qi "opencode@anthropic.com" && AI_TOOLS="${AI_TOOLS}OpenCode,"
echo "$ALL_COAUTHORS" | grep -qi "Copilot@users.noreply.github.com" && AI_TOOLS="${AI_TOOLS}Copilot,"
AI_TOOLS="${AI_TOOLS%,}"

# Per-tool commit counts (unique hashes per tool)
CLAUDE_COMMITS=$(git -C "$PROJ_PATH" log --all --format="COMMIT_START %H%n%b" 2>/dev/null \
  | awk '/^COMMIT_START /{hash=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*noreply@anthropic\.com/{print hash}' \
  | sort -u | wc -l | tr -d ' ')
OPENCODE_COMMITS=$(git -C "$PROJ_PATH" log --all --format="COMMIT_START %H%n%b" 2>/dev/null \
  | awk '/^COMMIT_START /{hash=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*opencode@anthropic\.com/{print hash}' \
  | sort -u | wc -l | tr -d ' ')
COPILOT_COMMITS=$(git -C "$PROJ_PATH" log --all --format="COMMIT_START %H%n%b" 2>/dev/null \
  | awk '/^COMMIT_START /{hash=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*Copilot@users\.noreply\.github\.com/{print hash}' \
  | sort -u | wc -l | tr -d ' ')

# Monthly commits
MONTHLY_JSON=$(git -C "$PROJ_PATH" log --all --format="%ad" --date=format:"%Y-%m" 2>/dev/null \
  | sort | uniq -c | awk '{printf "%s %s\n", $2, $1}')

# Monthly AI commits
MONTHLY_AI_JSON=$(git -C "$PROJ_PATH" log --all --format="COMMIT_START %ad%n%b" --date=format:"%Y-%m" 2>/dev/null \
  | awk '/^COMMIT_START /{month=$2} /[Cc]o-[Aa]uthored-[Bb]y:.*([Cc]laude|[Aa]nthropic|[Oo]pencode)/{print month}' \
  | sort | uniq -c | awk '{printf "%s %s\n", $2, $1}')
```

## JSON Construction

Use `jq -cn` for safe, compact JSON — one object per line (JSONL format):

```bash
jq -cn \
  --arg name "$NAME" \
  --arg path "$PROJ_PATH" \
  --argjson tc "$TOTAL_COMMITS" \
  --argjson ca "$CO_AUTHORED" \
  --arg models "${CLAUDE_MODELS_RAW:-}" \
  --arg tech "$TECH" \
  --arg monthly "$MONTHLY_JSON" \
  --arg monthly_ai "$MONTHLY_AI_JSON" \
  --arg source "$SOURCE" \
  --arg ai_tools "${AI_TOOLS:-}" \
  --argjson claude_c "${CLAUDE_COMMITS:-0}" \
  --argjson opencode_c "${OPENCODE_COMMITS:-0}" \
  --argjson copilot_c "${COPILOT_COMMITS:-0}" \
  '{
    name: $name,
    total_commits: $tc,
    co_authored_commits: $ca,
    co_author_percentage: (if $tc > 0 then (($ca / $tc * 1000 | round) / 10) else 0 end),
    claude_models_used: ($models | split("\n") | map(select(length > 0))),
    ai_tools: ($ai_tools | split(",") | map(select(length > 0))),
    claude_commits: $claude_c,
    opencode_commits: $opencode_c,
    copilot_commits: $copilot_c,
    tech_stack: ($tech | split(",") | map(select(length > 0))),
    monthly_commits: [($monthly | split("\n") | .[] | select(length > 0) | split(" ") | {month: .[0], count: (.[1] | tonumber)})],
    monthly_ai_commits: [($monthly_ai | split("\n") | .[] | select(length > 0) | split(" ") | {month: .[0], count: (.[1] | tonumber)})],
    source: $source
  }' >> "$TEMP_JSONL"
```

## Python Aggregation

After all projects are collected, use Python to compute aggregates and write final JSON:

```python
python3 - "$TEMP_JSONL" "$OUTPUT" << 'PYEOF'
import json, sys
from collections import defaultdict
from datetime import datetime

projects = []
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if line:
            projects.append(json.loads(line))

# Compute aggregates: totals, by_org, by_category, tech_stack,
# monthly_timeline, ai_adoption_timeline, model_projects, ai_tool_breakdown

# AI tool breakdown
total_claude = sum(p.get("claude_commits", 0) for p in projects)
total_opencode = sum(p.get("opencode_commits", 0) for p in projects)
total_copilot = sum(p.get("copilot_commits", 0) for p in projects)

tool_projects = defaultdict(list)
for p in projects:
    for t in p.get("ai_tools", []):
        if t:
            tool_projects[t].append(p["name"])

output = {
    "generated_at": datetime.now().isoformat(),
    "aggregates": {
        # ... totals, by_org, by_category, tech_stack, timeline, adoption, model_projects ...
        "ai_tool_breakdown": {
            "Claude": {"commits": total_claude, "projects": sorted(tool_projects.get("Claude", []))},
            "OpenCode": {"commits": total_opencode, "projects": sorted(tool_projects.get("OpenCode", []))},
            "Copilot": {"commits": total_copilot, "projects": sorted(tool_projects.get("Copilot", []))},
        },
        "ai_tools_summary": {t: len(ps) for t, ps in sorted(tool_projects.items())}
    },
    "projects": sorted(projects, key=lambda x: x.get("co_authored_commits", 0), reverse=True)
}

with open(sys.argv[2], "w") as f:
    json.dump(output, f, indent=2, default=str)
PYEOF
```

## Tech Stack Detection (Local)

```bash
TECH=""
[[ -f "$PROJ_PATH/artisan" ]] && TECH="${TECH}Laravel,"
[[ -f "$PROJ_PATH/composer.json" ]] && TECH="${TECH}PHP,"
[[ -f "$PROJ_PATH/package.json" ]] && TECH="${TECH}Node.js,"
[[ -f "$PROJ_PATH/go.mod" ]] && TECH="${TECH}Go,"
[[ -f "$PROJ_PATH/Cargo.toml" ]] && TECH="${TECH}Rust,"
[[ -f "$PROJ_PATH/tsconfig.json" ]] && TECH="${TECH}TypeScript,"
# ... etc
TECH="${TECH%,}"
```

## Tech Stack Detection (GitHub API)

```bash
LANGS=$(gh api "repos/$REPO/languages" --jq 'keys[]' 2>/dev/null || true)
echo "$LANGS" | grep -qi "php" && TECH="${TECH}PHP,"
echo "$LANGS" | grep -qi "javascript" && TECH="${TECH}Node.js,"
echo "$LANGS" | grep -qi "typescript" && TECH="${TECH}TypeScript,"
echo "$LANGS" | grep -qi "^go$" && TECH="${TECH}Go,"
# ... etc
```
