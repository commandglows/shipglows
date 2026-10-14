---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.1.1"
project: ShipGlows
created: "2026-10-11"
updated: "2026-10-14"
status: active
source_skill: sg-engineering
scope: isolated-linux-test-readiness-handoff
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-calibration.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md
  - shipglows_data/technical/conditional-skill-routing-linux-environment.md
  - tools/conditional_skill_routing_real_comparison_preflight.py
depends_on: []
supersedes: []
evidence:
  - "Native Linux 0.160.1: eight current-profile public mock replays PASS, 199 simulated requests and 184 callbacks."
  - "345 focused/guarded tests PASS; test exclusions and the interrupted broad-suite audit are retained."
  - "Nine offline gates independently PASS; coordinator checker confirms complete preparation and no launch authority."
  - "Fresh v5 seal, new A3 identity and evaluator resume verified through the delivered launcher."
next_step: "Rehash the current preparation stage and its independent receipts; supply deferred live conditions only when proceeding to the real baseline phase."
---

# Handoff — Codex Linux isolé

## Reprise du 14 octobre 2026

L'opératrice a demandé le lancement réel puis confirmé `gpt-6-luna` et le coût
nécessaire au test. Les choix modèle/coût et l'accord de lancement ne sont donc
plus à redemander. Cet accord ne dispense pas des contrôles techniques.

Le contrôle de reprise a trouvé plusieurs fichiers publics non suivis absents,
dont le launcher, le profil et les reçus V5. Le launcher et sa source Python ont
été restaurés depuis la trace publique, avec leurs hashes exacts. Les probes
réelles Linux sujet/évaluateur et 37 tests ciblés passent le 14 octobre. Les
preuves publiques nécessaires ont été récupérées ou renouvelées. Les huit
nouveaux mocks passent : 199 requêtes simulées, 184 callbacks, 232 fichiers
rehachés. La revue indépendante du 14 octobre clôt les neuf gates offline.
Le contrôle privé de reprise a été effectué uniquement par le vérificateur
isolé, sans contenu ni chemin privé exposé au contexte auteur.

Exécuter depuis le dossier public figé
`C:/Users/Diane/ShipGlows/shipglows/.csr-v5-runtime-20261014`, qui conserve les
22 fichiers attendus par le profil à leurs hashes exacts. Les sources suivies
du checkout restent intactes : leurs différences sont uniquement des fins de
ligne. Stage actif dans ce dossier :
`tools/fixtures/conditional_skill_routing/preparation-revisions/linux-offline-readiness-v5-20261011/readiness-stage-20261014.json`,
SHA256 `baa2043468be8fb9df865b6a2206ffd38803dc81d52ecdb591f80f2e75f40c52`.
Le reçu final indépendant est `independent-final-preflight-20261014-public.json`
dans le même répertoire, SHA256
`8d28c29fa19e5b0f7884c0458db6dee08c5cfe174a49785c5c4c94d0813f803c`.
`prepared_for_authorized_baseline=true` et aucune gate offline restante.
Les indicateurs de lancement restent false : l'accord humain existe, mais son
profil technique live, les limites effectives et l'accès API doivent encore
être matérialisés et contrôlés avant la première requête réelle.

Sauvegarde publique complète vérifiée hors checkout :
`/home/claude/.local/share/shipglows-isolated-codex-0.160.1/public/recovery-20261014/recovery-public-bundle-20261014.tar.gz`,
SHA256 `80c14bfb10a37a8e5c047fc5d6cd83f1282f3965dba35642c77b15240522b5df`.
Elle contient 288 fichiers publics, sans payload, index ou générateur privé.
Reçu local :
`tools/fixtures/conditional_skill_routing/preparation-revisions/execution-recovery-20261014/public-backup-20261014.json`.

Le parent HTTPS préparé appelle l'API Responses avec un credential injecté côté
parent. Au contrôle de reprise : aucune clé API dans l'environnement process,
utilisateur ou machine Windows, ni dans l'auth Windows ou Linux vérifiée ;
connexion ChatGPT détectée seulement côté Windows. Une configuration locale
`OPENAI_API_KEY` a été demandée sans transmission du secret dans le chat.
Aucune requête modèle ni comparaison n'a été lancée pendant cette reprise.

## Validation historique du 11 octobre 2026

Préparation offline terminée ; revue indépendante close. Les neuf gates sont
PASS et le checker final confirme `structural_valid=true`,
`prepared_for_authorized_baseline=true`, `offline_preparation_gates=[]`.
`ready_to_launch_baseline=false` et `ready_to_launch_final96=false` correspondent
aux décisions d'exécution réelle explicitement différées par l'opératrice.
Preuve : `independent-final-preflight-public.json` dans le répertoire V5 ci-dessous.
SHA256 du stage validé :
`4db00666405be1988339c77dd2ac2e2a5f80dae0d4aee8995cd41e39b480cd67`.

## Mandat et baseline

