---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-13"
created_at: "2026-07-13 21:00:14 UTC"
updated: "2026-07-13"
updated_at: "2026-07-13 21:27:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "cross-project source-analysis contract and email adapters"
owner: "Diane"
user_story: "En tant qu'operatrice qui revoit des emails concurrents, je veux que chaque email soit automatiquement enrichi avec un resume factuel, plusieurs angles de contenu et des prochaines actions adaptees au bon projet, afin de decider immediatement quoi creer sans maintenir deux moteurs d'analyse divergents dans Mail Intelligence et ContentGlowz."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/references/source-intake-classification.md"
  - "skills/references/private-memory-store.md"
  - "skills/references/schemas/source-analysis-v1.schema.json"
  - "/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/"
  - "/home/claude/dotfiles/nvim/MyNeovim/scripts/mail-intake"
  - "/home/claude/dotfiles/nvim/MyNeovim/systemd/user/shipglows-mail-intake.service"
  - "/home/claude/.config/systemd/user/shipglows-mail-intake.service"
  - "/home/claude/contentglowz/lab/agents/sources/"
  - "/home/claude/contentglowz/lab/api/services/project_generation_context.py"
  - "/home/claude/contentglowz/lab/api/services/pydantic_ai_runtime.py"
  - "/home/claude/contentglowz/lab/status/service.py"
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "shipglows_data/workflow/explorations/2026-06-29-mail-source-intake-automation.md"
    artifact_version: "1.1.0"
    required_status: draft
  - artifact: "/home/claude/dotfiles/nvim/MyNeovim/shipglows_data/workflow/specs/daily-mail-intake-review-v2.md"
    artifact_version: "1.0.0"
    required_status: ready
  - artifact: "/home/claude/contentglowz/shipglows_data/technical/lab/architecture.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "/home/claude/contentglowz/shipglows_data/branding/branding.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator request 2026-07-13: pre-enrich every reviewed email with proposed content angles and likely next actions before the operator opens it."
  - "Operator request 2026-07-13: inspect ContentGlowz email capabilities and avoid implementing the same analysis engine twice."
  - "Mail Intelligence already persists one private metadata-only review file per stable local message and exposes a Neovim review surface."
  - "ContentGlowz already extracts multiple ideas from newsletter bodies, scores them against persona context, inserts Idea Pool rows, and archives fetched messages."
  - "ContentGlowz currently has no canonical one-record-per-email analysis, no source-level dedupe, drops the source UID before Idea Pool persistence, and archives the full fetched batch after any non-empty result."
  - "Seventeen focused ContentGlowz email-source, newsletter, generation-context, memory-scoping, and Idea Pool tests passed on 2026-07-13; source extraction and partial-batch archive behavior have no focused tests."
  - "Installed codex-cli 0.144.3 exposes non-interactive --output-schema, --output-last-message, --ephemeral, model, config, working-directory, and read-only sandbox controls."
  - "Current Codex manual checked on 2026-07-13 confirms non-interactive structured output, ephemeral runs, explicit model selection, ignore-user-config/ignore-rules controls, and Linux bubblewrap sandboxing."
  - "The current local Codex model cache exposes gpt-5.4-mini with medium as its default reasoning level."
  - "Current official PydanticAI output documentation checked on 2026-07-13 confirms typed output_type validation; current official Sentry Python documentation confirms before_send scrubbing and that local variables, request data, and breadcrumbs are sensitive event surfaces."
  - "Installed Avante commit 2183acf00831a3ab366265ee35eef1a342716694 supports ACP streaming through avante.llm, while avante.api AskOptions still does not accept a per-request model or provider field."
next_step: "/102-sg-start shared source analysis contract and email adapters"
---

# Spec: Shared Source Analysis Contract And Email Adapters

🟢 [ShipGlows] spec: Shared Source Analysis Contract And Email Adapters | status: ready | path: shipglows_data/workflow/specs/shared-source-analysis-contract-and-email-adapters.md | next: /102-sg-start shared source analysis contract and email adapters

## Title

Shared Source Analysis Contract And Email Adapters

## Status

Ready. The contract passed the readiness, adversarial, security, freshness, proof, and cross-repository scope gates. No product code has been changed by the spec/readiness runs.

## User Story

En tant qu'operatrice qui revoit des emails concurrents, je veux que chaque email soit automatiquement enrichi avec un resume factuel, plusieurs angles de contenu et des prochaines actions adaptees au bon projet, afin de decider immediatement quoi creer sans maintenir deux moteurs d'analyse divergents dans Mail Intelligence et ContentGlowz.

## Minimal Behavior Contract

When a new competitor email enters either supported intake flow, the system creates or updates one durable analysis for that source before the operator reviews downstream proposals. The analysis separates observed facts from inferences and returns a factual summary, zero or more project candidates, multiple content angles, likely next actions, confidence, risks, and provenance under one versioned contract. Mail Intelligence uses portfolio-level project routing and leaves every downstream action pending human review; ContentGlowz uses a fixed authenticated project and may derive Idea Pool candidates only after the source analysis is durably persisted. If analysis, validation, persistence, or partial idea derivation fails, the source remains retryable, no raw body is copied into public/versioned artifacts, and no automatic archive or content action occurs. The easy edge case is a batch where only some emails or angles succeed: success and archive decisions must be source-specific, not batch-wide.

## Success Behavior

- Preconditions: A source email has a stable adapter-owned identifier, bounded readable text, and the relevant project context is available or explicitly absent.
- Trigger: Mail Intelligence's scheduled intake or explicit reanalysis runs in `portfolio_review` mode; ContentGlowz's per-user IMAP job runs in `fixed_project_content` mode.
- User/operator result: Opening a Mail Intelligence review item already shows its factual summary, candidate project, several content angles, risks, and proposed actions. ContentGlowz exposes the resulting ideas through its existing Idea Pool flow without requiring a second analysis prompt.
- System effect: Exactly one current `SourceAnalysis` is persisted per source key and schema version; downstream angle records reference stable analysis and angle identifiers.
- Success proof: Canonical schema validation, language-adapter parity tests, idempotent reruns, source-specific partial-failure tests, local systemd dry/live proof with redacted diagnostics, focused ContentGlowz tests, and manual Neovim review proof.
- Silent success: Not allowed. Mail Intelligence writes a redacted run summary and analysis status visible in the queue; ContentGlowz records source status and scheduler outcome without source content.

## Error Behavior

