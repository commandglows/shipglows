---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlowz
created: "2026-07-17"
created_at: "2026-07-17 13:25:56 UTC"
updated: "2026-08-01"
updated_at: "2026-08-01 15:30:00 UTC"
status: active
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: cross-repository installer bug
owner: Diane
confidence: high
user_story: "En tant qu'operatrice autorisee, je veux lancer une commande ShipGlowz unique qui choisit correctement l'installation locale ou complete, afin d'installer Termux sans sudo et un serveur sans ambiguite."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - install-shipglowz.sh
  - local/install.sh
  - cli/install.sh
  - tests/install/
  - tools/sync_shipglowz_public_bootstrap.sh
  - /home/claude/winglowz/winglowz_site/src/pages/shipglowz-script.ts
  - /home/claude/winglowz/winglowz_site/src/generated/shipglowz-installer.sh
  - /home/claude/winglowz/winglowz_site/src/data/scriptInstallPages.ts
  - /home/claude/winglowz/winglowz_site/tests/
  - BUG-2026-07-17-001
  - BUG-2026-07-13-002
depends_on:
  - artifact: shipglowz_data/technical/installer-and-user-scope.md
    artifact_version: "1.0.6"
    required_status: reviewed
  - artifact: shipglowz_data/technical/context.md
    artifact_version: "0.6.1"
    required_status: draft
  - artifact: /home/claude/winglowz/CLAUDE.md
    artifact_version: unknown
    required_status: active
supersedes: []
evidence:
  - "BUG-2026-07-17-001 records a real Android Termux failure: sudo is unavailable and the non-root bootstrap never reaches local/install.sh."
  - "The deployed www.winflowz.com bootstrap differs from the ShipGlowz bootstrap and duplicates its implementation in the WinGlowz site."
  - "The public endpoint remains the distribution authority; native Windows uses the public GitHub archive because the Windows bootstrap must not require Git."
  - "BUG-2026-07-13-002 already proves that local/install.sh has a Termux-aware path once the bootstrap reaches it."
next_step: "/405-sg-prod then /107-sg-test --retest BUG-2026-07-17-001"
---

## Title

Unified ShipGlowz Bootstrap Modes for Local and Full Installation

## Status

Ready. This specification owns `BUG-2026-07-17-001` and the public-distribution adapter needed to fix it.

## User Story

En tant qu'operatrice autorisee a acceder au depot ShipGlowz, je veux lancer une commande courte unique depuis Termux, un poste local ou un serveur, afin que ShipGlowz choisisse ou demande le bon mode, preserve mon compte utilisateur et m'explique clairement les erreurs d'elevation ou d'authentification.

## Minimal Behavior Contract

La commande publique sans `sudo` detecte d'abord le contexte d'execution, choisit automatiquement le mode local sur Termux et le mode complet lorsqu'elle est deja executee en root, demande `local` ou `full` via le terminal uniquement lorsque le contexte reste ambigu, puis telecharge ou met a jour le depot dans le bon home et lance l'installateur correspondant. Une demande complete sans privileges, un contexte non interactif ambigu ou un depot inaccessible echoue avant toute installation avec une commande corrective explicite; le cas facile a rater est le pipeline `curl | sh`, dont l'entree standard contient le script et ne peut donc pas servir au prompt.

## Success Behavior

- Sur Android Termux, `curl -fsSL https://www.winflowz.com/shipglowz-script | sh` selectionne `local`, n'appelle jamais `sudo`, utilise le home courant et finit par lancer `local/install.sh`.
- Execute en root sur un serveur supporte, la meme commande selectionne `full`, conserve l'utilisateur d'installation lorsqu'il est connu et lance `cli/install.sh`.
- Sur un poste non-root non-Termux avec `/dev/tty`, un prompt explique la difference entre installation locale et complete puis respecte le choix.
- `SHIPGLOWZ_INSTALL_MODE=local|full`, applique au processus `sh`, rend le choix deterministe en automatisation.
- Le depot existant est mis a jour sans perdre les changements locaux; un nouveau depot est clone sous le bon proprietaire.
- Le script public et le bootstrap canonique exposent la meme version et le meme comportement, verifiables mecaniquement.

