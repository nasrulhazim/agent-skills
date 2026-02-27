# Scaffold Templates

Complete documentation scaffolds for each project type. Use the relevant section based on
auto-detected or user-specified project type.

---

## Laravel Package

### `docs/README.md`

```markdown
# [Package Name] Documentation

[![Latest Version](https://img.shields.io/github/v/release/org/package?style=flat-square)](releases)
[![License](https://img.shields.io/github/license/org/package?style=flat-square)](LICENSE)
[![Packagist](https://img.shields.io/packagist/v/org/package?style=flat-square)](https://packagist.org/packages/org/package)

## Contents

- [Architecture](01-architecture/README.md)
- [Development](02-development/README.md)
- [Deployment](03-deployment/README.md)
- [API Reference](04-api/README.md)
```

### `docs/01-architecture/01-overview.md`

```markdown
# Architecture Overview

## Purpose

Brief description of what this package solves and why.

## Design Principles

- Service provider registration via `[Package]ServiceProvider`
- Contracts in `src/Contracts/` for dependency inversion
- Traits in `src/Traits/` for reusable behaviour
- Actions in `src/Actions/` for single-responsibility operations

## Package Structure

```text
src/
├── Contracts/          ← Interfaces
├── Traits/             ← Reusable traits
├── Actions/            ← Business logic units
├── Models/             ← Eloquent models (if any)
├── Http/
│   ├── Controllers/
│   └── Requests/
├── [Package]ServiceProvider.php
└── helpers.php
```

## Service Provider

Describe what the service provider registers, publishes, and boots.
```

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Requirements

- PHP 8.2+
- Laravel 11.x / 12.x

## Installation

```bash
composer require org/package
```

## Configuration

```bash
php artisan vendor:publish --tag=package-config
```

Edit `config/package.php`:

```php
return [
    'option' => env('PACKAGE_OPTION', 'default'),
];
```

## Basic Usage

```php
use Org\Package\Facades\Package;

Package::doSomething();
```
```

### `docs/02-development/02-testing.md`

```markdown
# Testing

## Setup

```bash
composer install
```

## Running Tests

```bash
./vendor/bin/pest
./vendor/bin/pest --coverage
```

## Writing Tests

Tests live in `tests/`. Use Pest with Orchestra Testbench:

```php
use Orchestra\Testbench\TestCase;

it('does something', function () {
    expect(true)->toBeTrue();
});
```
```

### `docs/03-deployment/01-publishing.md`

```markdown
# Publishing to Packagist

## Tagging a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

Packagist auto-syncs via GitHub webhook.

## Versioning

