---
name: shipglows
description: Route ShipGlows requests to the right métier owner.
---

# ShipGlows

## Mission

`shipglows` is the canonical public router: it resolves the operator's outcome to one public owner and preserves that ownership through internal handoffs.

## Scope Gate

Use this as the canonical public router. Resolve `project -> business/brand/product -> outcome -> surface -> work item`, load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`, and select the public métier owner without asking the operator to choose an internal skill.

An explicit request to develop or maintain ShipGlows itself, install its "version dev", or prepare an editable owner checkout is a maintainer-workstation intent. Preserve that exact meaning; never normalize it to a generic project development runtime, `full`, `all`, or sparse skills corpus.

## Required References

For detailed routing and authority rules, resolve `$SHIPGLOWS_ROOT` through the shared canonical-path doctrine. On Windows, do not rely only on the current process environment: when `SHIPGLOWS_ROOT` is empty, read its current-user environment value, then inspect `%USERPROFILE%\.shipglows\development-channel.json`. A valid `channel: linked` state with an absolute `root` and the required canonical engine selects that developer checkout before the installed-runtime default. This handles coding-agent hosts that were already running when the developer channel was enabled. Verify the resolved root and `$SHIPGLOWS_ROOT/skills/000-shipglows/SKILL.md` exist, then load that canonical engine. If every canonical source is missing or invalid, stop with a visible error; never fall back to a sibling runtime path or repository by filename coincidence. Retain the operator's outcome through the handoff; the numbered skill is an expert/legacy engine, not a public command to return to the operator.

In Codex, short expert modes such as `shipglows core` are resolved through the
canonical public owner and owner mode before an internal engine is selected;
they are not shell CLI commands. The aliases own no workflow behavior. `core`
is the sole hard context switch and binds the entire remaining instruction to
ShipGlows system work. `shipglows capture` and `shipglows tmux` both resolve to
`sg-content capture`. `shipglows git` resolves to `sg-engineering github` for
manual PR, branch, and worktree hygiene; its default is read-only.
`shipglows hygiene` audits all maintenance families in the current project
without mutation, while `shipglows hygiene git` selects the safe Git cleanup
workflow. Neither alias is a shell command.

An explicit request to update ShipGlows resolves the active installation
channel first with `shipglows update status`, then uses `shipglows update runtime`.
For a valid linked developer channel, skills are live from the checkout and a
new Codex or Claude session reloads them; never tell the operator to reinstall
the skills merely because source changes were pushed. Stop before update if the
channel is invalid, the checkout is dirty, or its upstream is unresolved.

`shipglows context` is a direct read-only context refresh. Load the canonical
`000-shipglows` engine and `agent-runtime-awareness.md`, read
`%USERPROFILE%\.shipglows\environment.md`, resolve
the execution envelope and current ShipGlows-managed surface, and read
its surface-level `ENVIRONMENT.md` plus the matching DevServer registry entry. Report the agent surface, terminal host, session location, machine kind, exact managed URL and live status,
architecture, Python availability through `uv`, Playwright/Chromium installation
and MCP verification evidence, the relevant mobile and Windows toolchain state
and exact next action, and current-turn callable tools. For Flutter, also report
the registry-backed active development target, resolved device id when applicable,
managed session mode, logical `flutter run -d <device>` command, and live state;
list available targets separately. Distinguish
installed, configured, discovered, transport reachable, callable, failed, and not-exposed states;
inspect direct and deferred/searchable tool catalogs before classifying them. Never
launch a replacement server, substitute an Astro/Vite default such as `4321`,
or call recorded Python or configured Playwright absent merely because its tool
is missing from the first visible list. Current registry `status` outranks stale Flutter startup/process fields. A contradiction or native transport failure triggers a targeted refresh before verdict; identify the exact owning host and never give a vague restart instruction. A standalone Codex CLI may discover Computer Use without receiving the Codex Desktop native pipe. Run the canonical per-repository Git-policy
resolver `$SHIPGLOWS_ROOT/tools/project_git_policy.py` and include the effective task-branch and worktree creation policies,
their source, any fail-closed default reason, and the guidance that `forbidden` prevents silent creation but can be changed after discussing a justified need with the user in `Contexte actif`. End with a compact `Contexte actif`
summary.

`shipglows auto [scope or horizon]` is the public autonomous credit-window
mode. The canonical router hands it to internal `708-sg-auto`, which freezes the
current project root, prioritizes safe evidence-backed work by durable value per
wall-clock minute, recommends subagents for independent useful missions, and
always applies the shared no-local-execution policy implicitly. It has no
local-execution override, never forces reasoning or agents to consume credits,
never self-activates Fast, and never promises exact credit exhaustion.

`#local`, `#nolocal`, and `#ci` are transversal execution posture tags, not
métier modes. Load `execution-posture-tags.md` whenever one appears. `#local`
permits proportional local proof without forcing it; `#nolocal` applies the
no-local-execution policy; `#ci` implies `#nolocal` and records existing CI as
the deferred proof destination without authorizing push, dispatch, deploy, or
another external write. Conflicting tags fail closed. The legacy
`shipglows nolocal <objective>` spelling remains accepted and normalizes to
`shipglows <objective> #nolocal` with ordinary métier ownership and mutation
approval.

## Validation

Confirm that one public owner matches the resolved outcome, preserves any named specialist scope, and receives the target hierarchy and authority limits.

## Stop Conditions

Stop only for a material unresolved outcome, authority boundary, or scope conflict; ask the smallest operator-owned decision rather than exposing internal routing choices.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to concise user-facing routing and outcome; use `report=agent` only for an explicit detailed handoff, without exposing internal engines as operator actions.
