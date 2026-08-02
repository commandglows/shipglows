# 400-sg-audit

> Run a coordinated multi-domain audit and get one prioritized view of product risk.

## What It Does

`400-sg-audit` is the master audit entrypoint. It orchestrates the specialist audits across code, design, copy, SEO, go-to-market, translation, dependencies, and performance, then consolidates the results into one report.

The goal is not to produce isolated checklists. It is to answer a harder question: does the product still hold together for the promised user journey?

## Who It's For

- Solo founders preparing a launch, relaunch, or major update
- Product owners maintaining several ShipGlows projects
- Teams that want one decision-ready audit instead of eight disconnected reviews

## When To Use It

- when you want a full project health check before shipping
- when a feature changed and you need to assess downstream impact across surfaces
- when you are at the workspace root and want to compare several projects

## What You Give It

- a project directory, a single file path, or `global`
- optional clarification on which domains matter most
- existing project context if the repo has `CLAUDE.md`, business docs, or brand docs

## What You Get Back

- a combined audit report with domain scores and severity-ranked findings
- proof gaps called out explicitly when context is missing or stale
- next-step recommendations on what to fix first

## Typical Examples

```bash
/400-sg-audit
/400-sg-audit src/pages/pricing.astro
/400-sg-audit global
```

## Limits

This skill is an orchestrator. It launches the relevant audits and synthesizes the outcome, but it is not the best tool when you already know you only need one domain-specific review.

## Related Skills

- `010-sg-technical audit` for a code-first review
- `406-sg-seo` for search visibility and metadata issues
- `103-sg-verify` for a final readiness pass after fixes
