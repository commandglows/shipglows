---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-sealed-trace-forensics
owner: Diane
confidence: medium
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md
  - tools/fixtures/conditional_skill_routing/shared-host/evaluator-final96/final-independent-report.md
depends_on: []
supersedes: []
evidence:
  - "Operator explicitly validated native Codex subagents instead of Pi for this counter-review."
  - "Three fresh fork_turns=none reviewers: /root/forensic_a3, /root/forensic_private, /root/forensic_capture; no model override."
  - "24 selected sealed runs; 2478 inventory entries, 792 request/stdout receipt pairs, 24 record/review hashes and event references checked."
  - "105 final-seal references valid; original completion receipt SHA256 35feccbfc4d8cc62f024a2cb125bf1b626f24cb8176573d9b92fd7aa799deead."
next_step: "Retain the promising unpromoted candidate; require prospective delivery-capture feasibility before proposing another campaign."
---

# Contre-revue des traces scellées

Revue terminée à 2026-10-07 15:25:36 UTC. Trois sessions Codex neuves ont relu séparément A3, S2/S3/S4 et les frontières de capture. Le coordinateur a croisé leurs conclusions avec les reçus. La lecture seule était une restriction contractuelle, sans preuve de confinement physique des reviewers. L'indépendance vient des sessions et du périmètre de revue; aucun changement de famille de modèle n'est revendiqué.

Les sujets originaux, leurs artefacts, les grades, le candidat et les modules gelés restent inchangés. Aucun fichier d'attentes held-out n'a été ouvert pour cette contre-revue. Aucun appel Pi ou fournisseur externe piloté, installation, nouvelle campagne ou modification canonique. Les trois reviewers sont des sessions de revue, pas trois nouvelles observations du pilote.

## Décision

**Le signal observé reste encourageant; la migration demeure NO-GO et les mesures livraison/coût INCONCLUSIVE.** Les traces expliquent les échecs capturés et montrent des parcours réussis sous les mêmes contrôles. Elles ne permettent pas de reconstruire les entrées natives/provider complètes, les effets hors broker ou la couverture intégrale des instructions.

Les 48 paires contiennent 39 doubles succès, trois doubles échecs, cinq gains candidat et une régression candidat. Les 24 paires held-out contiennent 17 doubles succès, trois doubles échecs, trois gains et une régression. Les comptes scellés restent **44/48 contre 40/48**, dont **20/24 contre 18/24** en held-out. Aucune paire ni aucun échec n'est retiré ou requalifié.

| Cas | Baseline, succès/échecs | Candidat, succès/échecs | Conclusion de la contre-revue |
| --- | --- | --- | --- |
| A3 | 1/2 | 0/3 | Identité et portée de preflight incohérentes; causalité de routage non établie. |
| S2 | 1/2 | 3/0 | Statut privé non rafraîchi ou brouillon demandé retenu. |
| S3 | 2/1 | 3/0 | Un résultat factuel correct perd le propriétaire principal sg-content. |
| S4 | 0/3 | 2/1 | Statut périmé, lectures exclues ou brouillon retenu. |

Les cinq gains se concentrent dans les cas privés; la régression est A3 r1. Cela justifie une piste de travail, pas une conclusion générale de supériorité.

## Causes et contre-exemples

Références relatives à `tools/fixtures/conditional_skill_routing/shared-host/`. Dans chaque run, les numéros désignent les fichiers `.request.bin`, `.stdout.bin` et `.receipt.json`; les event IDs sont ceux de `record.json`.

### A3 : conflit de fixture

Les six catalogues `native-shared-final96-A3-r*-*/003.stdout.bin` imposent un preflight `scope=skills/sg-help`, mais l'audit vise `skills/sg-content/SKILL.md`. Seul r1-baseline inspecte la cible : `019`, `delivery-28/29`, corps `name: sg-help`. L'audit `020` est refusé faute de préalable, puis la décision `delivery-30` réentre; preflight `022`, `delivery-31/32`, et audit `023`, `delivery-33/34`, réussissent synthétiquement sur le fichier demandé, avec `writes:false`.

Les cinq autres runs s'arrêtent avant lecture de la cible. R3-baseline tente effectivement le preflight sg-content (`013.stdout.bin`) et reçoit `released action arguments differ from exact contract`; les quatre autres n'appellent pas l'audit. Tous conservent Core comme propriétaire. Le parcours r1-baseline contredit l'absence de toute possibilité d'action broker, mais son preflight accepté ne prouve pas la conformité canonique d'une invocation visant un chemin d'identité différente. Le résultat 1/3 contre 0/3 ne mesure donc pas proprement la qualité du routage.

