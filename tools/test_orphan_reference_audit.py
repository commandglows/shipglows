#!/usr/bin/env python3
"""Focused tests for the ShipGlows orphan documentation audit."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.orphan_reference_audit import audit_orphans, source_kind


def _write(root: Path, relative: str, text: str = "") -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


class OrphanReferenceAuditTests(unittest.TestCase):
    def test_classifies_orphan_weak_unreachable_and_live(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            _write(root, "skills/demo/SKILL.md", "Load `references/live-ref.md`.\n")
            _write(root, "skills/demo/references/live-ref.md", "Then `chained-ref.md`.\n")
            _write(root, "skills/demo/references/chained-ref.md")
            _write(root, "skills/demo/references/lonely-ref.md")
            _write(root, "skills/demo/references/tested-ref.md")
            _write(root, "tools/test_demo.py", "tested-ref.md\n")
            _write(root, "skills/demo/references/island-a.md", "island-b.md\n")
            _write(root, "skills/demo/references/island-b.md")
            classes = {
                item["path"].rsplit("/", 1)[-1]: item["classification"]
                for item in audit_orphans(root)["findings"]
            }
            self.assertEqual(
                classes,
                {
                    "lonely-ref.md": "orphan",
                    "tested-ref.md": "weak",
                    "island-a.md": "orphan",
                    "island-b.md": "unreachable",
                },
            )

    def test_entrypoints_are_not_candidates_and_history_is_weak(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            _write(root, "skills/demo/SKILL.md")
            _write(root, "skills/demo/README.md")
            _write(root, "skills/demo/references/logged-ref.md")
            _write(root, "skills/REFRESH_LOG.md", "logged-ref.md\n")
            payload = audit_orphans(root)
            self.assertEqual(payload["candidates_scanned"], 1)
            self.assertEqual(payload["findings"][0]["classification"], "weak")

    def test_source_kind(self) -> None:
        self.assertEqual(source_kind("tools/fixtures/x/a.md"), "test")
        self.assertEqual(source_kind("tests/cli/a.sh"), "test")
        self.assertEqual(source_kind("CHANGELOG.md"), "history")
        self.assertEqual(source_kind("cli/lib.sh"), "live")


if __name__ == "__main__":
    unittest.main()
