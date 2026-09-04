---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: reviewed
source_skill: 900-shipglows-core
scope: progressive-loading-pilot-baseline
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
depends_on: []
supersedes: []
evidence:
  - "Approved progressive loading pilot preserves the existing behavior in directly selected references."
next_review: "2026-10-05"
next_step: none
---

# Progressive loading pilot baseline

Historical evidence only; not runtime instructions. Source commit:
65d3fc1791370ab7a2668014ce7b2338bde11d75. Existing paths in that commit
preserve the complete pre-pilot contracts. The audit used ceil(characters/4),
full files, canonical-path deduplication, excluding tool output and task evidence.

| Conservative audit path | Unique files | Tokens |
| --- | ---: | ---: |
| Core natural-language skill audit, including user audit report | 13 | 27963 |
| Explicit Core help, including user report | 10 | 17994 |
| Explicit engineering deps, including user audit report | 13 | 22746 |

These are lower bounds, not complete runtime traces. Mandatory conditions absent
from the first audit ledger are restored in the scenario baseline; additions are
itemized there. No baseline was measured by running a fresh model.

## Complete comparable scenario baselines

The registry stores exact source commit, SHA256 and per-file cost for each baseline.
The independent review recomputed every entry against that commit.

| Scenario | Original lower bound | Restored mandatory conditions | Complete baseline |
| --- | ---: | --- | ---: |
| Core skill audit with unfinished improvement decision | 27963 | execution 882 + excellence 2101 + fidelity 4513 + strategic choice 1605 | 37064 |
| Explicit Core help without established next outcome | 17994 | none; next-outcome fallback included before and after | 17994 |
| Engineering dependency audit with material findings | 22746 | excellence 2101 + freshness 1028 + strategic choice 1605 | 27480 |

These are declared contract scenarios, not observed model traces. Other scopes,
closure claims, uncertain routes, runtime dependencies or selected evidence may
load more. The first-read graph measures depth beneath the selected engine only.
No general all-skills budget compliance or live provider savings is claimed.

## Reporting historical evidence

  - "Operator decisions 2026-05-03 through 2026-08-07 define concise human reports, explicit agent handoffs, chantier-first headers, safe choices, bounded recurrence claims, and compact topology receipts."
  - "Wave 13 retained the default user decision surface here and moved conditional handoff, blocked/audit, and maintenance scenarios to direct leaves."
  - "Operator decision 2026-08-13: unfinished report choices steer business direction and short interaction controls trigger guided follow-up."
  - "Operator clarification 2026-08-15: every closure report must expose its documentation reflection instead of leaving documentation updates silent."
  - "Operator decision 2026-08-15: closure reports use a stable visual card whose proof and documentation evidence each stay on one compact line separated by middle dots."
  - "Operator decision 2026-08-15: approved substantive chantiers use a matching start card with objective, scope, expected proof, and planned documentation impact."
  - "Operator decision 2026-08-15: user reports omit file paths, file names, and technical file links unless the operator must act on the exact artifact or explicitly requests detail."
  - "Operator decision 2026-08-18: report cards summarize already-required work and must never create extra checks, research, documentation, or content merely to fill a block."
  - "Operator decision 2026-08-21: substantive code chantiers expose one compact implementation-guardrail receipt after pre-write classification."
  - "Operator decision 2026-08-16: every closure exposes a separate editorial reflection without creating ceremonial public content."
  - "Operator correction 2026-08-21: SUITE is mandatory business continuity and may never resolve to no action; it selects from unfinished conversation work, pending proof or delivery, active chantiers, tracker priority, overdue audits, then grounded improvement."
  - "Operator decision 2026-08-21: persistence reporting distinguishes local, remote backup, and deployment without adding a block when healthy delivery evidence is already clear."
  - "Operator decision 2026-08-16: completed chantiers may offer guided Approfondir and Réorienter follow-up without reopening delivery or authorizing mutation."
  - "Operator approval 2026-08-21: restart recommendations follow context quality rather than length, stabilize durable state first, and remain operator-started."
  - "Operator correction 2026-08-21: an independent outcome alone never triggers restart; user-facing language calls the restart prompt a handoff."
  - "Operator approval 2026-08-22: context health checks are lightweight at transitions and targeted only after a material degradation signal."
  - "Operator approval 2026-08-30: every managed-repository closure visibly classifies changelog impact without equating publication readiness with publication proof."
  - "Operator correction 2026-09-01: closure reports render documentation evidence resolved from current changed paths and the canonical docs map, independently from editorial impact."
  - "Operator correction 2026-09-01: editorial alignment and editorial/product opportunity are independent; `not impacted` never means no opportunity."

