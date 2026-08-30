---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-26"
created_at: "2026-08-26 21:51:04 UTC"
updated: "2026-08-29"
updated_at: "2026-08-29 02:26:18 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: GPT-5
scope: linux-cli-resource-pressure-rescue
owner: Diane
user_story: "En tant qu'operatrice ShipGlows sur une petite VM Linux, je veux etre avertie avant qu'une saturation RAM/swap ne rende le terminal inutilisable et pouvoir arreter uniquement les outils de developpement orphelins confirmes, afin de recuperer la machine sans expertise systeme ni risque pour mes conversations et services actifs."
confidence: high
risk_level: high
security_impact: medium
docs_impact: yes
linked_systems:
  - cli/config.sh
  - cli/lib.sh
  - tests/cli/memory-monitoring.sh
  - shipglows_data/technical/runtime-cli.md
depends_on:
  - artifact: "shipglows_data/technical/runtime-cli.md"
    artifact_version: "1.23.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Editorial correction 2026-08-29: the shipped rescue is a useful public tutorial opportunity for small-VM operators; the earlier no-impact verdict was technically scoped but editorially too narrow."
  - "Incident observe le 2026-08-26 sur une VM 2 vCPU/4 Go: swap 2 Go utilise a 100%, PSI CPU/memoire proche de 99%, PSI memoire full proche de 66% et terminal presque inutilisable."
  - "Deux commandes Vercel CLI detachees, PPID 1 et sans TTY, consommaient ensemble environ 1,9 Go de RAM et 1,2 Go de swap."
  - "La CLI existante classait seulement MemAvailable, signalait uniquement l'absence de swap et ne reconnaissait que Codex/Ranger/MCP dans ses nettoyages de processus."
next_step: "Draft the linked bilingual Linux VM pressure rescue tutorial without reopening the completed technical delivery."
---

# Spec: Linux CLI resource pressure rescue

🟢 [ShipGlows] spec: Linux CLI resource pressure rescue | status: reviewed | path: shipglows_data/workflow/specs/linux-cli-resource-pressure-rescue.md | next: draft the linked bilingual Linux VM pressure rescue tutorial

## Title

Linux CLI resource pressure rescue

## Status

ready

## User Story

En tant qu'operatrice ShipGlows sur une petite VM Linux, je veux etre avertie avant qu'une saturation RAM/swap ne rende le terminal inutilisable et pouvoir arreter uniquement les outils de developpement orphelins confirmes, afin de recuperer la machine sans expertise systeme ni risque pour mes conversations et services actifs.

## Minimal Behavior Contract

Quand ShipGlows rend son en-tete ou son ecran Health sur Linux, il doit classifier la pression memoire a partir de la RAM disponible, de l'utilisation du swap et, quand le noyau l'expose, du PSI memoire. Une situation de thrashing doit produire une alerte critique persistante qui nomme le chemin court `Health -> Emergency rescue`. Cette action doit lister uniquement les groupes de processus d'outils de developpement detaches reconnus par une signature fermee, masquer leurs arguments sensibles, proteger les conversations et services, puis demander confirmation avant tout `SIGTERM`; un `SIGKILL` reste une seconde confirmation. Si les metriques PSI sont absentes ou si aucun candidat sur n'existe, la CLI doit rester utilisable, expliquer la limite et ne rien arreter.

## Success Behavior

- Trigger: l'en-tete principal ou Health est rendu pendant une pression memoire severe.
- Operator result: une alerte rouge distingue la saturation d'une simple RAM basse et indique immediatement `Health -> Emergency rescue`.
- System result: la classification combine RAM, swap et PSI sans commande lourde ni daemon supplementaire.
- Rescue result: les outils orphelins reconnus sont affiches par groupe avec fournisseur, PID/PGID, RAM et age, sans arguments complets; seul un groupe confirme est arrete.
- Success proof: le scenario synthetique equivalent a l'incident est critique, le processus Vercel orphelin est candidat et les groupes proteges restent exclus.

## Error Behavior

- PSI absent ou illisible: conserver la classification RAM/swap et afficher les metriques disponibles sans echouer.
- Swap absent: conserver l'avertissement existant; ne pas confondre absence de swap et swap sature.
- Swap historiquement utilise mais RAM/PSI sains: ne pas produire une fausse urgence.
- Processus disparu ou identite changee avant l'action: refuser l'arret et rafraichir la liste.
- Groupe contenant un processus protege, un TTY ou une signature inconnue: l'exclure du sauvetage.
- `SIGTERM` insuffisant: demander explicitement avant `SIGKILL`.
- Must never happen: tuer automatiquement un processus, une conversation Codex, SSH, tmux, PM2, Caddy, systemd, un shell interactif ou un service applicatif.

