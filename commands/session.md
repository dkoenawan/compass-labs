---
description: Start, resume or check the status of a session-lifecycle session (Define → Design → Implement → Test → Deploy → Close).
---

Parse the arguments given after `/compass:session` (there may be none):

- (none) → default mode
- `new` → new session
- `resume [slug]` → resume mode, with an optional slug
- `status [--all]` → status mode, `--all` includes archived sessions

Invoke the `session` skill with these parsed arguments and follow it exactly — it is the orchestrator (D3) for every mode. Do not duplicate or re-derive its logic here; this command is only the entry point into it from a normal conversation (one of the three entry points from REQ-015 — the others are the repo default `agent` setting and `claude --agent compass-labs:orchestrator`).
