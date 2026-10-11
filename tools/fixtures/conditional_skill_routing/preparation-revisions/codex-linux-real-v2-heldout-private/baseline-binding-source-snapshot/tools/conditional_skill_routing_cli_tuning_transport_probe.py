"""Eight public tuning adapters through real CLI and fully simulated Responses.

Requires frozen dependency tree /dependency-root and outer WSL/bwrap namespace.
No held-out/evaluator payload, real provider, account or model. Synthetic private
transport bytes are ephemeral until independent verification/sanitization.
"""
import argparse
import copy
import http.client
import json
import os
from pathlib import Path
import socketserver
import subprocess
import sys
import threading
import time

if Path("/dependency-root").is_dir():
    sys.path.insert(0, "/dependency-root")
from tools import conditional_skill_routing_cli_broker_profile as profile
from tools import conditional_skill_routing_comparison_adapter as integration
from tools import conditional_skill_routing_runner as runner


def completed_response(raw):
    for block in reversed(raw.split(b"\n\n")):
        for line in block.splitlines():
            if line.startswith(b"data: "):
                event = json.loads(line[6:])
                if event.get("type") == "response.completed":
                    return event["response"]
    raise ValueError("no complete response object")


def schema_accepts(value, schema):
    if "const" in schema and value != schema["const"]:
        return False
    if "enum" in schema and value not in schema["enum"]:
        return False
    kind = schema.get("type")
    if isinstance(kind, list):
        return any(schema_accepts(value, {**schema, "type": item}) for item in kind)
    if kind == "null":
        return value is None
    if kind == "string":
        return type(value) is str
    if kind == "integer":
        return type(value) is int
    if kind == "boolean":
        return type(value) is bool
    if kind == "array":
        return type(value) is list and all(schema_accepts(item, schema.get("items", {})) for item in value)
    if kind == "object":
        return (type(value) is dict and set(schema.get("required", [])) <= set(value)
                and (schema.get("additionalProperties") is not False or set(value) <= set(schema.get("properties", {})))
                and all(schema_accepts(item, schema.get("properties", {}).get(key, {})) for key, item in value.items()))
    return True


def filter_request(original, subject):
    if type(original) is not dict or type(original.get("tools")) is not list:
        raise ValueError("unknown original request/tools")
    schemas = {row["name"]: row["inputSchema"] for row in subject.schema}
    selected = {}
    for row in original["tools"]:
        if row.get("name") not in schemas:
            continue
        if row["name"] in selected or row.get("type") != "function" or row.get("parameters") != schemas[row["name"]]:
            raise ValueError("case-owned schema changed/duplicated")
        selected[row["name"]] = copy.deepcopy(row)
    if set(selected) != subject.tools:
        raise ValueError("case-owned inventory incomplete")
    result = copy.deepcopy(original)
    result["tools"] = [selected[row["name"]] for row in subject.schema]
    if {key: value for key, value in result.items() if key != "tools"} != {key: value for key, value in original.items() if key != "tools"}:
        raise ValueError("input/instructions changed")
    return result


