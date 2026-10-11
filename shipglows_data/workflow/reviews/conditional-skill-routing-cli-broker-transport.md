---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-10-08"
updated: "2026-10-10"
status: draft
source_skill: sg-engineering
scope: conditional-skill-routing-simulated-broker-and-parent-transport
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_cli_broker_profile.py
  - tools/conditional_skill_routing_parent_transport.py
  - tools/conditional_skill_routing_broker_proof_review.py
  - shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md
depends_on: []
supersedes: []
evidence:
  - "Official temporary Linux CLI 0.160.1, exact original and offered request capture, actual dynamic callbacks under WSL/bwrap."
  - "Independent raw replay of 107 broker proof artifacts and original dynamic schemas."
  - "Windows parent with WSL/bwrap relay: synthetic secret/evaluator sentinels remain outside the namespace."
  - "Eight parent-owned H/A/B/S fixture flows: 199 mock requests, 184 exact callbacks, 232 rehashed artifacts, no real model call."
  - "Hash-bound semantic evaluator receipt gate added to the live-only launcher; focused offline regressions pass."
next_step: "Complete distinct source/runtime review and bind exact readiness receipts; no real provider or campaign launch."
---

# CLI broker and parent transport: simulated evidence

Preparation only. No real provider, account authentication, model observation or new campaign was launched. AC5 and all thresholds remain unchanged; migration remains NO-GO.

## Offered and callable tool boundary

Proof directory: `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-broker-profile-v1-20261007-attempt2/`.

Summary SHA256: `7b83dee20d242f7bd45b9fd602fc5e046383114a4f9b043461a870dd44039231`. Executed frozen source: `7c25cf087b5a1d4e800889bb1ccd16fad8e65da2b16f3085dd6c4a4e72e07dd7`. Independent review receipt: `independent-broker-review-v2.json`, SHA256 `a0d01c9a1a1012f6eb4551d28d4c706b862ceb2138a80e3a8e76f96500704c7f`; replay source preserved alongside it.

- One actual app-server thread, two user turns; first completed, second failed through the transport gate.
- Three actual registered callbacks: `instruction_read`, `fixture_read`, `simulated_replace`. Each exact callback appears in the next and all later model requests. Replacement affects only synthetic memory state.
- Five original CLI requests captured separately from the five model-offered requests. The latter reach the mock byte-identically. Only the `tools` value changes; other JSON values, including input and instructions, remain identical. JSON serialization is normalized, so these two request bodies are not claimed byte-identical.
- Offered schemas are exactly the three original registered dynamic schemas. Four complete bounded SSE streams are validated before emission, then reach the CLI byte-identically.
- The fifth stream tries native `exec_command`. The gate returns HTTP502 with zero provider SSE bytes emitted. Raw RPC contains no command execution item or side effect.
- Independent replay rehashes all 107 inventory artifacts, reconstructs raw RPC and checks exact callback delivery, schemas, stream admission and temporary binary cleanup.

Native CLI features remain enabled inside bwrap. This profile proves a trusted provider boundary, not native feature disablement. The original strict disabled-native profile remains unsatisfied. This three-tool fixture does not establish complete H/A/B/S case inventories or their approval/private semantics.

Attempt1 remains preserved as a failure: a local `http` variable shadowed the imported HTTP module before the mock request. No callback or provider stream escaped the gate. Attempt2 corrects that implementation error without replacing the failed evidence. Eleven offline adversarial tests cover schema drift, identities, namespaces, native call shapes, replay, malformed/truncated streams and contradictory lifecycle events; they do not prove compatibility with every future provider response shape.

## Trusted parent outside the subject namespace

Proof directory: `tools/fixtures/conditional_skill_routing/capture-demonstrations/parent-relay-wsl-bwrap-v1-20261007-attempt1/`. Summary SHA256: `0d634090c0f3d32666f932b2305ac4b1b1c6cd650f6e1ad6760a0d6f190a9850`.

The Windows parent executes the fixed mock callback and signs durable receipts. The Python relay runs under WSL/bwrap `--unshare-all --clearenv`, with readonly system/code mounts and tmpfs work directories. No host output, credential environment, evaluator path or interop socket is mounted. Actual diagnostics show only `lo`, non-loopback ENETUNREACH101, absent `/mnt` and `/run`, and an inaccessible parent-only fake evaluator sentinel. Fake credential/evaluator markers and the parent receipt key are absent from transmitted bootstrap, raw stdout/stderr and responses. Temporary parent state is removed.

Framing has bounded lengths, exact body hashes, authenticated envelopes and replay rejection. A channel key authenticates transport framing; it is available to the relay and does not make the subject trustworthy. A separate parent-only key signs receipts. Bad authentication, replay and partial-frame refusals are retained. Linux and Windows watchdogs bound the proof; a callback timeout does not prove cancellation of an underlying operation.

