# 203-sg-research

> Investigate a topic deeply, synthesize the findings, and save a reusable report in the repo.

## What It Does

`203-sg-research` runs a structured multi-source research pass on a topic and turns it into a markdown report with sources, options, best practices, and project-relevant recommendations. It is designed for questions that need more than one blog post or one doc page to answer well.

For a solo founder, it is a way to build durable decision material instead of repeating the same research every few weeks.

## Who It's For

- Founders comparing tools, architectures, or practices
- Developers who want a sourced recommendation before changing direction
- Teams that need a saved research artifact instead of chat-only output

## When To Use It

- when you need to compare libraries or approaches
- when best practices may have changed recently
- when a decision deserves a reusable written report

## What You Give It

- a topic, question, or comparison target
- optionally, the project context that should shape the recommendation

## What You Get Back

- a markdown research report saved to the repo
- source-backed findings
- option comparisons with tradeoffs
- practical recommendations for the current project

## Typical Examples

```bash
/203-sg-research
/203-sg-research "best auth stack for Astro SaaS"
/203-sg-research "Astro SSR caching patterns"
```

## Limits

- It is only as strong as the available and current source material.
- Some topics still need experiments or prototypes after the report.
- Research quality drops if the scope is too broad or poorly framed.

## Related Skills

- `009-sg-marketing market` for market-level validation
- `010-sg-technical migrate` for upgrade-specific research plus execution
- `300-sg-docs` if the findings should update permanent project docs
