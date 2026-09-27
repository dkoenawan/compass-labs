<!-- tier: full -->
# Diagrams: Self-service password reset for the team wiki

> Part of [index](index.md) · Define

## Impact map

```mermaid
mindmap
  root((Self-service password reset))
    OUT-01 access regained in under 10 minutes
      Wiki members
        Reset their own password
          REQ-001
          REQ-002
          REQ-005
    OUT-02 admin reset time under 30 minutes a week
      Wiki admins
        Stop handling routine resets
          REQ-001
        Check resets in the audit log instead
          REQ-006
```

## Context diagram

```mermaid
flowchart LR
  subgraph SCOPE["Work in scope: password reset"]
    W["Reset form and set-password page"]
  end
  M["Wiki members"] -->|"request a link, set a new password"| W
  A["Wiki admins"] -->|"read resets in the audit log"| W
  W -->|"send reset email via Notifier"| E["Email service"]
  E -->|"deliver reset link"| M
  W -.->|"later, #88"| S["Single sign-on"]
```

## Traceability

A small set with few crossing links, so a `requirementDiagram` is the easier one to review. REQ-003, REQ-004 and REQ-009 serve a need alone, so NEED-01 appears too. Struck REQ-007 and deferred REQ-008 are left out.

```mermaid
requirementDiagram
  requirement R001 {
    id: "REQ-001"
    text: "Email a reset link to the account address"
    risk: medium
    verifymethod: test
  }
  requirement R002 {
    id: "REQ-002"
    text: "Refuse expired or used links"
    risk: high
    verifymethod: test
  }
  requirement R003 {
    id: "REQ-003"
    text: "End open sessions after a reset"
    risk: medium
    verifymethod: test
  }
  requirement R004 {
    id: "REQ-004"
    text: "Same confirmation for unknown addresses"
    risk: high
    verifymethod: test
  }
  performanceRequirement R005 {
    id: "REQ-005"
    text: "Hand off the email within 10 seconds p95"
    risk: medium
    verifymethod: test
  }
  requirement R006 {
    id: "REQ-006"
    text: "Record resets in the audit log"
    risk: low
    verifymethod: inspection
  }
  requirement R009 {
    id: "REQ-009"
    text: "Keyboard and screen-reader usable"
    risk: low
    verifymethod: demonstration
  }
  element O01 {
    type: "outcome"
    docref: "OUT-01"
  }
  element O02 {
    type: "outcome"
    docref: "OUT-02"
  }
  element N01 {
    type: "need"
    docref: "NEED-01"
  }
  R001 - traces -> O01
  R001 - traces -> O02
  R002 - traces -> O01
  R005 - traces -> O01
  R006 - traces -> O02
  R003 - traces -> N01
  R004 - traces -> N01
  R009 - traces -> N01
```

## As-is and to-be

The same step IDs in both. Admin steps are removed; the member's steps change, and the audit-log step is new.

```mermaid
flowchart TD
  classDef changed fill:#FEF3C7,stroke:#92400E
  classDef new fill:#DCFCE7,stroke:#166534
  classDef removed fill:#FEE2E2,stroke:#991B1B
  subgraph ASIS["As-is"]
    A1["S1 member asks an admin in chat"] --> A2["S2 admin checks who is asking"]:::removed
    A2 --> A3["S3 admin sets a temporary password"]:::removed
    A3 --> A4["S4 member logs in and changes it"]
  end
  subgraph TOBE["To-be"]
    B1["S1 member submits the reset form"]:::changed --> B2["S2 wiki emails a single-use link"]:::changed
    B2 --> B3["S3 member sets a new password"]:::changed
    B3 --> B4["S4 member logs in"]:::changed
    B3 --> B5["S5 wiki records the reset in the audit log"]:::new
  end
```
