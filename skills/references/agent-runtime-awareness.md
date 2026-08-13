---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "3.0.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/install-devserver.ps1
depends_on: []
supersedes: []
evidence:
  - "The Windows installer writes the global development environment file."
  - "Each managed project exposes its durable assigned URL in a visible, versioned ENVIRONMENT.md file."
  - "The Windows DevServer registry remains the live status authority."
next_review: "2026-09-13"
next_step: "/103-sg-verify Windows runtime awareness"
---

# Agent Runtime Awareness

Before work depends on a local server or runtime-specific tool on Windows:

1. Read `%USERPROFILE%\.shipglows\environment.md` for the global development environment.
2. Resolve the registered project root from the current directory and read `<project-root>\ENVIRONMENT.md` for its durable ShipGlows-assigned URL.
3. Read the matching entry in `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json` for live `running`, `starting`, `stopped`, or `error` status.
4. Use the assigned URL only while that registry entry is `running` or `starting`.

Do not derive the URL from `package.json`, framework defaults such as Astro/Vite `4321`, a remembered port, or another project. `.shipglows.env` remains the optional committed runtime-policy file; it is not the environment summary or live-state authority.

ChatGPT apps/connectors and Codex CLI tools are separate surfaces. The global file describes what ShipGlows installed or configured, but only the tools exposed by the current host turn are callable. If Playwright is configured but unavailable in the turn, report `Playwright configuré, outil non exposé dans ce tour`.

If a source is missing or contradicts another source, stop only the dependent action and report the mismatch. Do not launch a second server to guess the URL. Durable assignment comes from `ENVIRONMENT.md`; live state comes from the registry.

Operator redirect:

```text
Lance `$shipglows context`. Lis %USERPROFILE%\.shipglows\environment.md,
<racine-projet>\ENVIRONMENT.md et l'état live du registre ShipGlows. Utilise
uniquement l'URL attribuée à ce projet et les outils exposés par le tour courant.
```
