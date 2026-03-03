# Mermaid.js Diagram Patterns

Quick-reference patterns for each diagram type used in research documents. Copy and adapt.

---

## 1. System Context Diagram

```mermaid
graph LR
    subgraph Sources["External Sources"]
        A[System A]
        B[System B]
    end

    subgraph System["Our System"]
        C[Component 1]
        D[Component 2]
    end

    subgraph Consumers["Consumers"]
        E[User A]
        F[User B]
    end

    Sources --> System
    System --> Consumers
```

---

## 2. Component Architecture (Top-Down)

```mermaid
graph TB
    subgraph Layer1["Presentation Layer"]
        A[CLI / API]
    end

    subgraph Layer2["Business Logic"]
        B[Service A]
        C[Service B]
    end

    subgraph Layer3["Data Layer"]
        D[Repository]
        E[Cache]
    end

    A --> B
    A --> C
    B --> D
    C --> D
    B --> E
```

---

## 3. Detailed Flowchart with Decisions

```mermaid
flowchart TD
    START["Entry Point"]

    CHECK{Decision?}
    PATH_A["Path A"]
    PATH_B["Path B"]

    NESTED{Nested<br/>Decision?}
    RESULT_1["Result 1"]
    RESULT_2["Result 2"]

    END["Done"]

    START --> CHECK
    CHECK -->|Yes| PATH_A
    CHECK -->|No| PATH_B
    PATH_A --> NESTED
    NESTED -->|Yes| RESULT_1
    NESTED -->|No| RESULT_2
    PATH_B --> END
    RESULT_1 --> END
    RESULT_2 --> END
```

---

## 4. Sequence Diagram (Multi-Actor)

```mermaid
sequenceDiagram
    participant User
    participant API as API Layer
    participant Engine as Core Engine
    participant DB as Database
    participant FS as File System

    User->>API: Request (args)

    rect rgb(240, 248, 255)
        Note over API,Engine: Phase 1 — Initialisation
        API->>Engine: Initialise with config
        Engine->>DB: Load existing data
        DB-->>Engine: Data
    end

    rect rgb(255, 248, 240)
        Note over API,FS: Phase 2 — Processing
        Engine->>Engine: Core algorithm
        Engine->>FS: Write output
    end

    Engine-->>User: Complete
```

---

## 5. Class Diagram

```mermaid
classDiagram
    class InterfaceName {
        <<interface>>
        +methodA(param) returnType
    }

    class AbstractBase {
        <<abstract>>
        #property1 Type
        #property2 Type
        +__construct(dep1, dep2)
    }

    class ConcreteA {
        -privateField Type
        +dump(data) void
        -helperMethod() Type
    }

    class ConcreteB {
        -privateField Type
        +dump(data) void
    }

    InterfaceName <|.. AbstractBase
    AbstractBase <|-- ConcreteA
    AbstractBase <|-- ConcreteB
    ConcreteA --> HelperClass
```

---

## 6. Entity Relationship Diagram

```mermaid
erDiagram
    ORGANISATION ||--o{ TEAM : has
    ORGANISATION ||--o{ REPOSITORY : owns
    TEAM ||--o{ USER : contains

    REPOSITORY ||--o{ PACKAGE : contains
    PACKAGE ||--o{ VERSION : has
    VERSION ||--o{ DEPENDENCY : requires

    ORGANISATION {
        uuid id
        string name
        string slug
    }

    PACKAGE {
        uuid id
        string name
        string type
        int downloads
    }

    VERSION {
        uuid id
        string version
        string stability
        json metadata
    }
```

---

## 7. Mindmap (Hierarchical)

```mermaid
mindmap
    root((Central Concept))
        Category A
            Feature 1
                Detail
                Detail
            Feature 2
        Category B
            Feature 3
            Feature 4
                Sub-detail
```

---

## 8. Gantt Chart (Roadmap)

```mermaid
gantt
    title Project Roadmap
    dateFormat YYYY-Q
    axisFormat %Y-Q%q

    section Phase 1 — MVP
    Feature A       :2026-Q2, 90d
    Feature B       :2026-Q2, 60d

    section Phase 2 — Growth
    Feature C       :2026-Q3, 45d
    Feature D       :2026-Q4, 30d
```

---

## 9. State Diagram

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading: trigger
    Loading --> Processing: data ready
    Processing --> Complete: success
    Processing --> Error: failure
    Error --> Idle: retry
    Complete --> Idle: reset
    Complete --> [*]

    state Processing {
        [*] --> StepA
        StepA --> StepB
        StepB --> StepC
        StepC --> [*]
    }
```

---

## 10. Quadrant Chart (Positioning)

```mermaid
quadrantChart
    title Feature Richness vs Cost
    x-axis Low Features --> High Features
    y-axis Low Cost --> High Cost

    CompetitorA: [0.15, 0.05]
    CompetitorB: [0.85, 0.9]
    OurProduct: [0.75, 0.4]
```

---

## 11. XY Chart (Revenue / Metrics)

```mermaid
xychart-beta
    title Monthly Recurring Revenue
    x-axis ["Q1", "Q2", "Q3", "Q4"]
    y-axis "MRR (USD)" 0 --> 50000
    bar [2000, 8000, 22000, 45000]
```

---

## 12. Styled Nodes

Use `style` to highlight important nodes:

```mermaid
flowchart TD
    A["Normal Node"]
    B["Warning Node"]
    C["Success Node"]
    D["Error Node"]

    style B fill:#fff3e0
    style C fill:#e8f5e9,stroke:#4caf50
    style D fill:#ffcdd2,stroke:#f44336
```

---

## 13. Subgraph Patterns

Group related items:

```mermaid
graph TB
    subgraph Group1["Input Layer"]
        style Group1 fill:#e3f2fd
        A[Source A]
        B[Source B]
    end

    subgraph Group2["Processing"]
        style Group2 fill:#fff3e0
        C[Processor]
    end

    subgraph Group3["Output"]
        style Group3 fill:#e8f5e9
        D[Output A]
        E[Output B]
    end

    A --> C
    B --> C
    C --> D
    C --> E
```

---

## 14. Pipeline Pattern (Horizontal)

```mermaid
flowchart LR
    S1["Step 1<br/>Input"]
    S2["Step 2<br/>Process"]
    S3["Step 3<br/>Filter"]
    S4["Step 4<br/>Transform"]
    S5["Step 5<br/>Output"]

    S1 --> S2 --> S3 --> S4 --> S5

    style S1 fill:#e1f5fe
    style S2 fill:#fff3e0
    style S3 fill:#e8f5e9
    style S4 fill:#f3e5f5
    style S5 fill:#fce4ec
```

---

## Tips

- Keep node labels short (2-5 words) — add `<br/>` for second lines
- Use `rect rgb(r,g,b)` in sequence diagrams to group phases
- Prefer `flowchart` over `graph` — flowchart supports more features
- Use `TD` for process flows, `LR` for pipelines and comparisons
- Always close subgraphs with `end`
- Quote node labels containing special characters: `["Label (with parens)"]`
- Use `-->|label|` for edge labels in flowcharts
- Use `Note over A,B:` for wide notes in sequence diagrams
