---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "shipglows"
created: "2026-06-10"
created_at: "2026-06-10 17:56:56 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:36:35 UTC"
status: draft
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "skill-security-tech-watch"
owner: "Diane"
confidence: "high"
user_story: "En tant qu'operatrice ShipGlows, je veux que les skills de veille, dependances, audit code et maintenance transforment les signaux securite externes en risques priorises avec actions concretes, afin de ne pas perdre les signaux CVE/KEV/vendor-risk dans des listes brutes ou des notes de veille."
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/sg-veille/SKILL.md"
  - "skills/010-sg-technical/references/dependency-audit-playbook.md"
  - "skills/010-sg-technical/references/technical-audit-playbook.md"
  - "skills/sg-check/SKILL.md"
  - "skills/sg-maintain/SKILL.md"
  - "skills/sg-help/references/help-catalog.md"
  - "skills/REFRESH_LOG.md"
  - "shipglows_data/workflow/TASKS.md"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: "active"
supersedes: []
evidence:
  - "User request 2026-06-10: OpenPostern serait hyper utile a ajouter aux skills de codage et veille technologique ShipGlows."
  - "OpenPostern official site checked 2026-06-10: vendor monitoring uses CVE/NVD, CISA KEV, SSL/TLS, DNS, HTTP headers, AI security news, 0-100 score, alerts, and next actions."
  - "BetaList checked 2026-06-10: OpenPostern positions itself as third-party vendor security monitoring with prioritized alerts and risk scores."
  - "NVD official CVE API docs checked 2026-06-10: CVE API exposes JSON REST endpoints, offset pagination, CVE IDs, statuses, tags, CPE filtering, and CVSS filters."
  - "CISA KEV official catalog checked 2026-06-10: catalog is available in CSV/JSON and is intended as an input to vulnerability and patch prioritization."
  - "Existing ShipGlows skills already split ownership: sg-veille handles external source triage, 010-sg-technical deps handles dependency/security posture, 010-sg-technical audit handles code/security review, sg-check handles quick checks, and sg-maintain orchestrates security maintenance through both exact 010 modes."
next_step: "/sg-ready OpenPostern Security Signal Routing For ShipGlows Skills"
---

# Title

OpenPostern Security Signal Routing For ShipGlows Skills

# Status

Draft saved by `sg-spec` on 2026-06-10. The spec is ready for `/sg-ready` review, but implementation must not start until readiness confirms the scope boundaries and validation commands.

# User Story

En tant qu'operatrice ShipGlows, je veux que les skills de veille, dependances, audit code et maintenance transforment les signaux securite externes en risques priorises avec actions concretes, afin de ne pas perdre les signaux CVE/KEV/vendor-risk dans des listes brutes ou des notes de veille.

# Minimal Behavior Contract

Quand un utilisateur fournit une source de veille securite, un outil de vendor-risk, une alerte CVE/KEV, un resultat d'audit dependances, ou une demande de maintenance securite, ShipGlows doit classer le signal selon son exposition reelle, son urgence, sa source, son impact projet et l'action suivante attendue, puis router vers le bon owner (`sg-veille`, `010-sg-technical deps`, `010-sg-technical audit`, `sg-check`, ou `sg-maintain`) sans inventer une certitude d'exploitabilite. En cas de source indisponible, de correspondance package/vendor incertaine, ou d'impact projet non prouve, le rapport doit afficher une confiance limitee et une action de verification plutot qu'un score fort. L'edge case facile a rater est de copier le pattern OpenPostern comme un "score 0-100" pseudo-scientifique alors que ShipGlows doit surtout produire un tri fiable, explicable et actionnable.

# Success Behavior

- Preconditions: un operateur lance `sg-veille` avec une source securite, `$010-sg-technical deps <project>`, `sg-check` avec quick dependency scan, `$010-sg-technical audit <target>` sur une surface sensible, ou `sg-maintain security`.
- Action: la skill identifie les signaux securite disponibles, les relie a un projet ou a un composant quand la preuve existe, classe impact/urgence/confiance, et propose l'owner skill ou le chantier suivant.
- Resultat visible: le rapport ne montre pas seulement une liste de CVE ou d'URLs; il affiche un court "Security Signal Summary" avec source, impact, confiance, priorite, action suivante, et raison.
- Effet systeme attendu: les skills restent dans leurs responsabilites actuelles; `010-sg-technical deps` ne devient pas un scanner vendor SaaS complet, `sg-veille` ne corrige pas du code, `sg-check` reste un quick scan, et `sg-maintain security` orchestre les lanes existantes.
- Preuve de succes: `rg` montre la doctrine partagee dans les skills cibles, les READMEs/help si les promesses publiques changent, et les validations de synchronisation skills passent.

