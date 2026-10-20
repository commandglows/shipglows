---
name: 104-sg-end
description: "Close tasks with summaries, trackers, and changelog prep."
argument-hint: "[full|partial|summary-only] [optional summary or notes]"
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md`; ShipGlows-owned resources resolve only from that root.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

## Report Modes

Before reporting load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default to outcome-first `report=user`; agent detail requires handoff, blocked proof, or audit intent.

## Mission

`104-sg-end` owns closure summary and tracker/changelog prep, not implementation proof or shipping. Apply `git-milestone-delivery-contract.md`: clean work proceeds to final commit/push; unpushed work remains pending.

## Scope Gate

Use when completion context is clear and closure summary or tracker/changelog preparation is needed.

Do not use this skill for:

- unresolved proof (`103-sg-verify` still needed),
- unresolved ship semantics (`005-sg-ship` still needed),
- unresolved bug diagnosis/fix loops (`003-sg-bug`/`106-sg-fix` still needed).

## Mode Detection

- `full` (default): update closure bookkeeping only when proof and documentation gates support it.
- `partial`: preserve unfinished state, record the remaining gap, and name the next owner.
- `summary-only`: produce the closure summary without mutating trackers, changelog, memory, specs, or archives.

When evidence cannot support `full`, select `partial`; never ask the operator to authorize a false clean closure.

## Required References

- `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md`
  - before any write on ShipGlows-owned workflow surfaces.
- `$SHIPGLOWS_ROOT/skills/references/closure-archive-guard.md`
  - before closing state transitions.
- `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md`
  - before changelog or tracker text implying completion.
- `$SHIPGLOWS_ROOT/skills/references/context-quality-contract.md`
  - for a bounded capsule before documentation classification when structured context is adopted.
- `$SHIPGLOWS_ROOT/skills/references/editorial-reflection-gate.md`
  - before any closure result, independently from documentation impact.
- `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`
  - before creating or changing tracker records.
- `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` and `$SHIPGLOWS_ROOT/skills/references/preview-proof-routing.md`
  - when closure depends on local, preview, hybrid, hosted, or provider proof.
- `$SHIPGLOWS_ROOT/skills/references/project-delivery-policy.md`
  - when closure depends on branch, preview, staging, production, or remote-persistence obligations; development posture never permits local-only clean closure.
- `$SHIPGLOWS_ROOT/skills/references/git-persistence-preflight.md`
  - before closure classification in a Git-backed chantier; healthy state stays silent, while local-only or ambiguous delivery remains pending.
- `$SHIPGLOWS_ROOT/skills/104-sg-end/references/closure-bookkeeping-playbook.md`
  - for closure steps and field-level bookkeeping.
- `$SHIPGLOWS_ROOT/skills/references/context-history-and-head.md`
  - when the project adopts structured history; append one significant closure, proof, invalidation, or next-action event and never record routine command chatter.
- `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`
  - only when a reusable lesson is explicitly accepted.

## Stop Conditions

- Do not claim done/closed without evidence and required guards.
- Do not emit any closure result without the shared visual closure card and its one-line `📖 DOCUMENTATION`, `✏️ ÉDITORIAL`, and `📰 CHANGELOG` classifications.
- Do not mutate tracker/changelog when proof or docs status is materially incomplete unless closure mode is partial.
- Do not mark product work as complete if documentation, editorial, or changelog status is materially `needs review`.
- Do not include internal file paths in user `report=user`.
- Do not claim shipping, release, or implementation truth from closure alone.
- Never commit or push; git shipping belongs to `005-sg-ship`.
- Do not present an otherwise clean completed chantier as terminal before final commit/push succeeds; local-only intent or a blocker remains explicitly delivery pending.
- In `summary-only`, do not mutate any project or ShipGlows-owned artifact.

## Validation

Run closure in this order:

1. select execution mode, then classify the result (`closed`, `partial`, `deferred`, `blocked`, `not applicable`),
2. apply `closure-archive-guard.md`,
3. prepare changelog/tracker state, classify changelog impact, and append at most one significant event when adopted,
4. revalidate the bounded capsule, map task-owned changes, run documentation reflection, then classify editorial impact independently; apply mapped updates and expose all three results,
5. route a clean completed daily chantier directly to bounded shipping, otherwise emit the concrete delivery limit and next owner clearly.

For `summary-only`, run read-only classification and reporting only; skip steps that write bookkeeping.

## Activation Map

- Load `closure-bookkeeping-playbook.md` before changing tracker/changelog artifacts.
- If a material documentation or editorial gap remains, classify result as `partial` and do not force done mode.
- If the run is not tied to a unique spec, apply local `(local)` chantier mode.

### Step 5 — Report

### Final closure summary

- Use the shared ordered card: `✨ RÉSULTAT`, `🧪 PREUVES`, `📖 DOCUMENTATION`, `✏️ ÉDITORIAL`, `📰 CHANGELOG`, `📦 LIVRAISON`.
- Keep proof, documentation, editorial, and changelog evidence each on one line separated by ` · `.
- Add `⚠️ LIMITES` only when material. Always print a useful `🧭 SUITE` selected through `reporting-contract.md`: continue unfinished work first, otherwise choose the strongest evidence-backed next outcome; never emit a null or no-action completion.
- Any intentional mutation, including documentation-only work, with no commit, no push, a local-only commit, or a failed push is `delivery pending`; never pair `Aucun commit ni push` or `modifications locales prêtes` with a completed verdict.

### Rules

- User-mode reports must stay plain language, no internal owner names, no raw paths, no modified file inventory.
- Include only explicit next action and residual risk.
