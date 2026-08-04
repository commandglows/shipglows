#!/usr/bin/env python3
"""Regression checks for shared-token and component migration doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOKEN_CONTRACT = ROOT / "skills" / "references" / "design-system-token-contract.md"
DESIGN_SKILL = ROOT / "skills" / "006-sg-design" / "SKILL.md"
TOKEN_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "design-token-audit-playbook.md"
COMPONENT_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "component-system-audit-playbook.md"
A11Y_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "accessibility-audit-playbook.md"
ANIMATION_PLAYBOOK = ROOT / "skills" / "006-sg-design" / "references" / "animation-playbook.md"
LIFECYCLE_ROUTING = ROOT / "skills" / "006-sg-design" / "references" / "design-lifecycle-routing.md"
PROOF_GUIDANCE = ROOT / "skills" / "006-sg-design" / "references" / "design-proof-and-reporting.md"
README = ROOT / "README.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
RUNTIME = ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md"


def normalized_text(path: Path) -> str:
    """Make contract assertions resilient to intentional Markdown wrapping."""
    return " ".join(path.read_text(encoding="utf-8").split())


class DesignContractTests(unittest.TestCase):
    def test_parallel_token_files_do_not_prove_shared_authority(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        audit = TOKEN_AUDIT.read_text(encoding="utf-8")
        self.assertIn("Multiple applications do not share a design system merely because", contract)
        self.assertIn("Parallel hand-maintained token files", contract)
        self.assertIn("compare resolved values and rendered roles", audit)
        self.assertIn("split-brain authority", audit)

    def test_component_migration_separates_behavior_and_visual_ownership(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        audit = COMPONENT_AUDIT.read_text(encoding="utf-8")
        self.assertIn("## Behavior And Visual Ownership Gate", contract)
        self.assertIn("headless primitives own semantics, focus, keyboard interaction", contract)
        self.assertIn("project wrappers own visual composition", contract)
        self.assertIn("Never recommend copying vendor component internals", audit)
        self.assertIn("Prefer incremental replacement behind project-owned wrappers", audit)

    def test_keyboard_parity_is_explicit_regression_proof(self) -> None:
        contract = TOKEN_CONTRACT.read_text(encoding="utf-8")
        a11y = A11Y_AUDIT.read_text(encoding="utf-8")
        skill = DESIGN_SKILL.read_text(encoding="utf-8")
        for behavior in (
            "Tab and Shift+Tab order",
            "pattern-specific arrows and Home/End",
            "Escape",
            "focus restoration",
            "application shortcuts",
        ):
            self.assertIn(behavior, contract)
        self.assertIn("build this matrix per affected primitive", a11y)
        self.assertIn("matching screenshots do not prove interaction parity", a11y)
        self.assertIn("copies vendor internals without equivalent regression proof", skill)

    def test_animation_mode_has_exact_provider_neutral_grammar(self) -> None:
        skill = normalized_text(DESIGN_SKILL)
        routing = normalized_text(LIFECYCLE_ROUTING)
        playbook = normalized_text(ANIMATION_PLAYBOOK)
        grammar = "animation <audit|design|implement|tune> [scope]"

        self.assertIn(grammar, skill)
        self.assertIn(grammar, routing)
        self.assertIn("`gsap` is not a public mode or alias", routing)
        self.assertIn("GSAP is an optional web adapter", playbook)
        self.assertIn("must list exactly `audit`, `design`, `implement`, and `tune`", routing)
        self.assertIn("perform no source edit", routing)

    def test_whole_page_animation_requires_a_motion_system_not_effect_sprawl(self) -> None:
        playbook = normalized_text(ANIMATION_PLAYBOOK)

        self.assertIn("reusable global patterns", playbook)
        self.assertIn("bounded section overrides", playbook)
        self.assertIn("animation budget", playbook)
        self.assertIn("Do not assign an arbitrary effect to every section", playbook)

    def test_gsap_selection_requires_fit_freshness_and_lifecycle_checks(self) -> None:
        playbook = normalized_text(ANIMATION_PLAYBOOK)

        for requirement in (
            "project stack and interaction fit",
            "current official documentation",
            "dependency, plugin, and licensing fit",
            "framework lifecycle fit",
            "performance and bundle impact",
        ):
            self.assertIn(requirement, playbook)
        self.assertIn("Never install GSAP", playbook)

    def test_animation_implementation_requires_accessible_responsive_safe_cleanup(self) -> None:
        playbook = normalized_text(ANIMATION_PLAYBOOK).lower()
        proof = normalized_text(PROOF_GUIDANCE).lower()

        for requirement in (
            "prefers-reduced-motion",
            "meaningful low-motion or no-motion outcome",
            "recompute responsive measurements",
            "content remains available if javascript, observers, or the animation engine fail",
            "mount/unmount cleanup",
            "duplicate initialization prevention",
        ):
            self.assertIn(requirement, playbook)
        self.assertIn("browser proof for reduced-motion", proof)
        self.assertIn("cleanup and remount behavior", proof)

    def test_animation_performance_and_read_only_rules_are_explicit(self) -> None:
        playbook = normalized_text(ANIMATION_PLAYBOOK)
        routing = normalized_text(LIFECYCLE_ROUTING)

        self.assertIn("Prefer transform and opacity", playbook)
        self.assertIn("layout- or paint-heavy animation", playbook)
        self.assertIn("measured justification", playbook)
        self.assertIn("Audit and design are read-only", routing)
        self.assertIn("Broad whole-page or multi-section implementation is spec-first", routing)

    def test_animation_mode_is_discoverable_without_ai_builder_claims(self) -> None:
        grammar = "animation <audit|design|implement|tune> [scope]"
        for document in (README, CHEATSHEET, RUNTIME):
            contents = normalized_text(document)
            self.assertIn(grammar, contents)
            self.assertIn("GSAP is optional", contents)


if __name__ == "__main__":
    unittest.main()
