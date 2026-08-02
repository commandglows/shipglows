# 700-sg-explore

> Think through a problem deeply before coding, using the real codebase when needed and refusing to rush into implementation.

## What It Does

`700-sg-explore` is ShipGlows’s deliberate thinking mode. It is for clarifying a problem, mapping options, challenging assumptions, and understanding the shape of a solution before anyone writes code.

Unlike implementation skills, this one is intentionally non-executing. It can inspect the repo, surface patterns, compare approaches, and draw diagrams, but it does not implement the outcome. That makes it useful when the expensive mistake would be coding too early.

## Who It's For

- Solo founders working through ambiguous product or architecture decisions
- Developers diagnosing messy systems before touching them
- Anyone who wants a real thought partner instead of instant code generation

## When To Use It

- when the problem is still fuzzy
- when there are several valid approaches with tradeoffs
- when the codebase feels more complex than the request suggests
- when you need diagnosis, framing, or decision support before execution

## What You Give It

- a question, idea, or problem statement
- optionally a file, subsystem, or architectural area to inspect

## What You Get Back

- a clearer framing of the real problem
- tradeoff analysis and possible paths
- diagrams or models when helpful
- a more solid next step, including when to switch to implementation

## Typical Examples

```bash
/700-sg-explore should we add realtime collaboration?
/700-sg-explore why has auth become so hard to maintain here?
/700-sg-explore postgres or sqlite for this local-first tool?
```

## Limits

`700-sg-explore` does not implement features or fixes. If you are already sure what to build, use an execution skill instead.

## Related Skills

- `301-sg-context` to load focused files first
- `100-sg-spec` when exploration needs to become an execution contract
- `102-sg-start` when the problem is clear enough to build
