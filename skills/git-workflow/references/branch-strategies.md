# Branch Strategies Reference

## Git Flow

### Overview

Git Flow uses long-lived branches for releases and parallel development.

```
main ─────●──────────────●──────────────●──────
           \            / \            /
develop ────●──●──●──●──   ●──●──●──●──
              \     /         \     /
feature/       ●──●           ●──●
```

### Branches

| Branch | Purpose | Merges Into |
|---|---|---|
| `main` | Production-ready code, tagged releases | — |
| `develop` | Integration branch for features | `main` (via release) |
| `feature/*` | New features | `develop` |
| `release/*` | Release preparation, final fixes | `main` and `develop` |
| `hotfix/*` | Emergency production fixes | `main` and `develop` |

### Workflow

1. Create feature branch from `develop`: `git checkout -b feature/add-login develop`
2. Work on feature, commit with conventional commits
3. Open PR from `feature/add-login` → `develop`
4. When ready to release, create release branch: `git checkout -b release/1.2.0 develop`
5. Fix release issues on release branch, then merge into `main` and `develop`
6. Tag `main`: `git tag -a 1.2.0 -m "1.2.0"`
7. For production emergencies, branch from `main`: `git checkout -b hotfix/fix-crash main`
8. Merge hotfix into both `main` and `develop`

### Best For

- Teams of 4+ developers
- Scheduled release cycles (weekly, bi-weekly, monthly)
- Projects with multiple environments (staging, production)
- When parallel release preparation is needed

---

## Trunk-Based Development

### Overview

All developers commit to `main` (the trunk) with short-lived feature branches.

```
main ─────●──●──●──●──●──●──●──●──●──●──
            \  /     \  /         \  /
feature/     ●        ●           ●
          (1-2 days)
```

### Rules

- Feature branches live at most 1-2 days
- All merges go directly to `main`
- Feature flags hide incomplete work in production
- `main` is always deployable
- CI runs on every push to `main`

### Workflow

1. Pull latest `main`: `git pull origin main`
2. Create short-lived branch: `git checkout -b feature/update-header`
3. Make small, focused changes (1-3 commits)
4. Open PR → `main`, get quick review
5. Squash merge into `main`
6. Delete feature branch
7. Deploy automatically from `main`

### Best For

- Teams practicing continuous deployment
- High-velocity development with multiple deploys per day
- Teams with strong CI/CD and automated testing
- Projects where feature flags are practical

---

## GitHub Flow

### Overview

A simplified workflow with `main` and PR-based feature branches.

```
main ─────●────────●────────●────────●──
           \      /  \      /  \      /
feature/    ●──●      ●──●      ●──●
```

### Rules

- `main` is always deployable
- Branch from `main` for any change
- Open a PR for discussion and review
- Merge via PR after review and CI passes
- Deploy after merge to `main`

### Workflow

1. Create branch from `main`: `git checkout -b feature/add-search`
2. Commit changes with conventional commits
3. Push branch: `git push -u origin feature/add-search`
4. Open PR with description and checklist
5. Address review feedback
6. Squash merge after approval and green CI
7. Delete branch after merge

### Best For

- Small teams (1-3 developers)
- Projects with simple release processes
- Open-source projects
- When simplicity is preferred over ceremony

---

## Decision Matrix

| Team Size | Release Cadence | CI/CD Maturity | Recommended Strategy |
|---|---|---|---|
| 1–3 | Continuous | Any | GitHub Flow |
| 1–3 | Scheduled | Any | GitHub Flow |
| 4–10 | Continuous | Strong | Trunk-based development |
| 4–10 | Scheduled | Any | Git Flow |
| 10+ | Continuous | Strong | Trunk-based development |
| 10+ | Scheduled | Any | Git Flow |

### Key Factors

- **Team size** — larger teams need more structure to avoid conflicts
- **Release frequency** — continuous deployment favours trunk-based; scheduled releases favour Git Flow
- **CI/CD maturity** — trunk-based development requires strong automated testing
- **Feature flags** — required for trunk-based development to hide incomplete work
- **Compliance** — regulated industries may require Git Flow for audit trails

---

## Branch Naming Conventions

### Format

```
<type>/<description>
```

### Types

| Prefix | Purpose |
|---|---|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `chore/` | Maintenance, refactoring |
| `release/` | Release preparation (Git Flow) |
| `hotfix/` | Emergency production fixes (Git Flow) |
| `docs/` | Documentation changes |
| `test/` | Test additions or updates |

### Rules

- Use kebab-case: `feature/add-user-search`
- Include ticket number if available: `feature/PROJ-123-add-user-search`
- Keep under 50 characters
- Use descriptive names: `fix/null-pointer-on-login` not `fix/bug`
- Delete branches after merging

---

## Branch Protection Rules

### Via GitHub CLI

Protect `main` branch:

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["tests", "lint", "phpstan"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

### For Git Flow — Protect `develop` Branch

```bash
gh api repos/{owner}/{repo}/branches/develop/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": false
  },
  "restrictions": null
}
EOF
```

### Rulesets (Newer Alternative)

For repositories using GitHub rulesets:

```bash
gh api repos/{owner}/{repo}/rulesets \
  --method POST \
  --input - <<EOF
{
  "name": "main-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    { "type": "pull_request", "parameters": { "required_approving_review_count": 1 } },
    { "type": "required_status_checks", "parameters": { "required_status_checks": [{ "context": "tests" }] } },
    { "type": "non_fast_forward" }
  ]
}
EOF
```
