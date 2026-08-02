# ShipGlows Plugin

ShipGlows is the main local Codex plugin for packaging ShipGlows as a user-facing workflow layer.

This alpha intentionally ships a small nucleus:

- `skills/shipglows`: public entrypoint and pack router
- `skills/shipglows/references/public-help-catalog.md`: public help content used by the `shipglows` entrypoint
- `skills/shipglows/references/pack-catalog.md`: planned pack model
- `skills/shipglows/references/reference-strategy.md`: local-vs-hosted reference policy
- `skills/shipglows/references/shipglows-main-portability-matrix.md`: current `shipglows-main` bundle-readiness decision matrix
- `skills/shipglows/references/shipglows-main-intents.md`: public partial-mode intent contracts for `spec`, `ready`, `start`, `verify`, `check`, and `fix`
- `assets/docs-links.json`: optional hosted-docs link map
- `scripts/audit_shipglows_packaging.py`: local audit for deciding which private ShipGlows skills can be packaged next
- `scripts/bootstrap_shipglows_repo.sh`: optional clone/update helper for the full ShipGlows source tree
- `scripts/refresh_shipglows_pack.py`: one-command pack staging and validation helper

It does not copy the full ShipGlows skill tree into the plugin. Users who need the complete corpus can bootstrap the public repository locally instead of installing many plugin packs.

Execution-critical references stay local to the plugin. Hosted docs are optional support material for public explanation, tutorials, SEO, and paid-product upgrade paths.

## Local Development

Validate the plugin:

```bash
python3 ~/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py ~/plugins/shipglows
```

Audit local ShipGlows packaging readiness:

```bash
python3 ~/plugins/shipglows/scripts/audit_shipglows_packaging.py
python3 ~/plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglows-main --matrix
```

Stage one optional pack from the catalog:

```bash
python3 ~/plugins/shipglows/scripts/refresh_shipglows_pack.py shipglows-main
```

The staged pack is written to `~/.shipglows/staged-packs/<pack-id>/` by default and includes a `shipglows-pack-report.json` audit report. Shared references are copied outside `skills/` so the staged plugin remains structurally valid. Treat review findings as portability work before publishing.

Clone or update the sparse ShipGlows source tree:

```bash
~/plugins/shipglows/scripts/bootstrap_shipglows_repo.sh
```

The default target is `~/.shipglows/source`. The checkout includes the skill/runtime corpus and excludes the site, TUI app, archives, research folders, generated builds, and dependency directories.

Install from a repo-backed marketplace source:

```bash
codex plugin marketplace add dianedef/ShipGlows --ref main --sparse .agents/plugins --sparse plugins/shipglows
```

Then restart Codex, open the plugin directory, choose the `ShipGlows` marketplace, and install the `shipglows` plugin.

Start with:

```text
$shipglows help me choose the right workflow
```

For local development only, the personal marketplace path is still valid when the plugin lives outside the repo.
