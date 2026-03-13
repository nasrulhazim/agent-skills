# Registry Schema — `.project-sync.json`

The project registry is a JSON file that stores metadata about all discovered Kickoff
Laravel projects. It is the central data store for all `/project-sync` commands.

---

## File Location

Default: `~/.claude/projects/.project-sync.json`

The path is configurable via the `config.base_dir` field — if changed, all commands
read from `<base_dir>/.project-sync.json` instead.

---

## Full Schema

```json
{
  "config": {
    "base_dir": "~/.claude/projects",
    "source": "https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md"
  },
  "last_scanned": "2026-03-14",
  "projects": [
    {
      "name": "project-name",
      "path": "/absolute/path/to/project",
      "url": "https://github.com/owner/repo",
      "description": "Short description from composer.json or CLAUDE.md",
      "framework": "laravel",
      "php_version": "8.4",
      "has_claude_md": true,
      "claude_md_size": 22450,
      "last_synced": "2026-03-10",
      "source": "local"
    }
  ]
}
```

---

## Field Definitions

### `config` (object)

Top-level configuration for the sync tool.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `base_dir` | string | `~/.claude/projects` | Directory where the registry file is stored |
| `source` | string | `https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md` | Default source of truth URL for CLAUDE.md syncing |

### `last_scanned` (string)

ISO date (`YYYY-MM-DD`) of the most recent `/project-sync scan` run.

### `projects` (array of objects)

Each entry represents a discovered Kickoff Laravel project.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Project directory name |
| `path` | string | Yes | Absolute filesystem path to the project root |
| `url` | string\|null | No | Git remote URL (null if no remote configured) |
| `description` | string\|null | No | From `composer.json` description or CLAUDE.md intro |
| `framework` | string | Yes | Always `"laravel"` for Kickoff projects |
| `php_version` | string\|null | No | PHP version from `composer.json` require constraint |
| `has_claude_md` | boolean | Yes | Whether CLAUDE.md exists in the project |
| `claude_md_size` | number | Yes | Size of CLAUDE.md in bytes (0 if missing) |
| `last_synced` | string\|null | No | ISO date of last successful sync (null if never synced) |
| `source` | string | Yes | How the project was discovered: `"local"` or `"github"` |

---

## CRUD Operations

### Create (during `scan`)

When a new project is discovered:

```json
{
  "name": "new-project",
  "path": "/home/user/Projects/new-project",
  "url": "https://github.com/user/new-project",
  "description": "A new Laravel project",
  "framework": "laravel",
  "php_version": "8.4",
  "has_claude_md": true,
  "claude_md_size": 18200,
  "last_synced": null,
  "source": "local"
}
```

### Read (during `status`, `diff`, `update`)

Load the file, parse JSON, iterate over `projects` array. Never modify during
read-only operations (`status`, `diff`).

### Update (during `scan` and `update`)

**During `scan`** — update existing entries matched by `path` (local) or `url` (GitHub):
- Update `has_claude_md`, `claude_md_size`, `description`, `php_version`
- Update `last_scanned` at the config level

**During `update`** — after successful merge:
- Set `last_synced` to current date
- Update `claude_md_size` with new file size
- Set `has_claude_md` to `true`

### Delete

Projects are **never automatically deleted** from the registry. If a project directory
no longer exists, it remains in the registry with stale data. The user can manually
remove entries by editing the JSON file.

---

## Deduplication Rules

### Local Scan Dedup

Match by `path` — if an entry with the same absolute path exists, update it.

### GitHub Scan Dedup

Match by `url` — if an entry with the same remote URL exists, update it.

### Cross-Source Dedup

If a GitHub-scanned project also exists locally (same `url`):
- Keep both entries but prefer the local entry for operations
- Set the GitHub entry's `path` to the local path if available
- Merge metadata (prefer local values for `has_claude_md`, `claude_md_size`)

---

## Example Registry

```json
{
  "config": {
    "base_dir": "~/.claude/projects",
    "source": "https://raw.githubusercontent.com/cleaniquecoders/kickoff/refs/heads/main/stubs/CLAUDE.md"
  },
  "last_scanned": "2026-03-14",
  "projects": [
    {
      "name": "project-alpha",
      "path": "/Users/nasrulhazim/Projects/2025/project-alpha",
      "url": "https://github.com/cleaniquecoders/project-alpha",
      "description": "Client portal for managing orders",
      "framework": "laravel",
      "php_version": "8.4",
      "has_claude_md": true,
      "claude_md_size": 22450,
      "last_synced": "2026-03-10",
      "source": "local"
    },
    {
      "name": "project-beta",
      "path": "/Users/nasrulhazim/Projects/2026/project-beta",
      "url": "https://github.com/cleaniquecoders/project-beta",
      "description": "Internal HR management system",
      "framework": "laravel",
      "php_version": "8.4",
      "has_claude_md": true,
      "claude_md_size": 19800,
      "last_synced": "2026-02-15",
      "source": "local"
    },
    {
      "name": "project-gamma",
      "path": null,
      "url": "https://github.com/cleaniquecoders/project-gamma",
      "description": "E-commerce platform",
      "framework": "laravel",
      "php_version": "8.3",
      "has_claude_md": false,
      "claude_md_size": 0,
      "last_synced": null,
      "source": "github"
    }
  ]
}
```

---

## File Safety

- Always read the existing file before writing (preserve entries from previous scans)
- Write atomically: write to a `.tmp` file first, then rename
- Validate JSON before writing: ensure the structure matches the schema
- Back up the existing file before overwriting (copy to `.project-sync.json.bak`)