- Expected failures: Missing source text, malformed model JSON, schema mismatch, provider timeout, unavailable project context, missing BYOK credential, duplicate source, stale reanalysis, database failure, partial angle derivation failure, IMAP archive failure, and prompt-injection-like instructions inside a source email.
- User/operator response: Mail Intelligence shows `pending_analysis`, `needs_review`, or `analysis_failed` with a short recoverable reason and keeps the explicit reanalysis action. ContentGlowz keeps a retryable source-analysis state and reports a structured authenticated error or scheduler failure.
- System effect: Do not overwrite the last valid analysis with invalid output. Persist only redacted error metadata, leave failed sources unarchived, and retry idempotently without duplicating ideas.
- Must never happen: Raw email bodies in ShipGlows, MyNeovim, ContentGlowz public repos, Sentry, systemd logs, or model-output diagnostics; cross-user project context; following instructions embedded in an email; remote Mail Intelligence inbox mutation by the analyzer; batch-wide archive after partial success; duplicated Idea Pool candidates for the same analysis angle.
- Silent failure: Not allowed. Local runs exit non-zero when any pending item fails after processing the bounded set; ContentGlowz records the failed source state, captures a redacted exception when Sentry is configured, and leaves the scheduled job diagnosable.

## Problem

Mail Intelligence and ContentGlowz currently solve adjacent parts of the same problem with incompatible contracts. Mail Intelligence keeps one source review record and portfolio routing but relies on an interactive, mostly single-angle analysis path. ContentGlowz extracts several content ideas, but it immediately flattens them into Idea Pool rows, loses stable source correlation, uses legacy server-key LLM access, and archives at batch scope. Implementing richer angles independently in both systems would duplicate prompt rules and cause schema, privacy, project-context, and review semantics to drift.

## Solution

Create a canonical provider-neutral `SourceEnvelope`/`SourceAnalysis` V1 contract in ShipGlows and enforce parity with machine validation. Implement separate host adapters: a scheduled, filesystem-isolated Codex batch adapter and Neovim renderer for Mail Intelligence, and a typed request-scoped PydanticAI adapter plus source-analysis persistence for ContentGlowz. Share the schema, field semantics, prompt-safety rules, and contract fixtures; keep source access, credentials, context retrieval, persistence, and mutation policy inside each host. For the existing Mail Intelligence v2 chantier, this contract supersedes only Task 4's Avante/ACP classification-persistence strategy; the restored v1 reader, v2 review UI, mappings, scan flow, and conversational Avante actions remain active and must be preserved.

## Scope In

- A versioned JSON Schema and human-readable contract owned by ShipGlows.
- `SourceEnvelope` input semantics for `portfolio_review` and `fixed_project_content` modes.
- `SourceAnalysis` output with factual summary, observations, inferences, project candidates, multiple angles, next actions, reusable email-pattern fields, risks, confidence, review requirements, and model provenance. Host review state remains outside the replaceable analysis block.
- Stable adapter-derived `source_key`, `angle_id`, and `action_id` rules.
- Cross-repo contract validation between canonical JSON Schema, Mail Intelligence parsing, and ContentGlowz Pydantic JSON Schema.
- Automatic bounded Mail Intelligence analysis after queue scan, before Neovim review, using non-interactive Codex structured output.
- Manual Mail Intelligence reanalysis through the same contract instead of a separate structured Avante implementation.
- Existing conversational Avante actions may remain for ad hoc questions and summaries, but they are not the canonical persistence path.
- One metadata-only analysis block per Mail Intelligence review file; raw bodies remain in Maildir.
- One tenant-scoped source-analysis record per ContentGlowz email source, with project context and analysis provenance.
- ContentGlowz derivation of idempotent Idea Pool candidates from persisted angles.
- Source-specific archive eligibility after successful analysis persistence and downstream derivation.
- Redacted Sentry/log/diagnostic behavior and commit/build timestamp visibility.
- Focused automated, provider-smoke, scheduler, and manual Neovim validation.

## Scope Out

- A shared deployable Python package in this phase. Extract only after both adapters prove V1 contract parity and maintenance duplication remains material.
- A new ContentGlowz screen for browsing raw emails or source-analysis records; existing Idea Pool remains its user-facing destination.
- Automatic publishing, newsletter sending, sequence sending, spec creation, or public content creation.
- One-to-one email composition or support inbox replies.
- Remote Mail Intelligence archive, delete, label, or read-state mutation by automatic analysis. Existing explicit operator-owned Gmail actions remain separate.
- Copying raw email bodies into private queue files, ShipGlows artifacts, ContentGlowz logs, or test fixtures.
- A visual redesign of the Neovim review surface.
- Migrating historical ContentGlowz Idea Pool rows or historical Mail Intelligence `done/` records.
- Generalizing the contract to every source type beyond email during V1, although the schema must leave room for future non-email source types.

## Constraints

