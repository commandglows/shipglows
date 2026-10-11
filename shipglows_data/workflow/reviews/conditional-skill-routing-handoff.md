# Next-step handoff - conditional skill routing pilot

## Reprise vérifiée — 2026-10-10 11:50 UTC

Cette vérification est documentaire et hors ligne. Aucun lancement de comparaison, appel fournisseur/modèle ou authentification n'a eu lieu. Le payload held-out privé, les captures brutes supprimées et les preuves scellées n'ont pas été ouverts ni modifiés.

### Contrôles et résultat courant

- Les neuf paquets publics référencés par le registre ont été analysés comme JSON. Leurs SHA256 correspondent aux valeurs du registre; toutes les références publiques présentes dans `artifact_hashes` existent et correspondent, sauf les deux références vers la spec qui attendent l'ancienne empreinte `691006e1322c610c356cfeb30547b6dae2d884adf845235784ee65f1ddafd98a`. L'empreinte observée de la spec avant cette mise à jour était `d333e3961ad9c357d1f956839caa5ff7f07c0da7a38f6ad41ac32170fe065198`; la mise à jour ci-dessous rend nécessaire une nouvelle liaison évaluateur. Aucun paquet n'a été édité.
- Les neuf paquets restent des brouillons: aucun `PASS`, `independent_review=false`, aucun évaluateur, `campaign_id=null`, `consumer_profile_sha256=null`, `receipt_sha256=null`. Les preuves mock ne sont que des appuis partiels; elles ne ferment pas les contrôles liés au profil final et ne valent pas revue indépendante.
- Le préflight lecture seule a été relancé: code de sortie 1 attendu, `structural_valid=true`, `errors=[]`, `model_calls=0`, `launch_performed=false`; `prepared_for_authorized_baseline=false`, `launch_authorized=false`, `ready_to_launch_baseline=false`. Les neuf gates offline, l'autorité de lancement distincte et les quinze paramètres différés restent bloquants.
- L'empreinte du template reste `c973ad5fa0a1de21fd8e2dafd8fa8eeb02d644c7d12cf958729ff573090e8761`; le scellement public v3 reste `f9cdbfa91553587a288a831e3678dc79ce714a88254ec445f5c6871cd8c5021b`. Le reçu distinct v3 `c5a1e9179a7a8cfcf5210b7ff70169698cdccf2fff5682c0b49510435f157702` soutient la reproduction du set et du binding baseline, mais ne prouve ni l'attachement au profil final ni l'isolation physique de l'évaluateur.

### État des neuf liaisons proposées

Les chemins ci-dessous désignent les paquets de revue en attente, pas des reçus approuvés. Pour chaque gate, une revue distincte doit vérifier les contrôles indiqués et lier le reçu au même nouveau `campaign_id` et au hash exact du profil final. Aucun identifiant n'est créé ici.

| Gate / paquet (SHA256 du paquet) | Appui public/offline actuel | Contrôles restant à examiner par un évaluateur distinct |
| --- | --- | --- |
| `new_campaign_id` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-campaign-identity-public.json` · `76dff4e2f2a5671f7f89f898df0b86fb18bdf5b67a3bf43d1e3f2316593c3ef3` | Aucun ID de campagne; `experiment_id` n'en est pas un. | Lier un nouvel ID au scellement v3 complet avant tout tuning; attacher le profil final. |
| `source_closure` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-source-closure-review-public.json` · `011d2cced3909bb4bb5659e91c5f7d5a1f8353a1881fe8768d8ee6f1eafa4d74` | Hash de calibration référencé; hash de spec périmé dans le paquet. Pas de fermeture v3 complète. | `original_o1_o9_preserved`, `mandatory_load_closure_reviewed`, `complete_normative_source_spans_hashed`, `baseline_source_revision_frozen`, `authority_hierarchy_identical`; examiner la spec actuelle et ses sources exactes. |
| `fresh_heldout_seal` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-heldout-profile-review-public.json` · `768465428e527d82f1d888faed15f8d769c2265e1d99b1ec7972da18bdc55b68` | Reproduction distincte du set v3 et binding baseline; le contenu privé reste fermé. Appui partiel seulement. | `executable_binding_complete`, `author_confidentiality_preserved`, `complete_fresh_set`; attachement au profil final et isolation physique évaluateur. |
| `a3_fixture_identity_review` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-a3-identity-review-public.json` · `25cc2d4574948d255b02fd5b52812af415bbff994da950c0731387a305f25e72` | Binding exécutable A3 dans le reçu public; pas de revue A3 distincte liée au profil final. | `identity_path_body_preflight_audit_agree`, `mismatch_refused`, `prerequisite_delivery_before_audit`. |
| `fixture_only_runtime` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-fixture-runtime-review-public.json` · `01689d98fd5116c26bf2edb12d80c84755c7b487b56220eaae7059db46e9021a` | Résumés WSL/bwrap mock H/A/B/S et rapports CLI; cela ne démontre pas la fermeture du profil final. | `exact_case_owned_broker_tool_inventory`, `nonbroker_native_calls_refused_before_dispatch`, `immutable_schema_bindings`, `unknown_calls_refused_before_dispatch`, `host_secret_boundary_verified`, `evaluator_resource_boundary_verified`. |
| `complete_scenario_transport` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-scenario-transport-review-public.json` · `dcb0dd09034dca191e38477ec4248101cf7a619a575204fabee3b8edd228a1d9` | Preuve de transport mock: huit cas, 199 requêtes simulées, 184 callbacks exacts, quatre refus de fixture; captures brutes supprimées. | `all_four_families`, `conditional_turns_and_grants`, `actual_effect_then_exact_result_delivery`, `refusals_errors_retries_preserved`; vérifier la séparation auteur/relecteur enfant. Aucune preuve de modèle réel ou AC5. |
| `instruction_role_span_capture` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-instruction-role-span-review-public.json` · `293a9aad9267fac983a9bf0044dfbd928785540232e07892628387b3e63cdd8f` | Requêtes et callbacks mock documentés; livraison/rétention par un modèle réel non observée. | `cli_and_model_requests_separate`, `input_and_instructions_unchanged`, `exact_roles_spans_hashes`, `all_request_accounting`, sur reçus publics conservés. |
| `context_loss_compaction_policy` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-context-loss-policy-review-public.json` · `b104dfa72ba816fcc1196e06be6ae64ed608963dd8bdeb6c1b318bcaee7b29f9` | Politique et sondes simulées; la compaction opaque/rétention cachée restent UNKNOWN. | `opaque_input_fail_closed`, `availability_invalidated`, `fresh_complete_delivery_before_action`, `hidden_retention_not_claimed`. |
| `independent_readiness_review` — `tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-independent-readiness-review-public.json` · `f33b39f842135b63acf46b531a5d43017eac0ab96645db562ce90d78b01db7ee` | Aucun reçu complet; le préflight et ce handoff ne sont pas une revue indépendante. | Après les autres gates: `all_offline_gates_reviewed`, `deferred_launch_parameters_explicit`, `no_real_model_run_claimed`, `preparation_only`. |