## Error Behavior

- Un mode inconnu echoue avec les valeurs acceptees et sans mutation.
- Un contexte non interactif ambigu echoue avec les deux commandes explicites, notamment `curl ... | SHIPGLOWZ_INSTALL_MODE=local sh`.
- `full` sans root echoue avant clone ou installation et indique la commande `sudo` reservee aux systemes qui la supportent; Termux ne recoit jamais cette recommandation.
- Un échec de téléchargement du dépôt public distingue clairement le réseau, l'archive et les dépendances locales, sans afficher de credential ni de remote contenant un secret.
- Un echec de dependance, clone, fetch, checkout ou installateur conserve un journal utilisateur lisible et ne produit pas de faux succes.
- L'adaptateur public ne doit jamais servir silencieusement une version differente du bootstrap canonique declare.

## Problem

Le bootstrap public force aujourd'hui une installation serveur root avant toute selection de mode. Sur Termux, `sudo` n'existe pas par defaut; sans `sudo`, le garde root coupe le flow avant `local/install.sh`. En parallele, WinGlowz embarque une seconde copie du script, deja differente du bootstrap ShipGlowz, ce qui rend les corrections difficiles a deployer et a verifier.

## Solution

Faire de `install-shipglowz.sh` l'autorite comportementale des modes `local|full`, avec detection avant elevation et prompt sur `/dev/tty`. Le code public est distribue en HTTPS; le parcours Windows telecharge une archive ZIP et installe OpenSSH avec UAC si necessaire. Synchroniser byte-for-byte les artefacts vers WinGlowz; le endpoint les importe comme texte brut avec Vite `?raw`. Un outil ShipGlowz possede les modes `--write` et `--check`, et la preuve hebergee compare ensuite les corps publics aux autorites canoniques.

## Scope In

- Selection automatique et explicite des modes `local` et `full`.
- Detection Termux avant le garde root.
- Prompt interactif compatible avec `curl | sh` via `/dev/tty`.
- Regles non interactives et messages correctifs.
- Clone/update, home, utilisateur et ownership coherents par mode.
- Routage vers `local/install.sh` ou `cli/install.sh`.
- Gestion observable du téléchargement public et des dépendances locales.
- Adaptateur public WinGlowz, copie francaise/anglaise et mecanisme de parite.
- Tests shell de regression, tests site, build, preuve hebergee et retest Termux reel.
- Mise a jour des docs d'installation et du contexte technique.

## Scope Out

- Rendre le depot ShipGlowz public.
- Installer ou configurer automatiquement des credentials GitHub.
- Elargir le support complet au-dela du contrat serveur existant.
- Remplacer `local/install.sh` ou `cli/install.sh` par un installateur commun.
- Fermer `BUG-2026-07-13-002` sans son propre retest Termux.
- Modifier les autres installateurs WinGlowz `dotfiles-script` ou `termux-script`.

## Constraints

- Le bootstrap canonique reste POSIX `sh`; les installateurs delegues restent Bash.
- Le prompt ne lit jamais l'entree standard du pipeline et n'apparait pas lorsque Termux, root ou une variable valide determine deja le mode.
- Le mode local ne cree aucun fichier possede par root dans le home utilisateur.
- Le mode complet ne contourne pas le garde root.
- Les changements WinGlowz existants `winglowz.com` vers `www.winflowz.com` sont concurrents et doivent etre preserves.
- Aucun token, credential, header prive ou URL credentialee ne doit entrer dans les logs, tests ou docs.
- Le endpoint public reste l'entree stable; il sert les artefacts versionnes plutot que de rediriger vers une URL de telechargement dependante du cache ou de la plateforme.

## Test Contract

