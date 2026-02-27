# Docker Templates for Laravel

Complete Dockerfile and docker-compose.yml templates for Laravel applications.
Read this file when generating Docker configurations for development or production.

---

## Development Dockerfile

For local development. Includes Xdebug, Node.js for asset compilation, and all
PHP extensions needed by a typical Laravel application.

```dockerfile
# Dockerfile.dev
FROM php:8.3-fpm

ARG NODE_VERSION=20
ARG WWWGROUP=1000
ARG WWWUSER=1000

WORKDIR /var/www/html

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    zip \
    unzip \
    supervisor \
    sqlite3 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache \
    && pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user
RUN groupadd --force -g $WWWGROUP sail \
    && useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u $WWWUSER sail

# Xdebug config
RUN echo "xdebug.mode=develop,debug,coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# PHP config
RUN echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/docker-php-uploads.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/docker-php-uploads.ini \
    && echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/docker-php-memory.ini

USER sail

EXPOSE 8000 5173

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
```

### Comparison with Laravel Sail

| Feature | Sail | Custom Dockerfile.dev |
|---|---|---|
| Pre-configured | Yes, via `sail:install` | Manual setup |
| Multi-database support | Yes (MySQL, Postgres, MariaDB) | Configure as needed |
| Xdebug | Optional via `SAIL_XDEBUG_MODE` | Always included |
| Node.js | Included | Included |
| Customisability | Limited (publish Dockerfiles) | Full control |
| Performance | Good | Same |
| Recommended for | Quick start, standard apps | Custom extensions, specific versions |

If the user already uses Sail, recommend sticking with it for development and only
creating a custom Dockerfile for production.

---

## Production Dockerfile (Multi-Stage)

Optimised for small image size, security, and performance. Uses multi-stage build
to separate build tools from the final runtime image.

```dockerfile
# Dockerfile
# ============================================================
# Stage 1: Composer dependencies
# ============================================================
FROM composer:2 AS composer-deps

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --no-interaction

COPY . .
RUN composer dump-autoload --optimize --classmap-authoritative

# ============================================================
# Stage 2: Node.js asset build
# ============================================================
FROM node:20-alpine AS node-build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --production=false

COPY resources/ resources/
COPY vite.config.js tailwind.config.js postcss.config.js ./
RUN npm run build

# ============================================================
# Stage 3: Final production image
# ============================================================
FROM php:8.3-fpm-alpine AS production

WORKDIR /var/www/html

# System dependencies (minimal for production)
RUN apk add --no-cache \
    libpng \
    libjpeg-turbo \
    freetype \
    libzip \
    libpq \
    icu-libs \
    linux-headers \
    && apk add --no-cache --virtual .build-deps \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        postgresql-dev \
        icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps \
    && rm -rf /tmp/pear

# OPcache configuration for production
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption=256" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=64" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=32531" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.save_comments=1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.jit=1255" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.jit_buffer_size=128M" >> /usr/local/etc/php/conf.d/opcache.ini

# PHP production config
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/docker-php-memory.ini \
    && echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/docker-php-uploads.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/docker-php-uploads.ini \
    && echo "expose_php = Off" >> /usr/local/etc/php/conf.d/docker-php-security.ini

# Create non-root user
RUN addgroup -g 1000 -S www && adduser -u 1000 -S www -G www

# Copy application
COPY --from=composer-deps /app/vendor vendor
COPY --from=node-build /app/public/build public/build
COPY . .

# Set permissions
RUN chown -R www:www storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

USER www

EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD php-fpm-healthcheck || exit 1

CMD ["php-fpm"]
```

---

## docker-compose.yml — Development

