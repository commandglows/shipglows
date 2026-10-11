#!/usr/bin/env python3
"""Regression checks for the provider-neutral interactive 3D doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "interactive-3d-experience-contract.md"
SPEC = ROOT / "shipglows_data" / "workflow" / "specs" / "interactive-3d-experience-contract.md"
DESIGN = ROOT / "skills" / "006-sg-design" / "SKILL.md"
BUILD = ROOT / "skills" / "001-sg-build" / "SKILL.md"
TECHNICAL = ROOT / "skills" / "010-sg-technical" / "SKILL.md"


def normalized_text(path: Path) -> str:
    """Make phrase checks insensitive to intentional Markdown wrapping."""
    return " ".join(path.read_text(encoding="utf-8").split())


class Interactive3DExperienceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = normalized_text(CONTRACT)

    def test_design_and_build_conditionally_load_the_shared_contract(self) -> None:
        reference = "$SHIPGLOWS_ROOT/skills/references/interactive-3d-experience-contract.md"
        self.assertEqual(normalized_text(DESIGN).count(reference), 1)
        self.assertEqual(normalized_text(BUILD).count(reference), 1)

    def test_contract_and_spec_record_quality_and_security_authority(self) -> None:
        dependency = 'artifact: skills/references/decision-quality-contract.md artifact_version: "2.2.0" required_status: active'
        for artifact in (self.contract, normalized_text(SPEC)):
            self.assertIn(dependency, artifact)
            self.assertIn("security_impact: yes", artifact)

    def test_contract_classifies_before_selecting_a_tool(self) -> None:
        for expected in (
            "Decorative depth",
            "Interactive object",
            "Product scene",
            "Configurator",
            "Immersive experience",
            "Never select or install automatically",
            "Do not use a brand name as the requirement",
        ):
            self.assertIn(expected, self.contract)

    def test_rive_is_an_interactive_2d_alternative_not_a_3d_engine(self) -> None:
        self.assertIn("Rive is an interactive 2D vector animation", self.contract)
        self.assertIn("Rive is not a 3D engine", self.contract)

    def test_essential_experience_survives_without_webgl_or_canvas(self) -> None:
        for expected in (
            "Essential information, controls, selections, prices, validation, and task completion must remain available without WebGL",
            "semantic controls outside or alongside the canvas",
            "A blank rectangle, perpetual loader",
            "prefers-reduced-motion",
            "meaningful stable outcome",
        ):
            self.assertIn(expected, self.contract)

    def test_build_only_completion_is_rejected(self) -> None:
        self.assertIn(
            "A build, lint, unit test, source inspection, asset preview, or successful canvas initialization alone never proves a 3D experience",
            self.contract,
        )
        for expected in (
            "WebGL unavailable",
            "context loss",
            "frame pacing",
            "representative hardware",
            "Report untested devices, browsers, provider behavior, and fallback states as proof gaps",
        ):
            self.assertIn(expected, self.contract)

    def test_asset_interchange_provenance_and_candidate_tools_are_explicit(self) -> None:
        for expected in (
            "Prefer glTF 2.0 interchange and `.glb`",
            "Unknown provenance blocks use",
            "Three.js",
            "Spline",
            "Womp",
            "Physically Based",
            "pmndrs market",
            "Plask",
        ):
            self.assertIn(expected, self.contract)

    def test_browser_access_is_not_misreported_as_accessibility_conformance(self) -> None:
        self.assertIn("browser-based creation surface", self.contract)
        self.assertIn("not accessibility conformance", self.contract)
        self.assertNotIn("accessible creation surface", self.contract)

    def test_technical_router_does_not_gain_an_implicit_3d_engine_route(self) -> None:
        technical = normalized_text(TECHNICAL)
        self.assertNotIn("interactive-3d-experience-contract.md", technical)
        self.assertNotIn("3d engine", technical.lower())


if __name__ == "__main__":
    unittest.main()
