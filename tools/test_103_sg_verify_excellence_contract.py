#!/usr/bin/env python3
"""Contract checks for the 103-sg-verify excellence focus mode."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "103-sg-verify" / "SKILL.md"
GATES = ROOT / "skills" / "103-sg-verify" / "references" / "verification-gates.md"
README = ROOT / "skills" / "103-sg-verify" / "README.md"
CHEATSHEET = (
    ROOT
    / "shipglows_data"
    / "technical"
    / "operator-guides"
    / "skill-launch-cheatsheet.md"
)
PUBLIC_PAGE = ROOT / "shipglows-site" / "src" / "content" / "skills" / "sg-verify.md"
MAX_ACTIVATION_LINES = 205


class VerifyExcellenceContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.gates = GATES.read_text(encoding="utf-8")
        cls.readme = README.read_text(encoding="utf-8")
        cls.cheatsheet = CHEATSHEET.read_text(encoding="utf-8")
        cls.public_page = PUBLIC_PAGE.read_text(encoding="utf-8")

    def test_ac1_standard_is_default_and_makes_no_excellence_claim(self) -> None:
        self.assertIn("## Mode Detection", self.skill)
        self.assertIn("No mode or `mode=standard` selects `standard`", self.skill)
        self.assertIn("makes no excellence claim", self.skill)
        self.assertIn("`verified`: standard métier and ship-readiness gates pass", self.skill)

    def test_baseline_quality_bar_is_distinct_from_excellence_result_claim(self) -> None:
        self.assertIn("Decision Quality Baseline", self.skill)
        self.assertIn("applies in every mode", self.skill)
        self.assertIn("Excellence Focus Verdict", self.skill)
        self.assertIn("only when the selected mode is `excellence`", self.skill)
        self.assertNotIn("decision quality and excellence verdict", self.skill)

    def test_unambiguous_natural_language_can_select_excellence(self) -> None:
        self.assertIn("unambiguous natural-language request", self.skill)
        self.assertIn("selects `excellence`", self.skill)
        self.assertIn("conflicting/unknown `mode=` values", self.skill)
        self.assertIn("unambiguous natural-language request", self.gates)
        self.assertIn("natural-language request", self.readme)
        self.assertIn("demande naturelle non ambiguë", self.cheatsheet)
        self.assertIn("unambiguous natural-language request", self.public_page)

    def test_mission_exposes_the_question_for_each_focus(self) -> None:
        self.assertIn("standard: Is this work proven enough", self.skill)
        self.assertIn("excellence: Once readiness passes", self.skill)
        self.assertIn("what material quality gap remains", self.skill)

    def test_ac2_material_gap_reopens_follow_up_without_rewriting_verified_history(self) -> None:
        self.assertIn("`mode=excellence`", self.skill)
        self.assertIn("`verified_with_excellence_gaps`", self.skill)
        self.assertIn("Never rewrite or erase an earlier `verified` row", self.skill)
        self.assertIn("EXCELLENCE-002 MATERIAL-GAP", self.gates)
        self.assertIn("bounded follow-up", self.gates)

    def test_ac3_excellent_requires_standard_readiness_and_fresh_second_pass(self) -> None:
        self.assertIn("standard readiness passes first", self.skill)
        self.assertIn("fresh second pass", self.skill)
        self.assertIn("no material excellence gap remains", self.skill)
        self.assertIn("EXCELLENCE-003 NO-MATERIAL-GAP", self.gates)

    def test_ac4_proof_correctness_security_and_risk_verdicts_take_precedence(self) -> None:
        for verdict in ("`partial`", "`not verified`", "`blocked`"):
            self.assertIn(verdict, self.skill)
        self.assertIn("take precedence over excellence verdicts", self.skill)
        self.assertIn("`excellent` is forbidden", self.skill)
        self.assertIn("EXCELLENCE-004 PROOF-OR-RISK-FAILURE", self.gates)

    def test_ac5_taste_level_suggestions_do_not_reopen_the_chantier(self) -> None:
        self.assertIn("Pure taste", self.gates)
        self.assertIn("do not reopen the chantier", self.gates)
        self.assertIn("EXCELLENCE-005 NON-MATERIAL-SUGGESTION", self.gates)

    def test_ac6_atomic_work_keeps_focused_proportional_evidence(self) -> None:
        self.assertIn("deterministic atomic change", self.gates)
        self.assertIn("focused evidence", self.gates)
        self.assertIn("does not force an unrelated exhaustive audit", self.gates)
        self.assertIn("EXCELLENCE-006 ATOMIC-PROPORTIONALITY", self.gates)

    def test_mode_is_discoverable_without_claiming_a_specialist_audit(self) -> None:
        for text in (self.readme, self.cheatsheet, self.public_page):
            self.assertIn("mode=excellence", text)
            self.assertIn("verified_with_excellence_gaps", text)
            self.assertIn("excellent", text)
        self.assertIn("does not replace specialist audits", self.readme)
        self.assertIn("ne remplace pas un audit spécialiste", self.cheatsheet)
        self.assertIn("does not replace a specialist audit", self.public_page)

    def test_activation_contract_stays_compact_and_loads_local_detail(self) -> None:
        self.assertLessEqual(len(self.skill.splitlines()), MAX_ACTIVATION_LINES)
        self.assertIn("references/verification-gates.md", self.skill)
        self.assertIn("detailed excellence pass", self.skill)


if __name__ == "__main__":
    unittest.main()
