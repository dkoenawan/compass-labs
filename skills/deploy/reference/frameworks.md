# Frameworks behind the release record

> Part of the [Deploy standard](../SKILL.md).

Each release-record section draws on an established framework. Every row has a verdict: **adopt** (used as is), **adapt** (used with the change named) or **reject** (considered and not used).

| Section | Framework | Verdict | Reason |
|---|---|---|---|
| Lifecycles run and why | Continuous Delivery (Humble and Farley): the deployment pipeline | adapt | L1 is creating or changing a part's pipeline. L2 is a run through it |
| Lifecycles run and why | ITIL 4 deployment management against release management | adapt | Keeps "put in place" apart from "made available". The plugin names them L1 and L2 |
| Release strategy | SRE release engineering, and the Continuous Delivery strategies (big bang, rolling, blue-green, canary) | adapt | Name one strategy for each release. A plugin's is "tagged release" |
| Completeness | The plugin's "never ship an incomplete product" pattern | adopt | Kept as is |
| Steps run | SRE release engineering: reproducible, declared steps | adapt | The steps come from the declaration word for word, with each step's kind |
| Confirmation | SRE post-release verification, and DORA's change failure rate | adapt | A declared check with a recorded pass or fail. The metric isn't collected |
| Rollback | SRE workbook ("roll back first"), and ITIL 4 remediation | adapt | The declared rollback, stated before it's needed |
| Change record | ITIL 4 change enablement: change record, change type, change authority | adapt | The user at the gate is the change authority. The type sets the tier |
| Change record | SemVer | adopt | The versioning rule a repo declares, such as compass-labs' `CLAUDE.md` rules |
| Change record | Keep a Changelog | reject | A repo changelog file, which the standard doesn't ask for |
| Confirmation and rollback | DORA four keys as collected metrics | reject | Measuring them is a runtime concern, outside the plugin's scope. Cited only as the reason for both sections |
| Tiers | ITIL 4 change types (standard, normal, emergency) | adapt | Standard points to short, normal to full. Emergency is rejected: no requirement covers it |
