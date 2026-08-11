---
artifact: veille_dispatch
project: shipglows_data
created: "2026-05-11"
updated: "2026-05-11"
status: dispatched
source_skill: sg-veille
scope: "dispatch des liens BetaList et outils vers les projets ShipGlows Data et serveur"
confidence: medium
---

# Dispatch veille — concurrents et inspirations — 2026-05-11

## Sources prises en compte

- Rapport source migré: `shipglows_data/workflow/research/beta-list-startup-portfolio-and-infra-research-2026-05-11.md`
- Projets: `~/shipglows_data/PROJECTS.md`, `~/shipglows_data/CLAUDE.md`, dossiers `~/shipglows_data/projects/*`
- Serveur: PM2 montre `contentflow_app` et `contentflow_lab` actifs.
- Correction canonique: `contentflow` est le projet canonique; `contentflowz` est à ignorer.
- Exclusion appliquée: Blacksmith, Flutter et Sentry ne sont pas dispatchés.
- Inclusion appliquée: `frp` est dispatché car il n'a pas été demandé de l'exclure.

## Vue rapide par projet

| Projet | Liens les plus pertinents | Lecture rapide |
|---|---|---|
| ContentFlow | Conscriba, AutoKap, Igloo, FlowSpeech, Browser7, BundleUp, Clamp, Spec27, Web-Analytics.ai | Projet canonique le plus concerné: concurrence/inspiration directe sur contenu, agents, reporting et distribution. |
| contentflow_app | Web-Analytics.ai, Conscriba, AutoKap, Airbin, Clamp | Surface applicative de ContentFlow: UX de reporting, preuves visuelles, analytics. |
| contentflow_lab | Browser7, Spec27, DataForSEO, BundleUp, frp | Backend/lab de ContentFlow: extraction, batch/live, validation agent, tunnels. |
| contentflowz | Aucun | Alias/dossier à ignorer; ne plus utiliser comme projet canonique. |
| GoCharbon | myGEOscore, Validue, Populous, VenturOS, Kurate, DataForSEO | Beaucoup de fiches outils et articles de méthode entrepreneuriale. |
| gocharbon_quiz | Validue, Populous, Web-Analytics.ai, myGEOscore | Amélioration scoring, sortie funnel et mesure conversion. |
| TubeFlow | FlowSpeech, Igloo, AutoKap, Kurate, TonimusAI, Spec27 | Audio, résumé vidéo, creator workflow, validation IA. |
| tubeflow_lab | FlowSpeech, Browser7, Spec27, frp, DataForSEO | Worker/transcription: audio, scraping, specs, tunnels. |
| ShipGlows | Spec27, frp, DiffHook, MemoryPlugin, Web-Analytics.ai, Airbin | Skills, validation, mémoire, monitoring, tunnels. |
| ShipGlows App | Airbin, Web-Analytics.ai, VenturOS, MemoryPlugin, Spec27 | Dashboard local, mémoire, pilotage et reporting. |
| PromptFlow | MemoryPlugin, Spec27, IntelCue, Conscriba, Impulse AI, Zedly AI | Mémoire IA, prompts fiables, MCP, agents. |
| SocialFlow | BundleUp, TonimusAI, Igloo, Photo Poodle, rembr, Web-Analytics.ai | Intégrations sociales, analytics créateur, contenu et CRM léger. |
| WinFlowz | VenturOS, Validue, Populous, IntelCue, MemoryPlugin, Spec27 | Formation/productivité/IA: modules et benchmarks. |
| Quit Coke site | Mindry, Vitality AI Health, rembr, Monthly Soup, Web-Analytics.ai, myGEOscore | Journaling, santé IA, communauté et SEO/GEO, avec forte prudence éthique. |
| NoCocaïne app | Mindry, Vitality AI Health, rembr, Betula, MemoryPlugin | App santé: inspiration UX, rappels, mémoire sensible. |
| PlaisirSurprise | Stamp'd, Photo Poodle, Monthly Soup, Web-Analytics.ai, rembr | Group booking, UGC événementiel, relances. |
| Nantes Gratuit | Photo Poodle, Stamp'd, myGEOscore, Web-Analytics.ai, Clamp | UGC local, sorties, analytics privacy-first. |
| ToolFlowz extension | Browser7, Conscriba, Clamp, MemoryPlugin, DiffHook | Extension navigateur, analyse pages, MCP, permissions. |
| Gamification | Mindry, Monthly Soup, rembr, Validue, Populous | Boucles de motivation, rituels, validation et feedback. |
| Dianedefores | VenturOS, Conscriba/myGEOscore/AutoKap, Web-Analytics.ai | Inspiration de positionnement portfolio, faible priorité. |
| Quickstore | Photo Poodle, Web-Analytics.ai, myGEOscore, rembr, Stamp'd, BundleUp, AutoKap | Site brocante de Katia: photos d'objets, SEO local, arrivages, suivi clients et analytics simples. |

## Questions ouvertes

- ContentFlow est canonique; `contentflow_site`, `contentflow_app` et `contentflow_lab` restent des vues spécialisées.
- `frp`: veux-tu un vrai benchmark technique contre ShipGlows/Caddy/DuckDNS, ou juste une note d'inspiration ?
