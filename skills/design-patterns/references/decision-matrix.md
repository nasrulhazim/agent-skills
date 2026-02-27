# Decision Matrix — Problem to Pattern Mapping

Use this matrix when the user describes a problem and you need to recommend the right
pattern. Each entry maps a problem type to the recommended pattern, with trade-offs
and when to avoid.

---

## Quick Reference Matrix

| Problem Type | Primary Pattern | Alternative | Avoid When |
|---|---|---|---|
| Complex object creation with many params | **Builder** | Factory | Object has < 4 params — just use constructor |
| Create objects without knowing exact class | **Factory** | Strategy | Only one concrete type exists |
| Exactly one instance needed | **Singleton** (container) | — | You're tempted to use static methods for convenience |
| Decouple data access from business logic | **Repository** | Query Scopes | Simple CRUD with no business rules |
| Add behaviour without modifying class | **Decorator** | Pipeline | Only one layer of behaviour needed |
| Wrap incompatible third-party interface | **Adapter** | — | You control both interfaces |
| Simplify complex subsystem | **Facade** (real) | Service class | Subsystem is already simple |
| Multiple algorithms for same task | **Strategy** | Config-driven | Only 2 options — `if/else` is fine |
| React to events / decouple side effects | **Observer** (Event) | Queue/Job | Synchronous result needed from observer |
| Sequential data processing stages | **Pipeline** | Middleware | Only 2 stages — just call sequentially |
| Encapsulate business operation | **Action** | Command/Job | Operation is trivial (1-2 lines) |
| Background / async processing | **Job** (Queue) | Event+Listener | Task must be synchronous |
| State-dependent behaviour | **State Machine** | Strategy | Only 2 states — `if/else` is fine |
| Transfer data between layers | **DTO** | Array | Internal-only, simple key-value |
| Domain concept defined by value | **Value Object** | Primitive | No domain behaviour needed |
| Reusable query constraints | **Query Scope** | Repository | Query is used in only one place |
| Input validation + authorization | **Form Request** | Inline validation | API with custom validation flow |
| Transform model to API response | **API Resource** | `toArray()` | Internal use only, no API consumers |

---

## Detailed Decision Guide

### "I need to create objects, but the type depends on input"

**Use: Factory Pattern**

```
Input → Factory → Concrete Object
```

**Signs you need it:**
- `match` or `switch` on a type string to create objects
- Object creation logic repeated in multiple places
- New types added frequently

**Trade-offs:**
- (+) Centralises creation logic
- (+) Easy to add new types
- (-) Extra class for simple creation
- (-) All concrete types must share an interface

**Avoid when:**
- Only one concrete type — just use `new` or container binding
- Creation is trivial with no conditional logic

---

### "This object has too many constructor parameters"

**Use: Builder Pattern**

```
Builder → step → step → step → build() → Object
```

**Signs you need it:**
- Constructor has 5+ parameters
- Many parameters are optional
- Object can be built in different configurations
- You find yourself passing `null` for unused params

**Trade-offs:**
- (+) Readable fluent API
- (+) Can validate at `build()` time
- (+) Self-documenting parameter names
- (-) More code than a simple constructor
- (-) IDE completion depends on return type hints

**Avoid when:**
- Object has 3 or fewer required params — use constructor
- All params are always required — use DTO

---

### "I want to decouple my data access layer"

**Use: Repository Pattern**

```
Controller → Action → Repository Interface → Eloquent Implementation
```

**Signs you need it:**
- Business logic mixed with query logic
- Same queries duplicated across controllers
- You need to swap data sources (Eloquent, API, cache)
- Complex queries that deserve their own tests

**Trade-offs:**
- (+) Testable — mock the interface in unit tests
- (+) Swappable implementations (Eloquent, API, Cache decorator)
- (+) Complex queries have a home
- (-) Extra interface + class for simple CRUD
- (-) Can become a "god repository" if not scoped properly

