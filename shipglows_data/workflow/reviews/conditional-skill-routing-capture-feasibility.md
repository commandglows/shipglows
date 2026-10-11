---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-prospective-capture-feasibility
owner: Diane
confidence: medium
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-forensic-review.md
  - tools/conditional_skill_routing_runner.py
depends_on: []
supersedes: []
evidence:
  - "Operator explicitly requested verification of complete-capture feasibility; three previously authorized Codex reviewers inspected separate local surfaces."
  - "Eleven existing bounded collector/pipe/correlation tests passed in 0.791 seconds."
  - "Empty-profile offline schema generation succeeded: Codex CLI 0.160.1, 440 JSON files; embedded executable 0.149.0, 401 JSON files."
next_step: "Synthetic HTTP demonstration completed; plan named CLI mock integration with actual egress/dependency bounds before any real call or campaign."
---

# Faisabilite de capture complete

Suite executee et revue: `shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md`. Codex Linux0.160.1 sous WSL/bwrap a reussi deux sessions mock avec trois requetes capturees. Les anciennes propositions d'integration ci-dessous sont historiques; callbacks/continuation et AC5 restent non valides.

Suite autorisee ensuite par l operatrice et executee: `shipglows_data/workflow/reviews/conditional-skill-routing-capture-demonstration.md`. La demonstration du transport HTTP synthetique passe (41 echanges, 210 controles); integration CLI/app et retention modele restent non prouvees. Les propositions ci-dessous sont historiques a cette investigation.

## Verdict

**Faisable en principe a la frontiere client-fournisseur sur une CLI instrumentee; pas encore demontre de bout en bout.** Une capture exhaustive de l'app Codex et de ses sous-agents natifs n'est pas etablie par les interfaces inspectees. Les consignes effectivement retenues/utilisees a l'interieur du modele restent opaques: une requete capturee prouve les octets envoyes, pas leur traitement interne.

L'investigation demandee est terminee. Aucun sujet original, nouvelle campagne, appel externe fournisseur pilote, installation ou ouverture des attentes held-out. Les trois sous-agents sont des sessions de revue, pas des observations du pilote. Les sources, seuils et artefacts scelles restent inchanges. Aucun test nouveau ajoute.

## Frontieres et preuves

| Frontiere | Verification locale | Conclusion |
| --- | --- | --- |
| Broker, refus, erreurs, octets et sorties deja conserves | Contre-revue precedente et collecteurs existants | Utilisable; pas une reconstruction des entrees natives absentes |
| Pipes, limites, timeout, correlation callbacks et injections | 11 tests existants passes | Briques locales verifiees; aucune preuve de livraison a un modele |
| Codex CLI 0.160.1 | 440 schemas generes hors session | Appels dynamiques, sorties brutes et usage exposes; transport exhaustif non demontre |
| Executable embarque Codex 0.149.0 | 401 schemas generes hors session | Surfaces proches mais differentes; pas preuve du comportement de l'app |
| OpenCode 1.18.32 | Code du probe et installation inspectes | baseURL locale instrumentable; probe actuel ne conserve pas tout le transport |
| Contexte retenu/utilise par le fournisseur-modele | Aucun acces interne | UNKNOWN; hors preuve client |
| Effets hors broker et absence d'egress parasite | Aucun confinement hote prouve | Bloquant pour une preuve exhaustive d'execution |

### Schemas Codex effectivement generes

Les deux executables ont execute seulement --version et app-server generate-json-schema --experimental --out, dans des repertoires temporaires neufs, avec CODEX_HOME, HOME, USERPROFILE, APPDATA et LOCALAPPDATA temporaires. Environnement transmis limite aux variables systeme de lancement et a ces chemins; aucune cle ou configuration utilisateur transmise. Aucune creation de thread/turn. Sorties 0; repertoires nettoyes. Ce diagnostic n'est pas une preuve generale de confinement reseau.

Les schemas exposent ThreadStartParams.experimentalRawEvents, DynamicToolCallParams (arguments, callId, threadId, turnId), RawResponseItemCompletedNotification (item, threadId, turnId), RawResponseCompletedNotification (responseId, usage, et usageMetadata dans 0.160.1), ThreadTokenUsageUpdatedNotification. Ce sont des surfaces de protocole, pas la preuve que chaque requete fournisseur complete et chaque sortie app seraient enregistrees. Aucun abonnement aux notifications n'a ete execute.

Hashes SHA256 des schemas utiles:

| Schema | CLI 0.160.1 | Embarque 0.149.0 |
| --- | --- | --- |
| ThreadStartParams.json | 80a40a7fac15b4bf70efb7f893fb353acc0a0d30c68f54aee4f01923deca85de | 25f490368ec6df52a2a3b82a5469d2413307eb93439121b309f415b5648eee7a |
| RawResponseCompletedNotification.json | aba140e87952c900f96e0308a8849d3e313d985de1f1aa2b77f193884a76357c | dab430b6c6e2ebb51d1fa2acdc597418ce68b12710382d4d93b652efd47fb61a |
| DynamicToolCallParams.json | 401bba20cfbd95762bef0467d840430c46be53369093ad9f26425ba757e34efc | 401bba20cfbd95762bef0467d840430c46be53369093ad9f26425ba757e34efc |

