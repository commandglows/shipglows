---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 202-sg-emailing
scope: cross-skill-email-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/010-sg-technical/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/107-sg-test/SKILL.md
  - skills/305-sg-init/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-07: connect email playbooks conditionally across ShipGlows skills without loading the full corpus for every email-adjacent task."
next_review: "2027-02-07"
next_step: "/103-sg-verify cross-skill email routing"
---

# Email Work Routing

## Purpose

Select the smallest email reference set across ShipGlows métiers. Load this
router only when work creates, changes, audits, tests, deploys, or operates an
email surface. Merely containing an email address or accepting email as an
account identifier does not trigger it.

`202-sg-emailing` owns the reusable email lifecycle contract. The active métier
keeps ownership of its implementation, design, engineering, test, release, or
setup outcome and uses the selected email references as domain constraints.

## Selection Matrix

All paths resolve from `$SHIPGLOWS_ROOT/skills/202-sg-emailing/references/`.

| Work detected | Required reference |
| --- | --- |
| Draft, sequence, campaign, transactional copy, subject, preview, CTA, localization, content audit | `accessible-email-writing-playbook.md` |
| HTML/template/component, responsive rendering, client compatibility, plain text, technical accessibility | `accessible-email-technical-playbook.md` |
| Sending domain, SPF, DKIM, DMARC, reputation, consent, unsubscribe, suppressions, bounces, complaints, delivery webhooks | `email-deliverability-and-authentication-playbook.md` |
| Resend plugin, MCP, CLI, API, agent inbox, logs, contacts, segments, broadcasts, templates, or agent-triggered sends | `resend-agent-integration-playbook.md` plus the task-specific reference above |

Load more than one only when the task crosses layers:

- password reset implementation: writing + technical; add deliverability only
  when provider/domain or real delivery is in scope
- newsletter campaign: writing + deliverability; add technical for an HTML
  template and Resend integration only when Resend tools are used
- DMARC audit: deliverability only
- Resend MCP connection: integration only until a concrete email action
  activates another layer

## Owner Routing

- Content and marketing may prepare source, positioning, and copy, then hand
  email lifecycle work to `202-sg-emailing`.
- Development owns product implementation.
- Design owns visual/template design and email accessibility.
- Engineering owns provider, DNS, webhook, reputation, and operational setup.
- Verification and test own proof of transformed and received results.
- Release owns authorization and production mutation gates.
- Init owns optional integration discovery/setup after explicit request.
- Auth debug uses email references only when delivery, template content, link,
  OTP, sender identity, or provider behavior is part of the bug. Local Mailpit
  wiring alone does not prove or require external deliverability.

## External-Action Gate

Drafting, static inspection, and read-only diagnostics do not authorize an
external mutation. Before sending or scheduling mail, changing recipients,
contacts, segments, suppressions, domains, DNS, webhooks, or credentials, load
`resend-agent-integration-playbook.md` when Resend is involved and require its
bounded authorization. Apply the same authorization principle elsewhere.

## Completion Gate

Do not report email work complete until the selected playbook's release or
review gate is satisfied. A component test does not prove received rendering;
a dashboard does not prove authentication alignment; a test send does not
authorize a campaign; and automated accessibility checks do not replace manual
contextual review.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/references/email-work-routing.md
rg -n "accessible-email-writing|accessible-email-technical|email-deliverability|resend-agent-integration|External-Action Gate|Completion Gate" skills/references/email-work-routing.md
```
