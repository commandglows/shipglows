#!/usr/bin/env python3
"""Regression checks for the 009-sg-marketing dispatcher contract."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "009-sg-marketing" / "SKILL.md"
PLAYBOOKS = {
    "market": ROOT / "skills" / "009-sg-marketing" / "references" / "market-study-playbook.md",
    "gtm": ROOT / "skills" / "009-sg-marketing" / "references" / "gtm-audit-playbook.md",
    "copy": ROOT / "skills" / "009-sg-marketing" / "references" / "copy-audit-playbook.md",
    "copywriting": ROOT / "skills" / "009-sg-marketing" / "references" / "copywriting-audit-playbook.md",
}
MIGRATION_EVIDENCE = (
    ROOT / "skills" / "009-sg-marketing" / "references" / "marketing-contract-migration-evidence.md"
)
CODE_INDEX = ROOT / "skills" / "references" / "skill-code-index.md"
SKILLS_INDEX_PAGE = ROOT / "shipglows-site" / "src" / "pages" / "skills" / "index.astro"
SKILL_MODES_PAGE = ROOT / "shipglows-site" / "src" / "pages" / "skill-modes.astro"
RUNTIME_LIFECYCLE = ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md"
RETIRED_SOURCE_DIRECTORIES = (
    "204-sg-market-study",
    "206-sg-audit-copy",
    "207-sg-audit-copywriting",
    "408-sg-audit-gtm",
)
MATRIX_ROWS = {
    "204-sg-market-study": ("market", "market-study-playbook.md"),
    "408-sg-audit-gtm": ("gtm", "gtm-audit-playbook.md"),
    "206-sg-audit-copy": ("copy", "copy-audit-playbook.md"),
    "207-sg-audit-copywriting": ("copywriting", "copywriting-audit-playbook.md"),
}
MATRIX_RULES = {
    "204-sg-market-study": (
        "source-intake-classification.md",
        "customer-feedback surface",
        "product-behavior-intelligence.md",
        "conservative projections",
        "MARKET-STUDY.md",
        "GO / GO CONDITIONNEL / PRUDENT / NO-GO",
        "never invent market data",
    ),
    "408-sg-audit-gtm": (
        "customer-feedback cross-check",
        "visits, signups, and clicks are not proof",
        "launch readiness",
        "A/B/C/D",
        "traffic-first",
        "do not recommend unshipped features",
    ),
    "206-sg-audit-copy": (
        "content-quality-rubric.md",
        "task-registry-routing.md",
        "at most five private IDs",
        "French typography",
        "surface missing: blog",
        "not an implicit copywriting pass",
    ),
    "207-sg-audit-copywriting": (
        "intended buyer",
        "awareness",
        "fake urgency",
        "fake social proof",
        "Route sentence-level repair or full rewrites to `copy`",
        "do not duplicate the full copy audit",
    ),
}
MAX_ACTIVATION_LINES = 180


class MarketingContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = SKILL.read_text(encoding="utf-8")
        cls.playbooks = {mode: path.read_text(encoding="utf-8") for mode, path in PLAYBOOKS.items()}
        cls.migration_evidence = MIGRATION_EVIDENCE.read_text(encoding="utf-8")
        cls.code_index = CODE_INDEX.read_text(encoding="utf-8")
        cls.skills_index_page = SKILLS_INDEX_PAGE.read_text(encoding="utf-8")
        cls.skill_modes_page = SKILL_MODES_PAGE.read_text(encoding="utf-8")
        cls.runtime_lifecycle = RUNTIME_LIFECYCLE.read_text(encoding="utf-8")

    def test_activation_contract_is_compact(self) -> None:
        self.assertLessEqual(len(self.text.splitlines()), MAX_ACTIVATION_LINES)

    def test_exact_modes_map_to_one_local_playbook(self) -> None:
        expected = {
            "market": "references/market-study-playbook.md",
            "gtm": "references/gtm-audit-playbook.md",
            "copy": "references/copy-audit-playbook.md",
            "copywriting": "references/copywriting-audit-playbook.md",
        }
        for mode, playbook in expected.items():
            self.assertIn(f"`{mode} <target>`", self.text)
            self.assertIn(f"`{playbook}`", self.text)
            self.assertTrue(PLAYBOOKS[mode].is_file(), mode)
        self.assertIn("`help`", self.text)

    def test_exact_public_grammar_and_owner_boundaries_remain(self) -> None:
        self.assertIn(
            'argument-hint: "<market|gtm|copy|copywriting> <target> | help"',
            self.text,
        )
        self.assertIn("`007-sg-content` remains the editorial lifecycle owner", self.text)
        self.assertIn(
            "Generic cited research -> `203-sg-research`; raw URL/source triage as the primary unmet need -> `205-sg-veille`; SEO -> `406-sg-seo`; email sequences -> `emailing`.",
            self.text,
        )

    def test_bare_invalid_and_missing_target_are_safe(self) -> None:
        for rule in (
            "Bare input",
            "unknown mode",
            "`audit` without a subtype",
            "without a target is safe",
            "do not infer one from the repository",
            "Do not run all modes automatically",
        ):
            self.assertIn(rule, self.text)

    def test_copy_and_copywriting_remain_distinct(self) -> None:
        self.assertIn("clear, credible, and usable", self.text)
        self.assertIn("persuades its intended buyer", self.text)
        self.assertIn("Never guess between `copy` and `copywriting`", self.text)
        self.assertIn("does not silently become `copywriting`", self.text)
        self.assertIn("does not duplicate a full copy audit", self.text)

    def test_required_mode_gates_survive(self) -> None:
        self.assertIn("source-intake-classification.md", self.text)
        self.assertIn("product-behavior-intelligence.md", self.text)
        self.assertIn("content-quality-rubric.md", self.text)
        self.assertIn("task-registry-routing.md", self.text)
        self.assertIn("design-inspiration-library.md", self.text)
        self.assertIn("it is draft", self.text)
        self.assertIn("at most five private reference IDs", self.text)

    def test_source_completeness_covers_each_predecessor_contract(self) -> None:
        source_rules = {
            "market": (
                "customer-feedback surface",
                "conservative projections",
                "MARKET-STUDY.md",
                "GO / GO CONDITIONNEL / PRUDENT / NO-GO",
            ),
            "gtm": (
                "Business metadata versions",
                "launch readiness",
                "traffic-first",
                "Do not recommend building unshipped features",
            ),
            "copy": (
                "product interface",
                "French typography",
                "real system states",
                "surface missing: blog",
            ),
            "copywriting": (
                "persona",
                "awareness level",
                "fake social proof",
                "strategic; route sentence-level repair",
            ),
        }
        for mode, rules in source_rules.items():
            for rule in rules:
                self.assertIn(rule, self.playbooks[mode], f"{mode}: {rule}")

    def test_maintenance_matrix_maps_every_retired_contract_to_its_exact_playbook(self) -> None:
        self.assertIn("maintenance and verification reference", self.migration_evidence)
        self.assertIn("must not load it", self.migration_evidence)
        for source, (mode, playbook_name) in MATRIX_ROWS.items():
            self.assertRegex(
                self.migration_evidence,
                rf"\| `{re.escape(source)}` \| `{mode}` \| `references/{re.escape(playbook_name)}` \|",
            )
            self.assertIn(f"`{mode} <target>`", self.text)
            self.assertTrue(PLAYBOOKS[mode].is_file(), source)

    def test_matrix_preserves_all_meaningful_former_contract_rules(self) -> None:
        for source, rules in MATRIX_RULES.items():
            for rule in rules:
                self.assertIn(rule, self.migration_evidence, f"{source}: {rule}")

        destination_rules = {
            "market": ("customer-feedback surface", "conservative projections", "GO / GO CONDITIONNEL / PRUDENT / NO-GO"),
            "gtm": ("launch readiness", "traffic-first", "Do not recommend building unshipped features"),
            "copy": ("French typography", "surface missing: blog", "content-quality-rubric.md"),
            "copywriting": ("intended buyer", "fake urgency", "strategic; route sentence-level repair"),
        }
        for mode, rules in destination_rules.items():
            for rule in rules:
                self.assertIn(rule, self.playbooks[mode], f"{mode}: {rule}")

    def test_neighbour_owners_remain_explicit(self) -> None:
        for owner in (
            "`007-sg-content`",
            "`203-sg-research`",
            "`205-sg-veille`",
            "`406-sg-seo`",
            "`emailing`",
        ):
            self.assertIn(owner, self.text)

    def test_active_taxonomy_keeps_marketing_conditional_and_out_of_master_lists(self) -> None:
        self.assertIn(
            "| `009` | `sg-marketing` | `009-sg-marketing` | Research/strategy/source |",
            self.code_index,
        )
        self.assertNotIn(
            "| `009` | `sg-marketing` | `009-sg-marketing` | Master |",
            self.code_index,
        )
        self.assertIn(
            'skills: "009-sg-marketing, sf-research, sf-veille',
            self.skills_index_page,
        )
        self.assertNotIn(
            'skills: "shipglows, sf-build, sf-maintain, sf-deploy, sf-design, sf-content, 009-sg-marketing',
            self.skills_index_page,
        )
        self.assertIn(
            'examples: "009-sg-marketing, sf-research, sf-veille',
            self.skill_modes_page,
        )
        self.assertNotIn(
            'examples: "shipglows, sf-build, sf-maintain, sf-deploy, sf-design, sf-content, 009-sg-marketing',
            self.skill_modes_page,
        )
        lifecycle_line = next(
            line for line in self.runtime_lifecycle.splitlines() if line.startswith("- Lifecycle/master:")
        )
        research_line = next(
            line for line in self.runtime_lifecycle.splitlines() if line.startswith("- Research/strategy/source:")
        )
        self.assertNotIn("009-sg-marketing", lifecycle_line)
        self.assertIn("`009-sg-marketing`", research_line)
        self.assertIn("`007-sg-content`", lifecycle_line)

    def test_playbooks_preserve_specialist_contracts(self) -> None:
        expected = {
            "market": ("GO / GO CONDITIONNEL / PRUDENT / NO-GO", "DataForSEO", "Chantier potentiel"),
            "gtm": ("positioning", "launch readiness", "operational-record-format.md"),
            "copy": ("product interface", "content-quality-rubric.md", "Claim Impact"),
            "copywriting": ("intended buyer", "fake urgency", "docs/copywriting/persona.md"),
        }
        for mode, phrases in expected.items():
            for phrase in phrases:
                self.assertIn(phrase, self.playbooks[mode], f"{mode}: {phrase}")

    def test_no_compatibility_or_extra_marketing_modes(self) -> None:
        for forbidden in (
            "`strategy`",
            "`research`",
            "`SEO`",
            "`email`",
            "compatibility aliases",
            "retired `009-sg-skill-build` identity as an alias",
        ):
            self.assertIn(forbidden, self.text)

    def test_retired_source_and_old_009_alias_directories_are_absent(self) -> None:
        for directory in RETIRED_SOURCE_DIRECTORIES:
            path = ROOT / "skills" / directory
            self.assertFalse(path.exists() or path.is_symlink(), directory)
        for path in (
            ROOT / "skills" / "009-sg-skill-build",
            ROOT / "plugins" / "shipglows" / "skills" / "009-sg-skill-build",
        ):
            self.assertFalse(path.exists() or path.is_symlink(), path)

    def test_retired_name_policy_keeps_historical_009_provenance_out_of_runtime(self) -> None:
        self.assertIn("`009-sg-marketing` is the only active public marketing identity", self.migration_evidence)
        self.assertIn("historical `source_skill: 009-sg-skill-build` value is provenance", self.migration_evidence)
        self.assertIn("not a `009-sg-marketing` alias", self.migration_evidence)
        self.assertIn("No `skills/009-sg-skill-build/` directory", self.migration_evidence)


if __name__ == "__main__":
    unittest.main()