def plans(subject, case_id):
    reads = [{"tool": "instruction_read", "arguments": {"resource_id": rid, "spans": None}}
             for rid in subject.accounting.resources]
    if case_id.startswith("H"):
        return [reads + [{"tool": "fixture_read", "arguments": {"target": "unreleased-negative-probe"}},
                         {"message": "Synthetic explanation only; no repair, publication or saved trace."}]]
    if case_id.startswith("A"):
        contracts = subject.mcp.released_actions.contracts
        targets = sorted(set(target for row in contracts.values() for target in row["required_delivered_targets"]))
        steps = reads + [{"tool": "fixture_read", "arguments": {"target": target}} for target in targets]
        if "invocation_preflight" in contracts:
            steps += [{"tool": "audit", "arguments": contracts["audit"]["arguments"]},
                      {"tool": "invocation_preflight", "arguments": contracts["invocation_preflight"]["arguments"]}]
        steps += [{"tool": "audit", "arguments": contracts["audit"]["arguments"]},
                  {"message": "Synthetic read-only audit returned; findings are fixture responses, not a real audit. No writes."}]
        return [steps]
    if case_id.startswith("B"):
        collector = subject.prepared.collector
        first = reads
        for name in ("invocation_preflight", "topology_preflight"):
            if name in subject.mcp.released_actions.contracts:
                first.append({"tool": name, "arguments": subject.mcp.released_actions.contracts[name]["arguments"]})
        first += [{"tool": "fixture_read", "arguments": {"target": collector.target}},
                  {"message": collector.approval_question()}]
        second = [{"tool": "simulated_replace", "arguments": {"target": collector.target, "old": collector.old, "new": collector.new}}]
        for target in subject.mcp.scope_evidence_after:
            second.append({"tool": "scope_evidence_read", "arguments": {"target": target}})
        second.append({"tool": "focused_verify", "arguments": {"target": collector.target}})
        for target in subject.mcp.scope_evidence_after:
            second.append({"tool": "scope_evidence_read", "arguments": {"target": target}})
        second.append({"message": "Synthetic exact replacement verified; unrelated bytes preserved. Broader schema migration remains a separate decision."})
        return [first, second]
    gate = subject.mcp.private_gate
    args = {"namespace": gate.namespace, "operation": "read", "resource_id": gate.resource_id}
    record = json.loads(gate.record)
    redacted = {key: value for key, value in record.items() if key not in ("secret", "personal_field", "personal_email")}
    final = "Synthetic redacted conversational draft; no publication or memorization: " + json.dumps(redacted, ensure_ascii=False)
    finish = [{"tool": "private_status", "arguments": {}}, {"tool": "private_capability", "arguments": args},
              {"tool": "private_record_read", "arguments": {"resource_id": gate.resource_id}}, {"message": final}]
    if gate.granted:
        return [reads + finish]
    return [reads + [{"tool": "private_status", "arguments": {}},
                     {"tool": "private_capability", "arguments": args}, {"message": gate.grant_question()}], finish]


