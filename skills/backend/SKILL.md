---
name: backend
description: The backend layer's home. Indexes the backend's per-phase guidance; today, how the Implement phase builds a backend DES item (stack, unit and component tests, the OpenAPI document as built and its Scalar render, and the API check against the design). Read by the Implement standard through the skills/{layer}/reference/implement.md path convention.
---

# Backend layer

This folder is the backend layer's one home (the layer contract in `${CLAUDE_PLUGIN_ROOT}/skills/design/kinds/three-tier.md`). Each phase finds its backend guidance here by path, so nothing else lists this layer.

| File | Holds | Read by |
|---|---|---|
| [`reference/implement.md`](reference/implement.md) | How Implement builds a backend `DES-*` item: stack, tests, the OpenAPI document as built, and the API check against the design | The Implement standard (`${CLAUDE_PLUGIN_ROOT}/skills/implement/SKILL.md`, part 4) |
| `reference/design.md` | The backend design standard | Not written yet: dkoenawan/compass-labs#47. Until then, Design covers the backend in the all-kinds sections |
