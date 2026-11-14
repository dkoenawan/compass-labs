<!-- tier: full. Rendering rules: skills/requirements/reference/diagrams.md -->
# Diagrams: Triage skill

> Part of [index](index.md) · Define

## Impact map

```mermaid
mindmap
  root((Triage skill))
    OUT-01 a report every Saturday unprompted
      Maintainer
        Stops having to remember to triage
          REQ-019
          REQ-028
          REQ-022
          REQ-023
          REQ-024
    OUT-02 no unapproved GitHub writes by scheduled runs
      Maintainer
        Approves every change in an apply
          REQ-010
          REQ-011
          REQ-012
          REQ-015
          REQ-025
    OUT-03 every open issue carries a triage comment
      Maintainer and orchestrator
        Read an issue's anchor mapping before picking it up
          REQ-004
          REQ-014
          REQ-016
    OUT-04 every open issue classified with evidence
      Maintainer
        Picks work from an aligned backlog
          REQ-001
          REQ-002
          REQ-003
          REQ-005
          REQ-006
          REQ-008
          REQ-009
          REQ-018
          REQ-028
    OUT-05 runs at the installed local time across DST
      Maintainers of other repositories
        Install triage at their own day time and zone
          REQ-019
```

## Context diagram

```mermaid
flowchart LR
  subgraph SCOPE["Work in scope"]
    T["Triage skill: stock-take, report, apply"]
    S["Schedule install and uninstall"]
  end
  M["Maintainer"] -->|"installs schedule, runs interactive stock-take, confirms groups in apply"| T
  M -->|"day, time, time zone"| S
  O["Other-repo maintainers"] -->|"install with own settings"| S
  C["Machine cron, UTC"] -->|"starts scheduled run"| T
  S -->|"adds or removes one entry"| C
  T -->|"reads issues and merged PRs, creates and closes report issues, applies confirmed actions"| G["GitHub issues and PRs via gh"]
  T -->|"reads code and anchor"| R["Repository working tree and README anchor"]
  T -->|"writes failures"| L["Local run log"]
  A["Orchestrator and phase agents"] -->|"read triage comments"| G
```

## Traceability

```mermaid
flowchart LR
  classDef must fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef should fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef could fill:#F1F5F9,stroke:#475569,color:#0F172A
  O01["OUT-01"]
  O02["OUT-02"]
  O03["OUT-03"]
  O04["OUT-04"]
  O05["OUT-05"]
  N01["NEED-01"]
  N02["NEED-02"]
  N03["NEED-03"]
  N04["NEED-04"]
  R001["REQ-001"]:::must --> O04
  R002["REQ-002"]:::must --> O04
  R002 --> N01
  R003["REQ-003"]:::must --> O04
  R004["REQ-004"]:::must --> O03
  R004 --> N03
  R005["REQ-005"]:::must --> N04
  R005 --> O04
  R006["REQ-006"]:::must --> O04
  R006 --> N03
  R007["REQ-007"]:::should --> N03
  R008["REQ-008"]:::must --> O04
  R008 --> N01
  R009["REQ-009"]:::should --> N01
  R009 --> O04
  R028["REQ-028"]:::must --> O01
  R028 --> O04
  R028 --> N01
  R010["REQ-010"]:::must --> O02
  R010 --> N02
  R011["REQ-011"]:::must --> O02
  R011 --> N02
  R012["REQ-012"]:::must --> N02
  R012 --> O02
  R013["REQ-013"]:::must --> N02
  R014["REQ-014"]:::must --> N02
  R014 --> O03
  R015["REQ-015"]:::must --> N02
  R015 --> O02
  R016["REQ-016"]:::should --> O03
  R016 --> N03
  R017["REQ-017"]:::should --> N02
  R018["REQ-018"]:::could --> N01
  R018 --> O04
  R019["REQ-019"]:::must --> O01
  R019 --> O05
  R019 --> N01
  R019 --> N04
  R020["REQ-020"]:::must --> N04
  R021["REQ-021"]:::should --> N04
  R022["REQ-022"]:::should --> O01
  R022 --> N01
  R023["REQ-023"]:::should --> O01
  R024["REQ-024"]:::should --> O01
  R025["REQ-025"]:::must --> N02
  R025 --> O02
```

## As-is and to-be

```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E,color:#451A03
  classDef new fill:#DCFCE7,stroke:#166534,color:#052E16
  classDef removed fill:#FEE2E2,stroke:#991B1B,color:#450A0A
  subgraph ASIS["As-is"]
    A1["S1 maintainer remembers to triage"] --> A2["S2 interactive stock-take of every open issue"] --> A3["S3 maintainer approves the stock-take"] --> A4["S4 close, merge, rewrite, open, comment"]
  end
  subgraph TOBE["To-be"]
    B0["S0 Saturday 01:00 local, cron starts a run"]:::new --> B2["S2 unattended stock-take, no tests"]:::changed --> B5["S5 report issue published, previous unapplied report closed"]:::new --> B3["S3 maintainer runs apply and confirms each group"]:::changed --> B4["S4 close, merge, rewrite, open, comment"]
    B1["S1 maintainer remembers to triage"]:::removed
  end
```