# Error Behavior

- Si NVD, CISA KEV, OpenPostern, une page fournisseur, un audit package-manager, ou une source securite n'est pas accessible, la skill doit dire `source unavailable` ou `fresh-docs gap` et ne pas inventer de score.
- Si une CVE ne peut pas etre reliee a un package, a une version installee, a un fournisseur utilise, ou a une surface exposee, la skill doit classer en `needs mapping` ou `watch`, pas en blocker.
- Si une source externe affirme une exploitation mais que la source primaire officielle ne confirme pas, la skill doit preferer la prudence: mentionner la source secondaire, demander verification primaire, et eviter les claims definitifs.
- Si un signal implique une faille critique, un fournisseur compromis, un secret expose, un auth/data boundary, ou une prod surface, la skill doit produire `Chantier potentiel: oui` ou router vers `sg-maintain security` / `$010-sg-technical deps <project>` / `$010-sg-technical audit <target>` selon l'owner.
- Ce qui ne doit jamais arriver: logguer des secrets, crawler agressivement des fournisseurs, declencher des scans externes intrusifs, classer un risque sans preuve de correspondance, ou modifier les trackers depuis `sg-spec`.

# Problem

ShipGlows sait deja auditer les dependances, verifier du code, analyser des sources de veille et orchestrer de la maintenance. Mais les signaux securite externes restent disperses:

- `sg-veille` peut triager un outil comme OpenPostern, mais ne dispose pas d'un pattern explicite pour transformer des signaux CVE/KEV/vendor-risk en chantier technique.
- `010-sg-technical deps` analyse les packages, supply chain, licences et config, mais son rapport pourrait mieux distinguer CVE brute, exploitation connue, exposition runtime, fournisseur critique et action suivante.
- `010-sg-technical audit` couvre la securite applicative, mais ne formalise pas encore un usage des signaux externes comme contexte de priorisation.
- `sg-check` propose un quick dependency scan, mais doit mieux rappeler quand un signal security quick-scan exige `/010-sg-technical deps <project>`.
- `sg-maintain security` orchestre deja `010-sg-technical deps` et `010-sg-technical audit`; il doit pouvoir integrer un pattern de scoring/action sans creer une nouvelle skill securite.

OpenPostern est une bonne inspiration parce qu'il vend un sujet anxiogene sous une forme simple: sources connues, score lisible, alertes priorisees, prochaines actions, et preuve pour l'assurance cyber. ShipGlows doit reprendre le pattern de decision, pas le produit complet.

# Solution

Ajouter une doctrine "security signal routing" aux skills ShipGlows concernes. Cette doctrine doit expliquer comment convertir un signal externe en classification explicable: source, cible, preuve de correspondance, urgence, impact, confiance, action suivante, owner skill, et besoin eventuel de chantier. Le scoring doit rester ordinal et justifie (`critical/high/medium/low/watch`) plutot qu'un 0-100 opaque, sauf si une source officielle fournit deja un score interpretable.

# Scope In

- Enrichir `sg-veille` pour reconnaitre les sources de veille securite et produire un tri security-tech-watch quand une source parle de CVE, KEV, vendor risk, certificats, DNS, headers HTTP, breach/news security, cyber insurance, ou evidence package.
- Enrichir `010-sg-technical deps` pour expliciter la priorisation CVE/KEV/exposition runtime/action suivante dans ses rapports, sans remplacer les outils d'audit package-manager.
- Enrichir `010-sg-technical audit` pour utiliser les signaux externes comme contexte de priorisation quand une review touche auth, permissions, secrets, data boundaries, headers, deployment config, supply chain ou exploitability.
- Enrichir `sg-check` pour que le quick dependency scan signale clairement quand une alerte ou un audit partiel doit etre escalade vers `/010-sg-technical deps <project>` ou `/sg-maintain security`.
- Enrichir `sg-maintain security` pour integrer le pattern dans sa triage lane, en gardant `010-sg-technical deps` et `010-sg-technical audit` comme owners.
- Ajouter ou mettre a jour la documentation utilisateur si les promesses de ces skills changent: README de skills, help catalog, refresh log, eventuellement public pages de skills si presentes.
- Conserver le backlog `shipglows_data/workflow/TASKS.md` comme reference de la decision, mais ne pas le modifier dans cette spec.

