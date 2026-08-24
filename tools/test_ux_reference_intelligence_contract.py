#!/usr/bin/env python3
"""Focused pressure contracts for provider-neutral UX reference intelligence."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "skills/references/ux-reference-intelligence.md"
CONNECTORS = ROOT / "skills/references/ux-reference-connectors.md"
DESIGN = ROOT / "skills/006-sg-design/SKILL.md"
BUILD = ROOT / "skills/001-sg-build/SKILL.md"
EXPERIENCE = ROOT / "skills/008-sg-customer/SKILL.md"
SPEC_SKILL = ROOT / "skills/100-sg-spec/SKILL.md"
RESOURCE_DISCOVERY = ROOT / "skills/references/resource-discovery.md"
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

    def test_runtime_availability_freshness_and_eligibility_are_distinct(self) -> None:
        text = normalized(CORE)
        for marker in (
            "availability, freshness, and eligibility are separate decisions",
            "inspect the current runtime's exposed tools, apps, and mcp connectors",
            "accessible but stale",
            "ineligible by default",
            "never infer current relevance from url reachability",
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
            "uxref-checklist-one",
            "uxref-checklist-proof",
        ):
            self.assertIn(marker, text)

    def test_checklist_sources_are_candidates_not_exhaustive_requirements(self) -> None:
        text = normalized(CORE)
        for marker in (
            "candidate scenarios, not requirements, consensus, acceptance criteria",
            "never import or apply an entire external checklist by default",
            "concrete functional responsibility",
            "one checklist remains one attributed source",
            "a checked box is never evidence that the behavior works",
            "only selected, product-relevant scenarios",
            "never the source's full list",
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

    def test_checklist_design_is_a_bounded_public_web_indicator(self) -> None:
        text = normalized(CONNECTORS)
        for marker in (
            "source id: `checklist-design-public-web`",
            "adapter class: `public-web`",
            "https://www.checklist.design/",
            "indicator among other evidence",
            "never import a full checklist",
            "completed checkboxes as usability or quality proof",
            "claims and statistics remain unverified until independently sourced",
            "only selected scenarios",
            "provider skills, agent packages, figma skills, and plugins are not installed",
            "zero relevant candidates",
        ):
            self.assertIn(marker, text)

    def test_collectui_is_accessible_but_freshness_unverified(self) -> None:
        text = normalized(CONNECTORS)
        for marker in (
            "source id: `collectui-public-web`",
            "adapter class: `public-web`",
            "https://collectui.com/",
            "availability state: `accessible`",
            "freshness state: `unverified`",
            "eligibility: `ineligible-by-default`",
            "zero shots published yesterday and during the previous week",
            "manual visual archive",
            "not evidence of a current convention",
            "not a real-product flow source",
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

    def test_build_experience_and_spec_activate_the_shared_contract(self) -> None:
        for path in (BUILD, EXPERIENCE, SPEC_SKILL):
            text = normalized(path)
            self.assertIn("skills/references/ux-reference-intelligence.md", text)
            self.assertIn("skills/references/ux-reference-connectors.md", text)
        self.assertIn("material journey", normalized(EXPERIENCE))
        self.assertIn("before readiness", normalized(BUILD))
        self.assertIn("selected observations", normalized(SPEC_SKILL))

    def test_resource_discovery_routes_external_experience_sources_explicitly(self) -> None:
        text = normalized(RESOURCE_DISCOVERY)
        self.assertIn("shared:ux-reference-intelligence", text)
        self.assertIn("shared:ux-reference-connectors", text)
        self.assertIn("external experience evidence", text)

    def test_connector_catalog_is_shared_not_design_local(self) -> None:
        self.assertTrue(CONNECTORS.is_file())
        self.assertFalse(
            (ROOT / "skills/006-sg-design/references/ux-reference-connectors.md").exists()
        )

    def test_ready_spec_preserves_extensibility_and_no_install_scope(self) -> None:
        text = normalized(SPEC)
        for marker in (
            "status: ready",
            "mobbin as the first documented connector",
            "no subscription purchase, billing, oauth authorization, api key, mcp configuration",
            "a new provider can be added",
            "cross-skill activation",
            "collect ui as a documented `public-web` archive",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