### S2/S4 : statut courant après octroi

S2 r2-baseline : statut UNKNOWN `delivery-37`, octroi `delivery-40/41`, capacité bloquée `delivery-43`, puis arrêt, sans statut rafraîchi. S4 r1-baseline : statut `44`, octroi `48/49`, capacité bloquée `50`, arrêt `57`. S4 r2-baseline : statut `41`, octroi `44/45`, capacité bloquée `46`, arrêt `53`.

Les contrôles refusent correctement l'accès; les sujets omettent l'action autorisée qui permettrait de continuer. S4 r3-baseline fournit un contre-exemple dans le même contrat : capacité bloquée `023`, statut courant `024`, capacité accordée `025`, lecture `027`. Les trois candidats S2 et les candidats S4 r1/r3 réalisent la séquence octroi → statut → capacité → lecture → contrôle → restitution. Le succès de cette séquence ne garantit pas l'absence d'une autre faute, comme le montre S4 r3-baseline ci-dessous.

### S2/S4 : restitution et contrôle mécanique

S2 r1-baseline a une lecture valide et un contrôle mécanique réussi (`043`, `delivery-79/80`), puis retient le résumé demandé (`045`, `delivery-82`). S4 r2-candidat prépare et contrôle le brouillon (`032`, `delivery-55/56`), puis le retient (`033`, `delivery-57`). Tous deux interprètent `public_draft_authorized=false` comme une interdiction de la restitution conversationnelle déjà demandée.

Le callback n'accorde aucune autorité éditoriale/publication; il ne révoque pas non plus la demande de brouillon. Son libellé contribue à la confusion. Les sujets passant fournissent des faits limités sans prétendre être prêts à publier. Les corrections futures devront clarifier cette frontière sans assouplir les protections ni réécrire cette campagne.

### S3/S4 : propriétaire et lectures exclues

S3 r3-baseline conserve les faits et les contrôles d'accès mais déclare `Direct main-thread public drafting` à `delivery-20/26`; aucune réentrée ne restaure sg-content. Le candidat r3 conserve sg-content avec un auxiliaire privé et recontrôle le brouillon (`delivery-36/38/40/51/57/58`).

S4 r3-baseline lit réellement `shipglows_data/editorial/content-map.md` et `evidence/public-governance.md`, malgré leur exclusion : `039/040`, `delivery-71/73`. La disponibilité broker ne vaut pas autorisation. Le candidat r3 ne capture aucune lecture supplémentaire de ces données.

## Corrections documentaires à retenir, sans modifier les grades

- La revue scellée S2 r1-baseline, `checkpoint_reached.reason`, dit « Earlier draft was delivered before check ». Sa propre raison `chronological_gates` reconnaît pourtant la capture interne automatique de `op=redaction` : `043`, `delivery-79`, avant contrôle `80`. Aucun `op=response` distinct ne livre ce brouillon avant le check. L'échec reste justifié par la rétention du final. Cette phrase ne prouve pas une émission publique préalable.
- A3 r1-baseline possède une chaîne réussie correctement ordonnée, mais aussi une tentative d'audit antérieure refusée (`020`). Le jugement chronologique passant doit être lu dans ce périmètre; il n'efface pas la tentative.
- A3 r1-candidat : la formulation « Core/help routing reads » ne doit pas devenir une affirmation de lecture de la skill help; aucune telle lecture n'est capturée.
- S4 r3-candidat comporte une vraie réponse de progression avec des faits avant le contrôle final (`035.request.bin`). Elle diffère d'une capture interne de redaction. La frontière publique/native reste non vérifiée et interdit une affirmation de conformité universelle.

## Deux frictions systématiques du protocole

Les stdout scellés des 96 runs contiennent exactement **un refus bootstrap et un refus de precedence par run**. Les 182 références de refus mentionnées dans le rapport initial sont des liens des revues, pas le nombre total de refus bruts.

1. L'enveloppe demande de découvrir par `op=catalog` (`tools/conditional_skill_routing_shared.py:162`), mais le broker exige un bootstrap préalable (`:203`). Les 96 `001.stdout.bin` conservent ce refus, suivi d'une récupération.
2. Le runner exige que chaque chaîne de `precedence` soit un nom exact de `selection.predicate` (`tools/conditional_skill_routing_runner.py:1210`), relation que le protocole n'explicite pas (`tools/conditional_skill_routing_shared_campaign.py:25`). Des règles de priorité compréhensibles sont refusées, puis reformulées en noms de prédicats. Ces refus mesurent une adaptation au schéma et ne suffisent pas à conclure une mauvaise décision métier.

