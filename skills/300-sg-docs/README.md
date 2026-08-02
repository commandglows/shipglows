# 300-sg-docs

> Generate, audit, and align project documentation so the docs keep up with the product instead of drifting behind it.

## What It Does

`300-sg-docs` handles documentation as an active product surface. It can bootstrap governance for a new repository, generate a project README, document APIs or components, add inline code documentation, audit existing docs for drift, and update ShipGlows decision artifacts with the right metadata.

For empty or near-empty repositories, `init` should produce a stable governance starter set rather than a generic product README.

For solo founders, this matters because stale docs cost time twice: once when you forget how the system works, and again when users, teammates, or future-you follow instructions that are no longer true.

## Who It's For

- Solo founders maintaining product and technical docs alone
- Developers onboarding themselves back into an older project
- Teams that need docs to stay aligned with behavior, setup, and architecture

## When To Use It

- when a README no longer reflects the actual project
- when APIs or components need human-readable documentation
- when internal docs feel fragmented or inconsistent
- when ShipGlows artifacts need metadata migration or cleanup
- when a new repository needs an initial documentation and governance scaffold

## What You Give It

- the current project directory
- a mode such as `init`, `readme`, `api`, `components`, `audit`, or `update`
- optionally a specific file path

## What You Get Back

- generated or updated documentation
- a documentation audit with concrete drift risks
- metadata-aligned ShipGlows artifacts where relevant
- clearer next steps when docs are too incomplete to trust

## Typical Examples

```bash
/300-sg-docs readme
/300-sg-docs api
/300-sg-docs components
/300-sg-docs audit
/300-sg-docs init
/300-sg-docs src/lib/pricing.ts
```

## Limits

`300-sg-docs` documents what the code and proven context support. It should not invent features, guarantees, or business claims that are not backed by the repo or explicit context.

## Related Skills

- `305-sg-init` to create the first project context docs
- `305-sg-init` for broader project bootstrap beyond documentation ownership
- `201-sg-enrich` for public-facing content improvements
- `104-sg-end` when implementation changed user-facing behavior and docs were updated
