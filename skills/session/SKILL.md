---
name: session
description: Orchestrates a Feature session end-to-end (Define → Design → Implement → Test → Deploy → Close) — starts or resumes a session, hands off to one phase agent per phase, relays questions to the user, gates each milestone (commit → push → gh), and checks REQ↔VER traceability before Test completes.
---

# Session Skill

You are the orchestrator (D3). You run in the **main session** — never as a subagent — because only the main session can ask the user questions (P2). Your job is to keep `docs/sessions/{date}-{slug}/` moving through its workflow, one phase at a time, using only what's in the session folder (state lives on disk, not in conversation memory — REQ-008).

Everything below is the Feature workflow. Other session types (Bugfix, Research) get their own workflow files later (#24/#25) and reuse this same skill.

## Mode dispatch (Phase 0)

| Invocation | Mode |
|---|---|
| `/compass:session` (no args), or starting as `compass-labs:orchestrator` | **Default**: list active/paused sessions, then ask new vs. resume |
| `/compass:session new` | **New** session flow |
| `/compass:session resume [slug]` | **Resume** flow. No slug → show the list and ask |
| `/compass:session status [--all]` | **Status**: list sessions (`--all` includes archived) |

To list sessions: scan `docs/sessions/*/log.md` frontmatter for `status: active` or `status: paused` (`--all` also includes `archived`). A `SessionStart` hook (`hooks/session-start.sh`, task 6's sibling) injects this list as context when you start as the orchestrator agent — if that context isn't present, scan the folders yourself.

## One-time setup

Run once per repo, the first time `/compass:session` is used in it:

1. `bash skills/session/scripts/gh-setup.sh` — creates every `phase:*` and `type:*` label (idempotent; safe to re-run).
2. Copy the commit-point rule into the repo: **TODO (task 14)** — `skills/session/templates/rules/compass-sessions.md` → `.claude/rules/compass-sessions.md`. Until task 14 lands, skip this step; it's not yet blocking.

## New session flow

1. **Issue**: ask for an existing issue number, or create one (`gh issue create --title … --label type:feature`). Store the number.
2. **Slug**: derive `{today}-{kebab-title}`. Create `docs/sessions/{slug}/`.
3. **Folder, in order** (the guard hook requires log.md to exist before anything else — D7):
   - `log.md` from `skills/session/templates/log.md`, frontmatter filled in (`session`, `type: feature`, `issue`, `phase: define`, `status: active`, `milestone: none`, `active_agent: main`, `next_step`).
   - `requirements.md` from `skills/session/templates/requirements.md` (thin — Define fills it in).
4. Commit + push (`docs(sessions): open session #{issue}`), **then** `bash skills/session/scripts/gh-milestone.sh {issue} none define {comment-file}` where the comment file says "Session opened." — this applies `phase:define` + `type:feature` and posts the opening comment (D5, order: commit → push → gh).
5. Enter the **main loop** at `define`.

## Resume flow

Read `log.md`: frontmatter, **Open items**, **Key decisions**, and the last entry under the current `## Phase:` section. Recap to the user in that order — this is the whole pickup contract (REQ-008; D2's "test for it"). Then re-enter the main loop at frontmatter `phase`.

## Main loop (per phase — D3, D4)

1. **Handoff.** Start (or resume via `SendMessage`, same conversation only — P4) `compass-labs:{phase}` with: session path, phase name, task, and any answers being relayed. Log a `handoff` entry (D2) once you have the input to record.
2. **Contract.** The agent returns `status` (`done` | `needs_input` | `blocked`), `questions`, `log_entries`, `files_changed` (D4). It writes only its own artifact — you write `log.md`, always (Q6 amendment: never a subagent).
   - `needs_input` → ask the `questions` via `AskUserQuestion`, then `SendMessage` the answers back to the same agent. Repeat until `done` or `blocked`.
   - `blocked` → surface the reason to the user; don't silently retry.
3. **Append.** Add every entry from `log_entries` to `log.md` verbatim, in D2 format, under the current `## Phase: {name}` heading. Update frontmatter `active_agent` / `next_step`.
4. **Milestone gate**, once the agent returns `done` with its artifact ready:
   - Show the artifact (or a summary of it) to the user. `AskUserQuestion`: approve / adjust / rethink.
   - **Adjust/rethink** → relay back to the agent (still the same phase; not a new handoff phase).
   - **Approve**:
     a. **Test milestone only** (REQ-011): before anything else, run `bash skills/session/scripts/check-traceability.sh {session-dir}`. Exit 1 → refuse the milestone, show the missing `REQ-*` ids, stay in Test.
     b. Set `log.md` frontmatter: `milestone: {completed phase key}`, `phase: {next phase key}` (from `workflows/feature.json`'s `phases[].phase` order — see the milestone-key note below).
     c. Append a `milestone` entry (D2).
     d. `git commit` + `git push` (D5 order — commit and push *before* any `gh` call, so links resolve).
     e. `bash skills/session/scripts/gh-milestone.sh {issue} {from-phase} {to-phase} {comment-file}`.
     f. If its output contains a `SYNC_PENDING:` line, log a `note` entry quoting it ("GitHub sync pending") — do **not** retry inline; the next milestone gate re-runs `gh-milestone.sh` first, per D5's "next milestone runs any pending sync first."
   - Move to the next phase in `workflows/feature.json`. If the completed phase was `close`, the session is done — nothing to hand off.

**Milestone-key note:** `log.md` frontmatter `milestone` holds the **phase key** of the last completed milestone (`none | define | design | implement | test | deploy | close`), not a display label. `workflows/feature.json`'s own `phases[].milestone` field *is* the display label ("Define complete", …) — use it only for user-facing text and `gh-milestone.sh` comment bodies. The guard hook (`hooks/session-guard.sh`) depends on this key to compute which artifacts are frozen — see `skills/session/templates/log.md`'s frontmatter comment.

## Follow-up issue creation (REQ-013)

When work is deferred during any phase, create the issue immediately (don't batch it):

```
gh issue create --title "{title}" --body "Origin: session docs/sessions/{slug}/ (parent #{issue})
Decision: {one-line decision/reason this was deferred}"
```

Log a `decision` entry noting the new issue number, and list it under `log.md`'s Open items or the artifact's own follow-up list (whichever the phase's standard calls for).

## Atomic commits (D8)

One commit per `decision`/`milestone` log entry, and one per ticked `tasks.md` task — see `.claude/rules/compass-sessions.md` (or the template copy, until task 14 wires it in) and `hooks/session-commit-guard.sh` (task 14). You are the one writing `log.md`, so you are the one this rule binds most: never let a turn end with a logged decision/milestone whose artifact changes aren't committed yet.

## Scripts this skill uses

| Script | Purpose |
|---|---|
| `skills/session/scripts/gh-setup.sh` | One-time label creation (D5) |
| `skills/session/scripts/gh-milestone.sh` | Label swap + milestone comment, idempotent, fails open with `SYNC_PENDING` (D5, REQ-009/010) |
| `skills/session/scripts/check-traceability.sh` | REQ-011 gate: every `REQ-*` has a passing `VER-*` |

## C8 note

If this file grows past ~250 lines as later issues (#26–#30) deepen each phase, move the detail into `skills/session/reference/*.md` and link it from here — don't let this file take on more than one job (orchestration) at a time.
