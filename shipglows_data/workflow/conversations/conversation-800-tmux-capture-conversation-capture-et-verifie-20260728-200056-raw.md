# Conversation 800-tmux-capture-conversation - capture et verifie

- Captured at: `2026-07-28 20:24:39 UTC`
- tmux session: `0`
- tmux source: `current pane`
- tmux window index: `:7`
- tmux pane index: `.1`
- tmux window name: `$`
- capture mode: `scrollback`
- prompt count: `14`
- first prompt: `Est-ce que tu peux m'expliquer c'est quoi le master, les`
- last prompt: `verifie que la convest`

/home/claude/home/claude/home/claude

  Chaque domaine pourra avoir son propre master, ses instances par
  projet et ses cycles. TASKS.md restera réservé aux actions
  concrètes, pas au suivi global des contrôles.

  J’ai aussi ajouté la règle importante : un domaine applicable
  sans master défini apparaît comme needs_review, jamais comme
  terminé.

  Vérifications passées : 9 tests Python, 29 tests TUI, metadata
  lint et git diff --check.

  Le chantier reste partiel tant que les masters détaillés ne sont
  pas tous écrits. Suite possible :

  1. Définir le master performance.
  2. Définir les masters marketing/copywriting.
  3. Passer à la vérification formelle du modèle actuel.


› Est-ce que tu peux m'expliquer c'est quoi le master, les
  instances par projet et les cycles ? Je n'ai pas compris.


• 🧱 CHANTIER (local) : comprendre le modèle
  🎯 VERDICT (17:56) : expliqué

  Imagine une recette de cuisine :

  - Le master est la recette officielle.
  - L’instance par projet est la recette utilisée pour un projet
    précis.

  - Le cycle est une nouvelle réalisation de cette recette à une
    période donnée.

  Exemple avec le SEO technique :

  Le master contient les étapes générales :

  1. Vérifier robots.txt
  2. Vérifier le sitemap
  3. Vérifier les balises importantes
  4. Vérifier les erreurs 404
  5. Vérifier les performances
  6. Vérifier l’indexation

  Pour le projet site-restaurant, on crée une instance :

  site-restaurant-seo-2026-07.md

  Elle indique :

  - les contrôles terminés ;
  - ceux qui restent ;
  - les preuves ;
  - les blocages ;
  - la progression, par exemple 4/6.

  Le cycle correspond à une exécution de la checklist :

  - launch-2026-07 : contrôle avant publication ;
  - monthly-2026-08 : contrôle mensuel ;
  - quarterly-2026-Q4 : contrôle trimestriel.

  On ne réinitialise jamais l’ancienne instance. On en crée une
  nouvelle, afin de conserver l’historique.

  Donc :

  Master SEO technique
          ↓
  Projet A — cycle lancement — terminé
  Projet A — cycle mensuel août — en cours
  Projet B — cycle lancement — bloqué

  Les tâches ne contiennent que les actions concrètes découvertes
  pendant le contrôle, par exemple :

  > Corriger la redirection de /ancienne-page.

  La checklist répond à : « où en est le domaine ? »
  La tâche répond à : « quelle action précise faut-il exécuter ? »


› Bien vu ! Tu peux terminer la rédaction des autres masters s'il
  te plaît. Si tu veux, utilise des agents en parallèle.


• Oui. Je vais compléter les masters manquants par domaine, en
  gardant un master par responsabilité et en séparant clairement
  les contrôles techniques des contrôles marketing, copywriting et
  contenu. Je n’utiliserai pas de parallélisme improvisé : les
  lots ne sont pas indépendants tant que le contrat commun n’est
  pas stabilisé, et je garderai une structure homogène pour que
  l’app puisse tous les lire de la même manière.

──────────────────────────────────────────────────────────────────

• Je vais créer les paires playbook + checklist master pour les
  domaines encore absents : performance, analytics, marketing,
  copywriting, contenu éditorial, production et maintenance. Le
  contenu SEO restera explicitement séparé du SEO technique.
  Chaque master aura des identifiants stables, une règle de
  complétion et une cadence applicable.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (17:59) : masters rédigés

  J’ai ajouté les 7 paires playbook + checklist master
  manquantes :

  - performance
  - analytics
  - marketing
  - copywriting
  - contenu éditorial
  - production
  - maintenance

  Chaque master possède :

  - son périmètre ;
  - ses étapes ordonnées ;
  - ses contrôles avec identifiants stables ;
  - sa règle de complétion ;
  - ses exceptions ;
  - sa cadence et ses preuves attendues.

  Le SEO technique reste limité à crawl, indexation, rendu,
  métadonnées et performance technique. Les mots-clés, la
  stratégie éditoriale et la création de contenu restent séparés.

  Validation passée : 17 fichiers metadata lintés, 9 tests Python
  réussis, git diff --check réussi.

  Les masters marketing, copywriting et contenu sont des premières
  versions opérationnelles : ils pourront être affinés lorsqu’ils
  seront utilisés sur un vrai projet.

  Suite logique :

  1. Créer les premières instances pour un projet réel.
  2. Ajouter les masters dans l’interface de statut du projet.
  3. Faire la vérification finale du chantier.