# Scope Out

- Ne pas construire un SaaS vendor-risk ou un clone OpenPostern.
- Ne pas ajouter un crawler actif de certificats, DNS, headers HTTP ou news IA sans spec separee.
- Ne pas appeler automatiquement NVD/CISA/OpenPostern depuis les skills pendant cette premiere tranche; la spec porte sur le routage et la discipline de decision.
- Ne pas produire un score 0-100 ShipGlows opaque.
- Ne pas modifier les projets clients ou leurs trackers depuis cette spec.
- Ne pas faire de claims d'assurance cyber ou de conformite.
- Ne pas remplacer les modes `010-sg-technical deps` et `010-sg-technical audit`, `sg-check`, ou `sg-maintain` par une nouvelle skill securite.

# Constraints

- Respecter le contrat de qualite ShipGlows: exactitude, securite, performance raisonnable, maintenabilite et preuve priment sur vitesse.
- Toutes les sources externes securite qui affectent une decision d'implementation doivent passer par la Documentation Freshness Gate.
- Les sources officielles priment: NVD pour CVE API, CISA pour KEV, docs fournisseur officielles pour avis de securite, package-manager audit pour versions installees.
- Les sources secondaires, startups, blogs, news ou IA peuvent declencher un tri, pas prouver seules une exploitation.
- Le pattern doit rester compact dans les `SKILL.md`; details volumineux doivent aller dans une reference partagee ou skill-local reference si necessaire.
- Les skills source-de-chantier doivent continuer a produire `Chantier potentiel` quand le signal depasse une correction locale.
- Ne pas exposer secrets, tokens, cookies, URLs privees, payloads de logs, ou details exploitables dans les rapports.

# Test Contract

- Surface/stack profile: ShipGlows skills Markdown, references Markdown, README/help docs, no application runtime code expected.
- Automated proof required: `rg` checks for security signal routing language in target skills; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `tools/shipglows_sync_skills.sh --check --all`; metadata lint for the spec.
- Manual proof required: adversarial read of one pressure scenario for each lane (`sg-veille`, `010-sg-technical deps`, `010-sg-technical audit`, `sg-check`, `sg-maintain security`) to confirm the output would be actionable and not overclaiming.
- Documentation proof required: README/help/public-skill surfaces updated only where the skill promise changes.
- Exception policy: no browser/prod proof required because this is a skill/documentation contract, not a web or app runtime change.

# Dependencies

- Local dependencies:
  - `skills/sg-veille/SKILL.md`
  - `skills/010-sg-technical/references/dependency-audit-playbook.md`
  - `skills/010-sg-technical/references/technical-audit-playbook.md`
  - `skills/sg-check/SKILL.md`
  - `skills/sg-maintain/SKILL.md`
  - `skills/sg-help/references/help-catalog.md`
  - `skills/REFRESH_LOG.md`
- Shared references:
  - `skills/references/decision-quality-contract.md`
  - `skills/references/documentation-freshness-gate.md`
  - `skills/references/chantier-tracking.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/operational-record-format.md`
- External docs checked:
  - OpenPostern official site: vendor monitoring, sources, scoring, pricing and evidence-package positioning.
  - BetaList OpenPostern listing: third-party security threats with prioritized alerts and risk scores.
  - NVD official CVE API docs: JSON REST API, pagination, CVE/CPE/status/tag/CVSS query concepts.
  - CISA KEV official catalog: CSV/JSON availability and use as prioritization input.
- Fresh-docs verdict: `fresh-docs checked` for the current spec scope. Implementation must re-check official docs if it introduces live API calls, data schemas, or automated fetching.

# Invariants

- `010-sg-technical deps` remains the owner for dependency vulnerabilities, supply chain, lockfile, package-manager audit, licenses, drift and config.
- `010-sg-technical audit` remains the owner for code correctness, auth, permissions, secrets, data boundaries, architecture and tests.
- `sg-veille` remains a source triage skill; it can route security signals, but it does not fix projects.
- `sg-check` remains a quick confidence pass and must not present dependency quick scans as full security sign-off.
- `sg-maintain security` remains an orchestrator and must not duplicate specialist internals.
- Chantiers remain tracked in `shipglows_data/workflow/specs/`, not in `TASKS.md`.
- External risk claims must include source and confidence.

# Links & Consequences

