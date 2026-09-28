# Bugfix problem statement

> Standard: [problem-statement](../SKILL.md) · Methods: [reference/methods.md](../reference/methods.md)

A Bugfix problem statement describes a failure precisely enough that someone else can reproduce it, and keeps what was seen apart from why it happened. This file stays at the depth the Bugfix workflow needs today. Deeper Bugfix content is tracked in #40, and the Bugfix workflow itself, including its framing block, its tiers and which files its framing artifact holds, in #24.

## Required content

| Element | Must contain |
|---|---|
| **Observed symptom** | What was seen, tagged `[observed: source]`, with **reproduction steps** someone else can follow: starting state, actions, and what happens. If it can't be reproduced yet, say so. |
| **Expected vs actual** | The behaviour that should have happened, and the behaviour that did, as two separate statements |
| **Impact** | Who is affected and how badly: how many, how often, and what they can't do |
| **Cause** | The cause, once it's shown, with the evidence that shows it; otherwise **unknown**. A suspected cause is an assumed claim, not the cause. |

At skip tier, one paragraph with the symptom and the expected behaviour is enough.

## Methods applied

Each has a Bugfix **adopt** verdict in [reference/methods.md](../reference/methods.md):

- **XY problem.** A bug report often asks for a fix ("add a retry"). Record the failure behind it; the requested fix becomes a candidate solution.
- **Symptom vs cause** (Genchi Genbutsu, root-cause analysis). Go and look at the failure itself; record the symptom as observed and the cause separately.
- **5 Whys.** Once the symptom reproduces, ask why until you reach a cause you can act on. Record the chain, and stop at the first cause the evidence supports.
- **Observed/assumed evidence.** Every claim about the failure is tagged.

## Checklist

- [ ] The symptom is tagged observed with its source, and has reproduction steps (or says it doesn't reproduce yet).
- [ ] Expected and actual behaviour are stated separately.
- [ ] Impact names who is affected and how.
- [ ] The cause is named with its evidence, or recorded as unknown.
- [ ] No fix is stated as the problem.
