# Merge Algorithm — Step-by-Step Procedure

This reference describes the exact procedure for merging a source CLAUDE.md into a
target project's CLAUDE.md while preserving project-specific content.

---

## Overview

The merge operates at **section level** (H2/H3 boundaries), not line-by-line. Each
section is classified as SHARED, PROJECT-SPECIFIC, MERGE, or CONDITIONAL per
`section-classification.md`, and handled accordingly.

---

## Step 1: Parse Both Files into Section Trees

Parse source and target CLAUDE.md into structured section trees.

### Parsing Rules

1. Split the file by H2 headers (`## `)
2. For each H2 section, split by H3 headers (`### `)
3. Preserve:
   - The H2/H3 header line itself (including any suffix like `— CRITICAL`)
   - All content between this header and the next header of equal or higher level
   - Inline gotchas (blockquotes starting with `> **Gotcha:**`)
   - Code blocks (preserve exactly, including language markers)
4. The file preamble (content before the first H2) is treated as the "header" section

### Section Tree Structure

```
Document
├── header (# CLAUDE.md + intro text)
├── Section: "Project Overview"
│   └── content (all text)
├── Section: "Architecture & Key Concepts"
│   ├── Subsection: "Models - CRITICAL"
│   │   └── content + inline gotchas
│   ├── Subsection: "Database Conventions"
│   │   └── content + inline gotchas
│   └── ...
├── Section: "Important Conventions"
│   ├── Subsection: "UI Requirements — MUST HAVE"
│   ├── Subsection: "Icons — Lucide via Flux"
│   ├── Subsection: "DO"
│   └── Subsection: "DON'T"
└── ...
```

---

## Step 2: Classify Each Section

For each section in the target, determine its classification using
`section-classification.md`:

1. **Match H2 header** against the H2 Section Map
2. If the H2 is CONDITIONAL, check H3 subsections individually
3. If the H2 is not listed in the map → classify as PROJECT-SPECIFIC
4. Record classification for each section/subsection

---

## Step 3: Build Merged Document

Process sections in the **target's order**, applying merge rules:

### For SHARED sections:

```
IF section exists in source:
    REPLACE target section content with source section content
ELSE:
    KEEP target section (source may have removed it — flag for review)
```

### For PROJECT-SPECIFIC sections:

```
KEEP target section content exactly as-is
```

### For MERGE sections (DO/DON'T):

```
1. Parse source items into a list
2. Parse target items into a list
3. Identify project-only items (in target but not in source)
4. Build merged list:
   a. All source items in source order
   b. Append project-only items in target order
5. Deduplicate by semantic meaning
```

### For CONDITIONAL sections:

```
FOR each H3 subsection:
    IF subsection is classified SHARED → replace from source
    IF subsection is classified PROJECT-SPECIFIC → preserve from target
    IF subsection is classified MERGE → apply merge rules
```

### For sections in source but NOT in target:

```
IF section is SHARED:
    INSERT after the last related section in target
    (Use the source's section order as a guide for placement)
```

### For sections in target but NOT in source:

```
KEEP — these are project-specific custom sections
```

---

## Step 4: Preserve Document Structure

After merging content, ensure the document maintains proper structure:

1. **Header** — keep the target's `# CLAUDE.md` line and any intro paragraph
2. **Section order** — maintain the target's existing section order. New shared
   sections from source are inserted at a logical position (after the closest
   related existing section)
3. **Separators** — preserve `---` horizontal rules between major sections
4. **Trailing newline** — ensure file ends with a single newline

---

## Step 5: Validate Merged Output

### Content Validation

