"""Opt-in loopback-only private human review intake (stdlib, no email actions)."""
from __future__ import annotations
import argparse
import hashlib
import hmac
import json
import math
import os
import re
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit
from uuid import UUID, uuid4

MAX_BODY = 65536
TYPES = {"newsletter_inspiration", "thematic_source", "potential_task", "other"}

class IntakeError(Exception):
    def __init__(self, status, code):
        self.status, self.code = status, code
        super().__init__(code)

def validate(value):
    required = {"client_intake_id", "source_key", "summary", "contribution_type"}
    allowed = required | {"justification", "confidence", "risks"}
    if not isinstance(value, dict) or not required <= value.keys() or value.keys() - allowed:
        raise IntakeError(422, "invalid_intake")
    try:
        client_id = str(UUID(value["client_intake_id"]))
    except (ValueError, TypeError, AttributeError):
        raise IntakeError(422, "invalid_intake") from None
    if not isinstance(value["source_key"], str) or not re.fullmatch(r"[a-f0-9]{64}", value["source_key"]):
        raise IntakeError(422, "invalid_intake")
    summary = value["summary"]
    justification = value.get("justification", "")
    risks = value.get("risks", [])
    confidence = value.get("confidence")
    if not isinstance(summary, str) or not summary.strip() or not 1 <= len(summary) <= 4000:
        raise IntakeError(422, "invalid_intake")
    if not isinstance(justification, str) or len(justification) > 2000:
        raise IntakeError(422, "invalid_intake")
    if not isinstance(value["contribution_type"], str) or value["contribution_type"] not in TYPES:
        raise IntakeError(422, "invalid_intake")
    if not isinstance(risks, list) or len(risks) > 10 or any(not isinstance(r, str) or len(r) > 500 for r in risks):
        raise IntakeError(422, "invalid_intake")
    if confidence is not None and (type(confidence) not in {int, float} or not math.isfinite(confidence) or not 0 <= confidence <= 1):
        raise IntakeError(422, "invalid_intake")
    return client_id, {"source_key": value["source_key"], "summary": summary,
                       "contribution_type": value["contribution_type"], "justification": justification,
                       "confidence": float(confidence) if confidence is not None else None, "risks": risks}


def load_grants(env):
    try:
        rows = json.loads(env.get("SHIPGLOWS_REVIEW_INTAKE_GRANTS", "[]"))
        if not isinstance(rows, list) or not rows:
            raise ValueError()
        grants = []
        seen = set()
        for row in rows:
            if not isinstance(row, dict) or set(row) != {"token_env", "project_ids"}:
                raise ValueError()
            key, projects = row["token_env"], row["project_ids"]
            if not isinstance(key, str) or not re.fullmatch(r"[A-Z][A-Z0-9_]{0,127}", key) or key in seen:
                raise ValueError()
            token = env.get(key, "")
            if not isinstance(token, str) or not 32 <= len(token) <= 512 or not token.isascii() or any(c.isspace() for c in token):
                raise ValueError()
            if not isinstance(projects, list) or not projects or any(not isinstance(p, str) or not re.fullmatch(r"[A-Za-z0-9_-]{1,128}", p) for p in projects):
                raise ValueError()
            if any(hmac.compare_digest(token, previous[1]) for previous in grants):
                raise ValueError()
            grants.append((key, token, frozenset(projects)))
            seen.add(key)
        return grants
    except (ValueError, TypeError):
        raise IntakeError(503, "grant_configuration_unavailable") from None


