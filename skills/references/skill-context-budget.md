---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-04-29"
updated: "2026-08-12"
status: active
source_skill: 300-sg-docs
scope: skill-context-budget
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/*/SKILL.md
  - skills/*/agents/openai.yaml
  - tools/skill_budget_audit.py
  - Codex
depends_on:
  - artifact: GUIDELINES.md
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Codex skills documentation checked on 2026-08-12."
  - "2026-08-12 inventory after wave 11: 65 source skills total 6785 portable characters; 14 implicit public wrappers remain 1376 portable characters."
  - "2026-08-12 runtime inventory after wave 11: all 65 installed skills total 8345 lexical characters, below the 8500 ceiling with 155 characters of margin."
  - "Operator decision 2026-08-12: separate discovery and activation budgets, retain expert explicit invocation, and compact through conditional references."
  - "Wave 9 distinguishes the registry ownership graph from deferred reference-activation accounting."
  - "Wave 10 pilots explicit baseline/gate activation accounting on 004 and 601 without parsing prose."
  - "Wave 11 compacted explicit-only expert descriptions while preserving trigger nouns and public descriptions."
next_review: "2026-09-12"
next_step: "/103-sg-verify progressive-skill-discovery-and-activation-budgets"
---

# Skill Context Budget

## Purpose

Keep skill discovery reliable without confusing three different costs:

- `D-portable`: repository-relative path + name + description for the selected catalogue;
- `D-runtime`: lexical installed path + name + description for a runtime root explicitly supplied;
- `A-activation`: selected `SKILL.md` body plus unique mandatory references and the bounded advisory pack.

Compacting a body or moving detail into `references/` reduces activation cost, not discovery cost.

## Current Codex Constraint

Codex initially exposes each skill's name, description, and path, then reads the full `SKILL.md` only after selection. The initial list is capped at roughly 2% of context or 8,000 characters when context size is unknown; descriptions may be shortened and skills omitted when the set is too large. Source checked 2026-08-12: https://learn.chatgpt.com/docs/build-skills

ShipGlows keeps the historical 8,500-character aggregate guard as a small compatibility margin around that fallback. Changing the threshold requires an explicit migration, never a silent workaround.

## Catalogue Policy

- The 14 public métier wrappers use `agents/openai.yaml` with `policy.allow_implicit_invocation: true`.
- The 51 expert engines use `false`: they stay installed and explicitly invocable, while public wrappers route to their canonical source paths.
- Installation inventory and implicit discovery are separate. `internal_catalog.include_all_runtime_skills` may remain true.
- Missing policy is treated as runtime-default implicit behavior and should be reported for repository-owned skills.

The invocation registry defines public, expert, and all catalogue membership. Do not create a second catalogue in code or docs.

## Discovery Measurements

The audit must report three labelled views:

1. `Source diagnostics`: validate every skill body and frontmatter.
2. `Portable source estimate`: gate the requested catalogue independently of clone depth.
3. `Runtime discovery estimate`: when `--runtime-skills-root` is supplied, count lexical installed paths and gate that runtime.

Never call `Path.resolve()` to price a runtime path: a junction would be rewritten to the source checkout and the result would no longer describe what Codex sees.

2026-08-12 baseline:

| Catalogue | Skills | Portable | Runtime lexical |
| --- | ---: | ---: | ---: |
| Public implicit | 14 | 1,376 | 1,712 |
| Expert explicit-only | 51 | 5,722 | 6,946 |
| Installed total | 65 | 7,098 | 8,658 |

Only the public implicit row is paid at startup after policy application. The total installed row remains useful capacity evidence, not an implicit-discovery verdict.

## Metadata And Body Targets

- `description`: one concise sentence, target 80–120 characters, warning above 140, hard ShipGlows maximum 200.
- Put syntax in `argument-hint`, never `Args:` in a description.
- Keep names lowercase, hyphenated, stable, under 64 characters, and equal to their directory.
- `SKILL.md`: target under 500 lines and about 5,000 estimated body tokens.
- Wrapper target: below 500 tokens; atomic owner 800–1,800; master 1,200–2,200 when safe.
- Activation core (`body + mandatory references`) should target below 5,000 unique estimated tokens.
- A reference above 5,000 estimated tokens is a review signal: split only when multiple real loading decisions exist.

Size is never authority to remove a stop condition, security gate, proof requirement, trace role, or reporting contract.

## Activation Accounting

For a selected skill, report:

- `B`: body estimate;
- `M`: unique references mandatory before the first decision;
- `C-mode`: unique conditional references for the selected mode;
- `P-advisory`: bounded resolver starter pack, separately labelled.

Do not infer reference dependencies from prose. The registry-owned activation graph validates public-owner-to-engine routing. Its optional `activation_profiles` section declares measured baseline and gate-specific reference sets only for migrated pilots. Count a shared file once and report body, baseline, each independently selected gate, and worst case with `tools/skill_activation_budget.py`. Skills without a profile continue to use mechanically declared loader measurements.

## Audit Commands

```bash
python3 tools/skill_budget_audit.py --skills-root skills --catalog all --discovery-mode implicit
python3 tools/skill_budget_audit.py --skills-root skills --catalog public --discovery-mode installed --format markdown
python3 tools/skill_budget_audit.py --skills-root skills --catalog all --discovery-mode implicit \
  --runtime-skills-root "$HOME/.agents/skills"
```

The source absolute checkout estimate may be printed for diagnosis, but it must not override a passing portable verdict. A runtime estimate is blocking only when its root was explicitly requested.

## Remediation Order

1. Correct an unintended implicit policy or catalogue membership.
2. Shorten a description only when its trigger remains precise.
3. Decouple public loaders from runtime sibling layout.
4. Compact activation bodies through conditional, purpose-specific references.
5. Split large mandatory references by real mode or gate.
6. Remove or merge a skill only through an approved taxonomy change.
