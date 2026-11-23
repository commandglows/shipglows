#!/usr/bin/env python3
"""Behavior tests for declarative product-site wiring: automatic projection of public
context events into draft updates and roadmap items, and the pending/publish gate."""

from pathlib import Path
from tempfile import TemporaryDirectory
import json
import subprocess
import sys
import unittest

from tools.context_history import ContextHistoryError, append_event
from tools.product_updates import (
    CONFIG_FILE,
    Frontmatter,
    load_config,
    pending,
    project_after_append,
    project_configured,
    publish,
)
from tools.test_context_history import public_payload, repository

TOOL = Path(__file__).resolve().parent / "context_history.py"
EVENT_DAY = "2026-11-20"


def wired_repository(root: Path, *, roadmap_package: bool = True) -> Path:
    """A Git repo with one site (updates + roadmap) declared in the product-updates config."""
    repository(root)
    site = root / "site"
    site.mkdir()
    dependencies = {"@shipglows/astro-updates": "link:../engine/updates"}
    if roadmap_package:
        dependencies["@shipglows/astro-roadmap"] = "link:../engine/roadmap"
    (site / "package.json").write_text(json.dumps({"dependencies": dependencies}), encoding="utf-8")
    (site / ".shipglows.content.json").write_text(json.dumps({"locales": ["en", "fr"]}), encoding="utf-8")
    (root / CONFIG_FILE).write_text(
        json.dumps({"schema": "shipglows.product-updates/v1", "sites": [{"root": "site", "products": ["replayglows"]}]}),
        encoding="utf-8",
    )
    for locale, title in (("en", "Fast exports"), ("fr", "Exports rapides")):
        item = site / "src/content/roadmap" / locale / "fast-exports.md"
        item.parent.mkdir(parents=True)
        item.write_text(
            "---\n"
            f'title: "{title}"\n'
            'summary: "Exports in seconds."\n'
            "status: in_progress\n"
            "products: [replayglows]\n"
            "visibility: public\n"
            "statusHistory:\n"
            '  - { to: planned, date: "2026-10-01" }\n'
            '  - { from: planned, to: in_progress, date: "2026-11-01", note: "Started, finally: yes" }\n'
            'createdAt: "2026-10-01"\n'
            "---\n"
            "\nHuman body stays.\n",
            encoding="utf-8",
        )
    return site


def shipped_public(**extra: object) -> dict:
    payload = public_payload()
    payload["roadmap"] = [{"id": "fast-exports", "status": "shipped"}]
    payload.update(extra)
    return payload


def append_projected(root: Path, public: dict, **kwargs: object) -> tuple[dict, dict]:
    path = append_event(root, "fixture", "CONTEXT_CHANGE", "Internal", occurred_at=f"{EVENT_DAY}T10:00:00Z",
                        public=public, **kwargs)
    event = json.loads(path.read_text(encoding="utf-8"))
    return event, project_after_append(root, event)