class Store:
    def __init__(self, path):
        self.path = str(path)
        with self.connect() as db:
            db.execute("PRAGMA journal_mode=WAL")
            db.execute("CREATE TABLE IF NOT EXISTS review_intake (actor TEXT NOT NULL, project_id TEXT NOT NULL, client_id TEXT NOT NULL, intake_id TEXT NOT NULL UNIQUE, created_at TEXT NOT NULL, payload TEXT NOT NULL, payload_hash TEXT NOT NULL, PRIMARY KEY(actor,project_id,client_id))")

    @contextmanager
    def connect(self):
        db = sqlite3.connect(self.path, timeout=15)
        try:
            db.execute("PRAGMA busy_timeout=15000")
            with db:
                yield db
        finally:
            db.close()

    @staticmethod
    def receipt(row):
        return {"schema_version": 1, "client_intake_id": row[0], "intake_id": row[1], "project_id": row[2], "state": "pending_review", "created_at": row[3]}

    def create(self, actor, project, value):
        client, payload = validate(value)
        serialized = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True, allow_nan=False)
        digest = hashlib.sha256(serialized.encode()).hexdigest()
        with self.connect() as db:
            db.execute("BEGIN IMMEDIATE")
            db.execute("INSERT INTO review_intake (actor,project_id,client_id,intake_id,created_at,payload,payload_hash) VALUES (?,?,?,?,?,?,?) ON CONFLICT(actor,project_id,client_id) DO NOTHING", (actor, project, client, str(uuid4()), datetime.now(timezone.utc).isoformat(), serialized, digest))
            row = db.execute("SELECT client_id,intake_id,project_id,created_at,payload,payload_hash FROM review_intake WHERE actor=? AND project_id=? AND client_id=?", (actor, project, client)).fetchone()
            if row[5] != digest:
                raise IntakeError(409, "idempotency_conflict")
            return self.receipt(row)

    def get(self, actor, project, client):
        with self.connect() as db:
            row = db.execute("SELECT client_id,intake_id,project_id,created_at FROM review_intake WHERE actor=? AND project_id=? AND client_id=?", (actor, project, client)).fetchone()
            return self.receipt(row) if row else None

    def list(self, actor, project, limit=50, offset=0):
        with self.connect() as db:
            rows = db.execute("SELECT client_id,intake_id,project_id,created_at,payload FROM review_intake WHERE actor=? AND project_id=? ORDER BY created_at,intake_id LIMIT ? OFFSET ?", (actor, project, limit, offset)).fetchall()
            return [{**self.receipt(row), **json.loads(row[4])} for row in rows]


class IntakeAPI:
    def __init__(self, store, grants):
        self.store, self.grants = store, grants

    def authorize(self, authorization, project):
        token = authorization[7:] if isinstance(authorization, str) and authorization.startswith("Bearer ") else ""
        if not token or len(token) > 512 or not token.isascii():
            raise IntakeError(401, "unauthenticated")
        actor = None
        rights = frozenset()
        for key, expected, projects in self.grants:
            if hmac.compare_digest(token, expected):
                actor, rights = key, projects
        if actor is None:
            raise IntakeError(401, "unauthenticated")
        if project not in rights:
            raise IntakeError(403, "forbidden")
        return actor

    def resolve(self, path, authorization):
        parsed = urlsplit(path)
        match = re.fullmatch(r"/api/projects/([A-Za-z0-9_-]{1,128})/review-intake(?:/([0-9a-fA-F-]{36}))?", parsed.path)
        if not match:
            raise IntakeError(404, "route_not_found")
        project, client = match.groups()
        actor = self.authorize(authorization, project)
        if client:
            try:
                client = str(UUID(client))
            except ValueError:
                raise IntakeError(422, "invalid_intake") from None
        return actor, project, client, parsed.query

    def handle(self, method, path, authorization, body=b""):
        actor, project, client, query = self.resolve(path, authorization)
        if method == "POST" and not client and not query:
            if len(body) > MAX_BODY:
                raise IntakeError(413, "payload_too_large")
            def pairs(items):
                result = {}
                for key, value in items:
                    if key in result:
                        raise ValueError()
                    result[key] = value
                return result
            try:
                value = json.loads(body.decode("utf-8"), object_pairs_hook=pairs, parse_constant=lambda _: (_ for _ in ()).throw(ValueError()))
            except (ValueError, UnicodeError, RecursionError):
                raise IntakeError(422, "invalid_intake") from None
            return 200, self.store.create(actor, project, value)
        if method == "GET" and client and not query:
            receipt = self.store.get(actor, project, client)
            if receipt is None:
                return 404, {"detail": {"code": "intake_not_found", "schema_version": 1, "client_intake_id": client, "project_id": project}}
            return 200, receipt
        if method == "GET" and not client:
            args = parse_qs(query, keep_blank_values=True)
            try:
                if args.keys() - {"limit", "offset"} or any(len(v) != 1 for v in args.values()):
                    raise ValueError()
                limit, offset = int(args.get("limit", ["50"])[0]), int(args.get("offset", ["0"])[0])
                if not 1 <= limit <= 100 or not 0 <= offset <= 1000000:
                    raise ValueError()
            except ValueError:
                raise IntakeError(422, "invalid_intake") from None
            return 200, self.store.list(actor, project, limit, offset)
        raise IntakeError(405, "method_not_allowed")


