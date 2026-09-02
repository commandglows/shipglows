#!/usr/bin/env python3
"""Scenario-first contract checks for the métier-first public skill surface.

These tests deliberately verify machine-readable ownership and activation
anchors, rather than pretending to evaluate an LLM conversation.  The
pressure scenarios (MH-01 through MH-23) stay deterministic by checking the
contract that every public owner must load and the canonical catalog that
drives public discovery.
"""

from __future__ import annotations

import json
from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
AUTONOMY = SKILLS / "references" / "intent-to-outcome-autonomy.md"
AUTONOMY_EXECUTION = SKILLS / "references" / "intent-to-outcome-execution.md"
AUTONOMY_SCENARIOS = SKILLS / "references" / "intent-to-outcome-pressure-scenarios.md"
STRATEGIC_CHOICES = SKILLS / "references" / "strategic-choice-contract.md"
BUSINESS_MESH = SKILLS / "references" / "business-context-mesh.md"
PARTNERSHIP = SKILLS / "references" / "operator-partnership-contract.md"
REGISTRY = SKILLS / "references" / "skill-invocation-registry.json"
ROUTER = SKILLS / "references" / "entrypoint-routing.md"
LIFECYCLE = SKILLS / "references" / "master-workflow-lifecycle.md"
DELEGATION = SKILLS / "references" / "master-delegation-semantics.md"
CODE_INDEX = SKILLS / "references" / "skill-code-index.md"

EXPECTED_DOMAINS = (
    "create",
    "quality",
    "publish",
    "grow-audience",
    "govern",
    "organize",
)
EXPECTED_OWNERS = {
    "sg-development": "001-sg-build",
    "sg-design": "006-sg-design",
    "sg-experience": "008-sg-customer",
    "sg-bug": "003-sg-bug",
    "sg-engineering": "010-sg-technical",
    "sg-maintenance": "002-sg-maintain",
    "sg-release": "004-sg-deploy",
    "sg-content": "007-sg-content",
    "sg-marketing": "009-sg-marketing",
    "sg-seo": "406-sg-seo",
    "sg-docs": "300-sg-docs",
    "sg-planning": "011-sg-pilotage",
    "sg-private": "603-sg-private",
    "sg-help": "302-sg-help",
}
EXPECTED_DISPLAY_NAMES = {
    "shipglows": "ShipGlows",
    "sg-development": "ShipGlows Development",
    "sg-design": "ShipGlows Design",
    "sg-experience": "ShipGlows Experience",
    "sg-bug": "ShipGlows Bug Repair",
    "sg-engineering": "ShipGlows Engineering",
    "sg-maintenance": "ShipGlows Maintenance",
    "sg-release": "ShipGlows Release",
    "sg-content": "ShipGlows Content",
    "sg-marketing": "ShipGlows Marketing",
    "sg-seo": "ShipGlows SEO",
    "sg-docs": "ShipGlows Documentation",
    "sg-planning": "ShipGlows Planning",
    "sg-private": "ShipGlows Private Memory",
    "sg-help": "ShipGlows Help",
}


class MetierFirstPublicSkillsContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.autonomy = AUTONOMY.read_text(encoding="utf-8")
        cls.autonomy_execution = AUTONOMY_EXECUTION.read_text(encoding="utf-8")
        cls.autonomy_scenarios = AUTONOMY_SCENARIOS.read_text(encoding="utf-8")
        cls.strategic_choices = STRATEGIC_CHOICES.read_text(encoding="utf-8")
        cls.business_mesh = BUSINESS_MESH.read_text(encoding="utf-8")
        cls.partnership = PARTNERSHIP.read_text(encoding="utf-8")
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        cls.catalog = cls.registry["public_catalog"]
        cls.router = ROUTER.read_text(encoding="utf-8")
        cls.lifecycle = LIFECYCLE.read_text(encoding="utf-8")
        cls.delegation = DELEGATION.read_text(encoding="utf-8")
        cls.code_index = CODE_INDEX.read_text(encoding="utf-8")
        cls.skills = [
            skill
            for domain in cls.catalog["domains"]
            for skill in domain["skills"]
        ]

    def owner_by_id(self) -> dict[str, dict[str, object]]:
        return {str(skill["id"]): skill for skill in self.skills}

    # MH-01: sparse requests with discoverable context proceed autonomously.
    def test_mh_01_resolve_before_asking_and_all_public_owners_load_the_contract(self) -> None:
        for required in (
            "## 1. Resolve",
            "Before asking a question",
            "discoverable evidence",
            "safe agent decisions",
            "Treat sparse prompts as delegated intent",
        ):
            self.assertIn(required, self.autonomy)

        public_entries = self.skills + [self.catalog["router"]]
        for entry in public_entries:
            public_skill = str(entry["public_skill"])
            runtime_skill = str(entry["runtime_skill"])
            body = (SKILLS / public_skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("intent-to-outcome-autonomy.md", body, public_skill)
            self.assertIn(runtime_skill, body, public_skill)

    # MH-01b: a public wrapper remains followable without requiring agents to
    # infer missing proof, stop, or reporting behavior from its runtime engine.
    def test_mh_01b_public_wrappers_expose_compact_activation_signals(self) -> None:
        required_headings = (
            "## Mission",
            "## Scope Gate",
            "## Required References",
            "## Validation",
            "## Stop Conditions",
            "## Report Modes",
        )
        public_entries = self.skills + [self.catalog["router"]]
        for entry in public_entries:
            public_skill = str(entry["public_skill"])
            body = (SKILLS / public_skill / "SKILL.md").read_text(encoding="utf-8")
            for heading in required_headings:
                self.assertIn(heading, body, f"{public_skill}: {heading}")
            self.assertIn("reporting-contract.md", body, public_skill)

    def test_mh_13_business_partner_first_is_active_for_every_public_path(self) -> None:
        for required in (
            "## Business Partner First",
            "business, brand, product, customer, or organizational outcome",
            "Before technical selection",
            "business-irrelevant work",
            "strategic-choice-contract.md",
            "operator-partnership-contract.md",
        ):
            self.assertIn(required, self.autonomy)

        runtime_skills = {
            str(entry["runtime_skill"])
            for entry in self.skills + [self.catalog["router"]]
        }
        for runtime_skill in runtime_skills:
            body = (SKILLS / runtime_skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("intent-to-outcome-autonomy.md", body, runtime_skill)

    def test_mh_14_material_choices_load_the_strategic_contract(self) -> None:
        self.assertIn("Material choices load `strategic-choice-contract.md`", self.autonomy)
        self.assertIn("business or product outcome", self.strategic_choices)
        self.assertIn("partner before becoming a technical executor", self.partnership)

    def test_mh_15_and_mh_16_mesh_business_truth_selectively(self) -> None:
        self.assertIn("business-context-mesh.md", self.autonomy)
        for required in (
            "smallest coherent source bundle",
            "shipglows_data/business/business.md",
            "shipglows_data/business/product.md",
            "shipglows_data/business/gtm.md",
            "shipglows_data/branding/branding.md",
            "portfolio-project-pitch-links.md",
            "project-competitors-and-inspirations.md",
            "affiliate-programs.md",
            "Do not read every family by default",
            "business/agent-profiles/",
            "context_conflict",
        ):
            self.assertIn(required, self.business_mesh)
        self.assertIn("`MH-15`", self.autonomy_scenarios)
        self.assertIn("`MH-16`", self.autonomy_scenarios)
        self.assertIn("`MH-17`", self.autonomy_scenarios)
        self.assertIn("`MH-18`", self.autonomy_scenarios)

    # MH-02: projects can contain several business, brand, product, and surface outcomes.
    def test_mh_02_preserves_the_full_target_hierarchy(self) -> None:
        target = "project -> business/brand/product -> outcome -> surface -> work item"
        self.assertIn(target, self.autonomy)
        self.assertIn("software is one possible form, not the default", self.autonomy)
        self.assertIn(target, self.router)

    # MH-03 / MH-04: only operator-owned business truth becomes a question.
    def test_mh_03_and_mh_04_question_only_material_business_truth(self) -> None:
        for required in (
            "Ask one numbered decision at a time",
            "recommend the strongest professional default",
            "never front-load a generic questionnaire",
            "Stop when a fresh capable agent can execute and prove safely",
            "Discoverable paths, commands, tests, and mechanics are agent decisions",
        ):
            self.assertIn(required, self.autonomy)
        self.assertIn("behavior, promise, scope", self.autonomy)
        self.assertIn("security", self.autonomy)
        self.assertIn("cost", self.autonomy)

    # MH-05 / MH-06: internal lifecycle and proof ownership never become work
    # the operator has to coordinate.
    def test_mh_05_and_mh_06_continue_through_internal_lifecycle(self) -> None:
        for required in (
            "Continue automatically after a successful internal stage",
            "Invoke internal engines without asking the operator to select or schedule them",
        ):
            self.assertIn(required, self.autonomy_execution)
        self.assertIn("A public métier owns the outcome across internal engines and handoffs", self.autonomy)
        self.assertIn("continue through its owned closure and ship route", self.lifecycle)
        self.assertIn("manual `/104-sg-end`, `/005-sg-ship`, or `/004-sg-deploy`", self.lifecycle)
        self.assertIn("never require the operator to select an owner, skill, or", self.delegation)

    # MH-07: public and internal documentation have distinct public owners.
    def test_mh_07_separates_public_content_from_internal_docs(self) -> None:
        self.assertEqual("007-sg-content", self.owner_by_id()["sg-content"]["runtime_skill"])
        self.assertEqual("300-sg-docs", self.owner_by_id()["sg-docs"]["runtime_skill"])
        public_content = (SKILLS / "sg-content" / "SKILL.md").read_text(encoding="utf-8")
        internal_docs = (SKILLS / "sg-docs" / "SKILL.md").read_text(encoding="utf-8")
        self.assertIn("editorial brand expression, public documentation, and audience content", public_content)
        self.assertIn("internal architecture, governance, context, metadata", internal_docs)
        self.assertIn("keep public docs and audience content with `sg-content`", internal_docs)

    # MH-08: data-like product infrastructure is one engineering métier.
    def test_mh_08_routes_sync_access_and_parity_through_engineering(self) -> None:
        engineering = self.owner_by_id()["sg-engineering"]
        self.assertEqual("010-sg-technical", engineering["runtime_skill"])
        self.assertTrue(
            {"600-sg-local-cloud-sync", "601-sg-product-entitlements", "602-sg-platform-parity"}
            .issubset(engineering["internal_engines"])
        )
        self.assertNotIn("sg-data", self.owner_by_id())

    # MH-09: autonomy never silently broadens authority.
    def test_mh_09_stops_for_material_scope_or_authority_changes(self) -> None:
        for required in (
            "new authority",
            "paid/destructive/external action",
            "Autonomy never expands authority",
            "material scope expansion",
        ):
            self.assertIn(required, self.autonomy)

    def test_autonomy_core_is_compact_and_branches_are_direct(self) -> None:
        self.assertLessEqual((len(self.autonomy) + 3) // 4, 1050)
        for branch in (AUTONOMY_EXECUTION.name, AUTONOMY_SCENARIOS.name):
            self.assertIn(branch, self.autonomy)
        self.assertNotIn(AUTONOMY_SCENARIOS.name, self.autonomy_execution)
        self.assertNotIn(AUTONOMY_EXECUTION.name, self.autonomy_scenarios)

    def test_mh_scenarios_remain_complete_and_test_only(self) -> None:
        for number in range(1, 19):
            self.assertIn(f"`MH-{number:02}`", self.autonomy_scenarios)
        self.assertIn("not a runtime prerequisite", self.autonomy_scenarios)

    # MH-10: normal help is simple; expert help exposes the runtime corpus.
    def test_mh_10_catalog_is_exactly_the_six_domain_public_surface(self) -> None:
        domains = self.catalog["domains"]
        self.assertEqual(EXPECTED_DOMAINS, tuple(domain["id"] for domain in domains))
        self.assertEqual(set(EXPECTED_OWNERS), set(self.owner_by_id()))
        self.assertEqual("shipglows", self.catalog["router"]["id"])
        self.assertEqual("000-shipglows", self.catalog["router"]["runtime_skill"])
        self.assertTrue(self.registry["internal_catalog"]["include_all_runtime_skills"])
        public_sources = {str(skill["public_skill"]) for skill in self.skills}
        public_sources.add(str(self.catalog["router"]["public_skill"]))
        expert = {path.parent.name for path in SKILLS.glob("*/SKILL.md")} - public_sources
        self.assertTrue(expert)

    def test_public_surface_has_consistent_human_interface_metadata(self) -> None:
        public_entries = self.skills + [self.catalog["router"]]
        display_names: set[str] = set()
        for entry in public_entries:
            public_skill = str(entry["public_skill"])
            metadata_path = SKILLS / public_skill / "agents" / "openai.yaml"
            metadata = metadata_path.read_text(encoding="utf-8")

            def value(field: str) -> str:
                match = re.search(rf'(?m)^  {field}: "([^"]+)"$', metadata)
                self.assertIsNotNone(match, f"{public_skill}: missing interface.{field}")
                return match.group(1)

            display_name = value("display_name")
            short_description = value("short_description")
            default_prompt = value("default_prompt")
            self.assertEqual(EXPECTED_DISPLAY_NAMES[public_skill], display_name)
            self.assertNotIn(display_name, display_names, public_skill)
            self.assertGreaterEqual(len(short_description), 25, public_skill)
            self.assertLessEqual(len(short_description), 64, public_skill)
            self.assertIn(f"${public_skill}", default_prompt, public_skill)
            display_names.add(display_name)

    # MH-11 / MH-12: all public capability ownership is unique, explicit, and
    # maps to one existing runtime engine without competing public aliases.
    def test_mh_11_and_mh_12_have_complete_unique_runtime_ownership(self) -> None:
        owners = self.owner_by_id()
        self.assertEqual(EXPECTED_OWNERS, {name: item["runtime_skill"] for name, item in owners.items()})
        self.assertEqual(set(EXPECTED_OWNERS), {str(item["public_skill"]) for item in owners.values()})
        runtime_names = [str(item["runtime_skill"]) for item in owners.values()]
        self.assertEqual(len(runtime_names), len(set(runtime_names)))
        for runtime_skill in runtime_names + [str(self.catalog["router"]["runtime_skill"])]:
            self.assertTrue((SKILLS / runtime_skill / "SKILL.md").is_file(), runtime_skill)
            self.assertIn(f"`{runtime_skill}`", self.code_index)
        for public_skill in list(owners) + ["shipglows"]:
            source = SKILLS / public_skill / "SKILL.md"
            self.assertTrue(source.is_file(), public_skill)
            self.assertIn(f"name: {public_skill}", source.read_text(encoding="utf-8"), public_skill)
        self.assertTrue(self.registry["internal_catalog"]["include_all_runtime_skills"])
        public_sources = set(owners) | {"shipglows"}
        for internal in {path.parent.name for path in SKILLS.glob("*/SKILL.md")} - public_sources:
            if internal not in runtime_names and internal != self.catalog["router"]["runtime_skill"]:
                self.assertNotIn(internal, owners, internal)


if __name__ == "__main__":
    unittest.main()
