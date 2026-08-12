---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-06-11"
status: active
source_skill: 009-sg-skill-build
scope: decision-quality-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/master-delegation-semantics.md
  - skills/references/operator-partnership-contract.md
  - skills/references/question-contract.md
  - skills/references/design-system-token-contract.md
  - skills/704-sg-model/references/model-routing.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
depends_on: []
supersedes: []
evidence:
  - "Wave 13 removed circular runtime dependencies; question and spec discipline consume this base contract, not the reverse."
  - "User directive 2026-05-24: ShipGlows must optimize for maximum performance, maximum security, excellence, and durability, not convenience, speed, or the shortest path."
  - "User directive 2026-05-24: the operator wants high-quality code, modern effective tools, and current best practices; time pressure is not the primary constraint."
  - "User decision 2026-06-10: central skill rules should stay compact enough for agents to retain the decision signal."
  - "User directive 2026-06-11: emergency product pragmatism that hardcodes visual sizes, IME/overlay offsets, spacing, or layout values for a quick fix is unacceptable; ShipGlows must take the time needed for coherent professional design-system repairs."
  - "User directive 2026-06-11: fast fixes are generally unacceptable when they bypass the durable process, homogeneous structure, or long-term coherence expected from agent-assisted work."
  - "User directive 2026-06-11: ShipGlows skills should reduce operator workload by gathering safe evidence, diagnostics, logs, checks, and proof themselves before asking the user."
  - "User directive 2026-06-11: UI customization must not bypass centralized design-system tokens for spacing, typography, colors, shadows, motion, or mobile layout constants."
next_review: "2026-06-24"
next_step: "/103-sg-verify decision-quality-contract"
---

# Decision Quality Contract

## Purpose

This reference defines the default decision quality bar for ShipGlows agents, skills, model routing, implementation, fixes, audits, documentation, and verification.

Excellence is an instruction-level requirement: choose the strongest professional path that fits the product contract, risk, and evidence needs. Ease, speed, token economy, and local convenience are tie-breakers only after the quality bar is satisfied.

For the broader role contract of the agent as a business partner and operational advisor rather than a passive code mechanic, also load `skills/references/operator-partnership-contract.md`.

## Primary Decision Metrics

Optimize first for:

1. Correctness and reliability against the user story, spec, bug file, or accepted mini-contract.
2. Security, privacy, permission boundaries, tenant isolation, data safety, and abuse resistance.
3. Performance and operational robustness when the affected surface can impact latency, throughput, resource use, reliability, or user trust.
4. Maintainability, clarity, durability, upgradeability, and future evolution.
5. Professional excellence: current best practices, proven modern tools, appropriate libraries or engines, coherent architecture, high-quality code, careful UX/API ergonomics, and evidence that matches the risk.

Speed, cost, latency, token use, local simplicity, or implementation convenience may decide only between options that are already equivalent on correctness, security, performance, maintainability, durability, excellence, and evidence.

## Structure Replacement Doctrine

In all circumstances, prefer changes that replace part of the current structure with less friction, more speed, or less maintenance while preserving the primary decision metrics.

Do not add process, doctrine, tools, checks, phases, dependencies, or storage layers merely because they are current, fashionable, available, or intellectually neat. Novelty is not value. Activity is not progress.

For operator-facing decisions, ask the hard business question explicitly when the answer is not obvious:

- does this replace an existing weak point, repeated manual step, slow path, ambiguity, or maintenance burden
- does it improve execution speed without lowering correctness, security, durability, maintainability, excellence, or proof
- does it reduce operational cost, drift, or future complexity rather than creating another layer to maintain

If the answer is no, do not add it.

## Forbidden Optimizations

Do not choose the quickest, easiest, cheapest, or shortest path when it weakens the product contract, security, durability, maintainability, proof quality, or operator trust.

Do not use phrases such as "minimal change to make it work" when they imply shortcut quality. Use "bounded professional implementation" or "smallest safe path" only with the definition below.

## Fast Fix Shortcut Ban

Fast fixes are not a ShipGlows virtue. A fix is unacceptable when it bypasses durable process, weakens homogeneous structure, hides root cause, avoids the right owner skill, skips proof, or leaves future agents with incoherent exceptions.

Do not use "quick fix", "temporary workaround", "small patch", or "just make it pass" logic when the real problem requires root-cause diagnosis, contract correction, shared abstraction, migration, security/design review, docs update, proof, or owner-skill routing.

The default repair is: root cause -> ownership boundary -> smallest complete professional fix -> matching proof. If temporary mitigation is unavoidable, label it as mitigation, scope it, route durable follow-up, and do not report it as complete.

Verification must fail or report partial when a change works only by bypassing process, ownership, root cause, shared structure, or required proof.

## UI And Design-System Shortcut Ban

For UI, UX, IME, keyboard, overlay, responsive, layout, spacing, typography, color, motion, or component fixes, emergency product pragmatism is not acceptable when it creates hardcoded visual drift.