Les chemins complets des neuf paquets et les empreintes des éléments d'appui figurent dans le registre « Offline gate-to-receipt binding » du rapport de préparation. Ne pas modifier les paquets pour transformer leurs booléens en succès. Après revue distincte, mise à jour des liaisons autorisée et ajout du profil/campagne par l'évaluateur, relancer le préflight en lecture seule. Une décision distincte reste indispensable avant tout lancement.

## Handoff update - 2026-10-10 02:01 UTC

This update supersedes the earlier next-step list below for receipt preparation. It preserves the existing no-launch boundary.

### Current state

- Target remains instrumented Codex CLI Linux 0.160.1. No real provider, authentication, account, model session, campaign, or comparison was used.
- The eight mock H1/H2, A1/A2, B1/B2 and S1/S2 cases remain the only consumer executions: 199 simulated requests, 184 exact callbacks, four fixture refusals. Their 232-artifact inventories and the public summary hashes are recorded in the preparation report. Raw captures remain deleted.
- The read-only preflight is structurally valid with no errors and `model_calls=0`; `prepared_for_authorized_baseline=false`, `launch_authorized=false`, and `ready_to_launch_baseline=false`. Its nonzero exit is the expected not-ready result.
- Nine public JSON review packets now exist under `tools/fixtures/conditional_skill_routing/preparation-revisions/`. Their hashes and exact review checks are in the preparation report. All remain pending: `independent_review=false`, no `PASS`, no campaign ID, and no final profile hash. They are not bound as successful receipts in the readiness template.
- Existing distinct v3 evaluator review SHA256 is `c5a1e9179a7a8cfcf5210b7ff70169698cdccf2fff5682c0b49510435f157702`; it reproduces the fresh v3 set and baseline binding. Final-profile attachment and evaluator isolation remain unproved. The private held-out payload was not read.
- The readiness template SHA256 remains `c973ad5fa0a1de21fd8e2dafd8fa8eeb02d644c7d12cf958729ff573090e8761`; public v3 seal SHA256 remains `f9cdbfa91553587a288a831e3678dc79ce714a88254ec445f5c6871cd8c5021b`.
- The preparation report is version 1.0.4; the spec is version 1.4.6 and records this continuation. Targeted metadata lint passed for those two Markdown files. No test suite was rerun during this continuation.
- Git remains on `main`, HEAD `e14fd26ef1cf06b47883bf3499638ad4a7b0c452`. No staging or commit was performed. Preserve unrelated dirty and untracked work.

### Remaining proof and decision boundary

The campaign ID, final consumer profile, independent source/A3/runtime/transport/instruction/context-loss reviews, and independent readiness review remain unresolved. Account/provider/model/settings, budget and separate execution authority remain deferred. AC5 and all thresholds are unchanged; migration remains NO-GO.

Next: a distinct evaluator must review the pending packets against the exact final profile, establish evaluator isolation, bind a new campaign ID to the fresh v3 seal, and issue exact reviewed receipts. Rerun the read-only preflight after those bindings. Any baseline launch still requires a separate explicit decision; do not launch as part of this handoff.

## Etat courant de reprise - 2026-10-10

### Capsule de contexte

- Cible: projet ShipGlows, chantier conditional-skill-routing; utilisateur du test futur: Codex CLI Linux instrumente 0.160.1.
- Resultat accepte: preparer une comparaison baseline/candidat avec modele reel, sans la lancer dans cette reprise.
- Contraintes: fournisseur simule seulement jusqu'a nouvel accord explicite; aucune authentification, campagne, installation globale, modification AC5/seuils, lecture du payload held-out prive ou changement des preuves scellees. Preserver le travail Git sans rapport; rien n'a ete stage ni commit.
- Sources canoniques: spec 1.4.6; rapports de preparation, transport parent et integration CLI ci-dessous. Le handoff est un resume, pas une nouvelle source normative.

### Faits et preuves

- Les huit cas publics H1/H2, A1/A2, B1/B2 et S1/S2 ont ete executes sous le meme WSL/bwrap avec fournisseur Responses simule: 199 requetes, 184 callbacks, quatre refus de fixture. Les sorties d'outils fictifs sont exactes dans la requete qui suit l'execution puis dans l'historique. Un appel natif non broker a ete refuse avec HTTP 502 avant SSE.
- Les huit inventaires (232 artefacts) ont ete rehashes. Les 105 empreintes du scellement historique correspondent toujours au recu dont le SHA256 est `35feccbfc4d8cc62f024a2cb125bf1b626f24cb8176573d9b92fd7aa799deead`. Les captures brutes des nouveaux runs sont deja supprimees: preuve conservee par recus et inventaires, pas par replay des octets purges.
- Le garde-fou live exige un recu evaluateur strict lie a la campagne, au cas et a l'inventaire temporaire; seul `PASS` peut rendre un baseline reel `passed`. Le hash courant de `conditional_skill_routing_cli_case_launch.py` est `78c5647fe202516738fab8e4f58b316f8377061484d30c3e181869f3f0df5f17`. Les huit preuves archivees utilisaient le hash anterieur `7eebf39739c2862165388bb4d1c09ac5e5edfe0fb7ade3f213b169062312f3a7`; elles ne prouvent pas l'execution du nouveau garde-fou.
- Le preflight rejette maintenant aussi les budgets `NaN`/infinis; les tests couvrent ces valeurs et les branches de refus de symlink du dossier de captures. Suite concernee: 83 tests OK; lint metadata des trois documents avec frontmatter OK; ce handoff sans frontmatter a ete saute par le lint; audit de topologie: compliant.
- Aucun modele reel, compte fournisseur, appel provider ou campagne n'a ete utilise. AC5 et tous les seuils restent inchanges; migration NO-GO.