- Surface: shell bootstrap + adaptateur Astro public + vrai Android Termux.
- Proof profile: regression-first, integration, hosted, device.
- Proof order: test shell simulant les modes -> syntaxe shell -> tests/build WinGlowz -> controle de parite -> deploy Vercel -> endpoint production -> retest Android Termux.
- Automated proof: matrice avec faux `id`, `git`, `pkg`/`apt-get`, `bash`, TTY disponible/absent et home jetable; tests unitaires du endpoint/copy; build du site.
- Hosted proof: `005-sg-ship -> 405-sg-prod` avant toute affirmation sur le endpoint corrige.
- Manual/device proof: `107-sg-test --retest BUG-2026-07-17-001` sur Android Termux, sans `sudo`, avec verification du chemin local.
- Required results: tous les criteres d'acceptation automatisables passent; le bug reste `fix-attempted` tant que le retest heberge/device n'est pas passe.
- Exception with proof: le vrai comportement Android/Termux ne peut pas etre prouve uniquement par un mock Linux; l'automatisation couvre le routage et le device couvre l'integration native.

## Dependencies

- POSIX `sh`, Bash, Git, curl et gestionnaire de paquets disponible selon le mode.
- Dépôt public accessible en HTTPS; Git n'est pas requis par le parcours Windows.
- WinGlowz Astro en mode server et deploiement Vercel hybride.
- Fresh docs checked: la documentation officielle Astro des endpoints confirme l'utilitaire `redirect()` et le code 307, mais cette approche est rejetee ici parce que la cible GitHub privee retourne 404 sans authentification: https://docs.astro.build/en/guides/endpoints/
- Fresh docs checked: la documentation officielle Vite confirme que le suffixe `?raw` importe un asset comme chaine, ce qui permet au endpoint de servir l'artefact shell genere sans reecrire son contenu: https://vite.dev/guide/assets.html#importing-asset-as-string

## Invariants

- Le mode est resolu avant tout garde root ou installation de dependances.
- `local` implique compte courant, home courant et `local/install.sh`.
- `full` implique root, cible serveur supportee et `cli/install.sh`.
- Une variable de mode valide gagne sur l'auto-detection; Termux refuse toutefois `full` avec une explication plutot que d'essayer une elevation impossible.
- Le bootstrap public ne stocke ni ne demande de secret GitHub.
- Les changements locaux du depot sont preserves par une sauvegarde non destructive avant update.
- Une erreur reste observable et aucun message final de succes n'est emis apres un echec.

## Links & Consequences

- `install-shipglowz.sh` devient l'autorite de selection et de routage.
- `local/install.sh` et `cli/install.sh` restent proprietaires de leurs dependances et configurations respectives.
- WinGlowz distribue les scripts et sa page explique les deux modes; le chemin Windows promet un dépôt public téléchargeable sans Git.
- Le changement de commande publique affecte README, documentation technique, page d'installation, claim register/public surface map si leur promesse devient fausse.
- La parite public/canonique devient une obligation de verification et de release, pas une comparaison informelle.
- `BUG-2026-07-17-001` recoit les tentatives et retests; `BUG-2026-07-13-002` reste un work item separe.

## Documentation Coherence

- Mettre a jour `README.md` et `shipglowz_data/technical/installer-and-user-scope.md` avec la commande sans `sudo`, les modes et la limite Windows Update/UAC.
- Mettre a jour les contenus EN/FR de `scriptInstallPages.ts` pour distinguer local, complet, dépôt public et élévation UAC.
- Revoir les registres editoriaux WinGlowz qui revendiquent une installation en une commande afin que la promesse n'implique pas un support universel ni l'absence de confirmation UAC.
- Ajouter une note de diagnostic Termux qui explique que `curl: Failed writing body` est une consequence du consommateur `sudo` absent, pas l'erreur racine du telechargement.

## Edge Cases

- `TERMUX_VERSION` absent mais `PREFIX` contient `com.termux`.
- Termux avec un binaire `sudo` ou `tsu` installe: le mode reste local et n'eleve pas.
- Root avec `HOME` herite d'un utilisateur et execution via `sudo` avec `SUDO_USER`.
- Pipeline sans `/dev/tty`, CI, cron ou shell detache.
- Variable vide, casse differente, espaces ou mode inconnu.
- Depot deja present, dirty, mauvais remote, branche absente ou path non-git.
- Clone prive sans credential helper, SSH key ou authentification GitHub.
- Echec partiel de `pkg`, `apt-get`, clone ou installateur delegue.
- Endpoint public en cache apres deploiement d'une nouvelle revision.

