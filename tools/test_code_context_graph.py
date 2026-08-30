from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.code_context_graph import _index_lock, _read_graph, build_graph, find_stale_files, graph_status, query_graph, update_graph


class CodeContextGraphTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        (self.root / "api.py").write_text(
            """from service import TrashService

router = object()

@router.post('/api/status/content/{content_id}/trash')
def trash_content(content_id: str):
    service = TrashService()
    return service.trash(content_id)
""",
            encoding="utf-8",
        )
        (self.root / "service.py").write_text(
            """class TrashService:
    def trash(self, content_id: str):
        query = 'UPDATE content_items SET trashed_at = ? WHERE id = ?'
        return query, content_id
""",
            encoding="utf-8",
        )
        (self.root / "client.dart").write_text(
            """import 'models.dart';

class TrashClient {
  Future<void> trashContent(String id) async {
    await dio.post('/api/status/content/$id/trash');
  }
}
""",
            encoding="utf-8",
        )
        (self.root / "models.dart").write_text(
            "class TrashItem { const TrashItem(this.id); final String id; }\n",
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_builds_symbols_routes_tables_and_relationships(self) -> None:
        graph = build_graph(self.root)
        node_ids = {node["id"] for node in graph["nodes"]}
        edge_pairs = {(edge["source"], edge["target"], edge["kind"]) for edge in graph["edges"]}

        self.assertIn("py:api.py:trash_content", node_ids)
        self.assertIn("py:service.py:TrashService", node_ids)
        self.assertIn("route:POST:/api/status/content/{content_id}/trash", node_ids)
        self.assertIn("table:content_items", node_ids)
        self.assertIn("dart:client.dart:TrashClient", node_ids)
        self.assertIn(("file:api.py", "file:service.py", "imports"), edge_pairs)
        self.assertIn(("file:client.dart", "file:models.dart", "imports"), edge_pairs)

    def test_query_returns_bounded_neighborhood(self) -> None:
        graph = build_graph(self.root)
        result = query_graph(graph, ["trash_content"], max_depth=2, max_nodes=20)

        self.assertEqual([], result["missing_seeds"])
        self.assertLessEqual(len(result["nodes"]), 20)
        self.assertTrue(any(node["id"] == "py:api.py:trash_content" for node in result["nodes"]))
        self.assertTrue(any(node["id"] == "file:api.py" for node in result["nodes"]))

    def test_detects_changed_and_deleted_files(self) -> None:
        graph = build_graph(self.root)
        (self.root / "service.py").write_text("class TrashService: pass\n", encoding="utf-8")
        (self.root / "models.dart").unlink()

        stale = find_stale_files(graph, self.root)

        self.assertEqual(["models.dart", "service.py"], stale)

    def test_incremental_update_adds_changes_renames_and_deletes(self) -> None:
        graph = build_graph(self.root)
        (self.root / "service.py").write_text("class TrashServiceV2: pass\n", encoding="utf-8")
        (self.root / "models.dart").rename(self.root / "entities.dart")
        (self.root / "api.py").unlink()
        (self.root / "new.sql").write_text("SELECT * FROM audit_events\n", encoding="utf-8")

        updated, changes = update_graph(graph, self.root)

        self.assertEqual(["new.sql"], changes["added"])
        self.assertEqual(["service.py"], changes["changed"])
        self.assertEqual([{"from": "models.dart", "to": "entities.dart"}], changes["renamed"])
        self.assertEqual(["api.py"], changes["deleted"])
        self.assertIn("client.dart", changes["revalidate"])
        self.assertIn("table:audit_events", {node["id"] for node in updated["nodes"]})
        self.assertNotIn("file:api.py", {node["id"] for node in updated["nodes"]})
        self.assertNotIn(
            ("file:client.dart", "file:models.dart", "imports"),
            {(edge["source"], edge["target"], edge["kind"]) for edge in updated["edges"]},
        )

    def test_incremental_update_preserves_unaffected_observation(self) -> None:
        graph = build_graph(self.root)
        before = graph["file_observations"]["client.dart"]
        (self.root / "service.py").write_text("class TrashServiceV2: pass\n", encoding="utf-8")

        updated, _ = update_graph(graph, self.root)

        self.assertEqual(before, updated["file_observations"]["client.dart"])

    def test_query_explains_every_selected_node(self) -> None:
        result = query_graph(build_graph(self.root), ["trash_content"], max_depth=2, max_nodes=20)

        self.assertEqual(
            {node["id"] for node in result["nodes"]},
            {reason["node_id"] for reason in result["selection_reasons"]},
        )
        self.assertTrue(any(reason["reason"] == "seed_match" for reason in result["selection_reasons"]))

    def test_status_reports_freshness_without_source_content(self) -> None:
        graph = build_graph(self.root)
        (self.root / "new.sql").write_text("SELECT * FROM audit_events\n", encoding="utf-8")

        status = graph_status(graph, self.root)

        self.assertEqual("stale", status["freshness"])
        self.assertEqual(1, status["new_file_count"])
        self.assertNotIn("audit_events", json.dumps(status))

    def test_old_schema_rebuilds_explicitly(self) -> None:
        updated, changes = update_graph({"schema_version": "1.0", "files": {}}, self.root)

        self.assertTrue(changes["rebuilt"])
        self.assertEqual("2.0", updated["schema_version"])

    def test_worktree_identity_isolated_by_root(self) -> None:
        other_dir = tempfile.TemporaryDirectory()
        self.addCleanup(other_dir.cleanup)
        other = Path(other_dir.name)
        (other / "api.py").write_text((self.root / "api.py").read_text(encoding="utf-8"), encoding="utf-8")

        self.assertNotEqual(
            build_graph(self.root)["repository"]["worktree_id"],
            build_graph(other)["repository"]["worktree_id"],
        )

    def test_corrupt_graph_and_concurrent_refresh_fail_bounded(self) -> None:
        graph_path = self.root / "graph.json"
        graph_path.write_text("{broken", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "graph is unreadable"):
            _read_graph(graph_path)
        with _index_lock(graph_path):
            with self.assertRaisesRegex(RuntimeError, "already in progress"):
                with _index_lock(graph_path):
                    pass

    def test_symlink_escape_is_not_indexed(self) -> None:
        outside_dir = tempfile.TemporaryDirectory()
        self.addCleanup(outside_dir.cleanup)
        outside = Path(outside_dir.name) / "outside.py"
        outside.write_text("def escaped(): return True\n", encoding="utf-8")
        try:
            (self.root / "linked.py").symlink_to(outside)
        except OSError as error:
            self.skipTest(f"symlink unavailable: {type(error).__name__}")

        self.assertNotIn("linked.py", build_graph(self.root)["files"])

    def test_graph_is_json_serializable_and_deterministic(self) -> None:
        first = build_graph(self.root)
        second = build_graph(self.root)

        self.assertEqual(
            json.dumps(first, sort_keys=True),
            json.dumps(second, sort_keys=True),
        )


if __name__ == "__main__":
    unittest.main()
