---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 202-sg-emailing
scope: accessible-email-technical-setup
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/202-sg-emailing/references/accessible-email-writing-playbook.md
  - skills/references/documentation-freshness-gate.md
depends_on: []
supersedes: []
evidence:
  - "Resend, 6 Tips for Accessible Emails, updated 2026-07-09: https://resend.com/blog/6-tips-for-accessible-emails"
  - "Email Markup Consortium, Accessibility Report 2026: https://emailmarkup.org/en/reports/accessibility/2026/"
next_review: "2027-02-07"
next_step: "/103-sg-verify accessible email technical setup"
---

# Accessible Email Technical Playbook

## Purpose

Define the minimum technical setup and verification for robust, accessible
HTML email. Email clients sanitize and transform markup unevenly, so accessible
source code is necessary but does not guarantee an accessible received message.

Use the paired writing playbook for content judgment. Use this reference when
implementing templates, components, provider integrations, or rendering QA.
Load `email-deliverability-and-authentication-playbook.md` for sending identity,
DNS authentication, reputation, compliance, and delivery operations.

## Freshness And Benchmark Source

Keep the following report as the dated compatibility benchmark for email
accessibility setup and periodic audits:

- [Email Markup Consortium — Accessibility Report 2026](https://emailmarkup.org/en/reports/accessibility/2026/)

The report tests both sent-message markup and 37 accessibility-related HTML/CSS
features across 43 client surfaces. It does not audit the accessibility of each
client application's own interface. Its 2026 results show wide variance, so do
not turn one client's score into a universal support claim.

Before changing client-specific behavior, framework/provider setup, or the QA
matrix, apply `skills/references/documentation-freshness-gate.md`, revisit the
report above, and check current official documentation for the selected stack.

## Markup Baseline

- Emit a complete document with a short, message-specific `<title>` whenever a
  browser/web fallback exists; retain it by default when the framework supports
  it safely.
- Set the correct BCP 47 `lang` and `dir` on `<html>`. Duplicate them on each
  direct child of `<body>` because some clients strip root attributes. Use
  `lang="und"` only as an explicit last-resort fallback, never as a substitute
  for known localization.
- Prefer semantic source order and native headings, paragraphs, lists, links,
  and buttons. Do not use layout position as reading order.
- Avoid layout tables where viable. When email compatibility requires them,
  add `role="presentation"` or `role="none"`; never apply that role to a real
  data table.
- Give every `<img>` an `alt` attribute. Use meaningful text for informative or
  functional images and `alt=""` for decoration. Ensure linked images expose a
  discernible destination even where ARIA is stripped.
- Prefer visible descriptive link text. Treat `aria-label`, `title`, generated
  content, and visually hidden-only repairs as fallbacks because support varies.
- Do not disable zoom or scaling. Keep layouts responsive, touch targets usable,
  live text readable when enlarged, and narrow viewports free of essential text
  baked into images.
- Set explicit foreground and background colors with sufficient contrast.
  Treat `prefers-color-scheme`, `prefers-reduced-motion`, `:hover`, `:focus`,
  and ARIA support as progressive enhancement, never as the only safeguard.
- Generate and test a meaningful `text/plain` alternative with the same core
  message, links, action, required footer, and opt-out path.

## Safe Defaults In The Component Layer

Centralize defaults rather than relying on every author to remember them:

- document language, direction, and title/preview plumbing
- empty alt as a required explicit decision, with lint/review for meaningful
  images rather than pretending an empty default proves accessibility
- presentational roles on layout primitives only
- semantic heading and text components
- contrast-safe tokens and dark-mode-resistant fallbacks
- descriptive CTA API and plain-text rendering

Do not upgrade a framework or provider package solely from a blog instruction.
Inspect the local version and changelog, follow the Freshness Gate, then run the
project's regression checks.

## Verification Ladder

1. **Static checks:** lint document language/direction, title policy, heading
   order, image alt presence, link names, layout-table roles, viewport/zoom,
   and computed contrast where tooling permits.
2. **Rendered inspection:** inspect generated HTML after the framework and ESP
   have transformed it, not only the source component.
3. **Manual accessibility review:** navigate the received message in source
   order with a screen reader, keyboard where interactive behavior exists,
   images disabled, zoom/text scaling, and forced dark mode.
4. **Client matrix:** choose representative clients from actual audience data.
   At minimum cover a WebKit-based strong renderer plus relevant Gmail and
   Outlook surfaces; include the legacy Windows Outlook surface whenever the
   audience includes enterprise or government users who still depend on it.
5. **Fallback review:** verify the plain-text part and web version, if present,
   preserve the purpose, links, CTA, preferences, and unsubscribe behavior.

Record client, platform, version/date, assistive technology, test message ID or
redacted fixture, and observed result. Do not claim broad client compatibility
from screenshots or one inbox.

## Release Gate

An email template is ready only when:

- content review from the writing playbook is complete
- transformed HTML passes the mechanical checks
- manual review covers contextual alt text, link purpose, reading order, zoom,
  contrast, images-off behavior, and the primary assistive-technology flow
- representative client tests have explicit results and accepted limitations
- plain-text and unsubscribe/preference paths work
- known client limitations have content-preserving fallbacks

Automated success is evidence, not conformance. The 2026 report found that even
the tiny set of messages passing all automated rules still contained contextual
issues during manual review.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/202-sg-emailing/references/accessible-email-technical-playbook.md
rg -n "Accessibility Report 2026|lang|dir|presentation|alt|contrast|plain-text|Client matrix|Release Gate" skills/202-sg-emailing/references/accessible-email-technical-playbook.md
```
