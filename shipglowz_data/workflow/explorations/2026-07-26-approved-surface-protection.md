---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlowz
created: "2026-07-26"
updated: "2026-07-26"
status: draft
source_skill: 700-sg-explore
scope: "Protection des sections et fonctionnalités approuvées contre les modifications agent non autorisées"
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/
  - skills/100-sg-spec/
  - skills/101-sg-ready/
  - skills/102-sg-start/
  - skills/103-sg-verify/
  - skills/106-sg-fix/
  - skills/108-sg-browser/
  - skills/references/design-system-token-contract.md
  - shipglowz_data/workflow/playbooks/spec-driven-workflow.md
  - shipglowz_data/workflow/research/approved-surface-protection-prior-art-2026-07-26.md
evidence:
  - "Operator report: agents modify site or application areas already considered perfect, with late discovery and costly manual reconstruction."
  - "Operator clarification: copywriting, design and functionality require independent permissions because one dimension may evolve while another remains protected."
  - "Operator decision: protect the user-visible or functional outcome, while internal implementation remains freely refactorable when proof preserves that outcome."
  - "Operator direction: use the same product cartography as a roadmap showing what exists, what remains, and which specifications implement each surface."
  - "Web research 2026-07-26: Vizzly provides approved visual baselines, human review history and agent context, but the consulted documentation does not show a multidimensional product atlas."
  - "Web research 2026-07-26: Chromatic, Playwright and Applitools provide visual baseline and review primitives; Atlassian and Productboard provide roadmap/hierarchy primitives."
  - "Existing design contracts require browser proof and token-drift checks but do not define operator-approved immutable surfaces."
  - "Git HEAD at exploration time: 3acbce04de3524107c182a63a173ff3a8e7c8e08."
depends_on: []
supersedes: []
next_step: "/100-sg-spec approved surface protection contract"
---

# Exploration Report: Approved Surface Protection

## Starting Question

Comment empêcher un agent de modifier silencieusement une section ou une
fonctionnalité que l'opératrice considère déjà comme parfaite, tout en gardant
une référence exacte pour la restaurer si une régression est découverte plus
tard ?

## Context Read

- `CLAUDE.md` - contraintes générales du dépôt et règles critiques.
- `shipglowz_data/technical/context.md` - architecture des skills et points
  d'intégration du workflow.
- `shipglowz_data/workflow/playbooks/spec-driven-workflow.md` - doctrine
  spec-first à laquelle raccorder le garde-fou.
- `skills/006-sg-design/SKILL.md` et ses références de cycle et de preuve -
  propriétaires actuels des changements visuels et de la preuve navigateur.
- `skills/103-sg-verify/SKILL.md` - gates existants de non-régression, dérive de
  design system et preuve.
- `skills/references/design-system-token-contract.md` - autorité actuelle sur
  les tokens, mais pas sur l'intégrité d'une surface approuvée.

## Internet Research

