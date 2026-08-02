# Conversation shipglows - :shipglows help

- Captured at: `2026-06-11 16:45:09 UTC`
- tmux session: `0`
- tmux source: `current pane`
- tmux window index: `:14`
- tmux pane index: `.1`
- tmux window name: `node`

/home/claude/home/claude/home/claude

⚠ Heads up, you have less than 10% of your 5h limit left. Run /status
  for a breakdown.

╭──────────────────────────────────────────────────────────╮
│ >_ OpenAI Codex (v0.139.0)                               │
│                                                          │
│ model:     gpt-5.3-codex-spark medium   /model to change │
│ directory: ~                                             │
╰──────────────────────────────────────────────────────────╯

  Tip: Use /side to start a side conversation in a temporary fork
  without polluting the main thread.


› $shipglows:shipglows help


• Fetching the ShipGlows plugin help catalog now and returning the
  built-in operator-facing help for $shipglows including what you can
  route through this plugin.

• Explored
  └ Read public-help-catalog.md

──────────────────────────────────────────────────────────────────────

• ShipGlows help summary (public plugin):

  - Entrypoint: shipglows (current public route: $shipglows <what I want
    to accomplish>)

  - What’s available now:
      - Explain the one-plugin model
      - Show pack catalog / planned packs
      - Explain pack status (bundled now, partial, planned, requires
        complete corpus)

      - Clarify where workflows are incomplete vs available
      - Run local packaging readiness audit (if local ShipGlows source
        exists)

      - Offer complete-corpus setup path (with your approval)

  - Bundle status (public):
      - Bundled now: shipglows public entrypoint + local references for
        help/routing/docs + packaging workflow guidance

      - shipglows-main is partial: routing/help exists, execution
        workflows are still planned

      - Planned packs: shipglows-build, shipglows-proof, shipglows-
        content, shipglows-design, shipglows-quality, shipglows-product

      - Internal-only: governance/Core-style operator workflows (not
        part of public plugin surface)

  - Example next commands:
      - $shipglows help
      - $shipglows show available packs
      - $shipglows explain shipglows-main
      - $shipglows install complete ShipGlows corpus

  Tell me what you want to accomplish and I’ll route it to the right
  ShipGlows path.

──────────────────────────────────────────────────────────────────────


› $shipglows:shipglows packs


• Reading the pack catalog reference and returning a concise pack-by-
  pack status for installed/available/planned options.

• Explored
  └ Read pack-catalog.md

──────────────────────────────────────────────────────────────────────

• Pack catalog status ($shipglows packs):

  - Current plugin status: shipglows entrypoint is bundled now;
    optional packs are not yet installed in this environment.

  - shipglows (core): bundled now.
  - shipglows-main: partial (help/routing available via shipglows;
    execution workflows still pending packaging).

  - shipglows-build: planned.
  - shipglows-proof: planned.
  - shipglows-content: planned.
  - shipglows-design: planned.
  - shipglows-quality: planned.
  - shipglows-governance: internal-first.
  - shipglows-product: planned.

  No automatic action was taken for this request.

  If you want, I can route you to a specific pack next (for example:
  “$shipglows help” vs “$shipglows [pack name]” request).

──────────────────────────────────────────────────────────────────────


› $shipglows:shipglows shipglows-main


• I’ll load the shipglows-main portability matrix reference now and
  return the exact pack state plus what can be executed from this
  public install.

• Explored
  └ Read shipglows-main-portability-matrix.md

──────────────────────────────────────────────────────────────────────

• shipglows-main status

  - Pack ID: shipglows-main
  - State: partial / not public-bundlable yet
  - Relevant skills: 000-shipglows, 302-sg-help, 100-sg-spec, 101-sg-
    ready, 102-sg-start, 103-sg-verify, 105-sg-check, 106-sg-fix

  - Why: these still depend on local ShipGlows source-tree assumptions
    ($SHIPGLOWS_ROOT, $HOME/shipglows, shipglows_data/, ShipGlows tools/,
    and shared private references), so they are currently only routed
    conceptually, not fully executable from the public plugin.

  - What is currently available through this plugin: shipglows help/
    routing + public pack/docs awareness only.

  Next action (recommended):

  - For now: continue using shipglows to route your request and run the
    planned workflow conceptually.

  - To execute shipglows-main end-to-end workflows: install the
    complete ShipGlows corpus via scripts/bootstrap_shipglows_repo.sh
    (requires your explicit approval), or wait for a future bundle of
    shipglows-main after portability work.

──────────────────────────────────────────────────────────────────────


› $800-tmux-capture-conversation


• Je vais charger d’abord les chemins canoniques de ShipGlows, puis
  exécuter un --dry-run pour inférer titre + destination (capture du
  pane courant), et te demander confirmation avant d’écrire le
  fichier.

• Ran SHIPGLOWS_ROOT=${SHIPGLOWS_ROOT:-/home/claude/shipglows}; if [ -f
  │ "$SHIPGLOWS_ROOT/skills/references/canonical-paths.md" ]; then
  │ sed -n '1,220p' "$SHIPGLOWS_ROOT/skills/references/
  │ … +2 lines
  └ ---
    artifact: technical_guidelines
    … +93 lines (ctrl + t to view transcript)

    Use the same pattern for other ShipGlows-owned tools and scripts.

──────────────────────────────────────────────────────────────────────

• Je lance le --dry-run du script de capture pour déterminer le plan
  d’enregistrement (titre + destination), puis je te le confirme avant
  d’écrire.

• Ran SHIPGLOWS_ROOT=${SHIPGLOWS_ROOT:-/home/claude/shipglows};
  │ "$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/scripts/
  │ capture_tmux_conversation.sh" --dry-run
  └ Title: Conversation shipglows - :shipglows help
    Destination: /home/claude/shipglows/docs/conversations/
    … +4 lines (ctrl + t to view transcript)
    Neovim command: cd /home/claude/shipglows/docs/conversations &&
    nvim conversation-shipglows-shipglows-help-20260611-164357.md

──────────────────────────────────────────────────────────────────────

• Plan pré‑inféré (sans écriture, mode --dry-run) :

  - Titre: Conversation shipglows - :shipglows help
  - Destination: /home/claude/shipglows/docs/conversations/
    conversation-shipglows-shipglows-help-20260611-164357.md

  - Cible tmux: pane courant 0:14.1 (window index :14, pane .1, nom de
    fenêtre node)

  Confirme si c’est OK.

  - Réponds oui pour lancer l’écriture,
  - ou donne un autre chemin de destination (remplacement autorisé),
  - ou no/q pour annuler.

──────────────────────────────────────────────────────────────────────


› oui


• Je lance maintenant la capture avec le titre et la destination
  confirmés.

• Working (1s • esc to interrupt)


› Write tests for @filename

  gpt-5.3-codex-spark medium · Context 84% left · ~

/home/claude/home/claude/home/claude