### Fichiers et depot

- Fichiers du chantier modifies: `tools/conditional_skill_routing_cli_case_launch.py`, `tools/test_conditional_skill_routing_cli_case_launch.py`, `tools/conditional_skill_routing_real_comparison_preflight.py`, `tools/test_conditional_skill_routing_real_comparison_preflight.py`, les rapports `conditional-skill-routing-real-comparison-preparation.md` et `conditional-skill-routing-cli-broker-transport.md`, ce handoff, et `shipglows_data/technical/code-docs-map.md`.
- Git: branche `main`, HEAD `e14fd26e`; aucun staging ni commit. Le depot contient d'autres modifications/fichiers non suivis; les conserver tels quels et ne pas lancer reset, clean ou staging global.

### Ce qui manque avant une baseline autorisee

Le preflight est structurellement valide, mais renvoie `prepared_for_authorized_baseline=false`, `launch_authorized=false`, `ready_to_launch_baseline=false`, `model_calls=0`. Ne pas traiter le statut non nul du script comme un echec de test: il signale ici qu'il n'est pas pret.

Il reste neuf gates de preparation offline sans lien exact vers un recu approuve: nouvel identifiant de campagne prevu; fermeture des sources; scellement held-out frais; revue d'identite A3; runtime fixture-only; transport complet des scenarios; capture des roles/spans d'instructions; politique de perte de contexte/compaction; revue independante de readiness. Le set v3 held-out et son binding de baseline existent, mais sa revue evaluateur distincte, l'attachement du profil final et la preuve d'isolation evaluateur restent pendants. Les preuves de composants mock ne suffisent pas a fermer les gates runtime/transport/retention.

Quinze parametres de lancement restent differes: hashes du binaire et du profil consumer; fournisseur/endpoint/modele/revision/settings; autorisation separee et plafonds de sujets, requetes, tokens, duree, depassements de tuning, retries et depense/devise. Les choisir seulement apres fermeture des gates offline, pour une decision de lancement separee. Apres le baseline, la comparaison complete demandera encore le recu baseline huit cas, la revue de substitution candidat et le recu de gel du candidat.

AC5, retention reelle du modele, compaction native, comportement provider et effets hors broker restent UNKNOWN/non prouves. Une revue distincte du code enfant et une revue independante de readiness restent a lier au preflight; le reviewer precedent a valide le contrat de recu, pas l'ensemble des gates de lancement.

### Prochaine suite conseillee

1. Relancer le preflight lecture seule et convertir sa liste de gates en tableau de recus exacts (chemin + SHA256 + revue distincte); ne pas ouvrir le payload held-out prive.
2. Fermer les preuves offline manquantes, en priorite fermeture des sources, revue distincte v3/A3, profil/runtime fixture-only et transport/capture complet. N'affirmer aucune retention que le consumer ne rend pas observable.
3. Lier les recus au template, puis refaire le preflight et demander une revue independante de l'ensemble. Garder tous les indicateurs de readiness a false tant qu'un gate manque.
4. Seulement apres readiness offline, demander les choix provider/compte/modele/budget et l'autorisation de lancement dans une decision distincte. Ne pas lancer dans ce handoff.

### Pointeurs

- `shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md`: etat des gates, v3 held-out, seuils et tableau des huit recus mock.
- `shipglows_data/workflow/reviews/conditional-skill-routing-cli-broker-transport.md`: transport parent/WSL/bwrap et hashes des huit cas.
- `shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md`: integration Codex Linux 0.160.1 vers fournisseur simule.
- `shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md`: contrat normatif, spec 1.4.5.

Cette section supersede les prochaines etapes d'octobre 7 ci-dessous. Elle ne modifie ni les preuves scellees, ni AC5/seuils, ni le travail sans rapport.

## Current state - 2026-10-07

The authorized shared-host experiment is **complete**: 96 fresh native subjects, 48 pairs, 96 independent reviews; no active subject. Baseline observed: 40/48 pass, eight fail. Compact candidate: 44/48 pass, four fail. Held-out: 20/24 versus 18/24, a promising observed signal that merits follow-up, but not yet a reliable or statistically established improvement. Formal passes: zero; all nonfailed outcomes inconclusive because complete applicable instruction coverage is unknown. **Migration remains NO-GO; delivery/cost INCONCLUSIVE.** Thresholds unchanged.

Author blind until final scoring/scellement; candidate/modules/protocol/source snapshots still frozen. No failed subject repaired/rerun. There is substantial usable trace evidence: ordered broker events, exact fixture request/response receipts, stdout/final responses, callback refusals/errors, and semantic reviews linked to event IDs. The sealed report checks 2,540 request/response pairs and retains 182 refusal references. The main evidence gap is narrower: complete native host/provider/model inputs, actual instruction delivery, and any effects outside the broker remain unknown. Second independent audit reproduced hashes, matrix, sequencing, grades, freeze and bounded privacy scan. All 24 private transient states removed; zero known sensitive markers in 2,898 scanned files.

Final artifacts: `tools/fixtures/conditional_skill_routing/shared-host/evaluator-final96/` contains `final-independent-report.md`, `completion-audit.json`, `final-completion-receipt.json`, `durable-artifact-inventory.json`, `receipt-digest-audit.json` and 96 semantic reviews. Final receipt SHA256: `35feccbfc4d8cc62f024a2cb125bf1b626f24cb8176573d9b92fd7aa799deead`.

