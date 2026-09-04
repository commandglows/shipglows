#!/usr/bin/env python3
"""Regression checks for proportional routing of clear bounded requests."""

from pathlib import Path
import unittest

from tools.test_support import optional_public_site


ROOT = Path(__file__).resolve().parents[1]
FIDELITY = ROOT / "skills" / "references" / "skill-execution-fidelity.md"
CONTENT = ROOT / "skills" / "007-sg-content" / "SKILL.md"
ENRICH = ROOT / "skills" / "201-sg-enrich" / "SKILL.md"
ROUTER = ROOT / "skills" / "000-shipglows" / "SKILL.md"
MAX_ROUTER_LINES = 160
ENTRYPOINT = ROOT / "skills" / "references" / "entrypoint-routing.md"
START = ROOT / "skills" / "102-sg-start" / "SKILL.md"
README = ROOT / "README.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
WORKFLOW = ROOT / "shipglows_data" / "workflow" / "playbooks" / "spec-driven-workflow.md"
PUBLIC_SITE = optional_public_site(ROOT)
PUBLIC_ROUTER = PUBLIC_SITE / "src/content/skills/shipglows.md" if PUBLIC_SITE else None


class SkillSelectionProportionalityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.fidelity = FIDELITY.read_text(encoding="utf-8")
        cls.content = CONTENT.read_text(encoding="utf-8")
        cls.enrich = ENRICH.read_text(encoding="utf-8")
        cls.router = ROUTER.read_text(encoding="utf-8")
        cls.entrypoint = ENTRYPOINT.read_text(encoding="utf-8")
        cls.start = START.read_text(encoding="utf-8")
        cls.public_docs = [
            README.read_text(encoding="utf-8"),
            CHEATSHEET.read_text(encoding="utf-8"),
            WORKFLOW.read_text(encoding="utf-8"),
        ]
        if PUBLIC_ROUTER is not None:
            cls.public_docs.append(PUBLIC_ROUTER.read_text(encoding="utf-8"))

    def test_shared_gate_directs_bounded_work_without_a_lifecycle(self) -> None:
        for phrase in (
            "## Skill Selection Proportionality Gate",
            "Directly execute the request when all of these are true",
            "few coherent actions and targets are enumerable",
            "material product, domain, architecture",
            "change one `h1` to `h2`",
            "Lorem ipsum",
            "exact-scope commit",
            "ordinary resolved push",
            "Do not load a master router merely because its domain label matches",
        ):
            self.assertIn(phrase, self.fidelity)

    def test_explicit_skill_invocation_still_wins(self) -> None:
        self.assertIn("An explicitly named skill still activates", self.fidelity)
        self.assertIn("choose its smallest safe mode", self.fidelity)
        self.assertIn("EXPLICIT-SKILL", self.fidelity)

    def test_content_router_excludes_literal_micro_edits(self) -> None:
        self.assertIn("substantive content lifecycles", self.content)
        self.assertIn("Do not activate it for an explicit atomic string", self.content)
        self.assertIn("Execute that change directly", self.content)

    def test_enrichment_excludes_literal_micro_edits(self) -> None:
        self.assertIn("Enrich substantive content", self.enrich)
        self.assertIn("Do not activate this skill for a literal placeholder", self.enrich)
        self.assertIn("Execute that change directly", self.enrich)

    def test_root_router_short_circuits_before_loading_routing_references(self) -> None:
        gate = self.router.index("## Bounded Direct-Execution Gate")
        routing = self.router.index("## Shared Routing Reference")
        self.assertLess(gate, routing)
        self.assertIn("Before loading routing, topology, or owner-skill references", self.router)
        self.assertIn("no owner skill", self.router)
        self.assertIn("An explicitly named skill still activates", self.router)
        self.assertNotIn("unless the request reveals a safer owner", self.router)
        self.assertIn("let that skill reroute explicitly", self.router)

    def test_root_router_stays_compact_and_delegates_detail_to_canonical_doctrine(self) -> None:
        self.assertLessEqual(len(self.router.splitlines()), MAX_ROUTER_LINES)
        for reference in (
            "entrypoint-routing.md",
            "master-delegation-semantics.md",
            "skill-execution-fidelity.md",
        ):
            self.assertIn(reference, self.router)

    def test_bounded_internal_reference_updates_short_circuit_to_a_focused_registry_edit(self) -> None:
        self.assertIn("Bounded internal reference-register updates", self.router)
        self.assertIn("one focused local lookup", self.router)
        self.assertIn("one primary-source check per supplied reference", self.router)
        self.assertIn("without launching source intake, market study, or documentation topology work", self.router)

    def test_reference_keywords_define_a_stable_url_shorthand(self) -> None:
        for phrase in (
            "`veille <URL>`",
            "`concurrent <URL>` or `inspiration <URL>`",
            "`veille` takes precedence",
            "analyzes without persistence",
        ):
            self.assertIn(phrase, self.router)

    def test_operator_cheatsheet_explains_reference_keyword_outcomes(self) -> None:
        cheatsheet = CHEATSHEET.read_text(encoding="utf-8")
        for phrase in (
            "Veille, concurrent, inspiration",
            "veille <URL>",
            "concurrent <URL>",
            "inspiration <URL>",
        ):
            self.assertIn(phrase, cheatsheet)

    def test_entrypoint_matrix_has_a_direct_bounded_route(self) -> None:
        self.assertIn("Skill Selection Proportionality Gate", self.entrypoint)
        self.assertIn("Clear bounded request with few enumerable actions/targets", self.entrypoint)
        self.assertIn("Direct main-thread execution with focused proof; no owner skill", self.entrypoint)

    def test_pressure_scenarios_cover_both_activation_branches(self) -> None:
        self.assertIn("ATOMIC-DIRECT", self.fidelity)
        self.assertIn("EXPLICIT-SKILL", self.fidelity)

    def test_implementation_skill_does_not_reabsorb_bounded_requests(self) -> None:
        self.assertIn("substantive local implementation tasks", self.start)
        self.assertIn("Clear bounded direct execution", self.start)
        self.assertIn("stays outside `102-sg-start`", self.start)

    def test_operator_and_public_docs_expose_the_same_bounded_route(self) -> None:
        for document in self.public_docs:
            self.assertIn("clear bounded requests", document)
            self.assertIn("focused proof", document)


if __name__ == "__main__":
    unittest.main()
