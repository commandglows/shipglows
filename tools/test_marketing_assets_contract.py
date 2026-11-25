#!/usr/bin/env python3
"""Contract checks for standardized marketing assets nomenclature and sg-design assets mode."""

from pathlib import Path
import unittest

from tools import shipglows_metadata_lint


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "marketing-assets-contract.md"
PLAYBOOK = ROOT / "skills" / "006-sg-design" / "references" / "marketing-assets-playbook.md"
TEMPLATE = ROOT / "templates" / "marketing_assets_index.md"
DESIGN_SKILL = ROOT / "skills" / "006-sg-design" / "SKILL.md"
LIFECYCLE_ROUTING = ROOT / "skills" / "006-sg-design" / "references" / "design-lifecycle-routing.md"
ENTRYPOINT_ROUTING = ROOT / "skills" / "references" / "entrypoint-routing.md"
MARKETING_SKILL = ROOT / "skills" / "009-sg-marketing" / "SKILL.md"
HANDOFFS = ROOT / "skills" / "references" / "content-owner-handoffs.md"
HELP_CATALOG = ROOT / "skills" / "302-sg-help" / "references" / "help-modes-catalog.md"
DOC_RULES = ROOT / "skills" / "references" / "documentation-governance-rules.md"
PLACEMENT = ROOT / "skills" / "references" / "canonical-project-governance-placement.md"
PROJ_RULES = ROOT / "skills" / "references" / "project-governance-rules.md"
DATA_README = ROOT / "shipglows_data" / "README.md"


def normalized(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class MarketingAssetsContractTests(unittest.TestCase):
    def test_contract_playbook_and_template_exist_with_locked_rules(self) -> None:
        for path in (CONTRACT, PLAYBOOK, TEMPLATE):
            self.assertTrue(path.is_file(), path)

        contract = normalized(CONTRACT)
        for required in (
            "shipglows_data/branding/assets/",
            "shipglows_data/marketing/assets/",
            "Git LFS",
            "*.mp4",
            "Theme Fidelity Gate",
            "Atomic Locale Parity",
            "shared/",
            "en/",
            "fr/",
            "GitHub is excluded from the default social profile pack",
            "1500×500",
            "1128×191",
            "1640×624",
            "2560×1440",
            "1546×423",
            "1200×630",
            "profiles-copy.md",
            "creative-asset-provenance-contract.md",
        ):
            self.assertIn(required, contract)

        playbook = normalized(PLAYBOOK)
        for required in (
            "assets <social-kit|campaign|stores|video|audit|list> [scope]",
            "marketing-assets-contract.md",
            "document.fonts.ready",
            "Git LFS",
        ):
            self.assertIn(required, playbook)

        template = normalized(TEMPLATE)
        self.assertIn("artifact: marketing_assets_index", template)
        self.assertIn("shipglows_data/marketing/assets/**", template)

    def test_skills_routing_and_governance_wire_marketing_assets(self) -> None:
        grammar = "assets <social-kit|campaign|stores|video|audit|list> [scope]"
        for doc in (DESIGN_SKILL, LIFECYCLE_ROUTING, HELP_CATALOG):
            self.assertIn(grammar, normalized(doc))

        self.assertIn("006-sg-design assets", normalized(ENTRYPOINT_ROUTING))
        self.assertIn("sg-design assets", normalized(MARKETING_SKILL))
        self.assertIn("006-sg-design assets", normalized(HANDOFFS))

        for doc in (DOC_RULES, PLACEMENT, PROJ_RULES, DATA_README):
            self.assertIn("marketing/assets/", normalized(doc))

    def test_metadata_lint_supports_marketing_assets_index(self) -> None:
        self.assertIn("marketing_assets_index", shipglows_metadata_lint.ARTIFACT_REQUIRED)
        self.assertIn("shipglows_data/marketing/assets/README.md", shipglows_metadata_lint.OFFICIAL_ARTIFACT_PATHS)
        fields, initial_errors = shipglows_metadata_lint.read_frontmatter(TEMPLATE)
        errors = shipglows_metadata_lint.validate(TEMPLATE, fields, initial_errors)
        self.assertEqual([], errors)


if __name__ == "__main__":
    unittest.main()
