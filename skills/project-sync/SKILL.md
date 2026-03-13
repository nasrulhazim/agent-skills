---
name: project-sync
metadata:
  compatible_agents: [claude-code]
  tags: [claude-md, sync, merge, conventions, multi-project, kickoff, laravel]
description: >
  Syncs CLAUDE.md across multiple Kickoff-based Laravel projects by intelligently
  merging shared conventions from a source of truth while preserving project-specific
  content. Scans local directories or GitHub accounts to discover Kickoff projects,
  maintains a project registry, and provides diff/update/report commands. Use this
  skill whenever the user asks to sync CLAUDE.md across projects, update conventions
  in multiple repos, check which projects are outdated, scan for Kickoff projects,
  or says "sync semua project", "update CLAUDE.md everywhere", "mana project outdated",
  "scan my repos", "diff CLAUDE.md", "project-sync", or any multi-project convention
  management task.
---

# Project Sync — CLAUDE.md Convention Synchronization

Intelligently syncs CLAUDE.md across Kickoff-based Laravel projects. Merges shared
conventions from a configurable source while preserving project-specific content
(overview, commands, packages, environment variables, custom sections).

## Command Reference

| Command | Purpose |
|---------|---------|
| `/project-sync scan [dir\|gh:account] [--since=YYYY] [--until=YYYY]` | Scan local directory or GitHub account for Kickoff Laravel projects |
| `/project-sync status` | Show which projects have outdated CLAUDE.md |
| `/project-sync diff <project>` | Dry-run merge — show what would change |
| `/project-sync update [project\|all] [--source=path]` | Sync CLAUDE.md, commit each project |
| `/project-sync report [latest\|YYYYMMDD.HHmm]` | View a sync report |

---

## `/project-sync scan`

Discover Kickoff Laravel projects in a local directory or GitHub account and save
them to the project registry.

### Syntax

```
/project-sync scan <target> [--since=YYYY] [--until=YYYY]
```

- `<target>`: Local directory path (e.g., `~/Projects`) or `gh:<account>` (e.g., `gh:cleaniquecoders`)
- `--since`: Only include projects with activity from this year onward (default: current year)
- `--until`: Only include projects with activity up to this year

### Local Directory Scan

1. **Find Laravel projects** — recursively search for directories containing an `artisan` file
   under the given path

2. **Filter by date** — for each candidate, check last commit date via `git log -1 --format=%ci`:
   - Skip if last commit year is before `--since`
   - Skip if last commit year is after `--until`

3. **Check detection markers** — verify at least one Kickoff marker exists.
   See `references/detection-markers.md` for the full list:
   - `app/Models/Base.php` exists
   - `composer.json` requires `cleaniquecoders/traitify`
   - `support/helpers.php` in composer autoload files
   - `CLAUDE.md` mentions "Kickoff" or "CleaniqueCoders"

4. **Extract metadata** for each confirmed project:

   ```json
   {
     "name": "project-name",
     "path": "/absolute/path/to/project",
     "url": "https://github.com/owner/repo",
     "description": "From composer.json description or CLAUDE.md first paragraph",
     "framework": "laravel",
     "php_version": "8.4",
     "has_claude_md": true,
     "claude_md_size": 22450,
     "last_synced": null,
     "source": "local"
   }
   ```

   - `url`: Extract from `git remote get-url origin` (null if no remote)
   - `description`: From `composer.json` > `description` field, or first non-heading paragraph of CLAUDE.md
   - `php_version`: From `composer.json` > `require` > `php` field (parse version constraint)
   - `claude_md_size`: File size in bytes (0 if no CLAUDE.md)
   - `last_synced`: null on first scan — set when `/project-sync update` runs

5. **Save to registry** — write/update `~/.claude/projects/.project-sync.json`.
   See `references/registry-schema.md` for the full schema.
   - Merge with existing entries (match by `path` for local, `url` for GitHub)
   - Update `last_scanned` timestamp

6. **Report results**:

   ```
   Scanned: ~/Projects
   Found: 12 Kickoff Laravel projects (filtered: --since=2025)

   ~/Projects/2025/ — 8 projects
     ✓ project-alpha          CLAUDE.md: 18.2 KB
     ✓ project-beta           CLAUDE.md: 22.1 KB
     ✗ project-gamma          No CLAUDE.md

   ~/Projects/2026/ — 4 projects
     ✓ project-delta          CLAUDE.md: 19.8 KB
     ...
   ```

