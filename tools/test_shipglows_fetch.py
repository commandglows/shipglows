from __future__ import annotations

import io
import json
import os
import unittest
from contextlib import redirect_stderr, redirect_stdout
from email.message import Message
from unittest.mock import patch

import tools.shipglows_fetch as fetch  # noqa: E402  (adds tools/ to sys.path)
import shipglows_html  # noqa: E402
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


def crawl_result(url, markdown, fit=None, status=200, success=True):
    return {"results": [{"url": url, "success": success, "status_code": status, "error_message": "blocked",
                         "metadata": {"title": "Local"},
                         "markdown": {"raw_markdown": markdown, "fit_markdown": markdown if fit is None else fit}}]}


class FetchFallbackTests(unittest.TestCase):
    def setUp(self):
        env = patch.dict(os.environ, {"CRAWL4AI_API_TOKEN": "c4-token", "FIRECRAWL_API_KEY": "fc-key",
                                      "PARALLEL_API_KEY": "", fetch.HTTP_ENV: "off"})
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
        status, output, calls = self.run_fetch(["https://example.com/"], crawl_result("https://example.com/", "# Local"))
        self.assertEqual(status, 0)
        self.assertEqual(output["pages"][0]["provider"], "crawl4ai")
        self.assertEqual(output["pages"][0]["title"], "Local")
        self.assertEqual(calls[0].get_header("Authorization"), "Bearer c4-token")
        params = json.loads(calls[0].data)["crawler_config"]["params"]
        self.assertEqual(params["markdown_generator"]["params"]["content_filter"]["type"], "PruningContentFilter")

    def test_query_uses_bm25_and_empty_fit_keeps_whole_page(self):
        result = crawl_result("https://example.com/", "whole page", fit="")
        _, output, calls = self.run_fetch(["https://example.com/", "--query", "pricing"], result)
        content_filter = json.loads(calls[0].data)["crawler_config"]["params"]["markdown_generator"]["params"]["content_filter"]
        self.assertEqual(content_filter, {"type": "BM25ContentFilter", "params": {"user_query": "pricing"}})
        self.assertEqual(output["pages"][0]["markdown"], "whole page")

    def test_blocked_or_http_error_page_falls_back(self):
        result = crawl_result("https://example.com/", "Just a moment", status=403, success=False)
        _, output, _ = self.run_fetch(["https://example.com/"], result)
        self.assertEqual(output["pages"][0]["provider"], "firecrawl")
        self.assertIn("HTTP 403", output["pages"][0]["attempts"][0]["reason"])

    def test_urls_share_one_crawl4ai_call(self):
        result = {"results": [*crawl_result("https://b.example/", "B")["results"],
                              *crawl_result("https://a.example/", "A")["results"]]}
        _, output, calls = self.run_fetch(["https://a.example/", "https://b.example/"], result)
        self.assertEqual([page["markdown"] for page in output["pages"]], ["A", "B"])
        self.assertEqual(len(calls), 1)

    def test_stopped_stack_falls_back_after_one_attempt(self):
        status, output, calls = self.run_fetch(["https://example.com/"], ConnectionRefusedError("refused"))
        self.assertEqual(status, 0)
        self.assertEqual(output["pages"][0]["provider"], "firecrawl")
        self.assertEqual(sum("firecrawl" not in call.full_url for call in calls), 1)

    def test_empty_page_falls_back(self):
        _, output, _ = self.run_fetch(["https://example.com/"], crawl_result("https://example.com/", "  "))
        self.assertEqual(output["pages"][0]["provider"], "firecrawl")

    def test_max_chars_truncates(self):
        _, output, _ = self.run_fetch(["https://example.com/", "--max-chars", "3"], crawl_result("https://example.com/", "abcdef"))
        self.assertEqual(output["pages"][0]["markdown"], "abc")
        self.assertTrue(output["pages"][0]["truncated"])

    def test_firecrawl_rate_limit_moves_on_without_retry_in_auto_mode(self):
        from urllib.error import HTTPError
        calls = []

        def opener(request, timeout):
            calls.append(request.full_url)
            if "firecrawl" in request.full_url:
                raise HTTPError(request.full_url, 429, "rate", {}, io.BytesIO(b"{}"))
            raise ConnectionRefusedError("refused")

        with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            status = fetch.main(["https://example.com/"], opener=opener)
        self.assertEqual(status, fetch.EXIT_ALL_FAILED)
        self.assertEqual(sum("firecrawl" in url for url in calls), 1)

    def test_every_provider_failing_exits_3(self):
        with patch.dict(os.environ, {"FIRECRAWL_API_KEY": ""}):
            status, output, _ = self.run_fetch(["https://example.com/"], ConnectionRefusedError("refused"))
        self.assertEqual(status, fetch.EXIT_ALL_FAILED)
        self.assertIsNone(output["pages"][0]["provider"])


