#!/usr/bin/env python3
"""Behavior tests for collision-free context history and Context Head freshness."""

from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import subprocess
import unittest

from tools.context_history import (
    ContextHistoryError,
    append_event,
    cache_status,
    generate_context_head,
    load_events,
)


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=root,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return result.stdout.strip()


def repository(root: Path) -> None:
    git(root, "init")
    git(root, "config", "user.email", "context-history@example.invalid")
    git(root, "config", "user.name", "Context History Test")
    (root / "README.md").write_text("# Fixture\n", encoding="utf-8")
    git(root, "add", "README.md")
    git(root, "commit", "-m", "init")


class ContextHistoryTests(unittest.TestCase):
    def test_parallel_appends_create_independent_daily_shards(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)

            def record(index: int) -> Path:
                return append_event(
                    project_root=root,
                    project="fixture",
                    kind="CONTEXT_CHANGE",
                    summary=f"Change {index}",
                    occurred_at="2026-08-25T19:00:00.000000Z",
                )

            with ThreadPoolExecutor(max_workers=8) as executor:
                paths = list(executor.map(record, range(24)))

            self.assertEqual(len(set(paths)), 24)
            self.assertTrue(all(path.parent.relative_to(root).as_posix().endswith("2026/08/25") for path in paths))
            self.assertEqual(len(load_events(root)), 24)

    def test_context_head_becomes_stale_after_dirty_state_changes(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            append_event(root, "fixture", "CONTEXT_DECISION", "Use Context Head")
            result = generate_context_head(root)
            self.assertFalse(cache_status(root)["stale"])
            self.assertLessEqual(len(result.markdown), 16_000)

            (root / "README.md").write_text("# Changed\n", encoding="utf-8")
            status = cache_status(root)
            self.assertTrue(status["stale"])
            self.assertIn("dirtyFingerprint", status["changed"])

    def test_public_payload_requires_both_locales_and_delivery_proof(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            public = {
                "category": "CHANGELOG_FEATURE",
                "title": {"en": "Context Head", "fr": "Context Head"},
                "summary": {
                    "en": "Agents resume from a bounded current view.",
                    "fr": "Les agents reprennent depuis une vue courante bornée.",
                },
                "delivery": {
                    "state": "DELIVERY_SITE_BUILD",
                    "proof": "Included in the same public site build",
                },
            }
            path = append_event(root, "fixture", "CONTEXT_CHANGE", "Internal summary", public=public)
            payload = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(payload["public"], public)

            public["title"].pop("fr")
            with self.assertRaisesRegex(ContextHistoryError, "English and French"):
                append_event(root, "fixture", "CONTEXT_CHANGE", "Invalid public", public=public)

    def test_secret_like_public_copy_is_rejected(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            with self.assertRaisesRegex(ContextHistoryError, "secret-like"):
                append_event(
                    root,
                    "fixture",
                    "CONTEXT_CHANGE",
                    "Internal summary",
                    public={
                        "category": "CHANGELOG_FIX",
                        "title": {"en": "Safe title", "fr": "Titre sûr"},
                        "summary": {"en": "Token sk-abcdefghijklmnopqrstuvwxyz", "fr": "Correction"},
                        "delivery": {"state": "DELIVERY_SHIPPED", "proof": "release-v1"},
                    },
                )

    def test_divergent_duplicate_event_id_fails_closed(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            event_id = "evt_0123456789abcdef0123456789abcdef"
            append_event(root, "fixture", "CONTEXT_CHANGE", "First", event_id=event_id)
            with self.assertRaisesRegex(ContextHistoryError, "immutable"):
                append_event(root, "fixture", "CONTEXT_CHANGE", "Second", event_id=event_id)

    def test_head_is_bounded_and_prefers_latest_next_action(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            for index in range(45):
                append_event(
                    root,
                    "fixture",
                    "CONTEXT_CHANGE",
                    f"Meaningful change {index}",
                    occurred_at=f"2026-08-25T19:{index:02d}:00.000000Z",
                    next_action=f"Continue with {index}",
                )
            result = generate_context_head(root, max_events=30, max_characters=16_000)
            self.assertEqual(result.event_count, 30)
            self.assertIn("Continue with 44", result.markdown)
            self.assertNotIn("Meaningful change 0\n", result.markdown)


if __name__ == "__main__":
    unittest.main()
