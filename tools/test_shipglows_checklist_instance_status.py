import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from shipglows_checklist_instance_status import project


FIXTURE = Path(__file__).parent / "fixtures/project-lifecycle/technical-seo-instance.md"


class ChecklistInstanceStatusTests(unittest.TestCase):
    def test_projects_cycle_progress_without_emitting_tasks(self):
        result = project(FIXTURE.read_text(encoding="utf-8"))
        self.assertTrue(result["ok"])
        self.assertEqual(result["checklist_id"], "seo-technical")
        self.assertEqual(result["artifact_status"], "draft")
        self.assertEqual(result["status"], "in_progress")
        self.assertEqual(result["progress"], {"done": 2, "total": 5})
        self.assertEqual(result["current_phase"], "Crawl et indexation")
        self.assertEqual(result["next_control"], "technical-crawl-robots")
        self.assertEqual(result["blocked_controls"], ["technical-crawl-sitemaps"])

    def test_required_verified_control_without_evidence_waits(self):
        markdown = FIXTURE.read_text(encoding="utf-8").replace(
            "| technical-scope-indexable-surfaces | Périmètre et environnement | Indexable surfaces are declared | yes | verified | reports/technical-seo-scope.md | |",
            "| technical-scope-indexable-surfaces | Périmètre et environnement | Indexable surfaces are declared | yes | verified | - | |",
        )
        result = project(markdown)
        item = next(item for item in result["controls"] if item["control_id"] == "technical-scope-indexable-surfaces")
        self.assertEqual(item["status"], "waiting_for_evidence")


if __name__ == "__main__":
    unittest.main()
