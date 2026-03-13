# DDD Architecture Tests

Pest architecture tests to enforce domain boundaries and DDD conventions.

## Layer Boundary Tests

```php
// tests/Architecture/DomainBoundaryTest.php

arch('domain layer is pure — no framework infrastructure imports')
    ->expect('Src\Domain\*\Domain')
    ->not->toUse([
        'Illuminate\Support\ServiceProvider',
        'Illuminate\Http',
        'Illuminate\Console',
        'Illuminate\Queue',
    ]);

arch('domain layer does not import application layer')
    ->expect('Src\Domain\*\Domain')
    ->not->toUse('Src\Domain\*\Application');

arch('domain layer does not import infrastructure layer')
    ->expect('Src\Domain\*\Domain')
    ->not->toUse('Src\Domain\*\Infrastructure');

arch('domain layer does not import presentation layer')
    ->expect('Src\Domain\*\Domain')
    ->not->toUse('Src\Domain\*\Presentation');

arch('application layer does not import presentation layer')
    ->expect('Src\Domain\*\Application')
    ->not->toUse('Src\Domain\*\Presentation');

arch('application layer does not import infrastructure layer')
    ->expect('Src\Domain\*\Application')
    ->not->toUse('Src\Domain\*\Infrastructure');

arch('infrastructure does not contain business logic models')
    ->expect('Src\Domain\*\Infrastructure')
    ->not->toExtend('Illuminate\Database\Eloquent\Model');

arch('presentation layer uses application layer, not domain directly')
    ->expect('Src\Domain\*\Presentation\Controllers')
    ->toOnlyUse([
        'Src\Domain\*\Application',
        'Illuminate\Http',
        'Illuminate\Routing',
        'Inertia',
    ]);
```

## Cross-Domain Isolation Tests

```php
// tests/Architecture/DomainIsolationTest.php

arch('domains do not import other domains directly')
    ->expect('Src\Domain\Identity')
    ->not->toUse([
        'Src\Domain\Billing\Domain',
        'Src\Domain\Catalogue\Domain',
    ]);

arch('domains can only use Shared domain')
    ->expect('Src\Domain\*\Domain')
    ->toOnlyUse([
        'Src\Domain\Shared',
        'Illuminate\Database',
        'Illuminate\Support\Collection',
        'Illuminate\Support\Carbon',
    ]);
```

## Model Convention Tests

```php
// tests/Architecture/DomainModelTest.php

arch('domain models extend Shared Base')
    ->expect('Src\Domain\*\Domain\Models')
    ->toExtend('Src\Domain\Shared\Domain\Models\Base');

arch('domain models live in Domain layer only')
    ->expect('Src\Domain\*\Application')
    ->not->toExtend('Illuminate\Database\Eloquent\Model');

arch('domain models use UUID trait')
    ->expect('Src\Domain\*\Domain\Models')
    ->toUseTrait('Src\Domain\Shared\Domain\Traits\HasUuid');
```

## Event Convention Tests

```php
// tests/Architecture/DomainEventTest.php

arch('domain events live in Domain layer')
    ->expect('Src\Domain\*\Domain\Events')
    ->toBeClasses();

arch('event listeners live in Infrastructure layer')
    ->expect('Src\Domain\*\Infrastructure\Listeners')
    ->toBeClasses();
```

## Value Object Tests

```php
// tests/Architecture/ValueObjectTest.php

arch('value objects are final')
    ->expect('Src\Domain\*\Domain\ValueObjects')
    ->toBeFinal();

arch('value objects are readonly')
    ->expect('Src\Domain\*\Domain\ValueObjects')
    ->toBeReadonly();

arch('value objects do not extend Eloquent')
    ->expect('Src\Domain\*\Domain\ValueObjects')
    ->not->toExtend('Illuminate\Database\Eloquent\Model');
```

## Action Convention Tests

```php
// tests/Architecture/ActionTest.php

arch('actions live in Application layer')
    ->expect('Src\Domain\*\Application\Actions')
    ->toBeClasses();

arch('actions extend base Action')
    ->expect('Src\Domain\*\Application\Actions')
    ->toExtend('CleaniqueCoders\LaravelAction\Action');

arch('controllers do not contain business logic')
    ->expect('Src\Domain\*\Presentation\Controllers')
    ->not->toUse('Illuminate\Support\Facades\DB');
```

## Service Provider Tests

```php
// tests/Architecture/ProviderTest.php

arch('each domain has a service provider')
    ->expect('Src\Domain\*\Infrastructure\Providers')
    ->toExtend('Illuminate\Support\ServiceProvider');

arch('service providers live in Infrastructure layer only')
    ->expect('Src\Domain\*\Domain')
    ->not->toExtend('Illuminate\Support\ServiceProvider');
```

## Naming Convention Tests

```php
// tests/Architecture/NamingTest.php

arch('controllers have Controller suffix')
    ->expect('Src\Domain\*\Presentation\Controllers')
    ->toHaveSuffix('Controller');

arch('requests have Request suffix')
    ->expect('Src\Domain\*\Presentation\Requests')
    ->toHaveSuffix('Request');

arch('resources have Resource suffix')
    ->expect('Src\Domain\*\Presentation\Resources')
    ->toHaveSuffix('Resource');

arch('service providers have ServiceProvider suffix')
    ->expect('Src\Domain\*\Infrastructure\Providers')
    ->toHaveSuffix('ServiceProvider');

arch('DTOs have Data suffix')
    ->expect('Src\Domain\*\Application\DTOs')
    ->toHaveSuffix('Data');
```

## Full Suite Runner

Add to `composer.json` scripts:

```json
{
    "scripts": {
        "test:arch": "pest --filter=Architecture"
    }
}
```

Run with:

```bash
composer test:arch
```