Repo : `C:/Users/Diane/ShipGlows/shipglows`. Préserver les modifications locales ;
aucun stage, commit, push, publication ou changement des skills canoniques.
L'opératrice demande une préparation complète et un handoff exploitable. Les choix
fournisseur, modèle, budget et autorité d'exécution réelle restent explicitement
différés. La remise de ce document ne lance aucune comparaison.

**Baseline documentaire : spécification actuelle v1.4.7**, SHA256
`bf787adcf495967313569ac9a42c9556415e4065fc16fcc8d71b9ac0a8253082`,
avec calibration v1.4.0, SHA256
`5e617dd1de6e64e17164374af729dd02385b25a2b6795a5a995f094e8f4082bd`.
Ces deux documents sont inchangés, avec snapshots exacts.

La baseline expérimentale utilise la révision des sources originales figées dans
le manifeste, revue séparément de cette baseline documentaire. Elle exige huit
nouvelles observations avant tout authoring/tuning candidat. Les anciens résultats
shared-host ne constituent pas cette baseline.

## Pièces à reprendre

Lire AGENT.md/CLAUDE.md, puis seulement la spécification, la calibration et :

- `shipglows_data/technical/conditional-skill-routing-linux-environment.md` : accès et frontières réellement vérifiées.
- `tools/fixtures/conditional_skill_routing/preparation-revisions/linux-offline-readiness-v5-20261011/readiness-stage.json` : stage courant.
- Dans le même répertoire : `readiness-contract.json`, `source-closure-inventory.json`, `offline-validation-public.json` et les neuf reçus indépendants `*-public.json` référencés par le stage.
- `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-consumer-profile.json` : profil générique courant, nom conservé pour compatibilité du launcher.
- `shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md` : protocole P0-P6 et historique, sans promouvoir les anciens packets pending.

Identité réservée inerte : `codex-linux-isolated-v5-20261011-prepared`.
Profil consommateur SHA256 :
`2b0f1d7b398fd3cd89db638ba98925472651fa608520b9d0ad17a65097792318`.
Contrat immuable SHA256 :
`6285eb1e51ab17325bdbdbf3687f80ca8ab65b2b6339a85ca3bff4e360394513`.
Le profil et le contrat ne référencent aucun reçu : aucun cycle de hashes.
Les reçus doivent tous être liés à ces identités et aux preuves exactes.

## Accès et contrôle public

Depuis PowerShell dans le repo, directement sans Doppler :

```powershell
& ./tools/conditional-skill-routing-linux.ps1 subject --version
& ./tools/conditional-skill-routing-linux.ps1 probe
& ./tools/conditional-skill-routing-linux.ps1 evaluator --help
python -B tools/conditional_skill_routing_real_comparison_preflight.py --template tools/fixtures/conditional_skill_routing/preparation-revisions/linux-offline-readiness-v5-20261011/readiness-stage.json
```

Le template par défaut historique reste volontairement incomplet. Utiliser
explicitement le stage courant. Le checker public ne lit aucun payload held-out,
aucun credential, n'effectue aucune requête fournisseur et ne lance aucun sujet.
**Exit 0 prouve la préparation offline seulement.** Vérifier séparément
`prepared_for_authorized_baseline`, `ready_to_launch_baseline` et
`ready_to_launch_final96` dans sa sortie. Ne jamais déduire l'autorité d'exécution
de l'exit code ou d'un PASS mock.

Runtime : WSL Ubuntu x86_64, bubblewrap 0.11.1, ELF Codex natif 0.160.1,
SHA256 `f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35`.
Installation : `/home/claude/.local/share/shipglows-isolated-codex-0.160.1`.
Sujet/évaluateur : six namespaces distincts, capabilities nulles, NoNewPrivs,
environnement nettoyé, états propres, aucun montage Windows/home/socket hôte ni
route réseau extérieure. Même hôte/noyau/coordinateur de confiance ; aucune
protection contre son administrateur n'est revendiquée.

Code/snapshots évaluateur RO ; ses propres inputs sont accessibles uniquement par
l'alias canonical `/opt/evaluator/inputs` de son `/work`. Le futur évaluateur
indépendant reprend son binding privé dans cet espace selon son reçu public.
Ne pas rechercher, lister ou ouvrir ce payload depuis le contexte auteur.

Reprise réservée au prochain évaluateur indépendant, une fois l'auteur inactif :

```powershell
& ./tools/conditional-skill-routing-linux.ps1 evaluator-shell -c 'python3 /opt/evaluator/support-v5/verify_resume.py csr-v5-8e637ac5c344f81a226eb4dc'
```

Comparer le hash d'index retourné à
`fcc9158c0d37e30ec5b29221fecf896773f2897e898ef2521396680b77915e48`.
Le reçu `v5-independent-resume-public.json` décrit ensuite la résolution privée
et le binding générique. Dépendances publiques RO déjà installées :
`/opt/evaluator/support-v5`. Aucun montage personnalisé n'est nécessaire.
Cette reprise vérifie les hashes ; elle n'autorise ni collecte ni scoring.

