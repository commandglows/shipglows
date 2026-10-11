---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-cli-mock-tool-continuity
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_cli_continuity.py
  - tools/conditional_skill_routing_cli_continuity_launch.py
  - shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
depends_on: []
supersedes: []
evidence:
  - "Operator authorized continuous fictional-tool proof, mock provider, existing WSL/bwrap confinement, subagents and temporary official binary."
  - "Single Codex Linux 0.160.1 exec thread/turn, five captured Responses requests; twelve checks pass."
next_step: "Keep mock proof bounded; complete prospective instruction/read/injection capture and compaction analysis before proposing any separately authorized campaign."
---

# Continuite CLI : outils fictifs et resultats exacts

La preuve demandee passe : **un seul processus `codex exec`, un thread et un tour**, avec trois appels `exec_command` prepares par le fournisseur Responses simule. Deux scripts Python fictifs sont effectivement executes. Le troisieme appel demande une escalade et est refuse par `approval_policy=never` avant execution. Aucun modele reel ne produit les appels ou la reponse finale.

## Preuve

Dossier durable : `tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-continuity-v1-20261007-attempt1/`.

Summary : `workspace/run/summary.json`, SHA256 `c8873d07ccf1a1669269690b2a03c662ddc8d2235289b38bec6d689a42810093`.

Source execute : SHA256 `db00577d8a7e38cce5f971a35a138fbfd22633e13e65df6bbbd321a7921d8d18`. Snapshot monte en lecture seule, identique au snapshot capture dans le run. Meme ELF officiel 0.160.1 et memes hashes archive/ELF que la preuve precedente; integrite SHA512 reverifiee avant extraction du seul membre ELF. Archive et ELF temporaires supprimes apres execution, sans installation globale.

| Requete | Resultats presents | Reponse mock |
| --- | --- | --- |
| http-001 | Aucun | Appel success, 200 |
| http-002 | Success exact | 503 controle |
| http-003 | Success exact, corps identique au retry | Appel error, 200 |
| http-004 | Success et error exacts | Appel refusal, 200 |
| http-005 | Success, error et refus exacts | Message final, 200 |

Les `call_id`, noms et arguments historiques sont verifies dans chaque requete suivante. La sortie success comporte Unicode, guillemet, backslash et retours a la ligne; elle correspond exactement a `aggregated_output` du CLI et au suffixe Output du callback. Le script error produit la sortie exacte attendue et exit 23, avec evenement CLI `status=failed`. Le callback de refus contient le rejet explicite de la politique Never; aucun evenement d'execution ni marqueur stdout du script refuse. Chaque resultat complet, y compris le wrapper CLI avec duree/chunk ID, reste identique dans les requetes suivantes. Ce wrapper est observe, pas predit.

Les cinq corps HTTP et chunks sont conserves avant parsing. Les SSE prepares/envoyes, stdout/stderr chunks, evenements JSONL, appels/arguments/resultats et receipts monotones sont conserves. Douze controles vrais; 75 artefacts inventories et rehashes. Duree du run 9.547703557 s, purement locale. Usage 40 input/8 output cumule fourni artificiellement par le mock; aucune inference sur cout ou latence modele.

## Confinement et effets

WSL Ubuntu et bwrap `--unshare-all --die-with-parent --new-session --clearenv`, montages systeme read-only, proc/dev neufs, tmpfs /tmp; seule sous-arborescence `workspace/` de cette preuve writable. Aucun montage checkout, profil utilisateur, /run, socket hote ou interop WSL. Les receipts du launcher et download restent hors du montage writable. Un timeout Linux de 140 s avec kill-after 5 s borne le namespace, wrapper Windows 150 s. Processus CLI borne a 75 s, corps 1 MiB, total declare 8 MiB, huit requetes, headers 8192 octets, stdout/stderr 2 MiB chacun.

Preflight : interface `lo` uniquement et destination nonloopback refusant avec ENETUNREACH=101. Configuration et environnement synthetiques sans credential/proxy; fournisseur loopback `requires_openai_auth=false`. Les scripts crees/executables, profils et fichiers CLI restent dans le montage writable. Les outils sont natifs `exec_command` transportant des diagnostics fictifs, pas un inventaire exclusif d'outils dynamiques. Le CLI utilise `danger-full-access` **a l'interieur du confinement OS**; ne pas attribuer la protection au sandbox applicatif.

Les avertissements aliases PATH sous home temporaire et metadata synthetic fallback sont conserves. L'erreur de refus du router est capturee en stderr. Le refus exerce est celui de l'escalade CLI, pas un refus de modele, une politique metier ou un refus serveur du corpus.

## Limites et suite

La continuite est prouvee sur les callbacks successifs d'un seul tour; aucun second message utilisateur, resume ou compaction exerce. La presence exacte dans les entrees du mock ne prouve pas retention/utilisation interne du modele, exhaustivite TCP/TLS, fermeture des obligations du pilote ou AC5. Les headers sont normalises/allowlist et auth expurgee. Les tests de limites et chemins d'exception ne sont pas tous exerces; une exception precoce du collecteur peut conserver des blobs sans summary final.

Incident de preparation : un ajout tardif de checks automatises des appels historiques a suivi la prise du snapshot execute. La revue independante a verifie ces appels sur les captures brutes. Le source courant est restaure aux octets effectivement executes; cet ajout non execute est conserve separement dans `late-unexecuted-checker-addition.patch`, sans lui attribuer de preuve runtime.

Aucun sujet original, grade, candidat, source gelee ou seuil modifie. Revue independante des captures et reverification des 105 references du receipt final original consignees dans `independent-review.json` : aucun ecart de taille/hash ou reference manquante. AC5 et seuils inchanges, migration **NO-GO**. Aucune campagne, fournisseur reel, publication, installation globale ou Git en ecriture.

La preuve suivante concerne lectures/instructions/injections et compaction sur toutes les requetes; elle reste a cadrer sous fournisseur simule. Toute campagne sur ce consommateur necessite une nouvelle baseline, un protocole revu et un nouveau held-out independant, ainsi qu'une autorisation distincte.
