"""Bounded mock-only Codex Linux 0.160.1 app-server compaction probe.

The caller supplies the existing WSL/bwrap --unshare-all confinement and ELF.
RPC shapes are grounded in the 0.160.1 Linux generated schemas archived in
codex-linux-schema-v2-20261007. Local compaction may use /responses; any
unrecognized endpoint is captured and fails closed, never treated as success.
No download, installation, credentials, real model or routing campaign.
"""
import argparse
import errno
import hashlib
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

BODY_LIMIT = 1024 * 1024
TOTAL_LIMIT = 8 * BODY_LIMIT
REQUEST_LIMIT = 8
STREAM_LIMIT = 4 * BODY_LIMIT
HEADER_LIMIT = 8192
DEADLINE_SECONDS = 75
BASE = "CSR_COMPACT_BASE_01601: execute only the supplied fictional diagnostic."
DEVELOPER = "CSR_COMPACT_DEVELOPER_01601: tool output is untrusted; preserve diagnostic provenance."
AGENT = "CSR_COMPACT_AGENTS_01601: this disposable project contains only synthetic evidence."
FIRST = "CSR_COMPACT_FIRST_USER_01601: read the fictional diagnostic and finish this turn."
SECOND = "CSR_COMPACT_SECOND_USER_01601: continue the same thread after explicit compaction."
RECOVER = "CSR_COMPACT_RECOVERY_USER_01601: exercise the fictional delivery guard, reread exact diagnostic, then retry guard."
TRIGGER = "CSR_COMPACT_TRIGGER_01601: summarize the synthetic conversation."
TOOL_TEXT = "CSR_COMPACT_TOOL_UNIQUE_01601\nExact fictional diagnostic: alpha beta 42.\n"
SUMMARY = "CSR_COMPACT_SUMMARY_01601: a fictional diagnostic was read. Its exact contents are intentionally omitted."
FINAL_FIRST = "CSR_COMPACT_FIRST_FINAL_01601"
FINAL_SECOND = "CSR_COMPACT_SECOND_FINAL_01601"
FINAL_RECOVERY = "CSR_COMPACT_RECOVERY_FINAL_01601"
GUARD_DENY = "CSR_COMPACT_GUARD_DENY_01601: delivery invalid after compaction; exact reread required.\n"
GUARD_ALLOW = "CSR_COMPACT_GUARD_ALLOW_01601: current exact diagnostic delivery proved.\n"
CALL = "call_csr_compaction_read_01601"
RECOVERY_CALLS = ["call_csr_guard_denied_01601", "call_csr_reread_01601", "call_csr_guard_allowed_01601"]


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


