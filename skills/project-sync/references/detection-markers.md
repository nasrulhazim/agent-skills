# Detection Markers — Kickoff Laravel Project Identification

This reference describes how to identify a project as a Kickoff-based Laravel project.
Used by `/project-sync scan` to filter candidates.

---

## Detection Logic

A project is classified as a **Kickoff Laravel project** if it meets:

1. **Required**: Has an `artisan` file in the project root (confirms it's a Laravel project)
2. **Plus at least ONE** of the Kickoff-specific markers below

---

## Kickoff-Specific Markers

| # | Marker | How to Check | Confidence |
|---|--------|-------------|------------|
| 1 | `app/Models/Base.php` exists | File existence check | High |
| 2 | `composer.json` requires `cleaniquecoders/traitify` | Parse `require` or `require-dev` keys | High |
| 3 | `support/helpers.php` in Composer autoload | Parse `autoload.files` in `composer.json` | High |
| 4 | `CLAUDE.md` mentions "Kickoff" or "CleaniqueCoders" | Read first 50 lines, case-insensitive search | Medium |
| 5 | `stubs/enum.stub` exists | File existence check | Medium |
| 6 | `config/access-control.php` exists | File existence check | Medium |

### Priority

Check markers in order (1 → 6). Stop at the first match — no need to check all markers
for every project.

---

## Local Directory Check

For local directories, use file system checks:

```bash
# Step 1: Find all artisan files (Laravel projects)
find <directory> -name "artisan" -maxdepth 4 -type f

# Step 2: For each directory containing artisan, check markers:

# Marker 1: Base model
test -f "<project>/app/Models/Base.php"

# Marker 2: Traitify dependency
grep -q "cleaniquecoders/traitify" "<project>/composer.json"

# Marker 3: Support helpers in autoload
grep -q "support/helpers.php" "<project>/composer.json"

# Marker 4: CLAUDE.md mentions Kickoff
head -50 "<project>/CLAUDE.md" | grep -qi "kickoff\|cleaniquecoders"

# Marker 5: Enum stub
test -f "<project>/stubs/enum.stub"

# Marker 6: Access control config
test -f "<project>/config/access-control.php"
```

---

## GitHub API Check

For GitHub repos (without cloning), use the GitHub API:

```bash
# Step 1: Check artisan exists
gh api repos/<owner>/<repo>/contents/artisan --silent 2>/dev/null
# Returns 200 if exists, 404 if not

# Step 2: Check Kickoff markers

# Marker 1: Base model
gh api repos/<owner>/<repo>/contents/app/Models/Base.php --silent 2>/dev/null

# Marker 2: Traitify in composer.json
gh api repos/<owner>/<repo>/contents/composer.json \
  --jq '.content' | base64 -d | grep -q "cleaniquecoders/traitify"

# Marker 3: Support helpers in autoload
gh api repos/<owner>/<repo>/contents/composer.json \
  --jq '.content' | base64 -d | grep -q "support/helpers.php"

# Marker 4: CLAUDE.md mentions Kickoff
gh api repos/<owner>/<repo>/contents/CLAUDE.md \
  --jq '.content' | base64 -d | head -50 | grep -qi "kickoff\|cleaniquecoders"
```

**Rate limiting**: GitHub API has rate limits. Add a 1-second delay between repos.
If a 403/429 response is received, pause for 60 seconds before retrying.

---

## Non-Kickoff Laravel Projects

Projects that have `artisan` but none of the Kickoff markers are standard Laravel
projects. These are **excluded** from the project-sync registry.

If the user wants to sync CLAUDE.md to non-Kickoff projects, they can use
`/project-sync update <project> --source=<path>` with a custom source — but these
projects must be manually added to the registry or scanned with relaxed detection.

---

## False Positive Prevention

These are NOT Kickoff projects even if some markers match:

| Scenario | Why Not Kickoff |
|----------|----------------|
| The kickoff package itself (`cleaniquecoders/kickoff`) | It has `artisan` in stubs but is the tool, not a generated project |
| Laravel packages with `artisan` in test fixtures | Not a full Laravel app |
| Forks of kickoff that haven't been used to generate projects | Source, not target |

To prevent false positives:
- If `composer.json` has `"name": "cleaniquecoders/kickoff"` → skip (it's the tool itself)
- If the directory is inside another project's `vendor/` → skip
- If the directory is inside a `test-output/` or `sandbox/` directory → skip (test artifacts)
