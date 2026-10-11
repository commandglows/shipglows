"""Framed stdio bridge with an injected trusted-parent callback only.

No provider implementation, network calls or credential/environment reads. Place
ParentBridge outside the subject OS namespace; its callback and receipt key are
never serialized to the relay. A relay channel key authenticates framing, not
model behavior. A separate parent-only key signs receipts. Runtime OS placement,
provider authorization and callback cancellation require independent evidence.
"""
import base64
import hashlib
import hmac
import io
import json
import queue
import re
import struct
import threading
import time


class TransportError(ValueError):
    pass


def require(ok, message):
    if not ok:
        raise TransportError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def packed(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _pairs(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "duplicate JSON key")
        result[key] = value
    return result


def decoded(raw):
    require(type(raw) is bytes, "envelope must be bytes")
    try:
        return json.loads(raw.decode("utf-8"), object_pairs_hook=_pairs,
                          parse_constant=lambda _: (_ for _ in ()).throw(TransportError("nonfinite JSON")))
    except (UnicodeError, json.JSONDecodeError) as error:
        raise TransportError("invalid UTF8/JSON envelope") from error


def _key(key):
    require(type(key) is bytes and len(key) >= 32, "authentication key must contain at least 32 bytes")


def authenticated(value, key):
    _key(key)
    require(type(value) is dict and "auth" not in value, "invalid unsigned envelope")
    return {**value, "auth": hmac.new(key, packed(value), hashlib.sha256).hexdigest()}


def verify(value, key):
    _key(key)
    require(type(value) is dict and type(value.get("auth")) is str, "missing authentication")
    unsigned = {k: v for k, v in value.items() if k != "auth"}
    expected = hmac.new(key, packed(unsigned), hashlib.sha256).hexdigest()
    require(hmac.compare_digest(value["auth"], expected), "invalid authentication")
    return unsigned


def frame(raw, maximum=2 * 1024 * 1024):
    require(type(raw) is bytes and 0 < len(raw) <= maximum, "invalid/oversize frame")
    return struct.pack(">I", len(raw)) + raw


def read_frame(stream, maximum=2 * 1024 * 1024):
    """Exact bounded framing; caller must supervise blocking OS pipes externally."""
    def exact(n):
        data = bytearray()
        while len(data) < n:
            chunk = stream.read(n - len(data))
            require(type(chunk) is bytes, "nonbinary stream")
            if not chunk:
                break
            data.extend(chunk)
        return bytes(data)
    header = exact(4)
    if not header:
        return None
    require(len(header) == 4, "partial frame header")
    length = struct.unpack(">I", header)[0]
    require(0 < length <= maximum, "frame admission limit")
    raw = exact(length)
    require(len(raw) == length, "partial frame body")
    return raw


def make_request(request_id, endpoint, body, key, headers=None):
    require(type(body) is bytes, "request body must be bytes")
    return packed(authenticated({"version": 1, "id": request_id, "endpoint": endpoint,
                                 "headers": headers or {"content-type": "application/json"},
                                 "body_b64": base64.b64encode(body).decode("ascii"),
                                 "body_sha256": sha(body)}, key))


def read_response(raw, key, request_id):
    value = verify(decoded(raw), key)
    require(set(value) == {"version", "id", "status", "headers", "body_b64", "body_sha256"}
            and type(value["version"]) is int and value["version"] == 1 and value["id"] == request_id,
            "invalid response shape/identity")
    body = _body(value)
    require(type(value["status"]) is int and 100 <= value["status"] <= 599, "invalid response status")
    _headers(value["headers"], response=True)
    return {"status": value["status"], "headers": value["headers"], "body": body}


def _body(value):
    require(type(value.get("body_b64")) is str and type(value.get("body_sha256")) is str, "invalid body metadata")
    try:
        body = base64.b64decode(value["body_b64"], validate=True)
    except (ValueError, UnicodeError) as error:
        raise TransportError("invalid body base64") from error
    require(sha(body) == value["body_sha256"], "body hash mismatch")
    return body


def _headers(value, response=False):
    require(type(value) is dict, "headers must be an object")
    allowed = {"content-type", "x-request-id", "retry-after"} if response else {"content-type"}
    require(set(value) <= allowed and len(value) <= 3, "header outside sanitized allowlist")
    for name, text in value.items():
        require(type(text) is str and len(text) <= 256 and all(32 <= ord(c) <= 126 for c in text), "invalid header value")
    if not response:
        require(value == {"content-type": "application/json"}, "fixed JSON content type required")


class ToolResponsePolicy:
    """Complete frozen broker SSE validation before release, no JSON fallback.

    This profile accepts only the frozen synthetic broker schemas. A different
    provider profile requires a separately reviewed complete validator.
    """
    def __init__(self, allowed_tools):
        from tools.conditional_skill_routing_cli_broker_profile import NAMES
        require(type(allowed_tools) in (set, list, tuple) and allowed_tools
                and all(type(n) is str and n in NAMES for n in allowed_tools), "invalid frozen tool allowlist")
        self.allowed = set(allowed_tools)
        self.seen = set()

    def __call__(self, response):
        from tools.conditional_skill_routing_cli_broker_profile import gate_complete_sse
        require(response["status"] == 200 and response["headers"].get("content-type", "").split(";", 1)[0] == "text/event-stream",
                "only complete successful frozen broker SSE supported")
        try:
            gate = gate_complete_sse(response["body"], self.seen)
            calls = {}
            # Gate already verifies every added/done/completed identity and args.
            for block in response["body"][:-2].split(b"\n\n"):
                lines = block.split(b"\n")
                value = decoded(next(line[6:] for line in lines if line.startswith(b"data: ")))
                if value.get("type") == "response.output_item.done" and value["item"]["type"] == "function_call":
                    item = value["item"]
                    require(item["name"] in self.allowed, "tool outside delegated allowlist")
                    calls[item["call_id"]] = item["name"]
            self.seen.update(gate["call_ids"])
            return {"tool_calls": calls, "status": "allowed", "complete_gate": gate}
        except Exception:
            raise TransportError("complete frozen response policy rejected") from None


class ParentBridge:
    def __init__(self, endpoint, callback, *, channel_key, receipt_key,
                 callback_kind="mock", launch_authorized=False, response_policy=None,
                 max_requests=12, max_body=1024 * 1024, max_response=1024 * 1024,
                 total_body=12 * 1024 * 1024, total_response=12 * 1024 * 1024,
                 callback_timeout=5.0, session_timeout=75.0):
        require(type(endpoint) is str and re.fullmatch(r"[a-z0-9][a-z0-9_.-]{0,63}", endpoint), "fixed endpoint identity required")
        require(callable(callback), "injected parent callback required")
        _key(channel_key)
        _key(receipt_key)
        require(channel_key != receipt_key, "parent receipt key must be separate from relay key")
        require(callback_kind in ("mock", "live") and type(launch_authorized) is bool, "invalid launch posture")
        require(callback_kind != "live" or launch_authorized, "live launch not authorized")
        for limit in (max_requests, max_body, max_response, total_body, total_response):
            require(type(limit) is int and limit > 0, "positive integer budget required")
        for limit in (callback_timeout, session_timeout):
            require(type(limit) in (int, float) and 0 < limit <= 300, "bounded positive deadline required")
        self.endpoint, self.callback = endpoint, callback
        self.channel_key, self.receipt_key = channel_key, receipt_key
        self.callback_kind, self.launch_authorized = callback_kind, launch_authorized
        self.response_policy = response_policy
        self.max_requests, self.max_body, self.max_response = max_requests, max_body, max_response
        self.total_body, self.total_response = total_body, total_response
        self.callback_timeout = callback_timeout
        self.deadline = time.monotonic() + session_timeout
        self.seen = set()
        self.attempts = self.request_bytes = self.response_bytes = 0
        self.receipts = []
        self.retired = False
        self.lock = threading.Lock()

    def _receipt(self, value):
        record = {"sequence": len(self.receipts) + 1, "monotonic_ns": time.monotonic_ns(), **value,
                  "previous_receipt_sha256": sha(packed(self.receipts[-1])) if self.receipts else None}
        signed = authenticated(record, self.receipt_key)
        self.receipts.append(signed)
        return signed

    def _invoke(self, body, deadline):
        result = queue.Queue(maxsize=1)
        def work():
            try:
                result.put((True, self.callback(body, deadline)))
            except Exception as error:
                # Exception text can contain provider credentials. Keep only type/hash.
                result.put((False, {"exception_type": type(error).__name__, "exception_sha256": sha(str(error).encode("utf-8", errors="replace"))}))
        thread = threading.Thread(target=work, daemon=True)
        thread.start()
        remaining = max(0, deadline - time.monotonic())
        try:
            ok, value = result.get(timeout=remaining)
        except queue.Empty as error:
            self.retired = True
            raise TransportError("callback deadline; cancellation unproved") from error
        if time.monotonic() > deadline:
            self.retired = True
            raise TransportError("callback deadline; bridge permanently retired; cancellation unproved")
        if not ok:
            self._receipt({"status": "callback_error", **value, "response_released": False})
            raise TransportError("parent callback error; details hash-only")
        return value

    def handle(self, raw):
        with self.lock:
            started = time.monotonic_ns()
            provenance = {"raw_envelope_sha256": sha(raw) if type(raw) is bytes else None,
                          "raw_envelope_bytes": len(raw) if type(raw) is bytes else None,
                          "callback_kind": self.callback_kind, "launch_authorized": self.launch_authorized,
                          "endpoint": self.endpoint, "response_released": False}
            try:
                self.attempts += 1
                require(not self.retired, "bridge permanently retired after callback timeout")
                require(self.attempts <= self.max_requests, "request count admission limit")
                require(type(raw) is bytes and len(raw) <= self.max_body * 2 + 4096, "envelope admission limit")
                require(time.monotonic() < self.deadline, "session deadline")
                require(self.callback_kind != "live" or self.launch_authorized, "live launch not authorized")
                value = verify(decoded(raw), self.channel_key)
                require(set(value) == {"version", "id", "endpoint", "headers", "body_b64", "body_sha256"}, "unknown/missing request field")
                require(type(value["version"]) is int and value["version"] == 1, "unknown protocol version")
                request_id = value["id"]
                require(type(request_id) is str and re.fullmatch(r"[A-Za-z0-9_.-]{1,64}", request_id), "invalid request id")
                provenance["id"] = request_id
                require(request_id not in self.seen, "replayed request id")
                self.seen.add(request_id)
                require(value["endpoint"] == self.endpoint, "endpoint outside fixed allowlist")
                _headers(value["headers"])
                body = _body(value)
                provenance.update({"body_sha256": sha(body), "body_bytes": len(body), "headers": value["headers"]})
                require(len(body) <= self.max_body and self.request_bytes + len(body) <= self.total_body, "request body/total admission limit")
                self.request_bytes += len(body)
                deadline = min(self.deadline, time.monotonic() + self.callback_timeout)
                response = self._invoke(body, deadline)
                require(type(response) is dict and set(response) == {"status", "headers", "body"}, "unknown/missing callback response field")
                require(type(response["status"]) is int and 100 <= response["status"] <= 599, "invalid callback status")
                require(type(response["body"]) is bytes, "nonbytes callback response")
                _headers(response["headers"], response=True)
                provenance.update({"response_status": response["status"], "response_sha256": sha(response["body"]),
                                   "response_bytes": len(response["body"]), "response_headers": response["headers"]})
                require(len(response["body"]) <= self.max_response and self.response_bytes + len(response["body"]) <= self.total_response, "response body/total admission limit")
                self.response_bytes += len(response["body"])
                if self.response_policy is not None:
                    try:
                        policy = self.response_policy(response)
                    except Exception as error:
                        self._receipt({"status": "response_policy_error", "exception_type": type(error).__name__,
                                       "exception_sha256": sha(str(error).encode("utf-8", errors="replace")),
                                       "response_released": False})
                        raise TransportError("independent response policy rejected") from None
                    provenance["response_policy"] = policy
                require(time.monotonic() <= deadline, "response deadline")
                wire = packed(authenticated({"version": 1, "id": request_id, "status": response["status"],
                                            "headers": response["headers"], "body_b64": base64.b64encode(response["body"]).decode("ascii"),
                                            "body_sha256": sha(response["body"])}, self.channel_key))
                self._receipt({**provenance, "status": "forwarded", "response_released": True,
                               "response_envelope_sha256": sha(wire), "duration_ns": time.monotonic_ns() - started})
                return wire
            except (TransportError, UnicodeError) as error:
                self._receipt({**provenance, "status": "refused", "error": str(error),
                               "duration_ns": time.monotonic_ns() - started})
                if isinstance(error, TransportError):
                    raise
                raise TransportError("invalid Unicode envelope") from error

    def serve_stream(self, reader, writer, *, max_frame=None):
        """Caller supervises pipe deadlines; no real provider/OS isolation implied."""
        maximum = max_frame or self.max_body * 2 + 4096
        while True:
            try:
                raw = read_frame(reader, maximum)
                if raw is None:
                    return
                wire = self.handle(raw)
                writer.write(frame(wire, self.max_response * 2 + 4096))
                writer.flush()
                self._receipt({"status": "stdio_written", "response_envelope_sha256": sha(wire),
                               "response_released": True, "relay_receipt": "UNKNOWN", "model_delivery": "UNKNOWN"})
            except TransportError as error:
                self._receipt({"status": "stream_error", "error": str(error), "response_released": False})
                raise
            except OSError as error:
                self._receipt({"status": "stream_io_error", "exception_type": type(error).__name__,
                               "exception_sha256": sha(str(error).encode("utf-8", errors="replace")),
                               "response_released": False, "partial_stdio_delivery": "UNKNOWN"})
                raise TransportError("stdio I/O failure; partial delivery UNKNOWN") from error

    def durable_receipts(self):
        """Return serialized hash-only diagnostics for a parent-owned evidence sink."""
        return packed({"receipts": self.receipts, "attempts": self.attempts,
                       "request_bytes": self.request_bytes, "response_bytes": self.response_bytes, "permanently_retired": self.retired,
                       "limits": ["Blocking stdio read requires external process watchdog",
                                  "Callback timeout refuses release; underlying callback cancellation unproved",
                                  "Parent-only receipt HMAC is separate from relay channel authentication",
                                  "No OS confinement, provider identity/auth or model retention proof"]})
