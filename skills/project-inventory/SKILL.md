---
name: project-inventory
metadata:
  compatible_agents: [claude-code]
  tags: [inventory, discovery, claude-code, ai, projects, reporting, dashboard, metrics]
description: >
  Discovers and inventories all Claude Code and AI-integrated projects across
  specified directories. Scans for CLAUDE.md files, .claude/ directories, AI SDK
  imports, and MCP configurations, then generates structured reports in Markdown,
  JSON, and a self-contained HTML portfolio dashboard with AI collaboration metrics.
  Use this skill whenever the user asks to list all their Claude Code projects,
  discover AI-powered repos, audit which projects use Claude, generate a project
  inventory, build an AI portfolio dashboard, or export project data — including:
  "list semua project Claude Code", "scan for AI projects", "inventory my repos",
  "which projects use Claude", "export project list", "cari semua project yang guna
  AI", "senarai project Claude", "audit Claude Code usage", "buat dashboard AI",
  "generate AI portfolio", "show my AI stats".
---

# Project Inventory — Claude Code & AI Project Discovery

Discovers, audits, and reports on all Claude Code and AI-integrated projects
across your workspace. Generates human-readable Markdown, machine-readable JSON
inventories, and a visual HTML portfolio dashboard with AI collaboration metrics.

## Command Reference

| Command | Purpose |
|---------|---------|
| `/inventory scan` | Scan directories for Claude Code / AI projects |
| `/inventory report` | Generate Markdown + JSON inventory reports |
| `/inventory audit` | Audit Claude Code adoption and configuration quality |
| `/inventory dashboard` | Generate AI collaboration metrics + HTML portfolio dashboard |

---

## `/inventory scan`

Scan one or more directories to discover projects that use Claude Code or AI integrations.

### Detection Signals

Scan for these indicators (in priority order):

| Signal | Weight | Description |
|--------|--------|-------------|
| `CLAUDE.md` | High | Claude Code project instructions file |
| `.claude/` directory | High | Claude Code configuration directory |
| `.claude/settings.json` | High | Claude Code settings with MCP servers, permissions |
| `anthropic` SDK import | Medium | `@anthropic-ai/sdk` or `anthropic` Python package |
| `openai` SDK import | Medium | OpenAI SDK usage in source files |
| `google.generativeai` import | Medium | Google Gemini SDK usage |
| `.cursorrules` | Medium | Cursor AI configuration |
| `.github/copilot` | Medium | GitHub Copilot configuration |
| `MCP` config references | Medium | Model Context Protocol server configs |

### Steps

1. **Ask user for directories to scan** — prompt for one or more root directories
   (e.g., `~/Projects`, `~/Packages`, `~/Work`)

2. **Discover projects** — for each directory, find all git repositories or
   directories containing a `composer.json`, `package.json`, `Cargo.toml`,
   `go.mod`, `pyproject.toml`, or similar project markers

3. **Detect AI signals** — for each discovered project, check for the detection
   signals listed above

4. **Extract metadata** — for each matching project:
   - **Name**: directory name
   - **Path**: absolute path
   - **Description**: from `composer.json` description, `package.json` description,
     README first line, or CLAUDE.md first paragraph
   - **URL**: from git remote origin URL
   - **Organization**: extracted from git remote URL (GitHub org/user)
   - **Has CLAUDE.md**: boolean
   - **AI signals found**: list of detected signals
   - **Tech stack**: detected from project files (Laravel, React, Go, Python, etc.)

5. **Present summary** — show count and grouped list to user for review before
   generating reports

### Example Output

```
Found 48 projects with AI integration:

~/Projects — 30 projects
  2025/ — 11 projects
  2026/ — 6 projects
  nadi-pro/ — 11 projects

~/Packages — 18 projects
  claude-tools/ — 4 projects
  laravel-packages/ — 14 projects
```

---

## `/inventory report`

Generate structured inventory reports in Markdown and JSON formats.

### Steps

1. **Run scan** if not already done — execute `/inventory scan` first

2. **Ask for output directory** — where to save the reports

