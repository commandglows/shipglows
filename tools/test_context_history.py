#!/usr/bin/env python3
"""Behavior tests for collision-free context history and Context Head freshness."""

from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import re
import subprocess
import unittest
from unittest.mock import patch

from tools.context_history import (
    ContextHistoryError,
    append_event,
    build_update_entry,
    cache_status,
    generate_context_head,
    load_events,
    project_updates,
)

UPDATE_SCHEMA = Path(__file__).resolve().parents[2] / "shipglows-app-engine/shared/updates/update-entry.schema.json"


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

    def test_head_combines_recent_history_with_bounded_code_graph(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            source = root / "service.py"
            source.write_text("def publish_content():\n    return True\n", encoding="utf-8")
            git(root, "add", "service.py")
            git(root, "commit", "-m", "add service")
            append_event(
                root,
                "fixture",
                "CONTEXT_CHANGE",
                "Publish flow changed",
                refs=["service.py"],
            )

            result = generate_context_head(root)
            metadata = json.loads(result.metadata_path.read_text(encoding="utf-8"))

            self.assertIn("## Code context", result.markdown)
            self.assertIn("`service.py`", result.markdown)
            self.assertEqual(metadata["codeGraph"]["status"], "ready")
            self.assertEqual(metadata["codeGraph"]["seedRefs"], ["service.py"])
            self.assertLessEqual(metadata["codeGraph"]["queryNodeCount"], 40)

    def test_head_degrades_safely_when_code_graph_is_unavailable(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            append_event(root, "fixture", "CONTEXT_DECISION", "Keep history readable")

            with patch("tools.code_context_graph.build_graph", side_effect=OSError("unavailable")):
                result = generate_context_head(root)

            self.assertIn("Derived graph unavailable", result.markdown)
            self.assertIn("Keep history readable", result.markdown)


def public_payload(title_en: str = "Faster exports", category: str = "CHANGELOG_FEATURE") -> dict:
    return {
        "category": category,
        "title": {"en": title_en, "fr": "Exports plus rapides"},
        "summary": {
            "en": "Exports finish in seconds.",
            "fr": "Les exports se terminent en quelques secondes.",
        },
        "delivery": {"state": "DELIVERY_SHIPPED", "proof": "release v1.2.0"},
        "link": "/docs/exports",
    }


def site(root: Path, *, locales: list[str] | None = None, package: bool = True) -> Path:
    directory = root / "site"
    directory.mkdir()
    dependencies = {"@shipglows/astro-updates": "link:../engine"} if package else {}
    (directory / "package.json").write_text(json.dumps({"dependencies": dependencies}), encoding="utf-8")
    if locales is not None:
        (directory / ".shipglows.content.json").write_text(
            json.dumps({"schema": "shipglows-content/v1", "locales": locales}), encoding="utf-8"
        )
    return directory


def assert_contract_shape(test: unittest.TestCase, entry: dict) -> None:
    """Check an entry against the shared JSON Schema without a jsonschema dependency."""
    if not UPDATE_SCHEMA.is_file():
        test.skipTest("shipglows-app-engine is not checked out next to this repository")
    schema = json.loads(UPDATE_SCHEMA.read_text(encoding="utf-8"))
    properties = schema["properties"]
    test.assertTrue(set(schema["required"]) <= set(entry))
    test.assertTrue(set(entry) <= set(properties))
    slug = re.compile(schema["$defs"]["slug"]["pattern"])
    test.assertRegex(entry["id"], slug)
    test.assertTrue(all(slug.fullmatch(item) for item in entry["products"]))
    test.assertRegex(entry["publishedAt"], schema["$defs"]["dateOrDateTime"]["pattern"])
    test.assertRegex(entry["locale"], properties["locale"]["pattern"])
    test.assertIn(entry["status"], properties["status"]["enum"])
    test.assertIn(entry["kind"], properties["kind"]["enum"])
    test.assertLessEqual(len(entry["title"]), properties["title"]["maxLength"])
    test.assertLessEqual(len(entry["summary"]), properties["summary"]["maxLength"])
    groups = properties["changes"]["items"]["properties"]["group"]["enum"]
    test.assertTrue(all(change["group"] in groups and change["items"] for change in entry["changes"]))
    test.assertRegex(entry["cta"]["href"], schema["$defs"]["href"]["pattern"])
    test.assertIn(entry["source"]["producer"], properties["source"]["properties"]["producer"]["enum"])


class ProductUpdateProjectionTests(unittest.TestCase):
    def test_public_event_becomes_bilingual_agent_drafts_with_one_id(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            target = site(root, locales=["fr", "en"])
            event_path = append_event(
                root,
                "fixture",
                "CONTEXT_CHANGE",
                "Internal",
                occurred_at="2026-11-20T10:00:00Z",
                public=public_payload(),
            )
            event = json.loads(event_path.read_text(encoding="utf-8"))

            report = project_updates(root, target, "replayglows", event_ids=[event["id"]])

            self.assertEqual([item["action"] for item in report["entries"]], ["created", "created"])
            self.assertEqual({item["id"] for item in report["entries"]}, {"replayglows-faster-exports"})
            french = (target / "src/content/updates/fr/replayglows-faster-exports.md").read_text(encoding="utf-8")
            english = (target / "src/content/updates/en/replayglows-faster-exports.md").read_text(encoding="utf-8")
            self.assertIn('title: "Exports plus rapides"', french)
            self.assertIn('cta: { label: "En savoir plus", href: "/docs/exports" }', french)
            self.assertIn('title: "Faster exports"', english)
            for text in (french, english):
                self.assertIn("status: draft", text)
                self.assertIn("kind: feature", text)
                self.assertIn("  - group: added", text)
                self.assertIn('publishedAt: "2026-11-20"', text)
                self.assertIn(f'source: {{ producer: agent, ref: "{event["id"]}" }}', text)
                self.assertNotIn("\nid:", text)
                self.assertNotIn("\nlocale:", text)
                self.assertNotIn("Internal", text)
            assert_contract_shape(self, build_update_entry(event, "replayglows", "fr", "replayglows-faster-exports"))

    def test_dry_run_writes_nothing(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            target = site(root, locales=["fr", "en"])
            append_event(root, "fixture", "CONTEXT_FIX", "Internal", public=public_payload(category="CHANGELOG_FIX"))

            report = project_updates(root, target, "replayglows", since="2000-01-01", dry_run=True)

            self.assertEqual([item["action"] for item in report["entries"]], ["would-create", "would-create"])
            self.assertFalse((target / "src/content/updates").exists())

    def test_rerun_is_idempotent_and_never_overwrites_human_edits(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            target = site(root, locales=["fr", "en"])
            append_event(root, "fixture", "CONTEXT_CHANGE", "Internal", public=public_payload())
            project_updates(root, target, "replayglows", since="2000-01-01")
            unchanged = project_updates(root, target, "replayglows", since="2000-01-01")
            self.assertEqual({item["action"] for item in unchanged["entries"]}, {"unchanged"})

            english = target / "src/content/updates/en/replayglows-faster-exports.md"
            french = target / "src/content/updates/fr/replayglows-faster-exports.md"
            edited = english.read_text(encoding="utf-8").replace("Faster exports", "Much faster exports")
            english.write_text(edited, encoding="utf-8")
            french.rename(french.with_name("exports-rapides.md"))

            report = project_updates(root, target, "replayglows", since="2000-01-01")

            actions = {item["locale"]: (item["action"], item["path"]) for item in report["entries"]}
            self.assertEqual(actions["en"][0], "skipped-edited")
            self.assertEqual(actions["fr"], ("already-projected", "src/content/updates/fr/exports-rapides.md"))
            self.assertEqual(english.read_text(encoding="utf-8"), edited)
            self.assertFalse(french.exists())

    def test_same_title_from_another_event_gets_a_deterministic_suffix(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            target = site(root, locales=["fr", "en"])
            first = "evt_0123456789abcdef0123456789abcdef"
            second = "evt_fedcba9876543210fedcba9876543210"
            append_event(root, "fixture", "CONTEXT_CHANGE", "One", public=public_payload(), event_id=first)
            append_event(root, "fixture", "CONTEXT_CHANGE", "Two", public=public_payload(), event_id=second)
            project_updates(root, target, "replayglows", event_ids=[first])

            report = project_updates(root, target, "replayglows", event_ids=[second])

            self.assertEqual({item["id"] for item in report["entries"]}, {"replayglows-faster-exports-fedcba98"})
            self.assertEqual({item["action"] for item in report["entries"]}, {"created"})

    def test_selection_locales_and_site_package_fail_closed(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            internal = append_event(root, "fixture", "CONTEXT_DECISION", "Internal only")
            internal_id = json.loads(internal.read_text(encoding="utf-8"))["id"]
            plain = site(root, package=False)
            with self.assertRaisesRegex(ContextHistoryError, "astro-updates"):
                project_updates(root, plain, "replayglows", since="2000-01-01")
            (plain / "package.json").write_text(
                json.dumps({"devDependencies": {"@shipglows/astro-updates": "*"}}), encoding="utf-8"
            )
            with self.assertRaisesRegex(ContextHistoryError, "--event-id or --since"):
                project_updates(root, plain, "replayglows")
            with self.assertRaisesRegex(ContextHistoryError, "content.json"):
                project_updates(root, plain, "replayglows", since="2000-01-01")
            with self.assertRaisesRegex(ContextHistoryError, "Unknown event"):
                project_updates(root, plain, "replayglows", event_ids=["evt_" + "0" * 32], locales=["fr"])

            (plain / ".shipglows.content.json").write_text(json.dumps({"locales": ["fr", "de"]}), encoding="utf-8")
            report = project_updates(root, plain, "replayglows", event_ids=[internal_id])
            self.assertEqual(report["entries"], [])
            self.assertEqual(report["notPublic"], [internal_id])
            self.assertEqual(report["skippedLocales"], ["de"])


if __name__ == "__main__":
    unittest.main()