## Budget history before pilot

---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.13.0"
project: ShipGlows
created: "2026-04-29"
updated: "2026-08-13"
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
depends_on: []
supersedes: []
evidence:
  - "Wave 20 closes the integrated full diagnostic graph at 691 artifacts, 895 dependencies, zero cycles, and zero findings while preserving the profiled graph at 133/89/0."
  - "Wave 19 preserves the valid profiled graph at 133 artifacts, 89 dependencies, and zero cycles while reducing the non-blocking full diagnostic from 89 to 29 classified missing-target findings."
  - "Wave 18 preserves the valid profiled graph at 133 artifacts, 89 dependencies, and zero cycles while reducing the non-blocking full diagnostic from 272 to 89 findings."
  - "Wave 17 reduces the remaining 010 and 103 hotspots to 4562 and 4907 tokens through conditional technical routing and direct verification proof leaves."
  - "Wave 16 replaces five monolithic workflow references with compact compatibility cores, direct non-chaining leaves, and five measured activation profiles."
  - "2026-08-12 Wave 16 measurement: workflow cores move from 7196/6607/6524/6189/5870 to 827/808/672/727/799 tokens; selected baselines are 2222/2097/2961/2821/3544."
  - "Wave 15 compacts canonical paths, intent-to-outcome autonomy, and decision quality into first-decision cores with direct non-chaining leaves."
  - "2026-08-12 Wave 15 measurement: selected baselines are 3128 for 004, 6177 for 010, 5657 for 103, 3451 for 300, 2081 for 601, and 2487 for 900 before conditional gates."
  - "Wave 14 expands explicit activation accounting from three to six profiles: 004, 010, 103, 300, 601, and 900."
  - "2026-08-12 Wave 14 measurement: selected baselines are 11,361 tokens for 010-sg-technical, 9,517 for 103-sg-verify, and 6,791 for 300-sg-docs."
  - "Wave 14 records shared canonical-path, intent-to-outcome, and decision-quality baseline weight as the next remediation target without compacting it in this wave."
  - "Wave 13 removed a retired root GUIDELINES dependency from the executable reference graph."
  - "Wave 13 profiles 900-shipglows-core and keeps the ordinary reporting path on a compact core, with agent, blocked/audit, and maintenance detail loaded conditionally."
  - "2026-08-12 Wave 13 measurement: 900-shipglows-core body 1592, baseline 4506, report-user +1631, report-agent +405, report-blocked-audit +678, and report-review +618 estimated tokens."
  - "Codex skills documentation checked on 2026-08-12."
  - "2026-08-12 inventory after wave 11: 65 source skills total 6785 portable characters; 14 implicit public wrappers remain 1376 portable characters."
  - "2026-08-12 runtime inventory after wave 11: all 65 installed skills total 8345 lexical characters, below the 8500 ceiling with 155 characters of margin."
  - "Operator decision 2026-08-12: separate discovery and activation budgets, retain expert explicit invocation, and compact through conditional references."
  - "Wave 9 distinguishes the registry ownership graph from deferred reference-activation accounting."
  - "Wave 10 pilots explicit baseline/gate activation accounting on 004 and 601 without parsing prose."
  - "Wave 11 compacted explicit-only expert descriptions while preserving trigger nouns and public descriptions."
  - "Wave 12 reduced the 004 multi-stage gate from about 8.5k to 1.29k tokens and split the 601 entitlement contract into a 1.37k primary doctrine plus direct 0.5-0.7k branches."
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

Do not infer reference dependencies from prose. The registry-owned ownership graph validates public-owner-to-engine routing. Its optional `activation_profiles` section declares measured baseline and gate-specific reference sets only for migrated pilots. Those explicit paths also seed the executable resource-dependency preflight; they do not make every conditional gate eager. Count a shared file once and report body, baseline, each independently selected gate, and worst case with `tools/skill_activation_budget.py`. Skills without a profile continue to use mechanically declared loader measurements.

When a high-fan-out authority is too large for an ordinary decision, keep its detailed compatibility contract and add a compact decision core. The activation body must name both: load the core for the normal gate and escalate to the detailed authority only for conditions the core states explicitly. For multi-branch doctrine, keep non-negotiable invariants in one primary reference and expose direct, non-chaining leaves by real mode or risk gate. Wave 13 applies this to reporting: successful user mode needs only the compact core; agent handoff, blocked/audit, and maintenance scenarios load direct conditional leaves, with explicit `report=agent` as the sole detailed-report authority.

