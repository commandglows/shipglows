#!/usr/bin/env python3
"""Regression checks for proportional skill selection on atomic edits."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
FIDELITY = ROOT / "skills" / "references" / "skill-execution-fidelity.md"
CONTENT = ROOT / "skills" / "007-sg-content" / "SKILL.md"
ENRICH = ROOT / "skills" / "201-sg-enrich" / "SKILL.md"
ROUTER = ROOT / "skills" / "000-shipglows" / "SKILL.md"
ENTRYPOINT = ROOT / "skills" / "references" / "entrypoint-routing.md"
START = ROOT / "skills" / "102-sg-start" / "SKILL.md"
README = ROOT / "README.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
WORKFLOW = ROOT / "shipglows_data" / "workflow" / "playbooks" / "spec-driven-workflow.md"
PUBLIC_ROUTER = ROOT / "shipglows-site" / "src" / "content" / "skills" / "shipglows.md"


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
            PUBLIC_ROUTER.read_text(encoding="utf-8"),
        ]

    def test_shared_gate_directs_atomic_work_without_a_lifecycle(self) -> None:
        for phrase in (
            "## Skill Selection Proportionality Gate",
            "Directly execute the request when all of these are true",
            "change one `h1` to `h2`",
            "Lorem ipsum",
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
        gate = self.router.index("## Atomic Direct-Execution Gate")
        routing = self.router.index("## Shared Routing Reference")
        self.assertLess(gate, routing)
        self.assertIn("Before loading routing, topology, or owner-skill references", self.router)
        self.assertIn("no owner skill", self.router)
        self.assertIn("An explicitly named skill still activates", self.router)
        self.assertNotIn("unless the request reveals a safer owner", self.router)
        self.assertIn("let that skill reroute explicitly", self.router)

    def test_entrypoint_matrix_has_a_direct_atomic_route(self) -> None:
        self.assertIn("Skill Selection Proportionality Gate", self.entrypoint)
        self.assertIn("Exact string, placeholder, typo, heading-tag", self.entrypoint)
        self.assertIn("Direct main-thread execution with focused validation; no owner skill", self.entrypoint)

    def test_pressure_scenarios_cover_both_activation_branches(self) -> None:
        self.assertIn("ATOMIC-DIRECT", self.fidelity)
        self.assertIn("EXPLICIT-SKILL", self.fidelity)

    def test_implementation_skill_does_not_reabsorb_micro_edits(self) -> None:
        self.assertIn("substantive local implementation tasks", self.start)
        self.assertIn("Atomic direct execution", self.start)
        self.assertIn("stays outside `102-sg-start`", self.start)

    def test_operator_and_public_docs_expose_the_same_atomic_route(self) -> None:
        for document in self.public_docs:
            self.assertIn("deterministic micro-edits", document)
            self.assertIn("focused validation", document)


if __name__ == "__main__":
    unittest.main()
