# Add a layer's Implement guidance

> → Reference: [Implement standard, layer plug-in contract](../reference/implement/standard.md#layer-plug-in-contract) · → Example: [`skills/backend/`](../../skills/backend/SKILL.md)
> Origin: #28

Use this when a layer (for example frontend, database or an AI-agent layer) needs its own Implement guidance. The Implement standard finds a layer by path, so you add files and a listing; you don't edit the standard.

1. **Pick the layer's name as the Design standard writes it.** The Implement standard reads the layer named first in a design item's Component cell, so the folder name must match that word, in lower case (`frontend`, `database`).

2. **Create the layer's home, `skills/{layer}/SKILL.md`.** Give it `name: {layer}` and a description in the frontmatter. In the body, add a table indexing the layer's files and who reads them, as `skills/backend/SKILL.md` does. If the layer has no design standard yet, list `reference/design.md` as not written, with its issue.

3. **Write `skills/{layer}/reference/implement.md`.** It must supply four things, each as its own section:
   1. **How to build it:** detect the established stack with the signals in `skills/design/reference/stack-defaults.md`, and link to that file. Don't restate a default stack.
   2. **Which tests:** the unit and component tests each item of this layer needs. Name no integration, UI or Playwright test; checks that need one go under Handed to Test.
   3. **The layer's artifact:** what Implement records under Layer artifacts → `### {Layer}` in `implement/as-built.md`, as a table.
   4. **The check against the design:** how to compare what was built with the layer's design, with one row per designed element, and a rule that each mismatch becomes a variation.

   Use plugin paths as `${CLAUDE_PLUGIN_ROOT}/skills/…`, never bare `skills/…`. Anything the guidance can't cover yet (for example a non-OpenAPI backend API) points to the Implement standard's fallback and cites its follow-up issue.

4. **List the skill.** Add `./skills/{layer}` to the `compass-labs` plugin's `skills` array in `.claude-plugin/marketplace.json`, and add the folder and a `/compass-labs:{layer}` section to the README. This is the only edit outside the layer's folder.

5. **Update the harness tests.** `tests/session/implement_standard_test.sh` asserts which layer folders exist: remove the layer from its "should not exist yet" loop, and add content assertions for the new `reference/implement.md` like the backend's. Don't add the layer's name to `skills/implement/SKILL.md`: the test fails if the standard names any layer.

6. **Run `bash tests/run.sh`.** It must pass. `marketplace_test.sh` fails until step 4 is done, and `implement_standard_test.sh` fails until step 5 is done.

7. **Version it as MINOR.** A new layer adds a skill and changes nothing that exists.
