<!-- tier: full -->
# Problem: Triage skill

> Part of [index](index.md) · Define

### Context

**Situation:** each Feature session defers 4 to 6 follow-ups to new GitHub issues [observed: #86 body], so the open backlog grows with every session. The only check of the backlog against the project anchor and against merged work is a manual stock-take run interactively by the maintainer, as on 2026-11-14 [observed: log.md, session opened].

**Complication:** the backlog had drifted. On 2026-11-14, 10 of 47 open issues were already covered by merged work, made obsolete by a change of direction, or duplicates, and 3 more needed rewriting [observed: #86 body]. Spotting this took a full interactive run, with the maintainer reading every issue's body, checking claims against the code and merged PRs, and approving the stock-take before anything was closed [observed: the user's approval, "Yes let's close them out. and merge. Rest of them, make a comment…"].

### Need and stakeholders

- **NEED-01:** When Feature sessions keep adding follow-up issues, the **compass-labs maintainer** (the person who approves sessions and picks the next work) wants the open backlog checked against the project anchor and merged work every week, without having to remember to start it, so they can pick the next work from a backlog that reflects the project's current direction.
- **NEED-02:** When a triage proposes closing, merging, rewriting or opening issues, the **maintainer** wants to review and confirm each group of changes before anything changes on GitHub, so that no issue is changed without their approval (the anchor's non-goal "Replacing user approval at milestones").
- **NEED-03:** When the maintainer, or the orchestrator opening a session, reads an open issue, they want it to say how it maps to the anchor's vision, mission, scope and non-goals, and which issues it duplicates, belongs with or is blocked by, so they can see whether it's in scope and what must happen first.
- **NEED-04:** When a **maintainer of another repository that uses compass-labs** adopts triage, they want to run it at their own local day and time, and in a repository with no project anchor, so they can use it without adopting this repo's settings.

### Evidence

- The 2026-11-14 manual triage took the backlog from 47 open issues to 37: 5 closed as covered or no longer relevant, 6 merged into their main issues, 1 replacement opened (#85), 3 rewritten, and every remaining issue given a triage comment [observed: #86 body; log.md].
- Most new issues are follow-ups deferred out of Feature sessions, 4 to 6 per session [observed: #86 body].
- Checking issues against the code turned up at least one claim that needed a test run to confirm: #69 still fails [observed: the orchestrator's account of the reference run].
- One issue (#69) blocks others (the layer issues) [observed: the orchestrator's answer to Q8].
- The maintainer approved the stock-take before any issue was closed, merged or commented [observed: the user's message in the reference run].
- Without a prompt, triage doesn't happen between sessions [assumed].
- The backlog will drift again at the same rate as Feature sessions keep running [assumed].
- Issue bodies are written by people and by agents, and an unattended run reading them could be steered by text in them [assumed].

### Impact and why now

- **If nothing changes:** the maintainer picks work from a backlog where about one issue in five is stale or duplicated (10 of 47 on 2026-11-14 [observed: #86 body]), and has to spend an interactive session catching up each time it's noticed. Agents that read issues to frame sessions take stale or superseded issue text at face value [assumed].
- **Why now:** a manual run has just been done and approved, so its six outcome categories and its comment format are a tested reference to build from [observed: the reference comments on #45, #72, #47, #24, #29, #85]. The backlog is at a clean baseline of 37, so a weekly run starts from a known state.

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | `Triage YYYY-MM-DD` report issues labelled `triage` created by scheduled runs, with nobody starting them | One report for each Saturday, for 4 Saturdays in a row | 4 weeks after release, from `gh issue list --label triage --state all` | NEED-01 |
| OUT-02 | GitHub writes made by scheduled runs, other than creating their own report issue and closing their own superseded report | Zero | At Test, by inspecting the issue events of a test repo after a scheduled run; and again 4 weeks after release | NEED-02 |
| OUT-03 | Issues still open after an apply that carry a `**Triage (YYYY-MM-DD):**` comment giving the category and the anchor mapping | Every issue that was open when the report was made and is still open | After the first apply on this repo | NEED-03 |
| OUT-04 | Open issues that appear in a report with a category, a proposed action and the evidence it rests on | Every open issue, except triage report issues | At Test, by comparing a report with `gh issue list --state open` on the test repo | NEED-01, NEED-03 |
| OUT-05 | Scheduled runs that start at the installed local day and time, in a time zone with daylight saving, either side of a daylight-saving change | Every run starts at the installed local hour and no run starts at any other hour | At Test, with simulated clock times either side of a change | NEED-04 |

### Appetite and no-gos

- **Appetite:** this one Feature session, with Implement fitting in about two working days [assumed: the user didn't set an appetite; see [Open questions](index.md#open-questions)].
- **No-gos:** see [Non-goals](index.md#non-goals).
