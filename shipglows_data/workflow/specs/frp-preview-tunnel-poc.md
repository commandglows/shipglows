---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "ShipGlows"
created: "2026-05-11"
created_at: "2026-05-11 09:48:06 UTC"
updated: "2026-07-13"
updated_at: "2026-07-13 09:35:38 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "FRP preview tunnel POC"
owner: "Diane"
confidence: "high"
user_story: "En tant qu'operateur ShipGlows, je veux tester FRP comme couche de tunnel preview isolee, afin de savoir s'il peut remplacer ou completer les tunnels SSH locaux sans affaiblir la securite."
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "config.sh"
  - "install.sh"
  - "lib.sh"
  - "shipglows.sh"
  - "local/dev-tunnel.sh"
  - "local/README.md"
  - "shipglows_data/technical/runtime-cli.md"
  - "README.md"
depends_on:
  - artifact: "README.md"
    artifact_version: "0.10.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/runtime-cli.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "local/README.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes: []
evidence:
  - "User requested a ShipGlows FRP POC/spec, then removal of FRP from the active research report."
  - "ShipGlows currently manages local access through SSH tunnels in local/dev-tunnel.sh."
  - "README.md describes app exposure through Caddy/DuckDNS and local access through SSH tunnel tooling."
  - "FRP official README describes FRP as a fast reverse proxy that exposes local servers behind NAT/firewall to the internet."
  - "FRP official README documents TCP, UDP, HTTP, HTTPS, STCP, SUDP, XTCP and TCPMUX proxy types."
  - "FRP release v0.68.1, dated 2026-04-13, fixes a configuration-dependent authentication bypass in HTTP proxy mode when routeByHTTPUser is used with httpUser/httpPassword."
next_step: "/sg-ready FRP preview tunnel POC"
---

# Title

FRP preview tunnel POC

# Status

Draft. No implementation has been started.

# User Story

En tant qu'operateur ShipGlows, je veux tester FRP comme couche de tunnel preview isolee, afin de savoir s'il peut remplacer ou completer les tunnels SSH locaux sans affaiblir la securite.

# Minimal Behavior Contract

ShipGlows doit pouvoir lancer un POC FRP completement optionnel qui expose une app locale ou distante sur une URL de preview controlee, avec authentification explicite, logs consultables et nettoyage automatique. Si FRP n'est pas installe, mal configure, non joignable, ou si une regle de securite echoue, ShipGlows doit refuser l'exposition publique et laisser le systeme actuel de tunnels SSH/Caddy intact. Le cas facile a oublier est la collision ou la persistance d'un tunnel apres arret de l'app: le POC doit prouver que le tunnel s'arrete ou devient inoffensif quand l'app n'est plus exposee.

# Success Behavior

Un succes du POC est observable quand un operateur lance une commande ou un menu ShipGlows de test, demarre un `frps` sur un serveur controle, demarre un `frpc` pour une app ShipGlows existante, obtient une URL de preview, ouvre cette URL, voit l'app cible, consulte les logs FRP/ShipGlows, puis arrete le tunnel et verifie que l'URL ne repond plus. Le systeme doit conserver le fonctionnement actuel de `local/dev-tunnel.sh` et ne doit pas remplacer les tunnels SSH existants pendant le POC.

# Error Behavior

En cas de binaire FRP absent, token manquant, port public indisponible, domaine preview non reserve, echec de connexion `frpc -> frps`, collision de nom, app locale non prete, ou controle auth invalide, le POC doit afficher une erreur actionnable, ne pas ouvrir de port public inutile, ne pas modifier les tunnels SSH existants, ne pas logguer de secret, et laisser un etat nettoyable par une commande d'arret. Si un comportement FRP contredit la posture de securite ShipGlows, le chantier doit s'arreter avant integration.

# Problem

ShipGlows sait deja exposer et acceder aux apps via PM2, Caddy, DuckDNS et tunnels SSH locaux. Ce modele marche, mais il depend de la connectivite SSH et d'un routage local. FRP pourrait apporter des previews plus flexibles derriere NAT/firewall, mais il introduit une surface reseau supplementaire et une responsabilite d'authentification forte.

# Solution

Creer un POC isole qui installe ou detecte FRP, lance un serveur `frps` experimental, lance un client `frpc` pour une seule app ShipGlows cible, expose une URL preview controlee, puis documente les resultats. Le POC doit rester derriere un flag explicite et ne pas devenir le chemin par defaut tant que la readiness securite n'est pas validee.

# Scope In

- Ajouter une configuration experimentale FRP desactivee par defaut.
- Definir les variables ShipGlows necessaires: enable flag, serveur FRP, ports, domaine/subdomain preview, token/auth, chemins de config et logs.
- Creer des helpers POC pour demarrer, arreter, statut, logs et cleanup FRP.
- Tester une seule app web ShipGlows sur un port PM2 existant.
- Comparer le comportement avec `local/dev-tunnel.sh`.
- Documenter la procedure POC et les criteres de rejet.

# Scope Out

