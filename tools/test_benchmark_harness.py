#!/usr/bin/env python3

import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest

from tools.benchmark_harness import BenchmarkError, load_suite, run_suite, summarize


class BenchmarkHarnessTests(unittest.TestCase):
    def test_runs_any_command_and_writes_samples_plus_summary(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            config = root / "suite.json"
            output = root / "results.jsonl"
            config.write_text(json.dumps({
                "schema_version": "1.0",
                "suite_id": "portable",
                "benchmarks": [{
                    "id": "child-runtime",
                    "command": [sys.executable, "-c", "print('ok')"],
                    "warmup": 1,
                    "iterations": 3,
                    "tags": {"language": "any"},
                }],
            }), encoding="utf-8")

            records = run_suite(config, output)
            samples = [record for record in records if record["record_type"] == "sample"]
            summary = records[-1]

            self.assertEqual(len(samples), 4)
            self.assertEqual([sample["phase"] for sample in samples], ["warmup", "measure", "measure", "measure"])
            self.assertTrue(all(sample["status"] == "ok" for sample in samples))
            self.assertEqual(summary["sample_count"], 3)
            self.assertEqual(summary["success_rate"], 1)
            self.assertEqual(len(output.read_text(encoding="utf-8").splitlines()), 5)

    def test_summary_separates_executions(self) -> None:
        samples = []
        for execution_id, durations in (("first", [10, 20]), ("second", [100, 200])):
            for duration in durations:
                samples.append({
                    "schema_version": "1.0", "record_type": "sample", "phase": "measure",
                    "suite_id": "suite", "benchmark_id": "bench", "execution_id": execution_id,
                    "status": "ok", "metrics": {"duration_ns": duration},
                })
        summaries = summarize(samples)
        self.assertEqual([item["metrics"]["duration_ns"]["median"] for item in summaries], [15, 150])

    def test_rejects_shell_strings_and_duplicate_ids(self) -> None:
        with TemporaryDirectory() as temporary:
            path = Path(temporary) / "invalid.json"
            path.write_text(json.dumps({
                "schema_version": "1.0", "suite_id": "suite",
                "benchmarks": [{"id": "same", "command": "echo unsafe"}, {"id": "same", "command": ["echo"]}],
            }), encoding="utf-8")
            with self.assertRaisesRegex(BenchmarkError, "command"):
                load_suite(path)


if __name__ == "__main__":
    unittest.main()
