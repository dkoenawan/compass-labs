---
name: problem-statement
description: Write a session's problem statement to its session type's standard — the need and who has it, tagged evidence, and (by depth tier) context, impact, measurable success outcomes and appetite. Per-type content lives in types/{type}.md, read on demand; method verdicts in reference/methods.md. Used by the phase agent that runs framing.
---

# Problem Statement Skill

The problem statement says what's wrong, for whom, and why it matters, before anything says how to fix it. It's one of the two artifact sections framing produces (the other is the requirements, in the `requirements` skill). Run the shared [framing](../framing/SKILL.md) step first: its confirmed tier decides how deep the problem statement goes, and its XY and symptom-vs-cause checks feed it.

## Read your type's file

The content required at each tier depends on the session type. Read the file your workflow's `framing.type_file` names, and only that one:

- [`types/feature.md`](types/feature.md): Feature sessions
- [`types/bugfix.md`](types/bugfix.md): Bugfix sessions

Each type file has a tier table, what each element must contain, optional templates and examples, and the methods that apply. The verdict behind every method is in [`reference/methods.md`](reference/methods.md).

## Rules for every type

- **No solution talk.** The problem statement states the need, not a fix. A fix the issue proposed goes to the framing record's candidate solutions (the XY check), unless the user confirmed the fix *is* the need.
- **Say who is affected.** Name the stakeholder group, not just "users" or "the team". If you can't say who has the problem, you don't know the problem yet.
- **Tag every claim about the problem.** A claim is either **observed**, with its source (the issue, a report, data, a quote), or **assumed**. An untagged claim reads as fact when it may be a guess. The suggested form is `[observed: source]` and `[assumed]`; any clear tagging passes.
- **Keep the symptom apart from the cause.** What was seen is observed; why it happened stays assumed until it's shown.
- **Unknowns stay visible.** Something you can't answer yet goes to the main doc's Open questions, not into a guessed answer.

## Defaults, not rigid rules

The type files say what content each element **must contain**. The templates, table layouts, tag syntax and sentence counts they suggest are defaults: a problem statement written as plain prose that has the required content passes. Named frameworks (SCQ, job stories, Shape Up and the rest) are offered as templates, never mandated. Where a check asks whether something is good enough, such as whether a stakeholder group is specific or an outcome is measurable, that's the reviewer's call, not a string test.
