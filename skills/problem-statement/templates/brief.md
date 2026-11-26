---
issue: {#N or none}
branch: {branch}
date: {YYYY-MM-DD}
anchor: {the anchor line this serves, quoted, or "none"}
---

# {Short problem title}

**Need:** {one line: what's wrong or missing} {evidence tag}
**Who:** {who has the need, and when they hit it}
**Why now:** {one line: cost of leaving it}

```mermaid
flowchart LR
  subgraph Now
    a1[{current step}] --> a2[{where it goes wrong}]
  end
  subgraph After
    b1[{current step}] --> b2[{what changes}]
  end
```

**Success check:**
- {observable check 1}
- {observable check 2, optional}

**Out of scope:** {one line}

**Assumptions:**
- ⚠ {the assumption that matters most if it's wrong}
- {other assumption}
