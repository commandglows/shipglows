---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-13"
status: active
source_skill: 108-sg-browser
scope: browser-proof-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/108-sg-browser/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 7 extracted objective-bounded browser proof collection."
  - "OpenAI curated playwright-interactive skill reviewed 2026-08-13 for bounded implementation-signoff QA coverage."
next_step: none
---

# Browser Proof Playbook

1. Record target, environment, development mode, objective, and allowed interaction level.
2. Navigate after runtime preflight.
3. Capture an accessibility snapshot when it proves structure/state.
4. Use a screenshot for visual layout, blank/clipped/overlaid state, snapshot disagreement, or explicit request.
5. Inspect console/network only when relevant or visible proof is incomplete; keep severe error count plus sanitized error family, method/path/status, redirect, timeout, or blocked state.
6. For runtime apps, inspect reversible Settings/Support/Diagnostics/Debug/error-fallback surfaces and safe `Copy diagnostics`/`Copy logs` actions. Confirm redacted commit/build and Paris/UTC build-time headers when available.
7. Decide only the requested objective.

If screenshot and accessibility state disagree, evidence is `partial` or `blocked`. If a diagnostics surface is absent/auth-blocked/unsafe or clipboard extraction fails, name that limit before asking the operator.

## Implementation-Signoff QA

Apply this section only when the objective is implementation signoff, reference fidelity, or a user-visible completion claim. A narrow screenshot, console, network, state, or single-assertion request keeps the focused seven-step path above.

### Shared QA Inventory

Before interaction, build one bounded coverage inventory from:

- the operator's accepted requirements
- the user-visible features and behavior actually implemented
- every user-visible claim intended for the final report

Map each requirement, control, mode, state change, and report claim to a functional check, the exact state and viewport where its visual check matters, and the evidence to collect. Convert subjective but central promises into observable checks. Add at least two safe exploratory or off-happy-path scenarios for an interactive implementation; if the bounded surface genuinely has fewer than two meaningful variants, record the evidence-based exception instead of inventing tests.

Update the inventory when exploration reveals a new visible state or claim. Do not sign off an item that has no matching check or an intentional exclusion with a material reason.

### Persistent Iteration

When the exposed browser runtime supports persistent handles, reuse the same browser, context, page, and viewport-specific surfaces across implementation iterations. Reload renderer-only changes and relaunch only when process ownership, startup, preload, or main-process behavior changed. Do not claim persistent-session execution when the current turn exposes only stateless browser calls.

### Functional Pass

Use normal user inputs such as keyboard, mouse, click, touch, or the equivalent exposed browser APIs. Inspection or state injection may support diagnosis but does not replace signoff input.

- exercise every objective-relevant visible control at least once
- verify one end-to-end critical flow when the surface is interactive
- check the initial state, changed state, and return path for reversible controls
- confirm visible outcomes rather than only internal state
- finish with a short safe exploratory pass and add any discovered state to the inventory

### Visual Pass

Run visual QA separately from the functional pass while using the same inventory.

- inspect the initial viewport before scrolling and confirm the primary promised content is perceptible
- inspect every relevant visible region and at least one meaningful post-interaction state
- inspect an in-transition state when motion or transitions materially affect the experience
- inspect the densest realistic reachable state for interfaces that grow after loading or interaction
- verify every explicitly supported viewport and the minimum supported viewport; otherwise choose a smaller realistic viewport and name it
- inspect clipping, overflow, occlusion, distortion, weak contrast, broken layering, inconsistent spacing or alignment, illegible text, layout imbalance, and awkward motion
- prefer viewport screenshots for signoff; use full-page captures as secondary context and focused captures for local defects

Presence is not proof of perceptibility. A control or promise that exists technically but is obscured, clipped, unstable, or too weak to perceive is a visual failure.

### Signoff Boundary

Functional correctness, viewport fit, and visual quality pass independently; success in one never implies the others. Each user-visible claim requires reviewed evidence from the state and viewport where it matters.

When screenshots and numeric layout checks disagree, investigate the discrepancy. Visible clipping, occlusion, or cutoff remains a failure even when scroll dimensions or other metrics appear acceptable. Before signoff, explicitly inspect the visible area most likely to have been missed and the defect most likely to embarrass the result under close review.

Report the inventory coverage, intentional exclusions, exploratory scope, and a short negative confirmation of the main defect classes checked. Keep sensitive screenshots and internal evidence details within the existing redaction and report-mode boundaries.

## Pressure Scenario

`BROWSER-SIGNOFF-001`: Given a fresh agent must sign off a reference-driven or user-visible implementation, when it verifies the non-auth surface, then one QA inventory connects requirements, controls, state changes, and final claims to separate functional and visual checks; representative and minimum viewports, dense and transitional states, and safe exploratory paths are covered; and visible clipping cannot be overruled by numeric metrics.
