---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.9.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 009-sg-skill-build
scope: skill-instruction-layering
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/skill-context-budget.md
  - skills/references/chantier-tracking.md
  - skills/references/reporting-contract.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
depends_on:
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
supersedes: []
evidence:
  - "Spec compact-shipglows-skill-instructions.md requested layered compaction for pilot skills."
  - "Repeated top-level doctrine across long skills was identified as instruction dilution risk."
  - "Wave 9 formalized the registry-owned skill graph while keeping reference activation conditional and non-inferred."
  - "Wave 10 added bounded reference-activation profiles for two measured pilots."
  - "Wave 12 established compatibility-preserving decision cores and direct non-chaining doctrine leaves for high-cost shared references."
  - "Wave 13 validates the executable closure of explicitly profiled resources and splits reporting into a compact core with three direct conditional leaves."
  - "Wave 15 applies first-decision cores and direct non-chaining leaves to canonical paths, intent-to-outcome autonomy, and decision quality."
  - "Wave 16 applies compact compatibility cores and direct non-chaining phase leaves to five monolithic domain workflows and adds truthful activation profiles for each owner."
  - "User decision 2026-06-10: keep SKILL.md contracts short and move detailed playbooks, examples, matrices, and edge cases to references."
  - "User decision 2026-07-07: for any skill-creation or skill-improvement work, improve the shared reference layer first and only add local skill wording when the behavior is truly owner-specific."
  - "User decision 2026-07-12: every skill change must preserve compaction and practical followability instead of adding repeated warning prose."
  - "Operator decision 2026-08-03: new cross-skill discovery contracts should prefer stable semantic resource IDs over repeated physical paths once resolver equivalence is proven."
  - "Operator decision 2026-08-12: public wrappers remain implicit while expert engines become explicit-only, and activation cost is tracked separately from discovery."
next_review: "2026-09-03"
next_step: "/103-sg-verify skill instruction layering"
---

# Skill Instruction Layering

## Purpose

Define where ShipGlows skill instructions belong so skill bodies stay compact without losing operational guardrails.

## Top-Level `SKILL.md` Contract

`SKILL.md` is the activation contract: keep it short, directive, and decision-oriented. Put detailed playbooks, examples, checklists, matrices, and edge cases in references.

Each `SKILL.md` must stay independently understandable after required references are loaded.

Required local sections:

1. Role and invocation contract (`707-name`, `description`, args hints).
2. `Canonical Paths` loader.
3. `Trace category` and `Process role` when chantier tracking applies.
4. Report mode contract and pointer to `skills/references/reporting-contract.md`.
5. Mode or route detection.
6. Local stop conditions and validation commands.
7. Explicit list of required references and when each one must be loaded.

The top-level skill body must prioritize first-screen clarity over exhaustive examples or narrative rationale.

## Discovery And Activation Profiles

Public wrappers and expert engines have different discovery roles:

- Public wrappers remain implicitly invocable and load their engine from `$SHIPGLOWS_ROOT/skills/<engine>/SKILL.md`; never depend on an expert sibling in the installed runtime.
- Expert engines remain explicitly invocable but set `policy.allow_implicit_invocation: false` in `agents/openai.yaml`.
- A missing canonical root or engine is a visible stop, not permission to fall back to a stale runtime copy.

Keep activation decisions explicit without inventing a graph from prose. `skill-invocation-registry.json` is the machine-readable public-owner-to-engine graph. Migrated pilots may add an explicit `activation_profiles` entry with body, baseline, and named conditional gates; runtime loaders in `SKILL.md` remain authoritative. Their declared resources seed a blocking dependency closure: `skills/**` edges are transitive, while profiled `shipglows_data/**` artifacts are verified as terminal governance leaves. The separate `--all` audit exposes historical metadata debt without becoming an invocation gate. Distinguish mandatory references needed before the first decision, conditional references selected by mode/gate, and advisory resolver results. Shared resources are counted once. Generalize profiles only after pilot evidence.

Wave 16 profiles `109-sg-auth-debug`, `200-sg-redact`, `201-sg-enrich`,
`400-sg-audit`, and `405-sg-prod`. Their established workflow paths remain
compact compatibility cores; each core routes bounded phase or proof leaves
directly. A local leaf must never load another local leaf.

## What Must Stay Local

Keep these elements in `SKILL.md` even when a reference exists:

- Skill role and scope boundaries.
- Non-negotiable stop conditions specific to this skill.
- Result semantics or verdict semantics that downstream lifecycle skills depend on.
- Routing choices that decide which reference to load.
- Any section labels mechanically checked by downstream workflows.
- The minimum reference-loading map needed to know which detail file applies.