L'aide expose aussi debug prompt-input (? Render the model-visible prompt input list as JSON ?). Commande non executee: l'aide ne prouve ni les octets reseau ni la couverture de toutes les iterations/compactions. exec --json fournit des evenements, pas une capture exhaustive de transport. app-server proxy est un proxy du protocole de controle app-server, pas un proxy fournisseur. Le probe historique d'inventaire exclusif reste fail-closed: sept fonctions non desactivees. Il n'a pas ete relance.

### Limites concretes du probe OpenCode existant

Dans tools/conditional_skill_routing_runner.py, capture_host_input (vers 1107) conserve roles, hashes, caracteres et champs, pas l'enveloppe exacte complete. probe_opencode_profile (vers 2173) recoit les corps HTTP en memoire, mais detruit le temporaire et ne persiste pas toutes les requetes, en-tetes, methodes/URL, statuts, SSE bruts, coupures, usages, retries et erreurs. Les requetes Responses input ne sont pas couvertes par la selection chat_requests. La verification d'injection porte sur la premiere requete, pas toutes les iterations.

observe_process_streams (vers 2041) conserve des octets et horloges de reception; cela ne donne pas l'heure d'emission native ou une causalite totale. correlate_callback_deliveries (vers 2112) lie noms, arguments, charges et identifiants; cette preuve synthetique ne constitue pas une authentification du fournisseur. Les sorties step_finish et une partie des usages ne sont conservees que comme hashes.

Le profil utilise une baseURL locale, une cle fictive, des repertoires neufs, plugin=[] et des outils natifs refuses. Mais le processus Windows OpenCode n'a pas de confinement reseau prouve; une resolution de paquet/catalogue reste possible avec cache neuf. Le confinement WSL du worker ne confine pas OpenCode. **Probe integre non execute** sous le scope sans installation/appel externe. Le nombre de requetes est controle apres reception, pas borne a l'admission.

## Verification executee

Suite ciblee de tools.test_conditional_skill_routing_runner.BoundaryTests: 11 tests, 0 echec, 0 erreur, 0.791 s. Perimetre: collecteurs en memoire et processus Python bornes, sans session Codex/OpenCode sujet ni fournisseur.

- live_stream: cleanup_failure_preserves_capture; capture_preserves_original_bytes_and_receipt_clock; timeout_retains_partial_capture_and_terminates_process; limit_fails_closed_and_keeps_earlier_bytes.
- callback_correlation_binds_exact_ids_arguments_payload_and_clock.
- output_stream: captures_every_visible_response_and_exact_hashes; refuses_unknown_events_and_missing_visible_response; retains_response_and_receipt_before_later_error.
- combined_injections_count_source_and_framing_once_atomically.
- host_input_capture_and_exact_injection_spans.
- injection_capture_rejects_user_quotes_changed_and_repeated_text.

Les noms ci-dessus abregent seulement le prefixe test_. Aucun resultat de mock ne prouve des decisions d'un modele reel.

## Preuve suivante necessaire

1. Prototype de capture sur un consommateur/version nomme: endpoint explicite ou proxy inverse local qui persiste avant parsing chaque corps requete et reponse, methode, destination, statut, flux SSE et interruptions, avec horloge monotone, identifiants et limites a l'admission. Expurger les en-tetes d'auth; aucune cle dans les traces. Un proxy CONNECT seul ne voit pas le contenu TLS.
2. Replay synthetique couvrant deux iterations et repetitions d'instructions, lecture partielle/complete, refus puis correction, grant et invalidation du statut, brouillon interne, controle de redaction, reponse visible, timeout puis erreur. Distinguer draft_submission, redaction_result et visible_response. Garder octets exacts, hashes, transformation d'expurgation et politique de retention.
3. Demo integree avec profil vide et sorties reseau effectivement bornees. Verifier chaque requete, chaque outil/effect et chaque resultat avant l'action dependante. Mesurer usages reels disponibles; un mock usage=1/1 n'est pas une mesure. Ne pas modifier les modules geles pour cette preuve.
4. Une minuscule validation fournisseur reelle exigerait ensuite autorisation et budget distincts. Pas de campagne 96 runs tant que les gates precedents ne passent.

Charge de planification, non mesuree: 2-4 h pour un prototype synthetique local et une revue; le confinement et une integration CLI complete peuvent depasser cette enveloppe. Aucun montant fournisseur estime ou appel reel autorise. Arreter au plafond si le consommateur choisi ne permet pas la preuve, plutot que financer une campagne opaque.

## Limite d'acceptation a conserver

AC5 exige actuellement des spans normatifs complets ? actually delivered/retained ?. Une capture client peut etablir la livraison au transport et la presence dans toutes les requetes observees, pas une retention interne du modele. **AC5 et les seuils restent inchanges.** Une clarification de cette frontiere serait une decision explicite distincte, pas une correction implicite de l'evaluateur.

Conclusion: conserver le candidat prometteur non promu. La faisabilite justifie une proposition de demonstration locale bornee, pas une migration ni une nouvelle campagne.
