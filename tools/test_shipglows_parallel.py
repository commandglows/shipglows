from __future__ import annotations

import io
import json
import os
import unittest
from contextlib import redirect_stderr, redirect_stdout
from unittest.mock import patch
from urllib.error import HTTPError, URLError

from tools.shipglows_parallel import API_URL, API_ROOT, EXTRACT_API_URL, ParallelError, _NoRedirectHandler, main, normalize_domain, request_search, request_research, request_monitor


class FakeResponse:
    def __init__(self, value):
        self.body = value if isinstance(value, bytes) else json.dumps(value).encode()

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return None

    def read(self, size=-1):
        return self.body[:size]


def response(results=None, **extra):
    return {"search_id": "search_test", "results": results or [], **extra}


class ParallelCliTests(unittest.TestCase):
    def setUp(self):
        self.env = patch.dict(os.environ, {"PARALLEL_API_KEY": "test-key"})
        self.env.start()
        self.addCleanup(self.env.stop)

    def call(self, argv, value):
        captured = {}

        def opener(request, timeout):
            captured["request"] = request
            captured["timeout"] = timeout
            captured["calls"] = captured.get("calls", 0) + 1
            return FakeResponse(value)

        return request_search(main_args(argv), opener=opener), captured

    def test_domain_normalization_and_boundary_safe_matching(self):
        self.assertEqual(normalize_domain("Claiire.fr."), "claiire.fr")
        result, _ = self.call(
            ["search", "--query", "coach bien-être", "--domain", "claiire.fr"],
            response([
                {"url": "https://claiire.fr/a", "title": "A", "excerpts": ["one"]},
                {"url": "https://blog.claiire.fr/b", "title": "B", "excerpts": []},
                {"url": "https://fakeclaiire.fr/", "title": "C", "excerpts": []},
            ]),
        )
        self.assertEqual([item["matches_domain"] for item in result["results"]], [True, True, False])

    def test_one_post_with_header_default_fast_mode_and_normalized_json(self):
        result, captured = self.call(["search", "--query", "coach bien-être"], response([
            {"url": "https://example.fr/", "title": "Exemple", "publish_date": None, "excerpts": ["extrait"]},
        ]))
        request = captured["request"]
        self.assertEqual(request.full_url, API_URL)
        self.assertEqual(request.get_method(), "POST")
        self.assertEqual(request.get_header("X-api-key"), "test-key")
        self.assertEqual(json.loads(request.data), {"search_queries": ["coach bien-être"], "mode": "fast"})
        self.assertEqual(captured["calls"], 1)
        self.assertEqual(result["results"][0]["position"], 1)
        self.assertIn("not a Google SERP", result["result_order"])
        self.assertEqual(captured["timeout"], 30)

    def test_accepts_positional_query_and_merges_with_flag(self):
        _, captured = self.call(["search", "coach bien-être"], response())
        self.assertEqual(json.loads(captured["request"].data)["search_queries"], ["coach bien-être"])
        _, captured = self.call(["search", "coach bien-être", "--query", "coach santé"], response())
        self.assertEqual(json.loads(captured["request"].data)["search_queries"], ["coach bien-être", "coach santé"])

    def test_search_without_any_query_is_rejected(self):
        with self.assertRaises(Exception):
            self.call(["search"], response())

    def test_accepts_two_queries_and_objective(self):
        _, captured = self.call(
            ["search", "--query", "coaching bien-être", "--query", "coach santé Paris", "--objective", "Find qualified sources"],
            response(),
        )
        body = json.loads(captured["request"].data)
        self.assertEqual(body["search_queries"], ["coaching bien-être", "coach santé Paris"])
        self.assertEqual(body["objective"], "Find qualified sources")

    def test_search_source_filters_are_sent_as_advanced_settings(self):
        _, captured = self.call(
            ["search", "--query", "content strategy", "--include-domain", "example.com",
             "--after-date", "2026-01-01", "--location", "fr", "--max-results", "7"],
            response(),
        )
        self.assertEqual(json.loads(captured["request"].data), {
            "search_queries": ["content strategy"], "mode": "fast",
            "advanced_settings": {
                "source_policy": {"include_domains": ["example.com"], "after_date": "2026-01-01"},
                "location": "FR", "max_results": 7,
            },
        })

    def test_task_run_create_status_and_result_use_documented_endpoints(self):
        captured = []

        def opener(request, timeout):
            captured.append(request)
            if request.get_method() == "POST":
                return FakeResponse({"run_id": "trun_1234567890abcdef", "status": "queued"})
            return FakeResponse({"run_id": "trun_1234567890abcdef", "status": "completed", "output": {"content": "report", "basis": []}})

        created = request_research(main_args([
            "research", "run", "--input", "Compare competitor content", "--processor", "pro",
            "--include-domain", "example.com",
        ]), opener)
        self.assertEqual(created["run_id"], "trun_1234567890abcdef")
        self.assertEqual(captured[0].full_url, f"{API_ROOT}/tasks/runs")
        self.assertEqual(captured[0].get_method(), "POST")
        self.assertEqual(json.loads(captured[0].data), {
            "input": "Compare competitor content", "processor": "pro",
            "task_spec": {"output_schema": {"type": "text"}},
            "source_policy": {"include_domains": ["example.com"]},
        })
        status = request_research(main_args(["research", "status", "--run-id", "trun_1234567890abcdef"]), opener)
        result = request_research(main_args(["research", "result", "--run-id", "trun_1234567890abcdef"]), opener)
        self.assertEqual(captured[1].full_url, f"{API_ROOT}/tasks/runs/trun_1234567890abcdef")
        self.assertEqual(captured[2].full_url, f"{API_ROOT}/tasks/runs/trun_1234567890abcdef/result")
        self.assertEqual(status["status"], "completed")
        self.assertEqual(result["output"]["content"], "report")

    def test_monitor_create_list_events_and_confirmed_cancel(self):
        captured = []

        def opener(request, timeout):
            captured.append(request)
            return FakeResponse({"monitor_id": "monitor_1234567890abcdef", "status": "active", "events": []})

        request_monitor(main_args([
            "monitor", "create", "--query", "Product launches", "--frequency", "1d",
            "--include-domain", "example.com", "--webhook", "https://hooks.example.com/parallel",
        ]), opener)
        request_monitor(main_args(["monitor", "list", "--limit", "10"]), opener)
        request_monitor(main_args(["monitor", "events", "--monitor-id", "monitor_1234567890abcdef", "--event-group-id", "group_123"]), opener)
        request_monitor(main_args(["monitor", "cancel", "--monitor-id", "monitor_1234567890abcdef", "--confirm"]), opener)
        self.assertEqual(captured[0].full_url, f"{API_ROOT}/monitors")
        self.assertEqual(json.loads(captured[0].data), {
            "type": "event_stream", "frequency": "1d", "processor": "lite",
            "settings": {"query": "Product launches", "advanced_settings": {"source_policy": {"include_domains": ["example.com"]}}},
            "webhook": {"url": "https://hooks.example.com/parallel", "event_types": ["monitor.event.detected"]},
        })
        self.assertEqual(captured[1].full_url, f"{API_ROOT}/monitors?limit=10&status=active")
        self.assertEqual(captured[2].full_url, f"{API_ROOT}/monitors/monitor_1234567890abcdef/events?limit=100&event_group_id=group_123")
        self.assertEqual(captured[3].full_url, f"{API_ROOT}/monitors/monitor_1234567890abcdef/cancel")
        self.assertEqual(captured[3].get_method(), "POST")

    def test_missing_key_fails_before_network(self):
        calls = []

        def opener(*_args, **_kwargs):
            calls.append(True)
            return FakeResponse(response())

        with patch.dict(os.environ, {"PARALLEL_API_KEY": ""}):
            with self.assertRaisesRegex(ParallelError, "PARALLEL_API_KEY"):
                request_search(main_args(["search", "--query", "coach bien-être"]), opener=opener)
        self.assertEqual(calls, [])

    def test_rejects_query_count_and_lengths(self):
        with self.assertRaisesRegex(ParallelError, "at most five"):
            self.call(["search", *(part for _ in range(6) for part in ("--query", "some phrase"))], response())
        with self.assertRaisesRegex(ParallelError, "200 characters"):
            self.call(["search", "--query", "x" * 201], response())

    def test_rejects_oversized_objective(self):
        with self.assertRaisesRegex(ParallelError, "5000 characters"):
            self.call(["search", "--query", "test words", "--objective", "x" * 5001], response())

    def test_invalid_domain_is_rejected_by_parser(self):
        with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            main(["search", "--query", "coach bien-être", "--domain", "claiire.fr/path"])

    def test_redirects_are_not_followed_with_api_key_header(self):
        handler = _NoRedirectHandler()
        self.assertIsNone(handler.redirect_request(None, None, 302, "Found", {}, "https://attacker.test/"))

    def test_http_and_network_errors_are_safe_and_key_redacted(self):
        def http_error(request, timeout):
            raise HTTPError(API_URL, 429, "rate", {}, io.BytesIO(b'{"error":{"message":"test-key over quota"}}'))

        with self.assertRaisesRegex(ParallelError, r"HTTP 429: \[REDACTED\] over quota"):
            request_search(main_args(["search", "--query", "coach bien-être"]), http_error)
        with self.assertRaisesRegex(ParallelError, "network request failed"):
            request_search(main_args(["search", "--query", "coach bien-être"]), lambda *_a, **_k: (_ for _ in ()).throw(URLError("offline")))
        with self.assertRaisesRegex(ParallelError, "network request failed"):
            request_search(main_args(["search", "--query", "coach bien-être"]), lambda *_a, **_k: (_ for _ in ()).throw(TimeoutError()))

    def test_application_json_error_redacts_key(self):
        with self.assertRaisesRegex(ParallelError, r"\[REDACTED\] denied"):
            self.call(["search", "--query", "coach bien-être"], {"type": "error", "error": {"message": "test-key denied"}})

    def test_invalid_json_and_unexpected_shapes_fail(self):
        with self.assertRaisesRegex(ParallelError, "invalid JSON"):
            self.call(["search", "--query", "coach bien-être"], b"not-json")
        with self.assertRaisesRegex(ParallelError, "results list"):
            self.call(["search", "--query", "coach bien-être"], {"results": None})

    def test_oversized_response_fails(self):
        from tools.shipglows_parallel import MAX_RESPONSE_BYTES

        with self.assertRaisesRegex(ParallelError, "4 MiB"):
            self.call(["search", "--query", "coach bien-être"], b" " * (MAX_RESPONSE_BYTES + 1))

    def test_cli_json_success_and_error_exit(self):
        output = io.StringIO()
        with redirect_stdout(output):
            status = main(["search", "--query", "coach bien-être"], opener=lambda *_a, **_k: FakeResponse(response()))
        self.assertEqual(status, 0)
        self.assertEqual(json.loads(output.getvalue())["provider"], "parallel")
        errors = io.StringIO()
        with patch.dict(os.environ, {"PARALLEL_API_KEY": ""}), redirect_stderr(errors):
            status = main(["search", "--query", "coach bien-être"])
        self.assertEqual(status, 2)
        self.assertIn("PARALLEL_API_KEY", errors.getvalue())


def main_args(argv):
    from tools.shipglows_parallel import build_parser

    return build_parser().parse_args(argv)


if __name__ == "__main__":
    unittest.main()
