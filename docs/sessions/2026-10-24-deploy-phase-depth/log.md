---
session: 2026-10-24-deploy-phase-depth
type: feature
issue: 30
# branch: the session branch, written once when the session opens, read by Resume.
branch: feat/30-deploy-phase-depth
phase: design
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: define
active_agent: main
next_step: "Design gate: user approves, adjusts or rethinks design/index.md"
---
# Session Log: Deploy phase depth (#30)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Follow-ups: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- Work is on branch `feat/30-deploy-phase-depth`; it reaches main through a PR.

## Key decisions

- **2026-11-03**: Starter choices — compass-labs' pipeline is the starter's first install (D12); starter values fixed at install time (D13); design ready for the gate.
- **2026-11-03**: Design Q1–Q4 answered — declaration offered at initiation and when a new part is added (REQ-026, REQ-027); optional starter GHA workflow offered, not default (REQ-028, framing revised); covered changed parts run L1; Deploy agent runs git/gh accepted.
- **2026-10-24**: ✅ Define complete — REQ-001 to REQ-025 approved (16 Must, 7 Should, 2 Could); two deploy lifecycles L1/L2; follow-ups #78–#82.
- **2026-10-24**: Requirements approved — REQ-001 to REQ-025 (16 Must, 7 Should, 2 Could); Deploy proposes its own tier by release risk, confirmed at the Deploy gate; bump picked by declared rule; tag form compass-labs--v{version}.
- **2026-10-24**: Problem agreed for #30 — full tier, scope (b) declaration + Deploy standard; two lifecycles L1 deployment setup / L2 session release; NEED-01–04, OUT-01–06; compass-labs routine release runs without prompts and a merge-triggered pipeline (its L1 setup) tags and publishes; anchor aligns, no update.
- **2026-10-24**: Follow-ups filed — #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references (per-part and per-cloud deploy depth, a non-goal of #30).
---

## Phase: Define

### 2026-10-24 — main — note: Session opened
- Issue #30 (Configure Deploy phase per repo). Picked after an SDLC depth review: Define and Design deep, Implement medium, Test thin, Deploy thinnest (`agents/deploy.md` works deploy out ad hoc; TODO #30).
- Branch `feat/30-deploy-phase-depth`, created from `main`.

### 2026-10-24 — main — note: Draft PR opened
- https://github.com/dkoenawan/compass-labs/pull/77 (draft, `feat/30-deploy-phase-depth` → `main`, Refs #30).

### 2026-10-24 — main — handoff: orchestrator → compass-labs:define (framing and problem for #30)
- **Input:** Run framing for #30. Scope is open: the declaration mechanism alone (config file, repo skill, Taskfile target or CLAUDE.md section), or also a Deploy standard (release strategy, rollback, post-deploy checks, change record) to match the depth Define/Design/Implement got. Context: SDLC depth review found Deploy the thinnest phase. Consider both cases, compass-labs' own plugin release and a consuming repo's real deployment; check overlap with #20 and #31.
- **Output:** needs_input; define/index.md, define/framing.md (new), define/problem.md (new)

### 2026-10-24 — compass-labs:define — attempt: Framing and problem statement drafted for #30
- Proposed tier: full (it changes a phase every Feature session goes through: the Deploy agent, its template, its gate, and a contract consuming repos follow). Awaiting the user's confirmation.
- Anchor complete; verdict aligns (draft). Anchor update: none. Overlaps: none in the registry; ADR-002 and ADR-006 limit the work; #20 and #31 related, no overlap.
- Evidence: all 5 archived release.md files re-derive what deploy means for compass-labs; the tag name and who does the bump changed between releases; Q9's "release as its own session" was overridden every time.
- Drafted NEED-01 to NEED-03 and OUT-01 to OUT-04 (NEED-03 and OUT-04 apply only if a Deploy standard is in scope). Scope, constraints, non-goals and appetite put to the user. No requirements yet.

