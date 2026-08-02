---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: active
source_skill: 009-sg-skill-build
scope: agent-clarity-pass-playbook
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/specs/agent-clarity-hardening-phase-4.md
  - shipglows_data/workflow/specs/agent-clarity-hardening-phase-5.md
  - shipglows_data/workflow/specs/agent-clarity-hardening-phase-6.md
  - shipglows_data/workflow/specs/agent-clarity-hardening-phase-7.md
  - shipglows_data/workflow/reviews/skill-system-hardening-register.md
  - shipglows_data/workflow/test-checklists/agent-clarity-pass-checklist.md
depends_on:
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.20.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/workflow/reviews/skill-system-hardening-register.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "2026-06-27 clarity campaign established repeatable heuristics across helper, pilotage, and owner surfaces."
  - "The campaign succeeded by keeping each phase bounded, clarifying one operator question per skill, and adding explicit stay/handoff/non-owner wording."
  - "A final transversal audit found no major role collision after bounded phases, only a duplicate taxonomy bullet that was removed in a micro-fix."
next_review: "2026-12-27"
next_step: "/900-shipglows-core build run the next bounded agent-clarity pass when ambiguity reappears"
---

# Agent Clarity Pass Playbook

## Purpose

This playbook captures how to run a future ShipGlows agent-clarity pass.

The goal is not to rewrite the whole corpus on instinct. The goal is to identify
the skill surfaces with the highest routing ambiguity, clarify their first
screen, validate the shared taxonomy, and preserve the lessons for the next
campaign.

## When To Run A New Clarity Pass

Run a new pass when at least one of these is true:

- fresh agents keep confusing two nearby skills or helper surfaces
- users report repetition, ambiguity, or unclear next-owner routing
- a new family of skills was added and its first-screen boundaries are not yet
  obvious
- a major doctrine shift changed who owns route, context, tracker, proof, or
  reporting decisions
- a future audit shows that boundary wording drifted enough to weaken the first
  30 seconds of execution discipline

Do not open a new clarity pass only because wording could be slightly prettier.
Clarity hardening is for role-boundary risk, not cosmetic copy churn.

## Core Lessons From The 2026-06 Campaign

### 1. Clarify One Operator Question Per Skill

Each touched skill should answer one concrete operator question on the first
screen. If a fresh agent cannot say "this skill exists to answer X", the
surface is still too fuzzy.

### 2. State Stay Here Vs Hand Off

First-screen wording should say:

- when the skill stays the owner
- which nearby skill takes over immediately when the user intent is different

This is more reliable than broad mission prose alone.

### 3. Add A Strong `does not` Boundary

Every ambiguous skill benefits from one explicit sentence stating what it does
not own. This prevents accidental role expansion under pressure.

### 4. Work In Small Batches

Bound the pass to a small cluster of overlapping skills:

- owner/master boundary batch
- helper/continuation batch
- route/context/status batch
- explore/backlog/priorities/review batch
- tasks/continue batch
- residual helper batch

Small batches preserve context and make validation simpler.

### 5. Update The Shared Taxonomy Every Time

When a batch changes how a role is explained, update
`shipglows_data/technical/skill-runtime-and-lifecycle.md` in the same slice.
Otherwise local wording improves but the shared map lags behind.

### 6. Separate Clarity From Other Hardening Work

Do not mix a clarity pass with:

- aggregate corpus compaction
- bootstrap/runtime hardening
- public-site doc campaigns
- broad behavioral redesign

The 2026-06 campaign moved faster because clarity stayed a distinct chantier.

### 7. End With A Transversal Dedup Pass

After the bounded phases, run one short transversal audit to catch:

- duplicate taxonomy bullets
- two skills claiming the same first-screen job
- leftover wording that silently re-blurs a cleared boundary

## Playbook Workflow

### Step 1: Define The Pressure Scenario

Before editing, name the concrete ambiguity:

- which two or more skills are being confused
- what wrong action a fresh agent is likely to take
- why that confusion matters operationally

If there is no pressure scenario, do not open a clarity chantier.

### Step 2: Choose The Smallest Justified Batch

Pick the smallest family of overlapping skills that can solve the ambiguity in
one pass. Prefer four or fewer touched skills per phase unless the cluster is
truly inseparable.

### Step 3: Use The First-Screen Contract

For each touched skill, expose these signals near the mission:

1. one operator question
2. what artifact, decision surface, or state the skill owns
3. `Keep the boundary explicit`
4. a short stay-here list
5. immediate handoff targets
6. one explicit `does not` sentence

### Step 4: Keep Changes Bounded

Edit only:

- the targeted `SKILL.md` files
- the shared taxonomy doc when the family map changed
- the active tracker/spec context for that phase

Avoid unrelated cleanup, compaction, or doctrine expansion.

### Step 5: Validate Mechanically

At minimum run:

```bash
python3 tools/audit_shipglows_skills.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipglows_metadata_lint.py <changed-artifacts>
tools/shipglows_sync_skills.sh --check --skill <each touched skill>
```

Also run focused `rg` checks on the boundary markers you introduced.

### Step 6: Update Shared Learning

After each phase, record:

- what ambiguity was removed
- which wording pattern worked
- whether a shared taxonomy sentence had to change
- whether the batch exposed a new future playbook rule

### Step 7: Run The Final Transversal Audit

Before declaring the campaign sufficiently hardened:

- scan all touched helper/pilotage/helper-adjacent skills for duplicate claims
- scan the shared taxonomy for duplicate or contradictory role bullets
- ship tiny fixes immediately if they are purely coherence-level

## Recommended Wording Pattern

Use this order when the surface is ambiguous enough:

1. mission sentence
2. `This skill answers one operator question: ...`
3. `It owns ...`
4. `Keep the boundary explicit:`
5. `does not ...`

This pattern proved compact enough to survive pressure while remaining specific.

## Failure Patterns To Avoid

- mission prose with no explicit operator question
- boundary language that names only what the skill does, never what it does not
- broad "can help with many things" wording on overlapping helper surfaces
- mixing current execution, backlog, review, and continuation inside one helper
- changing local skill wording without updating the shared taxonomy
- declaring the pass complete without a final duplicate-role sweep

## Outputs Of A Good Pass

A good clarity pass should leave:

- one bounded spec per phase
- targeted skill contract edits only
- a synchronized taxonomy doc
- audit and budget checks still green
- one short end-of-campaign transversal note or micro-fix if needed

## Reuse Rule

For the next pass, start with:

1. this playbook
2. `shipglows_data/workflow/test-checklists/agent-clarity-pass-checklist.md`
3. the latest relevant clarity-pass spec or review

Do not start from chat memory alone.
