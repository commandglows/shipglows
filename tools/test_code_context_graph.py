from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.code_context_graph import build_graph, find_stale_files, query_graph


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

    def test_graph_is_json_serializable_and_deterministic(self) -> None:
        first = build_graph(self.root)
        second = build_graph(self.root)

        self.assertEqual(
            json.dumps(first, sort_keys=True),
            json.dumps(second, sort_keys=True),
        )


if __name__ == "__main__":
    unittest.main()
