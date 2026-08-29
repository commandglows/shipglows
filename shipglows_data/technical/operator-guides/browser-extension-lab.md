---
artifact: operator_guide
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-29"
updated: "2026-08-29"
status: reviewed
source_skill: 300-sg-docs
scope: browser-extension-lab
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/shipglows-devserver.ps1
  - skills/references/browser-extension-lab.md
depends_on: []
supersedes: []
evidence:
  - "Chrome BRAT static MV3 detection and isolated loading passed on 2026-08-29."
next_step: none
---

# Tester une extension Chrome avec ShipGlows

Le laboratoire ouvre un Chromium séparé et temporaire. Il ne copie rien dans votre profil Chrome personnel et n'exécute jamais automatiquement les scripts téléchargés avec un dépôt.

## Le parcours le plus court

1. Importez ou ouvrez le dépôt avec ShipGlows.
2. Inspectez-le : `s extension-inspect -ProjectPath <dossier>`.
3. Si le résultat est `static` ou `built`, lancez `s extension-lab -ProjectPath <dossier>`.
4. Testez l'extension dans la fenêtre Chromium qui apparaît, puis fermez cette fenêtre pour arrêter le laboratoire.

Pour un agent ou une CI locale, utilisez :

```powershell
s extension-inspect -ProjectPath <dossier> -Json
s extension-lab -ProjectPath <dossier> -Headless -Json
```

## Comprendre le résultat

- **Statique** : le dépôt contient directement `manifest.json`, comme Chrome BRAT. Aucun build n'est nécessaire.
- **Construite** : un dossier comme `dist/chrome` contient l'extension prête à charger.
- **Construction requise** : ShipGlows a reconnu le projet, mais refuse volontairement d'exécuter son script. Vérifiez le dépôt, lancez explicitement sa commande documentée, puis recommencez.
- **Plusieurs artefacts** : des sorties anciennes ou concurrentes existent. Supprimez les sorties périmées ou ciblez le dossier exact.
- **Manifest V2** : la technologie est obsolète pour ce laboratoire ; migrez vers Manifest V3.

## Petit glossaire sans jargon

- `manifest.json` : la carte d'identité de l'extension.
- `source` : les fichiers que l'on modifie.
- `dist` ou `build` : le résultat prêt à être chargé après construction.
- `unpacked` : un simple dossier d'extension, sans publication sur le Chrome Web Store.
- `service worker` : le processus de fond d'une extension Manifest V3.
- `profil temporaire` : un navigateur jetable sans historique, cookies ni extensions personnelles.

## Ce que la preuve signifie

Un identifiant d'extension retourné prouve que Chromium a accepté l'artefact. `target-created-unverified` signifie que la cible du popup existe, pas que son interface fonctionne. `declared-not-awake` signifie que le service worker est déclaré mais ne s'est pas réveillé pendant la courte observation. Boutons, pages, content scripts et worker demandent donc encore leurs propres scénarios.
