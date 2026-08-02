---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-04-29"
created_at: "2026-04-29 09:43:03 UTC"
updated: "2026-04-29"
updated_at: "2026-04-29 10:23:42 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "En tant qu'operateur ShipGlows travaillant depuis une machine locale vers un serveur distant, je veux lancer un login OAuth MCP distant avec un tunnel SSH ephemere automatique, afin de connecter Codex aux MCP comme Vercel et Supabase sans recopier manuellement les ports de callback."
confidence: "high"
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "local/local.sh"
  - "local/dev-tunnel.sh"
  - "local/install.sh"
  - "local/README.md"
  - "install.sh"
  - "README.md"
  - "Codex CLI MCP OAuth"
  - "Vercel MCP"
  - "Supabase MCP"
  - "SSH local forwarding"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Observed working manual flow: BROWSER=echo codex mcp login vercel, SSH -L callback port, browser approval, Codex reports Successfully logged in."
  - "Observed working manual flow: BROWSER=echo codex mcp login supabase, SSH -L callback port, browser approval, Codex reports Successfully logged in."
  - "codex mcp login --help exposes OAuth login command: codex mcp login [OPTIONS] <NAME>."
  - "Local Codex CLI version checked during spec update: codex-cli 0.125.0."
  - "codex mcp list after manual flow reports vercel and supabase enabled with OAuth auth."
  - "Vercel official docs: https://vercel.com/docs/mcp/vercel-mcp"
  - "Supabase official MCP page: https://supabase.com/mcp"
next_step: "/sg-start Local MCP OAuth tunnel login"
---

## Title

Local MCP OAuth tunnel login

## Status

ready

## User Story

En tant qu'operateur ShipGlows travaillant depuis une machine locale vers un serveur distant, je veux lancer un login OAuth MCP distant avec un tunnel SSH ephemere automatique, afin de connecter Codex aux MCP comme Vercel et Supabase sans recopier manuellement les ports de callback.

## Minimal Behavior Contract

Quand l'operateur lance la commande locale ShipGlows pour connecter un MCP distant, le systeme accepte seulement un provider connu (`vercel`, `supabase`, `all`) ou un nom generique deja configure dont le format est strictement borne, rejette toute valeur vide, option-like, espacee, multiligne ou contenant un caractere shell avant toute connexion SSH, demarre ensuite sur le serveur distant `codex mcp login <provider>` en forcant l'affichage de l'URL OAuth, extrait le port de callback `127.0.0.1`, ouvre un tunnel SSH local ephemere vers ce port, affiche ou ouvre l'URL OAuth dans le navigateur local, attend la fin du login distant, puis ferme le tunnel et affiche un statut verifiable. Si le serveur, Codex, le provider, le port, le tunnel ou le callback echoue, l'operateur voit une erreur actionnable et aucun tunnel temporaire ne reste volontairement actif. L'edge case facile a oublier est que le port change a chaque tentative OAuth; le tunnel doit donc etre cree apres extraction du port frais, jamais reutilise depuis une tentative precedente.

## Success Behavior

- Given une connexion ShipGlows locale deja configuree dans `~/.shipglows/current_connection`, when l'operateur lance `shipglows-mcp-login vercel`, then le script lance le login Codex sur le serveur distant, extrait l'URL et le port OAuth, cree le tunnel local, ouvre ou affiche l'URL, attend le callback et termine en affichant que `vercel` est en `OAuth` dans `codex mcp list`.
- Given le meme environnement, when l'operateur lance `shipglows-mcp-login supabase`, then le meme flux reussit pour `supabase` et le statut final affiche `OAuth`.
- Given l'operateur passe par le menu local `urls`, when il choisit l'option MCP login et selectionne un provider, then le menu appelle la meme logique que la commande directe et revient au menu apres succes ou erreur.
- Given un browser opener local disponible (`open`, `xdg-open`, `wslview`, ou equivalent), when l'URL OAuth est extraite, then le navigateur local s'ouvre automatiquement; otherwise l'URL complete est affichee avec la consigne de l'ouvrir manuellement.
- Given un login reussi, when le script termine, then le processus SSH tunnel temporaire est arrete et le serveur conserve uniquement les tokens OAuth stockes par Codex dans le compte distant de l'operateur.
- Given un provider generique valide comme `custom-name_1`, when l'operateur lance `shipglows-mcp-login custom-name_1`, then le script le traite comme une valeur de donnees, pas comme du shell, verifie sa presence dans `codex mcp list`, puis execute le meme flow OAuth si Codex expose une URL localhost.

