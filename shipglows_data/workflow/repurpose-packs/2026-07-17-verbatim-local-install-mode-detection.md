---
artifact: verbatim_archive
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: draft
source_skill: 007-sg-content
scope: local-install-mode-detection
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: no
source_type: conversation
source_ref: "Two immediately preceding user/assistant messages before /007-sg-content repurpose verbatim 2"
linked_systems:
  - install-shipglows.sh
depends_on: []
supersedes: []
evidence:
  - "Two immediately preceding user/assistant messages preserved verbatim at the operator's request."
next_step: "None; verbatim preservation only."
---

# Verbatim Archive

User message 1

C'est bon, t'inquiète, j'ai commit. Alors il détecte automatiquement le mode local, c'est ça ? Comment il fait ça ? Moi je pense que ça peut être peut-être une bonne idée quand même de demander à l'utilisateur ce qu'il veut installer parce que peut-être qu'il veut installer le mode local sur Windows. Comment il fait pour détecter le mode local ?

Assistant message 2

Oui, mais il ne “détecte pas le mode local” de façon générale. La logique actuelle est :

1. `SHIPGLOWS_INSTALL_MODE` défini → respecte `local` ou `full`.
2. Termux détecté → sélection automatique de `local`.
3. Exécution en root → sélection automatique de `full`.
4. Sinon, avec un terminal interactif → demande :

```text
1) local — Termux/poste local
2) full  — serveur Ubuntu, root requis
```

Termux est reconnu grâce à `TERMUX_VERSION` ou à un `PREFIX` contenant `com.termux`.

Donc ton idée est déjà appliquée pour Windows sous WSL ou Git Bash : ce contexte n’est ni Termux ni root, donc le script demande à l’utilisateur ce qu’il souhaite installer.

Pour forcer le choix :

```bash
curl -fsSL https://www.winflowz.com/shipglows-script | SHIPGLOWS_INSTALL_MODE=local sh
```

```bash
curl -fsSL https://www.winflowz.com/shipglows-script | sudo env SHIPGLOWS_INSTALL_MODE=full sh
```

La nuance importante : sous Windows PowerShell natif, ce bootstrap shell ne lance pas encore automatiquement `local/install_local.ps1`. Il fonctionne surtout avec WSL ou Git Bash. Pour PowerShell natif, il faudrait idéalement proposer un second endpoint/one-liner PowerShell.

Je trouve le comportement actuel cohérent :

- Termux : `local` automatique, car `full` n’y est pas compatible.
- Windows/WSL/Git Bash et Linux non-root : question `local/full`.
- Serveur déjà root : `full` automatique.
- Automatisation sans terminal : mode explicite obligatoire.
