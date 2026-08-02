# ShipGlows Main Public Intents

This reference lets the public `shipglows` plugin expose useful `shipglows-main` behavior through one visible entrypoint without copying the internal numbered skill tree.

Use these intents behind:

```text
$shipglows <instruction>
```

Do not expose internal skill ids as the default user route.

## Availability

`shipglows-main` is partial in the public plugin.

Bundled now:

- intent routing for `spec`, `ready`, `start`, `verify`, `check`, and `fix`
- lightweight contracts for scoping, readiness, execution planning, verification, checks, and bug triage
- complete-corpus fallback guidance when full ShipGlows internals are required

Not bundled now:

- ShipGlows `shipglows_data/` workflow state
- internal numbered skills as separate public skills
- bug memory under `shipglows_data/workflow/bugs/`
- ShipGlows-specific tools under `tools/`
- long internal references such as chantier tracking, reporting contracts, design-system contracts, observability contracts, and metadata linting

## Shared Public Rule

Do the work that is safely possible in the current workspace before asking the operator to act.

Allowed in public partial mode:

- inspect local files when the user asks for project work
- infer project stack from ordinary repo files
- propose or run safe local checks when commands are obvious
- produce a spec skeleton, readiness verdict, execution plan, verification checklist, check plan, or bug triage
- say exactly which complete-corpus feature is missing when full ShipGlows behavior is unavailable

Do not claim a complete ShipGlows verdict when the bundled plugin lacks the full reference, tracking, or tool surface.

## Intent Map

### `spec`

Use when the instruction asks to write, frame, create, or clarify a spec.

Portable behavior:

- restate the user story as actor, need, and observable outcome
- define in scope and out of scope
- identify success, error, and edge cases
- list implementation surfaces and unknowns
- propose a compact task sequence

Stop or mark partial when:

- product intent is ambiguous
- security, billing, data deletion, auth, or migration behavior is underspecified
- the user expects ShipGlows-owned tracking files to be created but the complete corpus is not installed

### `ready`

Use when the instruction asks whether a spec or task is ready.

Portable behavior:

- return `ready`, `not ready`, or `blocked`
- check user-story fit, scope boundaries, behavioral contract, data/security risks, and verification plan
- name the smallest missing decision that blocks execution

Do not mark `ready` if success/error behavior or verification evidence is unclear.

### `start`

Use when the instruction asks to begin, implement, continue, or execute.

Portable behavior:

- decide whether the work is direct-execution or spec-first
- inspect the workspace enough to avoid blind instructions
- identify files, commands, and verification expected next
- execute only when the current session has the needed project context and tools

Partial mode:

- if the task needs internal ShipGlows workflow state, say that complete ShipGlows corpus setup is required for full tracking
- still continue with ordinary Codex implementation when the request is clear and local files are available

### `verify`

Use when the instruction asks to verify, review readiness, prove, or validate.

Portable behavior:

- check claimed change against requested behavior
- verify success path, error path, edge cases, regressions, and remaining risk
- run or recommend local checks based on discovered project tooling
- report `verified`, `partial`, or `blocked`

Do not ask the operator to retest before doing safe browser, command, file, or log checks that this session can perform.

### `check`

Use when the instruction asks for checks, lint, typecheck, build, tests, or dependency sanity.

Portable behavior:

- inspect package/tooling files before choosing commands
- prefer existing scripts over invented commands
- run safe non-deploy checks when available
- fix local failures when the user asked for repair or continuation

Ask before installs, destructive cleanup, credential use, production deploys, or commands that need explicit approval.

### `fix`

Use when the instruction asks to fix a bug, regression, failing check, or broken behavior.

Portable behavior:

- classify the issue as direct bugfix, needs reproduction, or spec-first
- inspect relevant code and evidence before proposing changes
- prefer regression-first proof when practical
- implement local fixes when scope and files are clear
- verify with the closest available check

Partial mode:

- if ShipGlows bug memory or internal proof routing is unavailable, say so
- continue with ordinary bug triage and local proof instead of stopping

## Complete Corpus Fallback

Full ShipGlows behavior requires the complete corpus when the workflow needs:

- `shipglows_data/` specs, checklists, or workflow records
- ShipGlows-owned bug memory
- internal numbered skills as callable separate skills
- ShipGlows scripts such as metadata linting, sync, or design drift tools
- private governance references

When this is required, say:

```text
This can run in public partial mode now. Full ShipGlows tracking/proof requires the complete ShipGlows corpus.
```

Then continue with the best safe partial action unless the missing corpus truly blocks the task.
