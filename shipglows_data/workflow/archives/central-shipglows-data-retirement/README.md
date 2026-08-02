# Central ShipGlows Data Repository Retirement Archive

Ce dossier contient les artefacts de retraite du dépôt central `~/shipglows_data`.

## But

Ce dépôt est traité comme **historique uniquement**. Les fichiers générés ici servent de preuve de migration/archivage et ne doivent **pas** être utilisés comme source de vérité opérationnelle.

## Contenu

- `inventory.json` : inventaire JSON complet du dépôt central (scan en lecture seule), incluant:
  - `path`, `type`, `size`, `mtime`, `sha256` (lorsque raisonnable),
  - statut git si applicable,
  - classification et destination initiale proposées.
- `inventory.md` : version markdown de l’inventaire pour lecture humaine.
- `shipglows_data-central-archive.bundle` : snapshot Git de l’historique de `~/shipglows_data`.
- `central-root-trackers/` : copie historique des trackers racine centraux modifiés (`TASKS.md`, `AUDIT_LOG.md`) conservés hors runtime.
- `legacy-collisions/` : variantes centrales archivées lorsque le fichier local canonique existait déjà avec un contenu différent.
- `legacy-project-trackers/` : trackers et notes des anciens projets sans workspace local ShipGlows détecté au moment de la retraite.

## Décisions de migration

- Les destinations absentes ont été copiées vers le corpus local cible.
- Les fichiers locaux existants n'ont pas été écrasés.
- Les variantes ShipGlows centrales plus anciennes ont été conservées dans `legacy-collisions/`.
- Les `TASKS.md` centraux de `gocharbon` et `winflowz` ont été ajoutés dans les trackers locaux sous une section `Legacy Imported From Central ShipGlows Data`.
- Les projets sans workspace local détecté ont été archivés dans `legacy-project-trackers/` plutôt que recréés comme projets actifs.

## Politique d’usage

- Ne pas brancher ce répertoire au runtime des skills/TUI/CLI.
- Ne pas copier/relier ces fichiers comme source de projet active.
- Conserver ce dossier en lecture seule et le référencer seulement pour audit, reprise ou preuve de conservation.
