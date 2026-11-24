# Secrets de développement avec SOPS + age

Statut : pilote démarré le 2026-11-24 sur `claiire/site`. Doppler reste en place
pour les autres projets, pour la production et comme secours du pilote.

## Pourquoi

Le plan gratuit Doppler plafonne à 10 projets. SOPS (CNCF, MPL-2.0) et age
(BSD-3) sont gratuits, sans service ni abonnement : les secrets restent chiffrés
dans le dépôt Git du projet, et seule une clé privée age les ouvre.

## Modèle

- **Fichier :** `secrets/<config>.sops.env` à la racine du dépôt (`dev`, `stg`,
  `staging`, suffixe `_…` facultatif). C'est un dotenv dont les noms restent
  lisibles et chaque valeur est chiffrée (`ENC[AES256_GCM,…]`). Il se commite.
- **Destinataires :** `.sops.yaml` à la racine du dépôt fixe la clé publique age
  par motif de fichier. La regex sépare le dossier et le nom par `.`, car sops
  voit les chemins Windows avec des antislashs.
- **Clé privée :** dev dans `%AppData%\sops\age\keys.txt` (emplacement lu par
  défaut par sops sous Windows). Clé publique dev :
  `age1thar54r0k7j3cvutcpkyj05sm8vf8a204vlf6wdfmyq6qa59pg6qn9nn4t`. La perdre
  rend les fichiers illisibles : une copie doit vivre dans le Bitwarden de
  l'opératrice. Une clé fuitée oblige à rechiffrer et à changer les valeurs
  qu'elle ouvre, car l'historique Git garde les anciens fichiers.
- **Fins de ligne :** sops refuse un dotenv chiffré en CRLF. Chaque dépôt déclare
  `*.sops.env text eol=lf` et `.sops.yaml text eol=lf` dans `.gitattributes`.
- **Outils :** `sops` (winget `SecretsOPerationS.SOPS`) et `age`
  (winget `FiloSottile.age`).

## Lancement géré

Une recette `.shipglows.node.json` remplace l'objet `doppler` par `sops` ; le
reste du contrat (`inject`, `publicEnvironment`) ne change pas :

```json
{
  "schemaVersion": "shipglows.node-recipe.v1",
  "sops": { "file": "../secrets/dev.sops.env" },
  "inject": "all",
  "publicEnvironment": []
}
```

`s start` valide le fichier avant tout lancement : chemin `secrets/<config>.sops.env`
de dev ou staging dans le même checkout Git, aucune valeur en clair, métadonnées
sops présentes. Il lance ensuite `ShipGlows.SecretRun.ps1`, qui déchiffre en
mémoire (`sops decrypt --output-type json`) et démarre la commande d'origine avec
ces valeurs. Avec `"inject": "public"`, seules les clés de `publicEnvironment`
entrent dans le processus, et une clé absente du fichier bloque le lancement.
La commande d'origine passe en base64 et la signature ShipGlows reste sur la
ligne de commande externe. Sans sops, sans clé ou avec un fichier illisible, le
lancement échoue : aucun repli sans secrets.

Les recettes Python (`.shipglows.python.json`) et Flutter
(`.shipglows.flutter.json`) ne connaissent pas encore `sops`.

## Commandes

- Éditer : `sops edit secrets/dev.sops.env` (ouvre l'éditeur, rechiffre à la sauvegarde).
- Ajouter ou changer une valeur : `sops set secrets/dev.sops.env '["CLE"]' '"valeur"'`.
- Lancer une commande à la main : `sops exec-env secrets/dev.sops.env "<commande>"`.
- Importer une config Doppler sans rien écrire en clair (exemple du pilote) :
  `doppler secrets download --project <p> --config dev --no-file --format json | jq 'with_entries(select(.key|startswith("DOPPLER_")|not))' | sops encrypt --filename-override secrets/dev.sops.env --input-type json --output-type dotenv > secrets/dev.sops.env`

## Reste hors pilote

Recettes Python et Flutter, CI GitHub (clé age en secret GitHub), runner de la
VM (clé dédiée), sync vers Vercel (commande `s` à écrire), clé prd distincte,
`tools/feedback_triage.py` qui lit encore les déclarations Doppler.
