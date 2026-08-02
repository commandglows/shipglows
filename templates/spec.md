---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
created_at: "YYYY-MM-DD HH:MM:SS UTC"
updated: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD HH:MM:SS UTC"
status: draft
source_skill: sg-spec
source_model: "[model name or unknown]"
scope: feature
owner: "[owner]"
user_story: "En tant que..., je veux..., afin de..."
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on:
  - artifact: "[BUSINESS.md|BRANDING.md|GUIDELINES.md|docs/path.md]"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "[code path, doc, user decision, or investigation note]"
next_step: "/sg-ready [title]"
---

# Spec: [title]

## Title

[Clear, concise feature or fix title.]

## Status

draft

## User Story

En tant que [actor], je veux [capability], afin de [value].

## Minimal Behavior Contract

[One non-technical paragraph: what the feature accepts or triggers, what it produces or returns, what happens on failure, and the easiest edge case to miss.]

## Success Behavior

- Preconditions: [state or inputs required for success.]
- Trigger: [user/system action.]
- User/operator result: [observable result.]
- System effect: [data persisted, status updated, event sent, file created, job launched, or `None, because ...`]
- Success proof: [test, sanity check, log, final state, or `None, because ...`]
- Silent success: [not allowed / justified because ... and verifiable by ...]

## Error Behavior

- Expected failures: [invalid input, missing permission, absent resource, external dependency error, timeout, duplicate, concurrency, stale state, or `None, because ...`]
- User/operator response: [message, status, fallback, or `None, because ...`]
- System effect: [no mutation, rollback, pending state, retry, compensation, log, alert, or `None, because ...`]
- Must never happen: [partial inconsistent data, expanded permission, unconfirmed deletion, logged secret, repeated side effect, or `None, because ...`]
- Silent failure: [not allowed / justified because ... and recoverable by ...]

## Problem

[What user, operator, or business problem is being solved.]

## Solution

[1-2 sentences describing the chosen approach.]

## Scope In

- [Included behavior, file area, or workflow.]

## Scope Out

- [Explicit non-goal or excluded follow-up.]

## Constraints

- [Technical, product, security, timing, or compatibility constraint.]

## Dependencies

- Runtime: [library, service, API, config, data prerequisite, or `None, because ...`]
- Document contracts: [versioned docs from `depends_on`, or `None, because ...`]
- Metadata gaps: [unknown versions, stale contracts, missing frontmatter, or `None`]

## Invariants

- [Business, data, permission, or UX invariant that must remain true.]

## Links & Consequences

- Upstream systems: [callers, producers, docs, config, or `None, because ...`]
- Downstream systems: [consumers, routes, jobs, analytics, support, or `None, because ...`]
- Cross-cutting checks: [auth, data, i18n, a11y, SEO, perf, deploy, ops, or `None, because ...`]

## Documentation Coherence

- [Docs, README, guides, FAQ, onboarding, pricing, changelog, examples, support surfaces to align, or `None, because ...`.]

## Edge Cases

- [Happy-path boundary, error state, invalid state, retry, concurrency, stale data, or abuse case.]

## Implementation Tasks

- [ ] Task 1: [Clear action]
  - File: `[path/to/file.ext]`
  - Action: [Specific change to make]
  - User story link: [Which part of the user promise this serves]
  - Depends on: [Task number, foundation, or `None`]
  - Validate with: `[exact command, test, or sanity check]`
  - Notes: [Implementation detail or `None`]

## Acceptance Criteria

- [ ] AC 1: Given [precondition], when [action], then [observable result].

## Test Strategy

- Unit: [tests or `None, because ...`]
- Integration: [tests or `None, because ...`]
- Manual: [sanity checks or `None, because ...`]

## Test Contract

### Surface

- Stack/surface: [Flutter|Astro|Python|API|auth|provider|docs|other]
- Primary proof mode: [automated_tests|agent_browser|agent_auth|contract_only|device_only|manual_only|mixed]
- Proof order (if applicable): [automated/agent_browser/auth/contract/provider/device]

### Manual checklist

- Needed: [yes|no]
- Checklist path: `shipglows_data/workflow/test-checklists/<scope>.md`
- Required scenario coverage: [required rows only]
- Exception with proof: [why and what alternate evidence was used, when required]

### Required evidence stack

- Automated / unit / integration checks: [exact commands]
- Agent-run browser proof: [routes/commands used, if any]
- Auth/session proof (`sf-auth-debug`): [route/objective, if any]
- Contract/integration proof: [API/service/doc checks]
- Provider evidence: [tool and target, if any]
- Device-native proof: [native-only scenario, if any]

## Risks

- Security impact: [none, because ... / yes, mitigated by ... / unknown, because ...]
- Product/data/performance risk: [risk and mitigation, or `None, because ...`]

## Execution Notes

- Read first: `[files/docs to read before implementation]`
- Validate with: `[commands/checks]`
- Stop conditions: [ambiguity, failing invariant, stale dependency, security concern, or `None`]

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| YYYY-MM-DD HH:MM:SS UTC | sf-spec | [model name or unknown] | Created spec for [slug] | draft | /sg-ready [title] |

## Current Chantier Flow

- `sf-spec`: done, draft spec created.
- `sf-ready`: not launched.
- `sf-start`: not launched.
- `sf-verify`: not launched.
- `sf-end`: not launched.
- `sf-ship`: not launched.

Next step: `/sg-ready [title]`
