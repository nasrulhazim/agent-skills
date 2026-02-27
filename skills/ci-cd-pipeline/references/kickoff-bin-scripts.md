# Kickoff /bin Scripts Integration

How to leverage Laravel Kickoff's existing /bin scripts in GitHub Actions CD workflows.
Read this file when integrating deployment automation with Kickoff's script conventions.

---

## Kickoff Script Patterns

Laravel Kickoff ships with shell scripts in the `bin/` directory. These are designed
to be run both manually via SSH and automatically from CI/CD pipelines.

### bin/deploy.sh

Standard deployment script that Kickoff provides:

```bash
#!/bin/bash
set -e

# Pull latest code
git pull origin "${BRANCH:-main}"

# Install PHP dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# Install and build frontend assets
npm ci
npm run build

# Run migrations
php artisan migrate --force

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan icons:cache

# Restart queue workers gracefully
php artisan queue:restart

echo "Deploy complete."
```

### bin/backup.sh

Pre-deployment backup script:

```bash
#!/bin/bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups/app}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="${DB_DATABASE:-laravel}"

mkdir -p "$BACKUP_DIR"

# Database backup
echo "==> Backing up database..."
mysqldump -u "${DB_USERNAME}" -p"${DB_PASSWORD}" "$DB_NAME" \
    | gzip > "$BACKUP_DIR/db_${TIMESTAMP}.sql.gz"

# File backup (storage directory)
echo "==> Backing up storage..."
tar -czf "$BACKUP_DIR/storage_${TIMESTAMP}.tar.gz" storage/app

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t db_*.sql.gz | tail -n +11 | xargs -r rm
ls -t storage_*.tar.gz | tail -n +11 | xargs -r rm

echo "==> Backup complete: $TIMESTAMP"
```

### bin/setup.sh

First-time server setup script:

```bash
#!/bin/bash
set -e

echo "==> Setting up application..."

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

# Install dependencies
composer install --no-dev --optimize-autoloader --no-interaction
npm ci
npm run build

# Set permissions
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Run migrations and seed
php artisan migrate --force
php artisan db:seed --force

# Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Storage link
php artisan storage:link

echo "==> Setup complete!"
```

---

## Integration with GitHub Actions CD

### Pattern 1: Direct SSH Execution

The simplest pattern — SSH into the server and run bin scripts directly.

```yaml
deploy:
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Deploy via SSH
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USER }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /var/www/app
          bash bin/backup.sh
          bash bin/deploy.sh
        script_stop: true
        timeout: 180s
```

### Pattern 2: SSH with Branch Specification

Pass the branch to deploy.sh so it knows which branch to pull.

```yaml
deploy-staging:
  runs-on: ubuntu-latest
  environment: staging
  steps:
    - name: Deploy staging
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.STAGING_HOST }}
        username: ${{ secrets.STAGING_USER }}
        key: ${{ secrets.STAGING_SSH_KEY }}
        script: |
          cd /var/www/staging
          BRANCH=develop bash bin/backup.sh
          BRANCH=develop bash bin/deploy.sh
```

### Pattern 3: SSH with Pre/Post Hooks

Wrap bin scripts with additional checks.

```yaml
deploy-production:
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Pre-deploy checks
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd /var/www/production

          # Check disk space (need at least 1GB free)
          FREE_SPACE=$(df -BG /var/www | tail -1 | awk '{print $4}' | tr -d 'G')
          if [ "$FREE_SPACE" -lt 1 ]; then
            echo "ERROR: Less than 1GB free disk space"
            exit 1
          fi

          # Check database connectivity
          php artisan db:monitor --max=100 || exit 1

    - name: Backup and deploy
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd /var/www/production
          bash bin/backup.sh
          php artisan down --retry=60
          bash bin/deploy.sh
          php artisan up

    - name: Post-deploy verification
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          # Health check
          curl -sf http://localhost/api/health || exit 1

          # Check queue is processing
          php artisan queue:monitor redis --max=1000 || true

          # Check latest migration ran
          cd /var/www/production
          php artisan migrate:status | tail -5
```

### Pattern 4: Docker Deployment with bin Scripts

Use bin scripts inside Docker containers for consistency.

```yaml
deploy-docker:
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Deploy Docker containers
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USER }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /var/www/app

          # Pull latest image
          docker pull ghcr.io/${{ github.repository }}:latest

          # Backup using bin script inside current container
          docker compose exec -T app bash bin/backup.sh

          # Update and restart
          docker compose -f docker-compose.prod.yml up -d --remove-orphans

          # Run migrations in new container
          docker compose exec -T app php artisan migrate --force

          # Cache in new container
          docker compose exec -T app php artisan config:cache
          docker compose exec -T app php artisan route:cache
          docker compose exec -T app php artisan view:cache

          # Health check
          sleep 5
          curl -sf http://localhost/api/health || exit 1
```

---

## VPS Deployment via SSH

### Server Setup Checklist

Before the first automated deployment, run these on the server:

1. **Create deploy user:**
   ```bash
   adduser deploy
   usermod -aG www-data deploy
   ```

