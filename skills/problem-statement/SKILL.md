---
name: problem-statement
description: Write a short, visual problem brief for one piece of work — the need, who has it, one diagram of now vs after, a testable success check, what's out, and the assumptions made instead of questions asked. About 25 lines, saved to docs/briefs/. Runs alongside a pstack run (the controller starts it in parallel) or on its own with /trellis:problem-statement <issue or task>.
argument-hint: "<issue number, URL or task text>"
---

# Problem brief

One page that says **what's wrong, for whom, and how we'll know it's fixed**, before anything says how. It's written for someone with five minutes: the maintainer reading it a week later, or the `close` step folding it into the docs. It never blocks the work. pstack builds in parallel, and the brief records the thinking behind the run.

## Inputs

- The issue (`gh issue view <n> --json title,body,comments,labels`) or the task text.
- The README's Project anchor, if there is one (`<!-- compass:anchor -->` … `<!-- /compass:anchor -->`), to say which line of the vision this serves.
- Only what you need from the code to name the current behaviour. Don't design.

## Output

Write `docs/briefs/{YYYY-MM-DD}-{slug}.md` from [`templates/brief.md`](templates/brief.md), where `{slug}` is the branch name without its prefix (or the issue title, kebab-case, at most 5 words). Rules:

- **About 25 lines, hard limit 40.** Each section is one line or a short list. No paragraphs.
- **One diagram at most:** a Mermaid `flowchart LR` showing now vs after, only when the change moves something (data, a step, a boundary). Leave it out when a sentence says it faster.
- **Success check:** one or two checks someone could run or observe, such as "page 1 returns the first N items" or "the scheduled run publishes a report". Never "it works".
- **Assumptions, not questions.** In an unattended run, nobody answers. Write each unknown as an assumption you've made, and mark the one that matters most with `⚠`. The weekly brief surfaces ⚠ items.
- **Evidence tags** on each claim in *Need*: `[issue]`, `[code: path:line]`, `[user]`. Untagged claims are guesses: say so.
- No solution design, no requirements IDs, no tables of options. Those belong in the PR (pstack's `architect`), and in an ADR if significant.

Don't commit. The controller, or `close` in a manual run, commits the brief with the run's docs on the feature branch. In a manual run with no `close`, tell the user where the file is.
