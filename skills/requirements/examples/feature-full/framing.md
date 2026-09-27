<!-- tier: full -->
# Framing: Self-service password reset for the team wiki

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** the issue asked for "a Forgot password button on the login page". The need behind it is that locked-out members regain access without waiting for an admin (NEED-01), and that admins stop handling routine resets (NEED-02).
- **Outcome:** the button moved to Candidate solutions. The user confirmed the need is regaining access, however it's done.

**Candidate solutions:**
- A "Forgot password" button on the login page that emails a reset link (from the issue)
- Security questions (raised in discussion, and not preferred by the user)

### Symptom and cause

- **Observed symptom:** reset requests wait up to a day for an answer [observed: admin panel export, #212].
- **Cause:** resets can only be done by an admin, by hand, from the admin panel [observed: admin guide, "Resetting a password"]. Admin availability outside office hours is the likely reason for the longest waits [assumed].

## Anchor

- **State:** complete: the wiki's `README.md` has one marker pair, with vision, mission, scope and non-goals present, and no conflicting restatement.
- **Verdict:** aligns
- **Rests on:** Scope: "Accounts and access for team members". Non-goals: "No public, anonymous editing" (unaffected: a reset needs an existing account).

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:** none

## Overlaps

- **Overlap:** the registry's `Notifier` construct already sends account emails. The reset email reuses it rather than adding a second email path (recorded as a constraint in [index](index.md#constraints)).
- **Conflicts with recorded decisions:** none found.
