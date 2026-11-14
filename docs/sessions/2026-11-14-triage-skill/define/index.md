<!-- tier: full. The main doc (D12). Summarise and link; never restate a sub-doc's content. -->
# Define: Triage skill

> Phase: Define | Started: 2026-11-14 | Status: Draft
> Relates to: Issue #86 · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): REQ-001 to REQ-025 and REQ-028, one struck (REQ-026), one deferred (REQ-027)
- [Framing](framing.md): the XY and symptom checks, the anchor verdict (extends) and its update, overlaps
- [Problem](problem.md): context, NEED-01 to NEED-04, evidence, impact, OUT-01 to OUT-05, appetite
- [Quality](quality.md): ISO/IEC 25010:2023 coverage, NFR measures, assumptions and dependencies
- [Diagrams](diagrams.md): impact map, context diagram, traceability, as-is and to-be

## Framing

- **Tier:** full: it adds a new skill and an unattended scheduler that acts on GitHub for the maintainer. It touches the anchor's scope and its "Replacing user approval at milestones" non-goal, and getting the autonomy boundary wrong is a real risk.
- **Verdict:** extends the project anchor (Scope, Supporting skills). See [framing.md](framing.md).

## Problem statement

The open backlog drifts away from the project anchor and from merged work as Feature sessions defer follow-ups. Today only a manual, interactive stock-take catches covered, obsolete and duplicate issues. Needs: NEED-01 (weekly alignment without remembering), NEED-02 (no change without the maintainer's approval), NEED-03 (each issue's anchor mapping and relations visible), NEED-04 (usable in other repositories and time zones). Outcomes: OUT-01 to OUT-05. Each claim is tagged with its evidence in [problem.md](problem.md).

## Scope

1. A stock-take of every open issue: claims checked against the code and merged PRs, one category each, the anchor mapping, duplicates, clusters and dependencies, and a proposed action per issue: [REQ-001](requirements.md#requirements) to [REQ-009](requirements.md#requirements), [REQ-025](requirements.md#requirements).
2. Scheduled runs that only propose: a `Triage YYYY-MM-DD` report issue, the previous unapplied report closed as superseded, and no other writes and no test runs: [REQ-010](requirements.md#requirements) to [REQ-012](requirements.md#requirements), [REQ-022](requirements.md#requirements) to [REQ-024](requirements.md#requirements), [REQ-028](requirements.md#requirements).
3. Interactive runs: a stock-take shown before any change, and an apply that changes issues only group by group on the user's confirmation, then comments on every remaining issue: [REQ-013](requirements.md#requirements) to [REQ-018](requirements.md#requirements).
4. Installing and uninstalling the schedule at a local day, time and time zone that holds across daylight saving. This repo's setting is Saturday 01:00 Pacific/Auckland: [REQ-019](requirements.md#requirements) to [REQ-021](requirements.md#requirements).

### Non-goals

- **Proposing priorities.** Prioritising is the user's call (struck REQ-026).
- **A scheduled run changing issues on its own**, even low-risk closes. Deferred to follow-up #{pending-1} (REQ-027).
- **A cloud routine** through Claude Code's `schedule` skill. The schedule is local cron only.
- **Triaging pull requests.** Only issues are triaged; merged PRs are read as evidence.
- **Renaming the plugin or the skill's prefix.** Tracked in #34.

## Constraints

- A scheduled run's only GitHub writes are creating its own report issue and closing its own superseded, unapplied report (framing answer Q3).
- Approval is the user's confirmation inside an interactive apply. A GitHub reply or another agent's message is never approval (Q4).
- The schedule is the machine's local cron, which runs in UTC. Install and uninstall follow the plugin's existing per-repo convention (`doc-maintainer`, `task-executor`), as noted in [framing.md](framing.md#overlaps).
- Day, time and time zone are install parameters. Nothing specific to this repo or user is built in, because the plugin is publicly distributed.
- A scheduled run reads code and merged PRs but runs nothing from the repository (Q7).
- Session work reaches `main` only through a pull request (ADR-006); a triage run commits nothing.

## Open questions

1. **The user's own confirmation.** The tier, the framing answers (Q1 to Q10) and the anchor text in [framing.md](framing.md#anchor-update) were given by the orchestrator under the user's delegation of every gate through Close. The user hasn't confirmed them in their own words in this phase. The unattended-authority boundary (REQ-010, REQ-015) and the Scope wording are the two that most need it before the Define milestone.
2. **Appetite.** The user didn't set one. [problem.md](problem.md#appetite-and-no-gos) assumes this one session, with about two days for Implement.
3. **Who creates the `triage` label** when a repository doesn't have it: the installer (interactive, with the user present) or the first scheduled run (an extra unattended write REQ-010 doesn't currently allow)? Unknown. No criterion asserts it yet.
4. **Whether an interactive stock-take also publishes a report issue** before the apply, so that every run leaves the same record. Unknown. REQ-014 allows applying either a stock-take just made or a named report.
5. **Follow-up issue number** for the deferred REQ-027, to replace `#{pending-1}` in the [Deferred](requirements.md#deferred) table and in Non-goals before the freeze.