## Error Behavior

- If `REMOTE_HOST` n'est pas configure ou ne repond pas en SSH, afficher la connexion cible et indiquer comment changer la connexion via le menu local, sans lancer de login distant.
- If le provider est vide, commence par `-`, contient un espace, une nouvelle ligne, un slash, un guillemet, un point-virgule, un dollar, un backtick, une substitution shell ou tout caractere hors de l'expression `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$`, afficher une erreur de validation locale et ne lancer ni SSH, ni Codex, ni tunnel.
- If `codex` est absent sur le serveur, afficher que Codex CLI doit etre installe/configure cote serveur et arreter avant de creer un tunnel.
- If le MCP n'est pas configure dans `codex mcp list`, pour les providers connus `vercel` et `supabase`, proposer la commande distante exacte `codex mcp add <name> --url <official-url>` sans l'executer automatiquement sauf si la future implementation ajoute un flag explicite.
- If la sortie de `codex mcp login <provider>` ne contient pas de `redirect_uri` localhost exploitable, afficher la sortie utile sans token, arreter le process distant, et ne pas creer de tunnel.
- If le port local est deja occupe, afficher le port et le processus si detectable, arreter le process distant de login, et demander de relancer.
- If l'utilisateur ne termine pas le login avant timeout, arreter le process distant et le tunnel local, puis expliquer qu'il faut relancer car l'URL OAuth est perissable.
- If le tunnel recoit `connect failed: Connection refused` mais le process distant finit avec succes, traiter l'operation comme reussie et afficher le statut final. Ce cas a ete observe pendant le flow manuel.
- Never log OAuth tokens, bearer tokens, refresh tokens, cookies, or full persisted auth files. The OAuth authorization URL may be displayed because it is required for operator action, but it must be treated as temporary and not written to logs by default.

## Problem

ShipGlows configure deja les MCP pour Claude et Codex pendant l'installation, mais l'authentification OAuth des MCP distants reste manuelle quand Codex tourne sur un serveur distant. Le callback OAuth revient vers `127.0.0.1:<port>` dans le navigateur local; sans tunnel SSH local vers le serveur, le navigateur parle a la machine locale au lieu du process Codex distant et l'utilisateur obtient `connection refused` ou `connection reset`.

Le flow manuel fonctionne, mais il est fragile: chaque tentative genere un port different, il faut lancer le tunnel au bon moment, ouvrir la bonne URL, garder le process distant en vie, puis verifier l'etat final. Cette friction revient pour Vercel, Supabase et tout MCP OAuth similaire.

## Solution

Ajouter un outil local ShipGlows dedie au login OAuth MCP distant. Il pilote le serveur par SSH, capture l'URL emise par `codex mcp login`, cree le tunnel SSH ephemere sur le port frais, ouvre ou affiche l'URL locale, attend la fin du process distant, nettoie le tunnel, puis verifie `codex mcp list`.

Le script doit vivre dans `local/` parce que c'est la couche qui connait la connexion SSH locale et qui controle les tunnels. `install.sh` reste responsable de configurer les serveurs MCP dans Codex; il ne devient pas responsable du login interactif.

## Scope In

- Creer une commande locale ShipGlows pour lancer un login OAuth MCP distant via SSH.
- Reutiliser la connexion locale existante stockee dans `~/.shipglows/current_connection`, avec fallback sur la config ShipGlows deja presente.
- Supporter explicitement `vercel` et `supabase` comme providers connus.
- Supporter un mode generique `shipglows-mcp-login <name>` pour tout MCP deja configure dans Codex et compatible `codex mcp login <name>`.
- Valider le nom provider localement avant tout SSH avec une allowlist de caracteres stricte et un rejet des valeurs option-like ou shell-like.
- Extraire automatiquement l'URL OAuth et le port `127.0.0.1:<port>` depuis la sortie distante.
- Creer et nettoyer un tunnel SSH local ephemere dedie au callback OAuth.
- Ajouter une entree au menu local `urls`.
- Ajouter les docs locales et les validations shell necessaires.