- [ ] All PROJECT-SPECIFIC sections preserved verbatim
- [ ] All SHARED sections match source content
- [ ] DO/DON'T lists contain both source and project-only items
- [ ] No duplicate sections
- [ ] No orphaned headers (H3 without parent H2)
- [ ] Code blocks are intact (matching ``` pairs)
- [ ] Gotcha blockquotes properly formatted

### Size Validation

1. Calculate byte size of merged content
2. If ≤ 40,960 bytes → proceed
3. If > 40,960 bytes → run auto-refinement:

   **Auto-refinement steps** (in order, stop when under 40 KB):
   a. Remove excessive blank lines (max 1 blank line between sections)
   b. Trim trailing whitespace from all lines
   c. Condense code block comments (remove obvious comment lines)
   d. Shorten redundant examples (if 3+ similar examples, keep 2)
   e. Consolidate similar gotchas into fewer, more concise entries

4. Re-check size after refinement
5. If still > 40,960 bytes → report to user:

   ```
   ⚠ Merged CLAUDE.md is 43,200 bytes (limit: 40,960 bytes)

   Largest sections:
     1. Architecture & Key Concepts  — 12,400 bytes
     2. Livewire Patterns            — 8,200 bytes
     3. Gotchas                      — 6,100 bytes

   Options:
     1. Write as-is (over limit)
     2. Trim specific sections
   ```

---

## Step 6: Write and Commit

1. Write merged content to the project's CLAUDE.md path
2. Check if file actually changed: `git diff --quiet CLAUDE.md`
3. If changed:
   ```bash
   git add CLAUDE.md
   git commit -m "docs: sync CLAUDE.md with kickoff conventions"
   ```
4. If unchanged: skip commit, report as "already current"

---

## Example Merge Walkthrough

### Source (kickoff/stubs/CLAUDE.md) has:

```markdown
## Architecture & Key Concepts
### Models - CRITICAL
ALL models MUST extend App\Models\Base... (updated content v2)

### DO
- ✅ DO extend App\Models\Base for all models
- ✅ DO use dual-key pattern
- ✅ DO use Pest syntax for tests
- ✅ DO use Form Requests for validation   ← NEW in source
```

### Target (project CLAUDE.md) has:

```markdown
## Project Overview
This is project-alpha...                    ← PROJECT-SPECIFIC

## Architecture & Key Concepts
### Models - CRITICAL
ALL models MUST extend App\Models\Base... (old content v1)

### DO
- ✅ DO extend App\Models\Base for all models
- ✅ DO use Pest syntax for tests
- ✅ DO use PostgreSQL for all new tables   ← PROJECT-ONLY

## Custom Deployment Notes                   ← CUSTOM SECTION
Deploy via rsync to production server...
```

### Merged result:

```markdown
## Project Overview
This is project-alpha...                    ← PRESERVED

## Architecture & Key Concepts
### Models - CRITICAL
ALL models MUST extend App\Models\Base... (updated content v2)  ← REPLACED

### DO
- ✅ DO extend App\Models\Base for all models   ← FROM SOURCE
- ✅ DO use dual-key pattern                     ← FROM SOURCE
- ✅ DO use Pest syntax for tests                ← FROM SOURCE
- ✅ DO use Form Requests for validation         ← NEW FROM SOURCE
- ✅ DO use PostgreSQL for all new tables         ← PROJECT-ONLY PRESERVED

## Custom Deployment Notes                   ← PRESERVED (custom section)
Deploy via rsync to production server...
```

---

## Edge Cases

### Reordered Sections

If the target has sections in a different order than the source, preserve the target's
order. The merge is content-based, not position-based.

### Missing Shared Section in Target

If the source has a shared section that doesn't exist in the target (e.g., a new
convention was added to kickoff), insert it after the closest related section in the
target. Use this placement order:

1. After the last subsection of the same parent H2
2. After the parent H2 section
3. Before `## Gotchas` (as a catch-all position for new convention sections)

### Empty Sections

If a shared section in the source is empty (header only, no content), still replace
the target's version — the source may have intentionally removed content.

### Conflicting Gotchas

If the same gotcha topic exists in both source and target but with different content,
the source version wins (for shared gotcha sections). If the target has additional
context specific to the project, that context should be preserved as a separate
project-specific gotcha entry.
