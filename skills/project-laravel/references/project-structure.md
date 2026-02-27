# Project Structure

## Directory Layout

A Kickoff-based Laravel project follows this structure:

```
project-root/
├── app/
│   ├── Actions/              # Business logic classes (Builder pattern)
│   ├── Concerns/             # Traits (must be traits)
│   ├── Contracts/            # Interfaces (must be interfaces)
│   ├── Enums/                # Backed enums (implement Enum contract)
│   ├── Events/               # Domain events
│   ├── Http/
│   │   ├── Controllers/      # Resource controllers (suffix Controller)
│   │   ├── Middleware/        # HTTP middleware
│   │   ├── Requests/         # Form request validation (suffix Request)
│   │   └── Resources/        # API resources (suffix Resource)
│   ├── Jobs/                 # Queued jobs
│   ├── Listeners/            # Event listeners
│   ├── Models/               # Eloquent models (extend Base)
│   ├── Notifications/        # Notification classes
│   ├── Policies/             # Authorisation policies (suffix Policy)
│   └── Providers/            # Service providers
├── bin/
│   ├── deploy.sh             # Deployment script
│   ├── backup.sh             # Database backup script
│   └── setup.sh              # Fresh environment setup
├── config/
│   ├── access-control.php    # Roles and permissions definition
│   └── ...                   # Standard Laravel config
├── database/
│   ├── factories/            # Model factories
│   ├── migrations/           # Database migrations (UUID + timestamps)
│   └── seeders/              # Database seeders (factory-based)
├── resources/
│   ├── css/
│   │   └── app.css           # TailwindCSS v4 entry point
│   ├── js/
│   │   └── app.js            # Alpine + Vite entry point
│   └── views/
│       ├── components/       # Blade/Flux components
│       ├── layouts/          # Layout templates
│       └── livewire/         # Livewire component views
├── routes/
│   ├── web.php               # Web bootstrap (loads routes/web/*.php)
│   ├── api.php               # API bootstrap (loads routes/api/*.php)
│   ├── web/                  # Modular web route files
│   └── api/                  # Modular API route files
├── support/
│   └── helpers.php           # Helper functions (function_exists guarded)
├── tests/
│   ├── Architecture/         # Pest architecture tests
│   ├── Feature/              # Feature / integration tests
│   └── Unit/                 # Unit tests
├── docker-compose.yml        # Local development services
├── Dockerfile                # Production container
├── phpstan.neon              # PHPStan/Larastan config
├── pint.json                 # Laravel Pint config
├── rector.php                # Rector config
└── vite.config.js            # Vite build config
```

## Config Files

### access-control.php

Defines all roles and permissions for Spatie Permission (see `access-control.md`).

### phpstan.neon

```neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app/
    level: 8
```

### pint.json

```json
{
    "preset": "laravel"
}
```

### rector.php

```php
<?php

use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/app',
    ])
    ->withPhpSets(php82: true)
    ->withPreparedSets(
        deadCode: true,
        codeQuality: true,
        typeDeclarations: true,
    );
```

## Docker Services

The `docker-compose.yml` provides:

| Service | Port | Purpose |
|---|---|---|
| MySQL 8 | 3306 | Primary database |
| Redis | 6379 | Cache, queues, sessions |
| Mailpit | 8025 | Local email testing |
| Meilisearch | 7700 | Full-text search engine |
| MinIO | 9000 | S3-compatible object storage |

## Shell Scripts (bin/)

### deploy.sh

```bash
#!/bin/bash
php artisan down
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan up
```

### setup.sh

```bash
#!/bin/bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
npm install && npm run build
```

## Stubs

Kickoff may include custom stubs in `stubs/` that override Laravel's default generators. When present, `php artisan make:model` etc. will use these stubs. Always check for custom stubs before generating code.

## DO / DON'T

- ✅ DO follow the directory layout exactly
- ✅ DO put business logic in `app/Actions/`
- ✅ DO put traits in `app/Concerns/`
- ✅ DO put interfaces in `app/Contracts/`
- ✅ DO put helpers in `support/`
- ✅ DO use `bin/` scripts for operational tasks
- ❌ DON'T create `app/Helpers/` — use `support/`
- ❌ DON'T create `app/Traits/` — use `app/Concerns/`
- ❌ DON'T create `app/Interfaces/` — use `app/Contracts/`
- ❌ DON'T put business logic in controllers or models
