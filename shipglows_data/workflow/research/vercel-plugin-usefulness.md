---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-18"
updated: "2026-07-18"
status: reviewed
source_skill: 203-sg-research
scope: "usefulness of vercel/vercel-plugin alongside ShipGlows Vercel MCP and CLI"
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
source_count: 3
depends_on: []
supersedes: []
evidence:
  - "https://vercel.com/docs/agent-resources/vercel-plugin"
  - "https://github.com/vercel/vercel-plugin"
  - "https://vercel.com/plugin"
next_step: "Decide whether to install the official Vercel plugin on the Codex/Claude agent hosts, with telemetry disabled if adopted."
---

# Research: Vercel Plugin Usefulness for ShipGlows

> Generated 2026-07-18 — Sources: 3

## Executive Summary

`vercel/vercel-plugin` is useful as a complementary, optional agent plugin for ShipGlows contributors who build or maintain Vercel/Next.js applications. It brings current Vercel platform guidance, targeted skills, commands, and deprecation guidance; it does not replace the existing Vercel MCP account tools or the installed Vercel CLI. [Vercel Plugin docs](https://vercel.com/docs/agent-resources/vercel-plugin)

Recommendation: install it on the shared coding-agent host only if ShipGlows wants Vercel-specific coding guidance by default for Vercel/Next.js work. Preserve the current MCP-on-demand policy for account actions, keep the CLI as fallback, and set `VERCEL_PLUGIN_TELEMETRY=off` before adoption unless daily anonymous usage telemetry is explicitly acceptable. [Plugin README](https://github.com/vercel/vercel-plugin)

## Existing ShipGlows Position

ShipGlows already provides:

- Vercel CLI, used for deploy, environment, logs, and other direct operational commands.
- Vercel MCP at `https://mcp.vercel.com`, registered but disabled by default and enabled for sessions that need provider/account evidence.
- A deployment rule that prefers the MCP for deployment truth when it is available, with the CLI as practical fallback.

The plugin fills a separate gap: it supplies current Vercel implementation knowledge before or while code is written. Vercel explicitly describes the plugin and MCP as complementary: the plugin provides knowledge and skills, while the MCP acts on the Vercel account. [Vercel Plugin page](https://vercel.com/plugin)

## What the Plugin Adds

- A Vercel ecosystem knowledge graph and 28 focused skills, including Next.js, CLI, deployments/CI, environment variables, functions, routing, storage, security, and verification. [Vercel Plugin docs](https://vercel.com/docs/agent-resources/vercel-plugin)
- Three specialised agent profiles and five commands: bootstrap, deploy, environment management, status, and Marketplace discovery. [Vercel Plugin docs](https://vercel.com/docs/agent-resources/vercel-plugin)
- Lightweight session-start activation only for empty directories and detected Vercel or Next.js projects; skills remain available on demand rather than being injected for every prompt/tool call. [Vercel Plugin docs](https://vercel.com/docs/agent-resources/vercel-plugin)
- Guidance intended to prevent deprecated APIs and sunset packages, plus a plugin-maintained upstream synchronization model for selected skills. [Plugin README](https://github.com/vercel/vercel-plugin)

## Fit and Limits

| Need | Existing ShipGlows capability | Plugin contribution |
| --- | --- | --- |
| Account deployment state, projects, logs | Vercel MCP | None; MCP remains primary |
| Direct deploy, environment, and log commands | Vercel CLI | Commands and current workflow guidance, but no replacement for CLI authority |
| Current Vercel/Next.js coding conventions | Internal notes plus manual docs research | Strong complement: maintained knowledge and targeted skills |
| ShipGlows Bash CLI, Flox, PM2, Caddy, Flutter workflows | ShipGlows skill corpus | No material coverage benefit |
| Cross-agent use (Codex and Claude Code) | Separate local configurations today | One official plugin supports both tools |

The plugin has a real overlap with ShipGlows deployment guidance, especially deployment, environment, and verification. It should therefore be treated as a provider-reference layer, not a new workflow owner: ShipGlows should retain its own routing, proof rules, and safety requirements.

## Security and Operations

The plugin requires Node.js 18+ and Bun according to its official documentation. It enables a once-per-day telemetry event by default; Vercel documents `VERCEL_PLUGIN_TELEMETRY=off` as the opt-out and states that prompt text, Bash commands, and tool-call contents are not collected. [Vercel Plugin docs](https://vercel.com/docs/agent-resources/vercel-plugin)

Adopting it still means accepting third-party hook code and an additional frequently updated skill source in agent sessions. Validate its behavior first with its documented doctor command and restrict initial adoption to a non-production or personal agent configuration. [Plugin README](https://github.com/vercel/vercel-plugin)

## Recommendation

Adopt the plugin as an opt-in or pilot dependency for Vercel/Next.js project work, not as a mandatory ShipGlows-wide runtime dependency.

1. Install it on one Codex/Claude host and disable telemetry before the first agent session.
2. Keep Vercel MCP disabled by default and enable it only for provider/account actions, as ShipGlows does now.
3. Keep the Vercel CLI available for explicit operational commands and fallback evidence.
4. Do not duplicate plugin content into ShipGlows skills; retain ShipGlows rules for deployment ownership, hosted proof, security, and project governance.

## Sources

- [Vercel Plugin documentation](https://vercel.com/docs/agent-resources/vercel-plugin) — official installation, supported agents, skills, hooks, commands, telemetry, and debugging details.
- [Vercel Plugin repository](https://github.com/vercel/vercel-plugin) — official repository architecture, skill inventory, hook behavior, telemetry details, and upstream synchronization.
- [Vercel Plugin overview](https://vercel.com/plugin) — official distinction between the plugin and Vercel MCP.

## Chantier potentiel

Chantier potentiel: incertain
Titre proposé: Intégration pilotée du plugin Vercel aux postes agents
Raison: une adoption partagée change la chaîne d’outils des agents, leurs hooks et le paramétrage de confidentialité ; l’intérêt dépend de la fréquence réelle des tâches Vercel/Next.js.
Sévérité: P3
Scope: configuration Codex/Claude des hôtes agents, documentation d’installation et politique de télémétrie.
Evidence:
- Le plugin ajoute 28 skills et des hooks de session, sans remplacer le MCP ou la CLI existants.
- La télémétrie quotidienne est active par défaut, avec un opt-out documenté.
Formalisation recommandée: oui — si l’adoption dépasse un essai individuel.
