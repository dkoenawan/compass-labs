# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model` and spawn `generalPurpose`). Alias entries in a panel list still count toward its fan-out.
# compass-labs subscription-safe roles (ADR-011, #98): Claude models only, never fable (needs usage credits) or another vendor (needs another account); nothing above high.
# defaults: 3
# budget: medium (high)
feature, refactoring: opus high
bug-fix: opus high
perf-issue: opus high
hillclimb: sonnet high
judgment and prose: sonnet high
arena runners: opus high, sonnet high
arena cross-judge pool: opus high, sonnet high
swarm workers: sonnet high
interrogate reviewers: opus high, sonnet high
