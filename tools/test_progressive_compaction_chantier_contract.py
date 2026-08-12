#!/usr/bin/env python3
"""Lifecycle coherence checks for progressive activation compaction waves 4 through 16."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPECS = ROOT / "shipglows_data" / "workflow" / "specs"
WAVE_4 = SPECS / "progressive-lifecycle-activation-compaction-wave-4.md"
WAVE_5 = SPECS / "progressive-skill-activation-compaction-wave-5.md"
WAVE_6 = SPECS / "progressive-contract-activation-compaction-wave-6.md"
WAVE_7 = SPECS / "progressive-proof-activation-compaction-wave-7.md"
WAVE_8 = SPECS / "progressive-domain-activation-compaction-wave-8.md"
WAVE_9 = SPECS / "canonical-skill-activation-graph-and-core-compaction-wave-9.md"
WAVE_10 = SPECS / "release-entitlement-compaction-and-activation-profile-wave-10.md"
WAVE_11 = SPECS / "installed-skill-discovery-budget-remediation-wave-11.md"
WAVE_12 = SPECS / "shared-activation-cores-and-entitlement-doctrine-wave-12.md"
WAVE_13 = SPECS / "executable-resource-graph-and-progressive-reporting-wave-13.md"
WAVE_14 = SPECS / "high-traffic-activation-profiles-wave-14.md"
WAVE_15 = SPECS / "shared-baseline-core-compaction-wave-15.md"
WAVE_16 = SPECS / "progressive-monolithic-workflows-wave-16.md"
REFRESH_LOG = ROOT / "skills" / "REFRESH_LOG.md"


class ProgressiveCompactionChantierContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.wave_4 = WAVE_4.read_text(encoding="utf-8")
        cls.wave_5 = WAVE_5.read_text(encoding="utf-8")
        cls.wave_6 = WAVE_6.read_text(encoding="utf-8")
        cls.wave_7 = WAVE_7.read_text(encoding="utf-8")
        cls.wave_8 = WAVE_8.read_text(encoding="utf-8")
        cls.wave_9 = WAVE_9.read_text(encoding="utf-8")
        cls.wave_10 = WAVE_10.read_text(encoding="utf-8")
        cls.wave_11 = WAVE_11.read_text(encoding="utf-8")
        cls.wave_12 = WAVE_12.read_text(encoding="utf-8")
        cls.wave_13 = WAVE_13.read_text(encoding="utf-8")
        cls.wave_14 = WAVE_14.read_text(encoding="utf-8")
        cls.wave_15 = WAVE_15.read_text(encoding="utf-8")
        cls.wave_16 = WAVE_16.read_text(encoding="utf-8")
        cls.refresh_log = REFRESH_LOG.read_text(encoding="utf-8")

    def test_shipped_waves_are_not_left_ready_or_next(self) -> None:
        for text in (self.wave_4, self.wave_5):
            self.assertIn("status: reviewed", text)
            self.assertNotIn("005-sg-ship (next)", text)
        self.assertNotIn("- [ ]", self.wave_5)
        self.assertIn("status: reviewed", self.wave_6)
        self.assertIn("005-sg-ship (next)", self.wave_6)
        self.assertNotIn("- [ ]", self.wave_6)
        self.assertIn("status: reviewed", self.wave_7)
        self.assertIn("005-sg-ship (next)", self.wave_7)
        self.assertNotIn("- [ ]", self.wave_7)
        self.assertIn("status: reviewed", self.wave_8)
        self.assertIn("005-sg-ship (next)", self.wave_8)
        self.assertNotIn("- [ ]", self.wave_8)
        self.assertIn("status: reviewed", self.wave_9)
        self.assertIn("005-sg-ship (next)", self.wave_9)
        self.assertNotIn("- [ ]", self.wave_9)
        self.assertIn("status: reviewed", self.wave_10)
        self.assertIn("005-sg-ship (next)", self.wave_10)
        self.assertNotIn("- [ ]", self.wave_10)
        self.assertIn("status: reviewed", self.wave_11)
        self.assertIn("005-sg-ship (next)", self.wave_11)
        self.assertNotIn("- [ ]", self.wave_11)
        self.assertIn("status: reviewed", self.wave_12)
        self.assertIn("005-sg-ship (next)", self.wave_12)
        self.assertNotIn("- [ ]", self.wave_12)
        self.assertIn("status: reviewed", self.wave_13)
        self.assertIn("005-sg-ship (next)", self.wave_13)
        self.assertNotIn("- [ ]", self.wave_13)
        self.assertIn("status: reviewed", self.wave_14)
        self.assertIn("005-sg-ship (next)", self.wave_14)
        self.assertNotIn("- [ ]", self.wave_14)
        self.assertIn("status: reviewed", self.wave_15)
        self.assertIn("005-sg-ship (next)", self.wave_15)
        self.assertNotIn("- [ ]", self.wave_15)
        self.assertIn("status: reviewed", self.wave_16)
        self.assertIn("005-sg-ship (next)", self.wave_16)
        self.assertNotIn("- [ ]", self.wave_16)

    def test_wave_thirteen_records_executable_graph_and_reporting_boundaries(self) -> None:
        for phrase in (
            "ownership and selected resource-closure preflights",
            "`skills/**` dependency traversal is transitive",
            "terminal governance leaves",
            "`--all` remains an explicit non-blocking diagnostic",
            "Explicit `report=agent` has sole priority",
            "three direct conditional leaves",
        ):
            self.assertIn(phrase, self.wave_13)
        self.assertIn("executable resource graph and progressive reporting wave 13", self.refresh_log)

    def test_wave_fourteen_records_high_traffic_profiles_without_compaction(self) -> None:
        for phrase in (
            "Six activation profiles",
            "11,361 tokens for",
            "`010-sg-technical`, 9,517 for `103-sg-verify`, and 6,791 for `300-sg-docs`",
            "canonical-paths.md",
            "intent-to-outcome-autonomy.md",
            "decision-quality-contract.md",
            "without compacting them",
        ):
            self.assertIn(phrase, self.wave_14)
        self.assertIn("high-traffic activation profiles wave 14", self.refresh_log)

    def test_wave_fifteen_records_shared_core_compaction_and_truthful_cost(self) -> None:
        for phrase in (
            "3,128 tokens for `004`",
            "6,177",
            "5,657",
            "3,451",
            "2,081",
            "2,487",
            "direct conditional leaves",
            "never chain to a",
            "`010` and `103` remain visible follow-up",
        ):
            self.assertIn(phrase, self.wave_15)
        self.assertIn("shared baseline core compaction wave 15", self.refresh_log)

    def test_wave_sixteen_records_profiles_and_non_chaining_cores(self) -> None:
        for phrase in (
            "7,196 | 827",
            "6,607 | 808",
            "6,524 | 672",
            "6,189 | 727",
            "5,870 | 799",
            "five new activation profiles",
            "never load sibling leaves",
            "102-sg-start | execute",
            "900-shipglows-core | refresh",
            "103-sg-verify | verify",
            "104-sg-end | close",
        ):
            self.assertIn(phrase, self.wave_16)
        self.assertIn("progressive monolithic workflows wave 16", self.refresh_log)

    def test_wave_five_acceptance_matches_progressive_loading(self) -> None:
        self.assertIn(
            "at most one local playbook loads before the first substantive action",
            self.wave_5,
        )
        self.assertNotIn("one local playbook per owner", self.wave_5)
        for skill in ("700-sg-explore", "104-sg-end", "203-sg-research"):
            self.assertIn(skill, self.wave_5)

    def test_independent_hardening_is_traced(self) -> None:
        self.assertIn("900-shipglows-core | audit/build", self.wave_5)
        self.assertIn("progressive activation compaction wave 5", self.refresh_log)
        self.assertIn("independent post-push review", self.refresh_log.lower())


if __name__ == "__main__":
    unittest.main()
