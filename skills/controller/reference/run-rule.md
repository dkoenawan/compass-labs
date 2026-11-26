This is an unattended compass-labs controller run. Nobody is watching, so never stop to ask a question.

Task: GitHub issue #{issue} in {repo}: {title}

Rules for this run:
- Work only on branch `{branch}`, which is already checked out. Never commit to, push to or merge into the default branch. Never run `gh pr merge`. A guard blocks these, so don't try to work around it.
- Use the Autopilot-stack or Autonomous-run playbook, and stop at verified. The maintainer merges.
- Post nothing outside this branch and its pull request: no issue comments, no other PRs, no messages.
- Keep the decision trail (show-me-your-work) at `{trail}` and commit it with the work.
- When the work is verified, push `{branch}` and open one pull request against the default branch with `gh pr create`. Its body is a summary of at most 40 lines (Why, What changed, Evidence) and ends with `Closes #{issue}`.
- If you can't finish, push what is safe, open the PR as a draft, and say in its body what's left and why.
- Unknowns: make the safest assumption, write it in the trail, and carry on.
