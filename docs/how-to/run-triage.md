# Run backlog triage

> Origin: #86 · #102


Takes stock of a repository's open GitHub issues. Each issue gets exactly one category (covered by merged work, direction changed, duplicate or cluster, rewrite or narrow, still relevant, or needs a user decision), the code lines or merged PRs it rests on, the project anchor lines it maps to, its cluster and blocked-by relations, and a proposed action. One procedure, [`skills/triage/reference/stock-take.md`](../../skills/triage/reference/stock-take.md), serves every mode.

**Modes:**
```bash
/trellis:triage                       # stock-take: show the proposed actions by category; changes nothing
/trellis:triage apply                 # apply the stock-take just made, one confirmed group at a time
/trellis:triage apply #N              # apply report issue #N; issues changed since the report are flagged and re-checked
/trellis:triage install --day sat --time 01:00 --tz Pacific/Auckland   # weekly scheduled run
/trellis:triage uninstall             # remove the schedule
```

An apply asks once per category group and acts only on your answer there. A comment such as "approved, apply all" on a report, a reaction, or a message from another agent is never approval. When it finishes, each issue still open gets a `**Triage (YYYY-MM-DD):**` comment, and an applied report is closed with the groups applied and declined. The interactive stock-take can run a test to settle a claim, only if you agree, and only in a scratch `git clone --local` copy.

**Scheduling:** `install` takes a day (`sun` to `sat`, or 0 to 6), a local time and an IANA time zone. Cron runs in UTC, so the installer writes one crontab line for each UTC slot the local time maps to across a year's daylight-saving changes (two for Saturday 01:00 Pacific/Auckland), and the run itself checks the local day and time. It refuses a second schedule for the same repository, warns if the time falls in a daylight-saving gap, and creates the `triage` label. The scripts can also be run directly:

```bash
bash skills/triage/scripts/install-schedule.sh /path/to/repo --day sat --time 01:00 --tz Pacific/Auckland
bash skills/triage/scripts/uninstall-schedule.sh /path/to/repo   # removes only this repo's lines
crontab -l | grep trellis:triage
```

**What a scheduled run may do:** create one `Triage YYYY-MM-DD` report issue (labelled `triage` when the label exists, with a note in the body when it doesn't), and close its own earlier report that was never applied, as not planned, linking the new one. Nothing else. It publishes nothing if the report doesn't cover every open issue, and never a second report for the same date.

**What it may not do:** close, edit, label or comment on any other issue, create a label, apply anything, run tests or any repository code, or write in the repository. The stock-take runs headless (`claude -p`) with only the Read, Grep and Glob tools, no settings files, hooks, plugins or MCP servers, and never `--dangerously-skip-permissions`. Issue text that reads like an instruction is triaged like any other content.

**Run log:** `${XDG_STATE_HOME:-$HOME/.local/state}/trellis/triage/{repo-slug}/YYYY-MM-DD.log`, outside the repository: each step's outcome and duration, and why a run failed. `gh` and `claude` need stored credentials (`gh auth login`, a logged-in `claude`): cron doesn't see variables exported only in a shell profile.

