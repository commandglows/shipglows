#!/usr/bin/env python3
"""Lifecycle coherence checks for progressive activation compaction waves 4 through 7."""

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
