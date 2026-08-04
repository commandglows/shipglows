# ShipGlows Pack Catalog

This catalog keeps the public experience simple: install one `shipglows` plugin,
then let ShipGlows route an outcome to one of thirteen métiers. Pack and numeric
engine names are packaging internals, not the default user vocabulary.

## Current Alpha

Bundled now:

- `shipglows`: public entrypoint, help, pack catalog, and packaging audit route
- `audit_shipglows_packaging.py`: local development audit for deciding which private skills are ready to package
- `reference-strategy.md`: local-vs-hosted documentation policy
- `docs-links.json`: optional hosted-docs link map for public documentation

Not bundled yet:

- the full private ShipGlows skill tree
- optional pack plugins
- hosted public documentation pages

Bundled staging helper:

- `scripts/stage_shipglows_pack.py`: stages one catalog pack into a local plugin candidate and writes a packaging report
- `scripts/refresh_shipglows_pack.py`: refreshes one staged pack and validates the generated plugin candidate

## Pack Model

## Public-to-Pack Map

| Public métier | Initial delivery pack | Numeric engine mapping (internal) |
| --- | --- | --- |
| `sg-development` | `shipglows-build` | `001-sg-build` with lifecycle engines |
| `sg-design` | `shipglows-design` | `006-sg-design` |
| `sg-experience` | `shipglows-product` | `008-sg-customer` |
| `sg-bug` | `shipglows-build` + `shipglows-proof` | `003-sg-bug` with proof engines |
| `sg-engineering` | `shipglows-quality` + `shipglows-product` | `010-sg-technical`, `600-602` |
| `sg-maintenance` | `shipglows-build` | `002-sg-maintain` |
| `sg-release` | `shipglows-proof` | `004-sg-deploy` with release engines |
| `sg-content` | `shipglows-content` | `007-sg-content` with editorial engines |
| `sg-marketing` | `shipglows-content` | `009-sg-marketing` |
| `sg-seo` | `shipglows-content` | `406-sg-seo` |
| `sg-docs` | `shipglows-governance` | `300-sg-docs` |
| `sg-planning` | `shipglows-product` | `011-sg-pilotage` |
| `sg-help` | `shipglows-main` | `302-sg-help` |
| `shipglows` | `shipglows-main` | `000-shipglows` |

The map is a packaging translation layer. It does not authorize a plugin to
advertise an engine as available before its pack is bundled and portable.

### `shipglows-main`

Purpose: first useful public experience.

Portability decision: not public-bundlable yet. See `references/shipglows-main-portability-matrix.md`.

Candidate skills:

- `000-shipglows`
- `302-sg-help`
- `100-sg-spec`
- `101-sg-ready`
- `102-sg-start`
- `103-sg-verify`
- `105-sg-check`
- `106-sg-fix`

Packaging status: partial. Public help and intent routing are bundled through `shipglows`; full execution parity still needs source-root dependency removal or complete-corpus setup.

### `shipglows-build`

Purpose: internal engines for `sg-development`, `sg-maintenance`, and part of `sg-bug`.

Candidate skills:

- `001-sg-build`
- `002-sg-maintain`
- `003-sg-bug`
- `005-sg-ship`
- `104-sg-end`
- `304-sg-changelog`

Packaging status: planned. High value, but likely needs reference-path cleanup.

### `shipglows-proof`

Purpose: internal proof engines for `sg-release` and `sg-bug`.

Candidate skills:

- `004-sg-deploy`
- `107-sg-test`
- `108-sg-browser`
- `109-sg-auth-debug`
- `405-sg-prod`

Packaging status: planned. Must be strict about operator-last-resort proof behavior.

### `shipglows-content`

Purpose: internal engines for `sg-content`, `sg-marketing`, and `sg-seo`.

Candidate skills:

- `007-sg-content`
- `009-sg-marketing`
- `200-sg-redact`
- `201-sg-enrich`
- `203-sg-research`
- `205-sg-veille`
- `406-sg-seo`

Packaging status: planned. Needs public/private data boundary review.

### `shipglows-design`

Purpose: internal engine for `sg-design`.

Candidate skills:

- `006-sg-design` (`system`, `playground`, `audit ui`, `audit tokens`, `audit components`, `audit a11y`)

Packaging status: planned. Good public candidate after validating mode playbooks and removing remaining source-root packaging assumptions.

### `shipglows-quality`

Purpose: internal engines for `sg-engineering`.

Candidate skills:

- `400-sg-audit`
- `010-sg-technical` (`audit`, `deps`, `performance`, `migrate`, `github`)
- `407-sg-translate` (`audit`, `sync`; `apply` is a `sync` alias)

Packaging status: planned. Needs careful command and network permission wording.

### `shipglows-governance`

Purpose: internal engines for `sg-docs` and maintainer-only workflow support.

Candidate skills:

- `300-sg-docs`
- `301-sg-context`
- `303-sg-resume`
- `305-sg-init`
- `306-sg-scaffold`
- `308-sg-status`
- `704-sg-model`
- `705-sg-conversation-audit`
- `706-continue`
- `707-name`
- `800-tmux-capture-conversation`
- `801-clean-conversation-transcript`

Packaging status: internal-first. Some parts may stay private because they govern ShipGlows itself.

### `shipglows-product`

Purpose: internal engines for `sg-experience`, `sg-engineering`, and `sg-planning`.

Candidate skills:

- `008-sg-customer`
- `600-sg-local-cloud-sync`
- `601-sg-product-entitlements`
- `602-sg-platform-parity`
- `700-sg-explore`
- `011-sg-pilotage` (`tasks`, `backlog`, `priorities`, `review`, `sessions`)

Packaging status: planned. Needs strong product-safety and paid-access boundary review.

## Installation Principle

The default user path is one install:

```text
Install ShipGlows
```

ShipGlows may later install or activate optional packs, but only after it can say exactly:

- why the pack is needed
- what will be installed
- whether a new Codex session is required
- what remains unavailable

Do not make the user choose among many technical plugins before they get value.

## Pack Generation

Stage one optional pack from the catalog:

```bash
python3 ~/plugins/shipglows/scripts/refresh_shipglows_pack.py shipglows-main
```

Default output:

```text
~/.shipglows/staged-packs/<pack-id>/
```

The generated directory is a local plugin candidate, not a public-ready promise. Review `shipglows-pack-report.json` before installing, sharing, or publishing it.
