# Problem: Session opens on a feature branch

> Part of [index](index.md) · Define

### Need and stakeholders

- **NEED-01:** When a compass-labs maintainer opens or resumes a session with the default branch checked out, they want none of the session's commits to reach the default branch except through a reviewed pull request merge, so they don't have to revert pushes to `main` and repair the session branch by hand.
- **NEED-02:** When a team uses the plugin in another repository, where the default branch may not be called `main`, may be protected, or may follow the team's own branch-naming convention, they want the same guarantee to hold under their repo's names and rules, so a session never pushes to their default branch or fights their conventions.

### Evidence

- In #23 the New session flow pushed its opening commit `d38c99c` straight to `origin/main` [observed: archived #23 `log.md`, lines 102–103].
- Fixing that took a revert on `main` (`912634c`), done in a separate worktree, and a merge of `origin/main` back into the session branch to keep the session files [observed: archived #23 `log.md`, lines 116–117 and 170].
- The New session flow commits and pushes without first creating or checking a branch [observed: `skills/session/SKILL.md`, line 42].
- Since #23, each session's branch has been created by hand before the first commit, this session's included [observed: this session's `log.md`; archived #27 and #28 logs].
- Resuming a session while the default branch is checked out would send the next milestone commit and push to the default branch, because no step checks the branch [assumed: no incident on record; inferred from the Resume flow and main loop in `skills/session/SKILL.md`].
- Teams using the plugin elsewhere have default branches with other names, protected default branches, and their own branch naming [assumed: stated by the user, 2026-10-17; no consuming-repo incident on record].
- Prompt instructions alone don't reliably stop agents from drifting from a required git workflow [observed: ADR-002, "Enforcement has to be mechanical"].

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | Session commits that reach the default branch other than through a pull request merge | 0 | At Test, in a throwaway repository: open a session on a clean default-branch checkout, resume it with the default branch checked out, and open a session on an existing non-default branch. Then again across the next 3 real sessions. | NEED-01, NEED-02 |
