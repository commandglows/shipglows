"""Prospective Codex Linux ELF + synthetic Responses capture, stdlib only.

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
TOTAL_LIMIT = 4 * BODY_LIMIT
REQUEST_LIMIT = 8
HEADER_LIMIT = 8192
STREAM_LIMIT = 2 * BODY_LIMIT
TIMEOUT = 40
INSTRUCTION = "Synthetic capture demonstration. Respond only with synthetic completed."


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
    state = {"count": 0, "bytes": 0, "retry_failed": False, "phase": "not_started"}
    receipts, processes = [], []
    lock = threading.Lock()

    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            self.request.settimeout(2)
            started = time.monotonic_ns()
            with lock:
                state["count"] += 1
                identifier = f"http-{state['count']:03d}"
                count = state["count"]
                phase = state["phase"]
            receipt = {"id": identifier, "phase": phase, "started_ns": started,
                       "destination": list(self.server.server_address), "body_captured_before_json_parse": True}
            raw = b""
            try:
                lines, size = [], 0
                while True:
                    line = self.rfile.readline(HEADER_LIMIT + 1)
                    size += len(line)
                    if not line or size > HEADER_LIMIT or time.monotonic_ns() - started > 3_000_000_000:
                        raise ValueError("header limit/incomplete/deadline")
                    lines.append(line)
                    if line == b"\r\n": break
                method, path, _ = lines[0].decode("ascii").strip().split(" ")
                values = {}
                for line in lines[1:-1]:
                    name, value = line.decode("ascii").strip().split(":", 1)
                    name = name.lower()
                    if name in values: raise ValueError("duplicate header")
                    values[name] = value.strip()
                allow = {"host", "content-type", "content-length", "authorization", "user-agent", "x-request-id"}
                receipt.update(method=method, path=path, headers={k: "[REDACTED]" if k == "authorization" else v for k, v in values.items() if k in allow})
                length = int(values.get("content-length", "0"))
                if length < 0 or "transfer-encoding" in values: raise ValueError("unsupported framing")
                with lock:
                    refused = count > REQUEST_LIMIT or length > BODY_LIMIT or state["bytes"] + length > TOTAL_LIMIT
                    if not refused: state["bytes"] += length
                receipt.update(declared_body_bytes=length, admission="refused" if refused else "accepted")
                if not refused:
                    while len(raw) < length:
                        if time.monotonic_ns() - started > 5_000_000_000: raise ValueError("body deadline")
                        chunk = self.rfile.read1(min(65536, length - len(raw)))
                        if not chunk: raise ValueError("incomplete body")
                        capture.save(identifier + f".request.chunk-{len(raw):07d}.bin", chunk)
                        raw += chunk
                capture.save(identifier + ".request.bin", raw)
                receipt["request_sha256"] = blob_hash(raw)
                if refused:
                    status, chunks = 413, [pack({"error": {"message": "synthetic admission limit"}})]
                elif method != "POST" or path != "/v1/responses":
                    status, chunks = 400, [pack({"error": {"message": "unexpected synthetic endpoint"}})]
                else:
                    request = json.loads(raw)
                    receipt["request_fields"] = sorted(request)
                    receipt["instruction_present"] = INSTRUCTION in json.dumps(request)
                    with lock:
                        transient = phase == "iteration-two" and not state["retry_failed"]
                        if transient: state["retry_failed"] = True
                    status, chunks = (503, [pack({"error": {"message": "synthetic retry", "type": "server_error"}})]) if transient else (200, responses_sse(identifier))
                body = b"".join(chunks)
                capture.save(identifier + ".response.bin", body)
                response_headers = {"Content-Type": "text/event-stream" if status == 200 else "application/json",
                                    "Content-Length": str(len(body)), "Connection": "close", "X-Request-ID": identifier,
                                    "Retry-After": "0"}
                receipt.update(status=status, response_headers=response_headers, response_sha256=blob_hash(body),
                               usage_label="fictional_synthetic_usage")
                header = f"HTTP/1.1 {status} Synthetic\r\n".encode() + b"".join(f"{k}: {v}\r\n".encode() for k, v in response_headers.items()) + b"\r\n"
                self.wfile.write(header)
                for index, chunk in enumerate(chunks):
                    capture.save(identifier + f".response.chunk-{index:03d}.bin", chunk)
                    self.wfile.write(chunk)
                    self.wfile.flush()
                receipt["sent_complete"] = True
            except (ValueError, OSError) as exc:
                receipt["error"] = type(exc).__name__ + ": " + str(exc)
                if not (out / (identifier + ".request.bin")).exists(): capture.save(identifier + ".request.bin", raw)
            finally:
                receipt["ended_ns"] = time.monotonic_ns()
                with lock: receipts.append(receipt)

    class Server(socketserver.ThreadingTCPServer):
        daemon_threads = False
    server = Server(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    config = ('model = "synthetic"\nmodel_provider = "mock"\n'
              'disable_response_storage = true\n[analytics]\nenabled = false\n'
              '[model_providers.mock]\nname = "Synthetic loopback"\nwire_api = "responses"\n'
              f'base_url = "http://127.0.0.1:{server.server_address[1]}/v1"\n'
              'requires_openai_auth = false\nrequest_max_retries = 1\nstream_max_retries = 0\n')
    (code_home / "config.toml").write_text(config)
    capture.save("config-snapshot.toml", config.encode())
    environment = {"HOME": str(home), "CODEX_HOME": str(code_home), "PATH": "/usr/bin:/bin",
                   "TMPDIR": str(home), "NO_COLOR": "1", "LANG": "C.UTF-8"}
    try:
        version_receipt = observe_process([str(cli), "--version"], project, environment, capture, "cli-version")
        capture.document("cli-version.receipt.json", version_receipt)
        version_ok = version_receipt["exit_code"] == 0 and b"0.160.1" in (out / "cli-version.stdout.bin").read_bytes()
        if not version_ok:
            raise RuntimeError("expected CLI 0.160.1 version proof failed")
        for phase in ("iteration-one", "iteration-two"):
            state["phase"] = phase
            command = [str(cli), "exec", "--json", "--ephemeral", "--skip-git-repo-check",
                       "--sandbox", "read-only", INSTRUCTION + " " + phase]
            capture.document(phase + ".launch.json", {"argv": command, "cwd": str(project), "environment": environment})
            processes.append(observe_process(command, project, environment, capture, phase))
    finally:
        server.shutdown()
        thread.join(timeout=2)
        server.server_close()
    capture.document("http-receipts.json", receipts)
    capture.document("process-receipts.json", processes)
    visible_messages = {}
    output_errors = {}
    for process in processes:
        label = process["label"]
        messages, errors = [], []
        for index, line in enumerate((out / (label + ".stdout.bin")).read_bytes().splitlines()):
            if not line.strip(): continue
            try:
                event = json.loads(line)
                if not isinstance(event, dict): raise ValueError("JSONL event is not an object")
                item = event.get("item", {})
                if event.get("type") == "item.completed" and isinstance(item, dict) and item.get("type") == "agent_message":
                    messages.append(item.get("text"))
            except (ValueError, TypeError) as exc:
                errors.append({"line": index, "error": str(exc)})
        visible_messages[label] = messages
        output_errors[label] = errors
    capture.document("visible-agent-messages.json", {"messages": visible_messages, "parse_errors": output_errors})
    accepted_requests = [r for r in receipts if r.get("admission") == "accepted" and r.get("path") == "/v1/responses"]
    checks = {"cli_version_01601": version_ok,
              "both_processes_successful": all(p["exit_code"] == 0 and not p["errors"] for p in processes),
              "each_phase_received_instructions": all(any(r.get("instruction_present") and r["phase"] == phase for r in receipts) for phase in ("iteration-one", "iteration-two")),
              "instruction_in_every_accepted_responses_request": bool(accepted_requests) and all(r.get("instruction_present") for r in accepted_requests),
              "mock_503_then_success": [r.get("status") for r in receipts if r["phase"] == "iteration-two"] == [503, 200],
              "exact_completed_agent_message_once_per_phase": all(visible_messages[p["label"]] == ["synthetic completed"] and not output_errors[p["label"]] for p in processes),
              "only_responses_endpoint": all(r.get("path") == "/v1/responses" for r in receipts),
              "all_http_capture_complete": all(r.get("sent_complete") and not r.get("error") for r in receipts),
              "all_blob_hashes": all(blob_hash((out / name).read_bytes()) == item["sha256"] for name, item in capture.inventory.items())}
    summary = {"synthetic_only": True, "passed": all(checks.values()), "checks": checks,
               "duration_ns": time.monotonic_ns() - began, "preflight": facts, "inventory": capture.inventory.copy(),
               "integration_status": "actual_local_cli_mock_transport" if all(checks.values()) else "unvalidated_or_failed",
               "limits": ["No real model/auth/provider; no routing-quality or instruction-closure claim",
                          "Two fresh exec sessions with repeated user prompt; no genuine conversation continuation",
                          "Instruction presence is textual user-prompt evidence, not system-role provenance",
                          "Only predetermined Responses turns; native tool callbacks untested",
                          "HTTP bodies exact; headers normalized/allowlisted/auth redacted; TLS untested",
                          "Source supplies namespace checks; caller supplies existing bwrap confinement",
                          "CLI model/backend flags unvalidated until this run succeeds"]}
    capture.document("summary.json", summary)
    return {"passed": summary["passed"], "summary_sha256": blob_hash((out / "summary.json").read_bytes()), "duration_seconds": summary["duration_ns"] / 1e9}


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


if __name__ == "__main__": main()
