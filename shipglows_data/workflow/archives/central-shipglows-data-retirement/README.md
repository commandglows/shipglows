# Central ShipGlows Data Repository Retirement Archive

Ce dossier contient les artefacts de retraite du dépôt central `~/shipglows_data`.

## But

Ce dépôt est traité comme **historique uniquement**. Les fichiers générés ici servent de preuve de migration/archivage et ne doivent **pas** être utilisés comme source de vérité opérationnelle.

## Contenu

- `central-root-trackers/` : copie historique des trackers racine centraux modifiés (`TASKS.md`, `AUDIT_LOG.md`) conservés hors runtime.
- `legacy-project-trackers/` : `TASKS.md` (et `gocharbon_quiz/BUSINESS.md`) des anciens projets sans workspace local ShipGlows détecté au moment de la retraite.

Supprimés le 2026-10-20 (ménage `shipglows tidy`, lot D1) et consultables uniquement dans l'historique Git : `inventory.json`, `inventory.md`, `shipglows_data_metadata_inventory.md`, `legacy-collisions/` et les `concurrent.md`/notes des `legacy-project-trackers/`. Le bundle `shipglows_data-central-archive.bundle` n'a jamais été suivi par Git.

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
