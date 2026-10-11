---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: design-inspiration-motion-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/design-inspiration-library.md
  - skills/006-sg-design/references/design-inspiration-library-operations.md
  - skills/references/design-inspiration/record.schema.yaml
  - tools/capture_design_inspiration.py
  - tools/capture_design_inspiration_playwright.js
  - tools/test_capture_design_inspiration.py
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/private-data-repo-contract.md
    artifact_version: "2.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved optional private motion-evidence contract on 2026-08-15."
  - "Playwright official video documentation confirms recordVideo and context-close persistence; local cached stable package 1.62.1 was observed."
next_review: "2026-11-15"
next_step: "/103-sg-verify design inspiration motion evidence"
---

# Design Inspiration Motion Evidence Contract

## Purpose And Default

Use this contract only when an operator explicitly adds `--motion` to one
private design-inspiration capture. Motion is optional and disabled by default.
It supplements the static page structure and WebP bundle with a short review
artifact; it never replaces static evidence or changes the meaning of its
capture status.

The only permitted sequence is:

1. hold the initial public state briefly;
2. perform bounded vertical scroll without hover, clicks, forms, or arbitrary
   scripts; and
3. return to the top and hold briefly.

No hover scripting or interaction DSL is allowed. One motion invocation accepts
exactly one public URL or one synthetic local fixture. Ordinary static batching
keeps its existing separate limit.

## Recording Boundary

Use Playwright's stable `browser.newContext({recordVideo})` API. Create a fresh
ephemeral context without credentials or persisted state, disable downloads and
service workers, and record one page only. Close the recording context before
reading or copying `page.video().path()`; Playwright finalizes the file on
context closure. A close or finalization error is a motion failure, not a static
capture failure.

The recording has no audio. Do not enable microphone, media capture, browser profiles,
authentication, cookies, storage state, localStorage,
sessionStorage, HAR, trace, downloads, or existing user sessions. Never retry
with credentials, stealth, a signed-in browser, or access-control bypass. An
auth wall or blocked state produces no durable motion artifact.

Live navigation, initial hold, scroll steps, scroll distance, return hold,
viewport, output size, elapsed time, and output bytes have fixed upper bounds
in the capture tool. A boundary failure deletes the temporary video and records
a safe reason. No source URL appears in command arguments; console output and
errors redact query strings.

## Static Independence And Result Semantics

Evaluate static capture and motion independently:

- `not_requested`: `--motion` was absent; no recorder was invoked and no WebM
  exists.
- `captured`: a finalized, non-empty WebM within all bounds exists and its
  checksum matches the record.
- `unavailable`: the shared Playwright CLI/package/browser or video capability
  is unavailable; static evidence remains truthful.
- `failed`: navigation, access check, context close, finalization, validation,
  size/duration bound, or cleanup prevented usable motion.

Motion failure must not downgrade a complete static capture or upgrade an
incomplete one. The static result remains `captured`, `partial`, `failed`,
`blocked`, or `auth_required` according to its own artifacts and access proof.
A failed or unavailable motion block contains an explicit reason code/message,
null artifact/checksum, and no fake file.

## Private Record And Storage Contract

New `record.yaml` files include a `motion` block. Legacy records without that
optional block remain readable. A successful block records:

- `requested: true`, `status: captured`, relative `artifact: motion.webm`,
  `format: webm`, `mime_type: video/webm`, and `audio: false`;
- SHA-256 checksum matching `checksums.files.motion.webm`;
- fixed sequence names, viewport and video size, elapsed duration, actual step
  count, maximum reached scroll distance, and configured bounds;
- null reason fields.

The WebM lives only inside the separate private corpus. It follows the same
attribution, takedown, replacement, purge, and no-redistribution posture as the
static bundle. No real WebM, source-derived page artifact, private record,
remote, or video fixture belongs in the public ShipGlows repository. Public
schemas and samples use metadata plus a synthetic `not_requested` example only.

## Git LFS And Synchronization

Private Git synchronization must verify the LFS filter for every changed
`.webp` and `.webm` path before `git add`. If any WebM is not LFS-tracked, return
exactly `pending reason=lfs_tracking_missing`; do not stage, commit, or push.
The local private capture remains intact for configuration repair.

This contract does not authorize a real sync, remote creation, repository
privacy change, commit, or push. Those actions retain the private-corpus
contract and explicit operator authority.

## Synthetic No-Network Proof

`--fixture --no-network --motion` is allowed only for a synthetic HTML fixture
and output under the system temporary directory. Abort browser network requests
and use local `page.setContent`; do not load the source URL. The proof may create
a temporary WebM, but must remove the whole temporary corpus after assertions.
If the shared recorder is unavailable, the fixture must still prove that static
capture remains valid and motion reports `unavailable` without a file.

Unit tests may mock the Python↔Node boundary with deterministic synthetic WebM
bytes. They must still prove relative path, checksum, metadata bounds, failure
semantics, finalization order, and cleanup. A mock never supports a claim that
the host recorder or a live page was rendered successfully.

## Proof And Stops

Proof must cover motion absent, success, unavailable/failure, multi-source
refusal, LFS refusal before Git mutation, synthetic no-network behavior,
forbidden state surfaces, duration/viewport/step/distance limits, Python↔Node
payload validation, context-close ordering, malformed/missing WebM, and cleanup.

Stop when `--motion` has multiple sources; auth or private state is required;
the sequence needs hover, clicks, forms, audio, arbitrary code, or another page;
the video cannot be finalized after context close; bounds or checksums fail;
the output is not in the private/temporary root; or LFS tracking is absent.

## Sources

- Playwright videos: `https://playwright.dev/docs/videos`
- Playwright Video API: `https://playwright.dev/docs/api/class-video`
