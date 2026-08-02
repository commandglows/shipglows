---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-26"
updated: "2026-07-26"
status: reviewed
source_skill: 203-sg-research
scope: "Projets existants pour baselines approuvées, non-régression visuelle par agent et cartographie produit"
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/explorations/2026-07-26-approved-surface-protection.md
  - skills/006-sg-design/
  - skills/103-sg-verify/
evidence:
  - "Vizzly official site and documentation: approved visual baselines, human review history, agent context and commit metadata."
  - "Chromatic official documentation: per-story baselines, accept/deny workflow, branch history and visual/accessibility tests."
  - "Playwright official documentation: screenshot and text snapshots committed to version control."
  - "Applitools official documentation: baseline acceptance/rejection and Visual AI comparisons."
  - "Atlassian and Productboard official documentation: story maps, product hierarchies and roadmap-to-delivery links."
  - "Search performed 2026-07-26 UTC across official vendor/project sources and public project repositories."
depends_on: []
supersedes: []
next_step: "Comparer Vizzly à un registre ShipGlows multidimensionnel et décider d'un pilote"
source_count: 10
---

# Research: Prior Art for Approved Surface Protection

> Recherche réalisée le 2026-07-26 — 10 sources consultées.

## Executive Summary

Le projet existant le plus proche de notre problème est **Vizzly**. Il est
explicitement conçu pour les agents de code : il conserve des baselines visuelles
approuvées, les différences, les commentaires, le commit et l'historique de
revue, puis expose ce contexte au prochain agent avant une modification.

Vizzly ne semble toutefois couvrir que la dimension visuelle. Aucun projet
consulté ne combine dans un même registre la cartographie produit, la roadmap,
les permissions indépendantes copy/design/behavior, les contrats fonctionnels et
la récupération par dimension. La bonne stratégie est donc de réutiliser les
patterns existants, pas de chercher un produit qui ferait déjà exactement tout.

## Landscape

### Vizzly — référence la plus proche pour les agents

