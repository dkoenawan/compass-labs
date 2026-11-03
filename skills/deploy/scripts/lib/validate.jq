# Validation rules for check-declaration.sh: prints one line per problem in
# a deploy declaration. See skills/deploy/reference/declaration.md.
  def steps_of(where; list):
    (list // []) | to_entries[] | {where: where, i: (.key + 1), s: .value};
  def steplabel: "\(.where) step \(.i)\(if (.s.name // "") != "" then " '\(.s.name)'" else "" end)";
  def check_step:
    (if (.s | type) != "object" then "invalid: \(steplabel) isn't an object"
     else
       (if (.s.name // "") == "" then "missing: name (\(steplabel))" else empty end),
       (if (.s.merge != true) and ((.s.run // "") == "") then "missing: run (\(steplabel))" else empty end),
       (if (.s.kind // "") == "" then "missing: kind, routine or production_affecting (\(steplabel))"
        elif (.s.kind != "routine" and .s.kind != "production_affecting") then "invalid: kind '\(.s.kind)' (\(steplabel))"
        else empty end),
       (if .s.merge == true and .s.kind != "production_affecting" then "merge marked routine: \(steplabel) must be production_affecting" else empty end)
     end);

  (if .deployment == null then "missing: deployment (declared or none)"
   elif .deployment != "declared" then "invalid: deployment '\(.deployment)' (declared or none)"
   else empty end),
  (if .release_mode == null then "missing: release mode (release_mode: in_session or own_session)"
   elif (.release_mode != "in_session" and .release_mode != "own_session") then "invalid: release_mode '\(.release_mode)' (in_session or own_session)"
   else empty end),
  (if (.l1.parts | type) != "array" then "missing: L1 setup (l1.parts, a list; it may be empty)"
   else (.l1.parts | to_entries[] |
     (if (.value.name // "") == "" then "missing: name (L1 part \(.key + 1))" else empty end),
     (if (.value.setup | type) != "array" then "missing: setup (L1 part '\(.value.name // (.key + 1))')" else empty end))
   end),
  (if (.l2.steps | type) != "array" or (.l2.steps | length) == 0 then "missing: L2 steps (l2.steps)" else empty end),
  ([ (.l1.parts // [] | if type == "array" then .[] else empty end | . as $p
        | steps_of("L1 part '\($p.name // "?")'"; ($p.setup | if type == "array" then . else [] end))),
     steps_of("L2"; (.l2.steps | if type == "array" then . else [] end)) ][] | check_step),
  (if (.confirmation.run // "") == "" then "missing: confirmation (confirmation.run)" else empty end),
  (if .rollback == null or .rollback == "" or .rollback == [] then "missing: rollback" else empty end),
  (if .versioning.tag != null and ((.versioning.tag | tostring) | contains("{version}") | not)
   then "versioning.tag has no {version}: \(.versioning.tag)" else empty end)
