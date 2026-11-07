---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-11-01"
updated: "2026-11-01"
status: active
source_skill: 900-shipglows-core
scope: content-tree-model
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/project-tree-model.md
  - skills/references/astro-site-playbook.md
  - skills/references/blog-and-cms-experience-contract.md
  - skills/references/editorial-content-corpus.md
  - shipglows-astro-engine
  - contentglows
  - shipglows_app
depends_on:
  - artifact: skills/references/project-tree-model.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-11-01: one content location and one taxonomy model on every site, so ContentGlows and shipglows_app read and write content without guessing."
  - "Operator decision 2026-11-01: evergreen content, so the collection is named articles, not blog."
  - "Operator decision 2026-11-01: flat files, structure carried by a taxonomy, URL /<pillar>/<slug>, graph view of articles in our software."
  - "Survey 2026-11-01 of 13 Astro sites: collections named blog, articles, guides, parcours or absent; locale as folder or as frontmatter; gocharbon keeps ~2,400 posts under src/data/ in up to 4 thematic folder levels with a frontmatter slug; claiire link paths rewritten by Obsidian (index.md -> Claiire/sante/.../index.md)."
  - "Google SEO Starter Guide (updated 2025-12-10): above a few thousand URLs, grouping topics in URL directories helps Google learn crawl frequency per directory; keywords in the URL path have hardly any ranking effect beyond breadcrumbs."
  - "Google breadcrumb structured data (updated 2026-09-08): breadcrumbs should represent a typical user path rather than mirror the URL."
  - "John Mueller (Google), reported by SEJ 2026-06-15 and patrickstox.com 2026-06-25: URL structure is a weak ranking factor, artificially flat URLs bring no benefit, URL stability is the real risk; internal linking is one of the biggest levers."
  - "Astro docs (content collections, content loader API): glob loader with generateId, reference() between collections, retainBody false for large collections; the Content Layer targets tens of thousands of entries."
  - "Astro 7.3.5 local check 2026-11-01: the default Sätteri Markdown processor parses [[wikilinks]] with features.wikilinks and accepts mdast plugins; contentglows/site migrated and served on the managed dev server (routes, 301s, hreflang, wikilinks, graph)."
next_review: "2027-02-01"
next_step: "Migrate the remaining sites of the Migration table onto @shipglows/astro-content."
---

# Content Tree Model

This reference is the single authority for where a site's editorial content lives, how it is classified, and how its URLs, breadcrumbs, links and graph are derived. `project-tree-model.md` fixes the `site/` folder; this file fixes what is inside it for content. Other references point here instead of restating it.

## Principles

- One location per fact. A file says where the article is stored; the frontmatter says what it is about; the taxonomy says where that subject sits. No fact is written twice.
- Files never move to reclassify. Reclassifying edits one field.
- URLs are stable. Only a change of pillar changes a URL, and that change always leaves a 301.
- Everything a tool needs is at a fixed path. ContentGlows, shipglows_app, Obsidian and the site read the same files.

## Layout

Paths are relative to the site root (`site/` in a multi-surface repository). They are fixed, not configurable.

```text
site/
  .shipglows.content.json          # content manifest (locales, URL policy)
  src/
    content.config.ts              # declares the articles collection and the taxonomy
    content/
      articles/
        <locale>/
          <slug>.md                # one article; the file name is its slug
      taxonomy.yaml                # the subject tree (pillars and sub-nodes)
      redirects.json               # every moved URL, kept forever
    assets/
      articles/<translationKey>/   # images of one article, shared by its locales
```

Rules:

- `articles/<locale>/` holds files directly. No subfolder below the locale folder.
- The file name is the slug: lowercase, hyphen-separated, ASCII, no date. It is unique within its locale, across articles and taxonomy node slugs.
- A file whose name starts with `_` is not loaded. Use it for templates or archived notes only; drafts use `draft: true`.
- A `hubFor` article is the one exception to slug uniqueness: its file name must equal the slug of its taxonomy node, and it renders at the hub URL, never as an article.
- The collection is named `articles` on every site, whatever the site calls it publicly ("guides", "encyclopédie", "ressources").
- Other structured collections (product documentation, skill catalogue, quiz paths) may exist in `src/content/<collection>/`. They are not editorial articles and never replace `articles/`. Legal and static pages stay in `src/pages/`.