## Problem

`mem_pressure_level` ne regarde que `MemAvailable`. `mem_alerts` sait seulement si le swap est configure, pas s'il est plein. La CLI n'utilise pas `/proc/pressure/memory`, et ses menus de nettoyage n'incluent pas les CLI de developpement detachees comme Vercel. Une VM peut donc thrash pendant que ShipGlows n'affiche qu'un avertissement modere et ne propose aucune cible de recuperation pertinente.

## Solution

- Ajouter des lecteurs bornes pour swap utilise et PSI memoire.
- Introduire une classification de pression systeme qui conserve les seuils RAM existants et les eleve quand swap et PSI prouvent une saturation active.
- Rendre l'alerte critique actionnable dans l'en-tete et Health.
- Ajouter un detecteur ferme de groupes d'outils de developpement orphelins, initialement Vercel CLI, avec garde-fous de groupe et sortie redactee.
- Ajouter un menu `Emergency process rescue` avec revalidation d'identite, `SIGTERM`, attente bornee, puis confirmation distincte avant `SIGKILL`.

## Scope In

- Monitoring RAM, swap et PSI memoire dans la CLI Linux.
- Alertes de l'en-tete et de l'ecran Health.
- Detection et sauvetage confirme des groupes Vercel CLI orphelins du meme utilisateur.
- Tests de regression shell et documentation technique runtime.
- Activation atomique des fichiers `cli/config.sh` et `cli/lib.sh` sur `shipglows-cx23` apres livraison Git.

## Scope Out

- Arret automatique sans confirmation.
- Nettoyage generique de tout processus PPID 1.
- Gestion Windows, dimensionnement Hetzner, redemarrage de VM ou manipulation de swap.
- Modification des services PM2/Caddy, des conversations Codex, SSH ou tmux.
- Ajout d'un daemon de monitoring, d'une dependance ou d'une telemetrie distante.
- Reconciliation generale du checkout runtime distant, qui contient d'autres fichiers modifies.

## Constraints

- Bash et outils `/proc` deja disponibles; aucune dependance nouvelle.
- Les sondes de l'en-tete doivent rester bornees et sans sous-processus couteux repetes.
- Le cache de statut conserve la compatibilite avec les valeurs historiques `0`, `1`, `warning` et `critical`.
- Les arguments complets des processus ne sont jamais affiches ni persistes.
- Les fichiers distants ne sont actives que si leur blob courant correspond encore au commit `b0c2e64`; sinon le deploiement s'arrete sans ecrasement.
- Le fichier local preexistant `shipglows_data/business/project-competitors-and-inspirations.md` reste hors staging et hors commit.

## Test Contract

- Surface: CLI Linux shell, fonctions pures fixturees autant que possible.
- Automated proof: `bash tests/cli/memory-monitoring.sh` et `bash -n cli/config.sh cli/lib.sh tests/cli/memory-monitoring.sh`.
- Runtime proof: apres activation, sourcer la CLI dans un shell non interactif et relever la classification/les candidats sans declencher d'arret.
- Mutation proof: utiliser le dry-run du sauvetage dans les tests; le live ne doit tuer aucun processus de test ou de production.
- Exception: le scenario de thrashing ne sera pas recree volontairement sur la VM; les metriques de l'incident et les fixtures constituent la preuve de regression.

## Dependencies

- `/proc/meminfo` pour RAM et swap.
- `/proc/pressure/memory` quand Linux PSI est disponible.
- `ps`, `awk`, `grep`, `kill` et les primitives UI existantes.
- Les fonctions existantes de formatage de RSS/age et d'arret TERM puis KILL confirme.

## Invariants

- Lecture seule par defaut; aucune action depuis l'en-tete ou Health sans choix explicite.
- Revalidation de PID, PGID, utilisateur, PPID, TTY, signature et protections juste avant `SIGTERM`.
- Candidats limites au meme utilisateur et a une liste de signatures d'outils fermee.
- Une metrique absente produit `unknown`, jamais une fausse preuve de sante ou une erreur bloquante.
- Une saturation historique du swap sans pression actuelle n'est pas une urgence.
- Les sorties restent redactees et n'affichent pas tokens, URLs sensibles ou arguments complets.

