---
name: close
description: Fold one finished run into the repo after a pstack run or a manual change on a feature branch. It updates the as-built docs the change touched and the docs index by layer, writes the run's important findings (decisions, risks, learnings, compass problems), each with one visual and a few lines, commits the brief and decision trail for drill-down, and adds a short Drill down section to the PR. The controller runs it after every run; by hand, run /trellis:close [branch or PR].
argument-hint: "[branch or PR number]"
---

# Close

Turns a finished change into **current docs and a handful of findings** the maintainer can take in at a glance, so nobody has to read the run. It writes only on the feature branch and never merges (the merge guard enforces this).

Scripts run through `${CLAUDE_PLUGIN_ROOT}`:

| Script | Does |
|---|---|
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/close/scripts/findings-index.sh <repo>` | Rebuilds `docs/findings/index.md` from each finding's frontmatter, newest first, with counts by type |
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/close/scripts/pr-drilldown.sh <pr> <repo>` | Replaces the PR body's `<!-- trellis:drilldown -->` section with links to the files `close` committed, or appends it |

## Inputs

- The branch's change: `git diff --stat {base}...HEAD` and the diff of the files that matter, plus the commit messages.
- The brief, `docs/briefs/*-{slug}.md`, if the run had one.
- The decision trail, `docs/trails/*-{slug}.tsv`, written by pstack's `show-me-your-work`, if it exists.
- The PR body, if a PR is open (`gh pr view --json number,body,url`).

## Steps

1. **As-built docs.** For each layer the change touched, update the doc that describes it, under `docs/reference/` or `docs/explanation/` (create one if none exists). Write what's true now, not the story of the run: no "we tried", no session or REQ IDs. Each touched file gets one `> Origin: #{issue}` line, or adds the issue to its existing line.
2. **Docs index by layer.** Keep `docs/index.md`'s `## By layer` table (template: [`templates/docs-index.md`](templates/docs-index.md)), with one row per layer: the layer, its docs, the last PR that changed it, and the date. Name layers by what the repo has. For an app that's Frontend, Backend, Data, Infrastructure; for a tool, Plugin, Hooks, Scripts. Add a layer row the first time a change touches it, and update the row on every change after that. Leave other sections of `docs/index.md` alone.
3. **Findings.** Write `docs/findings/{YYYY-MM-DD}-{slug}.md` from [`templates/finding.md`](templates/finding.md), **only** for what the maintainer would want to know a month from now: at most 3 findings per run, and none is a fine answer. Each finding has:
   - a `type`:
     - `decision`: a choice that shapes later work
     - `risk`: something that could break or cost later
     - `learning`: something non-obvious about the code or domain
     - `trellis`: a problem with trellis or pstack itself. These feed the monthly trellis week
   - one visual: a Mermaid diagram, or a two-column table when a diagram adds nothing
   - three bullets at most
   - evidence links (`file:line`, commit, PR, trail row)
   The brief's ⚠ assumption becomes a `risk` finding if the run didn't settle it.
4. **Index the findings.** Run `findings-index.sh`.
5. **Commit** the brief, the trail, the docs, the index and the findings on the feature branch, as one commit: `docs: close — {slug}`. Push the branch (`git push`, never to the default branch).
6. **Drill down.** If a PR is open, run `pr-drilldown.sh`. It adds links to the brief, findings, trail and docs touched, under a collapsed section. The PR's own summary stays on top and stays short.
7. **Reply** in five lines or fewer: the docs touched, the findings with their types, and anything that blocked a step.

If there's no feature branch (you're on the default branch), stop and say so: `close` never writes on the default branch.
