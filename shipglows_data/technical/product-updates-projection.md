---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-23"
updated: "2026-11-23"
status: active
source_skill: 900-shipglows-core
scope: product-updates-projection
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/context_history.py
  - tools/product_updates.py
  - tools/test_product_updates.py
  - tools/test_context_history.py
  - skills/references/context-history-and-head.md
  - shipglows-app-engine/shared/updates
  - shipglows-app-engine/shared/roadmap
depends_on:
  - artifact: skills/references/context-history-and-head.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "2026-11-23: 13 unit tests (tools/test_product_updates.py) cover automatic projection on append, idempotence and human-edit protection, roadmap transitions with bidirectional links, shipped-without-proof refusal, stale events, pending and publish."
  - "2026-11-23: dry runs on temporary copies of the CommunityGlows and CommandGlows site content passed the real @shipglows/astro-roadmap and @shipglows/astro-updates Zod schemas and checkRoadmapCollection."
next_review: "2027-01-23"
next_step: none
---

# Product Updates And Roadmap Projection

Agents keep each product site's public updates ("Nouveautés", changelog) and
roadmap current as a side effect of recording their closure event. Agents only
write drafts and hidden items; the operator publishes after review.

## End-to-end flow

1. A product repository declares its sites in `.shipglows.product-updates.json`
   at the repository root (the Git worktree root where history events live).
2. At closure, ship or release, an agent records one significant event with
   `tools/context_history.py append`, including a `public` object (changelog
   copy, `public.roadmap`, or both).
3. `append` writes the immutable event, then projects it into every declared
   site and prints the report under `projection`. A projection failure never
   removes the event: the report shows `status: error` with the site error.
4. The operator runs `pending`, reviews the drafts, then `publish --id <id>`
   (repeatable) or `publish --all`. Committing and deploying the site stay
   ordinary, separately authorized steps.

## Configuration

```json
{
  "schema": "shipglows.product-updates/v1",
  "sites": [{ "root": "site", "products": ["commandglows"] }]
}
```

- `root`: site directory relative to the repository root; a sibling repository
  is allowed (`../commandglows/site`). It must declare `@shipglows/astro-updates`
  in `package.json` and its locales in `.shipglows.content.json`.
- `products`: 1 to 8 product keys written into `products` of each update entry
  (and of created roadmap items); the first one prefixes generated update ids.
  The site must accept these keys in its updates/roadmap configuration.
- At most 8 sites; unknown keys, absolute paths and missing directories are refused.
- Without the file, `append` reports `projection.status: not-configured` and
  writes nothing outside the history.

Wired on 2026-11-23: `commandglows` (`site`, `commandglows`) and
`communityglows` (`site`, `communityglows`).

## Event `public` object

| Shape | Rule |
| --- | --- |
| Changelog copy | `category`, bilingual `title`/`summary`, `delivery {state, proof}`, optional `link` (unchanged allowlist). |
| `roadmap` | 1 to 16 `{ id, status, title?, summary? }`; `status` in `considering`, `planned`, `in_progress`, `shipped`, `declined`; `title`/`summary` (`en`, `fr`, 120/300 characters) only to create a missing item. |
| Roadmap-only | `roadmap` without changelog copy; `delivery` optional. |
| `shipped` | Always requires `delivery` with proof; otherwise `append` fails closed and records nothing. |

CLI: `--roadmap <id>:<status>` (repeatable) next to the `--public-*` and
`--delivery-*` options, or `--public-file <json>` for the whole object
(creation copy included). `--no-project` skips the projection.

`shipglows_app/site/scripts/export-public-changelog.mjs` still validates the
v1 changelog-only allowlist; an event of the ShipGlows repository carrying
`roadmap` would be rejected by that exporter.

## What the projection writes

