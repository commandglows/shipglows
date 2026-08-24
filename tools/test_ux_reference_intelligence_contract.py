#!/usr/bin/env python3
"""Focused pressure contracts for provider-neutral UX reference intelligence."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "skills/references/ux-reference-intelligence.md"
CONNECTORS = ROOT / "skills/006-sg-design/references/ux-reference-connectors.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
PRIVATE_LIBRARY = ROOT / "skills/references/design-inspiration-library.md"
SPEC = ROOT / "shipglows_data/workflow/specs/extensible-ux-reference-intelligence.md"


def normalized(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split()).casefold()


class UxReferenceIntelligenceContractTests(unittest.TestCase):
    def test_core_is_provider_neutral_and_adapter_based(self) -> None:
        text = normalized(CORE)
        for marker in (
            "sources are replaceable adapters",
            "`mcp`",
            "`api`",
            "`public-web`",
            "`manual-url`",
            "`platform-guidance`",
            "`private-corpus`",
            "`project-evidence`",
        ):
            self.assertIn(marker, text)
        normative_body = text.split("# ux reference intelligence", 1)[1]
        self.assertNotIn("mobbin", normative_body)

    def test_authority_order_rejects_popularity_as_usability_proof(self) -> None:
        text = normalized(CORE)
        markers = (
            "reference prevalence is evidence of familiarity, not proof of usability",
            "observed user behavior",
            "accessibility, safety, privacy, and platform requirements",
            "product, brand, content, and design-system authority",
            "one provider result or aesthetic preference",
        )
        for marker in markers:
            self.assertIn(marker, text)
        positions = [text.index(marker) for marker in markers[1:]]
        self.assertEqual(positions, sorted(positions))

    def test_observations_preserve_provenance_states_and_anti_copy(self) -> None:
        text = normalized(CORE)
        for marker in (
            "source_id",
            "user task",
            "loading, empty, error, recovery, permission, and cancellation states",
            "independent-source count",
            "accessibility",
            "possible duplicate-source lineage",
            "must_not_copy",
            "unknown stays unknown",
        ):
            self.assertIn(marker, text)

    def test_zero_one_many_conflict_and_rights_fail_safely(self) -> None:
        text = normalized(CORE)
        for marker in (
            "uxref-zero",
            "uxref-one",
            "uxref-many",
            "uxref-conflict",
            "uxref-accessibility",
            "uxref-not-callable",
            "uxref-rights",
            "uxref-anti-copy",
        ):
            self.assertIn(marker, text)

    def test_mobbin_is_documented_as_one_unconfigured_connector(self) -> None:
        text = normalized(CONNECTORS)
        for marker in (
            "source id: `mobbin-mcp`",
            "adapter class: `mcp`",
            "https://api.mobbin.com/mcp",
            "`search_screens`",
            "`search_flows`",
            "`search_sections`",
            "pro, team, and enterprise",
            "repository configuration state: not configured by this contract",
            "never inherit `callable` from this catalog",
            "fresh-docs checked",
        ):
            self.assertIn(marker, text)

    def test_connector_failures_have_explicit_fallbacks(self) -> None:
        text = normalized(CONNECTORS)
        for marker in (
            "`not-exposed`",
            "`auth-required` or `paywalled`",
            "`rate-limited`",
            "zero relevant results",
            "do not request credentials",
        ):
            self.assertIn(marker, text)

    def test_private_library_remains_stricter_first_party_adapter(self) -> None:
        core = normalized(CORE)
        private = normalized(PRIVATE_LIBRARY)
        connectors = normalized(CONNECTORS)
        self.assertIn("private design-inspiration library retains its stricter", core)
        self.assertIn("`shipglows-private-inspiration` private-corpus adapter", private)
        self.assertIn("source id: `shipglows-private-inspiration`", connectors)
        for marker in ("approval", "takedown", "git lfs"):
            self.assertIn(marker, private)

    def test_design_activation_is_direct_and_preserves_fallback(self) -> None:
        text = normalized(DESIGN)
        self.assertIn("skills/references/ux-reference-intelligence.md", text)
        self.assertIn("references/ux-reference-connectors.md", text)
        self.assertIn("replaceable evidence adapters", text)
        self.assertIn("complete fallback when no external connector is callable", text)

    def test_ready_spec_preserves_extensibility_and_no_install_scope(self) -> None:
        text = normalized(SPEC)
        for marker in (
            "status: ready",
            "mobbin as the first documented connector",
            "no subscription purchase, billing, oauth authorization, api key, mcp configuration",
            "a new provider can be added",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
