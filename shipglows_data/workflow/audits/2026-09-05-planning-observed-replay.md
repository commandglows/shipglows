---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: planning-observed-replay
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - shipglows_data/workflow/reviews/2026-09-05-planning-observed-capture.json
  - shipglows_data/workflow/reviews/2026-09-05-planning-observed-ambiguity.json
next_step: "Clarify simple-write confirmation versus chantier closure, and project clarification versus blocked-report routing, before further loading changes."
---

# Fresh-context planning replay

## Protocol

User authorized verification after the two compaction passes. Two independent
fresh-context agents used current sg-planning in disposable project fixtures.
No expected read inventory was supplied. Instrumentation separately recorded
responses, ordered actual reads, hash-only checks and failed attempts. Agents
were asked not to repair responses or reads retrospectively. No skill changed
during this run; frozen canonical source hashes still matched afterward.

The capture prompt requested Android validation on the Linux VM after commit
and push. An unrelated existing task had a custom field to preserve. A second
identical request tested deduplication in the same agent context. The ambiguity
prompt offered two equally credible projects without selecting either.

## Results

| Case | Behavioral result | Full skill/reference files | Estimated unique tokens |
| --- | --- | ---: | ---: |
| Supplied task, known project | One todo task, dependency preserved, no clarification | 7 | 12,233 |
| Same request repeated | No write; identical tracker hash | 0 additional | 0 additional |
| Project ambiguous | Asked only which project; neither tracker read or modified | 8 | 10,201 |

Counts describe agent-reported full reads; parent independently checked actual
fixture contents/hashes and source stability. Costs use ceil(characters/4), not
provider telemetry. Partial searches, memory lookup, environment, tracker reads,
hash-only checks, prompts, reasoning, responses and tool wrappers are excluded.
Repeated request still searched/read the tracker; zero additional skill reads
does not mean zero total cost. Neither agent reported truncated output.

Independent parent checks passed: one new task, existing custom field preserved,
identical second-request hash, both ambiguous-project trackers unchanged. No
Android test, build, install, commit, push or dependency execution occurred.

## Reporting gap

The capture agent did not read reporting-closure, documentation-reflection-gate,
or editorial-reflection-gate, although all three are included in the reviewed
complete capture declaration. Its response confirmed "Tache enregistree" without
the complete closure card. When asked after the run, it explained that it treated
recording confirmation as distinct from closure of the future Android task.

This omission was not corrected. The seven-file observed path must not replace
the ten-file, 17,009-token complete declaration or be advertised as a compliant
further reduction. Task capture/deduplication succeeded; complete first-pass
reporting compliance did not.

The ambiguous path read intent-to-outcome-autonomy, reporting-blocked-and-audit
and strategic-choice in addition to the entry/engine/path/question/report rules.
It posed the right question, but 10,201 estimated skill tokens is substantial
overhead for selecting between two supplied projects. Higher-priority concise
question instructions governed its final formatting.

## Limits and next design decision

Synthetic fixtures are not broad user or production coverage. Capture attempted
one missing fixture README read; this did not prevent the bounded task operation.
The ambiguity agent had one instrumentation-write failure, then successfully
wrote its observation via apply_patch; project trackers remained untouched.

The next candidate improvement is semantic clarity, not merely another shorter
file: distinguish a simple saved-record confirmation from technical chantier
closure, and a missing-project question from a full blocked-work report. Decide
which existing protections apply to each before changing triggers or ceilings.
This run authorizes no such semantic change and makes no billing claim.
