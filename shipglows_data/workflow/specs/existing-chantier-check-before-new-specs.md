---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-04-30"
created_at: "2026-04-30 22:20:07 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 20:11:48 UTC"
status: draft
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice ShipGlows qui travaille par chantiers spec-first, je veux que les skills verifient d'abord si une spec active couvre deja ma demande avant de creer un nouveau chantier, afin d'eviter la fragmentation des specs, les doublons et la perte de contexte de decision."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-spec/SKILL.md
  - skills/sg-ready/SKILL.md
  - skills/sg-start/SKILL.md
  - skills/references/chantier-tracking.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - specs/
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.4.0"
    required_status: "draft"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Historical migration-source provenance (legacy root documents): BUSINESS.md, GUIDELINES.md, PRODUCT.md."
  - "User concern 2026-04-30: a new spec should not be created when the current work is actually a continuation of an existing chantier."
  - "User decision 2026-04-30: default should be to continue an existing chantier when it covers the same promise; create a new spec only for a genuinely new user story or outcome."
  - "Repo investigation 2026-04-30: chantier-tracking.md already says to identify one spec before writing and stop when ambiguous."
  - "Repo investigation 2026-04-30: sg-spec can create or update specs but does not yet require an explicit Existing Chantier Check before creating a new file."
next_step: "/sg-ready Existing Chantier Check Before New Specs"
---

# Spec: Existing Chantier Check Before New Specs

## Title

Existing Chantier Check Before New Specs

## Status

draft

## User Story

En tant qu'utilisatrice ShipGlows qui travaille par chantiers spec-first, je veux que les skills verifient d'abord si une spec active couvre deja ma demande avant de creer un nouveau chantier, afin d'eviter la fragmentation des specs, les doublons et la perte de contexte de decision.

## Minimal Behavior Contract

Quand une skill lifecycle ou une skill d'orchestration envisage de creer une nouvelle spec, elle doit d'abord chercher les specs existantes proches, comparer la user story, le resultat attendu, les linked systems, les fichiers/surfaces cibles, le statut et le `Current Chantier Flow`, puis choisir clairement entre continuer une spec existante, creer une nouvelle spec, ou demander a l'utilisatrice si plusieurs candidates restent plausibles. Si une spec existante couvre la meme promesse, la skill doit la mettre a jour plutot que creer un doublon; si la demande porte sur une nouvelle promesse ou un resultat autonome, elle peut creer une nouvelle spec. L'edge case facile a rater est de confondre une clarification, extension ou correction d'un chantier actif avec un nouveau chantier parce que le libelle de la demande est different.

## Success Behavior

- Preconditions: le repo contient un dossier `specs/` ou `docs/` avec des specs ShipGlows; une skill recoit une demande pouvant creer ou mettre a jour un chantier.
- Trigger: `sg-spec`, `sg-build`, ou une skill qui route vers `sg-spec` considere qu'un travail non trivial doit etre formalise.
- User/operator result: l'utilisatrice voit que la skill continue le chantier existant quand il est clair, ou recoit une question courte quand plusieurs specs plausibles existent.
- System effect: la spec existante est mise a jour quand elle couvre la meme user story/resultat/surface; une nouvelle spec n'est creee que quand aucun chantier actif ne couvre le besoin; les traces restent dans le bon fichier.
- Success proof: `sg-spec` documente le choix `update existing` ou `create new`; `sg-ready` refuse les specs duplicates evidentes; `sg-start` bloque si la spec active semble contredite par une autre spec couvrant le meme chantier.
- Silent success: acceptable only when exactly one existing chantier matches and the final report nomme la spec continuee.

## Error Behavior

- Expected failures: aucune spec existante, plusieurs specs plausibles, spec ancienne sans frontmatter complet, demande trop vague, continuation vs nouveau chantier incertain, spec existante stale, conflit entre deux specs actives.
- User/operator response: si le choix change le contrat ou la trace de chantier, la skill pose une question de selection au lieu de deviner.
- System effect: aucune nouvelle spec n'est creee quand une candidate existante est plausible mais non tranchee; la skill rapporte `Chantier: non trace` ou route vers clarification si elle ne peut pas identifier une spec unique.
- Must never happen: creer une spec duplicate pour la meme user story, ecrire une trace dans une spec devinee, fusionner deux chantiers distincts sans decision, ou masquer une ambiguite de chantier sous un nouveau titre.
- Silent failure: not allowed; un choix incertain doit etre visible dans le rapport ou dans une question utilisateur.

