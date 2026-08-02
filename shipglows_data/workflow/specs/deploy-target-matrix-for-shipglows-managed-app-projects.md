---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "shipglows"
created: "2026-07-04"
created_at: "2026-07-04 13:13:10 UTC"
updated: "2026-07-16"
updated_at: "2026-07-16 09:29:38 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "deploy-target-governance"
owner: "unknown"
user_story: "As a ShipGlows operator managing web and server projects, I want Vercel to remain the default for compatible web surfaces and a separate governed matrix for dedicated servers, so ShipGlows does not replace the normal web default with server-hosting advice."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/research/codesphere-fit-for-shipglows-workflows.md"
  - "shipglows_data/workflow/research/codesphere-vs-railway-vs-render-vs-flyio-for-shipglows.md"
  - "skills/004-sg-deploy/SKILL.md"
  - "skills/000-shipglows/SKILL.md"
  - "skills/references/entrypoint-routing.md"
  - "shipglows_data/business/business.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/gtm.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Research verdict 2026-07-04: Codesphere is a specialized deploy/runtime target, not a replacement for ShipGlows governance."
  - "Market study verdict 2026-07-04: Railway should be the default recommendation, Render the strongest preview-heavy alternative, Fly.io the advanced-control target, and Codesphere the sovereignty/private-cloud target."
  - "User request 2026-07-04: formalize a deploy target matrix for ShipGlows-managed app projects."
  - "Operator correction 2026-07-16: Vercel is always the default for ordinary websites and compatible web applications; the existing matrix is reserved for genuine dedicated-server needs such as FastAPI."
next_step: "/104-sg-end deploy target matrix for ShipGlows-managed app projects"
---

# Spec: Deploy Target Matrix for ShipGlows-Managed App Projects

## Title

Deploy Target Matrix for ShipGlows-Managed App Projects

## Status

ready

## User Story

As a ShipGlows operator managing web and server projects, I want Vercel to remain the default for compatible web surfaces and a separate governed matrix for dedicated servers, so ShipGlows does not replace the normal web default with server-hosting advice.

## Minimal Behavior Contract

When a ShipGlows-managed project needs hosting guidance, ShipGlows first classifies the deployable surface. An ordinary website or Vercel-compatible web application defaults to Vercel. Railway, Render, Fly.io, and Codesphere are considered only for a genuine dedicated-server surface such as FastAPI, a persistent worker, a custom multi-service runtime, or a constraint incompatible with Vercel. A split architecture is classified per surface: Vercel remains the web default while only the dedicated backend enters the server matrix. The easy-to-miss edge case is treating any use of a database, webhook, authentication, or server function as proof that a separately hosted server is required.

## Success Behavior

- Preconditions: ShipGlows has a managed app project in scope, and the relevant business/product context plus deploy-platform research are available.
- Trigger: an operator asks which deploy target to use, requests deployment guidance, or invokes a deploy/build route that depends on target selection.
- User/operator result: ShipGlows can recommend a default deploy target, explain the recommendation by project type, and preserve clear exceptions for sovereignty, preview-heavy review workflows, or infra-control requirements.
- System effect: ShipGlows gains one canonical matrix and routing rule set that downstream skills and docs can reuse without inventing new platform advice each time.
- Success proof: the spec is implemented into canonical docs and owner skills, the recommendations are consistent across operator entrypoints, and manual routing scenarios produce the expected target recommendation.
- Silent success: not allowed; the chosen target or decision rule must be observable in the report or surfaced guidance.

## Error Behavior

- Expected failures: project traits are under-specified, platform guidance drifts across docs and skills, stale external platform assumptions invalidate a recommendation, or a deploy owner skill routes without a clear target policy.
- User/operator response: ShipGlows asks one precise routing question only when the missing answer changes platform choice materially; otherwise it uses the matrix default and states the exception rule.
- System effect: no target-specific promise, docs change, or deploy-owner route should ship while the canonical matrix is contradictory or unverified.
- Must never happen: ShipGlows presenting one platform as a hidden universal default, claiming support for a target without declared routing/doc proof, or collapsing workflow governance into platform branding.
- Silent failure: not allowed.

## Problem

