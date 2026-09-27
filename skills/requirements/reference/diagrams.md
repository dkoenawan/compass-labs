# Diagram catalogue

> Standard: [requirements](../SKILL.md) · Used by: [problem-statement/types/feature.md](../../problem-statement/types/feature.md), [types/feature.md](../types/feature.md)

Every diagram a Feature definition can contain, required or optional, with its Mermaid type, what it must show, the check that proves it, and a small example that renders. All of them go in `define/diagrams.md`, each under its own heading. Each diagram is owned by the type file of the section it illustrates; the rendering rules live here, once.

## Which diagrams, at which tier

| Diagram | Tier | Mermaid type | Owned by |
|---|---|---|---|
| [Impact map](#impact-map) | full, required | `mindmap` | problem-statement |
| [Context diagram](#context-diagram) | full, required | `flowchart LR` | problem-statement |
| [Traceability diagram](#traceability-diagram) | full, required | `requirementDiagram` or `flowchart LR` | requirements |
| [As-is / to-be](#as-is--to-be) | full, required when an existing process changes | `flowchart` ×2, or one with two subgraphs | problem-statement |
| [Customer journey](#customer-journey) | optional, any tier | `journey` | problem-statement |
| [Opportunity solution tree](#opportunity-solution-tree) | optional, any tier | `mindmap` | problem-statement |
| [Story map](#story-map) | optional, any tier | `flowchart TB`, one subgraph per activity | requirements |
| [Quality utility tree](#quality-utility-tree) | optional, any tier | `mindmap` | requirements |
| [Priority quadrant](#priority-quadrant) | optional, any tier | `quadrantChart` | requirements |
| [Example map](#example-map) | optional, any tier | `mindmap` | requirements |

**Short and skip tiers require no diagrams.** An optional diagram can be added at any tier when it helps, and `define/diagrams.md` then exists to hold it.

## Rendering rules

Diagrams must be viewable where the Markdown is read, without other tooling:

- Each diagram goes in its own ` ```mermaid ` fence.
- Use only the diagram types in this catalogue. GitHub renders all of them.
- Node IDs are alphanumeric (`R001`, `O01`), and the label carries the real ID: `R001["REQ-001"]`. A hyphen in a flowchart node ID can break parsing.
- Quote any label that contains punctuation, and never use a bare `end` as a flowchart node ID.
- A mindmap's hierarchy comes from indentation alone, so mindmap node text has no brackets or parentheses (other than the root's shape).
- In a `requirementDiagram`, block names are alphanumeric (`R001`), the `id` field carries the real ID, and `text` is quoted.

These examples are rendered with mermaid-cli when the plugin is tested. In a consuming repo nothing renders the diagrams at run time, so follow the rules above.

## Required at full tier

### Impact map

- **Must show:** the feature at the root → each `OUT-nn` → the stakeholder groups whose behaviour must change → each behaviour change → the `REQ-nnn` that deliver it. A REQ may appear under more than one branch.
- **Check:** every `OUT-nn` is present, each has at least one stakeholder and behaviour change, and each behaviour change has at least one REQ.
- **Helps with:** seeing why each requirement exists, and spotting an outcome nobody's behaviour serves.

```mermaid
mindmap
  root((Self-service reset))
    OUT-01 access regained in under 10 minutes
      Wiki members
        Reset their own password
          REQ-001
          REQ-002
    OUT-02 admin reset time halved
      Wiki admins
        Stop handling routine resets
          REQ-003
```

### Context diagram

- **Must show:** the work in scope as a central subgraph, every stakeholder group (from the `NEED-nn` rows) and every external system named in the problem statement or requirements, each with a labelled interaction edge.
- **Check:** every named group and system appears, with its interaction.
- **Helps with:** seeing the boundary of the work and every dependency across it.

```mermaid
flowchart LR
  subgraph SCOPE["Work in scope"]
    W["Password reset"]
  end
  M["Wiki members"] -->|"request reset, set new password"| W
  A["Wiki admins"] -->|"see reset audit log"| W
  W -->|"send reset link"| E["Email service"]
```

### Traceability diagram

- **Must show:** each `OUT-nn` linked to the `REQ-nnn` that serve it, with one link per Serves entry. `NEED-nn` appears only where a REQ serves a need alone. Show priority where the form makes that easy, for example with `classDef must`, `should` and `could` in a flowchart.
- **Check:** every `OUT-nn` and every live `REQ-nnn` appears, and every Serves link is drawn. Deferred and struck-through rows are left out.
- **Helps with:** showing that every requirement serves an outcome and every outcome is served.

**Choosing the form.** This is guidance, not a threshold:

- **`requirementDiagram`** suits a simple set: a handful of outcomes, requirements that each serve one or two of them, and few crossing links. Each REQ is a `requirement` block (`id`, `text`), each outcome is an `element`, and each Serves link is a `traces` relation. Its blocks show the requirement text, which helps a reviewer when there are few of them.
- **`flowchart LR`** suits a complicated set: many requirements, many-to-many Serves links, or a set where colouring by priority helps. Its nodes carry only IDs and short labels, so it stays compact.
- **Readability decides.** If one form is hard to read, try the other, or split the trace into one diagram per `OUT-nn`.
- **Too big to review is a signal.** If the trace is still too big to review after splitting, ask the user (through `needs_input`) whether the feature should be split into two sessions. The user decides; record the answer in `index.md`'s Open questions or framing summary.

A simple set, as a `requirementDiagram`:

```mermaid
requirementDiagram
  requirement R001 {
    id: "REQ-001"
    text: "Members can request a reset link by email"
    risk: medium
    verifymethod: test
  }
  requirement R002 {
    id: "REQ-002"
    text: "A reset link expires after 30 minutes"
    risk: high
    verifymethod: test
  }
  element O01 {
    type: "outcome"
    docref: "OUT-01"
  }
  R001 - traces -> O01
  R002 - traces -> O01
```

A complicated set, as a `flowchart LR` coloured by priority:

```mermaid
flowchart LR
  classDef must fill:#DCFCE7,stroke:#166534
  classDef should fill:#FEF3C7,stroke:#92400E
  classDef could fill:#F1F5F9,stroke:#475569
  O01["OUT-01"]
  O02["OUT-02"]
  R001["REQ-001"]:::must --> O01
  R002["REQ-002"]:::must --> O01
  R003["REQ-003"]:::should --> O02
  R004["REQ-004"]:::could --> O01
  R004 --> O02
```

### As-is / to-be

- **Must show:** the process as it is today and as it will be, with the same step IDs in both. Changed, added and removed steps are styled with `classDef changed`, `new` and `removed`.
- **Check:** every step that differs between the two is visible.
- **Required when:** the problem statement describes a change to an existing process. Otherwise leave it out.

```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E
  classDef new fill:#DCFCE7,stroke:#166534
  classDef removed fill:#FEE2E2,stroke:#991B1B
  subgraph ASIS["As-is"]
    A1["S1 member asks an admin"] --> A2["S2 admin resets by hand"]:::removed --> A3["S3 member logs in"]
  end
  subgraph TOBE["To-be"]
    B1["S1 member requests a link"]:::changed --> B2["S2 member sets a new password"]:::new --> B3["S3 member logs in"]
  end
```

## Optional at any tier

These are never required. Add one when it makes the definition easier to review.

### Customer journey

- **Mermaid type:** `journey`. **Shows:** a stakeholder's stages, the steps in each, and a satisfaction score per step. **Helps when:** the problem is spread across several steps of someone's experience.

```mermaid
journey
  title Forgotten password today
  section Locked out
    Try old passwords: 2: Member
    Ask an admin: 1: Member
  section Waiting
    Wait for a reply: 1: Member
    Log in again: 3: Member
```

### Opportunity solution tree

- **Mermaid type:** `mindmap`. **Shows:** a desired outcome → the opportunities that would move it → candidate solutions under each. **Helps when:** there are several competing ways to reach an outcome, and the choice needs showing.

```mermaid
mindmap
  root((OUT-01 access in under 10 minutes))
    Members can recover alone
      Email reset link
      Security questions
    Admins respond faster
      Reset request queue
```

### Story map

- **Mermaid type:** `flowchart TB`, one subgraph per activity. **Shows:** the activities that form the backbone → the stories under each → the release slice. **Helps when:** there are many stories and you need to see gaps or where to slice.

```mermaid
flowchart TB
  subgraph ACT1["Request reset"]
    S1["Enter email"] --> S2["Receive link"]
  end
  subgraph ACT2["Set password"]
    S3["Open link"] --> S4["Choose new password"]
  end
  ACT1 --> ACT2
```

### Quality utility tree

- **Mermaid type:** `mindmap`. **Shows:** utility → ISO/IEC 25010 characteristic → refinement → the scenario REQ. **Helps when:** several quality characteristics compete and you need to see which matter most.

```mermaid
mindmap
  root((Utility))
    Security
      Reset links cannot be reused
        REQ-002
    Performance efficiency
      Reset email arrives quickly
        REQ-005
```

### Priority quadrant

- **Mermaid type:** `quadrantChart`. **Shows:** requirements placed by value against effort. **Helps when:** the Must/Should/Could split is contested and a picture helps the conversation.

```mermaid
quadrantChart
  title Value against effort
  x-axis Low effort --> High effort
  y-axis Low value --> High value
  quadrant-1 Plan carefully
  quadrant-2 Do first
  quadrant-3 Maybe later
  quadrant-4 Avoid
  REQ-001: [0.3, 0.9]
  REQ-004: [0.7, 0.3]
```

### Example map

- **Mermaid type:** `mindmap`. **Shows:** each rule (a REQ) → its examples → open questions. **Helps when:** a requirement has edge cases, and you want the unanswered ones visible before writing criteria.

```mermaid
mindmap
  root((REQ-002 link expires after 30 minutes))
    Example link used at 29 minutes works
    Example link used at 31 minutes is refused
    Question what if two links are requested
```