3. **Generate Markdown report** (`claude-code-projects.md`):

   Follow this structure:

   ```markdown
   # Claude Code Project Inventory

   > Generated: YYYY-MM-DD
   > Total: **N projects** across [directories listed]

   ---

   ## [Location 1] (count)

   ### [Category/Subfolder]

   | # | Project | Description | URL |
   |---|---------|-------------|-----|
   | 1 | **project-name** | Short description | https://github.com/org/repo |

   ---

   ## Summary

   | Metric | Count |
   |--------|-------|
   | **Total projects** | **N** |
   | Projects with CLAUDE.md | N |
   | Projects with .claude/ only | N |

   ### By Organization
   | Organization | Count |
   |-------------|-------|
   | org-name | N |

   ### By Tech Stack
   | Stack | Projects |
   |-------|----------|
   | Laravel | ~N |
   ```

4. **Generate JSON report** (`claude-code-projects.json`):

   Array of objects with this schema:

   ```json
   [
     {
       "name": "project-name",
       "path": "/absolute/path/to/project",
       "description": "Short project description",
       "url": "https://github.com/org/repo",
       "location": "Projects",
       "category": "Category Name",
       "hasClaudeMd": true,
       "org": "github-org-name",
       "techStack": "Laravel",
       "aiSignals": ["CLAUDE.md", ".claude/"]
     }
   ]
   ```

   Rules:
   - `url`: set to `null` if no git remote configured
   - `org`: set to `null` if local-only project
   - `hasClaudeMd`: boolean based on file existence
   - `aiSignals`: array of all detected signals

5. **Validate outputs**:
   - Verify JSON is valid: `python3 -m json.tool <file> > /dev/null`
   - Verify project count matches scan results
   - Report file paths and sizes to user

---

## `/inventory audit`

Audit Claude Code adoption quality across discovered projects.

### Steps

1. **Run scan** if not already done

2. **Check each project for**:
   - Has `CLAUDE.md` (not just `.claude/` directory)
   - `CLAUDE.md` has meaningful content (not empty/boilerplate)
   - Has `.claude/settings.json` with configured permissions
   - Has MCP servers configured
   - Has project-specific instructions (not generic template)

3. **Generate audit report**:

   ```markdown
   ## Claude Code Adoption Audit

   ### Fully Configured (CLAUDE.md + settings)
   - project-a, project-b, ...

   ### Partial (CLAUDE.md only)
   - project-c, project-d, ...

   ### Minimal (.claude/ directory only)
   - project-e, project-f, ...

   ### Recommendations
   - N projects missing CLAUDE.md — add project instructions
   - N projects have empty CLAUDE.md — add stack, conventions, gotchas
   - N projects missing .claude/settings.json — configure permissions
   ```

4. **Offer to scaffold** — ask if user wants to generate template `CLAUDE.md`
   files for projects that are missing them

---

## `/inventory dashboard`

Generate an AI collaboration portfolio dashboard — a self-contained HTML file
with embedded metrics, charts, and interactive features. Requires a
`claude-code-projects.json` from `/inventory report` as input.

### Steps

1. **Locate or generate project JSON** — check if `claude-code-projects.json`
   exists in the output directory. If not, run `/inventory report` first.

2. **Ask user for output directory** — where to save the dashboard files

3. **Optionally expand project list from GitHub orgs** — ask user if they want
   to scan GitHub organizations for additional repos not in the local scan. Use
   `gh repo list <org> --limit 200 --json name,description,url,primaryLanguage,isArchived,isFork,pushedAt`
   to discover repos, filter by `pushedAt` date (e.g., active since 2025), exclude
   archived and forked repos, merge with existing `claude-code-projects.json`, and
   deduplicate by URL and name.

