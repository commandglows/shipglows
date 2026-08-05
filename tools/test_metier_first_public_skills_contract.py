#!/usr/bin/env python3
"""Scenario-first contract checks for the métier-first public skill surface.

These tests deliberately verify machine-readable ownership and activation
anchors, rather than pretending to evaluate an LLM conversation.  The
pressure scenarios (MH-01 through MH-12) stay deterministic by checking the
contract that every public owner must load and the canonical catalog that
drives public discovery.
"""

from __future__ import annotations

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
AUTONOMY = SKILLS / "references" / "intent-to-outcome-autonomy.md"
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
    "sg-help": "302-sg-help",
}
class MetierFirstPublicSkillsContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.autonomy = AUTONOMY.read_text(encoding="utf-8")
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

    # MH-02: projects can contain several products and surfaces.
    def test_mh_02_preserves_the_full_target_hierarchy(self) -> None:
        target = "project -> product -> surface -> feature"
        self.assertIn(target, self.autonomy)
        self.assertIn("One project may contain several products", self.autonomy)
        self.assertIn("one product may expose several surfaces", self.autonomy)
        self.assertIn(target, self.router)

    # MH-03 / MH-04: only operator-owned business truth becomes a question.
    def test_mh_03_and_mh_04_question_only_material_business_truth(self) -> None:
        for required in (
            "Ask one numbered decision at a time",
            "recommend the strongest professional default",
            "never front-load a generic questionnaire",
            "Stop questioning as soon as a fresh capable agent could execute",
            "implementation mechanics are not operator questions",
        ):
            self.assertIn(required, self.autonomy)
        self.assertIn("product behavior", self.autonomy)
        self.assertIn("security", self.autonomy)
        self.assertIn("cost", self.autonomy)

    # MH-05 / MH-06: internal lifecycle and proof ownership never become work
    # the operator has to coordinate.
    def test_mh_05_and_mh_06_continue_through_internal_lifecycle(self) -> None:
        for required in (
            "Continue automatically after a successful internal stage",
            "Invoke internal engines without asking the operator to select or schedule them",
            "Keep one public outcome owner for cross-métier work",
        ):
            self.assertIn(required, self.autonomy)
        self.assertIn("continue through its owned closure and ship route", self.lifecycle)
        self.assertIn("manual `/104-sg-end`, `/005-sg-ship`, or `/004-sg-deploy`", self.lifecycle)
        self.assertIn("never require the operator to select an owner, skill, or", self.delegation)

    # MH-07: public and internal documentation have distinct public owners.
    def test_mh_07_separates_public_content_from_internal_docs(self) -> None:
        self.assertIn("belong to `sg-docs`", self.autonomy)
        self.assertIn("belong to `sg-content`", self.autonomy)
        self.assertIn("Public README", self.autonomy)
        self.assertIn("Internal architecture", self.autonomy)
        self.assertEqual("007-sg-content", self.owner_by_id()["sg-content"]["runtime_skill"])
        self.assertEqual("300-sg-docs", self.owner_by_id()["sg-docs"]["runtime_skill"])

    # MH-08: data-like product infrastructure is one engineering métier.
    def test_mh_08_routes_sync_access_and_parity_through_engineering(self) -> None:
        engineering = self.owner_by_id()["sg-engineering"]
        self.assertEqual("010-sg-technical", engineering["runtime_skill"])
        self.assertTrue(
            {"600-sg-local-cloud-sync", "601-sg-product-entitlements", "602-sg-platform-parity"}
            .issubset(engineering["internal_engines"])
        )
        self.assertNotIn("sg-data", self.owner_by_id())
        self.assertIn("specialized `600-602` skills remain internal engines", self.autonomy)

    # MH-09: autonomy never silently broadens authority.
    def test_mh_09_stops_for_material_scope_or_authority_changes(self) -> None:
        for required in (
            "new authority",
            "paid/destructive/external action",
            "Autonomy never expands authority",
            "material scope expansion",
        ):
            self.assertIn(required, self.autonomy)

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
