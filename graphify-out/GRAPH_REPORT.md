# Graph Report - compass-labs  (2026-08-17)

## Corpus Check
- 95 files · ~95,830 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 394 nodes · 518 edges · 42 communities (22 shown, 20 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 47 edges (avg confidence: 0.87)
- Token cost: 40,000 input · 3,952 output

## Community Hubs (Navigation)
- Explore & Init Skills
- Compass Rename Run Sheet
- Architecture Registry Model
- Bootstrap Skill & Repo Guidance
- C4/arc42 Doc Spine
- Doc Maintainer & Diataxis
- Review Failure Patterns
- Registry Templates & Indexes
- Plan Skill Weekly Assessment Review
- Task Executor Postmortems & Reviews
- Brand Designer Domain Model
- Architecture Registry Lifecycle Stages
- Plugin Lifecycle & Taskfile
- Brand Designer Worked Examples
- Brand Validate Script
- Marketplace Manifest
- Diataxis Docs Restructure
- Explore Skill Traversal Model
- Stale Domains Script
- Doc Maintainer Doc Types
- Kimi CLI Integration
- Install Schedule Script
- Uninstall Schedule Script
- Post-Commit Hook
- Spec Validation Script
- Maintain Script
- Idempotency Check Script
- Issue Comment Script
- Commit and Push Script
- Test Command Detection Script
- Daily Execution Script
- Active Plan Finder Script
- Install Schedule Script (task-executor)
- Task Marking Script
- PR Opening Script
- Branch Prep Script
- Branch Restore Script
- Run Script
- Test Runner Script
- Task Selection Script
- Uninstall Schedule Script (task-executor)

## God Nodes (most connected - your core abstractions)
1. `plan Skill` - 21 edges
2. `doc-maintainer Skill` - 20 edges
3. `Architecture Registry & System Model Spec` - 19 edges
4. `Systematic Dev Kit Solution Design (L1)` - 17 edges
5. `brand-designer Skill` - 15 edges
6. `Doc Maintainer Skill` - 15 edges
7. `System Documentation (arc42/C4 HTML)` - 14 edges
8. `Full reference blast radius scan (30 files)` - 14 edges
9. `init Skill` - 13 edges
10. `System Model Redesign Review v2` - 13 edges

## Surprising Connections (you probably didn't know these)
- `Task Executor Execution Layer (daily run sequence)` --semantically_similar_to--> `Task Executor Execute Mode`  [INFERRED] [semantically similar]
  specs/task-executor-skill/overview.md → skills/task-executor/SKILL.md
- `release task` --semantically_similar_to--> `Plugin Install & Update Flow`  [INFERRED] [semantically similar]
  Taskfile.yml → docs/plugin-install-flow.html
- `lock task` --semantically_similar_to--> `Plugin Install & Update Flow`  [INFERRED] [semantically similar]
  Taskfile.yml → docs/plugin-install-flow.html
- `Init Brownfield-Migrate Mode` --semantically_similar_to--> `Brownfield Migration Path (existing kit users)`  [INFERRED] [semantically similar]
  skills/init/SKILL.md → specs/architecture-registry/overview.md
- `Failure Mode Matrix (E1-E14)` --semantically_similar_to--> `Task Executor Error Handling Reference (E1-E14)`  [INFERRED] [semantically similar]
  specs/task-executor-skill/overview.md → skills/task-executor/SKILL.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Skills that Read Documentation Before Source (Token Economy)** — skill_explore, skill_doc_maintainer, skill_plan [INFERRED 0.85]
- **Skills with Explicit Approval Gates Before File Generation** — skill_plan, skill_brand_designer, skill_adr [INFERRED 0.85]
- **Architecture Registry Read/Write Participants** — skill_init, skill_plan, skill_explore, skill_task_executor, skill_doc_maintainer, skill_adr, skill_post_hook_validator [EXTRACTED 1.00]
- **Files reorganized/created under Diataxis restructure (ADR-001)** — docs_registry_decisions_001_diataxis_docs_restructure, docs_reference_api_index, docs_reference_constructs_constructname, docs_tutorials_index, docs_sessions_readme, docs_registry_index [EXTRACTED 0.90]
- **Known Failure Patterns documented across skill reviews** — reviews_readme_natural_stopping_points, reviews_readme_declarative_vs_evaluative, reviews_readme_weak_transition_language, reviews_readme_no_verification_gate, reviews_plan_20260309_weekly_assessment, reviews_task_executor_20260628_category_management_false_completion, reviews_adr_20260628_category_management_postmortem [EXTRACTED 0.90]
- **Brand Designer worked examples demonstrating output quality** — skills_brand_designer_examples_readme, skills_brand_designer_examples_tidepool_brand_guideline, skills_brand_designer_examples_tidepool_brand_showcase, skills_brand_designer_examples_mithril_ledger_brand_guideline, skills_brand_designer_examples_mithril_ledger_brand_showcase, skills_brand_designer_template [EXTRACTED 0.85]
- **C4-layered documentation tree components (L1/L2/L3)** — skills_doc_maintainer_template_solution_design, skills_doc_maintainer_template_containers, skills_doc_maintainer_template, skills_doc_maintainer_examples_solution_design, skills_doc_maintainer_examples_containers, skills_doc_maintainer_examples_domain_overview [EXTRACTED 0.90]
- **Skills that read/write the Architecture Registry** — skills_init_skill, skills_plan_skill, skills_explore_skill, skills_task_executor_skill, skills_doc_maintainer_skill_doc_maintainer_skill, skills_post_hook_validator_skill, specs_architecture_registry_overview_l0_index [INFERRED 0.85]
- **Skills that drive the construct lifecycle state machine** — skills_plan_skill_construct_stub_write, skills_task_executor_skill_post_task_registry_write, skills_post_hook_validator_skill_outcome_routing, specs_architecture_registry_overview_construct_lifecycle [INFERRED 0.85]
- **Activities Claude owns** — claude, activity_1_plugin_identity, activity_2_namespace, activity_3_taskfile, activity_4_docs, activity_5_readme, activity_6_reviews, activity_7_verification [EXTRACTED]
- **Activities Daniel owns** — daniel, activity_gh_repo_rename, activity_update_remote, activity_npm_check, activity_marketplace_registration, activity_merge_pr, activity_tag_release [EXTRACTED]
- **Downstream impacts of the rename** — impact_existing_installs, impact_inflight_prs, impact_local_clones, impact_npm, impact_doc_crosslinks, impact_historical_reviews, impact_registry_empty [EXTRACTED]
- **30 files referencing systematic-dev-kit** — file_marketplace_json, file_plugin_json, file_claude_md, file_contributing_md, file_readme_md, file_taskfile_yml, file_hello_md, dir_docs_explanation, file_adr_001, file_solution_design, dir_reviews, dir_skills, dir_specs [EXTRACTED]

## Communities (42 total, 20 thin omitted)

### Community 0 - "Explore & Init Skills"
Cohesion: 0.06
Nodes (56): Bootstrap New Project Skill (Deprecated), Explore Skill, Investigation Report output format, Explore Post-Investigation Registry Write, Tiered Traversal Algorithm (Tier 0-3), Init Skill, ADR-001 Initial Stack Choices, ADR-002 Brownfield Registry Migration (+48 more)

### Community 1 - "Compass Rename Run Sheet"
Cohesion: 0.05
Nodes (55): Activity 1: Plugin identity update, Activity 2: Invocation namespace find/replace, Activity 3: Taskfile update, Activity 4: Docs — process/reference content update, Activity 5: README update, Activity 6: Reviews/historical records — do not rewrite, Activity 7: Verification pass, gh repo rename compass-labs (+47 more)

### Community 2 - "Architecture Registry Model"
Cohesion: 0.07
Nodes (29): ADR-007 Azure Functions over Service Bus, API Response Envelope Pattern, arc42 Documentation Spine, specs/architecture-registry/overview.md, Bidirectional Traceability, Agent-Maintained, L0 Black Box / L1 White Box / L2 Source Levels, C4 Visual Notation, Capability Search, not Path Search (+21 more)

### Community 3 - "Bootstrap Skill & Repo Guidance"
Cohesion: 0.11
Nodes (23): Approval Gates Before File Generation, Inline Template Problem, NewProject (bootstrap output), skills/bootstrap-new-project/SKILL.md, CLAUDE.md (Repo Guidance), Plugin Directory Structure Rules, hello command, Dedicated docs branch (chore/claude-maintain) (+15 more)

### Community 4 - "C4/arc42 Doc Spine"
Cohesion: 0.13
Nodes (19): examples/containers.md (taskflow L2 example), examples/domain-overview.md (tasks domain example), VALID_TRANSITIONS state machine, Tasks Domain (taskflow), examples/solution-design.md (taskflow L1 example), taskflow (fictional example project), C4-Layered Documentation Tree, chore/claude-maintain branch workflow (+11 more)

### Community 5 - "Doc Maintainer & Diataxis"
Cohesion: 0.14
Nodes (17): Approval Gate (Phase 4), Failure Pattern: Declarative vs. Evaluative Instructions, Failure Pattern: Natural Stopping Points, Failure Pattern: Weak Transition Language, FailurePattern, FollowUpChecklist, git add sibling-directory gotcha, GitHub Issue #79 (MithrilLedger) (+9 more)

### Community 6 - "Review Failure Patterns"
Cohesion: 0.17
Nodes (17): API Specs Reference Index, ConstructName Template, ADR-001: Diataxis-based docs/ restructure, Diataxis Framework, docs/sessions/ Fold-back Mechanism, Feature -> Pages -> API -> Architecture Index, Architecture Decision Record Index, ADR Template (+9 more)

### Community 7 - "Registry Templates & Indexes"
Cohesion: 0.14
Nodes (14): Adaptive Depth Engine, BackendLayer, ComplexityProfile, CQRS Naming Convention, DatabaseLayer, FeatureSpec, FrontendLayer, ImplementationOrder (+6 more)

### Community 8 - "Plan Skill Weekly Assessment Review"
Cohesion: 0.14
Nodes (14): BrandArchetype, skills/brand-designer/SKILL.md, skills/brand-designer/template.md, skills/brand-designer/scripts/validate.sh, BrandIdentity, ColorPalette, ComponentCharacter, CoreEmotions (+6 more)

### Community 9 - "Task Executor Postmortems & Reviews"
Cohesion: 0.24
Nodes (14): ADR Skill Review: Category-Management Post-mortem, Missing Prerequisite With No Fallback Branch (failure pattern), Plan Skill Review: Weekly Assessment Feature Test, Skill Review System README, Declarative vs Evaluative Instructions (failure pattern), Natural Stopping Points (failure pattern), No Verification Gate (failure pattern), Weak Transition Language (failure pattern) (+6 more)

### Community 10 - "Brand Designer Domain Model"
Cohesion: 0.20
Nodes (11): init brownfield-migrate Mode, ClarityLog, skills/doc-maintainer/scripts/find-stale-domains.sh, skills/doc-maintainer/scripts/install-schedule.sh, skills/doc-maintainer/scripts/maintain.sh, skills/doc-maintainer/SKILL.md, DomainClassification, Lifecycle Stage: Brownfield Init (+3 more)

### Community 11 - "Architecture Registry Lifecycle Stages"
Cohesion: 0.24
Nodes (11): docs/architecture/building-blocks.md, docs/architecture/data-models.md, Architecture Registry Skill Lifecycle, docs/architecture/infrastructure.md, Lifecycle Stage: Greenfield, Lifecycle Stage: Mature (10+ features), Lifecycle Stage: Sparse (1-3 features), docs/registry/constructs/ (per-construct files) (+3 more)

### Community 12 - "Plugin Lifecycle & Taskfile"
Cohesion: 0.24
Nodes (10): Plugin Install & Update Flow, Plugin Cache Stale Gap (known limitation), .plugin-lock File (proposed/implemented), Local Plugin Marketplace Registration, Semver Backwards Compatibility Rules, check-upgrade task, install task, lock task (+2 more)

### Community 13 - "Brand Designer Worked Examples"
Cohesion: 0.42
Nodes (9): Mithril Ledger Brand Guideline, Mithril Ledger Brand Showcase Page, Runic Channels Visual Concept, Brand Designer Examples README, Tidepool Brand Guideline, Tidepool Brand Showcase Page, Bioluminescent Data Visual Concept, Brand Designer Skill (+1 more)

### Community 14 - "Brand Validate Script"
Cohesion: 0.50
Nodes (8): bold(), fail(), green(), pass(), red(), validate.sh script, warn(), yellow()

### Community 15 - "Marketplace Manifest"
Cohesion: 0.25
Nodes (7): description, name, owner, email, name, plugins, $schema

### Community 16 - "Diataxis Docs Restructure"
Cohesion: 0.29
Nodes (6): ADR-001 Diataxis Docs Restructure, C4 Navigation Model (L1/L2/L3), Diataxis Documentation Structure, Feature Index, Feature Trace Template, How-To Guides Index

### Community 17 - "Explore Skill Traversal Model"
Cohesion: 0.29
Nodes (7): skills/explore/SKILL.md, InvestigationReport, explore Skill, SufficiencyGate, Tiered Sufficiency Architecture, TieredTraversal, Token Economy Read Ordering

### Community 18 - "Stale Domains Script"
Cohesion: 0.40
Nodes (3): RESULTS, find-stale-domains.sh script, usage()

### Community 19 - "Doc Maintainer Doc Types"
Cohesion: 0.50
Nodes (4): ContainerArchDoc (L2), DocumentationTree, DomainOverview (L3), SolutionDesignDoc (L1)

### Community 20 - "Kimi CLI Integration"
Cohesion: 0.50
Nodes (4): Kimi Code CLI, Kimi CLI Integration Note, Kimi Agent SDK, Master/Child Orchestration Pattern

## Knowledge Gaps
- **111 isolated node(s):** `$schema`, `name`, `description`, `name`, `email` (+106 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Systematic Dev Kit Solution Design (L1)` connect `Bootstrap Skill & Repo Guidance` to `Doc Maintainer & Diataxis`, `Registry Templates & Indexes`, `Plan Skill Weekly Assessment Review`, `Brand Designer Domain Model`, `Explore Skill Traversal Model`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `doc-maintainer Skill` connect `Brand Designer Domain Model` to `Bootstrap Skill & Repo Guidance`, `Architecture Registry Lifecycle Stages`, `Diataxis Docs Restructure`, `Explore Skill Traversal Model`, `Doc Maintainer Doc Types`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Why does `Architecture Registry Skill Lifecycle` connect `Architecture Registry Lifecycle Stages` to `Architecture Registry Model`, `Brand Designer Domain Model`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **What connects `$schema`, `name`, `description` to the rest of the system?**
  _111 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Explore & Init Skills` be split into smaller, more focused modules?**
  _Cohesion score 0.05513784461152882 - nodes in this community are weakly interconnected._
- **Should `Compass Rename Run Sheet` be split into smaller, more focused modules?**
  _Cohesion score 0.050505050505050504 - nodes in this community are weakly interconnected._
- **Should `Architecture Registry Model` be split into smaller, more focused modules?**
  _Cohesion score 0.07389162561576355 - nodes in this community are weakly interconnected._