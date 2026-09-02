---
name: deploy-app
metadata:
  compatible_agents: [claude-code]
  tags: [deployment, production, ssh, bin-deploy, laravel, kickoff]
description: >
  Deploys a Kickoff-based Laravel application to its host by running `bin/deploy` over SSH,
  then verifies the release and knows what each way it can stop means. Use this skill whenever
  the user asks to deploy an app, push the latest code to production, check what commit
  production is running, bring a site back up after a failed deploy, or roll back — "deploy
  latest", "deploy the app", "tolong deploy", "deploy latest dulu", "push to production", "apa
  commit dekat production", "site down after deploy", "keluarkan maintenance mode", "rollback
  production", "kenapa 503". Covers the deploy command and its flags, the post-deploy
  verification checklist, the recovery path for each failure mode, and the production traps
  that have already cost time. Does NOT cover provisioning a new host from bare metal
  (`bin/provision-host`), CI/CD pipeline design (`ci-cd-pipeline`), or writing deploy
  operations.
---

# Deploy a Kickoff app

One command does the whole release. This skill is mostly about **verifying** it and knowing
which failures matter — a deploy that prints a success line is not the same as a deploy that
worked.

## Before anything: establish the target

Never assume. Confirm these from the project's own docs (`docs/04-deployment/`), its
`CLAUDE.md`, or by asking:

| | |
|---|---|
| Host | SSH target and user |
| Path | application root on the host |
| Domain | public URL, for the health check |
| Branch | what production tracks (usually `main`) |
| Stack | web server, PHP-FPM, supervisor/Horizon, cron (scheduler) |
| Database | engine and whether it is local or managed |

If the project keeps this in a deployment doc, read it once and cache it in your answer — do
not re-derive it every deploy.

## Deploy

Check what would move first, then deploy:

```bash
ssh <user>@<host> 'cd <path> && git fetch origin <branch> --quiet \
  && echo "origin: $(git log --oneline -1 origin/<branch>)" \
  && echo "server: $(git log --oneline -1 HEAD)"'
```

```bash
ssh <user>@<host> 'cd <path> && ./bin/deploy -b <branch> 2>&1 | tail -60'
```

`tail` is deliberate: composer/npm output is long and the last 60 lines contain every decision
point.

> **Gotcha:** Always pass `-b <branch>`. With no `-b`, `bin/deploy` falls back to "latest tag"
> and `git describe` fails outright on a repository that has never been tagged.

What `bin/deploy` does, in order: pre-deploy database dump → `artisan down` → checked
`git checkout`/`pull` → `composer install --no-dev` → `npm ci && npm run build` → clear
config/route/view caches → `migrate --force` → `operations --isolated` → `optimize` →
`horizon:terminate` → chown to the web user → reload PHP-FPM → `artisan up` → health check,
with an **automatic rollback** to the previous commit if the health check does not pass.

## Verify

Always run this afterwards. The script's own success line is not the whole story.

```bash
ssh <user>@<host> 'cd <path> && git rev-parse --short HEAD \
  && php artisan horizon:status \
  && curl -s -o /dev/null -w "login=%{http_code}\n" https://<domain>/login'
```

| Check | Expected |
|---|---|
| `git rev-parse --short HEAD` | matches `origin/<branch>` |
| `horizon:status` | `Horizon is running.` |
| `/login` | `200` |
| deploy output | health check line, all `200` |
| migrations | either `Nothing to migrate` or the list of what ran |

Report the **before/after commit**, whether migrations ran, and the health line. If a migration
ran, name it — CI usually exercises migrations only on SQLite, so the first run against the
production engine is a real event.

## When it stops

| Symptom | What happened | Do this |
|---|---|---|
| `ERROR: could not pull … nothing was deployed` | The guard fired correctly; nothing was touched and `artisan up` already ran. Usually a diverged tree or a transient network failure. | SSH in, `git status`, resolve, re-run. **Never `git reset --hard` without looking first.** |
| `ERROR: deploy operations failed` + site 503 | An `operations/*` file threw. Maintenance mode is left **on deliberately** — a half-applied release must not go live. | Fix the operation and re-run; or `php artisan up` if the effect actually landed. |
| `WARNING: Health check failed` + `Rollback completed to <sha>` | The script already rolled the code back and brought the site up. | Diagnose the failed release. Do **not** re-deploy the same commit blind. |
| Site 503, no deploy running | Left in maintenance mode. | `ssh … 'cd <path> && php artisan up'` |
| `git` "detected dubious ownership" | The tree is chowned to the web user while the deploy runs as root. | `git config --global --add safe.directory <path>` |

> **Gotcha:** **A deploy operation is not a console command.** `Operation` has no `line()`,
> `info()` or `$this->command` — a progress message inside one throws **after** the work it was
> reporting already happened. The effects land, the command reports failure, the deploy stops,
> and production serves 503 over a change that actually succeeded. It also hides on a re-run,
> because by then the loop has nothing left to process and the throwing line is never reached.
> Keep operations silent. This is the single most common cause of the row above.