def handler_factory(api):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_):
            pass

        def _reply(self, status, payload):
            encoded = json.dumps(payload, separators=(",", ":")).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(encoded)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(encoded)
            self.close_connection = True

        def send_error(self, code, message=None, explain=None):
            self._reply(code, {"detail": {"code": "invalid_http_request"}})

        def _handle(self):
            try:
                api.resolve(self.path, self.headers.get("Authorization"))
                body = b""
                if self.command == "POST":
                    if self.headers.get("Transfer-Encoding"):
                        raise IntakeError(400, "invalid_intake")
                    if self.headers.get("Content-Type", "").split(";")[0].strip().lower() != "application/json":
                        raise IntakeError(415, "json_required")
                    try:
                        length = int(self.headers.get("Content-Length", ""))
                    except ValueError:
                        raise IntakeError(411, "length_required") from None
                    if not 0 <= length <= MAX_BODY:
                        raise IntakeError(413, "payload_too_large")
                    body = self.rfile.read(length)
                    if len(body) != length:
                        raise IntakeError(400, "invalid_intake")
                status, payload = api.handle(self.command, self.path, self.headers.get("Authorization"), body)
            except IntakeError as exc:
                status, payload = exc.status, {"detail": {"code": exc.code}}
            except Exception:
                status, payload = 503, {"detail": {"code": "review_intake_unavailable"}}
            try:
                self._reply(status, payload)
            except (BrokenPipeError, ConnectionResetError):
                pass
        do_POST = _handle
        do_GET = _handle
    return Handler


class PrivateServer(ThreadingHTTPServer):
    daemon_threads = True
    def handle_error(self, request, client_address):
        pass  # Never emit exception locals or request data.
    def get_request(self):
        request, address = super().get_request()
        request.settimeout(15)
        return request, address


def private_path():
    base = Path(os.environ["LOCALAPPDATA"]) / "ShipGlows/review-intake" if os.name == "nt" and os.getenv("LOCALAPPDATA") else Path.home() / ".shipglows/private/review-intake"
    base.mkdir(parents=True, mode=0o700, exist_ok=True)
    if os.name != "nt":
        base.chmod(0o700)
    return base / "intake.sqlite"


def main():
    parser = argparse.ArgumentParser(description="Opt-in loopback private project review intake")
    parser.add_argument("--port", type=int, default=8769)
    args = parser.parse_args()
    if os.getenv("SHIPGLOWS_REVIEW_INTAKE_ENABLED", "").lower() != "true":
        raise SystemExit("review_intake_disabled")
    if not 1 <= args.port <= 65535:
        raise SystemExit("invalid_port")
    try:
        grants = load_grants(os.environ)
        if os.name != "nt":
            os.umask(0o077)
        api = IntakeAPI(Store(private_path()), grants)
        with PrivateServer(("127.0.0.1", args.port), handler_factory(api)) as server:
            server.serve_forever()
    except KeyboardInterrupt:
        pass
    except Exception:
        raise SystemExit("review_intake_startup_unavailable") from None

if __name__ == "__main__":
    main()
