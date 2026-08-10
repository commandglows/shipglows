# 406-sg-seo

> Find the technical, content, and AI-search issues that limit discoverability and search trust.

## What It Does

`406-sg-seo` reviews a single page or full site for technical SEO, on-page structure, metadata quality, internal linking, performance signals, and AI-era visibility such as `llms.txt`, schema, and crawler rules.

It does not only ask whether the page can rank. It also checks whether search traffic would land on a truthful, current promise.

## Who It's For

- Solo founders who depend on organic traffic
- Content-led SaaS operators maintaining public sites
- Teams that want one audit spanning classic SEO and AEO/GEO readiness

## When To Use It

- when a page is underperforming in search
- when you have shipped content or metadata changes and want a review
- when you want to verify sitemap, canonical, structured data, and AI crawler posture

## What You Give It

- a page path, a project directory, or `global`
- optional business context that clarifies target audience and search intent
- optional Google Search Console property and date range for live monitoring

## What You Get Back

- a scored SEO review with concrete issues and likely impact
- visibility into outdated claims, wrong-intent pages, and technical gaps
- clear next steps for metadata, content structure, internal links, and crawlability

## Typical Examples

```bash
/406-sg-seo
/406-sg-seo src/pages/blog/ai-audit.astro
/406-sg-seo global
```

## Limits

This skill audits the codebase and visible content. In monitoring mode it can fetch read-only Google Search Console evidence through the ShipGlows GSC CLI when a local OAuth profile is already authorized. It does not launch OAuth consent automatically, fetch backlink profiles, or claim live ranking positions; supplied exports remain the fallback when GSC access is unavailable.

## Related Skills

- `009-sg-marketing copy` for language quality on indexed pages
- `201-sg-enrich` to upgrade content with fresher evidence
- `400-sg-audit` for a broader multi-domain release review
