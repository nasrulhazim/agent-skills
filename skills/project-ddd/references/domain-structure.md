# Domain Structure Template

## Full Directory Layout

```
src/
└── Domain/
    ├── Shared/
    │   └── Domain/
    │       ├── Models/
    │       │   └── Base.php              # Abstract base model (UUID, timestamps, soft deletes)
    │       ├── Traits/
    │       │   ├── HasUuid.php
    │       │   └── HasFactory.php
    │       ├── Contracts/
    │       │   └── HasDisplayName.php
    │       └── ValueObjects/
    │           └── Money.php
    │
    ├── {DomainName}/
    │   ├── Domain/                        # Pure business logic — no framework imports
    │   │   ├── Models/
    │   │   │   └── {Model}.php
    │   │   ├── Events/
    │   │   │   ├── {Model}Created.php
    │   │   │   └── {Model}Updated.php
    │   │   ├── Contracts/
    │   │   │   └── {Model}Repository.php
    │   │   └── ValueObjects/
    │   │       └── {ValueObject}.php
    │   │
    │   ├── Application/                   # Use cases — orchestrates domain objects
    │   │   ├── Actions/
    │   │   │   ├── Create{Model}.php
    │   │   │   ├── Update{Model}.php
    │   │   │   └── Delete{Model}.php
    │   │   ├── Jobs/
    │   │   │   └── Process{Model}.php
    │   │   ├── Services/
    │   │   │   └── {DomainName}Service.php
    │   │   └── DTOs/
    │   │       └── {Model}Data.php
    │   │
    │   ├── Infrastructure/                # Framework glue — providers, registrars, exports
    │   │   ├── Providers/
    │   │   │   └── {DomainName}ServiceProvider.php
    │   │   ├── Registrars/
    │   │   │   └── {DomainName}Registrar.php
    │   │   ├── Exports/
    │   │   │   └── {Model}Export.php
    │   │   └── Listeners/
    │   │       └── Handle{Event}.php
    │   │
    │   └── Presentation/                  # HTTP layer — controllers, resources, requests
    │       ├── Controllers/
    │       │   └── {Model}Controller.php
    │       ├── Resources/
    │       │   └── {Model}Resource.php
    │       └── Requests/
    │           ├── Store{Model}Request.php
    │           └── Update{Model}Request.php
    │
    └── ...                                # Additional domains follow same structure
```

## Autoloading Configuration

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Src\\": "src/"
        }
    }
}
```

After updating `composer.json`, run:

```bash
composer dump-autoload
```

## Layer Dependency Rules

```
Presentation → Application → Domain ← Infrastructure
                                ↑
                              Shared
```

| Layer | Can Import From | Must NOT Import From |
|---|---|---|
| Domain | Shared Domain only | Application, Infrastructure, Presentation |
| Application | Domain, Shared | Infrastructure, Presentation |
| Infrastructure | Domain, Application | Presentation |
| Presentation | Application | Domain directly, Infrastructure |

## Cross-Domain Communication

Domains should communicate through:

1. **Domain Events** — Domain A dispatches, Domain B listens via Infrastructure
2. **Contracts (Interfaces)** — Domain A defines, Infrastructure implements using Domain B
3. **Application Services** — orchestrate across domains at the Application layer

Domains must NEVER:

- Import another domain's Models directly
- Share database tables between domains
- Call another domain's Actions directly (use events or contracts)

## Naming Conventions

| Component | Convention | Example |
|---|---|---|
| Domain directory | PascalCase, business name | `DomainManagement`, `Identity` |
| Model | Singular PascalCase | `Invoice`, `Subscription` |
| Event | `{Model}{PastTenseVerb}` | `InvoicePaid`, `OrderShipped` |
| Action | `{Verb}{Model}` | `CreateInvoice`, `CancelOrder` |
| Contract | `{Model}{Noun}` | `InvoiceRepository`, `PaymentGateway` |
| Value Object | Descriptive PascalCase | `Money`, `EmailAddress`, `DateRange` |
| Service Provider | `{Domain}ServiceProvider` | `BillingServiceProvider` |
| DTO | `{Model}Data` | `InvoiceData`, `UserData` |
