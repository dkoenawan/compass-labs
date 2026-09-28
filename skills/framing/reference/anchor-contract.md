# Anchor contract

A **project anchor** is a project's one authoritative statement of its vision, mission, scope and (optionally) non-goals. Framing checks new work against it, framing creates or completes it once when it's missing, and `init` (#38) writes to this same contract when a project is created. It assumes no tech stack, no kind of work and no `docs/` layout: every repo has, or can have, a root README.

## Location

The consuming repo's root `README.md`. That's where someone new to the project looks first. If the repo has no README, creating the anchor creates it.

## Form

```markdown
<!-- compass:anchor -->
## Project anchor

### Vision

{The future the project is working towards, and for whom. One or two sentences.}

### Mission

{What the project does to get there: its job, stated so a newcomer can tell what it's for.}

### Scope

- {What the project covers. New work is judged against these lines.}

### Non-goals

- {What the project deliberately doesn't do. Optional: omit the section until the project has any.}
<!-- /compass:anchor -->
```

- The heading is `## Project anchor`, with `### Vision`, `### Mission`, `### Scope` and, optionally, `### Non-goals` under it, in that order.
- The whole section sits between one `<!-- compass:anchor -->` line and one `<!-- /compass:anchor -->` line. The markers make the anchor findable without judgement calls: whatever is between them is the anchor, and nothing outside them is.
- Scope is required because the aligns/extends verdict is judged against it. Non-goals are optional because a new project often has none yet; once they exist, they're checked like the rest.
- The wording inside each element is the project's own. The contract fixes the labels and markers, not the prose style or length.

## Checklist

A reviewer (or the framing step) marks each item pass or fail. The anchor is **complete** when every item passes, **incomplete** when the markers are found but any item fails, and **missing** when there's no README or no markers at all.

1. **Markers present exactly once.** One `<!-- compass:anchor -->` and one `<!-- /compass:anchor -->`, opening before closing. Zero pairs means missing; a duplicate or unpaired marker is a failure (incomplete), and the repair is drafted like any other anchor change.
2. **Vision present** under `### Vision`, and not empty.
3. **Mission present** under `### Mission`, and not empty.
4. **Scope present** under `### Scope`, and not empty.
5. **Non-goals present or not applicable.** Either a non-empty `### Non-goals`, or no such heading because the project has none yet. An empty `### Non-goals` heading fails.
6. **No conflicting restatement.** Nowhere else in the README, and in no doc the README links to, is any anchor element restated in words that differ from the anchor, unless that restatement links to the anchor instead of standing on its own. A check that fails names the conflicting restatement (the file and the line).

The checklist can be run without judging which statement "counts": the marked section is the authority, and every other statement either matches it or links to it.

## Writing the anchor

Framing drafts anchor text with the user; it never writes the README itself. The agreed text goes into the framing record's anchor-update block, and the orchestrator writes it into the README between the markers, in the same commit as the decision that records it. When the anchor is incomplete, only the missing or failing elements are written, and existing wording is left as it is. When the markers are missing, the orchestrator appends the whole section to the README (or creates the README), and offers to reuse any anchor-like wording the README already had.
