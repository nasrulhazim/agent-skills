---
name: project-status
metadata:
  compatible_agents: [claude-code]
  tags: [status, planning, backlog, github-issues, reporting]
description: >
  Produces a TLDR + table status report for a project by reading its planning tree
  (`documentation/03-planning`) and cross-checking every claim against live GitHub issues and
  the code itself. Use this skill whenever the user asks where a project stands, what is left,
  what is in flight, what is blocked, or what to do next — "current status", "status update",
  "what's the status", "summarise the planning docs", "apa status projek", "apa yang tinggal",
  "what's next", "backlog status", "issue status", "progress report", "mana yang belum siap",
  "berapa banyak lagi", "what should I work on". Covers which planning docs have gone stale,
  which open issues are actually already built, and the recommended next move. Does NOT cover
  writing new plans (`project-roadmap`), filing issues (`gh-workflow`), or deploying
  (`deploy-app`).
---

# Project status

Report in the house style: **TLDR first, then tables, minimal prose.** No narrative
paragraphs, no per-document walkthrough. A status report is a decision aid, not a diary.

## The one rule

**Never report a document's claim as status without checking the code.**

Planning documents go stale within days of being written. A file saying "not built" is a
*claim to verify*, not a fact — and the failure is asymmetric: reporting built work as
outstanding sends someone to rebuild it, while the reverse merely delays a discovery. The
same applies to open issues. An issue that is open and already built is the single most
common defect in these reports.

## Where the truth lives

| Source | Good for | What it lies about |
|---|---|---|
| `documentation/03-planning/tasks/*.md` | One file per feature; most carry a `**Status:**` line and a per-phase table | **Goes stale within days** — every claim needs a code check |
| `documentation/03-planning/*triage*.md` / `*-mvp-scope.md` | The ordered "order of attack" and a running open/closed count | Snapshot-dated. Check its date against today before quoting any count |
| `gh issue list` | The only live count | An open issue is often **already built** |
| `gh api .../milestones` | Burn-down per phase | A milestone with no issues is not the same as a finished one |
| `CLAUDE.md` gotchas | Corrections worth not repeating | Not status |
| The code | Final authority | — |

If the project keeps a `lessons.md` in its planning tree, read it for context — but new
corrections belong in `CLAUDE.md`, where every session picks them up.

## Gather

These are cheap and cover almost everything. Run them before reading a single plan.

```bash
# Live issue counts
gh issue list --state open --limit 200 --json number,title,labels \
  --template '{{range .}}#{{.number}}	{{.title}}	{{range .labels}}{{.name}},{{end}}
{{end}}'

# Milestone burn-down
gh api repos/:owner/:repo/milestones \
  --jq '.[] | "\(.title)\topen=\(.open_issues)\tclosed=\(.closed_issues)"'

# What shipped recently — anchors the TLDR
gh issue list --state closed --limit 30 --json number,title,closedAt \
  --template '{{range .}}#{{.number}}	{{.closedAt}}	{{.title}}
{{end}}'
```

```bash
# Every plan's self-declared status + checkbox progress, in one pass
cd documentation/03-planning/tasks && for f in *.md; do
  d=$(grep -c '^\s*- \[x\]' "$f"); t=$(grep -c '^\s*- \[ \]' "$f")
  hdr=$(grep -m1 -iE 'status|verdict|shipped' "$f" | sed 's/[|>*]//g' | cut -c1-95)
  printf '%-38s done=%-4s todo=%-4s %s\n' "$f" "$d" "$t" "$hdr"
done
```

```bash
# Repo reality
git status --short
git log --oneline -1
git branch -r --no-merged main | head    # anything sitting unmerged
```

Then **read the header (first ~25 lines) of only the plans that are not "shipped"** — those
carry the phase tables that say what is actually left. Skip the shipped ones; their detail is
history and reading them is most of the cost of a slow status report.

Finally, spot-check the two or three largest "open" claims against the code:

```bash
grep -rl "class SomeExpectedThing" app/
```

One grep per claim. This step is what turns a document summary into a status report — budget
for it and do not skip it when the plans look tidy.

## Report shape

1. **TLDR** — 2–3 sentences: headline counts, what shipped most recently, the single
   recommended next move.
2. **Table — where it stands**: issues open/closed, milestone burn-down, suite size,
   `main` sha.
3. **Table — in flight / what's left**: one row per *open* workstream, with issue #, plan file,
   what's done, what's left, blocker if any. Shipped plans collapse into one row, not one each.
4. **Table — stale docs**: any plan whose text disagrees with the code, and what is actually
   true. Empty is a fine answer; a missing table is not.
5. **Next** — the order of attack from the triage doc, adjusted for anything that shipped since
   its snapshot date.

## Judgement calls worth getting right

- **Distinguish "behind" from "deliberately last."** Go-to-market and polish phases are usually
  sequenced last on purpose. Reporting them as slippage is noise that trains the reader to skim.
- **Separate environmental blockers from code blockers.** "Needs a container-capable host" and
  "needs someone to write it" belong in different rows; only one is fixed by working harder.
- **Name the largest unbuilt piece explicitly.** The item that gates the most downstream work is
  the most useful single sentence in the report.
- **A closed milestone is not a finished phase** if issues were moved out of it. Check.

## Anti-patterns

| Don't | Do |
|---|---|
| Summarise each planning doc in turn | One table row per *open* workstream |
| Quote a triage doc's counts as current | Check its date, then use `gh issue list` |
| Report "not built" from a doc | Grep the code first |
| Write prose paragraphs | Tables, and a TLDR at the top |
| Treat every open issue as outstanding work | Spot-check the big ones — some are already done |
