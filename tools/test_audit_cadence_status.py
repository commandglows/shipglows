#!/usr/bin/env python3
"""Scenario tests for deterministic audit-cadence status."""

from datetime import date
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.audit_cadence_status import calculate_audit_status


MATRIX = {
    "schema_version": "1.0",
    "domains": [
        {
            "id": "security",
            "label": "Security",
            "max_age_days": 30,
            "priority": 1,
            "aliases": ["security"],
            "event_triggers": ["auth change"],
        },
        {
            "id": "dependencies",
            "label": "Dependencies",
            "max_age_days": 14,
            "priority": 2,
            "aliases": ["deps", "dependency"],
            "event_triggers": ["lockfile change"],
        },
        {
            "id": "seo",
            "label": "SEO",
            "max_age_days": 30,
            "priority": 3,
            "aliases": ["seo"],
            "event_triggers": ["public route change"],
        },
    ],
}


class AuditCadenceStatusTests(unittest.TestCase):
    def write_fixture(self, root: Path, body: str) -> tuple[Path, Path]:
        matrix = root / "matrix.json"
        audit_log = root / "AUDIT_LOG.md"
        matrix.write_text(json.dumps(MATRIX), encoding="utf-8")
        audit_log.write_text(body, encoding="utf-8")
        return matrix, audit_log

    def test_recent_and_overdue_records_are_classified(self) -> None:
        with TemporaryDirectory() as tmp:
            matrix, audit_log = self.write_fixture(
                Path(tmp),
                "# Audit Log\n\n"
                "audit: Security review | date: 2026-08-10 | domain: security\n"
                "audit: Dependency health | date: 2026-07-01 | domain: dependencies\n",
            )
            result = calculate_audit_status(matrix, audit_log, date(2026, 8, 21))
            by_id = {item["id"]: item for item in result}
            self.assertEqual("current", by_id["security"]["state"])
            self.assertEqual("overdue", by_id["dependencies"]["state"])
            self.assertEqual("never-run", by_id["seo"]["state"])

    def test_legacy_table_and_alias_records_are_understood(self) -> None:
        with TemporaryDirectory() as tmp:
            matrix, audit_log = self.write_fixture(
                Path(tmp),
                "# Audit Log\n\n"
                "| Date | Scope | SEO | Deps |\n"
                "| --- | --- | --- | --- |\n"
                "| 2026-08-01 | project | B | — |\n"
                "audit: Dependency health for site | date: 2026-08-15 | overall: B\n",
            )
            result = calculate_audit_status(matrix, audit_log, date(2026, 8, 21))
            by_id = {item["id"]: item for item in result}
            self.assertEqual("2026-08-01", by_id["seo"]["last_audit"])
            self.assertEqual("2026-08-15", by_id["dependencies"]["last_audit"])

    def test_domain_inference_uses_audit_title_not_issue_text(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            extended = dict(MATRIX)
            extended["domains"] = [
                *MATRIX["domains"],
                {
                    "id": "translation",
                    "label": "Translation",
                    "max_age_days": 30,
                    "priority": 4,
                    "aliases": ["translate", "translation", "locale"],
                    "event_triggers": ["locale change"],
                },
                {
                    "id": "reliability",
                    "label": "Reliability",
                    "max_age_days": 30,
                    "priority": 5,
                    "aliases": ["reliability"],
                    "event_triggers": ["incident"],
                },
            ]
            matrix = root / "matrix.json"
            audit_log = root / "AUDIT_LOG.md"
            matrix.write_text(json.dumps(extended), encoding="utf-8")
            audit_log.write_text(
                "audit: Translate public site | date: 2026-08-10 | overall: accepted "
                "| issues: agent contract reliability | scope: site\n",
                encoding="utf-8",
            )
            result = calculate_audit_status(matrix, audit_log, date(2026, 8, 21))
            by_id = {item["id"]: item for item in result}
            self.assertEqual("2026-08-10", by_id["translation"]["last_audit"])
            self.assertIsNone(by_id["reliability"]["last_audit"])

    def test_event_trigger_becomes_first_actionable_audit(self) -> None:
        with TemporaryDirectory() as tmp:
            matrix, audit_log = self.write_fixture(
                Path(tmp),
                "audit: Security review | date: 2026-08-20 | domain: security\n"
                "audit: Dependency review | date: 2026-08-20 | domain: dependencies\n"
                "audit: SEO review | date: 2026-08-20 | domain: seo\n",
            )
            result = calculate_audit_status(
                matrix, audit_log, date(2026, 8, 21), triggered_domains={"security"}
            )
            self.assertEqual("security", result[0]["id"])
            self.assertEqual("event-triggered", result[0]["state"])

    def test_missing_log_keeps_every_domain_actionable(self) -> None:
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            matrix = root / "matrix.json"
            matrix.write_text(json.dumps(MATRIX), encoding="utf-8")
            result = calculate_audit_status(matrix, root / "missing.md", date(2026, 8, 21))
            self.assertTrue(all(item["state"] == "never-run" for item in result))


if __name__ == "__main__":
    unittest.main()
