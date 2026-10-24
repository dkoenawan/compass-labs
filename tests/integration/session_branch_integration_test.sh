#!/usr/bin/env bash
# session_branch_integration_test.sh
# Test-phase integration checks for #37: the REAL plugin hooks and scripts
# (no stubs) against throwaway repos with local bare remotes. The New session,
# Resume and Close procedures of skills/session/SKILL.md are executed step by
# step as the orchestrator would, and every git commit/push is first passed
# through the real hooks/session-branch-guard.sh (as Claude Code's PreToolUse
# hook would) and only run if the guard allows it.
set -uo pipefail
PLUGIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$PLUGIN/hooks/session-branch-guard.sh"
START="$PLUGIN/hooks/session-start.sh"
DEFB="$PLUGIN/skills/session/scripts/default-branch.sh"
LIST="$PLUGIN/skills/session/scripts/list-sessions.sh"
W="$(mktemp -d)/work"
rm -rf "$W"; mkdir -p "$W"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

PASS=0; FAILN=0
ok()   { echo "PASS  $1"; PASS=$((PASS+1)); }
bad()  { echo "FAIL  $1"; FAILN=$((FAILN+1)); }
check(){ local d="$1"; shift; if "$@"; then ok "$d"; else bad "$d"; fi; }

# mkrepo NAME DEFAULT -> clone at $W/NAME, remote $W/NAME.git, one commit A
mkrepo() {
  local n="$1" d="$2"
  git init -q --bare -b "$d" "$W/$n.git"
  git init -q -b "$d" "$W/$n"
  ( cd "$W/$n" && echo a > README && git add README && git commit -qm A \
    && git remote add origin "$W/$n.git" && git push -q -u origin "$d" 2>/dev/null \
    && git remote set-head origin -a >/dev/null 2>&1 )
}

# guard CWD CMD -> exit code of the real hook; stderr to $W/guard.err
guard() {
  jq -nc --arg c "$2" --arg d "$1" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' \
    | bash "$GUARD" 2>"$W/guard.err"
}
# grun CWD CMD -> guard, then run CMD in CWD if allowed; returns 99 if blocked
grun() {
  if guard "$1" "$2"; then ( cd "$1" && eval "$2" ); else return 99; fi
}

writelog() { # writelog REPO SLUG ISSUE BRANCH [STATUS]
  mkdir -p "$1/docs/sessions/$2/define"
  cat > "$1/docs/sessions/$2/log.md" <<EOF
---
session: $2
type: feature
issue: $3
branch: $4
phase: define
status: ${5:-active}
milestone: none
active_agent: main
next_step: "Start Define"
---
# Session Log
EOF
  echo "# Define" > "$1/docs/sessions/$2/define/index.md"
}

# new_session REPO ISSUE BRANCHNAME MODE   (MODE: default | use | new)
# Runs New session flow steps 2b-4 exactly as SKILL.md states them.
new_session() {
  local r="$1" issue="$2" name="$3" mode="$4" def cur
  def="$(cd "$r" && bash "$DEFB" 2>"$W/defb.err")" || { echo "STOP: $(cat "$W/defb.err")"; return 1; }
  cur="$(git -C "$r" branch --show-current)"
  if [[ "$mode" == use ]]; then name="$cur"; fi
  if [[ "$name" != "$cur" ]]; then
    if git -C "$r" show-ref --verify --quiet "refs/heads/$name"; then
      git -C "$r" switch -q "$name" 2>"$W/switch.err" || { echo "STOP: $(cat "$W/switch.err")"; return 1; }
    else
      git -C "$r" switch -q -c "$name" "$def" 2>"$W/switch.err" || { echo "STOP: $(cat "$W/switch.err")"; return 1; }
    fi
  fi
  writelog "$r" "2026-10-24-widget" "$issue" "$name"
  grun "$r" "git add docs/sessions && git commit -qm 'docs(sessions): open session #$issue'" || return 1
  grun "$r" "git push -q -u origin $name 2>/dev/null" || return 1
}

