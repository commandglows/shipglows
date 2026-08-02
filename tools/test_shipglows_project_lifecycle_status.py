import unittest
from datetime import datetime, timezone
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from shipglows_project_lifecycle_status import LifecycleError, project


FIXTURE = Path(__file__).parent / "fixtures/project-lifecycle/sample.md"
NOW = datetime(2026, 7, 28, 8, 0, tzinfo=timezone.utc)


class ProjectLifecycleStatusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.markdown = FIXTURE.read_text(encoding="utf-8")

    def test_projection_separates_one_time_recurring_and_open_items(self):
        result = project(self.markdown, now=NOW)
        self.assertTrue(result["ok"])
        self.assertNotIn("example-site:seo-launch-gate:launch", result["today"])
        self.assertIn("example-site:performance-fix:2026-07-26", result["today"])
        security = next(item for item in result["items"] if item["item_id"] == "security-review")
        self.assertTrue(security["history_closed"])
        self.assertEqual(security["next_instance"]["due_at"], "2026-08-03T09:00:00+00:00")

    def test_missing_evidence_cannot_be_verified(self):
        markdown = self.markdown.replace("reports/seo-launch.md", "-").replace("state | Due At", "state | Due At")
        markdown = markdown.replace("| seo-launch-gate | example-site:seo-launch-gate:launch | one_time | seo | SEO launch gate | yes | verified |", "| seo-launch-gate | example-site:seo-launch-gate:launch | one_time | seo | SEO launch gate | yes | verified |")
        result = project(markdown, now=NOW)
        item = next(item for item in result["items"] if item["item_id"] == "seo-launch-gate")
        self.assertEqual(item["state"], "waiting_for_evidence")

    def test_timezone_boundary_projects_into_local_today(self):
        markdown = self.markdown.replace("2026-07-29T10:00:00+00:00", "2026-07-28T23:30:00+00:00")
        result = project(markdown, now=NOW, operator_timezone="America/Los_Angeles")
        self.assertIn("example-site:copy-review:2026-07-29", result["today"])

    def test_duplicate_item_ids_are_diagnostic(self):
        markdown = self.markdown.replace("| copy-review |", "| security-review |", 1)
        result = project(markdown, now=NOW)
        self.assertFalse(result["ok"])
        self.assertEqual(result["duplicate_item_ids"], ["security-review"])

    def test_overdue_items_remain_visible_this_week(self):
        result = project(self.markdown, now=NOW)
        self.assertIn("example-site:performance-fix:2026-07-26", result["this_week"])

    def test_paused_project_suspends_recurring_work(self):
        markdown = self.markdown.replace("## Lifecycle Items", "- Lifecycle phase: `paused`\n\n## Lifecycle Items")
        result = project(markdown, now=NOW)
        self.assertTrue(result["paused"])
        item = next(item for item in result["items"] if item["item_id"] == "security-review")
        self.assertTrue(item["suspended"])
        self.assertNotIn(item["instance_id"], result["today"])

    def test_cycle_and_event_do_not_invent_future_instances(self):
        markdown = self.markdown.replace("| copy-review | example-site:copy-review:2026-07-29 | recurring", "| cycle-review | example-site:cycle-review:2026-07-29 | cyclic")
        result = project(markdown, now=NOW)
        item = next(item for item in result["items"] if item["item_id"] == "cycle-review")
        self.assertNotIn("next_instance", item)


if __name__ == "__main__":
    unittest.main()