### GitHub Account Scan

1. **List repos** via GitHub CLI:

   ```bash
   gh repo list <account> --json name,pushedAt,url,description --limit 1000
   ```

2. **Filter by date** — parse `pushedAt` field, apply `--since`/`--until` year filter

3. **Check detection markers** — for each candidate repo, use GitHub API to check for
   Kickoff markers without cloning:

   ```bash
   # Check if artisan exists
   gh api repos/<owner>/<repo>/contents/artisan --silent 2>/dev/null

   # Check if Base.php exists
   gh api repos/<owner>/<repo>/contents/app/Models/Base.php --silent 2>/dev/null

   # Check composer.json for traitify
   gh api repos/<owner>/<repo>/contents/composer.json --jq '.content' | base64 -d | grep -q traitify
   ```

   **Rate limiting**: Add 1-second delay between repos. If rate-limited, pause and retry.

4. **Extract metadata** — same as local scan, with `"source": "github"` and `url` from the API.
   If the repo also exists locally (matching URL), merge entries and prefer local path.

5. **Save to registry** and report results (same as local scan)

---

## `/project-sync status`

Show which registered projects have outdated CLAUDE.md compared to the source.

### Steps

1. **Read registry** — load `~/.claude/projects/.project-sync.json`

2. **Fetch source CLAUDE.md** — from the configured source URL (default:
   `https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md`)

3. **For each project with `has_claude_md: true`**:
   - Read the project's CLAUDE.md
   - Extract shared sections (see `references/section-classification.md`)
   - Compare shared sections against source
   - Determine status: `up-to-date`, `outdated`, `missing`

4. **Display status table**:

   ```
   Source: kickoff/stubs/CLAUDE.md (fetched from GitHub)

   Project                 Status      Size     Last Synced
   ─────────────────────────────────────────────────────────
   project-alpha           ✓ current   18.2 KB  2026-03-10
   project-beta            ✗ outdated  22.1 KB  2026-02-15
   project-gamma           ⚠ missing   —        never
   project-delta           ✗ outdated  19.8 KB  2026-03-01

   Summary: 1 current, 2 outdated, 1 missing CLAUDE.md
   ```

5. **Suggest next step**: "Run `/project-sync diff <project>` to preview changes, or
   `/project-sync update all` to sync everything."

---

## `/project-sync diff`

Dry-run merge showing what would change in a project's CLAUDE.md.

### Syntax

```
/project-sync diff <project-name> [--source=path]
```

### Steps

1. **Resolve project** — find in registry by name. If ambiguous, show matching entries
   and ask user to specify.

2. **Fetch source CLAUDE.md** — from configured source or `--source` override.
   - If `--source` is a file path → read local file
   - If `--source` is a URL → fetch via WebFetch
   - If `--source` is neither → treat as inline instructions to merge

3. **Read target CLAUDE.md** — from the project's path

4. **Run merge algorithm** (dry-run) — see `references/merge-algorithm.md`:
   - Classify each section as SHARED or PROJECT-SPECIFIC
   - For SHARED sections: show diff (source vs target)
   - For DO/DON'T lists: show merged result (source items + project-only items)
   - For PROJECT-SPECIFIC sections: mark as "preserved (no changes)"

5. **Display diff**:

   ```
   Project: project-beta (/path/to/project-beta)
   Source: kickoff/stubs/CLAUDE.md

   ## Sections to UPDATE (from source):
     - Architecture & Key Concepts > Models - CRITICAL  [changed]
     - Architecture & Key Concepts > Enums  [changed]
     - Testing with Pest  [unchanged]
     - Livewire Patterns > Toast Notifications  [changed]
     - Code Quality Checklist  [unchanged]

   ## Sections to MERGE (combine items):
     - DO list: +2 new items from source, 3 project-only preserved
     - DON'T list: +1 new item from source, 1 project-only preserved

   ## Sections PRESERVED (project-specific):
     - Project Overview
     - Common Commands
     - Packages
     - Docker Services
     - Environment Variables
     - Quick Reference

   ## Size estimate:
     Current: 22,100 bytes
     After merge: ~23,400 bytes (within 40 KB limit)
   ```