## Scope Out

- Ne pas reimplementer OAuth, PKCE, stockage de tokens ou callback HTTP.
- Ne pas lire ni modifier les fichiers d'auth Codex directement.
- Ne pas automatiser le clic ou la saisie d'identifiants dans le navigateur.
- Ne pas gerer les MCP non-Codex, sauf documentation de limites futures.
- Ne pas remplacer la configuration MCP existante de `install.sh`.
- Ne pas laisser de tunnel OAuth permanent en arriere-plan.
- Ne pas ajouter de dependance lourde; Bash + SSH + outils shell de base suffisent.

## Constraints

- La commande doit s'executer depuis la machine locale, pas depuis le serveur.
- Le process `codex mcp login <provider>` doit tourner sur le serveur distant parce que les tokens doivent etre stockes dans le compte distant utilise par Codex.
- Le provider est une entree non fiable. Il doit matcher `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$`, ne jamais commencer par `-`, et etre refuse avant SSH si cette regle echoue.
- La commande distante ne doit pas utiliser `eval`, ne doit pas interpoler une entree non validee dans un script shell compose, et doit preferer un passage d'argument positionnel ou une quotation shell explicite apres validation locale.
- Le tunnel doit mapper le meme port local et distant: `-L PORT:127.0.0.1:PORT`.
- Le port OAuth doit etre extrait de la tentative courante; aucune valeur cachee ne doit etre reutilisee.
- Les URLs OAuth peuvent contenir `state` et `code_challenge`; elles doivent etre affichees seulement dans le terminal interactif, pas persistees dans un fichier de log ShipGlows.
- Le style doit rester coherent avec les scripts `local/*.sh`: Bash, messages operateur, validation simple, nettoyage explicite.
- Le script doit fonctionner avec une connexion SSH alias (`hetzner`) ou une cible complete (`ubuntu@203.0.113.10`) deja sauvegardee.

## Dependencies

- Local: `bash`, `ssh`, `sed`/`awk`/`grep`, optional `autossh` not required for ce tunnel ephemere, optional browser opener (`open`, `xdg-open`, `wslview`, `start`).
- Remote: `codex` CLI avec support `codex mcp login <name>`, config Codex contenant les MCP cibles.
- Services externes: Vercel MCP endpoint officiel `https://mcp.vercel.com`; Supabase MCP endpoint officiel `https://mcp.supabase.com/mcp`.
- Fresh external docs: fresh-docs checked. Vercel official docs confirment que Vercel MCP est un remote MCP OAuth supporte par Codex CLI et utilise `https://mcp.vercel.com`. Supabase official MCP page confirme que le MCP heberge peut ouvrir un navigateur pour login et autorisation d'organisation; les alternatives PAT sont pour les environnements CI ou clients incompatibles.
- Local external tooling: `codex-cli 0.125.0` expose `codex mcp login [OPTIONS] <NAME>` et `codex mcp add <NAME> --url <URL>` dans l'environnement local verifie le 2026-04-29.
- Local behavior evidence: `codex mcp login --help` sur ce serveur confirme la commande OAuth; les flows manuels Vercel et Supabase ont reussi avec tunnel SSH local.

## Invariants

- Les tokens OAuth restent geres par Codex sur le serveur distant.
- Les tunnels PM2 existants ne sont pas tues ni modifies par le login MCP.
- Un echec ne doit pas laisser de process `codex mcp login` distant orphelin ni de tunnel local volontairement actif.
- La commande doit verifier le statut final avec `codex mcp list` plutot que supposer le succes depuis la page navigateur.
- La commande doit etre idempotente au niveau operateur: relancer un provider deja connecte doit soit confirmer l'etat OAuth, soit permettre une reauth propre sans casser les autres MCP.
- Une entree provider invalide ne doit produire aucun effet distant: pas de tentative SSH, pas de process Codex, pas de tunnel, pas de fichier temporaire contenant une URL OAuth.

