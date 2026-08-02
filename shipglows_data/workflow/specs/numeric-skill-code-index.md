---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-10"
created_at: "2026-06-10 08:09:02 UTC"
updated: "2026-06-10"
updated_at: "2026-06-10 11:04:06 UTC"
status: reviewed
source_skill: sg-build
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'operatrice ShipGlows qui cherche souvent une skill precise dans Claude Code ou Codex, je veux un code numerique comprehensible devant chaque skill sans renommer la skill canonique, afin de retrouver rapidement le bon workflow par memoire et par frequence d'usage."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/references/skill-code-index.md
  - skills/shipglows/SKILL.md
  - skills/sg-help/SKILL.md
  - skills/sg-help/references/help-catalog.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - tools/skill_code_index_lint.py
depends_on:
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.16.0"
    required_status: reviewed
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-06-10: use numeric prefixes only; no symbols beyond the display separator."
  - "User decision 2026-06-10: keep canonical skill names unchanged while adding numeric codes before names for discovery."
  - "User decision 2026-06-10: reserve the 00 family for high-frequency master skills, then group the rest by understandable families."
next_step: "/sg-ship Numeric Skill Code Index"
---

# Spec: Numeric Skill Code Index

## Title

Numeric Skill Code Index

## Status

reviewed

## User Story

En tant qu'operatrice ShipGlows qui cherche souvent une skill precise dans Claude Code ou Codex, je veux un code numerique comprehensible devant chaque skill sans renommer la skill canonique, afin de retrouver rapidement le bon workflow par memoire et par frequence d'usage.

## Minimal Behavior Contract

ShipGlows doit exposer un index canonique `code -> skill` ou les codes sont faciles a memoriser: les codes courts `00-09` couvrent les skills master et les plus frequentes, puis les familles `10`, `20`, `30`, etc. groupent execution, contenu, docs, audit, design, data, pilotage et helpers. Les dossiers de skills, les champs `name:` et les commandes canoniques ne changent pas. Le routeur `shipglows` et l'aide doivent pouvoir expliquer qu'un utilisateur peut demander `01`, `01-sg-build` ou `01sfbuild` comme raccourci de routage vers `sg-build`. Le cas facile a rater est de creer de vrais doublons runtime ou de renommer les skills, ce qui casserait la compatibilite.

## Success Behavior

- Preconditions: les skills ShipGlows existent sous `skills/<name>/SKILL.md`.
- Trigger: l'operatrice consulte l'aide ou donne un code numerique au routeur ShipGlows.
- User/operator result: elle retrouve la skill exacte par un code stable, sans memoriser tout le nom.
- System effect: un index Markdown maintenu et lintable mappe chaque code a une skill canonique.
- Success proof: un linter verifie les doublons de codes, les doublons de skills, les skills manquantes et les references a des dossiers absents.
- Silent success: not allowed; le catalogue doit etre visible dans l'aide et verifiable par commande.

## Error Behavior

- Expected failures: code inconnu, code duplique, skill absente, skill non indexee, code qui pointe vers un dossier inexistant.
- User/operator response: le routeur demande de consulter l'index ou donne la skill canonique quand le code est valide.
- System effect: aucune mutation runtime; le linter echoue en cas de derive.
- Must never happen: renommer `name:`, deplacer des dossiers, creer une deuxieme skill wrapper pour le meme workflow, ou accepter des symboles complexes comme format de code.
- Silent failure: not allowed; toute derive d'index doit etre catchable par `tools/skill_code_index_lint.py`.

## Problem

La liste de skills est longue et certains noms sont proches. Chercher `sg-audit-copywriting`, `sg-local-cloud-sync` ou `sg-conversation-audit` demande trop de frappe et de memoire. Les alias natifs de runtime ne sont pas garantis de la meme maniere entre Claude Code et Codex, donc un renommage ou des wrappers dupliques creeraient de la confusion.

## Solution

Ajouter une couche canonique de decouverte numerique dans `skills/references/skill-code-index.md`, garder tous les noms de skills inchanges, puis documenter la resolution dans `shipglows`, `sg-help`, la cheatsheet et la doc technique. Ajouter un linter standard-library Python pour valider que l'index reste synchronise avec `skills/`.

## Scope In

