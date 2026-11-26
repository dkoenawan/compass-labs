---
date: 2026-11-26
type: decision
title: Kept the internal run role "compass" and the compass_repo key
pr: #106
issue: #34
---

# Kept the internal run role "compass" and the compass_repo key

```mermaid
flowchart LR
  old[runs.jsonl + configs: compass] --> keep[unchanged in 4.0.0]
  keep --> later[rename only with a migration]
```

- Old run logs, configs and findings typed `compass` are still read.
- Renaming would silently drop history, so it is deferred.
- Revisit with a migration if the leftover name confuses readers.

Evidence: docs/trails/2026-11-26-34-rename-the-plugin-to-trellis.tsv rows 3–4
