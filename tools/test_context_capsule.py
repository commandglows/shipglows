from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.code_context_graph import build_graph
from tools.context_capsule import build_capsule, evaluate_selection, write_evaluation


class ContextCapsuleTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.root = Path(self.temp_dir.name)
        (self.root / "api.py").write_text(
            "def status():\n    query = 'SELECT * FROM content_assets'\n    return query\n",
            encoding="utf-8",
        )
        (self.root / "client.dart").write_text(
            "class StatusClient { Future<void> load() async { await dio.get('/api/status/content'); } }\n",
            encoding="utf-8",
        )
        self.graph = build_graph(self.root)

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_capsule_is_bounded_deterministic_and_explainable(self) -> None:
        first = build_capsule(
            self.graph,
            task="Check content assets status",
            accepted_outcome="Identify the owning status surfaces.",
            explicit_seeds=["content_assets", "/api/status/content"],
            max_items=8,
        )
        second = build_capsule(
            self.graph,
            task="Check content assets status",
            accepted_outcome="Identify the owning status surfaces.",
            explicit_seeds=["content_assets", "/api/status/content"],
            max_items=8,
        )

        self.assertEqual(json.dumps(first, sort_keys=True), json.dumps(second, sort_keys=True))
        self.assertLessEqual(len(first["evidence"]), 8)
        self.assertTrue(all(item["reasons"] for item in first["evidence"]))
        self.assertTrue(all(item["certainty"] == "evidence_backed" for item in first["evidence"]))
        self.assertNotIn("Check content assets status", json.dumps(first))
        reason_text = json.dumps([item["reasons"] for item in first["evidence"]])
        self.assertNotIn("content_assets", reason_text)
        self.assertNotIn("assets", reason_text)

    def test_missing_seed_and_truncation_stay_visible(self) -> None:
        capsule = build_capsule(
            self.graph,
            task="missing owner",
            accepted_outcome="Find it.",
            explicit_seeds=["does-not-exist", "content_assets"],
            max_items=1,
        )

        self.assertTrue(capsule["gaps"])
        self.assertTrue(capsule["bounds"]["truncated"])

    def test_evaluation_contains_only_aggregate_counts(self) -> None:
        capsule = build_capsule(
            self.graph,
            task="content assets",
            accepted_outcome="Find owner.",
            explicit_seeds=["content_assets"],
        )
        result = evaluate_selection(capsule, expected_paths=["api.py"])

        self.assertEqual(1.0, result["recall"])
        self.assertNotIn("expected_paths", result)
        self.assertNotIn("evidence", result)

        output = self.root / "evaluation.json"
        write_evaluation(output, result)
        persisted = output.read_text(encoding="utf-8")
        self.assertNotIn("api.py", persisted)
        self.assertNotIn("content_assets", persisted)

    def test_unsupported_language_coverage_is_explicit(self) -> None:
        (self.root / "extension.ts").write_text("export const secretBody = 'not indexed';\n", encoding="utf-8")
        capsule = build_capsule(
            build_graph(self.root), task="extension", accepted_outcome="Find extension owner.", explicit_seeds=[]
        )

        gap = next(item for item in capsule["gaps"] if item["kind"] == "unsupported_languages")
        self.assertEqual(["ts"], gap["languages"])
        self.assertNotIn("secretBody", json.dumps(capsule))
        fallback = next(item for item in capsule["evidence"] if item["path"] == "extension.ts")
        self.assertIn("targeted_filename_fallback", fallback["reasons"])


if __name__ == "__main__":
    unittest.main()
