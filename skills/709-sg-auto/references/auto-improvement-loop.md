---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-21"
updated: "2026-10-21"
status: active
source_skill: 709-sg-auto
scope: autonomous-business-improvement
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/709-sg-auto/SKILL.md
  - skills/708-sg-blitz/references/blitz-session-coordination.md
  - skills/references/mutation-auto-authority.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-10-21: auto is a fully autonomous mode that keeps improving the business and its products across every facet, with no time or credit pressure, full tool use including lint and tests, and questions only when truly blocked."
next_review: "2026-11-21"
next_step: none
---

# Auto Improvement Loop

## Facets

Treat the business as a whole. Rotate attention across these facets and their
métier owners so no dimension is neglected for long:

| Facet | Typical owner |
|---|---|
| Product features and roadmap | `sg-development`, `sg-planning` |
| Defects and reliability | `sg-bug` |
| Architecture, code quality, dependencies, performance | `sg-engineering`, `sg-maintenance` |
| User experience, onboarding, accessibility | `sg-experience`, `sg-design` |
| SEO and discoverability | `sg-seo` |
| Content and public documentation | `sg-content` |
| Positioning, messaging, conversion, growth | `sg-marketing` |
| Security and compliance hardening | `sg-engineering`, `sg-maintenance` |
| Internal docs and agent context | `sg-docs` |

A focus argument narrows the facets; it never widens the project root.

## Candidate discovery

Gather candidates from, in order of trust:

1. Existing durable truth: roadmap, ready specs, open tasks, known bugs,
   recorded audit findings, Sentry or analytics evidence already accessible
   read-only.
2. Fresh evidence the run produces itself: facet audits (code health, test
   gaps, SEO crawl, UX journey review, accessibility, performance profile in
   a managed session, dependency and security review).
3. Grounded opportunities: competitor or market research through the
   configured web search cascade, content gaps, conversion friction, missing
   features users clearly need. Record each as a spec or task in the owner's
   tracker before implementing it.

Exclude speculative ideas without evidence, duplicates of existing work, work
claimed by another conversation, and anything requiring a forbidden effect.

## Ranking

Within the eligible pool, order by:

1. Expected durable business impact (revenue, retention, acquisition, trust,
   risk reduction).
2. Confidence the change achieves it, from evidence.
3. Reversibility and blast radius (prefer safe, contained slices first).
4. Effort, only as a tie-breaker; Auto does not optimize for speed.

Prefer finishing an in-progress item over starting a new one. After two
consecutive slices in one facet, re-check whether another facet now holds a
higher-value candidate.

## Continuous loop

For each selected candidate:

1. Bind one owner and one durable work item (create it in the owner's tracker
   when the run originated the idea).
2. Reserve the candidate and its smallest owned paths through the shared
   claim helper before any mutation. Skip fresh overlapping claims.
3. Load the owner contract and implement the largest coherent slice it allows.
4. Prove it with the owner's proportional local checks: lint, analyze or type
   check, focused tests, managed dev session through `shipglows-dev`, and
   browser proof when behavior is user-visible. Content-only slices prove by
   schema conformity, locale parity and editorial quality, not by builds.
5. Fix failures or revert the slice to the last good state. Never leave the
   checkout broken.
6. Commit the validated milestone with an exact-scope conventional commit on
   the current branch. Leave unrelated changes untouched.
7. Update the owner's durable record (task status, spec changelog, audit
   finding) and release the claim.
8. Select the next candidate immediately. Do not return to the operator to
   choose ordinary next work.

When the candidate pool empties, run a fresh multi-facet sweep before
concluding there is nothing to do.

## Questions and blocking

Ordinary choices belong to the agent: decide from evidence and best practice
and record the rationale. Turn strategic or irreversible decisions into a
recorded operator question, skip the candidate, and continue with others. Ask
only when no safe candidate can progress; then send one concise message listing
every pending question with a recommended answer for each.

## Scenarios

- `AUTO-NO-PRESSURE`: two candidates of similar value; the more valuable one
  wins even when slower.
- `AUTO-PROVE-LOCAL`: a code slice runs its lint and focused tests before the
  commit; a red check blocks the commit.
- `AUTO-NO-PUSH`: a validated milestone is committed locally and never pushed,
  even when an upstream exists.
- `AUTO-ORIGINATE`: an SEO audit reveals missing structured data; the run
  records a task with `sg-seo`, implements it, proves it, and commits.
- `AUTO-STRATEGIC-SKIP`: a pricing change would help conversion; the run
  records the question with a recommendation and continues another facet.
- `AUTO-SWEEP-BEFORE-STOP`: the backlog is empty; the run audits every facet
  before reporting no further safe work.
- `AUTO-SELF-GUARD`: an auto run never edits its own authority or guardrails.