ARTICLE = "<p>" + "Notes app pricing starts at nine euros per month for teams. " * 12 + "</p>"
STATIC_PAGE = f"""<html><head><title>Notes</title><script>x()</script></head><body>
<nav><a href="/menu">Menu</a></nav><main><h1>Pricing</h1>{ARTICLE}<p><a href="/plans">Plans</a></p></main>
<footer>Legal</footer></body></html>"""
SHELL_PAGE = "<html><head>" + "<script src='a.js'></script>" * 5 + "</head><body><div id='root'></div></body></html>"


class HtmlResponse:
    def __init__(self, html, content_type="text/html; charset=utf-8"):
        self.body = html.encode("utf-8")
        self.headers = Message()
        self.headers["Content-Type"] = content_type

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return None

    def read(self, size=-1):
        return self.body[:size]


class HttpFirstTests(unittest.TestCase):
    def setUp(self):
        env = patch.dict(os.environ, {"CRAWL4AI_API_TOKEN": "c4-token", "FIRECRAWL_API_KEY": "", "PARALLEL_API_KEY": ""})
        env.start()
        self.addCleanup(env.stop)
        os.environ.pop(fetch.HTTP_ENV, None)
        os.environ.pop(fetch.TIMEOUT_ENV, None)

    def run_fetch(self, argv, page):
        calls = []

        def opener(request, timeout):
            calls.append(request.full_url)
            if request.full_url.endswith("/crawl"):
                return FakeResponse(crawl_result("https://app.example/", "# Rendered by the browser"))
            return page

        out = io.StringIO()
        with redirect_stdout(out), redirect_stderr(io.StringIO()):
            status = fetch.main(argv, opener=opener)
        return status, json.loads(out.getvalue()), calls

    def test_static_page_skips_the_browser(self):
        status, output, calls = self.run_fetch(["https://app.example/"], HtmlResponse(STATIC_PAGE))
        page = output["pages"][0]
        self.assertEqual((status, page["provider"], page["title"]), (0, "http", "Notes"))
        self.assertIn("# Pricing", page["markdown"])
        self.assertIn("[Plans](https://app.example/plans)", page["markdown"])
        self.assertNotIn("Menu", page["markdown"])
        self.assertFalse(any(url.endswith("/crawl") for url in calls))

    def test_javascript_shell_goes_to_the_browser(self):
        _, output, calls = self.run_fetch(["https://app.example/"], HtmlResponse(SHELL_PAGE))
        page = output["pages"][0]
        self.assertEqual(page["provider"], "crawl4ai")
        self.assertIn("JavaScript shell", page["attempts"][0]["reason"])
        self.assertTrue(calls[-1].endswith("/crawl"))

    def test_non_html_answer_goes_to_the_browser(self):
        _, output, _ = self.run_fetch(["https://app.example/"], HtmlResponse("%PDF", "application/pdf"))
        self.assertEqual(output["pages"][0]["attempts"][0]["status"], "skipped")
        self.assertEqual(output["pages"][0]["provider"], "crawl4ai")


class HtmlConversionTests(unittest.TestCase):
    def test_short_static_page_is_not_a_shell(self):
        html = "<html><body><h1>Example</h1><p>This domain is for documentation examples only.</p></body></html>"
        _, markdown = shipglows_html.html_to_markdown(html, "https://example.com/")
        self.assertFalse(shipglows_html.looks_like_js_shell(html, markdown))

    def test_query_keeps_matching_blocks_with_their_heading(self):
        markdown = "# Intro

Welcome.

## Tarifs

Le prix démarre à 9 €.

## Équipe

Nous sommes dix."
        self.assertEqual(shipglows_html.filter_by_query(markdown, "prix"), "## Tarifs

Le prix démarre à 9 €.")


if __name__ == "__main__":
    unittest.main()
