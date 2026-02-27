# GitHub Actions Workflow Templates

Reusable workflow templates for Laravel CI/CD pipelines. Read this file when generating
or extending GitHub Actions workflows.

---

## CI Workflow — Lint, Test, Analyse

The baseline CI workflow that Kickoff provides. Extend this, do not replace it.

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite
          coverage: none

      - name: Install dependencies
        run: composer install --prefer-dist --no-interaction --no-progress

      - name: Check code style
        run: vendor/bin/pint --test

  analyse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite
          coverage: none

      - name: Install dependencies
        run: composer install --prefer-dist --no-interaction --no-progress

      - name: Run PHPStan
        run: vendor/bin/phpstan analyse --memory-limit=512M

      - name: Run Rector (dry-run)
        run: vendor/bin/rector --dry-run

  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ALLOW_EMPTY_PASSWORD: yes
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, mysql
          coverage: xdebug

      - name: Install dependencies
        run: composer install --prefer-dist --no-interaction --no-progress

      - name: Copy environment
        run: cp .env.ci .env

      - name: Generate key
        run: php artisan key:generate

      - name: Run tests
        run: php artisan test --coverage --min=80
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: testing
          DB_USERNAME: root
```

---

## CD Workflow — Deploy Staging

Triggers after CI passes on the `develop` branch.

```yaml
name: Deploy Staging

on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [develop]

concurrency:
  group: deploy-staging
  cancel-in-progress: false

jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to staging via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          port: ${{ secrets.STAGING_SSH_PORT || 22 }}
          script: |
            cd /var/www/staging
            bash bin/backup.sh
            bash bin/deploy.sh
          script_stop: true
          timeout: 120s

      - name: Verify deployment
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            curl -sf http://localhost/api/health || exit 1
```

---

## CD Workflow — Deploy Production

Triggers after CI passes on `main`. Uses environment protection rules requiring approval.

```yaml
name: Deploy Production

on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]

concurrency:
  group: deploy-production
  cancel-in-progress: false

jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to production via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USER }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          port: ${{ secrets.PRODUCTION_SSH_PORT || 22 }}
          script: |
            cd /var/www/production
            bash bin/backup.sh
            bash bin/deploy.sh
          script_stop: true
          timeout: 180s

      - name: Verify deployment
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USER }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          script: |
            curl -sf https://your-app.com/api/health || exit 1

      - name: Notify success
        if: success()
        uses: slackapi/slack-github-action@v2
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK }}
          webhook-type: incoming-webhook
          payload: |
            {
              "text": "Production deployed successfully for ${{ github.repository }}\nCommit: ${{ github.sha }}\nBy: ${{ github.actor }}"
            }
```

---

## Docker Build + Push Workflow

Builds and pushes Docker images on tagged releases.

```yaml
name: Docker Build & Push

