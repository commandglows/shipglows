# Comparatif des senders : Postmark et SMTP2GO

> État de la comparaison : 3 septembre 2026. Les tarifs et fonctionnalités des fournisseurs doivent être revérifiés avant toute souscription ou migration.

## Contexte ShipGlows

L'architecture envisagée est la suivante :

- **CommandGlows** possède les contacts, consentements, audiences et entitlements ;
- chaque inscription transmise par un produit contient un `business_id` ;
- le sender reste un transport remplaçable derrière CommandGlows ;
- **ShipGlows** pilote l'ensemble sans stocker ces données pour l'instant.

L'objectif est de gérer progressivement plusieurs business avec une excellente délivrabilité, peu de charge opérationnelle et une dette technique limitée. L'interface de création des emails et de gestion des audiences reste interne : le fournisseur n'a pas besoin d'être un CRM marketing complet.

## Synthèse

| Critère | Postmark | SMTP2GO |
| --- | --- | --- |
| Positionnement principal | Email applicatif transactionnel et broadcast | Relais SMTP/API polyvalent, agences et MSP |
| Isolation des business | Un `Server` par business | Un sous-compte par business |
| Séparation transactionnel/marketing | `Message Streams` dédiés, avec statistiques et suppressions séparées | Réalisable par sous-comptes, clés ou expéditeurs, mais moins structurante dans le modèle |
| Gestion de clients autonomes | Accès et permissions par `Server` | Sous-comptes réellement autonomes avec utilisateurs et réglages propres |
| Quotas par business | À piloter principalement dans CommandGlows | Quotas mensuels natifs par sous-compte avec alertes et blocage |
| Intégration applicative | API concise, SMTP, templates et webhooks | API, SMTP, envoi MIME, templates et webhooks |
| Compatibilité avec des outils anciens | Bonne via SMTP | Excellente orientation relais SMTP générique |
| Tests sans livraison réelle | Sandbox Servers, token de test et simulations de bounces | Sandbox Mode ; tests visuels et antispam sur les offres professionnelles |
| Archivage | 45 jours par défaut, configurable de 7 à 365 jours avec option | Archivage optionnel du contenu et des pièces jointes jusqu'à 5 ans |
| SMS | Non | Disponible en option sur les offres payantes |
| Infrastructure avancée | Infrastructure gérée avec priorité donnée à la délivrabilité | IP dédiées, pools d'IP, authentification et allowlist IP |
| Support | Support spécialisé email | Ticket, chat et téléphone sur les offres payantes |
| Meilleur usage | Backend central des produits ShipGlows | Plateforme SMTP pour clients externes ou systèmes très variés |

## Là où Postmark gagne

### 1. Séparation native des catégories d'emails

Postmark distingue explicitement les flux **transactionnels** et **broadcast**. Chaque business peut disposer de son propre `Server`, puis de streams séparés :

```text
CommandGlows
  ├── ContentGlows → Server Postmark
  │     ├── transactional
  │     └── broadcast
  ├── WinFlowz → Server Postmark
  │     ├── transactional
  │     └── broadcast
  └── Business suivant → Server Postmark
```

Cette séparation protège les emails essentiels — connexion, confirmation, reçu — des incidents liés à une campagne marketing. Les suppressions et statistiques peuvent être suivies par stream.

### 2. Alignement naturel avec CommandGlows

Le modèle `business_id → Server Postmark` est simple à provisionner et à maintenir. Les `Servers` sont illimités et administrables par API. CommandGlows conserve la logique métier tandis que l'adaptateur Postmark reste mince.

### 3. Faible charge opérationnelle

Postmark est spécialisé dans l'email applicatif. Son interface de diagnostic permet de retrouver rapidement la chronologie d'un message, la réponse du serveur destinataire, les bounces et les suppressions. Cette spécialisation réduit le travail nécessaire pour exploiter correctement le transport au quotidien.

### 4. Environnement de test adapté au développement

Les Sandbox Servers, le token de test et les adresses simulant différents bounces permettent de tester l'intégration et les webhooks sans envoyer aux destinataires réels ni endommager la réputation de production.

### 5. Isolation sans multiplication des comptes

