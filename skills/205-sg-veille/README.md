# 205-sg-veille

> Turn links or pasted research into concrete decisions and clear owner handoffs.

## What It Does

`205-sg-veille` analyzes URLs or pasted content for business relevance across the ShipGlows project portfolio. Bare sources resolve to `triage`, which fetches and summarizes only what classification needs, scores relevance from project-local governance context, then asks for an explicit decision: ignore it, hand it to the correct owner, or create an authorized follow-up.

It is built for strategic scanning, not passive bookmarking.

## Who It's For

- Solo founders tracking competitors, tools, and market signals
- Builders who want research to end in decisions, not tab sprawl
- Operators managing several projects with different strategic fits

## When To Use It

- when you have links from competitors, tools, articles, or trends to evaluate
- when you want to convert research into actionable backlog items or governed content handoffs
- when you need a cross-project relevance check instead of a single-project opinion

## What You Give It

- one or more URLs, or pasted text
- local project discovery plus project-local `shipglows_data/` context so the skill can score relevance across projects

## What You Get Back

- short French summaries for each item
- project-by-project relevance scoring
- interactive triage choices for each link
- decision-aware research output or tool sheets only after an explicit human decision
- optional technical entries in the target project's `shipglows_data/workflow/TASKS.md`
- optional editorial entries in `shipglows_data/editorial/ROADMAP.md`, only when the public surface is declared
- `007-sg-content repurpose <source>` handoffs or `surface missing: blog` findings when a content idea needs an undeclared editorial surface

## Typical Examples

```bash
/205-sg-veille https://example.com/tool
/205-sg-veille triage https://example.com/tool
/205-sg-veille https://site-a.com https://site-b.com
/205-sg-veille [paste article notes here]
/205-sg-veille help
```

## Limits

The README is in English, but produced reports are intentionally in French. `205-sg-veille` is only as good as the project-local governance context it can load. The cross-project control plane discovers projects; it does not replace each project's `shipglows_data/business`, `shipglows_data/editorial`, and `shipglows_data/technical` contracts. This skill helps with prioritization and triage, not final strategic judgment, cited deep research, content production, marketing audits, docs work, or general tracker maintenance.

## Related Skills

- `203-sg-research` when a topic needs deeper investigation after triage
- `007-sg-content repurpose <source>` when a source should become public content, repurposing, or a governed content brief
- `011-sg-pilotage backlog` when the resulting backlog needs further cleanup
- `011-sg-pilotage review` to fold research-driven work into a broader session review