› 1


• Je lance la première étape : créer les premières instances à
  partir des masters. Je vais d’abord repérer le projet gouverné
  déjà présent dans le dépôt et ses domaines déclarés, puis
  générer les instances sans inventer de progression ni cocher de
  contrôles.

──────────────────────────────────────────────────────────────────

• 🚧 CHANTIER (local) : premières instances de projet
  🎯 VERDICT (18:01) : choix du projet requis

  Le registre contient plusieurs projets. Je recommande de
  commencer par jarrettelacoke.fr, car il possède déjà le
  périmètre le plus complet : technique, design, copy, SEO, GTM,
  dépendances et performance.

  1. jarrettelacoke.fr — recommandé
  2. nantes-gratuit
  3. Un autre projet du registre — indique-moi son nom

  Dès que le projet est choisi, je créerai ses instances par
  domaine avec tous les contrôles à not_started, sans inventer de
  progression.


› ok


• Je prends jarrettelacoke.fr comme projet cible, conformément à
  la recommandation précédente. Je vérifie d’abord son corpus de
  gouvernance et ses surfaces réellement déclarées, puis je crée
  les instances dans son projet, toutes initialisées à
  not_started.

──────────────────────────────────────────────────────────────────

• 🚧 CHANTIER (local) : premières instances de projet
  🎯 VERDICT (18:03) : projet inaccessible

  Le projet recommandé jarrettelacoke.fr correspond à /home/
  claude/quit-coke, mais ce dossier n’existe pas dans
  l’environnement actuel. Je ne peux donc pas créer ses instances
  au mauvais endroit.

  1. Tu me redonnes le chemin actuel du projet.
  2. Tu choisis un projet présent dans cet environnement.
  3. Tu m’autorises à créer une fiche d’instance ShipGlows
     provisoire uniquement dans ce dépôt, sans la rattacher à un
     vrai projet.


› on la deja choisi oui


• Tu as raison : le projet choisi est bien jarrettelacoke.fr.

  Le problème n’est pas le choix, c’est que son chemin
  enregistré /home/claude/quit-coke n’est pas présent dans
  l’environnement actuel. Je garde donc ce projet comme cible et
  je ne te le redemanderai pas.

  Dès que le dépôt est accessible, je créerai ses instances
  initiales par domaine, toutes en not_started.


› Il est déjà accessible sur le serveur et on a déjà créé les
  instances normalement dans une autre conversation. Regarde.


• Je vais vérifier les emplacements réellement disponibles sur le
  serveur, y compris les autres corpus shipglows_data et les
  instances déjà créées, au lieu de me fier à l’ancien registre de
  projets. Je chercherai par project_id, nom de domaine et
  cycle_id pour retrouver la conversation précédente dans les
  artefacts.

──────────────────────────────────────────────────────────────────

• Oui, tu avais raison : les instances ont déjà été créées dans
  une autre conversation.

  Je les ai retrouvées ici :

  /home/claude/jarretelacoke/shipglows_data/workflow/checklist-
  instances/

  Il y en a déjà 7, toutes pour le cycle launch-2026-07 :

  - performance
  - analytics
  - marketing
  - copywriting
  - contenu
  - production
  - maintenance

  Elles sont bien initialisées à 0/total, sans contrôles cochés
  artificiellement.

  Il reste seulement à normaliser/créer les instances pour :

  - technique
  - cybersécurité
  - SEO technique
  - lancement

  🧱 CHANTIER (local) : retrouver les instances jarretelacoke.fr
  🎯 VERDICT (18:05) : instances existantes retrouvées


› vazy


• J’ai retrouvé les 7 instances existantes. Je complète maintenant
  les quatre lanes manquantes, sans recréer celles qui existent
  déjà : SEO technique, cybersécurité, lancement et technique.
  Pour la lane technique, je vais utiliser un master technique
  explicite afin de ne pas détourner la checklist de lancement.

──────────────────────────────────────────────────────────────────

