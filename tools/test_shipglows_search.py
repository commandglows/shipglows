from __future__ import annotations

import io
import json
import os
import unittest
from contextlib import redirect_stderr, redirect_stdout
from unittest.mock import patch
from urllib.error import HTTPError

import tools.shipglows_search as search  # noqa: E402  (adds tools/ to sys.path)
import shipglows_http  # noqa: E402


class FakeResponse:
    def __init__(self, value):
        self.body = json.dumps(value).encode()

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return None

    def read(self, size=-1):
        return self.body[:size]


FIRECRAWL_OK = {"success": True, "data": {"web": [{"url": "https://example.fr/", "title": "FC", "description": "d"}]}}
PARALLEL_OK = {"search_id": "s", "results": [{"url": "https://example.org/", "title": "PL", "excerpts": []}]}


class SearchFallbackTests(unittest.TestCase):
    def setUp(self):
        env = patch.dict(os.environ, {"FIRECRAWL_API_KEY": "fc-key", "PARALLEL_API_KEY": "pl-key",
                                      search.SEARXNG_URL_ENV: "off"})
        env.start()
        self.addCleanup(env.stop)
        for name in (search.TIMEOUT_ENV, "SHIPGLOWS_PARALLEL_TIMEOUT"):
            os.environ.pop(name, None)
        sleeper = patch.object(shipglows_http, "_sleep")
        self.sleep = sleeper.start()
        self.addCleanup(sleeper.stop)

    def run_search(self, argv, firecrawl_failures):
        calls = {"firecrawl": 0, "parallel": 0, "timeouts": []}

        def opener(request, timeout):
            calls["timeouts"].append(timeout)
            if "firecrawl" in request.full_url:
                calls["firecrawl"] += 1
                if calls["firecrawl"] <= len(firecrawl_failures):
                    raise firecrawl_failures[calls["firecrawl"] - 1]
                return FakeResponse(FIRECRAWL_OK)
            calls["parallel"] += 1
            return FakeResponse(PARALLEL_OK)

        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            status = search.main(argv, opener=opener)
        return status, (json.loads(out.getvalue()) if status == 0 else None), calls

    def http(self, code):
        return HTTPError(search.FIRECRAWL_SEARCH_URL, code, "err", {}, io.BytesIO(b"{}"))

    def test_rate_limit_falls_back_without_retrying_in_auto_mode(self):
        status, output, calls = self.run_search(["coach"], [self.http(429)])
        self.assertEqual(status, 0)
        self.assertEqual(output["provider"], "parallel")
        self.assertEqual(calls["firecrawl"], 1)
        self.assertIn("(1 attempt)", output["attempts"][0]["reason"])
        self.sleep.assert_not_called()

    def test_gateway_error_is_retried_on_firecrawl(self):
        status, output, calls = self.run_search(["coach"], [self.http(503)])
        self.assertEqual(status, 0)
        self.assertEqual(output["provider"], "firecrawl")
        self.assertEqual(calls["firecrawl"], 2)
        self.assertEqual(calls["parallel"], 0)

    def test_explicit_firecrawl_retries_rate_limit(self):
        status, output, calls = self.run_search(["coach", "--provider", "firecrawl"], [self.http(429)])
        self.assertEqual(status, 0)
        self.assertEqual(calls["firecrawl"], 2)

    def test_network_failures_report_reason_then_fall_back(self):
        status, output, calls = self.run_search(["coach"], [TimeoutError("timed out")] * 3)
        self.assertEqual(output["provider"], "parallel")
        self.assertEqual(calls["firecrawl"], 3)
        self.assertIn("TimeoutError: timed out) after 3 attempts", output["attempts"][0]["reason"])

    def test_timeout_flag_applies_to_every_provider(self):
        _, _, calls = self.run_search(["coach", "--timeout", "9"], [self.http(402)])
        self.assertEqual(calls["timeouts"], [9.0, 9.0])
        with patch.dict(os.environ, {search.TIMEOUT_ENV: "12"}):
            _, _, calls = self.run_search(["coach"], [])
        self.assertEqual(calls["timeouts"], [12.0])


class SearxngProviderTests(unittest.TestCase):
    def setUp(self):
        env = patch.dict(os.environ, {"FIRECRAWL_API_KEY": "fc-key", "PARALLEL_API_KEY": "",
                                      search.SEARXNG_URL_ENV: "http://127.0.0.1:8888/"})
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop(search.TIMEOUT_ENV, None)
        sleeper = patch.object(shipglows_http, "_sleep")
        sleeper.start()
        self.addCleanup(sleeper.stop)

    def run_search(self, argv, searxng):
        urls = []

        def opener(request, timeout):
            urls.append(request.full_url)
            if "127.0.0.1" in request.full_url:
                if isinstance(searxng, BaseException):
                    raise searxng
                return FakeResponse(searxng)
            return FakeResponse(FIRECRAWL_OK)

        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            status = search.main(argv, opener=opener)
        return status, (json.loads(out.getvalue()) if status == 0 else None), urls

    def test_searxng_answers_first(self):
        payload = {"results": [{"url": "https://local.example/", "title": "SX", "content": "c",
                                "publishedDate": "2026-10-01T00:00:00"}]}
        status, output, urls = self.run_search(["coach", "--include-domain", "example.com"], payload)
        self.assertEqual(status, 0)
        self.assertEqual(output["provider"], "searxng")
        self.assertEqual(output["results"][0]["publish_date"], "2026-10-01")
        self.assertTrue(urls[0].startswith("http://127.0.0.1:8888/search?"))
        self.assertIn("format=json", urls[0])
        self.assertIn("site%3Aexample.com", urls[0])

    def test_stopped_service_falls_back_after_one_attempt(self):
        status, output, urls = self.run_search(["coach"], ConnectionRefusedError("refused"))
        self.assertEqual(output["provider"], "firecrawl")
        self.assertEqual(sum("127.0.0.1" in url for url in urls), 1)

    def test_empty_results_fall_back(self):
        _, output, _ = self.run_search(["coach"], {"results": []})
        self.assertEqual(output["provider"], "firecrawl")
        self.assertIn("no results", output["attempts"][0]["reason"])

    def test_after_date_skips_searxng(self):
        _, output, urls = self.run_search(["coach", "--after-date", "2026-01-01"], {"results": []})
        self.assertEqual(output["attempts"][0]["status"], "skipped")
        self.assertFalse(any("127.0.0.1" in url for url in urls))


if __name__ == "__main__":
    unittest.main()