This proves OS placement for a relay and mocked parent callback. It does not yet prove the integrated Codex consumer uses that bridge, a real HTTPS callback, complete scenario scheduling, semantic compliance or hidden model retention. Real transport configuration, account/model, budget and execution authority remain deferred until launch.

## Integrated CLI through the trusted parent (2026-10-08)

Proof directory: `tools/fixtures/conditional_skill_routing/capture-demonstrations/parent-cli-stdio-wsl-bwrap-v1-20261008-attempt1/`. Summary SHA256: `54469e3be9bc0811088da4667f6dfbae04007f6972a40f9cf503384fe53ae62a`.

Five actual CLI requests traverse authenticated framed stdio to the Windows mock parent. Three exact tool results appear in the following and later requests. Four validated complete SSE responses reach the CLI unchanged; the fifth native tool attempt is blocked in the parent before any SSE reaches the pipe. The second native turn fails as expected, without a command execution event. Fake parent-only credentials and evaluator sentinels remain outside the child namespace.

Independent raw replay verifies all 197 artifacts, framing signatures and hashes, unchanged input/instructions, exact dynamic schemas, actual callback and assistant RPC events, response admission and temporary cleanup. Receipt: `independent-integrated-review.json`, SHA256 `d5552a66404e251ddf181896313fd945a3a63edc12fb952091f152f2c50728b1`.

This closes the integrated three-tool mocked transport step. Full H/A/B/S case orchestration uses a separate parent-owned controller and remains subject to its own actual CLI proofs and independent preparation gates. The earlier local-only summary in the child intentionally remains false because that local mock is unused; `integrated-summary.json` and the outer summary describe the executed parent path.

## Parent-owned H/A/B/S case flows under mock Responses (2026-10-09)

Eight fixed case proofs completed with Codex Linux 0.160.1 under WSL/bwrap and the scripted provider. The four families each include a cold and continuation case. Across 199 mock model requests, 184 fictional callbacks executed; every exact callback result appears in the immediately next and later requests. Four fixture refusals were captured. The integrated three-tool proof above supplies the separate pre-emission HTTP 502 rejection for a native `exec_command` attempt. These are fixture refusals and transport gates, not model refusals or semantic compliance.

| Case | Requests | Callbacks | Refusals | Summary SHA256 |
| --- | ---: | ---: | ---: | --- |
| H1 | 12 | 11 | 1 | `688fca186dc890b0b5fdb7f9a482e7ae90eb89c6310ecc401db7ec52333aea4c` |
| H2 | 14 | 12 | 1 | `d59904d8b45a94b1e2f2e929ef359669e0a02aee1c5eb984e7bdeeab41464878` |
| A1 | 23 | 22 | 1 | `a07b159576ad761799f4962da53055a90fdd62705679e8e9096b8c223fddb7d5` |
| A2 | 20 | 18 | 0 | `410b9b7f16259e9cd8bd27bfd5856c8d926acd99e589fa5c9392d47f9e931e85` |
| B1 | 19 | 17 | 0 | `a467e8a926b2f8a41599384d0477a73a12c5ad79ee8edf9a160287b094d0506f` |
| B2 | 31 | 28 | 1 | `a1749f051a94eebb825cd6251d7bb2f0b0da5db6b6e1f1d176fa656483288c62` |
| S1 | 37 | 36 | 0 | `ca20e83cc4df8e7d158021744e4da0274429813c39ec7d2ca105e24db3a37486` |
| S2 | 43 | 40 | 0 | `5c8ecf3eb827240c014f9bd4048c4ee283709ab470dbe49ed185be3b3831736b` |

Root-side rehash verified all 232 per-run inventory artifacts, child and parent source bindings, the exact reviewer snapshot, launcher source snapshot SHA256 `7eebf39739c2862165388bb4d1c09ac5e5edfe0fb7ade3f213b169062312f3a7`, and temporary cleanup receipts. The independent receipt checks raw associations before cleanup; the reviewer and child relay have one author, so distinct child-source review is still open. No raw conversation text is retained in the durable summary. Raw workspaces have already been removed; this is receipt/inventory verification, not a second raw replay.

The live-only launcher now requires an evaluator receipt bound to the campaign, case and hash of the unchanged ephemeral capture inventory. Its status must be exactly `PASS`, `FAIL` or `INCONCLUSIVE`; only `PASS` allows `summary.passed=true` for a real baseline. This receipt integrity check is not reviewer authentication. The new launcher source SHA256 is `78c5647fe202516738fab8e4f58b316f8377061484d30c3e181869f3f0df5f17`; the fixed eight runs predate this live-only guard and do not claim to exercise it. All 20 focused launcher tests and the combined 81-test affected suite pass offline. No real provider, account authentication, model observation, baseline or campaign was run. AC5 and thresholds remain unchanged; migration stays NO-GO.
