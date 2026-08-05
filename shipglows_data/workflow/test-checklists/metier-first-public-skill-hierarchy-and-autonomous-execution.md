---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-08-04"
updated: "2026-08-05"
status: reviewed
source_skill: 102-sg-start
scope: "metier-first-public-skill-hierarchy-and-autonomous-execution"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/references/skill-invocation-registry.json"
  - "skills/references/intent-to-outcome-autonomy.md"
  - "skills/302-sg-help/references/help-modes-catalog.md"
  - "tools/test_metier_first_public_skills_contract.py"
depends_on:
  - artifact: "shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md"
    artifact_version: "1.1.0"
    required_status: ready
supersedes: []
evidence:
  - "Scenario-first implementation maps every required MH scenario to deterministic contract tests and a manual language review."
next_review: "2026-09-04"
next_step: "/103-sg-verify metier-first-public-skill-hierarchy-and-autonomous-execution"
---

# Métier-First Public Skills — Verification Checklist

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MH-01 | Clarification | Sparse discoverable request | yes | Proceed without a question | PASS | Contract and direct public-skill loaders preserve evidence-first autonomy | tools/test_metier_first_public_skills_contract.py | Language reviewed | |
| MH-02 | Targeting | Multi-product ambiguity | yes | Resolve project -> product -> surface -> feature and ask only the material choice | PASS | Hierarchy is present in canonical routing and public owners | tools/test_metier_first_public_skills_contract.py | Multi-product example reviewed | |
| MH-03 | Clarification | Missing business truth | yes | Ask one numbered decision with a recommendation | PASS | Shared autonomy contract composes the Question Contract | tools/test_metier_first_public_skills_contract.py | Question tone reviewed | |
| MH-04 | Clarification | Missing implementation mechanics | yes | Agent decides mechanics | PASS | Mechanics remain explicitly agent-owned | tools/test_metier_first_public_skills_contract.py | | |
| MH-05 | Lifecycle | Ready continuation | yes | Continue through implementation and proof without operator commands | PASS | Public owner contract retains A-to-Z ownership | tools/test_metier_first_public_skills_contract.py | Simulated flow reviewed | |
| MH-06 | Ownership | Cross-métier request | yes | One public owner and internal collaborators | PASS | Registry mappings are unique | tools/test_metier_first_public_skills_contract.py | | |
| MH-07 | Documentation | Public versus internal docs | yes | Public docs route content and internal docs route docs | PASS | Boundary appears in contract, registry, help, README, plugin, and site | tools/test_metier_first_public_skills_contract.py | Examples reviewed | |
| MH-08 | Engineering | Sync, access, and parity | yes | Route to engineering and engines 600-602 | PASS | Registry and engineering façade map all three lanes | tools/test_metier_first_public_skills_contract.py | | |
| MH-09 | Authority | Material scope expansion | yes | Ask one authority decision and never widen silently | PASS | Shared contract contains explicit stop rule | tools/test_metier_first_public_skills_contract.py | | |
| MH-10 | Discovery | Public and expert help | yes | Public default and complete expert engine view | PASS | Catalog tests and runtime sync pass | tools/test_sg_help_modes_contract.py | Readability reviewed | |
| MH-11 | Coverage | Capability orphan check | yes | Every public owner maps to an existing engine | PASS | Registry validation passes | tools/test_metier_first_public_skills_contract.py | Legacy aliases remain expert-compatible | |
| MH-12 | Ownership | Duplicate public owner check | yes | No duplicate public IDs or runtime façade owners | PASS | Registry uniqueness assertions pass | tools/test_metier_first_public_skills_contract.py | | |
| MH-13 | Runtime metadata | Direct public skill picker | yes | Public `name:` metadata matches each métier name | PASS | 14 public runtime links expose the matching public `name:` | tools/test_metier_first_public_skills_contract.py; tools/shipglows_sync_skills.sh | Current-user Codex and Claude links checked | |
| MH-14 | Advanced proof | Hidden public excellence shortcut | yes | `sg-development excellence` selects internal excellence verification without default catalog exposure | PASS | Invocation fixture selects `103-sg-verify` / `excellence`; default help is unchanged | tools/test_skill_invocation_check.py; tools/test_sg_help_modes_contract.py | Expert engine remains direct-compatible | |
| MH-15 | Expert aliases | Owner-bound shortcut resolution | yes | Every shortcut resolves through one public owner and owner mode before its internal engine | PASS | Registry coverage and mode-ownership assertions pass for all 13 aliases | tools/test_shipglows_core_alias_contract.py; tools/test_skill_invocation_check.py | Alias reference contains no independent workflow | |
| MH-16 | Specialist proof | Contextual `shipglows verify` | yes | Explicit design, SEO, release, or bug scope preserves that specialist owner | PASS | Router and alias reference contain deterministic specialist-preservation rules | tools/test_shipglows_core_alias_contract.py | Generic fallback remains `sg-engineering verify` | |
| MH-17 | Discovery | Public modes versus expert modes | yes | Default help stays métier-only; expert help adds owner-bound shortcuts and numeric engines | PASS | Default catalog unchanged; expert catalog now prints shortcut, public mode, and engine | tools/test_sg_help_modes_contract.py; skills/302-sg-help/references/help-modes-expert-catalog.md | | |
| MH-18 | Core context | Hard ShipGlows-system binding | yes | Later project names or quoted outcomes cannot redirect `core` | PASS | Core pressure scenario remains asserted across router, compatibility entrypoint, and core contract | tools/test_shipglows_core_alias_contract.py | | |

## Run

```bash
python3 -m unittest tools.test_metier_first_public_skills_contract tools.test_sg_help_modes_contract tools.test_skill_invocation_check tools.test_shipglows_core_alias_contract
bash tests/skills/runtime-sync.sh
python3 tools/skill_code_index_lint.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/audit_shipglows_skills.py
```
