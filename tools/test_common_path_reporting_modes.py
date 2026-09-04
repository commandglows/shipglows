"""Keep common-path owners aligned with explicit-only agent reporting."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
OWNERS = ("300-sg-docs", "011-sg-pilotage", "900-shipglows-core")


class CommonPathReportingModesTests(unittest.TestCase):
    def test_owner_overrides_cannot_escalate_blockers_or_internal_handoffs(self):
        for owner in OWNERS:
            with self.subTest(owner=owner):
                body = (ROOT / "skills" / owner / "SKILL.md").read_text(encoding="utf-8")
                self.assertIn("reporting-contract.md", body)
                self.assertIn("`report=user`", body)
                self.assertIn("Use `report=agent` only on explicit operator/orchestrator request", body)
                self.assertIn("do not select it", body)
                self.assertIn("Preserve required blocker, proof, and continuity disclosures", body)
                for obsolete in (
                    "use `report=agent` for blocked runs",
                    "Use `report=agent` for detailed tracker anchors",
                    "details and blockers use `report=agent`",
                ):
                    self.assertNotIn(obsolete, body)

    def test_shared_gates_keep_user_risk_detail_and_explicit_handoff_separate(self):
        body = (ROOT / "skills/references/reporting-contract.md").read_text(encoding="utf-8")
        rows = [line for line in body.splitlines() if line.startswith("|")]
        explicit = next(row for row in rows if "Explicit `report=agent`" in row)
        blocked = next(row for row in rows if "Blocked, partial" in row)
        self.assertIn("reporting-agent-handoff.md", explicit)
        self.assertIn("reporting-blocked-and-audit.md", blocked)
        self.assertNotIn("reporting-agent-handoff.md", blocked)
        self.assertIn("never infer it from caller identity or blockers", body)


if __name__ == "__main__":
    unittest.main()