- ShipGlows owns contract meaning; host repositories own runtime adapters.
- The canonical machine contract lives at `skills/references/schemas/source-analysis-v1.schema.json`; host adapters must not silently extend required fields or reinterpret enums.
- Raw email is untrusted source material. Prompt instructions inside the email must be treated as data and must never change tools, destination, permissions, or mutation policy.
- Persist observed facts separately from inferred fields. Do not present project fit, audience fit, or action suggestions as source facts.
- The analysis output must contain no copied long passages, tracking URLs, recipient addresses, credentials, cookies, or headers beyond the minimum observed metadata allowed by the host.
- Mail Intelligence remains review-first. Every suggested action has `requires_review=true` and no downstream skill runs automatically.
- ContentGlowz is fixed-project for this flow. It uses the configured project ID and must not route an authenticated user's email across the operator's private portfolio cache.
- Tenant isolation is mandatory for ContentGlowz source, context, analysis, and Idea Pool records.
- ContentGlowz analysis registers no function, MCP, web, or external action tools; PydanticAI's provider-level structured-output mechanism is permitted only to return the typed result.
- Mail Intelligence automatic analysis is explicit local opt-in, enabled only after provider smoke and redaction proof on the current server.
- Default local batch model is `gpt-5.4-mini` with `model_reasoning_effort=medium`; environment overrides must be explicit and diagnostics must report the effective non-secret values.
- No automatic model fallback is allowed. If `gpt-5.4-mini` or an explicit override is unavailable, the source remains retryable and the run reports `model_unavailable` without attempting a different model.
- V1 hard limits are: 24,000 Unicode characters of source text, 48,000 characters of selected context, 32 KiB of final model output, 10 pending Mail Intelligence sources per scheduled run, one active model call per host worker, and 180 seconds per model call. Configuration may lower these limits but may not raise them without a contract-version change and renewed readiness/security review.
- Codex batch runs use `--ephemeral`, `--output-schema`, `--ignore-user-config`, `--ignore-rules`, a bounded temporary working directory, no persistent chat, and no dangerous sandbox bypass. Explicit overrides set `features.shell_tool=false`, `features.multi_agent=false`, `features.apps=false`, `features.remote_plugin=false`, `web_search="disabled"`, and `shell_environment_policy.inherit="none"`. They must run inside `bubblewrap` (available at `/usr/bin/bwrap` on the current host) or an equivalently proven filesystem sandbox that exposes only the bounded payload/schema workspace, required CA/runtime files, and a dedicated minimal Codex auth/config directory. Use `--clearenv` and restore only the minimum parent runtime variables. The untrusted source must not be able to read the normal home, repositories, private project cache, mailbox, SSH material, or unrelated environment secrets.
- The sandbox may retain only the provider transport and authentication required by the Codex parent process. The model has no shell, child command, MCP, app, plugin, web/search, connector, subagent, repository-instruction, or unrelated skill capability. Provider authentication is injected from the dedicated minimal runtime directory or an allowlisted descriptor; it is never copied into the payload workspace, model context, diagnostics, queue record, or child-process environment.
- Keep queue files as one editable Markdown file per source. Store the validated analysis as a bounded JSON block plus scalar status/version metadata; do not create a second raw-source cache.
- ContentGlowz archive is allowed only per source after its valid analysis is persisted and every intended angle derivation is committed or intentionally skipped. Archive failure does not roll back valid analysis but remains observable and retryable without duplicating ideas.
- Source-analysis failures sent to Sentry use a dedicated allowlisted event containing only error code, route, schema, status, model, commit, and timing metadata. Do not pass the original exception object when its stack or locals may retain source/context/model data. For this surface, `send_default_pii=false`, `include_local_variables=false`, `max_request_body_size=never`, and `before_send`/breadcrumb scrubbing are mandatory regardless of broader deployment defaults.
- No visual constants, colors, dimensions, or layout changes are allowed in this chantier. MyNeovim has no declared design-system authority; rendering must reuse the existing Markdown/layout behavior. Any visual redesign must stop and route through `300-sg-docs` plus `006-sg-design` before implementation.
- Preserve unrelated dirty changes in MyNeovim and any concurrent changes in all repositories.
- Adapter code, not model output, owns `source_key`, derived IDs, schema version, status normalization, timestamps, provider/model provenance, tenant/user/project scope, mutation policy, and review state. Mail Intelligence project candidates must resolve to the bounded private project index; ContentGlowz candidates must equal the authenticated configured project.

## Contract Model

### SourceEnvelope V1

Required normalized fields:

- `schema_version`: exact input contract version.
- `source_key`: stable adapter-derived opaque identifier; never use raw message content as the stored key.
- `source_type`: `email` in V1.
- `routing_mode`: `portfolio_review` or `fixed_project_content`.
- `observed`: bounded subject, sender label/domain when allowed, source date, and opaque host locator metadata.
- `content`: bounded text supplied only to the analyzer and excluded from persisted/logged envelope views.
- `project_hint`: optional operator/configured project constraint.
- `context`: bounded brand, audience, product, GTM, editorial, project, and portfolio context selected by the host.
- `allowed_outputs`: bounded output format/action vocabulary.
- `mutation_policy`: `never` for Mail Intelligence analysis and `after_source_commit` for ContentGlowz archive eligibility.

### SourceAnalysis V1

Required normalized fields:

- `schema_version`, `source_key`, `analysis_status`, and `generated_at`.
- `analysis_status` is exactly `matched`, `no_match`, or `needs_review`; provider/runtime failures are host operational states and are not persisted as valid model analyses.
- `summary`: one to five factual sentences with no copied long passage.
- `observations`: source-grounded facts only.
- `inferences`: explicit analytical deductions.
- `project_candidates`: zero or more `{project_id, confidence, reasoning}` entries; fixed-project mode returns only the configured project or `needs_review`.
- `angles`: two to five distinct entries for `matched`, zero entries for `no_match`, and zero to five entries for `needs_review`; each has `angle_id`, title, hook, output format, audience fit, evidence basis, risks, and confidence.
- `actions`: zero to five entries with `action_id`, owner kind, owner ID, action, priority, related angle IDs, and `requires_review`.
- `email_pattern`: optional structure, promise logic, proof pattern, CTA shape, objection handling, and sequence role without distinctive copied wording.
- `risks`: copyright, claims, brand, consent, privacy, freshness, and ambiguity risks.
- `provenance`: provider, model, reasoning effort when applicable, context version/hash, prompt-contract version, and generation timestamp.
- Review status, operator notes, accepted/rejected state, selected action, and handoff metadata are host-owned fields outside `SourceAnalysis` and survive reanalysis unchanged.

### Stable Identity Rules

- The host derives `source_key` from its stable message identifier plus tenant/account scope, then stores only an opaque hash where raw identifiers would leak data.
- The adapter derives `angle_id` after validation from `source_key + normalized title + output format`; model-supplied IDs are ignored.
- The adapter derives `action_id` from `source_key + owner + normalized action + sorted related angle IDs`.
- Reanalysis replaces the current analysis version atomically while retaining bounded provenance/history required for recovery; it does not append duplicate current analyses.
- ContentGlowz Idea Pool uniqueness is enforced on user, project, source analysis, and angle ID.

## Test Contract

### Surface

- `surface`: JSON Schema, Python CLI, Codex provider, Lua/Neovim UI, systemd user timer, FastAPI, PydanticAI, Turso/libSQL, authenticated multi-tenant data, IMAP, Idea Pool.
- `proof_profile`: `mixed-cross-repo-security-sensitive`.
- `proof_order`: canonical schema/unit tests -> host parser/store tests -> cross-repo contract parity -> ContentGlowz auth/data integration -> Codex provider smoke -> systemd dry/live run -> manual Neovim review -> verification.

### Manual checklist

- `checklist_path`: `shipglows_data/workflow/test-checklists/shared-source-analysis-email-adapters.md`.
- `required_scenario_ids`: `pre-enriched-neovim`, `matched-multiple-angles`, `no-match`, `manual-reanalysis-preserves-review`, `malformed-output-recovery`, `prompt-injection-sentinel`, `idempotent-rerun`, `partial-contentglowz-batch`, `source-specific-archive`, `model-unavailable-no-fallback`, and `redacted-diagnostics`.
- `required_results`: every required scenario records `pass`; automated suites and parity validation exit zero; provider smoke records the effective model without private payloads; the installed systemd unit matches the versioned source; manual Neovim proof confirms readable persisted analysis and stable navigation.
- `exception_with_proof`: No new Flutter visual proof is required because this phase exposes ContentGlowz results through the existing Idea Pool and adds no app screen. No Neovim visual redesign is claimed; manual proof checks data presence, readability, navigation stability, and absence of overlap at the existing terminal sizes.
- `exception_without_proof`: None.

### Required evidence stack