- `sg-veille` reports may start producing more `Chantier potentiel` blocks for security-oriented sources.
- `010-sg-technical deps` reports may become clearer and more operator-actionable, but must avoid turning every medium CVE into a blocker.
- `010-sg-technical audit` may cite external vulnerability context when assessing code or config risk.
- `sg-check` may more consistently route dependency/security gaps to `/010-sg-technical deps <project>`.
- `sg-maintain security` may provide a better top-level security posture workflow without adding a separate security skill.
- Help docs and public skill pages may need updates if the user-facing promise changes.
- The task previously added to `shipglows_data/workflow/TASKS.md` should be marked done only after implementation and verification.

# Documentation Coherence

- Update `skills/sg-veille/README.md` if `sg-veille` gains explicit security-tech-watch language.
- Update `shipglows-site/src/content/skills/sg-technical.md` if `010-sg-technical deps` gains explicit CVE/KEV/exposure/action-priority language beyond current dependency audit wording.
- Update `skills/sg-check/README.md` if the quick dependency scan escalation rule is user-facing.
- Update `skills/sg-help/references/help-catalog.md` so help output routes security/source-risk questions to the right owner skill.
- Update `skills/REFRESH_LOG.md` with the implemented skill refresh.
- Public site skill pages are in scope only if current ShipGlows docs expose these promises; implementation must search before editing.

# Edge Cases

- A source mentions a CVE but the project does not use the affected package or version.
- A package-manager audit lists a CVE, but the vulnerable code path is dev-only or not runtime reachable.
- CISA KEV lists an exploited vulnerability, but the project only uses a patched version.
- A vendor breach affects a SaaS mentioned in docs, but no project integration exists.
- A source says "AI detected breach news" without primary evidence.
- NVD/CISA sources are temporarily unreachable.
- A security signal is high severity but cannot be acted on by code because the next step is operator/vendor support contact.
- A dependency check runs from workspace root and could accidentally mix projects.
- A report includes evidence that could expose private project details or secrets.

# Implementation Tasks

- [ ] Task 1: Add a compact shared security signal routing doctrine.
  - File: `skills/references/security-signal-routing.md`
  - Action: Create a short reference defining signal types, source trust order, confidence labels, priority labels, owner skill routing, and no-overclaim rules.
  - User story link: Gives every target skill one consistent way to convert security signals into action.
  - Depends on: None.
  - Validate with: `rg -n "source trust|CISA KEV|NVD|owner skill|confidence|Chantier potentiel" skills/references/security-signal-routing.md`
  - Notes: Keep it compact. Do not create a full vulnerability management manual.

- [ ] Task 2: Wire `sg-veille` to security-tech-watch routing.
  - File: `skills/sg-veille/SKILL.md`
  - Action: Add the reference under required references when a source mentions security/vendor-risk signals; update triage behavior to route OpenPostern-like sources to ShipGlows skills or project-local tasks depending on target.
  - User story link: External security veille becomes a decision instead of a raw product note.
  - Depends on: Task 1.
  - Validate with: `rg -n "security-signal-routing|vendor-risk|CVE|KEV|010-sg-technical deps|010-sg-technical audit|sg-maintain security" skills/sg-veille/SKILL.md`
  - Notes: Preserve existing editorial/content gates.

- [ ] Task 3: Wire `010-sg-technical deps` to CVE/KEV/exposure/action prioritization.
  - File: `skills/010-sg-technical/references/dependency-audit-playbook.md`
  - Action: Add the reference and require findings to separate CVE severity, known exploitation, package/version match, runtime exposure, confidence and next action.
  - User story link: Dependency audit results become prioritized operational risk, not just package lists.
  - Depends on: Task 1.
  - Validate with: `rg -n "security-signal-routing|known exploitation|runtime exposure|confidence|next action|CISA KEV" skills/010-sg-technical/references/dependency-audit-playbook.md`
  - Notes: Keep `010-sg-technical deps` owner boundaries intact; do not add live API fetching in this tranche.

- [ ] Task 4: Wire `010-sg-technical audit` to use external security context without replacing code review.
  - File: `skills/010-sg-technical/references/technical-audit-playbook.md`
  - Action: Add the reference under gated references and require the audit to consider verified external signals when reviewing auth, permissions, secrets, deployment config, headers, supply chain or exposed attack surfaces.
  - User story link: Code audits can factor current threat context while still grounding findings in local code.
  - Depends on: Task 1.
  - Validate with: `rg -n "security-signal-routing|external security signals|auth|permissions|secrets|headers|supply chain" skills/010-sg-technical/references/technical-audit-playbook.md`
  - Notes: Do not make `010-sg-technical audit` perform dependency audit internals already owned by `010-sg-technical deps`.

