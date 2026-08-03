#!/usr/bin/env python3
"""Focused tests for exact reference-loader audit coverage."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.audit_shipglows_skills import missing_reference_paths


class AuditShipGlowsSkillReferenceTests(unittest.TestCase):
    def test_missing_shared_and_local_markdown_references_are_reported(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            skill = root / "skills/900-shipglows-core"
            skill.mkdir(parents=True)
            contract = skill / "SKILL.md"
            text = (
                "Load `$SHIPGLOWS_ROOT/skills/references/missing-shared.md`.\n"
                "Load `references/missing-local.md`.\n"
            )
            self.assertEqual(
                missing_reference_paths(contract, text),
                [
                    "referenced Markdown file missing: references/missing-local.md",
                    "referenced Markdown file missing: skills/references/missing-shared.md",
                ],
            )

    def test_existing_references_and_wildcards_do_not_raise(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            skill = root / "skills/900-shipglows-core"
            shared = root / "skills/references"
            local = skill / "references"
            shared.mkdir(parents=True)
            local.mkdir(parents=True)
            contract = skill / "SKILL.md"
            (shared / "shared.md").write_text("ok", encoding="utf-8")
            (local / "local.md").write_text("ok", encoding="utf-8")
            text = (
                "Load `skills/references/shared.md`.\n"
                "Load `references/local.md`.\n"
                "Inspect `skills/*/SKILL.md`.\n"
            )
            self.assertEqual(missing_reference_paths(contract, text), [])


if __name__ == "__main__":
    unittest.main()
