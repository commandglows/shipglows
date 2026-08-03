---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 407-sg-translate
scope: translation-sync
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/407-sg-translate/SKILL.md
  - skills/407-sg-translate/references/translation-quality-reference.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Controlled missing-entry synchronization and ambiguity safeguards migrated from the former 407 activation contract."
next_step: "/103-sg-verify consolidate translation skill under sg-translate"
---

# Translation Sync Playbook

Use only for `407-sg-translate sync [path|scope]`. `apply [path|scope]` normalizes to this exact route; it never selects a second implementation. Load `translation-quality-reference.md` before evaluating or writing entries.

## Establish Scope And Authority

1. Resolve an unambiguous current project and optional file/folder/content scope. No scope means the whole current project, never the workspace.
2. Detect locale architecture and configured default/source locale. If none is configured, infer the highest-coverage locale only when key/content evidence is unambiguous and report the inference.
3. Enumerate target locales and build a source-to-target matrix of message keys, localized content counterparts, and translatable frontmatter fields.
4. Identify the project glossary, tone/formality, brand names, technical-noun convention, locale mapping, and stable content IDs/slugs.
5. Record before counts by target locale and the exact candidate entries. A candidate is writable only when its source, destination, meaning, structure, and mapping are all clear.

## Safe Mutation Loop

For each candidate independently:

1. Confirm the target entry or counterpart is missing; never replace a non-empty translation by default.
2. Translate naturally for the target locale and project tone. Do not produce literal or machine-like wording.
3. Preserve placeholders and structure exactly: named/positional tokens, `%s`, ICU fragments, Markdown links, HTML tags, component markers, escapes, and interpolation syntax.
4. Preserve brand/product names and established technical terms. Follow the glossary rather than inventing a terminology change.
5. For content counterparts, require a reliable locale ID/slug/file mapping before creating a file. Do not fabricate a counterpart or change locale URL strategy.
6. Write only the bounded missing entry, then re-read or parse the affected structure before proceeding.

Ambiguous, business-sensitive, terminology-conflicting, placeholder-unsafe, culturally uncertain, or unmapped candidates remain unchanged. List each with evidence and, when useful, two clearly labeled options for operator review. Continue only with independent low-risk entries; never turn one ambiguity into an all-or-nothing silent guess.

## Forbidden Mutations

- rewriting existing non-empty translations for style, persuasion, or consistency
- changing locale routing, prefix, canonical, slug, or fallback strategy
- changing established terminology without glossary or operator authority
- extracting unrelated hardcoded strings or repairing markup discovered during sync
- expanding from the selected path/scope to the whole project
- hiding conflicts by copying source-language text into a target locale as if translated

Route persuasion to `009-sg-marketing`, SEO strategy/repairs to `406-sg-seo`, substantive drafting to `007-sg-content` or `200-sg-redact`, and documentation changes to `300-sg-docs`.

## Post-Sync Proof

Within the exact scope:

- recompute missing counts before/after by locale
- verify placeholder/token/ICU/link/tag/component-marker integrity
- parse or validate the changed localization structure with the project-native check when available
- check for accidental changes to existing non-empty entries
- note likely truncation risk for long UI labels/buttons rather than inventing layout changes
- verify relevant `lang`, locale-route, counterpart, and `hreflang` invariants without broadening into technical remediation
- list every touched file and ambiguous unchanged item

If any changed entry fails structural or placeholder integrity, revert only that bounded candidate through a recoverable edit and report it as unchanged/blocked; do not weaken the check.

## Report Contract

Report project/scope, canonical mode `sync`, whether `apply` was normalized, source locale and inference status, target locales, missing counts before/after, entries added, changed localization surfaces, ambiguous items unchanged, placeholder integrity, terminology drift, technical-i18n risk, checks run, and proof limits. In `report=agent`, include the exact touched-file list required by the proof record; in `report=user`, follow the shared reporting contract and omit file names, paths, and counts.

Persist follow-up records only when explicitly authorized. Load the shared operational-record and task-registry contracts, re-read the canonical project-local target immediately before the smallest traffic-first write, and never duplicate a root tracker by default.

## Stops And Pressure Scenarios

- `TR-SYNC-SAFE`: unambiguous missing entries are added with structure intact and before/after proof.
- `TR-APPLY-ALIAS`: `apply` uses this exact playbook and reports canonical mode `sync`.
- `TR-SYNC-AMBIGUOUS`: unsafe or disputed entries stay unchanged and visible for review.
- `TR-INVALID`: unsupported or materially ambiguous input reaches no mutation loop.
- Stop before mutation when the project, scope, source locale, target mapping, terminology authority, or placeholder structure cannot be established safely.