def run(cli, out, facts, dependency_root, case_id=None):
    capture = profile.Capture(out)
    capture.save("source-snapshot.py", Path(__file__).read_bytes())
    capture.document("preflight.json", facts)
    manifest_path = dependency_root / "tools/fixtures/conditional_skill_routing/manifest.json"
    cases_path = dependency_root / "tools/fixtures/conditional_skill_routing/cases.json"
    manifest, cases = json.loads(manifest_path.read_bytes()), json.loads(cases_path.read_bytes())["cases"]
    if [case["id"] for case in cases] != ["H1", "H2", "A1", "A2", "B1", "B2", "S1", "S2"] or any(case["split"] != "tuning" for case in cases):
        raise ValueError("only the eight public tuning cases may be loaded")
    if case_id is not None:
        cases = [case for case in cases if case["id"] == case_id]
        if len(cases) != 1: raise ValueError("unknown public tuning case")
    capture.document("dependency-inventory.json", {str(path.relative_to(dependency_root)): profile.digest(path.read_bytes())
        for path in dependency_root.rglob("*") if path.is_file()})
    # Linux execution of the identical existing worker, inside a second bwrap.
    # Original packet/report/receipt validations remain runner.run_worker's own.
    original_bounded = runner.bounded
    workers = []
    def linux_bounded(command, *, payload=None, timeout=20):
        if command[:4] != ["wsl.exe", "--distribution", "Ubuntu", "--exec"]:
            raise runner.RunnerError("unexpected worker launcher")
        began = time.monotonic_ns()
        process = subprocess.run(command[4:], input=payload, capture_output=True, timeout=timeout,
                                 env={"PATH": "/usr/bin:/bin"}, check=False)
        workers.append({"argv": command[4:], "request_sha256": profile.digest(payload),
                        "stdout_sha256": profile.digest(process.stdout), "stderr_sha256": profile.digest(process.stderr),
                        "exit_code": process.returncode, "started_ns": began, "ended_ns": time.monotonic_ns()})
        if process.returncode != 0:
            raise runner.RunnerError("nested confined worker failed: " + process.stderr[:200].decode(errors="replace"))
        return process.stdout
    runner.bounded = linux_bounded
    profile.REQUEST_LIMIT, profile.TOTAL_LIMIT, profile.DEADLINE_SECONDS, profile.STREAM_LIMIT = 256, 128 * 1024 * 1024, 270, 32 * 1024 * 1024
    state = {"subject": None, "case": None, "steps": [], "index": 0, "seen": set(), "released": [], "callback_count": 0}
    budgets = {name: {"count": 0, "bytes": 0} for name in ("model", "original")}
    http_receipts, case_receipts, errors, expected_native_messages = [], [], [], []
    def validate_function(item):
        subject = state["subject"]
        if item.get("type") != "function_call" or item.get("name") not in subject.tools:
            raise ValueError("native/nonbroker function refused before CLI dispatch")
        if set(item) - {"type", "id", "call_id", "name", "arguments", "status"} or item.get("status") != "completed":
            raise ValueError("malformed function item")
        if not all(type(item.get(key)) is str and item[key] for key in ("id", "call_id", "arguments")):
            raise ValueError("malformed function identity")
        schema = next(row["inputSchema"] for row in subject.schema if row["name"] == item["name"])
        arguments = integration._decode(item["arguments"].encode())
        if not schema_accepts(arguments, schema):
            raise ValueError("function arguments outside immutable case schema")
    profile.validate_function_item = validate_function

    class Model(socketserver.StreamRequestHandler):
        def handle(self):
            budget = budgets["model"]; budget["count"] += 1
            identifier = "model-%03d" % budget["count"]
            try:
                raw, envelope = profile.read_http(self, capture, identifier, budget, "/mock/responses")
                request = integration._decode(raw)
                subject = state["subject"]
                if [row.get("name") for row in request["tools"]] != [row["name"] for row in subject.schema]:
                    raise ValueError("model inventory differs from current case")
                step = state["steps"][state["index"]]
                state["index"] += 1
                if "message" in step:
                    profile.FINAL = step["message"]
                    body = profile.provider_sse(identifier)
                else:
                    body = profile.provider_sse(identifier, step["tool"], step["arguments"], state["case"] + "-" + identifier)
                capture.save(identifier + ".response.bin", body)
                profile.send_http(self, 200, body, "text/event-stream")
            except Exception as error:
                errors.append({"boundary": "mock_model", "error": type(error).__name__ + ": " + str(error)})

    model = socketserver.TCPServer(("127.0.0.1", 0), Model)
    model_thread = threading.Thread(target=model.serve_forever, daemon=True); model_thread.start()

    class Proxy(socketserver.StreamRequestHandler):
        def handle(self):
            budget = budgets["original"]; budget["count"] += 1
            identifier = "original-%03d" % budget["count"]
            receipt = {"id": identifier, "case_id": state["case"]}
            connection = None
            try:
                raw, envelope = profile.read_http(self, capture, identifier, budget, "/v1/responses")
                receipt.update(envelope)
                original = integration._decode(raw)
                forwarded = filter_request(original, state["subject"])
                forwarded_raw = profile.pack(forwarded)
                capture.save(identifier + ".forwarded-model-request.bin", forwarded_raw)
                observed = state["subject"].observe_request(forwarded_raw, label=identifier)
                receipt.update(non_tools_unchanged=True, model_offered_tool_names=[row["name"] for row in forwarded["tools"]],
                               forwarded_sha256=profile.digest(forwarded_raw), newly_delivered_callbacks=observed["newly_delivered_callbacks"])
                connection = http.client.HTTPConnection("127.0.0.1", model.server_address[1], timeout=5)
                connection.request("POST", "/mock/responses", body=forwarded_raw, headers={"Content-Type": "application/json"})
                response = connection.getresponse()
                body = response.read(profile.BODY_LIMIT + 1)
                capture.save(identifier + ".received-provider-response.bin", body)
                if response.status != 200 or len(body) != int(response.getheader("Content-Length", "-1")):
                    raise ValueError("mock provider envelope incomplete")
                gate = profile.gate_complete_sse(body, state["seen"])
                state["seen"].update(gate["call_ids"])
                completed = completed_response(body)
                if any(item["type"] == "message" for item in completed["output"]):
                    result = state["subject"].observe_assistant_response(profile.pack(completed), label=identifier)
                    state["released"].extend(result["released_turns"])
                capture.save(identifier + ".emitted-to-cli.bin", body)
                profile.send_http(self, 200, body, "text/event-stream")
                receipt.update(status=200, sent_complete=True, gate=gate)
            except Exception as error:
                receipt.update(status=502, error=type(error).__name__ + ": " + str(error))
                errors.append({"boundary": "proxy", "error": receipt["error"]})
                try:
                    profile.send_http(self, 502, profile.pack({"error": {"message": "mock capture/gate rejected request", "type": "gate_error"}}), "application/json")
                except OSError:
                    pass
            finally:
                if connection is not None: connection.close()
                http_receipts.append(receipt)

    proxy = socketserver.TCPServer(("127.0.0.1", 0), Proxy)
    proxy_thread = threading.Thread(target=proxy.serve_forever, daemon=True); proxy_thread.start()
    home, project = out / "synthetic-home", out / "synthetic-project"
    home.mkdir(); project.mkdir(); code_home = home / "codex"; code_home.mkdir()
    config = ('model="synthetic"\nmodel_provider="mock"\napproval_policy="never"\nsandbox_mode="danger-full-access"\n'
        '[analytics]\nenabled=false\n[model_providers.mock]\nname="Mock tuning transport"\nwire_api="responses"\n'
        f'base_url="http://127.0.0.1:{proxy.server_address[1]}/v1"\nrequires_openai_auth=false\nrequest_max_retries=0\nstream_max_retries=0\n')
    (code_home / "config.toml").write_text(config); capture.save("config-snapshot.toml", config.encode())
    environment = {"HOME": str(home), "CODEX_HOME": str(code_home), "PATH": "/usr/bin:/bin", "TMPDIR": str(home), "LANG": "C.UTF-8", "NO_COLOR": "1"}
    rpc, failure, turns, counter = None, None, [], 1
    def callback(parameters):
        identifier = "callback-%03d" % state["callback_count"]
        state["callback_count"] += 1
        capture.document(identifier + ".json", {"case_id": state["case"], "parameters": parameters})
        result = state["subject"].dispatch(parameters)
        capture.document(identifier + ".result.json", result)
        return result
    try:
        rpc = profile.Rpc([str(cli), "app-server", "--listen", "stdio://"], project, environment, capture, callback)
        rpc.call(counter, "initialize", {"clientInfo": {"name": "csr-eight-tuning-mock", "version": "1"}, "capabilities": {"experimentalApi": True}})
        rpc.send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
        for case in cases:
            identifier = case["id"]; state.update(case=identifier, index=0, seen=set(), released=[])
            # Build before thread creation to provide only exact case-owned schemas.
            subject = integration.prepare_tuning(manifest, case, thread_id="pending", turn_id="pending")
            state["subject"] = subject
            counter += 1
            instructions = "\n".join(row["text"] for row in subject.mcp.broker.bundle["injections"])
            thread = rpc.call(counter, "thread/start", {"cwd": str(project), "ephemeral": True, "model": "synthetic", "modelProvider": "mock",
                "approvalPolicy": "never", "sandbox": "danger-full-access", "dynamicTools": subject.dynamic_tools(), "baseInstructions": instructions})["thread"]["id"]
            subject.bind_thread(thread)
            phases = plans(subject, identifier)
            initial = subject.mcp.broker.bundle["turns"]
            invocations = []
            if len(initial) == 3:
                invocations.append((initial[0]["content"], [{"message": initial[1]["content"]}]))
            invocations.append((initial[-1]["content"], phases[0]))
            for index in range(len(phases) - 1): invocations.append((None, phases[index + 1]))
            case_turns = []
            for prompt, steps in invocations:
                if prompt is None:
                    if len(state["released"]) != 1: raise ValueError("canonical conditional turn not uniquely released")
                    prompt = state["released"].pop()["content"]
                state.update(index=0, steps=steps)
                counter += 1
                turn = rpc.call(counter, "turn/start", {"threadId": thread, "input": [{"type": "text", "text": prompt}]})["turn"]["id"]
                subject.begin_turn(turn)
                event = rpc.await_event(lambda row: row.get("method") == "turn/completed" and row.get("params", {}).get("turn", {}).get("id") == turn)
                if event["params"]["turn"].get("status") != "completed": raise ValueError("synthetic turn failed")
                if state["index"] != len(steps): raise ValueError("mock steps incomplete")
                case_turns.append(turn); turns.append(turn)
            # A last final text needs no next model request; all native callbacks
            # necessarily appeared in the request that received that final text.
            summary = subject.summary()
            expected_native_messages.extend(row["content"] for row in subject.responses)
            summary.update(case_id=identifier, turns=case_turns, all_callbacks_exactly_delivered=all(row["delivered"] for row in subject.callbacks.values()),
                           private_redaction_pass=(subject.prepared.redaction.receipts[-1]["redaction"] == "pass") if hasattr(subject.prepared, "redaction") and subject.prepared.redaction else None)
            capture.document(identifier + ".adapter-summary.json", summary)
            capture.document(identifier + ".accounting.json", subject.accounting.receipts)
            case_receipts.append(summary)
    except Exception as error:
        failure = type(error).__name__ + ": " + str(error)
    finally:
        if rpc is not None: rpc.close()
        for server, thread in ((proxy, proxy_thread), (model, model_thread)):
            server.shutdown(); thread.join(timeout=2); server.server_close()
        runner.bounded = original_bounded
    capture.document("http-receipts.json", http_receipts)
    capture.document("worker-receipts.json", workers)
    events = rpc.events if rpc else []
    items = [event.get("params", {}).get("item", {}) for event in events if event.get("method") == "item/completed"]
    native_messages = [item.get("text") for item in items if item.get("type") == "agentMessage"]
    native_effects = [item for item in items if item.get("type") in ("commandExecution", "fileChange", "mcpToolCall", "webSearch", "collabAgentToolCall")]
    capture.document("rpc-events.json", {"events": events, "errors": rpc.errors if rpc else [], "failure": failure})
    checks = {"selected_cases_complete": [row["case_id"] for row in case_receipts] == [case["id"] for case in cases], "all_callbacks_delivered": bool(case_receipts) and all(row["all_callbacks_exactly_delivered"] for row in case_receipts),
        "all_http_complete": bool(http_receipts) and all(row.get("sent_complete") and not row.get("error") for row in http_receipts),
        "nested_confined_workers": bool(workers) and all(row["exit_code"] == 0 for row in workers),
        "private_redaction": [row["private_redaction_pass"] for row in case_receipts if row["case_id"].startswith("S")] == [True for case in cases if case["id"].startswith("S")],
        "exact_all_native_assistant_messages": native_messages == expected_native_messages,
        "no_native_effect_events": not native_effects,
        "all_blob_hashes": all(profile.digest((out / name).read_bytes()) == row["sha256"] for name, row in capture.inventory.items()),
        "no_failure": failure is None and not errors and rpc is not None and not rpc.errors and rpc.process.returncode == 0}
    summary = {"passed": all(checks.values()), "checks": checks, "failure": failure, "errors": errors,
               "mock_only": True, "model_calls": 0, "campaign_runs": [], "cases": case_receipts, "turn_ids": turns,
               "inventory": capture.inventory.copy(), "limits": ["Scripted mock transport diagnostics, not observed baseline or comparison", "No semantic acceptance or hidden retention/AC5 pass", "Raw synthetic private capture ephemeral pending independent verification and sanitization", "Native features not disabled; case-owned offered/callable proxy closure is the tested boundary"]}
    capture.document("summary.json", summary)
    return {"passed": summary["passed"], "summary_sha256": profile.digest((out / "summary.json").read_bytes())}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--dependency-root", type=Path, default=Path("/dependency-root"))
    parser.add_argument("--case", choices=["H1", "H2", "A1", "A2", "B1", "B2", "S1", "S2"])
    args = parser.parse_args()
    facts = profile.preflight(args.cli)
    args.out.mkdir(exist_ok=False)
    result = run(args.cli, args.out, facts, args.dependency_root, args.case)
    print(json.dumps(result)); raise SystemExit(0 if result["passed"] else 1)


if __name__ == "__main__": main()