## Problem

ShipGlows a deja une doctrine de chantier: `specs/` est le registre durable, et les skills doivent tracer dans une spec unique quand elle existe. Mais la creation de spec reste trop facile: un agent peut proposer une nouvelle spec parce qu'un sujet semble nouveau dans la conversation, alors qu'il s'agit en realite d'une clarification ou extension d'une spec active.

Ce probleme fragmente le contexte: plusieurs specs peuvent parler de la meme promesse, les traces de skills se dispersent, `sg-ready` et `sg-start` perdent la vue d'ensemble, et l'utilisatrice doit arbitrer apres coup. C'est particulierement dangereux pour `sg-build`, qui doit rester un cockpit propre et ne pas multiplier les chantiers.

## Solution

Ajouter un `Existing Chantier Check` canonique aux skills qui creent, mettent a jour, readient ou demarrent des specs. Le check compare les specs actives avec la demande courante avant creation, privilegie la continuation d'une spec existante quand elle couvre la meme promesse, et force une question utilisateur quand le choix est ambigu.

## Scope In

- Mettre a jour `skills/sg-spec/SKILL.md` pour executer un `Existing Chantier Check` avant toute creation de nouvelle spec.
- Mettre a jour `skills/sg-ready/SKILL.md` pour signaler une spec qui semble duplicate ou qui devrait continuer un chantier existant.
- Mettre a jour `skills/sg-start/SKILL.md` pour bloquer si une spec ready semble entrer en conflit avec une autre spec active couvrant la meme promesse.
- Mettre a jour `skills/references/chantier-tracking.md` pour formaliser la doctrine "continue existing by default".
- Mettre a jour `shipglows_data/workflow/playbooks/spec-driven-workflow.md` pour documenter la decision nouvelle spec vs continuation.
- Definir les criteres de comparaison: user story, resultat attendu, linked systems, fichiers/surfaces cibles, statut, `next_step`, `Current Chantier Flow`, et evidence.
- Definir la question utilisateur quand plusieurs specs restent plausibles.

## Scope Out

- Fusionner automatiquement des specs existantes.
- Supprimer des specs duplicates historiques.
- Reecrire toutes les anciennes specs pour les normaliser.
- Creer un registre parallele hors `specs/`.
- Implementer un outil de matching semantique avance ou base de donnees de chantiers.
- Remplacer le jugement de l'agent ou de l'utilisatrice par un score automatique.

## Constraints

- Le check doit rester simple, lisible et executable par un agent frais.
- La continuation d'une spec existante est le default quand la meme promesse, le meme resultat, ou les memes linked systems sont clairement couverts.
- Une nouvelle spec exige une justification: nouvelle user story, nouveau resultat autonome, nouveau domaine/surface non couverte, ou ancien chantier clos et hors scope.
- Si plusieurs specs plausibles existent, la skill doit demander une selection explicite.
- Les specs stale ou draft peuvent etre candidates, mais la skill doit signaler leur statut avant de les utiliser comme contrat.
- Aucune trace ne doit etre ecrite dans une spec devinee.
- Les snapshots `TASKS.md` restent informatifs seulement; ils ne decident pas du chantier source de verite.

## Dependencies

- Project contracts: `BUSINESS.md` 1.1.0 reviewed, `PRODUCT.md` 1.1.0 reviewed, `GUIDELINES.md` 1.2.0 reviewed.
- Workflow contracts: `shipglows_data/workflow/playbooks/spec-driven-workflow.md` 0.4.0 draft, `skills/references/chantier-tracking.md` 0.1.0 draft.
- Runtime: markdown specs in `specs/`, `rg`, current filesystem, and lifecycle skill instructions.
- Fresh external docs: fresh-docs not needed. This change is local to ShipGlows markdown workflow doctrine and does not depend on external framework, SDK, API, auth, build, deployment, or integration behavior.

## Invariants

