---
name: 205-sg-veille
description: "Triage business veille sources into decisions."
disable-model-invocation: true
argument-hint: "triage <URLs or pasted content> | help"
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows-owned tools, shared references, skill-local references, templates, workflow docs, and internal scripts resolve from `$SHIPGLOWS_ROOT`; project artifacts resolve from the current project governance root.

## Instruction Layering

This is the compact activation contract. Load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` before changing it. Detailed source intake and decisions live in `references/triage-playbook.md`; permitted persistence and reporting live in `references/persistence-and-reporting-playbook.md`.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before final reporting. When exactly one active chantier owns the run, append only this run to its `Skill Run History` and update `Current Chantier Flow`; otherwise do not write a spec. Evaluate `Chantier potentiel` using the shared threshold: a multi-domain/product/content/architecture decision routes to `/100-sg-spec`, never to an ambiguous spec.

## Mission

`205-sg-veille` owns external-source triage: it turns URLs or pasted material into bounded, evidence-aware options and waits for an explicit human decision before durable writes. It is not a research, content, marketing, documentation, or tracker-maintenance owner.

The shared source-intake contract owns the first classification pass. `205-sg-veille` must consume that pass, not reimplement project-fit inference, source typing, cache policy, or owner routing from scratch.

## Mode Detection

Only two public modes exist:

| Input | Resolved mode | Action |
| --- | --- | --- |
| `triage <sources>` | `triage` | Load `references/triage-playbook.md`. |
| bare URL or pasted text | `triage` | Announce the resolved mode, then load the same playbook. This preserves invocation compatibility without a second public identity or undocumented mode. |
| contextualized decision reply to visible triage | `triage` continuation | Load `references/persistence-and-reporting-playbook.md`; never use hidden session/global state. |
| `help` | `help` | Explain inputs, decision flow, and owner routes only. Do not fetch, read a source, write, or load a business playbook. |
| empty or unrecognized input | input recovery | Load `question-contract.md` and ask one question: `Colle les liens ou le contenu à analyser.` |

If a continuation cannot be tied unambiguously to triage visible in the conversation, ask the smallest recovery question or ask the operator to relaunch `triage`; do not persist anything.

Scenario anchors: `VEILLE-MODE-BARE-COMPAT`, `VEILLE-EMPTY-QUESTION`, and `VEILLE-HELP-NO-SIDE-EFFECT`.

## Conditional Loaders

- `question-contract.md`: before the one missing-input question or a decision question.
- `source-intake-classification.md`: for every external, marketplace, competitor, or ambiguous source; select only governed project context that changes classification. Treat this as the shared first pass.
- `editorial-content-corpus.md`: before any public-content, public-doc, claim, product, or surface recommendation.
- `task-registry-routing.md` and `operational-record-format.md`: before any authorized durable follow-up write.
- `master-delegation-semantics.md`: before delegated URL work; only read-only fetches may be parallel.
- `references/persistence-and-reporting-playbook.md`: only after an explicit decision or for final durable reporting.
- `reporting-contract.md`: before final output.

## Boundaries And Safety

- Route a settled cited investigation to `203-sg-research`; `205` gathers only minimum evidence needed to classify a source or justify a decision.
- Route content transformation/publication to `007-sg-content`, explicit marketing audits/studies to `009-sg-marketing`, docs creation/update to `300-sg-docs`, and general tracker maintenance to `011-sg-pilotage tasks`.
- Preserve exactly four scoring axes: contenu, architecture, concurrence & inspiration, opportunité collab. Scores are explainable triage aids, never proof or permission to write.
- Keep sources ephemeral until an explicit operator decision. Never expose secrets, tokens, cookies, private text, PII, sensitive screenshots, or a public raw-source cache.
- A declared content surface and claim-safe context are required before any editorial recommendation. Otherwise report `surface missing: blog` (or the relevant surface) and hand off; never invent a project, blog, task, report, or tracker anchor.
- Before an authorized write, re-read the target, recompute a moved anchor once, and apply the smallest patch. Stop if it remains ambiguous.

## Stop Conditions

Stop or reroute when source access, source proof, project ownership, declared public surface, claim safety, target anchor, or explicit decision is missing. Do not turn triage into deep research, automatic backlog creation, drafting, publishing, or tracker cleanup. Do not create a session file, global watchlist, source cache, or an `apply` mode.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before final reporting. Default to `report=user`: concise French output with source limits, options/decisions, owner handoffs, and `Chantier potentiel` when applicable. `report=agent`, `handoff`, `verbose`, or `full-report` may include scoring, decision history, persistence evidence, and unresolved gates.

## Validation

```bash
rg -n "Instruction Layering|Mission|Mode Detection|triage|help|source-intake-classification|Chantier potentiel|Boundaries|203-sg-research|007-sg-content|009-sg-marketing|300-sg-docs|011-sg-pilotage tasks|Validation" skills/205-sg-veille/SKILL.md
python3 -m unittest tools.test_205_sg_veille_contract
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
```
