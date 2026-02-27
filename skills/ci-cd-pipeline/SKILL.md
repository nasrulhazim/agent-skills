---
name: ci-cd-pipeline
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, github-actions, docker, ci-cd, deployment]
description: >
  CI/CD pipeline builder for Laravel projects — extends Kickoff's existing GitHub Actions CI
  with continuous deployment pipelines (staging/production), Docker containerisation, secret
  management, and failure notifications. Generates Dockerfiles, docker-compose.yml, deployment
  configs for VPS via SSH, container registry push workflows, and leverages Kickoff's /bin
  scripts (deploy.sh, backup.sh, setup.sh) in automated workflows. Use this skill whenever
  the user asks to set up deployment pipelines, containerise a Laravel app, configure CD for
  staging or production, push Docker images to a registry, manage deployment secrets, add
  failure notifications to CI, or integrate /bin scripts with GitHub Actions. Triggers for
  requests like "set up CD pipeline", "deploy to staging automatically", "dockerise my Laravel
  app", "add Docker to my project", "push image to registry", "manage secrets in CI",
  "notify on failure", "extend CI with deployment", "setup deploy pipeline", "nak deploy
  guna GitHub Actions", "tambah Docker dalam project", "setup CD untuk staging", "nak auto
  deploy ke production", "dockerise Laravel app aku", "tambah notification kalau CI fail",
  "macam mana nak manage secrets dalam GitHub Actions", or "integrate bin scripts dengan CI".
  Assumes Laravel Kickoff as the baseline — GitHub Actions CI (Pint, PHPStan, Rector, Pest)
  and /bin scripts (deploy.sh, backup.sh) are already configured. This skill extends that
  baseline with CD, Docker, and deployment automation.
---

# CI/CD Pipeline Builder

Continuous deployment pipelines, Docker containerisation, and deployment automation for
Laravel projects. Built on top of Laravel Kickoff's existing GitHub Actions CI and /bin
scripts.

## Command Reference

| Command | Description |
|---|---|
| `/ci extend` | Extend Kickoff's CI with CD pipeline (staging + production deploy) |
| `/ci docker` | Generate Dockerfile, docker-compose.yml, and .dockerignore for Laravel |
| `/ci deploy` | Deployment configs for VPS via SSH or container registry |
| `/ci secrets` | Secret management guidance for GitHub Actions and deployment |

---

## Kickoff Baseline

Laravel Kickoff projects ship with these CI/CD foundations already configured:

### GitHub Actions CI (already exists)

| Tool | Workflow Step | Purpose |
|---|---|---|
| Pint | `pint --test` | Code style enforcement |
| PHPStan / Larastan | `phpstan analyse` | Static analysis |
| Rector | `rector --dry-run` | Automated refactoring checks |
| Pest | `php artisan test` | Test suite execution |

### /bin Scripts (already exist)

| Script | Purpose |
|---|---|
| `bin/deploy.sh` | Pull latest code, install deps, run migrations, restart services |
| `bin/backup.sh` | Database dump + file backup before deployments |
| `bin/setup.sh` | First-time server setup (packages, permissions, cron, queue) |

This skill **extends** the baseline — it does not replace it. All CI steps remain;
CD steps are added after successful CI.

---

## 1. `/ci extend` — Add CD Pipeline to Existing CI

### Step 1: Assess Current Setup

Read the existing `.github/workflows/` directory. Identify:
- Which CI steps already run (Pint, PHPStan, Rector, Pest)
- Whether any CD steps already exist
- The branch strategy (main, develop, staging branches)

Ask the user:
- What is your deployment target? (VPS via SSH / Docker registry / both)
- Do you have separate staging and production environments?
- What branch triggers each environment? (default: `develop` -> staging, `main` -> production)

### Step 2: Generate CD Workflow

Create or extend `.github/workflows/deploy.yml` with:

```yaml
name: Deploy

on:
  push:
    branches:
      - main
      - develop

concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false

jobs:
  ci:
    uses: ./.github/workflows/ci.yml

  deploy-staging:
    needs: ci
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /var/www/staging
            bash bin/backup.sh
            bash bin/deploy.sh

  deploy-production:
    needs: ci
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USER }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          script: |
            cd /var/www/production
            bash bin/backup.sh
            bash bin/deploy.sh

  notify-failure:
    needs: [deploy-staging, deploy-production]
    if: failure()
    runs-on: ubuntu-latest
    steps:
      - name: Notify on failure
        uses: slackapi/slack-github-action@v2
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK }}
          webhook-type: incoming-webhook
          payload: |
            {
              "text": "Deployment failed for ${{ github.repository }} on ${{ github.ref_name }}\nCommit: ${{ github.sha }}\nWorkflow: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
            }
```

