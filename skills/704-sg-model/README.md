# 704-sg-model

> Choose the right ShipGlows model for a task without wasting time on model debate.

## What It Does

`704-sg-model` routes a task to the model that best fits its scope, risk, speed requirements, and expected session length. Instead of overthinking model choice, it gives a practical recommendation: primary model, reasoning level, faster fallback, cheaper fallback, and the point where you should stop optimizing and just start the work.

For solo founders, this is mainly about momentum. You spend less time tuning the toolchain and more time shipping.

## Who It's For

- Founders switching between planning, coding, debugging, and UI work
- Operators balancing quality, latency, and cost
- Anyone using multiple ShipGlows-compatible models and wanting a sane default

## When To Use It

- before a non-trivial task
- when a spec exists and you want the right execution model
- when you are unsure whether a task needs a premium model or a fast cheap one

## What You Give It

- a task description, scope, or spec path
- optionally, the tradeoff you care about most: quality, speed, or cost

## What You Get Back

- a recommended primary model
- a reasoning setting
- a fast fallback
- a cheap fallback
- a clear next step, usually `102-sg-start`

## Typical Examples

```bash
/704-sg-model
/704-sg-model "fix payment webhook race condition"
/704-sg-model specs/onboarding-rewrite.md
```

## Limits

- It is a routing aid, not a benchmark report.
- The recommendation is only as good as the scope you give it.
- Very small tasks usually do not need dedicated routing at all.

## Related Skills

- `101-sg-ready` before execution on spec-driven work
- `102-sg-start` to actually run the task
- `303-sg-resume` if you need a quick thread snapshot before deciding