## Implementation Tasks

- [x] Tache 1 : Ajouter le test de regression du selecteur et du routage avant le correctif.
  - Fichier : `tests/install/bootstrap-mode-selection.sh`
  - Action : Simuler Termux, root, utilisateur ambigu, TTY/non-TTY, variables valides/invalides, clone/update, auth refusee et chemins delegues sans mutation systeme.
  - User story link : prouver que Termux ne rencontre plus le garde root et que full reste protege.
  - Depends on : none
  - Validate with : `bash tests/install/bootstrap-mode-selection.sh`

- [x] Tache 2 : Implementer la resolution de mode et les frontieres utilisateur/root.
  - Fichier : `install-shipglowz.sh`
  - Action : Ajouter detection Termux, variable `SHIPGLOWZ_INSTALL_MODE`, prompt `/dev/tty`, erreurs non interactives, home/ownership par mode, dependances adaptees et delegation locale/complete.
  - User story link : rendre la commande unique correcte et agreable sur les trois contextes.
  - Depends on : Tache 1
  - Validate with : `sh -n install-shipglowz.sh && bash tests/install/bootstrap-mode-selection.sh`

- [x] Tache 3 : Construire une distribution publique byte-for-byte sans redirection vers un dépôt interne.
  - Fichier : `tools/sync_shipglowz_public_bootstrap.sh`, `/home/claude/winglowz/winglowz_site/src/generated/shipglowz-installer.sh`, `/home/claude/winglowz/winglowz_site/src/pages/shipglowz-script.ts`
  - Action : Ajouter un outil `--write|--check` qui copie/compare exactement le bootstrap canonique vers l'artefact genere; importer cet artefact avec `?raw` dans le endpoint et supprimer le template shell duplique; preserver les changements hostname existants.
  - User story link : la commande publique execute le correctif reel.
  - Depends on : Tache 2
  - Validate with : `tools/sync_shipglowz_public_bootstrap.sh --check --winglowz-root /home/claude/winglowz && cmp install-shipglowz.sh /home/claude/winglowz/winglowz_site/src/generated/shipglowz-installer.sh`

- [x] Tache 4 : Aligner la page publique et ses tests.
  - Fichier : `/home/claude/winglowz/winglowz_site/src/data/scriptInstallPages.ts`, `/home/claude/winglowz/winglowz_site/tests/`
  - Action : Remplacer la commande root-only, documenter les modes EN/FR, l'acces autorise et ajouter les assertions endpoint/copy/parite.
  - User story link : l'operatrice copie une commande valide et comprend le mode choisi.
  - Depends on : Tache 3
  - Validate with : `pnpm --dir /home/claude/winglowz/winglowz_site test:unit && pnpm --dir /home/claude/winglowz/winglowz_site build:check`

- [x] Tache 5 : Aligner la documentation et la memoire du bug.
  - Fichier : `README.md`, `shipglowz_data/technical/installer-and-user-scope.md`, `shipglowz_data/workflow/bugs/BUG-2026-07-17-001.md`
  - Action : Documenter le nouveau contrat, actualiser la carte technique et ajouter la tentative de fix sans fermer le bug.
  - User story link : conserver une promesse d'installation honnete et durable.
  - Depends on : Taches 2-4
  - Validate with : metadata lint cible, recherches de commandes obsoletes et `git diff --check`

- [ ] Tache 6 : Executer la preuve hebergee puis le retest Termux.
  - Fichier : aucun code supplementaire attendu
  - Action : Ship borné des deux repos, attendre Vercel, verifier le script public, puis rejouer le flow reel sur Termux.
  - User story link : prouver le resultat sur la machine qui a revele le bug.
  - Depends on : Taches 1-5
  - Validate with : `005-sg-ship -> 405-sg-prod -> 107-sg-test --retest BUG-2026-07-17-001`