tip() { git -C "$1" rev-parse "$2" 2>/dev/null; }

echo "== REQ-001 / REQ-003: clean main at A, user accepts feat/5-widget"
mkrepo r1 main; A="$(tip "$W/r1" main)"
check "default-branch.sh reports main" test "$(cd "$W/r1" && bash "$DEFB")" = main
new_session "$W/r1" 5 feat/5-widget default
check "opening commit is on feat/5-widget" test "$(git -C "$W/r1" branch --show-current)" = feat/5-widget
check "opening commit is not A" test "$(tip "$W/r1" HEAD)" != "$A"
check "feat/5-widget pushed (origin tip == HEAD)" test "$(git -C "$W/r1.git" rev-parse feat/5-widget)" = "$(tip "$W/r1" HEAD)"
check "upstream set by -u" test "$(git -C "$W/r1" rev-parse --abbrev-ref '@{u}')" = origin/feat/5-widget
check "main still at A" test "$(tip "$W/r1" main)" = "$A"
check "origin/main (remote) still at A" test "$(git -C "$W/r1.git" rev-parse main)" = "$A"
check "opening commit's log.md names branch: feat/5-widget" \
  bash -c "git -C '$W/r1' show HEAD:docs/sessions/2026-10-24-widget/log.md | grep -qx 'branch: feat/5-widget'"

echo "== REQ-007: user replaces the name with team/ABC-5-widget"
mkrepo r7 main; A="$(tip "$W/r7" main)"
new_session "$W/r7" 5 team/ABC-5-widget default
check "branch created is team/ABC-5-widget" test "$(git -C "$W/r7" branch --show-current)" = team/ABC-5-widget
check "recorded branch is team/ABC-5-widget" \
  bash -c "git -C '$W/r7' show HEAD:docs/sessions/2026-10-24-widget/log.md | grep -qx 'branch: team/ABC-5-widget'"
check "no feat/5-widget created" bash -c "! git -C '$W/r7' show-ref --quiet refs/heads/feat/5-widget"
check "main and remote main at A" bash -c "[[ \$(git -C '$W/r7' rev-parse main) == $A && \$(git -C '$W/r7.git' rev-parse main) == $A ]]"

echo "== REQ-002: feat/5-existing checked out"
mkrepo r2 main; A="$(tip "$W/r2" main)"
( cd "$W/r2" && git switch -qc feat/5-existing && echo x > x && git add x && git commit -qm X )
X="$(tip "$W/r2" HEAD)"
check "guard sees a non-default branch (no block for commit there)" guard "$W/r2" "git commit -m y"
new_session "$W/r2" 5 ignored use
check "choice 'use': opening commit on feat/5-existing" test "$(git -C "$W/r2" branch --show-current)" = feat/5-existing
check "choice 'use': parent is X" test "$(git -C "$W/r2" rev-parse HEAD~1)" = "$X"
mkrepo r2b main; A="$(tip "$W/r2b" main)"
( cd "$W/r2b" && git switch -qc feat/5-existing && echo x > x && git add x && git commit -qm X )
new_session "$W/r2b" 5 feat/5-widget new
check "choice 'new': opening commit on feat/5-widget" test "$(git -C "$W/r2b" branch --show-current)" = feat/5-widget
check "choice 'new': branch starts from main's tip A, not feat/5-existing" test "$(git -C "$W/r2b" rev-parse HEAD~1)" = "$A"
check "main still at A" test "$(tip "$W/r2b" main)" = "$A"

