<!-- Write this only when the scope checklist marks visual UI design in scope. It hands visual design to Claude Design and records what comes back. Never write a colour, font or spacing value here. The returned visual design decides them. -->
# UI handoff: {Session Title}

> Main doc: [`index.md`](index.md) · Frontend design: [`frontend.md`](frontend.md) (if it exists)

## Screens and components

<!-- Example (notification preferences):
| Settings page | screen | REQ-001 | loading, saved, error | Lists one toggle per notification kind; saving is explicit, with a Save action |
| Preference toggle | component | REQ-001, REQ-002 | on, off, disabled while saving | Shows the notification kind's name and an on/off state |
-->

| Screen or component | Type | Serves | States | Behaviour constraints |
|---|---|---|---|---|
| {name} | {screen \| component} | REQ-{nnn} | {states, e.g. loading, empty, saved, error} | {content shown, interactions, validation, constraints from the frontend design} |

## Notes for Claude Design

{Anything else the visual design must respect: existing product conventions to follow, accessibility requirements from the REQs, content that must fit. No visual values.}

## Returned visual design

<!-- Filled in when Claude Design returns its HTML zip. Keep the zip as-is; never unzip it into the repo. Screenshots: see skills/design/reference/notations.md, "Screenshots of the Claude Design export". -->

- **Export:** [`ui-design.zip`](../assets/ui-design.zip)
- **Claude Design project:** {link, if there is one}

### {Screen name}

![{Screen name}](../assets/ui-{screen}.png)
