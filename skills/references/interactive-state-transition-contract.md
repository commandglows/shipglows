---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-03"
updated: "2026-09-03"
status: active
source_skill: 006-sg-design
scope: interactive-state-transition-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - skills/references/implementation-excellence-preflight.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-09-03: highly interactive interfaces must model states, transitions, temporal behavior, and transition proof before completion."
  - "Waveform pressure scenario showed that static-state design and screen-only tests can miss pause, resume, terminal, and replay invariants."
next_review: "2026-12-03"
next_step: "Apply this contract to the next stateful or temporal interface component."
---

# Interactive State And Transition Contract

## Purpose And Trigger

Apply this contract before designing or materially changing an interactive
surface whose behavior depends on time, progress, a session, asynchronous
work, continuous input, pause/resume, interruption, completion, replay,
loading, recovery, or coordinated animation. Typical examples include media,
recording, upload, live data, gesture-driven controls, Rive state machines,
WebGL or 3D scenes, multi-step interactions, and optimistic operations.

Do not impose this contract on a static component or a conventional control
whose complete behavior is already owned and proven by a maintained native or
shared primitive. Apply it to the smallest stateful boundary that explains the
behavior; do not turn an isolated component into an application-wide model.

## Design Contract Before Visual Completion

Define the behavioral model before treating the visual design as complete.
For every meaningful state, record:

| Field | Required decision |
|---|---|
| State | Stable situation visible or meaningful to the user |
| Entry | Event, condition, or result that enters the state |
| Evolution | Values, visuals, or processes that continue to advance |
| Freeze | Values and visuals that must stop changing |
| Persistence | Position, data, intent, or context retained across the transition |
| Actions | User and system actions allowed in the state |
| Exit | Valid next states and the event that selects each one |
| Feedback | Visual, semantic, haptic, or audio feedback when applicable |
| Proof | Observable invariant or transition scenario that demonstrates correctness |

Include initial, active, paused or interrupted, successful or terminal, error,
recovery, cancellation, and restart states when they are reachable. Mark
irrelevant states explicitly instead of inventing them. Resolve conflicts such
as animation continuing while domain progress is paused; decorative motion,
engine monitoring, domain mutation, and displayed progress are independent
behaviors unless the product contract deliberately couples them.

## Semantic State Model

Name state by product meaning, not by a convenient rendering or engine flag.
Separate concepts whenever they can vary independently, including:

- instantaneous activity from the existence of a session;
- domain progress from displayed or animated progress;
- engine readiness or monitoring from domain data collection;
- current position from retained position;
- completion from active playback or execution;
- user intent from provider or renderer status.

Do not let a flag such as `isPlaying`, `isAnimating`, `isLoading`, or
`isConnected` silently stand for a broader lifecycle. Prefer an explicit state
type when combinations of booleans could create contradictory or unreachable
states. Keep provider-specific details behind adapters when the product state
model has independent meaning.

## Transition And Temporal Proof

Static screenshots and isolated render tests do not prove a stateful
interaction. Test the meaningful transitions and their temporal invariants.
Cover, when applicable:

- start or enter, advance, pause or interrupt, wait, resume, and complete;
- cancellation, failure, retry, recovery, and safe fallback;
- completion followed by restart, replay, reset, or a new session;
- rapid repeated input, reordered or stale callbacks, and disposal or remount;
- background/foreground, route or viewport changes, reduced motion, and input
  alternatives when they can affect the state;
- persistence of frozen values during elapsed time and renewed progress only
  after the authorized transition;
- synchronization between domain state, accessible semantics, controls,
  visual output, animation, and audio or haptic feedback.

Use a controllable clock, deterministic provider substitute, or equivalent
test seam where real time would make proof flaky. Assert user-observable
behavior and domain invariants, not private implementation names alone.

## Rich Runtime Adapters

Rive, WebGL, game engines, 3D libraries, animation runtimes, audio engines, and
other renderers are adapters to the product interaction contract. Their native
state machines may implement the visual behavior, but they do not become the
sole product source of truth when controls, accessibility, persistence,
business rules, or fallback UI also consume the state.

For these adapters, additionally define initialization, asset-loading,
unsupported-device, context-loss, performance-degradation, reduced-motion,
pause/visibility, disposal, and fallback behavior when applicable. Preserve
essential meaning and primary actions when the rich runtime is unavailable;
visual fidelity may degrade, but the product must fail deliberately.

## Pressure Scenario: Recording Waveform

A recording waveform distinguishes active recording, recording paused,
playback session present, playback active, playback paused, playback complete,
and current playback position. Waveform collection advances only during active
recording even if engine monitoring continues. Playback color follows the
position, freezes while paused, reaches completion, and resets deliberately
for replay. Proof waits during both active and paused states so advance and
freeze are demonstrated rather than inferred from static renders.

## Completion Gate

A stateful interaction is not complete while a reachable material state or
transition is undefined, contradictory state combinations remain possible
without justification, or the proof covers only static screens. Report any
runtime-specific behavior that remains unproven and the exact scenario needed
to close it.
