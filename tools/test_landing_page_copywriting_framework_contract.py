#!/usr/bin/env python3
"""Contract checks for the reusable landing-page copywriting framework."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
FRAMEWORK = ROOT / "skills" / "references" / "landing-page-copywriting-framework.md"
SKILL = ROOT / "skills" / "009-sg-marketing" / "SKILL.md"
PLAYBOOK = (
    ROOT
    / "skills"
    / "009-sg-marketing"
    / "references"
    / "copywriting-audit-playbook.md"
)
FRAMEWORK_NAME = "landing-page-copywriting-framework.md"
FRAMEWORK_PATH = "$SHIPGLOWS_ROOT/skills/references/landing-page-copywriting-framework.md"


class LandingPageCopywritingFrameworkContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        if not FRAMEWORK.is_file():
            raise AssertionError(f"missing canonical framework: {FRAMEWORK}")
        cls.framework = FRAMEWORK.read_text(encoding="utf-8")
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.playbook = PLAYBOOK.read_text(encoding="utf-8")
        cls.activation = cls.framework.split("## Activation\n", 1)[1].split("\n## ", 1)[0]
        cls.shared_gates = cls.skill.split("## Conditional Shared Gates\n", 1)[1].split(
            "\n## ", 1
        )[0]

    def test_lpf_load_uses_one_local_playbook_then_shared_doctrine(self) -> None:
        """LPF-LOAD: landing-only requests load doctrine without adding a mode."""
        self.assertIn("### LPF-LOAD", self.framework)
        self.assertIn(FRAMEWORK_PATH, self.playbook)
        self.assertIn(FRAMEWORK_PATH, self.skill)
        for trigger in ("landing", "sales", "offer", "section flow", "repetition"):
            self.assertIn(trigger, self.playbook.lower())
        for boundary in (
            "after the `copywriting` playbook",
            "one local playbook",
            "shared doctrine",
            "does not load",
        ):
            self.assertIn(boundary, self.skill)
        public_modes = re.findall(
            r"^- `([a-z]+) <target>` -> load `references/[^`]+`",
            self.skill,
            flags=re.MULTILINE,
        )
        self.assertEqual(public_modes, ["market", "gtm", "copy", "copywriting"])
        self.assertIn(
            'argument-hint: "<market|gtm|copy|copywriting> <target> | help"',
            self.skill,
        )

    def test_lpf_load_skips_non_landing_without_explicit_section_need(self) -> None:
        self.assertIn(
            "A non-landing target without an explicit page-section-flow need does not load this framework",
            self.activation,
        )
        self.assertIn(
            "A non-landing target without that need does not load it",
            self.shared_gates,
        )

    def test_lpf_load_accepts_explicit_section_need_on_bounded_target(self) -> None:
        expected_activation_rule = (
            "the request explicitly concerns section order, section flow, reading flow, "
            "repetition, proof placement, objection placement, or CTA sequence on the bounded target."
        )
        self.assertIn(expected_activation_rule, self.activation)
        self.assertNotIn("on such a page", self.activation)
        self.assertIn(
            "explicit section-flow or repetition work on the bounded target",
            self.shared_gates,
        )

    def test_lpf_sequence_defines_inputs_spine_ledgers_and_actions(self) -> None:
        """LPF-SEQUENCE: every section advances a distinct reader decision."""
        self.assertIn("### LPF-SEQUENCE", self.framework)
        for required_input in (
            "intended buyer",
            "awareness level",
            "page goal",
            "offer",
            "product truth",
            "proof inventory",
            "objections",
            "CTA destination",
            "business",
            "brand",
            "editorial",
        ):
            self.assertIn(required_input, self.framework)
        for contract in (
            "Reader-Question Argument Spine",
            "Section Role Ledger",
            "Landing Sequence Plan",
            "not AIDA",
            "decision system",
        ):
            self.assertIn(contract, self.framework)
        for field in (
            "Section identity",
            "Reader question",
            "Unique job",
            "New information",
            "Claim IDs",
            "Proof",
            "Objection handled",
            "Transition",
            "CTA role",
            "Recommended action",
        ):
            self.assertIn(field, self.framework)
        for action in ("`keep`", "`move`", "`merge`", "`delete`", "`create`"):
            self.assertIn(action, self.framework)

    def test_lpf_dedupe_requires_material_value_for_later_mentions(self) -> None:
        """LPF-DEDUPE: cosmetic paraphrase is not intentional repetition."""
        self.assertIn("### LPF-DEDUPE", self.framework)
        self.assertIn("Repetition Ledger", self.framework)
        self.assertIn("first authoritative exposition", self.framework)
        for material_reason in (
            "proof",
            "specificity",
            "contrast",
            "objection handling",
            "recap value",
            "decision value",
            "distinct CTA function",
        ):
            self.assertIn(material_reason, self.framework)
        self.assertIn("cosmetic paraphrase", self.framework)

    def test_lpf_claims_keeps_the_strongest_honest_sequence(self) -> None:
        """LPF-CLAIMS: unsupported persuasion remains a visible evidence gap."""
        self.assertIn("### LPF-CLAIMS", self.framework)
        for risky_claim in (
            "testimonial",
            "user count",
            "conversion result",
            "guarantee",
            "urgency",
            "price",
            "capability",
        ):
            self.assertIn(risky_claim, self.framework)
        for safety_rule in (
            "needs proof",
            "claim mismatch",
            "must not invent",
            "must not strengthen",
            "strongest honest sequence",
        ):
            self.assertIn(safety_rule, self.framework)

    def test_sequence_coordinates_proof_objections_and_ctas(self) -> None:
        for phrase in (
            "proof before the claim-dependent ask",
            "objection before the decision it blocks",
            "CTA progression",
            "primary CTA",
            "secondary CTA",
        ):
            self.assertIn(phrase, self.framework)
        for phrase in (
            "Landing Sequence Plan",
            "keep|move|merge|delete|create",
            "strategic sequence",
            "sentence-level",
        ):
            self.assertIn(phrase, self.playbook)

    def test_error_behavior_is_visible_and_does_not_improvise(self) -> None:
        for phrase in (
            "## Error Behavior",
            "confidence-limited",
            "blocked",
            "concrete owner route",
            "must not improvise",
            "does not load",
        ):
            self.assertIn(phrase, self.framework)
        self.assertIn("missing shared framework", self.playbook)
        self.assertIn("concrete owner route", self.playbook)

    def test_reference_layering_and_project_copy_exclusion(self) -> None:
        for owner_reference in (
            "design-inspiration-library.md",
            "content-quality-rubric.md",
            "editorial-content-corpus.md",
            "decision-quality-contract.md",
        ):
            self.assertIn(owner_reference, self.framework)
        self.assertNotIn("ReplayGlowz", self.framework)
        self.assertLessEqual(len(self.skill.splitlines()), 180)


if __name__ == "__main__":
    unittest.main()