class AutomaticProjectionTests(unittest.TestCase):
    def test_cli_append_projects_update_and_roadmap_automatically(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            result = subprocess.run(
                [
                    sys.executable, str(TOOL), "--project-root", str(root), "append",
                    "--project", "fixture", "--kind", "CONTEXT_CHANGE", "--summary", "Internal",
                    "--occurred-at", f"{EVENT_DAY}T10:00:00Z",
                    "--public-category", "CHANGELOG_FEATURE",
                    "--public-title-en", "Faster exports", "--public-title-fr", "Exports plus rapides",
                    "--public-summary-en", "Exports finish in seconds.",
                    "--public-summary-fr", "Les exports se terminent en quelques secondes.",
                    "--delivery-state", "DELIVERY_SHIPPED", "--delivery-proof", "release v1.2.0",
                    "--roadmap", "fast-exports:shipped",
                ],
                capture_output=True, text=True, encoding="utf-8", check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            output = json.loads(result.stdout)
            projection = output["projection"]
            self.assertEqual(projection["status"], "ok")
            [report] = projection["sites"]
            self.assertEqual({item["action"] for item in report["updates"]}, {"created"})
            self.assertEqual({item["action"] for item in report["roadmap"]}, {"status-changed"})
            update = (site / "src/content/updates/fr/replayglows-faster-exports.md").read_text(encoding="utf-8")
            self.assertIn("status: draft", update)
            self.assertIn("relatedRoadmap: [fast-exports]", update)
            self.assertIn(f'ref: "{output["eventId"]}"', update)

    def test_unwired_repository_and_internal_events_project_nothing(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository(root)
            _, report = append_projected(root, public_payload())
            self.assertEqual(report["status"], "not-configured")
            internal = append_event(root, "fixture", "CONTEXT_DECISION", "Internal only")
            event = json.loads(internal.read_text(encoding="utf-8"))
            self.assertEqual(project_after_append(root, event)["status"], "skipped")

    def test_config_is_strict_and_site_errors_do_not_lose_the_event(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            config = root / CONFIG_FILE
            for invalid in (
                {"schema": "other", "sites": []},
                {"schema": "shipglows.product-updates/v1", "sites": [{"root": "site", "products": ["Bad Key"]}]},
                {"schema": "shipglows.product-updates/v1", "sites": [{"root": "nowhere", "products": ["a"]}]},
                {"schema": "shipglows.product-updates/v1", "sites": [{"root": "site", "products": ["a"], "x": 1}]},
            ):
                config.write_text(json.dumps(invalid), encoding="utf-8")
                with self.assertRaises(ContextHistoryError):
                    load_config(root)
            config.write_text(
                json.dumps({"schema": "shipglows.product-updates/v1", "sites": [{"root": "site", "products": ["replayglows"]}]}),
                encoding="utf-8",
            )
            (site / "package.json").write_text(json.dumps({"dependencies": {}}), encoding="utf-8")
            event, report = append_projected(root, public_payload())
            self.assertEqual(report["status"], "error")
            self.assertIn("astro-updates", report["sites"][0]["error"])
            self.assertTrue(event["id"].startswith("evt_"))


class RoadmapProjectionTests(unittest.TestCase):
    def test_shipped_status_appends_history_and_links_both_ways(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            event, report = append_projected(root, shipped_public())

            self.assertEqual(report["status"], "ok")
            for locale in ("en", "fr"):
                item_text = (site / f"src/content/roadmap/{locale}/fast-exports.md").read_text(encoding="utf-8")
                item = Frontmatter(item_text)
                self.assertEqual(item.scalar("status"), "shipped")
                self.assertEqual(item.scalar("visibility"), "public")
                self.assertEqual(item.list("shippedIn"), ["replayglows-faster-exports"])
                history = item.history()
                self.assertEqual(len(history), 3)
                self.assertEqual(history[-1], {"from": "in_progress", "to": "shipped", "date": EVENT_DAY})
                self.assertEqual(history[1]["note"], "Started, finally: yes")
                self.assertEqual(item.scalar("updatedAt"), EVENT_DAY)
                self.assertTrue(item_text.endswith("---\n\nHuman body stays.\n"))
                update = Frontmatter(
                    (site / f"src/content/updates/{locale}/replayglows-faster-exports.md").read_text(encoding="utf-8")
                )
                self.assertEqual(update.list("relatedRoadmap"), ["fast-exports"])
                self.assertEqual(update.scalar("status"), "draft")
                self.assertEqual(update.mapping("source"), {"producer": "agent", "ref": event["id"]})

    def test_rerun_is_idempotent_and_never_overwrites_human_edits(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            event, _ = append_projected(root, shipped_public())
            item_path = site / "src/content/roadmap/en/fast-exports.md"
            before = item_path.read_text(encoding="utf-8")

            again = project_configured(root, event_ids=[event["id"]])["sites"][0]
            self.assertEqual({item["action"] for item in again["updates"]}, {"unchanged"})
            self.assertEqual({item["action"] for item in again["roadmap"]}, {"unchanged"})
            self.assertEqual(item_path.read_text(encoding="utf-8"), before)

            update_path = site / "src/content/updates/en/replayglows-faster-exports.md"
            edited = update_path.read_text(encoding="utf-8").replace("Faster exports", "Much faster exports")
            update_path.write_text(edited, encoding="utf-8")
            third = project_configured(root, event_ids=[event["id"]])["sites"][0]
            actions = {item["locale"]: item["action"] for item in third["updates"]}
            self.assertEqual(actions["en"], "skipped-edited")
            self.assertEqual(update_path.read_text(encoding="utf-8"), edited)

    def test_older_event_never_moves_a_newer_status_back(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            append_projected(root, shipped_public())
            older = append_event(
                root, "fixture", "CONTEXT_CHANGE", "Older", occurred_at="2026-11-10T10:00:00Z",
                public={"roadmap": [{"id": "fast-exports", "status": "planned"}]},
            )
            event = json.loads(older.read_text(encoding="utf-8"))
            report = project_configured(root, event_ids=[event["id"]])["sites"][0]
            self.assertEqual({item["action"] for item in report["roadmap"]}, {"skipped-stale"})
            item = Frontmatter((site / "src/content/roadmap/fr/fast-exports.md").read_text(encoding="utf-8"))
            self.assertEqual(item.scalar("status"), "shipped")

    def test_shipped_without_delivery_proof_is_refused(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            with self.assertRaisesRegex(ContextHistoryError, "without delivery proof"):
                append_event(root, "fixture", "CONTEXT_CHANGE", "Claim",
                             public={"roadmap": [{"id": "fast-exports", "status": "shipped"}]})
            self.assertFalse((root / "shipglows_data").exists())
            with self.assertRaisesRegex(ContextHistoryError, "delivery"):
                append_event(root, "fixture", "CONTEXT_CHANGE", "Claim", public={
                    "roadmap": [{"id": "fast-exports", "status": "shipped"}],
                    "delivery": {"state": "DELIVERY_SHIPPED"},
                })

            event, report = append_projected(root, {"roadmap": [{"id": "fast-exports", "status": "planned"}]})
            [site_report] = report["sites"]
            self.assertEqual(site_report["updates"], [])
            self.assertEqual({item["action"] for item in site_report["roadmap"]}, {"status-changed"})
            proven, report = append_projected(root, {
                "roadmap": [{"id": "fast-exports", "status": "shipped"}],
                "delivery": {"state": "DELIVERY_AVAILABLE", "proof": "store build 42"},
            })
            [site_report] = report["sites"]
            self.assertEqual({item["action"] for item in site_report["roadmap"]}, {"status-changed"})
            self.assertEqual({item["linked"] for item in site_report["roadmap"]}, {False})
            item = Frontmatter((site / "src/content/roadmap/en/fast-exports.md").read_text(encoding="utf-8"))
            self.assertEqual((item.scalar("status"), item.list("shippedIn")), ("shipped", []))

    def test_agents_create_items_only_hidden_and_only_with_copy(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            payload = shipped_public(roadmap=[
                {"id": "pdf-export", "status": "shipped",
                 "title": {"en": "PDF export", "fr": "Export PDF"},
                 "summary": {"en": "Export a replay as PDF.", "fr": "Exporter une session en PDF."}},
                {"id": "unknown-item", "status": "in_progress"},
            ])
            _, report = append_projected(root, payload)
            actions = {(item["id"], item["locale"]): item["action"] for item in report["sites"][0]["roadmap"]}
            self.assertEqual(actions[("pdf-export", "fr")], "created")
            self.assertEqual(actions[("unknown-item", "en")], "missing")
            created = Frontmatter((site / "src/content/roadmap/fr/pdf-export.md").read_text(encoding="utf-8"))
            self.assertEqual(created.scalar("visibility"), "hidden")
            self.assertEqual(created.scalar("title"), "Export PDF")
            self.assertEqual(created.history(), [{"to": "shipped", "date": EVENT_DAY}])
            self.assertEqual(created.list("shippedIn"), ["replayglows-faster-exports"])
            self.assertEqual(created.mapping("source")["producer"], "agent")
            update = Frontmatter((site / "src/content/updates/en/replayglows-faster-exports.md").read_text(encoding="utf-8"))
            self.assertEqual(update.list("relatedRoadmap"), ["pdf-export"])

    def test_site_without_roadmap_package_skips_roadmap_only(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root, roadmap_package=False)
            _, report = append_projected(root, shipped_public())
            [site_report] = report["sites"]
            self.assertIn("astro-roadmap", site_report["roadmapSkipped"])
            self.assertEqual({item["action"] for item in site_report["updates"]}, {"created"})
            update = (site / "src/content/updates/en/replayglows-faster-exports.md").read_text(encoding="utf-8")
            self.assertNotIn("relatedRoadmap", update)


class ReviewGateTests(unittest.TestCase):
    def test_pending_lists_drafts_hidden_items_and_waiting_public_items(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            wired_repository(root)
            append_projected(root, shipped_public(roadmap=[
                {"id": "fast-exports", "status": "shipped"},
                {"id": "pdf-export", "status": "planned",
                 "title": {"en": "PDF export", "fr": "Export PDF"},
                 "summary": {"en": "Export as PDF.", "fr": "Exporter en PDF."}},
            ]))
            [site] = pending(root)["sites"]
            self.assertEqual([(item["id"], item["locales"], item["producer"]) for item in site["drafts"]],
                             [("replayglows-faster-exports", ["en", "fr"], "agent")])
            self.assertEqual([(item["id"], item["status"]) for item in site["hidden"]], [("pdf-export", "planned")])
            self.assertEqual({(item["item"], item["reason"]) for item in site["awaiting"]},
                             {("fast-exports", "update-draft")})
            self.assertNotIn("files", site["drafts"][0])

    def test_publish_flips_every_locale_and_unknown_ids_write_nothing(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = wired_repository(root)
            append_projected(root, shipped_public(roadmap=[
                {"id": "pdf-export", "status": "shipped",
                 "title": {"en": "PDF export", "fr": "Export PDF"},
                 "summary": {"en": "Export as PDF.", "fr": "Exporter en PDF."}},
            ]))
            update_en = site / "src/content/updates/en/replayglows-faster-exports.md"
            before = update_en.read_text(encoding="utf-8")
            with self.assertRaisesRegex(ContextHistoryError, "Nothing pending"):
                publish(root, ids=["replayglows-faster-exports", "typo"])
            self.assertEqual(update_en.read_text(encoding="utf-8"), before)
            with self.assertRaises(ContextHistoryError):
                publish(root, ids=["x"], publish_all=True)

            dry = publish(root, ids=["replayglows-faster-exports"], dry_run=True)
            self.assertEqual({item["action"] for item in dry["published"]}, {"would-publish"})
            self.assertEqual(update_en.read_text(encoding="utf-8"), before)

            result = publish(root, ids=["replayglows-faster-exports"])
            self.assertEqual(sorted(item["locale"] for item in result["published"]), ["en", "fr"])
            self.assertEqual(result["warnings"], [
                "update replayglows-faster-exports links hidden roadmap item pdf-export; publish it too."
            ])
            self.assertEqual(update_en.read_text(encoding="utf-8"), before.replace("status: draft", "status: published"))

            everything = publish(root, publish_all=True)
            self.assertEqual({(item["kind"], item["id"]) for item in everything["published"]}, {("roadmap", "pdf-export")})
            item = Frontmatter((site / "src/content/roadmap/fr/pdf-export.md").read_text(encoding="utf-8"))
            self.assertEqual(item.scalar("visibility"), "public")
            self.assertEqual(pending(root)["pendingCount"], 0)


class FrontmatterEditorTests(unittest.TestCase):
    def test_edits_preserve_crlf_block_lists_and_body(self) -> None:
        text = "---\r\ntitle: x\r\nshippedIn:\r\n    - first-update\r\nstatus: planned # note\r\n---\r\nBody\r\n"
        document = Frontmatter(text)
        self.assertEqual(document.scalar("status"), "planned")
        self.assertTrue(document.add_list_item("shippedIn", "second-update"))
        self.assertFalse(document.add_list_item("shippedIn", "first-update"))
        document.append_history('{ to: shipped, date: "2026-11-20" }')
        rendered = document.render()
        self.assertIn("\r\n    - first-update\r\n    - second-update\r\n", rendered)
        self.assertIn('statusHistory:\r\n  - { to: shipped, date: "2026-11-20" }\r\n---\r\nBody\r\n', rendered)
        self.assertNotIn("\n\n", rendered.replace("\r\n", "\n"))

    def test_unsupported_shapes_are_refused_not_rewritten(self) -> None:
        document = Frontmatter('---\nstatusHistory: [{ to: planned, date: "2026-01-01" }]\n---\n')
        with self.assertRaises(ContextHistoryError):
            document.append_history('{ to: shipped, date: "2026-11-20" }')
        with self.assertRaises(ContextHistoryError):
            Frontmatter("no frontmatter")


if __name__ == "__main__":
    unittest.main()
