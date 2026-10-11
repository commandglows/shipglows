"""Stdlib synthetic tests: no listener, credentials config or real project data."""
import concurrent.futures
import io
import json
import tempfile
import unittest
from pathlib import Path
from uuid import uuid4
from project_review_intake import IntakeAPI, IntakeError, Store, handler_factory, load_grants, validate

TOKEN = "synthetic-token-only-" + "x" * 40
PATH = "/api/projects/shipglows/review-intake"

def fixture():
    return {"client_intake_id": str(uuid4()), "source_key": "a" * 64,
            "summary": "Synthetic human-approved contribution", "contribution_type": "potential_task"}

class ReviewTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.db = Path(self.temp.name) / "intake.sqlite"
        self.store = Store(self.db)
        self.grants = load_grants({"SHIPGLOWS_REVIEW_INTAKE_GRANTS": json.dumps([{"token_env": "SYNTHETIC_TOKEN", "project_ids": ["shipglows"]}]), "SYNTHETIC_TOKEN": TOKEN})
        self.api = IntakeAPI(self.store, self.grants)

    def test_concurrent_replay_conflict_and_restart(self):
        value = fixture()
        def send(_):
            # Independent SQLite connections and Store instances.
            return Store(self.db).create("SYNTHETIC_TOKEN", "shipglows", value)
        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(send, range(16)))
        self.assertEqual(len({r["intake_id"] for r in results}), 1)
        replay = Store(self.db).create("SYNTHETIC_TOKEN", "shipglows", value)
        self.assertEqual(replay, results[0])
        with self.assertRaises(IntakeError) as error:
            self.store.create("SYNTHETIC_TOKEN", "shipglows", {**value, "summary": "changed"})
        self.assertEqual((error.exception.status,error.exception.code), (409,"idempotency_conflict"))
        self.assertIsNone(self.store.get("OTHER_ACTOR", "shipglows", value["client_intake_id"]))
        self.assertIsNone(self.store.get("SYNTHETIC_TOKEN", "other", value["client_intake_id"]))

    def test_api_rights_receipts_and_missing(self):
        value = fixture()
        status, receipt = self.api.handle("POST", PATH, "Bearer " + TOKEN, json.dumps(value).encode())
        self.assertEqual(status, 200)
        self.assertEqual(receipt["state"], "pending_review")
        self.assertEqual(receipt["schema_version"], 1)
        self.assertEqual(self.api.handle("GET", PATH + "/" + value["client_intake_id"], "Bearer " + TOKEN)[1], receipt)
        self.assertEqual(len(self.api.handle("GET", PATH + "?limit=1", "Bearer " + TOKEN)[1]), 1)
        missing = str(uuid4())
        status, response = self.api.handle("GET", PATH + "/" + missing, "Bearer " + TOKEN)
        self.assertEqual(status, 404)
        self.assertEqual(response["detail"], {"code": "intake_not_found", "schema_version": 1, "project_id": "shipglows", "client_intake_id": missing})
        for path, auth, status in [(PATH, "Bearer wrong",401),(PATH.replace("shipglows", "other"),"Bearer " + TOKEN,403)]:
            with self.assertRaises(IntakeError) as error:
                self.api.handle("GET", path, auth)
            self.assertEqual(error.exception.status,status)

    def test_payload_and_grant_bounds(self):
        value = fixture()
        for update in [{"raw_body": "PRIVATE_MARKER"}, {"summary": " "}, {"summary": "x" * 4001}, {"confidence": True}, {"confidence": float("nan")}, {"risks": ["x"] * 11}, {"client_intake_id": "bad"}, {"source_key": "subject"}]:
            with self.assertRaises(IntakeError):
                validate({**value, **update})
        with self.assertRaises(IntakeError):
            load_grants({"SHIPGLOWS_REVIEW_INTAKE_GRANTS": '[{"token_env":"TOKEN","project_ids":["shipglows"]}]', "TOKEN": "short"})
        for body in [b'{"summary":"PRIVATE_MARKER","summary":"duplicate"}', b'{"confidence":NaN}', b'not-json']:
            with self.assertRaises(IntakeError):
                self.api.handle("POST", PATH, "Bearer " + TOKEN, body)
        self.assertEqual(self.store.list("SYNTHETIC_TOKEN", "shipglows"), [])

    def test_handler_auth_before_body_and_redacted_error(self):
        handler_class = handler_factory(self.api)
        instance = handler_class.__new__(handler_class)
        instance.command, instance.path = "POST", PATH
        instance.headers = {"Authorization": "Bearer wrong", "Content-Type": "application/json", "Content-Length": "14"}
        instance.rfile = io.BytesIO(b"PRIVATE_MARKER")
        captured = []
        instance._reply = lambda status, payload: captured.append((status,payload))
        instance._handle()
        self.assertEqual(instance.rfile.tell(), 0)
        self.assertEqual(captured[0][0], 401)
        instance.headers["Authorization"] = "Bearer " + TOKEN
        instance.headers["Content-Length"] = str(len(b"PRIVATE_MARKER"))
        instance._handle()
        self.assertEqual(captured[-1], (422,{"detail":{"code":"invalid_intake"}}))
        self.assertNotIn("PRIVATE_MARKER", str(captured))

if __name__ == "__main__":
    unittest.main()
