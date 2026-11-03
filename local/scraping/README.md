# Recherche et scraping auto-hébergés

Stack Docker locale, écoutant uniquement sur `127.0.0.1`, pour éviter les appels payants à Firecrawl et Parallel.

| Service | URL | Utilisé par |
|---------|-----|-------------|
| SearXNG | `http://127.0.0.1:8888` | `shipglows-search` (premier fournisseur) |
| Crawl4AI | `http://127.0.0.1:11235` | `shipglows-fetch`, pour les pages que le HTTP simple ne lit pas ; playground `/playground` |

## Commandes

```bash
shipglows-scraping up        # installe/démarre : Docker Desktop si arrêté, token, conteneurs, attente de disponibilité
shipglows-scraping status    # Docker, conteneurs, santé des deux services (exit 1 si pas prêt)
shipglows-scraping logs crawl4ai
shipglows-scraping down      # arrête et supprime les conteneurs

shipglows-search "requête"                 # SearXNG → DeepSeek → Firecrawl → Parallel
shipglows-fetch https://exemple.com/page   # HTTP simple → agent-browser → Crawl4AI → DeepSeek → Firecrawl → Parallel, Markdown en JSON
shipglows-browse open https://exemple.com  # navigateur pilotable (agent-browser) avec garde-fous : snapshot, click, fill, screenshot…
```

`shipglows-fetch` lit d'abord chaque page en HTTP simple, sans navigateur (≈ 0,3 s par page, en parallèle), et convertit le HTML en Markdown. Une vidéo YouTube est lue depuis les données du lecteur intégrées au HTML (titre, chaîne, date, durée, description), sans navigateur ; la transcription n'y est pas. Seules les pages vides sans JavaScript, en erreur HTTP ou non-HTML passent au navigateur : d'abord agent-browser (Chrome for Testing, sans Docker, une session jetable par page, 3 en parallèle, ignoré si la CLI est absente ou si `SHIPGLOWS_FETCH_BROWSER=off`), puis Crawl4AI pour ce qui reste, en un seul appel `/crawl`. Mesuré sur 6 sites : 6 s au lieu de 13 s, et ≈ 1 s au lieu de 4 à 6 s pour une page statique seule. Jusqu'à dix URL par appel. Options : `--query "..."` (ne garde que les passages pertinents : filtre par mots en HTTP, BM25 dans Crawl4AI, objectif Parallel en secours), `--full` (page entière au lieu du contenu principal), `--max-chars` (40 000 par défaut, `0` = tout), `--provider`. Les bandeaux cookies et la navigation sont retirés ; une page en erreur HTTP ou détectée comme bloquée passe à Firecrawl. Exit 3 : une URL a échoué partout.

Pas de mode furtif ni de contournement anti-bot : les sites protégés passent par l'API Firecrawl.

## agent-browser

`npm i -g agent-browser && agent-browser install` (Chrome for Testing, ~200 Mo) ; sans lui, `shipglows-fetch` saute ce palier. `shipglows-browse` transmet tout à `agent-browser` avec : session `shipglows` jetable (ou `--session`), `AGENT_BROWSER_CONTENT_BOUNDARIES=1`, `AGENT_BROWSER_MAX_OUTPUT=50000`. `--profile`, `--auto-connect`, `--cdp` et `--state` (navigateur personnel) sont refusés sauf `SHIPGLOWS_BROWSE_ALLOW_PERSONAL=1`. Identifiants : coffre `agent-browser auth save|login`, jamais dans un prompt. Les extensions se testent avec `s extension-lab`.

## Nouvel ordinateur

1. Installer Docker Desktop (`winget install Docker.DockerDesktop`) et le lancer.
2. Lancer l'installeur ShipGlows : il crée les commandes et démarre la stack si Docker tourne. Sinon : `shipglows-scraping up`.

`up` crée une seule fois `local/scraping/.env` (ignoré par Git) avec le token Crawl4AI : sans token, Crawl4AI n'écoute que dans son conteneur. Les conteneurs ont `restart: unless-stopped` et redémarrent avec Docker Desktop.

## Réglages

- `SHIPGLOWS_SEARXNG_URL`, `SHIPGLOWS_CRAWL4AI_URL` : autre adresse ; `off` désactive le fournisseur local.
- Stack injoignable : `shipglows-search`/`shipglows-fetch` la relancent en arrière-plan (Docker Desktop compris) et passent au fournisseur suivant pour la requête en cours. `SHIPGLOWS_SCRAPING_AUTOSTART=off` désactive ce redémarrage.
- `SHIPGLOWS_FETCH_HTTP=off` : désactive la lecture HTTP simple (tout passe par le navigateur).
- Un service arrêté ou une réponse vide passe au fournisseur suivant après une seule tentative. `--after-date` et `--location` sautent SearXNG.

## Limites

- Les moteurs amont de SearXNG (Google, Bing, DuckDuckGo…) peuvent limiter une IP qui interroge beaucoup : la cascade bascule alors sur Firecrawl.
- Crawl4AI n'a pas de proxies résidentiels : les sites très protégés restent pour l'API Firecrawl.