4. **Generate data collection script** (`collect-ai-metrics.sh`):

   Create a bash script following the template in `references/collect-metrics-template.md`.
   The script:
   - Reads `claude-code-projects.json` as input
   - For each project with a local `.git/` directory, extracts metrics via `git log`
   - For projects with a GitHub URL but no local repo, falls back to `gh api`
   - Detects AI tools by email pattern in `Co-Authored-By` trailers
   - Counts per-tool commits (Claude, OpenCode, Copilot)
   - Handles duplicate GitHub repos (e.g., two projects pointing to same repo)
   - Deduplicates projects that exist both locally and remotely (prefers local)
   - Skips projects with neither local repo nor GitHub URL
   - Outputs `ai-portfolio-data.json` with per-project and aggregate metrics

   **Per-project metrics:**

   | Metric | Source |
   |--------|--------|
   | `total_commits` | `git rev-list --all --count` or GitHub API |
   | `co_authored_commits` | Commits with `Co-Authored-By` matching AI tool emails (case-insensitive) |
   | `co_author_percentage` | Calculated |
   | `first_commit_date` / `last_commit_date` | Earliest & latest commit dates |
   | `first_ai_commit_date` | Earliest co-authored commit date |
   | `claude_models_used` | Parsed from `Co-Authored-By: Claude <model>` trailer |
   | `ai_tools` | Array of detected AI tools (Claude, OpenCode, Copilot) |
   | `claude_commits` / `opencode_commits` / `copilot_commits` | Per-tool commit counts |
   | `authors_count` | Unique committer emails |
   | `tech_stack` | Detected from project files or GitHub languages API |
   | `monthly_commits` / `monthly_ai_commits` | `{month, count}` arrays |

   **AI tool detection by email pattern:**

   | Email | Tool |
   |-------|------|
   | `noreply@anthropic.com` | Claude (Claude Code) |
   | `opencode@anthropic.com` | OpenCode |
   | `Copilot@users.noreply.github.com` | GitHub Copilot |

   **Aggregate metrics:**
   - Totals (projects, commits, AI commits, percentage)
   - Projects by organization and category
   - Tech stack distribution
   - Monthly timeline (total + AI commits per month)
   - AI adoption timeline (sorted by first AI commit date)
   - Claude model usage with project lists
   - AI tool breakdown (per-tool commits and project lists)

   **Edge cases:**
   - Skip missing directories gracefully
   - Detect AI tools by `Co-Authored-By` email pattern (not name)
   - Count unique commit hashes (not trailer lines — a commit can have multiple trailers)
   - Deduplicate projects that exist both locally and on GitHub (prefer local)
   - GitHub search API has 30/min rate limit — use single combined search call per repo with 3s delay
   - Handle API rate limit errors gracefully (default to 0)

5. **Run the collection script** — execute and verify output is valid JSON