- [Vizzly](https://vizzly.dev/) - baselines visuelles approuvées, historique de
  revue humaine et contexte compact destiné aux agents ; source la plus proche
  du problème initial.
- [Vizzly agent context](https://vizzly.dev/agent-context/) - route, viewport,
  branche, commit, commentaires, diff et décision humaine exposés au prochain
  agent.
- [Chromatic baselines](https://www.chromatic.com/docs/branching-and-baselines/)
  - baselines par story, branches, commits et acceptation explicite.
- [Playwright snapshots](https://playwright.dev/docs/test-snapshots) - captures
  et snapshots texte versionnés dans Git.
- [Atlassian roadmap](https://www.atlassian.com/agile/product-management/roadmaps)
  - lien entre carte produit, epics, exigences et user stories.
- [Productboard hierarchy](https://support.productboard.com/hc/en-us/articles/360058212253-Build-your-product-hierarchy)
  - hiérarchie produit/composant/feature/sous-feature.

La synthèse complète et les limites de chaque précédent sont conservées dans
`shipglowz_data/workflow/research/approved-surface-protection-prior-art-2026-07-26.md`.

## Prior Art Finding

Le marché fournit les deux moitiés séparément :

```text
Vizzly / Chromatic / Playwright / Applitools
    → baseline visuelle + approbation + historique agent

Atlassian / Productboard / story maps
    → hiérarchie produit + roadmap + delivery links

ShipGlowz
    → doit relier les deux et ajouter copy/design/structure/behavior
```

Vizzly est la piste à évaluer en premier pour éviter de reconstruire une
infrastructure de visual review déjà existante. Il ne remplace pas l'atlas :
son unité principale est la comparaison visuelle, pas la capacité produit ni
la permission éditoriale ou fonctionnelle.

## Problem Framing

Les tests fonctionnels prouvent qu'une action reste possible. Les snapshots ou
tests visuels peuvent prouver qu'un rendu a changé. Aucun de ces mécanismes ne
peut décider seul que l'état précédent était subjectivement excellent et devait
rester intact.

Le problème est donc composé de cinq besoins distincts :

1. cartographier les surfaces produit avec des identifiants stables ;
2. séparer les dimensions éditoriale, visuelle, structurelle et fonctionnelle ;
3. enregistrer une approbation explicite de l'opératrice par dimension ;
4. bloquer les mutations non autorisées avant qu'elles soient implémentées ;
5. garder une référence récupérable et une preuve adaptée à chaque dimension.

Le terme recommandé est `operator-approved` ou `protected`, plutôt que
`perfect`. `Perfect` exprime correctement le ressenti, mais `approved` produit
un état de workflow testable : qui a approuvé quoi, dans quel contexte, et
quelles modifications restent permises.

## Option Space

### Option A: Commit Pin Only

- Summary: enregistrer pour chaque section le commit où elle était parfaite.
- Pros:
  - simple à comprendre ;
  - référence Git immuable si le SHA complet est conservé ;
  - permet `git show <sha>:<path>` et un diff historique.
- Cons:
  - une section dépend souvent de plusieurs composants, tokens, assets et
    layouts partagés ;
  - le commit représente tout le dépôt, pas la frontière logique de la
    section ;
  - ne détecte ni ne bloque la modification au moment où elle arrive ;
  - restaurer directement un vieux fichier peut casser les contrats actuels ;
  - ne capture pas les breakpoints, thèmes, états interactifs ou données de
    démonstration nécessaires pour reproduire le rendu.

### Option B: Visual Snapshot Protection Only

- Summary: capturer des screenshots ou golden tests et faire échouer les diffs.
- Pros:
  - détecte un changement visible ;
  - couvre mieux la beauté perçue que les tests fonctionnels ;
  - se prête à plusieurs viewports, thèmes et états.
- Cons:
  - bruit possible lié aux polices, animations, données et moteurs de rendu ;
  - un seuil automatique peut rater une petite régression importante ou
    bloquer un changement sans importance ;
  - ne protège pas les comportements invisibles ni l'architecture de la
    section ;
  - l'image seule ne permet pas de reconstruire proprement le code.

### Option C: Approved Surface Contract

- Summary: combiner une cartographie hiérarchique, un état de protection, un
  commit de référence, un manifeste de dépendances et une preuve visuelle.
- Pros:
  - empêche la mutation avant implementation ;
  - rend l'intention opératrice explicite et durable ;
  - permet une restauration ciblée et informée ;
  - combine code, comportement, design et contexte de rendu ;
  - peut aussi alimenter une vue roadmap.
- Cons:
  - nécessite une discipline de maintenance ;
  - demande un petit outillage pour relier les fichiers modifiés aux surfaces ;
  - les composants partagés créent des dépendances entre plusieurs surfaces ;
  - une cartographie exhaustive créée d'un coup deviendrait vite obsolète.

## Comparison

| Critère | Commit seul | Snapshots seuls | Contrat de surface |
| --- | --- | --- | --- |
| Bloque avant modification | non | généralement non | oui |
| Référence de code | partielle | non | oui |
| Référence visuelle | non | oui | oui |
| Autorité humaine explicite | faible | moyenne | forte |
| Restauration ciblée | fragile | impossible | prévue |
| Coût de maintenance | faible | moyen | moyen |
| Sert de cartographie/roadmap | faible | faible | oui |

## Emerging Recommendation

Adopter l'option C et conserver l'idée du commit pin comme l'une de ses briques.

### 1. Un registre hiérarchique de surfaces

Chaque surface reçoit un identifiant stable, indépendamment du nom actuel des
fichiers :

```text
site
├── home
│   ├── hero
│   ├── social-proof
│   └── pricing-preview
└── pricing
    ├── plan-cards
    └── faq

app
├── onboarding
│   ├── welcome
│   └── first-project
└── editor
    ├── toolbar
    └── document-canvas
```

Champs minimaux recommandés :

```yaml
id: site.home.hero
label: Home / Hero
kind: section
delivery_status: shipped
protection:
  copy:
    lifecycle: approved
    outcome: stable
    implementation: flexible
    baseline_commit: <copy-full-sha>
  design:
    lifecycle: approved
    outcome: protected
    implementation: flexible
    baseline_commit: <design-full-sha>
  structure:
    lifecycle: approved
    outcome: protected
    implementation: flexible
    baseline_commit: <structure-full-sha>
  behavior:
    lifecycle: approved
    outcome: protected
    implementation: flexible
    baseline_commit: <behavior-full-sha>
roadmap:
  priority: high
  target_release: current
  spec_refs:
    - <spec-id>
source_scope:
  - site/src/components/Hero.astro
  - site/src/styles/hero.css
dependencies:
  - component: ui.primary-button
  - token_group: marketing.hero
visual_baselines:
  - viewport: 390x844
    theme: light
    state: default
  - viewport: 1440x1000
    theme: light
    state: default
allowed_changes:
  - dimension: copy
    scope: "CTA label only"
notes: "Composition, rythme, contraste et CTA approuvés."
```

La cartographie peut servir de roadmap, mais les deux notions doivent rester
séparées dans le modèle :

- `delivery_status`: planned, in-progress, shipped ;
- `stability_status`: fluid, stable, protected.

Une section peut être expédiée sans être protégée, ou protégée tout en ayant une
évolution volontaire planifiée.

### 2. L'atlas comme roadmap produit

La carte devient la vue durable de l'état du produit :

```text
                    ATLAS PRODUIT
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼
     Ce qui existe   Ce qui reste     Ce qui est protégé
                          │
                          ▼
                    Specs à réaliser
```

La carte et les specs ne doivent cependant pas fusionner :

| Artefact | Question à laquelle il répond |
| --- | --- |
| Atlas produit | Qu'est-ce qui existe, manque, est vérifié ou approuvé ? |
| Spec | Quel changement précis fera évoluer ces surfaces ? |
| Tracker d'exécution | Sur quoi travaille-t-on maintenant ? |
| Code et preuves | L'état annoncé est-il réellement démontré ? |

L'atlas est la source de vérité du **produit courant et désiré**. Une spec est
un contrat temporaire de transformation. Elle référence les identifiants des
surfaces et dimensions concernées, puis l'exécution fait progresser leur état.

Cycle recommandé :

```text
Atlas : behavior=planned
          │
          ▼
Spec liée à site.pricing.checkout / behavior
          │
          ▼
Implémentation : behavior=implemented
          │
          ▼
Tests : behavior=verified
          │
          ▼
Validation opératrice : behavior=approved + outcome=protected
```

L'atlas peut aussi déclencher le travail dans l'autre sens :

```text
Filtre "planned ou specified"
          ↓
Surfaces restantes
          ↓
Priorisation
          ↓
Création ou reprise des specs liées
```

Il devient donc possible de répondre sans parcourir les anciens commits ou
specs :

- quelles pages et fonctionnalités existent ;
- quelles dimensions sont encore absentes ou incomplètes ;
- ce qui est seulement implémenté versus réellement vérifié ;
- ce que l'opératrice a approuvé ;
- ce qu'un agent n'a pas le droit d'altérer ;
- quelle spec explique chaque évolution passée ou à venir.

### 3. Un cycle de maturité distinct de la protection

Chaque dimension porte un état de réalisation :

```text
planned → specified → in_progress → implemented → verified → approved
```

États latéraux possibles :

- `deferred` : intention conservée mais non priorisée ;
- `retired` : surface ou comportement volontairement retiré ;
- `not_applicable` : dimension sans sens pour cette surface.

Ces états ne doivent pas être réduits à `todo/done`. Une fonctionnalité
implémentée mais non vérifiée n'est pas au même niveau qu'une fonctionnalité
approuvée. De même, `approved` ne signifie pas automatiquement `protected` :
l'opératrice peut considérer le résultat bon tout en autorisant son évolution.

La protection constitue un second axe :

```text
lifecycle: approved
outcome: protected
implementation: flexible
```

Cette combinaison exprime la décision opératrice retenue : le résultat compte,
pas la manière dont l'agent organise le code en coulisses.

### 4. Une matrice de protection par dimension

La protection appartient à une dimension de la surface, pas à la surface
entière :

| Dimension | Couvre | Baseline principale |
| --- | --- | --- |
| `copy` | titres, CTA, microcopy, claims, ton, ordre argumentaire | texte approuvé, règles éditoriales, SHA |
| `design` | composition, couleurs, typographie, espacements, responsive, mouvement | captures/goldens, tokens, SHA |
| `structure` | ordre des sections, hiérarchie, navigation, type de composant, architecture de l'information | arbre de surface, DOM/widget structurel, SHA |
| `behavior` | actions, validations, états, transitions, données, erreurs | scénarios et tests fonctionnels, SHA |

La quatrième dimension `structure` est recommandée car elle évite un trou entre
design et fonctionnalité. Remplacer un accordéon par des onglets peut préserver
le texte, rester esthétique et continuer à fonctionner, tout en changeant
fortement le modèle d'interaction et l'architecture de l'information.

Exemple :

```text
site.home.hero

copy       stable       → modification explicite permise avec preuve
design     protected    → aucune modification visuelle
structure  protected    → aucun déplacement ou changement de composition
behavior   protected    → CTA et navigation inchangés
```

Chaque dimension garde sa propre approbation et son propre commit de référence.
Si le texte est amélioré au commit B, le baseline copy passe de A à B, mais les
baselines design, structure et behavior peuvent rester ancrées au commit A.

Cela interdit de traiter le commit comme une version monolithique de la surface.
La restauration doit extraire l'intention de la dimension concernée, pas
restaurer aveuglément le fichier complet, car un même fichier mélange souvent
texte, markup, styles et comportement.

### 5. Trois niveaux de stabilité par dimension

- `fluid` : l'agent peut modifier dans le périmètre normal de la tâche.
- `stable` : modification permise seulement si la tâche la nomme explicitement,
  avec preuve avant/après.
- `protected` : arrêt bloquant. Une autorisation explicite de l'opératrice est
  requise avant tout changement direct ou indirect.

Le niveau `protected` doit être un hard stop, pas un avertissement. Un warning
est trop facile à ignorer sous pression et ne résout pas le problème exprimé.

### 6. Une autorisation n'ouvre qu'une dimension

Autoriser le copywriting ne doit jamais être interprété comme une permission de
retoucher le layout pour faire rentrer le nouveau texte. L'autorisation nomme :

- la dimension ouverte ;
- l'intention exacte ;
- les autres dimensions à préserver ;
- les preuves croisées nécessaires ;
- la durée de validité.

```yaml
surface: site.home.hero
authorization:
  dimension: copy
  change: "Améliorer le CTA principal"
  preserve:
    design: protected
    structure: protected
    behavior: protected
  proof:
    - copy review
    - mobile layout no-regression
    - desktop layout no-regression
  expires_with: <task-or-spec-id>
```

### 7. Les dimensions restent interdépendantes

La permission est indépendante, mais la preuve ne l'est pas :

```text
Changement copy
   ├── preuve éditoriale
   ├── contrôle design : retours à la ligne, hauteur, rythme
   └── contrôle behavior : CTA et destination inchangés

Changement design
   ├── preuve visuelle
   ├── contrôle copy : texte et hiérarchie sémantique inchangés
   └── contrôle behavior : cibles, focus et actions inchangés

Changement behavior
   ├── preuve fonctionnelle
   ├── contrôle design : états loading/error/success cohérents
   └── contrôle copy : messages et promesses non altérés
```

Le modèle doit donc distinguer :

- `authorized_dimension` : ce que l'agent peut intentionnellement modifier ;
- `preserved_dimensions` : les invariants qui doivent rester vrais ;
- `cross_dimension_proof` : les contrôles requis à cause des effets indirects.

### 8. Un baseline composite par dimension

Le SHA complet reste l'ancre historique, mais l'approbation doit aussi contenir :

- la liste des fichiers et composants directement concernés ;
- les dépendances partagées importantes : tokens, layout, composants parents ;
- des captures déterministes pour les viewports, thèmes et états importants ;
- les comportements à préserver ;
- les changements encore permis, par exemple texte uniquement ;
- une note courte expliquant ce qui est jugé réussi.

Pour le web, les preuves peuvent être des screenshots Playwright par surface.
Pour Flutter, des golden tests peuvent jouer le même rôle. Ces tests détectent
la dérive ; ils ne remplacent pas l'approbation humaine d'une nouvelle baseline.

Les preuves adaptées sont différentes :

- copy : diff textuel, claims, ton, terminologie, traduction éventuelle ;
- design : screenshots/goldens, tokens, responsive, thèmes ;
- structure : arbre de sections, ordre, rôles sémantiques, navigation ;
- behavior : scénarios, tests, états et contrats d'erreur.

### 9. Une gate d'impact avant modification

Avant d'écrire, l'agent doit :

1. déclarer les surfaces visées par la tâche ;
2. calculer les surfaces potentiellement touchées par les fichiers et
   dépendances partagées ;
3. déterminer les dimensions potentiellement affectées ;
4. lire leur état de stabilité et leur baseline indépendante ;
5. s'arrêter si une dimension `protected` est affectée sans autorisation ;
6. inscrire les dimensions autorisées et préservées dans le contrat
   d'exécution.

Cette gate protège aussi les modifications indirectes. Changer un bouton
partagé, un token global, une traduction ou un layout parent peut affecter dix
surfaces et plusieurs dimensions sans toucher leurs fichiers locaux.

### 10. Une autorisation de changement bornée

Le déverrouillage ne doit pas supprimer la protection. Il crée une permission
temporaire :

```yaml
surface: site.home.hero
authorized_dimension: copy
authorized_change: "Remplacer le texte du CTA"
preserved_dimensions:
  - design
  - structure
  - behavior
baseline_before: <copy-approval-id>
proof_required:
  - copy review
  - mobile screenshot
  - desktop screenshot
expires_with: <task-or-spec-id>
```

Après validation :

- si l'ancien rendu reste la référence, la protection revient inchangée ;
- si le nouveau texte est approuvé, seule la baseline copy est renouvelée ;
- une autre dimension n'est renouvelée que si son changement était lui aussi
  explicitement autorisé et approuvé ;
- toutes les anciennes baselines restent dans l'historique.

### 11. Une récupération qui ne restaure jamais tout le vieux commit

En cas de régression tardive, l'agent doit :

1. comparer l'état courant au baseline approuvé ;
2. afficher les écarts de code, dépendances et rendu ;
3. identifier le premier commit qui a introduit la dérive si possible ;
4. proposer une restauration ciblée adaptée à l'architecture actuelle ;
5. vérifier les autres surfaces dépendantes.

Un checkout global du commit approuvé est interdit : il écraserait les progrès
postérieurs et pourrait restaurer une ancienne copy en voulant seulement
récupérer le design. Le vieux commit est une source de vérité de comparaison,
pas une commande de rollback aveugle.

### 12. Intégration recommandée aux skills existants

Éviter de créer immédiatement une nouvelle skill publique. Le besoin est un
contrat transversal :

- design : cartographie, approbation et renouvellement des baselines ;
- contenu/copywriting : approbation éditoriale et preuve des claims ;
- exploration/priorisation : lecture des surfaces `planned`, `specified` ou
  incomplètes comme backlog produit structuré ;
- spec/readiness : liste obligatoire des surfaces, dimensions touchées,
  permissions, transitions de maturité et invariants croisés ;
- implementation/fix : preflight bloquant et scope fence ;
- browser/auth proof : captures reproductibles ;
- verification : diff des surfaces protégées et refus des changements non
  autorisés ;
- ship : interdiction d'expédier une violation de protection.

Une spec doit déclarer explicitement :

```yaml
surface_changes:
  - id: app.editor.export
    dimensions:
      behavior:
        from: specified
        to: implemented
      copy:
        from: planned
        to: implemented
    preserve:
      design: protected
      structure: protected
```

La transition ne devient `verified` qu'après preuve et ne devient `approved`
qu'après l'autorité correspondante. Une checkbox de spec ne suffit pas à
surclasser la réalité du code et des validations.

Un mode public de design du type `protect` ou `approve` pourra être ajouté
uniquement si l'usage humain justifie une commande dédiée. La logique centrale
doit vivre dans une référence partagée et un registre projet, pas être enfermée
dans une seule skill.

### 13. Déploiement progressif

Ne pas cartographier tout le produit en une seule passe. Commencer par les
surfaces à forte valeur ou déjà considérées comme excellentes :

1. les cinq à dix surfaces que l'opératrice refuse de perdre ;
2. les composants/tokens partagés qui peuvent les affecter ;
3. les captures mobile et desktop principales ;
4. la gate bloquante ;
5. extension progressive de la carte au fil des travaux.

Cette approche limite la dette documentaire et donne de la valeur dès le
premier verrou.

## Non-Decisions

- Format final du registre : YAML unique, fichiers par surface ou données
  générées.
- Niveau de granularité de roadmap : pages, sections, parcours, fonctionnalités
  ou combinaison hiérarchique.
- Taxonomie finale des dimensions et nécessité éventuelle de séparer
  `interaction` de `behavior`.
- Stockage exact des images de baseline : Git, Git LFS ou artefacts CI.
- Outil de screenshot : réutilisation directe de Playwright ou wrapper
  ShipGlowz.
- Nom public final : `protect`, `approve`, `lock` ou autre vocabulaire.
- Degré d'automatisation de la détection des dépendances partagées.
- Mécanisme exact de synchronisation entre transitions de specs et atlas sans
  créer deux sources de vérité concurrentes.

## Rejected Paths

- Commit comme unique protection - utile pour la récupération, insuffisant
  pour prévenir les mutations.
- Tests pixels comme arbitre de beauté - ils détectent une différence mais ne
  possèdent pas le jugement esthétique de l'opératrice.
- Cartographie exhaustive préalable - trop lente et susceptible de devenir
  obsolète avant de produire de la valeur.
- Specs comme seule roadmap - elles décrivent des transformations et de
  l'historique, mais ne donnent pas une vue fiable et compacte du produit
  courant.
- Warning non bloquant pour une surface protégée - ne garantit rien quand
  l'agent cherche à terminer rapidement.
- Restaurer directement tous les fichiers du commit approuvé - risque de casser
  les évolutions fonctionnelles et architecturales postérieures.

## Risks And Unknowns

- Les dépendances transversales sont le risque principal : un changement de
  token ou composant global peut altérer une surface sans changer son fichier.
- Les dimensions sont techniquement entremêlées dans les mêmes fichiers. La
  classification de l'intention doit être complétée par une preuve croisée,
  jamais utilisée comme garantie automatique suffisante.
- Les screenshots instables peuvent créer du bruit. Les données, polices,
  animations, horloges et dimensions doivent être déterministes.
- Un registre uniquement manuel dérivera. La découverte des routes, composants
  et fichiers doit être automatisée quand elle est fiable, tandis que
  l'approbation reste humaine.
- Une synchronisation bidirectionnelle naïve entre specs et atlas peut produire
  des conflits. L'atlas doit être canonique pour l'état produit ; les specs
  proposent des transitions, et seules les preuves validées les appliquent.
- Trop de surfaces `protected` peut rendre toute évolution pénible. La
  granularité et les permissions bornées doivent éviter un gel global du
  produit.
- Une belle apparence ne garantit ni accessibilité ni fonctionnalité. La
  protection visuelle ne doit jamais empêcher une correction de sécurité ou
  d'accessibilité ; elle doit imposer une décision et une preuve plus forte.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: aucun secret, log sensible ou donnée client n'a été utilisé.

## Decision Inputs For Spec

- User story seed: En tant qu'opératrice, je veux marquer une surface comme
  approuvée et protégée par dimension afin qu'un agent puisse, par exemple,
  améliorer le copywriting sans modifier le design, la structure ou le
  comportement, et afin de pouvoir reconstruire chaque état approuvé après une
  régression tardive.
- Scope in seed:
  - registre hiérarchique de surfaces ;
  - atlas produit servant de roadmap de couverture ;
  - dimensions copy/design/structure/behavior ;
  - cycle planned/specified/in_progress/implemented/verified/approved ;
  - niveaux fluid/stable/protected par dimension ;
  - protection du résultat avec implémentation interne flexible par défaut ;
  - approbations et SHA indépendants par dimension ;
  - références entre surfaces, dimensions et specs ;
  - détection pré-exécution des impacts directs et indirects ;
  - permission temporaire bornée à une dimension ;
  - invariants et preuves croisés entre dimensions ;
  - preuve visuelle et récupération ciblée ;
  - intégration aux contrats design, spec, readiness, start, fix, verify,
    browser et ship.
- Scope out seed:
  - cartographie exhaustive immédiate de tous les projets ;
  - remplacement des specs ou du tracker d'exécution par l'atlas ;
  - protection du détail d'implémentation interne par défaut ;
  - jugement esthétique automatique ;
  - rollback global d'un dépôt ;
  - remplacement des tests fonctionnels et d'accessibilité.
- Invariants/constraints seed:
  - l'approbation éditoriale, esthétique, structurelle et produit appartient à
    l'opératrice ;
  - `protected` est bloquant pour la dimension concernée ;
  - chaque dimension conserve sa propre baseline et son propre SHA complet ;
  - le résultat observable est protégé, l'implémentation interne reste flexible
    tant que la preuve de non-régression passe ;
  - l'atlas est canonique pour l'état produit ; une spec propose une transition
    mais ne peut pas s'auto-déclarer vérifiée ou approuvée ;
  - tout déverrouillage est borné à une tâche, une intention et une dimension ;
  - une permission copy n'autorise jamais implicitement une adaptation design ;
  - les anciennes baselines restent consultables ;
  - aucune preuve visuelle ne remplace l'accessibilité ou les tests métier.
- Validation seed:
  - un changement direct d'une dimension protégée est bloqué ;
  - un changement de token, composant, traduction ou comportement partagé
    affectant une dimension protégée est détecté ;
  - une permission copy autorise le texte mais pas le design, la structure ou le
    behavior ;
  - les baselines copy et design peuvent pointer vers des commits distincts ;
  - une surface peut être identifiée comme planned, implemented, verified ou
    approved indépendamment de son niveau de protection ;
  - une spec référence des identifiants de surfaces et fait progresser
    uniquement les dimensions qu'elle prouve ;
  - chaque changement autorisé déclenche les preuves croisées adaptées ;
  - une différence visuelle non autorisée fait échouer la vérification ;
  - une baseline approuvée permet de reconstruire un diff ciblé depuis Git ;
  - les surfaces fluides restent modifiables sans friction excessive.

## Handoff

- Recommended next command: `/100-sg-spec approved surface protection contract`
- Why this next step: la direction recommandée est suffisamment claire pour
  formaliser le schéma du registre, les gates, les scénarios de pression et le
  pilote initial sans encore implémenter.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-26 11:00:51 UTC | Protéger les sections jugées parfaites contre les modifications agent | Comparaison commit pin, snapshots visuels et contrat de surface approuvée ; intégration proposée au workflow ShipGlowz | Recommandation : registre incrémental + baseline composite + hard stop + permission bornée | Formaliser une spec et choisir un projet pilote |
| 2026-07-26 11:15:37 UTC | Autoriser séparément copywriting, design et fonctionnalité | Transformation du statut unique en matrice copy/design/structure/behavior avec baseline et permission indépendantes, plus preuves croisées | Recommandation renforcée : verrou par dimension, commit par dimension et invariants inter-dimensions | Formaliser le schéma et les scénarios de pression |
| 2026-07-26 12:42:39 UTC | Utiliser la cartographie comme roadmap et protéger le résultat plutôt que le code | Ajout du cycle de maturité, du lien atlas-specs et de la politique outcome protected / implementation flexible | Décision retenue : atlas canonique de l'état produit, specs comme transitions, protection du résultat observable | Explorer la granularité et l'héritage des surfaces |
| 2026-07-26 13:02:53 UTC | Chercher des projets existants couvrant la protection des surfaces et la roadmap | Recherche web officielle : Vizzly, Chromatic, Playwright, Applitools, vregt, Lost Pixel, Atlassian et Productboard | Vizzly est le précédent le plus proche pour les agents et baselines ; aucun candidat ne couvre l'atlas multidimensionnel complet | Évaluer Vizzly comme brique visuelle et conserver l'atlas ShipGlowz comme couche de gouvernance |