2. **Set up SSH key authentication:**
   ```bash
   mkdir -p /home/deploy/.ssh
   # Add the GitHub Actions public key to authorized_keys
   echo "ssh-ed25519 AAAA... github-actions-deploy" >> /home/deploy/.ssh/authorized_keys
   chmod 700 /home/deploy/.ssh
   chmod 600 /home/deploy/.ssh/authorized_keys
   chown -R deploy:deploy /home/deploy/.ssh
   ```

3. **Set application directory permissions:**
   ```bash
   mkdir -p /var/www/production
   chown -R deploy:www-data /var/www/production
   chmod -R 775 /var/www/production
   ```

4. **Allow deploy user to restart services without password:**
   ```bash
   # /etc/sudoers.d/deploy
   deploy ALL=(ALL) NOPASSWD: /usr/sbin/service php8.3-fpm restart
   deploy ALL=(ALL) NOPASSWD: /usr/sbin/service nginx reload
   deploy ALL=(ALL) NOPASSWD: /usr/bin/supervisorctl restart all
   ```

5. **Clone the repository initially:**
   ```bash
   cd /var/www/production
   git clone git@github.com:org/repo.git .
   bash bin/setup.sh
   ```

6. **Set up cron for Laravel scheduler:**
   ```bash
   # crontab -u deploy -e
   * * * * * cd /var/www/production && php artisan schedule:run >> /dev/null 2>&1
   ```

7. **Set up Supervisor for queue workers:**
   ```ini
   ; /etc/supervisor/conf.d/laravel-worker.conf
   [program:laravel-worker]
   process_name=%(program_name)s_%(process_num)02d
   command=php /var/www/production/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
   autostart=true
   autorestart=true
   stopasgroup=true
   killasgroup=true
   user=deploy
   numprocs=2
   redirect_stderr=true
   stdout_logfile=/var/www/production/storage/logs/worker.log
   stopwaitsecs=3600
   ```

### Extending bin/deploy.sh for CD

Add these enhancements to deploy.sh when used with GitHub Actions:

```bash
#!/bin/bash
set -e

APP_DIR="${APP_DIR:-/var/www/app}"
BRANCH="${BRANCH:-main}"
LOG_FILE="$APP_DIR/storage/logs/deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

cd "$APP_DIR"

log "Starting deployment of branch: $BRANCH"

# Maintenance mode
php artisan down --retry=60 --secret="bypass-token-here"
log "Maintenance mode enabled"

# Pull latest
git fetch origin "$BRANCH"
git reset --hard "origin/$BRANCH"
log "Pulled latest from $BRANCH"

# Install PHP dependencies
composer install --no-dev --optimize-autoloader --no-interaction
log "Composer dependencies installed"

# Install and build frontend
npm ci
npm run build
log "Frontend assets built"

# Migrate
php artisan migrate --force
log "Migrations complete"

# Cache everything
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan icons:cache
log "Caches warmed"

# Restart services
php artisan queue:restart
sudo service php8.3-fpm restart
log "Services restarted"

# Clear maintenance mode
php artisan up
log "Maintenance mode disabled"

log "Deployment complete!"
```

---

## Rollback Strategy

Add a rollback script that complements deploy.sh:

### bin/rollback.sh

```bash
#!/bin/bash
set -e

APP_DIR="${APP_DIR:-/var/www/app}"
cd "$APP_DIR"

# Get the previous commit
CURRENT=$(git rev-parse HEAD)
PREVIOUS=$(git rev-parse HEAD~1)

echo "==> Current:  $CURRENT"
echo "==> Rolling back to: $PREVIOUS"

php artisan down --retry=60

git checkout "$PREVIOUS"

composer install --no-dev --optimize-autoloader --no-interaction
npm ci && npm run build

php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:restart

php artisan up

echo "==> Rollback complete to $PREVIOUS"
```

### Trigger Rollback from GitHub Actions

```yaml
rollback:
  runs-on: ubuntu-latest
  environment: production
  steps:
    - name: Rollback
      uses: appleboy/ssh-action@v1
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd /var/www/production
          bash bin/rollback.sh
```

---

## Environment-Specific Variables

Configure bin scripts to behave differently per environment:

```bash
# In deploy.sh, detect environment
if [ "$APP_ENV" = "production" ]; then
    COMPOSER_FLAGS="--no-dev --optimize-autoloader"
    ARTISAN_FLAGS="--force"
else
    COMPOSER_FLAGS=""
    ARTISAN_FLAGS=""
fi

composer install $COMPOSER_FLAGS --no-interaction
php artisan migrate $ARTISAN_FLAGS
```

Pass environment from GitHub Actions:

```yaml
- name: Deploy
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USER }}
    key: ${{ secrets.SSH_KEY }}
    envs: APP_ENV,BRANCH
    script: |
      cd /var/www/${{ github.event.inputs.environment || 'staging' }}
      APP_ENV=$APP_ENV BRANCH=$BRANCH bash bin/deploy.sh
  env:
    APP_ENV: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    BRANCH: ${{ github.ref_name }}
```
