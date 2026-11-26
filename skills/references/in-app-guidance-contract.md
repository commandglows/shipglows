---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-26"
updated: "2026-11-26"
status: active
source_skill: 300-sg-docs
scope: in-app-guidance
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
depends_on: []
supersedes: []
next_review: "2027-02-26"
next_step: "Apply IG-2 to every ReplayGlows and ContentGlows tour step whose target opens a component."
evidence:
  - "Operator validation on 2026-11-26 of the ReplayGlows Feed guided tour: dimmed and blurred screen, lit card, the feed step going on over the filter sheet it opens."
  - "Operator rejection on 2026-11-26 of a guide that hid itself while the target's sheet was open: the tour must go on and adapt to the opened component."
---

# In-App Guidance Contract

## Purpose And When To Load

Load this contract before designing, implementing, reviewing or proving any
in-app guidance in a ShipGlows product: a first-visit guided tour, a coach mark
on a control, a one-step tip, or the replay of these from settings. It applies
to every app and surface; the operator chose it as the target for all future
onboarding on 2026-11-26.

It does not cover the first-launch introduction screens (carousel, quiz,
permission asks), which are a product decision of their own.

## Rules

### IG-1 The guide owns the screen while a step shows

- The rest of the screen recedes: dimmed (scrim about 72 %) and blurred (blur
  sigma about 4.5), and inert: taps outside the card and the step's target are
  absorbed. The user has no other choice than to read the card.
- The step's target sits in a clear, ringed hole with a halo and stays usable.
- The card is the brightest element on screen: surface lit by the accent from
  the top, accent border and glow, title about 22 px, body about 16 px, a
  prominent primary button, a short zoom-and-fade entrance.
- A step whose target is not on screen shows its card centered over the dimmed
  screen. A card floating over a live, undimmed screen is a defect.
- An app tunes the look through its theme (accent, surface, scrim, blur, width,
  radii), never by reimplementing the overlay.

### IG-2 The step goes on over what its target opens

- When tapping the target opens a sheet, menu, dialog or popover, the tour
  neither hides nor leaves that component under the scrim. The step goes on
  there: the spotlight moves to the opened component, which stays fully
  usable, and the card moves clear of it with texts that explain that
  component (what to pick, which button confirms, how to undo).
- When the component closes, the step is back on its target. Moving to
  another step closes it first: that step gets its own target, spotlight and
  card position, never the previous step's leftover component.
- Every step whose target opens something declares it: the opened component is
  wrapped as a guide target and the step names it with its own title and body.
  An undeclared one only gets the fallback (card at the top, nothing dimmed, the
  component usable) and is a defect to fix in the app.

### IG-3 Guidance can always be replayed

- The settings action that shows tips again resets the guided tours too, and a
  reset tour starts again the next time its screen is shown, without a reload,
  even on a screen kept mounted (a shell tab).
- Settings also offer a direct « replay the tour » entry per tour.

### IG-4 Accessibility and motion

- The card is a live region, its primary button takes focus, Escape pauses the
  tour (closes a tip), every button is at least 44 px.
- Reduced motion turns off the card entrance, the backdrop fade and the scroll
  to the target; the end state is identical.

## Implementation

- Flutter apps use the shared `shipglows_guide` package
  (`shipglows-app-engine/flutter/features/shipglows_guide`, its README holds the
  API: `GuideStep.targetId`, `openedTargetId`, `openedTitle`, `openedBody`,
  `GuideTrigger`, `GuideController.resetAll`, `GuideThemeData`). No app-local
  coach-mark overlay.
- Other surfaces (web sites, browser extensions) follow the same rules with
  their own components until a shared implementation exists.

## Proof

- Package mechanics are proved by its widget tests.
- Each tour is proved in the real app, step by step: the card anchors to its
  target (not centered for lack of a target), the screen is dimmed and blurred,
  every opened component is spotlit and usable with its own texts, and the step
  is back on its target once it closes. Replay from settings restarts the tour.
- A green test suite or a mock render does not replace this in-app proof.
