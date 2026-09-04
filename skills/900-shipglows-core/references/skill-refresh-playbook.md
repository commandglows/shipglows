---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: active
source_skill: 900-shipglows-core
scope: conservative-skill-refresh
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - skills/REFRESH_LOG.md
  - skills/references/documentation-freshness-gate.md
depends_on: []
supersedes:
  - skills/307-sg-skills-refresh/SKILL.md
evidence:
  - "2026-07-15 operator decision: make conservative refresh a 900 mode, not a second entrypoint."
next_step: "/103-sg-verify consolidate skill maintenance under shipglows core"
---

# Skill Refresh Playbook

Use for `900-shipglows-core refresh <skill>`. Resolve an exact existing `skills/<name>/SKILL.md`; missing, multiple, retired, or path-escaping targets block rather than selecting a recent skill. Ordinary `refresh 900-shipglows-core` is prohibited: use an explicit spec-backed `build` pass with scenario-first proof.

This is a conservative, normally monthly maintenance pass for one target. Never edit its frontmatter `name:` as part of refresh; an approved invocation rename belongs to `900 build` and its full runtime, routing, documentation, and retirement proof.

## Baseline And Evidence

1. Read the target before proposing work. Compare the local baseline: canonical paths, instruction layering, trace/process role, reporting, question/delegation, proof, context budget, docs/help, and runtime visibility when relevant.
2. Load `decision-quality-contract`, `question-contract`, `master-delegation-semantics`, and `skill-context-budget` as needed. Research is delegated only after the delegation contract; parallel work requires non-overlapping read-only scopes or ready batches.
3. Use local shared doctrine first. Apply the Documentation Freshness Gate and official/primary sources only when external framework, provider, security, accessibility, SEO, or platform behavior drives the change. Record `fresh-docs checked`, `not needed`, `gap`, or `conflict`.
4. A finding is actionable only when evidence shows it replaces ambiguity, friction, wasted work, latency, or maintenance cost. Keep decision-only, mixed, or project-specific findings for the report; do not turn novelty or style into edits.

## Replace In Place

1. Re-read a target before applying findings. Preserve every still-valid check, intent, and structure; update strictly obsolete checks in place and never rewrite the contract from scratch or stack duplicate phases.
2. Keep internal contracts English and user-facing material in the active language; fix accents in touched French user text and preserve quoted, legal, source, and machine-readable text.
3. Put material procedure growth in references, not activation bodies. Load `skill-context-budget.md` and apply its Loading Change Gate before changing references, loading triggers, shared normative text, protections, discovery metadata or activation bodies, even when files shrink.
4. When a route, promise, invocation, or public surface changes, align the relevant help, README, workflow/lifecycle docs, site page, and runtime links. `900` remains internal-only even when the refreshed target is public.

## Log, Validate, And Hand Off

1. Prepend one most-recent-first block per target to `skills/REFRESH_LOG.md` exactly as: `## YYYY-MM-DD — <skill-name>`, then `**Added:**`, `**Updated:**`, `**New phases:**`, and `**Sources:** N URLs consulted`. Use `none` where a section has no change; never batch targets.
2. Run focused required-gate/stale-name scans, metadata lint, budget audit, runtime sync when invocation/discovery changes, and site/plugin checks only for changed public surfaces. Check cross-surface coherence before reporting.
3. Report applied changes, deferred decision-only findings, sources, fresh-docs verdict, proof, runtime/reload state, and `Documentation Update Plan` plus `Editorial Update Plan`. Route non-trivial follow-up through the lifecycle; do not close or ship here.
