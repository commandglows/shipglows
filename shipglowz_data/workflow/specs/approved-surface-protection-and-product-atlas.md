---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlowz"
created: "2026-07-26"
created_at: "2026-07-26 13:21:00 UTC"
updated: "2026-07-26"
updated_at: "2026-07-26 17:01:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "approved-surface-protection-and-product-atlas"
owner: "Diane"
confidence: high
user_story: "En tant qu'operatrice, je veux cartographier les surfaces du produit et proteger independamment leur copywriting, design, structure et comportement, afin que les agents puissent faire evoluer le produit sans degrader ce que j'ai deja approuve."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglowz_data/workflow/explorations/2026-07-26-approved-surface-protection.md"
  - "shipglowz_data/workflow/research/approved-surface-protection-prior-art-2026-07-26.md"
  - "shipglowz_data/business/project-competitors-and-inspirations.md"
  - "skills/references/design-system-token-contract.md"
  - "skills/102-sg-start/SKILL.md"
  - "skills/103-sg-verify/SKILL.md"
  - "skills/106-sg-fix/SKILL.md"
  - "injectors/web-inspector.js"
  - "cli/lib.sh"
  - "/home/claude/best-fried-chicken/shipglowz_data/editorial/public-surface-map.md"
depends_on:
  - artifact: "shipglowz_data/workflow/explorations/2026-07-26-approved-surface-protection.md"
    artifact_version: "1.3.0"
    required_status: draft
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision: build the ShipGlowz-native solution instead of adopting a vendor as product authority."
  - "Operator decision: the cartography must also serve as the roadmap."
  - "Operator decision: copywriting, design and functionality need independent permissions; structure is included to close the gap between design and behavior."
  - "Prior-art review 2026-07-26: Vizzly, Chromatic, Playwright, Applitools, vregt, Lost Pixel, Atlassian and Productboard provide partial primitives but no combined multidimensional atlas."
  - "Local inspection review 2026-07-26: injectors/web-inspector.js selects div elements, copies generated XPath values, and captures element screenshots, but does not emit stable product target IDs or approval context."
next_step: "/102-sg-start Approved Surface Protection And Product Atlas"
---

# Title

Approved Surface Protection And Product Atlas

## Status

Draft — ready for an independent readiness pass after the first registry format and pilot surfaces are confirmed.

## User Story

En tant qu'operatrice ShipGlowz, je veux cartographier les surfaces du produit et proteger independamment leur copywriting, design, structure et comportement, afin que les agents puissent faire evoluer le produit sans degrader ce que j'ai deja approuve.

## Minimal Behavior Contract

Avant toute modification, l'agent declare les surfaces et dimensions potentiellement touchees, consulte leur niveau de stabilite et leur preuve approuvee, puis bloque toute dimension `protected` sans autorisation temporaire explicite ; une autorisation peut ouvrir une seule dimension, tandis que les autres restent des invariants a verifier, et un changement d'environnement qui rend la preuve non reproductible place la dimension en `needs_review` au lieu de renouveler silencieusement sa baseline.

## Inspector Bundle Schema

L'inspecteur copie un seul document JSON, versionne par `format_version`. Les champs structures sont la source de verite ; `agent_prompt_markdown` est genere localement a partir d'eux et sert uniquement de vue de transmission.

Champs obligatoires :

- `format_version` : version du format, actuellement `"1.0"`.
- `captured_at` : horodatage ISO-8601 UTC.
- `target.surface_id` : identifiant canonique de la surface dans l'atlas.
- `target.target_id` : identifiant canonique de la cible dans cette surface.
- `target.route` : route ou URL relative inspectee.
- `target.dimensions` : dimensions concernees, parmi `copy`, `design`, `structure`, `behavior`.
- `selectors.stable` : selecteur semantique fonde sur `data-sg-surface` et/ou `data-sg-target`.
- `reference.commit` : SHA complet si le depot est disponible, sinon `null`.
- `reference.viewport` : largeur, hauteur et device pixel ratio.
- `evidence.local_ref` : reference locale vers la capture ou le manifeste de preuve, sans contenu prive inline.

Champs optionnels : `target.label`, `target.state`, `target.parent_target_id`, `selectors.css_fallback`, `selectors.xpath_fallback`, `reference.context_fingerprint`, `reference.config_fingerprint`, `evidence.screenshot_ref`, `evidence.dom_hash`, `permissions.requested`, `agent_prompt_markdown`.