## Links & Consequences

- `local/local.sh` est l'interface interactive locale existante; l'ajout d'une option modifie l'experience du menu `urls`.
- `local/dev-tunnel.sh` contient deja des patterns de connexion et d'identite serveur; la nouvelle logique doit les suivre sans coupler le login OAuth aux tunnels PM2.
- `local/install.sh` gere les alias locaux; il doit exposer la nouvelle commande si on veut une UX directe.
- `install.sh` configure deja `vercel` et `supabase` dans Codex; la nouvelle feature depend de cette configuration mais ne doit pas la dupliquer inutilement.
- `tests/cli/input-validation.sh` contient deja les tests de validation d'entrees shell sensibles; il doit couvrir le provider MCP pour eviter une regression d'injection de commande distante.
- `local/README.md` et `README.md` doivent distinguer configuration MCP, login OAuth MCP, et tunnels d'applications.
- Impact securite: l'outil connecte un assistant distant a des comptes Vercel/Supabase utilisateur. Les messages doivent rappeler que l'operateur choisit le compte et l'organisation dans le navigateur officiel.

## Documentation Coherence

- Mettre a jour `local/README.md` avec la commande, le menu, le flow, les preconditions et le troubleshooting `connection refused/reset`.
- Mettre a jour `README.md` dans la section MCP/Codex ou utilisation locale pour signaler que ShipGlows sait maintenant aider au login OAuth MCP distant.
- Optionnel mais recommande: ajouter une entree `CHANGELOG.md` si l'implementation suit le processus release habituel.
- Ne pas modifier les docs de skills sauf si l'implementation change le workflow ShipGlows au-dela de l'outil local.

## Edge Cases

- Port OAuth change entre deux tentatives: toujours relancer la detection.
- Provider generique malveillant ou mal forme (`;`, `$()`, backticks, espaces, newline, `--config`, `/`, quotes): rejet local avant toute commande distante.
- URL OAuth arrive en plusieurs chunks de sortie SSH: la lecture doit attendre assez longtemps et parser de facon robuste.
- Le navigateur local ouvre une ancienne URL: le script doit afficher clairement l'URL fraiche et le port.
- Le tunnel est lance trop tard: le process distant peut timeout; le script doit afficher une relance propre.
- `codex mcp list` peut afficher `Auth Unsupported` avant login puis `OAuth` apres login; la verification doit accepter le format table courant.
- Provider deja connecte: proposer de continuer, confirmer le statut, ou relancer le login selon le comportement Codex observe.
- Remote host avec option `-i oracle.key`: si l'utilisateur a sauvegarde seulement `ubuntu@host`, ShipGlows ne connait pas la cle; le script doit s'appuyer sur la configuration SSH locale ou documenter que la connexion sauvegardee doit etre executable sans flags supplementaires.
- Environnement WSL/Windows: browser opener et quoting SSH peuvent differer; fournir fallback URL manuel.
- Sortie `channel open failed: connect failed: Connection refused` pendant fermeture: ne pas classer automatiquement en echec si Codex rapporte ensuite succes.
- MCP OAuth non supporte par Codex pour un provider donne: afficher l'erreur Codex brute utile et stopper.

## Implementation Tasks

- [ ] Tache 1 : Creer le script local de login MCP OAuth
  - Fichier : `local/mcp-login.sh`
  - Action : Ajouter un script executable Bash qui charge la connexion ShipGlows locale, valide l'argument provider avec `^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$` et rejet option-like avant tout SSH, lance le login distant, extrait URL et port, gere le tunnel, attend la completion et verifie le statut final.
  - User story link : Fournit la commande directe qui automatise le flow manuel.
  - Depends on : aucune
  - Validate with : `bash -n local/mcp-login.sh`
  - Notes : Preferer `ssh -N -L` avec cleanup par trap; ne pas utiliser `autossh` pour ce tunnel ephemere; centraliser la validation dans une fonction testable `validate_mcp_provider_name`.

