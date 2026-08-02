---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: "ShipGlows"
created: "2026-07-26"
created_at: "2026-07-26 13:21:00 UTC"
updated: "2026-08-02"
updated_at: "2026-08-02 19:20:50 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "approved-surface-protection-and-product-atlas"
owner: "Diane"
confidence: high
user_story: "En tant qu'operatrice, je veux annoter directement les surfaces visibles et les fonctions observables avec des niveaux simples de qualite, afin de proteger ce que j'approuve, signaler ce qui est faible et permettre aux agents d'evoluer le produit sans casser le resultat que je vois."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/explorations/2026-07-26-approved-surface-protection.md"
  - "shipglows_data/workflow/research/approved-surface-protection-prior-art-2026-07-26.md"
  - "shipglows_data/business/project-competitors-and-inspirations.md"
  - "skills/references/design-system-token-contract.md"
  - "skills/references/atlas-cartography-lifecycle.md"
  - "skills/references/product-decision-chain.md"
  - "templates/business_context.md"
  - "templates/product_context.md"
  - "skills/305-sg-init/SKILL.md"
  - "skills/102-sg-start/SKILL.md"
  - "skills/103-sg-verify/SKILL.md"
  - "skills/106-sg-fix/SKILL.md"
  - "injectors/web-inspector.js"
  - "cli/lib.sh"
  - "/home/claude/best-fried-chicken/shipglows_data/editorial/public-surface-map.md"
depends_on:
  - artifact: "shipglows_data/workflow/explorations/2026-07-26-approved-surface-protection.md"
    artifact_version: "1.3.0"
    required_status: draft
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision: build the ShipGlows-native solution instead of adopting a vendor as product authority."
  - "Operator decision: the cartography must also serve as the roadmap."
  - "Operator decision: copywriting, design and functionality need independent permissions; structure is included as an internal impact category so that result-oriented controls do not hide implementation risk."
  - "Operator decision 2026-08-02: the operator annotates visible product surfaces through three controls only — Copy, Design and Fonction — while the crawlable functional graph remains separate and is linked by stable IDs."
  - "Operator decision 2026-08-02: every operator-facing assessment starts at unknown and cycles through red, bronze, silver, gold and diamond; focus is an independent attention tag, not a quality level."
  - "Operator decision 2026-08-02: one visible surface may expose several functions, including a backend capability when its result is meaningfully observable by the operator."
  - "Operator decision 2026-08-02: browser/functional pilot verification is deliberately deferred for resumption on another server; its context must remain self-contained in this spec."
  - "Readiness decision 2026-08-02: browser annotations remain session-local until an explicit local export and validated project-side import; browser code never writes the atlas directly."
  - "Readiness decision 2026-08-02: the Atlas overlay owns named CSS custom properties in an injected local stylesheet; no remote script or visual literal bypass is required for the first release."
  - "Operator decision 2026-08-02: `305-sg-init atlas` creates the smallest useful draft map; the operator validates semantic boundaries and all draft assessments remain unknown."
  - "Operator decision 2026-08-02: Atlas bootstrap guides business identity, customer need and priority journey before deriving planned surfaces/functions."
  - "Operator decision 2026-08-02: the canonical product-decision chain must become concrete in the existing corpus, with readable semantic IDs, adjacent links and generated validation rather than a second hand-maintained database."
  - "Local BMAD review 2026-08-02: journey-derived capabilities remain implementation-agnostic, change proposals show artifact impact and before/after, and proof traceability is bidirectional."
  - "Prior-art review 2026-07-26: Vizzly, Chromatic, Playwright, Applitools, vregt, Lost Pixel, Atlassian and Productboard provide partial primitives but no combined multidimensional atlas."
  - "Local inspection review 2026-07-26: injectors/web-inspector.js selects div elements, copies generated XPath values, and captures element screenshots, but does not emit stable product target IDs or approval context."
next_step: "/101-sg-ready Approved Surface Protection And Product Atlas"
---

# Title

Approved Surface Protection And Product Atlas

## Status

Brouillon matériel à réévaluer. Les fondations Atlas déjà implémentées et la vérification navigateur différée restent inchangées ; le nouveau lot formalise comment la chaîne `objectif business → preuve` vit concrètement dans les documents, le JSON Atlas, les specs et les preuves sans créer une seconde source de vérité.

## User Story

En tant qu'operatrice ShipGlows, je veux annoter directement les surfaces visibles et les fonctions observables avec des niveaux simples de qualite, afin de proteger ce que j'approuve, signaler ce qui est faible et permettre aux agents d'evoluer le produit sans casser le resultat que je vois.

## Minimal Behavior Contract

L'operatrice active le mode Atlas dans l'inspecteur, voit les surfaces semantiques superposees et clique sur `Copy`, `Design` ou `Fonction` pour faire avancer l'evaluation de `unknown` a `red`, `bronze`, `silver`, `gold`, puis `diamond`. `Copy` et `Design` portent sur la surface visible ; `Fonction` ouvre les fonctions observables liees a cette surface, une ou plusieurs selon le cas. Les clics restent dans une session navigateur non canonique jusqu'a l'action explicite `Exporter les annotations`; l'import local valide et fusionne ensuite le bundle dans le registre projet. L'agent consulte alors cette annotation et le graphe d'impact avant toute ecriture : `gold` bloque toute modification non autorisee de la dimension concernee, `diamond` exige en plus une instruction operatrice explicite nommant la cible, et aucune note `red` n'autorise implicitement une modification large. Les categories internes `structure` et `behavior` restent analysees lors du preflight afin qu'une demande result-oriented ne masque pas un impact technique ou backend. Une preuve devenue non reproductible passe a `needs_review`, sans renouvellement silencieux.

## Inspector Bundle Schema

L'atlas canonique reste un seul document JSON projet, mais il contient deux sous-arbres distincts : `surfaces` pour la carte visuelle et `functions` pour le graphe fonctionnel crawlable par l'IA. Les deux se relient uniquement par des IDs stables ; aucun XPath, screenshot ou nom de composant ne sert d'identite.

Une surface contient `surface_id`, `target_id`, libelle, routes, selecteur stable, `impact_paths` project-relative et les evaluations operatrice de `copy` et `design`. Un noeud fonctionnel contient `function_id`, `kind` (`interaction`, `capability` ou `internal`), son ou ses `surface_ids`, dependances frontend/backend et son evaluation `function`. Une capacite backend n'est montrable dans l'interface que si `operator_observable: true` et qu'elle est reliee a une surface ou un effet que l'operatrice peut juger. Les noeuds `internal` non observables restent hors de l'interface mais sont parcourables par l'IA.

Les statuts operatrice sont exactement `unknown`, `red`, `bronze`, `silver`, `gold`, `diamond`. `focus` est un champ d'attention independant, booleen et non un niveau. Leur politique est fixe :

- `unknown` : pas encore evalue ; aucune baseline et aucune promesse de stabilite.
- `red` : resultat juge insuffisant ; priorite de travail, sans autorisation implicite d'elargir le scope.
- `bronze` : valide mais ameliorable ; modification autorisable avec preuve normale.
- `silver` : stable ; modification explicitement declaree et verification renforcee.
- `gold` : approuve et protege ; baseline obligatoire et hard stop sans permission explicite de la dimension.
- `diamond` : approuve et gele ; meme hard stop que `gold`, plus instruction operatrice explicite nommant ID et dimension avant renouvellement.

`gold` et `diamond` correspondent a une protection technique `protected`; `silver` a `stable`; les trois autres a `fluid`. Les anciennes categories d'impact `structure` et `behavior` ne sont pas des boutons operatrice : elles restent dans `impact_categories` et dans les permissions/preflights pour conserver les garde-fous techniques.

L'inspecteur echange un seul bundle JSON en `format_version: "2.0"`. Les champs structures sont la source de verite ; `agent_prompt_markdown` est genere localement et n'est jamais maintenu a la main. Les bundles de selection v1 restent lisibles comme indices de migration, mais ne peuvent pas enregistrer une annotation v2 ou renouveler une baseline.

### Local Persistence Contract

Le navigateur ne peut jamais ecrire directement dans `shipglows_data/`, dans Git, ni dans l'atlas source. Les clics d'une session Atlas sont gardes uniquement en memoire et un bouton explicite `Exporter les annotations (n)` produit un fichier ou une copie presse-papiers `shipglows-atlas-annotations.v2.json`. Aucun `localStorage`, cookie, appel reseau, token, chemin local, screenshot brut ou contenu de formulaire ne fait partie du journal de session.

