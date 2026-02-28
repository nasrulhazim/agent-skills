---
name: package-dev
metadata:
  compatible_agents: [claude-code]
  tags: [laravel, php, package, sdk, composer, packagist]
description: >
  Complete Laravel package development skill — scaffolds package directory structure with src,
  config, migrations, tests, README, and CHANGELOG; generates service providers, facades, config
  publishing patterns; sets up Pest test suites with Orchestra Testbench integration; manages
  release workflows including version bumps, changelog updates, git tags, and Packagist publishing;
  generates professional README files with badges, installation instructions, usage examples,
  testing commands, and changelog sections. Use this skill whenever the user asks to create a
  Laravel package, scaffold a PHP package, set up a Composer library, generate a service provider,
  add facade support, configure Testbench tests, prepare a package release, write a package README,
  publish to Packagist, or manage package versioning — including: "create a new Laravel package",
  "scaffold package structure", "set up package tests", "prepare a release", "generate package
  README", "add a facade to my package", "configure Testbench", "publish my package",
  "buat package Laravel baru", "scaffold struktur package", "sediakan test untuk package",
  "sediakan release", "jana README package", "tambah facade", "konfigurasi Testbench",
  "terbitkan package ke Packagist", or "uruskan versioning package".
---

# Package Development Skill

Scaffold, test, document, and release production-quality Laravel/PHP packages — from initial
directory structure through Packagist publishing. Follows Laravel ecosystem conventions and
integrates with Orchestra Testbench for package testing.

## Command Reference

| Command | Description |
|---|---|
| `/package scaffold` | Generate complete package directory structure with all boilerplate files |
| `/package test` | Set up Pest test suite with Orchestra Testbench integration |
| `/package release` | Run release checklist: version bump, changelog, git tag, Packagist |
| `/package readme` | Generate professional README with badges, installation, usage, and testing sections |

---

## 1. `/package scaffold` — Generate Package Structure

### Step 1: Gather Package Information

Ask the user for:

- **Vendor name** — always ask, default: `cleaniquecoders`
- **Package name** — kebab-case, all lowercase (e.g. `laravel-helper`, `profile`)
- **Package type** — Laravel package or pure PHP package
- **Package description** (one-liner for composer.json)
- **PHP minimum version** (default: `^8.4`)
- **Laravel version constraint** (default: `^12.0`, Laravel packages only)
- **Namespace** (default: derived from vendor/package, e.g. `CleaniqueCoders\Profile`)
- **Features to include** (config, migrations, views, routes, commands — pick applicable ones)

If the user already provided context, extract what you can and only ask for what is missing.

### Skeleton Templates

Use Spatie's skeleton templates to scaffold the package:

