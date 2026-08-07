---
artifact: editorial_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 202-sg-emailing
scope: accessible-email-writing
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/202-sg-emailing/SKILL.md
  - skills/202-sg-emailing/references/accessible-email-technical-playbook.md
  - skills/references/email-sequence-storage.md
depends_on: []
supersedes: []
evidence:
  - "Resend, 6 Tips for Accessible Emails, updated 2026-07-09: https://resend.com/blog/6-tips-for-accessible-emails"
  - "Email Markup Consortium, Accessibility Report 2026: https://emailmarkup.org/en/reports/accessibility/2026/"
next_review: "2027-02-07"
next_step: "/202-sg-emailing audit accessible email writing"
---

# Accessible Email Writing Playbook

## Purpose

Help an agent write an email whose meaning, action, and structure remain clear
with images disabled, low vision, a screen reader, zoom, forced dark mode, or a
client-generated summary. This reference owns editorial decisions. The paired
technical playbook owns markup, rendering, delivery setup, and QA.

## Before Drafting

Confirm or infer from governed project context:

- audience, message trigger, and one primary objective
- primary action and a descriptive CTA label
- message language and text direction
- required legal, consent, preference, and opt-out content
- essential proof, claims, and information that must remain available as text

Do not make an image, color, icon, layout, hover state, or animation the only
way to understand information or complete the action.

## Drafting Contract

1. Write a specific subject and preview that identify the message without
   relying on visual context. Avoid decorative characters that create noise
   when announced.
2. Put the purpose and essential next step early. Use short paragraphs, plain
   language, informative labels, and a predictable reading order.
3. Give a substantial message one descriptive main heading, then nest headings
   without skipping levels. A very short notification may omit headings when
   its purpose is already unambiguous.
4. Make every link understandable out of context. Prefer “Review your August
   invoice” to “Click here” or a bare URL. Distinguish links that lead to
   different destinations.
5. For every meaningful image, write concise alt text that communicates its
   purpose in this message. Use empty alt text for purely decorative images.
   A linked image is functional: its accessible text must describe the action
   or destination, not merely the picture.
6. Keep essential copy out of images. If an image contains useful text, repeat
   the meaning in live copy and make its alt text context-appropriate.
7. Never communicate status or priority through color alone. Choose foreground
   and background colors that meet at least 4.5:1 for normal text; the technical
   review must also inspect large text, controls, focus, and dark-mode outcomes.
8. Localize the whole message, including subject, preview, alt text, CTA,
   unsubscribe text, and web-version title. Declare the actual language and
   direction; never silently default a non-English message to English.

## Agent Draft Shape

For each email, keep these fields visible during review:

```text
Purpose:
Subject:
Preview text:
Language / direction:
Main heading (or short-message exception):
Body:
Primary CTA and destination:
Secondary links:
Images and alt decisions:
Required footer / preferences / opt-out:
Claims or proof to verify:
```

The final prose can omit these labels when the delivery format does not need
them, but the review record should preserve the decisions.

## Human Review

Read the email in source order with images hidden and ask:

- Is the sender, purpose, and requested action clear immediately?
- Do headings summarize the sections and follow a logical hierarchy?
- Does each link make sense when read alone?
- Does each alt value match the image's purpose in this exact context?
- Is any important meaning dependent on color, position, or visual styling?
- Is the localized language natural, and are language direction and mixed-
  language passages identified correctly?
- Can a recipient understand and act without the HTML version?

Automated checks can detect missing fields and some contrast failures. They
cannot judge whether wording, alt text, link purpose, reading order, or a
heading exception is appropriate. Do not report an email accessible from a
lint result alone.

## Handoff To Technical Setup

Load `accessible-email-technical-playbook.md` when the task creates or changes
a template, component, provider integration, rendering setup, test matrix, or
sending pipeline. A writing-only draft should still record language, direction,
heading, link, image, contrast, and plain-text decisions for that handoff.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/202-sg-emailing/references/accessible-email-writing-playbook.md
rg -n "subject|preview|heading|link|alt|contrast|language|direction|Human Review" skills/202-sg-emailing/references/accessible-email-writing-playbook.md
```
