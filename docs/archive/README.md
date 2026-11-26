# Archive

> Origin: #102

Docs for parts of compass-labs that [ADR-012](../registry/decisions/012-retire-feature-session-pipeline.md) retired: the gated Feature session, its phase standards, and the skills that pstack, graphify or Claude Design now cover. They're kept as history, not as current fact. The code they describe is gone from the tree, and every removed file is still at commit `b1d47e1` (`git show b1d47e1:<path>`).

| Area | Docs | Replaced by |
|---|---|---|
| Feature session lifecycle | [explanation/session](explanation/session/overview.md) · [reference/session](reference/session/) | pstack run → PR, with the controller and `close` |
| Framing and project anchor | [explanation/framing](explanation/framing/overview.md) · [reference/framing](reference/framing/tiers-and-anchor.md) | The `problem-statement` brief. The README anchor stays |
| Design standard | [explanation/design](explanation/design/overview.md) · [reference/design](reference/design/standard.md) · [solution design](explanation/solution-design.md) | pstack `architect`, and an ADR when significant |
| Implement standard | [explanation/implement](explanation/implement/overview.md) · [reference/implement](reference/implement/standard.md) · [layer guidance how-to](how-to/add-layer-implement-guidance.md) | pstack worker, test first |
| Constructs no longer built | [reference/constructs](reference/constructs/) | — |
| explore, doc-maintainer, brand-designer, bootstrap-new-project | [explanation/*](explanation/) | graphify, `close`, Claude Design, `init` |
| task-executor review note | [explanation](explanation/task-executor-untracked-files-not-committed.md) | The controller |

Past sessions stay where they were, in [`docs/sessions/`](../sessions/).
