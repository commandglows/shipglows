from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
PREFERRED_STACKS = ROOT / "skills" / "references" / "preferred-stacks.md"
EXTENSION_WORKFLOW = ROOT / "skills" / "references" / "browser-extension-lab.md"
EXTENSION_API_CONTRACT = ROOT / "skills" / "references" / "webextension-api-contract.md"
OBSIDIAN_WORKFLOW = ROOT / "skills" / "references" / "obsidian-plugin-workflow.md"
DEVELOPMENT_SKILL = ROOT / "skills" / "sg-development" / "SKILL.md"
VERIFICATION_RUNTIME = ROOT / "skills" / "103-sg-verify" / "references" / "verification-security-ui-runtime.md"


class CreationSurfacePresetContract(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.stacks = PREFERRED_STACKS.read_text(encoding="utf-8")
        cls.extension = EXTENSION_WORKFLOW.read_text(encoding="utf-8")
        cls.extension_api = EXTENSION_API_CONTRACT.read_text(encoding="utf-8")
        cls.obsidian = OBSIDIAN_WORKFLOW.read_text(encoding="utf-8")
        cls.development = DEVELOPMENT_SKILL.read_text(encoding="utf-8")
        cls.verification = VERIFICATION_RUNTIME.read_text(encoding="utf-8")

    def test_sparse_browser_extension_uses_approved_preset(self) -> None:
        for marker in (
            "### Browser extensions",
            "WXT with strict TypeScript and pnpm",
            "Manifest V3",
            "Chromium, Edge, Vivaldi, and Firefox",
            "Add Vue 3 through WXT's Vue module",
            "React is not a default or fallback",
            "`PSP-008 sparse browser extension`",
        ):
            self.assertIn(marker, self.stacks)
        self.assertIn("## Greenfield creation contract", self.extension)
        self.assertIn("Vue 3", self.extension)

    def test_sparse_obsidian_plugin_uses_native_first_vue_preset(self) -> None:
        for marker in (
            "### Obsidian plugins",
            "official `obsidian` TypeScript API",
            "desktop and mobile by default",
            "Add Vue 3",
            "unmount it deterministically",
            "React is not a default or fallback",
            "`PSP-009 sparse Obsidian plugin`",
        ):
            self.assertIn(marker, self.stacks)
        for marker in (
            "## Greenfield creation contract",
            "Use Obsidian components",
            "Use Vue 3",
            "unmount it",
            "plugin lifecycle",
        ):
            self.assertIn(marker, self.obsidian)

    def test_development_owner_discovers_both_specialized_workflows(self) -> None:
        for reference in (
            "skills/references/browser-extension-lab.md",
            "skills/references/obsidian-plugin-workflow.md",
        ):
            self.assertIn(reference, self.development)

    def test_webextension_api_contract_is_discoverable_and_behavioral(self) -> None:
        for consumer in (self.stacks, self.extension, self.development, self.verification):
            self.assertIn("webextension-api-contract.md", consumer)
        for marker in (
            "## Compatibility Before Implementation",
            "Treat the Manifest V3 service worker as ephemeral",
            "optional host permissions",
            "typed, schema-validated messages",
            "`declarativeNetRequest`",
            "`WEBEXT-API-PROOF`",
        ):
            self.assertIn(marker, self.extension_api)


if __name__ == "__main__":
    unittest.main()
