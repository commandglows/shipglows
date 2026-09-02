import tempfile
import unittest
from pathlib import Path

from tools.audit_project_pitches import audit_project, discover_projects


class AuditProjectPitchesTests(unittest.TestCase):
    def test_docs_workflows_and_pitch_tag_use_the_audit_contract(self):
        repository = Path(__file__).resolve().parents[1]
        governance = (repository / "skills/300-sg-docs/references/governance-playbooks.md").read_text(
            encoding="utf-8"
        )
        bootstrap = (repository / "skills/300-sg-docs/references/simple-bootstrap-playbooks.md").read_text(
            encoding="utf-8"
        )
        routing = (repository / "skills/references/entrypoint-routing.md").read_text(encoding="utf-8")
        self.assertIn("tools/audit_project_pitches.py", governance)
        self.assertIn("root `PITCH.md`", bootstrap)
        self.assertIn("active project's root `PITCH.md` first", routing)

    def test_missing_pitch_is_reported(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "example"
            root.mkdir()
            self.assertEqual(audit_project(root).status, "missing")

    def test_current_pitch_with_navigation_passes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "example"
            (root / "shipglows_data" / "business").mkdir(parents=True)
            (root / "shipglows_data" / "business" / "business.md").write_text(
                'updated: "2026-09-01"\n', encoding="utf-8"
            )
            (root / "PITCH.md").write_text(
                "# Example — Pitch\n\n"
                "> Pitch reviewed: 2026-09-02 · Project state: see canonical sources below\n\n"
                "Example helps people do useful work.\n\n"
                "## Current state\n\nIn development.\n\n"
                "## Navigate\n\n- Business truth: `shipglows_data/business/business.md`\n",
                encoding="utf-8",
            )
            self.assertEqual(audit_project(root).status, "current")

    def test_older_pitch_is_stale(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "example"
            (root / "shipglows_data" / "business").mkdir(parents=True)
            (root / "shipglows_data" / "business" / "product.md").write_text(
                'updated: "2026-09-02"\n', encoding="utf-8"
            )
            (root / "PITCH.md").write_text(
                "# Example — Pitch\n\n"
                "> Pitch reviewed: 2026-09-01 · Project state: see canonical sources below\n\n"
                "## Current state\n\nIn development.\n\n"
                "## Navigate\n\n- Product truth: `shipglows_data/business/product.md`\n",
                encoding="utf-8",
            )
            result = audit_project(root)
            self.assertEqual(result.status, "stale")

    def test_discovery_ignores_non_git_children(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            git_project = root / "managed"
            git_project.mkdir()
            (git_project / ".git").mkdir()
            (root / "notes").mkdir()
            self.assertEqual(discover_projects(root), [git_project])


if __name__ == "__main__":
    unittest.main()