## Links & Consequences

- `cli/config.sh`: seuils configurables et bornes sures.
- `cli/lib.sh`: classification, alertes, cache, affichage, detection et action de sauvetage.
- `tests/cli/memory-monitoring.sh`: preuve de regression et protections.
- `shipglows_data/technical/runtime-cli.md`: contrat operateur et limites.
- `CONTEXT-FUNCTION-TREE.md`: aucune mise a jour requise si les nouvelles fonctions restent dans la section Memory/System Monitor existante et ne deplacent pas de flux majeur.
- Runtime distant: seuls les deux fichiers CLI sont actives; aucun autre changement du checkout n'est absorbe ou ecrase.

## Documentation Coherence

- Mettre a jour `shipglows_data/technical/runtime-cli.md` avec les signaux, le chemin de sauvetage, les confirmations et les protections.
- Ajouter l'evidence au frontmatter et incrementer `artifact_version` de facon mineure.
- Documentation publique: non impactee, car il s'agit d'un mecanisme operateur interne du runtime Linux.
- Editorial: non impacte, aucune promesse marketing ou surface publique ne change.

## Edge Cases

- `/proc/pressure/memory` absent, vide, malforme ou acces refuse.
- Swap total nul, swap utilise nul, 79/80/89/90/100%, valeurs non numeriques.
- RAM exactement aux seuils 10% et 20%.
- PSI `some` eleve mais `full` nul; `full` juste sous, au et au-dessus du seuil critique.
- Swap eleve avec RAM saine apres disparition d'un gros processus.
- Processus Vercel actif avec parent vivant, avec TTY, trop recent ou sous le seuil RAM.
- Processus Vercel orphelin disparu, recycle ou ayant change de groupe avant confirmation.
- Groupe contenant Codex, SSH, tmux, PM2, Caddy, systemd ou un shell interactif.
- Plusieurs groupes orphelins; l'operatrice n'en selectionne qu'un.

## ZOMBIES Coverage

- Z: aucun swap, aucun PSI, aucun candidat; diagnostic degrade mais utilisable et aucune action.
- O: un groupe Vercel orphelin valide; affichage redacte et arret confirme de ce groupe seulement.
- M: plusieurs groupes; selection et revalidation independantes sans arret global.
- B: seuils RAM, swap et PSI juste sous/a/au-dessus; age et RSS minimaux des candidats.
- I: `/proc`, `ps`, cache de menu et UI de confirmation gardent des formats fermes et compatibles.
- E: metrique malformee, PID recycle, groupe protege, TERM refuse et KILL annule.
- S: lecteurs shell et un menu de sauvetage dans le flux Health existant, sans daemon ni dependance.

## Implementation Tasks

- [x] Task 1: Etendre la classification de pression
  - Files: `cli/config.sh`, `cli/lib.sh`
  - Action: lire swap/PSI, valider les seuils et calculer `ok|warning|critical|unknown` en conservant la compatibilite RAM.
  - User-story link: l'alerte doit representer le thrashing reel.
  - Dependency: aucune.
  - Validate with: fixtures RAM/swap/PSI dans `tests/cli/memory-monitoring.sh`.
  - Constraints: sondes bornees, aucun daemon, PSI optionnel.

- [x] Task 2: Rendre l'alerte actionnable
  - Files: `cli/lib.sh`
  - Action: persister la severite combinee dans le cache et afficher le chemin `Health -> Emergency rescue` dans l'en-tete et Health.
  - User-story link: l'operatrice doit savoir quoi faire avant que le terminal soit inutilisable.
  - Dependency: Task 1.
  - Validate with: assertions de texte warning/critical et compatibilite cache historique.
  - Constraints: aucune action automatique.

- [x] Task 3: Ajouter le sauvetage des outils orphelins
  - Files: `cli/lib.sh`
  - Action: detecter, afficher, revalider et arreter sur confirmation les groupes Vercel CLI orphelins; proteger les processus et groupes sensibles.
  - User-story link: recuperer la VM sans expertise systeme.
  - Dependency: fonctions de groupes de processus existantes.
  - Validate with: fixture `ps`, dry-run, candidats valides et exclusions protegees.
  - Constraints: meme utilisateur, PPID 1, sans TTY, age/RSS minimaux, signature fermee, sortie redactee.