## Taxonomy

`taxonomy.yaml` is the only place the subject hierarchy exists.

```yaml
- id: marketing                    # stable id, never translated, never reused
  labels:
    fr: { slug: marketing, title: Marketing, description: "..." }
    en: { slug: marketing, title: Marketing, description: "..." }
- id: seo
  parent: marketing
  labels:
    fr: { slug: seo, title: SEO, description: "..." }
    en: { slug: seo, title: SEO, description: "..." }
```

- A node without `parent` is a pillar. Depth is at most 4 levels, pillar included.
- Every node has a label for every site locale. A node is a real hub page: it needs a title and a useful description.
- No catch-all node (`autres`, `divers`, `misc`, `other`). An article that fits no node reveals a missing node or an off-topic article.
- Moving a branch edits one `parent`. Moving a branch to another pillar changes URLs and requires `redirects.json` entries (see URLs).

## Article Frontmatter

Required:

| Field | Meaning |
| --- | --- |
| `title` | page title |
| `description` | meta description and card summary |
| `topic` | id of one taxonomy node, the most specific one that fits |
| `translationKey` | identity shared by the locale peers of one article |
| `publishDate` | first publication, ISO date |

Optional:

| Field | Meaning |
| --- | --- |
| `updatedDate` | last substantive revision, ISO date; drives `lastmod` and the visible "updated" date |
| `tags` | cross-cutting labels; never a substitute for `topic` |
| `draft` | `true` hides the entry from every listing, sitemap, feed, graph and route |
| `hubFor` | taxonomy id; marks this article as the long-form introduction of that hub page |
| `image`, `imageAlt` | cover image from `src/assets/articles/<translationKey>/` |

Forbidden, because the path or the taxonomy already carries them: `slug`, `locale`, `category`, `categories`, `section`, `permalink`, `url`, `parent`, and date aliases (`date`, `pubDate`). The schema rejects them.