on:
  push:
    tags:
      - 'v*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  ci:
    uses: ./.github/workflows/ci.yml

  build-and-push:
    needs: ci
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            APP_ENV=production
```

---

## Notification Workflow

Reusable notification job for failure alerts.

```yaml
# Add as a job in any workflow
notify-failure:
  needs: [deploy]  # adjust to your job names
  if: failure()
  runs-on: ubuntu-latest
  steps:
    # Slack notification
    - name: Notify Slack
      if: ${{ secrets.SLACK_WEBHOOK != '' }}
      uses: slackapi/slack-github-action@v2
      with:
        webhook: ${{ secrets.SLACK_WEBHOOK }}
        webhook-type: incoming-webhook
        payload: |
          {
            "blocks": [
              {
                "type": "header",
                "text": {
                  "type": "plain_text",
                  "text": "Deployment Failed"
                }
              },
              {
                "type": "section",
                "fields": [
                  { "type": "mrkdwn", "text": "*Repository:*\n${{ github.repository }}" },
                  { "type": "mrkdwn", "text": "*Branch:*\n${{ github.ref_name }}" },
                  { "type": "mrkdwn", "text": "*Commit:*\n${{ github.sha }}" },
                  { "type": "mrkdwn", "text": "*Actor:*\n${{ github.actor }}" }
                ]
              },
              {
                "type": "actions",
                "elements": [
                  {
                    "type": "button",
                    "text": { "type": "plain_text", "text": "View Run" },
                    "url": "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
                  }
                ]
              }
            ]
          }

    # Telegram notification
    - name: Notify Telegram
      if: ${{ secrets.TELEGRAM_TOKEN != '' }}
      uses: appleboy/telegram-action@master
      with:
        to: ${{ secrets.TELEGRAM_TO }}
        token: ${{ secrets.TELEGRAM_TOKEN }}
        format: markdown
        message: |
          *Deployment Failed*
          Repository: `${{ github.repository }}`
          Branch: `${{ github.ref_name }}`
          Commit: `${{ github.sha }}`
          [View Run](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
```

---

## Matrix Testing

For testing across multiple PHP and Laravel versions:

```yaml
test:
  runs-on: ubuntu-latest
  strategy:
    fail-fast: false
    matrix:
      php: ['8.2', '8.3', '8.4']
      laravel: ['11.*', '12.*']
      exclude:
        - php: '8.2'
          laravel: '12.*'

  name: PHP ${{ matrix.php }} / Laravel ${{ matrix.laravel }}

  steps:
    - uses: actions/checkout@v4

    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: ${{ matrix.php }}
        extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite
        coverage: none

    - name: Install dependencies
      run: |
        composer require "laravel/framework:${{ matrix.laravel }}" --no-interaction --no-update
        composer update --prefer-dist --no-interaction --no-progress

    - name: Run tests
      run: php artisan test
```

---

## Caching Strategies

### Composer Cache

```yaml
- name: Get Composer cache directory
  id: composer-cache
  run: echo "dir=$(composer config cache-files-dir)" >> $GITHUB_OUTPUT

- name: Cache Composer dependencies
  uses: actions/cache@v4
  with:
    path: ${{ steps.composer-cache.outputs.dir }}
    key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
    restore-keys: ${{ runner.os }}-composer-
```

### NPM Cache

```yaml
- name: Cache npm dependencies
  uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
    restore-keys: ${{ runner.os }}-npm-
```

### Docker Layer Cache

```yaml
- name: Build and push with cache
  uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Combined Workflow with All Caching

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite
          coverage: none

      - name: Get Composer cache directory
        id: composer-cache
        run: echo "dir=$(composer config cache-files-dir)" >> $GITHUB_OUTPUT

      - name: Cache Composer
        uses: actions/cache@v4
        with:
          path: ${{ steps.composer-cache.outputs.dir }}
          key: ${{ runner.os }}-composer-${{ hashFiles('**/composer.lock') }}
          restore-keys: ${{ runner.os }}-composer-

      - name: Install PHP dependencies
        run: composer install --prefer-dist --no-interaction --no-progress

      - name: Cache npm
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
          restore-keys: ${{ runner.os }}-npm-

      - name: Install Node dependencies
        run: npm ci

      - name: Build assets
        run: npm run build

      - name: Run Pint
        run: vendor/bin/pint --test

      - name: Run PHPStan
        run: vendor/bin/phpstan analyse --memory-limit=512M

      - name: Run tests
        run: php artisan test
```

---

## Reusable Workflow Pattern

Split CI into a reusable workflow that CD workflows can call:

### `.github/workflows/ci.yml` (reusable)

```yaml
name: CI

on:
  workflow_call:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
      - run: composer install --prefer-dist --no-interaction
      - run: vendor/bin/pint --test

  analyse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
      - run: composer install --prefer-dist --no-interaction
      - run: vendor/bin/phpstan analyse --memory-limit=512M
      - run: vendor/bin/rector --dry-run

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
      - run: composer install --prefer-dist --no-interaction
      - run: php artisan test
```

### `.github/workflows/deploy.yml` (calls CI)

```yaml
name: Deploy

on:
  push:
    branches: [main, develop]

jobs:
  ci:
    uses: ./.github/workflows/ci.yml

  deploy:
    needs: ci
    runs-on: ubuntu-latest
    # ... deployment steps
```
