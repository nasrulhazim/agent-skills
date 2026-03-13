# DDD Migration Checklist

## Pre-Migration

- [ ] All tests passing on current flat structure
- [ ] Domain map completed (`/project-ddd discover`)
- [ ] Migration plan generated (`/project-ddd plan`)
- [ ] Team aligned on domain boundaries
- [ ] Git branch created for migration

## Phase 1: Foundation

### Task 1: Scaffold src/ and Configure Autoloading

- [ ] Create `src/Domain/` directory
- [ ] Update `composer.json` with `"Src\\": "src/"` PSR-4 mapping
- [ ] Run `composer dump-autoload`
- [ ] Verify autoloader works with a test class
- [ ] Commit: `refactor(ddd): scaffold src/ directories and configure autoloading`

### Task 2: Move Shared Domain

- [ ] Create `src/Domain/Shared/Domain/Models/`
- [ ] Move `Base.php` and shared traits
- [ ] Move shared contracts/interfaces
- [ ] Move shared value objects
- [ ] Update all `use App\Models\Base` references to `Src\Domain\Shared\Domain\Models\Base`
- [ ] Run `composer dump-autoload`
- [ ] Run tests — all must pass
- [ ] Commit: `refactor(ddd): move Shared domain models`

**Gate: Tests must pass before proceeding.**

## Phase 2: Core Domains (repeat per domain)

### Task N: Move {Domain} Domain Layer

- [ ] Create `src/Domain/{Domain}/Domain/Models/`
- [ ] Move domain models
- [ ] Move domain events
- [ ] Move domain contracts/interfaces
- [ ] Move value objects (if any)
- [ ] Update all namespace references across codebase
- [ ] Run `composer dump-autoload`
- [ ] Run tests
- [ ] Commit: `refactor(ddd): move {Domain} domain layer`

### Task N+1: Move {Domain} Application Layer

- [ ] Create `src/Domain/{Domain}/Application/`
- [ ] Move actions (if using cleaniquecoders/laravel-action)
- [ ] Move jobs
- [ ] Move services
- [ ] Move DTOs (if any)
- [ ] Update all namespace references
- [ ] Run tests
- [ ] Commit: `refactor(ddd): move {Domain} application layer`

### Task N+2: Move {Domain} Infrastructure Layer

- [ ] Create `src/Domain/{Domain}/Infrastructure/`
- [ ] Move registrars
- [ ] Move exports
- [ ] Move event listeners
- [ ] Update all namespace references
- [ ] Run tests
- [ ] Commit: `refactor(ddd): move {Domain} infrastructure layer`

**Gate: Tests must pass before moving to next domain.**

## Phase 3: Wiring

### Task: Create Domain Service Providers

- [ ] Generate `{Domain}ServiceProvider` for each domain
- [ ] Move domain-specific bindings from `AppServiceProvider`
- [ ] Register domain providers in `bootstrap/providers.php`
- [ ] Wire up domain event listeners in domain providers
- [ ] Clean up `AppServiceProvider` (should be minimal)
- [ ] Run tests
- [ ] Commit: `refactor(ddd): create domain service providers`

### Task: Update Architecture Tests

- [ ] Add layer boundary tests (domain cannot import infrastructure)
- [ ] Add naming convention tests
- [ ] Add cross-domain isolation tests
- [ ] Verify all arch tests pass
- [ ] Commit: `test(ddd): update architecture tests for DDD structure`

## Phase 4: Verification

### Task: Final Cleanup

- [ ] Remove empty directories in `app/`
- [ ] Verify no orphan files left in `app/Models/`, `app/Events/`, etc.
- [ ] Run full test suite
- [ ] Run PHPStan (check for missing class references)
- [ ] Run `composer dump-autoload --optimize`
- [ ] Verify application works end-to-end (manual smoke test)
- [ ] Commit: `refactor(ddd): clean up empty directories, final verification`

## Post-Migration

- [ ] Update CLAUDE.md with new domain structure conventions
- [ ] Update team documentation
- [ ] Update CI pipeline if paths changed
- [ ] Tag release

## Migration Rules

1. **One task = one commit** — easy to revert if something breaks
2. **Tests after every move** — never skip this
3. **Move, don't refactor** — resist the urge to "improve" while migrating
4. **Shared first, then core, then supporting** — dependency order matters
5. **Keep app/ and src/ coexisting** — migration is incremental
6. **No database changes** — DDD is code organisation, tables stay the same
7. **Update references immediately** — don't leave broken imports for later
