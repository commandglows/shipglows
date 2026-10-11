---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-synthetic-http-capture-demonstration
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_capture_demo.py
  - tools/fixtures/conditional_skill_routing/capture-demonstrations/local-http-v1-20261007/summary.json
  - tools/fixtures/conditional_skill_routing/capture-demonstrations/development-failures-20261007/failure-provenance.json
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-capture-feasibility.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md
depends_on: []
supersedes: []
evidence:
  - "Operator replied ok to the proposed local simulated-provider demonstration; existing native subagent authority continued."
  - "Named stdlib Python loopback client/server: 41 exchanges, 41 receipts, 210 checks true and 480 inventoried blobs with exact hashes."
  - "Two independent reviewers inspected the final source and durable artifacts; no model/provider/CLI integration claimed."
next_step: "Choose a named CLI and plan a bounded mock integration with verified egress/dependency confinement before any separately authorized real call."
---

# Demonstration locale de capture HTTP synthetique

Suite executee et revue: `shipglows_data/workflow/reviews/conditional-skill-routing-cli-capture-integration.md`. Codex Linux0.160.1 sous WSL/bwrap a reussi deux sessions mock avec trois requetes capturees. Les anciennes propositions d'integration ci-dessous sont historiques; callbacks/continuation et AC5 restent non valides.

## Resultat

**La capture des corps et des erreurs est demontree pour les scenarios scripts de ce client/serveur Python local.** La preuve passe; elle ne couvre ni l'app Codex, ni ses sous-agents sujets, ni un client Codex/OpenCode reel, ni la retention interne du modele. AC5 et tous les seuils du pilote restent inchanges. Migration NO-GO.

Execution directe, Doppler NONE:

```powershell
python -B tools/conditional_skill_routing_capture_demo.py --out tools/fixtures/conditional_skill_routing/capture-demonstrations/local-http-v1-20261007
```

Le dossier cible etait inexistant; tout dossier existant est refuse. Aucune dependance ajoutee. Serveur sur 127.0.0.1, port alloue localement, sockets client vers ce seul endpoint, threads fermes a la fin. Aucun lancement de Codex/OpenCode/Pi, appel fournisseur externe pilote, profil utilisateur, credential ou attente held-out consulte. Les sous-agents sont des reviewers de cette preuve synthetique, pas de nouveaux sujets du pilote.

## Preuves durables

- Run final: 41 appels et 41 recus serveur, 210 controles vrais, 480 blobs inventories; duree locale 2.2535211 s, pas une latence modele.
- Source et snapshot execute identiques: SHA256 `31bc98fac4ace81f6a62cce2caba1f865bf92db35e34d2ce06399dc1db428976`.
- Summary SHA256 `44a204532065663bfb19d8101f89f4a055b69b4dd8e358be90a8cf9c11f53bb1`.
- Corps client avant envoi, corps serveur avant parsing JSON, chunks de reponse client avant parsing SSE/JSON, resultats attendus, flux SSE, recus et snapshot conserves. Hashes et tailles reverifies sans divergence.
- Metadonnees: methode, chemin, destination loopback, statut, headers autorises normalises, identifiants, parents et horloges monotoniques de capture/reception. Authorization expurge dans les metadonnees. Source-snapshot contient volontairement la constante d'auth fictive du programme; aucune cle reelle n'est utilisee.
- Une reponse HTTP est comptee comme transport complet seulement si les octets declares sont recus; timeout/coupure/overflow restent des erreurs attendues, jamais des succes de livraison complete.
- Les fichiers serveur response-sent sont prepares avant emission; les comparaisons cote client prouvent les octets effectivement recus dans les scenarios observes, pas une trace noyau de send/TCP.

