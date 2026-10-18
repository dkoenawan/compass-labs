# Requirements: Session opens on a feature branch

> Part of [index](index.md) · Define

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted. A Won't meaning "never" is struck through with its reason; a Won't meaning "later" moves to the Deferred table below.

- **"Default branch"** means the branch the repository's remote reports as its default (for example `main`, `master` or `trunk`). It is never assumed to be `main`.
- **"Session commit"** means a commit made by the orchestrator or a phase agent while a session is active: session-folder changes, and Implement's code and test commits.
- **"Session branch"** means the branch a session's commits are made on, recorded for that session.

| ID | Requirement | Priority | Serves | Acceptance criterion |
|---|---|---|---|---|
| REQ-001 | When a new session is opened while the default branch is checked out, the orchestrator shall create the session branch and switch to it before the session's first commit. | Must | OUT-01, NEED-01 | Given a throwaway repo whose default branch `main` is checked out clean at commit `A` and matches its remote, when the user opens a session for issue #5, then the opening commit is on a new non-default branch and that branch is pushed, and `main` and `origin/main` both still point at `A`. |
| REQ-002 | When a new session is opened while a non-default branch is checked out, the orchestrator shall ask the user whether to use that branch as the session branch or to create a new one, before the session's first commit. | Must | OUT-01, NEED-01, NEED-02 | Given a throwaway repo with branch `feat/5-existing` checked out, when the user opens a session for issue #5, then the user is asked to choose between `feat/5-existing` and a new branch before any commit, and the opening commit lands on the branch they chose. |
| REQ-003 | The orchestrator shall record the session branch in the session folder when the session opens. | Must | OUT-01, NEED-01 | Given a session opened for issue #5 on branch `feat/5-widget`, when the opening commit is inspected, then the session folder names `feat/5-widget` as the session branch. |
| REQ-004 | When a session is resumed while a branch other than its session branch is checked out, the orchestrator shall switch to the session branch before the session's next commit. | Must | OUT-01, NEED-01 | Given a session whose recorded branch is `feat/5-widget`, and `main` checked out, when the user resumes the session and approves the next milestone, then the milestone commit is on `feat/5-widget`, and `main` and `origin/main` don't change. |
| REQ-005 | If a session commit or a push of one targets the default branch, then the plugin shall block it before it is made. | Must | OUT-01, NEED-01, NEED-02 | Given an active session in a throwaway repo with `main` checked out, when the orchestrator runs `git commit` for a change to the session's `log.md`, then the commit is refused with a message naming `main` as the default branch, and `main`'s head doesn't change. |
| REQ-006 | The plugin shall identify the default branch from the repository rather than assume its name. | Must | OUT-01, NEED-02 | Given a throwaway repo whose remote's default branch is `trunk` and which has no `main`, when the user opens a session with `trunk` checked out, then the opening commit is not on `trunk`, and a direct session commit to `trunk` is blocked as in REQ-005. |
| REQ-007 | When the orchestrator proposes a name for a new session branch, it shall let the user accept or replace the name before the branch is created. | Should | NEED-02 | Given a session being opened for issue #5 on a clean default branch, when the orchestrator proposes `feat/5-widget` and the user replies `team/ABC-5-widget`, then the branch created and recorded is `team/ABC-5-widget`. |
| REQ-008 | The Feature workflow shall include an explicit step, taken only after asking the user, that opens a pull request from the session branch into the default branch before the Deploy milestone is approved. | Must | OUT-01, NEED-01 | Given a session at the Deploy gate on `feat/5-widget` with no pull request, when the user approves opening one, then a pull request from `feat/5-widget` into the default branch exists before the Deploy milestone entry is logged. |
| REQ-009 | The orchestrator shall merge the session's pull request only when the user explicitly instructs it to. | Must | NEED-01, NEED-02 | Given a session whose pull request is open and whose Close milestone is approved, when the user hasn't asked for a merge, then the pull request is still open and unmerged. |
| REQ-010 | If the session branch can't be created or switched to, then the orchestrator shall stop before the session's first commit and tell the user why. | Should | OUT-01, NEED-01, NEED-02 | Given a throwaway repo where branch `feat/5-widget` is already checked out in another worktree, when the user opens a session for issue #5 and accepts the name `feat/5-widget`, then no commit is made, and the user is told that the branch couldn't be switched to and why. |

## Deferred

None. No remote and a failed push are out of scope as a non-goal tracked by #70 (see [index](index.md#non-goals)), not as a deferred requirement.
