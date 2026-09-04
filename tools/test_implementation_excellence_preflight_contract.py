#!/usr/bin/env python3
"""Pressure-scenario checks for the universal implementation preflight."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/implementation-excellence-preflight.md"
DESIGN_CONTRACT = ROOT / "skills/references/design-system-token-contract.md"


class ImplementationExcellencePreflightContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = CONTRACT.read_text(encoding="utf-8")

    def test_contract_has_three_enforced_phases(self) -> None:
        for marker in (
            "Phase 1 — Classify Before The First Write",
            "Phase 2 — Reclassify During Implementation",
            "Phase 3 — Enforce Before Completion",
            "frontend · backend · shared/domain · infrastructure · documentation-only",
            "Implementation Excellence Gate",
            "unresolved applicable obligations prevent a clean verdict",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_frontend_gate_blocks_token_and_primitive_drift(self) -> None:
        for marker in (
            "canonical design-system authority",
            "semantic tokens",
            "maintained shared components",
            "native/headless primitives",
            "keyboard/focus behavior",
            "responsive/adaptive behavior",
            "supported themes",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_frontend_gate_preserves_content_when_javascript_or_animation_fails(self) -> None:
        design_contract = " ".join(DESIGN_CONTRACT.read_text(encoding="utf-8").split())
        for marker in (
            "initial semantic document",
            "must never be the only mechanism that reveals or unlocks them",
            "disabled or failed JavaScript/animation initialization",
            "prefers-reduced-motion",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, design_contract)

        for marker in (
            "initial semantic document",
            "must not be required to reveal or unlock them",
            "failed or disabled JavaScript/animation initialization",
            "IEP-FRONTEND-CONTENT-AVAILABILITY",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_frontend_gate_is_css_first_without_becoming_dogmatic(self) -> None:
        design_contract = " ".join(DESIGN_CONTRACT.read_text(encoding="utf-8").split())
        for marker in (
            "Use semantic HTML and native CSS by default",
            "application state, data, complex interaction, coordination, or runtime measurement",
            "Framework convenience, visual novelty, or an animation library's availability is not sufficient justification",
            "keep the semantic HTML/CSS baseline independently usable",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, design_contract)

        for marker in (
            "use semantic HTML and native CSS by default",
            "record the functional justification for presentation-layer JavaScript",
            "IEP-FRONTEND-CSS-FIRST",
            "over a JavaScript-free dogma",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_backend_gate_covers_authoritative_safety_boundaries(self) -> None:
        for marker in (
            "authoritative boundary",
            "authorization",
            "data isolation server-side",
            "stale writes",
            "idempotence",
            "partial failure",
            "recovery/rollback",
            "backward-compatible",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_shared_gate_is_portable_without_abstracting_adapters(self) -> None:
        for marker in (
            "Separate domain rules and pure decisions",
            "Keep adapters stack-native",
            "stack-agnostic means portable domain meaning",
            "DRY/AHA",
            "Rule of Three",
            "speculative generalization",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, self.contract)

    def test_feature_refactor_fix_and_verify_routes_are_wired(self) -> None:
        consumers = {
            "skills/001-sg-build/SKILL.md": ("Feature and refactor", "Implementation Excellence Gate"),
            "skills/102-sg-start/SKILL.md": ("implementation-excellence-preflight.md", "GARDE-FOUS"),
            "skills/106-sg-fix/SKILL.md": ("implementation-excellence-preflight.md", "Implementation Excellence Gate"),
            "skills/103-sg-verify/SKILL.md": ("implementation-excellence-preflight.md", "independently reconstruct"),
        }
        for relative_path, markers in consumers.items():
            text = (ROOT / relative_path).read_text(encoding="utf-8")
            for marker in markers:
                with self.subTest(relative_path=relative_path, marker=marker):
                    self.assertIn(marker, text)

    def test_start_receipt_is_visible_but_proportional(self) -> None:
        root = (ROOT / "skills/references/reporting-contract.md").read_text(encoding="utf-8")
        self.assertIn("| Approved substantive chantier is actually starting | `reporting-start.md` |", root)
        reporting = (ROOT / "skills/references/reporting-start.md").read_text(encoding="utf-8")
        for marker in (
            "🛡️ GARDE-FOUS",
            "substantive authored or materially modified code",
            "implementation-excellence-preflight.md",
            "omit it for `IEP-MICRO-EDIT` and non-code chantiers",
        ):
            with self.subTest(marker=marker):
                self.assertIn(marker, reporting)

    def test_pressure_scenarios_cover_known_bypass_paths(self) -> None:
        for scenario in (
            "IEP-FRONTEND-TOKENS",
            "IEP-FRONTEND-PRIMITIVE",
            "IEP-FRONTEND-CONTENT-AVAILABILITY",
            "IEP-FRONTEND-CSS-FIRST",
            "IEP-BACKEND-AUTHZ",
            "IEP-BACKEND-CONCURRENCY",
            "IEP-SHARED-BOUNDARY",
            "IEP-SCOPE-GROWTH",
            "IEP-FINAL-ENFORCEMENT",
            "IEP-MICRO-EDIT",
        ):
            with self.subTest(scenario=scenario):
                self.assertIn(scenario, self.contract)


if __name__ == "__main__":
    unittest.main()
