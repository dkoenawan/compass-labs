<!-- tier: full (the four required diagrams). At short or skip tier, created only when an optional diagram is chosen. Follow the rendering rules in the requirements skill's reference/diagrams.md. -->
# Diagrams: {Session Title}

> Part of [index](index.md) · Define

## Impact map

```mermaid
mindmap
  root((Feature))
    OUT-01 outcome
      Stakeholder group
        Behaviour change
          REQ-001
```

## Context diagram

```mermaid
flowchart LR
  subgraph S["Work in scope"]
    W["Feature"]
  end
  G1["Stakeholder group"] -->|"interaction"| W
  W -->|"interaction"| X1["External system"]
```

## Traceability

<!-- requirementDiagram or flowchart LR, whichever is easier to review (D10). Every OUT, every live REQ, every Serves link. -->
```mermaid
flowchart LR
  O01["OUT-01"]
  R001["REQ-001"] --> O01
```

## As-is and to-be

<!-- Only when an existing process changes. Same step IDs in both; changed, new and removed steps styled with classDef. -->
```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E
  classDef new fill:#DCFCE7,stroke:#166534
  classDef removed fill:#FEE2E2,stroke:#991B1B
  subgraph ASIS["As-is"]
    A1["S1 step"] --> A2["S2 step"]
  end
  subgraph TOBE["To-be"]
    B1["S1 step"] --> B2["S2 step, changed"]:::changed --> B3["S3 step, new"]:::new
  end
```
