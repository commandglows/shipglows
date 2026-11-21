---
name: shipglows
description: Route ShipGlows requests to the right métier owner.
---

# ShipGlows

## Mission

Canonical public router. Preserve `project -> business/brand/product -> outcome
-> surface -> work item`, the named specialist and authority through the handoff.

## Scope Gate

The engine selects the smallest safe route and continues in this conversation.

## Required References

A current first-person arrival/setup intent on this operator's new host/device,
addressed to ShipGlows with no more specific outcome (e.g. « je viens d'arriver
sur un nouvel ordi », new phone/tablet/VM), normalizes to init. Questions, quotes,
hypothetical/third-party discussion, project/repository onboarding and concrete
app/bug tasks merely mentioning a device do not. Clarify an ambiguous host versus
project environment before writes; preserve constraints/tags and init's authority limits.

Resolve `$SHIPGLOWS_ROOT` from the process. On Windows, if empty, read its
current-user environment value, then `%USERPROFILE%\.shipglows\development-channel.json`.
A valid absolute `channel: linked` root containing `skills/000-shipglows/SKILL.md`
wins before the installed default `$HOME/.shipglows/runtime`. Verify root and
engine, then load `$SHIPGLOWS_ROOT/skills/000-shipglows/SKILL.md`.
If missing or invalid, stop root-dependent work with a visible error; never fall
back to a sibling runtime path or a guessed checkout.
Explicit `init` without a valid runtime or filesystem access establishes device versus
execution host and consult/remote intent from exposed context, gives available guidance,
reports session-only progress and the missing root, and never claims persistence.
Local development uses the official bootstrap guidance
`https://shipglows.com/shipglows-script` (native Windows: `?format=powershell`);
installation mode/execution stay explicit. Discussing or implementing init never
initializes the current machine implicitly.

The engine owns conditional loaders (portfolio index, GSC,
`intent-to-outcome-autonomy.md`); do not preload alias tables, domain skills or every reference here.

## Validation

Keep one owner, proof and authority limits. Clear bounded requests do not authorize
a chantier. Material uncertainty or scope growth stops for an operator-owned decision.
The engine owns proof selection, including content-only changes.

## Stop Conditions

Stop for missing canonical contracts or unresolved authority; never guess a fallback.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting.
Default to concise active-language output; agent detail requires explicit request.
Continue safely agent-runnable authorized work before returning control.
