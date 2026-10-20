from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
PREFERRED_STACKS = ROOT / "skills" / "references" / "preferred-stacks.md"
EXTENSION_WORKFLOW = ROOT / "skills" / "references" / "browser-extension-lab.md"
OBSIDIAN_WORKFLOW = ROOT / "skills" / "references" / "obsidian-plugin-workflow.md"
DEVELOPMENT_SKILL = ROOT / "skills" / "sg-development" / "SKILL.md"


def normalized_text(path: Path) -> str:
    """Make contract assertions resilient to intentional Markdown wrapping."""
    return " ".join(path.read_text(encoding="utf-8").split())


class CreationSurfacePresetContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.stacks = normalized_text(PREFERRED_STACKS)
        cls.extension = normalized_text(EXTENSION_WORKFLOW)
        cls.obsidian = normalized_text(OBSIDIAN_WORKFLOW)
        cls.development = normalized_text(DEVELOPMENT_SKILL)

    def test_sparse_browser_extension_uses_approved_preset(self) -> None:
        for marker in (
            "### Browser extensions",
            "WXT, strict TypeScript, pnpm and Manifest V3",
            "Keep simple UI native.",
            "Use Vue 3 only for rich reactive UI",
            "React is not the default",
            "Disable WXT's automatic browser startup",
            "`PSP-008 sparse browser extension`",
        ):
            self.assertIn(marker, self.stacks)
        self.assertIn("For greenfield work use `preferred-stacks.md`", self.extension)

    def test_sparse_obsidian_plugin_uses_native_first_vue_preset(self) -> None:
        for marker in (
            "### Obsidian plugins",
            "official `obsidian` TypeScript API",
            "Support desktop and mobile by default.",
            "Add Vue 3 only for rich reactive views",
            "unmount it on surface close and plugin unload",
            "Commands, vault access and registration remain host-owned.",
            "`PSP-009 sparse Obsidian plugin`",
        ):
            self.assertIn(marker, self.stacks)
        self.assertIn("use the Obsidian preset in `preferred-stacks.md`", self.obsidian)

    def test_development_owner_discovers_both_specialized_workflows(self) -> None:
        for reference in (
            "skills/references/browser-extension-lab.md",
            "skills/references/obsidian-plugin-workflow.md",
        ):
            self.assertIn(reference, self.development)


if __name__ == "__main__":
    unittest.main()
