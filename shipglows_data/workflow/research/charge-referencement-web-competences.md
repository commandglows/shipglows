---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: reviewed
source_skill: 203-sg-research
scope: "fiche metier charge de referencement web - competences et aptitudes"
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
owner: ShipGlows
source_count: 10
depends_on: []
supersedes: []
evidence:
  - "Onisep - Charge / Chargee de referencement Web"
  - "France Travail - Referenceur / Referenceuse web"
  - "APEC - Charge de referencement web"
  - "CIDJ - Consultant / Consultante SEO"
  - "Choisir le service public - Chargee / Charge de referencement"
  - "Google Search Central - SEO Starter Guide"
  - "Google Search Central - Creating helpful, reliable, people-first content"
  - "Google Search Central - Robots.txt introduction"
  - "Google Search Central - Canonical URLs"
  - "Google Search Central - Structured data"
next_step: "/202-sg-repurpose transformer ce rapport en playbook ou checklist SEO agents"
---

# Research: Charge de referencement web - competences et aptitudes

> Genere le 2026-06-27 - Sources: 10

## Executive Summary

Les fiches metier institutionnelles convergent sur le coeur du role: analyser la visibilite d'un site, definir une strategie SEO, optimiser la structure technique et editoriale, suivre la performance et ajuster les actions. Les documents Google Search Central permettent de traduire cette fiche metier en competences d'execution beaucoup plus techniques que les formulations RH habituelles.

Pour des agents, il faut modeler ce metier comme une combinaison de 4 familles: diagnostic SEO, implementation technique, pilotage editorial base sur l'intention de recherche, et instrumentation analytique. A cela s'ajoutent des aptitudes de rigueur, priorisation, synthese, et coordination transverse.

## Ce que disent les fiches metier

Baseline commune observee dans les fiches Onisep, France Travail, APEC, CIDJ et Service Public:

- realiser des audits SEO
- analyser les mots-cles et la concurrence
- optimiser les contenus et la structure des pages
- ameliorer la visibilite organique
- suivre les indicateurs de trafic et de positionnement
- recommander puis piloter des actions correctives
- travailler avec redaction, marketing, produit et developpement

## Liste technique des competences requises

La liste ci-dessous est volontairement orientee execution. Les blocs `A` a `F` sont directement alignes avec les fiches metier et la documentation Google. Les blocs `G` a `J` sont une extension operationnelle raisonnable pour un profil SEO actuel, deduite des standards Google et des pratiques d'outillage modernes.

### A. Diagnostic SEO et audit

- savoir auditer l'indexabilite d'un site
- verifier les statuts HTTP, redirections, boucles, chaines et pages orphelines
- detecter les blocages `robots.txt`, `noindex`, `nofollow`, `x-robots-tag`
- controler la coherence des URLs canoniques
- identifier les duplications de contenu, duplications de templates, facettes et parametrages d'URL
- cartographier l'arborescence, la profondeur de clic et le maillage interne
- auditer les titles, meta descriptions, H1-Hn, breadcrumbs, alt images, ancres et pagination
- evaluer les sitemaps XML: couverture, fraicheur, segmentation, erreurs
- reperer les problemes de rendu JavaScript qui empechent le crawl ou l'indexation
- lire et interpreter un crawl d'outil type Screaming Frog, Sitebulb ou equivalent
- auditer la compatibilite mobile et les signaux de page experience
- detecter les regressions SEO post-mise en production

### B. Acquisition semantique et recherche d'intention

- conduire une recherche de mots-cles par theme, intention, volume et difficulte
- distinguer les intentions `informationnelle`, `navigationnelle`, `commerciale`, `transactionnelle`
- construire des clusters semantiques et des cartes d'intention
- faire une analyse de SERP: formats presents, concurrents, type de contenu, enrichissements
- reperer les gaps semantiques entre le site et les concurrents
- prioriser les sujets selon potentiel business, faisabilite et autorite du domaine
- mapper une requete vers la bonne page cible pour eviter la cannibalisation
- identifier les opportunites longues traines, questions, entites et variantes lexicales

### C. Optimisation on-page

