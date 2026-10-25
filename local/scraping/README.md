# Recherche et scraping auto-hébergés

Stack Docker locale, écoutant uniquement sur `127.0.0.1`, pour éviter les appels payants à Firecrawl et Parallel.

| Service | URL | Rôle |
|---------|-----|------|
| SearXNG | `http://127.0.0.1:8888` | Premier fournisseur de `shipglows-search` (API JSON) |
| Crawl4AI | `http://127.0.0.1:11235` | Rendu navigateur d'une page en Markdown (`/crawl`, `/md`, playground `/playground`) |

## Démarrer / arrêter

Crawl4AI exige un token, sinon il n'écoute que dans son conteneur. Il vit dans `local/scraping/.env` (ignoré par Git) ; à créer une fois :

```bash
printf 'CRAWL4AI_API_TOKEN=%s\n' "$(python -c 'import secrets;print(secrets.token_hex(32))')" > local/scraping/.env
```

Les appels passent `Authorization: Bearer <token>`.

```bash
docker compose -f local/scraping/docker-compose.yml up -d
docker compose -f local/scraping/docker-compose.yml down
```

Les conteneurs ont `restart: unless-stopped` : ils redémarrent avec Docker Desktop.

## Cascade

`shipglows-search` essaie SearXNG, puis Firecrawl, puis Parallel. Un service arrêté, une réponse vide, `--after-date` ou `--location` passent au fournisseur suivant après une seule tentative. `SHIPGLOWS_SEARXNG_URL` change l'adresse ; `off` désactive SearXNG.

## Limites

- Les moteurs amont de SearXNG (Google, Bing, DuckDuckGo…) peuvent limiter une IP qui interroge beaucoup : la cascade bascule alors sur Firecrawl.
- Crawl4AI n'a pas de proxies résidentiels : les sites très protégés restent pour l'API Firecrawl.
