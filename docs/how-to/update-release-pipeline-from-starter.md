# Update compass-labs' release pipeline from the starter

> → Reference: [Deploy standard: the starter workflow](../reference/deploy/standard.md#the-starter-workflow) · → Concepts: [Deploy overview](../explanation/deploy/overview.md)
> Origin: #30

compass-labs' own release pipeline, `.github/workflows/release.yml` and `.github/scripts/release-tag.sh`, is an unedited install of the Deploy standard's starter. `tests/session/own_pipeline_test.sh` fails if the two files differ from a fresh install, so a change to the pipeline is made in the starter template and installed again, never by editing `.github/` directly.

Use this when you need to change how compass-labs tags and publishes releases, or when a fix to the starter should reach compass-labs' own pipeline.

## Steps

1. **Work on a branch**, never the default branch (the session branch, if this is session work).
2. **Change the template**, not the copy: `skills/deploy/templates/github/release.yml` and/or `skills/deploy/templates/github/release-tag.sh`. Keep the starter generic: no `dkoenawan/compass-labs`, no `CLAUDE_PLUGIN_ROOT`, no compass-labs values outside the settings block placeholders.
3. **Run the starter's own tests:**
   ```bash
   bash tests/session/release_tag_test.sh
   bash tests/session/release_workflow_test.sh
   bash tests/session/install_starter_test.sh
   ```
4. **Remove the installed copies.** `install-starter.sh` never overwrites; it refuses (exit 5) while either file exists.
   ```bash
   rm .github/workflows/release.yml .github/scripts/release-tag.sh
   ```
5. **Install again** from the repo root. The values come from `.claude/deploy.json`'s `versioning` block (`.claude-plugin/plugin.json`, `.version`, `compass-labs--v{version}`); the script doesn't touch the declaration, which already lists the `merge-triggered pipeline` part.
   ```bash
   bash skills/deploy/scripts/install-starter.sh .
   ```
6. **Check the result:** `git diff .github/` should show only the change you made to the template, and
   ```bash
   bash tests/session/own_pipeline_test.sh
   bash .github/scripts/release-tag.sh --check
   ```
   should pass and print the tag a merge would create.
7. **Commit the template and both installed files together**, staged by name, and open or update the pull request. Its `release` workflow run on the pull request (the `check` job) is the first proof the changed files load on GitHub; the tag-and-publish job only runs once the pull request is merged.

## If something goes wrong after the merge

- **The run failed before publishing:** no tag or release exists yet. Fix forward in a new pull request, or re-run `gh release create compass-labs--v{version} --target {merge sha} --generate-notes` by hand.
- **The run failed because the tag exists:** that's the pipeline refusing to overwrite a tag. Bump to a new version in a new pull request; never move or delete a published tag.