- [ ] Tache 2 : Implementer la capture robuste du process distant
  - Fichier : `local/mcp-login.sh`
  - Action : Demarrer `BROWSER=echo codex mcp login <provider>` sur le serveur distant, capturer la sortie dans un fichier temporaire local, detecter l'URL `https://...` et extraire le port depuis `redirect_uri=http%3A%2F%2F127.0.0.1%3A<port>%2Fcallback`.
  - User story link : Evite que l'operateur recopie manuellement le port et l'URL.
  - Depends on : Tache 1
  - Validate with : test manuel Vercel/Supabase ou simulation de sortie avec une fixture shell.
  - Notes : Prevoir aussi une extraction depuis une URL decodee `http://127.0.0.1:<port>/callback` si Codex change le format d'affichage.

- [ ] Tache 3 : Gerer provider connu, provider generique et preflight Codex
  - Fichier : `local/mcp-login.sh`
  - Action : Ajouter `vercel`, `supabase`, et `all` comme raccourcis documentes; verifier a distance `command -v codex` et `codex mcp list`; pour provider absent, afficher la commande `codex mcp add` officielle quand connue; pour provider invalide, stopper localement avant SSH.
  - User story link : Rend le login utilisable sans connaitre les details de chaque MCP courant.
  - Depends on : Tache 1
  - Validate with : `shipglows-mcp-login ';touch /tmp/pwned'` doit echouer localement sans tentative SSH; `shipglows-mcp-login vercel --dry-run` si un dry-run est ajoute, ou verification manuelle des messages preflight.
  - Notes : `all` doit traiter les providers sequentiellement, pas en parallele, car chaque flow OAuth est interactif; `all` est un raccourci local et ne doit jamais etre envoye tel quel a `codex mcp login all`.

- [ ] Tache 4 : Ajouter ouverture navigateur et fallback manuel
  - Fichier : `local/mcp-login.sh`
  - Action : Detecter un opener local (`open`, `xdg-open`, `wslview`, `cmd.exe /c start` selon environnement) et ouvrir l'URL; sinon afficher l'URL complete et une consigne courte.
  - User story link : Reduit la friction du flow tout en restant compatible serveur distant.
  - Depends on : Tache 2
  - Validate with : execution sur l'environnement local cible et fallback force via variable d'env optionnelle.
  - Notes : Ne jamais lancer de navigateur sur le serveur distant.

- [ ] Tache 5 : Nettoyer correctement tunnel et processus
  - Fichier : `local/mcp-login.sh`
  - Action : Ajouter traps `EXIT`, `INT`, `TERM`; tuer le process tunnel local et le process SSH/login distant si encore actif; supprimer les fichiers temporaires.
  - User story link : Garantit que le login OAuth ne laisse pas de ports/processus parasites.
  - Depends on : Taches 1, 2, 4
  - Validate with : interrompre avec Ctrl+C pendant attente OAuth et verifier `ps`/`lsof` local.
  - Notes : Ne pas tuer les tunnels PM2 existants de `local/local.sh`.

- [ ] Tache 6 : Integrer au menu local ShipGlows
  - Fichier : `local/local.sh`
  - Action : Ajouter une option `Connecter un MCP distant` qui propose `vercel`, `supabase`, `all`, et `custom`, puis appelle `local/mcp-login.sh` avec le provider choisi.
  - User story link : Permet a l'operateur d'utiliser la feature depuis l'interface locale existante.
  - Depends on : Tache 1
  - Validate with : lancer `local/local.sh`, verifier le menu et un choix custom sans executer de login reel si possible.
  - Notes : Preserver les options existantes et eviter de casser le raccourci historique `0|6` si le menu utilise deja `6` implicitement pour quitter.

- [ ] Tache 7 : Exposer la commande directe dans l'installation locale
  - Fichier : `local/install.sh`
  - Action : Ajouter un alias ou lien pour `shipglows-mcp-login` pointant vers `~/shipglows/local/mcp-login.sh`, coherent avec les alias `urls` et `tunnel`.
  - User story link : Donne une commande directe memorisable pour les logins MCP.
  - Depends on : Tache 1
  - Validate with : relire `local/install.sh`; si execute en test, verifier que l'alias est disponible apres reload shell.
  - Notes : Ne pas imposer de dependance `autossh`.

