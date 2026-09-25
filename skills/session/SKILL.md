---
name: session
description: Orchestrates a Feature session end-to-end (Define → Design → Implement → Test → Deploy → Close) — starts or resumes a session, hands off to one phase agent per phase, relays questions to the user, gates each milestone (commit → push → gh), and checks REQ↔VER traceability before Test completes.
argument-hint: "[new | resume [slug] | status [--all]]"
---

# Session Skill

You are the orchestrator (D3). You run in the **main session** — never as a subagent — because only the main session can ask the user questions (P2). Your job is to keep `docs/sessions/{date}-{slug}/` moving through its workflow, one phase at a time, using only what's in the session folder (state lives on disk, not in conversation memory — REQ-008).

Everything below is the Feature workflow. Other session types (Bugfix, Research) get their own workflow files later (#24/#25) and reuse this same skill.

**Path note:** every script and template this skill references lives inside the plugin, not the consuming repo. Always resolve them as `${CLAUDE_PLUGIN_ROOT}/skills/session/…` — Claude Code substitutes `${CLAUDE_PLUGIN_ROOT}` with the plugin's actual install directory wherever it appears in a skill's own markdown, so this works whether you're developing the plugin itself or running it installed in some other repo. Never write a bare `skills/session/…` path — that only happens to resolve while developing inside compass-labs itself, and silently breaks everywhere else. `docs/sessions/…` paths, by contrast, are always repo-relative (they're the *consuming* repo's own session folders, not plugin files) and stay as-is. Resolve them against the project's git root (`git rev-parse --show-toplevel` from the working directory) — **never** against `${CLAUDE_PLUGIN_ROOT}`: the plugin ships its own `docs/sessions/`, and listing or resuming from there reports the plugin's sessions instead of the user's.

## Mode dispatch (Phase 0)

Arguments passed to this skill: `$ARGUMENTS` (empty when there are none, or when this skill was preloaded or read from disk rather than invoked as a slash command — treat that as the default mode). This skill **is** the slash command: plugin skills are user-invocable as `/compass-labs:session …`, so there is deliberately no `commands/session.md` (a command of the same name would shadow this skill for the Skill tool and for the orchestrator's `skills:` preload — VER-021).

| Invocation | Mode |
|---|---|
| `/compass-labs:session` (no args), or starting as `compass-labs:orchestrator` | **Default**: list active/paused sessions, then ask new vs. resume |
| `/compass-labs:session new` | **New** session flow |
| `/compass-labs:session resume [slug]` | **Resume** flow. No slug → show the list and ask |
| `/compass-labs:session status [--all]` | **Status**: list sessions (`--all` includes archived) |

To list sessions: scan `docs/sessions/*/log.md` frontmatter for `status: active` or `status: paused` (`--all` also includes `archived`). A `SessionStart` hook (`${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh`, task 7) injects this list as context when you start as the orchestrator agent — if that context isn't present, scan the folders yourself.

## One-time setup

Run once per repo, the first time `/compass-labs:session` is used in it:

1. `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/gh-setup.sh` — creates every `phase:*` and `type:*` label (idempotent; safe to re-run).
2. Copy the commit-point rule into the repo, **only if it isn't already there**: if `.claude/rules/compass-sessions.md` doesn't exist, copy `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/rules/compass-sessions.md` to it (a repo-relative destination — rules live in the consuming repo, not the plugin). Never overwrite an existing `.claude/rules/compass-sessions.md` — the repo may have customized it.

## New session flow

1. **Issue**: ask for an existing issue number, or create one (`gh issue create --title … --label type:feature`). Store the number.
2. **Slug**: derive `{today}-{kebab-title}`. Create `docs/sessions/{slug}/`.
3. **Folder, in order** (the guard hook requires log.md to exist before anything else — D7):
   - `log.md` from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/log.md`, frontmatter filled in (`session`, `type: feature`, `issue`, `phase: define`, `status: active`, `milestone: none`, `active_agent: main`, `next_step`).
   - `requirements.md` from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/requirements.md` (thin — Define fills it in).
4. Commit + push (`docs(sessions): open session #{issue}`), **then** `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/gh-milestone.sh {issue} none define {comment-file}` where the comment file says "Session opened." — this applies `phase:define` + `type:feature` and posts the opening comment (D5, order: commit → push → gh).
5. Enter the **main loop** at `define`.

## Resume flow

Read `log.md`: frontmatter, **Open items**, **Key decisions**, and the last entry under the current `## Phase:` section. Recap to the user in that order — this is the whole pickup contract (REQ-008; D2's "test for it"). Then re-enter the main loop at frontmatter `phase`.

## Main loop (per phase — D3, D4)

1. **Handoff — logged every time, before the agent starts** (REQ-007). Every phase-agent start through the `Agent` tool gets its own `handoff` entry — the first start in a phase, a restart after `blocked`, a fresh agent replacing one `SendMessage` couldn't reach, a fix pass after a freeze. No exceptions, and never "once you have enough to record": append it **before** calling `Agent`:
   ```
   ### {date} — main — handoff: orchestrator → compass-labs:{phase} ({task, a few words})
   - **Input:** {task}; {answers relayed, if any}
   ```
   Then start `compass-labs:{phase}` with: session path, phase name, task, and any answers being relayed. Relaying answers to the **same** running agent via `SendMessage` (same conversation only — P4) continues that invocation and needs no new handoff entry. When the agent returns, add an `- **Output:** {status}; {files_changed}` bullet to your handoff entry before appending anything below it.
2. **Contract.** The agent returns `status` (`done` | `needs_input` | `blocked`), `questions`, `log_entries`, `files_changed` (D4). It writes only its own artifact — you write `log.md`, always (Q6 amendment: never a subagent).
   - `needs_input` → ask the `questions` via `AskUserQuestion`, then `SendMessage` the answers back to the same agent. Repeat until `done` or `blocked`.
   - `blocked` → surface the reason to the user; don't silently retry.
3. **Append.** Add the entries from `log_entries` to `log.md` in D2 format, under the current `## Phase: {name}` heading, verbatim **except**:
   - **A phase agent's `milestone` entry is never appended as a milestone.** Milestones are the user's to grant at the gate (step 4), and only you write them (step 4c). Downgrade it: rewrite its event type to `note` (keep the title and body) and append that. Don't mirror it into Key decisions, and don't treat it as approval.
   - Every `decision` entry — the agent's or your own — is also **mirrored into Key decisions** (see below) in the same edit.

   Update frontmatter `active_agent` / `next_step`.

   **Key decisions mirror (REQ-007).** Every `decision` and every `milestone` entry you append to a phase section also gets a one-line bullet at the top of `## Key decisions` (newest first), written in the **same edit** so the two land in the same commit: `- **{date}**: {one line}` for a decision, `- **{date}**: ✅ {milestone label} — {one line}` for a milestone. A decision that exists only as a `note`, or only in a phase section, is a logging defect — if you find one, add the missing bullet.
4. **Milestone gate**, once the agent returns `done` with its artifact ready:
   - Show the artifact (or a summary of it) to the user. `AskUserQuestion`: approve / adjust / rethink.
   - **Adjust/rethink** → relay back to the agent (still the same phase; not a new handoff phase).
   - **Approve**:
     a. **Test milestone only** (REQ-011): before anything else, run `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/check-traceability.sh {session-dir}`. Exit 1 → refuse the milestone, show the missing `REQ-*` ids, stay in Test.
     a2. **Deploy milestone only** (never ship an incomplete product): before anything else, check `release.md`'s *Completeness* section says the release manifest lists only complete components and leaves none out. Missing, or any gap named → refuse the milestone, show the gaps, stay in Deploy.
     b. Set `log.md` frontmatter: `milestone: {completed phase key}`, `phase: {next phase key}` (from `${CLAUDE_PLUGIN_ROOT}/skills/session/workflows/feature.json`'s `phases[].phase` order — see the milestone-key note below).
     c. Append a `milestone` entry (D2), actor `main`, and its ✅ bullet under Key decisions in the same edit (see the mirror rule in step 3).
     d. **Stage explicitly, then commit + push** (D5 order — commit and push *before* any `gh` call, so the milestone comment's links resolve):
        - Precondition: `git status --porcelain` may show only this milestone's own changes — the phase's artifact (`feature.json`'s `phases[].artifact` for the completed phase, e.g. `design.md`), `log.md`, and the session's `assets/`. Code and tests are committed per task during Implement (D8), so anything else uncommitted is either an unfinished task or unrelated work: don't bundle it into the milestone commit — surface it to the user and resolve it first.
        - `git add docs/sessions/{slug}/{artifact} docs/sessions/{slug}/log.md` (plus `docs/sessions/{slug}/assets/` if it exists). Name the paths — never rely on `git commit -a` or on an earlier add: a new artifact is **untracked** until you add it, and a milestone commit without it freezes an artifact that was never pushed (VER-013).
        - Check `git diff --cached --name-only` lists the artifact (unless it's already committed unchanged), then `git commit -m "docs(sessions): {milestone label} — #{issue}"` + `git push`.
     e. `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/gh-milestone.sh {issue} {from-phase} {to-phase} {comment-file}`.
     f. If its output contains a `SYNC_PENDING:` line, log a `note` entry quoting it ("GitHub sync pending") — do **not** retry inline; the next milestone gate re-runs `gh-milestone.sh` first, per D5's "next milestone runs any pending sync first."
   - Move to the next phase in `feature.json`. **The `close` phase is special — see below** instead of following steps b–f as written.

**Milestone-key note:** `log.md` frontmatter `milestone` holds the **phase key** of the last completed milestone (`none | define | design | implement | test | deploy | close`), not a display label. `feature.json`'s own `phases[].milestone` field *is* the display label ("Define complete", …) — use it only for user-facing text and `gh-milestone.sh` comment bodies. The guard hook (`${CLAUDE_PLUGIN_ROOT}/hooks/session-guard.sh`) depends on this key to compute which artifacts are frozen — see `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/log.md`'s frontmatter comment.

## Close milestone (special ordering — D6, D8)

Close has no artifact and ends the session, so its milestone gate replaces steps b–f above with this **exact order** — getting this wrong either archives a folder the guard will then block further legitimate writes to, or leaves `log.md` claiming `archived` while the folder is still live:

1. Append the final `milestone` entry to `log.md` (e.g. `✅ Session closed — …`) with its Key decisions bullet, **and in the same edit** set frontmatter `milestone: close`, `status: archived`. (`log.md` is the one file always writable — see below — so this is safe to do before the move.)
2. `git add docs/sessions/{slug}/log.md` **plus every doc the Close agent returned in `files_changed`** (the fold-back edits under `docs/reference/`, `docs/explanation/`, `docs/registry/`), then `git commit` — one atomic commit (D8: the log entry, the frontmatter flip that makes it true, and the fold-back it describes belong together). Afterwards `git status --porcelain` must be empty; if it isn't, resolve that before step 3 (`archive-session.sh` refuses a dirty tree).
3. `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/archive-session.sh {session-dir}` — it refuses unless step 2 is already committed and the tree is clean, then does the `git mv` into `docs/sessions/archive/{slug}/`.
4. `git add`+`git commit` (the move itself, separate from step 2's commit).
5. `git push`.
6. `bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/gh-milestone.sh {issue} deploy close {comment-file}`, then `gh issue close {issue} --comment "…"` (D5's milestone table: Closed = PR merged, follow-ups confirmed, final comment, issue closed).

Why `log.md` first, archive second: the guard hook always allows the orchestrator to write `log.md` (never a subagent), but once the folder is under `docs/sessions/archive/`, the guard blocks **every** write there, orchestrator included. Setting `status: archived` has to happen while the folder is still at its live path, not after.

## Follow-up issue creation (REQ-013)

When work is deferred during any phase, create the issue immediately (don't batch it):

```
gh issue create --title "{title}" --body "Origin: session docs/sessions/{slug}/ (parent #{issue})
Decision: {one-line decision/reason this was deferred}"
```

Log a `decision` entry noting the new issue number, and list it under `log.md`'s Open items or the artifact's own follow-up list (whichever the phase's standard calls for).

## Atomic commits (D8)

One commit per `decision`/`milestone` log entry, and one per ticked `tasks.md` task — see `.claude/rules/compass-sessions.md` (repo-relative; copied from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/rules/compass-sessions.md` by the one-time setup step above) and `${CLAUDE_PLUGIN_ROOT}/hooks/session-commit-guard.sh`, which enforces it on `Stop`. You are the one writing `log.md`, so you are the one this rule binds most: never let a turn end with a logged decision/milestone whose artifact changes aren't committed yet — the hook will block the stop if you try. Its loop guard: it blocks at most **2 times in a row** within one turn, then allows the stop with a warning (the count restarts on each fresh, non-hook-forced stop — `stop_hook_active: false`). An allowed-with-warning stop means the entry is still uncommitted: commit it next turn.

## Scripts this skill uses

All under `${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/`:

| Script | Purpose |
|---|---|
| `gh-setup.sh` | One-time label creation (D5) |
| `gh-milestone.sh` | Label swap + milestone comment, idempotent, fails open with `SYNC_PENDING` (D5, REQ-009/010) |
| `check-traceability.sh` | REQ-011 gate: every `REQ-*` has a passing `VER-*` |
| `archive-session.sh` | Close milestone only: `git mv` a session into `docs/sessions/archive/`, refusing unless `status: archived` is already committed and the tree is clean (D6) |

## C8 note

If this file grows past ~250 lines as later issues (#26–#30) deepen each phase, move the detail into `${CLAUDE_PLUGIN_ROOT}/skills/session/reference/*.md` and link it from here — don't let this file take on more than one job (orchestration) at a time.
