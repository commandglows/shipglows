# Plan de Migration : Fonctionnalités Dokploy-Dev → Menu Simple

## Objectif
Migrer les fonctionnalités essentielles du script `dokploy-dev.sh` vers `menu_simple_color.sh` pour obtenir un menu complet de gestion des environnements Docker.

## Fonctionnalités à Migrer

### ✅ Fonctionnalités Existantes (menu_simple_color.sh)
- Lister les environnements Docker
- Afficher les URLs des environnements
- Stopper un environnement

### ❌ Fonctionnalités Manquantes à Ajouter

#### 1. Démarrer un Environnement Arrêté
**Description :** Permettre de sélectionner et démarrer un environnement qui est arrêté
**Étapes :**
- Lister les environnements avec statut "stopped" ou "exited"
- Présenter une sélection interactive
- Exécuter `docker compose start` sur l'environnement choisi
- Afficher confirmation de succès

#### 2. Supprimer un Environnement Complètement
**Description :** Supprimer complètement un environnement (containers, volumes, fichiers)
**Étapes :**
- Lister tous les environnements (running et stopped)
- Demander confirmation avec avertissement
- Exécuter `docker compose down -v` pour supprimer containers et volumes
- Option pour supprimer également les fichiers du projet
- Afficher confirmation de suppression

#### 3. Ouvrir le Répertoire de Code
**Description :** Ouvrir le dossier de code d'un environnement avec nvim
**Étapes :**
- Lister tous les environnements (pas seulement running)
- Vérifier que le répertoire de code existe
- Ouvrir avec nvim si disponible, sinon avec shell
- Gérer les cas où nvim n'est pas installé

#### 4. Déployer un Nouveau Repo GitHub
**Description :** Déployer un nouveau repository GitHub comme environnement Docker
**Étapes :**
- Lister les repositories GitHub de l'utilisateur
- Sélectionner un repo à déployer
- Cloner le repository
- Détecter automatiquement le type de projet (Node.js, Python, etc.)
- Créer Dockerfile et docker-compose.yml appropriés
- Démarrer l'environnement
- Afficher les URLs d'accès

## Structure d'Implémentation

### Ajouts au Menu
Nouvelles options à ajouter dans le menu principal :
- 9) ▶️ Démarrer un environnement
- 10) 💀 Supprimer un environnement
- 11) 📝 Ouvrir le répertoire de code
- 12) 🚀 Déployer un repo GitHub

### Fonctions à Créer
- `start_environment()` : Gère le démarrage d'environnements arrêtés
- `remove_environment()` : Gère la suppression complète d'environnements
- `open_code_directory()` : Gère l'ouverture des répertoires de code avec nvim
- `deploy_github_repo()` : Gère le déploiement complet d'un repo GitHub

### Configuration Requise
- `DOKPLOY_DIR="/etc/dokploy/compose"` : Répertoire des environnements
- Vérification présence de `gh` (GitHub CLI) pour déploiement
- Vérification présence de `jq` pour parsing JSON
- Vérification présence de `nvim` pour ouverture code

## Ordre de Priorité
1. Démarrer un environnement (simple, utile au quotidien)
2. Supprimer un environnement (nécessaire pour nettoyage)
3. Ouvrir le répertoire de code (utile pour développement)
4. Déployer un repo (complexe, mais complète l'outil)

## Gestion des Erreurs
- Vérifier la disponibilité des outils avant utilisation
- Afficher des messages d'erreur explicites
- Proposer des alternatives quand un outil n'est pas disponible
- Confirmer les actions destructives avec avertissements

## Tests de Validation
- Tester chaque nouvelle fonctionnalité individuellement
- Vérifier le comportement en cas d'erreur
- S'assurer que l'interface reste cohérente
- Tester avec différents environnements Docker
