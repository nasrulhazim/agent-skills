# Hooks and Templates Reference

## CaptainHook — PHP/Laravel

### Installation

```bash
composer require --dev captainhook/captainhook captainhook/hook-installer
vendor/bin/captainhook install
```

### Full Configuration — `captainhook.json`

```json
{
  "config": {
    "verbosity": "normal",
    "run-mode": "docker",
    "run-exec": "docker exec -t app",
    "run-path": "",
    "fail-on-first-error": false,
    "ansi-colors": true
  },
  "pre-commit": {
    "enabled": true,
    "actions": [
      {
        "action": "vendor/bin/pint --test --dirty",
        "conditions": [
          {
            "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any",
            "args": ["*.php"]
          }
        ]
      },
      {
        "action": "vendor/bin/phpstan analyse --no-progress --memory-limit=512M",
        "conditions": [
          {
            "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any",
            "args": ["*.php"]
          }
        ]
      },
      {
        "action": "vendor/bin/pest --dirty",
        "conditions": [
          {
            "exec": "\\CaptainHook\\App\\Hook\\Condition\\FileChanged\\Any",
            "args": ["*.php"]
          }
        ]
      }
    ]
  },
  "commit-msg": {
    "enabled": true,
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
    "enabled": true,
    "actions": [
      {
        "action": "vendor/bin/pest --parallel"
      }
    ]
  },
  "prepare-commit-msg": {
    "enabled": false,
    "actions": []
  },
  "post-commit": {
    "enabled": false,
    "actions": []
  },
  "post-merge": {
    "enabled": false,
    "actions": []
  },
  "post-checkout": {
    "enabled": false,
    "actions": []
  },
  "post-rewrite": {
    "enabled": false,
    "actions": []
  }
}
```

### Docker Mode

When using Laravel Sail or Docker, set `run-mode` to `docker` and `run-exec` to execute commands inside the container:

```json
{
  "config": {
    "run-mode": "docker",
    "run-exec": "docker exec -t app"
  }
}
```

For non-Docker environments, use local mode:

```json
{
  "config": {
    "run-mode": "local"
  }
}
```

---

## husky + lint-staged — JavaScript/Node

### Installation

```bash
npm install --save-dev husky lint-staged
npx husky init
```

### Pre-commit Hook — `.husky/pre-commit`

```bash
npx lint-staged
```

### Commit Message Hook — `.husky/commit-msg`

```bash
npx --no -- commitlint --edit $1
```

### lint-staged Configuration — `package.json`

```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "prettier --write"
    ],
    "*.{json,md,yaml,yml}": [
      "prettier --write"
    ],
    "*.vue": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

### commitlint Configuration — `commitlint.config.js`

```js
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert',
    ]],
    'scope-enum': [2, 'always', [
      'auth', 'api', 'ui', 'db', 'config',
      'test', 'ci', 'model', 'route', 'middleware',
    ]],
    'subject-max-length': [2, 'always', 72],
    'body-max-line-length': [2, 'always', 80],
  },
};
```

### commitlint Installation

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

---

## PR Template

### `.github/pull_request_template.md`

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

## Screenshots

<!-- If applicable, add screenshots or screen recordings -->

## Related Issues

Closes #
```

### Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug Report
about: Report a bug to help us improve
labels: bug
---

## Description

<!-- A clear description of the bug -->

## Steps to Reproduce

1.
2.
3.

## Expected Behaviour

<!-- What should happen -->

## Actual Behaviour

<!-- What actually happens -->

## Environment

- PHP:
- Laravel:
- OS:
```

Create `.github/ISSUE_TEMPLATE/feature_request.md`:

```markdown
---
name: Feature Request
about: Suggest an idea for this project
labels: enhancement
---

## Problem

<!-- What problem does this solve? -->

## Proposed Solution

<!-- Describe the solution you'd like -->

## Alternatives Considered

<!-- Any alternative solutions or features? -->

## Additional Context

<!-- Add any other context or screenshots -->
```

---

## .gitignore Templates

### Laravel Application

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

### Laravel Package

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

### Node/JavaScript

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

### Full-Stack Laravel + Node

```gitignore
# Dependencies
/node_modules
/vendor

# Build output
/public/build
/public/hot

# Environment
.env
.env.backup
.env.production
.env.local

# Laravel
/storage/*.key
.phpunit.result.cache
/.phpunit.cache
Homestead.json
Homestead.yaml
auth.json

# Logs
npm-debug.log
yarn-error.log
storage/logs/*.log

# IDE
/.fleet
/.idea
/.vscode
/.claude

# OS
.DS_Store
Thumbs.db

# Coverage
/coverage
```

---

## .gitattributes Template

### Standard Project

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
*.xml text

# Shell
*.sh text eol=lf
*.bash text eol=lf

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

# SQLite (binary)
*.sqlite binary
*.db binary

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

### Package Distribution

For packages that use `--prefer-dist`, add more export-ignore rules:

```gitattributes
# Additional export-ignore for packages
/.github export-ignore
/tests export-ignore
/docs export-ignore
/.editorconfig export-ignore
/.gitattributes export-ignore
/.gitignore export-ignore
/phpstan.neon export-ignore
/phpunit.xml export-ignore
/pint.json export-ignore
/rector.php export-ignore
/CLAUDE.md export-ignore
/CHANGELOG.md export-ignore
/CONTRIBUTING.md export-ignore
/testbench.yaml export-ignore
```
