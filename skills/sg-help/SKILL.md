---
name: sg-help
description: Explain ShipGlows skills, modes, workflows, and prompts.
---

# sg-help

## Mission

`sg-help` is the public owner for explaining ShipGlows skills, modes, workflows, and prompts.

## Scope Gate

Answer explanation-only requests directly. For actionable work, resolve the intended public métier and transition in the same conversation; do not make the operator invoke a numbered engine.

## Required References

Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` when the request becomes actionable. Then verify the canonical root and `$SHIPGLOWS_ROOT/skills/302-sg-help/SKILL.md` exist before loading that engine for the full help catalog and exact `mode` / `mode --expert` behavior. If the root or file is missing, stop with a visible error; never fall back to a sibling runtime path. Treat `302-sg-help` as an expert/legacy engine only.

## Validation

Verify that the explanation names the appropriate public owner and that any actionable handoff preserves the operator's stated goal.

## Stop Conditions

Stop when the requested action needs a material decision, authority, or context that cannot be established from the conversation and durable evidence.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Keep explanations concise and public-facing; do not expose numbered engines unless the operator explicitly requests expert behavior.