- [x] Task 4: Documenter et verifier
  - Files: `tests/cli/memory-monitoring.sh`, `shipglows_data/technical/runtime-cli.md`
  - Action: couvrir le scenario incident, les faux positifs, les protections, la syntaxe et le contrat runtime.
  - User-story link: prevenir la recurrence et rendre la fonction maintenable.
  - Dependency: Tasks 1-3.
  - Validate with: test cible, `bash -n`, metadata lint cible et revue du diff.
  - Constraints: aucun audit global ni suite sans lien avec la surface.

- [x] Task 5: Livrer et activer sur la premiere VM
  - Files: commit exact du chantier; runtime distant `cli/config.sh` et `cli/lib.sh`.
  - Action: scanner, committer et pousser le scope exact; revalider les blobs distants, sauvegarder les deux fichiers puis les remplacer atomiquement depuis le commit valide.
  - User-story link: rendre la recuperation disponible sur la VM concernee.
  - Dependency: Tasks 1-4 et verification standard.
  - Validate with: push confirme, hash des fichiers actives, syntaxe distante et diagnostic non interactif.
  - Constraints: aucun autre fichier distant modifie; arret si divergence.

## Acceptance Criteria

- [x] AC 1: Given 15% de RAM disponible, 100% du swap utilise et PSI memoire full eleve, when la pression est classee, then le resultat est `critical` et l'en-tete indique `Health -> Emergency rescue`.
- [x] AC 2: Given 60% de RAM disponible, du swap historiquement utilise et PSI nul, when la pression est classee, then aucune urgence critique n'est affichee.
- [x] AC 3: Given PSI absent, when la CLI calcule la pression, then elle utilise RAM/swap sans erreur et expose la limite dans Health.
- [x] AC 4: Given un Vercel CLI PPID 1, sans TTY, assez ancien et lourd, when les candidats sont listes, then son groupe apparait avec une etiquette redactee.
- [x] AC 5: Given Codex, SSH, tmux, PM2, Caddy, systemd, un shell interactif ou un groupe mixte, when le sauvetage analyse les groupes, then ils sont exclus.
- [x] AC 6: Given un candidat confirme, when l'identite a change avant TERM, then aucun signal n'est envoye.
- [x] AC 7: Given TERM ne suffit pas, when le groupe reste actif, then KILL exige une seconde confirmation.
- [x] AC 8: Given le chantier valide, when il est livre, then seuls ses fichiers sont stages/committes/pousses et le fichier metier preexistant reste intact.
- [x] AC 9: Given les blobs runtime distants correspondent au baseline attendu, when l'activation a lieu, then les originaux sont sauvegardes et les deux nouveaux fichiers passent la syntaxe distante; sinon aucune activation n'a lieu.

## Test Strategy

