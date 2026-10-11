#!/usr/bin/env python3
"""Regression checks for the web image performance doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills" / "references" / "web-image-performance-contract.md"
SPEC = ROOT / "shipglows_data" / "workflow" / "specs" / "web-image-performance-contract.md"
BUILD = ROOT / "skills" / "001-sg-build" / "SKILL.md"
DESIGN = ROOT / "skills" / "006-sg-design" / "SKILL.md"
PERFORMANCE = ROOT / "skills" / "010-sg-technical" / "references" / "performance-audit-playbook.md"
TECHNICAL = ROOT / "skills" / "010-sg-technical" / "SKILL.md"


def normalized_text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class WebImagePerformanceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = normalized_text(CONTRACT)

    def test_build_design_and_performance_audit_load_the_contract(self) -> None:
        reference = "$SHIPGLOWS_ROOT/skills/references/web-image-performance-contract.md"
        for owner in (BUILD, DESIGN, PERFORMANCE):
            self.assertEqual(normalized_text(owner).count(reference), 1)

    def test_contract_and_spec_follow_the_current_quality_baseline(self) -> None:
        dependency = 'artifact: skills/references/decision-quality-contract.md artifact_version: "2.2.0" required_status: active'
        self.assertIn(dependency, self.contract)
        self.assertIn(dependency, normalized_text(SPEC))

    def test_squoosh_is_calibration_not_the_production_pipeline(self) -> None:
        for expected in (
            "Squoosh for calibration and diagnosis",
            "a manual Squoosh export is not a reproducible build step or CI proof",
            "Framework-native pipeline first",
            "Sharp/libvips for a programmable raster gap",
            "SVGO for controlled SVG optimization",
        ):
            self.assertIn(expected, self.contract)

    def test_format_and_quality_are_measured_not_universal(self) -> None:
        for expected in (
            "There is no universal AVIF-first rule",
            "Never choose one universal quality number",
            "No format, quality setting, or encoder wins without representative visual and performance evidence",
            "A smaller file with visible unacceptable degradation is a failed optimization",
        ):
            self.assertIn(expected, self.contract)

    def test_responsive_delivery_covers_selection_lcp_and_cls(self) -> None:
        for expected in (
            "correct `srcset` and `sizes`",
            "prevent avoidable CLS",
            "actual LCP image discoverable in initial markup",
            "applying them broadly creates contention",
            "combinatorial variant generation",
        ):
            self.assertIn(expected, self.contract)

    def test_metadata_remote_fetch_and_svg_safety_are_explicit(self) -> None:
        for expected in (
            "Normalize orientation before removing EXIF orientation data",
            "Strip GPS and unnecessary metadata by default",
            "prevent internal-network and credential-bearing fetches",
            "decompression-bomb inputs",
            "SVGO alone does not establish safety",
            "source rights, transformation rights, attribution, trademark constraints, and redistribution terms",
        ):
            self.assertIn(expected, self.contract)

    def test_source_roles_and_adoption_limits_are_recorded(self) -> None:
        for expected in (
            "https://github.com/GoogleChromeLabs/squoosh",
            "https://sharp.pixelplumbing.com/",
            "https://www.libvips.org/",
            "https://svgo.dev/",
            "https://docs.astro.build/en/guides/images/",
            "Rechecked 2026-08-18",
            "Recheck versions, platform support, pricing, licenses, and deployment constraints at adoption time",
            "https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html",
            "https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html",
            "https://www.w3.org/TR/svg-integration/",
        ):
            self.assertIn(expected, self.contract)

    def test_security_sources_do_not_weaken_svg_or_remote_fetch_boundaries(self) -> None:
        self.assertIn("a hostname allowlist alone is insufficient", self.contract)
        self.assertIn("optimization never substitutes for the selected security policy", self.contract)
        self.assertNotIn("SVGO sanitizes", self.contract)

    def test_no_public_asset_mode_is_added(self) -> None:
        technical = normalized_text(TECHNICAL)
        self.assertIn("<audit|architecture|deps|performance|migrate|github|sync|access|parity|help>", technical)
        self.assertNotIn("asset [", technical.lower())
        self.assertNotIn("image [", technical.lower())


if __name__ == "__main__":
    unittest.main()
