---
name: sg-help
description: Explain ShipGlows skills, modes, workflows, and prompts.
---

# sg-help

Answer explanation-only requests directly. For actionable work, resolve the intended public métier and transition in the same conversation; do not make the operator invoke a numbered engine.

Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` when the request becomes actionable, then load `../302-sg-help/SKILL.md` for the full help catalog and exact `mode` / `mode --expert` behavior. Treat `302-sg-help` as expert/legacy only.