Exemple minimal :

```json
{
  "format_version": "1.0",
  "captured_at": "2026-07-26T14:46:00Z",
  "target": {
    "surface_id": "marketing.home.hero",
    "target_id": "marketing.home.hero.primary-cta",
    "route": "/",
    "dimensions": ["copy", "design"]
  },
  "selectors": {
    "stable": "[data-sg-target=\"marketing.home.hero.primary-cta\"]",
    "css_fallback": "main section:first-of-type a.cta"
  },
  "reference": {
    "commit": "0123456789abcdef0123456789abcdef01234567",
    "viewport": {"width": 1440, "height": 900, "dpr": 1},
    "context_fingerprint": "sha256:..."
  },
  "evidence": {"local_ref": "evidence/marketing.home.hero.primary-cta.json"},
  "agent_prompt_markdown": "## Cible approuvee\n- Surface: marketing.home.hero\n- Cible: marketing.home.hero.primary-cta\n- Dimensions: copy, design\n- Ne pas modifier: structure, behavior"
}
```

Un bundle sans `surface_id`, `target_id` ou `selectors.stable` peut aider au diagnostic, mais ne peut jamais creer ou renouveler une baseline protegee.

## Success Behavior

- Le produit possede une cartographie hierarchique a identifiants stables qui distingue l'etat de livraison (`planned` a `approved`) et la stabilite (`fluid`, `stable`, `protected`).
- Chaque surface peut proteger independamment `copy`, `design`, `structure` et `behavior`.
- Une approbation conserve un commit Git complet, une empreinte de contexte reproductible, les fichiers et dependances d'impact, les preuves et la decision humaine.
- Le preflight d'execution detecte les impacts directs et indirects avant ecriture et bloque les violations.
- Une permission temporaire ouvre seulement les dimensions explicitement nommees et expire avec la spec ou la tache.
- Le renouvellement met a jour uniquement les dimensions effectivement approuvees ; les autres baselines restent intactes.
- La cartographie expose ce qui existe, ce qui reste a faire, ce qui est protege et les specs associees, devenant une vue roadmap sans remplacer les specs.

## Error Behavior

- Si une surface ou dimension n'est pas identifiable, l'agent bloque avant modification et demande une cartographie ou une décision de portée.
- Si un fichier ou une dépendance partagée peut toucher une dimension `protected`, l'agent bloque même si le fichier de la surface n'est pas directement modifié.
- Si une permission couvre le copywriting mais que le layout doit changer pour faire rentrer le texte, l'agent bloque le design et demande une autorisation séparée.
- Si une baseline ne peut plus être reproduite après une mise à jour de navigateur, police, framework, token ou environnement, la dimension devient `needs_review`.
- Une restauration ne fait jamais de checkout global d'un ancien commit ; elle propose une correction ciblée et vérifie les surfaces dépendantes.

## Problem

Les tests fonctionnels prouvent surtout qu'une action reste possible. Les tests visuels détectent un rendu différent mais ne savent pas si l'ancien rendu était volontairement approuvé. Un commit seul ne capture ni le contexte de rendu, ni les dépendances partagées, ni les permissions dimensionnelles. Il manque donc une autorité unique reliant intention produit, preuve, portée de changement et récupération.

## Solution

Construire un contrat transversal ShipGlowz composé de quatre éléments :

1. un atlas produit hiérarchique et versionné ;
2. un registre de protection par surface et dimension ;
3. un graphe d'impact reliant fichiers, composants, tokens, traductions et surfaces ;
4. un preflight, une preuve et un historique d'approbation intégrés au cycle spec/implementation/verification.

Le commit approuvé reste l'ancre historique, mais la vérité exploitable est un baseline composite. L'atlas reste la source de vérité du produit courant et désiré ; une spec reste le contrat temporaire d'une transformation.

L'inspecteur visuel permet de sélectionner une cible et de copier un bundle de référence relié à l'atlas, au lieu de fournir seulement un XPath fragile. Une cible sans identifiant sémantique stable reste un indice de diagnostic et ne peut pas créer ou renouveler une baseline protégée.

## Scope In

