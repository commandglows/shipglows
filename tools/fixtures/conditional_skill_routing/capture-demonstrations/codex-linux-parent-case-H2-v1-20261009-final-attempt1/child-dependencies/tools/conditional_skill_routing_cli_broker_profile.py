"""Mock-only Codex Linux dynamic broker profile with a trusted Responses gate.

The caller supplies WSL/bwrap confinement. Exact original CLI requests and
forwarded model requests have distinct provenance. Only tools are filtered.
Native CLI features are NOT claimed disabled; provider-produced unauthorized
calls are rejected before any provider response bytes reach the CLI.
"""
import argparse
import copy
import errno
import hashlib
import http.client
import json
import os
from pathlib import Path
import queue
import signal
import socket
import socketserver
import subprocess
import threading
import time

BODY_LIMIT=1024*1024
TOTAL_LIMIT=12*BODY_LIMIT
REQUEST_LIMIT=8
STREAM_LIMIT=4*BODY_LIMIT
HEADER_LIMIT=8192
DEADLINE_SECONDS=75


def pack(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


class Capture:
    def __init__(self, out):
        self.out, self.inventory, self.lock = out, {}, threading.Lock()

    def save(self, name, raw):
        with self.lock:
            with (self.out / name).open("xb") as stream:
                stream.write(raw)
                stream.flush()
            self.inventory[name] = {"bytes": len(raw), "sha256": digest(raw)}

    def document(self, name, value):
        self.save(name, pack(value))


def preflight(cli):
    if os.name != "posix" or not cli.is_absolute() or not cli.is_file():
        raise RuntimeError("requires an existing absolute Linux ELF inside caller namespace")
    if cli.read_bytes()[:4] != b"\x7fELF":
        raise RuntimeError("non-ELF CLI refused")
    interfaces = [line.split(":", 1)[0].strip() for line in Path("/proc/net/dev").read_text().splitlines()[2:]]
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as connection:
        connection.settimeout(0.2)
        error = connection.connect_ex(("203.0.113.1", 9))
    if interfaces != ["lo"] or error != errno.ENETUNREACH:
        raise RuntimeError("caller network namespace confinement unproved")
    return {"interfaces": interfaces, "nonloopback_probe_errno": error,
            "cli_sha256": digest(cli.read_bytes()), "source_sha256": digest(Path(__file__).read_bytes())}


def output_text(item):
    value = item.get("output")
    if isinstance(value, str):
        return value
    if isinstance(value, list) and all(isinstance(x, dict) and x.get("type") == "input_text"
                                      and isinstance(x.get("text"), str) for x in value):
        return "".join(x["text"] for x in value)
    raise ValueError("unknown callback output shape")


def text_values(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for item in value.values():
            yield from text_values(item)
    elif isinstance(value, list):
        for item in value:
            yield from text_values(item)


class Rpc:
    def __init__(self, command, cwd, environment, capture, callback):
        self.callback = callback
        self.capture, self.events, self.errors, self.queue = capture, [], [], queue.Queue()
        self.sent, self.threads, self.pending = 0, [], []
        self.end = time.monotonic() + DEADLINE_SECONDS
        self.process = subprocess.Popen(command, cwd=cwd, env=environment, stdin=subprocess.PIPE,
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
        for name, stream in (("stdout", self.process.stdout), ("stderr", self.process.stderr)):
            thread = threading.Thread(target=self.collect, args=(name, stream), daemon=True)
            thread.start()
            self.threads.append(thread)

    def collect(self, name, stream):
        count, total = 0, 0
        try:
            while True:
                raw = stream.readline(BODY_LIMIT + 1)
                if not raw:
                    break
                self.capture.save(f"rpc-{name}-{count:04d}.bin", raw)
                count, total = count + 1, total + len(raw)
                if len(raw) > BODY_LIMIT or total > STREAM_LIMIT:
                    raise ValueError(name + " admission limit")
                if name == "stdout":
                    event = json.loads(raw)
                    if not isinstance(event, dict):
                        raise ValueError("RPC event not object")
                    self.events.append(event)
                    self.queue.put(event)
        except (ValueError, OSError) as exc:
            self.errors.append(type(exc).__name__ + ": " + str(exc))
            self.queue.put({"capture_failure": True})
        finally:
            if name == "stdout":
                self.queue.put({"eof": True})

    def send(self, value):
        raw = pack(value) + b"\n"
        self.capture.save(f"rpc-input-{self.sent:03d}.bin", raw)
        self.sent += 1
        self.process.stdin.write(raw)
        self.process.stdin.flush()

    def await_event(self, predicate):
        for index, event in enumerate(self.pending):
            if predicate(event):
                return self.pending.pop(index)
        while time.monotonic() < self.end:
            try:
                event = self.queue.get(timeout=max(0.01, self.end - time.monotonic()))
            except queue.Empty:
                raise RuntimeError("RPC global timeout")
            if event.get("capture_failure") or event.get("eof"):
                raise RuntimeError("RPC stream failed or closed")
            if "method" in event and "id" in event:
                if event["method"] == "item/tool/call":
                    self.send({"jsonrpc": "2.0", "id": event["id"], "result": self.callback(event["params"])})
                    continue
                self.send({"jsonrpc": "2.0", "id": event["id"],
                           "error": {"code": -32000, "message": "Mock broker denies unsolicited callback"}})
                raise RuntimeError("unexpected server callback")
            if predicate(event):
                return event
            self.pending.append(event)
        raise RuntimeError("RPC global timeout")

    def call(self, identifier, method, params):
        self.send({"jsonrpc": "2.0", "id": identifier, "method": method, "params": params})
        value = self.await_event(lambda e: e.get("id") == identifier)
        if "error" in value or "result" not in value:
            raise RuntimeError("RPC rejected: " + method + ": " + pack(value).decode())
        return value["result"]

    def close(self):
        try:
            self.process.stdin.close()
            self.process.wait(timeout=4)
        except (OSError, subprocess.TimeoutExpired):
            os.killpg(self.process.pid, signal.SIGKILL)
            self.process.wait(timeout=3)
            self.errors.append("process did not exit after stdin close")
        for thread in self.threads:
            thread.join(timeout=2)
        for stream in (self.process.stdout, self.process.stderr):
            stream.close()


INSTRUCTIONS = "CSR_BROKER_INSTRUCTION_01601\nOnly fictional fixture operations are authorized.\n"
FIXTURE = "CSR_BROKER_FIXTURE_01601\nExact synthetic input: snowman \u2603; newline preserved.\n"
INITIAL = "synthetic original target\n"
REPLACEMENT = "synthetic replacement target\n"
FIRST = "CSR_BROKER_FIRST_USER_01601: exercise only the registered fictional broker tools."
SECOND = "CSR_BROKER_ATTACK_USER_01601: negative transport validation; no native execution authorized."
FINAL = "CSR_BROKER_FINAL_01601"
CALLS = ["call_instruction_read_01601", "call_fixture_read_01601", "call_simulated_replace_01601"]
NAMES = ["instruction_read", "fixture_read", "simulated_replace"]
PATHS = ["fixture/instructions", "fixture/input", "fixture/target"]
SCHEMAS = [
    {"type": "object", "properties": {"path": {"type": "string", "enum": [PATHS[0]]}}, "required": ["path"], "additionalProperties": False},
    {"type": "object", "properties": {"path": {"type": "string", "enum": [PATHS[1]]}}, "required": ["path"], "additionalProperties": False},
    {"type": "object", "properties": {"path": {"type": "string", "enum": [PATHS[2]]},
     "expected_sha256": {"type": "string"}, "text": {"type": "string"}},
     "required": ["path", "expected_sha256", "text"], "additionalProperties": False}]
DYNAMIC_TOOLS = [{"type": "function", "name": name, "description": "Bounded synthetic broker " + name,
                  "inputSchema": schema, "deferLoading": False} for name, schema in zip(NAMES, SCHEMAS)]
ARGUMENTS = [{"path": PATHS[0]}, {"path": PATHS[1]},
             {"path": PATHS[2], "expected_sha256": digest(INITIAL.encode()), "text": REPLACEMENT}]
REPLIES = [INSTRUCTIONS, FIXTURE, pack({"status": "simulated_only", "path": PATHS[2],
           "before_sha256": digest(INITIAL.encode()), "after_sha256": digest(REPLACEMENT.encode())}).decode()]


def filter_model_request(request):
    """Preserve every non-tools value exactly; select existing registered schemas."""
    if not isinstance(request, dict) or not isinstance(request.get("tools"), list) or not isinstance(request.get("input"), list):
        raise ValueError("unknown original CLI request shape")
    selected = {}
    for tool in request["tools"]:
        if not isinstance(tool, dict):
            raise ValueError("malformed original tool entry")
        name = tool.get("name")
        if name not in NAMES:
            continue
        if name in selected or tool.get("type") != "function" or tool.get("parameters") != SCHEMAS[NAMES.index(name)]:
            raise ValueError("duplicate/malformed/changed registered tool schema")
        selected[name] = tool
    if set(selected) != set(NAMES):
        raise ValueError("three exact registered tool schemas not advertised by CLI")
    forwarded = copy.deepcopy(request)
    forwarded["tools"] = [copy.deepcopy(selected[name]) for name in NAMES]
    if {k: v for k, v in forwarded.items() if k != "tools"} != {k: v for k, v in request.items() if k != "tools"}:
        raise ValueError("non-tools content changed")
    return forwarded


def validate_function_item(item):
    if not isinstance(item, dict) or item.get("type") != "function_call" or item.get("name") not in NAMES:
        raise ValueError("unregistered or native provider tool call refused")
    if set(item) - {"type", "id", "call_id", "name", "arguments", "status"}:
        raise ValueError("unknown function item fields")
    if item.get("status") != "completed" or not all(isinstance(item.get(key), str) and item[key] for key in ("id", "call_id", "arguments")):
        raise ValueError("malformed function call identity/arguments")
    arguments = json.loads(item["arguments"])
    if arguments != ARGUMENTS[NAMES.index(item["name"])]:
        raise ValueError("arguments outside bounded broker fixture")


def validate_message_item(item):
    if not isinstance(item, dict) or item.get("type") != "message" or item.get("role") != "assistant" or item.get("status") != "completed":
        raise ValueError("unknown provider output item type")
    if set(item) - {"type", "id", "role", "status", "content"}:
        raise ValueError("unknown provider message fields")
    content = item.get("content")
    if not isinstance(content, list) or not content:
        raise ValueError("malformed completed message")
    if not all(isinstance(part, dict) and set(part) <= {"type", "text", "annotations"}
               and part.get("type") == "output_text" and isinstance(part.get("text"), str)
               and part.get("annotations") == [] for part in content):
        raise ValueError("unknown provider content shape")


def gate_complete_sse(raw, seen_call_ids=frozenset()):
    """Validate the entire bounded stream before any provider bytes reach CLI."""
    if not raw or len(raw) > BODY_LIMIT or not raw.endswith(b"\n\n"):
        raise ValueError("incomplete/oversized provider SSE")
    allowed = {"response.created", "response.output_item.added", "response.output_item.done",
               "response.function_call_arguments.delta", "response.function_call_arguments.done",
               "response.content_part.added", "response.content_part.done", "response.output_text.delta",
               "response.output_text.done", "response.completed"}
    event_fields = {
        "response.created": {"response"}, "response.completed": {"response"},
        "response.output_item.added": {"output_index", "item"}, "response.output_item.done": {"output_index", "item"},
        "response.function_call_arguments.delta": {"item_id", "output_index", "delta"},
        "response.function_call_arguments.done": {"item_id", "output_index", "arguments"},
        "response.content_part.added": {"item_id", "output_index", "content_index", "part"},
        "response.content_part.done": {"item_id", "output_index", "content_index", "part"},
        "response.output_text.delta": {"item_id", "output_index", "content_index", "delta"},
        "response.output_text.done": {"item_id", "output_index", "content_index", "text"}}
    events, completed, added, fragments, texts, response_id = [], {}, {}, {}, {}, None
    indexes, argument_done, text_done, part_added, part_done = {}, set(), set(), set(), set()
    for block in raw[:-2].split(b"\n\n"):
        lines = block.split(b"\n")
        if len(lines) != 2 or not lines[0].startswith(b"event: ") or not lines[1].startswith(b"data: "):
            raise ValueError("unknown SSE framing")
        event = json.loads(lines[1][6:])
        event_type = lines[0][7:].decode("ascii")
        if not isinstance(event, dict) or event_type not in allowed or event.get("type") != event_type or type(event.get("sequence_number")) is not int or event.get("sequence_number") != len(events):
            raise ValueError("unknown/out-of-order SSE event")
        if set(event) != event_fields[event_type] | {"type", "sequence_number"}:
            raise ValueError("unknown/missing SSE event fields")
        if "output_index" in event and (type(event["output_index"]) is not int or event["output_index"] < 0):
            raise ValueError("invalid output index")
        if "content_index" in event and (type(event["content_index"]) is not int or event["content_index"] < 0):
            raise ValueError("invalid content index")
        if "response" in event:
            response = event["response"]
            if not isinstance(response, dict) or set(response) != {"id", "object", "created_at", "status", "model", "output", "usage"} or response.get("object") != "response":
                raise ValueError("unknown response envelope fields")
            usage = response["usage"]
            if type(response["created_at"]) is not int or not isinstance(response["model"], str) or not isinstance(response["output"], list) or not isinstance(usage, dict) or set(usage) != {"input_tokens", "output_tokens", "total_tokens", "input_tokens_details", "output_tokens_details"}:
                raise ValueError("unknown provider response/usage shape")
            if any(type(usage[key]) is not int or usage[key] < 0 for key in ("input_tokens", "output_tokens", "total_tokens")) or usage["input_tokens_details"] != {"cached_tokens": 0} or usage["output_tokens_details"] != {"reasoning_tokens": 0}:
                raise ValueError("unsupported synthetic usage metadata")
        if events and events[-1]["type"] == "response.completed":
            raise ValueError("provider event after completion")
        events.append(event)
        if event_type == "response.created":
            if len(events) != 1 or not isinstance(event.get("response"), dict):
                raise ValueError("invalid created response")
            response_id = event["response"].get("id")
            if not isinstance(response_id, str) or not response_id or event["response"].get("output") != [] or event["response"].get("status") != "in_progress":
                raise ValueError("missing response id")
        elif event_type in ("response.output_item.added", "response.output_item.done"):
            item = event.get("item")
            if not isinstance(item, dict) or item.get("type") not in ("message", "function_call"):
                raise ValueError("unknown provider item")
            if item["type"] == "function_call" and item.get("name") not in NAMES:
                raise ValueError("unregistered or native provider tool call refused")
            fields = {"type", "id", "status", "call_id", "name", "arguments"} if item["type"] == "function_call" else {"type", "id", "role", "status", "content"}
            if set(item) != fields:
                raise ValueError("unknown/missing output item fields")
            identity = item.get("id")
            if not isinstance(identity, str) or not identity:
                raise ValueError("missing output id")
            if event_type.endswith("added"):
                if identity in added or event["output_index"] in indexes.values() or item.get("status") != "in_progress":
                    raise ValueError("duplicate added output item")
                if item["type"] == "function_call" and (item.get("arguments") != "" or not isinstance(item.get("call_id"), str) or not item["call_id"] or item["call_id"] in seen_call_ids):
                    raise ValueError("invalid/replayed added function call")
                if item["type"] == "message" and (item.get("role") != "assistant" or item.get("content") != []):
                    raise ValueError("unknown added message shape")
                added[identity] = item
                indexes[identity] = event["output_index"]
            else:
                if identity not in added or identity in completed or event["output_index"] != indexes[identity]:
                    raise ValueError("unmatched/duplicate completed output item")
                validate_function_item(item) if item["type"] == "function_call" else validate_message_item(item)
                if any(item.get(key) != added[identity].get(key) for key in ("type", "id", "name", "call_id", "role")):
                    raise ValueError("output item identity/type changed")
                if item["type"] == "function_call" and identity in fragments and fragments[identity] != item["arguments"]:
                    raise ValueError("argument deltas disagree with completed tool call")
                if item["type"] == "function_call" and identity in fragments and identity not in argument_done:
                    raise ValueError("argument stream ended before done")
                if item["type"] == "message" and identity in texts and texts[identity] != "".join(part["text"] for part in item["content"]):
                    raise ValueError("text deltas disagree with completed message")
                if item["type"] == "message" and (identity not in text_done or identity not in part_added or identity not in part_done):
                    raise ValueError("message stream ended before content/text completion")
                completed[identity] = item
        elif event_type == "response.completed":
            response = event.get("response")
            if not isinstance(response, dict) or response.get("id") != response_id or response.get("status") != "completed" or response.get("output") != list(completed.values()) or set(added) != set(completed):
                raise ValueError("incomplete/inconsistent completed provider response")
        else:
            identity = event.get("item_id")
            if identity not in added or identity in completed or event["output_index"] != indexes[identity]:
                raise ValueError("event outside active output item")
            if event_type.startswith("response.function_call_arguments"):
                if added[identity]["type"] != "function_call":
                    raise ValueError("argument event attached to message")
                if event_type.endswith("delta"):
                    if identity in argument_done or not isinstance(event["delta"], str):
                        raise ValueError("invalid argument delta")
                    fragments[identity] = fragments.get(identity, "") + event["delta"]
                elif identity in argument_done or not isinstance(event["arguments"], str) or (identity in fragments and event["arguments"] != fragments[identity]):
                    raise ValueError("inconsistent completed arguments")
                else:
                    fragments[identity] = event["arguments"]
                    argument_done.add(identity)
            elif added[identity]["type"] != "message":
                raise ValueError("text/content event attached to tool call")
            elif event_type.startswith("response.content_part"):
                part = event["part"]
                if event["content_index"] != 0 or not isinstance(part, dict) or set(part) != {"type", "text", "annotations"} or part.get("type") != "output_text" or not isinstance(part.get("text"), str) or part.get("annotations") != []:
                    raise ValueError("unknown provider content part")
                if event_type.endswith("added"):
                    if identity in part_added or part["text"] != "":
                        raise ValueError("duplicate/nonempty added content part")
                    part_added.add(identity)
                else:
                    if identity not in part_added or identity in part_done or identity not in text_done or part["text"] != texts[identity]:
                        raise ValueError("unmatched/inconsistent completed content part")
                    part_done.add(identity)
            elif event_type == "response.output_text.delta":
                if event["content_index"] != 0 or identity not in part_added or identity in text_done or not isinstance(event["delta"], str):
                    raise ValueError("malformed provider text delta")
                texts[identity] = texts.get(identity, "") + event["delta"]
            elif event_type == "response.output_text.done":
                if event["content_index"] != 0 or identity not in part_added or identity in text_done or not isinstance(event["text"], str) or (identity in texts and event["text"] != texts[identity]):
                    raise ValueError("inconsistent completed text")
                texts[identity] = event["text"]
                text_done.add(identity)
    if not events or events[-1]["type"] != "response.completed" or not completed:
        raise ValueError("provider stream incomplete")
    calls = [item["call_id"] for item in completed.values() if item["type"] == "function_call"]
    if len(calls) != len(set(calls)):
        raise ValueError("duplicate provider call id")
    return {"response_id": response_id, "events": len(events), "output_items": len(completed), "call_ids": calls,
            "function_names": [item["name"] for item in completed.values() if item["type"] == "function_call"],
            "provider_bytes_validated_before_cli_emission": len(raw)}


def provider_sse(identifier, name=None, arguments=None, call_id=None):
    if name:
        item = {"type": "function_call", "id": "fc_" + identifier, "call_id": call_id,
                "name": name, "arguments": pack(arguments).decode(), "status": "completed"}
    else:
        item = {"type": "message", "id": "msg_" + identifier, "role": "assistant", "status": "completed",
                "content": [{"type": "output_text", "text": FINAL, "annotations": []}]}
    response = {"id": "resp_" + identifier, "object": "response", "created_at": 0, "status": "completed",
                "model": "synthetic", "output": [item], "usage": {"input_tokens": 10, "output_tokens": 2, "total_tokens": 12,
                "input_tokens_details": {"cached_tokens": 0}, "output_tokens_details": {"reasoning_tokens": 0}}}
    added = {**item, "status": "in_progress"}
    if name:
        added["arguments"] = ""
    else:
        added["content"] = []
    events = [{"type": "response.created", "response": {**response, "status": "in_progress", "output": []}},
              {"type": "response.output_item.added", "output_index": 0, "item": added}]
    if name:
        events.extend([
            {"type": "response.function_call_arguments.delta", "item_id": item["id"], "output_index": 0, "delta": item["arguments"]},
            {"type": "response.function_call_arguments.done", "item_id": item["id"], "output_index": 0, "arguments": item["arguments"]}])
    else:
        part = item["content"][0]
        events.extend([
            {"type": "response.content_part.added", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": {**part, "text": ""}},
            {"type": "response.output_text.delta", "item_id": item["id"], "output_index": 0, "content_index": 0, "delta": FINAL},
            {"type": "response.output_text.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "text": FINAL},
            {"type": "response.content_part.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": part}])
    events.extend([{"type": "response.output_item.done", "output_index": 0, "item": item},
                   {"type": "response.completed", "response": response}])
    return b"".join(b"event: " + event["type"].encode() + b"\ndata: " + pack({**event, "sequence_number": index}) + b"\n\n"
                    for index, event in enumerate(events))


def read_http(handler, capture, identifier, budget, expected_path):
    handler.request.settimeout(2)
    began, lines, size, raw = time.monotonic_ns(), [], 0, b""
    while True:
        line = handler.rfile.readline(HEADER_LIMIT + 1)
        size += len(line)
        if not line or size > HEADER_LIMIT or time.monotonic_ns() - began > 3_000_000_000:
            raise ValueError("HTTP header incomplete/limit/deadline")
        lines.append(line)
        if line == b"\r\n":
            break
    method, path, _ = lines[0].decode("ascii").strip().split(" ")
    headers = {}
    for line in lines[1:-1]:
        key, value = line.decode("ascii").strip().split(":", 1)
        key = key.lower()
        if key in headers:
            raise ValueError("duplicate HTTP header")
        headers[key] = value.strip()
    length = int(headers.get("content-length", "0"))
    if length < 0 or length > BODY_LIMIT or budget["bytes"] + length > TOTAL_LIMIT or budget["count"] > REQUEST_LIMIT or "transfer-encoding" in headers or "authorization" in headers:
        raise ValueError("HTTP framing/admission/auth refused")
    budget["bytes"] += length
    try:
        while len(raw) < length:
            if time.monotonic_ns() - began > 5_000_000_000:
                raise ValueError("HTTP body deadline")
            chunk = handler.rfile.read1(min(65536, length - len(raw)))
            if not chunk:
                raise ValueError("incomplete HTTP body")
            capture.save(identifier + f".request.chunk-{len(raw):07d}.bin", chunk)
            raw += chunk
    finally:
        capture.save(identifier + ".request.bin", raw)
    if method != "POST" or path != expected_path:
        raise ValueError("unexpected endpoint")
    return raw, {"method": method, "path": path, "started_ns": began, "body_sha256": digest(raw),
                 "bytes": length, "headers": {k: v for k, v in headers.items() if k in
                 {"host", "content-type", "content-length", "user-agent", "x-request-id"}}}


def send_http(handler, status, raw, content_type):
    handler.wfile.write(f"HTTP/1.1 {status} Synthetic\r\nContent-Type: {content_type}\r\nContent-Length: {len(raw)}\r\nConnection: close\r\n\r\n".encode() + raw)
    handler.wfile.flush()


def run(cli, out, facts):
    capture = Capture(out)
    capture.save("source-snapshot.py", Path(__file__).read_bytes())
    capture.document("preflight.json", facts)
    capture.document("registered-dynamic-tools.json", DYNAMIC_TOOLS)
    home, project = out / "synthetic-home", out / "synthetic-project"
    home.mkdir()
    project.mkdir()
    code_home = home / "codex"
    code_home.mkdir()
    forbidden_effect = project / "NATIVE_TOOL_MUST_NOT_EXECUTE"
    attack = {"cmd": "/usr/bin/python3 -c " + "\"from pathlib import Path;Path('NATIVE_TOOL_MUST_NOT_EXECUTE').write_text('unauthorized')\"",
              "workdir": str(project), "shell": "/bin/sh", "login": False, "yield_time_ms": 1000}
    model_receipts, proxy_receipts, callbacks, callback_outputs = [], [], [], {}
    model_budget, proxy_budget = {"count": 0, "bytes": 0}, {"count": 0, "bytes": 0}
    broker = {"stage": 0, "target": INITIAL, "thread_id": None}
    proxy_state = {"accepted": 0, "denied": 0, "seen_call_ids": set()}

    def callback(params):
        index = broker["stage"]
        capture.document(f"broker-callback-{index:03d}.json", params)
        if index >= 3 or params.get("threadId") != broker["thread_id"] or params.get("namespace") is not None or params.get("tool") != NAMES[index] or params.get("callId") != CALLS[index] or params.get("arguments") != ARGUMENTS[index]:
            raise RuntimeError("unexpected/out-of-order broker callback")
        if index == 2:
            if digest(broker["target"].encode()) != params["arguments"]["expected_sha256"]:
                raise RuntimeError("synthetic replacement preimage mismatch")
            broker["target"] = params["arguments"]["text"]
        result = {"success": True, "contentItems": [{"type": "inputText", "text": REPLIES[index]}]}
        capture.document(f"broker-reply-{index:03d}.json", result)
        callbacks.append({"tool": NAMES[index], "call_id": CALLS[index], "reply_text_sha256": digest(REPLIES[index].encode()),
                          "span_utf8": [0, len(REPLIES[index].encode())], "reply": result})
        broker["stage"] += 1
        return result

    class MockHandler(socketserver.StreamRequestHandler):
        def handle(self):
            model_budget["count"] += 1
            identifier = f"model-{model_budget['count']:03d}"
            receipt = {"id": identifier}
            try:
                raw, envelope = read_http(self, capture, identifier, model_budget, "/mock/responses")
                receipt.update(envelope)
                request = json.loads(raw)
                if not isinstance(request, dict) or not isinstance(request.get("input"), list):
                    raise ValueError("unknown forwarded model request")
                tools = request.get("tools")
                if not isinstance(tools, list) or [t.get("name") for t in tools] != NAMES or any(t.get("type") != "function" or t.get("parameters") != schema for t, schema in zip(tools, SCHEMAS)):
                    raise ValueError("model sees more/fewer/changed broker tools")
                receipt["model_tools"] = NAMES
                receipt["schema_sha256"] = [digest(pack(t["parameters"])) for t in tools]
                index = model_budget["count"] - 1
                outputs = [item for item in request["input"] if isinstance(item, dict) and item.get("type") == "function_call_output"]
                results = {item.get("call_id"): output_text(item) for item in outputs}
                if len(results) != len(outputs) or set(results) != set(CALLS[:min(index, 3)]):
                    raise ValueError("missing/unexpected/duplicate broker output")
                for call_id, previous in callback_outputs.items():
                    if results.get(call_id) != previous:
                        raise ValueError("historical exact callback changed")
                if 1 <= index <= 3:
                    latest = CALLS[index - 1]
                    if results[latest] != REPLIES[index - 1]:
                        raise ValueError("exact broker callback text changed")
                    callback_outputs[latest] = results[latest]
                receipt["callback_sha256"] = {k: digest(v.encode()) for k, v in results.items()}
                if index < 3:
                    body = provider_sse(identifier, NAMES[index], ARGUMENTS[index], CALLS[index])
                elif index == 3:
                    body = provider_sse(identifier)
                elif index == 4:
                    if not any(SECOND in text for text in text_values(request)):
                        raise ValueError("negative second user turn missing")
                    body = provider_sse(identifier, "exec_command", attack, "call_native_must_be_denied_01601")
                else:
                    raise ValueError("unexpected model iteration")
                capture.save(identifier + ".provider-response.bin", body)
                send_http(self, 200, body, "text/event-stream")
                receipt.update(status=200, response_sha256=digest(body), sent_complete=True)
            except Exception as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
            finally:
                receipt["ended_ns"] = time.monotonic_ns()
                model_receipts.append(receipt)

    model_server = socketserver.TCPServer(("127.0.0.1", 0), MockHandler)
    model_thread = threading.Thread(target=model_server.serve_forever, daemon=True)
    model_thread.start()

    class ProxyHandler(socketserver.StreamRequestHandler):
        def handle(self):
            proxy_budget["count"] += 1
            identifier = f"cli-original-{proxy_budget['count']:03d}"
            receipt = {"id": identifier, "provider_sse_bytes_emitted_to_cli": 0}
            connection = None
            try:
                raw, envelope = read_http(self, capture, identifier, proxy_budget, "/v1/responses")
                receipt.update(envelope)
                original = json.loads(raw)
                forwarded = filter_model_request(original)
                forwarded_raw = pack(forwarded)
                capture.save(identifier + ".forwarded-model-request.bin", forwarded_raw)
                receipt.update(original_tool_names=[tool.get("name") for tool in original["tools"]],
                               forwarded_tool_names=NAMES, forwarded_sha256=digest(forwarded_raw),
                               non_tools_unchanged={k: v for k, v in original.items() if k != "tools"} == {k: v for k, v in forwarded.items() if k != "tools"},
                               input_sha256=digest(pack(original["input"])),
                               instructions_sha256=digest(pack(original.get("instructions"))))
                connection = http.client.HTTPConnection("127.0.0.1", model_server.server_address[1], timeout=3)
                connection.request("POST", "/mock/responses", body=forwarded_raw, headers={"Content-Type": "application/json"})
                response = connection.getresponse()
                if response.status != 200 or response.getheader("Content-Type") != "text/event-stream" or response.getheader("Transfer-Encoding") is not None:
                    raise ValueError("unknown provider response envelope")
                length = int(response.getheader("Content-Length", "-1"))
                if not 0 <= length <= BODY_LIMIT:
                    raise ValueError("provider response admission limit")
                provider_raw = response.read(BODY_LIMIT + 1)
                capture.save(identifier + ".received-provider-response.bin", provider_raw)
                if len(provider_raw) != length:
                    raise ValueError("incomplete provider response body")
                try:
                    receipt["gate"] = gate_complete_sse(provider_raw, proxy_state["seen_call_ids"])
                except ValueError as exc:
                    proxy_state["denied"] += 1
                    receipt.update(gate_status="denied_before_cli_emission", gate_reason=str(exc), status=502)
                    rejection = pack({"error": {"message": "trusted transport rejected provider response before CLI dispatch", "type": "unregistered_tool"}})
                    capture.save(identifier + ".cli-rejection.bin", rejection)
                    send_http(self, 502, rejection, "application/json")
                    receipt["sent_complete"] = True
                    return
                capture.save(identifier + ".emitted-to-cli.bin", provider_raw)
                send_http(self, 200, provider_raw, "text/event-stream")
                receipt.update(gate_status="accepted_complete_stream", provider_sse_bytes_emitted_to_cli=len(provider_raw),
                               emitted_sha256=digest(provider_raw), status=200, sent_complete=True)
                proxy_state["accepted"] += 1
                proxy_state["seen_call_ids"].update(receipt["gate"]["call_ids"])
            except Exception as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
            finally:
                if connection is not None:
                    connection.close()
                receipt["ended_ns"] = time.monotonic_ns()
                proxy_receipts.append(receipt)

    proxy_server = socketserver.TCPServer(("127.0.0.1", 0), ProxyHandler)
    proxy_thread = threading.Thread(target=proxy_server.serve_forever, daemon=True)
    proxy_thread.start()
    config = ('model="synthetic"\nmodel_provider="mock"\napproval_policy="never"\nsandbox_mode="danger-full-access"\n'
              '[analytics]\nenabled=false\n[model_providers.mock]\nname="Trusted mock broker gate"\nwire_api="responses"\n'
              f'base_url="http://127.0.0.1:{proxy_server.server_address[1]}/v1"\nrequires_openai_auth=false\nrequest_max_retries=0\nstream_max_retries=0\n')
    (code_home / "config.toml").write_text(config)
    capture.save("config-snapshot.toml", config.encode())
    environment = {"HOME": str(home), "CODEX_HOME": str(code_home), "PATH": "/usr/bin:/bin", "TMPDIR": str(home), "NO_COLOR": "1", "LANG": "C.UTF-8"}
    command = [str(cli), "app-server", "--listen", "stdio://"]
    capture.document("launch.json", {"argv": command, "cwd": str(project), "environment": environment,
                                     "confinement": "caller WSL/bwrap --unshare-all", "native_features_disabled": "NOT_PROVED"})
    rpc, failure, turns, version_ok = None, None, [], False
    try:
        version = subprocess.run([str(cli), "--version"], cwd=project, env=environment, capture_output=True, timeout=4, check=False)
        capture.save("cli-version.stdout.bin", version.stdout)
        capture.save("cli-version.stderr.bin", version.stderr)
        version_ok = version.returncode == 0 and version.stdout.strip() == b"codex-cli 0.160.1"
        if not version_ok:
            raise RuntimeError("CLI version is not exactly0.160.1")
        rpc = Rpc(command, project, environment, capture, callback)
        rpc.call(1, "initialize", {"clientInfo": {"name": "csr-broker-profile", "version": "1"}, "capabilities": {"experimentalApi": True}})
        rpc.send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
        started = rpc.call(2, "thread/start", {"cwd": str(project), "ephemeral": True, "model": "synthetic", "modelProvider": "mock",
                          "approvalPolicy": "never", "sandbox": "danger-full-access", "dynamicTools": DYNAMIC_TOOLS,
                          "baseInstructions": "Synthetic broker profile. All provider calls pass through trusted transport gate."})
        broker["thread_id"] = started["thread"]["id"]
        first = rpc.call(3, "turn/start", {"threadId": broker["thread_id"], "input": [{"type": "text", "text": FIRST}]})
        turns.append(first["turn"]["id"])
        rpc.await_event(lambda event: event.get("method") == "turn/completed" and event.get("params", {}).get("turn", {}).get("id") == turns[0])
        second = rpc.call(4, "turn/start", {"threadId": broker["thread_id"], "input": [{"type": "text", "text": SECOND}]})
        turns.append(second["turn"]["id"])
        rpc.await_event(lambda event: event.get("method") == "turn/completed" and event.get("params", {}).get("turn", {}).get("id") == turns[1])
    except (RuntimeError, ValueError, KeyError, TypeError, OSError, subprocess.TimeoutExpired) as exc:
        failure = type(exc).__name__ + ": " + str(exc)
    finally:
        if rpc is not None:
            rpc.close()
        for server, thread in ((proxy_server, proxy_thread), (model_server, model_thread)):
            server.shutdown()
            thread.join(timeout=2)
            server.server_close()
    events = rpc.events if rpc else []
    items = [event.get("params", {}).get("item", {}) for event in events if event.get("method") == "item/completed"]
    completed = [event.get("params", {}).get("turn", {}) for event in events if event.get("method") == "turn/completed" and event.get("params", {}).get("turn", {}).get("id") in turns]
    commands = [item for item in items if item.get("type") in ("commandExecution", "fileChange", "mcpToolCall", "webSearch", "collabAgentToolCall")]
    capture.document("proxy-receipts.json", proxy_receipts)
    capture.document("model-receipts.json", model_receipts)
    capture.document("broker-callbacks.json", callbacks)
    capture.document("rpc-events.json", {"events": events, "errors": rpc.errors if rpc else [], "failure": failure, "turn_ids": turns})
    checks = {"cli_version_01601": version_ok,
              "capture_and_process_complete": failure is None and rpc is not None and not rpc.errors and rpc.process.returncode == 0,
              "exact_three_registered_callbacks": broker["stage"] == 3 and len(callbacks) == 3 and set(callback_outputs) == set(CALLS),
              "fixture_mutation_only_simulated": broker["target"] == REPLACEMENT,
              "two_user_turns_success_then_failed_by_gate": len(turns) == 2 and len(completed) == 2 and [turn.get("status") for turn in completed] == ["completed", "failed"],
              "exact_three_model_tools_and_schemas": len(model_receipts) == 5 and all(r.get("model_tools") == NAMES and r.get("schema_sha256") == [digest(pack(s)) for s in SCHEMAS] and not r.get("error") for r in model_receipts),
              "input_and_instructions_unchanged": len(proxy_receipts) == 5 and all(r.get("non_tools_unchanged") and not r.get("error") for r in proxy_receipts),
              "exact_forwarded_body_reaches_mock": len(proxy_receipts) == len(model_receipts) == 5 and all(p.get("forwarded_sha256") == m.get("body_sha256") for p, m in zip(proxy_receipts, model_receipts)),
              "four_complete_provider_streams_accepted": proxy_state["accepted"] == 4 and [r.get("status") for r in proxy_receipts] == [200, 200, 200, 200, 502],
              "native_call_rejected_before_cli_dispatch": proxy_state["denied"] == 1 and len(proxy_receipts) == 5 and proxy_receipts[-1].get("provider_sse_bytes_emitted_to_cli") == 0 and proxy_receipts[-1].get("gate_status") == "denied_before_cli_emission",
              "no_native_command_event_or_sideeffect": not commands and not forbidden_effect.exists(),
              "exact_first_final_only": [item.get("text") for item in items if item.get("type") == "agentMessage"] == [FINAL],
              "all_blob_hashes": all(digest((out / name).read_bytes()) == row["sha256"] for name, row in capture.inventory.items())}
    summary = {"passed": all(checks.values()), "checks": checks, "failure": failure, "synthetic_only": True,
               "inventory": capture.inventory.copy(), "preflight": facts,
               "limits": ["Native CLI features and tools remain; this is a trusted provider-boundary gate",
                          "Original CLI request and forwarded model request are separate evidence tiers",
                          "Only tools field filtered; other JSON values unchanged, serialization normalized",
                          "Complete bounded HTTP/SSE responses inspected before CLI emission; no TLS/TCP sniffer",
                          "Three registered fixture callbacks exercised; simulated replacement has no real target",
                          "One malicious native exec_command response rejected; broader adversarial coverage requires separate evidence",
                          "All provider responses and usage synthetic; no account, model retention, AC5 or campaign proof",
                          "Original strict all-native-features-disabled gate remains unsatisfied by this profile"]}
    capture.document("summary.json", summary)
    return {"passed": summary["passed"], "failure": failure, "summary_sha256": digest((out / "summary.json").read_bytes())}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    facts = preflight(args.cli)
    args.out.mkdir(parents=False, exist_ok=False)
    result = run(args.cli, args.out.resolve(), facts)
    print(json.dumps(result))
    raise SystemExit(0 if result["passed"] else 1)


if __name__ == "__main__":
    main()