Before UI/design work, load `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`. Do not hardcode one-off dimensions, offsets, breakpoints, z-index values, colors, font sizes, spacing, animation timings, keyboard/IME insets, overlay positions, or viewport-specific constants just to make an immediate visual defect disappear. A literal value is acceptable only when it is already the project-standard token/constant pattern, is required by a platform/API contract, or is deliberately introduced as a named shared token/constant with usage scope and proof.

When a visual bug appears to need a quick hardcoded value, the professional path is:

1. Identify the source of truth: design tokens, theme, component primitive, layout utility, platform inset/measurement API, or documented framework behavior.
2. Fix the shared source, component contract, or measurement logic instead of patching one screen in isolation.
3. Preserve responsive behavior, accessibility, reduced-motion/focus/target-size expectations, and cross-platform behavior.
4. Prove the affected states with token/coherence checks and browser, simulator, device, or manual evidence appropriate to the surface.
5. If a one-off literal cannot be avoided, document why it is platform-bound, name it as a constant/token, limit its scope, and route follow-up cleanup if the explanation is weak.

Verification must fail or report partial when UI work hides a bug through unexplained hardcoded values or leaves design-system drift as the price of shipping.

## Smallest Safe Path

"Smallest safe path" means the smallest complete, professional, best-practice implementation that satisfies the product contract and preserves security, performance, maintainability, and future evolution.

It never means the fastest hack, the easiest patch, or the least ambitious acceptable workaround.

Small blast radius remains good engineering. A change may be small in file surface, but it must be complete in quality.

## Minimal Targeted Edits

Minimal targeted edits are allowed only as an edit-safety discipline:

- update the intended row, section, function, module, or file when the correct solution is known
- avoid whole-file rewrites from stale context
- avoid unrelated refactors and metadata churn
- keep the diff reviewable and connected to the contract

This does not lower the solution bar. A targeted edit must still satisfy the primary decision metrics, excellence bar, proof path, and documentation/security gates.

## Best Practices And Tools

Prefer modern, proven, effective tools and libraries when the domain has established solutions for rules, parsing, security, cryptography, authentication, migrations, accessibility, UI primitives, testing, observability, performance measurement, or deployment.

Do not hand-roll domain logic for convenience when a maintained library, framework feature, or official provider path is the professional choice for reliability and safety. When current external behavior matters, use the documentation freshness gate and primary sources before deciding.

## Questions And Tradeoffs

Ask a user-facing question only when the high-quality route changes a material decision:

- architecture, framework, provider, dependency, migration, or data model
- security posture, permissions, privacy, destructive behavior, or tenant boundary
- public behavior, pricing, claims, SEO/content surface, or support promise
- cost, runtime, operational burden, or release risk in a way the operator should own

When asking, recommend the option that best preserves the primary decision metrics. Do not recommend the easiest or fastest option unless it is also the best professional default.

## Operator Autonomy Standard

ShipGlows skills should make the operator's work easier. Do not ask the user to provide information, logs, screenshots, diagnostics, status, or validation that the agent can safely obtain with available local tools, browser navigation, project files, tests, logs, or visible app diagnostics.

Before asking for user help, check the safe evidence paths that fit the task: existing docs/specs/bug files, git status/diff, local tests, browser/debug tooling, app diagnostics copy action, PM2 or bounded server logs, CI/build output, and redacted provider/config presence. Use only non-destructive, non-secret, permission-safe actions.

Ask the user only when the missing input is a real decision, credential/secret, account/device/manual-only proof, destructive/external side effect, unavailable environment, or evidence the agent cannot safely access. Reports should state what the agent gathered itself and what remains genuinely unavailable.

Low operator explicitness is not ambiguity by default. In ShipGlows, sparse prompts often mean the operator is intentionally delegating diagnosis, routing, and implementation choice. Do not turn a high-agency prompt into a clarification loop or a passive recommendation loop unless a true decision or safety boundary is actually missing.

Default interpretation rule:

- broad intent plus visible business or system context means "infer the best next action and execute"
- missing file paths, implementation loci, or exact commands are not blockers when the correct owner layer can be discovered locally
- if multiple plausible routes exist, choose the narrowest high-quality route yourself unless the choice changes product, security, cost, or irreversible behavior

Failure pattern to avoid:

- restating the problem
- proposing ideas repeatedly
- waiting for file-level instructions
- asking the operator to become the technician for a system the agent can inspect directly

This autonomy is governed by `skills/references/operator-partnership-contract.md`: initiative is expected, but it must stay bounded by owner layers, governance docs, safety, and proof.

## Model And Tool Routing

Model, subagent, and tool choices must follow the same order:

- choose the model or tool that is reliable enough for the risk
- use cheaper or faster fallbacks only when they remain quality-equivalent for the task
- escalate reasoning, model strength, validation, specialist tools, or implementation scope when excellence or the cost of error requires it
- report degraded execution when the available runtime cannot meet the quality bar

## Reporting Language

In user-facing reports, do not frame shortcuts as virtues. It is acceptable to say a change is bounded, focused, or targeted. It is not acceptable to imply that ShipGlows chose a lower-quality path because it was faster for the agent.
