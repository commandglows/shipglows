---
artifact: operator_guide
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-29"
updated: "2026-09-03"
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
  - "WXT production and development outputs gained deterministic Chromium/Firefox selection while CRXJS compatibility remained covered on 2026-09-03."
next_step: none
---

# Tester une extension dans Chromium, Edge, Vivaldi ou Firefox

Le laboratoire ouvre le navigateur demandé avec un profil séparé et temporaire. Il ne copie rien dans vos profils personnels et n'exécute jamais automatiquement les scripts téléchargés avec un dépôt.

Pour une nouvelle extension, le preset ShipGlows utilise WXT, TypeScript strict, pnpm et Manifest V3. Une interface simple reste native; une interface riche utilise Vue 3. WXT doit laisser l'ouverture du navigateur désactivée dans sa configuration afin que le profil isolé du laboratoire reste l'autorité de validation.

## Le parcours le plus court

1. Importez ou ouvrez le dépôt avec ShipGlows.
2. Inspectez-le : `s extension-inspect -ProjectPath <dossier>`.
3. Si le résultat est `static` ou `built`, lancez `s extension-lab -ProjectPath <dossier>`.
4. Testez l'extension dans la fenêtre Chromium qui apparaît, puis fermez cette fenêtre pour arrêter le laboratoire.

Pour un agent ou une CI locale, utilisez :

```powershell
s extension-inspect -ProjectPath <dossier> -Json
s extension-lab -ProjectPath <dossier> -Headless -Json
s extension-lab -ProjectPath <dossier> -Browser Edge -Headless -Json
s extension-lab -ProjectPath <dossier> -Browser Vivaldi -Headless -Json
s extension-lab -ProjectPath <dossier> -Browser Firefox -Headless -Json -TargetUrl https://example.com/
```

Pour vérifier les content scripts sur une page précise, fournissez volontairement sa cible :

```powershell
s extension-lab -ProjectPath <dossier> -Headless -Json -TargetUrl https://example.com/
```

Sans `-TargetUrl`, ShipGlows répond `not-requested` et ne navigue nulle part. La cible doit être une URL absolue `http://` ou `https://`; évitez une page privée ou authentifiée sans autorisation explicite.

Pour conserver une preuve visuelle isolée, ajoutez `-Screenshot` :

```powershell
s extension-lab -ProjectPath <dossier> -Headless -Json -TargetUrl https://example.com/ -Screenshot
```

Le JSON retourne `visual.screenshotStatus`, le chemin absolu du PNG et le viewport `1280 × 800`. Avec `-TargetUrl`, l’image montre la page cible après le délai d’observation des scripts injectés. Sans cible explicite, Chromium, Edge et Vivaldi montrent le popup déclaré. La capture est conservée dans les preuves du runtime ShipGlows, en dehors du profil jetable qui est supprimé à la fin du Lab.

Pour cliquer puis inspecter un rendu précis :

```powershell
s extension-lab -ProjectPath <dossier> -Browser Edge -Headless -Json -TargetUrl https://example.com/ -ClickSelector "#extension-root button" -VisualSelector "#extension-root" -Screenshot
```

Le clic exige un seul élément. L’inspection retourne le texte borné, la visibilité, les dimensions et une liste fixe de styles calculés. La section `browser` donne le produit, le moteur, le chemin exact du binaire, sa version et la version observée à l’exécution. Firefox sélectionne un artefact `dist/firefox` lorsqu’il existe et l’installe temporairement via WebDriver BiDi. Sur une page cible Firefox, `observation-unavailable` signifie seulement que Playwright ne sait pas énumérer les URL des scripts injectés : une capture DOM ciblant un élément propre à l’extension apporte alors la preuve comportementale.

## Comprendre le résultat

- **Statique** : le dépôt contient directement un `manifest.json` d'extension avec `manifest_version`, comme Chrome BRAT. Aucun build n'est nécessaire. Un fichier générique portant ce nom mais sans ce champ est ignoré.
- **Construite** : un dossier WXT comme `.output/chrome-mv3`/`.output/firefox-mv3`, ou un dossier compatible comme `dist/chrome`, contient l'extension prête à charger.
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

Un identifiant d'extension retourné prouve que Chromium a accepté l'artefact. `opened` signifie que le popup a atteint `domcontentloaded` sans erreur capturée. `observed` confirme qu'un service worker ou, dans la section `contentScripts`, qu'un script de l'extension a réellement été vu. `not-requested` garantit qu'aucune cible de content script n'a été visitée implicitement. Les erreurs de console, page, navigation et requêtes sont bornées dans la sortie et produisent `loaded-with-diagnostic-errors`.