- [ ] Tache 8 : Documenter usage et troubleshooting
  - Fichier : `local/README.md`
  - Action : Documenter `shipglows-mcp-login vercel`, `shipglows-mcp-login supabase`, `shipglows-mcp-login all`, la relation avec `~/.shipglows/current_connection`, et les erreurs `connection refused/reset`.
  - User story link : Rend le flow autonome pour une future session sans relire cette conversation.
  - Depends on : Taches 1 a 7
  - Validate with : relecture doc + coherence avec les messages du script.
  - Notes : Expliquer que le script doit etre lance sur la machine locale.

- [ ] Tache 9 : Mettre a jour la documentation globale ShipGlows
  - Fichier : `README.md`
  - Action : Ajouter une note dans la section Codex/MCP ou Local usage indiquant que ShipGlows configure les MCP et fournit une commande locale pour le login OAuth distant.
  - User story link : Aligne la promesse produit avec la nouvelle capacite.
  - Depends on : Tache 8
  - Validate with : `rg -n "shipglows-mcp-login|MCP OAuth" README.md local/README.md`
  - Notes : Garder la distinction entre `vercel mcp` CLI et Vercel hosted MCP pour Codex.

- [ ] Tache 10 : Ajouter validation syntaxique et tests de parsing
  - Fichier : `tests/cli/input-validation.sh` ou nouveau test local dedie
  - Action : Ajouter au minimum `bash -n local/mcp-login.sh local/local.sh local/install.sh`, des tests de `validate_mcp_provider_name`, et un test de parsing du port depuis une URL OAuth encodee.
  - User story link : Reduit le risque de casser le flow fragile port/URL.
  - Depends on : Taches 1, 2, 6, 7
  - Validate with : `./tests/cli/input-validation.sh` ou commande de test dediee documentee.
  - Notes : Ne pas faire de vrai login OAuth dans les tests automatiques; inclure des providers invalides avec espace, newline, `;`, `$`, backtick, slash, quote, et `--config`.

## Acceptance Criteria

- [ ] CA 1 : Given une machine locale avec connexion ShipGlows sauvegardee, when l'operateur lance `shipglows-mcp-login vercel`, then le script lance `codex mcp login vercel` sur le serveur, cree le tunnel du port frais, ouvre ou affiche l'URL OAuth, puis affiche `vercel` avec auth `OAuth` apres succes.
- [ ] CA 2 : Given le meme setup, when l'operateur lance `shipglows-mcp-login supabase`, then le flow reussit pour `supabase` et affiche auth `OAuth`.
- [ ] CA 3 : Given un port OAuth different a chaque tentative, when le script relance un login apres timeout ou interruption, then il extrait et utilise le nouveau port, pas l'ancien.
- [ ] CA 4 : Given un port local deja occupe, when le script detecte le conflit avant tunnel, then il arrete le login distant et affiche une erreur actionnable sans attendre inutilement.
- [ ] CA 5 : Given un login non termine avant timeout, when le timeout expire, then le script ferme le tunnel, arrete le process distant si possible, supprime ses fichiers temporaires et dit de relancer avec une URL fraiche.
- [ ] CA 6 : Given l'utilisateur choisit l'option MCP dans `local/local.sh`, when il selectionne `vercel` ou `supabase`, then le menu appelle la meme commande locale et conserve le fonctionnement existant des options de tunnels PM2.
- [ ] CA 7 : Given un provider inconnu mais deja configure dans Codex, when l'operateur lance `shipglows-mcp-login custom-name`, then le script tente `codex mcp login custom-name` et applique le meme tunnel si une URL localhost est emise.
- [ ] CA 8 : Given un provider connu absent de Codex config, when le preflight le detecte, then le script affiche la commande d'ajout officielle et ne pretend pas que le login a reussi.
- [ ] CA 9 : Given une interruption Ctrl+C pendant le flow, when le script sort, then aucun process `ssh -N -L <oauth-port>` lance par ce script ne reste actif.
- [ ] CA 10 : Given les docs locales, when un operateur lit `local/README.md`, then il comprend que la commande se lance localement, pourquoi le tunnel est necessaire, et comment reagir a `connection refused/reset`.
- [ ] CA 11 : Given un provider invalide comme `--config`, `bad name`, `bad/name`, `bad;cmd`, `bad$(cmd)`, une chaine vide ou une valeur multiligne, when l'operateur lance `shipglows-mcp-login <provider>`, then le script affiche une erreur de validation locale, ne lance aucune commande SSH distante, ne cree aucun tunnel et ne cree aucun fichier temporaire OAuth persistant.

