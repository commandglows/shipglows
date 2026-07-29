---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlowz
created: "2026-06-28"
updated: "2026-07-28"
status: reviewed
source_skill: 203-sg-research
scope: "checklist maître SEO technique"
owner: "ShipGlowz"
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
depends_on:
  - artifact: "shipglowz_data/workflow/research/charge-referencement-web-competences.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Le rapport de recherche met explicitement en avant une liste technique d'execution et des aptitudes de priorisation, synthese et collaboration."
next_step: "/007-sg-content repurpose <source> ou /300-sg-docs pour brancher cette checklist dans les chantiers SEO"
---

# Checklist maître — SEO technique

## Purpose

Checklist réutilisable pour contrôler la fondation SEO technique d’un projet, avant publication puis pendant son exploitation.

La stratégie éditoriale, la recherche de mots-clés, les clusters, les intentions de recherche et la création de contenu appartiennent à un autre projet et ne sont pas suivis ici.

## Applicability

Utiliser avant, pendant et apres:

- audit SEO technique;
- migration SEO;
- lancement de site;
- refonte;
- suivi technique récurrent;
- vérification après mise en production.

## Required Before Start

- site, environnement et surfaces indexables identifiés;
- accès ou exports disponibles notés : crawl, Search Console, logs, analytics;
- propriétaire technique identifié;
- domaine et pays/langues concernés déclarés;
- source de vérité pour les changements techniques définie.

## Checklist

### 1. Périmètre et environnement

- [ ] `technical-scope-environments` — Les environnements de production, préproduction et développement sont distingués.
- [ ] `technical-scope-indexable-surfaces` — Les surfaces et routes destinées à l’indexation sont déclarées.
- [ ] `technical-scope-non-public` — Les environnements non publics sont protégés contre l’indexation.

### 2. Crawl et indexation

- [ ] `technical-crawl-robots` — `robots.txt` est présent, valide et cohérent avec la stratégie d’accès.
- [ ] `technical-crawl-sitemaps` — Les sitemaps sont générés, accessibles et déclarés.
- [ ] `technical-crawl-directives` — Les directives `noindex`, `nofollow` et canonicals sont contrôlées.
- [ ] `technical-crawl-http` — Les pages importantes renvoient des codes HTTP corrects.
- [ ] `technical-crawl-errors-redirects` — Les erreurs 4xx/5xx, redirections et chaînes de redirections sont documentées.
- [ ] `technical-crawl-coverage` — La couverture d’indexation est vérifiée dans Search Console ou via un export équivalent.

### 3. URLs et architecture technique

- [ ] `technical-urls-canonicals` — Les URLs canoniques sont stables, cohérentes et absolues.
- [ ] `technical-urls-variants` — Les variantes de paramètres, trailing slash et protocoles sont maîtrisées.
- [ ] `technical-urls-link-reachability` — Le maillage technique permet d’atteindre les pages indexables.
- [ ] `technical-urls-orphans-depth` — Les pages orphelines et profondeurs de clic anormales sont identifiées.
- [ ] `technical-urls-migration-redirects` — Les migrations ou changements d’URL disposent d’un plan de redirection.

### 4. Rendu, balises et données structurées

- [ ] `technical-rendering-javascript` — Le rendu JavaScript expose le contenu et les liens nécessaires au crawl.
- [ ] `technical-rendering-metadata` — Les balises `title`, meta description et headings sont techniquement injectées sur les routes prévues.
- [ ] `technical-rendering-social-metadata` — Les balises Open Graph et autres métadonnées de partage sont cohérentes avec les routes.
- [ ] `technical-rendering-structured-data` — Les données structurées sont valides, justifiées et reliées aux bonnes entités.
- [ ] `technical-rendering-hreflang` — Les versions linguistiques et `hreflang` sont cohérentes lorsqu’elles existent.

### 5. Performance et signaux techniques

- [ ] `technical-performance-vitals` — Les Core Web Vitals et budgets de performance sont mesurés.
- [ ] `technical-performance-resources` — Les ressources bloquantes, images, polices et scripts excessifs sont identifiés.
- [ ] `technical-performance-mobile` — Le comportement mobile et responsive est contrôlé.
- [ ] `technical-performance-before-after` — Les changements de performance disposent d’une preuve avant/après.

### 6. Vérification et maintenance

- [ ] `technical-verification-access-gaps` — Les accès Search Console, analytics, crawl ou logs manquants sont notés comme limites.
- [ ] `technical-verification-priorities` — Les findings sont classés par gravité technique et effort.
- [ ] `technical-verification-evidence` — Chaque correction technique possède une preuve attendue et un plan de recontrôle.
- [ ] `technical-verification-post-deploy` — Une vérification post-déploiement est planifiée.
- [ ] `technical-verification-cycle-close` — Le cycle est clôturé seulement quand les preuves requises sont attachées.

## Completion Rule

Cette checklist est complete seulement quand:

- les contrôles techniques applicables sont exécutés ou explicitement marqués non applicables;
- les risques et limites de preuve sont documentés;
- les corrections techniques restantes sont référencées séparément dans le tracker adéquat;
- la vérification post-changement est définie;
- le résultat du cycle est archivé avant toute réinitialisation.

## Linked Playbook

- `shipglowz_data/workflow/playbooks/seo-charge-referencement-web-playbook.md`

## Exceptions

- Si le chantier est purement exploratoire, noter `incomplete by design`.
- Si la donnee manque, noter la preuve absente au lieu de forcer une conclusion.
