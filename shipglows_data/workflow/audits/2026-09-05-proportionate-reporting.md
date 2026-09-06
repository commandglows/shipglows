---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: proportionate-reporting
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - shipglows_data/workflow/reviews/2026-09-05-proportionate-capture.json
  - shipglows_data/workflow/reviews/2026-09-05-proportionate-question.json
  - tools/fixtures/proportionate_reporting_baseline.json
next_step: "Local changes ready for scoped Git delivery when requested."
---

# Proportionate reporting

The user approved distinguishing recording confirmation, a simple question and chantier closure. This intentionally clarifies reporting requirements; it does not retroactively make omissions in the earlier replay compliant.

A verified internal save or duplicate receives a concise confirmation. A missing factual project input receives one question before tracker access. Neither triggers closure/reflection, clock, status-card or next-outcome searches. Technical execution, failure/uncertainty, evidence-dependent status, security/authority choices, explicit full reports and real closure take precedence and retain applicable gates. Attached-spec tracing remains required.

## Context cost

Estimates use ceil(UTF-8-decoded characters/4), including frontmatter. They exclude project evidence, environment, prompt/history and provider billing.

| Declared route | Before | After |
| --- | ---: | ---: |
| Supplied-task capture | 10 files / 17,009 tokens | 7 files / 12,388 tokens |
| Missing-project question | 8 files / 10,201 tokens | 5 files / 6,914 tokens |

Initial complete capture baseline remains 14 files / 28,718 estimated tokens. Existing unrelated scenario ceilings were not raised; the capture ceiling tightened to 14,000. The shared selector was shortened to keep the other routes within their existing budgets.

## Verification and limits

119 focused Python checks passed, including required-read omission, real closure gates and prior authority/reporting regressions. All 16 declared scenarios meet their budgets. Metadata validation passed for changed shared reporting and tasks references. Independent review found no blocking semantic regression.

Two fresh agents produced the expected concise responses. Capture preserved the unrelated custom field, kept Android todo with its commit/push prerequisite, and made no duplicate; the parent verified the final tracker hash. The question accessed no tracker. Neither ran Android or Git. Durable observations above retain exact responses and limitations.

Observed file inventories match seven and five unique references. Capture had truncated combined output and a partial reread; canonical-paths was read after engine resolution in both runs. Minor core wording compaction continued during replay. Therefore declared final-source totals are not exact observed traffic or billed tokens, and full canonical read-order compliance is not claimed. The prior broader suite's four out-of-scope failures were not repaired or reclassified here.

Changes remain local; no commit or push performed.
