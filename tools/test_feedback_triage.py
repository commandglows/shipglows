#!/usr/bin/env python3
"""Behavior tests for per-product feedback triage (tools/feedback_triage.py).

A fake runner stands in for ``doppler run -- convex run``: no Convex call, no Doppler,
no secret is involved. The site and history writes use temporary Git repositories."""

from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any
import json
import unittest

from tools.context_history import load_events
from tools.feedback_triage import (
    DECISIONS_SCHEMA,
    TriageError,
    _parse_output,
    apply,
    check_deployment,
    discover_backend,
    inbox,
    load_decisions,
    main,
    similarity,
)
from tools.test_product_updates import wired_repository

DEPLOYMENT = "dev:happy-otter-123"


class FakeRunner:
    def __init__(self, deployment: str = DEPLOYMENT, *, answers: dict[str, Any] | None = None, fail_on: str | None = None):
        self._deployment = deployment
        self.answers = answers or {}
        self.fail_on = fail_on
        self.calls: list[tuple[str, dict[str, Any]]] = []

    def deployment(self) -> str:
        return self._deployment

    def run(self, function: str, args: dict[str, Any]) -> Any:
        self.calls.append((function, args))
        if function == self.fail_on:
            raise TriageError(f"feedback:{function} failed (exit 1): request not found")
        answer = self.answers.get(function)
        return answer(args) if callable(answer) else answer if answer is not None else {"ok": True}


def product_repository(root: Path, *, prd_doc: bool = True) -> Path:
    """A wired product repo (site with roadmap item fast-exports) whose site hosts the Convex backend."""
    site = wired_repository(root)
    (site / ".shipglows.backend.json").write_text(json.dumps({
        "schemaVersion": "shipglows.backend.v1", "provider": "convex", "mode": "remote",
        "readiness": {"url": "https://happy-otter-123.convex.cloud/", "statusCode": 200},
    }), encoding="utf-8")
    (site / ".shipglows.node.json").write_text(json.dumps({
        "schemaVersion": "shipglows.node-recipe.v1", "doppler": {"project": "replayglows", "config": "dev"},
    }), encoding="utf-8")
    convex = site / "convex"
    convex.mkdir()
    (convex / "feedback.ts").write_text(
        "const feedback = defineFeedbackFunctions(builders, { module: 'feedback', products: ['replayglows'] })\n",
        encoding="utf-8",
    )
    cli = site / "node_modules/convex"
    (cli / "bin").mkdir(parents=True)
    (cli / "package.json").write_text(json.dumps({"bin": {"convex": "bin/main.js"}}), encoding="utf-8")
    (cli / "bin/main.js").write_text("", encoding="utf-8")
    if prd_doc:
        (root / "ENVIRONMENT.md").write_text(
            "| Production | `quiet-lynx-9` | Doppler `replayglows/prd` |\n", encoding="utf-8",
        )
    return site


def inbox_answers() -> dict[str, Any]:
    return {
        "triageListFeedback": [
            {"id": "fb1", "product": "replayglows", "userId": "gu_secret_person", "kind": "text",
             "message": "Exports are too slow, please make fast exports", "context": {"platform": "android", "buildCommitSha": "abc"},
             "status": "new", "createdAt": 1},
            {"id": "fb2", "product": "replayglows", "userId": "gu_other", "kind": "audio", "audioUrl": "https://signed.example/a",
             "audioDurationMs": 4000, "context": {"platform": "windows"}, "status": "new", "createdAt": 2},
            {"id": "fb3", "product": "replayglows", "userId": "gu_third", "kind": "text",
             "message": "Please make fast exports, exports are too slow", "context": {"platform": "web"}, "status": "new", "createdAt": 3},
        ],
        "triageListRequests": [
            {"id": "req_a", "title": "Faster exports", "description": "Exports take minutes.", "products": ["replayglows"],
             "moderation": "pending", "authorId": "gu_secret_person", "possibleDuplicates": ["fast-exports"], "createdAt": "x"},
            {"id": "req_b", "title": "Dark theme", "description": "Night mode.", "products": ["otherproduct"],
             "moderation": "pending", "authorId": "gu_x", "createdAt": "y"},
        ],
        "counts": lambda args: {"schema": "shipglows-roadmap-counts/v1",
                                "counts": {item: {"voteCount": 7, "hasVoted": False} for item in args["itemIds"]}},
    }


