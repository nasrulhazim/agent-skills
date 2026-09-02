---
description: Set the response output format for this session (tldr, table, verbose, bullets, narrative, json, raw). Default is tldr+table.
---

# Output Format

Set how responses are formatted for the rest of this session.

**Requested mode:** `$ARGUMENTS`

## Modes

| Mode | Shape |
|---|---|
| `tldr` | A bold **TLDR:** line of 1–3 sentences, then nothing else unless asked. |
| `table` | Findings, comparisons, options and status as markdown tables. Prose only where a table cannot carry the meaning. |
| `default` | **TLDR + table.** A TLDR line, then tables for the substance. This is the baseline. |
| `verbose` | Full reasoning, background, trade-offs, alternatives considered, and worked examples. Use when the user is learning or deciding. |
| `bullets` | Flat bullet lists. No tables, no paragraphs. |
| `narrative` | Flowing prose paragraphs. For post-mortems, proposals, and anything a non-technical reader will read end to end. |
| `json` | A single fenced JSON block, no prose around it. For piping into another tool. |
| `raw` | Command output, file contents or diffs verbatim, with no commentary. |

## Behaviour

1. If `$ARGUMENTS` names a mode, adopt it for the remainder of the session and confirm in one line.
2. If `$ARGUMENTS` is empty, report the current mode and list the available ones.
3. If `$ARGUMENTS` is `reset` or `default`, return to **TLDR + table**.

## Rules that hold in every mode

- **A one-off override in the user's own prompt beats the session mode.** "explain in detail",
  "just the table", "one line please", "terangkan panjang" — follow it for that reply only,
  then return to the session mode.
- **Never drop required content to satisfy a format.** A safety caveat, an unmet requirement,
  a failing test, or a stated assumption is reported in every mode, `tldr` and `json` included.
- **`verbose` is not permission to pad.** More detail, not more words per point.
- **`tldr` is not permission to omit.** If the honest answer needs three sentences, use three.
- Code, diffs and commands are always shown in full regardless of mode — the format governs
  the prose around them, never the artifact itself.