echo "== REQ-006: remote default trunk, no main"
mkrepo r6 trunk; T="$(tip "$W/r6" trunk)"
check "no main branch exists" bash -c "! git -C '$W/r6' show-ref --quiet refs/heads/main"
check "default-branch.sh reports trunk" test "$(cd "$W/r6" && bash "$DEFB")" = trunk
new_session "$W/r6" 5 feat/5-widget default
check "opening commit not on trunk" test "$(git -C "$W/r6" branch --show-current)" = feat/5-widget
check "trunk and remote trunk unchanged" bash -c "[[ \$(git -C '$W/r6' rev-parse trunk) == $T && \$(git -C '$W/r6.git' rev-parse trunk) == $T ]]"
( cd "$W/r6" && git switch -q trunk && writelog "$W/r6" 2026-10-24-other 6 feat/6-x && git add docs )
grun "$W/r6" "git commit -qm 'log change'"; rc=$?
check "direct session commit on trunk blocked (exit 2 -> 99)" test "$rc" = 99
check "block message names trunk" grep -q "trunk" "$W/guard.err"
check "trunk head unchanged" test "$(tip "$W/r6" trunk)" = "$T"
echo "   guard said: $(head -c 300 "$W/guard.err")"

echo "== REQ-005 / DES-003 handed check (real hook, real collaborators), main"
mkrepo r5 main; A="$(tip "$W/r5" main)"
writelog "$W/r5" 2026-10-24-widget 5 feat/5-widget
( cd "$W/r5" && git add docs )
grun "$W/r5" "git commit -m 'log.md change'"; rc=$?
check "commit on main with active session blocked" test "$rc" = 99
check "message names main" grep -q "main" "$W/guard.err"
echo "   guard said: $(head -c 300 "$W/guard.err")"
check "main head unchanged" test "$(tip "$W/r5" main)" = "$A"
guard "$W/r5" "git push origin HEAD:main"; check "git push origin HEAD:main blocked" test $? = 2
guard "$W/r5" "git push"; check "bare git push on main blocked" test $? = 2
guard "$W/r5" "ls"; check "ls allowed" test $? = 0
guard "$W/r5" "git status"; check "git status allowed" test $? = 0
( cd "$W/r5" && git switch -qc feat/5-widget )
grun "$W/r5" "git commit -qm 'open session'"; check "git commit on feat/5-widget allowed and made" test $? = 0
grun "$W/r5" "git push -q -u origin feat/5-widget 2>/dev/null"; check "git push -u origin feat/5-widget allowed and made" test $? = 0
check "remote main still at A" test "$(git -C "$W/r5.git" rev-parse main)" = "$A"
# no active session, nothing staged under docs/sessions/
mkrepo r5n main
( cd "$W/r5n" && echo b > b && git add b )
grun "$W/r5n" "git commit -qm b"; check "no session, nothing staged in docs/sessions: commit on main allowed" test $? = 0
# trunk variant
mkrepo r5t trunk; T="$(tip "$W/r5t" trunk)"
writelog "$W/r5t" 2026-10-24-widget 5 feat/5-widget; ( cd "$W/r5t" && git add docs )
guard "$W/r5t" "git commit -m x"; check "trunk default, no main: commit blocked" test $? = 2
check "  message names trunk" grep -q trunk "$W/guard.err"
guard "$W/r5t" "git push origin HEAD:trunk"; check "  push HEAD:trunk blocked" test $? = 2
# no jq: PATH of symlinks to everything in /usr/bin and /bin except jq
NJ="$W/nojq-bin"; mkdir -p "$NJ"
for f in /usr/bin/* /bin/*; do b="${f##*/}"; [[ "$b" == jq ]] && continue; [[ -e "$NJ/$b" ]] || ln -s "$f" "$NJ/$b"; done
input="$(printf '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"},"cwd":"%s"}' "$W/r5t")"
( cd "$W/r5t" && git switch -q trunk 2>/dev/null; PATH="$NJ" bash "$GUARD" <<<"$input" 2>"$W/nojq.err" ); rc=$?
check "no jq: allowed (exit 0)" test "$rc" = 0
check "no jq: warning printed" grep -qi "jq not found" "$W/nojq.err"

