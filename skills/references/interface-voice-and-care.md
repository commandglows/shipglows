---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-07"
updated: "2026-09-07"
status: active
source_skill: 008-sg-customer
scope: interface-voice-and-care
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/008-sg-customer/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/009-sg-marketing/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval 2026-09-07: translate existing benefit, choice and emotional-intent principles into warm interface copy and interactions."
next_review: "2027-03-07"
next_step: none
---

# Interface Voice And Care

## Activation

Use when writing, designing, implementing, or reviewing user-facing interface
copy and interactions: welcome, onboarding, forms, permissions, empty states,
loading, success, errors, and recovery. Infrastructure-only work does not load
this reference. Experience owns this shared intent; each active skill retains
its existing task and proof ownership. This governs product interfaces, not
agent work reports. Existing brand voice and user direction remain authoritative.

## Make The Person Feel Considered

Write as a team that wants the person to succeed. Lead with the useful intention
or benefit where explanation is needed, then offer a concrete next step. Translate
system state into what it means for the person's task. Technical terminology
belongs in optional detail unless the audience needs it to make the decision.

Clarity and truth are necessary but do not alone make good interface copy.
Ask what the person needs to feel at this moment: welcomed, encouraged, confident,
recognized, or supported. Express care through relevant wording and helpful
behavior, not through extra adjectives or generic enthusiasm. Keep concise
control labels explicit; not every button needs a sentence.

## Match The Moment

| Moment | Copy and interaction direction |
| --- | --- |
| Welcome and onboarding | Make the person feel expected; connect the first small action to something they want to accomplish. Encourage progress rather than presenting a configuration checklist. |
| Permission or setup | Explain what this enables for them before the request. Keep optional choices easy to defer and revisit; choosing not to enable something is not a failure. |
| Empty state | Offer a relevant invitation and achievable first action. Distinguish a new workspace from no search results or a loading failure; do not invite creation when the person is trying to find existing work. |
| Loading | Explain what we are preparing or doing for them using real progress. Avoid implementation-stage jargon and invented durations; keep repeat status messages unobtrusive. |
| Success | Acknowledge the concrete accomplishment and make the next useful action available. Save larger celebrations for meaningful milestones and brand-appropriate contexts. |
| Error and recovery | Recognize the interruption, explain its practical consequence, and offer a working recovery path. Use a calm, caring voice; do not blame the user or make playful jokes about a loss or failure. |

Warm colors, illustration and small interactions can reinforce the tone when
appropriate to the brand. Avoid mandatory mascots, emojis, confetti, forced
familiarity or repetitive praise. Accessible focus, contrast, reduced motion,
choice persistence and usable recovery are part of care, not optional polish.

## Truthful Warmth

State verified benefits with confidence. An intention such as offering the best
possible experience is welcome; do not turn it into an unsupported guarantee.
Never claim that work is saved, data is safe, payment succeeded, nothing was lost,
or a retry is harmless without evidence. Explain actual advertising, costs,
permissions and consequences plainly. A legitimate refusal or optional skipped
step receives a distinct neutral state, not danger styling or guilt-inducing copy.
Reserve warning or danger for an actual consequence, explained separately.

## French Tone Examples

These illustrate direction, not universal replacement strings. Adapt benefits,
actions and register to the product and its verified behavior.

| Mechanical wording | Caring direction |
| --- | --- |
| Aucun projet | Vos idées ont leur place ici. Créons votre premier projet. |
| Autorisation microphone requise | Pour donner vie à vos idées à voix haute, autorisez l’accès au micro. |
| Chargement en cours | Nous préparons votre espace. |
| Configuration terminée | Tout est prêt, vous pouvez commencer ! |
| Échec de l’enregistrement | Nous n’avons pas pu enregistrer vos modifications. Vous pouvez réessayer. |

The retry example requires a supported retry action; the ready example requires
the relevant setup to be complete. Preserve the benefit-led warmth of the cookie
consent reference for that specific surface; do not replace it with a generic
technical notice.

## Review In Context

Review representative rendered states along with the words. For each, check:
does it address the person's intention, fit their likely emotional situation,
sound natural in the brand's voice, tell the truth, and provide the promised
action? Mark text that is accurate but cold, blaming, patronizing or needlessly
technical as needing revision. Verify that a refusal stays respectful, an error
offers usable recovery, and a success message reflects actual completion.

Keep authoring guidance separate from proof: reading this reference or passing
metadata checks does not prove an agent applied the tone or users experienced it.