6. **Ask for confirmation** if any concerns (e.g., large size increase, unexpected
   section classification)

---

## `/project-sync update`

Apply the merge and commit changes.

### Syntax

```
/project-sync update [project-name|all] [--source=path]
```

- `project-name`: Update a single project
- `all`: Update all outdated projects in the registry
- `--source`: Override the source CLAUDE.md (path, URL, or inline text)

### Steps

1. **Resolve targets** — single project by name, or all projects with `outdated` or
   `missing` status

2. **Fetch source CLAUDE.md** — same resolution as `/project-sync diff`

3. **For each target project**:

   a. **Read target CLAUDE.md** (or create from template if missing — use
      `references/section-classification.md` for structure)

   b. **Run merge algorithm** — see `references/merge-algorithm.md`:
      - Replace SHARED sections with source content
      - Merge DO/DON'T lists (deduplicate)
      - Preserve PROJECT-SPECIFIC sections verbatim
      - Preserve any custom H2 sections not in source

   c. **Validate size** — check merged file is under 40 KB (40,960 bytes):
      - If over 40 KB: auto-refine (condense verbose sections, trim redundant
        examples, consolidate similar gotchas)
      - Re-check after refinement
      - If still over 40 KB: ask user for confirmation — show size and largest sections
      - User can approve (write as-is) or request further trimming

   d. **Write the file** — save merged CLAUDE.md to the project directory

   e. **Commit** — if file actually changed (diff is non-empty):

      ```bash
      cd /path/to/project
      git add CLAUDE.md
      git commit -m "docs: sync CLAUDE.md with kickoff conventions"
      ```

   f. **Update registry** — set `last_synced` to current date, update `claude_md_size`

4. **Generate sync report** — save to `~/.claude/projects/reports/<YYYYMMDD.HHmm>/`:
   - `report.json` — machine-readable results
   - `report.md` — human-readable Markdown summary
   See report format below.

5. **Display summary**:

   ```
   Sync complete:
     ✓ Updated: 8 projects
     — Skipped: 2 projects (already current)
     ✗ Failed: 1 project (git working tree dirty)

   Report saved: ~/.claude/projects/reports/20260314.0600/
   ```

### Report Format

Each update run generates a report directory at `~/.claude/projects/reports/<YYYYMMDD.HHmm>/`.

**`report.json`**:

```json
{
  "timestamp": "2026-03-14T06:00:00Z",
  "source": "https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md",
  "total_projects": 12,
  "results": [
    {
      "name": "project-alpha",
      "path": "/path/to/project-alpha",
      "status": "updated",
      "before_size": 18200,
      "after_size": 19400,
      "sections_changed": ["Models - CRITICAL", "Enums", "DO", "DON'T"],
      "commit_sha": "abc1234"
    },
    {
      "name": "project-beta",
      "path": "/path/to/project-beta",
      "status": "skipped",
      "reason": "already current"
    }
  ],
  "summary": {
    "updated": 8,
    "skipped": 2,
    "failed": 1
  }
}
```

**`report.md`**:

```markdown
# Project Sync Report — 2026-03-14 06:00

**Source**: kickoff/stubs/CLAUDE.md (GitHub)
**Projects processed**: 12

## Results

| # | Project | Status | Size Change | Sections Changed |
|---|---------|--------|-------------|------------------|
| 1 | project-alpha | ✓ Updated | 18.2 → 19.4 KB | Models, Enums, DO, DON'T |
| 2 | project-beta | — Skipped | 22.1 KB | (already current) |
| 3 | project-gamma | ✗ Failed | — | (git working tree dirty) |

## Summary

- **Updated**: 8 projects
- **Skipped**: 2 projects
- **Failed**: 1 project
```

---

## `/project-sync report`

View a previously generated sync report.

### Syntax

```
/project-sync report [latest|YYYYMMDD.HHmm]
```

- `latest` (default): Show the most recent report
- `YYYYMMDD.HHmm`: Show a specific report by directory name

### Steps

1. **List report directories** — scan `~/.claude/projects/reports/` and sort by name
   (lexicographic = chronological)

2. **Resolve target**:
   - `latest`: Pick the last directory
   - Specific name: Match exactly

3. **Read and display `report.md`** — render the Markdown content directly

