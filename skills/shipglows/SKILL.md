---
name: shipglows
description: Route ShipGlows requests to the right métier owner.
---

# ShipGlows

## Mission

`shipglows` is the canonical public router: it resolves the operator's outcome to one public owner and preserves that ownership through internal handoffs.

## Scope Gate

Use this as the canonical public router. Resolve `project -> product -> surface -> feature`, load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`, and select the public métier owner without asking the operator to choose an internal skill.

## Required References

For detailed routing and authority rules, resolve `$SHIPGLOWS_ROOT` through the shared canonical-path doctrine, verify the root and `$SHIPGLOWS_ROOT/skills/000-shipglows/SKILL.md` exist, then load that canonical engine. If the root or file is missing, stop with a visible error; never fall back to a sibling runtime path. Retain the operator's outcome through the handoff; the numbered skill is an expert/legacy engine, not a public command to return to the operator.

In Codex, short expert modes such as `shipglows core` are resolved through the
canonical public owner and owner mode before an internal engine is selected;
they are not shell CLI commands. The aliases own no workflow behavior. `core`
is the sole hard context switch and binds the entire remaining instruction to
ShipGlows system work. `shipglows capture` and `shipglows tmux` both resolve to
`sg-content capture`.

## Validation

Confirm that one public owner matches the resolved outcome, preserves any named specialist scope, and receives the target hierarchy and authority limits.

## Stop Conditions

Stop only for a material unresolved outcome, authority boundary, or scope conflict; ask the smallest operator-owned decision rather than exposing internal routing choices.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to concise user-facing routing and outcome; use `report=agent` only for an explicit detailed handoff, without exposing internal engines as operator actions.
