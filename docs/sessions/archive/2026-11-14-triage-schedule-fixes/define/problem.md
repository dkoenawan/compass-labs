# Problem: Triage scheduled-run fixes

> Part of [index](index.md) · Define

### Need and stakeholders

- **NEED-01:** When Claude Code (or gh) updates itself on a machine with an installed triage schedule, the maintainer who installed it wants the weekly runs to keep working, so they keep getting a report each week without reinstalling or hand-editing the crontab.
- **NEED-02:** When a maintainer reads a scheduled triage report, they want its header's run date to be the same local date as its title and run log, so they can tell which week's run it is without cross-checking.

### Evidence

- On a self-updating install, `claude` on PATH is the symlink `~/.local/bin/claude`, pointing into `~/.local/share/claude/versions/{version}` [observed: #93; `docs/explanation/triage/overview.md:138`].
- The installer writes the symlink's resolved target into every cron line [observed: `skills/triage/scripts/install-schedule.sh:83, 158`].
- After an auto-update removes that version, every scheduled run fails preflight and publishes nothing [observed: #93, logged under REQ-022 of the #86 session].
- The maintainer's own VM schedule already needed a hand edit of the claude path to keep running [observed: #93 workaround; the maintainer's VM setup notes for #92/#93].
- `gh` goes through the same resolution, so a symlinked `gh` (for example a package manager's shim) would be pinned the same way [observed: code, `install-schedule.sh:86`]; whether any user's `gh` update removes its target is unknown [assumed].
- A scheduled report's header run date can be the UTC day while its title is the local Saturday [observed: #91].
- The headless prompt carries no date, so the model fills the header's run date itself [observed: `run-scheduled.sh:166-173`]; that it uses UTC is [assumed].
- Claude Code auto-updates often enough that a weekly schedule meets an update within weeks [assumed].

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | A scheduled run's preflight and stock-take after the `claude` (or `gh`) version present at install has been removed and the PATH symlink points to a new version | Preflight passes and the run uses the binary the symlink points to now; no reinstall or crontab edit | Test phase, with a symlinked stub; and the first real scheduled run after a Claude Code auto-update on the maintainer's machine | NEED-01 |
| OUT-02 | The `- Run date:` line of a published scheduled report, compared with its title's date | Equal in every scheduled report, including a run whose local date is a day ahead of UTC | Test phase, with `TRIAGE_NOW` at a UTC Friday that is Saturday in Pacific/Auckland; and the next real scheduled report | NEED-02 |