4. If no reports exist, inform the user: "No sync reports found. Run
   `/project-sync update` to generate one."

---

## Source Configuration

### Default Source

The default source of truth is fetched from GitHub:

```
https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md
```

This ensures every sync uses the latest published conventions. The URL is stored in the
registry config and can be changed by editing `~/.claude/projects/.project-sync.json`:

```json
{
  "config": {
    "source": "https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md"
  }
}
```

### Overriding with `--source`

The `--source` flag accepts:

| Input Type | Example | Behavior |
|-----------|---------|----------|
| Local file path | `--source=~/kickoff/stubs/CLAUDE.md` | Read file directly |
| URL | `--source=https://example.com/CLAUDE.md` | Fetch via WebFetch |
| Inline text | `--source="Add rule: always use UUIDs"` | Treat as additional instructions to merge |

When using a non-kickoff source, Claude analyzes the source structure dynamically and
classifies sections as shared vs project-specific based on content analysis rather than
the static map in `references/section-classification.md`.

---

## Section-Based Merge Strategy

CLAUDE.md files have clear H2/H3 section boundaries. The merge operates at section
level — not line-by-line diff. See `references/section-classification.md` for the
complete section map and `references/merge-algorithm.md` for the step-by-step procedure.

### Merge Rules Summary

| Section Type | Merge Action |
|-------------|-------------|
| **Shared** | Replace entirely from source |
| **Project-specific** | Preserve verbatim — never touch |
| **DO/DON'T lists** | Merge: source items + project-only items (deduplicate) |
| **Gotchas (shared)** | Replace shared gotchas, preserve project-specific gotchas |
| **Custom H2 sections** | Preserve — any section not in source is project-specific |

### Size Validation

Final CLAUDE.md must be under **40 KB** (40,960 bytes). If exceeded:

1. **Auto-refine**: Condense verbose sections, remove redundant examples, shorten code
   blocks, consolidate similar gotchas, trim excessive whitespace
2. Re-check size
3. If still over 40 KB: **ask user** — show current size and largest sections
4. User can approve as-is or request trimming of specific sections

---

## Registry File

The project registry is stored at `~/.claude/projects/.project-sync.json`. It is only
modified by `/project-sync scan` and `/project-sync update`.

See `references/registry-schema.md` for the complete schema.

Key behaviors:
- `scan` creates/updates entries — never deletes
- `update` sets `last_synced` and `claude_md_size` after successful merge
- `status`, `diff` read-only — they never modify the registry
- Entries are matched by `path` (local) or `url` (GitHub) for deduplication

---

## Detection Markers

A project is classified as a Kickoff Laravel project if it has an `artisan` file
**plus** at least one of the Kickoff-specific markers. See `references/detection-markers.md`
for the complete list.

---

## Edge Cases

### Missing CLAUDE.md in Target

If a project has no CLAUDE.md, `/project-sync update` creates one using the source as
a base, with project-specific sections populated from `composer.json` metadata:
- Project Overview: name and description from composer.json
- Common Commands: standard Kickoff commands
- All shared sections: copied from source

### Dirty Git Working Tree

If the target project has uncommitted changes, `/project-sync update` skips that project
and reports it as failed with reason "git working tree dirty". The user must commit or
stash changes first.

### No Registry File

If `.project-sync.json` doesn't exist when running `status`, `diff`, or `update`,
inform the user: "No project registry found. Run `/project-sync scan` first."

### Network Failure (GitHub Source)

If the source URL fetch fails, check for a cached version in the registry. If no cache,
fail with a clear error and suggest using `--source` with a local file.

---

## Notes

- The scan is non-destructive — it only reads files and git metadata
- The update modifies only `CLAUDE.md` in each project — no other files are touched
- Each update creates a git commit only if the file actually changed
- Reports accumulate over time as an audit trail — they are never auto-deleted
- The registry file is shared across conversations — any Claude Code session can read it
- Date filtering uses year granularity for simplicity (not month/day)

## Reference Files

| File | Read When |
|------|-----------|
| `references/section-classification.md` | Classifying sections during merge |
| `references/merge-algorithm.md` | Executing the merge procedure |
| `references/detection-markers.md` | Identifying Kickoff Laravel projects |
| `references/registry-schema.md` | Reading/writing the project registry |
