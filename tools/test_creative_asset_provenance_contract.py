#!/usr/bin/env python3
"""Scenario-first regression checks for creative-asset provenance doctrine."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/creative-asset-provenance-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/creative-asset-provenance-contract.md"
OWNERS = (
    ROOT / "skills/001-sg-build/SKILL.md",
    ROOT / "skills/006-sg-design/SKILL.md",
    ROOT / "skills/007-sg-content/SKILL.md",
)


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class CreativeAssetProvenanceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = text(CONTRACT)

    def test_conditional_owner_loaders(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "creative-asset-provenance-contract.md"
        for owner in OWNERS:
            value = text(owner)
            self.assertIn(reference, value)
            self.assertTrue(" when " in value.lower() or " whenever " in value.lower())

    def test_asset_classes_and_complete_adoption_record(self) -> None:
        for value in (
            "original/internal", "customer-supplied", "claimed public domain",
            "AI-generated or AI-edited", "stable asset ID", "canonical source URL",
            "acquisition date", "license or terms version", "evidence snapshot",
            "intended product, channel, territory, and term", "original file hash",
            "derived file hashes", "accountable owner and reviewer",
            "replacement, rollback, quarantine, and takedown route",
        ):
            self.assertIn(value, self.contract)

    def test_public_url_payment_metadata_and_attribution_are_not_rights(self) -> None:
        for value in (
            "Availability, downloadability, payment, attribution, or a public URL is not permission",
            "Do not treat attribution as a substitute for permission",
            "A checksum proves byte identity, not rights or safety",
            "None alone proves clearance, safety, conformance, or publication readiness",
        ):
            self.assertIn(value, self.contract)

    def test_cc_spdx_and_redistribution_boundaries(self) -> None:
        for value in (
            "BY attribution", "SA sharing adaptations", "NC noncommercial restrictions",
            "ND restrictions on distributing adaptations", "SPDX identifiers and expressions",
            "they do not grant rights", "Separate use in an end product from redistribution of source material",
            "source kit, template, editable scene, font file, library, standalone asset",
        ):
            self.assertIn(value, self.contract)

    def test_people_property_privacy_customer_and_brand_review(self) -> None:
        for value in (
            "identifiable people", "model/property release", "publicity, personality, privacy, moral",
            "customer authorization", "trademark", "Screenshots inherit the rights and privacy concerns",
            "Do not expose customer or private assets to an external optimizer",
        ):
            self.assertIn(value, self.contract)

    def test_ai_c2pa_and_iptc_do_not_overstate_provenance(self) -> None:
        for value in (
            "does not automatically establish copyright, ownership, exclusivity, non-infringement",
            "Disclose or label only where applicable", "signed provenance assertions and tamper-evidence",
            "They do not prove that an assertion is true", "Metadata may be stale, incorrect, absent, or stripped",
            "keep external evidence and lineage independent of embedded fields",
        ):
            self.assertIn(value, self.contract)

    def test_untrusted_inputs_and_conversion_boundary(self) -> None:
        for value in (
            "Treat SVG, 3D files, archives, office/source files, fonts, images, audio/video",
            "Conversion, transcoding, rasterization, optimization, or metadata removal is not sanitization",
            "size, dimension, duration, decompression, nesting, and external-resource limits",
            "active content, scripts, macros", "least-privileged, isolated tooling",
            "never trust a filename extension or client-provided MIME value alone",
        ):
            self.assertIn(value, self.contract)

    def test_lineage_monitoring_takedown_and_history(self) -> None:
        for value in (
            "Inventory existing assets before adoption, migration, optimization",
            "original -> conversion -> optimization -> crop/edit -> delivery derivative",
            "never rewrite history or delete evidence", "fast unpublish or distribution-stop capability",
            "quarantine", "replacement", "rollback", "Never destroy the history",
        ):
            self.assertIn(value, self.contract)

    def test_provider_tools_are_candidates_not_authority(self) -> None:
        for value in (
            "Unsplash, Drawkit, Shapefest", "candidate sources or tools only",
            "One provider's license does not automatically clear depicted people",
            "Tools can help discover, inspect, optimize, transform, or record assets",
            "they cannot turn unclear rights into permission",
        ):
            self.assertIn(value, self.contract)

    def test_not_legal_advice_and_material_rights_escalate(self) -> None:
        for value in (
            "it is not legal advice", "qualified legal or rights-holder review",
            "rather than asking an agent to infer clearance", "never fill the gap with agent inference",
        ):
            self.assertIn(value, self.contract)

    def test_primary_sources_and_integration_boundary(self) -> None:
        for value in (
            "https://creativecommons.org/share-your-work/cclicenses/",
            "https://spdx.org/licenses/", "https://help.unsplash.com/en/collections/1463188-unsplash-license",
            "https://www.drawkit.com/license", "https://c2pa.org/specifications/specifications/2.2/index.html",
            "https://www.wipo.int/copyright/en/",
            "https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html",
            "https://iptc.org/standards/photo-metadata/",
        ):
            self.assertIn(value, self.contract)
        if SPEC.is_file():  # the spec lives in the private data corpus
            spec = text(SPEC)
            self.assertIn("104-sg-end`: ready for operator review", spec)
            self.assertIn("005-sg-ship`: out of scope", spec)
            self.assertIn("Integration-owner review and broader verification complete", spec)


if __name__ == "__main__":
    unittest.main()
