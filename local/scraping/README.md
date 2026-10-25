# Recherche et scraping auto-hébergés

Stack Docker locale, écoutant uniquement sur `127.0.0.1`, pour éviter les appels payants à Firecrawl et Parallel.

| Service | URL | Utilisé par |
|---------|-----|-------------|
| SearXNG | `http://127.0.0.1:8888` | `shipglows-search` (premier fournisseur) |
| Crawl4AI | `http://127.0.0.1:11235` | `shipglows-fetch` (premier fournisseur), playground `/playground` |

## Commandes

```bash
shipglows-scraping up        # installe/démarre : token, conteneurs, attente de disponibilité
shipglows-scraping status    # Docker, conteneurs, santé des deux services (exit 1 si pas prêt)
shipglows-scraping logs crawl4ai
shipglows-scraping down      # arrête et supprime les conteneurs

shipglows-search "requête"                 # SearXNG → Firecrawl → Parallel
shipglows-fetch https://exemple.com/page   # HTTP simple → Crawl4AI → Firecrawl → Parallel, Markdown en JSON
```

`shipglows-fetch` lit d'abord chaque page en HTTP simple, sans navigateur (≈ 0,3 s par page, en parallèle), et convertit le HTML en Markdown. Seules les pages vides sans JavaScript, en erreur HTTP ou non-HTML passent au navigateur Crawl4AI, en un seul appel `/crawl`. Mesuré sur 6 sites : 6 s au lieu de 13 s, et ≈ 1 s au lieu de 4 à 6 s pour une page statique seule. Jusqu'à dix URL par appel. Options : `--query "..."` (ne garde que les passages pertinents, filtre BM25 ; objectif Parallel en secours), `--full` (page entière au lieu du contenu principal), `--max-chars` (40 000 par défaut, `0` = tout), `--provider`. Les bandeaux cookies et la navigation sont retirés ; une page en erreur HTTP ou détectée comme bloquée passe à Firecrawl. Exit 3 : une URL a échoué partout.

Pas de mode furtif ni de contournement anti-bot : les sites protégés passent par l'API Firecrawl.

## Nouvel ordinateur

1. Installer Docker Desktop (`winget install Docker.DockerDesktop`) et le lancer.
2. Lancer l'installeur ShipGlows : il crée les commandes et démarre la stack si Docker tourne. Sinon : `shipglows-scraping up`.

`up` crée une seule fois `local/scraping/.env` (ignoré par Git) avec le token Crawl4AI : sans token, Crawl4AI n'écoute que dans son conteneur. Les conteneurs ont `restart: unless-stopped` et redémarrent avec Docker Desktop.

## Réglages

- `SHIPGLOWS_SEARXNG_URL`, `SHIPGLOWS_CRAWL4AI_URL` : autre adresse ; `off` désactive le fournisseur local.
- `SHIPGLOWS_FETCH_HTTP=off` : désactive la lecture HTTP simple (tout passe par le navigateur).
- Un service arrêté ou une réponse vide passe au fournisseur suivant après une seule tentative. `--after-date` et `--location` sautent SearXNG.

## Limites

- Les moteurs amont de SearXNG (Google, Bing, DuckDuckGo…) peuvent limiter une IP qui interroge beaucoup : la cascade bascule alors sur Firecrawl.
- Crawl4AI n'a pas de proxies résidentiels : les sites très protégés restent pour l'API Firecrawl.
