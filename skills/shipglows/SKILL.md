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

Normalize a current first-person arrival/setup intent on this operator's new
host/device, addressed to ShipGlows with no more specific outcome (e.g. « je viens
d'arriver sur un nouvel ordi », new phone/tablet/VM), to init. Questions, quotes,
hypothetical/third-party discussion, project/repository onboarding and concrete
app/bug tasks merely mentioning a device do not trigger it. Clarify an ambiguous
host versus project environment before writes. Preserve constraints/tags and init's
existing authority limits.

For explicit `init` on a host without filesystem access, establish the device versus
execution host and consult/remote intent from exposed context; provide available
guidance and report session-only progress. Finish this portable branch without root
resolution; do not require installation for consult or claim persistence. Other
init work uses the verified engine below.

Resolve `$SHIPGLOWS_ROOT` from the process. On Windows, if empty, read its
current-user environment value, then `%USERPROFILE%\.shipglows\development-channel.json`.
A valid absolute `channel: linked` root containing `skills/000-shipglows/SKILL.md`
wins before the installed default `$HOME/.shipglows/runtime`. Verify root and
engine, then load `$SHIPGLOWS_ROOT/skills/000-shipglows/SKILL.md`.
If missing or invalid, stop root-dependent work with a visible error; never fall
back to a sibling runtime path or a guessed checkout. Explicit init can still use
its portable guidance below.
For explicit `init` with no valid runtime, continue available consult/remote guidance
and report the missing root for dependent work. Local development uses the official
bootstrap guidance `https://shipglows.com/shipglows-script` (native Windows:
`?format=powershell`); installation mode/execution stay explicit.
Discussing or implementing init never initializes the current machine implicitly.

The engine owns conditional loaders; do not preload alias tables, domain skills
or every reference here. For non-trivial outcomes it loads
`$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`.

Exception: when the request mentions the operator's projects or pitches ("mes
projets", "mes pitchs", "par projet", a project name), read
`$SHIPGLOWS_PRIVATE_DATA_DIR/projects/index.md` first — the portfolio index is
standing read-only context, no namespace or capability gate.

## Validation

Keep one owner, proof and authority limits. Clear bounded requests do not authorize
a chantier. Material uncertainty or scope growth stops for an operator-owned decision.
Content-only changes prove by frontmatter/schema conformity and locale parity; never run a
build, type check, lint, or test for them unless code also changed or the operator asks.

## Stop Conditions

Stop for missing canonical contracts or unresolved authority; never guess a fallback.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting.
Default to concise active-language output; agent detail requires explicit request.
Continue safely agent-runnable authorized work before returning control.
