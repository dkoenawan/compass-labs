<!-- tier: full. Follows the rendering rules in skills/requirements/reference/diagrams.md. -->
# Diagrams: Deploy phase depth

> Part of [index](index.md) · Define

## Impact map

```mermaid
mindmap
  root((Deploy phase depth))
    OUT-01 compass-labs release runs with no prompts before the merge
      compass-labs maintainer
        Merges the PR and nothing else
          REQ-002
          REQ-005
          REQ-018
    OUT-02 no declaration means Deploy stops and says how to declare
      Consuming repo maintainer
        Declares deploy once instead of being guessed for
          REQ-003
          REQ-004
    OUT-03 declared release and check run and are recorded
      Consuming repo maintainer
        Relies on Deploy to follow the repo's own process
          REQ-001
          REQ-002
          REQ-006
          REQ-007
          REQ-008
    OUT-04 release record complete to the standard, gate refuses gaps
      User at the Deploy gate
        Approves releases against one standard shape
          REQ-014
          REQ-015
          REQ-025
    OUT-05 Deploy tells setup from release
      Consuming repo maintainer
        Gets deployment setup whenever the architecture changes
          REQ-009
          REQ-010
          REQ-011
    OUT-06 merge triggers tag and release with no manual step
      compass-labs maintainer
        Stops tagging and publishing by hand
          REQ-009
          REQ-018
          REQ-019
          REQ-020
          REQ-021
          REQ-022
          REQ-023
          REQ-024
```

## Context diagram

```mermaid
flowchart LR
  subgraph SCOPE["Work in scope"]
    STD["Deploy standard and release record"]
    DEP["Deploy phase and its gate"]
    DECL["Deploy declaration contract"]
    PIPE["compass-labs merge-triggered pipeline, L1"]
  end
  MAINT["compass-labs maintainer"] -->|"merges the PR"| HOST["Repository host, GitHub"]
  CMAINT["Consuming repo maintainer"] -->|"declares L1 setup and L2 release"| DECL
  USER["User at the Deploy gate"] -->|"approves or refuses the release record"| DEP
  DEP -->|"reads"| DECL
  DEP -->|"writes to"| STD
  DEP -->|"reads deployable parts from"| DESIGN["Frozen design artifact"]
  DEP -->|"pushes the branch, marks the PR ready"| HOST
  DEP -->|"runs declared steps and checks"| TOOLS["Repo's own deploy tooling"]
  HOST -->|"merge event"| PIPE
  PIPE -->|"creates the tag, publishes the release"| HOST
  MAINT -->|"refreshes the local install, if left to the user"| LOCAL["Local plugin install"]
```

## Traceability

Split per group of outcomes so it can be reviewed. Colour shows priority. `NEED-nn` appears only where a requirement serves a need alone.

```mermaid
flowchart LR
  classDef must fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef should fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef could fill:#F1F5F9,stroke:#475569,color:#0F172A
  O01["OUT-01"]
  O02["OUT-02"]
  O03["OUT-03"]
  O04["OUT-04"]
  N02["NEED-02"]
  N03["NEED-03"]
  R001["REQ-001"]:::must --> O03
  R002["REQ-002"]:::must --> O01
  R002 --> O03
  R003["REQ-003"]:::must --> O02
  R004["REQ-004"]:::should --> O02
  R005["REQ-005"]:::must --> O01
  R006["REQ-006"]:::must --> O03
  R007["REQ-007"]:::must --> O03
  R008["REQ-008"]:::must --> O03
  R012["REQ-012"]:::should --> N02
  R013["REQ-013"]:::could --> N02
  R014["REQ-014"]:::must --> O04
  R015["REQ-015"]:::must --> O04
  R025["REQ-025"]:::must --> O04
  R016["REQ-016"]:::should --> N03
  R017["REQ-017"]:::must --> N03
  R018["REQ-018"]:::must --> O01
```

```mermaid
flowchart LR
  classDef must fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef should fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef could fill:#F1F5F9,stroke:#475569,color:#0F172A
  O05["OUT-05"]
  O06["OUT-06"]
  R009["REQ-009"]:::must --> O05
  R009 --> O06
  R010["REQ-010"]:::must --> O05
  R011["REQ-011"]:::should --> O05
  R018["REQ-018"]:::must --> O06
  R019["REQ-019"]:::must --> O06
  R020["REQ-020"]:::must --> O06
  R021["REQ-021"]:::should --> O06
  R022["REQ-022"]:::should --> O06
  R023["REQ-023"]:::should --> O06
  R024["REQ-024"]:::could --> O06
```

REQ-001 also serves NEED-02, REQ-006 and REQ-023 also serve NEED-01, and REQ-008 and REQ-025 also serve NEED-03. Those needs are already reached through their outcomes, so the links aren't drawn.

## As-is and to-be

The Deploy process for a compass-labs release, as recorded in the five archived release records, and as it will be.

```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef removed fill:#FEE2E2,stroke:#991B1B,color:#450A0A
  subgraph ASIS["As-is"]
    A1["S1 agent works out what deploy means for this repo"] --> A2["S2 completeness check"]
    A2 --> A3["S3 agent runs some steps, lists the rest as pending"]
    A3 --> A4["S4 user or orchestrator bumps, pushes, readies the PR"]
    A4 --> A5["S5 user merges"]
    A5 --> A6["S6 user tags main and publishes by hand"]
    A6 --> A7["S7 user refreshes the local install"]
  end
  subgraph TOBE["To-be"]
    B1["S1 Deploy reads the repo's declaration"]:::changed --> B2["S2 completeness check"]
    B2 --> B8["S8 Deploy decides whether L1 is needed and runs it first"]:::new
    B8 --> B3["S3 routine L2 steps run with no prompts"]:::changed
    B3 --> B9["S9 declared confirmation check, Deploy tier proposed, record checked by the gate against that tier"]:::new
    B9 --> B5["S5 user merges"]
    B5 --> B6["S6 merge-triggered pipeline tags main and publishes"]:::changed
    B6 --> B7["S7 local install refresh, user step unless Design moves it"]
  end
  class A4 removed
```

S4 is removed: the separate hand-run bump, push and PR-ready steps become part of S3's routine steps.