- concevoir ou corriger des balises `title` et meta descriptions utiles au CTR
- structurer une page avec H1, H2, H3 coherents avec l'intention
- optimiser le texte pour la couverture semantique sans bourrage de mots-cles
- aligner slug, title, H1, intro, sections et liens internes
- optimiser les medias: nommage, poids, texte alternatif, contexte editorial
- definir des regles de maillage interne: hub, silo, cocon, pages piliers, liens contextuels
- gerer la cannibalisation entre pages proches
- optimiser les pages categories, fiches produits, articles, landing pages et FAQ
- evaluer le potentiel de rich results et adapter le contenu en consequence

### D. SEO technique

- comprendre HTML, balisage semantique et structure DOM
- comprendre le role des en-tetes HTTP, codes de reponse, cache et redirections
- manipuler `robots.txt`, sitemaps XML, canonicals, hreflang, directives d'indexation
- verifier la bonne exposition des contenus aux robots en environnement SSR, SSG ou SPA
- comprendre les impacts SEO de JavaScript, hydration, lazy loading et infinite scroll
- controler les migrations de site: changements d'URL, domaine, protocole, CMS, templates
- suivre les erreurs de crawl, d'indexation et de couverture
- valider ou corriger le schema markup via JSON-LD ou microdata selon le cas
- gerer les versions multilingues ou multi-pays avec `hreflang`
- collaborer avec les developpeurs sur Core Web Vitals et performance percue

### E. Donnees structurees et search appearance

- savoir quels schemas sont utiles selon la typologie de page
- implementer ou specifier `Article`, `Breadcrumb`, `FAQ`, `Organization`, `Product`, `LocalBusiness`, etc.
- verifier la conformite du balisage et son alignement avec le contenu visible
- comprendre comment les rich results influencent l'apparence dans les resultats
- surveiller les regressions de donnees structurees apres releases ou refontes

### F. Mesure, reporting et experimentation

- utiliser Google Search Console pour lire impressions, clics, CTR, positions et couverture
- croiser Search Console avec GA4 pour distinguer visibilite, trafic et conversion
- suivre les pages qui gagnent, stagnent ou perdent
- construire un reporting par segment: repertoire, template, cluster, pays, device, brand/non-brand
- definir des KPIs SEO relies au business: trafic qualifie, leads, CA, conversions assistees
- prioriser les actions selon impact attendu et effort
- isoler les causes d'une chute SEO: update Google, dette technique, contenu, concurrence, migration
- documenter hypotheses, tests, resultats et actions correctives

### G. Strategie de contenu SEO

- produire ou encadrer des briefs de contenu exploitables
- definir la page cible, l'intention, le plan, les preuves, les liens internes et les CTA
- evaluer la qualite "helpful content" d'une page
- distinguer contenu utile, contenu redondant et contenu cree uniquement pour capter du trafic
- orchestrer creation, refresh, fusion, suppression ou redirection de contenus
- faire converger SEO, UX, conversion et branding

### H. Autorite, popularite et off-page

- comprendre les principes du netlinking et de l'evaluation d'un profil de liens
- identifier backlinks utiles, toxiques ou sans valeur
- analyser ancres, domaines referents, pages d'atterrissage et rythme d'acquisition
- definir des campagnes d'acquisition de liens, digital PR ou partenariats
- mesurer l'impact de la popularite sur des clusters ou pages cibles

### I. Outils et stack de travail

- Search Console
- GA4
- Google Trends
- crawlers type Screaming Frog / Sitebulb
- suites SEO type Ahrefs / Semrush / Sistrix / SE Ranking
- logs serveur ou exports crawl quand disponibles
- CMS et editeurs structurants type WordPress, Shopify, Webflow, headless CMS
- tableurs, SQL leger ou outils BI pour segmenter les donnees
- validateurs de schema et outils Lighthouse / PageSpeed pour la partie technique

### J. Competences agents-ready utiles en 2026

Ces competences sont une inference de pratique actuelle, pas une etiquette toujours explicite dans les fiches metier:

- transformer un audit en backlog actionnable par severite, dependance et ROI
- ecrire des prompts ou consignes robustes pour des agents de redaction, de crawl ou d'analyse
- distinguer ce qui releve d'un correctif technique, editorial, produit ou analytics
- preparer des checklists de mise en ligne SEO et de migration SEO
- raisonner en surfaces de recherche, pas seulement en liens bleus: snippets, rich results, packs locaux, resultats IA, etc.
- verifier l'eligibilite documentaire d'un contenu pour les moteurs et les experiences de recherche generees