Living spec 1.4.5, calibration 1.4.0 and run ledger distinguish shared completion from original isolated campaign (still not_started/fail-closed). Frozen snapshots unchanged. Latest focused checks from the campaign: evaluator 127, runner 93, shared adapter/campaign 18 passed; unrelated historical QualityPilot failure remains disclosed. Counter-review checks only existing artifacts and documentary metadata, not a rerun of those suites. Doppler NONE for execution. Preserve unrelated dirty work. No canonical skill edit, install, real private access, Git write, publication or deployment belongs to this experiment.

## Preuve de continuite CLI terminee - 2026-10-07

La suite explicitement autorisee est executee : rapport `shipglows_data/workflow/reviews/conditional-skill-routing-cli-continuity.md`. Un seul thread/tour `codex exec` Linux0.160.1 sous WSL/bwrap, fournisseur Responses entierement simule. Deux scripts fictifs executes avec stdout exact et exit0/23; un appel d'escalade refuse par politique Never avant execution. Cinq requetes200/503/200/200/200 : call_ids/arguments historiques et resultats complets exacts dans chaque requete suivante; retry byte-identique. Douze checks vrais, 75 captures rehashes, revue independante brute favorable. Summary SHA256 `c8873d07ccf1a1669269690b2a03c662ddc8d2235289b38bec6d689a42810093` dans `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-continuity-v1-20261007-attempt1/workspace/run/summary.json`.

Meme ELF officiel temporaire reverifie puis supprime; aucune installation globale. Namespace lo uniquement, ENETUNREACH101; receipts launcher hors montage writable; snapshot source ro et timeout Linux. `danger-full-access` est interne au confinement bwrap, jamais preuve de protection CLI. Les 105 references originales restent identiques avant/apres. Refus = escalade CLI, pas refus modele/metier. Un seul tour : second message utilisateur/resume/compaction non exerces. AC5/model retention UNKNOWN, seuils inchanges, migration NO-GO. Cette section supersede les anciennes prochaines etapes callbacks ci-dessous. Suite prospective a cadrer : lectures/instructions/injections et compaction sous mock; aucun fournisseur reel ou nouvelle campagne autorise.

## Contre-revue Codex terminee - 2026-10-07

L'operatrice a prefere Codex a Pi et a explicitement valide les sous-agents. Trois reviewers neufs (`fork_turns=none`, sans override modele) ont relu A3, S2/S3/S4 et les frontieres de capture. Rapport : `shipglows_data/workflow/reviews/conditional-skill-routing-forensic-review.md`. Aucun sujet original relance, aucune attente held-out ouverte, aucun artefact scelle ou grade modifie. La lecture seule etait contractuelle; aucun confinement physique des reviewers n'est revendique.

Les causes capturees et les contre-exemples sont confirmes : A3 reste confondu par son identite/preflight; les cas prives montrent statut non rafraichi, confusion brouillon/publication, perte du proprietaire ou lectures exclues. Les 48 paires conservent cinq gains candidat et une regression; les comptes 44/48 vs 40/48 et 20/24 vs 18/24 restent inchanges et encourageants. Deux frictions communes aux 96 runs sont etablies : catalogue avant bootstrap obligatoire, puis precedence refusee faute de relation explicite avec les noms de predicats. Une phrase residuelle de revue S2 confond capture interne et emission publique; le rapport annote cette erreur sans changer le grade.

Integrite : 2 478 entrees des 24 runs, 792 paires de recus, hashes/references des 24 revues et 105 references du scellement final verifies, aucun ecart inattendu. Les 15 differences stdout prive expurge/hash original sont attendues et declarees. Livraison native/provider complete, effets hors broker et couverture integrale restent UNKNOWN.