- Creer l'index numerique canonique des 64 skills actuelles.
- Definir le format de code accepte: deux chiffres, display `NN-skill`, saisie tolerante `NN`, `NN-skill`, `NNskill`.
- Mettre a jour le routeur et l'aide pour charger ou citer l'index.
- Ajouter une validation mecanique de l'index.
- Mettre a jour la documentation technique et la cheatsheet.

## Scope Out

- Renommer les dossiers `skills/*`.
- Modifier les champs frontmatter `name:`.
- Creer des wrappers ou symlinks numeriques runtime.
- Promettre que Claude Code ou Codex invoquent nativement une skill par code sans passer par `shipglows`.
- Changer les descriptions de toutes les skills dans cette passe.

## Constraints

- Le code numerique est une couche de decouverte, pas une nouvelle identite runtime.
- Chaque skill canonique doit avoir exactement un code.
- Chaque code doit pointer vers exactement une skill existante.
- Les codes doivent rester digits-only pour la partie memoire; le tiret n'est qu'un separateur d'affichage.
- Les codes `00-09` sont reserves aux masters et entrees les plus frequentes.

## Dependencies

- Runtime: Markdown et Python standard library.
- Document contracts: `skill-runtime-and-lifecycle.md`, `entrypoint-routing.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`.
- Metadata gaps: aucun.

## Invariants

- Les noms de skills existants restent les seules invocations canoniques.
- Les familles doivent rester comprehensibles sans connaitre la taxonomie interne.
- La frequence d'appel prime sur la famille quand une skill est a la fois master et domaine.
- Les helpers rares ont des codes plus longs a memoriser en pratique car leur prefixe de famille est moins central.

## Links & Consequences

- Upstream systems: `skills/` fournit la liste de skills existantes.
- Downstream systems: `shipglows` et `sg-help` consomment l'index pour orienter l'operatrice.
- Cross-cutting checks: validation de couverture de l'index, coherence docs, pas d'impact securite.

## Documentation Coherence

- `skills/references/skill-code-index.md` devient la source de verite.
- `skills/shipglows/SKILL.md` doit expliquer la resolution des codes.
- `skills/sg-help/SKILL.md` et `skills/sg-help/references/help-catalog.md` doivent pointer vers l'index.
- `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` doit resumer les familles numeriques.
- `shipglows_data/technical/skill-runtime-and-lifecycle.md` et `code-docs-map.md` doivent documenter la surface.
- `CHANGELOG.md` doit mentionner la nouvelle couche de decouverte.

## Edge Cases

- `01` seul doit etre resolvable par contexte vers `sg-build`.
- `01-sg-build` et `01sfbuild` doivent etre compris comme le meme code.
- Un code avec un nom incoherent, par exemple `01-sg-docs`, doit privilegier le code et signaler la mismatch si une implementation stricte est ajoutee plus tard.
- Une future skill ajoutee sans code doit faire echouer le linter.
- Un code reserve sans skill ne doit pas apparaitre comme ligne active dans la table.

## Implementation Tasks

- [x] Task 1: Creer la spec prete
  - File: `shipglows_data/workflow/specs/numeric-skill-code-index.md`
  - Action: Formaliser la decision utilisateur et le perimetre.
  - User story link: Evite de confondre index numerique et renommage runtime.
  - Depends on: None
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/numeric-skill-code-index.md`
  - Notes: None

- [x] Task 2: Ajouter l'index numerique canonique
  - File: `skills/references/skill-code-index.md`
  - Action: Lister les codes, familles, skills et regles de resolution.
  - User story link: Donne la carte de memorisation.
  - Depends on: Task 1
  - Validate with: `python3 tools/skill_code_index_lint.py`
  - Notes: Les `name:` restent inchanges.

- [x] Task 3: Ajouter le linter d'index
  - File: `tools/skill_code_index_lint.py`
  - Action: Verifier unicite des codes, unicite des skills, existence des dossiers et couverture complete.
  - User story link: Evite que la carte numerique derive.
  - Depends on: Task 2
  - Validate with: `python3 tools/skill_code_index_lint.py`
  - Notes: Standard library only.

- [x] Task 4: Mettre a jour le routeur et l'aide
  - File: `skills/shipglows/SKILL.md`, `skills/sg-help/SKILL.md`, `skills/sg-help/references/help-catalog.md`
  - Action: Dire quand charger l'index et comment interpreter `NN`, `NN-skill`, `NNskill`.
  - User story link: Rend les codes utilisables dans la conversation.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "skill-code-index|numeric skill code|01-sg-build|00-shipglows" skills/shipglows/SKILL.md skills/sg-help/SKILL.md skills/sg-help/references/help-catalog.md`
  - Notes: Ne pas dupliquer toute la table dans `SKILL.md`.

