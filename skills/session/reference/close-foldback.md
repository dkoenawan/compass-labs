# Close fold-back procedure (D6)

This is what the Close phase agent actually does, kept out of `agents/close.md` itself so that file stays a thin D4 wrapper (C8).

Close produces **no session artifact** of its own (`artifact: null` in `feature.json`). Your job is to turn the finished session into as-built documentation, not to archive the folder yourself — the orchestrator does the archive move, after you're done, using its own script (see "What you don't do" below).

## Steps

1. **Read, don't write, the session's own record**: the frozen `requirements.md`, `design.md`, and `log.md`'s **Key decisions** section (never write `log.md` — you return `log_entries` like every other phase agent).
2. **Run a `doc-maintainer` pass** to update the repo's as-built docs:
   - `docs/reference/` and `docs/explanation/` — reflect what's now true about the system, not what happened to get there.
   - `docs/registry/index.md` and `docs/reference/constructs/*.md` — flip any construct this session built from `planned` to `built` (or add new ones the session introduced), the same way `task-executor` does per-task.
   - **No session narrative anywhere in as-built docs.** No "we discussed," no "first we tried X, then...". That story stays in the archived session folder, not in the flat docs.
   - Add exactly **one `Origin: #{issue}` line** to each doc file you touch — a stable pointer back to the session's GitHub issue (which persists after archive; the session path inside the archived folder is the fuller "why," reachable from the issue if anyone needs it).
3. **Return `done`** with `log_entries` including one `milestone` entry (e.g. `✅ Session closed — folded requirements/design into <list of doc files>`) summarizing what was folded back and where. The orchestrator appends it, then does the archive move itself (see below) — that's what actually finishes the session.

## What you don't do

- You don't flip `log.md`'s `status` to `archived` — the orchestrator does, since it owns every write to `log.md`.
- You don't run `git mv` or `${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/archive-session.sh` — the script itself refuses to run until `status: archived` is already committed (so the guard hook's file set stays correct at every point: nothing should try to write under `docs/sessions/{id}/` *after* the move, since everything past that point is under `archive/`, which the guard always blocks). The **order** the orchestrator follows is spelled out in `skills/session/SKILL.md`'s Close-milestone section — you don't need to enforce it yourself, just don't try to do the move.

## If fold-back can't proceed

Return `blocked` (not `needs_input` — you can't ask the user mid-fold-back) if, for example, a `REQ-*` has no sensible home in the existing `docs/` structure and you can't reasonably invent one. Say what's missing; the orchestrator surfaces it to the user.