• La recherche confirme que la conversation précédente a bien créé
  7 instances dans le bon dépôt : /home/claude/jarretelacoke. Je
  complète les quatre manquantes et je vais aussi normaliser les
  identifiants stables des masters concernés, car c’est nécessaire
  pour que les instances restent lisibles par l’app et
  historisables.

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:10) : instances complétées

  Tu avais raison : les 7 instances existaient déjà dans /home/
  claude/jarretelacoke.

  J’ai ajouté les 4 manquantes :

  - technique — 0/10
  - cybersécurité — 0/15
  - SEO technique — 0/28
  - lancement — 0/9

  Le projet possède maintenant 11 instances pour le cycle launch-
  2026-07. Aucun contrôle n’a été coché artificiellement.

  Le parser confirme pour chaque instance :

  - cycle correct ;
  - progression 0/total ;
  - statut not_started ;
  - prochain contrôle identifiable ;
  - aucun blocage inventé.

  Le modèle est maintenant prêt pour commencer l’exécution réelle
  des contrôles sur jarretelacoke.fr.

• Context compacted


› comment vas t elle se passer cette execution?


• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:22) : l’exécution se fera par contrôles
  successifs, projet par projet

  Le fonctionnement sera le suivant :

  1. On choisit un projet et un cycle
     Exemple : jarretelacoke.fr — cycle launch-2026-07.

  2. Chaque domaine possède sa propre instance
     Technique, cybersécurité, SEO technique, performance,
     analytics, marketing, copywriting, contenu, production,
     maintenance et lancement.

  3. On exécute les contrôles dans l’ordre prévu

     Pour chaque contrôle, on vérifie concrètement le projet :
      - not_started : pas encore vérifié ;
      - in_progress : vérification en cours ;
      - done : preuve trouvée et contrôle validé ;
      - blocked : impossible d’avancer, avec explication ;
      - not_applicable : contrôle non pertinent pour ce projet.

  4. On conserve la preuve dans l’instance Markdown

     Par exemple :

     - [x] `technical-architecture-surfaces`
       - status: done
       - evidence: `docs/architecture.md`, inspection du dépôt
       - checked_at: 2026-07-28

  5. Le prochain contrôle devient automatiquement visible

     L’outil peut alors répondre :
      - progression : 4/10 ;
      - contrôle actuel : technical-dependency-hygiene ;
      - prochain contrôle : technical-runtime-verification ;
      - blocage éventuel ;
      - dernière preuve ajoutée.

  6. Les tâches restent séparées

     Une checklist constate l’état du projet. Elle ne remplit pas
     le tracker avec toutes ses cases.

     Si un contrôle révèle qu’il faut corriger quelque chose, on
     crée une tâche concrète :

     > Corriger le robots.txt de jarretelacoke.fr

     Une fois la tâche terminée, on revient dans la checklist et
     on valide le contrôle avec sa preuve.

  7. Les cycles récurrents créent une nouvelle instance

     On ne réinitialise pas l’ancienne checklist. Par exemple :
      - launch-2026-07 : cycle de lancement ;
      - maintenance-2026-08 : cycle mensuel suivant ;
      - seo-technical-2026-Q4 : nouvel audit technique.

     L’historique reste donc traçable.

  Pour jarretelacoke.fr, l’exécution réelle commencera maintenant
  par le premier contrôle de chaque instance. Les 11 instances
  sont prêtes, mais aucune case n’a été cochée artificiellement :
  chaque validation devra être faite à partir du code, de la
  configuration, du site et des preuves disponibles.

• You’re continuing from this point in a new conversation


› on lancera les cycles tous les combien de temps a ton.avis?
  cest configurable ?


• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:27) : oui, la cadence sera configurable par
  domaine et par projet

  Je recommande cette base :

   Domaine                       Cadence recommandée
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Production / santé du site    hebdomadaire
  ────────────────────────────  ──────────────────────────────────
   Maintenance / dépendances     mensuelle
  ────────────────────────────  ──────────────────────────────────
   Cybersécurité                 mensuelle + après incident ou
                                 changement sensible
  ────────────────────────────  ──────────────────────────────────
   Performance                   mensuelle + après modification
                                 importante
  ────────────────────────────  ──────────────────────────────────
   Analytics                     mensuelle
  ────────────────────────────  ──────────────────────────────────
   SEO technique                 trimestrielle + après refonte ou
                                 changement technique
  ────────────────────────────  ──────────────────────────────────
   Marketing / copywriting       à chaque campagne ou lancement
  ────────────────────────────  ──────────────────────────────────
   Contenu éditorial             selon le calendrier éditorial
  ────────────────────────────  ──────────────────────────────────
   Lancement                     une seule fois, puis contrôle
                                 post-lancement
  ────────────────────────────  ──────────────────────────────────
   Technique                     à chaque évolution importante ou
                                 avant une mise en production

  Il faut distinguer deux choses :

  - la checklist de lancement, exécutée une fois ;
  - les contrôles cycliques, recréés à chaque nouvelle période.

  Par exemple :

  seo-technical-launch-2026-07
  seo-technical-quarterly-2026-Q4
  seo-technical-quarterly-2027-Q1

  Le modèle est donc configurable avec une cadence par instance ou
  par domaine :

  cadence: quarterly
  next_cycle: 2026-10-01
  trigger_events:
    - major_release
    - domain_migration
    - redesign

  Aujourd’hui, les cycles sont configurables manuellement via les
  fichiers Markdown. L’automatisation du calendrier — rappels,
  création automatique de la prochaine instance et affichage “à
  faire cette semaine” — sera une fonction de l’application
  ShipGlows à ajouter ensuite.


