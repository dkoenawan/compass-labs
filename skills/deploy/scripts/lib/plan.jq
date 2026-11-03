# The --plan output for check-declaration.sh, on a valid declaration.
# See skills/deploy/SKILL.md, sections 3 and 5.
  def kindtxt: if .merge == true then "production_affecting, merge" else .kind end;
  def runtxt: if .merge == true then "" else ": " + .run end;
  .release_mode as $mode
  | "plan: release mode: \($mode)",

    # L1: in declared order; once a step waits, every later L1 step waits.
    ( reduce ([.l1.parts[] | .name as $n | .setup | to_entries[] | {part: $n, i: (.key + 1), s: .value}][]) as $x
        ({waiting: false, out: []};
         (.waiting or $x.s.kind != "routine") as $w
         | .waiting = $w
         | .out += ["plan: L1 part '\($x.part)' step \($x.i) '\($x.s.name)' (\($x.s | kindtxt)): "
             + (if $w then (if $x.s.kind == "routine" then "waits (an earlier step waits for the user)" else "waits for the user" end)
                else "may run, if L1 is needed for the part" end) + ($x.s | runtxt)])
      | .out[] ),

    ( if ([.l1.parts[].setup[] | select(.kind != "routine")] | length) > 0
      then "plan: note: an L1 step waits for the user; if L1 runs for that part, no L2 step runs until the user instructs it"
      else empty end ),

    # L2: own_session waits for a release session; otherwise declared order.
    ( if $mode == "own_session" then
        (.l2.steps | to_entries[] | "plan: L2 step \(.key + 1) '\(.value.name)' (\(.value | kindtxt)): waits for a release session")
      else
        ( reduce (.l2.steps | to_entries[]) as $x ({waiting: false, out: []};
            (.waiting or $x.value.kind != "routine") as $w
            | .waiting = $w
            | .out += ["plan: L2 step \($x.key + 1) '\($x.value.name)' (\($x.value | kindtxt)): "
                + (if $w then (if $x.value.merge == true then "waits for the user (the merge is always the user's)"
                               elif $x.value.kind == "routine" then "waits (an earlier step waits for the user)"
                               else "waits for the user's instruction" end)
                   else "may run" end) + ($x.value | runtxt)])
          | .out[] )
      end ),

    # Tier (D6): a merge never counts towards the risk.
    ( [.l2.steps[] | select(.kind == "production_affecting" and .merge != true) | .name] as $prod2
      | [.l1.parts[].setup[] | select(.kind == "production_affecting") | .name] as $prod1
      | (if $mode == "own_session" then {t: "skip", r: "the release waits for a release session and no step runs"}
         elif ($prod2 | length) > 0 then {t: "full", r: "a production-affecting step is waiting: \($prod2 | join(", ")) (normal change)"}
         else {t: "short", r: "every step that runs is routine (standard change); the merge doesn't count"} end) as $base
      | (if ($prod1 | length) > 0 then {t: "full", r: "an L1 setup step is production-affecting: \($prod1 | join(", ")) (normal change)"}
         elif $base.t == "skip" then {t: "short", r: "L1 runs and every step that runs is routine (standard change); the release waits for a release session"}
         else $base end) as $l1
      | "plan: tier: \($base.t): \($base.r)",
        "plan: tier if L1 runs: \($l1.t): \($l1.r)" )
