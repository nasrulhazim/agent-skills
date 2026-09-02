---
name: git-workflow
metadata:
  compatible_agents: [claude-code]
  tags: [git, conventional-commits, semver, changelog, hooks, branching, github]
description: >
  Git workflow automation for Laravel and JavaScript projects. Covers conventional commits,
  semantic versioning, changelog generation, release workflows, branch strategies, pre-commit
  hooks, PR templates, and .gitignore scaffolding. Trigger: "set up git conventions",
  "generate commit message", "create changelog", "prepare release", "branch strategy",
  "set up git hooks", "create PR template", "generate gitignore". BM: "sediakan konvensyen git",
  "jana mesej commit", "buat changelog", "sediakan release", "strategi branch",
  "sediakan git hooks", "buat templat PR", "jana gitignore".
---

# Git Workflow

Automate and standardise git workflows — from commit messages to releases — for Laravel and JavaScript projects.

## Command Reference

| Command | Description |
|---|---|
| `/git init-conventions` | Set up conventional commits + commitlint + hooks in a project |
| `/git commit` | Generate conventional commit message from staged changes |
| `/git changelog` | Generate/update CHANGELOG.md from git history |
| `/git release` | Version bump, changelog, tag, GitHub Release |
| `/git branch-strategy` | Recommend and scaffold branch strategy |
| `/git hooks` | Set up pre-commit hooks (CaptainHook for PHP, husky for JS) |
| `/git pr-template` | Generate PR template + review checklist |
| `/git ignore` | Generate .gitignore + .gitattributes by project type |

---

## 1. `/git init-conventions` — Conventional Commits Setup

Set up conventional commits tooling in an existing project.

### Conventional Commits Specification

Format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Allowed Types

| Type | SemVer Impact | When to Use |
|---|---|---|
| `feat` | MINOR | New feature or capability |
| `fix` | PATCH | Bug fix |
| `docs` | — | Documentation only |
| `style` | — | Formatting, whitespace, semicolons |
| `refactor` | — | Code restructure without behaviour change |
| `perf` | PATCH | Performance improvement |
| `test` | — | Adding or updating tests |
| `build` | — | Build system or dependency changes |
| `ci` | — | CI configuration changes |
| `chore` | — | Maintenance tasks |
| `revert` | varies | Reverts a previous commit |

### Laravel Scopes

Use scopes to identify the affected area:

- `auth` — Authentication, authorization, guards, policies
- `api` — API routes, controllers, resources, middleware
- `ui` — Blade, Livewire, Flux components, frontend
- `db` — Migrations, seeders, factories, query changes
- `config` — Configuration files, environment variables
- `test` — Test files and test utilities
- `ci` — GitHub Actions, deployment scripts
- `model` — Eloquent models, relationships, scopes
- `route` — Route definitions, middleware assignment
- `middleware` — HTTP middleware classes

### Breaking Changes

Signal breaking changes with either:

1. `!` after type/scope: `feat(api)!: change pagination response format`
2. `BREAKING CHANGE:` footer:

```
feat(api): change pagination response format

BREAKING CHANGE: Pagination now returns `meta.total` instead of `total`.
Consumers must update response parsing logic.
```

Both trigger a MAJOR version bump.

### Setup Steps

1. **PHP/Laravel projects** — install CaptainHook for commit-msg validation:

```bash
composer require --dev captainhook/captainhook captainhook/hook-installer
vendor/bin/captainhook install
```

Add commit-msg hook to `captainhook.json`:

```json
{
  "commit-msg": {
    "actions": [
      {
        "action": "\\CaptainHook\\App\\Hook\\Message\\Action\\Regex",
        "options": {
          "regex": "#^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\\(.+\\))?!?:\\s.{1,72}$#"
        }
      }
    ]
  }
}
```