Full development stack with app, database, Redis, Meilisearch, and Mailpit.

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "${APP_PORT:-8000}:8000"
      - "${VITE_PORT:-5173}:5173"
    volumes:
      - .:/var/www/html
      - /var/www/html/vendor
      - /var/www/html/node_modules
    environment:
      - APP_ENV=local
      - APP_DEBUG=true
      - DB_CONNECTION=${DB_CONNECTION:-mysql}
      - DB_HOST=${DB_CONNECTION:-mysql}
      - DB_PORT=${DB_PORT:-3306}
      - DB_DATABASE=${DB_DATABASE:-laravel}
      - DB_USERNAME=${DB_USERNAME:-sail}
      - DB_PASSWORD=${DB_PASSWORD:-password}
      - REDIS_HOST=redis
      - MAIL_MAILER=smtp
      - MAIL_HOST=mailpit
      - MAIL_PORT=1025
      - SCOUT_DRIVER=meilisearch
      - MEILISEARCH_HOST=http://meilisearch:7700
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - laravel

  mysql:
    image: mysql:8.0
    ports:
      - "${DB_PORT:-3306}:3306"
    environment:
      MYSQL_ROOT_PASSWORD: "${DB_PASSWORD:-password}"
      MYSQL_DATABASE: "${DB_DATABASE:-laravel}"
      MYSQL_USER: "${DB_USERNAME:-sail}"
      MYSQL_PASSWORD: "${DB_PASSWORD:-password}"
    volumes:
      - mysql-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-p${DB_PASSWORD:-password}"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - laravel

  # Alternative: PostgreSQL (uncomment and remove mysql service)
  # postgres:
  #   image: postgres:16-alpine
  #   ports:
  #     - "${DB_PORT:-5432}:5432"
  #   environment:
  #     POSTGRES_DB: "${DB_DATABASE:-laravel}"
  #     POSTGRES_USER: "${DB_USERNAME:-sail}"
  #     POSTGRES_PASSWORD: "${DB_PASSWORD:-password}"
  #   volumes:
  #     - postgres-data:/var/lib/postgresql/data
  #   healthcheck:
  #     test: ["CMD-SHELL", "pg_isready -U ${DB_USERNAME:-sail}"]
  #     interval: 10s
  #     timeout: 5s
  #     retries: 3
  #   networks:
  #     - laravel

  redis:
    image: redis:7-alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - laravel

  meilisearch:
    image: getmeili/meilisearch:latest
    ports:
      - "${MEILISEARCH_PORT:-7700}:7700"
    environment:
      MEILI_MASTER_KEY: "${MEILISEARCH_KEY:-masterKey}"
      MEILI_NO_ANALYTICS: true
    volumes:
      - meilisearch-data:/meili_data
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:7700/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - laravel

  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "${MAILPIT_PORT:-8025}:8025"
      - "${MAILPIT_SMTP_PORT:-1025}:1025"
    networks:
      - laravel

volumes:
  mysql-data:
  # postgres-data:
  redis-data:
  meilisearch-data:

networks:
  laravel:
    driver: bridge
```

---

## docker-compose.prod.yml — Production

Production stack with Nginx reverse proxy. Database is assumed external (managed service).

```yaml
# docker-compose.prod.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    volumes:
      - app-storage:/var/www/html/storage
    env_file:
      - .env
    healthcheck:
      test: ["CMD-SHELL", "php-fpm-healthcheck || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
    networks:
      - laravel

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./docker/nginx/ssl:/etc/nginx/ssl:ro
      - app-storage:/var/www/html/storage:ro
    depends_on:
      app:
        condition: service_healthy
    networks:
      - laravel

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis-data:/data
    command: redis-server --requirepass ${REDIS_PASSWORD}
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - laravel

  queue-worker:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    command: php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
    env_file:
      - .env
    depends_on:
      app:
        condition: service_healthy
    networks:
      - laravel

  scheduler:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    command: >
      sh -c "while true; do php artisan schedule:run --verbose --no-interaction; sleep 60; done"
    env_file:
      - .env
    depends_on:
      app:
        condition: service_healthy
    networks:
      - laravel

volumes:
  app-storage:
  redis-data:

networks:
  laravel:
    driver: bridge
```

---

## Nginx Configuration

Production Nginx config for the reverse proxy.

```nginx
# docker/nginx/default.conf
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php;

    charset utf-8;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_types
        application/json
        application/javascript
        application/xml
        text/css
        text/plain
        text/xml;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Static assets caching
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## .dockerignore

Exclude unnecessary files from Docker build context.

```
# .dockerignore
.git
.gitignore
.github
.env
.env.*
!.env.example

# Dependencies (installed in container)
node_modules
vendor

# Build artifacts
public/build
public/hot

# IDE
.idea
.vscode
*.swp
*.swo

# Testing
tests
phpunit.xml
.phpunit.cache
coverage

# Development tools
docker-compose.yml
docker-compose.override.yml
Dockerfile.dev

# Documentation
docs
*.md
!README.md

# OS files
.DS_Store
Thumbs.db

# CI
.github

# Storage (mounted as volume in production)
storage/logs/*
storage/framework/cache/*
storage/framework/sessions/*
storage/framework/views/*
```

---

## Queue Worker Supervisor Config

For production containers running queue workers.

```ini
; docker/supervisor/queue-worker.conf
[program:queue-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/html/storage/logs/queue-worker.log
stopwaitsecs=3600
```
