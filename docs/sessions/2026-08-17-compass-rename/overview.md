# Rename systematic-dev-kit → Compass — Run Sheet

**Source**: [Issue #18](https://github.com/dkoenawan/systematic-dev-kit/issues/18)
**Date**: 2026-08-17
**Type**: Repo-wide rename / migration (not a new feature — no DB/Backend/Frontend layers apply)

## Scope decisions (confirmed 2026-08-17)

| Decision | Choice |
|---|---|
| GitHub repo slug | **Rename it**: `dkoenawan/systematic-dev-kit` → `dkoenawan/compass-labs` (GitHub auto-redirects old URL, but does not fix hardcoded links or local remotes) |
| Version bump | **Major bump** — `/compass:*` namespace change is breaking. `0.6.0` → `1.0.0` |
| Execution mode | Split: mechanical find/replace + docs done in one pass by Claude; `gh repo rename` and any account/marketplace-owner actions done manually by Daniel |

## Full reference blast radius (as scanned 2026-08-17)

30 files currently reference `systematic-dev-kit`:

```
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
CLAUDE.md
CONTRIBUTING.md
README.md
Taskfile.yml
commands/hello.md
docs/explanation/bootstrap-new-project/overview.md
docs/explanation/brand-designer/overview.md
docs/explanation/doc-maintainer/overview.md
docs/explanation/explore/overview.md
docs/explanation/init/overview.md
docs/explanation/plan/overview.md
docs/explanation/reviews/task-executor-untracked-files-not-committed.md
docs/explanation/solution-design.md
docs/registry/decisions/001-diataxis-docs-restructure.md
reviews/TEMPLATE.md
reviews/adr/20260628_category-management-postmortem.md
reviews/plan/20260309_weekly-assessment.md
reviews/task-executor/20260628_category-management-false-completion.md
skills/bootstrap-new-project/SKILL.md
skills/brand-designer/SKILL.md
skills/doc-maintainer/SKILL.md
skills/doc-maintainer/examples/containers.md
skills/doc-maintainer/examples/solution-design.md
skills/doc-maintainer/template-containers.md
skills/doc-maintainer/template-solution-design.md
skills/explore/SKILL.md
skills/init/SKILL.md
skills/plan/SKILL.md
skills/plan/examples/user-management/overview.md
skills/plan/template.md
skills/post-hook-validator/SKILL.md
skills/task-executor/SKILL.md
skills/task-executor/examples/sample-feature/overview.md
specs/architecture-registry/overview.md
specs/task-executor-skill/overview.md
```

No `.github/` workflows reference the name. No CI to update.

**Architecture registry check**: `docs/registry/index.md` currently has 0 constructs cataloged — this rename predates any registry population, so there are no construct stubs to update.

---

## Activities — Claude does

These are mechanical, reversible, and don't touch external systems. Done as a single PR branch.

### 1. Plugin identity
- [ ] `.claude-plugin/plugin.json`: `name` → `compass-labs`, `version` → `1.0.0`, `repository` → `https://github.com/dkoenawan/compass-labs`
- [ ] `.claude-plugin/marketplace.json`: both `name` fields → `compass-labs`

### 2. Invocation namespace (breaking — every skill's slash command changes)
- [ ] Find/replace `/systematic-dev-kit:` → `/compass:` across all `skills/*/SKILL.md` (init, brand-designer, explore, plan, doc-maintainer, post-hook-validator, task-executor, bootstrap-new-project)
- [ ] Same replace in `commands/hello.md`
- [ ] Same replace in `skills/*/examples/**/*.md` and `skills/*/template*.md` where they show example invocations

### 3. Taskfile
- [ ] `Taskfile.yml` line 4: `PLUGIN_NAME: systematic-dev-kit` → `compass-labs`
- [ ] Line 21 echo string, line 182 nested marketplace JSON key — same replace
- [ ] Grep Taskfile again after edit for any residual `systematic-dev-kit` string (e.g. in comments)

### 4. Docs — process/reference content
- [ ] `CLAUDE.md` — repo purpose section references plugin name
- [ ] `CONTRIBUTING.md`
- [ ] `docs/explanation/**/*.md` (7 files) — mostly namespace references in prose/examples
- [ ] `docs/registry/decisions/001-diataxis-docs-restructure.md` — likely just a path reference, verify before blind replace
- [ ] `specs/architecture-registry/overview.md`, `specs/task-executor-skill/overview.md`

### 5. README (heaviest single file — ~15+ occurrences)
- [ ] Clone URL (`git clone https://github.com/dkoenawan/...`) — update to new slug, but **only after** the repo rename actually happens (see manual step below) or GitHub's redirect will mask a stale link silently
- [ ] `claude plugin marketplace add` / `claude plugin install` / `claude plugin update` command examples
- [ ] `claude --plugin-dir` example path
- [ ] Directory tree diagram (`systematic-dev-kit/`)
- [ ] Every `#### /systematic-dev-kit:<skill>` heading and its example invocation block (init, brand-designer, explore, plan, doc-maintainer, and any others in the file)

### 6. Reviews / historical records — **do not rewrite**
- [ ] `reviews/TEMPLATE.md`, `reviews/adr/*`, `reviews/plan/*`, `reviews/task-executor/*` — these are dated postmortems. Leave references to the old name as-is; they describe what was true at the time. Only touch `reviews/TEMPLATE.md` if it's a live template (not a historical record) — verify which before editing.

### 7. Verification pass
- [ ] Re-run `grep -rl "systematic-dev-kit"` across the repo (excluding `.git/`, `reviews/` historical files, and `graphify-out/`) — should return zero hits outside intentionally-preserved historical records
- [ ] `claude --plugin-dir .` smoke test — confirm `/compass:*` commands resolve
- [ ] Open PR against `main`, do not merge until repo rename (manual step) is confirmed done, since README clone URL depends on it

---

## Activities — Daniel does (manual, external-system, hard-to-reverse)

- [ ] **`gh repo rename compass-labs`** (or via GitHub UI) — GitHub auto-creates a redirect from the old slug, but:
  - [ ] Update your local `origin` remote: `git remote set-url origin git@github:dkoenawan/compass-labs.git`
  - [ ] Any other local clones (other machines) need the same remote update
  - [ ] If any CI/external service references the old clone URL outside this repo (none found in `.github/`, but check any external marketplace listing, personal notes, bookmarks)
- [ ] **npm namespace check** — confirm intent to publish/reference as `compass-labs` only, never bare `compass` (squatted by dormant 2013 Sass/SCSS port per issue note) — no action needed unless/until an npm publish step exists
- [ ] **Marketplace registration** — if `compass-labs`/`systematic-dev-kit` is registered in any external Claude plugin marketplace listing beyond this repo's own `marketplace.json`, update that listing's name/URL manually
- [ ] **Merge the PR** once repo rename is confirmed live (so README clone URLs are accurate at merge time)
- [ ] **Tag the release**: `v1.0.0` per the major-bump decision, after merge

---

## Downstream impacts

| Area | Impact | Mitigation |
|---|---|---|
| **Existing installs** | Anyone with `systematic-dev-kit@systematic-dev-kit` installed will have a broken/stale plugin reference after rename | Note in release/CHANGELOG: users must `claude plugin uninstall systematic-dev-kit` then reinstall as `compass-labs@compass-labs` |
| **In-flight PRs/branches** | Repo rename doesn't break GitHub PRs (redirect handles it), but any branch with hardcoded old-name references will conflict with this rename PR | Land this rename PR promptly; rebase any parallel branches after |
| **Local clones (other machines/collaborators)** | `origin` remote URL still resolves via GitHub redirect, but best practice is to update explicitly | Communicate the rename; each clone owner runs `git remote set-url` |
| **npm** | `compass` (bare) is squatted — cannot publish under that name | Always use `compass-labs` scope/package name, documented in the issue already |
| **Documentation cross-links** | `docs/registry/decisions/001-diataxis-docs-restructure.md` and other docs may reference old paths/slugs | Verify each doc's reference before blind find-replace (flagged above) |
| **Historical reviews** | Postmortems under `reviews/` mention `systematic-dev-kit` as a description of past state | Deliberately NOT rewritten — historical accuracy preserved |
| **Registry (`docs/registry/index.md`)** | Currently empty (0 constructs) | No construct stub updates needed — clean slate |
| **Two other open issues** (#19 domain-neutral scope pass, #20 Terraform scaffolding) | Neither references the plugin name directly, but #19's "domain-neutral scope pass across skills" may overlap with the same SKILL.md files touched here | Sequence: land #18 rename first, then #19 touches the renamed files (avoids merge conflicts on the same lines) |

## Implementation order

1. Claude: branch `feat/compass-rename`, execute Activities 1-4 (plugin identity, namespace, Taskfile, docs)
2. Claude: hold README clone-URL edits (part of Activity 5) until repo rename is confirmed — do the rest of Activity 5 now
3. Claude: open PR, do not merge
4. Daniel: `gh repo rename compass-labs`, update local remote
5. Claude (on request): finish README clone-URL edits pointing at new slug, push
6. Claude: run verification grep pass
7. Daniel: review + merge PR
8. Daniel: tag `v1.0.0`, handle marketplace listing update if applicable

## Open questions

- Should `reviews/TEMPLATE.md` be treated as a live template (edit) or a frozen historical artifact (leave)? Flagged in Activity 6 — needs a quick look before the mechanical pass.
- Any external marketplace listing beyond this repo's own `marketplace.json` that needs manual update? Unconfirmed — Daniel to check.