- Remplacer les tunnels SSH existants.
- Activer FRP par defaut.
- Exposer plusieurs apps en production.
- Gerer automatiquement DNS public en production.
- Stocker ou afficher des tokens FRP dans les logs.
- Supporter Windows/PowerShell dans la premiere version.
- Garantir compatibilite avec toutes les options FRP avancees.

# Constraints

- Le POC doit etre reversible sans toucher aux flows SSH existants.
- FRP doit etre pinne a une version explicite, avec hash verifie si le binaire est telecharge.
- Les secrets FRP doivent vivre sous `$SHIPGLOWS_SECRETS_DIR` avec permissions restrictives.
- Les configs runtime doivent vivre sous `$SHIPGLOWS_RUNTIME_DIR` ou un sous-dossier dedie.
- Le POC doit refuser les hostnames/domaines non explicites.
- Le POC ne doit jamais exposer une app si l'app cible n'ecoute pas sur localhost.

# Dependencies

- ShipGlows shell stack: `config.sh`, `lib.sh`, `install.sh`, `local/dev-tunnel.sh`.
- PM2 app inventory and existing port allocation from `lib.sh` / PM2 ecosystem files.
- User-mode Caddy remains independent during the POC.
- FRP official project: <https://github.com/fatedier/frp>.
- FRP official release evidence: <https://github.com/fatedier/frp/releases>.
- Fresh External Docs: `fresh-docs checked`. Official GitHub README and releases were consulted on 2026-05-11. Current release evidence shows `v0.68.1` dated 2026-04-13 with an auth bypass fix in HTTP proxy mode.

# Invariants

- Existing SSH tunnel behavior remains unchanged.
- Existing Caddy behavior remains unchanged.
- Existing PM2 port allocation remains source of truth for app target ports.
- No secret is printed to stdout, logs, reports, or generated configs shown to the user.
- A failed POC must be recoverable with one cleanup command.

# Links & Consequences

- `config.sh`: add experimental FRP env vars only.
- `install.sh`: optionally detect/install FRP only if the POC requires it; no automatic production enablement.
- `lib.sh`: likely home for shared FRP helper functions if implementation proceeds.
- `local/dev-tunnel.sh`: comparison point and possible future UX bridge, but not modified unless the POC explicitly adds a menu entry.
- `local/README.md`: must document the distinction between SSH tunnels, OAuth callback tunnels, and FRP preview tunnels.
- `README.md`: must mention FRP only as experimental if the POC lands.
- Security consequence: public exposure path changes from operator-local SSH forwarding to server/client reverse proxy, so auth and lifecycle cleanup become blocking gates.

# Documentation Coherence

Docs impact is required if the POC is implemented:

- Update `local/README.md` with experimental FRP setup, cleanup, and risk notes.
- Update `README.md` only with an experimental mention, not a general product claim.
- Add troubleshooting notes for auth failure, port collision, stale tunnel, and unreachable app.
- Do not market FRP as production-ready until `/sg-verify` validates the POC.

# Edge Cases

- FRP client remains running after PM2 app stops.
- Two apps request the same preview subdomain.
- FRP server is reachable but auth token is wrong.
- FRP server accepts connection but upstream app returns 502/connection refused.
- Public domain routes to the wrong app after restart.
- Operator runs cleanup while another POC tunnel is active.
- FRP release changes security defaults or config syntax.
- HTTP proxy auth is misconfigured in a way related to the v0.68.1 auth bypass fix.

# Implementation Tasks

- [ ] Task 1: Add experimental FRP configuration defaults
  - File: `config.sh`
  - Action: Add disabled-by-default env vars for FRP enable flag, binary path/version, server address, bind ports, auth token file, runtime config dir, log dir, preview domain, and allowed app scope.
  - User story link: Keeps the POC explicit and reversible.
  - Depends on: None
  - Validate with: Source `config.sh` and confirm defaults do not enable FRP.
  - Notes: Do not put secret values directly in env defaults.

- [ ] Task 2: Add FRP binary detection and version check
  - File: `lib.sh`
  - Action: Add helper functions to detect `frps`/`frpc`, read versions, and compare against the pinned POC version.
  - User story link: Prevents unknown binary behavior.
  - Depends on: Task 1
  - Validate with: Run helper against missing and present binaries.
  - Notes: If install is added later, verify release checksum before use.

- [ ] Task 3: Generate isolated FRP runtime configs
  - File: `lib.sh`
  - Action: Generate `frps.toml` and `frpc.toml` under ShipGlows runtime dirs with restrictive permissions and without printing secrets.
  - User story link: Provides a reproducible preview tunnel without mutating global config.
  - Depends on: Task 1, Task 2
  - Validate with: Inspect generated config permissions and redacted logs.
  - Notes: Prefer TOML because recent FRP errors report TOML line/column details.

- [ ] Task 4: Add POC lifecycle commands
  - File: `lib.sh`
  - Action: Add start, stop, status, logs, and cleanup helpers for one app/port.
  - User story link: Makes success and failure observable.
  - Depends on: Task 3
  - Validate with: Start/stop one test app and verify URL opens then closes.
  - Notes: Cleanup must target only ShipGlows-managed FRP POC processes.

