from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class InstallSurfaceParityContractTests(unittest.TestCase):
    def test_public_components_never_select_windows_maintainer(self) -> None:
        windows = (ROOT / "install-shipglows.ps1").read_text(encoding="utf-8")

        self.assertIn("Resolve-SgInstallSurface", windows)
        self.assertNotIn("if (-not $InstallSurface -and $requestedComponents", windows)
        self.assertNotIn("$InstallSurface = 'corpus'", windows)
        self.assertIn("'maintainer'", windows)

    def test_unix_uses_skills_as_the_canonical_public_corpus_name(self) -> None:
        unix = (ROOT / "install-shipglows.sh").read_text(encoding="utf-8")

        self.assertIn("INSTALL_SURFACE=skills", unix)
        self.assertIn("corpus|skills|opencode|kilocode", unix)
        self.assertIn("INSTALL_SURFACE=skills", unix.split("corpus|skills|opencode|kilocode", 1)[1])

    def test_plugin_distinguishes_maintainer_from_sparse_skills(self) -> None:
        plugin = (ROOT / "plugins/shipglows/skills/shipglows/SKILL.md").read_text(encoding="utf-8")

        self.assertIn("maintainer", plugin)
        self.assertIn("-InstallSurface maintainer", plugin)
        self.assertIn("sparse", plugin)


if __name__ == "__main__":
    unittest.main()