Le bundle exporte contient `format_version`, `kind: "atlas_annotation_patch"`, `project`, `base_atlas_digest`, `exported_at`, une liste d'annotations v2 et un manifeste de preuves locales relatives. Il ne contient aucun champ executable. Un importeur ShipGlows local, lance explicitement dans le depot projet, valide le schema, le digest du registre courant, les IDs, la politique `gold`/`diamond`, les references de preuves et les donnees interdites, puis fusionne atomiquement les seules annotations admissibles. Lorsqu'une annotation Gold/Diamond a été confirmée dans l'Atlas, l'option explicite `--approve-protected` exige un worktree Git propre, lit le SHA HEAD complet et produit la baseline composite (empreinte de contexte, décision et référence d'import) sans écrire de commit ni recopier le code. Un dépôt dirty, un SHA absent, un atlas hors du dépôt ou un bundle invalide n'écrit rien. En cas de digest divergent, d'ID inconnu ou de conflit de revision, l'importeur produit un refus reimportable après résolution.

L'export est donc le passage visible entre l'experience operatrice et la source de verite. L'import met a jour l'atlas et son historique ; un rechargement de la page ou de l'injecteur est requis pour relire l'etat canonique. Cette separation fonctionne sur tout serveur de developpement/preview sans ouvrir un endpoint d'ecriture arbitraire dans l'application cible.

Champs obligatoires pour une annotation persistable :

- `captured_at` : horodatage ISO-8601 UTC.
- `target.surface_id`, `target.target_id`, `target.route` et `selectors.stable`.
- `annotation.dimension` : `copy`, `design` ou `function`.
- `annotation.quality` : l'un des six statuts operatrice ; `annotation.focus` est optionnel.
- `annotation.function_id` si `dimension` vaut `function`.
- `reference.commit`, `reference.viewport` et `evidence.local_ref` ; les valeurs indisponibles sont `null` avec une raison explicite.
- Pour un bundle exporte : `kind: "atlas_annotation_patch"`, `project`, `base_atlas_digest`, `exported_at` et une liste non vide d'annotations valides.

Champs optionnels : `target.label`, `target.state`, `target.parent_target_id`, `target.function_ids`, `selectors.css_fallback`, `selectors.xpath_fallback`, `reference.context_fingerprint`, `reference.config_fingerprint`, `evidence.screenshot_ref`, `evidence.dom_hash`, `permissions.requested`, `agent_prompt_markdown`.

Exemple pour une capacite backend observable depuis le checkout :

```json
{
  "format_version": "2.0",
  "captured_at": "2026-08-02T13:01:00Z",
  "target": {
    "surface_id": "checkout.payment",
    "target_id": "checkout.payment.primary",
    "route": "/paiement/",
    "function_ids": ["checkout.validate-form", "payment.process", "orders.create"]
  },
  "selectors": {"stable": "[data-sg-target=\"checkout.payment.primary\"]"},
  "annotation": {
    "dimension": "function",
    "function_id": "payment.process",
    "quality": "red",
    "focus": true,
    "observation": "Le paiement echoue du point de vue client."
  },
  "reference": {
    "commit": "0123456789abcdef0123456789abcdef01234567",
    "viewport": {"width": 1440, "height": 900, "dpr": 1}
  },
  "evidence": {"local_ref": "evidence/checkout.payment/payment.process.json"}
}
```

Un bundle sans `surface_id`, `target_id` ou `selectors.stable` peut aider au diagnostic, mais ne peut jamais creer ou renouveler une annotation protegee. Une fonction non liee a une surface observable ne peut pas etre note par l'operatrice depuis l'injecteur.

## Canonical Atlas v2 Schema

Le fichier canonique reste `shipglows_data/workflow/atlas/approved-surfaces.json` pendant le pilote. Sa forme v2 est un objet unique :

```json
{
  "format_version": "2.0",
  "project": "best-fried-chicken",
  "updated_at": "2026-08-02T13:14:06Z",
  "source_of_truth": "atlas",
  "surfaces": [
    {
      "surface_id": "checkout.payment",
      "target_id": "checkout.payment.primary",
      "label": "Checkout et paiement",
      "route_patterns": ["/paiement/"],
      "selectors": {"stable": "[data-sg-target=\"checkout.payment.primary\"]"},
      "assessments": {
        "copy": {"quality": "unknown", "focus": false, "approval": null},
        "design": {"quality": "unknown", "focus": false, "approval": null}
      },
      "function_ids": ["checkout.validate-form", "payment.process", "orders.create"],
      "upstream_ids": ["capability.complete-order"],
      "spec_ids": ["spec.approved-surface-protection-and-product-atlas"],
      "impact_categories": ["copy", "design", "structure", "behavior"],
      "status": "planned",
      "aliases": []
    }
  ],
  "functions": [
    {
      "function_id": "payment.process",
      "kind": "capability",
      "label": "Paiement",
      "operator_observable": true,
      "surface_ids": ["checkout.payment"],
      "upstream_ids": ["capability.complete-order"],
      "spec_ids": ["spec.approved-surface-protection-and-product-atlas"],
      "dependencies": {"frontend": [], "backend": ["payments.create"]},
      "assessment": {"quality": "unknown", "focus": false, "approval": null},
      "aliases": []
    }
  ],
  "import_history": []
}
```

`approval` is either `null` or an object containing the full commit SHA, context fingerprint, local evidence reference, operator decision, timestamp and previous baseline reference. `quality` uses the six fixed values; `status` remains the delivery roadmap state. `functions[].dependencies` are AI-only and are never copied into the browser context. A v1 migration maps existing `copy` and `design` values of `fluid` to `unknown`, preserves `structure`/`behavior` in `impact_categories`, creates empty `function_ids` and `functions`, preserves every stable selector, and records the v1 source format in `import_history`.

The generator creates a separate noncanonical `public/shipglows-atlas-context.json` next to the injected JS/CSS. It includes only `project`, `atlas_digest`, format version, visible surface IDs/labels/selectors/routes, operator-facing `copy`/`design` assessments and observable function IDs/labels/assessments. It excludes backend dependencies, source paths, baseline evidence, import history, private notes and internal functions. The inspector fails closed into diagnostic-only mode when this context is absent, stale or malformed.

## Corpus Decision Trace Contract

La chaîne canonique devient concrète par propriété distribuée : chaque nœud vit dans l’artefact qui en possède le sens, et ne répète que ses liens directs. Aucun fichier central édité à la main ne recopie toutes les décisions.

| Nœud | ID canonique | Source de vérité | Liens directs minimaux |
| --- | --- | --- | --- |
| Objectif business | `goal.<slug>` | contrat business canonique du projet | `downstream_ids` vers besoins |
| Besoin client | `need.<slug>` | contrat produit canonique | `upstream_ids` vers objectifs, `downstream_ids` vers parcours |
| Parcours | `journey.<slug>` | contrat produit canonique | besoins amont, moments/capacités aval |
| Moment critique | `moment.<slug>` | contrat produit canonique | parcours amont, capacités/Atlas aval, preuve attendue |
| Capacité observable | `capability.<slug>` | contrat produit canonique | parcours/moments amont, fonctions/surfaces Atlas aval |
| Surface/fonction | ID Atlas existant, par exemple `home.hero` ou `ordering.place-order` | `shipglows_data/workflow/atlas/approved-surfaces.json` | `upstream_ids` vers capacités, `spec_ids` gouvernantes |
| Transformation | `spec.<frontmatter scope>` | spec canonique | IDs affectés, `before → after`, invariants, `proof_ids` attendus |
| Preuve | `proof.<slug>` dans l’artefact de vérification | test, checklist ou rapport de vérification canonique | `covers_ids` vers critères/spec/Atlas/capacités effectivement prouvés |

Les `<slug>` sont en minuscules ASCII, séparés par des tirets et orientés sens métier : `goal.reduce-handoff-loss`, `need.resume-without-reexplaining`, `journey.resume-existing-work`, `capability.recover-current-context`. Ils sont stables après confirmation et ne contiennent ni numéro séquentiel sans sens, ni chemin de fichier, route, composant, sélecteur DOM ou technologie. Un renommage éditorial ne change pas l’ID. Une décision réellement remplacée devient `superseded` et pointe vers `superseded_by`; un ID retiré n’est jamais recyclé.

Les documents Markdown conservent les explications humaines. Ils ajoutent des tables courtes dans leurs sections naturelles, pas un bloc YAML géant ni une base encodée dans le frontmatter. Format minimal d’un nœud :

```markdown
| ID | Décision ou résultat observable | État | Amont | Aval | Preuve |
| --- | --- | --- | --- | --- | --- |
| `need.resume-without-reexplaining` | Reprendre un chantier sans reconstruire son contexte | confirmed | `goal.reduce-handoff-loss` | `journey.resume-existing-work` | entretien opératrice 2026-08-02 |
```

Les colonnes peuvent être spécialisées par section, mais les valeurs machine restent des IDs exacts. `État` accepte seulement `confirmed`, `evidence_backed`, `hypothesis`, `unknown` ou `superseded`. Une cellule sans lien applicable utilise `not_applicable: <raison>` ; une cellule simplement inconnue reste `unknown` et ne devient pas `not_applicable` pour faire passer le contrôle.

Le JSON Atlas ne reçoit pas le Markdown business/produit. Chaque surface ou fonction ajoute seulement `upstream_ids` et `spec_ids`; les vues humaines et le Markdown de handoff sont générés. Les specs ajoutent une section `Product Decision Trace` contenant le résultat client, les IDs amont/aval affectés, le `before → after` si nécessaire, les invariants préservés et les preuves attendues. Les artefacts de vérification déclarent leurs `covers_ids`; un nom de test implicite ne suffit pas pour une exigence matérielle.

Un outil ShipGlows en lecture seule découvre les contrats canoniques selon la topologie du projet, extrait ces tables ainsi que les liens Atlas/spec/preuve, puis produit un index dérivé et jetable. Il valide la grammaire, l’unicité globale par namespace, l’existence des références, la réciprocité utile des liens adjacents, les cycles interdits, les nœuds orphelins et la couverture jusqu’à la preuve. Il ne réécrit jamais automatiquement une décision opératrice et ne bloque que le scope matériel touché : `conflict` ou `orphan` bloque, `gap` demande la plus petite décision manquante, `warning` exige une vérification explicite.

Exemple complet attendu :

```text
goal.reduce-handoff-loss
  → need.resume-without-reexplaining
  → journey.resume-existing-work
  → moment.recover-current-state
  → capability.recover-current-context
  → atlas function context.resume-work / surface workflow.chantier-status
  → spec.approved-surface-protection-and-product-atlas
  → proof.product-trace-valid-chain
```

La migration est progressive. L’outil commence par signaler les zones non matérialisées sans inventer d’IDs à partir de chaque paragraphe existant. `300-sg-docs` ou `305-sg-init atlas` propose les premiers nœuds à partir du corpus et demande confirmation uniquement pour le sens métier; une spec nouvelle ou modifiée doit ensuite maintenir les liens qu’elle touche. Les documents historiques non concernés restent lisibles et ne sont pas massivement réécrits.

## Success Behavior

- Toute decision produit materielle peut etre retracee dans une chaine legere `business goal → customer need → journey → capability → Atlas function/surface → spec → proof`; cette chaine reutilise les IDs des artefacts existants et ne cree pas un registre concurrent.
- Un agent frais peut ouvrir un objectif, besoin, parcours, capacité, nœud Atlas, spec ou preuve et suivre ses liens directs dans les deux sens sans rechercher un identifiant séquentiel opaque.
- Les contrats business/produit restent lisibles en Markdown, le JSON Atlas reste structurel, et un index de chaîne éventuellement généré demeure dérivé et jetable.
- Le validateur distingue un lien cassé, un nœud orphelin, une décision inconnue et une preuve manquante sans modifier automatiquement le sens confirmé par l’opératrice.
- Avant implementation, un controle de coherence signale les promesses sans capacite, les fonctions sans besoin client, les surfaces sans parcours, les choix UX impossibles a soutenir techniquement et les preuves sans exigence source.
- Lorsqu'une decision change, l'agent montre l'ancien et le nouveau contrat, calcule les impacts sur les documents, parcours, capacites, surfaces, fonctions, specs et preuves, puis preserve explicitement les dimensions non concernees avant toute ecriture.
- Les moments critiques du parcours — action centrale, premier resultat utile, confiance, erreur et recuperation — peuvent porter l'emotion recherchee, l'emotion a eviter, leur surface/fonction observable et leur niveau de preuve/protection.
- Une retrospective conserve uniquement les enseignements prouves, leur champ d'application et la verification attendue au chantier suivant ; elle ne transforme jamais automatiquement une opinion locale en doctrine globale.
- Avant de proposer l'arbre Atlas, l'agent guide l'operatrice de l'identite business au besoin client puis au parcours prioritaire : il montre une synthese sourcée, pose une question thematique a fort impact, propose le texte exact et attend `Confirmer`, `Corriger` ou `Approfondir`.
- Les contrats business, produit, GTM et marque distinguent faits confirmes, preuves, hypotheses et inconnues. Un stack technique ne devient jamais une preuve implicite d'audience, de promesse ou de modele economique.
- Un parcours client confirme produit des capacites observables (`actor can capability`), des surfaces/fonctions candidates et leur statut roadmap, sans imposer leur implementation technique.
- Le produit possede une cartographie hierarchique a identifiants stables qui distingue l'etat de livraison (`planned` a `approved`), le niveau operatrice et la protection technique derivee.
- Le mode Atlas affiche uniquement les surfaces semantiques en dev/preview, avec leur ID visible et trois controles : `Copy`, `Design` et `Fonction`.
- Un clic sur un controle avance son evaluation dans l'ordre `unknown` → `red` → `bronze` → `silver` → `gold` → `diamond` → `unknown`; Gold et Diamond demandent une confirmation qui nomme la dimension et l'ID visé, puis l'import explicite lie la baseline au SHA Git propre courant. L'interface donne aussi une legende du niveau courant et un filtre global par dimension.
- Une session de clics affiche un compteur d'annotations non exportees et ne devient durable qu'apres export local puis import valide dans le depot projet.
- Le filtre global `Copy`, `Design`, `Fonction` ou `Toutes` ne modifie aucune donnee : il change seulement le calque et les couleurs affiches.
- Une surface peut avoir plusieurs fonctions liees. Le controle `Fonction` ouvre leur liste ; chaque fonction est notee individuellement, et le resume de surface est `mixed` si les niveaux divergent.
- Les evaluations `copy`, `design` et `function` sont independantes ; les categories techniques `structure` et `behavior` restent des impacts internes que l'agent doit analyser.
- Une approbation conserve un commit Git complet, une empreinte de contexte reproductible, les fichiers et dependances d'impact, les preuves et la decision humaine.
- Le preflight d'execution detecte les impacts directs et indirects avant ecriture et bloque les violations.
- Une permission temporaire ouvre seulement les dimensions explicitement nommees et expire avec la spec ou la tache.
- Le renouvellement met a jour uniquement les dimensions effectivement approuvees ; les autres baselines restent intactes.
- La cartographie expose ce qui existe, ce qui reste a faire, ce qui est protege et les specs associees, devenant une vue roadmap sans remplacer les specs.

## Error Behavior

- Si une surface ou dimension n'est pas identifiable, l'agent bloque avant modification et demande une cartographie ou une décision de portée.
- Si une surface est visible mais non enregistree, le mode Atlas la signale comme non stable et propose une creation d'ID semantique ; elle ne peut pas etre protegee depuis un XPath seul.
- Si une surface expose plusieurs fonctions, l'interface ne choisit jamais arbitrairement laquelle noter : elle affiche les fonctions liees et une action explicite peut appliquer une note a chacune.
- Si une capacite backend ne produit aucun resultat observable, elle reste dans le graphe IA et n'est pas presentée comme un controle utilisateur.
- Si l'export navigateur ou l'import local echoue, l'interface explique que la source de verite n'a pas change et conserve la session en memoire tant que la page reste ouverte ; elle ne simule jamais une sauvegarde reussie.
- Si le bundle cible un atlas different ou un digest obsolete, l'import refuse toute ecriture et fournit les IDs/revisions a rebaser ; il ne fusionne jamais aveuglement une annotation de l'ancien etat.
- Si un fichier ou une dépendance partagée peut toucher une dimension `protected`, l'agent bloque même si le fichier de la surface n'est pas directement modifié.
- Si une permission couvre le copywriting mais que le layout doit changer pour faire rentrer le texte, l'agent bloque le design et demande une autorisation séparée.
- Si une annotation `red` implique une correction d'une surface `gold` ou `diamond` dependante, l'agent ne casse pas la protection : il produit d'abord l'impact et demande la permission exacte.
- Si une baseline ne peut plus être reproduite après une mise à jour de navigateur, police, framework, token ou environnement, la dimension devient `needs_review`.
- Une restauration ne fait jamais de checkout global d'un ancien commit ; elle propose une correction ciblée et vérifie les surfaces dépendantes.

## Problem

Les tests fonctionnels prouvent surtout qu'une action reste possible. Les tests visuels détectent un rendu différent mais ne savent pas si l'ancien rendu était volontairement approuvé. Un commit seul ne capture ni le contexte de rendu, ni les dépendances partagées, ni les permissions dimensionnelles. Il manque donc une autorité unique reliant intention produit, preuve, portée de changement et récupération.

## Solution

Construire un contrat transversal ShipGlows composé de cinq éléments :

1. un atlas visuel produit, hiérarchique et versionné ;
2. un calque d'annotation operatrice `Copy` / `Design` / `Fonction` ;
3. un graphe fonctionnel separe reliant interactions, capacites frontend/backend et surfaces observables ;
4. un graphe d'impact reliant fichiers, composants, tokens, traductions, fonctions et surfaces ;
5. un preflight, une preuve et un historique d'approbation intégrés au cycle spec/implementation/verification.

Le commit approuvé reste l'ancre historique, mais la vérité exploitable est un baseline composite. L'atlas reste la source de vérité du produit courant et désiré ; une spec reste le contrat temporaire d'une transformation.

L'inspecteur visuel devient l'interface de lecture et de marquage de l'atlas, sans devenir sa seconde source de verite. Il permet de selectionner une cible, d'afficher son ID, de noter une dimension et de copier un bundle de reference relie a l'atlas. Le graphe fonctionnel n'est pas expose comme une architecture a l'operatrice : il est seulement resolu par l'IA a partir des IDs. Une cible sans identifiant sémantique stable reste un indice de diagnostic et ne peut pas créer ou renouveler une baseline protégée.

## Scope In

- Contrat partage de chaine de decision produit, matrice de coherence, propagation des changements et boucle d'apprentissage.
- Reutilisation des IDs et artefacts canoniques existants, sans nouveau registre de verite concurrent.
- Approfondissement selectif par une seule lentille pertinente, sans personnages simules ni menus permanents.
- Templates canoniques enrichis pour les contrats business, produit, GTM et marque.
- Reference partagee de decouverte guidee, chargee par l'initialisation et la maintenance documentaire.
- Dialogue progressif sans questionnaire exhaustif, avec reprise depuis la premiere decision non resolue.
- Modèle canonique d'identifiants de surface et de dimension.
- Deux sous-arbres canoniques dans le meme document projet : carte `surfaces` visible et graphe `functions` crawlable.
- Mode Atlas de l'inspecteur : IDs visibles, controles `Copy` / `Design` / `Fonction`, cycle de qualite, legende et filtres de calque.
- Persistance locale explicite : journal de session en memoire, export de patch JSON non executable, import projet valide et fusion atomique avec detection de conflit.
- Declaration de l'autorite visuelle de l'overlay et feuille locale de tokens `--sg-atlas-*` distribuee avec l'injecteur.
- Notes individuelles de plusieurs fonctions depuis une meme surface, y compris une capacite backend observable par son resultat utilisateur.
- Tag d'attention `focus`, distinct de la qualite et disponible aussi depuis la conversation.
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
- Exposition brute du graphe technique, des dependances backend ou des noms internes a l'operatrice dans le mode Atlas.
- Notation de fonctions purement internes sans resultat observable par l'operatrice.
- Endpoint applicatif, cookie, `localStorage` ou ecriture navigateur directe servant a modifier le registre atlas.
- Chargement automatique de scripts, styles ou captureurs tiers depuis un CDN ; la capture d'ecran est hors du premier increment tant qu'un asset local ne l'active pas explicitement.

## Constraints

- Les dimensions operatrice sont exactement `copy`, `design`, `function`; l'interface ne les appelle jamais `structure` ou `behavior`.
- Les categories internes d'impact restent `copy`, `design`, `structure`, `behavior` ; `structure` et `behavior` ne sont jamais supprimees du preflight, mais elles ne sont pas des statuts a cliquer.
- Le mapping entre une note `function` et ses impacts `structure`/`behavior` est explicite dans le graphe fonctionnel ; il ne cree aucune permission implicite.
- Tous les nouveaux controles commencent a `unknown`. Le cycle de qualite est unique et stable : `unknown`, `red`, `bronze`, `silver`, `gold`, `diamond`.
- `focus` est un tag d'attention distinct ; il peut coexister avec n'importe quel niveau, y compris `unknown`.
- L'autorite de design-system de l'overlay est une feuille locale `injectors/web-inspector.css`, copiee vers le projet en meme temps que l'injecteur. Elle declare les custom properties `--sg-atlas-*` pour couleurs, typographie, espacements, rayons, elevations, calques et motion ; `web-inspector.js` consomme ces tokens et ne porte pas de valeurs visuelles Atlas en ligne.
- L'overlay reste clairement distinct du design-system de l'application inspectee : il ne modifie aucun token, style ou composant applicatif.
- L'injecteur ne charge aucun script externe par defaut. Eruda, html2canvas et l'upload ImgBB sont des integrations hors premier increment : elles restent desactivees, ne peuvent etre activees que par configuration explicite et ne participent pas au flux d'annotation.
- Le seul chemin d'ecriture est `export JSON patch` → `import local valide` → `fusion atomique`; le navigateur n'ecrit ni registre, ni Git, ni endpoint applicatif.
- `protected` est un hard stop, pas un simple warning.
- Une permission n'ouvre jamais implicitement une autre dimension.
- L'implémentation reste `flexible` tant que le résultat approuvé et les preuves restent valides.
- Les preuves visuelles doivent utiliser l'autorité de design-system déclarée et les tokens canoniques ; aucune valeur visuelle locale non justifiée n'est introduite.
- Les snapshots sont des preuves de dérive, pas une décision d'approbation automatique.
- Les identifiants restent stables quand un fichier, un composant ou un libellé change ; les surfaces supprimées passent par `retired`.
- Le selector DOM est une preuve de localisation, jamais l'identité canonique de la surface.
- L'inspecteur est une aide de sélection, de marquage et de preuve ; il persiste uniquement les choix operatrice explicites et ne deduit jamais une approbation d'une couleur, d'un screenshot ou d'une interaction seule.
- Les uploads distants, clés API, cookies, stockage local et contenu authentifié sont exclus par défaut de tout bundle copié ou persisté.

## Test Contract

- surface/stack profile: governance cross-surface, web/app agnostic, with browser or golden proof adapters.
- proof_profile: `atlas-protection-v1`.
- automated proof: schema validation, surface/function ID uniqueness, reciprocal referential integrity between both trees, fixed status-cycle validation, export/import schema and digest checks, atomic conflict rejection, strict relative-evidence validation, protected-baseline completeness check, clean-Git baseline creation/refusal checks, context fail-closed validation, changed-surface/function impact preflight (`clear`/`review`/`block`) and protected-dimension authorization check.
- non-automated proof: operator approval of the initial baseline and of each renewed dimension; visual review on representative viewports/states; user-observable functional judgement for linked backend capabilities.
- proof order: registry/schema → surface/function graph integrity → protected impact diff → browser/golden evidence → interactive Atlas annotation evidence → cross-dimension invariants → operator approval → shipment gate.
- checklist_path: `/home/claude/best-fried-chicken/shipglows_data/workflow/test-checklists/approved-surface-protection-and-product-atlas.md` (created with implementation).
- required_scenario_ids: `ATLAS-001` initial registration, `ATLAS-002` copy-only authorization, `ATLAS-003` protected design hard stop, `ATLAS-004` shared-dependency impact, `ATLAS-005` environment drift to `needs_review`, `ATLAS-006` inspector bundle round-trip, `ATLAS-007` targeted recovery, `ATLAS-008` quality cycle and dimension filter, `ATLAS-009` multi-function surface, `ATLAS-010` observable backend capability, `ATLAS-011` unregistered-target rejection, `ATLAS-012` local export/import round-trip, `ATLAS-013` stale-digest conflict rejection, `ATLAS-014` offline/no-CDN inspector startup, `ATLAS-015` vague-founder guided discovery, `ATLAS-016` partial-corpus preservation, `ATLAS-017` journey-to-capability derivation, `ATLAS-018` no-questionnaire-dump interaction, `ATLAS-019` decision-change impact propagation, `ATLAS-020` cross-contract coherence conflict, `ATLAS-021` critical-experience-moment mapping, `ATLAS-022` orphan trace rejection, `ATLAS-023` one-lens deepening, `ATLAS-024` evidence-backed retrospective replay, `ATLAS-025` lightweight-no-theater boundary, `ATLAS-026` valid distributed corpus chain, `ATLAS-027` broken adjacent reference, `ATLAS-028` duplicate semantic ID, `ATLAS-029` superseded decision history, `ATLAS-030` proof back-link coverage, `ATLAS-031` progressive legacy migration, `ATLAS-032` generated-index non-authority.
- required_results: each scenario records pass/fail, affected surface IDs, dimensions, evidence references, operator decision and any residual risk; any failure blocks readiness or shipment for the affected scope.
- exception-with-proof: a dimension may be `not_applicable` only when the registry records the reason and the readiness/verification evidence confirms it. Deferred browser/functional verification is permitted only when this spec records the exact resume packet and does not claim pilot approval.

## Dependencies

- Git history and full commit SHAs.
- `tools/shipglows_atlas_context.py`, which derives a redacted `public/shipglows-atlas-context.json` from the canonical registry and its byte-level SHA-256 digest.
- `tools/shipglows_atlas_import.py`, a project-local import command that reads a selected patch path and rewrites only the project-owned registry atomically. It is not an application API and requires no target-site runtime endpoint.
- `tools/shipglows_atlas_preflight.py` and `skills/references/atlas-protection-preflight.md`, which resolve intended/staged changed paths through `impact_paths` and function dependencies before an agent writes, verifies or ships.
- `injectors/web-inspector.css` as the local visual token authority for the injected overlay, declared in `shipglows_data/technical/design-system-authority.md`.
- Project design-system authority and token checks.
- Browser or golden-test capture adapter for each declared surface.
- Existing spec, implementation, verification and ship lifecycle gates.
- A read-only product-trace validator and generated-index adapter to be implemented by Task 11; neither becomes a product-decision authority.
- Official visual-testing prior art is informative only: [Vizzly](https://vizzly.dev/), [Chromatic](https://www.chromatic.com/docs/branching-and-baselines/), [Playwright](https://playwright.dev/docs/test-snapshots).

## Invariants

- A protected dimension cannot change without a matching, explicit authorization.
- `gold` and `diamond` always have a baseline, an operator decision and a reproducible context; `red`, `bronze`, `silver` and `unknown` never masquerade as an approval.
- `diamond` renewal requires an explicit operator instruction that names the surface/function ID and the dimension; `gold` may use a scoped temporary authorization.
- `focus` changes prioritization only; it never changes scope, quality, protection or permission.
- `authorized_dimension` is always narrower than or equal to the set of affected dimensions.
- `preserved_dimensions` must have proof after the change, including indirect effects.
- A new approval never deletes the previous approval or baseline.
- A baseline is not valid without its context fingerprint and proof references.
- A copied inspector bundle must contain a stable `surface_id` or `target_id`, selector candidates, route, viewport/state context, commit when available, and a local evidence reference.
- The copied bundle is one JSON document: structured fields are canonical, while `agent_prompt_markdown` is generated from those fields and is never maintained separately.
- A changed shared dependency re-evaluates every dependent protected surface.
- Every `function_id` resolves to zero or more surfaces and dependencies; every user-visible function has at least one linked surface. A function with no surface is always `internal` and cannot be annotated in the UI.
- A surface linked to several functions never has an invented single function grade: its visual summary is `mixed` until the operator explicitly records a batch assessment.
- A UI filter changes no persisted annotation and cannot hide a protected conflict from preflight.
- Browser session annotations are noncanonical until a successful validated import; export and import always display whether durable state changed.
- An import validates `project` and `base_atlas_digest` before it writes. It has no partial-write mode, no silent rebase, no arbitrary path from bundle content and no authority to modify source code or Git state.
- An Atlas preflight returns `block` for an unapproved protected target, `review` for unmapped paths and `clear` only when every path is mapped without an unapproved protected impact. Lifecycle skills run it before writes and again from the actual diff before verification/shipping.
- The browser annotation flow remains functional with network disabled; no annotation, export or local import requires a CDN, remote API or credential.
- Roadmap status cannot claim `approved` when the corresponding proof is absent.
- Semantic decision IDs are stable, meaningful and globally unique inside their namespace; confirmed IDs are superseded, never silently renamed or recycled.
- Every material link is stored at its owning node and traversable through adjacent IDs; a generated index may cache the graph but never becomes an editable source of truth.
- Markdown owns human reasoning, Atlas JSON owns surface/function structure, specs own transformations and verification artifacts own proof; no layer embeds or duplicates another layer's full content.

## Links & Consequences

- `100-sg-spec` requires surfaces, dimensions, permissions and transitions in every relevant spec.
- `101-sg-ready` rejects a spec whose declared change touches a protected dimension without authorization and proof planning.
- `102-sg-start` performs the impact preflight before writing.
- `103-sg-verify` compares protected dimensions and validates cross-dimension invariants.
- `106-sg-fix` uses the baseline history to propose targeted recovery instead of global rollback.
- `005-sg-ship` refuses shipment when a protected-surface violation or unresolved `needs_review` remains.
- The atlas can drive prioritization, but it does not replace `TASKS.md`, `ROADMAP.md` or the transformation spec.
- `108-sg-browser` and the existing `web-inspector.js` provide the browser-side selection/capture adapter; the atlas remains the authority.
- The AI can crawl the `functions` tree and traverse its surface/dependency links; the operator works only with labels, visible IDs, simple quality controls and observable outcomes.
- The CLI/injector distribution copies the local Atlas stylesheet alongside the script; both assets are removed together when the inspector is disabled.
- The context generator exposes a redacted read-only browser view of the atlas; the generated context is disposable and is never a second source of truth.

## Documentation Coherence

- Document the two-tree registry schema, operator quality vocabulary, function/surface links, export/import patch protocol, authorization format and baseline-context fingerprint.
- Extend the ShipGlows design-system authority with the inspector overlay token declaration and update the code/docs map for the injector, stylesheet and importer.
- Add the atlas and protected-surface preflight to the relevant skill references and public operator guidance where appropriate.
- Link each pilot surface to its implementation, evidence and owning spec.
- Add compact decision-trace sections to the business/product templates, the Atlas schema, the spec template and proof templates; document the semantic-ID grammar and ownership boundaries once in the shared product-decision-chain contract.
- Map the read-only trace validator and its generated disposable index to their primary technical documentation, validation command and update triggers.
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
- A surface has `gold` design but a linked backend payment capability is `red`; the UI must preserve the design protection while directing work to the function.
- A user marks a whole surface functionally `red` even though its linked functions differ; require either individual notes or an explicit batch note with the affected IDs.
- An animation is the only observable part of an interaction; it is modeled as an `interaction` function linked to the visual surface, not as a fake backend capability.
- A backend availability calculation is judged wrong by its displayed result; it is modelled as an observable `capability` linked to the menu surface, while the service-only details remain internal.
- The inspector runs on an authenticated page or contains sensitive data; the bundle must be redacted/local-only and upload remains disabled.

## Implementation Tasks

- [x] Task 1: Register the first visual pilot and stable hooks.
  - Fichier: `/home/claude/best-fried-chicken/shipglows_data/workflow/atlas/approved-surfaces.json` and the Astro public surfaces.
  - Action: register five project-local surface IDs and add `data-sg-surface` / `data-sg-target` hooks.
  - User story link: make visible product boundaries discoverable without XPath-only targeting.
  - Depends on: none.
  - Validate with: JSON validation, Astro typecheck and production build (completed on 2026-07-28).

- [ ] Task 2: Establish the local Atlas overlay design authority and distribution.
  - Fichier: `injectors/web-inspector.css`, `injectors/web-inspector.js`, `cli/lib.sh`, `shipglows_data/technical/design-system-authority.md` and `shipglows_data/technical/code-docs-map.md`.
  - Action: create the local `--sg-atlas-*` token stylesheet, have the inspector consume it without inline Atlas visual literals, copy/remove the CSS with the JS injector and declare its visual authority, component bridge, layout/motion ownership and drift validation.
  - User story link: keep the annotation interface clear and consistent without modifying the inspected application's design system.
  - Depends on: Task 1.
  - Validate with: injected stylesheet availability, no Atlas CSS literals in JS outside the token source, overlay keyboard/focus states and design-system drift scan.

- [ ] Task 3: Upgrade the canonical atlas to the two-tree v2 schema.
  - Fichier: `shipglows_data/workflow/atlas/approved-surfaces.json`, `tools/shipglows_atlas_context.py` and generated `public/shipglows-atlas-context.json` in the inspected project.
  - Action: migrate the registry using the Canonical Atlas v2 Schema, preserve existing `surfaces`, add `functions` nodes/edges, surface-to-function links, user-observability, internal dependencies, quality, focus, baseline and migration aliases, then generate the redacted context and digest. Keep one canonical JSON document; generated Markdown/context views remain read-only.
  - User story link: let visual annotations inform a complete product/function map without exposing technical structure to the operator.
  - Depends on: Tasks 1–2.
  - Validate with: v1-to-v2 migration fixture, unique IDs, valid cross-tree links, redacted context generation/digest, multiple functions on one surface and internal-only function fixtures.

- [ ] Task 4: Define quality, authorization and impact policies.
  - Fichier: shared atlas schema/reference plus `skills/101-sg-ready/`, `skills/102-sg-start/`, `skills/103-sg-verify/`, `skills/106-sg-fix/` and `skills/005-sg-ship/` integration points.
  - Action: derive protection from the six quality levels, retain `structure`/`behavior` as internal impact categories, add scoped permissions, baseline renewal rules and hard stops for `gold` / `diamond`.
  - User story link: keep operator intent authoritative while preventing a result-level request from hiding shared or backend impact.
  - Depends on: Task 3.
  - Validate with: copy-only authorization that rejects design/structure impact; `diamond` change rejection without named operator instruction; red function linked to gold design.

- [ ] Task 5: Build the inspector Atlas mode.
  - Fichier: `injectors/web-inspector.js`, injection path in `cli/lib.sh`, project layouts/components and atlas adapter tooling.
  - Action: add a dev/preview-only Atlas toggle that overlays registered surfaces, displays their stable IDs, cycles `Copy` and `Design` quality on click, opens individual linked functions from `Fonction`, supports `focus`, and filters the overlay by `Toutes`, `Copy`, `Design` or `Fonction` without mutating data.
  - User story link: let the operator annotate a visible result without memorising an ID or navigating technical architecture.
  - Depends on: Tasks 2–4.
  - Validate with: overlay restricted to registered targets, quality cycle persistence, filter isolation, multiple-function panel, unknown/unregistered target flow and keyboard/mouse accessibility.

- [ ] Task 6: Export annotations locally and import them atomically into the project atlas.
  - Fichier: `injectors/web-inspector.js`, `tools/shipglows_atlas_import.py`, `cli/lib.sh`, atlas adapter tooling and project evidence manifest.
  - Action: keep browser changes in memory, export a non-executable v2 patch with base digest, validate and atomically merge it through an explicit project-local importer, generate the Markdown handoff locally and create baselines only for `gold` / `diamond`.
  - User story link: make every judgement durable and portable without granting arbitrary browser write access to source files.
  - Depends on: Tasks 3–5.
  - Validate with: offline export/import round-trip, v1 diagnostic compatibility, stale-digest rejection without writes, no selector-only baseline, generated-Markdown anti-drift and context mismatch to `needs_review`.

- [ ] Task 7: Harden privacy and scope boundaries.
  - Fichier: `injectors/web-inspector.js`, injection path in `cli/lib.sh`, inspector documentation/tests.
  - Action: remove automatic Eruda/CDN loading from the default injector path, keep annotation/export/import local by default, require separate explicit configuration for optional diagnostics/capture/upload, redact credentials/cookies/authenticated payloads, prevent internal function details appearing in the operator UI and keep injection dev/preview only.
  - User story link: preserve trustworthy annotations without leaking private UI data or technical complexity.
  - Depends on: Tasks 5–6.
  - Validate with: offline startup, no-network annotation/export, redaction fixture, disabled optional integration path, internal-node invisibility and injected-runtime scope check.

- [ ] Task 8: Resume and verify the Best Fried Chicken pilot on an available server.
  - Fichier: project checklist and local evidence under `/home/claude/best-fried-chicken/shipglows_data/workflow/`.
  - Action: execute the deferred browser/functional proof from the resume packet; do not claim an approved baseline before it passes.
  - User story link: prove that visible annotations, function links and protection gates work on a real application.
  - Depends on: Tasks 2–7 and a usable dev/preview server.
  - Validate with: all `ATLAS-001` through `ATLAS-014`, desktop/mobile representative states and one intentional protected regression.

- [x] Task 9: Guide business owners into durable product framing.
  - Fichier: canonical business/product/GTM/brand templates, shared guided-discovery reference, `300-sg-docs`, `305-sg-init` and bootstrap workflow.
  - Action: replace one-sentence/stack inference with progressive evidence-led questioning, proposed synthesis, explicit confirmation and journey-to-capability traceability.
  - User story link: let a business owner who cannot formulate a complete specification co-create the product map without losing ownership of the decisions.
  - Depends on: shared cartography doctrine.
  - Validate with: `ATLAS-015` through `ATLAS-018` contract test plus metadata, skill and synchronization audits.

- [x] Task 10: Add the lightweight BMAD decision discipline.
  - Fichier: shared product-decision-chain reference, product template, guided discovery contract and the design/spec/readiness/execution/verification/closure/review/docs owner skills.
  - Action: establish traceability, cross-contract coherence, critical moments, change propagation, focused deepening and evidence-backed learning without importing BMAD roles, party mode or document ceremony.
  - User story link: let the operator change direction and improve the product without hidden contradictions, orphan work or repeated mistakes.
  - Depends on: Task 9 and the Atlas cartography lifecycle.
  - Validate with: `ATLAS-019` through `ATLAS-025` contract tests, metadata lint, skill audit, budget and runtime sync.

- [ ] Task 11: Materialize the canonical decision chain in the corpus.
  - Fichier: shared product-decision-chain reference; canonical business/product, spec and proof templates; Atlas schema/tooling; read-only product-trace validator; generated-index adapter; owner skills and code/docs map.
  - Action: define the semantic ID grammar and node ownership, add compact adjacent-link fields to each owning artifact, add `upstream_ids`/`spec_ids` to Atlas nodes and `covers_ids` to proofs, generate a disposable cross-corpus view, and report broken, duplicate, orphaned, superseded or uncovered chains without automatically rewriting operator-confirmed meaning.
  - User story link: let the operator and a fresh agent see why a product area exists, what remains to build and which proof validates it without maintaining a second database.
  - Depends on: Tasks 9–10 and the existing Atlas v2 schema.
  - Validate with: `ATLAS-026` through `ATLAS-032`, template fixtures, valid/broken graph fixtures, metadata lint, skill audit, budget, runtime sync and `git diff --check`.

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
- [ ] AC-16: In Atlas mode, the operator sees only registered semantic surfaces, their readable IDs and the three controls `Copy`, `Design`, `Fonction`.
- [ ] AC-17: Each operator-facing quality control follows the exact `unknown` → `red` → `bronze` → `silver` → `gold` → `diamond` cycle, while `focus` remains independent.
- [ ] AC-18: The global dimension filter changes only the visible overlay; it preserves all annotations and never bypasses a protection preflight.
- [ ] AC-19: One surface can link several functions, each receives an individual function evaluation, and a divergent surface summary is rendered as `mixed` rather than guessed.
- [ ] AC-20: An observable backend capability can be evaluated from the linked user result, while a non-observable internal function cannot appear in the operator-facing Atlas mode.
- [ ] AC-21: `gold` and `diamond` create/reuse a reproducible baseline; `diamond` renewal requires a direct operator instruction naming the ID and dimension.
- [ ] AC-22: A fresh agent on another server can resume deferred verification from this spec without requiring the original conversation, a remembered identifier or an unstated test decision.
- [ ] AC-23: Browser annotations are session-local until explicit export; a validated local import is the only way they modify the canonical project atlas.
- [ ] AC-24: A stale atlas digest, foreign project ID, malformed annotation or conflict results in zero registry writes and an actionable import report.
- [ ] AC-25: Atlas mode starts and exports annotations with network disabled; it makes no default CDN, upload, cookie or `localStorage` call.
- [ ] AC-26: Atlas visual values resolve through the declared local `--sg-atlas-*` token layer, which is copied and removed with the inspector assets.
- [ ] AC-27: The generated browser context exposes only redacted operator-facing surface/function data, carries the canonical atlas digest and causes Atlas mode to fail closed when missing or invalid.
- [x] AC-28: The four canonical context templates elicit business identity, customer need/journeys, capabilities/scope, GTM and brand decisions while separating confirmed truth, evidence, hypotheses and unknowns.
- [x] AC-29: Documentation bootstrap and update load one shared guided-discovery contract and cannot treat technical-stack inference as confirmed business truth.
- [x] AC-30: A confirmed journey can be traced into observable product capabilities and candidate Atlas surface/function IDs without prescribing code architecture.
- [x] AC-31: The operator is guided one thematic decision at a time and can confirm, correct or deepen the proposed synthesis before it is persisted.
- [x] AC-32: Material product decisions reuse a trace chain from business goal to proof and do not create a parallel source-of-truth registry.
- [x] AC-33: Readiness detects material contradictions between business, product, GTM, brand, UX, architecture, Atlas, specs and proof before implementation.
- [x] AC-34: A changed decision produces explicit before/after, affected artifacts and IDs, preserved invariants and proof impact before code changes.
- [x] AC-35: Critical experience moments identify the desired and avoided emotion, observable capability/surface/function and required evidence.
- [x] AC-36: Focused deepening applies at most one relevant lens before returning to the normal guided loop.
- [x] AC-37: Retrospective learning records evidence, applicability and a future verification hook; local opinion cannot silently become global doctrine.
- [x] AC-38: ShipGlows does not import simulated role-play, party-mode orchestration, permanent A/P/C menus or exhaustive BMAD document ceremony.
- [ ] AC-39: Goals, needs, journeys, moments and capabilities use stable semantic IDs with explicit owning documents; Atlas, specs and proofs reuse their own existing stable identities.
- [ ] AC-40: Every material node stores only its direct upstream/downstream links, while a generated disposable index can reconstruct and traverse the complete chain bidirectionally.
- [ ] AC-41: Business/product Markdown remains human-readable, Atlas JSON contains no duplicated narrative Markdown, and no generated graph becomes an editable source of truth.
- [ ] AC-42: A read-only validator detects invalid grammar, duplicate IDs, missing references, forbidden cycles, material orphans and missing proof links with file/section-level diagnostics.
- [ ] AC-43: Superseding a confirmed decision preserves its ID, prior statement/evidence and replacement link; no retired or superseded ID is silently renamed or reused.
- [ ] AC-44: Specs declare the affected decision/Atlas IDs, customer outcome, before/after when applicable, preserved invariants and expected proof IDs before readiness can pass.
- [ ] AC-45: Verification artifacts use explicit `covers_ids`, allowing proof-to-requirement and requirement-to-proof traversal without relying on test-name inference alone.
- [ ] AC-46: Existing projects can adopt the format progressively; untouched legacy prose produces scoped gaps/warnings rather than an automatic mass rewrite or invented business decisions.

## Test Strategy

- Registry contract tests: v1-to-v2 migration, surface/function IDs, lifecycle transitions, aliases, quality cycle, focus and deduplication.
- Import contract tests: required fields, project/digest validation, malformed JSON, duplicate patch replay, atomic no-write conflict path and valid merge history.
- Graph tests: surface-to-function referential integrity, one-to-many links, observable backend capability, internal-only function invisibility and dependency traversal.
- Context tests: generated digest matches the registry bytes, visible IDs resolve, backend dependencies/private notes remain absent and an invalid context disables Atlas mode without disabling diagnostics.
- Scope tests: direct and indirect impact resolution, protected hard stop, temporary authorization expiry, `gold` versus `diamond` renewal and focus non-escalation.
- Evidence tests: context fingerprint mismatch, missing proof, `needs_review` transition and dimension-specific renewal.
- Browser/golden tests: representative mobile/desktop themes and default/loading/error/focus states, Atlas layer filters and multi-function selection.
- Recovery test: introduce a design regression after a copy-only change and produce a targeted repair proposal.
- Inspector adapter tests: semantic target resolution, selector fallback, v1/v2 bundle migration, annotation cycle, function panel, export counter, local patch generation, offline startup and optional-integration opt-in guard.
- Documentation checks: metadata lint, diff check and cross-links from lifecycle skills and project governance.
- Product-trace contract tests: semantic ID grammar, namespace uniqueness, adjacent-link extraction from Markdown/JSON, complete-chain reconstruction, broken reference, orphan, cycle, supersession history, explicit proof back-link and generated-index non-authority.

## Risks

- Overly granular mapping could create maintenance burden; mitigate with stable IDs and a five-to-ten-surface pilot.
- Visual snapshots can be noisy; mitigate with deterministic environments and human review, not arbitrary thresholds.
- Shared dependencies can create broad blast radius; mitigate with impact graph and protected-by-default hard stops.
- Multiple dimensions in one file complicate recovery; mitigate with dimension-specific evidence and targeted patches.
- A stale registry can create false confidence; mitigate with verification of changed paths and `needs_review` on environment drift.
- XPath/CSS selectors can become stale; mitigate by making registry IDs authoritative and selectors diagnostic fallbacks.
- The existing inspector loads third-party browser scripts and contains an optional ImgBB upload path; mitigate by limiting injection to development/preview and making local-only evidence the default.
- A simple colour may be mistaken for a permission; mitigate with the fixed quality-to-protection policy and visible legend before the first interactive release.
- A function score may be wrongly attached to a whole section; mitigate with individual function IDs, explicit batch notes and `mixed` summaries rather than inferred aggregation.
- A backend capability may expose technical details or sensitive data; mitigate by showing only the observable outcome and never rendering internal dependencies in operator mode.
- A deferred verification may be falsely remembered as passed; mitigate with the explicit resume packet and a hard rule that the current pilot has no approved baselines.
- A browser session may be mistaken for saved project state; mitigate with a non-dismissible pending-export indicator and a project-side digest-validated import report.
- A project may contain an older injected JS file without its matching stylesheet; mitigate with paired asset version metadata and fail-closed Atlas-mode startup when the local stylesheet is unavailable.
- A sequential or implementation-derived ID can become meaningless after refactoring; mitigate with semantic business slugs, explicit supersession and no ID recycling.
- Duplicating the full graph in every document can make the corpus unreadable and divergent; mitigate with adjacent links only and a generated disposable index.

## Execution Notes

- The initial implementation should remain ShipGlows-native and repository-readable.
- External tools are patterns to learn from, not runtime dependencies.
- The project atlas is the product source of truth; the spec is the temporary transformation contract.
- `305-sg-init atlas <project>` owns the smallest useful draft map; `100-sg-spec` names map transitions, `102-sg-start` maintains mapping alongside code, and `309-sg-tasks` reads it as a roadmap view. The detailed semantic-ID policy is `skills/references/atlas-cartography-lifecycle.md`.
- Atlas creation begins from the customer: recover business identity, customer need and the priority value journey from the project corpus, then ask only concise operator-owned business questions before deriving planned nodes.
- Decision-chain materialization follows artifact ownership: business goals stay in the business contract; needs, journeys, moments and capabilities stay in the product contract; surfaces/functions stay in Atlas; transformations stay in specs; proof coverage stays in verification artifacts. Only adjacent IDs cross those boundaries.
- Prefer semantic slugs over sequential IDs for new business/product nodes. Preserve existing stable IDs when already meaningful; migration proposes aliases or supersession instead of renumbering the corpus.
- No new public skill is required for the pilot; extend shared references and existing lifecycle gates first.
- The inspector is a dev/preview annotation adapter, not a second product map or approval authority; it reads and writes only through the canonical atlas adapter.
- The first interactive increment has a static-tool exception for Sentry: the injector creates no production runtime and does not send telemetry. It must provide visible export/import error messages and safe local console diagnostics; no secrets or annotation payloads are logged.
- No external browser integration is needed for the first interactive increment. Use current browser standards only for DOM, CSS custom properties, `Blob`, download and clipboard fallbacks; re-open the freshness gate before adding any SDK, remote capture library or API.
- Keep the operator vocabulary in French (`Copy`, `Design`, `Fonction`) even when machine fields remain English for stable contracts.
- Conversation shorthand remains a fallback for advanced operation: `sg-copy :gold <surface-id>`, `sg-design :gold <surface-id>`, `sg-surface :diamond <surface-id>`, and `:focus <surface-id>`; the visual interface is the preferred discovery mechanism.

## Deferred Verification And Resume Context

Verification state: deliberately deferred by operator decision on 2026-08-02. This is neither a pass nor a failure and must never be reported as an approved pilot.

Why it is deferred: the remaining browser/functional proof needs a usable development or preview server. The next environment may be a different server; it must re-establish local facts rather than trusting generated output or prior browser state.

Current pilot facts to preserve:

- Project: `best-fried-chicken`, repository `/home/claude/best-fried-chicken`, branch `main`, point-in-time HEAD `39ecced06af818367931c03ac400740ba22815a7` on 2026-08-02. This SHA is context, not a rollback instruction; inspect the current worktree before changing anything.
- Active public implementation: Astro `site/`; the Flutter prototype is paused and is not required for this pilot.
- Registered visual pilot surfaces: `navigation.header`, `home.hero`, `menu.catalog`, `checkout.payment`, `order.follow-up`. Their target IDs are respectively `navigation.header.primary`, `home.hero.primary`, `menu.catalog.primary`, `checkout.payment.primary`, `order.confirmation.primary`.
- Current registration state: all five are `planned`, all existing dimensions are `fluid`, and `approval` is `null`. No operator judgement, `gold`, `diamond` baseline or functional-node tree has been recorded yet.
- Existing completed local proof dated 2026-07-28: JSON syntax validation, Astro typecheck and Astro build passed. A broad lint command was not usable because it scanned generated `.vercel` output; this is not evidence that source lint passed or failed.
- Existing project checklist: `/home/claude/best-fried-chicken/shipglows_data/workflow/test-checklists/approved-surface-protection-and-product-atlas.md`. Extend it for `ATLAS-008` to `ATLAS-014`; do not replace the earlier scenarios.

Required restart sequence on the future server:

1. Read this spec and the Best Fried Chicken agent/context documents; confirm the active Astro source, registry and stable hooks still match the recorded IDs.
2. Inspect the worktree and current commit. Preserve unrelated operator changes; do not use a global checkout or reset to the recorded SHA.
3. Run the local JSON/typecheck/build evidence again before browser proof. Resolve generated-output lint noise by narrowing lint to source or documenting its exclusion; do not hide it.
4. Start a local dev or preview environment with paired local inspector CSS/JS injection limited to development/preview. Confirm Atlas starts offline and test only non-auth public routes unless explicit permission and redaction rules are available.
5. Verify the five registered surfaces at representative desktop/mobile viewports and default/loading/error/focus states where applicable; then execute quality filtering, local export/import, protected-regression, multi-function and observable-backend scenarios.
6. Persist only redacted local evidence, update the checklist with pass/fail and residual risk, and keep the pilot unapproved if any required scenario is missing.

The future agent needs no remembered conversation detail beyond this section. If the registry or source layout has changed, it must first migrate IDs and graph links, record aliases, and re-run readiness before testing.

## Open Questions

None. Decisions resolved for v2:

- Canonical registry: one project-owned JSON index with separate `surfaces` and `functions` subtrees; Markdown atlas/roadmap views are generated and never edited as a second source of truth.
- Operator view: use only `Copy`, `Design`, `Fonction`, visible stable IDs, quality cycle and filters. Do not expose technical trees, backend dependencies or internal-only functions.
- Quality: `unknown`, `red`, `bronze`, `silver`, `gold`, `diamond`; `focus` is independent. The exact protection policies are stated in the Inspector Bundle Schema.
- Function tree: a surface may link several interactions/capabilities. Observable backend outcomes may be annotated through their linked surface; unobservable internal functions remain AI-only.
- Persistence: browser interactions are session-only. An explicit JSON patch export and a digest-validated, atomic local project import are required to change the atlas; no application write endpoint, cookie or browser storage is used.
- Overlay authority: `injectors/web-inspector.css` is the local token source for the Atlas overlay. Its assets are paired with the injected script, and the first increment makes no remote script/style/capture dependency.
- Pilot project: `best-fried-chicken` (`/home/claude/best-fried-chicken`). The active Astro pilot has five registered slots listed in the deferred verification packet. Browser/functional verification is deliberately deferred until a suitable server is available.
- Context fingerprint: full commit SHA, route, locale, viewport width/height/DPR, browser engine/version, OS/runtime, font asset hashes, design-token version, feature-flag/config hash and deterministic fixture/data-set ID. Unsupported fields are recorded as `null` with a reason, never silently omitted.
- Corpus trace representation: semantic namespaced IDs, compact Markdown tables in the owning business/product sections, adjacent references in Atlas/spec/proof artifacts and a generated read-only index. There is no hand-maintained master graph and no Markdown narrative embedded in Atlas JSON.
- Migration policy: validate and enrich only the material scope touched by a chantier; do not mass-number existing prose or invent operator decisions to obtain a green report.

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
| 2026-07-28 19:09:00 | 102-sg-start | GPT-5 Codex | Implemented the Best Fried Chicken pilot atlas, stable `data-sg-surface`/`data-sg-target` hooks on the five pilot zones, and the project proof checklist. | Implementation slice complete; local typecheck/build and JSON validation pass. Browser/golden proof remains for verification. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 13:01:00 | 100-sg-spec | GPT-5 Codex | Integrated the operator-facing Atlas mode, six-level quality cycle, global dimension filters, separate crawlable function graph, multiple-function links, observable backend outcomes and a server-independent verification resume packet. | v2 contract is self-contained; the prior ready decision must be renewed before the new implementation scope starts. Browser/functional pilot proof remains deliberately deferred. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-08-02 13:13:28 | 101-sg-ready | GPT-5 Codex | Re-reviewed the v2 scope against the existing injector, injection path, privacy boundary and visual-authority contract. | Not ready: the spec must define the durable local import/export path for browser annotations and declare the inspector overlay token authority before code can safely persist or render the new UI. | /100-sg-spec Approved Surface Protection And Product Atlas |
| 2026-08-02 13:14:06 | 100-sg-spec | GPT-5 Codex | Closed the readiness gaps with an explicit session/export/import contract, atomic digest-conflict policy, local overlay token authority, paired asset distribution and offline-first inspector rule. | Contract repaired; independent readiness review required before code. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-08-02 13:17:30 | 101-sg-ready | GPT-5 Codex | Re-reviewed the repaired v2 contract, including the canonical schema, redacted browser context, offline-first assets, explicit import boundary, token authority and deferred-proof packet. | Ready: a fresh agent can implement without a hidden persistence, privacy, design-system or server-state decision. | /102-sg-start Approved Surface Protection And Product Atlas |
| 2026-08-02 13:27:11 | 102-sg-start | GPT-5 Codex | Implemented the first v2 foundation: redacted-context generator, digest-validated atomic importer, local Atlas token stylesheet, offline-first overlay source and Best Fried Chicken registry migration/context generation. | Partial: project activation/distribution, formal tests and browser proof remain. Local syntax, context generation and isolated import-round-trip checks pass. | /102-sg-start Approved Surface Protection And Product Atlas |
| 2026-08-02 13:30:19 | 102-sg-start | GPT-5 Codex | Wired the Best Fried Chicken Astro pilot behind an explicit development flag, distributed the paired local assets and declared the overlay design authority/documentation mapping. | Partial: static/type/build and drift evidence pass; browser interaction and the deferred functional scenarios still require the future dev/preview server. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 14:16:03 | 102-sg-start | GPT-5 Codex | Hardened the sole Atlas write boundary: strict patch/annotation validation, exact target/route/selector checks, quality-cycle enforcement, reciprocal graph validation, relative evidence restrictions and mandatory composite baselines for `gold`/`diamond`; added executable regression fixtures and made redacted context generation fail closed for invalid stored protection. | Implemented for this guardrail slice: malformed, stale and under-evidenced patches cannot write; valid protected baselines and redaction are covered by local tests. Browser interaction and functional proof remain deferred to the recorded server resume packet. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 14:55:35 | 309-sg-tasks | GPT-5 Codex | Reconciled the operational tracker with the actual Atlas chantier state. | In progress: local registry/overlay/import guardrails are implemented, but the operator-friendly protected-baseline flow, lifecycle-gate integration and deferred Best Fried Chicken browser proof remain. | /102-sg-start Approved Surface Protection And Product Atlas |
| 2026-08-02 15:09:22 | 102-sg-start | GPT-5 Codex | Implemented the operator-friendly protected-baseline flow: Gold/Diamond confirmation names the target and dimension; explicit clean-Git import derives the full current SHA, context fingerprint, import evidence reference and renewal link without creating a commit or copying source code. | Implemented for this local slice: six regression tests cover successful clean-SHA protection and dirty-worktree refusal; syntax, drift and Best Fried Chicken type/build checks pass. Rendered browser proof remains deferred. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 15:57:05 | 102-sg-start | GPT-5 Codex | Added the Atlas impact resolver and lifecycle gate: BFC now maps its pilot files/styles to surfaces/functions, while readiness, implementation, bug-fix, verification and ship contracts require a `clear` preflight or exact documented authorization. | Implemented for this local slice: automated coverage proves protected impact blocks, exact authorization clears it and unknown paths require review. Browser/functional pilot proof remains deferred. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 16:34:57 | 900-shipglows-core | GPT-5 Codex | Formalized Atlas cartography ownership across existing skills: explicit `305-sg-init atlas` draft creation, spec transition naming, implementation-time map maintenance, and roadmap reading without tracker replacement. | Implemented: semantic IDs remain product-level rather than DOM-level, all agent-created draft assessments remain unknown, and the shared lifecycle reference records pressure scenarios. Browser/functional pilot proof remains deferred. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 16:36:00 | 900-shipglows-core | GPT-5 Codex | Made Atlas creation customer-led: `305-sg-init atlas` first recovers business identity, customer need and priority journey, then proposes planned surfaces/functions; specs now carry the customer outcome. | Implemented: the agent guides the operator with concise business questions instead of a technical feature questionnaire, while business/product documents remain the durable framing source. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 17:05:00 | 100-sg-spec | GPT-5 Codex | Added BMAD-inspired progressive discovery, evidence states, journey-to-capability traceability and four pressure scenarios to the existing Atlas contract. | Ready: the bounded documentation/skill slice has explicit behavior, owners and proof without changing the deferred browser-test decision. | /900-shipglows-core build guided-business-product-discovery |
| 2026-08-02 17:11:00 | 900-shipglows-core | GPT-5 Codex | Expanded the four canonical context templates and wired one shared guided-discovery contract into documentation initialization and maintenance. | Implemented: vague or partial founder context now leads to progressive synthesis and confirmation rather than questionnaire dumps or stack-based business guesses. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 18:50:00 | 100-sg-spec | GPT-5 Codex | Added the lightweight BMAD decision discipline: canonical trace chain, cross-contract coherence, critical experience moments, decision-change propagation, focused deepening and evidence-backed lesson replay. | Scope is explicit, reuses existing artifacts/IDs and excludes role-play, permanent menus and parallel registries. | /101-sg-ready Approved Surface Protection And Product Atlas |
| 2026-08-02 18:55:00 | 101-sg-ready | GPT-5 Codex | Reviewed the new decision-discipline slice for ownership, ambiguity, source-of-truth duplication, operator authority and scenario proof. | Ready: the slice has bounded owners, seven pressure scenarios and no unresolved product, persistence or security decision. | /900-shipglows-core build product-decision-chain |
| 2026-08-02 19:08:00 | 900-shipglows-core | GPT-5 Codex | Implemented one shared product-decision chain and activated it across design, spec, readiness, execution, verification, docs, closure and review owners. | Implemented: ShipGlows now checks coherence, propagates changed intent, maps critical moments and replays evidence-backed lessons without importing BMAD ceremony. | /103-sg-verify Approved Surface Protection And Product Atlas |
| 2026-08-02 19:20:50 | 100-sg-spec | GPT-5 Codex | Materialized the conceptual decision chain into an implementable corpus contract: semantic IDs, artifact ownership, adjacent links, generated read-only traversal, progressive migration and explicit proof back-links. | Draft scope is autonomous and scenario-backed; its new representation and validator lot requires independent readiness review before implementation. | /101-sg-ready Approved Surface Protection And Product Atlas |

## Current Chantier Flow

- 100-sg-spec: completed — v2 contract now includes durable annotation persistence, redacted context and local overlay design authority.
- 101-sg-ready: completed — the v2 implementation contract has no material unresolved ambiguity.
- 102-sg-start: implemented for the current local slice — v2 registry, redacted context, strict atomic import guardrails, clean-Git protected-baseline flow, impact resolver, lifecycle-gate contract, regression fixtures, overlay source and opt-in Astro pilot activation exist.
- 900-sg-shipglows-core: implemented — shared cartography doctrine and owner routing now preserve how a draft is created, reviewed, maintained, and read as roadmap.
- 900-sg-shipglows-core guided discovery: implemented — canonical templates and owner skills now guide business identity, customer need, journeys, capabilities, GTM and brand through explicit evidence states and operator confirmation.
- 900-sg-shipglows-core product decision chain: implemented — material decisions now retain cross-contract trace, change impact, critical moments and evidence-backed learning through existing canonical artifacts.
- 100-sg-spec corpus trace materialization: completed — Task 11 and AC-39 through AC-46 now define exactly how the chain is represented, linked, validated and migrated without a parallel source of truth.
- 101-sg-ready corpus trace materialization: pending — the new Task 11 contract must be independently reviewed before implementation.
- 103-sg-verify: deferred — browser/functional pilot proof waits for a usable future dev/preview server; it must resume from the recorded packet.
- 104-sg-end: pending.
- 005-sg-ship: pending.