- Automated / unit / integration checks: ShipGlows metadata/schema tests; MyNeovim Python tests and headless Neovim load/command tests; ContentGlowz focused pytest and migration/store tests; `git diff --check` in every modified repo.
- Agent-run browser proof: Not required unless implementation adds a ContentGlowz API surface consumed by Flutter beyond existing Idea Pool contracts.
- Auth/session proof (`109-sg-auth-debug`): Required only for any new authenticated ContentGlowz route; otherwise service/store tests must prove user/project scoping.
- Contract/integration proof: Canonical JSON Schema validates fixtures and matches the ContentGlowz Pydantic schema; both hosts reject the same invalid fixtures.
- Provider evidence: One redacted `codex exec` structured-output smoke and one ContentGlowz request-scoped OpenRouter/PydanticAI smoke with synthetic fixtures only.
- Device-native proof: Not required because no native-only UI behavior changes.

## Dependencies

- ShipGlows source classification and private-memory contracts named in frontmatter.
- Current Mail Intelligence Maildir/notmuch, private queue, Neovim review, and user systemd flow.
- `codex-cli 0.144.3` local batch capabilities: `--output-schema`, `--output-last-message`, `--ephemeral`, `--model`, `--config`, `--cd`, `--skip-git-repo-check`, and `--sandbox read-only`.
- `/usr/bin/bwrap` and a dedicated private Codex runtime directory for filesystem isolation. Codex's own read-only sandbox remains defense in depth and is not accepted as the sole read-isolation boundary.
- Installed Avante source at commit `2183acf00831a3ab366265ee35eef1a342716694` for conversational compatibility only; canonical structured persistence must not depend on undocumented `avante.api.ask` fields.
- ContentGlowz `AIRuntimeService`, `run_openrouter_structured`, `ProjectGenerationContextBuilder`, status/Idea Pool service, per-user email source, and Sentry observability adapter.
- Turso/libSQL additive migrations and idempotent startup ensure pattern.
- Fresh external docs verdict: `fresh-docs checked`. The current Codex manual and local `codex-cli 0.144.3`/model cache support non-interactive schema output, ephemeral execution, explicit `gpt-5.4-mini`, medium reasoning, ignore-config/rules controls, and Linux bubblewrap sandboxing. Current official PydanticAI output docs plus the ContentGlowz runtime wrapper support typed structured output; implementation must not upgrade the declared `pydantic-ai>=1.56.0,<2.0` range and must re-check official docs if the runtime-resolved API diverges. Current official Sentry Python docs require explicit source-analysis scrubbing because exception locals, request data, and breadcrumbs can contain sensitive data.
- Design-system authority: no declared MyNeovim authority exists. This spec prohibits visual implementation changes and therefore does not authorize token/layout/style edits.

## Invariants

- One source, one current analysis per schema version and host scope.
- Same V1 semantics and enum meanings in both adapters.
- Raw bodies stay in Maildir or transient request memory and are never persisted by `SourceAnalysis`.
- Every downstream action remains a proposal until the owning host's existing review policy accepts it.
- Mail Intelligence automatic analysis never mutates Gmail, Maildir, labels, read state, or remote folders.
- ContentGlowz never reads the operator's global private project cache; it uses authenticated tenant/project context only.
- ContentGlowz never uses a server-global key in BYOK mode and never returns or logs a provider secret.
- A provider or parsing failure cannot destroy the previous valid analysis.
- A partial batch cannot archive or mark successful a source that did not complete its own persistence boundary.
- Reruns do not duplicate analysis rows or Idea Pool angles.
- Model output cannot select tools, write paths, mutation policy, user ID, tenant ID, or project ownership.
- Model output cannot supply trusted provenance, timestamps, schema/status state, source identity, or a project identifier outside the host-owned allowlist.
- The local model process cannot read the normal user home, Maildir, repositories, private project cache, SSH material, authentication files, or environment secrets beyond the bounded source/context explicitly placed in model input; the adapter exports only one bounded source payload and bounded context into its isolated workspace. Shell, child command, subagent, MCP, app, plugin, web/search, and connector capabilities remain disabled.
- Sentry and logs use low-cardinality status/schema/route metadata only, never email content, subject, sender, recipient, source locator, project context text, or model response.

## Links & Consequences

- Upstream systems: Gmail filters/labels, mbsync, notmuch, Mail Intelligence scan, per-user ContentGlowz email-source settings, scheduler jobs, private project cache, and ContentGlowz Project Intelligence.
- Downstream systems: Neovim review/handoff, `#source`, `emailing`, repurpose/research/docs owner skills, ContentGlowz Idea Pool, scheduler article/newsletter generation, Sentry, and operator diagnostics.
- Data consequences: New schema version and new ContentGlowz source-analysis persistence; additive Idea Pool linkage/uniqueness migration; richer private queue analysis block without raw source text.
- Auth consequences: ContentGlowz analysis is user/project scoped and uses request-scoped AI runtime secrets; no new anonymous surface.
- Operational consequences: The existing user timer gains a bounded analysis phase and may take longer or partially fail after scan. Logs must separate `scanned`, `analyzed`, `skipped`, `failed`, and `archive_failed` counts.
- Cost consequences: Automatic model calls are bounded by pending item count, source/context character limits, one active worker by default, and idempotent skip of current valid analyses.
- Performance consequences: Neovim only reads persisted analysis and does not wait for provider output during normal open; ContentGlowz analyzes source-by-source or with stable source-correlated batches and bounded concurrency.
- Product consequences: ContentGlowz continues to promise ready-made content with optional review; Mail Intelligence remains an operator decision surface rather than an autonomous content publisher.
- Existing-chantier consequence: Mail Intelligence v2 Task 4's current Avante/ACP structured persistence becomes migration input, not a second canonical analysis path. Its useful rendering and queue behavior may be retained, but the old single-angle schema and provider-captured persistence must be retired once the V1 contract is proven.

## Documentation Coherence

- Add `skills/references/source-analysis-contract.md` and link it from `source-intake-classification.md`, `emailing`, and the private-memory contract where applicable.
- Update the existing Mail Intelligence v2 spec, `Mail Intel.md`, and cheat sheet to mark the old Task 4 Avante/ACP persistence strategy as superseded by this contract while distinguishing scheduled analysis, manual reanalysis, conversational Avante questions, model configuration, failure states, and privacy boundaries.
- Update ContentGlowz lab architecture, code-docs map, agent-pipelines documentation, email-source spec, and Idea Pool API/data documentation.
- Update ContentGlowz `.env.example` only with non-secret model/bounds settings and existing Sentry/build metadata fields; never include real keys.
- Add a short migration note describing old Idea Pool rows as unlinked legacy rows rather than pretending they have source provenance.
- Do not update public marketing copy in this phase because no new public product promise is being launched.

## Edge Cases

