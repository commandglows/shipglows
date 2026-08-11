# ShipGlows Main Portability Matrix

This matrix is the current public-packaging decision surface for `shipglows-main`.

Generated from:

```bash
python3 /home/claude/plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglows-main --matrix
```

Source corpus: `/home/claude/shipglows`

## Decision Summary

`shipglows-main` is partially bundled.

Public help has been folded into the `shipglows` plugin entrypoint through plugin-local references. The remaining execution candidates still assume a local ShipGlows source tree through `$SHIPGLOWS_ROOT`, `$HOME/.shipglows/runtime`, `shipglows_data/`, ShipGlows-owned `tools/`, or shared references that are not packaged inside the plugin.

The next implementation pass should reuse the public-entrypoint pattern: create plugin-local public contracts behind `shipglows`, include only execution-critical safe references, mark unbundled behavior honestly, and keep internal ShipGlows-specific behavior out of the public pack.

## Matrix

| Pack | Skill | Status | Finding type | Decision | Recommended action |
| --- | --- | --- | --- | --- | --- |
| `shipglows-main` | `000-shipglows` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `302-sg-help` | `partial` | source-root dependency | not public-bundlable yet | Keep internal numeric help out of the public plugin; expose public help through `shipglows` instead. |
| `shipglows-main` | `100-sg-spec` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `101-sg-ready` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `102-sg-start` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `103-sg-verify` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `105-sg-check` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |
| `shipglows-main` | `106-sg-fix` | `partial` | source-root dependency | not public-bundlable yet | Adapt before bundling: replace source-tree assumptions with plugin-local references, complete-corpus setup access, or explicit non-bundled status. |

## Porting Rule

Before a candidate skill moves from `planned` to bundled:

1. Replace direct `$SHIPGLOWS_ROOT` dependency with plugin-local references, when the reference is execution-critical and safe to publish.
2. Move long explanatory material to hosted docs only when it is optional for execution.
3. Keep full-corpus behavior behind the complete ShipGlows corpus setup script (`scripts/bootstrap_shipglows_repo.sh`) when the skill needs broad ShipGlows internals.
4. Keep internal operator workflows out of the public plugin.
5. Re-run:

```bash
python3 /home/claude/plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglows-main
python3 /home/claude/plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglows-main --matrix
```