## Aptitudes et comportements necessaires

## 1. Rigueur analytique

- savoir partir de donnees imparfaites sans surinterpreter
- verifier les hypotheses avant d'attribuer une cause
- distinguer correlation et causalite
- documenter les limites de preuve

## 2. Sens de la priorisation

- traiter d'abord ce qui bloque crawl, indexation ou conversion
- arbitrer entre quick wins et chantiers structurels
- raisonner impact business avant volume de taches

## 3. Pensee systemique

- comprendre qu'un probleme SEO peut venir du code, du contenu, du design, du CMS, du tracking ou du business model
- raisonner a l'echelle du site et non page par page uniquement

## 4. Capacite de synthese

- convertir un audit volumineux en recommandations nettes
- produire des tickets exploitables pour dev, contenu, design et marketing
- adapter le niveau de detail selon l'interlocuteur

## 5. Discipline documentaire

- tenir des hypotheses, preuves, actions, statuts et resultats
- garder une trace des changements SEO deployes
- savoir revenir sur une decision a partir des preuves

## 6. Collaboration transverse

- travailler avec developpeurs sur technique et performance
- travailler avec redacteurs sur intention, structure et utilite
- travailler avec acquisition, marque et produit sur priorites et promesse

## Modele compact pour tes agents

Si tu veux un schema directement exploitable par des agents, le plus utile est:

- `competences-techniques`
  - audit-technique-seo
  - recherche-mots-cles-et-intentions
  - optimisation-on-page
  - architecture-information-et-maillage
  - indexation-crawl-rendering
  - donnees-structurees
  - mesure-search-console-ga4
  - strategie-contenu-seo
  - netlinking-et-autorite
  - reporting-priorisation-backlog
- `aptitudes`
  - rigueur-analytique
  - priorisation
  - esprit-systemique
  - capacite-de-synthese
  - discipline-documentaire
  - collaboration-transverse

## Recommandation

Pour de futurs agents, ne modele pas "charge de referencement web" comme un seul role abstrait. Decoupe plutot le role en 4 sous-specialites operatoires:

- `seo-audit-analyst`
- `seo-technical-implementer`
- `seo-content-strategist`
- `seo-performance-reporter`

Cette decomposition colle mieux a la realite du travail et permet d'affecter des checklists et playbooks plus precis.

## Sources

- [Onisep - Charge / Chargee de referencement Web](https://www.onisep.fr/ressources/univers-metier/metiers/charge-chargee-de-referencement-web) - fiche metier institutionnelle avec missions et competences requises.
- [France Travail - Referenceur / Referenceuse web](https://candidat.francetravail.fr/metierscope/fiche-metier/E1405/referenceur-referenceuse-web) - cadre emploi/competences attendu sur le marche francais.
- [APEC - Charge de referencement web](https://www.apec.fr/tous-nos-metiers/commercial-marketing/charge-de-referencement-web.html) - fiche metier cadre avec dimensions de formation et attendus professionnels.
- [CIDJ - Consultant / Consultante SEO](https://www.cidj.com/s-orienter/metiers/consultant-consultante-seo) - fiche orientation recente sur les missions SEO.
- [Choisir le service public - Chargee / Charge de referencement](https://choisirleservicepublic.gouv.fr/metiers/numerique/chargee-charge-de-referencement/) - formulation publique des missions, audits et strategie.
- [Google Search Central - SEO Starter Guide](https://developers.google.com/search/docs/fundamentals/seo-starter-guide) - socle officiel des domaines techniques SEO.
- [Google Search Central - Creating helpful, reliable, people-first content](https://developers.google.com/search/docs/fundamentals/creating-helpful-content) - cadre officiel pour l'evaluation du contenu utile.
- [Google Search Central - Robots.txt Introduction](https://developers.google.com/search/docs/crawling-indexing/robots/intro) - reference officielle sur les controles de crawl.
- [Google Search Central - Canonical URLs](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls) - reference officielle sur la canonicalisation.
- [Google Search Central - Structured Data](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data) - reference officielle sur les donnees structurees et l'apparence dans la recherche.