Le sujet ne reçoit que sa slice exécutable. Le parent de confiance possède broker,
contrats, captures et proxy ; le sujet n'a ni dataset/attentes, ni évaluateur,
credentials ou résultats concurrents. Les capacités natives du CLI restent
activées : les appels non enregistrés sont refusés avant dispatch par validation
complète de la réponse. Le profil live et ses ceilings devront être établis
séparément, avec credentials côté parent et egress limité au fournisseur choisi.

## Preuves et limites conservées

Huit mocks natifs publics actuels : H1/H2 attempt3, A1/A2/B1/B2/S1/S2 attempt2,
199 requêtes simulées et 184 callbacks, snapshots tous concordants avec le profil.
Le reçu `offline-validation-public.json` donne leurs chemins/hashes publics.
Aucun mock n'est une observation de baseline ou une comparaison.

345 tests passent : 31 child/launch, 94 preflight/runtime/controller/accounting/
transport, 220 source synthetic runner/eval/shared-campaign avec `_heldout`
explicitement interdit. Un test historique Windows attend 0.160.1 alors que ce
consommateur distinct est désormais 0.161.0 : exclu du verdict Linux natif.
Les tests CLI preflight évaluateur qui peuvent charger l'ancien seal sont exclus
de la suite auteur protégée.

Audit : une suite trop large a été démarrée puis interrompue après découverte de
ce chargement implicite possible. Aucun contenu privé n'a été émis ou vu par
l'auteur ; zéro ouverture interne de l'ancien seal n'est pas attesté. Cette suite
n'est créditée comme PASS nulle part. L'évaluateur indépendant a créé et figé un
jeu v5 entièrement neuf après cet arrêt, sans consulter l'ancien contenu ni son
générateur. Ses formulations, attentes et emplacements restent privés.

Le contrôle final a révoqué les PASS provisoires v4 : identité A3 cohérente mais
non neuve, et reprise initiale dépendante d’un montage personnalisé. Le payload
v4 reste scellé intact ; un jeu complet v5 neuf a été créé et scellé, avec nouvelle
identité A3 vérifiée avant seal. Ses huit bindings sont validés. Le contrôle A3
refuse l'action sans préflight puis l'accepte après livraison du préflight, sans
modifier le payload scellé. Aucun verdict v4 révoqué ne fait autorité.

Un manque temporaire de mémoire hôte a interrompu le démarrage WSL, puis Linux
a récupéré et les probes ont repassé. Le plafonnement temporaire tenté à 2 Go
n'a pas été appliqué ; le fichier créé a été retiré, restaurant son absence
initiale. Aucun processus tiers n'a été arrêté. Le reçu public
`host-startup-memory-public.json` conserve cet incident ; aucun plafond 2 Go
n'est revendiqué.

Corrections revues : alias d'inputs évaluateur ; probe RO fail-closed avec contrôle
négatif ; identité campagne/runtime requise ; contrat sans cycle ; réemploi ELF
local seulement après hash/taille exacts ; émission HTTP/RPC atomique avec retraite
contextuelle. Les deux ordres de concurrence sont testés. Une opération déjà
admise peut finir avant retraite ; aucune émission nouvelle après retraite.

Les captures texte/spans et les frames d'instructions sont des preuves de livraison
instrumentée. Le compteur général ResponsesAccounting exclut noms/arguments et
JSON framing ; ne pas le confondre avec le coût normatif complet C(X). Les verdicts
coût/économies exigent le collecteur normatif et toutes ses catégories, sinon
UNKNOWN/inconclusif. Rétention opaque et compaction réelle ne sont jamais déduites
d'un mock. Aucun verdict comportemental held-out ni économie n'est publié ici.

## Phase réelle ultérieure

Ne lancer que lorsque `ready_to_launch_baseline=true`, avec reçus revérifiés,
profil live exact, fournisseur/modèle/révision/settings, budget/ceilings et autorité
concrète établis. Ces décisions ne sont pas demandées par ce handoff de préparation.

1. Huit baselines fraîches H1/H2/A1/A2/B1/B2/S1/S2.
2. Ensuite authoring/tuning compact et explicit, revue des cinq pages/substitutions.
3. Freeze puis `ready_to_launch_final96=true` avant la comparaison finale.

Conserver 96 runs/48 paires, sujet frais, ordre baseline→candidate aux répétitions
1/3 et inverse à la répétition2, cold/continuation distincts, FR/EN, AC5, O1-O9 et
tous les seuils. Auteur inactif pendant collecte/scoring held-out ; résultats
retenus jusqu'à clôture complète. Toute exposition suivie de réparation impose
nouvelle campagne et jeu complet frais. UNKNOWN reste UNKNOWN, échecs conservés,
migration toujours NO-GO.