ShipGlows now has enough evidence to recommend deploy substrates, but today that knowledge lives in research artifacts rather than in a durable execution contract. Without a canonical matrix, different skills and docs can drift into ad hoc platform advice, overfit one platform, or blur the difference between ShipGlows's workflow layer and the runtime platform layer.

## Solution

Create one governed deploy target matrix for ShipGlows-managed app projects as a ShipGlows-owned reference artifact under `skills/references/`. The matrix defines the default recommendation, decision criteria, exception lanes, downstream owner skills, and documentation surfaces that must stay aligned. It keeps ShipGlows platform-agnostic at the workflow layer while allowing strong target-specific recommendations at the deployment layer, while making explicit that ShipGlows only advises and that the final deploy choice still depends on project-specific context.

## Scope In

- Canonical Vercel web default plus a dedicated-server decision matrix for Railway, Render, Fly.io, and Codesphere.
- Project-trait criteria for default and exception routing.
- Owner-skill implications for `004-sg-deploy`, `000-shipglows`, and adjacent public/operator docs.
- Documentation and public-surface alignment rules for deploy target recommendations.
- Validation scenarios that prove recommendation coherence.

## Scope Out

- Full implementation of target-specific deploy automation.
- New CLI integrations, credentials flows, or provider APIs.
- Support for other providers outside Vercel, Railway, Render, Fly.io, and Codesphere in this tranche.
- Repositioning ShipGlows itself around any single hosting platform.

## Constraints

- ShipGlows remains the workflow governor; deploy targets are substrates, not the product center of gravity.
- Platform recommendations must reflect the current ShipGlows audience: solo founders first, then small technical teams.
- Public claims about platform support must stay narrower than true implementation coverage.
- External platform behavior is freshness-sensitive and must be rechecked before readiness or implementation where docs/contracts depend on current provider behavior.
- The matrix is a recommendation reference, not an automatic selector or a guarantee that one target fits every project.
- Final deploy-target choice remains project-contextual and may require owner-skill arbitration when local product, infra, compliance, or workflow constraints dominate the default recommendation.

## Test Contract

- Surface: mixed governance/docs/skill-routing contract.
- Proof profile: advisory policy plus owner-skill/doc alignment; no live provider automation required in this tranche.
- Proof order: static doc/reference checks -> skill/routing coherence checks -> operator-facing scenario review -> docs/public-surface build when touched.
- Automated proof: metadata lint, focused `rg` checks, runtime skill sync checks if skill contracts change, and site/docs build where relevant.
- Manual proof: recommendation scenarios across at least four project archetypes.
- Checklist path: `shipglows_data/workflow/test-checklists/deploy-target-matrix-for-shipglows-managed-app-projects.md`
- Required scenario ids:
  - `DTM-001` ordinary website or compatible web app -> Vercel
  - `DTM-002` dedicated FastAPI or equivalent server -> Railway
  - `DTM-003` dedicated preview-heavy server workflow -> Render
  - `DTM-004` dedicated advanced-topology server -> Fly.io
  - `DTM-005` dedicated sovereignty/private-cloud server -> Codesphere
  - `DTM-006` compatible frontend plus dedicated backend -> split Vercel/server recommendation
- Required results:
  - one default recommendation exists
  - each exception lane can override the default with a documented reason
  - operator-facing routing does not present the matrix as an automatic final decision
  - docs and skills reference one canonical matrix source
- Exception with proof: live provider deployment proof is explicitly out of scope for this spec phase because this tranche governs advice and routing, not real target integrations.

## Dependencies

- `shipglows_data/business/business.md` - audience and business framing.
- `shipglows_data/business/product.md` - scope, user problem, and product principles.
- `shipglows_data/business/gtm.md` - positioning and promise discipline.
- `shipglows_data/workflow/research/codesphere-fit-for-shipglows-workflows.md` - target-specific assessment for Codesphere.
- `shipglows_data/workflow/research/codesphere-vs-railway-vs-render-vs-flyio-for-shipglows.md` - cross-platform comparison and ranking.
- Planned canonical matrix artifact: `skills/references/deploy-target-matrix.md`.
- Fresh external docs: required again before `101-sg-ready` if the implementation writes provider-specific promises into skills, public docs, or deploy contracts.

## Invariants