- Regression-first: reproduire d'abord l'incident par fixtures RAM/swap/PSI et processus.
- Syntax: `bash -n cli/config.sh cli/lib.sh tests/cli/memory-monitoring.sh`.
- Focused behavior: `bash tests/cli/memory-monitoring.sh`.
- Metadata: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/linux-cli-resource-pressure-rescue.md shipglows_data/technical/runtime-cli.md`.
- Diff review: verifier les chemins stages, les sorties redactees et l'absence du fichier metier preexistant.
- Runtime: diagnostic non interactif apres activation; aucun test destructif live.

## Risks

- Faux positif de processus orphelin: reduit par signature fermee, meme utilisateur, PPID 1, absence de TTY, seuils age/RSS, protections de groupe, revalidation et confirmation.
- Faux positif de pression: swap seul ne suffit pas a une urgence; le niveau critique exige pression active ou combinaison swap presque plein + RAM basse.
- Cout de l'en-tete: lectures `/proc` simples et cache existant; aucune boucle d'echantillonnage.
- Fuite d'arguments: les arguments servent uniquement a classifier une signature et ne sont jamais affiches/persistes.
- Divergence runtime: les blobs distants sont verifies avant remplacement et les originaux sauvegardes.
- Residual risk: une CLI inconnue restera non eligible jusqu'a ajout explicite et teste de sa signature.

## OWASP Security Gate

- Applicability: pas de surface HTTP, auth ou tenant; OWASP Top 10 non applicable.
- Privileged/destructive boundary: applicable au signal de processus.
- Required proof: aucun signal sans confirmation; groupe strictement borne; identite revalidee; arguments redactes; services/conversations proteges; KILL confirme separement.
- Verdict before implementation: decision-complete, verification requise.

## Execution Notes

- First-read files: `cli/config.sh`, the Memory/System Monitor sections of `cli/lib.sh`, `tests/cli/memory-monitoring.sh`, `shipglows_data/technical/runtime-cli.md`, and this spec.
- Topology: main-only, car le chantier forme une seule chaine coherente et le runtime interdit la delegation proactive non demandee.
- Proof path: regression-first puis preuve runtime non destructive.
- Pressure scenario: VM 2 vCPU/4 Go, swap 2 Go sature, PSI memoire some/full extreme et deux Vercel CLI orphelins.
- Followability Gate: les fonctions restent dans la section Memory/System Monitor de `cli/lib.sh`; le chemin operateur est visible depuis l'alerte et Health.
- Structure Replacement Fit: la severite combinee remplace le jugement RAM-only; le sauvetage remplace l'absence de cible, sans ajouter un second systeme de monitoring.
- Fast Fix Shortcut Gate: le correctif traite la cause de detection et de recuperation, pas seulement le texte de l'alerte.

## Open Questions

None. Les seuils et protections sont internes, configurables et couverts par tests; aucun choix produit, cout, permission ou donnees supplementaire n'est requis.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-26 21:51:04 UTC | 100-sg-spec | GPT-5 | Formalized and adversarially reviewed Linux resource-pressure detection and confirmed orphaned-tool rescue from the observed VM incident. | reviewed | /101-sg-ready Linux CLI resource pressure rescue |
| 2026-08-26 21:53:10 UTC | 101-sg-ready | GPT-5 | Confirmed autonomous behavior, bounded process-signal protections, exact proof, deployment rollback, and documentation consequences. | ready | /102-sg-start Linux CLI resource pressure rescue |
| 2026-08-26 22:01:35 UTC | 102-sg-start | GPT-5 | Implemented combined RAM/swap/PSI severity, actionable Health rescue, closed Vercel orphan detection, redacted display, revalidation, confirmations, regression tests, and runtime documentation. | implemented | /103-sg-verify Linux CLI resource pressure rescue |
| 2026-08-26 22:05:27 UTC | 103-sg-verify | GPT-5 | Verified 21 focused pressure and rescue cases, Bash syntax, targeted metadata, diff integrity, official Linux PSI semantics, and fail-closed process protections. | verified locally | /005-sg-ship Linux CLI resource pressure rescue |
| 2026-08-26 22:14:51 UTC | 005-sg-ship | GPT-5 | Pushed the bounded implementation commit, revalidated the remote baseline, created a private backup, activated only the two approved runtime scripts, and matched their committed hashes and Linux syntax. | shipped and activated | /104-sg-end Linux CLI resource pressure rescue |
| 2026-08-26 22:14:51 UTC | 104-sg-end | GPT-5 | Closed the unique chantier after a live non-destructive diagnostic reported pressure ok, swap 39%, memory PSI 0.00/0.00, zero eligible orphan groups, and expected runtime ownership; technical documentation is updated and public editorial surfaces are not impacted. | closed | Observe the next organic memory-pressure event through the CLI Health rescue path. |
| 2026-08-29 02:26:18 UTC | 007-sg-content | GPT-5 | Corrected the editorial reflection: the completed technical capability remains closed, while its verified incident and rescue path now source a separate bilingual public tutorial draft. | editorial follow-up linked | /102-sg-start Linux VM pressure rescue public tutorial |

## Current Chantier Flow

- `100-sg-spec`: reviewed contract created from confirmed incident evidence.
- `101-sg-ready`: ready; behavior, safety, proof, and deployment boundaries are decision-complete.
- `102-sg-start`: implemented; focused regression and Bash syntax pass locally.
- `103-sg-verify`: verified locally and on the active Linux runtime.
- `104-sg-end`: closed; durable documentation and proof are aligned.
- `005-sg-ship`: shipped and activated from commit `c101bd7` with a private rollback backup.
- Editorial follow-up: linked to the separate ready bilingual tutorial spec; the technical chantier remains closed.

Next step: draft the linked bilingual Linux VM pressure rescue tutorial; do not manufacture pressure on the live VM or reopen the completed technical delivery.