echo "== REQ-010: feat/5-widget checked out in another worktree"
mkrepo r10 main; A="$(tip "$W/r10" main)"
git -C "$W/r10" branch feat/5-widget
git -C "$W/r10" worktree add -q "$W/r10-wt" feat/5-widget 2>/dev/null
before="$(git -C "$W/r10" for-each-ref --format='%(objectname) %(refname)' | sort)"
out="$(new_session "$W/r10" 5 feat/5-widget default)"; rc=$?
echo "   told the user: $out"
check "flow stopped (non-zero)" test "$rc" != 0
check "reason relayed from git (worktree)" bash -c "grep -qi worktree <<<\"\$1\"" _ "$out"
check "no session folder written" test ! -e "$W/r10/docs/sessions"
check "no ref moved anywhere" test "$before" = "$(git -C "$W/r10" for-each-ref --format='%(objectname) %(refname)' | sort)"
check "still on main" test "$(git -C "$W/r10" branch --show-current)" = main

echo "== REQ-004 / DES-007: resume with main checked out"
mkrepo r4 main; A="$(tip "$W/r4" main)"
new_session "$W/r4" 5 feat/5-widget default >/dev/null
git -C "$W/r4" switch -q main
check "session folder not in main's working tree" test ! -e "$W/r4/docs/sessions/2026-10-24-widget"
L="$(bash "$LIST" "$W/r4")"; echo "   list-sessions: $L"
check "list-sessions finds it on feat/5-widget with recorded branch" \
  test "$L" = "$(printf '2026-10-24-widget\tactive\tfeat/5-widget\tfeat/5-widget')"
# guard backstop: an un-switched milestone commit on main is refused
writelog "$W/r4" 2026-10-24-widget 5 feat/5-widget; ( cd "$W/r4" && git add docs )
guard "$W/r4" "git commit -m 'Define complete'"; check "backstop: milestone commit on main would be blocked" test $? = 2
( cd "$W/r4" && git reset -q && rm -rf docs )
# Resume flow: branch = col 4 (or col 3 if -), switch if not current
sb="$(cut -f4 <<<"$L")"; [[ "$sb" == - ]] && sb="$(cut -f3 <<<"$L")"
[[ "$(git -C "$W/r4" branch --show-current)" == "$sb" ]] || git -C "$W/r4" switch -q "$sb"
check "resume switched to feat/5-widget before recap" test "$(git -C "$W/r4" branch --show-current)" = feat/5-widget
sed -i 's/^milestone: none/milestone: define/' "$W/r4/docs/sessions/2026-10-24-widget/log.md"
echo "## Define complete" >> "$W/r4/docs/sessions/2026-10-24-widget/log.md"
grun "$W/r4" "git add docs && git commit -qm 'docs(sessions): Define complete — #5'"; check "milestone commit allowed" test $? = 0
grun "$W/r4" "git push -q 2>/dev/null"; check "milestone push allowed" test $? = 0
check "milestone commit on feat/5-widget" bash -c "git -C '$W/r4' log -1 --format=%s feat/5-widget | grep -q 'Define complete'"
check "remote feat/5-widget has it" test "$(git -C "$W/r4.git" rev-parse feat/5-widget)" = "$(tip "$W/r4" feat/5-widget)"
check "main and origin/main unchanged" bash -c "[[ \$(git -C '$W/r4' rev-parse main) == $A && \$(git -C '$W/r4.git' rev-parse main) == $A ]]"
# resume switch failure: branch checked out elsewhere
git -C "$W/r4" switch -q main; git -C "$W/r4" worktree add -q "$W/r4-wt" feat/5-widget 2>/dev/null
git -C "$W/r4" switch -q feat/5-widget 2>"$W/sw.err"; rc=$?
check "resume switch failure surfaces git's reason" bash -c "[[ $rc != 0 ]] && grep -qi worktree '$W/sw.err'"

