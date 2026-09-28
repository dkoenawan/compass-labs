# Problem statement: methods record

> Standard: [problem-statement](../SKILL.md) · Types: [feature](../types/feature.md), [bugfix](../types/bugfix.md)

This is the verdict record for the problem-statement candidates in the #32 research, bounded as agreed in #23 (Scope item 7). Each candidate has one Feature verdict and one Bugfix verdict. Adopt and adapt verdicts say when the method applies and, for Feature, which outcome requirement it serves (the Serves column cites #23's `REQ-023` to `REQ-045`). A Bugfix verdict of "deferred to #40" is settled when Bugfix framing is deepened, and needs no rationale here.

**Verdicts:** *adopt* means the type file uses the method as it is. *Adapt* means the type file uses part of it, as the rationale says. *Reject* means the type file doesn't use it. Every method is still a template, never a mandate: a problem statement that has the required content passes whatever method produced it.

## Verdicts

| Method | Group | Feature verdict | Rationale | Applies when | Serves (REQ-023–045) | Bugfix verdict | Bugfix rationale / applies when |
|---|---|---|---|---|---|---|---|
| XY problem | Problem framing | adopt | Issues often name a fix rather than the need behind it. Asking for the need, and parking the fix as a candidate solution, keeps the need and stakeholder rows about the problem. | Short and full tier, whenever the issue names a fix | REQ-024 | adopt | Bug reports often ask for a specific fix ("add a retry"). Record the failure behind it; applies whenever a report names a fix. |
| SCQ/Minto (situation, complication, question) | Problem framing | adopt | Situation and complication give the context in two short, separately checkable parts, and the complication usually supplies the "why now". The question is left implicit, because the XY check has already turned it into the need. | Full tier, as the optional template for Context | REQ-023, REQ-026 | deferred to #40 | — |
| Job stories (JTBD) | Need and stakeholders | adopt | "When ⟨situation⟩, ⟨group⟩ wants to ⟨need⟩, so they can ⟨outcome⟩" carries exactly the four things a need row must contain, and names the situation that user stories leave out. | Short and full tier, as the optional template for each `NEED-nn` | REQ-024 | deferred to #40 | — |
| Observed/assumed evidence | Evidence | adopt | Tagging each claim as observed, with a source, or assumed makes it visible which parts of the problem are known and which are guesses. It's cheap and needs no framework. | Short and full tier, on every claim about the problem | REQ-025 | adopt | A bug report mixes what was seen with guesses about why. Tag every claim; applies to every Bugfix problem statement. |
| Symptom vs cause (Genchi Genbutsu, root-cause analysis) | Evidence | adopt | Keeping what was seen apart from why it happened stops a guessed cause being read as fact. The symptom is observed, and the cause stays assumed until it's shown. | Short and full tier, whenever the issue reports a symptom | REQ-025 | adopt | Central to any bug: go and see the failure, record the symptom with reproduction steps, and name the cause only once it's shown. Applies to every Bugfix. |
| 5 Whys | Cause analysis | reject | It traces a failure back to its cause. Feature work rarely has a single failure to trace, and asking "why" of a feature request tends to produce solution talk. It belongs to Bugfix. | — | — | adopt | Once the symptom reproduces, asking why until reaching an actionable cause is a quick, well-known route from symptom to cause. Applies once reproduction steps exist. |
| Impact Mapping | Outcomes | adapt | Only the goal level (the "why" made measurable) and the goal → actor → impact → deliverable chain are used: the goal becomes each `OUT-nn`, and the chain becomes the impact map diagram. The deliverable planning the method also covers belongs to Design. | Full tier for the impact map; short and full tier for measurable outcomes | REQ-027, REQ-039 | deferred to #40 | — |
| Opportunity Solution Tree | Outcomes | adapt | Only its desired-outcome root is used, as another way to phrase an `OUT-nn`, plus an optional diagram. Its continuous-discovery loop and experiment branches are beyond a single session. | Any tier, when a stakeholder has several competing opportunities worth showing | REQ-027, REQ-043 | deferred to #40 | — |
| Shape Up appetite and no-gos | Bounds | adapt | Appetite (a budget, not an estimate) and no-gos bound the work before requirements are written. Shaping, betting and cycles are a delivery process this plugin doesn't impose, so only these two ideas are used. | Full tier | REQ-028 | deferred to #40 | — |
| PR-FAQ (working backwards) | Problem framing | reject | A mock press release and FAQ is a heavy, product-launch format. Its useful parts, the customer's need and the measure of success, are already covered by job stories and success outcomes. | — | — | deferred to #40 | — |

Every method the [Feature type file](../types/feature.md) lists has a Feature adopt or adapt verdict above, and every method the [Bugfix type file](../types/bugfix.md) lists (XY, symptom vs cause, 5 Whys, observed/assumed evidence) has a Bugfix adopt verdict.

## Additions

Methods beyond the candidate list, at most three for this section, each naming the gap it fills.

None. The candidate list covers every element the Feature type file requires.

## Deferred

Further method proposals, each with its follow-up issue.

None.
