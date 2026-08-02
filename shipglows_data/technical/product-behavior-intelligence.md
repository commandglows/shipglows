---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-11"
updated: "2026-07-11"
status: draft
source_skill: 900-shipglows-core
scope: product-behavior-intelligence
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/business/product.md
  - shipglows_data/business/gtm.md
  - shipglows_data/technical/README.md
  - shipglows_data/workflow/specs/
  - skills/700-sg-explore/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/009-sg-marketing/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "ReplayGlowz product-analysis conversation showed recurring need for a reusable framework connecting behavior modeling, activation, retention, feature impact, and GTM proof."
  - "Several projects in this workspace can benefit from a shared doctrine for turning usage signals into product and growth decisions."
next_review: "2026-08-11"
next_step: "/300-sg-docs audit shipglows_data/technical/product-behavior-intelligence.md"
---

# Product Behavior Intelligence

## Purpose

Use this reference when a project needs more than generic analytics and should instead understand whether user behavior turns into durable product value.

This document is for projects where the important question is not only:

- who opened the app,
- how many sessions happened,
- or which screen was viewed,

but rather:

- what users captured,
- how they organized it,
- whether they came back to it,
- whether an assistive feature improved the workflow,
- and which behaviors actually predict retention, adoption, or credible GTM proof.

This reference was generalized from a ReplayGlowz analysis, but it is intentionally cross-project.

## Use When

Reach for this framework when a project needs one or more of these:

- activation metrics tied to real value instead of vanity usage;
- retention hypotheses tied to behavior quality instead of generic session counts;
- feature-impact analysis for AI, transcript, summarization, recommendation, or other assistive layers;
- a lightweight exploratory analytics lane before committing to a heavier BI stack;
- decision-support dashboards that help choose feature priorities;
- evidence-backed public proof for landing pages, pricing pages, comparison pages, or sales claims.

Typical fit:

- learning workflows;
- note-taking or knowledge workflows;
- content systems with capture and reuse loops;
- shopping/save-for-later systems with revisit and decision behavior;
- local-first products that need to understand whether saved state becomes repeated value.

## Core Rule

Model the value loop, not just the traffic.

If the product promise depends on helping users transform raw input into something reusable, then the analytics model should follow that transformation.

The usual failure is to stop at:

- account creation,
- screen opens,
- clicks,
- or total session counts.

Those are context signals, not proof of product value.

## The Six-Layer Framework

### 1. Behavior Graph

Start by modeling the entities and relationships that describe the product's reusable-value loop.

Canonical entity families:

- `user`
- `source_object`
  - example: video, note source, document, product, prompt, feed item
- `session`
- `capture`
  - example: note, save, annotation, extraction, clip
- `organization`
  - example: playlist, folder, list, tag, board
- `assistive_feature`
  - example: transcript, AI summary, suggestion, recommendation, parser
- `revisit`
  - example: reopen, reread, replay, resurface, return-to-item
- `feedback_signal`
  - example: explicit rating, completion, export, share, downstream use

The graph should answer:

- what the user engaged with;
- what they captured from it;
- how they organized it;
- whether they returned;
- and whether an assistive feature improved the loop or only added complexity.

### 2. Activation Model

Activation should represent the first real value loop, not the first generic interaction.

Useful generic ladder:

- `A0` account or access ready
- `A1` first real source interaction
- `A2` first capture
- `A3` first organization action
- `A4` first revisit
- `A5` first durable loop

Project-specific meaning matters. For many products:

- `A1` is not enough;
- `A2` is often the first meaningful signal;
- `A4` and `A5` are where real habit formation begins.

Questions to force early:

- what counts as "first value";
- what counts as "reusable value";
- what behavior proves the user is getting more than one-off novelty.

### 3. Retention Model

Retention should be explained by meaningful behavior, not only measured as a generic return percentage.

Priority questions:

- which early actions predict J7, J14, or J30 return;
- does capture matter more than simple consumption;
- does organization matter more than raw capture;
- does revisit behavior outperform both as a retention predictor;
- which behaviors signal durable habit instead of passive browsing.

Useful retention cuts:

- users with capture vs without capture;
- users with organization vs without organization;
- users with revisit vs without revisit;
- users with assistive-feature usage vs without assistive-feature usage;
- segment-by-segment comparison, not only global averages.

### 4. Feature Impact Model

Optional or costly features should be evaluated inside the core value loop, not beside it.

This matters especially for:

- transcripts;
- AI summaries;
- retrieval features;
- recommendations;
- automation layers.

Do not ask only:

- how often the feature was used.

Ask instead:

- did the feature increase capture;
- did it improve organization quality;
- did it increase revisits;
- did it improve retention for any segment;
- did it justify its cost and complexity.

The default assumption should be:

- optional features are not equally useful for all users;
- some segments benefit a lot;
- some segments gain little and only increase cost or UI complexity.

### 5. Decision-Support Layer

The analytics system should help product decisions, not just report activity.

Typical decisions this layer should support:

- which feature deserves the next investment;
- which workflow step has the biggest friction;
- whether an assistive feature deserves to stay optional, premium, or default;
- whether a behavior loop is strong enough to justify GTM emphasis;
- whether the product is reinforcing the promised outcome or drifting into generic usage.

If the output cannot inform a priority decision, it is probably too shallow.

### 6. GTM Proof Layer

Strong product analytics should feed public proof carefully.

Use validated behavior signals to support:

- landing page positioning;
- pricing value language;
- comparison pages;
- objection handling;
- support or onboarding content.

Good GTM proof is grounded in measured outcomes such as:

- repeated use of captured value;
- return-to-item behavior;
- improved organization;
- feature adoption that correlates with meaningful success.

Avoid vague claims like:

- "AI-powered"
- "saves hours"
- "boosts productivity"

unless the product has evidence strong enough to support them honestly.

## Canonical Join Patterns

The most important joins are usually these:

- `source_object -> capture -> revisit`
- `source_object -> organization -> revisit`
- `source_object -> assistive_feature -> capture`
- `assistive_feature -> capture -> revisit`
- `source_object -> session -> feedback_signal`

When a project has a transcript-like feature, add:

- `source_object -> transcript_version -> capture/revisit`

The point is to make cross-layer reasoning easy without building a new ad hoc query for every question.

## Instrumentation Rule

Instrument only the events that can answer behavior, activation, retention, or feature-impact questions.

Do not flood the project with low-signal telemetry just because it is easy to log events.

Prioritize events like:

- first capture;
- first organization action;
- assistive feature viewed or used;
- revisit of a captured item;
- revisit after organization;
- revisit after assistive-feature use;
- downstream success signals.

Low-value event spam often makes the model noisier and harder to trust.

## Exploratory Analytics Workspace

Before committing to a heavy data stack, create a lightweight exploration lane when the product is still learning.

This lane should allow teams to:

- filter,
- transform,
- join,
- aggregate,
- and visualize

without paying the full cost of a mature BI program too early.

The purpose is not to avoid rigor. The purpose is to learn quickly enough to decide what deserves rigor first.

## Canonical Deliverables

When this framework is used for a project, the first serious deliverables should usually be:

1. a behavior-graph note or spec;
2. an activation-stage definition;
3. a retention-hypothesis pack;
4. a feature-impact model for optional/AI features;
5. a shortlist of internal decision-support dashboards;
6. a GTM-proof note listing which measured claims are safe to surface publicly.

## Pressure Scenarios

### When this framework is needed

- The project keeps measuring signups and opens but cannot explain why users stay.
- A transcript or AI feature looks impressive but its real value is unclear.
- A team wants to push stronger marketing claims but lacks proof tied to user outcomes.
- A product has capture/save/organize/revisit mechanics, but they are not yet modeled as one loop.
- A founder wants to know which behaviors predict retention without building a full analytics warehouse first.

### When this framework is overkill

- The product is still too undefined to know its core loop.
- There is no reusable-value workflow yet, only one-step utilities.
- The project still lacks basic event ownership or stable object identities.

## Anti-Patterns

Avoid these mistakes:

- treating account creation as activation;
- using screen opens as the main product metric;
- evaluating assistive features only by usage count;
- building dashboards before defining joins and event meaning;
- making GTM claims from intuition instead of measured behavior;
- copying the same retention model across products with different value loops.

## Adoption Checklist

Before applying this framework to a project, answer:

1. What is the source object the user engages with?
2. What counts as capture?
3. What counts as organization?
4. What counts as revisit?
5. Which optional or expensive feature needs impact proof?
6. What is the first durable value loop for this product?
7. Which public claims would benefit from measured proof?

If those questions are still fuzzy, exploration should start there before dashboard work.

## Maintenance Rule

Update this reference when ShipGlows gains a better cross-project doctrine for activation, retention, feature-impact analysis, exploratory analytics, or GTM proof from product behavior.