- Two messages have the same subject but different stable message IDs.
- The same message appears under multiple local labels or folders.
- A source is re-fetched after successful analysis but before archive synchronization.
- One source produces no useful angle and returns `no_match`; this is a valid persisted analysis, not a provider failure.
- One source maps equally to multiple portfolio projects; Mail Intelligence persists candidates and `needs_review` instead of forcing one.
- A fixed ContentGlowz project has empty Project Intelligence context; analysis continues in degraded mode with explicit provenance and lower confidence.
- The configured ContentGlowz project changes after a source was analyzed; a new project-scoped analysis is required and old linked ideas remain attributable to the previous project.
- Provider JSON is valid JSON but violates bounds, enums, required review flags, or source key.
- Provider output includes raw source passages or tracking links; the sanitizer rejects or removes them before persistence and records a redacted validation failure when unsafe content cannot be repaired deterministically.
- Email content attempts prompt injection, requests tool use, asks for secret files, or changes the target project.
- Codex process times out, is killed, or writes no last message.
- The configured model is absent from the current authenticated Codex model set; do not fall back silently or persist fallback provenance.
- A local queue record is edited while scheduled analysis is running; atomic compare/update prevents overwriting operator decisions.
- ContentGlowz persists analysis but Idea Pool insertion fails for one angle; no source archive occurs until the intended derivation set is complete or explicitly marked skipped.
- IMAP archive fails after all durable writes; retry archive only and do not regenerate analysis or ideas.
- Sentry is unavailable; bounded local logs and persisted failure state remain sufficient for recovery.
- Model/version changes create semantically different output; provenance and contract version make the drift visible, and reanalysis remains explicit.

## Implementation Tasks

- [ ] Task 1: Define the canonical source-analysis contract and fixtures.
  - File: `skills/references/schemas/source-analysis-v1.schema.json`, `skills/references/source-analysis-contract.md`, `skills/references/source-intake-classification.md`, `tests/fixtures/source-analysis/`
  - Action: Specify V1 input/output semantics, enums, size limits, identity derivation, observed-versus-inferred rules, prompt-injection boundary, valid fixtures, and invalid pressure fixtures.
  - User story link: Creates the single shared meaning that prevents two engines from drifting.
  - Depends on: Existing source-intake and private-memory contracts.
  - Validate with: `python3 tools/validate_source_analysis_contract.py --fixtures tests/fixtures/source-analysis`
  - Notes: The JSON Schema is canonical for output shape; the human reference owns semantics that JSON Schema cannot express.

- [ ] Task 2: Add a cross-repo contract parity validator.
  - File: `tools/validate_source_analysis_contract.py`, `tests/test_source_analysis_contract.py`
  - Action: Validate canonical fixtures in `--canonical-only` mode, add strict adapter comparison for later tasks, compare required fields/enums/bounds against ContentGlowz's generated Pydantic schema when an adapter path is supplied, and expose deterministic diagnostics without reading private data.
  - User story link: Makes shared behavior enforceable rather than documentary only.
  - Depends on: Task 1.
  - Validate with: `python3 -m pytest tests/test_source_analysis_contract.py -q && python3 tools/validate_source_analysis_contract.py --canonical-only --fixtures tests/fixtures/source-analysis`
  - Notes: `--canonical-only` is the Task 2 completion gate. Strict mode accepts explicit repo paths and fails clearly when an expected adapter is absent or stale; it becomes mandatory after Task 6.

- [ ] Task 3: Implement the local Mail Intelligence batch analyzer.
  - File: `/home/claude/dotfiles/nvim/MyNeovim/scripts/mail-analyze`, `/home/claude/dotfiles/nvim/MyNeovim/scripts/mail-intake`, `/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/config.lua`, `/home/claude/dotfiles/nvim/MyNeovim/tests/test_mail_analyze.py`, `/home/claude/dotfiles/nvim/MyNeovim/tests/test_mail_intake.py`
  - Action: Add `analyze` and bounded `analyze-pending` flows that export one source transiently, load bounded private project context, create a minimal dedicated Codex runtime, disable shell/multi-agent/apps/plugins/web search and child environment inheritance through explicit `-c` overrides, run `codex exec --ignore-user-config --ignore-rules` through `bubblewrap --clearenv` with the canonical output schema and fixed model defaults, validate/sanitize output, derive stable IDs/provenance, and atomically update only the analysis fields in the existing queue record.
  - User story link: Ensures the analysis is present before the operator opens the email.
  - Depends on: Tasks 1-2.
  - Validate with: `cd /home/claude/dotfiles/nvim/MyNeovim && python3 -m pytest tests/test_mail_analyze.py tests/test_mail_intake.py -q`
  - Notes: Use synthetic fixtures only. Tests must inspect Codex event output to prove no command/tool/MCP/web/subagent item occurs and that hostile source instructions cannot access a sentinel file outside the allowlisted sandbox. The temporary work directory, payload, and output file live under a private runtime temp path and are removed on success/failure. Preserve operator review state, selected action, notes, and handoff metadata during atomic analysis replacement. Do not use dangerous sandbox bypasses.

- [ ] Task 4: Integrate scheduled local pre-analysis.
  - File: `/home/claude/dotfiles/nvim/MyNeovim/systemd/user/shipglows-mail-intake.service`, `/home/claude/.config/systemd/user/shipglows-mail-intake.service`, `/home/claude/dotfiles/nvim/MyNeovim/Mail Intel.md`
  - Action: Add the service definition to the versioned MyNeovim tree, install it deterministically into the user systemd directory, run bounded `analyze-pending` after scan, add explicit opt-in/configuration, preserve scan results on analyzer failure, and emit redacted counts plus effective model/schema/commit and UTC/Paris run timestamps.
  - User story link: Moves enrichment before review instead of requiring the `a` key for every message.
  - Depends on: Task 3 and successful synthetic provider smoke.
  - Validate with: `systemd-analyze --user verify ~/.config/systemd/user/shipglows-mail-intake.service && systemctl --user start shipglows-mail-intake.service && journalctl --user -u shipglows-mail-intake.service -n 80 --no-pager`
  - Notes: The installed user unit must match the versioned source before enabling/restarting the timer. Review journal output for redaction first. Do not include raw source identifiers or text.

- [ ] Task 5: Render persisted analysis and unify manual reanalysis in Neovim.
  - File: `/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/ai.lua`, `/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/review.lua`, `/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/init.lua`
  - Action: Migrate useful behavior from the current uncommitted `ai.lua`/review implementation, parse and display the canonical analysis block when a source opens, show multiple angles/actions readably, keep source body read-only, and make `a` invoke the same local analyzer/reanalysis path. Keep `r` and optional conversational Avante questions separate from canonical persistence; remove the old single-angle Avante persistence path after parity proof.
  - User story link: Gives the operator all useful proposals on arrival and one consistent reanalysis path.
  - Depends on: Tasks 1 and 3.
  - Validate with: Headless Neovim module/command tests plus the manual checklist scenarios `pre-enriched-neovim`, `matched-multiple-angles`, and `manual-reanalysis-preserves-review`.
  - Notes: Reuse existing layout and Markdown rendering. No new colors, dimensions, highlights, or design tokens.