- [x] Task 5: Mettre a jour les docs techniques et la cheatsheet
  - File: `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/code-docs-map.md`, `CHANGELOG.md`
  - Action: Documenter la couche de decouverte numerique et sa validation.
  - User story link: Les futurs agents savent ou maintenir les codes.
  - Depends on: Tasks 2-4
  - Validate with: `rg -n "skill-code-index|skill_code_index_lint|00-shipglows|01-sg-build" shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/technical/skill-runtime-and-lifecycle.md shipglows_data/technical/code-docs-map.md CHANGELOG.md`
  - Notes: No public-site category change in this pass.

## Acceptance Criteria

- [x] AC 1: Given l'index, when un agent lit `skills/references/skill-code-index.md`, then chaque skill actuelle a exactement un code.
- [x] AC 2: Given le code `01`, `01-sg-build`, ou `01sfbuild`, when le routeur ShipGlows interprete la demande, then la skill canonique cible est `sg-build`.
- [x] AC 3: Given les dossiers `skills/*`, when `python3 tools/skill_code_index_lint.py` est lance, then les codes et skills sont uniques et couvrent toutes les skills.
- [x] AC 4: Given la doc d'aide, when l'operatrice cherche les codes, then elle voit les familles `00`, `10`, `20`, `30`, `40`, `50`, `60`, `70`.
- [x] AC 5: Given les skills existantes, when on inspecte leurs `name:`, then aucun nom canonique n'a ete modifie pour ajouter un code.

## Test Strategy

- Unit: `python3 tools/skill_code_index_lint.py`.
- Integration: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/numeric-skill-code-index.md skills/references/skill-code-index.md shipglows_data/technical/skill-runtime-and-lifecycle.md shipglows_data/technical/code-docs-map.md`.
- Manual: review top codes for memorability and family fit.

## Test Contract

### Surface

- Stack/surface: docs/skills/tools
- Primary proof mode: mixed
- Proof order (if applicable): contract/linter/metadata

### Manual checklist

- Needed: no
- Checklist path: `shipglows_data/workflow/test-checklists/numeric-skill-code-index.md`
- Required scenario coverage: None
- Exception with proof: linter and metadata checks cover this docs/tooling change.

### Required evidence stack

- Automated / unit / integration checks: `python3 tools/skill_code_index_lint.py`; `python3 tools/shipglows_metadata_lint.py ...`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- Agent-run browser proof: None
- Auth/session proof (`sg-auth-debug`): None
- Contract/integration proof: rg checks named in tasks.
- Provider evidence: None
- Device-native proof: None

## Risks

- Security impact: none, because this adds docs and validation only.
- Product/data/performance risk: Medium discoverability risk if codes feel arbitrary. Mitigation: frequency-first `00-09`, family bands, and linter-backed single source of truth.

## Execution Notes

- Read first: `skills/references/skill-code-index.md` once created, `skills/shipglows/SKILL.md`, `skills/sg-help/SKILL.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`.
- Validate with: commands in Test Strategy.
- Stop conditions: a runtime requires renaming skills, duplicate code pressure appears, or the user rejects frequency-first master codes.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-10 08:09:02 UTC | sg-build | GPT-5 Codex | Created ready spec for numeric skill code index | implemented | /sg-start Numeric Skill Code Index |
| 2026-06-10 08:09:02 UTC | sg-build | GPT-5 Codex | Implemented numeric skill-code index, router/help/docs wiring, and linter validation | implemented | /sg-end Numeric Skill Code Index |
| 2026-06-10 11:04:06 UTC | sg-end | GPT-5 Codex | Closed the chantier after verified implementation, changelog entry, and task tracking alignment | closed | /sg-ship Numeric Skill Code Index |

## Current Chantier Flow

- `sg-spec`: done, ready spec created from user decision.
- `sg-ready`: accepted by direct user approval and bounded ready contract.
- `sg-start`: done, index, linter, router/help/docs updates implemented.
- `sg-verify`: done, focused checks passed.
- `sg-end`: done, chantier closed.
- `sg-ship`: next.

Next step: `/sg-ship Numeric Skill Code Index`
