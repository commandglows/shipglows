from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "103-sg-verify" / "SKILL.md"
REFS = SKILL.parent / "references"
PACKS = (
    "verification-baseline.md",
    "verification-excellence.md",
    "verification-security-ui-runtime.md",
    "verification-coherence.md",
    "verification-release-proof.md",
    "verification-ci.md",
)


class VerifyCompactionContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")

    def test_body_meets_wave_four_budget(self) -> None:
        body = self.skill.split("---", 2)[2].lstrip("\n")
        self.assertLessEqual(len(body) / 4, 1900)

    def test_wave_seventeen_body_and_baseline_have_margin(self) -> None:
        baseline = (REFS / "verification-baseline.md").read_text(encoding="utf-8")
        body = self.skill.split("---", 2)[2].lstrip("\n")
        self.assertLess((len(body) + len(baseline)) / 4, 4300)

    def test_standard_route_loads_only_baseline_initially(self) -> None:
        progressive = self.skill.split("## Progressive Verification Packs", 1)[1].split(
            "## Standard Contract", 1
        )[0]
        self.assertIn("verification-baseline.md", progressive)
        self.assertIn("for every run", progressive)
        self.assertIn("Only after standard readiness passes", progressive)
        self.assertIn("then only applicable", progressive)
        self.assertIn("verification-release-proof.md", progressive)
        self.assertIn("verification-ci.md", progressive)
        baseline = (REFS / "verification-baseline.md").read_text(encoding="utf-8")
        body = self.skill.split("---", 2)[2]
        self.assertLess((len(body) + len(baseline)) / 4, 5000)

    def test_packs_exist_are_direct_and_do_not_chain(self) -> None:
        for pack in PACKS:
            self.assertIn(f"references/{pack}", self.skill)
            text = (REFS / pack).read_text(encoding="utf-8")
            for other in PACKS:
                self.assertNotIn(other, text, f"{pack} chains to {other}")
            self.assertIsNone(re.search(r"(?i)\bload\b[^\n]*verification-[^\n]*\.md", text), pack)
        index = (REFS / "verification-gates.md").read_text(encoding="utf-8")
        self.assertIn("Compatibility index only", index)

    def test_verdict_precedence_and_implementation_boundary_remain_local(self) -> None:
        for phrase in (
            "`verified_with_excellence_gaps`",
            "`excellent` is forbidden",
            "take precedence over excellence verdicts",
            "102-sg-start: implemented",
            "103-sg-verify: partial",
            "Passing technical checks never substitutes",
        ):
            self.assertIn(phrase, self.skill)

    def test_external_security_ui_and_visual_proof_stop_clean_verification(self) -> None:
        for phrase in (
            "high/critical bug remains open",
            "external, browser/auth, manual/device, production, or provider proof is missing",
            "critical security/data/workflow risk is unproven",
            "one-off hardcoded values",
            "unresolved design-system drift",
            "owasp-application-security-awareness.md",
            "design-system-token-contract.md",
        ):
            self.assertIn(phrase, self.skill)

    def test_conditional_authorities_remain_explicit(self) -> None:
        for phrase in (
            "$SHIPGLOWS_ROOT/skills/references/canonical-paths.md",
            "$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-baseline.md",
            "$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-excellence.md",
            "$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-security-ui-runtime.md",
            "$SHIPGLOWS_ROOT/skills/103-sg-verify/references/verification-coherence.md",
            "$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md",
            "$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md",
            "$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md",
            "$SHIPGLOWS_ROOT/skills/references/operational-record-format.md",
            "$SHIPGLOWS_ROOT/skills/references/reporting-contract.md",
            "$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md",
        ):
            self.assertIn(phrase, self.skill)
        self.assertIn("Conditional shared gates load from `$SHIPGLOWS_ROOT/skills/references/`", self.skill)

    def test_tracker_is_read_only_and_routes_remain_concrete(self) -> None:
        self.assertIn("Trackers are read-only", self.skill)
        for tracker in ("TASKS.md", "AUDIT_LOG.md", "PROJECTS.md"):
            self.assertIn(tracker, self.skill)
        for owner in ("405-sg-prod", "108-sg-browser", "109-sg-auth-debug", "107-sg-test"):
            self.assertIn(owner, self.skill)

    def test_skill_coherence_and_chantier_reporting_are_conditional(self) -> None:
        coherence = (REFS / "verification-coherence.md").read_text(encoding="utf-8")
        for phrase in ("Trace category", "Process role", "scenario-first", "ZOMBIES coverage"):
            self.assertIn(phrase, coherence)
        for phrase in (
            "Never rewrite or erase an earlier `verified` row",
            "chantier-tracking.md",
            "reporting-contract.md",
            "actionable-failure-contract.md",
        ):
            self.assertIn(phrase, self.skill)


if __name__ == "__main__":
    unittest.main()