- [ ] Task 5: Add a guarded menu or shortcut entry
  - File: `shipglows.sh` or menu files selected during implementation
  - Action: Expose the POC only when `SHIPGLOWS_FRP_EXPERIMENTAL=true`.
  - User story link: Lets operators run the POC intentionally.
  - Depends on: Task 4
  - Validate with: Disabled flag hides/refuses FRP, enabled flag shows/runs FRP.
  - Notes: Avoid adding FRP to normal happy-path deployment menus yet.

- [ ] Task 6: Document the POC and rollback
  - File: `local/README.md`
  - Action: Document FRP preview setup, when to use it, when not to use it, cleanup command, and security caveats.
  - User story link: Makes the operator workflow repeatable.
  - Depends on: Task 4
  - Validate with: Follow docs on a clean test machine or dry-run environment.
  - Notes: Keep this clearly labeled experimental.

- [ ] Task 7: Record POC findings
  - File: `research/frp-preview-tunnel-poc-results.md`
  - Action: Write a short result report after the POC with latency, setup friction, security observations, failure modes, and go/no-go recommendation.
  - User story link: Turns the experiment into a decision.
  - Depends on: Task 4, Task 6
  - Validate with: Report includes pass/fail evidence and recommendation.
  - Notes: This is required before any production integration spec.

# Acceptance Criteria

- [ ] CA 1: Given FRP is disabled, when ShipGlows starts normally, then no FRP process, port, menu action, or config is created.
- [ ] CA 2: Given FRP is enabled and a valid test app is online, when the POC starts, then a preview URL reaches the target app and logs show the managed tunnel.
- [ ] CA 3: Given the target app is stopped, when the POC starts, then ShipGlows refuses or reports a clear upstream-not-ready state without exposing a misleading success.
- [ ] CA 4: Given an invalid FRP token, when `frpc` connects to `frps`, then the POC fails closed and does not expose the app.
- [ ] CA 5: Given two apps request the same preview name, when the second tunnel starts, then ShipGlows rejects the collision before changing active routing.
- [ ] CA 6: Given the operator runs cleanup, when managed FRP processes exist, then only ShipGlows-managed FRP POC processes stop and existing SSH tunnels remain running.
- [ ] CA 7: Given logs are inspected, when configs include auth material, then secrets are redacted or absent from displayed output.
- [ ] CA 8: Given POC evidence is collected, when `/sg-verify` runs, then the decision is either proceed to production spec, keep experimental, or reject FRP.

# Test Strategy

- Unit-style shell checks for config defaults, path validation, port validation, and process selection.
- Manual integration test with one PM2 app on localhost.
- Negative tests for missing binary, bad token, occupied preview name, stopped upstream, and cleanup.
- Security review focused on token storage, process args, logs, public bind ports, and v0.68.1 auth bypass context.
- Regression check that `local/dev-tunnel.sh` still creates SSH tunnels before and after FRP POC.

# Risks

- High security risk: FRP creates a public ingress path and must fail closed.
- Auth risk: latest official release evidence includes an auth bypass fix for a specific HTTP proxy configuration; ShipGlows must avoid relying on fragile proxy auth combinations.
- Operational risk: stale tunnels could expose old apps if cleanup is weak.
- DNS/routing risk: preview host collision could route traffic to the wrong app.
- Scope creep risk: FRP should not become production infra before a separate verified integration spec.

# Execution Notes

- Read first: `config.sh`, `lib.sh`, `local/dev-tunnel.sh`, `local/README.md`, `README.md`.
- Keep FRP behind `SHIPGLOWS_FRP_EXPERIMENTAL=true`.
- Prefer one command path for the POC before adding menu UX.
- Do not modify Caddy or DuckDNS during the first POC unless the implementation proves domain routing needs it.
- Stop condition: any secret leakage, unauthenticated public exposure, or inability to reliably cleanup managed processes blocks promotion.
- Stop condition: if FRP docs or release notes conflict with planned config syntax, reroute through `/sg-research` before coding.
- Validation command candidates: shellcheck if available, one dry-run config generation, one real start/stop on a disposable app, and one SSH tunnel regression check.

# Open Questions

- Should the first POC use a dedicated public test domain/subdomain, or only a raw server port?
- Should FRP run on the same ShipGlows server, or on a separate tunnel broker host?
- Should install support download FRP automatically, or should the POC require a preinstalled binary?
- Should preview URLs be authenticated at FRP level, Caddy level, or both?

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-11 09:48:06 UTC | sf-spec | GPT-5 Codex | Created FRP preview tunnel POC spec from user request and official FRP docs evidence. | Draft saved. | /sg-ready FRP preview tunnel POC |

# Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | done | Draft created for isolated FRP POC. |
| sf-ready | not launched | Validate security gates, docs freshness, and open questions. |
| sf-start | not launched | Do not implement before readiness. |
| sf-verify | not launched | Must verify tunnel cleanup and security behavior after POC. |
| sf-end | not launched | Close only after POC result report. |
| sf-ship | not launched | Not applicable until implementation is verified. |

Next command: `/sg-ready FRP preview tunnel POC`