- [ ] Task 6: Add ContentGlowz typed models and durable source-analysis storage.
  - File: `/home/claude/contentglowz/lab/api/models/source_analysis.py`, `/home/claude/contentglowz/lab/api/services/source_analysis_store.py`, `/home/claude/contentglowz/lab/api/migrations/008_source_analysis.sql`, `/home/claude/contentglowz/lab/status/db.py`
  - Action: Implement Pydantic V1 models aligned with the canonical schema and additive tenant/project/source keyed storage with atomic upsert, status, provenance, bounded error metadata, and no raw body column.
  - User story link: Preserves one explainable source record before producing multiple content candidates.
  - Depends on: Tasks 1-2.
  - Validate with: `cd /home/claude/contentglowz/lab && pytest -p no:cacheprovider tests/test_source_analysis_models.py tests/test_source_analysis_store.py -q`; then `cd /home/claude/shipglows && python3 tools/validate_source_analysis_contract.py --fixtures tests/fixtures/source-analysis --contentglowz-root /home/claude/contentglowz`
  - Notes: Enforce user/project/source uniqueness in storage, not only application code. Strict cross-repo schema parity is part of Task 6 completion.

- [ ] Task 7: Move ContentGlowz email analysis onto Project Intelligence and request-scoped AI runtime.
  - File: `/home/claude/contentglowz/lab/api/services/source_analysis_service.py`, `/home/claude/contentglowz/lab/api/services/ai_runtime_service.py`, `/home/claude/contentglowz/lab/api/services/pydantic_ai_runtime.py`, `/home/claude/contentglowz/lab/agents/sources/newsletter_extractor.py`
  - Action: Authorize the configured/provided project against the authenticated user, build fixed-project context through `ProjectGenerationContextBuilder`, run typed structured output through the current BYOK/platform resolver, sanitize/validate results, derive stable IDs/provenance, and retire the direct `utils.llm_simple.chat()` path for inbox analysis.
  - User story link: Reuses ContentGlowz's richer project truth while honoring the shared analysis contract.
  - Depends on: Task 6.
  - Validate with: `cd /home/claude/contentglowz/lab && pytest -p no:cacheprovider tests/test_source_analysis_service.py tests/test_pydantic_ai_runtime.py tests/test_project_generation_context.py -q`
  - Notes: Register a stable route ID such as `source_analysis.email`; no credential value may enter logs or persisted provenance.

- [ ] Task 8: Make ContentGlowz ingestion source-idempotent and archive-safe.
  - File: `/home/claude/contentglowz/lab/agents/sources/ingest.py`, `/home/claude/contentglowz/lab/scheduler/scheduler_service.py`, `/home/claude/contentglowz/lab/status/service.py`, `/home/claude/contentglowz/lab/api/migrations/009_idea_source_analysis_link.sql`, `/home/claude/contentglowz/lab/api/routers/idea_pool.py`
  - Action: Analyze sources with stable UID correlation, persist each analysis before derivation, insert/update Idea Pool angles with unique analysis/angle linkage, use configured project ID when manual request omits it, and archive only source-specific completed records.
  - User story link: Prevents duplicate work and ensures one failed email does not disappear with a successful batch.
  - Depends on: Tasks 6-7.
  - Validate with: `cd /home/claude/contentglowz/lab && pytest -p no:cacheprovider tests/test_newsletter_ingest_source_analysis.py tests/test_email_source_service.py tests/test_idea_pool_source_links.py tests/test_scheduler_newsletter_ingest.py -q`
  - Notes: Analysis with zero angles is a successful `no_match`; it may become archive-eligible after persistence. Archive-only retry must not rerun the model.

- [ ] Task 9: Add redacted observability and runtime/build diagnostics.
  - File: `/home/claude/contentglowz/lab/api/observability.py`, `/home/claude/contentglowz/lab/api/routers/health.py`, `/home/claude/contentglowz/lab/.env.example`, ContentGlowz source-analysis service/scheduler, and MyNeovim analyzer diagnostics.
  - Action: Add a dedicated allowlisted source-analysis failure event by error code instead of sending raw exceptions that may retain source/context locals; enforce no PII, request body, local variables, source-bearing breadcrumbs, or model response; add low-cardinality route/schema/status diagnostics; expose commit plus UTC/Paris build timestamps through existing version/diagnostic surfaces; and document Sentry/PM2 fallback without logging source content.
  - User story link: Makes automatic enrichment trustworthy and recoverable when it fails unattended.
  - Depends on: Tasks 3-8.
  - Validate with: `cd /home/claude/contentglowz/lab && pytest -p no:cacheprovider tests/test_observability.py tests/test_health.py tests/test_source_analysis_observability.py -q` plus redacted local diagnostic inspection.
  - Notes: Sentry screenshots, replay, request bodies, exception locals, email fields, prompt text, source-bearing breadcrumbs, and model responses remain disabled/excluded. Tests inspect the final event after `before_send`, not only the caller arguments.

- [ ] Task 10: Align documentation and create the manual proof checklist.
  - File: `shipglows_data/workflow/test-checklists/shared-source-analysis-email-adapters.md`, `/home/claude/dotfiles/nvim/MyNeovim/Mail Intel.md`, `/home/claude/dotfiles/nvim/MyNeovim/Cheat Sheet.md`, `/home/claude/dotfiles/nvim/MyNeovim/shipglows_data/workflow/specs/daily-mail-intake-review-v2.md`, `/home/claude/contentglowz/shipglows_data/technical/lab/architecture.md`, `/home/claude/contentglowz/shipglows_data/technical/lab/code-docs-map.md`, `/home/claude/contentglowz/shipglows_data/technical/lab/agent-pipelines.md`
  - Action: Document contract ownership, host-specific policies, scheduled/manual behavior, privacy, model/runtime selection, archive rules, failure recovery, legacy records, and exact proof scenarios.
  - User story link: Keeps future agents from rebuilding or contradicting the shared engine.
  - Depends on: Tasks 1-9.
  - Validate with: ShipGlows metadata lint, focused `rg` coherence checks, and code-docs-map coverage.
  - Notes: Do not include real email examples, private project contents, or secrets.

