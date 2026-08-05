---
name: shipglows
description: Route ShipGlows requests to the right métier owner.
---

# ShipGlows

Use this as the canonical public router. Resolve `project -> product -> surface -> feature`, load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`, and select the public métier owner without asking the operator to choose an internal skill.

For detailed routing and authority rules, load `../000-shipglows/SKILL.md`. Retain the operator's outcome through the handoff; the numbered skill is an expert/legacy engine, not a public command to return to the operator.

In Codex, short expert modes such as `shipglows core` are resolved through the
canonical public owner and owner mode before an internal engine is selected;
they are not shell CLI commands. The aliases own no workflow behavior. `core`
is the sole hard context switch and binds the entire remaining instruction to
ShipGlows system work. `shipglows capture` and `shipglows tmux` both resolve to
`sg-content capture`.