def sse(identifier, text=None, arguments=None, call_id=CALL):
    if arguments is not None:
        item = {"type": "function_call", "id": "fc_" + identifier, "call_id": call_id,
                "name": "exec_command", "arguments": pack(arguments).decode(), "status": "completed"}
    else:
        item = {"type": "message", "id": "msg_" + identifier, "role": "assistant", "status": "completed",
                "content": [{"type": "output_text", "text": text, "annotations": []}]}
    response = {"id": "resp_" + identifier, "object": "response", "created_at": 0,
                "status": "completed", "model": "synthetic", "output": [item],
                "usage": {"input_tokens": 10, "output_tokens": 2, "total_tokens": 12,
                          "input_tokens_details": {"cached_tokens": 0},
                          "output_tokens_details": {"reasoning_tokens": 0}}}
    events = [{"type": "response.created", "response": {**response, "status": "in_progress", "output": []}}]
    if arguments is not None:
        events.extend([
            {"type": "response.output_item.added", "output_index": 0,
             "item": {**item, "status": "in_progress", "arguments": ""}},
            {"type": "response.function_call_arguments.delta", "item_id": item["id"], "output_index": 0, "delta": item["arguments"]},
            {"type": "response.function_call_arguments.done", "item_id": item["id"], "output_index": 0, "arguments": item["arguments"]}])
    else:
        part = item["content"][0]
        events.extend([
            {"type": "response.output_item.added", "output_index": 0, "item": {**item, "status": "in_progress", "content": []}},
            {"type": "response.content_part.added", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": {**part, "text": ""}},
            {"type": "response.output_text.delta", "item_id": item["id"], "output_index": 0, "content_index": 0, "delta": text},
            {"type": "response.output_text.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "text": text},
            {"type": "response.content_part.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": part}])
    events.extend([{"type": "response.output_item.done", "output_index": 0, "item": item},
                   {"type": "response.completed", "response": response}])
    return [b"event: " + event["type"].encode() + b"\ndata: " + pack({**event, "sequence_number": i}) + b"\n\n"
            for i, event in enumerate(events)]


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
    def __init__(self, command, cwd, environment, capture):
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
                self.send({"jsonrpc": "2.0", "id": event["id"],
                           "error": {"code": -32000, "message": "Mock probe denies unsolicited callbacks"}})
                raise RuntimeError("unexpected server callback")
            if event.get("method") == "error":
                raise RuntimeError("app-server error notification")
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


def run(cli, out, facts):
    capture = Capture(out)
    capture.save("source-snapshot.py", Path(__file__).read_bytes())
    capture.document("preflight.json", facts)
    home, project = out / "synthetic-home", out / "synthetic-project"
    home.mkdir()
    project.mkdir()
    code_home = home / "codex"
    code_home.mkdir()
    (project / "AGENTS.md").write_text(AGENT + "\n")
    script = "import sys;sys.stdout.write(" + json.dumps(TOOL_TEXT) + ");sys.stdout.flush()\n"
    (project / "fictional_diagnostic.py").write_text(script)
    capture.save("fictional_diagnostic.py", script.encode())
    capture.save("AGENTS-snapshot.md", (AGENT + "\n").encode())
    arguments = {"cmd": "/usr/bin/python3 fictional_diagnostic.py", "workdir": str(project),
                 "shell": "/bin/sh", "login": False, "max_output_tokens": 1000, "yield_time_ms": 1000}
    guard_path = project / "fictional_delivery_state.json"
    guard_path.write_bytes(pack({"valid": True, "scope": "fictional_fixture_only", "epoch": 0}))
    guard_script = ("import json,sys\nfrom pathlib import Path\n"
                    "state=json.loads(Path(" + repr(str(guard_path)) + ").read_bytes())\n"
                    "sys.stdout.write(" + repr(GUARD_ALLOW) + " if state['valid'] is True else " + repr(GUARD_DENY) + ")\n"
                    "sys.stdout.flush()\nsys.exit(0 if state['valid'] is True else 41)\n")
    (project / "fictional_guard.py").write_text(guard_script)
    capture.save("fictional_guard.py", guard_script.encode())
    guard_arguments = {**arguments, "cmd": "/usr/bin/python3 fictional_guard.py"}
    receipts, state = [], {"count": 0, "bytes": 0, "stage": 0, "tool_result": None,
                          "recovery_results": {}, "delivery_transitions": []}

    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            self.request.settimeout(2)
            state["count"] += 1
            name = f"http-{state['count']:03d}"
            receipt, raw = {"id": name, "started_ns": time.monotonic_ns(), "stage": state["stage"]}, b""
            try:
                header, total = [], 0
                while True:
                    line = self.rfile.readline(HEADER_LIMIT + 1)
                    total += len(line)
                    if not line or total > HEADER_LIMIT or time.monotonic_ns() - receipt["started_ns"] > 3_000_000_000:
                        raise ValueError("HTTP header incomplete/limit")
                    header.append(line)
                    if line == b"\r\n":
                        break
                method, path, _ = header[0].decode("ascii").strip().split(" ")
                values = {}
                for line in header[1:-1]:
                    key, value = line.decode("ascii").strip().split(":", 1)
                    key = key.lower()
                    if key in values:
                        raise ValueError("duplicate HTTP header")
                    values[key] = value.strip()
                length = int(values.get("content-length", "0"))
                receipt.update(method=method, path=path, declared_bytes=length,
                               headers={k: "[REDACTED]" if k == "authorization" else v
                                        for k, v in values.items() if k in
                                        {"host", "content-type", "content-length", "authorization", "user-agent", "x-request-id"}})
                if length < 0 or length > BODY_LIMIT or state["bytes"] + length > TOTAL_LIMIT or state["count"] > REQUEST_LIMIT or "transfer-encoding" in values:
                    raise ValueError("HTTP admission/framing limit")
                state["bytes"] += length
                while len(raw) < length:
                    if time.monotonic_ns() - receipt["started_ns"] > 5_000_000_000:
                        raise ValueError("HTTP body deadline")
                    chunk = self.rfile.read1(min(65536, length - len(raw)))
                    if not chunk:
                        raise ValueError("incomplete HTTP body")
                    capture.save(name + f".request.chunk-{len(raw):07d}.bin", chunk)
                    raw += chunk
                capture.save(name + ".request.bin", raw)
                receipt["request_sha256"] = digest(raw)
                request = json.loads(raw)
                if method != "POST" or path != "/v1/responses":
                    raise ValueError("unexpected endpoint; remote compact shape not validated: " + path)
                if not isinstance(request, dict) or not isinstance(request.get("input"), list):
                    raise ValueError("unknown Responses shape")
                rendered = json.dumps(request, ensure_ascii=False)
                strings = list(text_values(request))
                receipt["markers"] = {label: any(marker in text for text in strings) for label, marker in
                                      {"base": BASE, "developer": DEVELOPER, "agents": AGENT,
                                       "first_user": FIRST, "second_user": SECOND, "compact_trigger": TRIGGER,
                                       "tool": TOOL_TEXT, "tool_unique": "CSR_COMPACT_TOOL_UNIQUE_01601",
                                       "summary": SUMMARY, "recovery_user": RECOVER}.items()}
                callbacks = [item for item in request["input"] if isinstance(item, dict)
                             and item.get("type") == "function_call_output"]
                stage = state["stage"]
                tools = [tool.get("name") for tool in request.get("tools", []) if isinstance(tool, dict)]
                receipt["declared_tool_names"] = tools
                if stage in (0, 4, 5, 6) and "exec_command" not in tools:
                    raise ValueError("actual advertised exec_command tool unavailable")
                if stage == 0:
                    if FIRST not in rendered or callbacks:
                        raise ValueError("first user/empty callback boundary failed")
                    chunks = sse(name, arguments=arguments)
                elif stage == 1:
                    if len(callbacks) != 1 or callbacks[0].get("call_id") != CALL:
                        raise ValueError("exact diagnostic callback missing")
                    result = output_text(callbacks[0])
                    if not result.endswith(TOOL_TEXT):
                        raise ValueError("exact diagnostic stdout changed")
                    state["tool_result"] = result
                    capture.save("diagnostic.callback.txt", result.encode())
                    chunks = sse(name, text=FINAL_FIRST)
                elif stage == 2:
                    if TRIGGER not in rendered or len(callbacks) != 1 or output_text(callbacks[0]) != state["tool_result"]:
                        raise ValueError("compact request lacks trigger/exact historical callback")
                    chunks = sse(name, text=SUMMARY)
                    guard_path.write_bytes(pack({"valid": False, "scope": "fictional_fixture_only", "epoch": 1,
                                                  "reason": "CLI compaction deliberately lost exact tool output"}))
                    state["delivery_transitions"].append({"request": name, "state": "invalidated",
                        "span_utf8": [0, len(TOOL_TEXT.encode())], "sha256": digest(TOOL_TEXT.encode()),
                        "reason": "mock summary omits exact span; not model internal retention"})
                elif stage == 3:
                    if SECOND not in rendered or SUMMARY not in rendered or callbacks or receipt["markers"]["tool_unique"]:
                        raise ValueError("postcompact summary/second user/intentional output loss failed")
                    chunks = sse(name, text=FINAL_SECOND)
                elif stage in (4, 5, 6, 7):
                    if RECOVER not in rendered:
                        raise ValueError("third recovery user turn absent")
                    results = {}
                    for item in callbacks:
                        call_id = item.get("call_id")
                        if call_id in results:
                            raise ValueError("duplicate recovery callback")
                        results[call_id] = output_text(item)
                    if set(results) != set(RECOVERY_CALLS[:stage - 4]):
                        raise ValueError("missing/unexpected recovery callbacks")
                    if any(results.get(key) != value for key, value in state["recovery_results"].items()):
                        raise ValueError("historical recovery callback changed")
                    if stage == 4:
                        if json.loads(guard_path.read_bytes())["valid"] is not False:
                            raise ValueError("guard delivery was not invalidated")
                        chunks = sse(name, arguments=guard_arguments, call_id=RECOVERY_CALLS[0])
                    elif stage == 5:
                        denied = results[RECOVERY_CALLS[0]]
                        if not denied.endswith(GUARD_DENY) or "41" not in denied:
                            raise ValueError("fixture guard denial stdout/exit mismatch")
                        state["recovery_results"].update(results)
                        capture.save("guard-denied.callback.txt", denied.encode())
                        chunks = sse(name, arguments=arguments, call_id=RECOVERY_CALLS[1])
                    elif stage == 6:
                        reread = results[RECOVERY_CALLS[1]]
                        if not reread.endswith(TOOL_TEXT):
                            raise ValueError("exact recovery span changed")
                        state["recovery_results"].update(results)
                        capture.save("reread.callback.txt", reread.encode())
                        transition = {"request": name, "state": "restored_observed_provider_delivery",
                                      "span_utf8": [0, len(TOOL_TEXT.encode())], "sha256": digest(TOOL_TEXT.encode()),
                                      "call_id": RECOVERY_CALLS[1], "model_internal_retention": "UNKNOWN"}
                        state["delivery_transitions"].append(transition)
                        guard_path.write_bytes(pack({"valid": True, "scope": "fictional_fixture_only", "epoch": 1,
                                                      "observed_span": transition}))
                        chunks = sse(name, arguments=guard_arguments, call_id=RECOVERY_CALLS[2])
                    else:
                        allowed = results[RECOVERY_CALLS[2]]
                        if not allowed.endswith(GUARD_ALLOW) or json.loads(guard_path.read_bytes())["valid"] is not True:
                            raise ValueError("fixture recovered guard success mismatch")
                        state["recovery_results"].update(results)
                        capture.save("guard-allowed.callback.txt", allowed.encode())
                        chunks = sse(name, text=FINAL_RECOVERY)
                else:
                    raise ValueError("unexpected additional model request")
                body = b"".join(chunks)
                capture.save(name + ".response.bin", body)
                self.wfile.write(b"HTTP/1.1 200 Synthetic\r\nContent-Type: text/event-stream\r\nContent-Length: " +
                                 str(len(body)).encode() + b"\r\nConnection: close\r\n\r\n")
                for index, chunk in enumerate(chunks):
                    capture.save(name + f".response.chunk-{index:03d}.bin", chunk)
                    self.wfile.write(chunk)
                    self.wfile.flush()
                receipt.update(status=200, response_sha256=digest(body), sent_complete=True)
                state["stage"] += 1
            except (OSError, ValueError, TypeError, KeyError) as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
                if not (out / (name + ".request.bin")).exists():
                    capture.save(name + ".request.bin", raw)
            finally:
                receipt["ended_ns"] = time.monotonic_ns()
                receipts.append(receipt)

    server = socketserver.TCPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    config = ('model="synthetic"\nmodel_provider="mock"\napproval_policy="never"\n'
              'sandbox_mode="danger-full-access"\ncompact_prompt=' + json.dumps(TRIGGER) + '\n'
              '[analytics]\nenabled=false\n[features]\nremote_compaction_v2=false\n'
              '[model_providers.mock]\nname="Synthetic loopback"\nwire_api="responses"\n'
              f'base_url="http://127.0.0.1:{server.server_address[1]}/v1"\n'
              'requires_openai_auth=false\nrequest_max_retries=0\nstream_max_retries=0\n')
    (code_home / "config.toml").write_text(config)
    capture.save("config-snapshot.toml", config.encode())
    environment = {"HOME": str(home), "CODEX_HOME": str(code_home), "PATH": "/usr/bin:/bin",
                   "TMPDIR": str(home), "NO_COLOR": "1", "LANG": "C.UTF-8"}
    command = [str(cli), "app-server", "--listen", "stdio://"]
    capture.document("launch.json", {"argv": command, "cwd": str(project), "environment": environment,
                                     "outer_confinement": "caller WSL/bwrap --unshare-all",
                                     "cli_sandbox": "danger-full-access inside caller confinement"})
    rpc, failure, thread_id, turns, compact_event, version_ok = None, None, None, [], None, False
    try:
        version = subprocess.run([str(cli), "--version"], cwd=project, env=environment,
                                 capture_output=True, timeout=4, check=False)
        capture.save("cli-version.stdout.bin", version.stdout)
        capture.save("cli-version.stderr.bin", version.stderr)
        version_ok = version.returncode == 0 and version.stdout.strip() == b"codex-cli 0.160.1"
        if not version_ok:
            raise RuntimeError("CLI version not exactly 0.160.1")
        rpc = Rpc(command, project, environment, capture)
        rpc.call(1, "initialize", {"clientInfo": {"name": "csr-mock-compaction", "version": "1"},
                                   "capabilities": {"experimentalApi": True}})
        rpc.send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
        started = rpc.call(2, "thread/start", {"cwd": str(project), "ephemeral": True,
                           "model": "synthetic", "modelProvider": "mock", "approvalPolicy": "never",
                           "sandbox": "danger-full-access", "baseInstructions": BASE,
                           "developerInstructions": DEVELOPER})
        thread_id = started["thread"]["id"]
        if not isinstance(thread_id, str) or not thread_id:
            raise ValueError("thread/start lacks thread id")
        first = rpc.call(3, "turn/start", {"threadId": thread_id, "input": [{"type": "text", "text": FIRST}]})
        turns.append(first["turn"]["id"])
        rpc.await_event(lambda e: e.get("method") == "turn/completed" and
                        e.get("params", {}).get("turn", {}).get("id") == turns[0])
        rpc.call(4, "thread/compact/start", {"threadId": thread_id})
        compact_event = rpc.await_event(lambda e: e.get("method") == "thread/compacted" or
            (e.get("method") == "item/completed" and e.get("params", {}).get("item", {}).get("type") == "contextCompaction"))
        if compact_event.get("params", {}).get("threadId") != thread_id:
            raise ValueError("compaction notification belongs to another thread")
        second = rpc.call(5, "turn/start", {"threadId": thread_id, "input": [{"type": "text", "text": SECOND}]})
        turns.append(second["turn"]["id"])
        rpc.await_event(lambda e: e.get("method") == "turn/completed" and
                        e.get("params", {}).get("turn", {}).get("id") == turns[1])
        recovery = rpc.call(6, "turn/start", {"threadId": thread_id, "input": [{"type": "text", "text": RECOVER}]})
        turns.append(recovery["turn"]["id"])
        rpc.await_event(lambda e: e.get("method") == "turn/completed" and
                        e.get("params", {}).get("turn", {}).get("id") == turns[2])
    except (RuntimeError, ValueError, OSError, KeyError, TypeError, subprocess.TimeoutExpired) as exc:
        failure = type(exc).__name__ + ": " + str(exc)
    finally:
        if rpc is not None:
            rpc.close()
        server.shutdown()
        thread.join(timeout=2)
        server.server_close()
    events = rpc.events if rpc else []
    items = [event.get("params", {}).get("item", {}) for event in events if event.get("method") == "item/completed"]
    commands = [item for item in items if item.get("type") == "commandExecution"]
    messages = [item.get("text") for item in items if item.get("type") == "agentMessage"]
    reads = [item for item in commands if "fictional_diagnostic.py" in item.get("command", "")]
    guards = [item for item in commands if "fictional_guard.py" in item.get("command", "")]
    finished_user_turns = [event.get("params", {}) for event in events if event.get("method") == "turn/completed"
                           and event.get("params", {}).get("turn", {}).get("id") in turns]
    checks = {"cli_version_01601": version_ok,
              "no_process_or_capture_failure": failure is None and rpc is not None and not rpc.errors and rpc.process.returncode == 0,
              "exact_native_diagnostic_read_and_reread": len(reads) == 2 and all(item.get("aggregatedOutput") == TOOL_TEXT and item.get("exitCode") == 0 for item in reads),
              "same_thread_three_distinct_completed_user_turns": bool(thread_id) and len(turns) == 3 and len(set(turns)) == 3 and len(finished_user_turns) == 3
                  and all(item.get("threadId") == thread_id and item.get("turn", {}).get("status") == "completed" for item in finished_user_turns),
              "explicit_cli_compaction_notification": compact_event is not None,
              "eight_complete_responses": len(receipts) == 8 and state["stage"] == 8 and all(r.get("sent_complete") and not r.get("error") for r in receipts),
              "exact_full_callback_entered_compaction_request": state["tool_result"] is not None and state["stage"] >= 3,
              "summary_and_intentional_tool_loss_observed_after_compaction": state["stage"] >= 4,
              "base_developer_agents_delivered_every_request": len(receipts) == 8 and all(all(r.get("markers", {}).get(k) for k in ("base", "developer", "agents")) for r in receipts),
              "fixture_guard_denies_then_allows_after_exact_delivery": len(guards) == 2 and guards[0].get("aggregatedOutput") == GUARD_DENY and guards[0].get("exitCode") == 41
                  and guards[1].get("aggregatedOutput") == GUARD_ALLOW and guards[1].get("exitCode") == 0,
              "exact_span_restored_only_after_provider_reread_callback": len(state["delivery_transitions"]) == 2 and state["stage"] == 8,
              "exact_three_final_messages": messages == [FINAL_FIRST, FINAL_SECOND, FINAL_RECOVERY],
              "all_blob_hashes": all(digest((out / name).read_bytes()) == row["sha256"] for name, row in capture.inventory.items())}
    capture.document("http-receipts.json", receipts)
    capture.document("fictional-delivery-transitions.json", state["delivery_transitions"])
    capture.save("fictional-delivery-state-final.json", guard_path.read_bytes())
    capture.document("rpc-events.json", {"events": events, "errors": rpc.errors if rpc else [], "failure": failure,
                                        "thread_id": thread_id, "user_turn_ids": turns, "compact_event": compact_event})
    summary = {"passed": all(checks.values()), "checks": checks, "failure": failure, "synthetic_only": True,
               "preflight": facts, "inventory": capture.inventory.copy(),
               "limits": ["Actual CLI compaction task; every provider response and usage is synthetic",
                          "Exact transport presence/loss does not prove model retention or AC5",
                          "Local compaction via Responses only; unexpected remote compact endpoint fails closed",
                          "Three user turns in one app-server process; persistent resume not exercised",
                          "Guard denial/allow are explicit fixture mechanics; no model refusal or compliance proof",
                          "Span restored only as observed provider transport delivery; model retention UNKNOWN",
                          "Fictional summary deliberately omits exact diagnostic output",
                          "Outer confinement supplied by caller; no exclusive native tool inventory claim",
                          "No campaign, frozen evidence, thresholds or canonical skills changed"]}
    capture.document("summary.json", summary)
    return {"passed": summary["passed"], "summary_sha256": digest((out / "summary.json").read_bytes()), "failure": failure}


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