- Modèle canonique d'identifiants de surface et de dimension.
- Etats de livraison et de stabilité indépendants.
- Baseline composite avec SHA, contexte reproductible, preuves, dépendances et note d'approbation.
- Permissions temporaires par dimension, portée, invariants préservés et expiration.
- Graphe d'impact direct et indirect.
- Gate de preflight avant modification et gate de vérification avant livraison.
- Renouvellement dimension par dimension et historique des anciennes baselines.
- Etat `needs_review` après dérive d'environnement.
- Vues atlas/roadmap et liens vers les specs.
- Pilote limité aux cinq à dix surfaces déjà considérées comme excellentes.
- Intégration du navigateur inspector existant comme point d'entrée de ciblage et de capture.

## Scope Out

- Adoption de Vizzly, Chromatic, Applitools ou d'un SaaS comme source de vérité produit.
- Cartographie exhaustive de toutes les surfaces dès la première itération.
- Restauration automatique de fichiers ou d'un dépôt entier depuis un ancien commit.
- Score automatique de beauté ou remplacement de l'approbation humaine par un seuil visuel.
- Nouvelle skill publique dédiée tant que les contrats partagés et les pilotes ne prouvent pas ce besoin.
- Dépendance de l'atlas à un XPath ou à un screenshot sans identifiant sémantique.

## Constraints

- Les dimensions sont `copy`, `design`, `structure`, `behavior` ; `structure` ne doit pas être absorbée par `design` ou `behavior`.
- `protected` est un hard stop, pas un simple warning.
- Une permission n'ouvre jamais implicitement une autre dimension.
- L'implémentation reste `flexible` tant que le résultat approuvé et les preuves restent valides.
- Les preuves visuelles doivent utiliser l'autorité de design-system déclarée et les tokens canoniques ; aucune valeur visuelle locale non justifiée n'est introduite.
- Les snapshots sont des preuves de dérive, pas une décision d'approbation automatique.
- Les identifiants restent stables quand un fichier, un composant ou un libellé change ; les surfaces supprimées passent par `retired`.
- Le selector DOM est une preuve de localisation, jamais l'identité canonique de la surface.
- L'inspecteur est une aide de sélection et de preuve ; il ne décide pas seul qu'une cible est approuvée.
- Les uploads distants, clés API, cookies, stockage local et contenu authentifié sont exclus par défaut de tout bundle copié ou persisté.

## Test Contract

- surface/stack profile: governance cross-surface, web/app agnostic, with browser or golden proof adapters.
- proof_profile: `atlas-protection-v1`.
- automated proof: schema validation, ID uniqueness, permission-scope checks, changed-surface impact report, protected-dimension violation check, baseline-context hash check.
- non-automated proof: operator approval of the initial baseline and of each renewed dimension; visual review on representative viewports/states.
- proof order: registry/schema → impact graph → protected-surface diff → browser/golden evidence → cross-dimension invariants → operator approval → shipment gate.
- checklist_path: `/home/claude/best-fried-chicken/shipglowz_data/workflow/test-checklists/approved-surface-protection-and-product-atlas.md` (created with implementation).
- required_scenario_ids: `ATLAS-001` initial registration, `ATLAS-002` copy-only authorization, `ATLAS-003` protected design hard stop, `ATLAS-004` shared-dependency impact, `ATLAS-005` environment drift to `needs_review`, `ATLAS-006` inspector bundle round-trip, `ATLAS-007` targeted recovery.
- required_results: each scenario records pass/fail, affected surface IDs, dimensions, evidence references, operator decision and any residual risk; any failure blocks readiness or shipment for the affected scope.
- exception-with-proof: a dimension may be `not_applicable` only when the registry records the reason and the readiness/verification evidence confirms it.

## Dependencies

