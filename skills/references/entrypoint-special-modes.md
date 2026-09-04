---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: entrypoint-special-modes
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Approved progressive loading pilot preserves the existing behavior in directly selected references."
next_review: "2026-10-05"
next_step: none
---

# Entrypoint Special Modes

Load only for update, context, auto, hygiene or execution-posture compatibility.
Apply only the selected mode; this is never an eager bundle.

An explicit request to update ShipGlows resolves the active installation
channel first with `shipglows update status`, then uses `shipglows update`.
For a valid linked developer channel, skills are live from the checkout and a
new Codex or Claude session reloads them; never tell the operator to reinstall
the skills merely because source changes were pushed. Stop before update if the
channel is invalid, the checkout is dirty, or its upstream is unresolved.

`shipglows context` is a direct read-only context refresh. The canonical router is already loaded; load `agent-runtime-awareness.md`, read
`%USERPROFILE%\.shipglows\environment.md`, resolve
the current ShipGlows-managed project root, and read
`<project-root>\ENVIRONMENT.md` plus the matching DevServer registry entry. Report the exact managed URL and live status,
architecture, Python availability through `uv`, Playwright/Chromium installation
and MCP verification evidence, the relevant mobile and Windows toolchain state
and exact next action, and current-turn callable tools. For Flutter, also report
the registry-backed active development target, resolved device id when applicable,
managed session mode, logical `flutter run -d <device>` command, and live state;
list available targets separately. Distinguish
installed, configured, discovered, callable, failed, and not-exposed states;
inspect direct and deferred/searchable tool catalogs before classifying them. Never
launch a replacement server, substitute an Astro/Vite default such as `4321`,
or call recorded Python or configured Playwright absent merely because its tool
is missing from the first visible list. End with a compact `Contexte actif`
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


For the selected Auto mode, load `no-local-execution-policy.md` always and implicitly.