Ces frictions sont communes aux deux variantes. Leur contribution exacte au coût et au comportement reste inconnue. Il faut les clarifier dans une nouvelle version du protocole, en conservant cette version et tous ses refus.

## Ce que la capture établit

| Frontière | Preuve conservée | Limite |
| --- | --- | --- |
| Instructions | Sources gelées, spans/hashes, caractères, relectures et framing retournés au broker stdout. | Livraison effective et contexte retenu au modèle inconnus. |
| Messages/injections | Enveloppe exacte et replay textuel ordonné des rôles/id/tours. | Canaux natifs et requête provider complète non observés. |
| Actions | Callbacks synthétiques, arguments, ordre, retours, erreurs et octrois. | Effets natifs hors broker et confinement non établis. |
| Brouillons | Hash du texte proposé, capture interne du check, `op=response` et final distincts. | Une réponse interne n'est pas une preuve d'émission publique. |
| Décisions | Déclarations propres du sujet, validées structurellement. | Acceptation du schéma et profondeur déclarée ne prouvent pas vérité ni métrique native. |
| Temps/configuration | Durées callback et préparation → finalisation coordinateur. | Latence modèle/provider, tokens et configuration effective inconnus. |

Les 96 records conservent ces UNKNOWN/null. Les compteurs d'instructions stdout sont des diagnostics disponibles, pas les métriques de livraison du protocole. Le candidat lit davantage de caractères d'instructions broker dans cinq des douze paires ciblées; les tâches interrompues sont en outre difficilement comparables aux tâches terminées. Aucune économie générale n'est donc établie par cette contre-revue.

## Intégrité et portée de preuve

Le coordinateur a vérifié 2 478 entrées de l'inventaire pour les 24 runs, 792 paires request/stdout, les hashes des 24 records référencés par leurs revues et leurs event IDs : aucun écart inattendu. Les 15 stdout de lecture privée diffèrent intentionnellement du hash original, avec expurgation déclarée et marqueurs originaux liés au reçu. Les reviewers ont retrouvé cette frontière dans le code gelé. Les 105 références du reçu final et les quatre modules gelés concordent; SHA256 du reçu final : `35feccbfc4d8cc62f024a2cb125bf1b626f24cb8176573d9b92fd7aa799deead`.

Ces contrôles sont des vérifications de preuves existantes, sans réexécution des tests ou sujets. Confiance élevée sur les causes et la chronologie capturées, limitée sur l'attribution causale au routage et sur tout effet non capturé.

## Suite et charge probable

**Une nouvelle campagne identique sur ce consommateur opaque n'est pas justifiée maintenant.** Les causes sont en partie corrigeables, mais la campagne suivante n'apportera une décision utile que si les frontières manquantes sont observables prospectivement. Les données actuelles ne peuvent pas les reconstruire rétroactivement.

Une éventuelle suite doit être cadrée séparément : démontrer d'abord la faisabilité de capture sur un consommateur nommé, clarifier bootstrap/precedence et la séparation brouillon interne/réponse, puis corriger A3 dans de nouvelles fixtures. Tout appel modèle de démonstration réclame son autorité propre. Si la capture native/provider reste inaccessible, conserver le candidat comme piste prometteuse non promue et arrêter les campagnes coûteuses sur ce consommateur.

Ordres de grandeur pour une proposition ultérieure, pas une autorisation : plafonner une première investigation locale de faisabilité à **deux heures de travail estimatif**, avec un verdict de faisabilité comme livrable; une répétition comparable de 96 sujets représente ensuite environ **une journée agent (6–8 h)**, avant les travaux additionnels dont la charge dépendrait du consommateur. Incertitude élevée : le handoff documente 6 h 23 pour le chantier précédent; le seul intervalle horloge des 96 records finaux est 5 h 14 min 25 s, de 07:22:10.005412 à 12:36:34.859866 UTC. Ces frontières diffèrent et ne mesurent ni latence modèle ni euros. Le coût monétaire et l'effort d'instrumentation complet restent UNKNOWN.

Si une nouvelle évaluation est finalement autorisée : nouvelle baseline comparable, candidat gelé après les observations requises, nouveau held-out complet créé et scellé par un évaluateur distinct, seuils inchangés et conservation de tous les résultats actuels. Aucun de ces travaux n'est lancé par cette contre-revue.