## Acceptance Criteria

- [x] CA1 : Given Android Termux non-root, when la commande publique sans `sudo` est executee, then le mode local est choisi et `local/install.sh` est lance.
- [x] CA2 : Given Termux, when `full` est demande, then le bootstrap refuse avant mutation et explique que le mode complet cible un serveur supporte.
- [x] CA3 : Given root sur serveur, when aucun mode n'est fourni, then `full` est choisi et `cli/install.sh` est lance.
- [x] CA4 : Given un utilisateur non-root ambigu avec TTY, when la commande est lancee, then le prompt lit `/dev/tty` et respecte `local` ou `full`.
- [x] CA5 : Given un contexte ambigu sans TTY, when aucun mode n'est fourni, then aucune installation ne commence et les commandes explicites sont affichees.
- [x] CA6 : Given `SHIPGLOWZ_INSTALL_MODE=local|full` sur le processus `sh`, when la plateforme est compatible, then le choix est deterministe sans prompt.
- [x] CA7 : Given mode local, when clone/update et delegation s'executent, then le depot et le log appartiennent a l'utilisateur courant et aucun `sudo` n'est appele.
- [x] CA8 : Given mode full via sudo, when `SUDO_USER` existe, then le depot cible le home de cet utilisateur et l'installateur complet s'execute en root.
- [x] CA9 : Given un dépôt public inaccessible, when téléchargement ou extraction échoue, then le message distingue le réseau, l'archive et la dépendance locale sans exposer de secret.
- [x] CA10 : Given une revision canonique, when l'adaptateur public est teste, then son corps/revision est mecaniquement en parite et la divergence bloque la validation.
- [x] CA11 : Given les pages EN/FR, when l'utilisateur lit ou copie la commande, then aucun `sudo` n'est impose au chemin local et la limite d'acces autorise est visible.
- [ ] CA12 : Given le deploiement Vercel correspondant, when le endpoint public est recupere puis execute sur le vrai Termux, then le flow local passe avant que le bug puisse devenir `fixed-pending-verify`.

## Test Strategy

- Commencer par un test shell rouge reproduisant exactement le garde root precedant le mode.
- Utiliser des shims de commandes et un home jetable; ne jamais lancer de vrai `pkg`, `apt-get`, `git clone` prive ou installateur systeme dans le test.
- Tester le script canonique comme boite noire et verifier commande deleguee, utilisateur, home, log et code retour.
- Ajouter des tests WinGlowz sur la commande affichee, le contrat EN/FR et la parite de l'adaptateur.
- Executer syntaxe shell, tests cibles et build site avant le ship.
- Apres ship, verifier HTTP, cache/revision et contenu du endpoint via `405-sg-prod`.
- Terminer par le scenario reel Android Termux de `107-sg-test`; ne pas inventer son resultat.

## Risks

- Le prompt peut consommer le script du pipeline si `/dev/tty` n'est pas utilise strictement.
- Un mauvais calcul de home peut creer des fichiers root-owned ou installer dans `/root`.
- Un mode full auto-selectionne sur une plateforme non supportee peut causer une installation partielle.
- La copie publique peut diverger a nouveau si le mecanisme de sync/parite reste seulement documentaire.
- Une politique réseau ou Windows Update bloquée peut faire croire à une panne de bootstrap lorsque le dépôt ou OpenSSH ne peut pas être téléchargé.
- Les caches Vercel peuvent servir un ancien script apres deploiement.
- Les fichiers WinGlowz cibles sont deja modifies; une reecriture globale pourrait perdre les changements hostname en cours.

## Execution Notes

