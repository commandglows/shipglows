---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: reviewed
source_skill: sg-engineering
scope: conditional-skill-routing-codex-linux-cli-mock-capture-integration
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - tools/conditional_skill_routing_cli_capture.py
  - tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-cli-v1-20261007-attempt2/run/summary.json
  - shipglows_data/workflow/reviews/conditional-skill-routing-capture-demonstration.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-capture-feasibility.md
  - shipglows_data/workflow/reviews/conditional-skill-routing-handoff.md
  - shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved integration into a real CLI with a simulated provider."
  - "Operator explicitly approved temporary official Codex Linux 0.160.1 download only; no global installation or real key."
  - "Existing WSL bwrap isolation verified before CLI launch: only loopback and ENETUNREACH=101 for nonloopback destination."
  - "Codex 0.160.1: two fresh exec sessions, three captured HTTP requests, 59 hashed artifacts, nine checks pass, two independent final reviews."
next_step: "Verify same-thread tool callbacks/results and controlled effects under the same mock boundary before proposing any separately authorized real provider validation or new campaign."
---

# Integration de capture : vraie CLI Codex, fournisseur simule

## Verdict

**Integration validee pour Codex Linux 0.160.1 et le mock Responses local sous WSL/bwrap.** La capture ne repose plus uniquement sur un client HTTP invente: le binaire officiel a execute deux vrais exec --json --ephemeral et traite les reponses du simulateur. Aucun modele reel n'a produit ces reponses.

Ce resultat porte sur deux sessions fraiches, pas une conversation continue. Il ne valide pas les outils natifs, la retention interne du modele, les obligations du corpus pilote ou l'app Codex et ses sous-agents natifs. AC5 et les seuils restent inchanges. Migration NO-GO; signal historique encourageant conserve.

## Autorisation et choix de runtime

L'operatrice a valide l'integration mock, puis explicitement le **binaire temporaire uniquement**. Les CLI deja installees sont Windows. Les shims visibles sous WSL renvoient vers ces executables Windows; ce n'est pas un confinement Linux. Le sandbox Windows Codex ne fournissait pas une invocation certifiee sans effets ACL/firewall; ses helpers incluent ces chemins, sans preuve qu'ils seraient executes dans chaque cas. Aucune invocation sandbox Windows effectuee, aucune regle pare-feu ni ACL hote modifiee.

Le package local npm de Codex 0.160.1 declare l'alias Linux officiel @openai/codex@0.160.1-linux-x64. Telechargement direct de ce paquet public, sans recherche web, secret, compte ou installation globale. Premiere reception arretee au plafond initial de 100 MiB, trop bas pour ce paquet. Deuxieme reception en streaming bornee a 512 MiB, integrite SHA512 verifiee, seul membre ELF extrait; aucun script npm execute. Provenance complete dans download-receipt.json.

- Archive: 163294814 octets; SHA256 dc9ebd133d3af19ccac4bd5515a5049005b8b05ef3bd558d257d44f32a94f758.
- ELF: 289166920 octets; SHA256 f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35.
- Package: @openai/codex, version 0.160.1-linux-x64; executable annonce codex-cli 0.160.1.
- Source execute et snapshot exact: 227e1e336d0a3a7dacd686aa3ddb5cce7db0ad7b7ca853289b01f722089288e2.

## Confinement effectif

launch.json conserve l'argv complet bwrap: --unshare-all, --die-with-parent, --new-session, --clearenv; /usr, /bin, /lib, /lib64 en lecture seule; proc/dev neufs; tmpfs /tmp; seul repertoire de preuve writable /work; source et ELF montes en lecture seule. Pas de montage /run, socket hote, profil utilisateur ou WSL interop. Pas de montage du checkout complet. Le fait que le fichier ELF provienne d'un fichier Windows ro-bind n'en fait pas un processus Windows: format ELF verifie, execute par Linux dans ce namespace.

Avant le CLI, le preflight exige /proc/net/dev avec seul lo et un connect vers 203.0.113.1 donnant **ENETUNREACH=101**. Le mock et le CLI partagent la meme boucle locale isolee. Le premier probe local distinct a egalement verifie un aller-retour loopback exact. Aucun reseau externe routable pour ces processus; cette preuve ne porte pas sur le trafic global de l'hote ou des outils d'infrastructure.

Home, CODEX_HOME, projet et configuration neufs sous /work. Environnement CLI explicite: chemins synthetiques, PATH systeme borne, NO_COLOR et LANG; aucune variable de credential/proxy heritee. Config provider mock, base_url loopback, wire_api Responses, requires_openai_auth=false, analytics=false. Les flags applicatifs ne remplacent pas le namespace.

## Preuve durable finale

Dossier:
tools/fixtures/conditional_skill_routing/capture-demonstrations/codex-linux-cli-v1-20261007-attempt2/

Summary SHA256:
f1f6a398d043cb3dbce0ad38cfc5f422fd44b2848545d01f1e3a5504873f9c3a

| Controle | Resultat |
| --- | --- |
| Version reelle | 0.160.1, stdout/stderr captures |
| Sessions | Deux exec independants; deux thread IDs distincts; exit 0 |
| Requetes | Trois POST /v1/responses, 39305 octets chacun |
| Statuts | Session 1: 200; session 2: 503 puis 200 |
| Retry | Les deux corps de session 2 sont identiques byte pour byte |
| Prompt | Meme marqueur synthetique present dans chaque requete au role user, retry compris |
| Reponse finale | Exactement un item.completed/agent_message, texte synthetic completed, par session; turn.completed ensuite |
| Usage | 10 input / 2 output par session, fourni artificiellement par le mock |
| Integrite | 59 artefacts inventories, hashes et tailles reverifies sans ecart; neuf controles vrais |
| Durees | 19.387196501 s wrapper, environ 15.716 s demonstration; exclusivement local, jamais latence modele |