- [ ] Task 5: Wire `sg-check` quick dependency scan escalation.
  - File: `skills/sg-check/SKILL.md`
  - Action: Add a concise rule that quick dependency/security checks summarize only high-level signals and route full analysis to `/010-sg-technical deps <project>` or `/sg-maintain security` when severity/exposure is unclear.
  - User story link: Operators do not mistake quick checks for complete security posture.
  - Depends on: Task 1.
  - Validate with: `rg -n "security-signal-routing|quick dependency|not.*security sign-off|010-sg-technical deps|sg-maintain security" skills/sg-check/SKILL.md`
  - Notes: Preserve existing proportional checks policy.

- [ ] Task 6: Wire `sg-maintain security` orchestration.
  - File: `skills/sg-maintain/SKILL.md`
  - Action: Add security signal routing to the security mode intake so it composes `010-sg-technical deps`, `010-sg-technical audit`, `sg-check`, and `sg-fix` according to owner boundaries.
  - User story link: Maintenance can act on OpenPostern-like signals without inventing a parallel security workflow.
  - Depends on: Tasks 2-5.
  - Validate with: `rg -n "security-signal-routing|security signals|010-sg-technical deps|010-sg-technical audit|sg-check|sg-maintain security" skills/sg-maintain/SKILL.md`
  - Notes: Keep `sg-maintain` as orchestrator only.

- [ ] Task 7: Update user-facing help/docs where promises changed.
  - File: `skills/sg-veille/README.md`, `shipglows-site/src/content/skills/sg-technical.md`, `skills/sg-check/README.md`, `skills/sg-help/references/help-catalog.md`, optional public skill pages if found.
  - Action: Update only the surfaces whose promise changed; avoid duplicating the full reference.
  - User story link: Operators can discover which skill owns a security/source-risk situation.
  - Depends on: Tasks 2-6.
  - Validate with: `rg -n "vendor-risk|CVE|KEV|security signal|sg-maintain security|010-sg-technical deps" skills/sg-veille/README.md shipglows-site/src/content/skills/sg-technical.md skills/sg-check/README.md skills/sg-help/references/help-catalog.md`
  - Notes: If a public page does not exist for a skill, record `not applicable`.

- [ ] Task 8: Record refresh and close tracker after verification.
  - File: `skills/REFRESH_LOG.md`, `shipglows_data/workflow/TASKS.md`
  - Action: Add a compact refresh note and mark the OpenPostern ShipGlows backlog item done only after validation passes.
  - User story link: Durable project state reflects that the security signal routing improvement shipped.
  - Depends on: Tasks 1-7 and validation.
  - Validate with: `rg -n "OpenPostern|security signal|tech-watch-security-skills" skills/REFRESH_LOG.md shipglows_data/workflow/TASKS.md`
  - Notes: Use `sg-tasks` or the implementing owner flow for tracker mutation; this spec does not edit tracker state beyond its own file.

# Acceptance Criteria

- [ ] CA 1: Given an operator runs `sg-veille` on an OpenPostern-like source, when the source is triaged, then the report identifies it as a security-tech-watch signal and routes to content, project backlog, or ShipGlows skill improvement without treating it as a direct project competitor.
- [ ] CA 2: Given `010-sg-technical deps` finds a vulnerability, when the report is produced, then the finding distinguishes CVE severity, known exploitation/KEV status when available, package/version match, runtime exposure, confidence, and next action.
- [ ] CA 3: Given `sg-check` runs a quick dependency scan, when a high/critical or unclear security signal appears, then it explicitly says the quick scan is not a security sign-off and routes to `/010-sg-technical deps <project>` or `/sg-maintain security`.
- [ ] CA 4: Given `010-sg-technical audit` reviews a sensitive code/config surface, when verified external security context is relevant, then it can cite that context while still grounding findings in local code evidence.
- [ ] CA 5: Given `sg-maintain security` is invoked, when security signals are present, then it routes through `010-sg-technical deps` and `010-sg-technical audit` owner lanes instead of creating a separate hidden security workflow.
- [ ] CA 6: Given an external source is unavailable or non-primary, when a skill reports risk, then it records confidence/source limitations and does not invent exploitability.
- [ ] CA 7: Given a signal cannot be mapped to project usage, when the skill reports it, then it labels the item as watch/needs mapping instead of blocker.
- [ ] CA 8: Given validation runs after implementation, when all checks pass, then `skill_budget_audit`, skill sync check, focused `rg` checks, and spec metadata lint produce acceptable output.