- **Laravel package**: Clone from [spatie/package-skeleton-laravel](https://github.com/spatie/package-skeleton-laravel)
- **PHP package**: Clone from [spatie/package-skeleton-php](https://github.com/spatie/package-skeleton-php)

After cloning, run the skeleton's configure script to replace placeholders with the actual vendor name, package name, namespace, and author details.

### Step 2: Generate Directory Structure

Create the following structure:

```
packages/vendor/package-name/
├── src/
│   ├── PackageNameServiceProvider.php
│   ├── Facades/
│   │   └── PackageName.php
│   ├── Actions/
│   ├── Concerns/
│   └── Contracts/
├── config/
│   └── package-name.php
├── database/
│   ├── factories/
│   └── migrations/
├── resources/
│   └── views/
├── routes/
│   └── web.php
├── tests/
│   ├── Pest.php
│   ├── TestCase.php
│   └── Feature/
├── stubs/
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── README.md
├── composer.json
└── phpunit.xml
```

Only include directories for features the user selected. Always include `src/`, `tests/`,
`composer.json`, `README.md`, `CHANGELOG.md`, and `LICENSE`.

### Step 3: Generate composer.json

Read `references/package-structure.md` for the full template. Key sections:

```json
{
    "name": "vendor/package-name",
    "description": "Package description here",
    "keywords": ["laravel", "php"],
    "license": "MIT",
    "require": {
        "php": "^8.4",
        "illuminate/support": "^12.0"
    },
    "require-dev": {
        "orchestra/testbench": "^10.0",
        "pestphp/pest": "^3.0",
        "pestphp/pest-plugin-laravel": "^3.0",
        "laravel/pint": "^1.0"
    },
    "autoload": {
        "psr-4": {
            "Vendor\\PackageName\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Vendor\\PackageName\\Tests\\": "tests/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "Vendor\\PackageName\\PackageNameServiceProvider"
            ],
            "aliases": {
                "PackageName": "Vendor\\PackageName\\Facades\\PackageName"
            }
        }
    },
    "config": {
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true
        }
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}
```

### Step 4: Generate ServiceProvider

Read `references/package-structure.md` for the full ServiceProvider patterns. The provider must:

- Extend `Illuminate\Support\ServiceProvider`
- Use `register()` for bindings and merging config
- Use `boot()` for publishing assets, loading routes, views, migrations, and commands
- Include conditional `if ($this->app->runningInConsole())` blocks for publishable assets
- Group publishes with tags: `{package-name}-config`, `{package-name}-migrations`, etc.

### Step 5: Generate Facade

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Facades;

use Illuminate\Support\Facades\Facade;

/**
 * @see \Vendor\PackageName\PackageName
 */
class PackageName extends Facade
{
    protected static function getFacadeAccessor(): string
    {
        return \Vendor\PackageName\PackageName::class;
    }
}
```

### Step 6: Generate Config File

```php
<?php

return [
    // Package configuration options
];
```

### Step 7: Generate Starter Files

Generate `.gitignore`, `LICENSE` (MIT), initial `CHANGELOG.md`, and `phpunit.xml`.

---

## 2. `/package test` — Pest + Orchestra Testbench Setup

### Step 1: Check Existing Test Setup

Scan the package for existing `tests/` directory and `phpunit.xml`. If they exist, extend
rather than overwrite.

### Step 2: Generate TestCase Base Class

Read `references/testbench-patterns.md` for the full Testbench TestCase patterns.

```php
<?php

declare(strict_types=1);

namespace Vendor\PackageName\Tests;

use Orchestra\Testbench\TestCase as Orchestra;
use Vendor\PackageName\PackageNameServiceProvider;

class TestCase extends Orchestra
{
    protected function setUp(): void
    {
        parent::setUp();
    }

    protected function getPackageProviders($app): array
    {
        return [
            PackageNameServiceProvider::class,
        ];
    }

    protected function getPackageAliases($app): array
    {
        return [
            'PackageName' => \Vendor\PackageName\Facades\PackageName::class,
        ];
    }

    protected function getEnvironmentSetUp($app): void
    {
        config()->set('database.default', 'testing');
        config()->set('database.connections.testing', [
            'driver' => 'sqlite',
            'database' => ':memory:',
            'prefix' => '',
        ]);
    }

    protected function defineDatabaseMigrations(): void
    {
        $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
    }
}
```

### Step 3: Generate Pest.php

```php
<?php

declare(strict_types=1);

use Vendor\PackageName\Tests\TestCase;

uses(TestCase::class)->in('Feature');
```

### Step 4: Generate Starter Tests

Generate tests based on what the package provides:

| Package Feature | Test File | Key Assertions |
|---|---|---|
| ServiceProvider | `tests/Feature/ServiceProviderTest.php` | Provider loads, bindings resolve, config merges |
| Config | `tests/Feature/ConfigTest.php` | Config file publishable, default values correct |
| Migrations | `tests/Feature/MigrationTest.php` | Tables created, columns match expectations |
| Commands | `tests/Feature/CommandTest.php` | Command registered, executes without error |
| Routes | `tests/Feature/RouteTest.php` | Routes registered, middleware applied, responses correct |
| Facade | `tests/Feature/FacadeTest.php` | Facade resolves, methods callable |

### Step 5: Generate phpunit.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
    bootstrap="vendor/autoload.php"
    colors="true"
>
    <testsuites>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>src</directory>
        </include>
    </source>
</phpunit>
```

---

## 3. `/package release` — Release Checklist

### Step 1: Pre-Release Validation

Run through these checks before releasing:

| Check | Command | Pass Condition |
|---|---|---|
| Tests pass | `composer test` or `./vendor/bin/pest` | Exit code 0, no failures |
| Code style | `./vendor/bin/pint --test` | No style violations |
| No uncommitted changes | `git status` | Clean working tree |
| README up to date | Manual review | Installation, usage, and changelog sections current |
| License file present | `ls LICENSE` | File exists |

### Step 2: Version Bump

Follow Semantic Versioning (SemVer):

| Change Type | Version Bump | Example |
|---|---|---|
| Bug fix, patch | PATCH | `1.0.0` -> `1.0.1` |
| New feature, backward-compatible | MINOR | `1.0.1` -> `1.1.0` |
| Breaking change | MAJOR | `1.1.0` -> `2.0.0` |

Update the version in `composer.json` if a `version` field exists (most packages rely on
git tags instead).

### Step 3: Update CHANGELOG.md

Follow Keep a Changelog format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.1.0] - 2026-02-27

### Added
- New feature X for handling Y
- Support for Laravel 12

### Changed
- Updated minimum PHP version to 8.2

### Fixed
- Resolved issue with config publishing (#42)

## [1.0.0] - 2026-01-15

### Added
- Initial release
- Service provider with config publishing
- Facade support
- Migration publishing

[Unreleased]: https://github.com/vendor/package/compare/1.1.0...HEAD
[1.1.0]: https://github.com/vendor/package/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/vendor/package/releases/tag/1.0.0
```

### Step 4: Commit and Tag

```bash
git add -A
git commit -m "chore: release 1.1.0"
git tag -a 1.1.0 -m "1.1.0"
git push origin main --tags
```

### Step 5: Packagist Publishing

- **First release:** Register at [packagist.org](https://packagist.org/packages/submit)
  with the GitHub repository URL
- **Subsequent releases:** Packagist auto-updates if the GitHub webhook is configured;
  otherwise run `curl -X POST https://packagist.org/api/update-package?username=USER&apiToken=TOKEN`
- Verify the release appears on Packagist within a few minutes

---

## 4. `/package readme` — README Generation

### Step 1: Scan Package

Read `composer.json`, `src/`, and `config/` to understand what the package provides.

### Step 2: Generate README Structure

```markdown
# Package Name

[![Latest Version on Packagist](https://img.shields.io/packagist/v/vendor/package-name.svg?style=flat-square)](https://packagist.org/packages/vendor/package-name)
[![GitHub Tests Action Status](https://img.shields.io/github/actions/workflow/status/vendor/package-name/run-tests.yml?branch=main&label=tests&style=flat-square)](https://github.com/vendor/package-name/actions?query=workflow%3Arun-tests+branch%3Amain)
[![Total Downloads](https://img.shields.io/packagist/dt/vendor/package-name.svg?style=flat-square)](https://packagist.org/packages/vendor/package-name)

Short description of the package — one or two sentences.

## Installation

You can install the package via Composer:

\```bash
composer require vendor/package-name
\```

You can publish the config file with:

\```bash
php artisan vendor:publish --tag="package-name-config"
\```

Optionally, you can publish the migrations with:

\```bash
php artisan vendor:publish --tag="package-name-migrations"
\```

## Usage

\```php
use Vendor\PackageName\Facades\PackageName;

// Example usage
$result = PackageName::doSomething();
\```

## Testing

\```bash
composer test
\```

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) for details.

## Security Vulnerabilities

Please review [our security policy](../../security/policy) on how to report security
vulnerabilities.

## Credits

- [Author Name](https://github.com/author)
- [All Contributors](../../contributors)

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.
```

### Step 3: Customise Sections

Based on the package scan:

| Package Feature | README Section to Add |
|---|---|
| Config file | "Configuration" section with key options documented |
| Migrations | "Database" section explaining tables created |
| Commands | "Commands" section listing artisan commands |
| Routes | "Routes" section with endpoint table |
| Views | "Views" section explaining publishable views |
| Events | "Events" section listing dispatched events |
| Middleware | "Middleware" section with registration instructions |

---

## 5. Anti-Patterns to Avoid

| Anti-Pattern | Correct Approach |
|---|---|
| Hardcoding Laravel version in ServiceProvider | Use `illuminate/*` packages with version ranges |
| Registering everything in `boot()` | Use `register()` for bindings, `boot()` for bootstrapping |
| Missing `declare(strict_types=1)` | Include in every PHP file |
| No publish tags | Always tag publishable assets: `{package}-config`, `{package}-migrations` |
| Monolithic ServiceProvider | Extract to separate concerns if provider exceeds 100 lines |
| Testing against real database | Always use SQLite `:memory:` via Testbench |
| Missing `extra.laravel` in composer.json | Required for auto-discovery to work |
| No `.gitignore` for `vendor/` and `composer.lock` | Packages must ignore `composer.lock` (apps keep it) |

---

## Reference Files

| File | Read When |
|---|---|
| `references/package-structure.md` | Scaffolding package structure, ServiceProvider, Facade, and composer.json patterns |
| `references/testbench-patterns.md` | Setting up Orchestra Testbench, writing package tests |