- Lire d'abord le bug, `install-shipglowz.sh`, `local/install.sh`, `cli/install.sh`, puis les deux fichiers WinGlowz cibles et leurs diffs.
- Ne pas modifier `local/install.sh` sauf si le nouveau test demontre une incompatibilite apres routage; `BUG-2026-07-13-002` en reste proprietaire.
- Le mecanisme de parite est fixe: copie byte-for-byte versionnee, outil ShipGlowz `--write|--check`, import Vite `?raw`, puis comparaison du endpoint heberge. Ne pas introduire de second template ou generateur de logique shell.
- Preserver les variables legacy `SHIPFLOW_*` seulement si leur compatibilite est encore documentee; les nouvelles commandes utilisent `SHIPGLOWZ_*`.
- Appliquer les edits WinGlowz hunk par hunk autour des changements concurrents et exclure tout fichier non lie du stage futur.
- Fresh docs checked; aucune nouvelle dependance runtime ne doit etre ajoutee pour la selection de mode.
- Stop si l'implementation exige de rendre le depot public, de stocker un token GitHub cote client, de contourner root en mode full ou d'ecraser les changements Winglowz existants.
- Validation locale: `sh -n install-shipglowz.sh`, test de regression bootstrap, tests/local Termux, metadata lint cible, tests/build WinGlowz, diff checks dans les deux repos.

## Open Questions

None. The safest Windows distribution default is the public ZIP path with automatic OpenSSH installation and an explicit UAC boundary.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-17 13:25:56 UTC | 100-sg-spec | GPT-5 Codex | Created the cross-repository bootstrap mode and Termux routing contract from BUG-2026-07-17-001 | draft | `/101-sg-ready Unified ShipGlowz Bootstrap Modes for Local and Full Installation` |
| 2026-07-17 13:29:32 UTC | 101-sg-ready | GPT-5 Codex | Ran structure, adversarial, security, freshness, proof, and cross-repository consequence review; fixed the parity mechanism to a byte-for-byte generated asset with `?raw` import | ready | `/102-sg-start Unified ShipGlowz Bootstrap Modes for Local and Full Installation` |
| 2026-07-17 13:42:00 UTC | 102-sg-start | GPT-5 Codex | Implemented mode selection, Termux routing, privilege boundaries, public artifact synchronization, endpoint/copy tests, and operator documentation | implemented locally; automated and build proofs pass | `/405-sg-prod`, then `/107-sg-test --retest BUG-2026-07-17-001` |
| 2026-08-01 15:04 UTC | 001-sg-build | GPT-5 Codex | Added native Windows PowerShell bootstrap distribution through the same public endpoint, adaptive local SSH setup without mandatory WSL/autossh/ssh-agent, and parity/test coverage | partial; shell regressions and public parity pass, PowerShell/runtime deployment proof pending | Deploy public adapter, then verify from the Windows VM |
| 2026-08-01 15:30 UTC | 300-sg-docs | GPT-5 Codex | Updated internal and public install documentation for the public ZIP bootstrap, automatic OpenSSH installation, UAC confirmation, and Windows Update/VM policy limits | docs aligned locally; deployment and Windows runtime proof pending | Push/deploy, then verify from the Windows VM |
| 2026-08-01 15:45 UTC | 010-sg-technical | GPT-5 Codex | Audited and removed stale private-repository messaging, hardcoded legacy SSH host/IP guidance, and obsolete Windows bootstrap instructions while preserving Linux/Termux autossh paths | targeted audit passed; Windows runtime and hosted deployment proof pending | Push/deploy, then verify from the Windows VM |
| 2026-08-01 15:56 UTC | 010-sg-technical | GPT-5 Codex | Removed the obsolete hardcoded SSH config template and replaced its manual documentation path with installer environment configuration | cleanup verified; Windows runtime and hosted deployment proof pending | Push/deploy, then verify from the Windows VM |

## Current Chantier Flow

- `100-sg-spec`: draft created
- `101-sg-ready`: ready
- `102-sg-start`: implemented
- `103-sg-verify`: local automated and build proof passed; hosted/device proof pending
- `104-sg-end`: not launched
- `005-sg-ship`: WinGlowz files were included in concurrent pushed commit `84dcdbb`; ShipGlowz changes remain unshipped
- Next step: deploy and verify the Windows adapter from the constrained Windows VM, then continue hosted/device proof