- [ ] Task 11: Run cross-repo verification without shipping unrelated dirty changes.
  - File: This spec, both host repositories, and the manual checklist evidence.
  - Action: Run the complete proof order, inspect diffs in each repository, verify no recursive duplicate Neovim modules return, confirm ContentGlowz remains tenant scoped, and hand off to `103-sg-verify` with explicit provider/manual proof limits.
  - User story link: Proves the shared behavior actually replaces duplicate analysis rather than adding another path.
  - Depends on: Tasks 1-10.
  - Validate with: Commands in Test Strategy plus `git diff --check` and scoped status/diff review in all three repositories.
  - Notes: Do not commit or revert unrelated user/concurrent changes.

## Acceptance Criteria

- [ ] AC 1: Given a valid synthetic email envelope, when either adapter analyzes it, then the output validates against `source-analysis-v1.schema.json` and preserves the same field semantics.
- [ ] AC 2: Given a new Mail Intelligence queue item with `analysis_status=matched`, when the scheduled service finishes successfully, then opening the item in Neovim shows a factual summary, zero or more allowlisted project candidates, two to five distinct angles, actions, confidence, risks, and adapter-owned provenance without pressing `a`.
- [ ] AC 3: Given an already current valid Mail Intelligence analysis, when the timer reruns, then the provider is not called again and the queue record is not duplicated.
- [ ] AC 4: Given the operator explicitly invokes manual reanalysis, when it succeeds, then the same canonical analysis block is atomically replaced and the prior operator decision is not silently overwritten.
- [ ] AC 5: Given malformed, unsafe, or schema-invalid provider output, when local analysis runs, then the previous valid analysis remains intact or the item stays retryable with a redacted error and non-zero run summary.
- [ ] AC 6: Given an email contains instructions to read files, call tools, change project, or mutate inbox state, when analyzed, then those instructions are ignored as source data, a sentinel outside the allowlisted sandbox is unreadable, and no unauthorized tool, ownership, project, or mutation decision enters the result.
- [ ] AC 7: Given two emails share a subject but have distinct stable IDs, when ContentGlowz analyzes them, then two source-analysis records are correlated by stable source keys rather than subject text.
- [ ] AC 8: Given the same ContentGlowz source is ingested twice, when the second run completes, then it updates/skips the current analysis and creates no duplicate Idea Pool angle rows.
- [ ] AC 9: Given a ContentGlowz per-user source has a configured project and the manual ingest request omits `project_id`, when ingestion runs, then server-side authorization confirms that project belongs to the authenticated user before using its tenant-scoped Project Intelligence context; an unauthorized provided/configured project is rejected without analysis or archive.
- [ ] AC 10: Given BYOK mode without a valid OpenRouter credential, when ContentGlowz analysis runs, then it returns/records the structured runtime error, creates no ideas, and does not archive the source.
- [ ] AC 11: Given a three-email ContentGlowz batch where one source fails analysis, when the batch ends, then successful sources may persist/derive/archive independently while the failed source remains unarchived and retryable.
- [ ] AC 12: Given analysis succeeds but one intended Idea Pool insertion fails, when ContentGlowz handles the source, then no archive occurs until derivation is complete or explicitly skipped, and retry does not duplicate completed angles.
- [ ] AC 13: Given an analysis returns zero useful angles, when it validates as `no_match`, then it is persisted as a successful analysis, creates no Idea Pool row, and follows the configured source-specific archive policy.
- [ ] AC 14: Given logs, journal output, Sentry breadcrumbs/events, and diagnostics from both adapters, when reviewed, then they contain status/count/schema/model/commit/time metadata but no raw body, subject, sender, recipient, source locator, private context, secrets, or model response.
- [ ] AC 15: Given the ContentGlowz Pydantic model changes, when the cross-repo validator runs, then incompatible required fields, enums, or bounds fail before implementation can be verified.
- [ ] AC 16: Given ContentGlowz generation consumes a linked Idea Pool angle, when provenance is inspected, then the source-analysis ID and stable angle ID remain available without exposing the raw source body.
- [ ] AC 17: Given the current Neovim review layout, when enriched analysis is rendered at supported terminal sizes, then text remains readable, navigation/mappings remain stable, and no new visual literals or overlapping UI are introduced.
- [ ] AC 18: Given a provider or scheduler failure in unattended operation, when the operator inspects the documented diagnostic path, then commit, schema version, effective model, UTC/Paris time, counts, and a redacted recovery reason are available.
- [ ] AC 19: Given the implementation diff across ShipGlows, MyNeovim, and ContentGlowz, when reviewed, then no raw/private email fixture, cache, credential, or unrelated dirty change is included.
- [ ] AC 20: Given `gpt-5.4-mini` or the explicit local override is unavailable to the authenticated Codex runtime, when analysis starts, then the run records `model_unavailable`, does not call a fallback model, leaves the source retryable, and preserves any prior valid analysis.

## Test Strategy

- Unit:
  - Canonical JSON Schema valid/invalid fixtures, bounds, enums, stable ID derivation, sanitizer, and prompt-injection pressure cases.
  - MyNeovim queue analysis parsing, atomic update, current-analysis skip, model-unavailable behavior, operator-state preservation, failure preservation, and no-body persistence.
  - ContentGlowz Pydantic schema parity, store uniqueness, project authorization, AI service context/runtime selection, source correlation, and Idea Pool uniqueness.
- Integration:
  - Synthetic Codex structured-output smoke through the local batch adapter.
  - Headless Neovim command registration and fixture-backed review rendering.
  - ContentGlowz authenticated service/scheduler tests with fake IMAP reader, fake structured provider, real temporary DB/migration, and partial archive outcomes.
  - Cross-repo schema parity validator.
- Manual:
  - Run the current local timer/service on a bounded real private source set after synthetic proof.
  - Open the resulting Mail Intelligence review UI and inspect precomputed fields, multiple angles, reanalysis, handoff, and navigation.
  - Inspect redacted journal/Sentry-compatible diagnostics without copying private contents into evidence.
- Regression:
  - Existing Mail Intelligence v1 reader and v2 commands/mappings.
  - Existing ContentGlowz 17-test email/newsletter/context baseline plus full affected service tests.
  - Existing explicit Mail Intelligence Gmail delete/admin behavior remains separate and operator-invoked.

## Risks

