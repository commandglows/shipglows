---
artifact: migration_evidence
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 102-sg-start
scope: repurpose-mode-consolidation-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-router.md
  - skills/007-sg-content/references/repurpose-playbook.md
  - tools/test_007_sg_content_repurpose_contract.py
depends_on:
  - artifact: "shipglows_data/workflow/specs/consolidate-repurpose-mode-under-sg-content.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Tasks 1-6 of the consolidation spec."
next_step: "/103-sg-verify consolidate repurpose mode under sg-content"
---

# Repurpose Consolidation Evidence

## Rule Transfer Matrix

| Retired-source rule family | Authoritative destination | Mechanical proof |
| --- | --- | --- |
| Exact `repurpose <source>` grammar, bare-source limit, no second dispatch | `content-router.md` and `repurpose-playbook.md` | contract test grammar assertions |
| Verbatim / `mot pour mot` / `copie exacte`, exact ordering, count limit, no analysis | `repurpose-playbook.md` | verbatim scenario assertions |
| Source classification, project ownership, private-cache boundary | `source-intake-classification.md` | shared-reference and safety assertions |
| Canonical pack order, evidence separation, compression | `source-faithful-pack-contract.md` | shared-reference assertion |
| Existing-content two-lane scan, learning moment, read-only fan-out | `repurpose-playbook.md` | playbook assertions |
| Output selection, transformation, public-map and claim gates | `repurpose-playbook.md` plus `editorial-content-corpus.md` | playbook and boundary assertions |
| Diffusion map and cross-surface repetition | `repurpose-playbook.md` | playbook assertion |
| Quality score/status | `content-quality-rubric.md` | shared-reference assertion |
| Declared-public default | `public-first-content-default.md` | shared-reference assertion |
| Durable pack path, safe persistence, verbatim naming | `repurpose-pack-storage.md` plus `repurpose-playbook.md` | storage and verbatim assertions |
| Source safety, no logs/fixtures/fallback persistence | `repurpose-playbook.md` and shared intake/storage contracts | safety scenario assertions |
| Exact downstream handoffs and payload | `content-owner-handoffs.md` and `repurpose-playbook.md` | owner-boundary assertions |
| Read-only repurpose boundary | `repurpose-playbook.md` | owner-boundary assertions |

## Active-Reference Policy

Actionable current instructions must use `007-sg-content repurpose <source>` (or its public `sg-content repurpose <source>` rendering). The test scans active skills, shared references, runtime/catalog, public site, root/current docs, templates, and current workflow playbooks/checklists.

The intentionally narrow factual-history allowlist is: completed or predecessor specs, audits/reviews, refresh log, archive trees, durable repurpose packs, research evidence, and the current consolidation spec. `shipglows_data/workflow/TASKS.md` is also excluded only because the operator explicitly preserved this unrelated tracker during implementation; it is not a general workflow exclusion.

No source text, secrets, private material, URLs, customer content, or transcript excerpts are stored in this matrix or its test fixtures.