## Test Strategy

- Syntax:
  - `bash -n local/mcp-login.sh`
  - `bash -n local/local.sh`
  - `bash -n local/install.sh`
- Parsing:
  - Ajouter un test automatisable qui nourrit la fonction de parsing avec une URL Vercel/Supabase encodee contenant `redirect_uri=http%3A%2F%2F127.0.0.1%3A46319%2Fcallback` et verifie `46319`.
  - Tester aussi une URL decodee `http://127.0.0.1:46319/callback`.
- Input validation:
  - Ajouter des cas automatises pour `validate_mcp_provider_name`: accepter `vercel`, `supabase`, `custom-name`, `custom_name.1`; refuser vide, `--config`, espace, newline, slash, quote, point-virgule, dollar, backtick et toute valeur de plus de 64 caracteres.
  - Si un dry-run est ajoute, verifier qu'un provider invalide echoue avant tout appel SSH en remplacant `ssh` par un stub qui ferait echouer le test s'il est invoque.
- Manual remote:
  - Depuis la machine locale, lancer `shipglows-mcp-login vercel`, finir le login navigateur, verifier `codex mcp list` distant.
  - Refaire avec `shipglows-mcp-login supabase`.
  - Interrompre volontairement un flow avec Ctrl+C et verifier que le tunnel est nettoye.
- Regression:
  - Lancer `local/local.sh` et verifier que les options existantes `Démarrer les tunnels SSH`, `Afficher les URLs`, `Arrêter les tunnels`, `Statut`, et `Redémarrer` fonctionnent encore.
  - Verifier que les tunnels PM2 existants ne sont pas tues par un login MCP.

## Risks

- Security: l'outil facilite l'octroi d'acces Vercel/Supabase a Codex distant. Mitigation: afficher clairement le provider, utiliser les endpoints officiels, ne pas logger les tokens, et laisser l'utilisateur approuver dans le navigateur officiel.
- Security: le provider generique est une entree non fiable qui pourrait devenir une injection de commande distante si elle est interpolee naivement. Mitigation: validation locale stricte, rejet avant SSH, pas de `eval`, passage d'argument ou quotation shell explicite, tests d'abus dans `tests/cli/input-validation.sh`.
- OAuth fragility: les formats de sortie Codex ou URLs peuvent changer. Mitigation: parser plusieurs formes et afficher une erreur claire si aucune URL callback n'est detectee.
- SSH cleanup: un mauvais cleanup peut laisser des tunnels. Mitigation: traps et tests d'interruption.
- UX confusion: l'utilisateur peut lancer la commande sur le serveur au lieu du local. Mitigation: docs et message de preflight qui explique que la commande doit tourner localement.
- Compatibility: Windows/WSL browser openers et quoting SSH peuvent differer. Mitigation: fallback URL manuel et documentation Windows si necessaire.
- Scope creep: ajouter l'auto-configuration MCP, PAT CI, ou login Claude dans le meme changement diluerait la feature. Mitigation: limiter a Codex OAuth via tunnel local.

## Execution Notes

