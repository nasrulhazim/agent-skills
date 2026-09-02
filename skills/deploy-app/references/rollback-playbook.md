# Rollback Playbook

Rolling back is cheaper than debugging in production. Decide fast, apologise later.

## Decide in 60 seconds

| Signal | Action |
|---|---|
| 5xx rate above baseline, any volume | Roll back now |
| New exception class in the log | Roll back now |
| Queue backing up, jobs failing | Roll back now |
| One cosmetic bug, no data risk | Fix forward |
| Slow but correct | Fix forward, monitor |

## Code-only release (no migrations)

```bash
php artisan down
git checkout <previous-tag>
composer install --no-dev --optimize-autoloader
npm ci && npm run build          # only if assets shipped
php artisan optimize
php artisan queue:restart
php artisan up
```

## Release with additive migrations

Additive migrations (new nullable column, new table, new index) are usually **backward
compatible** — roll the code back and leave the schema alone. Do not run `migrate:rollback`
just for tidiness; an unused column is harmless, a dropped one is not.

## Release with destructive migrations

There is no clean rollback. This is why the backup exists.

1. `php artisan down` — stop writes immediately
2. Restore the pre-deploy database dump
3. Roll the code back to the previous tag
4. `php artisan up`
5. Accept and announce the data loss window: everything written between deploy and restore is gone

## After any rollback

- Write down the trigger signal, the time, and the data window lost
- Open an issue with the failing commit range before touching the fix
- Do not redeploy the same commit "to see if it was a fluke"
