"""Single Codex Linux conversation with synthetic native-tool continuity.

UNVALIDATED until executed with the installed CLI inside existing WSL bwrap
--unshare-all. No downloads, real model, credentials or routing campaign.
The caller mounts this source, a chosen ELF, and a writable output parent.
"""
import argparse
import errno
import hashlib
import json
import os
from pathlib import Path
import selectors
import signal
import socket
import socketserver
import subprocess
import threading
import time

BODY_LIMIT = 1024 * 1024
TOTAL_LIMIT = 8 * BODY_LIMIT
REQUEST_LIMIT = 8
HEADER_LIMIT = 8192
STREAM_LIMIT = 2 * BODY_LIMIT
TIMEOUT = 75
INSTRUCTION = "Synthetic continuity demonstration. Execute only the supplied fictional diagnostic tools."


def blob_hash(raw):
    return hashlib.sha256(raw).hexdigest()


def pack(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


class Capture:
    def __init__(self, out):
        self.out = out
        self.inventory = {}
        self.lock = threading.Lock()

    def save(self, name, raw):
        with self.lock:
            with (self.out / name).open("xb") as stream:
                stream.write(raw)
                stream.flush()
            self.inventory[name] = {"bytes": len(raw), "sha256": blob_hash(raw)}

    def document(self, name, value):
        self.save(name, pack(value))


def preflight(cli):
    if os.name != "posix" or not Path("/proc/net/dev").is_file():
        raise RuntimeError("requires existing isolated Linux namespace")
    if not cli.is_absolute() or not cli.is_file():
        raise RuntimeError("--cli requires an existing absolute Linux ELF path")
    with cli.open("rb") as stream:
        if stream.read(4) != b"\x7fELF":
            raise RuntimeError("CLI must be Linux ELF; Windows PE and launchers refused")
    interfaces = [line.split(":", 1)[0].strip() for line in Path("/proc/net/dev").read_text().splitlines()[2:]]
    if interfaces != ["lo"]:
        raise RuntimeError("network namespace must expose only lo")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as connection:
        connection.settimeout(0.2)
        error = connection.connect_ex(("203.0.113.1", 9))
    if error != errno.ENETUNREACH:
        raise RuntimeError("non-loopback route denial unproved: errno=" + str(error))
    return {"interfaces": interfaces, "nonloopback_probe_errno": error,
            "network_probe": "ENETUNREACH before CLI launch", "cli_sha256": blob_hash(cli.read_bytes()),
            "source_sha256": blob_hash(Path(__file__).read_bytes()), "cli_format": "Linux ELF"}


def responses_sse(identifier):
    part = {"type": "output_text", "text": "synthetic completed", "annotations": []}
    item = {"id": "msg_" + identifier, "type": "message", "role": "assistant", "status": "completed", "content": [part]}
    response = {"id": "resp_" + identifier, "object": "response", "created_at": 0,
                "status": "completed", "model": "synthetic", "output": [item],
                "usage": {"input_tokens": 10, "output_tokens": 2, "total_tokens": 12,
                          "input_tokens_details": {"cached_tokens": 0}, "output_tokens_details": {"reasoning_tokens": 0}}}
    events = [
        {"type": "response.created", "response": {**response, "status": "in_progress", "output": []}},
        {"type": "response.output_item.added", "output_index": 0, "item": {**item, "status": "in_progress", "content": []}},
        {"type": "response.content_part.added", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": {**part, "text": ""}},
        {"type": "response.output_text.delta", "item_id": item["id"], "output_index": 0, "content_index": 0, "delta": part["text"]},
        {"type": "response.output_text.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "text": part["text"]},
        {"type": "response.content_part.done", "item_id": item["id"], "output_index": 0, "content_index": 0, "part": part},
        {"type": "response.output_item.done", "output_index": 0, "item": item},
        {"type": "response.completed", "response": response},
    ]
    return [b"event: " + event["type"].encode() + b"\ndata: " + pack({**event, "sequence_number": index}) + b"\n\n"
            for index, event in enumerate(events)]


def observe_process(command, cwd, environment, capture, label):
    started = time.monotonic_ns()
    process = subprocess.Popen(command, cwd=cwd, env=environment, stdin=subprocess.DEVNULL,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    selector = selectors.DefaultSelector()
    for stream, name in [(process.stdout, "stdout"), (process.stderr, "stderr")]:
        os.set_blocking(stream.fileno(), False)
        selector.register(stream, selectors.EVENT_READ, name)
    chunks = {"stdout": [], "stderr": []}
    records, errors = [], []
    deadline = time.monotonic() + TIMEOUT
    try:
        while selector.get_map():
            if time.monotonic() >= deadline:
                errors.append("process timeout")
                os.killpg(process.pid, signal.SIGKILL)
                break
            for key, _ in selector.select(timeout=min(0.2, max(0, deadline - time.monotonic()))):
                raw = os.read(key.fileobj.fileno(), 65536)
                if not raw:
                    selector.unregister(key.fileobj)
                    continue
                name = key.data
                if sum(map(len, chunks[name])) + len(raw) > STREAM_LIMIT:
                    errors.append(name + " admission limit")
                    os.killpg(process.pid, signal.SIGKILL)
                    break
                filename = label + f".{name}.chunk-{len(chunks[name]):04d}.bin"
                capture.save(filename, raw)  # Before JSON parsing, including error streams.
                chunks[name].append(raw)
                records.append({"stream": name, "blob": filename, "received_ns": time.monotonic_ns()})
            if errors: break
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            errors.append("process wait timeout after streams closed")
            os.killpg(process.pid, signal.SIGKILL)
            process.wait(timeout=2)
    finally:
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait(timeout=2)
        selector.close()
        for stream in (process.stdout, process.stderr): stream.close()
    for name, parts in chunks.items(): capture.save(label + "." + name + ".bin", b"".join(parts))
    return {"label": label, "started_ns": started, "ended_ns": time.monotonic_ns(),
            "exit_code": process.returncode, "errors": errors, "chunks": records}


SUCCESS = 'fictional-tool-success\nexact snowman: \u2603\nquote: " backslash: \\\nend-success\n'
ERROR = "fictional-tool-error\ncontrolled exit 23\n"
DENIED = "fictional-tool-refusal-MUST-NOT-EXECUTE"
FINAL = "synthetic continuity completed"
CALLS = ["call_fictional_success", "call_fictional_error", "call_fictional_refusal"]


def function_sse(identifier, call_id, arguments):
    item = {"type": "function_call", "id": "fc_" + identifier,
            "call_id": call_id, "name": "exec_command",
            "arguments": json.dumps(arguments, ensure_ascii=False, separators=(",", ":")),
            "status": "completed"}
    response = {"id": "resp_" + identifier, "object": "response", "created_at": 0,
                "status": "completed", "model": "synthetic", "output": [item],
                "usage": {"input_tokens": 10, "output_tokens": 2, "total_tokens": 12,
                          "input_tokens_details": {"cached_tokens": 0},
                          "output_tokens_details": {"reasoning_tokens": 0}}}
    events = [
        {"type": "response.created", "response": {**response, "status": "in_progress", "output": []}},
        {"type": "response.output_item.added", "output_index": 0,
         "item": {**item, "status": "in_progress", "arguments": ""}},
        {"type": "response.function_call_arguments.delta", "item_id": item["id"],
         "output_index": 0, "delta": item["arguments"]},
        {"type": "response.function_call_arguments.done", "item_id": item["id"],
         "output_index": 0, "arguments": item["arguments"]},
        {"type": "response.output_item.done", "output_index": 0, "item": item},
        {"type": "response.completed", "response": response},
    ]
    return [b"event: " + event["type"].encode() + b"\ndata: " + pack({**event, "sequence_number": index}) + b"\n\n"
            for index, event in enumerate(events)]


def result_text(item):
    value = item.get("output")
    if isinstance(value, str):
        return value
    if isinstance(value, list) and all(isinstance(part, dict) and part.get("type") == "input_text"
                                       and isinstance(part.get("text"), str) for part in value):
        return "".join(part["text"] for part in value)
    raise ValueError("unsupported function output representation")


def run(cli, out, facts, preflight_only):
    began = time.monotonic_ns()
    capture = Capture(out)
    capture.save("source-snapshot.py", Path(__file__).read_bytes())
    capture.document("preflight.json", facts)
    if preflight_only:
        capture.document("summary.json", {"preflight_only": True, "cli_launched": False, **facts})
        return {"preflight_only": True, "cli_launched": False}
    home, project = out / "synthetic-home", out / "synthetic-project"
    home.mkdir()
    project.mkdir()
    code_home = home / "codex"
    code_home.mkdir()
    # No shell interpolation of supplied text; literals are JSON encoded into Python source.
    scripts = ["import sys;sys.stdout.write(" + json.dumps(SUCCESS) + ");sys.stdout.flush()",
               "import sys;sys.stdout.write(" + json.dumps(ERROR) + ");sys.stdout.flush();sys.exit(23)",
               "import sys;sys.stdout.write(" + json.dumps(DENIED + "\n") + ");sys.stdout.flush()"]
    names = ["fictional_success.py", "fictional_error.py", "fictional_refusal.py"]
    for name, script in zip(names, scripts):
        (project / name).write_text(script + "\n")
        capture.save(name, (script + "\n").encode())
    arguments = [{"cmd": "/usr/bin/python3 " + name, "workdir": str(project),
                  "shell": "/bin/sh", "login": False, "max_output_tokens": 1000,
                  "yield_time_ms": 1000} for name in names]
    arguments[2].update(sandbox_permissions="require_escalated",
                        justification="Synthetic refusal probe; never execute under approval_policy=never")
    capture.document("fictional-tool-plan.json", {"call_ids": CALLS, "arguments": arguments,
                     "success_stdout": SUCCESS, "error_stdout": ERROR, "error_exit": 23,
                     "refusal_forbidden_stdout": DENIED})
    state = {"count": 0, "bytes": 0, "stage": 0, "retry_failed": False,
             "retry_raw": None, "results": {}, "seen": []}
    receipts = []
    lock = threading.Lock()

    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            self.request.settimeout(2)
            started = time.monotonic_ns()
            with lock:
                state["count"] += 1
                identifier = f"http-{state['count']:03d}"
                count = state["count"]
                stage = state["stage"]
            receipt = {"id": identifier, "stage": stage, "started_ns": started,
                       "destination": list(self.server.server_address),
                       "body_captured_before_json_parse": True}
            raw = b""
            try:
                lines, size = [], 0
                while True:
                    line = self.rfile.readline(HEADER_LIMIT + 1)
                    size += len(line)
                    if not line or size > HEADER_LIMIT or time.monotonic_ns() - started > 3_000_000_000:
                        raise ValueError("header limit/incomplete/deadline")
                    lines.append(line)
                    if line == b"\r\n":
                        break
                method, path, _ = lines[0].decode("ascii").strip().split(" ")
                values = {}
                for line in lines[1:-1]:
                    name, value = line.decode("ascii").strip().split(":", 1)
                    name = name.lower()
                    if name in values:
                        raise ValueError("duplicate header")
                    values[name] = value.strip()
                allow = {"host", "content-type", "content-length", "authorization", "user-agent", "x-request-id"}
                receipt.update(method=method, path=path,
                    headers={key: "[REDACTED]" if key == "authorization" else val
                             for key, val in values.items() if key in allow})
                length = int(values.get("content-length", "0"))
                if length < 0 or "transfer-encoding" in values:
                    raise ValueError("unsupported framing")
                with lock:
                    refused = count > REQUEST_LIMIT or length > BODY_LIMIT or state["bytes"] + length > TOTAL_LIMIT
                    if not refused:
                        state["bytes"] += length
                receipt.update(declared_body_bytes=length, admission="refused" if refused else "accepted")
                if not refused:
                    while len(raw) < length:
                        if time.monotonic_ns() - started > 5_000_000_000:
                            raise ValueError("body deadline")
                        chunk = self.rfile.read1(min(65536, length - len(raw)))
                        if not chunk:
                            raise ValueError("incomplete body")
                        capture.save(identifier + f".request.chunk-{len(raw):07d}.bin", chunk)
                        raw += chunk
                capture.save(identifier + ".request.bin", raw)
                receipt["request_sha256"] = blob_hash(raw)
                if refused:
                    status, chunks = 413, [pack({"error": {"message": "synthetic admission limit"}})]
                elif method != "POST" or path != "/v1/responses":
                    status, chunks = 400, [pack({"error": {"message": "unexpected endpoint"}})]
                else:
                    request = json.loads(raw)
                    if not isinstance(request, dict) or not isinstance(request.get("input"), list):
                        raise ValueError("request/input shape")
                    receipt["instruction_present"] = INSTRUCTION in json.dumps(request, ensure_ascii=False)
                    tools = [tool.get("name") for tool in request.get("tools", []) if isinstance(tool, dict)]
                    receipt["declared_tools"] = tools
                    if "exec_command" not in tools or not receipt["instruction_present"]:
                        raise ValueError("required tool/instruction absent")
                    input_items = request["input"]
                    results = {}
                    for item in input_items:
                        if isinstance(item, dict) and item.get("type") == "function_call_output":
                            call_id = item.get("call_id")
                            if call_id in results:
                                raise ValueError("duplicate callback")
                            results[call_id] = result_text(item)
                    if set(results) != set(CALLS[:stage]):
                        raise ValueError("missing/unexpected callbacks: " + str(sorted(results)))
                    for call_id, previous in state["results"].items():
                        if results.get(call_id) != previous:
                            raise ValueError("previous callback changed")
                    if stage:
                        latest = CALLS[stage - 1]
                        text = results[latest]
                        if stage == 1 and not text.endswith(SUCCESS):
                            raise ValueError("success exact stdout suffix mismatch")
                        if stage == 2 and (not text.endswith(ERROR) or "23" not in text):
                            raise ValueError("controlled error exact stdout/exit mismatch")
                        if stage == 3 and (DENIED in text or
                                not any(word in text.lower() for word in ("reject", "denied", "never", "approval policy"))):
                            raise ValueError("refusal output missing or forbidden command executed")
                        if latest not in state["results"]:
                            state["results"][latest] = text
                            capture.save(latest + ".result.txt", text.encode())
                    receipt["callback_sha256"] = {key: blob_hash(value.encode()) for key, value in results.items()}
                    state["seen"].append({"stage": stage, "request": identifier, "callbacks": receipt["callback_sha256"]})
                    if stage == 1 and not state["retry_failed"]:
                        state["retry_failed"] = True
                        state["retry_raw"] = raw
                        status, chunks = 503, [pack({"error": {"message": "synthetic retry", "type": "server_error"}})]
                    else:
                        if stage == 1 and raw != state["retry_raw"]:
                            raise ValueError("HTTP retry request changed")
                        if stage < len(CALLS):
                            chunks = function_sse(identifier, CALLS[stage], arguments[stage])
                        elif stage == len(CALLS):
                            chunks = [chunk.replace(b"synthetic completed", FINAL.encode())
                                      for chunk in responses_sse(identifier)]
                        else:
                            raise ValueError("unexpected conversation continuation")
                        status = 200
                        state["stage"] += 1
                body = b"".join(chunks)
                capture.save(identifier + ".response.bin", body)
                response_headers = {"Content-Type": "text/event-stream" if status == 200 else "application/json",
                                    "Content-Length": str(len(body)), "Connection": "close",
                                    "X-Request-ID": identifier, "Retry-After": "0"}
                receipt.update(status=status, response_headers=response_headers,
                               response_sha256=blob_hash(body), usage_label="fictional_synthetic_usage")
                self.wfile.write(f"HTTP/1.1 {status} Synthetic\r\n".encode() +
                    b"".join(f"{key}: {value}\r\n".encode() for key, value in response_headers.items()) + b"\r\n")
                for index, chunk in enumerate(chunks):
                    capture.save(identifier + f".response.chunk-{index:03d}.bin", chunk)
                    self.wfile.write(chunk)
                    self.wfile.flush()
                receipt["sent_complete"] = True
            except (ValueError, TypeError, OSError) as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
                if not (out / (identifier + ".request.bin")).exists():
                    capture.save(identifier + ".request.bin", raw)
                # Close the transport without advancing a successful proof stage.
            finally:
                receipt["ended_ns"] = time.monotonic_ns()
                with lock:
                    receipts.append(receipt)

    class Server(socketserver.TCPServer):
        pass

    server = Server(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    config = ('model = "synthetic"\nmodel_provider = "mock"\napproval_policy = "never"\n'
              'sandbox_mode = "danger-full-access"\n[analytics]\nenabled = false\n'
              '[model_providers.mock]\nname = "Synthetic loopback"\nwire_api = "responses"\n'
              f'base_url = "http://127.0.0.1:{server.server_address[1]}/v1"\n'
              'requires_openai_auth = false\nrequest_max_retries = 1\nstream_max_retries = 0\n')
    (code_home / "config.toml").write_text(config)
    capture.save("config-snapshot.toml", config.encode())
    environment = {"HOME": str(home), "CODEX_HOME": str(code_home), "PATH": "/usr/bin:/bin",
                   "TMPDIR": str(home), "NO_COLOR": "1", "LANG": "C.UTF-8"}
    processes, version_ok = [], False
    try:
        version = observe_process([str(cli), "--version"], project, environment, capture, "cli-version")
        capture.document("cli-version.receipt.json", version)
        version_ok = version["exit_code"] == 0 and b"0.160.1" in (out / "cli-version.stdout.bin").read_bytes()
        if not version_ok:
            raise RuntimeError("expected CLI 0.160.1 version proof failed")
        command = [str(cli), "exec", "--json", "--ephemeral", "--skip-git-repo-check",
                   "--sandbox", "danger-full-access", "-c", 'approval_policy="never"', INSTRUCTION]
        capture.document("continuity.launch.json", {"argv": command, "cwd": str(project),
                         "environment": environment, "confinement": "caller bwrap namespace",
                         "cli_sandbox": "danger-full-access inside outer bwrap only"})
        processes.append(observe_process(command, project, environment, capture, "continuity"))
    finally:
        server.shutdown()
        thread.join(timeout=2)
        server.server_close()
    capture.document("http-receipts.json", receipts)
    capture.document("process-receipts.json", processes)
    events, parse_errors = [], []
    for index, line in enumerate((out / "continuity.stdout.bin").read_bytes().splitlines()):
        if not line.strip():
            continue
        try:
            event = json.loads(line)
            if not isinstance(event, dict):
                raise ValueError("JSONL event not object")
            events.append(event)
        except ValueError as exc:
            parse_errors.append({"line": index, "error": str(exc)})
    completed = [event.get("item", {}) for event in events if event.get("type") == "item.completed"]
    commands = [item for item in completed if item.get("type") == "command_execution"]
    messages = [item.get("text") for item in completed if item.get("type") == "agent_message"]
    threads = [event.get("thread_id") for event in events if event.get("type") == "thread.started"]
    execution_checks = {}
    for index, expected in enumerate((SUCCESS, ERROR)):
        matches = [item for item in commands if names[index] in item.get("command", "")]
        execution_checks[CALLS[index]] = len(matches) == 1 and matches[0].get("aggregated_output") == expected and matches[0].get("exit_code") == (0 if index == 0 else 23)
    refusal_executions = [item for item in commands if names[2] in item.get("command", "")]
    capture.document("parsed-cli-events.json", {"events": events, "parse_errors": parse_errors,
                     "execution_checks": execution_checks, "refusal_executions": refusal_executions})
    checks = {"cli_version_01601": version_ok,
              "single_process_success": len(processes) == 1 and processes[0]["exit_code"] == 0 and not processes[0]["errors"],
              "single_thread_single_turn": len(threads) == 1 and bool(threads[0]) and
                  sum(event.get("type") == "turn.started" for event in events) == 1 and
                  sum(event.get("type") == "turn.completed" for event in events) == 1,
              "exact_actual_command_outputs": all(execution_checks.values()),
              "all_callbacks_received": set(state["results"]) == set(CALLS),
              "refused_command_not_executed": not refusal_executions and DENIED.encode() not in (out / "continuity.stdout.bin").read_bytes(),
              "ordered_http_200_503_200_200_200": [receipt.get("status") for receipt in receipts] == [200, 503, 200, 200, 200],
              "all_stages_completed": state["stage"] == 4,
              "all_http_capture_complete": len(receipts) == 5 and all(receipt.get("sent_complete") and not receipt.get("error") for receipt in receipts),
              "all_requests_preserve_instruction": bool(receipts) and all(receipt.get("instruction_present") for receipt in receipts),
              "exact_final_agent_message": messages == [FINAL] and not parse_errors,
              "all_blob_hashes": all(blob_hash((out / name).read_bytes()) == item["sha256"] for name, item in capture.inventory.items())}
    summary = {"synthetic_only": True, "passed": all(checks.values()), "checks": checks,
               "preflight": facts, "duration_ns": time.monotonic_ns() - began,
               "inventory": capture.inventory.copy(), "callbacks": state["seen"],
               "integration_status": "actual_single_cli_thread_native_callbacks" if all(checks.values()) else "unvalidated_or_failed",
               "limits": ["Entire provider output simulated; no actual model retention or AC5 proof",
                          "Single exec turn with successive native callbacks; no resume/user second turn",
                          "Only fictional diagnostic Python commands and escalation refusal exercised",
                          "Exact stdout verified against CLI JSONL and next-request output suffix; runtime wrapper varies",
                          "Full function output preserved unchanged across all later requests, including 503 retry",
                          "CLI sandbox danger-full-access; external caller supplies WSL/bwrap --unshare-all confinement",
                          "HTTP headers normalized/allowlisted/auth redacted; no TCP/TLS sniffer",
                          "Usage fictional; no routing campaign, thresholds or sealed corpus changed"]}
    capture.document("summary.json", summary)
    return {"passed": summary["passed"], "summary_sha256": blob_hash((out / "summary.json").read_bytes()),
            "duration_seconds": summary["duration_ns"] / 1e9}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--preflight-only", action="store_true")
    args = parser.parse_args()
    facts = preflight(args.cli)
    args.out.mkdir(parents=False, exist_ok=False)
    result = run(args.cli, args.out.resolve(), facts, args.preflight_only)
    print(json.dumps(result))
    raise SystemExit(0 if result.get("passed", args.preflight_only) else 1)


if __name__ == "__main__":
    main()