- `specs/` remains the global registry for spec-first chantiers.
- One active chantier should have one durable spec unless a user explicitly decides to split it.
- Lifecycle traces belong in the spec that owns the current chantier.
- Ambiguous matching must stop or ask; it must not create a duplicate just to keep momentum.
- Existing contract sections and history must be preserved when updating a spec.

## Links & Consequences

- `sg-spec`: gains the primary gate before creating new files.
- `sg-ready`: gains an adversarial duplicate/continuation check.
- `sg-start`: uses the check as a final guard before implementation.
- `sg-build`: benefits from the global doctrine but still needs its own orchestration gate.
- `chantier-tracking.md`: becomes stricter about reuse vs creation.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: must teach users and agents that new spec is not the default when a chantier exists.

## Documentation Coherence

- `skills/sg-spec/SKILL.md` must document `Existing Chantier Check` before Step 3 save/create.
- `skills/sg-ready/SKILL.md` must include duplicate/continuation risk in readiness.
- `skills/sg-start/SKILL.md` must route back if the selected spec is not the obvious owner.
- `skills/references/chantier-tracking.md` must add the canonical rule.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md` must explain the decision tree.
- README/help docs are optional for this narrow internal rule unless implementation touches public workflow docs.
- `CHANGELOG.md` is not part of this spec phase; `sg-end` handles it after implementation.

## Edge Cases

- A spec is `ready` but the user asks for a refinement before implementation: update the existing spec and rerun readiness.
- A spec is `closed` but the user asks for a new behavior on the same feature: create a new spec if the outcome is autonomous; otherwise ask whether to reopen/update.
- Two specs touch the same files but different user stories: do not merge automatically; ask only if the current request could belong to either.
- One request spans two active specs: ask whether to split the work or create an umbrella spec.
- The best matching spec lacks modern frontmatter: use it as a candidate but mark metadata migration as part of update or readiness risk.
- A source skill reports `Chantier potentiel` while a matching active spec exists: route to updating that spec, not creating a new one.

## Implementation Tasks

- [ ] Task 1: Add Existing Chantier Check to `sg-spec`
  - File: `skills/sg-spec/SKILL.md`
  - Action: Before creating a new spec path, require scanning active specs and comparing user story, outcome, linked systems, files/surfaces, status, `next_step`, and `Current Chantier Flow`.
  - User story link: Prevents duplicate specs at the point of creation.
  - Depends on: None
  - Validate with: `rg -n "Existing Chantier Check|continue existing|new spec|Current Chantier Flow|linked systems" skills/sg-spec/SKILL.md`
  - Notes: If exactly one existing spec matches, update it; if several match, ask.

- [ ] Task 2: Add duplicate/continuation gate to `sg-ready`
  - File: `skills/sg-ready/SKILL.md`
  - Action: Reject or block readiness when the spec appears to duplicate or fragment an active chantier without explicit justification.
  - User story link: Stops duplicate specs before implementation.
  - Depends on: Task 1
  - Validate with: `rg -n "duplicate|Existing Chantier|continuation|same user story|same linked systems" skills/sg-ready/SKILL.md`
  - Notes: Should be strict only when the overlap is material.

- [ ] Task 3: Add final owner check to `sg-start`
  - File: `skills/sg-start/SKILL.md`
  - Action: Before implementation, verify the selected ready spec is the clear owner of the current request; route back if another active spec appears to own it.
  - User story link: Prevents coding against the wrong chantier.
  - Depends on: Task 2
  - Validate with: `rg -n "Existing Chantier|selected spec|owner|route back|duplicate" skills/sg-start/SKILL.md`
  - Notes: This is a guardrail, not a second spec-writing path.

- [ ] Task 4: Update chantier doctrine
  - File: `skills/references/chantier-tracking.md`
  - Action: Add the canonical rule: default to continuing an existing chantier; create new only when a new user story/outcome is proven; ask if ambiguous.
  - User story link: Makes the rule shared across lifecycle and source skills.
  - Depends on: Task 1
  - Validate with: `rg -n "continue existing|new chantier|ambiguous|duplicate|Existing Chantier" skills/references/chantier-tracking.md`
  - Notes: Preserve existing trace categories and role matrix.

- [ ] Task 5: Update workflow docs
  - File: `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Document the decision tree for update existing vs create new spec.
  - User story link: Makes the behavior understandable to future agents and operators.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "Existing Chantier|continue existing|new spec|same user story|same outcome" shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: Keep this concise and operational.

