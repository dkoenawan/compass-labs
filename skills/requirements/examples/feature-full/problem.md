<!-- tier: full -->
# Problem: Self-service password reset for the team wiki

> Part of [index](index.md) · Define

### Context

**Situation:** wiki admins reset forgotten passwords by hand from the admin panel, after a member asks them in chat or by email [observed: admin panel export, #212].

**Complication:** the team doubled in size this year [observed: member count in the admin panel], and reset requests now wait up to a day for an admin to be free [observed: admin panel export, #212].

### Need and stakeholders

- **NEED-01:** When a wiki member forgets their password outside office hours, they want to regain access themselves, so they can keep working without waiting for an admin.
- **NEED-02:** When a member is locked out, wiki admins want routine resets to stop landing on them, so they can spend that time on moderation and support.

### Evidence

- Reset requests waited 9 hours on average in March, and 26 hours at worst [observed: admin panel export, #212].
- Admins logged about 2 hours a week on resets in Q1 [observed: admin time sheet, quoted in #212].
- About 60% of reset requests arrive outside office hours [observed: request timestamps in the export].
- Every member's account has a working email address [assumed].
- Members would rather reset by email than by security questions [assumed, from two comments on #212].

### Impact and why now

- **If nothing changes:** locked-out members lose up to a working day each time [observed: admin panel export, #212], and admins keep spending about 2 hours a week on resets [observed: admin time sheet, #212], which grows with the team [assumed].
- **Why now:** the team doubles again next quarter [observed: hiring plan, quoted in #212], and the admin rota is already stretched [assumed].

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | median time from reset request to regained access, from the auth log | under 10 minutes (from 9 hours) | 30 days after release | NEED-01 |
| OUT-02 | admin hours per week spent on password resets, from the admin time sheet | under 30 minutes (from about 2 hours) | 30 days after release | NEED-02 |

### Appetite and no-gos

- **Appetite:** one week for one developer.
- **No-gos:** see [Non-goals](index.md#non-goals).
