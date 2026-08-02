---
artifact: veille_concurrents_inspirations
project: contentflow_lab
created: "2026-05-11"
updated: "2026-05-11"
status: reviewed
source_skill: sg-veille
scope: "veille pour processus serveur PM2 contentflow_lab"
confidence: medium
---

# Concurrents et inspirations — contentflow_lab

## Lecture projet

`contentflow_lab` est actif sur PM2. Je le traite comme laboratoire/backend de ContentFlow: pipelines, données, agents, sources et expérimentation. La veille canonique est dans `~/shipglows_data/projects/contentflow/concurrent.md`.

## Liens prioritaires

| Lien | Type | Score | Usage concret |
|---|---:|:---:|---|
| [Browser7](https://betalist.com/startups/browser7) | Inspiration extraction | 8/10 | Scraping JS/proxy/captcha: utile pour un lab de collecte et enrichissement de sources. |
| [Spec27](https://betalist.com/startups/spec27) | Inspiration validation agent | 8/10 | Très bon modèle pour tester les pipelines IA du lab avec specs et fixtures. |
| [DataForSEO Live vs Standard](https://dataforseo.com/help-center/live-vs-standard-method/amp) | Pattern API | 7/10 | Cadre live vs batch pour jobs coûteux/lents. Article ancien, à compléter avec docs actuelles. |
| [BundleUp](https://betalist.com/startups/bundleup) | Inspiration intégrations | 6/10 | API unifiée: utile si le lab connecte plusieurs fournisseurs de données. |
| [frp](https://github.com/fatedier/frp) | Infrastructure tunnel | 6/10 | Peut aider à exposer temporairement un service lab derrière NAT, mais seulement après comparaison avec ShipGlows/Caddy. |

## Prudence

- Les sources scraping/API doivent être classées par niveau de permission, coût, latence et risque légal.
