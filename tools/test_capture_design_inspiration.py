from __future__ import annotations

import contextlib
import hashlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import yaml
from PIL import Image

from tools import capture_design_inspiration as capture


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tools" / "fixtures" / "design-inspiration" / "sample-sales-page.html"
RECORD_SCHEMA = ROOT / "skills" / "references" / "design-inspiration" / "record.schema.yaml"
INDEX_SCHEMA = ROOT / "skills" / "references" / "design-inspiration" / "index.schema.yaml"
SAMPLE_RECORD = ROOT / "skills" / "references" / "design-inspiration" / "sample-record.yaml"


def read_yaml(path: Path):
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def file_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class PathAndSchemaTests(unittest.TestCase):
    def test_path_refuses_shipglows_public_repo(self) -> None:
        with self.assertRaises(capture.CaptureToolError) as caught:
            capture.validate_output_root(ROOT / "tmp-inspiration-output", fixture_mode=False)
        self.assertEqual(caught.exception.code, "public_repo_target")

    def test_path_fixture_requires_system_temp(self) -> None:
        with self.assertRaises(capture.CaptureToolError) as caught:
            capture.validate_output_root(ROOT / "fixture-output", fixture_mode=True)
        self.assertEqual(caught.exception.code, "public_repo_target")

    def test_path_accepts_synthetic_fixture_in_temp(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            resolved = capture.validate_output_root(Path(temporary) / "corpus", fixture_mode=True)
            self.assertTrue(capture.is_relative_to(resolved, Path(tempfile.gettempdir()).resolve()))

    def test_schema_required_fields_match_synthetic_sample(self) -> None:
        schema = read_yaml(RECORD_SCHEMA)
        sample = read_yaml(SAMPLE_RECORD)
        self.assertEqual(schema["schema_version"], "1.0")
        self.assertFalse(set(schema["required"]) - set(sample))
        capture.validate_record(sample)
        self.assertEqual(capture.urlsplit(sample["source"]["url"]).hostname, "example.invalid")

    def test_index_schema_covers_duplicate_and_checksum_contract(self) -> None:
        schema = read_yaml(INDEX_SCHEMA)
        required = schema["properties"]["entries"]["items"]["required"]
        self.assertIn("capture_status", required)
        self.assertIn("bundle_checksum", required)
        self.assertIn("full_page_checksum", required)
        self.assertIn("duplicate_events", schema["required"])

    def test_url_normalization_and_query_redaction(self) -> None:
        original = "HTTPS://Example.Invalid:443/path/?token=private#fragment"
        self.assertEqual(capture.normalize_url(original), "https://example.invalid/path")
        redacted = capture.redact_url(original)
        self.assertNotIn("private", redacted)
        self.assertIn("redacted", redacted)


class TextExtractionTests(unittest.TestCase):
    def test_text_extracts_structure_and_excludes_hidden_boilerplate(self) -> None:
        html = FIXTURE.read_text(encoding="utf-8")
        markdown, blocks = capture.extract_fixture_markdown(html, "https://example.invalid/synthetic")
        self.assertGreater(len(blocks), 15)
        self.assertIn("# Turn scattered launch notes", markdown)
        self.assertIn("- Clarify the audience", markdown)
        self.assertIn("**Button:** Create my synthetic plan", markdown)
        self.assertIn("**Label:** Fictional work email", markdown)
        self.assertIn("[Read synthetic details]", markdown)
        self.assertNotIn("must never be extracted", markdown)
        self.assertNotIn("Accept every fictional cookie", markdown)
        self.assertNotIn("Hidden private copy", markdown)

    def test_text_fixture_rejects_non_synthetic_source_url(self) -> None:
        with self.assertRaises(capture.CaptureToolError) as caught:
            capture.capture_fixture(FIXTURE, "https://example.com/not-allowed")
        self.assertEqual(caught.exception.code, "fixture_source_not_synthetic")


class NodePlaywrightBridgeTests(unittest.TestCase):
    def test_discovery_resolves_package_from_global_cli(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            package_json = Path(temporary) / "node_modules" / "playwright" / "package.json"
            package_json.parent.mkdir(parents=True)
            package_json.write_text("{}", encoding="utf-8")
            completed = capture.subprocess.CompletedProcess(
                args=[], returncode=0, stdout=str(package_json), stderr=""
            )

            def which(name: str) -> str | None:
                return {"playwright": "/shared/bin/playwright", "node": "/usr/bin/node"}.get(name)

            with mock.patch.object(capture.shutil, "which", side_effect=which), mock.patch.object(
                capture.subprocess, "run", return_value=completed
            ) as run:
                runtime = capture.discover_node_playwright_runtime()

            self.assertEqual(runtime.package_json, package_json.resolve())
            self.assertEqual(runtime.cli_path, Path("/shared/bin/playwright").resolve())
            resolver_command = run.call_args.args[0]
            self.assertEqual(resolver_command[0], "/usr/bin/node")
            self.assertEqual(resolver_command[-1], "/shared/bin/playwright")
            self.assertIn("cmd-shim-target", resolver_command[2])
            self.assertIn("@playwright/test/package.json", resolver_command[2])

    def test_discovery_reports_missing_cli(self) -> None:
        with mock.patch.object(capture.shutil, "which", return_value=None):
            with self.assertRaises(capture.CaptureToolError) as caught:
                capture.discover_node_playwright_runtime()
        self.assertEqual(caught.exception.code, "playwright_cli_unavailable")
        self.assertIn("global Node prefix", str(caught.exception))

    def test_discovery_reports_missing_package(self) -> None:
        completed = capture.subprocess.CompletedProcess(args=[], returncode=1, stdout="", stderr="private details")

        def which(name: str) -> str | None:
            return {"playwright": "/shared/bin/playwright", "node": "/usr/bin/node"}.get(name)

        with mock.patch.object(capture.shutil, "which", side_effect=which), mock.patch.object(
            capture.subprocess, "run", return_value=completed
        ):
            with self.assertRaises(capture.CaptureToolError) as caught:
                capture.discover_node_playwright_runtime()
        self.assertEqual(caught.exception.code, "playwright_package_unavailable")
        self.assertNotIn("private details", str(caught.exception))

    def test_bridge_passes_url_over_stdin_and_returns_structured_data(self) -> None:
        runtime = capture.NodePlaywrightRuntime(
            Path("/usr/bin/node"), Path("/shared/bin/playwright"), Path("/shared/playwright/package.json")
        )
        secret_url = "https://example.invalid/page?token=must-not-be-an-argument"
        payload = {"ok": True, "entries": [], "screenshotFailed": True}
        completed = capture.subprocess.CompletedProcess(args=[], returncode=0, stdout=json.dumps(payload), stderr="")
        with tempfile.TemporaryDirectory() as temporary, mock.patch.object(
            capture.subprocess, "run", return_value=completed
        ) as run:
            result = capture.run_node_capture(runtime, secret_url, Path(temporary) / "page.png")

        self.assertEqual(result, payload)
        command = run.call_args.args[0]
        self.assertNotIn(secret_url, command)
        self.assertEqual(json.loads(run.call_args.kwargs["input"]), {"url": secret_url})
        self.assertFalse(run.call_args.kwargs["check"])

    def test_bridge_reports_shared_browser_cache_error_without_raw_stderr(self) -> None:
        runtime = capture.NodePlaywrightRuntime(
            Path("/usr/bin/node"), Path("/shared/bin/playwright"), Path("/shared/playwright/package.json")
        )
        completed = capture.subprocess.CompletedProcess(
            args=[],
            returncode=2,
            stdout=json.dumps({"ok": False, "code": "playwright_browser_unavailable"}),
            stderr="secret URL and browser internals",
        )
        with tempfile.TemporaryDirectory() as temporary, mock.patch.object(
            capture.subprocess, "run", return_value=completed
        ):
            with self.assertRaises(capture.CaptureToolError) as caught:
                capture.run_node_capture(runtime, "https://example.invalid/", Path(temporary) / "page.png")
        self.assertEqual(caught.exception.code, "playwright_browser_unavailable")
        self.assertIn("shared cache", str(caught.exception))
        self.assertNotIn("secret URL", str(caught.exception))

    def test_live_capture_converts_bridge_dom_and_temporary_png(self) -> None:
        runtime = capture.NodePlaywrightRuntime(
            Path("/usr/bin/node"), Path("/shared/bin/playwright"), Path("/shared/playwright/package.json")
        )

        def bridge(_runtime, _url, png_path):
            Image.new("RGB", (80, 120), "white").save(png_path, format="PNG")
            return {
                "ok": True,
                "finalUrl": "https://example.invalid/final?private=kept-out-of-logs",
                "statusCode": 200,
                "title": "Synthetic",
                "visibleText": "Visible copy",
                "entries": [{"order": 0, "tag": "h1", "text": "Visible copy", "href": None}],
                "unsupported": ["canvas"],
                "screenshotFailed": False,
            }

        with mock.patch.object(capture, "discover_node_playwright_runtime", return_value=runtime), mock.patch.object(
            capture, "run_node_capture", side_effect=bridge
        ):
            result = capture.capture_live("https://example.invalid/source")

        self.assertEqual(result.capture_status, "captured")
        self.assertIn("# Visible copy", result.markdown or "")
        self.assertEqual(result.unsupported_elements, ["canvas"])
        self.assertEqual(result.image.size if result.image else None, (80, 120))


class ImageAndIntegrationTests(unittest.TestCase):
    def run_fixture(self, output: Path, reference_id: str = "sample-sales-page", url: str | None = None) -> tuple[int, str, str]:
        argv = [
            "--fixture",
            str(FIXTURE),
            "--output",
            str(output),
            "--id",
            reference_id,
            "--no-network",
        ]
        if url:
            argv.extend(["--url", url])
        stdout = io.StringIO()
        stderr = io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            code = capture.run(argv)
        return code, stdout.getvalue(), stderr.getvalue()

    def test_image_fixture_generates_complete_webp_bundle_and_checksums(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            code, stdout, stderr = self.run_fixture(corpus)
            self.assertEqual((code, stderr), (0, ""))
            self.assertIn("status=captured", stdout)
            bundle = corpus / "references" / "sample-sales-page"
            expected = ["record.yaml", "page.md", "full-page.webp", "thumbnail.webp", "segments/001.webp"]
            for name in expected:
                self.assertTrue((bundle / name).is_file(), name)
            segments = sorted((bundle / "segments").glob("*.webp"))
            self.assertGreaterEqual(len(segments), 2)
            self.assertEqual([path.name for path in segments], [f"{index:03d}.webp" for index in range(1, len(segments) + 1)])
            for image_path in [bundle / "full-page.webp", bundle / "thumbnail.webp", *segments]:
                with Image.open(image_path) as image:
                    self.assertEqual(image.format, "WEBP")
                    self.assertGreater(image.width, 0)
                    self.assertGreater(image.height, 0)
            record = read_yaml(bundle / "record.yaml")
            self.assertEqual(record["capture_status"], "captured")
            self.assertEqual(record["capture"]["engine"], "synthetic_fixture")
            self.assertEqual(record["capture"]["segment_height"], 1600)
            self.assertEqual(record["capture"]["segment_overlap"], 160)
            for relative, checksum in record["checksums"]["files"].items():
                self.assertEqual(file_sha256(bundle / relative), checksum)
            self.assertEqual(record["checksums"]["bundle"], capture.bundle_checksum(record["checksums"]["files"]))
            self.assertFalse((bundle / "source.html").exists())

    def test_sync_reports_pending_without_failing_a_local_capture(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            stdout = io.StringIO()
            stderr = io.StringIO()
            with mock.patch.object(capture, "sync_private_corpus", return_value="pending reason=git_lfs_unavailable") as sync, contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                code = capture.run(
                    [
                        "--fixture",
                        str(FIXTURE),
                        "--output",
                        str(corpus),
                        "--id",
                        "sync-pending",
                        "--no-network",
                        "--sync",
                    ]
                )
            self.assertEqual((code, stderr.getvalue()), (0, ""))
            self.assertIn("sync=pending reason=git_lfs_unavailable", stdout.getvalue())
            sync.assert_called_once()

    def test_sync_is_rejected_for_read_only_list_mode(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                code = capture.run(["--output", str(Path(temporary) / "corpus"), "--list", "--sync"])
            self.assertEqual(code, 2)
            self.assertIn("read_mode_conflict", stderr.getvalue())

    def test_image_thumbnail_is_bounded(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            code, _, _ = self.run_fixture(corpus)
            self.assertEqual(code, 0)
            with Image.open(corpus / "references" / "sample-sales-page" / "thumbnail.webp") as thumbnail:
                self.assertLessEqual(thumbnail.width, capture.THUMBNAIL_WIDTH)

    def test_oversized_full_page_is_downscaled_and_segments_are_retained(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            staging = Path(temporary) / "reference"
            staging.mkdir()
            image = Image.new("RGB", (320, capture.MAX_WEBP_DIMENSION + 100), "white")
            segments, warnings = capture.create_image_artifacts(image, staging)
            self.assertGreaterEqual(len(segments), 10)
            self.assertTrue(warnings)
            with Image.open(staging / "full-page.webp") as full_page:
                self.assertLessEqual(max(full_page.size), capture.MAX_WEBP_DIMENSION)
            self.assertTrue((staging / "segments" / "001.webp").is_file())

    def test_image_duplicate_checksum_does_not_create_second_reference(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            first, _, _ = self.run_fixture(corpus, "first-reference", "https://example.invalid/shared-fixture")
            second, stdout, _ = self.run_fixture(corpus, "second-reference", "https://example.invalid/shared-fixture-copy")
            self.assertEqual(first, 0)
            self.assertEqual(second, 3)
            self.assertIn("duplicate_checksum", stdout)
            self.assertFalse((corpus / "references" / "second-reference").exists())
            index = read_yaml(corpus / "index.yaml")
            self.assertEqual(len(index["entries"]), 1)
            self.assertEqual(index["duplicate_events"][-1]["reason"], "duplicate_checksum")


class StatusAndFailureTests(unittest.TestCase):
    def test_status_duplicate_id_is_recorded_without_overwrite(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            first = capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "same-id", "--no-network"])
            record_before = (corpus / "references" / "same-id" / "record.yaml").read_bytes()
            second = capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "same-id", "--no-network"])
            self.assertEqual(first, 0)
            self.assertEqual(second, 3)
            self.assertEqual(record_before, (corpus / "references" / "same-id" / "record.yaml").read_bytes())
            index = read_yaml(corpus / "index.yaml")
            self.assertEqual(index["duplicate_events"][-1]["reason"], "duplicate_id")

    def test_status_live_failure_writes_record_without_fake_artifacts(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = capture.validate_output_root(Path(temporary) / "private-corpus", fixture_mode=False)
            index = capture.bootstrap_corpus(corpus)
            failure = capture.CaptureToolError(
                "playwright_unavailable",
                "Install Playwright and Chromium, then retry.",
            )
            with mock.patch.object(capture, "capture_live", side_effect=failure):
                record, status = capture.capture_one(
                    root=corpus,
                    index=index,
                    url="https://example.invalid/live-failure?token=private",
                    reference_id="live-failure",
                    fixture=None,
                )
            self.assertEqual(status, "failed")
            self.assertIsNotNone(record)
            bundle = corpus / "references" / "live-failure"
            self.assertTrue((bundle / "record.yaml").is_file())
            self.assertFalse((bundle / "page.md").exists())
            self.assertFalse((bundle / "full-page.webp").exists())
            self.assertEqual(record["capture"]["reason_code"], "playwright_unavailable")
            self.assertEqual(record["checksums"]["files"], {})

    def test_status_auth_required_is_explicit_and_artifact_free(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = capture.validate_output_root(Path(temporary) / "private-corpus", fixture_mode=False)
            index = capture.bootstrap_corpus(corpus)
            result = capture.CaptureResult(
                final_url="https://example.invalid/login",
                access_status="authenticated",
                capture_status="auth_required",
                engine="playwright",
                reason_code="auth_required",
                reason="authentication wall detected",
            )
            with mock.patch.object(capture, "capture_live", return_value=result):
                record, status = capture.capture_one(
                    root=corpus,
                    index=index,
                    url="https://example.invalid/private",
                    reference_id="auth-wall",
                    fixture=None,
                )
            self.assertEqual(status, "auth_required")
            self.assertEqual(record["lifecycle_status"], "blocked")
            self.assertEqual(record["artifacts"]["segments"], [])

    def test_status_query_parameters_are_redacted_from_output_but_kept_private(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                code = capture.run(
                    [
                        "--fixture",
                        str(FIXTURE),
                        "--output",
                        str(corpus),
                        "--id",
                        "redaction-check",
                        "--url",
                        "https://example.invalid/redaction?secret=must-not-log",
                        "--no-network",
                    ]
                )
            self.assertEqual(code, 0)
            self.assertNotIn("must-not-log", stdout.getvalue())
            record = read_yaml(corpus / "references" / "redaction-check" / "record.yaml")
            self.assertIn("must-not-log", record["source"]["url"])

    def test_status_only_is_read_only_and_summarizes_index(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "status-check", "--no-network"])
            before = (corpus / "index.yaml").read_bytes()
            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                code = capture.run(["--output", str(corpus), "--status-only"])
            self.assertEqual(code, 0)
            self.assertIn('"captured": 1', stdout.getvalue())
            self.assertEqual(before, (corpus / "index.yaml").read_bytes())

    def test_approve_promotes_reviewed_candidate_and_refreshes_index(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            self.assertEqual(
                capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "review-me", "--no-network"]),
                0,
            )
            before = read_yaml(corpus / "index.yaml")
            self.assertEqual(before["entries"][0]["lifecycle_status"], "candidate")
            self.assertEqual(
                capture.run(
                    [
                        "--output",
                        str(corpus),
                        "--approve",
                        "review-me",
                        "--summary",
                        "Clear hierarchy from problem to proof.",
                        "--what-to-borrow",
                        "Use the proof sequence after the mechanism.",
                        "--what-not-to-copy",
                        "Do not reuse distinctive language or branding.",
                        "--page-type",
                        "landing-page",
                        "--audience",
                        "small-business",
                        "--style",
                        "editorial",
                        "--section",
                        "hero",
                        "--copy-pattern",
                        "problem-agitation",
                        "--conversion-goal",
                        "trial",
                    ]
                ),
                0,
            )
            record = read_yaml(corpus / "references" / "review-me" / "record.yaml")
            index = read_yaml(corpus / "index.yaml")
            self.assertEqual(record["lifecycle_status"], "approved")
            self.assertEqual(record["curation"]["summary"], "Clear hierarchy from problem to proof.")
            self.assertEqual(index["entries"][0]["lifecycle_status"], "approved")
            self.assertEqual(record["taxonomy"]["styles"], ["editorial"])
            self.assertEqual(index["entries"][0]["conversion_goals"], ["trial"])

    def test_approve_requires_classification(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "needs-taxonomy", "--no-network"])
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                code = capture.run(
                    [
                        "--output",
                        str(corpus),
                        "--approve",
                        "needs-taxonomy",
                        "--summary",
                        "A useful sequence.",
                        "--what-to-borrow",
                        "Use proof after the promise.",
                        "--what-not-to-copy",
                        "Do not copy the source language.",
                    ]
                )
            self.assertEqual(code, 2)
            self.assertIn("taxonomy_page_type_invalid", stderr.getvalue())

    def test_retry_replaces_an_explicit_failed_candidate_after_runtime_recovery(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "retry-me", "--no-network"])
            record_path = corpus / "references" / "retry-me" / "record.yaml"
            failed = read_yaml(record_path)
            failed["capture_status"] = "failed"
            failed["artifacts"] = {"page_markdown": None, "full_page_image": None, "thumbnail_image": None, "segments": []}
            failed["checksums"] = {"algorithm": "sha256", "files": {}, "bundle": ""}
            failed["capture"]["reason_code"] = "playwright_package_unavailable"
            capture.atomic_yaml_write(record_path, failed)
            index = read_yaml(corpus / "index.yaml")
            index["entries"][0]["capture_status"] = "failed"
            capture.atomic_yaml_write(corpus / "index.yaml", index)
            with mock.patch.object(capture, "capture_live", return_value=capture.capture_fixture(FIXTURE, "https://example.invalid/retry-me")):
                code = capture.run(["--output", str(corpus), "--retry", "retry-me"])
            self.assertEqual(code, 0)
            record = read_yaml(record_path)
            self.assertEqual(record["capture_status"], "captured")
            self.assertEqual(record["capture"]["retry_of"]["reason_code"], "playwright_package_unavailable")

    def test_approve_requires_a_complete_review(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            capture.run(["--fixture", str(FIXTURE), "--output", str(corpus), "--id", "incomplete-review", "--no-network"])
            self.assertEqual(capture.run(["--output", str(corpus), "--approve", "incomplete-review"]), 2)
            record = read_yaml(corpus / "references" / "incomplete-review" / "record.yaml")
            self.assertEqual(record["lifecycle_status"], "candidate")

    def test_wayback_url_is_optional_metadata_and_never_fetched(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            self.assertEqual(
                capture.run(
                    [
                        "--fixture",
                        str(FIXTURE),
                        "--output",
                        str(corpus),
                        "--id",
                        "with-wayback",
                        "--url",
                        "https://example.invalid/with-wayback",
                        "--wayback-url",
                        "https://web.archive.org/web/20260101000000/https://example.invalid/with-wayback",
                        "--no-network",
                    ]
                ),
                0,
            )
            record = read_yaml(corpus / "references" / "with-wayback" / "record.yaml")
            self.assertEqual(
                record["source"]["wayback_url"],
                "https://web.archive.org/web/20260101000000/https://example.invalid/with-wayback",
            )

    def test_list_redacts_query_strings_and_is_read_only(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            corpus = Path(temporary) / "corpus"
            capture.run(
                [
                    "--fixture",
                    str(FIXTURE),
                    "--output",
                    str(corpus),
                    "--id",
                    "list-check",
                    "--url",
                    "https://example.invalid/list-check?secret=must-not-log",
                    "--no-network",
                ]
            )
            before = (corpus / "index.yaml").read_bytes()
            stdout = io.StringIO()
            with contextlib.redirect_stdout(stdout):
                self.assertEqual(capture.run(["--output", str(corpus), "--list"]), 0)
            self.assertIn('"id": "list-check"', stdout.getvalue())
            self.assertNotIn("must-not-log", stdout.getvalue())
            self.assertEqual(before, (corpus / "index.yaml").read_bytes())


if __name__ == "__main__":
    unittest.main()
