---
name: sg-release
description: Prepare, deploy, and verify releases.
---

# sg-release

## Mission

`sg-release` owns a bounded release outcome: readiness, deployment truth, and the proof required to trust it.

## Scope Gate

Resolve the product, release target, and authority boundary, then load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`. Own readiness and proof, while pausing only for genuinely required deploy authority or external action.

## Required References

Resolve `$SHIPGLOWS_ROOT` through the shared canonical-path doctrine, verify the root and `$SHIPGLOWS_ROOT/skills/004-sg-deploy/SKILL.md` exist, then load that canonical engine for detailed release and verification rules. If the root or file is missing, stop with a visible error; never fall back to a sibling runtime path. Treat `004-sg-deploy` as expert/legacy only.

Hidden expert modes are `ship` and `deploy`; `prod` remains a normal release
mode. The equivalent `shipglows ship`, `shipglows deploy`, and `shipglows prod`
forms only select these `sg-release` modes. This skill keeps authority,
readiness, deployment, and live-proof gates intact.

## Validation

Require the runtime release contract's checks, deployment truth, and applicable live proof before reporting a release as ready or deployed.

## Stop Conditions

Stop for unresolved release scope, missing required proof, failed checks or deployment truth, unrelated dirty scope, or an unapproved destructive or external action.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to concise user-facing outcome and proof; use `report=agent` only for an explicit detailed handoff, without exposing the internal engine in user reports.