### Step 3: Environment Protection Rules

Advise the user to configure GitHub Environment protection:

| Environment | Rules |
|---|---|
| staging | No approval required, deploy on push to `develop` |
| production | Require 1 reviewer approval, deploy on push to `main` |

### Step 4: Add Notification Job

Support these notification channels:

| Channel | Action | Secret Required |
|---|---|---|
| Slack | `slackapi/slack-github-action@v2` | `SLACK_WEBHOOK` |
| Telegram | `appleboy/telegram-action@master` | `TELEGRAM_TOKEN`, `TELEGRAM_TO` |
| Email | Built-in GitHub notifications | None (configure in repo settings) |

Always add notification as a separate job that runs `if: failure()` on the deployment jobs.

---

## 2. `/ci docker` — Docker Setup for Laravel

### Step 1: Determine Environment

Ask the user:
- Development only, production only, or both?
- Database: MySQL or PostgreSQL?
- Need Redis? Meilisearch? Mailpit?
- Are you already using Laravel Sail?

### Step 2: Generate Files

Read `references/docker-laravel.md` for complete templates.

**For development:**
- `docker-compose.yml` — app, database, redis, meilisearch, mailpit
- `Dockerfile.dev` — PHP + extensions + Node for asset building
- Compare with Sail: if Sail is already in use, explain differences and let user choose

**For production:**
- `Dockerfile` — multi-stage build (composer install, npm build, final slim image)
- `docker-compose.prod.yml` — app + nginx, external database assumed
- `.dockerignore` — exclude dev files, tests, node_modules, .git

### Step 3: Docker Build + Push Workflow

If the user wants CI to build and push Docker images, generate:

```yaml
name: Docker Build & Push

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.ref_name }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## 3. `/ci deploy` — Deployment Configurations

### Step 1: Determine Deployment Strategy

Ask:
- VPS via SSH (traditional) or container-based?
- Single server or multi-server?
- Zero-downtime required?

### Step 2: VPS via SSH Deployment

Leverage Kickoff's `/bin` scripts. Read `references/kickoff-bin-scripts.md` for integration patterns.

**deploy.sh enhancement for CD:**

```bash
#!/bin/bash
set -e

APP_DIR=${APP_DIR:-/var/www/app}
cd "$APP_DIR"

echo "==> Starting deployment..."

# Maintenance mode
php artisan down --retry=60

# Pull latest
git pull origin "$BRANCH"

# Install dependencies
composer install --no-dev --optimize-autoloader --no-interaction
npm ci && npm run build

# Migrate
php artisan migrate --force

# Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan icons:cache

# Restart queue workers
php artisan queue:restart

# Clear maintenance mode
php artisan up

echo "==> Deployment complete!"
```

### Step 3: Container-Based Deployment

For Docker deployments on VPS:

```bash
#!/bin/bash
set -e

IMAGE=${IMAGE:-ghcr.io/org/app:latest}

echo "==> Pulling latest image..."
docker pull "$IMAGE"

echo "==> Running migrations..."
docker run --rm --env-file .env "$IMAGE" php artisan migrate --force

echo "==> Restarting services..."
docker compose -f docker-compose.prod.yml up -d --remove-orphans

echo "==> Cleaning up old images..."
docker image prune -f
```

### Step 4: Zero-Downtime with Symlink Strategy

For projects that need zero-downtime without containers:

```bash
#!/bin/bash
set -e

APP_DIR="/var/www/app"
RELEASES_DIR="$APP_DIR/releases"
SHARED_DIR="$APP_DIR/shared"
RELEASE="$(date +%Y%m%d%H%M%S)"
CURRENT="$APP_DIR/current"

# Create release directory
mkdir -p "$RELEASES_DIR/$RELEASE"
cd "$RELEASES_DIR/$RELEASE"

# Clone
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" .

# Link shared resources
ln -sf "$SHARED_DIR/.env" .env
ln -sf "$SHARED_DIR/storage" storage

# Install
composer install --no-dev --optimize-autoloader --no-interaction
npm ci && npm run build

# Migrate
php artisan migrate --force

# Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Swap symlink (atomic)
ln -sfn "$RELEASES_DIR/$RELEASE" "$CURRENT"

# Restart
sudo systemctl reload php8.3-fpm
php artisan queue:restart

# Keep only last 5 releases
cd "$RELEASES_DIR"
ls -dt */ | tail -n +6 | xargs rm -rf