- Git history and full commit SHAs.
- Project design-system authority and token checks.
- Browser or golden-test capture adapter for each declared surface.
- Existing spec, implementation, verification and ship lifecycle gates.
- Official visual-testing prior art is informative only: [Vizzly](https://vizzly.dev/), [Chromatic](https://www.chromatic.com/docs/branching-and-baselines/), [Playwright](https://playwright.dev/docs/test-snapshots).

## Invariants

- A protected dimension cannot change without a matching, explicit authorization.
- `authorized_dimension` is always narrower than or equal to the set of affected dimensions.
- `preserved_dimensions` must have proof after the change, including indirect effects.
- A new approval never deletes the previous approval or baseline.
- A baseline is not valid without its context fingerprint and proof references.
- A copied inspector bundle must contain a stable `surface_id` or `target_id`, selector candidates, route, viewport/state context, commit when available, and a local evidence reference.
- The copied bundle is one JSON document: structured fields are canonical, while `agent_prompt_markdown` is generated from those fields and is never maintained separately.
- A changed shared dependency re-evaluates every dependent protected surface.
- Roadmap status cannot claim `approved` when the corresponding proof is absent.

## Links & Consequences

- `100-sg-spec` requires surfaces, dimensions, permissions and transitions in every relevant spec.
- `101-sg-ready` rejects a spec whose declared change touches a protected dimension without authorization and proof planning.
- `102-sg-start` performs the impact preflight before writing.
- `103-sg-verify` compares protected dimensions and validates cross-dimension invariants.
- `106-sg-fix` uses the baseline history to propose targeted recovery instead of global rollback.
- `005-sg-ship` refuses shipment when a protected-surface violation or unresolved `needs_review` remains.
- The atlas can drive prioritization, but it does not replace `TASKS.md`, `ROADMAP.md` or the transformation spec.
- `108-sg-browser` and the existing `web-inspector.js` provide the browser-side selection/capture adapter; the atlas remains the authority.

## Documentation Coherence

- Document the registry schema, lifecycle states, authorization format and baseline-context fingerprint.
- Add the atlas and protected-surface preflight to the relevant skill references and public operator guidance where appropriate.
- Link each pilot surface to its implementation, evidence and owning spec.
- Update the competitor/inspiration registry when a new external tool materially changes the design.

## Edge Cases

- A shared button or token changes several protected surfaces at once.
- Copy changes alter line wrapping or CTA dimensions without an intentional design change.
- A translation changes text length and affects responsive layout.
- A browser/font/framework update creates a visual diff with no product commit.
- A surface splits into two or two surfaces merge; preserve aliases and history.
- A design-approved change alters loading, error or focus states not visible in the default screenshot.
- A source file contains multiple dimensions and requires targeted rather than whole-file restoration.
- The generated XPath changes after a DOM refactor; the bundle must prefer `data-sg-surface`/`data-sg-target` or a registry ID, with CSS/XPath as diagnostic fallback.
- A selected target is a shared component and affects several protected surfaces.
- The inspector runs on an authenticated page or contains sensitive data; the bundle must be redacted/local-only and upload remains disabled.

## Implementation Tasks

- [ ] Task 1: Define the canonical atlas and protection registry schema.
  - Fichier: `shipglowz_data/workflow/` (canonical registry location to be selected during readiness)
  - Action: define stable IDs, lifecycle, stability, dimensions, approvals, permissions, proof references and aliases.
  - User story link: make approved product intent durable and discoverable.
  - Depends on: none.
  - Validate with: schema examples for site, app, shared component and retired surface.

- [ ] Task 2: Define the baseline-context fingerprint and evidence contract.
  - Fichier: `shipglowz_data/technical/` and shared skill references.
  - Action: record SHA, route/surface, viewport, theme, state, data fixture, browser/device, dependency versions and proof artifacts.
  - User story link: make restoration and comparison reproducible.
  - Depends on: Task 1.
  - Validate with: same-context replay and changed-environment `needs_review` scenario.

- [ ] Task 3: Define the impact graph and changed-surface resolver.
  - Fichier: ShipGlowz-owned tooling and project registry integration.
  - Action: map source files, components, tokens, translations and shared parents to surface IDs and dimensions; report indirect impacts.
  - User story link: prevent silent regressions through shared dependencies.
  - Depends on: Task 1.
  - Validate with: one shared token change affecting multiple protected surfaces.

- [ ] Task 4: Add authorization and preflight contracts to readiness and implementation.
  - Fichier: `skills/101-sg-ready/`, `skills/102-sg-start/`, shared references.
  - Action: require `authorized_dimension`, `preserved_dimensions`, `proof_required` and `expires_with`; hard-stop protected violations.
  - User story link: keep the operator in control of scope.
  - Depends on: Tasks 1–3.
  - Validate with: copy-only authorization that rejects a layout edit.

- [ ] Task 5: Add dimension-specific verification and renewal rules.
  - Fichier: `skills/103-sg-verify/`, `skills/106-sg-fix/`, `skills/005-sg-ship/`.
  - Action: diff each dimension, preserve old baselines, support targeted recovery and block unresolved `needs_review`.
  - User story link: recover quality without destroying later work.
  - Depends on: Tasks 2–4.
  - Validate with: approved design baseline plus independently renewed copy baseline.

- [ ] Task 6: Pilot the atlas on five to ten already-approved surfaces.
  - Fichier: project-owned atlas and evidence/checklist artifacts.
  - Action: register representative site/app sections, shared dependencies and mobile/desktop states.
  - User story link: deliver immediate protection without attempting exhaustive mapping.
  - Depends on: Tasks 1–5.
  - Validate with: operator review, browser/golden proof and one intentional regression.

- [ ] Task 7: Integrate the existing web inspector as a semantic target adapter.
  - Fichier: `injectors/web-inspector.js`, `cli/lib.sh`, project layouts/components and atlas tooling.
  - Action: add stable `data-sg-surface`/`data-sg-target` hooks, copy one JSON target bundle with canonical structured fields plus a generated `agent_prompt_markdown` handoff view, preserve CSS/XPath as fallback selectors, and include route, viewport, state, commit/config context and screenshot evidence references.
  - User story link: let the operator point to exactly what must change without forcing an agent to rediscover the surface boundary.
  - Depends on: Tasks 1–2.
  - Validate with: select a nested target, copy/reload the bundle, resolve it after a harmless DOM refactor, and reject a bundle with no stable ID for baseline creation.

- [ ] Task 8: Harden inspector evidence and privacy boundaries.
  - Fichier: `injectors/web-inspector.js`, inspector injection path in `cli/lib.sh`, inspector documentation/tests.
  - Action: keep local clipboard/download as default, require explicit opt-in for remote upload, avoid exposing credentials or authenticated payloads, and mark inspector injection as development/preview tooling.
  - User story link: preserve trustworthy reference material without leaking private UI data.
  - Depends on: Task 7.
  - Validate with: no-network capture, redaction fixture, disabled-upload path and injected-runtime scope check.

## Acceptance Criteria

- [ ] AC-1: A fresh agent can identify affected surfaces and dimensions before editing.
- [ ] AC-2: A protected dimension without explicit authorization blocks implementation.
- [ ] AC-3: A copy-only authorization preserves and verifies design, structure and behavior.
- [ ] AC-4: Shared dependency changes produce an impact report for all affected protected surfaces.
- [ ] AC-5: An approval stores a full SHA, reproducible context, proof and human decision.
- [ ] AC-6: An environment change creates `needs_review` instead of silently renewing a baseline.
- [ ] AC-7: Renewing one dimension leaves all other baseline references unchanged.
- [ ] AC-8: Targeted recovery never performs a global checkout of the old commit.
- [ ] AC-9: The atlas separates roadmap delivery state from protection state and links each surface to its specs.
- [ ] AC-10: The pilot passes browser/golden, cross-dimension and operator review evidence.
- [ ] AC-11: Inspector selection copies a structured bundle containing a stable atlas ID, selector fallbacks, route/context and evidence references.
- [ ] AC-12: A selector-only bundle cannot create or renew a protected baseline.
- [ ] AC-13: Inspector capture works locally without remote upload and does not persist secrets, cookies, authenticated payloads or raw private screenshots.
- [ ] AC-14: A target bundle remains resolvable after a non-semantic DOM refactor when its stable target ID is preserved.
- [ ] AC-15: The copied target bundle is a single JSON document whose `agent_prompt_markdown` is generated from the canonical structured fields, preventing drift between machine and human handoff formats.

## Test Strategy

- Registry contract tests: schema, IDs, lifecycle transitions, aliases and deduplication.
- Scope tests: direct and indirect impact resolution, protected hard stop, temporary authorization expiry.
- Evidence tests: context fingerprint mismatch, missing proof, `needs_review` transition and dimension-specific renewal.
- Browser/golden tests: representative mobile/desktop themes and default/loading/error/focus states.
- Recovery test: introduce a design regression after a copy-only change and produce a targeted repair proposal.
- Inspector adapter tests: semantic target resolution, selector fallback, bundle round-trip, context capture, no-network privacy mode and remote-upload opt-in guard.
- Documentation checks: metadata lint, diff check and cross-links from lifecycle skills and project governance.

## Risks

- Overly granular mapping could create maintenance burden; mitigate with stable IDs and a five-to-ten-surface pilot.
- Visual snapshots can be noisy; mitigate with deterministic environments and human review, not arbitrary thresholds.
- Shared dependencies can create broad blast radius; mitigate with impact graph and protected-by-default hard stops.
- Multiple dimensions in one file complicate recovery; mitigate with dimension-specific evidence and targeted patches.
- A stale registry can create false confidence; mitigate with verification of changed paths and `needs_review` on environment drift.
- XPath/CSS selectors can become stale; mitigate by making registry IDs authoritative and selectors diagnostic fallbacks.
- The existing inspector loads third-party browser scripts and contains an optional ImgBB upload path; mitigate by limiting injection to development/preview and making local-only evidence the default.

## Execution Notes

- The initial implementation should remain ShipGlowz-native and repository-readable.
- External tools are patterns to learn from, not runtime dependencies.
- The project atlas is the product source of truth; the spec is the temporary transformation contract.
- No new public skill is required for the pilot; extend shared references and existing lifecycle gates first.
- The inspector remains a capture/targeting adapter, not a second product map or approval authority.

## Open Questions

None. Decisions resolved for v1:

- Canonical registry: one project-owned JSON index; Markdown atlas/roadmap views are generated and never edited as a second source of truth.
- Pilot project: `best-fried-chicken` (`/home/claude/best-fried-chicken`). Five representative slots are registered there, each when present — Astro navigation/header, public menu/home hero, Flutter ordering entry/CTA, cart or checkout/payment surface, and order follow-up/help or legal/recovery surface. Each pilot captures desktop and mobile plus default, loading, error and focus states where applicable.
- Context fingerprint: full commit SHA, route, locale, viewport width/height/DPR, browser engine/version, OS/runtime, font asset hashes, design-token version, feature-flag/config hash and deterministic fixture/data-set ID. Unsupported fields are recorded as `null` with a reason, never silently omitted.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-07-26 13:21:00 | 100-sg-spec | GPT-5 Codex | Created the initial contract from the approved-surface exploration and prior-art review; added reproducible baselines, impact graph, temporary permissions, dimension-specific renewal and environment revalidation. | Draft spec created; readiness is still required. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 13:34:00 | 100-sg-spec | GPT-5 Codex | Integrated the existing web inspector as a semantic targeting and evidence adapter; added stable target hooks, structured bundles, selector fallbacks and privacy boundaries. | Draft spec expanded; implementation and readiness remain pending. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 14:46:00 | 100-sg-spec | GPT-5 Codex | Settled the inspector handoff format as one JSON document with canonical structured fields and generated `agent_prompt_markdown`; added the anti-drift invariant and acceptance criterion. | Bundle contract is explicit; implementation and readiness remain pending. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 14:49:00 | 100-sg-spec | GPT-5 Codex | Defined the inspector JSON schema, required/optional fields and a minimal bundle example. | Schema is implementable; implementation and readiness remain pending. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 14:52:00 | 101-sg-ready | GPT-5 Codex | Reviewed structure, user-story fit, proof contract, task ordering, adversarial risks and security boundaries. | Not ready: registry representation, pilot surfaces and reproducible context fields remain unresolved; Test Contract also needs explicit scenario/result fields. | /100-sg-spec Approved Surface Protection And Product Atlas |
| 2026-07-26 16:58:00 | 100-sg-spec | GPT-5 Codex | Resolved readiness blockers: JSON canonical registry with generated views, five pilot surface slots, deterministic context fingerprint fields and explicit proof scenarios/results. | Spec updated for readiness review. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 17:01:00 | 100-sg-spec | GPT-5 Codex | Bound the pilot to the real `best-fried-chicken` project and mapped the five pilot slots across its Astro and Flutter public/ordering surfaces. | Scope is now project-specific; independent readiness review remains required. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-07-26 17:03:00 | 101-sg-ready | GPT-5 Codex | Re-reviewed the resolved contract, explicit proof scenarios, context fingerprint and Best Fried Chicken pilot scope. | Ready: no material ambiguity or unresolved security/proof blocker remains for implementation. | /102-sg-start Approved Surface Protection And Product Atlas |

## Current Chantier Flow

- 100-sg-spec: completed — durable draft created.
- 101-sg-ready: completed — spec ready for implementation on the Best Fried Chicken pilot.
- 102-sg-start: pending.
- 103-sg-verify: pending.
- 104-sg-end: pending.
- 005-sg-ship: pending.
