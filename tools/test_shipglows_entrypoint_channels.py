#!/usr/bin/env python3
"""Contract tests for mutually exclusive ShipGlows Codex entrypoint channels."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ShipGlowsEntrypointChannelContract(unittest.TestCase):
    def test_generic_repository_skill_shim_is_not_codex_discoverable(self) -> None:
        self.assertFalse((ROOT / ".agents/skills/shipglows/SKILL.md").exists())
        self.assertTrue((ROOT / ".opencode/skills/shipglows/SKILL.md").is_file())

    def test_sync_helper_owns_explicit_codex_channels(self) -> None:
        helper = (ROOT / "tools/shipglows_sync_skills.sh").read_text(encoding="utf-8")
        self.assertIn("--codex-entrypoint linked|plugin", helper)
        self.assertIn("Codex ShipGlows entrypoint conflict", helper)
        self.assertIn("plugin-entrypoint-selected", helper)

    def test_installer_forwards_the_selected_channel(self) -> None:
        installer = (ROOT / "cli/install.sh").read_text(encoding="utf-8")
        self.assertIn('SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED="${SHIPGLOWS_CODEX_ENTRYPOINT:-linked}"', installer)
        self.assertIn('--codex-entrypoint "$SHIPGLOWS_CODEX_ENTRYPOINT_RESOLVED"', installer)

    def test_public_plugin_understands_resume_auto_and_posture_tags(self) -> None:
        plugin = (ROOT / "plugins/shipglows/skills/shipglows/SKILL.md").read_text(encoding="utf-8")
        for fragment in (
            "`resume`, `résume`, or `reprends`",
            "never approves a pending plan",
            "`blitz` always implies `#nolocal`",
            "`#ci` implies `#nolocal`",
            "never creates busywork merely to consume credits",
        ):
            self.assertIn(fragment, plugin)

    def test_public_plugin_delegates_to_canonical_router_when_corpus_exists(self) -> None:
        plugin = (ROOT / "plugins/shipglows/skills/shipglows/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("## Canonical Router Delegation", plugin)
        self.assertIn("load `skills/shipglows/SKILL.md` from that root", plugin)
        self.assertIn("edit the canonical router\nfirst", plugin)
        self.assertTrue((ROOT / "skills/shipglows/SKILL.md").is_file())


if __name__ == "__main__":
    unittest.main()