echo "== DES-008: real session-start.sh with real list-sessions.sh"
# r4 now: main checked out, session only on feat/5-widget
SS="$(jq -nc --arg d "$W/r4" '{agent_type:"compass-labs:orchestrator",cwd:$d}' | bash "$START")"; rc=$?
echo "$SS" | sed 's/^/   /'
check "session-start exits 0" test "$rc" = 0
check "session on another branch shown 'on feat/5-widget'" grep -q "2026-10-24-widget (#5, active) — on feat/5-widget" <<<"$SS"
check "phase read from that branch's log.md (define)" grep -q "phase: define" <<<"$SS"
check "hook did not switch branch" test "$(git -C "$W/r4" branch --show-current)" = main
SS2="$(jq -nc --arg d "$W/r1" '{agent_type:"compass-labs:orchestrator",cwd:$d}' | bash "$START")"
check "working-tree session shown without 'on'" bash -c "grep -q '2026-10-24-widget (#5, active) — phase' <<<\"\$1\"" _ "$SS2"

echo "== REQ-008 / DES-006: draft PR prompt with a recording gh shim (no real GitHub)"
mkrepo r8 main
GHB="$W/ghbin"; mkdir -p "$GHB"; : > "$W/gh.calls"; : > "$W/gh.prs"
cat > "$GHB/gh" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "$W/gh.calls"
case "\$1 \$2" in
  "pr list") cat "$W/gh.prs" ;;
  "pr create") echo "draft \$*" >> "$W/gh.prs"; echo "https://github.com/x/y/pull/1" ;;
  "pr merge") echo MERGED >> "$W/gh.merged" ;;
esac
EOF
chmod +x "$GHB/gh"
export PATH="$GHB:$PATH"
new_session "$W/r8" 5 feat/5-widget default
DEF="$(cd "$W/r8" && bash "$DEFB")"
# step 4 order: commit, push -u, PR prompt (check open PR, user agrees), then gh-milestone
open="$(gh pr list --head feat/5-widget --state open)"
check "no open PR before prompt" test -z "$open"
gh pr create --draft --base "$DEF" --head feat/5-widget --title "Widget (#5)" --body "Refs #5" >/dev/null
check "draft PR from feat/5-widget into main created" grep -q -- "--draft --base main --head feat/5-widget" "$W/gh.prs"
check "PR body refs the issue" grep -q "Refs #5" "$W/gh.calls"
check "branch already on remote when PR opened" git -C "$W/r8.git" rev-parse --verify -q feat/5-widget
check "a second run sees the open PR (prompt skipped)" test -n "$(gh pr list --head feat/5-widget --state open)"

echo "== REQ-009: Close procedure with no merge request"
grep -nE 'gh pr merge|git merge' "$PLUGIN/skills/session/SKILL.md" "$PLUGIN/agents/orchestrator.md" | sed 's/^/   /'
# Run Close steps 1-5 on r8 (git side) through the guard
sed -i 's/^status: active/status: archived/; s/^milestone: none/milestone: close/' "$W/r8/docs/sessions/2026-10-24-widget/log.md"
grun "$W/r8" "git add docs && git commit -qm 'docs(sessions): close'"; c1=$?
( cd "$W/r8" && bash "$PLUGIN/skills/session/scripts/archive-session.sh" docs/sessions/2026-10-24-widget >/dev/null 2>&1 ); c2=$?
grun "$W/r8" "git add -A && git commit -qm 'docs(sessions): archive'"; c3=$?
grun "$W/r8" "git push -q 2>/dev/null"; c4=$?
check "Close git steps ran (commit, archive, commit, push)" test "$c1$c2$c3$c4" = 0000
check "no gh pr merge was called" test ! -e "$W/gh.merged"
check "remote main unchanged by Close" test "$(git -C "$W/r8.git" rev-parse main)" = "$(git -C "$W/r8" rev-parse main)"
check "PR still listed open" test -n "$(gh pr list --head feat/5-widget --state open)"

echo
echo "$PASS passed, $FAILN failed"
[[ $FAILN == 0 ]]