The loading map may use stable semantic resource IDs resolved through the shared resource resolver. Keep the gate condition and mandatory/optional meaning local; avoid embedding a physical path when exact ID resolution and focused failure tests already provide equivalent followability. Existing path loaders migrate one at a time, never through an unproved bulk rewrite.

Never remove `Trace category`, `Process role`, chantier routing visibility, canonical-paths loading, reporting-contract loading, redaction/security gates, or documentation-update gates just to reduce lines.

## What Moves To Shared References

Use `skills/references/*.md` for doctrine reused across multiple skills:

- chantier and lifecycle doctrine
- reporting formats
- canonical path resolution
- documentation freshness rules
- development mode / validation surface rules
- Sentry and observability expectations
- cross-skill language and metadata doctrine

Do not copy large shared doctrine blocks into multiple skill bodies.

Use `skills/references/resource-discovery.md` for progressive search, semantic resource IDs, expansion, and resolver authority boundaries. Do not reproduce resolver commands or ranking rules in each skill.

## Reference-First Skill Rule

For any skill-creation or skill-improvement task, start by checking whether the requested behavior belongs in a shared reference before touching a local `SKILL.md`.

Default order:

1. improve the canonical shared reference when the doctrine could apply to more than one skill
2. update the owner skill only to point to, narrow, or adapt that shared doctrine locally
3. edit a local `SKILL.md` directly only when the rule is genuinely owner-specific, activation-critical, or cannot be expressed safely at the reference layer

Do not use local skill edits or a brand-new skill body as the first response to a general execution-quality critique when the underlying issue is doctrinal.

When code, references, and local skill wording are all plausible targets, repair the highest reusable canonical layer first.

When the trigger is a conversation failure, operator frustration, or execution critique, extract the reusable failure class before editing. Do not stop at "make this skill better for this one case" if the same doctrine gap could mislead other skills.

## What Moves To Skill-Local References

Use `$SHIPGLOWS_ROOT/skills/<skill>/references/*.md` for long, skill-specific detail:

- domain checklists and scoring matrices
- long mode playbooks
- extended examples
- migration checklists
- large report templates
- edge-case catalogs and troubleshooting branches

Local references should be split by purpose. Avoid creating one new mega-reference.

For a large shared authority with direct readers, preserve its canonical detailed path and introduce a compact `*-core.md` only when the core can make the first decision safely. The skill must directly name the detailed escalation condition; a core is not a silent substitute. For domain doctrine with independent concerns, use one primary invariant reference plus direct leaves. Leaves must not chain to siblings.

Reporting follows this pattern with one compact core and three direct leaves: explicit agent handoff, blocked/audit user outcomes, and maintenance pressure scenarios. Explicit `report=agent` takes sole priority over blocked/audit detail because its handoff leaf already owns detailed risks and audit state.

High-fan-out shared baseline doctrine follows the same direct-leaf rule. The
canonical authority path retains the minimum owner, safety, stop, and first-
decision contract. It names each detailed branch and its exact loading gate;
runtime/private roots, project-governance placement, outcome execution,
pressure scenarios, and implementation discipline stay independently
selectable. A leaf must never load a sibling to reconstruct a hidden monolith.

## Compaction Rule

When a local instruction grows past activation, route it by type:

| Keep in `SKILL.md` | Move to references |
| --- | --- |
| Trigger, mission, scope, required loaders, stop conditions, validation commands, report mode, and local non-negotiables | Examples, rationale, mode playbooks, scoring tables, provider matrices, migration steps, troubleshooting trees, and long templates |

If moving detail would make the activation contract ambiguous, keep the stricter local sentence and move only the supporting detail.

## Exception Policy For Long Skills

If a pilot skill still exceeds 500 lines after safe extraction:

1. Keep the stricter local guardrail.
2. Document why compaction would be unsafe.
3. Record the exception in the active chantier/spec report.
4. Optionally substitute a fallback pilot from the approved list when required by the spec.

Safety beats line-count reduction.

## Followability Gate

Every skill modification must pass two questions before completion: does the change prevent the target failure, and can a fresh agent still identify and follow the next required action from the activation body? If the answer is only achieved by adding more prose, move the doctrine to the narrowest shared reference, keep one local directive, and add a mechanical or scenario-first check instead of another warning block.

## Validation After Compaction

Always run:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --catalog all --discovery-mode implicit --format markdown
tools/shipglows_sync_skills.sh --check --all
```

For changed references and docs with frontmatter:

```bash
python3 tools/shipglows_metadata_lint.py <changed-artifacts>
```

Use focused `rg` checks to verify mandatory labels and shared-reference links remain visible in compacted skill bodies.

## Integration Notes

- Do not rename skill directories, `name:` fields, or invocation keys during compaction.
- Resolve ShipGlows-owned references from `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}`.
- Keep reports concise for users, detailed only when explicit handoff or blocked state requires it.