- Security impact: Yes, mitigated by untrusted-source prompt boundaries, no-body persistence, tenant scoping, request-scoped provider credentials, structured output validation, redacted observability, bounded context, and no automatic Mail Intelligence mutation.
- Privacy risk: Provider processing receives private email text. Mitigate with explicit local opt-in, bounded text, documented provider/model, no session persistence in batch mode, and no raw diagnostic storage.
- Telemetry risk: Python exception locals, request context, or breadcrumbs can retain email/context data even when default PII collection is disabled. Emit only a dedicated allowlisted failure event and test the final scrubbed Sentry payload.
- Prompt injection risk: Emails may attempt to redirect the agent or exfiltrate readable local files. Mitigate with an OS-level allowlisted filesystem sandbox, a dedicated minimal Codex runtime, a data-delimited analysis prompt, structured schema, adapter-owned IDs/policies, and rejection of model-selected ownership/mutation fields. Codex's read-only sandbox alone is insufficient proof.
- Data loss risk: Current ContentGlowz batch archive can remove failed sources from the active folder. Mitigate with source-specific commit/derivation/archive state.
- Duplication risk: Parallel adapters may drift. Mitigate with one canonical schema, shared fixtures, semantic reference, and cross-repo parity validation before verification.
- Premature abstraction risk: A deployable shared package could create cross-repo release coupling before the contract stabilizes. Keep package extraction out of V1 and revisit after parity evidence.
- Cost/latency risk: Twice-daily automatic analysis can consume model quota and extend service duration. Apply the V1 hard limits of 10 sources, one worker, 24,000 source characters, 48,000 context characters, 32 KiB output, and 180 seconds per call; retain idempotent skips and expose counts/duration.
- Availability risk: Codex or OpenRouter may fail independently. Preserve retryable records and prior valid analysis; never make review/source access depend on provider success.
- Model drift risk: Different providers may produce different useful angles. Preserve provider/model/provenance and validate structure, while treating content quality as a manual proof concern.
- Migration risk: Existing Idea Pool rows lack source-analysis linkage. Keep them valid as legacy unlinked rows and avoid a speculative backfill.
- UI risk: More content can make the Neovim source view noisy. Keep a bounded, scannable Markdown analysis section and existing layout; visual redesign is out of scope.

## Execution Notes

- Read first:
  - `skills/references/source-intake-classification.md`
  - `shipglows_data/workflow/explorations/2026-06-29-mail-source-intake-automation.md`
  - `/home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail/ai.lua`
  - `/home/claude/dotfiles/nvim/MyNeovim/scripts/mail-intake`
  - `/home/claude/contentglowz/lab/agents/sources/ingest.py`
  - `/home/claude/contentglowz/lab/api/services/project_generation_context.py`
  - `/home/claude/contentglowz/lab/api/services/pydantic_ai_runtime.py`
- Implementation order: canonical contract -> parity tooling -> local analyzer/storage -> scheduled integration -> Neovim rendering -> ContentGlowz typed storage/runtime -> idempotent ingestion/archive -> observability/docs -> verification.
- Allowed patterns: JSON Schema Draft supported by local validators, Python standard library plus existing repo dependencies, Pydantic v2 models, existing ContentGlowz runtime/store/migration patterns, `vim.system`, existing Mail Intelligence queue files, and atomic file/database updates.
- Avoid: A new network microservice, Neovim calling ContentGlowz, ContentGlowz reading ShipGlows private cache, direct legacy `llm_simple.chat()` for inbox analysis, regex-only JSON parsing when structured validation exists, prompt-selected IDs/permissions, batch-wide archive, and a new shared package before contract parity.
- Local Codex batch posture: use a bounded synthetic/private payload, `--ephemeral`, `--output-schema`, `--output-last-message`, `--ignore-user-config`, `--ignore-rules`, fixed model/reasoning defaults, temporary working directory, `bubblewrap --clearenv` with allowlisted parent filesystem/environment inputs, and explicit config disabling shell, multi-agent, apps, plugins, web search, and child environment inheritance. No MCP/connectors/repository instructions are loaded. Apply timeout and cleanup; expose neither the normal home nor private repositories/caches/mailboxes/auth to model tools. Never use `--dangerously-bypass-approvals-and-sandbox`.
- ContentGlowz runtime posture: resolve current user mode/credential through `AIRuntimeService`, build bounded project context with provenance, run typed PydanticAI output, and store only normalized analysis.
- Sentry posture: existing server Sentry integration is reused. Capture sanitized exceptions and bounded tags only; no request bodies, source metadata, screenshots, replay, private URLs, or user content.
- Build/diagnostic posture: ContentGlowz `/version` and local analyzer diagnostics must expose commit plus UTC and Europe/Paris build/run timestamps. Do not retain the current hardcoded build date as proof.
- Stop conditions:
  - Canonical schema cannot represent both host policies without host-specific permission fields leaking into model control.
  - ContentGlowz migration cannot enforce user/project/source uniqueness safely.
  - Provider path cannot guarantee structured response capture without dangerous permissions or persistent private sessions.
  - Filesystem isolation cannot prevent an untrusted source from reading a sentinel outside the allowlisted runtime workspace.
  - The authenticated Codex runtime does not expose the configured model and the operator has not explicitly selected a replacement.
  - Any test/log path exposes raw email or project-cache content.
  - A visual Neovim redesign becomes necessary without a declared design-system authority.
  - Current user/concurrent dirty changes materially conflict with required files.
- Validation commands:
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shared-source-analysis-contract-and-email-adapters.md skills/references/source-analysis-contract.md`
  - `python3 tools/validate_source_analysis_contract.py --fixtures tests/fixtures/source-analysis --contentglowz-root /home/claude/contentglowz`
  - MyNeovim focused Python tests, `nvim -u NONE --headless` runtimepath load/command checks, script `--help`, `systemd-analyze --user verify`, and `git diff --check`.
  - ContentGlowz focused pytest for models/store/runtime/ingestion/scheduler/observability plus `git diff --check`.
  - Manual checklist followed by `/103-sg-verify shared source analysis contract and email adapters`.

## Open Questions

None. V1 uses the safe defaults established in this spec: contract-first without a shared deployable package, automatic Mail Intelligence pre-analysis through bounded Codex batch, fixed-project ContentGlowz analysis through its request-scoped runtime, and source-specific archive only after durable completion.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-13 21:00:14 UTC | 100-sg-spec | GPT-5 Codex | Created the cross-project source-analysis contract and email-adapter implementation spec from the existing exploration and current code | draft spec with contract, host policies, ordered tasks, security/data boundaries, and proof path | /101-sg-ready shared source analysis contract and email adapters |
| 2026-07-13 21:19:26 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, user-story fit, task ordering, linked systems, documentation freshness, proof contract, adversarial cases, and security boundaries; resolved deterministic readiness gaps | ready; contract explicitly supersedes only the old Mail Intelligence Task 4 persistence strategy, adds strict proof fields, fixed resource limits, host-owned state/provenance, model-unavailable behavior, and correct parity ordering | /102-sg-start shared source analysis contract and email adapters |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: done, verdict ready.
- `102-sg-start`: not launched.
- `103-sg-verify`: not launched.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: `/102-sg-start shared source analysis contract and email adapters`