Vizzly décrit un workflow où les agents récupèrent une baseline approuvée, les
différences et l'historique de décision avant d'éditer l'interface. Son contexte
inclut route, viewport, navigateur, branche, commit, PR, statut de revue et
commentaires. La décision finale reste humaine ; une différence non examinée
reste à revoir. [Site officiel](https://vizzly.dev/), [documentation](https://docs.vizzly.dev/), [agent context](https://vizzly.dev/agent-context/), [organisation GitHub](https://github.com/vizzly-testing).

**Correspondance avec notre besoin :** très forte pour `design.outcome`,
`baseline`, `human approval`, `agent preflight` et `review history`.

**Limites observées :** la documentation publique consultée ne présente pas de
registre produit hiérarchique, de roadmap des surfaces manquantes, ni de
permissions séparées pour copywriting, design, structure et behavior.

### Chromatic + Storybook — référence mature pour composants et états

Chromatic transforme les stories Storybook en tests visuels, d'interaction et
d'accessibilité. Les changements sont acceptés ou refusés story par story ; une
acceptation met à jour la baseline et le refus maintient l'échec. Les baselines
conservent une histoire liée aux branches et aux commits approuvés. [Quickstart officiel](https://www.chromatic.com/docs/quickstart/), [branches et baselines](https://www.chromatic.com/docs/branching-and-baselines/), [tests visuels Storybook](https://storybook.js.org/docs/9/writing-tests/visual-testing).

**Correspondance :** excellente pour un catalogue de composants et la preuve
visuelle par état, avec un workflow d'approbation déjà industrialisé.

**Limites :** centré sur Storybook/les snapshots UI ; ne constitue pas un atlas
de produit ou de fonctionnalités, et ne modélise pas la permission de modifier
le copywriting tout en protégeant le design.

### Playwright — brique locale et versionnée

Playwright fournit `toHaveScreenshot()` pour créer et comparer des captures,
ainsi que des snapshots texte ou binaires. Les snapshots peuvent être conservés
dans Git et revus avec le code ; la documentation recommande un environnement
de rendu cohérent pour éviter les différences de machine. [Documentation officielle](https://playwright.dev/docs/test-snapshots).

**Correspondance :** bonne base technique pour les surfaces web, les états et
les preuves croisées copy/design.

**Limites :** Playwright fournit la comparaison, pas la gouvernance de
l'approbation, la cartographie, l'autorisation par dimension ou le contexte
agent.

### Applitools Eyes — référence Visual AI et approbation

Applitools compare des baselines avec des algorithmes de Visual AI, gère le
contenu dynamique et permet d'accepter ou rejeter les différences. Sa
documentation distingue explicitement le rejet d'une image pour conserver
l'ancienne baseline et l'acceptation pour promouvoir la nouvelle. [Eyes officiel](https://applitools.com/platform/eyes/), [workflow de mise à jour des baselines](https://help.applitools.com/hc/en-us/articles/360007189051-Adding-new-steps-to-the-baseline-updating-the-baseline).

**Correspondance :** utile pour diminuer le bruit des snapshots et traiter les
zones dynamiques.

**Limites :** reste une plateforme de test visuel, pas une carte produit ni un
contrat multidimensionnel de surface.

### vregt et Lost Pixel — alternatives open source / framework-agnostic

vregt reçoit des screenshots depuis n'importe quel runner, les compare à une
baseline, produit un diff et permet l'approbation via dashboard ou API. [Documentation vregt](https://docs.vregt.com/getting-started/overview/)

Lost Pixel prend en charge Storybook, Ladle, Histoire, pages applicatives et
captures custom, avec seuils, viewports, masquage et un workflow d'approbation
sur sa plateforme. [Dépôt officiel](https://github.com/lost-pixel/lost-pixel).

**Correspondance :** briques réutilisables si l'on souhaite garder davantage de
contrôle ou éviter un fournisseur unique.

**Limites :** même frontière : visual regression et review, pas roadmap produit
ou protection copy/behavior.

## Product Mapping and Roadmap Prior Art

Les systèmes de roadmap existants résolvent une autre moitié du problème.

- Les story maps organisent les activités et histoires selon le parcours
  utilisateur et les versions à livrer. [Guide Atlassian](https://www.atlassian.com/blog/2016/05/guide-to-agile-user-story-maps), [template Confluence](https://www.atlassian.com/software/confluence/templates/user-story-map).
- Atlassian recommande de relier les idées de roadmap aux epics, exigences et
  user stories du delivery roadmap. [Guide officiel](https://www.atlassian.com/agile/product-management/roadmaps).
- Productboard organise les produits, composants, fonctionnalités et
  sous-fonctionnalités dans une hiérarchie qui sert ensuite à filtrer la
  roadmap. [Hiérarchie officielle](https://support.productboard.com/hc/en-us/articles/360058212253-Build-your-product-hierarchy), [glossaire API](https://developer.productboard.com/reference/glossary-feature).

Ces pratiques valident notre séparation : une carte durable de ce que le
produit contient et veut devenir, puis des specs ou histoires qui réalisent les
transitions. Elles ne fournissent cependant pas la baseline esthétique ou le
verrou agent que Vizzly traite.

## Comparison

| Capability | Vizzly | Chromatic/Storybook | Playwright | Roadmap/story map | Needed ShipGlows contract |
| --- | --- | --- | --- | --- | --- |
| Baseline visuelle approuvée | oui | oui | oui, local | non | oui |
| Historique de décision humaine | oui | oui | limité au Git/PR | variable | oui |
| Contexte utilisable par agent | oui | partiel | non natif | non | oui |
| Diff par route/surface | oui | surtout story | test-defined | variable | oui |
| Copywriting protégé séparément | non observé | non observé | possible à construire | non | oui |
| Behavior protégé séparément | non observé | interaction tests | tests fonctionnels possibles | non | oui |
| Cartographie produit | non observé | composant-centric | non | oui | oui |
| Roadmap des manques | non observé | non | non | oui | oui |
| Commit/source recovery | commit metadata | commit/branch lineage | snapshots Git | liens de delivery | oui, par dimension |

## Recommended Architecture for ShipGlows

1. **Réutiliser le pattern Vizzly pour le design :** baseline approuvée,
   contexte agent, diff significatif, commentaire humain et historique attaché.
2. **Réutiliser Playwright ou équivalent pour la preuve web :** screenshots,
   snapshots texte et états déterministes.
3. **Réutiliser le pattern story map/product hierarchy pour l'atlas :** IDs
   stables, hiérarchie d'interface, capacité produit et liens vers specs.
4. **Ajouter la couche qui manque chez tous les candidats :** un contrat par
   dimension (`copy`, `design`, `structure`, `behavior`) avec un état de
   réalisation et un niveau de protection du résultat observable.
5. **Garder l'implémentation flexible par défaut :** les outils prouvent la
   stabilité de l'expérience, sans transformer un ancien fichier en code
   intouchable.

## Important Caveat

Vizzly est le résultat le plus proche, mais son site et sa documentation sont
récents. Avant de l'adopter, il faudra vérifier la maturité réelle du CLI, les
conditions de stockage des baselines, l'intégration Flutter, la confidentialité
des captures et la possibilité d'exporter l'historique dans notre gouvernance.
La recherche établit une piste à évaluer, pas une décision d'achat ou
d'intégration.

## Sources

- [Vizzly](https://vizzly.dev/) — visual regression pour agents avec baselines approuvées.
- [Vizzly Features](https://vizzly.dev/features/) — métadonnées, review history et PR checks.
- [Vizzly Agent Context](https://vizzly.dev/agent-context/) — contexte compact destiné aux agents.
- [Vizzly Docs](https://docs.vizzly.dev/) — workflow capture, review, baseline et CLI.
- [Vizzly GitHub](https://github.com/vizzly-testing) — CLI open source et organisation publique.
- [Chromatic Quickstart](https://www.chromatic.com/docs/quickstart/) — accept/reject par story.
- [Chromatic Branches and Baselines](https://www.chromatic.com/docs/branching-and-baselines/) — historique et branches.
- [Playwright Visual Comparisons](https://playwright.dev/docs/test-snapshots) — screenshots et snapshots versionnés.
- [Applitools Eyes](https://applitools.com/platform/eyes/) — Visual AI et détection de régressions.
- [Atlassian Product Roadmaps](https://www.atlassian.com/agile/product-management/roadmaps) — liaison roadmap vers delivery work.

## Chantier potentiel

- oui
- titre proposé : "Approved Surface Protection and Product Atlas"
- raison : la recherche confirme qu'il existe des briques matures, mais aucun
  outil identifié ne couvre la combinaison agent + baseline + cartographie
  produit + permissions multidimensionnelles.
- sévérité : haute pour la préservation du travail approuvé, moyenne pour la
  construction initiale.
- scope : registre de surfaces/capacités, transitions de roadmap, baselines
  visuelles et fonctionnelles, contexte agent, permissions par dimension,
  preuves croisées et pilote sur un projet.
- evidence : Vizzly pour le sous-problème visuel-agent ; Chromatic/Playwright
  pour les tests ; Atlassian/Productboard pour la cartographie/roadmap.
- next step : formaliser le contrat avant de choisir ou d'intégrer Vizzly.