- Lire d'abord `local/local.sh` pour reprendre la gestion `REMOTE_HOST`, `~/.shipglows/current_connection`, `select_connection`, `pause`, et le style de menu.
- Lire ensuite `local/dev-tunnel.sh` pour les patterns de validation SSH, keepalive et affichage d'identite serveur.
- Lire `install.sh` autour de `configure_codex_vercel_mcp` et `configure_codex_supabase_mcp` pour connaitre les noms MCP et endpoints officiels deja installes.
- Lire `local/install.sh` avant d'ajouter alias ou lien local.
- Approche recommandee:
  - Implementer d'abord `local/mcp-login.sh` avec `validate_mcp_provider_name` et un provider unique.
  - Construire les commandes distantes sans `eval`; si une commande SSH necessite `bash -lc`, passer le provider comme argument positionnel ou le shell-quoter apres validation.
  - Ajouter parsing + cleanup + verification finale.
  - Brancher le menu local.
  - Ajouter docs et tests.
- Commandes de validation minimales:
  - `bash -n local/mcp-login.sh local/local.sh local/install.sh`
  - `./tests/cli/input-validation.sh` si le test y est ajoute
  - test manuel `shipglows-mcp-login vercel` et `shipglows-mcp-login supabase` depuis une machine locale avec SSH fonctionnel.
- Stop conditions / reroute:
  - Si Codex change la sortie OAuth et ne fournit plus d'URL localhost exploitable, stopper et documenter le nouveau flow au lieu de deviner.
  - Si la validation stricte du provider bloque un nom MCP reel contenant un caractere hors allowlist, stopper et ajuster la spec avant d'elargir l'allowlist.
  - Si l'environnement local ne peut pas executer SSH sans options interactives non sauvegardees, demander de corriger la connexion ShipGlows locale ou la config SSH avant de poursuivre.
  - Si l'utilisateur demande support CI/headless, creer une spec separee pour PAT ou OAuth app credentials.

## Open Questions

- None. La premiere version prend maintenant en charge une connexion ShipGlows locale executable avec la configuration SSH normale ou avec une cle explicite enregistree via le menu local.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-29 09:43:03 UTC | sg-spec | GPT-5 Codex | Created spec for local MCP OAuth tunnel login automation | Draft spec saved | /sg-ready Local MCP OAuth tunnel login |
| 2026-04-29 10:00:09 UTC | sg-ready | GPT-5 Codex | Readiness gate for local MCP OAuth tunnel login | Not ready: provider input validation contract is underspecified for remote shell execution | /sg-spec Local MCP OAuth tunnel login |
| 2026-04-29 10:10:16 UTC | sg-spec | GPT-5 Codex | Updated spec after readiness feedback | Provider validation, security, tests, and acceptance criteria tightened | /sg-ready Local MCP OAuth tunnel login |
| 2026-04-29 10:14:29 UTC | sg-ready | GPT-5 Codex | Readiness gate after provider validation update | Ready | /sg-start Local MCP OAuth tunnel login |
| 2026-04-29 10:23:42 UTC | sg-start | GPT-5 Codex | Implemented remote MCP OAuth tunnel login flow | implemented | /sg-verify Local MCP OAuth tunnel login |
| 2026-04-29 11:06:00 UTC | sg-verify | GPT-5 Codex | Verification gate for local MCP OAuth tunnel login | Partial: static checks pass, browser OAuth flow proof not demonstrated in this run | /sg-auth-debug Local MCP OAuth tunnel login |
| 2026-04-29 12:48:00 UTC | sg-ship | GPT-5 Codex | Full close and ship for local MCP OAuth tunnel login helper | shipped with partial browser-OAuth evidence note | manual OAuth retest on local machine |
| 2026-04-29 13:05:00 UTC | sg-repurpose | GPT-5 Codex | Repurposed MCP OAuth tunnel workstream into docs and content surfaces | content pack produced | decide target docs update |
| 2026-04-29 13:15:00 UTC | sg-start | GPT-5 Codex | Applied documentation surfaces for remote MCP OAuth tunnel concept | implemented | /sg-verify Local MCP OAuth tunnel docs |
| 2026-04-29 16:05:00 UTC | sg-start | GPT-5 Codex | Added dedicated public guide for remote MCP OAuth callback tunnels | implemented | /sg-verify Local MCP OAuth tunnel article |

## Current Chantier Flow

- sg-spec: done
- sg-ready: ready
- sg-start: implemented
- sg-verify: partial
- sg-end: not launched
- sg-ship: shipped

Next command: /sg-verify Local MCP OAuth tunnel article
