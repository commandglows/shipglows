# 301-sg-context

> Prepare one known task with sufficient, qualified context without making memory or retrieval tooling authoritative.

## What It Does

`301-sg-context` resolves the task target and accepted outcome, inspects only decision-changing sources, qualifies facts and gaps, and returns a context verdict plus the next safe action.

It uses `context_continue`, `context_retrieve`, and `context_read` when those MCP tools are callable in the current turn. Otherwise it falls back to native repository search, focused reads, Git state, environment evidence, and applicable canonical documentation. It never reports MCP evidence that was not obtained.

## Context Verdicts

- `context_ready`: sufficient for the named next action.
- `context_partial`: bounded investigation may continue, but a named gap blocks dependent work.
- `context_conflict`: authoritative sources disagree.
- `context_stale`: a material claim requires targeted revalidation.

## Boundaries

Memory and cache accelerate discovery; project-owned sources, observed repository/runtime state, operator decisions, and current official external documentation retain their respective authority. The context capsule is working state, not a new project registry.

The skill primes context only. It does not implement, mutate specs, select an unresolved workflow, report cross-project status, or bypass approval/readiness/security gates.

## Typical Examples

```text
301-sg-context fix the billing webhook retry behavior
301-sg-context add pagination to the admin users surface
301-sg-context explain src/lib/auth.ts
```