Audit supplementaire: independent-capture-audit.json inventorie les 133 fichiers presents avant l'audit, dont 68 fichiers supplementaires produits par le CLI dans son profil synthetique. Ces fichiers ne font pas partie des 59 captures du collecteur; leurs tailles/hashes sont conserves separement. Le summary lui-meme est hash-verifie par les reviewers.

Nettoyage: archive, ELF et receipt du dossier temporaire Windows supprimes apres copie de la provenance durable; dossier supprime. Le chemin temporaire Linux de la copie initiale est verifie absent. Receipts de nettoyage conserves. Aucune installation globale. Pour reexecuter, il faudra remettre le meme ELF temporaire verifie dans le launcher, pas utiliser un chemin nettoye.

Corps HTTP recus cote serveur et chunks conserves avant parsing JSON. SSE et reponses preparees avant emission, avec metadonnees de statut, destination, headers normalises/allowlist et auth expurgee. Stdout/stderr CLI sauvegardes en chunks avant parsing JSONL avec horloge monotone de reception. Les evenements assistant finaux sont verifies comme JSON, pas par simple sous-chaine dans les logs.

Cette capture observe les requetes au serveur mock, les reponses preparees/envoyees et leur interpretation visible par le CLI. Elle ne fournit pas un sniffer TCP/TLS exhaustif ou les entrees internes d'un fournisseur reel. Noms iteration-one/two dans les fichiers sont des labels historiques du script: il s'agit de deux sessions neuves.

Bornes du script: 1 MiB corps requete, 4 MiB budget declare, huit requetes, 8192 octets headers, 2 MiB par stream stdout/stderr, 40 s par processus, 150 s wrapper. Admission avant lecture du corps, timeout et groupe de processus termines en cas d'echec. Les cas de depassement du CLI ne sont pas tous exerces ici; la demonstration HTTP precedente couvre ses propres bornes distinctes.

## Avertissements conserves

Le CLI annonce que disable_response_storage est ignore. Ne pas attribuer un effet a ce reglage. Les trois requetes capturees portent effectivement store:false, independamment de cet avertissement.

Le modele synthetic n'a pas de metadonnees officielles: fallback conserve dans les sorties. La creation d'aliases PATH helper est refusee sous le home temporaire actuel. Ces avertissements ne bloquent pas les deux reponses mock, mais interdisent de presenter ce profil comme valide pour des outils natifs reels.

L'inventaire des trois requetes expose **neuf outils**, dont terminal, web, agents et goals. Aucun callback n'est execute; aucune exclusivite ou desactivation des outils n'est prouvee. Confinement du processus, inventaire d'outils et comportement de modele sont trois preuves differentes.

## Incidents conserves

- Docker deja installe a ete examine comme alternative sans image telechargee. Le demarrage detache a ete demande, mais aucun moteur accessible ni image disponible n'a ete confirme. Status/stop CLI ont timeout. Les processus Docker precis crees par cette tentative ont ete arretes; aucun processus preexistant arrete. Cette piste n'est pas utilisee dans la preuve finale.
- Un lancement WSL de copie du binaire a termine avec Wsl/Service/CreateInstance/CreateVm/0x800705b4. Apres nettoyage des processus Docker de la tentative, wsl true a reussi. Association chronologique, pas diagnostic causal definitif.
- attempt1 conserve launch, stdout/stderr, receipt et provenance: bwrap ne trouvait plus le chemin ELF temporaire Linux entre deux invocations. Echec avant programme Python/CLI. La cause de disparition du chemin n'est pas etablie.
- attempt2 monte directement en lecture seule l'ELF verifie conserve temporairement cote Windows. Reussite ci-dessus, sans effacer attempt1.
- Aucun sujet original, grade, candidat, module gele ou attente held-out modifie/ouvert. Les 105 references du scellement original sont reverifiees separement.

Les reponses fournisseur sont entierement simulees. Les telechargements publics du paquet ont ete autorises; aucun appel fournisseur de modele reel pilote. Les reviewers Codex restent des sessions de revue distinctes, pas des observations du pilote.

## Decision et suite

La voie CLI Linux sous namespace peut capturer concretement les entrees Responses de ce consommateur. C'est une preuve utile nouvelle, qui justifie de poursuivre l'instrumentation mock plutot qu'une campagne opaque.

Avant une nouvelle campagne: exercer une conversation continue avec callbacks d'outils et retours exacts, inventorier effets/outils, conserver refus et erreurs, traiter lectures/injections/compaction sur toutes requetes, resoudre la frontiere AC5 delivered/retained sans la modifier implicitement. Le passage du consumer natif partage au CLI Linux change le consommateur: une future comparaison necessiterait nouvelle baseline, protocole revue et nouveau held-out distinct.

Aucun appel fournisseur reel, nouvelle campagne, installation globale, modification canonique, commit/push, publication ou deploiement autorise par ce resultat. Signal 44/48 vs 40/48, held-out 20/24 vs 18/24 preserve; migration NO-GO.