def decisions(*items: dict[str, Any], deployment: str = DEPLOYMENT, env: str = "dev") -> dict[str, Any]:
    return {"schema": DECISIONS_SCHEMA, "env": env, "deployment": deployment, "operator": "diane", "decisions": list(items)}


def write_decisions(root: Path, payload: dict[str, Any]) -> Path:
    path = root / "decisions.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    return path


CREATE = {
    "action": "create-item", "id": "dark-theme", "status": "considering",
    "title": {"en": "Dark theme", "fr": "Thème sombre"},
    "summary": {"en": "A darker interface for the evening.", "fr": "Une interface sombre pour le soir."},
}


class DiscoveryTests(unittest.TestCase):
    def test_dev_comes_from_the_recipe_and_prd_only_from_a_declared_mention(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            dev = discover_backend(root, "dev")
            self.assertEqual((dev.doppler_project, dev.doppler_config, dev.module), ("replayglows", "dev", "feedback"))
            self.assertEqual(dev.expected_deployment, "happy-otter-123")
            self.assertEqual(dev.directory, (root / "site").resolve())
            prd = discover_backend(root, "prd")
            self.assertEqual((prd.doppler_project, prd.doppler_config), ("replayglows", "prd"))
            self.assertIn("ENVIRONMENT.md", prd.declared_from)

    def test_missing_declarations_fail_closed(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = product_repository(root, prd_doc=False)
            with self.assertRaisesRegex(TriageError, "production"):
                discover_backend(root, "prd")
            (site / ".shipglows.node.json").unlink()
            with self.assertRaisesRegex(TriageError, "Doppler dev"):
                discover_backend(root, "dev")
            (site / "convex/feedback.ts").write_text("export const x = 1\n", encoding="utf-8")
            with self.assertRaisesRegex(TriageError, "defineFeedbackFunctions"):
                discover_backend(root, "dev")

    def test_two_backends_need_an_explicit_directory(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = product_repository(root)
            other = root / "api"
            (other / "convex").mkdir(parents=True)
            (other / ".shipglows.backend.json").write_text((site / ".shipglows.backend.json").read_text(), encoding="utf-8")
            (other / "convex/triage.ts").write_text("defineFeedbackFunctions(b, {})\n", encoding="utf-8")
            with self.assertRaisesRegex(TriageError, "--backend-dir"):
                discover_backend(root, "dev")
            with self.assertRaisesRegex(TriageError, "Doppler dev"):
                discover_backend(root, "dev", "api")
            (other / ".shipglows.node.json").write_text(
                json.dumps({"doppler": {"project": "replayglows-api", "config": "dev"}}), encoding="utf-8",
            )
            chosen = discover_backend(root, "dev", "api")
            self.assertEqual((chosen.module, chosen.doppler_project), ("triage", "replayglows-api"))

    def test_deployment_guard(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            dev = discover_backend(root, "dev")
            self.assertEqual(check_deployment(dev, DEPLOYMENT), DEPLOYMENT)
            for resolved in ("", "dev:someone-else-1", "prod:happy-otter-123", "garbage"):
                with self.assertRaises(TriageError):
                    check_deployment(dev, resolved)
            prd = discover_backend(root, "prd")
            self.assertEqual(check_deployment(prd, "prod:quiet-lynx-9"), "prod:quiet-lynx-9")
            with self.assertRaises(TriageError):
                check_deployment(prd, DEPLOYMENT)


class InboxTests(unittest.TestCase):
    def test_inbox_reads_one_product_without_identities_and_suggests(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            runner = FakeRunner(answers=inbox_answers())
            report = inbox(discover_backend(root), runner)
            self.assertEqual([call[0] for call in runner.calls], ["triageListFeedback", "triageListRequests", "counts"])
            self.assertEqual(runner.calls[0][1], {"status": "new", "product": "replayglows", "limit": 50})
            self.assertEqual(report["products"], ["replayglows"])
            self.assertEqual(report["summary"], {"newFeedback": 3, "pendingRequests": 1, "roadmapItems": 1, "votes": 7})
            serialized = json.dumps(report)
            for private in ("gu_secret_person", "gu_other", "signed.example", "abc"):
                self.assertNotIn(private, serialized)
            self.assertTrue(report["feedback"][1]["hasAudio"])
            self.assertEqual(report["roadmap"][0], {
                "id": "fast-exports", "status": "in_progress", "visibility": "public",
                "title": "Fast exports", "votes": 7, "inRegistry": True,
            })
            suggestions = report["suggestions"]
            self.assertEqual(suggestions["feedback"][0]["matchingItems"][0]["itemId"], "fast-exports")
            self.assertEqual(suggestions["requests"][0]["matchingItems"][0]["itemId"], "fast-exports")
            self.assertEqual(suggestions["duplicateFeedback"][0]["ids"], ["fb1", "fb3"])

    def test_inbox_refuses_a_foreign_deployment_before_any_read(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            runner = FakeRunner("prod:happy-otter-123", answers=inbox_answers())
            with self.assertRaises(TriageError):
                inbox(discover_backend(root), runner)
            self.assertEqual(runner.calls, [])

    def test_similarity_ignores_accents_case_and_stopwords(self) -> None:
        self.assertGreaterEqual(similarity("Le thème sombre SVP", "Theme sombre"), 0.6)
        self.assertLess(similarity("Crash at login", "Fast exports"), 0.3)


class DecisionFileTests(unittest.TestCase):
    def test_invalid_files_are_refused_whole(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            for invalid in (
                decisions({"action": "delete-everything"}),
                decisions({"action": "merge-request", "requestId": "req_a", "itemId": "a", "intoRequestId": "req_b"}),
                decisions({"action": "approve-request", "requestId": "req_a", "itemId": "Not A Slug"}),
                decisions({"action": "link-feedback", "feedbackId": "fb1"}),
                decisions({"action": "mark-bug", "feedbackId": "fb1", "classification": "bug"}),
                decisions({**CREATE, "status": "shipped"}),
                decisions({"action": "approve-request", "requestId": "req_a", "itemId": "a"}, deployment="gallant"),
                {**decisions({"action": "reject-request", "requestId": "req_a"}), "extra": 1},
            ):
                with self.assertRaises(TriageError, msg=json.dumps(invalid)):
                    load_decisions(write_decisions(root, invalid))


class ApplyTests(unittest.TestCase):
    def full_file(self) -> dict[str, Any]:
        return decisions(
            CREATE,
            {"action": "approve-request", "requestId": "req_a", "itemId": "dark-theme", "note": "Ajouté."},
            {"action": "merge-request", "requestId": "req_c", "intoRequestId": "req_a"},
            {"action": "reject-request", "requestId": "req_d"},
            {"action": "merge-items", "fromItemId": "night-mode", "toItemId": "fast-exports"},
            {"action": "link-feedback", "feedbackId": "fb1", "itemId": "fast-exports", "classification": "idea"},
            {"action": "mark-bug", "feedbackId": "fb2", "note": "Crash on export"},
            {"action": "mark-duplicate", "feedbackId": "fb3", "duplicateOfFeedbackId": "fb1"},
            {"action": "verify-tallies"},
        )

    def test_dry_run_plans_every_call_and_writes_nothing(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = product_repository(root)
            backend = discover_backend(root)
            report = apply(backend, load_decisions(write_decisions(root, self.full_file())), None, today="2026-11-23")
            self.assertEqual(report["status"], "planned")
            self.assertFalse((site / "src/content/roadmap/en/dark-theme.md").exists())
            self.assertEqual(load_events(root), [])
            self.assertEqual({record["action"] for record in report["projection"][0]["roadmap"]}, {"would-create"})
            calls = {entry["index"]: (entry.get("function"), entry.get("args")) for entry in report["plan"]}
            self.assertEqual(calls[1], ("feedback:moderateRequest", {
                "requestId": "req_a", "decision": "approved", "itemId": "dark-theme", "note": "Ajouté.", "operator": "diane"}))
            self.assertEqual(calls[2][1]["intoRequestId"], "req_a")
            self.assertEqual(calls[3][1]["decision"], "rejected")
            self.assertEqual(calls[4], ("feedback:mergeItems", {"fromItemId": "night-mode", "toItemId": "fast-exports", "operator": "diane"}))
            self.assertEqual(calls[5][1], {"feedbackId": "fb1", "linkedItemId": "fast-exports", "classification": "idea", "operator": "diane"})
            self.assertEqual(calls[6][1]["classification"], "bug")
            self.assertEqual(calls[7][1], {"feedbackId": "fb3", "duplicateOfFeedbackId": "fb1", "classification": "duplicate",
                                           "status": "archived", "operator": "diane"})
            self.assertEqual(calls[8], ("feedback:verifyVoteTallies", {}))
            self.assertIn("absent from the site content", " ".join(report["warnings"]))

    def test_confirm_creates_hidden_items_through_history_then_runs_triage_in_order(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            site = product_repository(root)
            runner = FakeRunner()
            report = apply(discover_backend(root), load_decisions(write_decisions(root, self.full_file())), runner, confirm=True)
            self.assertEqual(report["status"], "ok", report)
            for locale in ("en", "fr"):
                item = (site / f"src/content/roadmap/{locale}/dark-theme.md").read_text(encoding="utf-8")
                self.assertIn("visibility: hidden", item)
                self.assertIn("producer: agent", item)
            [event] = load_events(root)
            self.assertEqual(event["kind"], "CONTEXT_DECISION")
            self.assertEqual(event["public"]["roadmap"][0]["id"], "dark-theme")
            self.assertEqual(
                [call[0] for call in runner.calls],
                ["moderateRequest", "moderateRequest", "moderateRequest", "mergeItems",
                 "triageFeedback", "triageFeedback", "triageFeedback", "verifyVoteTallies"],
            )
            self.assertEqual(report["summary"]["results"], {"ok": 9})

    def test_first_failure_stops_the_remaining_calls(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            runner = FakeRunner(fail_on="mergeItems")
            file = decisions(
                {"action": "reject-request", "requestId": "req_d"},
                {"action": "merge-items", "fromItemId": "night-mode", "toItemId": "fast-exports"},
                {"action": "archive-feedback", "feedbackId": "fb1"},
            )
            report = apply(discover_backend(root), load_decisions(write_decisions(root, file)), runner, confirm=True)
            self.assertEqual(report["status"], "error")
            self.assertEqual([result["status"] for result in report["results"]], ["ok", "error", "not-run"])
            self.assertEqual(len(runner.calls), 2)

    def test_unknown_items_existing_items_and_deployment_mismatch_are_refused(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            backend = discover_backend(root)
            unknown = decisions({"action": "approve-request", "requestId": "req_a", "itemId": "nowhere"})
            with self.assertRaisesRegex(TriageError, "neither a roadmap item"):
                apply(backend, load_decisions(write_decisions(root, unknown)), None)
            existing = decisions({**CREATE, "id": "fast-exports"})
            with self.assertRaisesRegex(TriageError, "already exists"):
                apply(backend, load_decisions(write_decisions(root, existing)), None)
            other = decisions({"action": "reject-request", "requestId": "req_d"}, deployment="dev:someone-else-1")
            with self.assertRaisesRegex(TriageError, "dev deployment"):
                apply(backend, load_decisions(write_decisions(root, other)), None)
            prd_file = decisions({"action": "reject-request", "requestId": "req_d"}, env="prd", deployment="prod:quiet-lynx-9")
            with self.assertRaisesRegex(TriageError, "--env"):
                apply(backend, load_decisions(write_decisions(root, prd_file)), None)

    def test_cli_dry_run_never_builds_a_runner(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            product_repository(root)
            path = write_decisions(root, decisions({"action": "reject-request", "requestId": "req_d"}))

            def no_runner(_backend: Any) -> Any:
                raise AssertionError("dry run must not reach Convex")

            buffer = StringIO()
            with redirect_stdout(buffer):
                code = main(["--project-root", str(root), "apply", "--decisions", str(path), "--format", "text"],
                            runner_factory=no_runner)
            self.assertEqual(code, 0)
            self.assertIn("DRY RUN", buffer.getvalue())
            self.assertIn("[planned] reject-request req_d", buffer.getvalue())

    def test_convex_output_parser_skips_log_lines(self) -> None:
        self.assertEqual(_parse_output('[]\n'), [])
        self.assertEqual(_parse_output('Running...\n{\n  "a": 1\n}\n'), {"a": 1})
        with self.assertRaises(TriageError):
            _parse_output("no json here")


if __name__ == "__main__":
    unittest.main()