Decision : ne pas relancer une campagne identique sur le consommateur opaque. Une suite n'aurait de valeur qu'apres preuve prospective de capture sur un consommateur nomme, avec plan distinct, nouvelle baseline et nouveau held-out. Le rapport donne des charges conditionnelles (investigation locale plafonnee a 2 h; campagne comparable de l'ordre de 6-8 h, cout monetaire UNKNOWN). Aucun de ces travaux futurs n'est autorise ou lance ici. Pi reste une option de confrontation entre modeles, non executee.

## Integration CLI mock validee - 2026-10-07

L'operatrice a valide l'integration puis explicitement le binaire officiel Linux temporaire uniquement. Rapport actuel: `shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md`. Codex Linux 0.160.1 execute sous WSL/bwrap --unshare-all, environnement vide, montages bornes, aucun IPC/interop hote; preflight lo seul et ENETUNREACH101. Profil/config/projet neufs, provider Responses loopback sans vraie auth, aucune installation globale.

Preuve durable `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-cli-v1-20261007-attempt2/`: deux sessions exec independantes reussies, trois requetes de 39305 octets (200 puis503/200), retry corps identiques, prompt user dans chaque requete, deux messages assistant finaux exacts. Neuf checks vrais, 59 artefacts rehashes, source snapshot exact; deux reviews independantes favorables. Attempt1 echec de montage avantCLI conserve; incidents Docker/WSL de preparation documentes.

Cette preuve ne couvre pas conversation continue, callbacks d'outils, modele/fournisseur reel, app/sous-agents natifs, retention interne ou AC5. Neuf outils natifs declares; aucune exclusivite prouvee. Warnings flag storage ignore, fallback metadata et aliases helpers refuses conserves; store:false observe sur chaque requete. Usage10/2 fictif, temps locaux pas model latency. Migration NO-GO/seuils inchanges.

Prochaine preuve proposee: conversation continue avec callbacks/retours sous le meme confinement mock. Aucun appel fournisseur reel/campagne autorise. Ce changement de consumer impose baseline/protocole/held-out neufs si une campagne est ensuite decidee. Cette section supersede les anciennes mentions d'integration CLI encore a choisir ou non autorisee.

## Demonstration synthetique executee - 2026-10-07

L'operatrice a valide la demonstration locale par ? ok ?. Rapport actuel: `shipglows_data/workflow/reviews/conditional-skill-routing-capture-demonstration.md`. Fichier neuf `tools/conditional_skill_routing_capture_demo.py`, execute sans Doppler et sans runtime/model fournisseur. Preuve durable `tools/fixtures/conditional_skill_routing/capture-demonstrations/local-http-v1-20261007/`: 41 echanges/41 recus, 210 controles vrais, 480 blobs hashes, 2.2535211 s locaux. Source snapshot exact lie au summary. Deux reviewers ont relu transport et causalite. Echecs intermediaires b/c conserves avec revision source UNKNOWN.

La capture du transport synthetique et les gates exerces passent: refus/correction, spans partiel/complet, grant avec statut/capability expires puis refresh, digest de brouillon et substitution refusee, 503/retry, coupure/timeout, JSON invalide, erreur SSE sans done, taille requete/reponse et quota. Cette preuve est bornee aux scenarios; headers normalises, usage fictif, compaction simulee. Aucun modele, auth fournisseur, app Codex/sous-agents sujets, CLI reelle, retention interne ou confinement OS prouve. AC5/seuils inchanges, migration NO-GO.

Cette section supersede les mentions precedentes de demonstration encore a proposer. Prochaine decision: choisir une CLI/version pour integration mock avec egress/dependances effectivement bornes, avant tout appel fournisseur reel distinctement autorise. Aucune nouvelle campagne, install, mutation canonique ou Git/publication/deploiement autorise.

## Faisabilite de capture verifiee - 2026-10-07

Investigation locale explicitement demandee par l'operatrice, avec les trois sous-agents Codex deja autorises. Rapport: `shipglows_data/workflow/reviews/conditional-skill-routing-capture-feasibility.md`. Capture exhaustive a la frontiere client-fournisseur plausible sur une CLI instrumentee, mais non demontree de bout en bout; capture de l'app et des sous-agents natifs non etablie. Retention/utilisation interne des instructions reste UNKNOWN.

Verification: 11 tests existants collecteurs/pipes/correlation passes en 0.791 s; schemas hors session generes sous profils temporaires vides pour CLI 0.160.1 (440 fichiers) et executable embarque 0.149.0 (401). Aucun thread/turn sujet, appel fournisseur externe pilote, installation ou nouvelle campagne. Le probe OpenCode integre n'a pas ete lance: confinement reseau hote et dependances non prouves. Les surfaces raw events/usage Codex ne prouvent pas une capture exhaustive des requetes.

Prochaine etape proposee: demonstration synthetique bornee de transport, puis profil integre effectivement confine, avant tout appel reel distinctement autorise. Enveloppe de planification 2-4 h pour prototype local/revue, non mesuree; integration/confinement peuvent depasser. AC5 delivered/retained et seuils inchanges; aucune preuve client ne certifie les etats internes du modele. Migration NO-GO conservee. Cette section supersede les anciennes mentions de faisabilite encore a faire; aucun prototype nouveau ni campagne n'est autorise ici.

## Suite recommandee et point de decision

**Lecture recommandee : resultat encourageant, preuve encore insuffisante pour migrer.** Le candidat gagne 4 observations sur 48 au total et 2 sur 24 en held-out. Ce signal est positif et justifie d'examiner la trajectoire, sans le traiter comme une victoire acquise : A3 est confondu par le contrat de fixture, les gains/fautes sont concentres dans quelques familles, quatre echecs candidat restent reels, et la couverture complete des consignes n'est pas prouvee. NO-GO de migration est un verdict de preuve et de promotion, pas la conclusion que le travail n'a servi a rien.

La **revue forensique locale des traces deja scellees** est terminee par trois sous-agents Codex, choix explicitement valide par l'operatrice. Lire le rapport de contre-revue avant toute nouvelle proposition. Pi 1.0.3 reste installe mais n'a pas ete lance; un autre modele pourrait apporter une confrontation distincte, sans remplacer les preuves manquantes. Ne pas relancer les sujets originaux ni exposer un nouveau held-out a un auteur de candidat. Aucune revue ne peut recuperer retroactivement des entrees natives non enregistrees.

Apres cette revue, prendre une decision fondee sur les causes : (a) si les traces expliquent les echecs et une capture plus complete parait faisable, preparer un nouveau plan chiffre avec fixture A3 corrigee et nouvelle held-out; (b) si le gain reste fragile ou les preuves de livraison irrealisables, conserver le candidat comme piste prometteuse non promue et arreter les appels couteux. Aucune nouvelle campagne, appel fournisseur, installation ou migration n'est autorise par ce handoff. La campagne precedente a coute environ 6 h 23; toute proposition doit expliciter le cout attendu et ce qu'une nouvelle preuve changera dans la decision.

### Revue achevee et decisions restantes

1. Revue A3/S2/S3/S4 achevee par sous-agents Codex : causes, contre-exemples, erreurs de libelle de revue et frontieres du broker documentes dans `conditional-skill-routing-forensic-review.md`. Ne modifier aucun artefact scelle.
2. Audit du consommateur Codex partage et des modules geles egalement termine : les frontieres instruction/stdout, messages/injections, entree provider, brouillon/reponse, chronologie et effets natifs sont distinguees dans le rapport. Les mesures absentes restent UNKNOWN, jamais zero; aucun test ou sujet original relance.
3. Conclusion de decision livree : signal encourageant conserve, causes capturees expliquees, aucune campagne identique justifiee sans preuve prospective de capture. Les charges futures sont conditionnelles et ne valent pas autorisation. Tout prototype de capture, autre consommateur ou nouvelle evaluation exige une proposition distincte avant execution.
4. Garder NO-GO migration jusqu'a satisfaction des gates; ne pas effacer le signal positif observé ni le presenter comme preuve acquise. Ce handoff n'autorise aucune campagne, appel facture, installation, changement canonique, publication, Git en ecriture ou deploiement.

### Si une nouvelle campagne est ensuite autorisee

- Commencer par corriger l'incoherence A3 dans une nouvelle copie de fixture: le schema de preflight expose `sg-help`, la requete vise `sg-content` et le corps cible declare `sg-help`. Revoir ensemble le schema et l'identite du corps; ne pas supprimer les trois echecs A3 du dossier scelle.
- Transformer les echecs observes en regressions explicites: cinq echecs d'audit A3 (deux baseline, trois candidat); rafraichissement de statut prive apres octroi S2/S4; maintien de `sg-content` comme proprietaire principal en S3; ne pas lire les ressources exclues; produire le brouillon factuel permis apres controles plutot que le retenir. Clarifier aussi bootstrap, precedence et la capture interne du brouillon dans un nouveau protocole.
- L'evaluateur cree un nouveau jeu held-out complet et le scelle avant que l'auteur ne voie ses attentes. L'ancien held-out est desormais connu de l'auteur: ses exemples peuvent etre etiquetes regressions connues, jamais reutilises comme held-out neuf.
- Refaire une baseline comparable si une correction change fixtures, schema, consignes ou options d'action. N'ecrire aucun candidat avant les observations de baseline requises. Faire revoir et geler le nouveau candidat avant toute evaluation held-out.
- Conserver les memes seuils. Executer a nouveau les 96 sujets / 48 paires et leur scoring independant seulement si la capture permet une conclusion utile. Conserver les echecs, refus, erreurs de transport et artefacts originaux; aucune reparation ou relance apres observation.
- Promotion exige comportement sans violation, couverture des consignes suffisamment prouvee et mesures sous les seuils d'origine. Sinon, conclure NO-GO/inconclusif sans migration canonique.

### Reprise autonome pour un agent

```text
Cible: C:/Users/Diane/ShipGlows/shipglows. Lire ce handoff puis la spec `shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md`, la calibration `shipglows_data/workflow/reviews/conditional-skill-routing-calibration.md` et le rapport scelle `tools/fixtures/conditional_skill_routing/shared-host/evaluator-final96/final-independent-report.md`.

Decision actuelle: pilote native shared-host termine (96/96); signal observé encourageant (44/48 candidat vs 40/48 baseline; held-out 20/24 vs 18/24), mais pas encore une preuve fiable de gain. NO-GO migration; cout/livraison/couverture inconclusifs. Traces substantielles existent: broker, recus request/response, stdout, refus, erreurs et revues liees aux event IDs. Contre-revue Codex A3/S2/S3/S4 et frontieres de capture terminee par trois sous-agents, voir `shipglows_data/workflow/reviews/conditional-skill-routing-forensic-review.md`. Pi non lance. Les entrees natives completes restent inconnues. Preserver les nombreux changements non lies dans le worktree. Branche et HEAD verifies: main, e14fd26ef1cf06b47883bf3499638ad4a7b0c452; revalider le git status avant tout travail. Execution de ce projet: Doppler NONE.

Revue forensique des traces et audit des frontieres deja effectues, ne pas les relancer par defaut. Les traces expliquent les causes observees et montrent des contre-exemples reussis; elles ne prouvent pas livraison native complete ou confinement. La faisabilite locale et la demonstration HTTP synthetique sont maintenant terminees; lire `conditional-skill-routing-capture-demonstration.md`. L'integration CLI mock est maintenant validee: lire `conditional-skill-routing-cli-capture-integration.md`. La prochaine preuve porte sur une conversation continue avec callbacks/retours, avant toute campagne. Distinguer donnees broker, entrees/sorties provider-modele et effets natifs; UNKNOWN n'est jamais zero. Aucun nouvel appel fournisseur/campagne, reparation de l'ancienne, ouverture des attentes held-out a l'auteur, modification canonique, installation, publication, commit/push ou deploiement.

Si une suite semble faisable, exposer d'abord le plan, le cout d'une nouvelle campagne et les gates: reparer A3 dans une nouvelle fixture, ajouter les echecs S2/S3/S4 et les lectures interdites aux regressions, new held-out distinct scelle a neuf, baseline avant candidat et nouvelle evaluation 96/48. Attendre l'autorisation de l'operatrice avant toute nouvelle campagne de sujets.
```

Tout evidence deja recueillie est dans `tools/fixtures/conditional_skill_routing/shared-host/evaluator-final96/`; le registre est `shipglows_data/workflow/reviews/conditional-skill-routing-runs.json`. Ne pas confondre l'experience partagee terminee avec le consommateur isole historique, toujours fail-closed. Aucun travail de production ne suit du resultat actuel.

## Historical preparation handoff (superseded current state)

Prior zero-run/no-model/pending-authority statements below are dated historical records. Preserve provenance/failures; use current state above for resumption.

---

# HANDOFF - terminer le pilote de routage conditionnel

## Reprise et objectif

Reprendre dans le MEME checkout Windows C:/Users/Diane/ShipGlows/shipglows. Les fichiers du pilote sont locaux et non suivis : un autre clone ne suffit pas.
Objectif : terminer preparation, puis experience autorisee et evaluation, sans declarer le pilote valide sur la seule preuve unitaire. Ne pas refaire ideation, migrer les skills ou fabriquer des routeurs avant baseline observe.

Commencer par verifier racine canonique selon instructions actives, branche, HEAD et git status. Dernier HEAD verifie : e14fd26ef1cf06b47883bf3499638ad4a7b0c452, branche main. Nombreux changements tiers : tous a preserver. Aucun commit/push/deploiement pour le pilote.
Lire AGENT.md, CLAUDE.md et references applicables ; skill sg-engineering deja appliquee. Doppler NONE pour execution de ce projet, decision explicite aussi documentee dans AGENT.md. Aucune credential a lire/exporter.

## Sources principales

- shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
- shipglows_data/workflow/reviews/conditional-skill-routing-calibration.md
- shipglows_data/workflow/reviews/conditional-skill-routing-runs.json
- tools/fixtures/conditional_skill_routing/manifest.json
- tools/conditional_skill_routing_runner.py et tools/test_conditional_skill_routing_runner.py
- tools/conditional_skill_routing_eval.py et tools/test_conditional_skill_routing_eval.py
- tools/fixtures/conditional_skill_routing/cases.json (tuning uniquement)

Spec/annexe actives 1.2.0 ; snapshots originaux 1.0.0 conserves dans manifeste. Le dossier comporte de nombreux checkpoints historiques : ne pas les confondre avec etat actuel.

## Autorisations et limites

Autorise : preparation offline runner/tests/preuves/spec/annexe/manifeste ; tests sans sujet modele ; revue independante en lecture seule.
NON autorise actuellement : appel reel de sujet modele/fournisseur facturable/campagne, installation, modification canonique, acces prive reel, publication, Git en ecriture/deploiement.
Une question d'autorisation de l'experience complete (baseline puis candidat puis 96 runs, apres validation prerequis) a ete envoyee ; AUCUNE reponse recue a la transmission. Silence et continuation automatique ne valent pas consentement.

Clarification S1/S2 recue : resume court dans conversation = owner sg-content, helper seulement si redaction substantielle ; protections privees, expurgation et rubrique final-draft maintenues. Ferme documentairement le tuning, sans modifier les canoniques.
L'operateur a confirme la revue independante lecture seule. Agent existant /root/independent_pilot_review ; pas de held-out ni sujet modele ni campagne. Une revue des dependances de revision source est en cours au passage de contexte ; recuperer son resultat si agent encore disponible. Ne pas creer d'autres agents sans autorite applicable.

## Ce qui est livre et prouve

Evaluateur strict et fixtures ; runner Python stdlib avec worker WSL bubblewrap, brokers outils fixture/MCP, captures exactes des instructions/framing et effets simules, approbation conditionnelle, grants privees fictives, expurgation, audits simules, verification ciblee et preuves de scope. Assembleurs tuning H/A, B1/B2 et S1/S2 revus independamment dans leur perimetre offline.
Codex Windows 0.160.1 inspecte : absence de preuve de suppression exclusive des builtins, unified_exec persiste. Ne pas presenter son transport comme confine.
Probe OpenCode installe + fournisseur local MOCK + WSL reussie : aucune invocation de modele reel. Cela ne certifie pas le runtime modele ni un raccordement de campagne.
launch_subject refuse toujours ; runtime complet non livre/certifie.

Dernier runner : 90 tests passent (39.262 s). Evaluateur : dernier run 127 tests, 4 echecs + 1 erreur dus au drift source content ci-dessous. Regression qui supposait encore closure review_pending corrigee, test cible passe. Ne pas annoncer suite evaluateur verte. Lint metadata spec/annexe passe avant dernier archivage. Echec historique QualityPilot common-page-comprehension conserve ; pas de suite globale verte revendiquee.
Timeouts WSL intermittents conserves comme preuves, pas effaces/requalifies.

## Nouveau blocage : source canonique content modifiee par travail tiers

skills/007-sg-content/SKILL.md a change hors de ce chantier.
Snapshot content : 89d9c3cddf781f0352d36da42429b2e7fb5a2ee4141952c4825df361c38ac32a
Live verifie : a72c339fd990eb4a8e1becdef063f54f32ac10c16cc648bc95c40b5a63b14a90
L'evaluateur refuse correctement : mandatory selected live source drift: content.
Ne PAS enlever ce controle, restaurer le fichier tiers ou remplacer silencieusement les snapshots.

Trois nouvelles branches conditionnelles : blog/CMS, identite publique auteur, provenance assets creatifs. Revue independante tuning : toutes FALSE pour S1/S2 actuels ; aucune lecture obligatoire additionnelle justifiee. Compatibilite held-out NON revue.

Travail tout juste effectue :
- archive complete exacte du manifeste avant revision, sous tools/fixtures/conditional_skill_routing/preparation-revisions/manifest-before-content-revision-<sha256>.json ; chemin/hash precis dans content_source_revision_preparation du manifeste et ledger ;
- proposition INACTIVE content-live-revision-proposal.json dans ce dossier, snapshot live et O8/O9 full-file spans/hashes proposes ;
- aucune revision de source active appliquee ; 52 snapshots/31 witnesses historiques conserves dans archive ;
- proposition pas encore validee/revue, comptabilite pas encore recalculee.
Premier essai archivage a echoue sur normalize_text(str) ; corrige avec normalize_text(bytes), puis preparation reussie. Aucun test de la proposition execute.

Suite source : revoir toutes dependances (versions/provenance/obligations/comptabilite/audit frozen-root), expliciter revision active et conserver archive, revoir couverture independamment. Un evaluateur DISTINCT doit verifier compatibilite held-out sans exposer auteur ; reviewer actuel n'a PAS autorisation de lire held-out. Ne pas activer une source et lever lancement sur seul avis tuning.

## Held-out et protocole

NE PAS ouvrir les prompts/attentes de evaluator-cases.json comme auteur/integrateur. Preflight sans affichage seulement. Digest canonique : d50cd44ab951d32c811a4c11d821bd861b329d0285c12caf52c4c4344c28bf07.
Campaign ID conditional-skill-routing-v1-campaign-1 ; not_started ; runs=[] ; modele reel 0 ; baseline observe 0 ; candidat not_created. Cinq pages candidates absentes volontairement.
Auteur en pause pendant held-out ; sujets recoivent leur prompt/fixture, jamais attentes ; candidat fige. Exposition puis reparation exige nouvelle campagne/nouveau held-out complet et conservation echecs.

## Suite technique concrete

1. Terminer reconciliation source explicite et validations ci-dessus.
2. Unifier transport executable des huit assembleurs tuning ; prouver inventaire exclusif, outils indirects, frontiere fournisseur/reseau et confinement runtime reel.
3. Figer protocole sujet visible : declarations routage, approbations/grants, drafts/checkpoints/reports ; capture exacte chronologie ordonnee, refus et sorties echouees compris, durees/config par run.
4. Export ledger durable expurge ; traces privees seulement ephemeres pour evaluation ; revue semantique/rubric S distincte.
5. Apres autorisation appels reels ET validation independante prerequis : baseline tuning observe AVANT redaction candidat ; puis cinq pages, revue/freeze ; campagne finale et scoring held-out independant.

96 runs/48 paires, 4 familles, 2 tuning+2 held-out chacune, 3 repetitions, 2 variantes. Rep1/3 baseline puis candidat, rep2 inverse. Mesure caracteres reellement livres, relectures comptees, UNKNOWN jamais FALSE/zero. Gain familial moyenne des deux reductions relatives par cas held-out, jamais pooling. Seuils inchanges : >=15%, mediane candidat<=baseline, run<=105% mediane baseline, lectures<=baseline+2, profondeur<=3, latence<=1.25. Aucun gain ne prouve occupation totale contexte opaque.

Tests autorises : python -B -m unittest tools.test_conditional_skill_routing_runner ; python -B -m unittest tools.test_conditional_skill_routing_eval ; preflight evaluateur --cases tools/fixtures/conditional_skill_routing/cases.json --manifest tools/fixtures/conditional_skill_routing/manifest.json --format text ; lint deux docs. Tant que source non reconciliee, refus attendu du preflight doit etre conserve.

## Etat honnete

T2 evaluateur implemente ; fermeture documentaire tuning revue ; runner composants offline avances, transport complet non prouve. T3/T4 non executes. Pilote NON valide experimentalement et implementation complete NON terminee. Recommandation pending ; migration no-go ; aucune promotion autorisee.
L'operateur demande avancee autonome et explications simples : pas de nouvelles confirmations routinieres, seulement autorite materiellement manquante. Ce handoff transmet le chantier, il ne resout pas les gates restants.

## Revue de strategie recue avant transmission

Reviewer independant approuve la preparation INACTIVE, sans activation. Recalculer aussi baseline_tokens/budget.max_tokens S1/S2 via audit_scenarios(frozen_root copie), regenerer receipts/hashes bundles S, lier nouvelle revue documentaire aux octets live et expliciter parent/hash revision. Injections communes independantes de content : hashes inchanges. Revue semantique O8/O9 et compatibilite held-out distincte restent obligatoires. Aucun held-out ou modele ouvert par reviewer ; aucun fichier modifie par lui.


### Revision proposal calculation (2026-10-07 continuation)

Using the proposed content snapshot in a disposable frozen root, `audit_scenarios` initially found the old S budgets undercounted. Recalculated static unique-read values: S1 30,852 and S2 32,381; depth remains 3, both within revised declared max/baseline and min reduction 0. These are static counts, not observed baseline. The eight other static scenarios remain valid. Reassembled S1/S2 offline bundles against proposed source: receipts are in `content-live-revision-proposal.json`; synthetic private record stays outside generic bundle; runtime_ready false and model_calls 0. This does not approve O8/O9 semantic coverage or held-out compatibility. Active manifest remains frozen and evaluator will continue rejecting live content drift until revision is independently approved and activated.


Un manifeste complet de revision inactive est maintenant prepare : `tools/fixtures/conditional_skill_routing/preparation-revisions/manifest-content-live-revision-inactive.json`. Le preflight `validate_contract` passe en `structural=valid`, seal held-out valide (8 cases, digest identique sans afficher le contenu), `ready=false`. Restent notamment couverture independante, revue held-out distincte, isolation/transport, baseline et candidat. Aucun fichier actif ne pointe vers la revision. Les hashes precis sont dans la preuve `content_source_revision_preparation` du manifeste et du ledger.


### Codex app-server live capability probe (2026-10-07)

`--inspect-codex` generated temporary schemas and confirmed dynamic tool protocol support, but that does not prove an exclusive tool inventory. A bounded `--probe-app-server` used a disposable empty CODEX_HOME, disabled features and registered dynamic tools on an empty ephemeral thread without a turn. It exited fail-closed because these features remained enabled: `unified_exec`, `terminal_resize_reflow`, `tool_search_always_defer_mcp_tools`, `resize_all_images`, `item_ids`, `collaboration_modes`, `tui_app_server`. No model call, user CODEX_HOME or credentials. Codex cannot currently serve as an isolated subject via this profile. Probe evidence is recorded in manifest/ledger as `codex_app_server_isolation_probe_latest`.


### Independent review of inactive content revision

Reviewer approved O8/O9 full normalized spans `[0, 6735)` with hash `3b40ac72e95e9d51d866f79cee5264d758a99d8951fcb17308b14a13a29ba155`, for inactive preparation only. S1/S2 static counts (30,852 / 32,381), budgets and bundle receipts reproduced; private record excluded from generic bundles. Obligations, protections, authority limits, injections, thresholds and mappings preserved. Three newly added references remain conditional and nonmandatory for these tuning cases. Historical approvals are historical. The receipt is recorded in the inactive manifest and proof ledger. Held-out compatibility remains unreviewed by a distinct evaluator; activation is not approved.


### D?tail du sch?ma Codex

Les sch?mas g?n?r?s en temporaire confirment `dynamicTools`, mais aussi `permissions` comme identifiant de profil sans ?num?ration d?un profil sans outils, `sandbox` avec read-only/workspace-write/danger-full-access, et des champs de racines/runtime environment. Ils ne prouvent donc pas le retrait des outils h?te. L?inventaire app-server a ?chou? ci-dessus avec sept fonctions toujours activ?es. Hashes de sch?mas et nettoyage consign?s dans le manifeste/ledger.


### Codex feature-disable diagnostic correction and tests (2026-10-07)

The original app-server probe stopped before trying the runtime disable RPC. It now requests disablement for the complete runtime feature inventory and validates the returned receipt and a second inventory. Codex accepted only a partial update; seven features remained enabled (see exact list in manifest/ledger), so it fails closed before thread creation/turn start. No model or credential access. `python -B -m unittest tools.test_conditional_skill_routing_runner`: 90 passed in 26.812 s. The inactive revision preflight remains structurally valid, sealed-valid without content reporting, readiness false. Metadata lint passed for spec and calibration; both living docs are 1.3.0 while embedded frozen snapshots remain unchanged.


### Independent Codex probe review and fail-closed correction ? 2026-10-07

The reviewer found that a resumed inventory must require `enabled` to be a real boolean exactly `false`; missing, null, integer zero or other values cannot count as disabled. The probe now validates every row, unique names, the complete unchanged inventory, and acknowledgement of every previously enabled feature before it can send `thread/start`. Unit tests cover malformed inventories/receipts and assert no thread request is sent. Live probe now stops before thread creation because Codex does not acknowledge disablement for seven still-enabled features, including `unified_exec`. Runner suite: 93 tests passed in 35.215 seconds. No turn, model or credential access.


Installed `codex exec --help` exposes no exclusive tool-inventory option. Its read-only sandbox is documented as applying to model-generated shell commands only. This confirms the current Codex profile has no proven confinement route; details are in `codex_cli_restriction_surface_check` in the manifest/ledger.
