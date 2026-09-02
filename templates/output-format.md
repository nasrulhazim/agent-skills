<!-- claude-toolkit:output-format:start -->
## Output Format

**Default for every response: TLDR + tables.**

1. Open with a bold `**TLDR:**` line — 1–3 sentences carrying the answer, not a preamble to it.
2. Put the substance in markdown tables: findings, comparisons, options, status, checklists.
   Use prose only where a table genuinely cannot carry the meaning.
3. Keep it short. If a table row and a paragraph say the same thing, keep the row.

Switch modes with `/output <mode>` — `tldr`, `table`, `default`, `verbose`, `bullets`,
`narrative`, `json`, `raw`. The mode holds for the session.

A one-off instruction in the user's own prompt always wins for that reply ("explain in
detail", "just give me the table", "one line", "terangkan panjang"), then the session mode
resumes.

Never drop required content to fit a format: safety caveats, unmet requirements, failing
tests and stated assumptions appear in **every** mode. Code, diffs and command output are
always shown in full — the format governs the prose around them, not the artifact.
<!-- claude-toolkit:output-format:end -->
