---
paths:
  - "docs/sessions/**"
---

# Compass sessions: commit points

Session folders follow the session lifecycle (#22, `docs/sessions/2026-08-19-session-lifecycle/design.md`).

- **Every `decision` or `milestone` entry in a session's `log.md` gets exactly one commit.** That commit contains the log entry *and* the artifact changes the entry describes. A complete set of requirements is recorded as its own `decision` entry, so it gets its own commit.
- **Every ticked task in `tasks.md` gets one commit** containing the code and the tick.
- Drafts still under discussion, with no `decision` entry yet, stay uncommitted.
- At a milestone, the order is: commit, push, then `gh` updates (D5).
- Only the orchestrator writes `log.md`. Phase agents return log entries instead (D4).