echo "==> Deployed release $RELEASE"
```

---

## 4. `/ci secrets` — Secret Management

### GitHub Actions Secrets

Guide the user through setting up required secrets:

| Secret | Used By | How to Get |
|---|---|---|
| `STAGING_HOST` | SSH deploy | Server IP or hostname |
| `STAGING_USER` | SSH deploy | SSH username (e.g., `deploy`) |
| `STAGING_SSH_KEY` | SSH deploy | `ssh-keygen -t ed25519 -C "github-actions"` |
| `PRODUCTION_HOST` | SSH deploy | Server IP or hostname |
| `PRODUCTION_USER` | SSH deploy | SSH username |
| `PRODUCTION_SSH_KEY` | SSH deploy | Separate key from staging |
| `SLACK_WEBHOOK` | Notifications | Slack Incoming Webhook URL |
| `TELEGRAM_TOKEN` | Notifications | BotFather token |
| `TELEGRAM_TO` | Notifications | Chat ID |

### SSH Key Setup

Walk the user through:

1. **Generate a deploy key** (on local machine):
   ```bash
   ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/gh_deploy_key -N ""
   ```

2. **Add public key to server**:
   ```bash
   ssh-copy-id -i ~/.ssh/gh_deploy_key.pub deploy@your-server
   ```

3. **Add private key to GitHub**:
   - Go to repo Settings -> Secrets and variables -> Actions
   - New repository secret: name `STAGING_SSH_KEY`, paste private key content

### Environment-Specific Secrets

Recommend using GitHub Environments for secret scoping:

```
Repository Secrets (shared):
  - SLACK_WEBHOOK

Staging Environment Secrets:
  - STAGING_HOST
  - STAGING_USER
  - STAGING_SSH_KEY

Production Environment Secrets:
  - PRODUCTION_HOST
  - PRODUCTION_USER
  - PRODUCTION_SSH_KEY
```

### .env File Management

For application secrets on the server:

| Approach | When to Use |
|---|---|
| `.env` file on server | Simple VPS deployments, file persists across deploys |
| GitHub Secrets -> `.env` | Generate `.env` during CI, inject into container |
| Vault (HashiCorp) | Enterprise, multi-service, strict compliance |
| AWS SSM / GCP Secret Manager | Cloud-native deployments |

**Generate .env from GitHub Secrets** (for Docker deployments):

```yaml
- name: Create .env file
  run: |
    cat <<EOF > .env
    APP_NAME="${{ secrets.APP_NAME }}"
    APP_ENV=production
    APP_KEY="${{ secrets.APP_KEY }}"
    APP_URL="${{ secrets.APP_URL }}"
    DB_HOST="${{ secrets.DB_HOST }}"
    DB_DATABASE="${{ secrets.DB_DATABASE }}"
    DB_USERNAME="${{ secrets.DB_USERNAME }}"
    DB_PASSWORD="${{ secrets.DB_PASSWORD }}"
    REDIS_HOST="${{ secrets.REDIS_HOST }}"
    MAIL_MAILER="${{ secrets.MAIL_MAILER }}"
    EOF
```

Never commit `.env` files. Always verify `.gitignore` includes `.env*`.

---

## Workflow Architecture

The recommended pipeline architecture builds on Kickoff's existing CI:

```
Push to develop          Push to main            Push tag v*
      │                       │                       │
      ▼                       ▼                       ▼
  ┌────────┐             ┌────────┐             ┌────────┐
  │   CI   │             │   CI   │             │   CI   │
  │ (Pint, │             │ (Pint, │             │ (Pint, │
  │PHPStan,│             │PHPStan,│             │PHPStan,│
  │Rector, │             │Rector, │             │Rector, │
  │ Pest)  │             │ Pest)  │             │ Pest)  │
  └───┬────┘             └───┬────┘             └───┬────┘
      │                      │                      │
      ▼                      ▼                      ▼
  ┌────────┐           ┌──────────┐          ┌──────────┐
  │ Deploy │           │  Deploy  │          │  Docker  │
  │Staging │           │Production│          │Build+Push│
  │via SSH │           │ via SSH  │          │to Registry│
  └───┬────┘           └────┬─────┘          └──────────┘
      │                     │
      ▼                     ▼
  ┌────────┐           ┌────────┐
  │ Notify │           │ Notify │
  │if fail │           │if fail │
  └────────┘           └────────┘
```

---

## Reference Files

| File | Read When |
|---|---|
| `references/github-actions-templates.md` | Generating or extending CI/CD workflows, adding matrix testing, caching, notifications |
| `references/docker-laravel.md` | Creating Dockerfile, docker-compose.yml, .dockerignore for Laravel |
| `references/kickoff-bin-scripts.md` | Integrating /bin deploy, backup, setup scripts with GitHub Actions CD |
