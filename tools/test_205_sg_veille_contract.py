#!/usr/bin/env python3
"""Deterministic scenario-first contract for the compact 205 veille dispatcher."""

from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


class VeilleDispatcherContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = read("skills/205-sg-veille/SKILL.md")
        cls.triage = read("skills/205-sg-veille/references/triage-playbook.md")
        cls.persistence = read("skills/205-sg-veille/references/persistence-and-reporting-playbook.md")

    def test_two_public_modes_and_bare_compatibility(self) -> None:
        self.assertIn("Only two public modes exist", self.skill)
        for phrase in ("`triage <sources>`", "`help`", "bare URL or pasted text", "without a second public identity"):
            self.assertIn(phrase, self.skill)
        self.assertNotIn("watchlist", read("skills/205-sg-veille/README.md").lower())

    def test_empty_help_and_continuation_are_side_effect_safe(self) -> None:
        for phrase in ("Colle les liens ou le contenu à analyser.", "Do not fetch, read a source, write", "hidden session/global state"):
            self.assertIn(phrase, self.skill)
        self.assertIn("VEILLE-CONTINUATION-NO-HIDDEN-STATE", self.persistence)

    def test_required_loader_and_owner_boundaries(self) -> None:
        for phrase in (
            "source-intake-classification.md", "editorial-content-corpus.md", "task-registry-routing.md",
            "operational-record-format.md", "203-sg-research", "007-sg-content", "009-sg-marketing",
            "300-sg-docs", "309-sg-tasks",
        ):
            self.assertIn(phrase, self.skill)
        self.assertIn("VEILLE-OWNER-BOUNDARY", self.triage)

    def test_triage_preserves_evidence_and_four_axes(self) -> None:
        for phrase in (
            "marketplace listing", "three layers", "official site", "feedback surface",
            "Contenu", "Architecture", "Concurrence & inspiration", "Opportunité collab",
            "⚔️ CONCURRENT", "surface missing: blog", "VEILLE-MARKETPLACE-THREE-LAYERS",
            "VEILLE-CONTENT-SURFACE-GATE", "VEILLE-RAW-NOT-RESEARCH",
        ):
            self.assertIn(phrase, self.triage)

    def test_persistence_is_explicit_redacted_and_split(self) -> None:
        for phrase in (
            "Only explicit operator decisions", "re-read the exact target", "smallest append/update",
            "shipglows_data/workflow/TASKS.md", "shipglows_data/editorial/ROADMAP.md",
            "Never persist or print tokens", "VEILLE-SPLIT-PERSISTENCE", "VEILLE-CHANTIER-POTENTIAL",
        ):
            self.assertIn(phrase, self.persistence)

    def test_required_scenario_anchors_exist(self) -> None:
        all_text = "\n".join((self.skill, self.triage, self.persistence))
        scenarios = {
            "VEILLE-MODE-BARE-COMPAT", "VEILLE-EMPTY-QUESTION", "VEILLE-HELP-NO-SIDE-EFFECT",
            "VEILLE-RAW-NOT-RESEARCH", "VEILLE-MARKETPLACE-THREE-LAYERS", "VEILLE-CONTENT-SURFACE-GATE",
            "VEILLE-SPLIT-PERSISTENCE", "VEILLE-CONTINUATION-NO-HIDDEN-STATE", "VEILLE-CHANTIER-POTENTIAL",
            "VEILLE-OWNER-BOUNDARY",
        }
        missing = {scenario for scenario in scenarios if scenario not in all_text}
        self.assertEqual(set(), missing)
        self.assertIsNone(re.search(r"^\| `(?:research|content|docs|marketing|backlog|apply)`", self.skill, re.MULTILINE))


if __name__ == "__main__":
    unittest.main()
