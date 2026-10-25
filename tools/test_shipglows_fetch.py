from __future__ import annotations

import io
import json
import os
import unittest
from contextlib import redirect_stderr, redirect_stdout
from unittest.mock import patch

import tools.shipglows_fetch as fetch  # noqa: E402  (adds tools/ to sys.path)
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


class FetchFallbackTests(unittest.TestCase):
    def setUp(self):
        env = patch.dict(os.environ, {"CRAWL4AI_API_TOKEN": "c4-token", "FIRECRAWL_API_KEY": "fc-key",
                                      "PARALLEL_API_KEY": ""})
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop(fetch.TIMEOUT_ENV, None)
        sleeper = patch.object(shipglows_http, "_sleep")
        sleeper.start()
        self.addCleanup(sleeper.stop)

    def run_fetch(self, argv, crawl4ai):
        calls = []

        def opener(request, timeout):
            calls.append(request)
            if "firecrawl" in request.full_url:
                return FakeResponse({"success": True, "data": {"markdown": "# FC", "metadata": {"title": "T"}}})
            if isinstance(crawl4ai, BaseException):
                raise crawl4ai
            return FakeResponse(crawl4ai)

        out = io.StringIO()
        with redirect_stdout(out), redirect_stderr(io.StringIO()):
            status = fetch.main(argv, opener=opener)
        return status, json.loads(out.getvalue()), calls

    def test_crawl4ai_serves_first_with_token(self):
        status, output, calls = self.run_fetch(["https://example.com/"], {"markdown": "# Local"})
        self.assertEqual(status, 0)
        self.assertEqual(output["pages"][0]["provider"], "crawl4ai")
        self.assertEqual(calls[0].get_header("Authorization"), "Bearer c4-token")
        self.assertEqual(json.loads(calls[0].data)["f"], "fit")

    def test_stopped_stack_falls_back_after_one_attempt(self):
        status, output, calls = self.run_fetch(["https://example.com/"], ConnectionRefusedError("refused"))
        self.assertEqual(status, 0)
        self.assertEqual(output["pages"][0]["provider"], "firecrawl")
        self.assertEqual(sum("firecrawl" not in call.full_url for call in calls), 1)

    def test_empty_page_falls_back(self):
        _, output, _ = self.run_fetch(["https://example.com/"], {"markdown": "  "})
        self.assertEqual(output["pages"][0]["provider"], "firecrawl")

    def test_max_chars_truncates(self):
        _, output, _ = self.run_fetch(["https://example.com/", "--max-chars", "3"], {"markdown": "abcdef"})
        self.assertEqual(output["pages"][0]["markdown"], "abc")
        self.assertTrue(output["pages"][0]["truncated"])

    def test_every_provider_failing_exits_3(self):
        with patch.dict(os.environ, {"FIRECRAWL_API_KEY": ""}):
            status, output, _ = self.run_fetch(["https://example.com/"], ConnectionRefusedError("refused"))
        self.assertEqual(status, fetch.EXIT_ALL_FAILED)
        self.assertIsNone(output["pages"][0]["provider"])


if __name__ == "__main__":
    unittest.main()