2. **JS/Node projects** — install commitlint + husky:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional husky
npx husky init
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
```

Create `commitlint.config.js`:

```js
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', [
      'auth', 'api', 'ui', 'db', 'config', 'test', 'ci',
      'model', 'route', 'middleware',
    ]],
  },
};
```

See `references/conventional-commits.md` for the full specification and examples.

---

## 2. `/git commit` — Commit Message Generation

Generate a conventional commit message from staged changes.

### Workflow

1. Read the staged diff: `git diff --cached --stat` and `git diff --cached`
2. Classify the change type from the diff content
3. Detect the scope from file paths (e.g., `app/Http/Middleware/` → `middleware`)
4. Generate the commit message with appropriate type, scope, subject, and body

### Scope Detection Rules

| Path Pattern | Scope |
|---|---|
| `app/Models/` | `model` |
| `app/Http/Controllers/Api/` | `api` |
| `app/Http/Middleware/` | `middleware` |
| `app/Policies/`, `app/Http/Controllers/Auth/` | `auth` |
| `resources/views/`, `resources/js/` | `ui` |
| `database/migrations/`, `database/seeders/` | `db` |
| `config/` | `config` |
| `tests/` | `test` |
| `routes/` | `route` |
| `.github/workflows/` | `ci` |

### Message Rules

- Subject line: imperative mood, lowercase, no period, max 72 characters
- Body: wrap at 80 characters, explain **what** and **why**, not how
- Footer: reference issues with `Closes #123` or `Refs #456`

### Co-Authored-By Support

When pair programming or AI-assisted development, add the footer:

```
feat(auth): add two-factor authentication support

Implement TOTP-based 2FA using pragmarx/google2fa-laravel package.

Co-Authored-By: Name <email@example.com>
```

---

## 3. `/git changelog` — Changelog Generation

