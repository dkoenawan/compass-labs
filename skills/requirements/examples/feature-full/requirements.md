<!-- tier: full -->
# Requirements: Self-service password reset for the team wiki

> Part of [index](index.md) · Define

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted. A Won't meaning "never" is struck through with its reason; a Won't meaning "later" moves to the Deferred table below.

- **"Member"** means anyone with a wiki account. **"Admin"** means a member with the admin role.
- **"Reset link"** means a single-use link, emailed to a member, that lets them set a new password.

| ID | Requirement | Priority | Serves | Acceptance criterion |
|---|---|---|---|---|
| REQ-001 | When a member submits the reset form with the email address on their account, the wiki shall email them a reset link. | Must | OUT-01, OUT-02 | Given member `ana@example.org` is locked out, when she submits `ana@example.org` on the reset form at 10:00, then an email with a reset link reaches `ana@example.org`, and no admin is involved. |
| REQ-002 | If a reset link is opened more than 30 minutes after it was issued, or after it has been used, then the wiki shall refuse it and offer to send a new one. | Must | OUT-01 | Given a link issued to Ana at 10:00 and used at 10:05, when it's opened again at 10:10, then the page says the link can't be used and offers a new one, and Ana's password is unchanged. |
| REQ-003 | When a member sets a new password through a reset link, the wiki shall end every session that member had open. | Should | NEED-01 | Given Ana is logged in on a laptop and a phone, when she sets `Tide-Pool-42` through a reset link, then both devices are logged out within one page load, and she can log in with `Tide-Pool-42`. |
| REQ-004 | When the reset form is submitted with an email address that belongs to no account, the wiki shall show the same confirmation it shows for a known address, and send no email. | Must | NEED-01 | Given no account uses `nobody@example.org`, when it's submitted on the reset form, then the page shows "If that address has an account, we've sent a link", and no email is sent. |
| REQ-005 | While the wiki serves up to 200 concurrent members, when a member submits the reset form, the wiki shall hand the reset email to the email service. Measure: see [quality.md](quality.md#nfr-measures). | Should | OUT-01 | Given a load test holding 200 concurrent members, when 100 reset forms are submitted over one minute, then the 95th-percentile time from submit to the email service accepting the email is 10 seconds or less. |
| REQ-006 | When a reset link is requested or used, the wiki shall record the member, the event and its time in the admin audit log. | Could | OUT-02 | Given Ana requests a link at 10:00 and uses it at 10:05, when an admin opens the audit log, then it shows "reset requested, ana@example.org, 10:00" and "reset completed, ana@example.org, 10:05". |
| ~~REQ-007~~ | ~~When a member asks for a reset by SMS, the wiki shall text them a code.~~ **Won't (never):** the wiki stores no phone numbers, and the user decided it won't start. | — | — | — |
| REQ-009 | The reset form and the set-password page shall be usable with only a keyboard and a screen reader. | Could | NEED-01 | Given a member using only the keyboard with the NVDA screen reader, when they tab through the reset form, then each field and button is reached in order and announced by name, and Enter submits the form. |

## Deferred

| Follow-up | Was | Requirement | Reason |
|---|---|---|---|
| #88 | REQ-008 | Members can reset their password through the company's single sign-on. | Single sign-on isn't rolled out until next quarter. |
