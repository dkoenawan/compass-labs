<!-- tier: full. Rendering rules: skills/requirements/reference/diagrams.md. -->
# Diagrams: Implement phase — an as-built artifact, the backend API artifact and the testing boundary

> Part of [index](index.md) · Define · Explains [problem.md](problem.md)

## As-is and to-be

**The problem in one line:** Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design.

The same step IDs (S1 to S8) appear in both views. Legend: green is new, amber is changed, red dashed is a gap today, and grey is unchanged.

```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E
  classDef new fill:#DCFCE7,stroke:#166534
  classDef removed fill:#FEE2E2,stroke:#991B1B
  classDef gap fill:#FEE2E2,stroke:#991B1B,stroke-dasharray:4 3
  classDef unchanged fill:#F1F5F9,stroke:#475569

  subgraph ASIS["As-is"]
    direction LR
    A1["S1 Define: define/ index, framing, problem, requirements"]:::unchanged
    A2["S2 Design: design/, ADR flags, visual deltas, DES table"]:::unchanged
    A3["S3 Implement: code, tests of no stated kind"]
    A4["S4 Implement artifact: none, only a task checklist ✗"]:::gap
    A5["S5 Layer artifact: none, built API never checked ✗"]:::gap
    A6["S6 Implement gate: reviewer sees code and commits"]
    A7["S7 Test: verification.md, unit, e2e or manual"]
    A8["S8 Close: folds back define/ and design/ only"]
    AV["Variation found while building"]:::gap
    A1 --> A2 --> A3 --> A6 --> A7 --> A8
    A3 -.->|"variation"| AV
    AV -.->|"goes nowhere ✗"| A8
  end

  subgraph TOBE["To-be"]
    direction LR
    B1["S1 Define: unchanged"]:::unchanged
    B2["S2 Design: unchanged, API contract in design/"]:::unchanged
    B3["S3 Implement: code plus unit and component tests"]:::changed
    B4["S4 Implement artifact: as-built record per DES-*, built as designed, deviated or not built, with reasons, and variations listed"]:::new
    B5["S5 Backend artifact: OpenAPI spec rendered with Scalar, checked against the design API"]:::new
    B6["S6 Implement gate: reviewer checks the as-built record, variations raised"]:::changed
    B7["S7 Test: verification.md, integration, UI and Playwright"]:::changed
    B8["S8 Close: folds back define/, design/ and the variations"]:::changed
    BF["Later layers, examples only: frontend component inventory and screenshots, database"]:::unchanged
    B1 --> B2 --> B3
    B3 -->|"records"| B4
    B3 -->|"generates"| B5
    B2 -.->|"design API"| B5
    B5 -->|"mismatches become variations"| B4
    B4 --> B6 --> B7 --> B8
    B8 -.->|"as-built docs, read by the next Design"| B2
    BF -.->|"same plug-in contract, own issues"| B5
  end
```

**The same diagram as plain text.**

| Step | As-is | To-be |
|---|---|---|
| S1 Define | `define/`: index, framing, problem, requirements | Unchanged |
| S2 Design | `design/`, ADR flags, visual deltas, the `DES-*` table | Unchanged. Its API contract is what S5 checks against |
| S3 Implement | Code, plus tests of no stated kind | Code plus **unit and component tests** (backend always both) |
| S4 Implement artifact | None, only a task checklist with free-prose deviations ✗ | **New:** an as-built record per `DES-*` (built as designed, deviated, not built, each with a reason), listing every variation |
| S5 Layer artifact | None. The built API is never checked ✗ | **New, backend:** an OpenAPI spec rendered with Scalar, generated with the code and checked against the design's API. A mismatch becomes a variation in S4. Frontend and database are later issues; a component inventory with screenshots is only an example |
| S6 Implement gate | The reviewer sees code and commits | The reviewer checks the as-built record, and **variations are raised** for the user to decide on |
| S7 Test | `verification.md`; methods unit, e2e or manual | `verification.md`: **integration, UI and Playwright** tests |
| S8 Close | Folds back `define/` and `design/` only | Also folds back the **variations**, so the as-built docs, which the next Design reads, match what was built |
| Variation path | Found while building → goes nowhere ✗ | Found while building → recorded in S4 → raised at S6 → folded back at S8 |

**Two kinds of testing.** Implement (S3) owns unit and component tests. Test (S7) owns integration, UI and Playwright tests.

## Context diagram

```mermaid
flowchart LR
  subgraph SCOPE["Work in scope"]
    STD["Implement phase standard: as-built record, testing boundary, tasks from DES"]
    BE["Backend Implement guidance: OpenAPI spec with Scalar, checked against design"]
    PLUG["Layer plug-in contract"]
    TE["task-executor in step with the lifecycle"]
  end
  REV["Implement milestone reviewer"] -->|"checks the as-built record, decides variations"| STD
  DEV["Developers consuming the backend API"] -->|"read the built API spec"| BE
  DOCS["As-built doc maintainers and later sessions"] -->|"rely on variations being folded back"| STD
  IMPL["Implement agent"] -->|"follows, writes unit and component tests"| STD
  TEST["Test agent"] -->|"runs integration, UI and Playwright tests"| STD
  MAINT["Plugin maintainers"] -->|"add later layers by files only"| PLUG
  DESIGN["design/ folder and DES table"] -->|"API contract, results, checks, order"| STD
  STD -->|"variations to fold back"| CLOSE["Close fold-back"]
  BE -->|"rendered by"| SCALAR["Scalar and OpenAPI tooling"]
  BE -->|"plugs into"| PLUG
  TE -->|"executes tasks, registers constructs once"| REG["Construct registry"]
```

