<!-- tier: full. Worked example (DES-018): an invented team wiki, not a real session. -->
# Define: Self-service password reset for the team wiki

> Phase: Define | Started: 2026-01-12 | Status: Approved (example)
> Relates to: Issue #212 (invented, for this example)

## Contents

- [Requirements](requirements.md): REQ-001 to REQ-009, one struck, one deferred
- [Framing](framing.md): the XY and symptom checks, the anchor verdict, overlaps
- [Problem](problem.md): context, NEED-01 and NEED-02, evidence, impact, OUT-01 and OUT-02, appetite
- [Quality](quality.md): ISO/IEC 25010:2023 coverage, NFR measures, assumptions and dependencies
- [Diagrams](diagrams.md): impact map, context diagram, traceability, as-is and to-be

## Framing

- **Tier:** full: it changes a process members and admins follow today, adds a security-sensitive flow and depends on an external email service.
- **Verdict:** aligns with the wiki's anchor scope ("accounts and access for team members"). See [framing.md](framing.md).

## Problem statement

Members locked out of the wiki wait for an admin to reset their password by hand, and admins spend hours a week doing it. Needs: NEED-01 (members regain access themselves), NEED-02 (admins stop handling routine resets). Outcomes: OUT-01, OUT-02. See [problem.md](problem.md).

## Scope

1. Members reset a forgotten password themselves, from the login page, through an emailed single-use link: [REQ-001](requirements.md#requirements) to [REQ-004](requirements.md#requirements).
2. The reset email arrives fast enough to be useful under normal load: [REQ-005](requirements.md#requirements).
3. Admins can see every reset in the audit log: [REQ-006](requirements.md#requirements).
4. The reset pages are usable by keyboard and screen reader: [REQ-009](requirements.md#requirements).

### Non-goals

- **Reset by SMS.** The wiki stores no phone numbers, and won't start (struck REQ-007).
- **Reset through single sign-on.** Tracked in #88, after the SSO rollout (deferred REQ-008).
- **Changing how admins create accounts.** Out of this feature's appetite.

## Constraints

- The reset email goes through the wiki's existing email service; no new mail provider.
- No new personal data is stored about members.

## Open questions

1. **A second link while the first is still valid.** If a member requests a new link while an earlier one is still within its 30 minutes, does the earlier link stop working? Unknown; no acceptance criterion asserts a result for it until it's answered.