› très bien.


• Parfait. Le modèle retenu est donc :

  - des masters par domaine ;
  - une instance par projet et par cycle ;
  - une cadence configurable ;
  - des déclencheurs exceptionnels ;
  - un historique conservé ;
  - les tâches séparées des contrôles.

  La prochaine étape logique sera d’ajouter officiellement ces
  paramètres de cadence aux templates Markdown et à l’instance de
  jarretelacoke.fr.


› oui


• Je vais intégrer la cadence et les déclencheurs dans les
  templates, puis les appliquer à l’instance de jarretelacoke.fr.
  Je m’appuie sur le workflow 001-sg-build pour garder les cycles
  compatibles avec le modèle existant, sans créer de tâches
  artificielles.

• Explored
  └ Read SKILL.md (001-sg-build skill), CLAUDE.md, README.md,
         project_checklist_instance.md, chantier-tracking.md,
         reporting-contract.md, project_lifecycle.md, project-
         lifecycle-checklist-operating-model.md, seo-technical-
         launch-
         2026-07.md
    Search cadence|next_review|trigger|Current Chantier Flow|Skill
    Run
           History in project-lifecycle-checklist-contract.md
    Read project-lifecycle-checklist-contract.md, project-
    lifecycle-
         checklist-operating-model.md, project_lifecycle.md,
         shipglows_checklist_instance_status.py,
         checklistInstances.ts, performance-launch-2026-07.md
    Search cycle_kind|artifact_status|next_control|project\( in
    tests
    List rg --files
    Search checklist|lifecycle
    Search shipglows_checklist_instance_status|progress_status|
           cycle_kind in .
    Read test_shipglows_checklist_instance_status.py, project-
         lifecycle-checklist-contract.md, project-lifecycle-read-
         model.md

──────────────────────────────────────────────────────────────────

• J’ai vérifié le contrat existant : il prévoit déjà les cadences
  au niveau des contrôles, mais pas encore une déclaration claire
  de cadence au niveau d’une instance de projet. Je vais donc
  ajouter cette couche sans modifier le suivi des tâches ni la
  logique des contrôles.

• Explored
  └ Read project_lifecycle.md, project_checklist_instance.md

• Edited 4 files (+37 -4)
  └ skills/references/project-lifecycle-checklist-contract.md (+15
  -1)
      3  metadata_schema_version: "1.0"
      4 -artifact_version: "0.3.0"
      4 +artifact_version: "0.4.0"
      5  project: ShipGlows
        ⋮
    141  cycle_kind: initial
    142 +cadence_kind: monthly
    143 +cadence_anchor: 2026-07-27
    144 +timezone: Europe/Paris
    145 +trigger_events:
    146 +  - major_release
    147 +  - domain_migration
    148 +next_review: 2026-08-27
    149  status: in_progress
        ⋮
    151
    152 +Project checklist instances declare their operating caden
         ce explicitly. The
    153 +`cycle_kind` describes the current occurrence, while `cad
         ence_kind` describes
    154 +how a future occurrence is scheduled. `cycle` is used for
          a named release,
    155 +campaign or migration; `event` is used when a declared tr
         igger creates the
    156 +next occurrence. `cadence_anchor`, `timezone`, `trigger_e
         vents` and
    157 +`next_review` make the next review deterministic without
         requiring the app.
    158 +
    159  ## Lifecycle Instance Shape

  └ templates/project_checklist_instance.md (+9 -0)
    10  cycle_kind: "initial | recurring | release | migration | e
        vent"
    11 +cadence_kind: "daily | weekly | monthly | quarterly | cycl
        e | event"
    12 +cadence_anchor: "YYYY-MM-DD or event name"
    13 +timezone: "Europe/Paris"
    14 +trigger_events: []
    15 +next_review: "YYYY-MM-DD"
    16  scope: project-checklist-instance
       ⋮
    40  - Cycle kind: `initial | recurring | release | migration |
         event`
    41 +- Cadence: `daily | weekly | monthly | quarterly | cycle |
         event`
    42 +- Cadence anchor: `YYYY-MM-DD` or the event that starts th
        e cycle
    43 +- Timezone: `Europe/Paris`
    44 +- Trigger events: `-` or a comma-separated list of excepti
        onal triggers
    45  - Started: `YYYY-MM-DD`

  └ templates/project_lifecycle.md (+8 -3)
    32  - Next review: `YYYY-MM-DD`
    33 +- Operator timezone: `Europe/Paris`
    34
       ⋮
    52
    53 +Cadences use `daily`, `weekly`, `monthly`, `quarterly`, `c
        ycle` or `event`. A
    54 +cadence change applies only to future instances; historica
        l cycles remain
    55 +unchanged. Optional event triggers are declared per domain
        .
    56 +
    57  ## Linked Definitions
       ⋮
    66
    62 -| Checklist ID | Master Version | Instance Path | Cycle ID
         | Status | Progress | Current Phase | Next Action |
    63 -| --- | --- | --- | --- | --- | --- | --- | --- |
    64 -| `seo-technical` | `1.1.0` | `shipglows_data/workflow/che
        cklist-instances/seo-technical-YYYY-MM-DD.md` | `[project:
        checklist:period]` | `not_started` | `0/0` | `[phase]` | `
        [next unchecked control]` |
    67 +| Checklist ID | Master Version | Instance Path | Cycle ID
         | Cadence | Next Review | Status | Progress | Current Pha
        se | Next Action |
    68 +| --- | --- | --- | --- | --- | --- | --- | --- | --- | --
        - |
    69 +| `seo-technical` | `1.1.0` | `shipglows_data/workflow/che
        cklist-instances/seo-technical-YYYY-MM-DD.md` | `[project:
        checklist:period]` | `monthly` | `YYYY-MM-DD` | `not_start
        ed` | `0/0` | `[phase]` | `[next unchecked control]` |
    70

  └ tools/shipglows_checklist_instance_status.py (+5 -0)
    114          "cycle_kind": metadata.get("cycle_kind"),
    115 +        "cadence_kind": metadata.get("cadence_kind"),
    116 +        "cadence_anchor": metadata.get("cadence_anchor"),
    117 +        "timezone": metadata.get("timezone", "UTC"),
    118 +        "trigger_events": metadata.get("trigger_events",
         "[]"),
    119 +        "next_review": metadata.get("next_review"),
    120          "artifact_status": metadata.get("status", "draft"
         ),

• Explored
  └ Read project_lifecycle.md

• Edited ~/jarretelacoke/shipglows_data/workflow/
project_lifecycle.md (+16 -14)
     3  metadata_schema_version: "1.0"
     4 -artifact_version: "0.1.0"
     4 +artifact_version: "0.2.0"
     5  project: jarretelacoke.fr
       ⋮
    37  - Next review: `2026-08-04`
    38 +- Operator timezone: `Europe/Paris`
    39
       ⋮
    59
    59 -| Checklist ID | Master Version | Instance Path | Cycle ID
         | Status | Progress | Current Phase | Next Action |
    60 -| --- | --- | --- | --- | --- | --- | --- | --- |
    61 -| performance-project-readiness-and-monitoring | 0.1.0 | `
        shipglows_data/workflow/checklist-instances/performance-la
        unch-2026-07.md` | `jarretelacoke-fr:performance:launch-20
        26-07` | in_progress | 0/10 | Scope and baseline | Start `
        performance-scope-surfaces` |
    62 -| analytics-measurement-readiness-and-quality | 0.1.0 | `s
        hipglowz_data/workflow/checklist-instances/analytics-launc
        h-2026-07.md` | `jarretelacoke-fr:analytics:launch-2026-07
        ` | in_progress | 0/10 | Measurement plan | Start `analyti
        cs-objectives` |
    63 -| marketing-go-to-market-readiness | 0.1.0 | `shipglows_da
        ta/workflow/checklist-instances/marketing-launch-2026-07.m
        d` | `jarretelacoke-fr:marketing:launch-2026-07` | in_prog
        ress | 0/9 | Audience and positioning | Start `marketing-a
        udience` |
    64 -| copywriting-public-surface-quality | 0.1.0 | `shipglows_
        data/workflow/checklist-instances/copywriting-launch-2026-
        07.md` | `jarretelacoke-fr:copywriting:launch-2026-07` | i
        n_progress | 0/10 | Clarity and structure | Start `copy-au
        dience-context` |
    65 -| content-publication-and-editorial-operations | 0.1.0 | `
        shipglows_data/workflow/checklist-instances/content-launch
        -2026-07.md` | `jarretelacoke-fr:content:launch-2026-07` |
         in_progress | 0/10 | Preparation | Start `content-brief-a
        udience` |
    66 -| production-health-and-operations | 0.1.0 | `shipglows_da
        ta/workflow/checklist-instances/production-launch-2026-07.
        md` | `jarretelacoke-fr:production:launch-2026-07` | in_pr
        ogress | 0/10 | Target truth | Start `production-target` |
    67 -| maintenance-freshness-and-dependency-operations | 0.1.0
        | `shipglows_data/workflow/checklist-instances/maintenance
        -launch-2026-07.md` | `jarretelacoke-fr:maintenance:launch
        -2026-07` | in_progress | 0/10 | Technical health | Start
        `maintenance-dependencies` |
    68 -| technical-project-readiness-and-operations | 0.1.0 | `sh
        ipglowz_data/workflow/checklist-instances/technical-launch
        -2026-07.md` | `jarretelacoke-fr:technical:launch-2026-07`
         | in_progress | 0/10 | Scope and configuration | Start `t
        echnical-architecture-surfaces` |
    69 -| cybersecurity-project-readiness-and-maintenance | 0.1.0
        | `shipglows_data/workflow/checklist-instances/cybersecuri
        ty-launch-2026-07.md` | `jarretelacoke-fr:cybersecurity:la
        unch-2026-07` | in_progress | 0/15 | Scope and access | St
        art `security-surfaces-environments` |
    70 -| seo-technical | 1.1.0 | `shipglows_data/workflow/checkli
        st-instances/seo-technical-launch-2026-07.md` | `jarretela
        coke-fr:seo:launch-2026-07` | in_progress | 0/28 | Scope a
        nd environment | Start `technical-scope-environments` |
    71 -| site-launch | 1.0.0 | `shipglows_data/workflow/checklist
        -instances/launch-2026-07.md` | `jarretelacoke-fr:launch:l
        aunch-2026-07` | in_progress | 0/9 | Canonical strategy |
        Start `launch-canonical-strategy` |
    60 +| Checklist ID | Master Version | Instance Path | Cycle ID
         | Cadence | Next Review | Status | Progress | Current Pha
        se | Next Action |
    61 +| --- | --- | --- | --- | --- | --- | --- | --- | --- | --
        - |
    62 +| performance-project-readiness-and-monitoring | 0.1.0 | `
        shipglows_data/workflow/checklist-instances/performance-la
        unch-2026-07.md` | `jarretelacoke-fr:performance:launch-20
        26-07` | weekly | 2026-08-04 | in_progress | 0/10 | Scope
        and baseline | Start `performance-scope-surfaces` |
    63 +| analytics-measurement-readiness-and-quality | 0.1.0 | `s
        hipglowz_data/workflow/checklist-instances/analytics-launc
        h-2026-07.md` | `jarretelacoke-fr:analytics:launch-2026-07
        ` | monthly | 2026-08-28 | in_progress | 0/10 | Measuremen
        t plan | Start `analytics-objectives` |
    64 +| marketing-go-to-market-readiness | 0.1.0 | `shipglows_da
        ta/workflow/checklist-instances/marketing-launch-2026-07.m
        d` | `jarretelacoke-fr:marketing:launch-2026-07` | monthly
         | 2026-08-28 | in_progress | 0/9 | Audience and positioni
        ng | Start `marketing-audience` |
    65 +| copywriting-public-surface-quality | 0.1.0 | `shipglows_
        data/workflow/checklist-instances/copywriting-launch-2026-
        07.md` | `jarretelacoke-fr:copywriting:launch-2026-07` | m
        onthly | 2026-08-28 | in_progress | 0/10 | Clarity and str
        ucture | Start `copy-audience-context` |
    66 +| content-publication-and-editorial-operations | 0.1.0 | `
        shipglows_data/workflow/checklist-instances/content-launch
        -2026-07.md` | `jarretelacoke-fr:content:launch-2026-07` |
         weekly | 2026-08-04 | in_progress | 0/10 | Preparation |
        Start `content-brief-audience` |
    67 +| production-health-and-operations | 0.1.0 | `shipglows_da
        ta/workflow/checklist-instances/production-launch-2026-07.
        md` | `jarretelacoke-fr:production:launch-2026-07` | weekl
        y | 2026-08-04 | in_progress | 0/10 | Target truth | Start
         `production-target` |
    68 +| maintenance-freshness-and-dependency-operations | 0.1.0
        | `shipglows_data/workflow/checklist-instances/maintenance
        -launch-2026-07.md` | `jarretelacoke-fr:maintenance:launch
        -2026-07` | monthly | 2026-08-28 | in_progress | 0/10 | Te
        chnical health | Start `maintenance-dependencies` |
    69 +| technical-project-readiness-and-operations | 0.1.0 | `sh
        ipglowz_data/workflow/checklist-instances/technical-launch
        -2026-07.md` | `jarretelacoke-fr:technical:launch-2026-07`
         | monthly | 2026-08-28 | in_progress | 0/10 | Scope and c
        onfiguration | Start `technical-architecture-surfaces` |
    70 +| cybersecurity-project-readiness-and-maintenance | 0.1.0
        | `shipglows_data/workflow/checklist-instances/cybersecuri
        ty-launch-2026-07.md` | `jarretelacoke-fr:cybersecurity:la
        unch-2026-07` | monthly | 2026-08-28 | in_progress | 0/15
        | Scope and access | Start `security-surfaces-environments
        ` |
    71 +| seo-technical | 1.1.0 | `shipglows_data/workflow/checkli
        st-instances/seo-technical-launch-2026-07.md` | `jarretela
        coke-fr:seo:launch-2026-07` | monthly | 2026-08-28 | in_pr
        ogress | 0/28 | Scope and environment | Start `technical-s
        cope-environments` |
    72 +| site-launch | 1.0.0 | `shipglows_data/workflow/checklist
        -instances/launch-2026-07.md` | `jarretelacoke-fr:launch:l
        aunch-2026-07` | cycle | 2026-07-28 | in_progress | 0/9 |
        Canonical strategy | Start `launch-canonical-strategy` |
    73
       ⋮
    81  - Next review: `2026-08-04`.
    82 +- Cadence policy: weekly production-facing reviews; monthl
        y technical, security, SEO, analytics, marketing, copywrit
        ing and maintenance reviews; launch is one-time.
    83  - Domain progress: eleven instantiated domains `0/total`,
        `in_progress`; no control is claimed complete.

• Edited 11 files (+55 -0)
  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  analytics-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [major_release, measurement_change]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  content-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: weekly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [publication]
    15 +next_review: 2026-08-04
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  copywriting-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [new_campaign, public_surface_change]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  cybersecurity-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [security_incident, credential_rotation, m
        ajor_release]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: cycle
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [release_candidate]
    15 +next_review: 2026-07-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  maintenance-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [security_advisory, dependency_update]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  marketing-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [new_campaign, offer_change]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  performance-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: weekly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [major_release, performance_regression]
    15 +next_review: 2026-08-04
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  production-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: weekly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [deployment, incident]
    15 +next_review: 2026-08-04
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  seo-technical-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [major_release, domain_migration, redesign
        ]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

  └ ~/jarretelacoke/shipglows_data/workflow/checklist-instances/
  technical-launch-2026-07.md (+5 -0)
    10  cycle_kind: launch
    11 +cadence_kind: monthly
    12 +cadence_anchor: 2026-07-28
    13 +timezone: Europe/Paris
    14 +trigger_events: [major_release, architecture_change]
    15 +next_review: 2026-08-28
    16  created: "2026-07-28"

──────────────────────────────────────────────────────────────────

• La cadence est maintenant déclarée à deux niveaux : dans le
  projet (politique par domaine) et dans chaque instance (cadence,
  date d’ancrage, fuseau, déclencheurs, prochaine revue).
  J’applique maintenant ces paramètres au cycle de
  jarretelacoke.fr, puis je vérifie que les lecteurs les exposent
  correctement.

• Edited shipglows_data/workflow/specs/project-lifecycle-
checklist-operating-model.md (+2 -1)
    302  | 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex |
         Initialized jarretelacoke.fr with a project lifecycle dec
         laration and seven launch-cycle instances, all at not_sta
         rted with no inferred progress | partial | Normalize stab
         le IDs in the legacy technical, cybersecurity, SEO and la
         unch masters before instantiating those domains |
    303 +| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex |
         Added explicit project and instance cadence fields, confi
         gurable review dates, timezones and event triggers; appli
         ed the first cadence policy to all eleven jarretelacoke.f
         r launch instances | partial | Execute the configured lau
         nch-cycle controls and retain each future occurrence as a
          new instance |
    304
        ⋮
    313
    313 -Next step: run final verification and retain Markdown as
         the application source; instantiate the transversal maste
         rs on a real project, with content SEO and keyword work o
         utside the technical SEO instance.
    314 +Next step: execute the configured launch-cycle controls o
         n jarretelacoke.fr; each future occurrence must receive a
          new cycle ID, with content SEO and keyword work outside
         the technical SEO instance.

• Ran python3 tools/shipglows_metadata_lint.py templates/
  │ project_checklist_instance.md templates/project_lifecycle.md
  │ skills/references/project-lifecycle-checklist-contract.md
  │ … +2 lines
  └ ShipGlows metadata lint passed: 4 file(s) checked.

• Ran git -C /home/claude/shipglows diff --check && git -C /home/
  │ claude/jarretelacoke diff --check
  └ (no output)

• Ran for f in /home/claude/jarretelacoke/shipglows_data/workflow/
  │ checklist-instances/*.md; do python3 /home/claude/shipglowz/
  │ tools/shipglows_checklist_instance_status.py "$f" >/dev/null
  │ … +1 lines
  └ usage: shipglows_checklist_instance_status.py [-h] path
    shipglows_checklist_instance_status.py: error: ## Controls
    section is required

• Ran python3 tools/test_shipglows_checklist_instance_status.py
  └ ..
    --------------------------------------------------------------
    … +2 lines (ctrl + t to view transcript)

    OK

• Ran python3 tools/shipglows_metadata_lint.py /home/claude/
  │ jarretelacoke/shipglows_data/workflow/project_lifecycle.md /
  │ home/claude/jarretelacoke/shipglows_data/workflow/
  │ … +1 lines
  └ ShipGlows metadata lint passed: 13 file(s) checked.

• Ran git -C /home/claude/shipglows diff --check; git -C /home/
  │ claude/jarretelacoke diff --check
  └ (no output)

• Ran python3 tools/shipglows_checklist_instance_status.py /home/
  │ claude/jarretelacoke/shipglows_data/workflow/
  │ checklist-instances/seo-technical-launch-2026-07.md | sed -n
  │ … +1 lines
  └ {
      "project_id": "jarretelacoke-fr",
    … +31 lines (ctrl + t to view transcript)
        {
          "control_id": "technical-scope-indexable-surfaces",

• Ran for f in /home/claude/jarretelacoke/shipglows_data/workflow/
  │ checklist-instances/*.md; do case "$f" in */README.md)
  │ continue;; esac; python3 /home/claude/shipglowz/tools/
  │ … +2 lines
  └ 11 checklist instances: OK