- ShipGlows must not imply that deploy target selection replaces spec/verify/end/ship governance.
- Default recommendations must remain audience-fit, not infra-maximalist by default.
- Any target-specific route must preserve a fallback path when the target is not suitable for the current project traits.
- One canonical matrix must govern all public and operator-facing target recommendations.
- The matrix must explicitly state that ShipGlows advises and that final selection still depends on project-specific context.

## Links & Consequences

- `004-sg-deploy` may need a target-selection contract or argument model that consumes the reference without pretending to decide in a vacuum.
- `000-shipglows` and `skills/references/entrypoint-routing.md` may need explicit routing language for deploy-target advice.
- `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and any public docs that discuss app deployment may need a platform recommendation section.
- Future deploy playbooks or target-specific docs should derive from the matrix instead of inventing their own ranking.
- If the matrix is absent or stale, operator trust degrades because ShipGlows appears opinionated without a durable basis.

## Documentation Coherence

- Update `README.md` only if deploy target recommendation is part of the public operator story.
- Update `shipglows_data/workflow/playbooks/spec-driven-workflow.md` if deploy substrates become an explicit supported decision lane.
- Update `004-sg-deploy` docs/help/public surfaces if target-aware deploy routing is introduced.
- Add the canonical matrix as `skills/references/deploy-target-matrix.md`, then make every other surface point back to it.
- Public docs must avoid claiming deeper platform automation than actually exists.

## Edge Cases

- A small founder project asks for a platform with strong sovereignty language but does not truly need private cloud; the matrix should avoid over-recommending Codesphere.
- A dedicated-server project has a review-heavy deployment workflow; the server matrix should allow Render to beat Railway without displacing Vercel for compatible web surfaces.
- An infra-complex project values networking, topology, or multi-region control; the matrix should allow Fly.io to win without becoming the default for everyone else.
- A project wants a single recommendation without enough detail; ShipGlows should use the default audience-fit recommendation instead of asking unnecessary questions.
- A future provider docs change weakens a current recommendation; implementation must not hardcode claims that cannot be refreshed.

## Implementation Tasks

- [ ] Task 1: Create the canonical deploy target matrix reference.
  - File: `skills/references/deploy-target-matrix.md`
  - Action: Define the matrix, decision criteria, default ranking, exception lanes, recommendation language, and the explicit "advice only, final choice remains project-contextual" rule.
  - User story link: gives operators one durable decision source instead of repeating ad hoc comparisons.
  - Depends on: none
  - Validate with: metadata lint plus focused `rg` checks for target names, criteria, and default/exception language.
  - Notes: this file is the canonical home; every other surface should reference it rather than duplicating the matrix.

- [ ] Task 2: Align deploy owner routing.
  - File: `skills/004-sg-deploy/SKILL.md` and any minimal skill-local references it relies on.
  - Action: Introduce target-matrix consumption rules for deploy recommendations and target-aware follow-up routing, while preserving project-context arbitration.
  - User story link: ensures deploy advice is consistent when the operator asks ShipGlows to act.
  - Depends on: Task 1
  - Validate with: focused `rg` checks plus metadata lint on changed skill/reference files.
  - Notes: keep the deploy skill owner-pure; do not promise provider automation beyond actual support.

- [ ] Task 3: Align entrypoint guidance.
  - File: `skills/000-shipglows/SKILL.md` and `skills/references/entrypoint-routing.md` if deploy-target advice needs a canonical route.
  - Action: Ensure generic "where should I deploy this app?" questions route to the matrix-backed owner path and make clear that a large project-context delta can still change the final answer.
  - User story link: preserves one coherent answer surface for operators.
  - Depends on: Task 1
  - Validate with: focused routing scenario checks and `rg` verification.
  - Notes: do not duplicate matrix internals inside the router.

- [ ] Task 4: Align public/operator docs.
  - File: `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and any relevant public docs/help surfaces selected during implementation.
  - Action: Add compact target recommendation guidance that points back to the canonical matrix without overstating certainty or implementation depth.
  - User story link: keeps public and operator guidance consistent.
  - Depends on: Task 1
  - Validate with: metadata lint where applicable and docs/site build if public surfaces change.
  - Notes: keep wording disciplined; recommendation clarity matters more than marketing breadth.

