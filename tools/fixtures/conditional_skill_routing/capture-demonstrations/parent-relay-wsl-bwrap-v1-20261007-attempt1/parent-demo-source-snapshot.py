"""Windows trusted parent / WSL bwrap relay proof, mock callback only.

No CLI download, provider, real credential read, held-out decode or campaign.
Only synthetic channel credentials cross stdin. Parent-only fake credential and
evaluator sentinel remains outside all child mounts; durable captures are parent
owned. This proof certifies this relay placement, not a later Codex integration.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import threading
import time

from tools.conditional_skill_routing_parent_transport import (
    ParentBridge, TransportError, decoded, frame, packed, read_frame, sha, verify)

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "tools/fixtures/conditional_skill_routing/capture-demonstrations"

RELAY = r'''
import base64,errno,importlib.util,json,os,pathlib,socket,sys
spec=importlib.util.spec_from_file_location("parent_transport","/relay-transport.py")
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
bootstrap=m.decoded(m.read_frame(sys.stdin.buffer,8192))
assert set(bootstrap)=={"channel_key","body_b64","synthetic_parent_probe_path"}
key=base64.b64decode(bootstrap["channel_key"],validate=True)
body=base64.b64decode(bootstrap["body_b64"],validate=True)
interfaces=[line.split(":",1)[0].strip() for line in pathlib.Path("/proc/net/dev").read_text().splitlines()[2:]]
with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s:
 s.settimeout(.2);error=s.connect_ex(("203.0.113.1",9))
probe=pathlib.Path(bootstrap["synthetic_parent_probe_path"])
diagnostic={"interfaces":interfaces,"nonloopback_errno":error,"parent_sentinel_visible":probe.exists(),
 "mnt_visible":pathlib.Path("/mnt").exists(),"host_run_visible":pathlib.Path("/run").exists(),
 "environment_keys":sorted(os.environ),"credential_or_evaluator_environment_present":any(k in os.environ for k in ("OPENAI_API_KEY","PARENT_FAKE_CREDENTIAL","EVALUATOR_FAKE_STATE")),
 "mountinfo":pathlib.Path("/proc/self/mountinfo").read_text(),"relay_source_sha256":m.sha(pathlib.Path("/relay.py").read_bytes()),
 "transport_source_sha256":m.sha(pathlib.Path("/relay-transport.py").read_bytes())}
assert interfaces==["lo"] and error==errno.ENETUNREACH
assert not diagnostic["parent_sentinel_visible"] and not diagnostic["credential_or_evaluator_environment_present"]
assert not diagnostic["mnt_visible"] and not diagnostic["host_run_visible"]
sys.stdout.buffer.write(m.frame(m.packed({"type":"preflight","diagnostic":diagnostic})));sys.stdout.buffer.flush()
raw=m.make_request("relay-os-one","responses-fixture",body,key)
sys.stdout.buffer.write(m.frame(raw));sys.stdout.buffer.flush()
wire=m.read_frame(sys.stdin.buffer,8192)
response=m.read_response(wire,key,"relay-os-one")
payload=m.decoded(response["body"])
assert response["status"]==200 and base64.b64decode(payload["synthetic_echo_b64"],validate=True)==body
result={"type":"relay_complete","exact_request_body_sha256":m.sha(body),"exact_response_body_sha256":m.sha(response["body"]),
 "response_frame_sha256":m.sha(wire),"parent_response_hmac_verified":True,"mock_only":True}
sys.stdout.buffer.write(m.frame(m.packed(result)));sys.stdout.buffer.flush()
'''


def linux(path):
    require(path.is_absolute() and path.drive, "absolute Windows path required")
    return "/mnt/" + path.drive[0].lower() + path.as_posix()[2:]


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


class Capture:
    def __init__(self, root):
        self.root, self.inventory = root, {}
        self.lock = threading.Lock()
    def save(self, name, raw):
        with self.lock:
            with (self.root / name).open("xb") as stream:
                stream.write(raw)
            self.inventory[name] = {"bytes": len(raw), "sha256": sha(raw)}
    def doc(self, name, obj):
        self.save(name, packed(obj))


class CapturedReader:
    def __init__(self, stream, capture):
        self.stream, self.capture, self.index, self.total = stream, capture, 0, 0
    def read(self, count):
        raw = self.stream.read(count)
        if raw:
            self.capture.save("relay-stdout-chunk-%04d.bin" % self.index, raw)
            self.index += 1
            self.total += len(raw)
            require(self.total <= 256 * 1024, "relay stdout budget")
        return raw


def run(label):
    require(os.name == "nt", "Windows/WSL parent placement required")
    require(type(label) is str and label.replace("-", "").isalnum(), "invalid proof label")
    out = BASE / label
    out.mkdir(exist_ok=False)
    capture = Capture(out)
    transport = ROOT / "tools/conditional_skill_routing_parent_transport.py"
    capture.save("transport-source-snapshot.py", transport.read_bytes())
    capture.save("parent-demo-source-snapshot.py", Path(__file__).read_bytes())
    capture.save("relay-source-snapshot.py", RELAY.encode("utf-8"))
    channel_key = b"synthetic-os-relay-channel-000001"
    receipt_key = b"synthetic-parent-only-proof-00002"
    parent_credential = b"FAKE_PARENT_CREDENTIAL_NEVER_RELAY_01601"
    evaluator_state = b"FAKE_EVALUATOR_STATE_NEVER_RELAY_01601"
    request_body = '{ "input" : "bonjour café, preuve U0001f9ea" }\n'.encode("utf-8")
    response_body = packed({"synthetic_echo_b64": base64.b64encode(request_body).decode(),
                            "result": "synthetic trusted parent result U0001f9ea"})
    callback_inputs = []
    process, watchdog, stderr_thread = None, None, None
    errors, diagnostics, response, child_final = [], None, None, None
    start = time.monotonic_ns()
    with tempfile.TemporaryDirectory(prefix="sg-parent-relay-synthetic-") as temporary:
        folder = Path(temporary)
        sentinel = folder / "parent-only-fake-state.json"
        sentinel.write_bytes(packed({"credential": parent_credential.decode(), "evaluator": evaluator_state.decode()}))
        def callback(body, deadline):
            require(body == request_body, "unexpected callback request bytes")
            require(sentinel.is_file(), "parent sentinel disappeared")
            callback_inputs.append({"body_sha256": sha(body), "body_bytes": len(body),
                                    "deadline_is_bounded": time.monotonic() < deadline})
            return {"status": 200, "headers": {"content-type": "application/json", "x-request-id": "synthetic-parent-one"}, "body": response_body}
        parent = ParentBridge("responses-fixture", callback, channel_key=channel_key, receipt_key=receipt_key,
                              callback_kind="mock", launch_authorized=False, max_requests=2,
                              max_body=8192, max_response=8192, total_body=16384, total_response=16384,
                              callback_timeout=2, session_timeout=30)
        command = ["/usr/bin/bwrap", "--unshare-all", "--die-with-parent", "--new-session", "--clearenv"]
        for system in ("/usr", "/bin", "/lib", "/lib64"):
            command += ["--ro-bind", system, system]
        command += ["--proc", "/proc", "--dev", "/dev", "--tmpfs", "/tmp", "--tmpfs", "/work",
                    "--ro-bind", linux(out / "transport-source-snapshot.py"), "/relay-transport.py",
                    "--ro-bind", linux(out / "relay-source-snapshot.py"), "/relay.py",
                    "--chdir", "/work", "--setenv", "HOME", "/work", "--setenv", "PATH", "/usr/bin:/bin",
                    "--setenv", "LANG", "C.UTF-8", "/usr/bin/python3", "-B", "/relay.py"]
        argv = ["wsl", "-d", "Ubuntu", "--", "/usr/bin/env", "-i", "PATH=/usr/bin:/bin",
                "/usr/bin/timeout", "--signal=TERM", "--kill-after=2s", "25s", *command]
        capture.doc("launch.json", {"argv": argv, "linux_timeout_seconds": 25, "windows_watchdog_seconds": 35,
                                    "parent_platform": "Windows", "callback_kind": "mock", "launch_authorized": False,
                                    "no_writable_host_mount": True, "no_parent_evaluator_credential_mount": True})
        try:
            process = subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            watchdog = threading.Timer(35, process.kill)
            watchdog.start()
            def stderr_capture():
                index, total = 0, 0
                while raw := process.stderr.read1(4096):
                    capture.save("relay-stderr-chunk-%04d.bin" % index, raw)
                    index += 1
                    total += len(raw)
                    if total > 256 * 1024:
                        process.kill()
                        errors.append("stderr admission limit")
                        break
            stderr_thread = threading.Thread(target=stderr_capture, daemon=True)
            stderr_thread.start()
            reader = CapturedReader(process.stdout, capture)
            bootstrap = packed({"channel_key": base64.b64encode(channel_key).decode(),
                                "body_b64": base64.b64encode(request_body).decode(),
                                "synthetic_parent_probe_path": linux(sentinel)})
            # Parent-only fake marker/proof key never enters the child pipe.
            require(all(marker not in bootstrap for marker in (parent_credential, evaluator_state, receipt_key)), "parent marker in bootstrap")
            capture.save("bootstrap-frame.bin", frame(bootstrap))
            process.stdin.write(frame(bootstrap)); process.stdin.flush()
            preflight_raw = read_frame(reader, 32768)
            capture.save("relay-preflight-envelope.bin", preflight_raw)
            diagnostics = decoded(preflight_raw)
            require(diagnostics["type"] == "preflight", "relay preflight missing")
            request_raw = read_frame(reader, 32768)
            capture.save("parent-received-request-envelope.bin", request_raw)
            response = parent.handle(request_raw)
            capture.save("parent-response-envelope.bin", response)
            capture.save("parent-response-frame.bin", frame(response))
            process.stdin.write(frame(response)); process.stdin.flush()
            final_raw = read_frame(reader, 32768)
            capture.save("relay-completion-envelope.bin", final_raw)
            child_final = decoded(final_raw)
            process.stdin.close()
            require(read_frame(reader, 32768) is None, "unexpected relay frame")
            process.wait(timeout=5)
            stderr_thread.join(timeout=5)
            require(not stderr_thread.is_alive(), "stderr capture remains active")
        except Exception as error:
            errors.append(type(error).__name__ + ": " + str(error))
        finally:
            if watchdog:
                watchdog.cancel()
            if process and process.poll() is None:
                process.kill()
                process.wait(timeout=5)
            if stderr_thread:
                stderr_thread.join(timeout=5)
            if process:
                for stream in (process.stdin, process.stdout, process.stderr):
                    if stream and not stream.closed:
                        stream.close()
            capture.save("parent-durable-receipts.json", parent.durable_receipts())
            capture.doc("callback-observations.json", callback_inputs)
            capture.doc("process-receipt.json", {"exit_code": process.returncode if process else None,
                                                 "duration_ns": time.monotonic_ns() - start, "errors": errors})
        # Auth rejection, replay and partial frame errors remain independently
        # durable alongside the successful relay exchange, without new callbacks.
        negatives = []
        if response is not None:
            for kind, raw in [("replay", request_raw), ("unauthenticated", packed({"id": "bad"}))]:
                try:
                    parent.handle(raw)
                    negatives.append({"kind": kind, "refused": False})
                except TransportError:
                    negatives.append({"kind": kind, "refused": True})
            partial_parent = ParentBridge("responses-fixture", callback, channel_key=channel_key, receipt_key=receipt_key)
            import io
            try:
                partial_parent.serve_stream(io.BytesIO(b"\0\0\0\x04ab"), io.BytesIO())
            except TransportError:
                capture.save("partial-frame-durable-receipts.json", partial_parent.durable_receipts())
                negatives.append({"kind": "partial_frame", "refused": True})
            capture.save("parent-final-durable-receipts.json", parent.durable_receipts())
            require(all(verify(row, receipt_key) for row in parent.receipts), "parent receipt signature mismatch")
        capture.doc("negative-observations.json", negatives)
    capture.doc("parent-temporary-cleanup.json", {"temporary_folder_exists": folder.exists(), "real_credential_access": False})
    diagnostic = diagnostics["diagnostic"] if diagnostics else {}
    transmitted = b"".join((out / name).read_bytes() for name in capture.inventory if name.startswith(("relay-stdout", "relay-stderr", "bootstrap", "parent-response", "relay-completion")))
    checks = {"process_success": process is not None and process.returncode == 0 and not errors,
              "lo_only_enetunreach": diagnostic.get("interfaces") == ["lo"] and diagnostic.get("nonloopback_errno") == 101,
              "parent_sentinel_absent": diagnostic.get("parent_sentinel_visible") is False,
              "no_host_paths_or_environment": diagnostic.get("mnt_visible") is False and diagnostic.get("host_run_visible") is False
                  and diagnostic.get("credential_or_evaluator_environment_present") is False,
              "exact_source_snapshots": diagnostic.get("relay_source_sha256") == sha(RELAY.encode())
                  and diagnostic.get("transport_source_sha256") == sha(transport.read_bytes()),
              "exact_request_and_response": len(callback_inputs) == 1 and child_final is not None
                  and child_final.get("exact_request_body_sha256") == sha(request_body)
                  and child_final.get("exact_response_body_sha256") == sha(response_body)
                  and child_final.get("parent_response_hmac_verified") is True,
              "parent_only_fake_markers_not_transmitted": all(marker not in transmitted for marker in (parent_credential, evaluator_state, receipt_key)),
              "negative_receipts_retained": len(negatives) == 3 and all(row["refused"] for row in negatives),
              "temporary_parent_state_removed": not folder.exists(),
              "inventory_rehashed": all(sha((out / name).read_bytes()) == entry["sha256"] for name, entry in capture.inventory.items())}
    capture.doc("summary.json", {"synthetic_only": True, "passed": all(checks.values()), "checks": checks,
                                  "inventory": capture.inventory.copy(), "diagnostic": diagnostic,
                                  "limits": ["Windows trustedparent and Python relay OS placement proved; Codex consumer not integrated here",
                                             "No model/provider/real credential/evaluator held-out access; fake markers only",
                                             "Only transport framing and fixed mocked callback; no eight-scenario comparison proof",
                                             "Callback timeout cannot prove cancellation; Linux/Windows watchdogs bound this fixture",
                                             "No AC5 internal retention or exclusive Codex tool inventory claim"]})
    return {"passed": all(checks.values()), "output": str(out), "summary_sha256": sha((out / "summary.json").read_bytes())}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--label", required=True)
    args = parser.parse_args()
    result = run(args.label)
    print(json.dumps(result))
    raise SystemExit(0 if result["passed"] else 1)