## Production traps that have already cost time

- **`.env` is not the source of truth for settings the app stores in the database.**
  `App\Settings\MailSettings` overlays `config('mail.*')` at boot, so after any
  `migrate:fresh` the mailer reverts to the seeded default (`log`) — and `app:test-send-mail`
  then exits 0 and writes to `storage/logs` while recording a `mail_histories` row. Nothing
  distinguishes that from a delivered email. Check `config('mail.default')`, never
  `env('MAIL_MAILER')`.
- **Unquoted `.env` values containing spaces break the entire file** ("Failed to parse dotenv
  file") — not just that line. Quote anything with whitespace.
- **Some hosts block outbound SMTP on 25/465/587** (DigitalOcean does). Use **2525**, which
  SparkPost, Mailgun and SendGrid all publish for this reason. It is a network-level block; no
  firewall rule opens it.
- **Any command that may run unattended needs `--force`.** A production confirmation prompt with
  no TTY cancels *and exits 0* — that is how a `migrate:fresh` + seed leaves a migrated but
  **unseeded** database with no superadmin and a caller that believes it succeeded.
- **Never rotate `APP_KEY`.** It destroys every `encrypted:array` column with no recovery, and
  invalidates every registered passkey (`config/passkeys.php` derives the WebAuthn user handle
  secret from it unless `PASSKEYS_USER_HANDLE_SECRET` is pinned).
- **The scheduler must run from cron on exactly one host**, and Horizon supervises only the
  connections named in `config/horizon.php`. A job dispatched with `->onConnection('database')`
  is invisible to a Horizon watching `redis` — it sits unclaimed in `jobs` while the UI reports
  success. Both the scheduler and a worker on the right connection must be alive for the app to
  do anything.
- **A self-hosting deployment platform must never register its own host as a managed node.**
  The destroy path would remove its own runtime; the bootstrap path would rewrite its own SSH
  access.

## Stay in scope

A deploy request is a deploy request. Pre-existing non-fatal warnings in the output —
`optimize` failing at the view stage over a missing Blade component is the classic one, since
views simply run uncached and the site is fine — get **mentioned once** in the report and are
not chased. Do not turn "deploy latest" into a refactor.

## Related

- `docs/04-deployment/` — the project's own host reference, `.env` guide, backup/restore drill
- `bin/provision-host` — idempotent host provisioner for a new machine
- `bin/backup-db` / `bin/backup-app` — run before any risky release
- `ci-cd-pipeline` skill — for the pipeline itself rather than a manual release

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's a one-line change, no need for the checklist" | The checklist is short precisely so it survives one-line changes. Most bad deploys were small. |
| "The backup is probably fine" | An unverified backup is not a backup. Check the file size and the timestamp before you migrate. |
| "I'll run the migration and see what happens" | On production, "see what happens" is the plan for data loss. Classify it as additive or destructive first. |
| "Tests passed on main, so this commit is fine" | You are deploying a specific commit. Confirm the suite was green on *that* SHA. |
| "The queue will pick up the new code eventually" | Workers hold the class in memory. Without `queue:restart` they run the old code until they die. |
| "I'll fix forward, rolling back is messy" | Fixing forward under pressure ships a second untested change on top of a broken one. |
| "Maintenance mode is annoying for users" | A 503 for ninety seconds is less annoying than a half-migrated database. |
| "It deployed without errors, so it worked" | A successful deploy command and a working application are different claims. Load a real page. |
| "Let me just rotate APP_KEY to be safe" | That destroys every `encrypted:` column with no recovery, and invalidates every passkey. |

## Red Flags

- Deploying without a fresh, size-checked backup
- A destructive migration with no written rollback
- `migrate:fresh`, `db:wipe`, or `--seed` typed against a production host
- `queue:restart` skipped after a deploy that touched job classes
- New `.env` keys added to the repo but never set on the host
- No post-deploy verification beyond "the command exited 0"
- The app left in maintenance mode with nobody told
- Editing files directly on the production host
- A deploy that also contains a refactor
- `APP_KEY` in the diff

## Verification

- [ ] Backup taken, and its size and timestamp checked
- [ ] Migrations classified; destructive ones have a written rollback
- [ ] Deployed commit SHA matches a green test run
- [ ] `php artisan about` shows the expected env, drivers and versions
- [ ] Homepage and one authenticated route return 200
- [ ] `queue:restart` ran, and one real job was observed completing
- [ ] Scheduler alive on exactly one host; `schedule:list` matches cron
- [ ] Log tailed for 60s with no new exception class
- [ ] App is out of maintenance mode
- [ ] Report delivered: what shipped, what migrated, what warnings were seen and deliberately not chased

---

## Reference Files

| File | Read When |
|---|---|
| `references/deploy-checklist.md` | Running a release — pre-flight, release steps, post-flight verification |
| `references/rollback-playbook.md` | A release went wrong; deciding roll back vs fix forward, and how to do either |
