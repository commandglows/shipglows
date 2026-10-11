---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-cli-instruction-delivery-and-native-compaction
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_cli_instruction_capture.py
  - tools/conditional_skill_routing_cli_compaction_probe.py
  - tools/conditional_skill_routing_cli_mock_launch.py
  - tools/conditional_skill_routing_responses_accounting.py
  - shipglows_data/workflow/reviews/conditional-skill-routing-cli-continuity.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-real-comparison-preparation.md
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
depends_on: []
supersedes: []
evidence:
  - "Operator requested autonomous preparation with subagents, then specified real-model baseline/candidate comparison without launch."
  - "Instruction proof: seventeen checks, nine Responses requests, 126 hashed captures."
  - "Native local compaction/recovery: thirteen checks, three user turns, eight Responses requests, 180 hashed captures."
next_step: "Finish the selected Codex Linux broker-only transport and scenario bindings, then independently audit real-comparison preparation without launching it."
---

# Instructions, injections et compaction native : fournisseur simule

Deux nouvelles preuves utilisent le meme ELF officiel temporaire Codex Linux 0.160.1, verifie et supprime apres execution, sous WSL/bwrap avec seul loopback et ENETUNREACH=101. Aucun modele/fournisseur reel ou campagne lance. Le source monte est un snapshot read-only; seuls le workspace synthetique et /tmp sont writable. Aucun checkout, profil utilisateur, socket hote ou interop monte. Les receipts du launcher sont hors du workspace.

## Lectures et injections

Dossier `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-instructions-v1-20261007-attempt1/`; summary SHA256 `2d087cae14824363a1fe6bd1e8baeba2919ee0712f23a6c537a5d32e950944c7`.

Un thread/tour `exec`, sept callbacks, neuf requetes avec retry 503 byte-identique. Le CLI execute lecture partielle de 29 caracteres Unicode, garde d'action refuse exit41, lecture complete de 257 caracteres, relecture, action autorisee, erreur exit23; l'escalade finale est refusee avant execution. La zone normative comporte 102 caracteres. Sa couverture reste partielle avant http-005 et devient complete dans http-005; l'injection hostile citee dans les sorties est separee des spans normatifs.

Les instructions synthetiques AGENTS sont presentes exactement aux roles observes user/developer et le prompt commun au role user dans chaque requete. Le texte hostile ne figure pas avant sa lecture; il reste un resultat d'outil, jamais un grant. Les arguments/call_ids et sorties CLI/callbacks sont verifies exactement. Le garde est un mecanisme fictif fourni par l'outil; ce n'est pas une demonstration de raisonnement ou de resistance du modele a l'injection.

Revue independante : 126 captures rehashes, ledger natif `[0,29)`, `[0,257)`, `[0,257)` compare aux octets de fixture; sortie des six commandes et sept appels verifies, retry identique. `accounting.json` SHA256 `0fe38e12250cb19c5a54d6a82d10b94feded9802d2aa6fa718a952ccc1231612`, avec source/replay du comptable conserves hors workspace. 2 545 caracteres de source livres sur toutes requetes, historique/retry/relecture compris; 186 965 caracteres de texte d'entree inventories. Ce dernier compte exclut schemas, noms/arguments d'outils et framing JSON; les corps HTTP complets ont leurs propres tailles/hashes. Aucune assimilation au total de tokens internes.

## Compaction et recuperation

Le probe app-server est fonde sur les schemas generes par le meme ELF dans `codex-linux-schema-v2-20261007/` (448 artefacts, aucun appel modele). Il utilise `thread/compact/start` sur un thread ephemeral, pas une suppression manuelle d'historique par le driver. Le fournisseur mock repond avec une synthese deliberement privee de la sortie diagnostique.

Attempt1 conserve : `codex-linux-compaction-v1-20261007-attempt1/`, summary SHA256 `3e973c5512c69381f11fb6dd23a95a69600ce5e07df4bf658fd85fbac30c13c2`. `environments=[]` desactivait effectivement l'environnement; `exec_command` n'etait pas annonce, et le callback etait `unsupported call: exec_command`. Le stream echoue, le tour termine failed. Aucun resultat de ce probe n'est promu.

Attempt2 : `codex-linux-compaction-v1-20261007-attempt2/`, summary SHA256 `21c0fe1994191b3d8bdd2a62917c2226d4a73ef4f6e5150f697922e26b1cf179`, source SHA256 `a47fc11bfd17a791f542fa729af55d668ee0e53ab5606b5148f04fd8ac319124`. Le profil utilise l'environnement local confine et exige l'annonce de exec_command avant son appel. Un seul thread, trois tours utilisateur distincts termines completed, huit requetes Responses. Le CLI annonce un item `contextCompaction` completed; la requete de compaction contient le callback exact. La requete suivante contient la synthese exacte, les instructions base/developer/AGENTS, et ne contient plus la sortie diagnostique precedente.

Le driver invalide la disponibilite observee de la fixture. Au troisieme tour, le garde fictif refuse exit41; le CLI relit exactement la fixture, le retour entre dans la requete suivante avec span/hash verifies, puis le garde accepte exit0. Ce mecanisme prouve la perte dans le transport, sa detection et la recuperation de livraison observee. Il ne prouve pas que le modele a retenu ou applique une protection.

Revue brute independante : 180 captures rehashes, RPC stdout original reproduisant exactement les events parses, trois tours utilisateur completed et compaction completed, quatre sorties natives/codes0,41,0,0 verifies. `accounting.json` SHA256 `dd935e86034981df473b8864b870817ba418d3c289e364644719f3643ce2dff8` conserve hors workspace, avec replay/source. La couverture diagnostique des huit requetes est `[false,true,true,false,false,false,true,true]`; l'invalidation change la generation de disponibilite et la relecture restaure seulement la livraison observee dans http-007. 292 caracteres diagnostiques livres, retransmissions comprises; 29 988 caracteres de texte d'entree inventories, avec les memes exclusions que la preuve precedente.

## Bornes, incidents et limites

Le launcher generique verifie archive SHA256/SHA512 et ELF, snapshot source, configuration/environment neufs, timeout Linux et wrapper borne (240 s instructions, 300 s compaction). Les collecteurs bornent requetes, corps, headers, streams et durees. Les headers sont normalises/allowlist/auth expurgee. Les fichiers CLI supplementaires sous profils synthetiques ne sont pas tous dans l'inventaire du collecteur; cet inventaire des captures n'est pas un inventaire exhaustif de tous les effets disque.

Le launcher generique initial pouvait sortir0 apres un namespace nonzero. Le defaut est corrige, avec test de propagation nonzero et conservation des sorties partielles en timeout. Les preuves sont jugees sur namespace-receipt et summary, pas sur le seul code shell. Snapshots de chaque version preservees; aucune trace precedente reecrite.

Compaction observee locale par Responses, pas endpoint remote compact, pas resume persistant. Toutes les reponses/usage sont fabriques. Outils natifs encore annonces; le confinement OS ne prouve pas un inventaire exclusif du broker. Presence exacte au transport et comptabilite des spans ne certifient pas retention/utilisation interne. AC5 et seuils restent inchanges; migration NO-GO.

Pour la comparaison reelle, ces preuves satisfont seulement les controles d'instrumentation sur ce consommateur/version. Le protocole, provider/model/profile, source closure, held-out neuf confidentiel et chronologie baseline/candidat doivent etre prepares distinctement, sans reutiliser silencieusement la campagne historique.