──────────────────────────────────────────────────────────────────

• 🧱 CHANTIER (spec) : Project Lifecycle Checklist Operating Model
  🎯 VERDICT (18:35) : cadences configurables ajoutées

  C’est fait pour jarretelacoke.fr :

  - cadence par domaine ;
  - prochaine date de revue ;
  - fuseau horaire ;
  - déclencheurs exceptionnels ;
  - distinction entre cycle actuel et cycle suivant ;
  - conservation de l’historique.

  La configuration actuelle prévoit notamment :

  - contenu, performance et production : hebdomadaire ;
  - technique, cybersécurité, SEO, analytics, marketing,
    copywriting et maintenance : mensuelle ;

  - lancement : cycle unique ;
  - déclencheurs immédiats : mise en production, incident,
    migration, refonte, changement de dépendance, etc.

  Les 11 instances sont reconnues par le parser et restent à 0/
  total, sans progression inventée. La création automatique des
  prochains cycles et les rappels seront ajoutés ensuite dans
  l’interface ShipGlows.

─ Worked for 5m 19s ──────────────────────────────────────────────


› $800-tmux-capture-conversation capture et verifie


• J’utilise 800-tmux-capture-conversation pour capturer le panneau
  tmux courant, puis je vérifierai le Markdown produit (présence,
  lisibilité de base et absence de troncature évidente). Je
  commence par afficher la destination et le contenu détecté avant
  l’écriture.

• Ran SHIPGLOWS_ROOT=/home/claude/shipglows /home/claude/shipglowz/
  │ skills/800-tmux-capture-conversation/scripts/
  │ capture_tmux_conversation.sh --dry-run
  └ Title: Conversation 800-tmux-capture-conversation - capture et
    verifie
    … +14 lines (ctrl + t to view transcript)
    conversation-800-tmux-capture-conversation-capture-et-verifie-
    20260728-200056.md

──────────────────────────────────────────────────────────────────

• Le plan détecté est :

  - Panneau tmux courant : 0:7.1
  - Mode : scrollback
  - Destination : /home/claude/jarretelacoke/shipglows_data/
    workflow/conversations/conversation-800-tmux-capture-
    conversation-capture-et-verifie-20260728-200056.md

  - Sujet détecté : gestion des masters, instances et cycles

  Je lance l’écriture et la vérification avec cette destination ?

──────────────────────────────────────────────────────────────────


› ok


• Je capture maintenant le panneau validé, puis je contrôle le
  fichier généré et sa structure Markdown.

• Working (2s • esc to interrupt)

 
› verifie que la convest              
 
  tab to queue message                          74% context left

/home/claude/home/claude/home/claude