**Avoid when:**
- Simple CRUD with no business rules — Eloquent directly is fine
- The model is only used in one place
- You'd just be wrapping `Model::find()` with `Repository::find()`

**Scope it right:**
- One repository per aggregate root, not per table
- `OrderRepository` manages orders — not `OrderItemRepository` separately

---

### "I need to add caching/logging/rate-limiting to an existing service"

**Use: Decorator Pattern**

```
Controller → Cached Repository (Decorator) → Eloquent Repository (Real)
```

**Signs you need it:**
- You want to add behaviour without changing the original class
- The added behaviour is cross-cutting (caching, logging, metrics)
- You might want to stack multiple behaviours

**Trade-offs:**
- (+) Open/Closed principle — extend without modifying
- (+) Behaviours are composable and stackable
- (+) Each decorator is independently testable
- (-) Must implement entire interface (even pass-through methods)
- (-) Debugging can be confusing with many layers

**Avoid when:**
- Only one layer needed — a simple wrapper method might suffice
- The behaviour applies to all methods equally — use middleware instead

---

### "Different customers get different pricing/export/notification logic"

**Use: Strategy Pattern**

```
Context → Strategy Interface → Concrete Strategy A / B / C
```

**Signs you need it:**
- Growing `match`/`switch` statement that adds cases over time
- Algorithm varies by customer type, plan, region, etc.
- You want to test each algorithm independently

**Trade-offs:**
- (+) Each strategy is isolated and testable
- (+) New strategies added without touching existing code
- (+) Clean separation of variant logic
- (-) Extra classes for each variant
- (-) Context must know how to select the right strategy

**Avoid when:**
- Only 2 options and unlikely to grow — `if/else` is clearer
- The "strategy" is just a config value, not real logic

---

### "When X happens, multiple things need to happen (email, log, webhook)"

**Use: Observer / Event-Listener Pattern**

```
Action → dispatch(Event) → Listener A, Listener B, Listener C (queued)
```

**Signs you need it:**
- One action triggers multiple side effects
- Side effects are independent of each other
- Side effects should not block the main action
- New side effects are added frequently

**Trade-offs:**
- (+) Main action stays focused — doesn't know about side effects
- (+) Listeners can be queued independently
- (+) New listeners added without touching the action
- (-) Harder to trace what happens when (event flow)
- (-) Can lead to event storms if overused

**Avoid when:**
- Only one side effect — just call it directly
- The "listener" needs to return a result to the dispatcher
- You need guaranteed ordering of side effects

---

### "Data passes through multiple processing stages"

**Use: Pipeline Pattern**

```
Input → Stage 1 → Stage 2 → Stage 3 → Output
```

**Signs you need it:**
- Data goes through sequential transformations
- Stages should be reorderable or optional
- Each stage should be independently testable
- Similar to middleware but for data processing, not HTTP

**Trade-offs:**
- (+) Each stage is isolated and testable
- (+) Stages can be reordered or skipped dynamically
- (+) Clean separation of processing steps
- (-) Harder to short-circuit (need convention for stopping)
- (-) Context object can become a "grab bag"

**Avoid when:**
- Only 2 stages — just call them sequentially
- Stages don't share a context or transform the same data

---

### "This object changes behaviour based on its current status"

**Use: State Machine Pattern**

```
Object → Current State → allowed transitions → New State
```

**Signs you need it:**
- Object has a `status` field that controls what operations are allowed
- `if ($order->status === 'pending')` scattered across multiple files
- Invalid transitions cause bugs (e.g., completing a cancelled order)
- Business rules differ per state

**Trade-offs:**
- (+) Transitions are explicit and validated
- (+) Impossible states are compile-time (or runtime) errors
- (+) Each state's behaviour is isolated
- (-) Many classes for many states
- (-) Can be overkill for simple status fields

**Avoid when:**
- Only 2 states (active/inactive) — a boolean is fine
- Status is display-only and doesn't affect behaviour
- Transitions have no business rules

---

### "I need a single business operation that's reusable"

**Use: Action Pattern**

```
Controller → Action::execute(DTO) → Result
```