Wave 13 measured the `900-shipglows-core` profile at 1,592 body tokens and 4,506 selected baseline tokens. Reporting then adds 1,631 for the core user contract, 405 for agent handoff, 678 for blocked/audit, or 618 for maintenance scenarios. These are independently selected gates, not one eager reporting bundle.

Wave 14 expands the measured pilot from three to six profiles by adding
`010-sg-technical`, `103-sg-verify`, and `300-sg-docs`. Their selected
baselines are respectively 11,361, 9,517, and 6,791 estimated tokens. These
hotspots are evidence for the next tranche, not a reason to delete mandatory
loaders or to describe the profiles as budget-compliant. The likely shared
baseline candidates are canonical-path resolution, intent-to-outcome autonomy,
and decision-quality doctrine; Wave 14 performs no compaction of them.

Wave 15 compacts those three high-fan-out authorities in place. Their canonical
paths now hold the minimum safe first decision; detailed runtime/private-root,
project-governance, outcome-execution, pressure-scenario, and implementation-
discipline procedure lives in direct conditional leaves. No leaf loads a
sibling. The resulting selected baselines, before conditional gates, are 3,128
for `004`, 6,177 for `010`, 5,657 for `103`, 3,451 for `300`, 2,081 for `601`,
and 2,487 for `900`. Only `004` and `300` newly cross below the 5,000 target;
`010` and `103` remain explicit hotspots.

Wave 16 applies the same progressive boundary to five expensive domain
workflows while preserving their canonical compatibility paths. The redact,
enrich, audit, production-verification, and auth-debug cores move from 7,196,
6,607, 6,524, 6,189, and 5,870 tokens to 827, 808, 672, 727, and 799. Their new
selected activation-profile baselines are 2,222, 2,097, 2,961, 2,821, and
3,544 respectively. Each gate selects a direct leaf; local leaves never load
siblings and registry profiles remain accounting metadata rather than runtime
loading authority.

Wave 17 brings the two remaining profiled hotspots below target. `010` selects
its semantic mode before loading `technical-router.md`, reducing its baseline
from 6,177 to 4,562 tokens. `103` removes the duplicated ShipGlows-owned
preflight from its baseline and routes release-proof and CI procedure through
two direct non-chaining leaves, reducing its baseline from 5,657 to 4,907.
Owner, verdict, security, product, proof, stop, and reporting decisions remain
activation-local.

Wave 18 preserves the boundary between activation accounting and corpus
diagnostics. The profiled execution graph remains valid at 133 artifacts, 89
dependencies, and zero cycles. The full `--all` diagnostic improves from 687
artifacts, 998 dependencies, 3 cycles, and 272 findings to 688 artifacts, 923
dependencies, zero cycles, and 89 findings after 79 constraint repairs, 13
active canonical-path migrations, and 73 historical-edge reclassifications.
The residual 73 missing targets, 6 status mismatches, 6 unversioned targets, 3
invalid required-version constraints, and 1 invalid actual status remain non-blocking debt and must not be pulled into activation merely
to make the diagnostic green.

Wave 19 reduces the full diagnostic again, from 688 artifacts, 923
dependencies, zero cycles, and 89 findings to 689 artifacts, 912 dependencies,
zero cycles, and 29 findings. It migrates 44 proven canonical missing paths,
resolves all 10 original status/version constraint findings, and reclassifies
6 README, template, or executable-skill relationships outside `depends_on`
without fabricating artifact metadata. All residual findings are missing targets
classified as external, genuinely absent, old unversioned skill paths without a
proven replacement, or inverse relationships that would create cycles. Two
candidate migrations were reverted after cycle proof. The profiled execution
graph remains valid at 133 artifacts, 89 dependencies, and zero cycles.

Wave 20 closes the remaining diagnostic debt. The complete `--all` graph is
valid at 691 artifacts, 895 dependencies, zero cycles, and zero findings; the
profiled execution graph remains valid at 133 artifacts, 89 dependencies, and
zero cycles. This does not increase activation cost: executable skills,
runtime shims, external APIs, historical evidence, and other-project doctrine
were reclassified outside `depends_on` instead of being loaded or assigned
artificial artifact metadata.

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
