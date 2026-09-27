<!-- tier: full -->
# Quality: Self-service password reset for the team wiki

> Part of [index](index.md) · Define

## Quality coverage (ISO/IEC 25010:2023)

| Characteristic | Covered by | Not applicable because |
|---|---|---|
| Functional suitability | REQ-001, REQ-002, REQ-003 | |
| Performance efficiency | REQ-005 | |
| Compatibility | | The feature adds no interface other systems call; it sends email through the wiki's existing `Notifier`, unchanged. |
| Interaction capability | REQ-009 | |
| Reliability | | The feature adds no service of its own. Its availability is the wiki's and the email service's (see Dependencies), and a member can still ask an admin, as today. |
| Security | REQ-002, REQ-003, REQ-004 | |
| Maintainability | | No new component: the flow reuses the wiki's existing auth module and `Notifier`. |
| Flexibility | | It runs wherever the wiki runs, with no new deployment target or setting. |
| Safety | | A password reset can't cause physical, health or environmental harm. |

## NFR measures

| Requirement | Scale | Tolerable | Goal |
|---|---|---|---|
| REQ-005 | seconds from reset-form submit to the email service accepting the email, 95th percentile, at 200 concurrent members | 60 | 10 |
| REQ-009 | WCAG 2.2 level A and AA success criteria failed on the reset form and the set-password page, checked with keyboard only and NVDA | 0 | 0 |

## Assumptions and dependencies

**Assumptions:**
- Every member's account has a working email address. A member without one still asks an admin.
- Members can open the reset email on the device they're locked out on, or on another one.

**Dependencies:**
- The wiki's email service, through `Notifier`: relied on by REQ-001 and REQ-005.

The admin audit log (relied on by REQ-006) and the auth log (the source of OUT-01's signal) are part of the wiki, inside the context diagram's system boundary, so they aren't external dependencies.