**Signs you need it:**
- Same business operation called from controller, command, job, or test
- Controller method is getting long with business logic
- You want to test business logic without HTTP

**Trade-offs:**
- (+) Reusable across entry points
- (+) Testable without HTTP
- (+) Single responsibility — one action, one purpose
- (-) Can lead to many small classes
- (-) Naming can be verbose

**Avoid when:**
- Operation is trivial (1-2 lines) — inline in controller
- Operation is only ever called from one place and unlikely to change

---

## Anti-Pattern Detection

### God Controller

**Symptoms:**
- Controller > 200 lines
- Multiple responsibilities in one method
- Business logic in controller
- Direct Eloquent queries in controller

**Fix:** Extract to Action classes + Form Request + API Resource

### Fat Model

**Symptoms:**
- Model > 300 lines
- Business logic, validation, query logic all in one class
- Methods that don't operate on model attributes

**Fix:** Extract business logic to Actions, queries to Scopes, validation to Form Requests

### Service Locator Abuse

**Symptoms:**
- `app()->make(SomeClass::class)` scattered in business logic
- `resolve(SomeClass::class)` used instead of constructor injection
- Facade usage inside domain classes (not controllers/commands)

**Fix:** Use constructor injection. Let the container auto-resolve.

### Premature Abstraction

**Symptoms:**
- Interface with exactly one implementation and no plan for a second
- Abstract class with one child
- "Future-proofing" that adds complexity now

**Fix:** Use concrete class. Extract interface when the second implementation actually exists.
The cost of extracting an interface later is trivial. The cost of maintaining unnecessary
abstractions is ongoing.

### God Service

**Symptoms:**
- Service class > 300 lines
- Methods for unrelated operations
- `UserService` with `createUser()`, `sendWelcomeEmail()`, `calculateDiscount()`, `exportToCsv()`

**Fix:** Split into focused Action classes: `CreateUserAction`, `SendWelcomeEmailAction`, etc.

### Anaemic Domain Model

**Symptoms:**
- Models are just data containers (`$model->getAttribute()` only)
- All logic lives in external services
- No methods on the model that express domain behaviour

**Fix:** Move domain-specific behaviour to model methods. A `$user->isAdmin()` is better
than `$adminService->isUserAdmin($user)`. An `$order->canBeCancelled()` is better than
`$orderService->canCancel($order)`.

---

## Choosing Between Similar Patterns

### Action vs Service vs Job

| Criteria | Action | Service | Job |
|---|---|---|---|
| Purpose | Single operation | Orchestrate multiple operations | Background processing |
| Sync/Async | Synchronous | Synchronous | Asynchronous (queued) |
| Complexity | One thing, done well | Coordinates multiple things | One thing, done later |
| Example | `CreateOrderAction` | `CheckoutService` (calls multiple actions) | `GenerateReportJob` |

### Repository vs Query Scope

| Criteria | Repository | Query Scope |
|---|---|---|
| Interface required | Yes (for swappable implementations) | No |
| Testability | Mock the interface | Test with database |
| Complexity | Higher (interface + implementation + binding) | Lower (method on model) |
| Best for | Complex queries, multiple data sources | Simple reusable constraints |

### DTO vs Array vs Value Object

| Criteria | DTO | Array | Value Object |
|---|---|---|---|
| Type safety | Full (typed properties) | None | Full |
| Immutability | Yes (readonly) | No | Yes |
| Behaviour | Factory methods only | None | Domain behaviour |
| Use case | Transfer between layers | Quick internal use | Domain concept |
| Example | `CreateOrderData` | Config arrays | `Money`, `Email` |

### Event/Listener vs Direct Call

| Criteria | Event/Listener | Direct Call |
|---|---|---|
| Coupling | Loose — dispatcher doesn't know listeners | Tight — caller knows callee |
| Traceability | Harder to follow flow | Easy to follow |
| Async | Listeners can be queued | Synchronous by default |
| Best for | Multiple independent side effects | Single, required consequence |
