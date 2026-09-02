# Deployment Checklist

Run top to bottom. A skipped box is a decision, not an oversight — say which one you skipped and why.

## Pre-flight (before touching the host)

- [ ] `git log --oneline <last-tag>..HEAD` reviewed — you know what is shipping
- [ ] Migrations in the diff identified and classified (additive / destructive / long-running)
- [ ] Any destructive migration has a written rollback, or the release is blocked
- [ ] `.env.example` diff checked — new keys exist on the host before deploy, not after
- [ ] New queue connections / scheduled commands cross-checked against `config/horizon.php` and cron
- [ ] Test suite green on the exact commit being deployed
- [ ] Backup taken (`bin/backup-db`, `bin/backup-app`) and its file size sanity-checked — a 0-byte dump is not a backup

## Release

- [ ] `php artisan down --render=errors::503 --retry=60` if migrations are destructive or long
- [ ] Pull the commit, `composer install --no-dev --optimize-autoloader`
- [ ] `npm ci && npm run build` if front-end assets changed
- [ ] `php artisan migrate --force`
- [ ] `php artisan optimize` (config/route/view/event caches)
- [ ] `php artisan queue:restart` — workers run stale code until restarted
- [ ] `php artisan up`

## Post-flight (the part people skip)

- [ ] Homepage and one authenticated route load
- [ ] `php artisan about` shows the expected environment, cache drivers and versions
- [ ] Horizon (or `queue:work`) is processing — dispatch one real job and watch it complete
- [ ] Scheduler heartbeat: `php artisan schedule:list` matches cron, and cron is alive on exactly one host
- [ ] `tail` the log for 60 seconds — a new exception class appearing is a failed deploy
- [ ] Report: what shipped, what migrated, what warnings appeared, what was deliberately not chased

## Never

- Rotate `APP_KEY` on a live app with encrypted columns or registered passkeys
- Run `migrate:fresh`, `db:wipe` or `migrate --seed` against production
- Deploy an untested commit "because it's a one-line fix"
- Leave the app in maintenance mode without saying so in the report