Updates (`src/content/updates/<locale>/<id>.md`, one per site locale among
`en`/`fr`): `status: draft`, `source: { producer: agent, ref: <event id> }`,
`relatedRoadmap: [...]` for the items this event ships in that locale. Ids are
`<first product>-<English title slug>`, suffixed with the event id on a foreign
collision. Existing files are never overwritten: `unchanged`, `skipped-edited`
or `already-projected` (renamed file still referencing the event).

Roadmap (`src/content/roadmap/<locale>/<id>.md`, only when the site declares
`@shipglows/astro-roadmap`), per locale:

| Action | Meaning |
| --- | --- |
| `status-changed` | One `{ from, to, date }` appended to `statusHistory`, `status` set, `updatedAt` raised when allowed by `createdAt`. |
| `unchanged` / `linked` | Already at that status; `linked` when only `shippedIn` was added. |
| `created` | Missing item with creation copy: `visibility: hidden`, `source.producer: agent`, one-entry history. |
| `missing` | Missing item without copy: nothing written. |
| `skipped-stale` | The item history has a later date, or already reached that status on that day (re-run or older event). |
| `skipped-inconsistent` | The last `statusHistory.to` differs from `status`: left for a human. |
| `skipped-unsupported-format` | Frontmatter shape the line editor refuses (inline `statusHistory` list, no frontmatter). |

On `shipped`, `shippedIn[]` of the item receives the update id of the same
locale and the update gets `relatedRoadmap[]`; `shippedIn` is only written when
the item ends `in_progress` or `shipped`. Agents never change the visibility of
an existing item, so a status change of a public item becomes visible at the
next deploy; `pending` flags such an item while its delivering update is still
a draft.

The frontmatter editor is line-based (standard library, top-level keys only):
it keeps the Markdown body, comments, quoting, CRLF and the existing flow or
block list style, and refuses shapes it cannot edit safely.

## Commands

```powershell
$t = "$env:SHIPGLOWS_ROOT\tools\context_history.py"   # or C:\Users\Diane\ShipGlows\shipglows\tools
python $t --project-root <repo> append --project <name> --kind CONTEXT_CHANGE --summary "..." `
  --public-category CHANGELOG_FEATURE --public-title-en "..." --public-title-fr "..." `
  --public-summary-en "..." --public-summary-fr "..." `
  --delivery-state DELIVERY_SHIPPED --delivery-proof "release 1.8.0" --roadmap focus-mode:shipped
python $t --project-root <repo> project --event-id evt_... [--dry-run]   # re-run for configured sites
python $t --project-root <repo> pending [--format text]
python $t --project-root <repo> publish --id <id> [--id <id>] [--kind update|roadmap] [--dry-run]
python $t --project-root <repo> publish --all [--dry-run]
python $t --project-root <repo> project-updates --site-root <site> --product <key> --event-id evt_...  # unconfigured site
```

`pending` lists, per site, draft updates (all producers), hidden roadmap items
and public items whose `shippedIn` update is a draft or missing. `publish`
validates the whole selection before writing (an unknown id writes nothing),
flips `status: draft` to `published` and `visibility: hidden` to `public` in
every locale, and warns when a published update links a still-hidden item.

Feedback triage (`tools/feedback_triage.py apply`, `product-feedback-triage.md`) creates
items through this projection with one `CONTEXT_DECISION` event; they stay hidden.

## Limits

- Only `en` and `fr` copy exists; other site locales are reported in `skippedLocales`.
- No automatic commit, push or deploy; the site's own build validates the
  content schema.
- The editor does not rewrite inline `statusHistory` lists or YAML anchors.

## Proof

- `python -m unittest tools.test_context_history tools.test_context_history_contract tools.test_product_updates`
- Before changing the editor or the roadmap rules, dry-run on a temporary copy
  of a real site's `src/content` and validate with the site's packages
  (`roadmapCollectionSchema`, `createUpdateSchemas(...).frontmatter`,
  `checkRoadmapCollection`); never against the real site content.