### 2026-10-24 — compass-labs:define — attempt: Problem statement and constraints revised for two deploy lifecycles
- The user confirmed tier full and scope (b): the declaration plus a Deploy standard. Q9: the repo declares in-session or separate release. No real consuming repo, so non-plugin cases use a fixture repo. Appetite: same as #26 to #28.
- Problem split into L1 (deployment setup: repo start, architecture change) and L2 (session release). Needs NEED-01 to NEED-04; outcomes OUT-01 to OUT-05 (NEED-04 and OUT-05 are the new L1 need and outcome).
- Constraint revised: PR merge and production-affecting steps only on the user's instruction; declared routine release steps (for compass-labs: bump, commit, push, PR ready) run without prompts. ADR-006 and the no-merge rule unchanged.
- Per-layer and per-cloud deploy depth made non-goals; five follow-up issues proposed. Overlaps added: bootstrap-new-project, init (#38), #50. Anchor still aligns. Awaiting the user's confirmation; no requirements yet.

### 2026-10-24 — main — decision: Follow-ups filed for per-part and per-cloud deploy depth
- Per the user's choice of five issues: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references. Each links back to this session.

### 2026-10-24 — compass-labs:define — decision: Problem statement, constraints and non-goals agreed for #30
- Tier full; scope (b): a per-repo deploy declaration plus a Deploy standard. Anchor verdict aligns; no anchor update.
- Two lifecycles: L1 deployment setup (when a repo starts, and whenever its architecture changes) and L2 session release (when a session completes). Needs NEED-01 to NEED-04; outcomes OUT-01 to OUT-06 (define/problem.md).
- compass-labs: routine release steps (bump, commit, push the session branch, mark the PR ready) run without prompts. What follows the merge (tagging main, publishing the release) runs as a pipeline triggered by the merge: compass-labs' own L1 setup, in scope for this session and its first real L1 case (OUT-06). Mechanism left to Design.
- Constraints: PR merge and production-affecting steps only on the user's instruction; ADR-006 and the no-merge rule unchanged; one Deploy owner writing only its artifact in the session folder; the Deploy milestone still needs approval; declarations work in any repo and are optional; the standard is based on established frameworks; the completeness check is kept; past release.md files are not migrated.
- Q9: each repo declares whether a release runs inside the feature session or as its own session. Non-plugin cases are tested on a fixture repo. Appetite: same as #26 to #28.
- Non-goals: per-layer deploy depth, frontend #78, backend #79, database #80, infrastructure (Terraform) #81; cloud provider references #82; compass-labs as a deploy runner; #31; #20; #72 and #36; changing the completeness check.
- Open for Design: whether the plugin cache refresh (local to the user's machine) stays a user step; whether the Deploy agent or the orchestrator runs the routine steps.

### 2026-10-24 — compass-labs:define — note: Requirements set drafted for #30 (awaiting the user's approval)
- define/requirements.md: REQ-001 to REQ-024 (15 Must, 7 Should, 2 Could; no live Won't). Every OUT-01 to OUT-06 is served; REQ-012, REQ-013, REQ-016 and REQ-017 serve needs directly.
- OUT-06 has a check before the merge (REQ-019: a check run that reports the tag it would create) and checks after it (REQ-020 to REQ-024: tag and release on the merge commit with no user step, no tag without a version change, never overwrite a tag, the user's remaining steps listed, tag visible within 10 minutes).
- Deferred: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- define/quality.md: 25010:2023 coverage (Safety N/A with a reason), the NFR measure for REQ-024 (Goal 10 min, Tolerable 30), assumptions and dependencies. define/diagrams.md: impact map, context, traceability, as-is/to-be.
- Assumptions to confirm: version bump chosen by the declared rule without a prompt; release-record depth follows the framing tier; tag form compass-labs--v{version}. Open for Design: local cache refresh, who runs the routine steps, what a separate release session is.

### 2026-10-24 — compass-labs:define — decision: Requirements set approved for #30
- The user approved define/requirements.md at the Define gate: REQ-001 to REQ-025 (16 Must, 7 Should, 2 Could; no live Won't), serving OUT-01 to OUT-06. Deferred: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- Change at the gate: Deploy proposes its own depth tier from the release's risk (e.g. a routine plugin bump vs a production change) and the user confirms it at the Deploy gate; it doesn't follow the session's framing tier. REQ-014 (the standard states the risk that points to each tier) and REQ-015 (the gate checks against the confirmed Deploy tier) revised; REQ-025 added (Deploy proposes and records its tier and reason; the gate asks the user to confirm).
- Assumptions confirmed: the version bump is picked by the declared rule without a prompt and can be refused at the gate; tag form compass-labs--v{version}.
- quality.md, diagrams.md and index.md updated to match; define/index.md status set to Approved 2026-10-24.
- Open for Design: the Deploy tiers and their risk signals, the local plugin-cache refresh, who runs the routine steps, what a separate release session is.

### 2026-10-24 — main — milestone: ✅ Define complete
- The user approved the Define gate. REQ-001 to REQ-025 frozen in define/requirements.md, with problem.md, framing.md, quality.md and diagrams.md. Anchor update: none (a3 not applicable).

---

## Phase: Design

### 2026-10-24 — main — handoff: orchestrator → compass-labs:design (design from frozen define/)
- **Input:** Classify the solution and produce design/ for REQ-001 to REQ-025. Open questions from Define: the Deploy tiers and their risk signals (REQ-014); whether the local plugin-cache refresh stays a user step; whether the Deploy agent or the orchestrator runs the routine steps; what a separate release session is (REQ-012); the declaration mechanism (config file, repo skill, Taskfile target, CLAUDE.md section); the merge-triggered pipeline mechanism (must not depend on Claude pushing to main, ADR-006).
- **Output:** needs_input; design/index.md (draft)

### 2026-10-24 — compass-labs:design — attempt: Classification, scope and significant choices drafted for #30
- Prior knowledge read: docs/registry (index, patterns, ADR-002, -004, -005, -006), docs/reference/constructs/SessionBranchGuard.md, docs/explanation/session/overview.md, README anchor, and the code (agents/deploy.md, agents/orchestrator.md, skills/session/SKILL.md, feature.json, templates/release.md, phase-agent-contract.md, skills/implement/SKILL.md, hooks/session-guard.sh, Taskfile.yml, plugin.json v2.2.1, marketplace.json). No past session folder read.
- Proposed primary kind: Plugin/tooling (no in-depth path, #51). In scope: plugin/tooling, process/workflow (#49), infrastructure narrowed to the merge-triggered pipeline (#50), tests and fixture repos. Out of scope: frontend, backend, database, visual UI design, project docs, per-cloud references.
- Eleven significant choices drafted with options and a recommendation each (D1 to D11 in design/index.md). All are waiting for the user. Nothing is designed past classification yet.

### 2026-10-31 — main — handoff: orchestrator → compass-labs:design (complete design/ from the user's answers)
- **Input:** Complete design/ for REQ-001 to REQ-025 (fresh agent; the earlier one can't be reached from this conversation). Answers relayed: classification and scope accepted; D1 accepted, and "on project initiation when user use the compass-labs"; D2 accepted, and "think about where this can be deterministic and be a default GHA"; D3 to D11 accepted as recommended.
- **Output:** needs_input; design/index.md

### 2026-10-31 — compass-labs:design — attempt: Design completed from the user's answers, four questions open
- Classification and scope confirmed by the user. D1 to D11 marked chosen as the user answered. ADR flags: D1, D2 (refines ADR-002), D3 (relates to ADR-006).
- Wrote the context, component, process and deployment views, the delta list, DES-001 to DES-013 (coverage: all 25 live REQs), the principles check and the risks. Mermaid blocks parse.
- The D1 addition became D1a, and the D2 addition became D2a with a table of deterministic and agent-run steps. DES-014 is pending Q1 and not counted in coverage.
- Open: Q1 where the declaration offer goes (options 1 to 3 add a new REQ-026; no existing requirement changes); Q2 whether to ship a default GitHub Actions workflow; Q3 whether a changed part the declaration already covers needs L1; Q4 the single-responsibility trade-off on D2.
- Prior knowledge read also includes skills/init, bootstrap-new-project, the branch and commit guards, check-design.sh, stack-defaults.md and issue #38. No past session folder read.

### 2026-10-31 — compass-labs:design — note: Bash used outside its allowed purpose
- One Bash call ran `ls` on session, template and skill folders, and `gh issue view 38`. Both were read-only, nothing changed, and no past session folder was read. Later reading used Read; Bash was then used only for the Mermaid render check, with output to a temp directory.

### 2026-11-03 — main — decision: Design questions Q1–Q4 answered; REQ-026–REQ-028 added to the frozen set
- Q1 (D1a): offer the deploy declaration at project initiation **and** as a new component is added. Agreed as two triggers: (1) at initiation, in `init` and the `session` skill's one-time setup, skipped if a declaration exists (REQ-026, Should); (2) at Deploy, when the frozen design adds a deployable part the declaration doesn't cover, Deploy offers to add it before L1 runs; declining means no deploy step runs and the part is recorded as uncovered (REQ-027, Should).
- Q2 (D2a): option B. No workflow by default; offer an optional starter GitHub Actions workflow that the repo copies and owns, at initiation or when the user asks (REQ-028, Could). framing.md's anchor reasoning revised to match. Verdict still "aligns": the starter runs on the repo's own CI and never calls compass-labs at run time.
- Q3 (D9): yes. A new or changed part the declaration already covers also needs L1, and its declared setup runs.
- Q4 (D2): the single-responsibility trade-off on the Deploy agent is accepted.
- define/requirements.md, define/framing.md, define/quality.md and define/index.md amended. No existing requirement text changes.

### 2026-11-03 — main — handoff: orchestrator → compass-labs:design (finish design/ from Q1–Q4 and REQ-026–REQ-028)
- **Input:** Complete design/ (fresh agent). Answers relayed: Q1, two offer triggers (initiation, REQ-026; new uncovered part at Deploy, REQ-027); Q2, option B, an optional starter workflow offered at initiation or on request (REQ-028, Could); Q3, yes (recommended option); Q4, trade-off accepted.
- **Output:** needs_input; design/index.md

### 2026-11-03 — compass-labs:design — attempt: Design finished from Q1–Q4; two starter choices open
- Applied the 2026-11-03 answers: D1a option 3 with the skip rule plus the Deploy-time offer (REQ-026, REQ-027); D2a option B, the starter (REQ-028); D9's covered-part case chosen; D2's SRP trade-off accepted.
- New DES-014 (initiation offer: one procedure in the Deploy standard, called from init (both modes) and session one-time setup), DES-015 (install-starter.sh), DES-016 (compass-labs' pipeline installed from the starter). DES-002, 004, 005, 007, 008, 009, 011, 013 revised; the l1.new_part recipe rejected under YAGNI. Coverage: all 28 live REQs.
- Open: Q5 (D12), whether compass-labs' pipeline is the starter's first install; Q6 (D13), whether the starter's values are fixed at copy time or read at run time. Both recommended A.
- check-design.sh: ok. All five Mermaid blocks parse (mermaid-cli 12, output to a temp directory).

### 2026-11-03 — compass-labs:design — note: Bash used outside its allowed purpose
- Three read-only Bash calls listed the session, skill and template folders, and grepped or printed parts of skills/design/reference/notations.md, skills/session/SKILL.md (one-time setup) and skills/init/SKILL.md (headings and its commit steps). Nothing was written, no past session folder was read, and only this session's own log.md was printed. All other reading used Read. Bash was otherwise used only for check-design.sh and the Mermaid render check.

### 2026-11-03 — compass-labs:design — decision: Starter choices D12 and D13 made; design ready for the gate
- Q5 (D12): option A. compass-labs' own merge-triggered pipeline is the starter's first install: Implement runs install-starter.sh on this repo, so .github/workflows/release.yml and .github/scripts/release-tag.sh are filled-in copies of the starter templates (DES-016). One copy of the release logic, and the starter gets a real run on PR #77 and its merge.
- Q6 (D13): option A. install-starter.sh writes versioning.file, versioning.field and versioning.tag into the copied script's settings block at install time (DES-008, DES-015). The copy is self-contained and owned by the repo, and CI never reads .claude/deploy.json.
- Both chosen by the user, as recommended. D12 and D13 fall under D2's ADR flag (with D2a). Principles check: D12 and D13 rows met throughout.
- design/index.md: Q1–Q6 resolved, status set to ready for the Design gate. Coverage unchanged: all 28 live REQs (REQ-001 to REQ-028). check-design.sh: ok. All five Mermaid blocks parse.
- Follow-up issue still needed: the Release session type (D5).

### 2026-11-03 — compass-labs:design — note: Bash used for checks only this turn
- Bash ran check-design.sh, the mermaid-cli render check (output to a temp directory), and one grep of this session's own design/index.md to confirm no Q5/Q6 "pending" text remained. Nothing was written outside design/index.md, and no past session folder was read.
