# Handoff : `shipglows-dev start` échoue sur le raccourci Flutter Dev d'un autre worktree

- Date : 2026-10-14
- Repo à corriger : `C:\Users\Diane\ShipGlows\shipglows`
- Fichier : `cli/windows/ShipGlows.DevServer.psm1`
- Test existant : `tests/windows/devserver-flutter-background.ps1` (ligne ~79)
- Statut : corrigé le 2026-10-15 (`Install-SgDevShortcut` : nom canonique, worktrees ignorés, échec non bloquant)
- Attention : le repo a déjà des modifications non committées dans `ShipGlows.DevServer.psm1` (autre session). Ne pas créer de branche ni de worktree : travailler sur `main` dans ce checkout, en ne touchant que les lignes du correctif et sans écraser ni committer les modifications des autres.

## Symptôme

```
s start -ProjectPath C:\Users\Diane\ShipGlows\wt-windows\commandglows_app -FlutterDevice windows
[ShipGlows] Existing shortcut is not owned by ShipGlows: C:\Users\Diane\Desktop\ShipGlows - commandglows_app - Dev.lnk
exit code 1
```

L'app démarre bien et `s status` affiche `running`. Seul le code de sortie et le message sont faux : un agent ou un script croit que le lancement a échoué.

## Cause (vérifiée)

1. `Install-SgFlutterDevShortcut` (l. ~2865) construit le chemin du `.lnk` uniquement à partir de `Entry.name`. Plusieurs checkouts du même projet (repo principal, `wt-windows`, `worktrees\commandglows\poplar-merlin\…`) ont le même nom, donc le même fichier `.lnk`.
2. Le marqueur de propriété inclut le chemin du projet (`ShipGlows managed Flutter Dev shortcut v1 | <path>`). Le raccourci existant porte le marqueur d'un autre worktree (`…\poplar-merlin\commandglows\commandglows_app`). Il est donc jugé « not owned » alors que ShipGlows l'a bien créé.
3. L'appel (l. ~3063, dans `Start-SgProjectCore`, après `Set-SgReservationState … 'running'`) n'est pas protégé par un try/catch. L'exception remonte et fait sortir `start` en code 1 après un démarrage réussi.

## Correctif attendu

1. **Non bloquant** : envelopper l'appel l. ~3063 comme le moniteur de sortie juste au-dessus. Si l'opération échoue, afficher `Write-SgWarn "Flutter Dev shortcut skipped: …"`, sans changer le statut ni le code de sortie.
2. **Reconnaître ses propres raccourcis** : considérer comme « owned » tout raccourci dont la description commence par `ShipGlows managed Flutter Dev shortcut v1 |`. Le refus doit être réservé aux raccourcis vraiment étrangers.
3. **Politique worktree** : la règle utilisateur est « raccourci Desktop officiel seulement, jamais un raccourci de worktree ». Un checkout qui n'est pas le repo principal (détection : `git rev-parse --git-common-dir` ≠ `--git-dir`, ou chemin sous `worktrees\` / `wt-*`) ne doit pas créer ni écraser le raccourci Desktop. Il saute simplement l'étape, avec une ligne d'info.
4. Vérifier aussi que le nom affiché (`ShipGlows - commandglows_app - Dev`) et `$path = "$displayName - Dev.lnk"` correspondent au nom legacy géré (l. ~2875), pour ne pas laisser de doublons.

## Tests à ajouter (dans `tests/windows/devserver-flutter-background.ps1` ou un nouveau fichier)

- Un raccourci existant avec le marqueur d'un autre chemin du même projet est accepté (ou ignoré pour un worktree) et ne lève pas d'exception.
- Un raccourci étranger (sans marqueur) n'est pas écrasé, et `start` réussit quand même avec un avertissement.
- Un worktree ne crée pas de raccourci Desktop.

## Validation

- Lancer les tests PowerShell Windows du repo concernés par DevServer.
- Repro réelle : `s stop` puis `s start -ProjectPath C:\Users\Diane\ShipGlows\wt-windows\commandglows_app -FlutterDevice windows`. Résultat attendu : code 0, app `running`, raccourci Desktop officiel inchangé.
- Mettre à jour `shipglows_data/technical/operator-guides/windows-devserver.md` (section raccourcis) si la politique worktree change.
