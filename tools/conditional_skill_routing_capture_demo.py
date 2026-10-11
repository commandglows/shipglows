"""Synthetic loopback HTTP capture demonstration; no model/runtime/credentials.

Run: python tools/conditional_skill_routing_capture_demo.py --out NEW_DIRECTORY
Only creates NEW_DIRECTORY. Refuses overwrite. All usage is invented.
"""
import argparse
import hashlib
import json
from pathlib import Path
import socket
import socketserver
import threading
import time

MAX_BODY = 32768
MAX_HEADER = 8192
MAX_REQUESTS = 40
MAX_TOTAL = 1024 * 1024
TIMEOUT = 0.3
DEADLINE = 1.0
INSTRUCTION = "SYNTHETIC instruction: fixture only; public output requires draft check."
PRIVATE = "SYNTHETIC_PRIVATE_RECORD"


def encoded(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


class Store:
    def __init__(self, root):
        self.root = root
        self.blobs = {}
        self.lock = threading.Lock()

    def put(self, name, raw):
        with self.lock:
            with (self.root / name).open("xb") as stream:
                stream.write(raw)
                stream.flush()
            self.blobs[name] = {"bytes": len(raw), "sha256": digest(raw)}
        return name

    def document(self, name, value):
        return self.put(name, encoded(value))


def header_block(stream):
    """Admission bounds apply before parsing any header value."""
    lines, total = [], 0
    while True:
        line = stream.readline(MAX_HEADER + 1)
        total += len(line)
        if total > MAX_HEADER or not line:
            raise ValueError("header admission limit or incomplete headers")
        lines.append(line)
        if line == b"\r\n":
            return lines


def headers(lines):
    result = {}
    for line in lines:
        key, value = line.decode("ascii").strip().split(":", 1)
        key = key.lower()
        if key in result:
            raise ValueError("duplicate header")
        result[key] = value.strip()
    return result


def safe_headers(values):
    allow = {"host", "content-type", "content-length", "connection", "retry-after",
             "x-causal-id", "x-parent-id", "x-tool-call-id", "authorization"}
    return {k: "[REDACTED]" if k == "authorization" else v
            for k, v in values.items() if k in allow}


def response_wire(status, body, causal, extra=None, declared_length=None):
    values = {"content-type": "text/event-stream" if status == 200 else "application/json",
              "content-length": str(len(body) if declared_length is None else declared_length),
              "connection": "close", "x-causal-id": causal}
    values.update(extra or {})
    prefix = f"HTTP/1.1 {status} Synthetic\r\n".encode()
    prefix += b"".join(f"{k}: {v}\r\n".encode() for k, v in values.items()) + b"\r\n"
    return prefix, values


def sse(result):
    events = [{"event": "tool_result", "data": result},
              {"event": "usage", "data": {"label": "fictional_synthetic_usage",
                  "input_tokens": 7, "output_tokens": 3}},
              {"event": "done", "data": {"synthetic": True}}]
    return b"".join(b"event: " + e["event"].encode() + b"\ndata: " + encoded(e["data"])
                    + b"\n\n" for e in events)


def run(root):
    start = time.monotonic_ns()
    store = Store(root)
    source = Path(__file__).read_bytes()
    store.put("source-snapshot.py", source)
    state = {"count": 0, "bytes": 0, "seen": set(), "last": None,
             "grant": False, "read": False, "checked": False, "draft_sha256": None,
             "epoch": 0, "status_epoch": -1, "capability_epoch": -1}
    receipts, checks, calls = [], {}, []
    lock = threading.Lock()

    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            self.request.settimeout(TIMEOUT)
            begin = time.monotonic_ns()
            receipt = {"boundary": "synthetic_loopback_server", "started_ns": begin}
            raw, status, result = b"", 400, {"error": "invalid request"}
            causal = "unparsed"
            try:
                lines = header_block(self.rfile)
                method, path, version = lines[0].decode("ascii").strip().split(" ")
                values = headers(lines[1:-1])
                causal = values.get("x-causal-id", "unparsed")
                if not causal.startswith("exchange-") or not causal[9:].isdigit():
                    raise ValueError("invalid causal id")
                receipt.update(method=method, path=path, destination=list(self.server.server_address),
                               headers=safe_headers(values), causal_id=causal)
                length = int(values.get("content-length", "-1"))
                if method != "POST" or path != "/v1/synthetic" or version != "HTTP/1.1" or length < 0:
                    raise ValueError("invalid synthetic endpoint")
                with lock:
                    if causal in state["seen"]:
                        raise ValueError("duplicate causal id")
                    state["seen"].add(causal)
                    previous_causal = state["last"]
                    state["last"] = causal
                    state["count"] += 1
                    count = state["count"]
                    exceeds_total = state["bytes"] + length > MAX_TOTAL
                    if count <= MAX_REQUESTS and length <= MAX_BODY and not exceeds_total:
                        state["bytes"] += length
                admission = (429 if count > MAX_REQUESTS else
                             413 if length > MAX_BODY or exceeds_total else None)
                receipt.update(admission_status=admission, declared_request_bytes=length)
                # At most MAX_BODY+1 bytes retained, including the oversize witness.
                wanted = 0 if admission == 429 or exceeds_total else min(length, MAX_BODY + 1)
                while len(raw) < wanted:
                    if (time.monotonic_ns() - begin) / 1e9 > DEADLINE:
                        raise socket.timeout("request total deadline")
                    chunk = self.rfile.read1(min(4096, wanted - len(raw)))
                    if not chunk:
                        break
                    store.put(causal + f".request.chunk-{len(raw):06d}.bin", chunk)
                    raw += chunk
                store.put(causal + ".server-request.bin", raw)  # BEFORE JSON parsing.
                receipt["body_sha256"] = digest(raw)
                if admission == 413:
                    status, result = 413, {"error": "body admission limit"}
                elif admission == 429:
                    status, result = 429, {"error": "request count admission limit"}
                elif len(raw) != length:
                    status, result = 400, {"error": "incomplete request body"}
                else:
                    request = json.loads(raw)
                    if request.get("tool_call_id") != "call-" + causal or request.get("parent_id") != previous_causal:
                        raise ValueError("causal parent or tool call mismatch")
                    action = request["action"]
                    receipt["action"] = action
                    if action == "retry" and request["attempt"] == 1:
                        status, result = 503, {"error": "synthetic transient failure"}
                    else:
                        status = 200
                        if action == "tool_denied": result = {"status": "denied", "tool": "native_shell"}
                        elif action == "tool_corrected": result = {"status": "ok", "tool": "fixture_read"}
                        elif action == "partial_read": result = {"status": "partial", "text": "first", "extent": "partial", "span": [0, 5], "source_sha256": digest(b"first second"), "span_sha256": digest(b"first")}
                        elif action == "full_read": result = {"status": "ok", "text": "first second", "extent": "full", "span": [0, 12], "source_sha256": digest(b"first second"), "span_sha256": digest(b"first second")}
                        elif action == "grant":
                            state["grant"] = True
                            state.update(epoch=state["epoch"] + 1, status_epoch=-1, capability_epoch=-1)
                            result = {"status": "granted", "scope": "synthetic_record"}
                        elif action == "private_read":
                            state["read"] = state["grant"] and state["status_epoch"] == state["epoch"] and state["capability_epoch"] == state["epoch"]
                            result = ({"status": "ok", "text": PRIVATE} if state["read"] else {"status": "denied"})
                        elif action == "invalidate":
                            state.update(grant=False, read=False, checked=False)
                            state.update(epoch=state["epoch"] + 1, status_epoch=-1, capability_epoch=-1)
                            result = {"status": "invalidated"}
                        elif action == "compaction":
                            result = {"status": "compacted", "synthetic": True,
                                      "retained_instruction_sha256": digest(INSTRUCTION.encode())}
                        elif action == "status":
                            state["status_epoch"] = state["epoch"]
                            result = {"grant": state["grant"], "read": state["read"]}
                        elif action == "capability":
                            state["capability_epoch"] = state["epoch"]
                            result = {"can_read": state["grant"], "synthetic": True}
                        elif action == "draft_check":
                            state["checked"] = PRIVATE not in request["draft"]
                            state["draft_sha256"] = digest(request["draft"].encode())
                            result = {"status": "safe" if state["checked"] else "blocked", "draft_sha256": state["draft_sha256"]}
                        elif action == "visible_response":
                            result = ({"status": "visible", "text": request["draft"]}
                                      if state["checked"] and PRIVATE not in request["draft"] and digest(request["draft"].encode()) == state["draft_sha256"] else {"status": "denied"})
                        elif action in ("retry", "interrupted", "timeout", "iteration"):
                            result = {"status": "ok", "action": action}
                        elif action == "sse_error": result = {"error": "synthetic SSE failure"}
                        elif action == "response_overflow": result = {"status": "oversize_response"}
                        else: raise ValueError("unknown synthetic action")
                result["tool_call_id"] = "call-" + causal
                body = sse(result) if status == 200 else encoded(result)
                if receipt.get("action") == "sse_error":
                    body = b"event: error\ndata: " + encoded(result) + b"\n\n"
                elif receipt.get("action") == "response_overflow":
                    body = b"x" * (MAX_BODY + 1)
                store.put(causal + ".server-response-intended.bin", body)
                declared = len(body) + 100 if receipt.get("action") == "interrupted" else None
                prefix, response_headers = response_wire(status, body, causal,
                    {"retry-after": "0"} if status == 503 else None, declared)
                receipt.update(status=status, response_headers=safe_headers(response_headers),
                               response_intended_sha256=digest(body), expected_result=result)
                self.wfile.write(prefix)
                if receipt.get("action") in ("interrupted", "timeout"):
                    sent = body[:24]
                    store.put(causal + ".server-response-sent.bin", sent)
                    self.wfile.write(sent)
                    self.wfile.flush()
                    if receipt["action"] == "timeout": time.sleep(TIMEOUT * 2)
                else:
                    store.put(causal + ".server-response-sent.bin", body)
                    for frame in body.splitlines(keepends=True):
                        self.wfile.write(frame)
                    self.wfile.flush()
            except (ValueError, KeyError, socket.timeout, OSError) as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
                if causal != "unparsed" and not (root / (causal + ".server-request.bin")).exists():
                    store.put(causal + ".server-request.bin", raw)
                if causal != "unparsed" and not (root / (causal + ".server-response-intended.bin")).exists():
                    failure = {"error": "malformed_request", "tool_call_id": "call-" + causal}
                    body = encoded(failure)
                    prefix, response_headers = response_wire(400, body, causal)
                    store.put(causal + ".server-response-intended.bin", body)
                    store.put(causal + ".server-response-sent.bin", body)
                    receipt.update(status=400, response_headers=safe_headers(response_headers), expected_result=failure)
                    try:
                        self.wfile.write(prefix + body)
                        self.wfile.flush()
                    except OSError: pass
            finally:
                receipt["ended_ns"] = time.monotonic_ns()
                with lock: receipts.append(receipt)

    class Server(socketserver.ThreadingTCPServer):
        allow_reuse_address = False
        daemon_threads = False

    server = Server(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    host, port = server.server_address
    if host != "127.0.0.1": raise RuntimeError("non-loopback destination refused")

    def exchange(action, expected, **fields):
        causal = f"exchange-{len(calls) + 1:03d}"
        if expected != {"partial": True}:
            expected["tool_call_id"] = "call-" + causal
        request = {"action": action, "tool_call_id": "call-" + causal,
                   "parent_id": calls[-1]["causal_id"] if calls else None,
                   "messages": [{"role": "system", "content": INSTRUCTION},
                                {"role": "user", "content": "synthetic only"}],
                   "tools": [{"name": "fixture_read", "synthetic": True}], **fields}
        if calls and "events" in calls[-1]:
            request["messages"].append({"role": "tool", "tool_call_id": calls[-1]["tool_call_id"],
                "content": encoded(calls[-1]["events"][0]["data"]).decode()})
        if action in ("partial_read", "full_read"):
            span_text = b"first" if action == "partial_read" else b"first second"
            expected.update(span=[0, len(span_text)], source_sha256=digest(b"first second"), span_sha256=digest(span_text))
        if action == "draft_check": expected["draft_sha256"] = digest(fields["draft"].encode())
        raw = fields.pop("oversize_raw", None) if "oversize_raw" in fields else None
        if raw is None: raw = encoded(request)
        store.put(causal + ".client-request.bin", raw)
        store.document(causal + ".expected-result.json", expected)
        start_call = time.monotonic_ns()
        record = {"causal_id": causal, "parent_id": request["parent_id"], "tool_call_id": request["tool_call_id"],
                  "action": action, "started_ns": start_call, "destination": [host, port],
                  "request_sha256": digest(raw), "response_chunks": []}
        received = b""
        try:
            with socket.create_connection((host, port), timeout=TIMEOUT) as connection:
                connection.settimeout(TIMEOUT)
                prefix = (f"POST /v1/synthetic HTTP/1.1\r\nHost: {host}:{port}\r\n"
                          f"Content-Type: application/json\r\nContent-Length: {len(raw)}\r\n"
                          f"X-Causal-ID: {causal}\r\nAuthorization: SYNTHETIC-NOT-A-KEY\r\nConnection: close\r\n\r\n").encode()
                connection.sendall(prefix + raw)
                stream = connection.makefile("rb")
                lines = header_block(stream)
                record["status"] = int(lines[0].split()[1])
                values = headers(lines[1:-1])
                record["headers"] = safe_headers(values)
                while len(received) < int(values["content-length"]):
                    if (time.monotonic_ns() - start_call) / 1e9 > DEADLINE:
                        raise socket.timeout("response total deadline")
                    chunk = stream.read1(min(4096, int(values["content-length"]) - len(received), MAX_BODY + 1 - len(received)))
                    if not chunk:
                        record["error"] = "incomplete_response"
                        break
                    name = causal + f".response.chunk-{len(received):06d}.bin"
                    store.put(name, chunk)  # BEFORE any SSE/JSON parsing.
                    record["response_chunks"].append({"blob": name, "received_ns": time.monotonic_ns()})
                    received += chunk
                    if len(received) > MAX_BODY:
                        raise ValueError("response admission limit; bounded witness retained")
        except (socket.timeout, OSError, ValueError) as exc:
            record["error"] = type(exc).__name__ + ": " + str(exc)
        store.put(causal + ".client-response.bin", received)
        record.update(ended_ns=time.monotonic_ns(), response_sha256=digest(received))
        if "error" not in record:
            if record["status"] == 200:
                frames = received.split(b"\n\n")
                parsed = []
                for index, frame in enumerate(frames):
                    if not frame: continue
                    store.put(causal + f".sse-frame-{index:03d}.bin", frame + b"\n\n")
                    event, data = frame.split(b"\n", 1)
                    parsed.append({"event": event[7:].decode(), "data": json.loads(data[6:])})
                record["events"] = parsed
                record["stream_error"] = any(e["event"] == "error" for e in parsed)
                actual = parsed[0]["data"]
            else: actual = json.loads(received)
            record["semantic_match"] = actual == expected
        else: record["semantic_match"] = expected == {"partial": True} and bool(received)
        calls.append(record)
        return record

    try:
        for iteration in (1, 2): exchange("iteration", {"status": "ok", "action": "iteration"}, iteration=iteration)
        for action, expected in [
            ("tool_denied", {"status": "denied", "tool": "native_shell"}),
            ("tool_corrected", {"status": "ok", "tool": "fixture_read"}),
            ("partial_read", {"status": "partial", "text": "first", "extent": "partial"}),
            ("full_read", {"status": "ok", "text": "first second", "extent": "full"}),
            ("grant", {"status": "granted", "scope": "synthetic_record"}),
            ("private_read", {"status": "denied"}),
            ("status", {"grant": True, "read": False}),
            ("private_read", {"status": "denied"}),
            ("capability", {"can_read": True, "synthetic": True}),
            ("private_read", {"status": "ok", "text": PRIVATE}),
            ("status", {"grant": True, "read": True}),
            ("invalidate", {"status": "invalidated"}),
            ("status", {"grant": False, "read": False}),
            ("capability", {"can_read": False, "synthetic": True}),
            ("private_read", {"status": "denied"}),
            ("grant", {"status": "granted", "scope": "synthetic_record"}),
            ("private_read", {"status": "denied"}),
            ("status", {"grant": True, "read": False}),
            ("private_read", {"status": "denied"}),
            ("capability", {"can_read": True, "synthetic": True}),
            ("private_read", {"status": "ok", "text": PRIVATE}),
            ("compaction", {"status": "compacted", "synthetic": True,
                            "retained_instruction_sha256": digest(INSTRUCTION.encode())}),
        ]: exchange(action, expected)
        exchange("draft_check", {"status": "blocked"}, draft=PRIVATE)
        exchange("visible_response", {"status": "denied"}, draft=PRIVATE)
        exchange("draft_check", {"status": "safe"}, draft="Public synthetic summary")
        exchange("visible_response", {"status": "denied"}, draft="Changed draft")
        exchange("visible_response", {"status": "visible", "text": "Public synthetic summary"}, draft="Public synthetic summary")
        exchange("retry", {"error": "synthetic transient failure"}, attempt=1)
        exchange("retry", {"status": "ok", "action": "retry"}, attempt=2)
        exchange("interrupted", {"partial": True})
        exchange("timeout", {"partial": True})
        exchange("invalid_json", {"error": "malformed_request"}, oversize_raw=b"{")
        exchange("sse_error", {"error": "synthetic SSE failure"})
        exchange("response_overflow", {"partial": True})
        exchange("oversize", {"error": "body admission limit"}, oversize_raw=b"x" * (MAX_BODY + 1))
        while len(calls) < MAX_REQUESTS: exchange("iteration", {"status": "ok", "action": "iteration"})
        exchange("iteration", {"error": "request count admission limit"})
    finally:
        server.shutdown()
        thread.join(timeout=2)
        server.server_close()
    # Independent durable byte comparisons after all handlers have completed.
    for call in calls:
        causal = call["causal_id"]
        receipt = next(r for r in receipts if r.get("causal_id") == causal)
        expected_capture = (b"" if receipt["admission_status"] == 429 else
                            (root / (causal + ".client-request.bin")).read_bytes())
        checks[causal + "_request_capture_exact"] = expected_capture == (root / (causal + ".server-request.bin")).read_bytes()
        checks[causal + "_response_exact"] = ((root / (causal + ".client-response.bin")).read_bytes() ==
                                               (root / (causal + ".server-response-sent.bin")).read_bytes())
        checks[causal + "_semantic"] = call["semantic_match"]
        if "error" not in call:
            expected_raw = (root / (causal + ".expected-result.json")).read_bytes()
            expected_body = (b"event: error\ndata: " + expected_raw + b"\n\n" if call["action"] == "sse_error" else sse(json.loads(expected_raw))) if call["status"] == 200 else expected_raw
            checks[causal + "_expected_body_exact"] = expected_body == (root / (causal + ".client-response.bin")).read_bytes()
            checks[causal + "_status"] = call["status"] == receipt["status"]
    checks["instructions_repeated"] = all(json.loads((root / (c["causal_id"] + ".client-request.bin")).read_bytes())["messages"][0]["content"] == INSTRUCTION for c in calls[:2])
    checks["headers_auth_redacted"] = all(r.get("headers", {}).get("authorization") == "[REDACTED]" for r in receipts)
    retry_calls = [c for c in calls if c["action"] == "retry"]
    checks["http503_retry"] = [c["status"] for c in retry_calls] == [503, 200]
    checks["partial_stream_retained"] = all(c.get("error") and c["response_chunks"] for c in calls if c["action"] in ("interrupted", "timeout"))
    checks["oversize_failclosed"] = next(c for c in calls if c["action"] == "oversize")["status"] == 413
    checks["count_failclosed"] = calls[-1]["status"] == 429
    linked = []
    for previous, following in zip(calls, calls[1:]):
        if "events" not in previous or following["action"] in ("oversize", "invalid_json") or following["status"] == 429: continue
        following_request = json.loads((root / (following["causal_id"] + ".server-request.bin")).read_bytes())
        message = following_request["messages"][-1]
        linked.append(message["tool_call_id"] == previous["tool_call_id"] and
                      message["content"].encode() == encoded(previous["events"][0]["data"]))
    checks["callback_payload_next_request_exact"] = bool(linked) and all(linked)
    checks["invalid_json_failclosed"] = next(c for c in calls if c["action"] == "invalid_json")["status"] == 400
    error_call = next(c for c in calls if c["action"] == "sse_error")
    checks["sse_error_without_done"] = error_call["stream_error"] and not any(e["event"] == "done" for e in error_call["events"])
    overflow = next(c for c in calls if c["action"] == "response_overflow")
    checks["response_overflow_retained"] = "response admission limit" in overflow.get("error", "") and (root / (overflow["causal_id"] + ".client-response.bin")).stat().st_size == MAX_BODY + 1
    store.document("server-receipts.json", receipts)
    store.document("client-exchanges.json", calls)
    checks["blob_hashes"] = all(digest((root / name).read_bytes()) == meta["sha256"] for name, meta in store.blobs.items())
    summary = {"schema_version": 1, "synthetic_only": True, "passed": all(checks.values()),
        "source_sha256": digest(source),
        "duration_ns": time.monotonic_ns() - start, "checks": checks, "blobs": store.blobs.copy(),
        "bounds": {"body_bytes": MAX_BODY, "header_bytes": MAX_HEADER, "requests": MAX_REQUESTS,
                   "total_request_bytes": MAX_TOTAL, "socket_timeout_seconds": TIMEOUT,
                   "exchange_deadline_seconds": DEADLINE},
        "limits": ["No model, Codex/OpenCode, provider authentication or real provider integration",
                   "Synthetic-only application actions and fictional usage; no OS confinement proof",
                   "Allowlisted headers; authorization redacted; no raw secret headers retained",
                   "Bounded scripted clients only; no adversarial multi-client/OS admission proof",
                   "A maximum one-byte oversize witness is retained; rejected calls never parse task JSON",
                   "Count/aggregate rejection captures zero body bytes by design; client sender blob remains separate",
                   "Headers are normalized allowlist metadata, not exact raw TCP headers or TLS evidence",
                   "Loopback endpoint only; no external requests, environment or user-profile reads"]}
    store.document("summary.json", summary)
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=False, exist_ok=False)
    summary = run(args.out.resolve())
    print(json.dumps({"out": str(args.out.resolve()), "passed": summary["passed"],
                      "duration_seconds": summary["duration_ns"] / 1e9,
                      "summary_sha256": digest((args.out / "summary.json").read_bytes())}))
    raise SystemExit(0 if summary["passed"] else 1)


if __name__ == "__main__":
    main()