A project may add fields for its own domain (for example gocharbon's tool ratings), provided none of them encodes location, hierarchy or URL.

## URLs

- Article: `[/<locale>]/<pillar-slug>/<slug>`. The locale prefix follows the site's i18n policy declared in the manifest.
- Hub page of any taxonomy node: `[/<locale>]/<pillar-slug>` for a pillar, `[/<locale>]/<pillar-slug>/<node-slug>` below it.
- Exactly one directory level: the pillar. Sub-levels appear in breadcrumbs and hubs, never in article URLs. Reclassifying an article inside its pillar never changes its URL.
- Changing an article's pillar, renaming its file or moving a branch across pillars appends `{ "from", "to", "date" }` to `redirects.json`. JSON keeps it readable by `astro.config.mjs` and every tool without a parser dependency. The site turns that file into permanent redirects. Entries are never deleted.
- Tag pages, if any, are `noindex` unless they carry real editorial content.

## Breadcrumbs And Hubs

- Every article shows the full taxonomy path of its `topic`, from pillar to node, then the article. The same trail is emitted as `BreadcrumbList` JSON-LD.
- Every taxonomy node has a hub page listing its sub-nodes and its articles, sorted by `updatedDate` then `publishDate`. Its `hubFor` article, when present, is its introduction.

## Links And Graph

- Internal links between articles use wikilinks: `[[slug]]`, `[[slug|text]]`, `[[slug#heading]]`. They resolve within the same locale, to an article or a taxonomy node. They survive every reclassification because they never contain a path. `[[slug]]` without text displays the target title.
- Astro 7: enable `features.wikilinks` on the Sätteri processor (`@astrojs/markdown-satteri`) and resolve slugs with an mdast plugin; `[[...]]` inside code is never a link.
- Obsidian setting for a content vault: wikilinks on, new link format "shortest path when possible".
- A wikilink to a missing slug is an error on a published page, not a silent plain text. In a draft it is a warning.
- The site serves `/content-graph.json`, prerendered, without drafts:

```json
{
  "schema": "shipglows-content-graph/v1",
  "nodes": [{ "id": "fr/seo-local", "kind": "article", "locale": "fr", "title": "...", "topic": "seo", "url": "/marketing/seo-local" }],
  "edges": [{ "from": "fr/seo-local", "to": "fr/google-business-profile", "kind": "link" }]
}
```

  Node kinds: `article`, `topic`. Edge kinds: `link` (wikilink), `topic` (article to its node), `parent` (node to its parent), `translation` (locale peers). ContentGlows, shipglows_app and the site render the graph view from this one shape. A tool working on a repository computes the same shape from the files.

## Content Manifest

`site/.shipglows.content.json` declares what varies between sites. Paths are not in it, because they are fixed by this reference.

```json
{
  "schema": "shipglows-content/v1",
  "locales": ["fr", "en"],
  "defaultLocale": "fr",
  "prefixDefaultLocale": false,
  "trailingSlash": "never",
  "sourceLocale": "fr"
}
```

`trailingSlash` (`never` by default, or `always`) must equal the Astro `trailingSlash` setting of the site: the model appends the slash to every article, hub and wikilink URL it emits, so internal links never depend on a redirect.

A site without this file does not follow the model. Tools report it as non-conforming instead of guessing.

## Shared Implementation

The `taxonomy.yaml` loader, the wikilink resolvers, breadcrumb trails, `redirects.json` loading, the forbidden-field check and the graph live once in `@shipglows/astro-content` (`shipglows-astro-engine/packages/content`, see its README). Each site keeps its HTML, styling and Zod schema, wires `shipglowsContent()` and a wikilink plugin in `astro.config.mjs`, and reads the package by path (`tool/provide-engines.sh` clones the engine on Vercel and CI).

## Proof

Content changes follow the Content Proof section of `astro-site-playbook.md`: schema conformity, locale parity, editorial quality, no build. `shipglows stack scan -ProjectPath <site repo> -Checks` already verifies the manifest, the fixed paths, no subfolder under a locale, the locale folders, `taxonomy.yaml` and forbidden fields. The full check will also verify: fixed paths, no subfolder under a locale, unique slugs, forbidden fields absent, every `topic` and wikilink resolving, every locale label present, no catch-all node, and a redirect for every URL that disappeared.

## Migration

Move content with `git mv` into `articles/<locale>/`, derive `topic` from the old folder or category, remove forbidden fields, write `taxonomy.yaml`, convert internal links to wikilinks, and add a `redirects.json` entry for every published URL that changes. Commit one site at a time.

| Site | Observed 2026-11-01 | Main work |
| --- | --- | --- |
| `contentglows/site` | migrated 2026-11-01 (commit 1e6a1146) | reference implementation; rewrite `tests/blog-content.test.mjs` |
| `shipglows_app/site` | migrated 2026-11-01 (commit aadc50fe) | rename identity to `translationKey`, add taxonomy |
| `gocharbon/site` | ~2,400 posts in `src/data/`, 4 folder levels, frontmatter `slug` | flatten, folders become taxonomy, redirects for changed URLs |
| `claiire/site` | migrated 2026-11-01 (commit 55b091b) | two pillars, 26 sub-nodes, 286 articles, 1858 wikilinks, Obsidian vault kept outside the collection |
| `commandglows/site` | migrated 2026-11-02 (commit 0141e59e) | six pillars, EN/FR `translationKey` pairs, wikilinks, 50 redirects in `redirects.json`; unified processor kept with a wikilink mdast plugin instead of Sätteri; `trailingSlash` left at the Astro default |
| `communityglows/site` | migrated 2026-11-01 (commit e38ccd53) | six pillars, bilingual `translationKey` pairs, wikilinks, 64 redirects in `redirects.json` and `vercel.json` |
| `replayglows/site` | migrated 2026-11-01 (commit 501aa1fc) | reference for flat `blog/` sites: taxonomy with four pillars, wikilinks, `redirects.json` |
| `dreamglows/site` | migrated 2026-11-01 (commit b8a77d1) | four pillars, flat `articles/fr/`, 11 wikilinked articles, 11 redirects from `/guides/` |
| `beatglows`, `bestfriedchicken`, `dianedefores` sites | no articles yet | adopt the model when the first article ships |
| `notefinderz/site` | migrated 2026-11-06 (commit b900126) | 7 bilingual blog posts, two pillars, shared slugs across locales, 14 redirects from `/blog/<slug>`; app listings and category guides stay data-driven, not articles |
| `nococaine/site` (ex-`jarretelacoke`) | migrated 2026-11-06 (commit 92086c0) | five pillars, 165 articles, question clusters as sub-nodes, unified processor with a wikilink remark plugin; moved to the `nococaine` monorepo the same day |