| Scenario | Observation conservee |
| --- | --- |
| Deux iterations | Instruction synthetique repetee dans les requetes |
| Refus puis correction d'outil | Deux retours distincts, refus non efface |
| Lecture partielle puis complete | Spans 0:5 et 0:12 d'une source synthetique commune, hashes verifies; aucune obligation du corpus pilote deduite |
| Grant et refresh | Read refuse avant statut puis avant capability; accepte apres les deux |
| Invalidation/nouveau grant | Epoch changee, anciens refresh inutilisables; meme sequence de refus/refresh |
| Compaction | Evenement synthetique declare et repris; pas une vraie compaction de modele |
| Brouillon, check, sortie | Draft transmis au check dans requete interne; digest retourne; draft sensible et substitution refuses; seul texte verifie accepte comme visible_response simulee |
| HTTP 503 puis retry | Deux tentatives distinctes, meme action synthetique |
| Coupure et timeout | Prefixes recus conserves; incomplete_response et TimeoutError explicites |
| JSON invalide | HTTP 400 sans action executee; octets bruts conserves |
| SSE erreur | Event error conserve, absence de done verifiee |
| Reponse trop grande | Arret au plafond + un octet temoin, 32769 octets recus conserves |
| Requete trop grande | HTTP 413, temoin borne; pas de parsing de l'action |
| Quota de requetes | 41e requete refusee HTTP 429, aucun corps lu serveur; corps client distinct conserve |

La revue prive/chronologie a reverifie 33 liens parent/call ID/payload exact vers la requete suivante. Echanges 007-012: grant, refus avant statut, refus avant capability, puis read autorise. Invalidation 014 et nouveau grant 018 reprennent ce gate jusqu'a 023. Draft sensible 025/026 refuse, check 027 lie au digest, substitution 028 refusee, texte exact 029 accepte.

## Bornes et limites

Bornes configurees: 32768 octets de corps + un octet temoin, 8192 octets de headers, 40 requetes admises, 1 MiB de budget declare de requetes, timeout socket 0.3 s et deadline de corps par echange 1 s. Quota et budget declare sont reserves avant lecture du corps; le depassement de quota n'absorbe aucun corps. Ce sont des limites du parcours script, pas un confinement physique contre un client hostile.

Non demontres: quota agrege effectivement atteint, headers lents/malformes, JSON/SSE general arbitraire, doublons/parents invalides en essais negatifs, clients concurrents hostiles et borne globale de session contre slow headers. Les headers sont filtres/normalises, pas des bytes TCP exacts. TLS, auth fournisseur, retries automatiques d'une CLI, sorties hors broker et environnement reseau OS ne sont pas valides.

Tous les usages sont fictifs et etiquetes synthetic; aucun cout monetaire ou consommation modele n'est mesure. Le marker prive est un texte invente conserve intentionnellement dans les traces; ce dossier ne doit pas etre reutilise avec de vrais secrets. Les blobs restent locaux, sans publication; pas de politique de retention de donnees privees reelles autorisee.

## Revue et echecs de developpement

Un sous-agent a cree le fichier neuf, deux autres ont relu independamment. Les premieres relectures ont trouve admission apres lecture, contexte de statut non contraignant, check seulement booleen et provenance source absente. Corrections appliquees avant le run final, sans toucher les modules geles.

Deux tentatives intermediaires echouees sont conservees durablement dans `capture-demonstrations/development-failures-20261007/`:

- b: 383 fichiers; erreur JSONDecodeError pendant validation d'un callback devant une requete refusee vide.
- c: 380 fichiers; FileNotFoundError de response-sent apres mismatch de parent a la suite d'un refus oversize.

Ces erreurs sont les descriptions rapportees par l'auteur; les captures precedant l'echec sont copiees avec inventaire hash. Aucun summary de succes ni snapshot historique du source ne les accompagne: revision source UNKNOWN, pas celle du run final. Les echecs ne sont pas effaces ou requalifies.

## Decision et suite

Cette demonstration ferme la faisabilite du mecanisme de capture pour ce transport HTTP synthetique nomme. Elle ne ferme pas le besoin d'integration avec un consommateur reel. **Pas de nouvelle campagne maintenant.**

Suite proposee: une integration mock sur une CLI/version choisie, dans un profil neuf, seulement apres verification des dependances disponibles et confinement d'egress. Conserver toutes iterations/injections et sorties/erreurs, inventorier outils et effets, enregistrer usages disponibles, verifier les correspondances avant actions dependantes. Une eventualite d'appel fournisseur reel exige ensuite budget et autorisation distincts.

AC5 delivered/retained reste non satisfait: meme une requete fournisseur authentifiee ne prouverait pas la retention/utilisation interne. Toute clarification de ce critere est une decision explicite distincte. Signal du pilote conserve: 44/48 contre 40/48, dont 20/24 contre 18/24; aucune promotion.