- [ ] Task 6: Validate no duplicate creation path remains undocumented
  - File: `skills/sg-spec/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/references/chantier-tracking.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Action: Relire comme un agent frais et verify that creation, readiness, and start all preserve the same doctrine.
  - User story link: Ensures the rule is not only documented in one place.
  - Depends on: Tasks 1-5
  - Validate with: `rg -n "Existing Chantier|continue existing|duplicate|new spec|ambiguous" skills/sg-spec/SKILL.md skills/sg-ready/SKILL.md skills/sg-start/SKILL.md skills/references/chantier-tracking.md shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - Notes: Rerun `/sg-ready Existing Chantier Check Before New Specs`.

## Acceptance Criteria

- [ ] AC 1: Given a request matches exactly one active spec by user story/outcome/linked systems, when `sg-spec` runs, then it updates or continues that spec instead of creating a new file.
- [ ] AC 2: Given multiple active specs plausibly match, when `sg-spec` runs, then it asks the user to select or clarify instead of guessing.
- [ ] AC 3: Given no active spec covers the user story or outcome, when `sg-spec` runs, then it creates a new spec with evidence explaining why it is new.
- [ ] AC 4: Given a spec appears duplicate during readiness, when `sg-ready` evaluates it, then readiness fails or blocks with a concrete continuation recommendation.
- [ ] AC 5: Given `sg-start` receives a ready spec but another active spec appears to own the current request, when execution would begin, then `sg-start` routes back instead of coding.
- [ ] AC 6: Given a source skill reports a chantier potential that matches an existing spec, when routed to `sg-spec`, then the existing spec is updated rather than duplicating the chantier.
- [ ] AC 7: Given a closed spec covers the same feature, when the request asks for a new autonomous outcome, then a new spec can be created with explicit justification.

## Test Strategy

- Unit: None, because ShipGlows skills are markdown instruction artifacts without executable unit harness today.
- Static: use `rg` validations listed in tasks.
- Manual scenario 1: run a mental simulation with `sg-build Autonomous Master Skill`; verify a clarification updates the existing spec.
- Manual scenario 2: simulate two plausible specs; verify the skill asks rather than writes.
- Manual scenario 3: simulate no matching spec; verify new spec creation remains allowed.
- Regression: inspect existing trace category rules to ensure source skills still do not write into guessed specs.

## Risks

- Security impact: yes, mitigated by preventing traces and execution from attaching to the wrong chantier, which could otherwise bypass scope, permission, or validation assumptions.
- Workflow risk: medium if the check becomes too heavy; mitigated by using simple file/text comparison and asking only when ambiguity is material.
- Product risk: high if duplicate specs fragment decision history; mitigated by continue-existing default.
- False-positive risk: medium if unrelated specs share files; mitigated by comparing user story/outcome, not files alone.
- Documentation risk: medium if only `sg-spec` is updated; mitigated by also updating readiness, start, doctrine, and workflow docs.

## Execution Notes

- Read first: `skills/sg-spec/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/references/chantier-tracking.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.
- Implement in this order: sg-spec gate, sg-ready gate, sg-start guard, chantier doctrine, workflow docs, final coherence pass.
- Matching heuristic: compare title/slug, user story, minimal behavior, linked systems, files/surfaces, status, `next_step`, `Current Chantier Flow`, and recent `Skill Run History`.
- Stop conditions: multiple candidates with no clear winner, stale spec used as active dependency without review, or proposed new spec with same user story/outcome as an active chantier.
- Packages to avoid: no new package or database; keep the doctrine markdown-first.
- Fresh docs: not needed; local workflow doctrine only.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-30 22:20:07 UTC | sg-spec | GPT-5 Codex | Created spec for Existing Chantier Check before new specs | draft | /sg-ready Existing Chantier Check Before New Specs |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: not launched.
- `sg-start`: not launched.
- `sg-verify`: not launched.
- `sg-end`: not launched.
- `sg-ship`: not launched.

Next step: `/sg-ready Existing Chantier Check Before New Specs`
