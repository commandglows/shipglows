#!/usr/bin/env python3
"""Focused pressure contracts for the shared functional-excellence doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
FUNCTIONAL = ROOT / "skills/references/functional-excellence-contract.md"
DECISION = ROOT / "skills/references/decision-quality-contract.md"
DESIGN = ROOT / "skills/references/design-system-token-contract.md"
CONTENT = ROOT / "skills/references/content-quality-rubric.md"
INTENT = ROOT / "skills/references/intent-to-outcome-autonomy.md"
SPEC = ROOT / "shipglows_data/workflow/specs/functional-excellence-doctrine.md"


def normalized(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split()).casefold()


class FunctionalExcellenceContractTests(unittest.TestCase):
    def test_core_defines_the_functional_sequence_and_dimensions(self) -> None:
        text = normalized(FUNCTIONAL)
        for marker in (
            "outcome -> functional excellence -> specialized conception -> implementation excellence -> proportional proof",
            "useful",
            "understandable",
            "unobtrusive",
            "honest",
            "durable",
            "thorough",
            "minimal but complete",
        ):
            self.assertIn(marker, text)

    def test_minimalism_cannot_remove_consequential_responsibilities(self) -> None:
        text = normalized(FUNCTIONAL)
        for marker in (
            "no element without a responsibility",
            "no consequential responsibility omitted",
            "security",
            "privacy",
            "accessibility",
            "recovery",
            "context",
            "nuance",
            "proof",
            "simplism, not excellence",
        ):
            self.assertIn(marker, text)

    def test_external_inspiration_is_not_runtime_or_visual_authority(self) -> None:
        text = normalized(FUNCTIONAL)
        for marker in (
            "dieter rams",
            "drams",
            "historical inspiration",
            "neither is a shipglows runtime dependency",
            "visual resemblance",
        ):
            self.assertIn(marker, text)

    def test_decision_quality_activates_function_before_implementation(self) -> None:
        text = normalized(DECISION)
        self.assertIn("functional excellence gate", text)
        self.assertIn("skills/references/functional-excellence-contract.md", text)
        self.assertIn("before conception or implementation", text)
        self.assertIn("`minimal` never means incomplete", text)

    def test_intent_activates_function_before_surface_selection(self) -> None:
        text = normalized(INTENT)
        functional = "skills/references/functional-excellence-contract.md"
        self.assertIn(functional, text)
        self.assertIn("after resolving the outcome and before choosing its surface or work item", text)
        outcome_index = text.index("project -> business/brand/product -> outcome")
        functional_index = text.index(
            "apply functional excellence before selecting the candidate form"
        )
        surface_index = text.index("surface -> work item")
        self.assertLess(outcome_index, functional_index)
        self.assertLess(functional_index, surface_index)

    def test_every_public_metier_loads_intent_autonomy(self) -> None:
        wrappers = sorted((ROOT / "skills").glob("sg-*/SKILL.md"))
        wrappers.append(ROOT / "skills/shipglows/SKILL.md")
        self.assertGreaterEqual(len(wrappers), 14)
        for wrapper in wrappers:
            with self.subTest(wrapper=wrapper.parent.name):
                self.assertIn(
                    "intent-to-outcome-autonomy.md",
                    wrapper.read_text(encoding="utf-8"),
                )

    def test_design_adapts_function_without_equating_it_to_aesthetics(self) -> None:
        text = normalized(DESIGN)
        for marker in (
            "functional design gate",
            "understanding, task completion, trust, accessibility",
            "style imitation, novelty, or spectacle",
            "simplest complete experience",
        ):
            self.assertIn(marker, text)

    def test_content_adapts_function_without_sacrificing_honesty(self) -> None:
        text = normalized(CONTENT)
        for marker in (
            "functional content gate",
            "governed audience intent",
            "context, qualification, source fidelity, provenance, nuance",
            "concise piece that overstates",
        ):
            self.assertIn(marker, text)

    def test_pressure_scenarios_cover_all_requested_surfaces(self) -> None:
        text = normalized(FUNCTIONAL)
        for marker in (
            "fex-product-accumulation",
            "fex-content-concision",
            "fex-design-imitation",
            "fex-system-obtrusion",
            "fex-minimal-incomplete",
            "fex-thorough-clutter",
            "fex-durable-speculation",
        ):
            self.assertIn(marker, text)

    def test_ready_spec_preserves_scope_and_failure_semantics(self) -> None:
        text = normalized(SPEC)
        for marker in (
            "status: ready",
            "products, content, experiences, durable artifacts, workflows, reports, and shipglows mechanisms",
            "minimal means no element without responsibility",
            "no visual redesign, framer component import, or drams asset adoption",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