**As plain text:**
- The **work in scope** is the Implement phase standard, the backend Implement guidance, the layer plug-in contract and the `task-executor` fix.
- The **Implement reviewer** checks the as-built record and decides on variations.
- **Developers who consume the backend API** read the built spec.
- **As-built doc maintainers and later sessions** rely on Close folding variations back.
- The **Implement agent** follows the standard and writes unit and component tests. The **Test agent** runs integration, UI and Playwright tests.
- **Plugin maintainers** add later layers by adding files.
- The work reads the **`design/` folder** and writes to **Close's fold-back**.
- It uses **Scalar and OpenAPI tooling**.
- `task-executor` registers constructs in the **construct registry** exactly once.

## Impact map

```mermaid
mindmap
  root((Implement phase standard))
    OUT-01 every DES item has an as-built status
      Implement agent
        Records a status and reason per DES item
          REQ-001
          REQ-002
      Implement milestone reviewer
        Checks statuses at the gate
          REQ-004
    OUT-02 no unlisted mismatch between design API and OpenAPI spec
      Implement agent
        Produces an OpenAPI spec with the backend code
          REQ-011
        Compares it with the design API contract
          REQ-012
    OUT-03 every raised variation folded back or dropped
      Implement agent
        Records variations without touching frozen artifacts
          REQ-002
          REQ-003
      Implement milestone reviewer
        Decides each variation at the gate
          REQ-004
          REQ-005
      Close agent
        Folds accepted variations into as-built docs
          REQ-006
    OUT-04 no test in the wrong phase
      Implement agent
        Writes unit and component tests only
          REQ-007
          REQ-008
        Hands integration and UI checks to Test
          REQ-016
      Test agent
        Verifies each REQ with a Test-owned test
          REQ-009
          REQ-010
    OUT-05 every task comes from a DES item in order
      Implement agent
        Derives tasks from Result, Check and Depends on
          REQ-015
          REQ-016
    OUT-06 task-executor finds the design and constructs have one writer
      Developers running task-executor
        Plan against the design folder or a past design file
          REQ-017
      Plugin maintainers
        Keep one construct owner and a validator trigger
          REQ-018
          REQ-019
    OUT-07 a later layer plugs in by files only
      Plugin maintainers
        Add a layer home without other changes
          REQ-014
```

REQ-013 (an established stack wins) serves NEED-02 directly, and REQ-020 (past sessions unchanged) serves NEED-01 and NEED-06. Both appear in the traceability diagram below.

## Traceability

```mermaid
flowchart LR
  classDef must fill:#DCFCE7,stroke:#166534
  classDef should fill:#FEF3C7,stroke:#92400E
  O01["OUT-01"]
  O02["OUT-02"]
  O03["OUT-03"]
  O04["OUT-04"]
  O05["OUT-05"]
  O06["OUT-06"]
  O07["OUT-07"]
  N01["NEED-01"]
  N02["NEED-02"]
  N03["NEED-03"]
  N06["NEED-06"]
  R001["REQ-001"]:::must --> O01
  R002["REQ-002"]:::must --> O01
  R002 --> O03
  R003["REQ-003"]:::must --> N03
  R004["REQ-004"]:::must --> O01
  R004 --> O03
  R005["REQ-005"]:::should --> O03
  R006["REQ-006"]:::must --> O03
  R007["REQ-007"]:::must --> O04
  R008["REQ-008"]:::must --> O04
  R009["REQ-009"]:::must --> O04
  R010["REQ-010"]:::should --> O04
  R011["REQ-011"]:::must --> O02
  R012["REQ-012"]:::must --> O02
  R013["REQ-013"]:::must --> N02
  R014["REQ-014"]:::must --> O07
  R015["REQ-015"]:::must --> O05
  R016["REQ-016"]:::should --> O05
  R016 --> O04
  R017["REQ-017"]:::must --> O06
  R018["REQ-018"]:::must --> O06
  R019["REQ-019"]:::should --> O06
  R020["REQ-020"]:::must --> N01
  R020 --> N06
```

**As plain text:**

| Outcome or need | Served by |
|---|---|
| OUT-01 | REQ-001, REQ-002, REQ-004 |
| OUT-02 | REQ-011, REQ-012 |
| OUT-03 | REQ-002, REQ-004, REQ-005, REQ-006 |
| OUT-04 | REQ-007, REQ-008, REQ-009, REQ-010, REQ-016 |
| OUT-05 | REQ-015, REQ-016 |
| OUT-06 | REQ-017, REQ-018, REQ-019 |
| OUT-07 | REQ-014 |
| NEED-01, NEED-06 | REQ-020 |
| NEED-02 | REQ-013 |
| NEED-03 | REQ-003 |

Must is green and Should is amber. There are no Coulds. Deferred rows REQ-021 to REQ-026 are left out.
