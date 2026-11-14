<!-- tier: full -->
# Framing: Triage skill

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** #86 asks for "a triage skill" that "runs on a schedule". The need behind it is a backlog that stays aligned with the project anchor and with merged work, without anyone having to remember to triage it (NEED-01), while nothing on GitHub changes without the maintainer's approval (NEED-02).
- **Outcome:** the need is the aligned backlog, and the skill is the means. The weekly schedule is also a stated requirement for this repo (Saturdays 01:00 Pacific/Auckland), so it stays in the requirements as an install setting (REQ-019), not as the need.

**Candidate solutions:**
- A cloud routine through Claude Code's `schedule` skill. Raised in framing and not chosen: the schedule uses local cron, like the existing scheduled skills (see [Constraints](index.md#constraints)).
- A scheduled run that applies low-risk actions itself, for example closing an issue as completed with the merged PR cited (option (c) in framing). Not chosen for this session. Deferred (see [requirements.md](requirements.md#deferred)).

### Symptom and cause

- **Observed symptom:** before the manual triage of 2026-11-14 there were 47 open issues. 5 were already covered or no longer relevant, 6 duplicated a main issue and 3 needed rewriting [observed: #86 body; log.md, session opened].
- **Cause:** partly known. Most new issues are follow-ups deferred out of Feature sessions, 4 to 6 per session [observed: #86 body]. Why they weren't caught as later work covered them, or as the direction changed, is **unknown**. That no triage ran between sessions because nobody was prompted to run one is [assumed].

## Anchor

- **State:** complete: `README.md` has one marker pair (lines 11 and 44), with Vision, Mission, Scope and Non-goals present and not empty. The Overview's summary of the plugin links to the anchor instead of standing on its own, so it isn't a conflicting restatement.
- **Verdict:** extends
- **Rests on:** Scope: "Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, brand design." Backlog triage isn't among them. Non-goals: "Replacing user approval at milestones". The work stays inside this non-goal because a scheduled run only proposes, and every change to an issue waits for the user's confirmation in an interactive apply (REQ-010, REQ-014, REQ-015). Non-goals: "A runtime, framework or hosted service". This is unaffected, because the schedule is the user's own local cron and no service is hosted.

### Anchor update

- **Action:** extend
- **Elements:** scope
- **Agreed text:**

Replace the Scope line "- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, brand design." with:

- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, backlog triage, brand design.

Approval: the orchestrator relayed this as approved under the user's delegation of every gate through Close (see the decision in log.md). The user's own confirmation is still open; see [Open questions](index.md#open-questions).

## Overlaps

- **Overlap (pattern, not a registry construct):** `doc-maintainer` and `task-executor` each ship an `install-schedule.sh` and an `uninstall-schedule.sh` that register a local cron job per repo. Neither is in `docs/registry/index.md`. The triage schedule should follow the same install and uninstall convention instead of adding a different one. Note that `task-executor`'s installer takes the time in UTC and has no time-zone guard, which REQ-019 needs.
- **Overlap (pattern):** `task-executor/scripts/comment-on-issue.sh` already posts issue comments through `gh`. Design should look at reusing it.
- **Registry constructs:** no construct's "Does" column covers listing, classifying or triaging issues. None found.
- **Conflicts with recorded decisions:** none found. ADR-006 (session work reaches the default branch only through a pull request) would apply only if a run committed or pushed, and REQ-010 rules that out for scheduled runs. ADR-002 and ADR-003 aren't affected.