Generate or update CHANGELOG.md following the [Keep a Changelog](https://keepachangelog.com/) format.

### Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- feat commits

### Changed
- refactor, perf commits

### Deprecated
- commits noting deprecations

### Removed
- commits removing features

### Fixed
- fix commits

### Security
- security-related fix commits

## [1.2.0] - 2026-02-27

### Added
- ...
```

### Commit Type to Changelog Section Mapping

| Commit Type | Changelog Section |
|---|---|
| `feat` | Added |
| `fix` | Fixed |
| `refactor`, `perf` | Changed |
| `revert` | Removed or Changed |
| `docs`, `style`, `test`, `build`, `ci`, `chore` | Omitted (unless notable) |
| Breaking change | Section header gets `**BREAKING**` prefix |

### Generation Steps

1. Determine the last release tag: `git describe --tags --abbrev=0`
2. Parse commits since last tag: `git log <tag>..HEAD --format="%H %s"`
3. Group commits by type using the mapping above
4. If CHANGELOG.md exists, insert the new section below `## [Unreleased]`
5. If CHANGELOG.md does not exist, create it with the full header

### Comparison Links

Add comparison links at the bottom of the changelog:

```markdown
[Unreleased]: https://github.com/owner/repo/compare/1.2.0...HEAD
[1.2.0]: https://github.com/owner/repo/compare/1.1.0...1.2.0
```

---

## 4. `/git release` — Release Workflow

Automate version bumps, changelog updates, tagging, and GitHub Releases.

### Semantic Versioning Rules

Given a version `MAJOR.MINOR.PATCH`:

- **MAJOR** — breaking changes (`BREAKING CHANGE:` footer or `!` in type)
- **MINOR** — new features (`feat` type)
- **PATCH** — bug fixes (`fix`, `perf` types)

Pre-release versions: `1.0.0-alpha.1`, `1.0.0-beta.1`, `1.0.0-rc.1`

### Version Detection

Read the current version from:

- **PHP**: `composer.json` → `version` field, or latest git tag
- **JS/Node**: `package.json` → `version` field
- **Fallback**: `git describe --tags --abbrev=0`

### Tag Format

Tags use **bare semver** without `v` prefix: `1.0.0`, `1.2.3`, `2.0.0-beta.1`.

- **DO**: `git tag -a 1.2.0 -m "1.2.0"`
- **DON'T**: `git tag -a v1.2.0 -m "v1.2.0"`

### Release Steps

1. **Determine bump type** — scan commits since last tag for breaking changes, features, fixes
2. **Bump version** — update `composer.json` and/or `package.json`
3. **Update changelog** — run the changelog generation workflow
4. **Commit** — `chore(release): X.Y.Z`
5. **Tag** — `git tag -a X.Y.Z -m "X.Y.Z"`
6. **Push** — `git push && git push --tags`
7. **GitHub Release** — create via `gh release create`:

```bash
gh release create X.Y.Z \
  --title "X.Y.Z" \
  --notes-file CHANGELOG_EXCERPT.md \
  --latest
```

### Pre-release Support

For alpha/beta/rc releases:

```bash
gh release create X.Y.Z-beta.1 \
  --title "X.Y.Z Beta 1" \
  --prerelease
```

---

## 5. `/git branch-strategy` — Branch Strategy

Recommend and scaffold a branching strategy based on team size and release cadence.

### Strategy Selection

| Team Size | Release Frequency | Recommended Strategy |
|---|---|---|
| 1–3 | Continuous | GitHub Flow |
| 1–3 | Scheduled | GitHub Flow |
| 4–10 | Continuous | Trunk-based development |
| 4–10 | Scheduled | Git Flow |
| 10+ | Continuous | Trunk-based development |
| 10+ | Scheduled | Git Flow |

### Branch Naming Conventions

```
feature/SHORT-DESCRIPTION     # New features
fix/SHORT-DESCRIPTION          # Bug fixes
chore/SHORT-DESCRIPTION        # Maintenance tasks
release/X.Y.Z                  # Release preparation (Git Flow)
hotfix/SHORT-DESCRIPTION       # Production hotfixes (Git Flow)
```

Rules:
- Use kebab-case for descriptions
- Prefix with ticket number if available: `feature/PROJ-123-add-login`
- Keep branch names under 50 characters

### Branch Protection

Set up branch protection via `gh` CLI:

```bash
# Protect main branch
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["tests", "lint"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
EOF
```

See `references/branch-strategies.md` for detailed strategy diagrams and guidance.

---

## 6. `/git hooks` — Pre-commit Hooks

Set up pre-commit hooks to enforce code quality before commits are created.

### PHP/Laravel — CaptainHook

Install and configure CaptainHook:

```bash
composer require --dev captainhook/captainhook captainhook/hook-installer
vendor/bin/captainhook install
```

Full `captainhook.json` configuration:

```json
{
  "pre-commit": {
    "actions": [
      {
        "action": "vendor/bin/pint --test --dirty",
        "conditions": [
          { "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any", "args": ["*.php"] }
        ]
      },
      {
        "action": "vendor/bin/phpstan analyse --no-progress --memory-limit=512M",
        "conditions": [
          { "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any", "args": ["*.php"] }
        ]
      },
      {
        "action": "vendor/bin/pest --dirty",
        "conditions": [
          { "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any", "args": ["*.php"] }
        ]
      }
    ]
  },
  "commit-msg": {
    "actions": [
      {
        "action": "\\CaptainHook\\App\\Hook\\Message\\Action\\Regex",
        "options": {
          "regex": "#^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\\(.+\\))?!?:\\s.{1,72}$#"
        }
      }
    ]
  },
  "pre-push": {
    "actions": [
      {
        "action": "vendor/bin/pest --parallel"
      }
    ]
  }
}
```

### JS/Node — husky + lint-staged

```bash
npm install --save-dev husky lint-staged
npx husky init
```

Create `.husky/pre-commit`:

```bash
npx lint-staged
```

Add to `package.json`:

```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx}": ["eslint --fix", "prettier --write"],
    "*.{css,scss}": ["prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
```

See `references/hooks-and-templates.md` for complete configuration templates.

---

## 7. `/git pr-template` — PR Template

Generate a pull request template and review checklist.

### Template Location

Create `.github/pull_request_template.md`:

```markdown
## Summary

<!-- Describe what this PR does and why -->

## Type of Change

- [ ] feat: New feature
- [ ] fix: Bug fix
- [ ] refactor: Code restructure
- [ ] docs: Documentation
- [ ] test: Test coverage
- [ ] chore: Maintenance

## Changes

<!-- List the key changes -->

-

## Testing

- [ ] Tests pass locally (`php artisan test` / `npm test`)
- [ ] New tests added for new functionality
- [ ] Manual testing completed

## Checklist

- [ ] Code follows project conventions
- [ ] Self-reviewed the diff
- [ ] No `dd()`, `dump()`, `console.log()` left behind
- [ ] Database migrations are reversible
- [ ] No secrets or credentials committed
- [ ] Documentation updated if needed

## Related Issues

Closes #
```

### Label Conventions

| Label | Colour | When to Apply |
|---|---|---|
| `feature` | `#0E8A16` | New functionality |
| `bugfix` | `#D93F0B` | Bug fix |
| `breaking` | `#B60205` | Breaking change |
| `docs` | `#0075CA` | Documentation only |
| `dependencies` | `#EDEDED` | Dependency updates |

### Squash Merge Guidance

- Use squash merge for feature branches to keep main history clean
- The squash commit message should follow conventional commits format
- Set as repository default:

```bash
gh api repos/{owner}/{repo} \
  --method PATCH \
  --field allow_squash_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=false \
  --field squash_merge_commit_title=PR_TITLE
```

---

## 8. `/git ignore` — .gitignore & .gitattributes

Generate .gitignore and .gitattributes files by project type.

### Laravel Application .gitignore

```gitignore
/node_modules
/public/build
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
npm-debug.log
yarn-error.log
/.fleet
/.idea
/.vscode
/.claude
```

### Laravel Package .gitignore

```gitignore
/vendor
/node_modules
/.phpunit.result.cache
/.phpunit.cache
/coverage
/.idea
/.vscode
/.claude
composer.lock
.env
```

### Node/JavaScript .gitignore

```gitignore
node_modules/
dist/
build/
coverage/
.env
.env.local
.env.*.local
*.log
.DS_Store
/.idea
/.vscode
/.claude
```

### .gitattributes Template

```gitattributes
# Auto detect text files and perform LF normalisation
* text=auto

# PHP
*.php text diff=php

# Web
*.css text diff=css
*.html text diff=html
*.js text
*.ts text
*.json text
*.md text
*.yaml text
*.yml text

# Graphics (binary)
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.svg text

# Archives (binary)
*.zip binary
*.gz binary
*.tar binary

# Fonts (binary)
*.woff binary
*.woff2 binary
*.ttf binary
*.eot binary

# Export ignore (for git archive / --prefer-dist)
/.github export-ignore
/tests export-ignore
/.editorconfig export-ignore
/.gitattributes export-ignore
/.gitignore export-ignore
/phpstan.neon export-ignore
/phpunit.xml export-ignore
/pint.json export-ignore
/rector.php export-ignore
/CLAUDE.md export-ignore
```

See `references/hooks-and-templates.md` for additional templates.

---

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll squash it all into one commit at the end" | The end is when you have forgotten why each change was made. Commit at each working point. |
| "'fix stuff' is fine, the diff explains it" | The diff says what changed. Only the message can say why, and why is what the next reader needs. |
| "Force push is fine, it's my branch" | Until someone reviewed it, based work on it, or you typed the wrong branch name. Use `--force-with-lease`. |
| "I'll just commit the .env, it's a private repo" | Repos become public, get forked, and get cloned to laptops. A committed secret is a rotated secret. |
| "Rebasing rewrites history, that's dangerous" | Rebasing your own unpushed branch is the safest way to keep history readable. Rebasing shared history is the dangerous one. |
| "This PR is big but it's all one feature" | A 1500-line PR gets an "LGTM", not a review. Split it and get an actual read. |
| "Merge commits pollute the log" | Sometimes. But a fake-linear history that hides an integration failure is worse than a merge commit. |
| "I'll clean up the branches later" | Two hundred stale branches later, nobody can tell which are live. Delete on merge. |

## Red Flags

- Commit messages: "fix", "wip", "update", "changes", "phase 1"
- A commit containing a fix, a refactor and a formatting sweep together
- `git push --force` without `--with-lease`
- `.env`, `*.pem`, `id_rsa`, `.DS_Store`, `vendor/` or `node_modules/` in a diff
- A PR over ~1000 lines that is not a generated-file or lockfile change
- Committing directly to `main` on a repo with a PR workflow
- A merge that resolved conflicts by taking one side wholesale without reading
- Tags that drift from the version in `composer.json` / `plugin.json`
- Long-lived branches that have not been rebased in weeks

## Verification

- [ ] Each commit is one logical change, and the suite is green at that commit
- [ ] Subject lines are imperative, under ~72 chars, and say what and why
- [ ] No secrets, build artifacts or local config in the diff (`git status` is clean)
- [ ] Branch is up to date with `main` and conflicts were resolved deliberately
- [ ] PR description states the change, the reason, and how it was verified
- [ ] Diff size is reviewable in one sitting, or the PR explains why it cannot be split
- [ ] Version bumps and tags are consistent across every file that carries a version

---

## Reference Files

| File | Read When |
|---|---|
| `references/conventional-commits.md` | Setting up conventional commits, generating commit messages, or validating commit format |
| `references/branch-strategies.md` | Choosing or scaffolding a branch strategy, setting up branch protection |
| `references/hooks-and-templates.md` | Configuring pre-commit hooks, PR templates, .gitignore, or .gitattributes |