- [ ] Task 5: Define proof scenarios.
  - File: `shipglows_data/workflow/test-checklists/deploy-target-matrix-for-shipglows-managed-app-projects.md` if manual proof is needed.
  - Action: Capture manual scenarios for default founder app, preview-heavy app, infra-control app, and sovereignty-sensitive app.
  - User story link: proves the matrix yields consistent recommendations across representative use cases.
  - Depends on: Task 1
  - Validate with: checklist presence and scenario review during verify.
  - Notes: scenario names should match the ranking logic from the research.

## Acceptance Criteria

- [ ] CA 1: Given an ordinary website or Vercel-compatible web application, when hosting is selected, then Vercel is recommended by default without entering the dedicated-server ranking.
- [ ] CA 2: Given a genuine dedicated FastAPI or equivalent server requirement, when the server matrix is consulted, then Railway is recommended by default with a clear rationale.
- [ ] CA 2b: Given a preview-heavy dedicated-server workflow, when the server matrix is consulted, then Render is allowed to outrank Railway with a documented reason.
- [ ] CA 3: Given a project that needs deeper runtime, networking, or topology control, when the matrix is consulted, then Fly.io is recommended without becoming the universal default.
- [ ] CA 4: Given a project that needs sovereignty, private cloud, or institutional hosting posture, when the matrix is consulted, then Codesphere is surfaced as the specialized fit.
- [ ] CA 5: Given an operator asks ShipGlows a generic deploy-target question, when routing occurs, then the answer or handoff is consistent with the canonical matrix rather than ad hoc assistant judgment.
- [ ] CA 5: Given an operator asks ShipGlows a generic deploy-target question, when routing occurs, then the answer or handoff is consistent with the canonical matrix rather than ad hoc assistant judgment, and still states that final choice depends on project context.
- [ ] CA 6: Given public or skill docs mention supported deploy targets, when they are reviewed, then they point to one canonical matrix and do not overclaim platform automation.
- [ ] CA 7: Given the matrix is implemented, when verification runs, then static checks and manual scenario review show coherent recommendations across docs and owner skills.
- [ ] CA 8: Given a compatible web frontend plus a dedicated backend, when hosting is selected, then ShipGlows recommends Vercel for the frontend and applies the server matrix only to the backend.

## Test Strategy

