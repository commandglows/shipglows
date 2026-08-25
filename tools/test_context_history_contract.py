#!/usr/bin/env python3
"""Contract tests for automatic Context Head and changelog lifecycle adoption."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "skills/references/context-history-and-head.md"
QUALITY = ROOT / "skills/references/context-quality-contract.md"
CONTEXT = ROOT / "skills/301-sg-context/SKILL.md"
CHANGELOG = ROOT / "skills/304-sg-changelog/SKILL.md"
CLOSURE = ROOT / "skills/104-sg-end/SKILL.md"
SHIP = ROOT / "skills/005-sg-ship/SKILL.md"
TOOL = ROOT / "tools/context_history.py"


def compact(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split()).casefold()


class ContextHistoryContractTests(unittest.TestCase):
    def test_shared_reference_owns_significance_freshness_and_public_boundary(self) -> None:
        doctrine = compact(REFERENCE)
        for marker in (
            "significant event capture",
            "year/month/day",
            "parallel work never appends to a shared daily file",
            "public projection gate",
            "english and french",
            "delivery proof",
            "raw history objects never become page props",
            "30 significant events",
            "16,000 characters",
        ):
            self.assertIn(marker, doctrine)

    def test_context_quality_and_context_skill_prefer_bounded_head_without_promoting_it(self) -> None:
        quality = compact(QUALITY)
        context = compact(CONTEXT)
        self.assertIn("context-history-and-head.md", quality)
        self.assertIn("context-history-and-head.md", context)
        self.assertIn("never canonical truth", quality)
        self.assertIn("--no-write", context)
        self.assertIn("revalidate material claims", context)

    def test_closure_shipping_and_changelog_share_one_event_contract(self) -> None:
        for consumer in (CLOSURE, SHIP, CHANGELOG):
            with self.subTest(consumer=consumer):
                self.assertIn("context-history-and-head.md", compact(consumer))
        self.assertIn("at most one significant delivery event", compact(SHIP))
        self.assertIn("structured history first", compact(CHANGELOG))
        self.assertIn("public eligibility is never inferred from a commit message alone", compact(CHANGELOG))

    def test_tool_stays_standard_library_and_exposes_bounded_commands(self) -> None:
        source = TOOL.read_text(encoding="utf-8")
        for marker in ("append_event", "generate_context_head", "cache_status", "--no-write", "MAX_FILES", "MAX_EVENTS"):
            self.assertIn(marker, source)
        for dependency in ("requests", "pydantic", "yaml", "jsonschema"):
            self.assertNotIn(f"import {dependency}", source)


if __name__ == "__main__":
    unittest.main()