Chaque business peut avoir son token, ses streams, ses statistiques, templates, webhooks et suppressions dans un compte central. Des droits peuvent être accordés sur un `Server` précis si une personne doit intervenir uniquement sur un business.

## Là où SMTP2GO gagne

### 1. Véritable organisation agence ou reseller

SMTP2GO fournit des sous-comptes conçus pour séparer les clients. Chaque sous-compte peut avoir ses propres utilisateurs, paramètres, rapports et limites. Ce modèle devient préférable si les business sont exploités par des équipes autonomes ou si ShipGlows sert un jour des clients externes.

### 2. Quotas natifs par business

Le compte principal peut attribuer une limite mensuelle à chaque sous-compte. SMTP2GO envoie des alertes à différents seuils d'utilisation et bloque finalement l'envoi. Cela empêche un client ou un système défaillant de consommer tout le volume commun sans devoir reconstruire entièrement ce contrôle dans CommandGlows.

### 3. SMTP universel

SMTP2GO convient particulièrement aux CMS, logiciels métiers, NAS, scanners et applications anciennes qui proposent uniquement une configuration SMTP classique. Il constitue un meilleur choix lorsque la diversité des systèmes connectés dépasse les applications développées en interne.

### 4. Archivage de longue durée

L'archivage optionnel peut conserver pendant un à cinq ans le contenu complet, les en-têtes, les pièces jointes et les informations de livraison. Cet avantage devient déterminant pour un besoin contractuel, réglementaire ou d'audit de longue durée.

### 5. Services complémentaires

SMTP2GO peut réunir dans le même fournisseur :

- tests visuels dans de nombreux clients email et tests antispam ;
- SMS avec réception de réponses ;
- IP dédiées et pools d'IP attribuables aux sous-comptes ;
- authentification et restrictions par adresse IP ;
- support par ticket, chat et téléphone.

## Décision recommandée

**Postmark est le choix recommandé pour CommandGlows.**

Les business concernés appartiennent au même écosystème et sont pilotés centralement. Ils n'ont pas actuellement besoin de sous-comptes clients réellement autonomes. Le couple `Server + Message Streams` correspond mieux à la séparation attendue entre les business et entre les emails transactionnels et marketing.

Architecture cible :

```text
CommandGlows = données, consentements, audiences et entitlements
Postmark     = transport, délivrabilité, événements et suppressions
ShipGlows    = gouvernance

1 business_id       = 1 Server Postmark
email transactionnel = Transactional Stream
newsletter           = Broadcast Stream
```

SMTP2GO reste l'alternative prioritaire si l'un des besoins suivants apparaît :

- des clients externes doivent administrer eux-mêmes leur espace d'envoi ;
- des quotas fournisseurs stricts doivent être affectés par business ;
- de nombreux équipements ou logiciels SMTP non développés en interne doivent être connectés ;
- un archivage supérieur à un an devient obligatoire ;
- les SMS doivent être regroupés chez le même fournisseur.

## Sources officielles

### Postmark

- [Tarifs](https://postmarkapp.com/pricing)
- [Servers](https://postmarkapp.com/support/article/1137-servers-faq)
- [Message Streams](https://postmarkapp.com/support/article/how-to-create-and-send-through-message-streams)
- [Architecture multi-clients](https://postmarkapp.com/support/article/how-do-i-send-email-on-behalf-of-my-customers)
- [Permissions par Server](https://postmarkapp.com/support/article/1071-how-do-i-set-a-users-permissions)
- [Tests et Sandbox](https://postmarkapp.com/support/article/1213-best-practices-for-testing-your-emails-through-postmark)
- [Rétention des messages](https://postmarkapp.com/support/article/how-long-are-inbound-and-outbound-messages-stored-in-activity)

### SMTP2GO

- [Tarifs et fonctionnalités](https://www.smtp2go.com/pricing/)
- [Gestion des sous-comptes](https://support.smtp2go.com/hc/en-gb/articles/900004307303-Subaccount-Management)
- [Guide des fonctionnalités](https://support.smtp2go.com/hc/en-gb/articles/12747932085145-Quick-Start-Guide)
- [Fonctionnalités de l'API](https://developers.smtp2go.com/docs/api-features-guide)
- [Archivage](https://developers.smtp2go.com/reference/email-archive)
