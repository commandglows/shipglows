#!/usr/bin/env python3
"""Deterministic contract proof for the 011-sg-pilotage consolidation."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL_ROOT = ROOT / "skills" / "011-sg-pilotage"
SKILL = SKILL_ROOT / "SKILL.md"
README = SKILL_ROOT / "README.md"
PLAYBOOKS = {
    mode: SKILL_ROOT / "references" / f"{mode}-playbook.md"
    for mode in ("tasks", "backlog", "priorities", "review", "sessions")
}
PREDECESSORS = (
    "309-sg-tasks",
    "701-sg-backlog",
    "702-sg-priorities",
    "703-sg-review",
)
CODE_INDEX = ROOT / "skills" / "references" / "skill-code-index.md"
CATALOG = ROOT / "plugins" / "shipglows" / "assets" / "pack-catalog.json"
ACTIVE_DOCS = (
    README,
    ROOT / "plugins" / "shipglows" / "skills" / "shipglows" / "references" / "pack-catalog.md",
    ROOT / "plugins" / "shipglows" / "skills" / "shipglows" / "references" / "public-help-catalog.md",
    ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md",
    ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md",
    ROOT / "shipglows_data" / "technical" / "code-docs-map.md",
    ROOT / "shipglows_data" / "workflow" / "playbooks" / "spec-driven-workflow.md",
)
MAX_ACTIVATION_LINES = 150


class PilotageContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.readme = README.read_text(encoding="utf-8")
        cls.playbooks = {
            mode: path.read_text(encoding="utf-8")
            for mode, path in PLAYBOOKS.items()
        }
        cls.code_index = CODE_INDEX.read_text(encoding="utf-8")
        cls.catalog = json.loads(CATALOG.read_text(encoding="utf-8"))

    def test_pilotage_exact_five_modes(self) -> None:
        """PILOTAGE-EXACT-FIVE-MODES and PILOTAGE-AMBIGUOUS-NO-WRITE."""
        self.assertLessEqual(len(self.skill.splitlines()), MAX_ACTIVATION_LINES)
        self.assertIn(
            'argument-hint: "<tasks|backlog|priorities|review|sessions> [arguments]"',
            self.skill,
        )
        mode_lines = [
            line for line in self.skill.splitlines()
            if re.match(r"^- `(tasks|backlog|priorities|review|sessions)(?: |`)" , line)
        ]
        self.assertEqual(len(mode_lines), 5)
        self.assertEqual(
            {re.match(r"^- `([^ `]+)", line).group(1) for line in mode_lines},
            set(PLAYBOOKS),
        )
        self.assertIn("loads no substantive playbook", self.skill)
        self.assertIn("mutates nothing", self.skill)
        self.assertIn("exactly these five choices", self.skill)
        self.assertNotRegex(self.skill, r"(?m)^- `help(?: |`)" )

    def test_pilotage_one_playbook_per_mode(self) -> None:
        for mode, path in PLAYBOOKS.items():
            self.assertTrue(path.is_file(), path)
            line = next(
                line for line in self.skill.splitlines()
                if re.match(rf"^- `{re.escape(mode)}(?: |`)", line)
            )
            selected = set(re.findall(r"[a-z]+-playbook\.md", line))
            self.assertEqual(selected, {path.name}, mode)
        actual = {path.name for path in (SKILL_ROOT / "references").glob("*-playbook.md")}
        self.assertEqual(actual, {path.name for path in PLAYBOOKS.values()})

    def test_pilotage_tasks_not_sessions_and_local_tracker_safety(self) -> None:
        """PILOTAGE-TASKS-NOT-SESSIONS and PILOTAGE-LOCAL-TRACKER-SAFETY."""
        text = self.playbooks["tasks"]
        for phrase in (
            "tasks sessions",
            "authoritatively re-read",
            "smallest possible patch",
            "re-read once and recompute",
            "never rewrite the whole file from stale context",
            "task-registry-routing.md",
        ):
            self.assertIn(phrase, text)
        self.assertIn("never reads `state_5.sqlite`", text)
        self.assertIn("ask for one explicit project or portfolio scope", text)
        self.assertIn("never creates or mutates a central master tracker", text)
        for forbidden in ("rename_codex_session.py", "prune_codex_sessions.py"):
            self.assertNotIn(forbidden, text)

    def test_pilotage_sessions_status_cwd_and_prune_safety(self) -> None:
        """PILOTAGE-SESSIONS-STATUS-GATE and PILOTAGE-SESSIONS-CWD-AND-PRUNE-SAFETY."""
        text = self.playbooks["sessions"]
        for phrase in (
            "todo`, `doing`, `in_progress`, `blocked`, or `done",
            "CONVERSATION-RENAME-MISSING-STATUS",
            "ask for exactly one supported status",
            "do not derive a title, inspect sessions, call the helper, or mutate",
            "exact absolute `cwd`",
            "current thread",
            "dry-run",
            "exact apply confirmation",
            "strictly more than 30 days",
            "first-N-word extraction",
            "at most five words",
        ):
            self.assertIn(phrase, text)
        self.assertNotIn("name-conversation", text)

    def test_pilotage_backlog_priorities_and_review_boundaries(self) -> None:
        """BACKLOG-NOT-PRIORITY, PRIORITIES-NOT-EXECUTION, and REVIEW-NOT-VERIFY."""
        backlog = self.playbooks["backlog"]
        priorities = self.playbooks["priorities"]
        review = self.playbooks["review"]
        for phrase in ("Discarded", "confirm before deleting", "does not rank active work"):
            self.assertIn(phrase, backlog)
        for phrase in ("impact", "effort", "blockers", "dependencies", "risk", "706-continue", "102-sg-start", "does not execute"):
            self.assertIn(phrase, priorities)
        for phrase in ("implemented", "verified", "assumed", "metadata-bearing", "103-sg-verify", "does not replace verification"):
            self.assertIn(phrase, review)
        self.assertIn("ask for one explicit project or portfolio scope", review)
        self.assertIn("security/risk framing materially ambiguous", review)

    def test_pilotage_neighbor_owners_remain_explicit(self) -> None:
        """PILOTAGE-BOUNDARY-NEIGHBORS."""
        neighbors = {
            "700-sg-explore": "explore",
            "704-sg-model": "model",
            "705-sg-conversation-audit": "conversation audit",
            "706-continue": "continue",
            "308-sg-status": "status",
            "707-name": "Claude statusline",
            "103-sg-verify": "verify",
            "104-sg-end": "close",
        }
        for owner, purpose in neighbors.items():
            self.assertIn(owner, self.skill)
            self.assertIn(purpose, self.skill)
            self.assertTrue((ROOT / "skills" / owner / "SKILL.md").is_file(), owner)

    def test_pilotage_sources_are_retired(self) -> None:
        """PILOTAGE-NO-LEGACY-RUNTIME source-side proof."""
        for predecessor in PREDECESSORS:
            source = ROOT / "skills" / predecessor
            self.assertFalse(source.exists() or source.is_symlink(), predecessor)
            self.assertNotRegex(self.code_index, rf"\| `{predecessor.split('-', 1)[0]}` \|")
        self.assertIn("| `011` | `sg-pilotage` | `011-sg-pilotage` | Master/pilotage |", self.code_index)

    def test_pilotage_active_docs_and_catalog_are_migrated(self) -> None:
        """PILOTAGE-ACTIVE-DOCS-MIGRATION."""
        for path in ACTIVE_DOCS:
            text = path.read_text(encoding="utf-8")
            self.assertIn("011-sg-pilotage", text, path)
            for predecessor in PREDECESSORS:
                self.assertNotIn(predecessor, text, f"{path}: {predecessor}")
        memberships = [
            pack["id"]
            for pack in self.catalog["packs"]
            if "011-sg-pilotage" in pack["skills"]
        ]
        self.assertEqual(memberships, ["shipglows-product"])
        for pack in self.catalog["packs"]:
            for predecessor in PREDECESSORS:
                self.assertNotIn(predecessor, pack["skills"], pack["id"])


if __name__ == "__main__":
    unittest.main()
