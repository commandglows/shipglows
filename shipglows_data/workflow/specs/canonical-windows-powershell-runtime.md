---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-24"
updated: "2026-08-24"
status: ready
source_skill: sg-development
scope: feature
owner: Diane
user_story: "En tant qu'operatrice ShipGlows sous Windows, je veux un unique moteur PowerShell portable et epingle afin que le CLI ait un comportement reproductible sans dependre du PATH ni modifier le systeme."
confidence: high
risk_level: high
security_impact: high
docs_impact: yes
linked_systems:
  - cli/windows/
  - install-shipglows.ps1
  - tests/windows/
  - shipglows_data/technical/
depends_on: []
supersedes: []
evidence:
  - "Decision operatrice du 2026-08-24: Windows PowerShell 5.1 sert uniquement au bootstrap et ShipGlows possede son runtime PowerShell 7 portable."
next_step: "/sg-verify canonical Windows PowerShell runtime"
---

# Runtime PowerShell Windows canonique

## Status

ready

## Minimal Behavior Contract

Windows PowerShell 5.1 execute seulement un bootstrap local. Celui-ci garantit PowerShell 7.6.5 LTS win-x64 dans `%USERPROFILE%\.shipglows\toolchains\powershell\7.6.5\win-x64`, puis lance le CLI avec ce chemin absolu. L'archive officielle est `https://github.com/PowerShell/PowerShell/releases/download/v7.6.5/PowerShell-7.6.5-win-x64.zip`, SHA-256 `32EB8F6CDCE08F86E987D625A2733E54AC3E289AE7E1621B14C0B5BCEC2434EA`. Aucun `pwsh` du `PATH` et aucune installation systeme ne sont admis.

## Success And Error Behavior

- Un runtime deja valide est reutilise sans reseau.
- Le mode offline reutilise un runtime valide, mais echoue clairement s'il est absent ou corrompu.
- Une acquisition utilise HTTPS, une URL fixe, un staging isole, un verrou borne, un SHA-256 obligatoire et une extraction ZIP bornee.
- L'extraction refuse traversal, chemins racines, liens/reparse, ADS, noms reserves, collisions insensibles a la casse, conflits fichier/dossier, nombre ou volume decompresse excessif.
- Le runtime est sonde pour `7.6.5`, edition `Core` et architecture x64 avant activation.
- Le pointeur JSON est remplace atomiquement; une erreur conserve l'ancien pointeur. Le staging est nettoye.
- Authenticode est complementaire; une revocation indisponible ne rend pas offline un runtime valide par SHA et sonde.
- Les erreurs sont actionnables et ne divulguent ni profil complet ni URL arbitraire.

## Scope

In: module de resolution/acquisition, bootstrap, wrappers, installateurs, executions internes PowerShell, tests et documentation. Out: installation systeme, modification du PATH pour `pwsh`, telechargement reel pendant l'implementation, autres architectures et macOS/Linux.

## Invariants

- `powershell.exe` 5.1 n'apparait que comme hote initial du bootstrap ou de l'installateur ShipGlows, y compris la reentree de mise a jour.
- Toute logique DevServer s'execute sous le runtime Core canonique et marque `SHIPGLOWS_MANAGED_PWSH` avec son chemin absolu.
- Une entree directe de `shipglows-devserver.ps1` sous Desktop est refusee; une entree Core non geree est egalement refusee. Seuls le bootstrap et l'installateur peuvent effectuer la reentree unique vers Core gere.
- `-Offline` est une option reservee au bootstrap et consommee avant le transfert; une valeur litterale telle que `--literal=-Offline` reste un argument frontend.
- `DownloadOnly` package les sources sans installer la toolchain.
- Le pointeur ne peut designer qu'une coordonnee immuable sous la racine toolchain validee.

## Implementation Tasks

- [x] Ajouter le module, son manifeste epingle et le bootstrap.
- [x] Router l'entree CLI, les wrappers et les processus PowerShell internes.
- [x] Integrer l'acquisition a l'installation complete et le packaging a l'installateur public.
- [x] Ajouter les regressions securite/offline/rollback/PATH et adapter le contrat Windows.
- [x] Aligner architecture, runtime, portee installateur, arbre de contexte et guide operateur.

## Acceptance Criteria

- [x] Installation fraiche depuis fixture, runtime existant, offline, corruption, SHA invalide et rollback sont prouves sans reseau.
- [x] Les archives hostiles representatives sont refusees avant ecriture hors staging.
- [x] Un faux `pwsh` dans le PATH n'est jamais execute.
- [x] Le frontend refuse Desktop direct et Core non gere; le bootstrap prouve la liaison vers le Core gere.
- [ ] Les contrats Windows, parseurs, metadonnees et `git diff --check` passent.

## Test Strategy

Utiliser des runners, ZIP fixtures et un writer de pointeur injectables uniquement avec un download runner dans `tests/windows/powershell-runtime.ps1`; aucun telechargement ou runtime reel. Prouver les bornes et attributs hostiles, probes invalides, nettoyages staging, rollback/pointeur, binding d'arguments et wrappers. Le test source direct du control plane Python ne remplace jamais la preuve live de `s env` apres installation.

## Skill Run History

| Date UTC | Skill | Action | Result | Next step |
|---|---|---|---|---|
| 2026-08-24 | sg-development | Decision et contrat pre-implementation formalises. | ready | Implementer regression-first. |
| 2026-08-24 | sg-development | Runtime portable, bootstrap, routage, packaging, regressions et documentation implementes sans acquisition reelle. | implemented | Verification independante. |

## Current Chantier Flow

- `sg-spec`: done
- `sg-ready`: passed by explicit operator approval
- `sg-start`: done
- `sg-verify`: pending
- `sg-end`: pending
- `sg-ship`: excluded (no commit/push authority)
