# Triage Playbook

The questions to ask at each stage. If you cannot answer the current stage's questions, do
not advance to the next one.

## Stage 1 — Reproduce

- What is the *exact* input? Request payload, authenticated user, tenant, record ID, timestamp.
- What is the expected output, stated concretely? "It should work" is not an expectation.
- Does it fail every time, or intermittently? Intermittent means state, time or concurrency.
- What is the cheapest environment where it still fails?
  `Pest test` → `tinker` → `local HTTP` → `staging` → `production`
- If it only fails in production, what differs? Capture and compare:
  ```bash
  php artisan about
  php -v && composer show laravel/framework
  ```
  Data volume, queue driver, cache driver, `APP_ENV`, `APP_DEBUG`, PHP extensions, timezone.

**Exit criteria:** you can trigger the failure on demand with one command.

## Stage 2 — Localise

- Which frame in the stack trace is the deepest one in `app/`? That is the suspect.
- Is the thrown exception the *cause*, or a downstream effect? A `TypeError` on a null often
  means something upstream returned null and nobody checked.
- What changed?
  ```bash
  git log --oneline --since="2 weeks ago" -- <suspect path>
  git blame -L <start>,<end> <file>
  ```
- Who else calls the suspect function?
  ```bash
  grep -rn "<functionName>" app/ tests/ routes/
  ```
  If more than one caller, the fix probably belongs in the function, not the caller.
- Can `git bisect` find it faster than reading?
  ```bash
  git bisect start && git bisect bad HEAD && git bisect good <tag>
  git bisect run ./vendor/bin/pest --filter=<TestName>
  ```

**Exit criteria:** you can name the file and the lines, and you know every caller.

## Stage 3 — Reduce

Delete until every remaining line matters.

- Remove the HTTP layer — call the service directly. Still fails?
- Remove auth and middleware. Still fails?
- Replace the DB record with a hand-built model. Still fails?
- Replace each dependency with a stub returning a fixed value, one at a time. Which one
  makes the failure disappear?

**Exit criteria:** a reproducer where removing any line makes the failure stop.

## Stage 4 — Fix

- State the root cause in one sentence, out loud, before editing.
- Is this the cause or a symptom? Re-read the symptom/root table in SKILL.md.
- Where do all the broken callers route through? Fix there.
- Does the fix change a public signature or behaviour other code depends on? Check callers again.
- Is there a simpler fix that deletes code rather than adding it?

**Exit criteria:** the diff is the smallest change that removes the cause, at the shared point.

## Stage 5 — Guard

- Write the test **before** applying the fix; watch it fail for the right reason.
- Apply the fix; watch it pass.
- Revert the fix; confirm the test fails again. If it still passes, the test does not guard
  the bug — rewrite it.
- Run the whole suite. A fix that breaks two other tests is not a fix.
- Remove every `dd`, `dump`, `ray`, `var_dump` and `Log::debug` you added.

**Exit criteria:** the SKILL.md Verification checklist is fully ticked.

## Reporting the result

```markdown
**Symptom:** <what was reported>
**Root cause:** <one sentence — a cause, not a restatement of the symptom>
**Fix:** <file:line, and why it belongs there rather than at the call site>
**Guard:** <test name; confirmed to fail when the fix is reverted>
**Blast radius:** <who/what was affected, over what time window> (omit if never deployed)
**Not chased:** <any pre-existing warnings seen and deliberately left alone>
```