# Test Strategy

1. Run focused text checks:
   - `rg -n "security-signal-routing|vendor-risk|CVE|KEV|runtime exposure|confidence" skills/sg-veille/SKILL.md skills/010-sg-technical/references/dependency-audit-playbook.md skills/010-sg-technical/references/technical-audit-playbook.md skills/sg-check/SKILL.md skills/sg-maintain/SKILL.md`
2. Run skill budget audit:
   - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
3. Run skill runtime sync check:
   - `tools/shipglows_sync_skills.sh --check --all`
4. Run metadata lint for this spec:
   - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/openpostern-security-signal-routing-for-shipglows-skills.md`
5. Manual pressure scenarios:
   - `sg-veille`: OpenPostern source triage routes to ShipGlows security-signal spec or project-specific actions.
   - `010-sg-technical deps`: one high CVE with no runtime exposure is not over-prioritized.
   - `010-sg-technical deps`: one KEV-matched installed vulnerable version becomes high/critical with next action.
   - `sg-check`: quick scan explicitly escalates incomplete security proof.
   - `010-sg-technical audit`: external signal informs a code/config finding without replacing local evidence.
   - `sg-maintain security`: routes lanes through owners and names proof gaps.

# Risks

- Overclaim risk: a startup/product pattern could be mistaken for a security authority. Mitigation: source trust order and confidence labels.
- Scope creep risk: implementing live NVD/CISA/vendor monitoring would become a product feature. Mitigation: scope out automated fetching and scanners in this tranche.
- Report noise risk: every medium CVE could become a blocker. Mitigation: require exposure, confidence, and next action.
- Security disclosure risk: reports may include sensitive project or vendor details. Mitigation: redaction and no-secret reporting rules.
- Skill bloat risk: adding too much detail directly to `SKILL.md` can degrade instruction retention. Mitigation: shared compact reference.
- Drift risk: multiple skills may interpret the pattern differently. Mitigation: single shared `security-signal-routing.md`.

# Execution Notes

- Read first:
  - `skills/sg-veille/SKILL.md`
  - `skills/010-sg-technical/references/dependency-audit-playbook.md`
  - `skills/010-sg-technical/references/technical-audit-playbook.md`
  - `skills/sg-check/SKILL.md`
  - `skills/sg-maintain/SKILL.md`
  - `skills/references/decision-quality-contract.md`
  - `skills/references/documentation-freshness-gate.md`
- Implementation approach:
  1. Create the shared compact reference.
  2. Add gated loading/use language to each target skill.
  3. Update README/help surfaces only after the skill promise is stable.
  4. Run focused text checks and budget/sync validation.
  5. Use `sg-tasks`/owner flow to mark backlog done only after verification.
- External docs:
  - `fresh-docs checked` for spec creation using OpenPostern, BetaList, NVD CVE API and CISA KEV catalog.
  - If implementation adds live calls to NVD/CISA/OpenPostern or any scanner, stop and create/update a deeper integration spec.
- Package policy:
  - No new package expected for this tranche.
  - No network API client implementation expected for this tranche.
- Stop conditions:
  - If a target skill has conflicting unshipped edits that make safe patching ambiguous, stop and ask.
  - If budget audit shows the added guidance makes skills too large, move details from `SKILL.md` into the shared reference.
  - If public docs promise automated monitoring, block and revise copy because this spec does not deliver that capability.

# Open Questions

None for this draft. The scope is intentionally limited to ShipGlows skill-routing doctrine, not automated security data ingestion.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 17:56:56 UTC | sg-spec | GPT-5 Codex | Created draft spec from user request to add OpenPostern-inspired vendor-risk/security signal routing to ShipGlows coding and technical veille skills. | draft saved | /sg-ready OpenPostern Security Signal Routing For ShipGlows Skills |

# Current Chantier Flow

| Skill | Status | Notes |
|-------|--------|-------|
| sg-spec | done | Draft spec created with user story, behavior contract, scope, tasks, acceptance criteria, risks and proof path. |
| sg-ready | not started | Must validate scope boundaries, no-overclaim rules, target files and proof plan. |
| sg-start | not started | Should implement only after readiness passes. |
| sg-verify | not started | Should verify skill budget, sync, focused rg checks, metadata lint and pressure scenarios. |
| sg-end | not started | Use if the chantier needs closure bookkeeping. |
| sg-ship | not started | Ship after verify passes and tracker/docs are reconciled. |

Next command: `/sg-ready OpenPostern Security Signal Routing For ShipGlows Skills`
