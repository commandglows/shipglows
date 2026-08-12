---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-28"
updated: "2026-08-12"
status: draft
source_skill: 300-sg-docs
scope: site-launch-playbook
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/README.md
  - shipglows_data/workflow/checklists/site-launch-checklist.md
  - skills/406-sg-seo/references/seo-audit-workflow.md
depends_on: []
supersedes: []
evidence:
  - "Legacy source recovered from /home/claude/site-launch-playbook.md on 2026-06-28."
  - "Legacy source recovered from /home/claude/site-launch-agent-checklist.md on 2026-06-28."
  - "Playbook normalized to keep the reusable method separate from project-specific execution notes."
  - "Wave 18 clarified that the playbook owns the launch method; its paired checklist depends on it, while this reverse relation remains provenance through linked_systems only."
next_review: "2026-07-05"
next_step: "/300-sg-docs migrate additional launch playbooks into workflow/playbooks"
---

# Site Launch Playbook

## Purpose

Launch a public site into Google Search Console with one coherent canonical origin, a valid sitemap, a valid robots file, and no accidental exposure of private or broken surfaces.

## Applicability

Use this playbook when a site is about to become indexable or when a production domain has changed enough that Search Console setup, canonical origin, sitemap, or crawlability must be revalidated.

Typical triggers:

- first production launch
- domain migration
- `www` vs non-`www` conflict
- staging-to-production cutover
- multilingual rollout
- SEO remediation before indexing

## Inputs

- domain root, for example `example.com`
- target canonical origin, for example `https://example.com` or `https://www.example.com`
- production URL that should be indexable
- current sitemap and robots implementation
- project stack and SEO config locations

## Execution Order

### 1. Choose One Canonical Origin

Decide the single canonical production origin before opening Search Console workflow details.

Rules:

- choose exactly one production truth
- keep `http` only as a redirect path
- keep only one of `www` or non-`www`
- align code, redirects, sitemap, robots, `llms.txt`, `hreflang`, `og:url`, and JSON-LD to that same origin

If the hosting platform already enforces a stable redirect, align the code to that reality unless there is an explicit reason to change the hosting setup first.

### 2. Verify Live Redirections

Test the four public variants:

- `https://<domain>/`
- `http://<domain>/`
- `https://www.<domain>/`
- `http://www.<domain>/`

Expected outcome:

- all variants converge to the same final canonical origin
- final page returns `200`
- no redirect loop
- no contradictory `www` / non-`www` behavior

If production ends in `500`, `404`, DNS failure, or the final origin differs from the declared canonical origin, the launch is blocked.

### 3. Verify Public SEO Files

Before any Search Console submission, confirm that these public files are reachable on the canonical origin:

- `robots.txt`
- `sitemap.xml`
- `llms.txt` when AI visibility is part of the launch standard

Required behavior:

- `robots.txt` returns `200`
- `sitemap.xml` returns `200`
- no private or non-production URLs appear in the sitemap
- `llms.txt` is coherent with the same canonical origin when present

### 4. Audit Canonicality In Rendered HTML

Sample the home page and a small set of representative pages:

- home
- one localized page if multilingual
- one category or hub page
- one detail page
- one guide/article
- one alternatives/comparison page
- one archived/discontinued page if the site uses them

For every sampled page:

- a canonical tag exists
- the canonical points directly to the chosen origin
- the canonical page returns `200`
- localized pages canonicalize to themselves, not to another locale
- `hreflang`, `og:url`, and schema URLs do not contradict the canonical

### 5. Register Or Verify Search Console Property

Preferred path:

- create a `Domain` property using the root domain only

Fallback path:

- create a URL-prefix property using the exact canonical origin

Do not treat old Search Console UI concepts such as historical canonical-domain toggles as blocking requirements. The runtime truth comes from redirects, canonical tags, sitemap, and URL inspection.

### 6. Submit Sitemap

Only submit the sitemap after production is stable.

Preconditions:

- site home returns `200`
- sitemap returns `200`
- sitemap is canonical-origin aligned
- no private routes are listed

Then:

- open Search Console `Sitemaps`
- submit the canonical sitemap URL
- record submission date and status

### 7. Inspect Priority URLs

Use URL Inspection on the highest-value pages:

- home
- 3 to 5 strategic pages

Check:

- Google can fetch the page
- page is indexable
- declared canonical is coherent
- Google-selected canonical is coherent when shown

### 8. Monitor Early Indexation

Review the first wave of Search Console coverage and exclusions:

- server errors
- soft 404
- blocked by robots
- excluded by `noindex`
- duplicate without correct canonical
- crawled or explored but not indexed

Separate:

- blockers to fix now
- expected exclusions
- warnings to monitor

## Decision Gates

### Ready

The launch is ready when:

- Search Console property is verified
- all domain variants converge to one canonical origin
- home returns `200`
- sitemap returns `200`
- robots returns `200`
- sampled pages expose coherent canonical signals
- sitemap submits without error
- at least 3 to 5 priority URLs have been inspected

### Blocked

Do not launch when any of these is true:

- production home returns `500`
- sitemap returns `500` or `404`
- code and hosting disagree on `www` vs non-`www`
- canonical points to a URL that still redirects elsewhere
- private or preview URLs are present in sitemap or public SEO files

## Outputs

- verified Search Console property
- submitted sitemap
- canonical-origin decision recorded
- initial URL inspection completed
- first-week monitoring plan created

## Linked Checklists

- [site-launch-checklist.md](/home/claude/shipglows/shipglows_data/workflow/checklists/site-launch-checklist.md)

## Common Risks

- treating Search Console as the source of canonical truth instead of production behavior
- submitting a sitemap before the site is stable
- mixing `www` and non-`www` across redirects, code, and sitemap
- leaking private routes into sitemap or `llms.txt`
- canonicalizing localized pages to the wrong locale

## Monitoring Cadence

- `J+1`: inspect 5 to 10 key URLs
- `J+3`: review indexation errors
- `J+7`: review impressions, discovered pages, excluded pages
- `J+14`: confirm canonical, sitemap, and robots behavior is stable

## Validation

```bash
python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/shipglows/shipglows_data/workflow/playbooks/site-launch-playbook.md
```
