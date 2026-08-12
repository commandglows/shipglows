---
name: 203-sg-research
description: "Research web and local sources into cited Markdown reports."
disable-model-invocation: true
argument-hint: <topic>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

If a unique active spec exists, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` and update the spec only when the work belongs to it.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

## Mission

`203-sg-research` turns a topic into a cited, source-backed Markdown report.

It owns source selection, claim wording, uncertainty framing, and durable saving path.

## Scope Gate

Use this skill when:

- the operator asks for a decision-quality research question,
- the topic needs cross-source comparison,
- implementation details are not yet fixed and must be informed by current evidence.

Use `/205-sg-veille` or other owners if this becomes recurring market monitoring rather than bounded research.

## Required References

- `$SHIPGLOWS_ROOT/skills/references/question-contract.md`
  - when the topic or source scope is missing.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`
  - when technical, legal, security, platform, or API behavior claims are requested.
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md`
  - before turning research into public content/recommendation wording.
- `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md`
  - before reading any ShipGlows-owned workflow or tooling surfaces.
- `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md`
  - when public-facing behavior claims are part of the report.
- `$SHIPGLOWS_ROOT/skills/203-sg-research/references/research-execution-playbook.md`
  - for research workflow, source triage, and synthesis sequence.
- `$SHIPGLOWS_ROOT/skills/203-sg-research/references/research-report-template.md`
  - before saving a durable research artifact.

## Stop Conditions

- Do not claim verified truth from uncited assertions.
- Do not use stale sources as primary facts without freshness warning.
- Do not publish implementation guidance from incomplete evidence.
- Do not write a public artifact from this skill if source claims are uncertain.
- If topic is missing, ask one focused topic question and stop.

## Validation

- Always produce a source list with dates or version context for technical claims.
- Save a durable report when requested or when research materially changes a decision path.
- Use explicit uncertainty language for conflicts, unknowns, and unresolved consensus.
- Never route to implementation directly without scope-aware handoff (`001`/`104` or owner skill as appropriate).

## Activation Map

- If no topic is provided, load `question-contract.md` first and ask for one focused topic.
- If the run is tied to a spec and produces durable future work, record optional chantier potential before report.
- If freshness applies, load and follow freshness guidance before final synthesis.
- If output includes public-facing claims, ensure editorial gates and content handoff are explicit.
