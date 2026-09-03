#!/usr/bin/env python3
"""Regression checks for shared-token and component migration doctrine."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOKEN_CONTRACT = ROOT / "skills" / "references" / "design-system-token-contract.md"
DESIGN_SKILL = ROOT / "skills" / "006-sg-design" / "SKILL.md"
PUBLIC_DESIGN_SKILL = ROOT / "skills" / "sg-design" / "SKILL.md"
TOKEN_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "design-token-audit-playbook.md"
COMPONENT_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "component-system-audit-playbook.md"
A11Y_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "accessibility-audit-playbook.md"
ANIMATION_PLAYBOOK = ROOT / "skills" / "006-sg-design" / "references" / "animation-playbook.md"
IDENTITY_PLAYBOOK = ROOT / "skills" / "006-sg-design" / "references" / "brand-identity-playbook.md"
LIFECYCLE_ROUTING = ROOT / "skills" / "006-sg-design" / "references" / "design-lifecycle-routing.md"
PROOF_GUIDANCE = ROOT / "skills" / "006-sg-design" / "references" / "design-proof-and-reporting.md"
DESIGN_AUDIT = ROOT / "skills" / "006-sg-design" / "references" / "design-audit-playbook.md"
REFERENCE_DRIVEN = ROOT / "skills" / "006-sg-design" / "references" / "reference-driven-frontend-playbook.md"
SYSTEM_CREATION = ROOT / "skills" / "006-sg-design" / "references" / "design-system-creation-playbook.md"
LANDING_COHERENCE = ROOT / "skills" / "references" / "landing-page-experience-coherence.md"
README = ROOT / "README.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
RUNTIME = ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md"
HELP_CATALOG = ROOT / "skills" / "302-sg-help" / "references" / "help-modes-catalog.md"


def normalized_text(path: Path) -> str:
    """Make contract assertions resilient to intentional Markdown wrapping."""
    return " ".join(path.read_text(encoding="utf-8").split())


class DesignContractTests(unittest.TestCase):
    def test_interface_is_a_first_class_bounded_visual_design_mode(self) -> None:
        skill = normalized_text(DESIGN_SKILL)
        routing = normalized_text(LIFECYCLE_ROUTING)

        self.assertIn("interface [scope]", skill)
        for phrase in (
            "`interface` owns the visual and interaction composition",
            "hierarchy, layout, responsive behavior, component composition",
            "does not silently redefine the customer journey, product behavior, brand identity, or design-system foundations",
        ):
            self.assertIn(phrase, routing)

    def test_shared_iconography_canon_is_functional_and_project_overridable(self) -> None:
        contract = normalized_text(TOKEN_CONTRACT)
        creation = normalized_text(SYSTEM_CREATION)

        for phrase in (
            "## Shared Iconography Canon",
            "Phosphor as the default functional icon family",
            "Regular weight by default",
            "Fill may communicate selected or active state",
            "Use Simple Icons only for third-party brand marks",
            "Unicon is an optional web discovery and export tool, not an icon family",
            "constrain its source to Phosphor",
            "project-local design-system authority",
            "one dominant iconography language per surface",
            "Do not retrofit existing projects solely to satisfy this default",
        ):
            self.assertIn(phrase, contract)

        self.assertIn("Iconography: [Phosphor default / documented project exception]", creation)
        self.assertIn("functional iconography follows the shared canon", creation)

    def test_identity_is_a_first_class_non_software_design_outcome(self) -> None:
        skill = normalized_text(DESIGN_SKILL)
        public = normalized_text(PUBLIC_DESIGN_SKILL)
        routing = normalized_text(LIFECYCLE_ROUTING)
        identity = normalized_text(IDENTITY_PLAYBOOK)

        for text in (skill, public, routing):
            self.assertIn("identity", text)
        for phrase in (
            "An identity is a business system",
            "not necessarily a software interface",
            "Marketing owns market, offer, positioning, message strategy, and verbal foundations",
            "Design owns art direction",
            "Content owns editorial expression",
            "Do not require a website, application, or software product",
            "Persist every repository-representable artifact",
            "canonical source link",
            "without agent mediation",
            "IDENTITY-TECH-05",
        ):
            self.assertIn(phrase, identity)

    def test_reference_driven_frontend_requires_project_native_iterative_visual_proof(self) -> None:
        skill = normalized_text(DESIGN_SKILL)
        routing = normalized_text(LIFECYCLE_ROUTING)
        proof = normalized_text(PROOF_GUIDANCE)
        playbook = normalized_text(REFERENCE_DRIVEN)

        self.assertIn("reference-driven-frontend-playbook.md", skill)
        self.assertIn("reference-driven-frontend-playbook.md", routing)
        self.assertIn("reference-driven-frontend-playbook.md", proof)
        for phrase in (
            "DESIGN-REFERENCE-001",
            "representative desktop and mobile",
            "loading, empty, error, and success states",
            "project-native interpretation",
            "Reuse canonical components",
            "creating a parallel component layer",
            "canonical breakpoints",
            "compare hierarchy, composition, spacing, alignment, typography, imagery, overflow, interaction, and responsive behavior",
            "rerender affected viewport-state pairs",
            "A build, lint, unit test, DOM snapshot, or source inspection alone never proves reference fidelity",
            "separate functional, viewport-fit, and visual-quality verdicts",
            "visually clipped result fails even when numeric layout metrics appear acceptable",
            "persistent browser session",
        ):
            self.assertIn(phrase, playbook)

    def test_public_design_owner_is_followable_and_hides_runtime_identity(self) -> None:
        public = PUBLIC_DESIGN_SKILL.read_text(encoding="utf-8")
        runtime = DESIGN_SKILL.read_text(encoding="utf-8")

        for heading in ("## Mission", "## Scope Gate", "## Required References", "## Validation", "## Stop Conditions", "## Report Modes"):
            self.assertIn(heading, public)
        self.assertIn("reporting-contract.md", public)
        self.assertIn("public `sg-design`", runtime)
        self.assertNotIn("sole public entrypoint", runtime)

    def test_public_catalog_exposes_every_design_library_operation(self) -> None:
        catalog = HELP_CATALOG.read_text(encoding="utf-8")
        self.assertIn("library <add|retry|approve|list|status>", catalog)

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

    def test_cyclic_content_requires_continuity_proof(self) -> None:
        audit = normalized_text(COMPONENT_AUDIT)
        for phrase in (
            "COMPONENT-CYCLIC-CONTINUITY",
            "no reachable blank interval",
            "visible seam",
            "reset jump",
            "manual interaction and autoplay",
            "responsive resize",
            "remount",
            "reduced-motion",
            "content-variation proof",
            "explicitly reframed as finite",
        ):
            self.assertIn(phrase, audit)

    def test_page_audit_detects_unexplained_cross_section_drift(self) -> None:
        audit = normalized_text(LANDING_COHERENCE)
        for phrase in (
            "LPX-CROSS-SECTION-GRAMMAR",
            "equivalent sections",
            "alignment axis",
            "icon or media scale",
            "content anatomy and order",
            "one dominant visual grammar",
            "left-aligned and the next centered",
            "large leading icons followed by small incidental icons",
            "operator-preferred grammar",
            "justified exceptions",
            "system-level harmonization",
        ):
            self.assertIn(phrase, audit)

    def test_page_audit_requires_whole_page_harmony_not_local_polish(self) -> None:
        audit = normalized_text(LANDING_COHERENCE)
        for phrase in (
            "LPX-WHOLE-PAGE-HARMONY",
            "whole-page harmony contract",
            "spatial rhythm",
            "proportional hierarchy",
            "iconography language",
            "typographic cadence",
            "transitions between sections",
            "motion intensity",
            "explicit exception budget",
            "cumulative effect fragments the page",
            "purposeful hierarchy",
        ):
            self.assertIn(phrase, audit)

    def test_visual_variation_cannot_disguise_semantic_duplication(self) -> None:
        audit = normalized_text(LANDING_COHERENCE)
        for phrase in (
            "LPX-VISUAL-DISGUISED-DUPLICATION",
            "semantic duplication disguised by visual variation",
            "answer the same reader question",
            "express the same promise",
            "visual difference is not evidence",
            "009-sg-marketing copywriting",
            "landing-page-copywriting-framework.md",
            "merge|delete|move|narrow",
            "must not preserve both sections",
        ):
            self.assertIn(phrase, audit)

    def test_landing_coherence_is_loaded_by_both_owner_playbooks(self) -> None:
        design = normalized_text(DESIGN_AUDIT)
        marketing = normalized_text(ROOT / "skills" / "009-sg-marketing" / "references" / "copywriting-audit-playbook.md")
        path = "$SHIPGLOWS_ROOT/skills/references/landing-page-experience-coherence.md"
        self.assertIn(path, design)
        self.assertIn(path, marketing)
        self.assertIn("semantic-duplication gate before visual polish", design)
        self.assertIn("copywriting sequence first", marketing)

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