- Static: `rg` checks for target names, default ranking, exception cases, and canonical doc references.
- Metadata: run `python3 tools/shipglows_metadata_lint.py` on the new matrix artifact, updated spec, and any changed skill/docs files.
- Skill/runtime: if skills change, run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipglows_sync_skills.sh --check --all` or bounded equivalents.
- Docs/public build: run the relevant docs/site build if public/help surfaces change.
- Manual scenarios: validate the web/server boundary plus the dedicated-server exception cases defined as `DTM-001` through `DTM-006`.

## Risks

- Freshness risk: provider capabilities and pricing can change, making a static matrix stale. Mitigation: require freshness recheck before readiness/implementation of provider claims.
- Product risk: ShipGlows could drift into platform branding instead of workflow governance. Mitigation: keep the matrix explicitly substrate-oriented.
- Trust risk: public docs may imply support depth that ShipGlows does not actually implement. Mitigation: separate recommendation coverage from automation coverage.
- Routing risk: entrypoint or deploy skills may start duplicating the matrix. Mitigation: one canonical matrix document, with thin references elsewhere.

## Execution Notes

- Read first: `shipglows_data/workflow/research/codesphere-fit-for-shipglows-workflows.md`, `shipglows_data/workflow/research/codesphere-vs-railway-vs-render-vs-flyio-for-shipglows.md`, `skills/004-sg-deploy/SKILL.md`, `skills/000-shipglows/SKILL.md`, `skills/references/entrypoint-routing.md`, and the current public docs that mention deploy or platform positioning.
- Approach: choose the canonical matrix home first, then propagate thin references into deploy/routing/docs surfaces.
- Canonical home is fixed by user decision: `skills/references/deploy-target-matrix.md`.
- Fresh-docs note: provider-specific statements should be rechecked against official docs before `101-sg-ready` if they become normative contract text outside research artifacts.
- Validation order: canonical matrix -> owner skill alignment -> entrypoint guidance -> docs/public surfaces -> static/manual proof.
- Stop conditions: public claims exceed actual support, provider freshness gaps remain unresolved, or downstream owner skill scope becomes ambiguous.

## Open Questions

None. User clarified that Vercel is the web default and that the Railway/Render/Fly.io/Codesphere matrix applies only to genuine dedicated-server needs; final target choice remains project-contextual.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-04 13:13:10 UTC | 100-sg-spec | GPT-5 Codex | Created a durable spec from the Codesphere fit research and the cross-platform market study to formalize a deploy target matrix for ShipGlows-managed app projects. | draft | /101-sg-ready deploy target matrix for ShipGlows-managed app projects |
| 2026-07-04 13:16:49 UTC | 101-sg-ready | GPT-5 Codex | Reviewed the spec for readiness and kept it out of ready state because the canonical matrix artifact home is unresolved, the proof contract is not in the stricter readiness shape, and Task 1 still leaves a material file/location decision open. | not ready | /100-sg-spec deploy target matrix for ShipGlows-managed app projects |
| 2026-07-05 07:24:36 UTC | 100-sg-spec | GPT-5 Codex | Updated the spec after operator clarification: canonical matrix home fixed to `skills/references/`, ShipGlows positioned as advisory only, and final deploy choice made explicitly project-contextual. | reviewed | /101-sg-ready deploy target matrix for ShipGlows-managed app projects |
| 2026-07-05 07:24:36 UTC | 101-sg-ready | GPT-5 Codex | Re-reviewed the spec after the operator clarification and accepted it as ready once the canonical matrix home, advisory scope, and strict proof contract were explicit. | ready | /102-sg-start deploy target matrix for ShipGlows-managed app projects |
| 2026-07-05 07:28:42 UTC | 102-sg-start | GPT-5 Codex | Implemented the canonical deploy-target matrix reference, aligned deploy and router owner surfaces, added compact docs guidance, created the manual checklist, and corrected metadata versioning after lint feedback. | implemented | /103-sg-verify deploy target matrix for ShipGlows-managed app projects |
| 2026-07-05 09:20:21 UTC | 103-sg-verify | GPT-5 Codex | Verified that the invocation path is wired through the router, deploy skill, docs, and canonical reference. Kept the verdict partial because the manual checklist scenarios `DTM-001` to `DTM-004` are defined but not yet executed. | partial | /107-sg-test --preview deploy target matrix for ShipGlows-managed app projects |
| 2026-07-05 09:34:41 UTC | 107-sg-test | GPT-5 Codex | Logged user-provided transcript evidence for checklist scenario `DTM-001`: `000-shipglows` routed the founder CRUD deploy question to `004-sg-deploy`, recommended Railway, and kept the advisory/project-context boundary explicit. Remaining manual scenarios are still unexecuted. | partial | /107-sg-test --preview deploy target matrix for ShipGlows-managed app projects |
| 2026-07-16 09:26:47 UTC | 900-shipglows-core | GPT-5 Codex | Corrected the canonical classification boundary after operator feedback: Vercel is the web default; the existing provider ranking is now explicitly a dedicated-server matrix. | implemented | /103-sg-verify corrected web/server deploy target boundary |
| 2026-07-16 09:29:38 UTC | 103-sg-verify | GPT-5 Codex | Verified all six web, dedicated-server, exception, and split-surface scenarios; metadata lint, generic skill audit, budget audit, runtime owner sync, focused scans, checklist parser, and diff checks passed. | verified | /104-sg-end deploy target matrix for ShipGlows-managed app projects |

## Current Chantier Flow

- `100-sg-spec`: done; draft spec created from the research-backed chantier potentiel.
- `101-sg-ready`: ready; canonical matrix home, advisory scope, and project-context arbitration rule are explicit.
- `102-sg-start`: implemented; canonical matrix reference, owner-skill alignment, docs guidance, checklist, and metadata versioning are in place.
- `103-sg-verify`: verified; all `DTM-001` to `DTM-006` scenarios pass and the prior generic-app Railway proof is superseded.
- `104-sg-end`: pending.
- `005-sg-ship`: pending.

Next step: `/104-sg-end deploy target matrix for ShipGlows-managed app projects`
