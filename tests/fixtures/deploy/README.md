# Deploy fixtures

Four small repos for the Deploy phase's criteria (#30, DES-013). The plugin's own tests use them through `tests/run.sh`; Test runs the Deploy agent and the offers on them. Always work on a temp copy (`cp -R`), never on the fixture itself, and `git init` the copy where a criterion needs a repo.

Each fixture's steps are harmless: `deploy.sh` only appends what it was asked to do to `deploy-log` in the copy, and `check-health.sh` prints the state in `health-state` and exits 0 only when it's `healthy`. To make the confirmation check fail, write `unhealthy` into the copy's `health-state`.

| Fixture | What it is | Criteria |
|---|---|---|
| `fixture-service` | One web service (`web-service`) with a routine staging deploy, a production deploy that waits for the user, a merge, a `versioning` block (`package.json`, `.version`, `v{version}`) and a session design that changes only page text | REQ-001 (write its declaration from the standard), REQ-004 (use `variants/no-rollback.json`), REQ-006, REQ-007, REQ-008 (`health-state` set to `unhealthy`), REQ-010 (`docs/sessions/2026-01-01-page-text/`), REQ-012 (use `variants/own-session.json`), REQ-028 (a copy with a GitHub `origin`, and one without) |
| `fixture-no-declaration` | The same steps, but no `.claude/deploy.json` | REQ-003, REQ-026 (a first session answered "later", "nothing to deploy" and "declare now") |
| `fixture-new-part` | Declares `web-service` only; its session design (`docs/sessions/2026-01-01-billing/`) adds a new container, `billing-service` | REQ-009, REQ-011, REQ-027 (answer the offer yes, then no) |
| `fixture-docs-only` | Declares `{"deployment": "none"}` | REQ-013 |

To use a variant, copy it over the copy's declaration: `cp variants/own-session.json .claude/deploy.json`.

The component tests that read these fixtures: `tests/session/check_declaration_test.sh`, `check_declaration_plan_test.sh` and `install_starter_test.sh`.
