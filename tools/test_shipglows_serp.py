"""Credential-free tests for the SerpApi Google SERP CLI."""

import io
import json
import os
import unittest
from contextlib import redirect_stderr, redirect_stdout
from email.message import Message
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlsplit

from tools import shipglows_serp as serp


class FakeResponse:
    def __init__(self, body):
        self.body = body if isinstance(body, bytes) else json.dumps(body).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *_args):
        return False

    def read(self, size=-1):
        return self.body if size < 0 else self.body[:size]


def response(results=None, **extra):
    value = {
        "search_metadata": {"status": "Success", "id": "fixture-1"},
        "organic_results": results or [],
    }
    value.update(extra)
    return value


class SerpApiCliTests(unittest.TestCase):
    def setUp(self):
        self.previous_key = os.environ.get("SERPAPI_API_KEY")
        os.environ["SERPAPI_API_KEY"] = "fixture-secret-key"

    def tearDown(self):
        if self.previous_key is None:
            os.environ.pop("SERPAPI_API_KEY", None)
        else:
            os.environ["SERPAPI_API_KEY"] = self.previous_key

    def fake_opener(self, value, captured):
        def open_request(request, timeout):
            captured.append((request, timeout))
            return FakeResponse(value)
        return open_request

    def test_search_encodes_locale_and_sends_exactly_one_request(self):
        captured = []
        args = serp.parser().parse_args(["search", "--query", "référencement à Paris", "--location", "Paris, France"])
        result = serp.request_search(args, self.fake_opener(response(), captured))

        self.assertEqual(len(captured), 1)
        request, timeout = captured[0]
        params = parse_qs(urlsplit(request.full_url).query)
        self.assertEqual(timeout, 30)
        self.assertEqual(urlsplit(request.full_url).scheme, "https")
        self.assertEqual(params["engine"], ["google"])
        self.assertEqual(params["q"], ["référencement à Paris"])
        self.assertEqual(params["gl"], ["fr"])
        self.assertEqual(params["hl"], ["fr"])
        self.assertEqual(params["device"], ["desktop"])
        self.assertEqual(params["location"], ["Paris, France"])
        self.assertEqual(params["api_key"], ["fixture-secret-key"])
        self.assertNotIn("fixture-secret-key", json.dumps(result))
        self.assertEqual(result["query"], "référencement à Paris")

        resolved = response()
        resolved["search_parameters"] = {"location_used": "Paris,France"}
        result = serp.request_search(args, self.fake_opener(resolved, []))
        self.assertEqual(result["search_parameters"]["resolved_location"], "Paris,France")

    def test_domain_match_handles_apex_subdomain_and_lookalike(self):
        captured = []
        args = serp.parser().parse_args(["search", "--query", "test", "--domain", "claiire.fr"])
        result = serp.request_search(args, self.fake_opener(response([
            {"position": 1, "title": "Apex", "link": "https://claiire.fr/a"},
            {"position": 2, "title": "Subdomain", "link": "https://www.claiire.fr/b"},
            {"position": 3, "title": "Lookalike", "link": "https://fakeclaiire.fr/c"},
        ]), captured))

        self.assertEqual([item["matches_domain"] for item in result["organic_results"]], [True, True, False])
        self.assertEqual(result["target_rank"], 1)
        self.assertEqual([item["position"] for item in result["target_matches"]], [1, 2])

    def test_api_key_is_required_before_network_io(self):
        args = serp.parser().parse_args(["search", "--query", "test"])
        os.environ.pop("SERPAPI_API_KEY")
        called = []
        with self.assertRaisesRegex(serp.SerpApiError, "SERPAPI_API_KEY"):
            serp.request_search(args, lambda *_a, **_k: called.append(True))
        self.assertEqual(called, [])

    def test_domain_validation_rejects_deceptive_or_url_input(self):
        self.assertEqual(serp.normalize_domain("WWW.Claiire.fr."), "www.claiire.fr")
        for value in ("https://claiire.fr", "fake_domain.fr", "claiire.fr/path", "singlelabel"):
            with self.subTest(value=value), self.assertRaises(serp.argparse.ArgumentTypeError):
                serp.normalize_domain(value)

    def test_invalid_input_fails_before_network_io(self):
        called = []
        with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            serp.parser().parse_args(["search", "--query", "test", "--country", "not-a-country"])

        for query, location in (("  ", None), ("x" * 513, None), ("test", "x" * 201)):
            args = serp.parser().parse_args(["search", "--query", query] + (["--location", location] if location else []))
            with self.subTest(query_length=len(query), location_length=len(location or "")), self.assertRaises(serp.SerpApiError):
                serp.request_search(args, lambda *_a, **_k: called.append(True))
        self.assertEqual(called, [])

    def test_unexpected_status_and_malformed_organic_results_are_handled(self):
        args = serp.parser().parse_args(["search", "--query", "test"])
        processing = response()
        processing["search_metadata"]["status"] = "Processing"
        with self.assertRaisesRegex(serp.SerpApiError, "did not complete"):
            serp.request_search(args, self.fake_opener(processing, []))

        malformed = response(organic_results={"unexpected": "shape"})
        result = serp.request_search(args, self.fake_opener(malformed, []))
        self.assertEqual(result["organic_results"], [])

    def test_api_key_is_redacted_from_application_error(self):
        args = serp.parser().parse_args(["search", "--query", "test"])
        with self.assertRaises(serp.SerpApiError) as raised:
            serp.request_search(args, self.fake_opener(response(error="bad key fixture-secret-key"), []))
        self.assertNotIn("fixture-secret-key", str(raised.exception))
        self.assertIn("[REDACTED]", str(raised.exception))

    def test_http_network_timeout_and_invalid_json_errors_are_safe(self):
        args = serp.parser().parse_args(["search", "--query", "test"])
        headers = Message()
        openers = (
            lambda *_a, **_k: (_ for _ in ()).throw(HTTPError("https://serpapi.com/?api_key=fixture-secret-key", 429, "rate limit", headers, io.BytesIO(b'{"error":"fixture-secret-key denied"}'))),
            lambda *_a, **_k: (_ for _ in ()).throw(URLError("https://serpapi.com/?api_key=fixture-secret-key")),
            lambda *_a, **_k: (_ for _ in ()).throw(TimeoutError("fixture-secret-key")),
        )
        for opener in openers:
            with self.assertRaises(serp.SerpApiError) as raised:
                serp.request_search(args, opener)
            self.assertNotIn("fixture-secret-key", str(raised.exception))

        with self.assertRaisesRegex(serp.SerpApiError, "invalid JSON"):
            serp.request_search(args, lambda *_a, **_k: FakeResponse(b"not-json"))

    def test_large_response_is_rejected(self):
        args = serp.parser().parse_args(["search", "--query", "test"])
        oversized = b" " * (serp.MAX_RESPONSE_BYTES + 1)
        with self.assertRaisesRegex(serp.SerpApiError, "too large"):
            serp.request_search(args, lambda *_a, **_k: FakeResponse(oversized))

    def test_cli_emits_json_on_success_and_nonzero_safe_error(self):
        out = io.StringIO()
        with redirect_stdout(out):
            code = serp.main(["search", "--query", "test"], opener=self.fake_opener(response(), []))
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(out.getvalue())["source"], "serpapi.google_search")
        self.assertNotIn("fixture-secret-key", out.getvalue())

        err = io.StringIO()
        with redirect_stderr(err):
            code = serp.main(["search", "--query", "test"], opener=lambda *_a, **_k: (_ for _ in ()).throw(URLError("fixture-secret-key")))
        self.assertEqual(code, 2)
        self.assertNotIn("fixture-secret-key", err.getvalue())


if __name__ == "__main__":
    unittest.main()