6. **Generate HTML dashboard** (`ai-portfolio.html`):

   Create a self-contained HTML file following the template in
   `references/dashboard-template.md`. Embed the JSON data inline via
   `<script>const DATA = {...};</script>`.

   **Dashboard sections:**

   | # | Section | Visualization |
   |---|---------|--------------|
   | 1 | Hero Header | Gradient bg, dynamic count-up stats from DATA |
   | 2 | Executive Summary | 6 stat cards in 3x2 grid |
   | 3 | AI Activity Heatmap | GitHub-style 365-day calendar heatmap |
   | 4 | AI Adoption Trend | Dual-line chart (AI commits + cumulative projects) |
   | 5 | AI Adoption Timeline | Swim-lane chart (project bars from first AI commit to last) |
   | 6 | Monthly Activity | Stacked bar chart (AI vs human commits) |
   | 7 | Projects by Category | Grouped card grids |
   | 8 | Organization Breakdown | Horizontal bar chart |
   | 9 | Tech Stack Distribution | Horizontal bars + CSS donut chart |
   | 10 | AI Collaboration Leaderboard | Ranked table with AI tool badges, progress bars, medals |
   | 11 | AI Tools Breakdown | Per-tool cards with commit counts + CSS donut chart |
   | 12 | Claude Model Usage | Cards per model with project tag lists |
   | 13 | Project Detail Grid | Searchable, filterable, sortable table with AI Tools column |
   | 14 | Footer | Generated date, "Powered by Claude Code" badge |

   **Important implementation notes:**
   - Hero stats MUST be dynamic — read values from `DATA.aggregates` via JS, never hardcode
   - All `data-count` attributes should be set from DATA at runtime
   - Project Detail Grid section should have `class="reveal visible"` (always visible, not scroll-dependent)
   - Table elements need explicit `color:var(--fg)` to prevent dark-on-dark in dark mode
   - Select dropdowns need `option { background:var(--bg2); color:var(--fg) }` for dark mode

   **Design system:**
   - Dark-first theme (`#0B1120`), light mode toggle with localStorage
   - Fonts: Space Grotesk (display), JetBrains Mono (mono), Inter (body) via Google Fonts
   - Accent colors: Amber `#F59E0B`, Green `#10B981`, Blue `#3B82F6`, Purple `#8B5CF6`, Cyan `#06B6D4`, Pink `#EC4899`
   - Layout: `max-width: 1200px`, CSS Grid, responsive at 768px/480px
   - Charts: CSS-only (calculated widths, conic-gradient donut, grid swim-lanes)
   - Heatmap: Full 365-day calendar grid with 5-level green intensity scale
   - Animations: IntersectionObserver scroll reveal, count-up hero numbers
   - Print: `@media print` forces light theme, hides interactive controls
   - Zero external JS dependencies — all CSS/JS inline

   **JS features (all inline):**
   - Theme toggle with localStorage persistence
   - Count-up animation on hero stats
   - Search/filter/sort on project grid
   - IntersectionObserver scroll reveal
   - Tooltip on heatmap cells

7. **Verify dashboard**:
   - Open in browser — all sections render
   - Dark/light toggle works
   - Search/filter in project grid works
   - Heatmap shows full year
   - Print preview looks clean

### Output Files

| File | Purpose |
|------|---------|
| `collect-ai-metrics.sh` | Bash script for git + GitHub API metric extraction |
| `ai-portfolio-data.json` | Structured JSON with per-project + aggregate metrics |
| `ai-portfolio.html` | Self-contained dashboard (all CSS/JS inline, no deps) |

---

## Tech Stack Detection

Use these file indicators to detect tech stack:

| File | Stack |
|------|-------|
| `artisan` + `composer.json` (laravel/) | Laravel |
| `package.json` + `next.config.*` | Next.js |
| `package.json` + `vite.config.*` | Vite (React/Vue) |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` / `setup.py` | Python |
| `Gemfile` | Ruby |
| `*.csproj` / `*.sln` | .NET |
| `pom.xml` / `build.gradle` | Java |
| `docker-compose.yml` | Docker |
| `VitePress` in package.json | VitePress |
| `drupal/` in composer.json | Drupal |
| `wordpress` theme/plugin structure | WordPress |

---

## Organization Extraction

Extract organization from git remote URL:

```
https://github.com/ORG/repo.git → ORG
git@github.com:ORG/repo.git → ORG
https://gitlab.com/ORG/repo.git → ORG
https://custom.domain/ORG/repo → ORG
```

If no remote is configured, set `org` to `null`.

---

## Notes

- Always ask the user which directories to scan — never assume paths
- Never hardcode personal information (names, emails, paths) — keep everything dynamic
- Projects without any AI signals are excluded from the inventory
- The scan is non-destructive — it only reads files, never modifies them
- For large directory trees, show progress updates during scanning
- Group projects logically by location, then by category/subfolder
- Include both `CLAUDE.md` and `.claude/` directory projects in the count
- JSON output should be valid and parseable by standard tools
- Dashboard HTML must be self-contained — no external JS/CSS dependencies
- Embed data inline in the HTML so it works offline and can be shared as a single file
- All paths in generated files should use variables, not hardcoded absolute paths

## Reference Files

| File | Description |
|------|-------------|
| `references/detection-patterns.md` | AI signal detection patterns and file indicators |
| `references/collect-metrics-template.md` | Template for the data collection bash script |
| `references/dashboard-template.md` | Template for the self-contained HTML dashboard |
