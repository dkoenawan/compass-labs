# Phase agent contract (D4)

Every phase agent in the Feature workflow (`compass-labs:define`, `:design`, `:implement`, `:test`, `:deploy`, `:close`) follows this same contract. It's kept in one place (C8) instead of being duplicated across six agent files — each agent's own `.md` only says which artifact it owns and what its phase does.

## Input

You are started by the orchestrator (never directly by the user) with:

- **Session path** — `docs/sessions/{date}-{slug}/`. Everything you need is on disk under it; nothing carries over from a previous invocation except what's written there.
- **Phase** — your own phase name (matches your `agent_type`'s suffix).
- **Task** — what to do this turn (e.g. "start Define", "continue with the user's answers below", "revise per the user's adjust feedback").
- **Answers**, if you previously returned `needs_input` and the orchestrator is relaying the user's response via `SendMessage` (same conversation only — a paused agent can't be resumed across a session break; the orchestrator re-derives everything it needs from the session folder instead).

## Output

Return, every time:

- **`status`** — one of:
  - `done` — your artifact is ready for the orchestrator to show the user at the milestone gate.
  - `needs_input` — you need the user to answer something before continuing (conversational phases: Define, Design). Include `questions`.
  - `blocked` — you cannot proceed and this isn't something the user can answer through a question (e.g. a broken build, a missing dependency). Say why.
- **`questions`** — only with `needs_input`. Plain text or structured prompts the orchestrator will ask via `AskUserQuestion`.
- **`log_entries`** — zero or more entries in **D2 format** (`### {date} — {actor} — {event type}: {title}`, event type one of `handoff | decision | attempt | milestone | note`) for the orchestrator to append to `log.md` verbatim, under the current `## Phase: {name}` heading. This is how your work gets recorded — you never write `log.md` yourself.
- **`files_changed`** — the file(s) you wrote this turn (should be exactly your own artifact, plus code/tests for Implement).

## Rules

1. **Write only your own artifact.** The guard hook (`hooks/session-guard.sh`) enforces this by `agent_type` — writing anyone else's artifact, or `log.md`, is blocked regardless of what you intend.
2. **Never write `log.md`.** Return `log_entries` instead; only the orchestrator writes the log (Q6 amendment to D4).
3. **A frozen artifact stays frozen.** Once your phase's milestone has been approved, the guard hook blocks further writes to your artifact from any subagent, full stop — not even you can amend it after that point. If something needs to change post-freeze, that's a `decision` the orchestrator logs and applies itself.
4. **State lives in the session folder, not in your memory.** You may be a fresh invocation with no history of a previous attempt; read your own artifact and the session's other frozen artifacts (by ID reference — `REQ-*`, `DES-*`, etc.) rather than assuming continuity.
5. **IDs link artifacts instead of repeating content** (D1). Reference upstream IDs (e.g. a task naming the `DES-*` it implements) rather than re-explaining them.
