# ShipGlows Pack Catalog

This catalog keeps the public experience simple: install one `shipglows` plugin, then let ShipGlows route to bundled or optional capabilities.

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

Purpose: implementation lifecycle from request to shippable change.

Candidate skills:

- `001-sg-build`
- `002-sg-maintain`
- `003-sg-bug`
- `005-sg-ship`
- `104-sg-end`
- `304-sg-changelog`

Packaging status: planned. High value, but likely needs reference-path cleanup.

### `shipglows-proof`

Purpose: browser, production, deploy, auth, and manual QA proof.

Candidate skills:

- `004-sg-deploy`
- `107-sg-test`
- `108-sg-browser`
- `109-sg-auth-debug`
- `405-sg-prod`

Packaging status: planned. Must be strict about operator-last-resort proof behavior.

### `shipglows-content`

Purpose: content, research, SEO, copy, GTM, and editorial workflows.

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

Purpose: UI, UX, design systems, tokens, accessibility, and component audits.

Candidate skills:

- `006-sg-design` (`system`, `playground`, `audit ui`, `audit tokens`, `audit components`, `audit a11y`)

Packaging status: planned. Good public candidate after validating mode playbooks and removing remaining source-root packaging assumptions.

### `shipglows-quality`

Purpose: broad audits, unified technical posture, and translation quality.

Candidate skills:

- `400-sg-audit`
- `010-sg-technical` (`audit`, `deps`, `performance`, `migrate`, `github`)
- `407-sg-translate` (`audit`, `sync`; `apply` is a `sync` alias)

Packaging status: planned. Needs careful command and network permission wording.

### `shipglows-governance`

Purpose: ShipGlows's own docs, skills, conversations, transcripts, status, and model routing.

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

Purpose: onboarding, sync, entitlements, platform parity, exploration, and explicit work/session pilotage.

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
