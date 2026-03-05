---
name: dev-summary
metadata:
  compatible_agents: [claude-code]
  tags: [git, stats, summary, commits, timeline, development, reporting, multi-repo]
description: >
  Multi-repo development summary and timeline skill — scans one or more git
  repositories and produces a combined summary table with first commit date,
  latest commit date, total commits, duration, and per-repo breakdowns.
  Optionally generates a detailed report with file counts, contributor stats,
  commit frequency, and an HTML timeline dashboard. Use this skill whenever the
  user asks for development stats, project timeline, commit history summary, how
  long a project has been in development, or wants a combined view across multiple
  repos — including: "berapa lama dah develop", "development summary", "commit
  stats", "project timeline", "how many commits", "summarise all repos",
  "ringkasan development", "statistik commit", "berapa commit semua repo",
  "timeline projek ni", "development report".
---

# Dev Summary — Multi-Repo Development Stats & Timeline

Scans git repositories and produces combined development summaries with commit
stats, timelines, and optional detailed reports.

## Command Reference

| Command | Purpose |
|---------|---------|
| `/dev-summary quick` | Quick summary table — dates + commit counts |
| `/dev-summary detailed` | Detailed report — files, contributors, frequency |
| `/dev-summary timeline` | HTML timeline dashboard with charts |

---

## `/dev-summary quick`

Generate a quick combined summary table for one or more repos.

### Steps

1. **Get repo paths** — ask the user for repo paths if not provided. Accept:
   - Current directory (default)
   - Multiple paths (comma or space separated)
   - Glob patterns (e.g., `~/Projects/2026/*`)

2. **For each repo, extract**:

   ```bash
   # First commit date
   git log --reverse --format="%ai" | head -1

   # Latest commit date
   git log --format="%ai" | head -1

   # Total commits
   git log --oneline | wc -l
   ```

3. **Present combined table**:

   ```markdown
   ## Development Summary

   | Repo | Mula | Latest | Commits |
   |---|---|---|---|
   | **repo-name** | DD Mon YYYY | DD Mon YYYY | N |
   | **TOTAL** | **earliest** | **latest** | **sum** |

   - **Duration**: N days (N weeks)
   - **Average**: ~N commits/day across all repos
   ```

4. **Run all repo scans in parallel** — use parallel tool calls for each repo
   to minimize wait time.

### Notes

- Repo name is derived from directory name
- Dates formatted as `DD Mon YYYY` (e.g., `8 Jan 2026`)
- Duration calculated from earliest first commit to latest last commit
- Average commits/day = total commits / duration days

---

## `/dev-summary detailed`

Generate a detailed development report with file counts, contributors, and
commit frequency analysis.

### Steps

1. **Run quick summary first** — get base stats from `/dev-summary quick`

2. **For each repo, additionally extract**:

   ```bash
   # Source file count (excluding vendor/node_modules/.git)
   find . -not -path './.git/*' -not -path './vendor/*' \
          -not -path './node_modules/*' -not -path './dist/*' \
          -type f | wc -l

   # Unique contributors
   git log --format="%aN <%aE>" | sort -u

   # Commits per month (last 6 months)
   git log --format="%Y-%m" | sort | uniq -c | tail -6

   # Most active day
   git log --format="%ai" | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -1

   # Language/stack detection (check for key files)
   # composer.json → PHP/Laravel
   # package.json → Node/JS
   # go.mod → Go
   # Cargo.toml → Rust
   # pyproject.toml → Python
   ```

3. **Present detailed report**:

   ```markdown
   ## Development Report

   ### Overview
   [Quick summary table from step 1]

   ### Per-Repo Details

   #### repo-name
   - **Stack**: Laravel / Node.js / etc.
   - **Files**: N source files
   - **Contributors**: N (list names)
   - **Most active day**: YYYY-MM-DD (N commits)
   - **Monthly breakdown**:
     | Month | Commits |
     |-------|---------|
     | 2026-01 | N |
     | 2026-02 | N |

   ### Combined Stats
   | Metric | Value |
   |--------|-------|
   | Total repos | N |
   | Total commits | N |
   | Total source files | N |
   | Unique contributors | N |
   | Duration | N days |
   | Avg commits/day | ~N |
   | Most active repo | repo-name (N commits) |
   ```

---

## `/dev-summary timeline`

Generate a self-contained HTML timeline dashboard.

### Steps

1. **Run detailed summary first** — collect all stats

2. **Generate HTML file** (`dev-timeline.html`):

   **Sections:**

   | # | Section | Content |
   |---|---------|---------|
   | 1 | Header | Project name, total duration, total commits |
   | 2 | Stat Cards | 4 cards: repos, commits, duration, avg/day |
   | 3 | Timeline | Horizontal timeline showing each repo's active period |
   | 4 | Commit Chart | Monthly stacked bar chart per repo |
   | 5 | Repo Cards | Per-repo detail cards with key stats |
   | 6 | Footer | Generated date |

   **Design:**
   - Self-contained (no external dependencies)
   - Dark theme default with light toggle (localStorage)
   - Fonts: system-ui stack
   - Colors: distinct color per repo (blue, green, amber, purple, cyan, pink)
   - Timeline: CSS grid with repo bars showing start→end dates
   - Charts: CSS-only (calculated widths for bars)
   - Responsive at 768px
   - Print-friendly via `@media print`

3. **Save and report** — tell user the file path and size

### Output Files

| File | Purpose |
|------|---------|
| `dev-timeline.html` | Self-contained HTML dashboard |

---

## Stack Detection

| File | Stack |
|------|-------|
| `artisan` + `composer.json` | Laravel |
| `package.json` + `next.config.*` | Next.js |
| `package.json` + `astro.config.*` | Astro |
| `package.json` + `vite.config.*` | Vite |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` | Python |
| `docker-compose.yml` (only) | Docker/Ops |
| `*.sh` scripts (only) | Shell/Ops |

---

## Notes

- Always run repo scans in parallel for speed
- Never modify any files in scanned repos — read-only operations
- Handle missing repos gracefully — warn and skip
- Use the repo's directory name as display name
- For monorepos, scan from root (don't recurse into sub-packages)
- Dates should respect the repo's timezone (from git log output)
- If user provides a single repo, skip the "combined" row in the table
- All git commands should work on any repo regardless of branch name

## Reference Files

| File | Description |
|------|-------------|
| `references/git-commands.md` | Git commands reference for extracting stats |