Follow [Semantic Versioning](https://semver.org):

- `MAJOR` — breaking changes
- `MINOR` — new features, backwards-compatible
- `PATCH` — bug fixes
```

---

## API

### `docs/01-architecture/01-overview.md`

```markdown
# API Architecture Overview

## Style

- REST / GraphQL / gRPC (specify)
- Versioned via URL prefix: `/api/v1/`
- JSON responses throughout

## Authentication

Describe: Bearer token / OAuth2 / API key / session

## Request/Response Conventions

- Dates: ISO 8601 (`2026-02-03T10:00:00Z`)
- Pagination: cursor-based / offset
- Error format: `{ "message": "...", "errors": {} }`
```

### `docs/04-api/01-endpoints.md`

```markdown
# API Endpoints

## Base URL

```
https://api.example.com/v1
```

## Authentication

```
Authorization: Bearer <token>
```

## Endpoints

### `GET /resources`

Returns a paginated list.

**Query Parameters**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `page` | integer | No | Page number (default: 1) |
| `per_page` | integer | No | Items per page (default: 15) |

**Response**

```json
{
  "data": [],
  "meta": { "current_page": 1, "total": 0 }
}
```
```

---

## CLI Tool

### `docs/01-architecture/01-overview.md`

```markdown
# CLI Architecture Overview

## Command Structure

```text
cli-name/
├── bin/cli-name           ← Entry point
├── src/
│   ├── Commands/          ← Command handlers
│   └── Helpers/           ← Utilities
└── config/                ← Default config
```

## Command Design

Each command follows single-responsibility. Flags are explicit, not positional where possible.
```

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Installation

```bash
# Via package manager
brew install org/tap/cli-name

# Via script
curl -fsSL https://example.com/install.sh | bash
```

## Basic Usage

```bash
cli-name [command] [flags]
```

## Available Commands

| Command | Description |
|---|---|
| `cli-name init` | Initialise in current directory |
| `cli-name run` | Execute primary action |
| `cli-name --help` | Show help |
```

---

## SDK / Library

### `docs/01-architecture/01-overview.md`

```markdown
# SDK Architecture Overview

## Design Philosophy

- Thin wrapper over the underlying API
- Immutable configuration after instantiation
- All methods return typed objects, never raw arrays

## Core Classes

| Class | Responsibility |
|---|---|
| `Client` | HTTP transport, auth, retries |
| `Resource` | Base class for API resources |
| `Exception` | Typed error hierarchy |
```

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Installation

```bash
# PHP
composer require org/sdk

# Node
npm install @org/sdk

# Python
pip install org-sdk
```

## Initialisation

```php
$client = new Org\SDK\Client(apiKey: 'your-key');
```

## First Request

```php
$result = $client->resources()->list();
```
```

---

## Full-Stack Application

### `docs/01-architecture/01-overview.md`

```markdown
# Architecture Overview

## Stack

| Layer | Technology |
|---|---|
| Frontend | React / Vue / Livewire |
| Backend | Laravel / Node |
| Database | MySQL / PostgreSQL |
| Cache | Redis |
| Queue | Laravel Horizon / BullMQ |

## High-Level Flow

```
Browser → CDN → Load Balancer → App Servers → Database
                                            → Cache
                                            → Queue Workers
```

## Key Design Decisions

Document ADRs in `01-architecture/adr/`.
```

### `docs/02-development/01-getting-started.md`

```markdown
# Local Development Setup

## Prerequisites

- PHP 8.2+ / Node 20+
- Composer / npm
- Docker (recommended)

## Quick Start

```bash
git clone https://github.com/org/app
cd app
cp .env.example .env
composer install && npm install
php artisan key:generate
php artisan migrate --seed
npm run dev
```

## Services

Start all services:

```bash
docker compose up -d
```

| Service | URL |
|---|---|
| App | http://localhost:8000 |
| Mailpit | http://localhost:8025 |
| Redis | localhost:6379 |
```

---

## Python Package

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Installation

```bash
pip install package-name
# or
poetry add package-name
```

## Usage

```python
from package_name import Client

client = Client(api_key="your-key")
result = client.do_something()
```

## Development Setup

```bash
git clone https://github.com/org/package
cd package
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest
```
```

---

## Rust Crate

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Installation

Add to `Cargo.toml`:

```toml
[dependencies]
crate-name = "0.1"
```

## Usage

```rust
use crate_name::Client;

let client = Client::new("api-key");
let result = client.fetch().await?;
```

## Building

```bash
cargo build
cargo test
cargo clippy
```
```

---

## Go Module

### `docs/02-development/01-getting-started.md`

```markdown
# Getting Started

## Installation

```bash
go get github.com/org/module@latest
```

## Usage

```go
import "github.com/org/module"

client := module.NewClient("api-key")
result, err := client.Fetch(ctx)
```

## Development

```bash
go test ./...
go vet ./...
golangci-lint run
```
```

---

## Common Files (All Project Types)

### `docs/03-deployment/01-overview.md`

```markdown
# Deployment Overview

## Environments

| Environment | Purpose | URL |
|---|---|---|
| Local | Development | localhost |
| Staging | QA / UAT | staging.example.com |
| Production | Live | example.com |

## Deployment Process

1. Merge to `main`
2. CI passes
3. Auto-deploy to staging
4. Manual approval → production

## Rollback

Describe rollback procedure specific to your stack.
```

### `docs/01-architecture/adr/0001-record-architecture-decisions.md`

```markdown
# ADR 0001: Record Architecture Decisions

## Status

Accepted

## Context

We need a way to track significant architectural decisions and their rationale.

## Decision

We will use Architecture Decision Records (ADRs), stored in `docs/01-architecture/adr/`.

## Consequences

New ADRs must be created for any significant architectural change.
Format: `NNNN-short-description.md`. Status: Proposed → Accepted → Deprecated.
```
