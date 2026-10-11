"""Independent raw compaction/continuation/recovery accounting replay."""
import ast
import hashlib
import importlib.util
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
RUN = BASE / "workspace/run"
ROOT = BASE.parents[4]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(ok, message):
    if not ok:
        raise ValueError(message)


def load(name):
    return json.loads((RUN / name).read_bytes())


def main():
    summary_raw = (RUN / "summary.json").read_bytes()
    require(sha(summary_raw) == "21c0fe1994191b3d8bdd2a62917c2226d4a73ef4f6e5150f697922e26b1cf179", "unexpected summary")
    summary = json.loads(summary_raw)
    for name, entry in summary["inventory"].items():
        raw = (RUN / name).read_bytes()
        require(sha(raw) == entry["sha256"] and len(raw) == entry["bytes"], "inventory mismatch: " + name)
    constants = {}
    for node in ast.parse((RUN / "source-snapshot.py").read_bytes()).body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            try:
                constants[node.targets[0].id] = ast.literal_eval(node.value)
            except (ValueError, TypeError):
                pass
    text = constants["TOOL_TEXT"]
    require(text.encode() in (RUN / "fictional_diagnostic.py").read_bytes() or json.dumps(text).encode() in (RUN / "fictional_diagnostic.py").read_bytes(), "diagnostic source mismatch")
    rpc = load("rpc-events.json")
    events = rpc["events"]
    stdout = b"".join(path.read_bytes() for path in sorted(RUN.glob("rpc-stdout-*.bin")))
    require([json.loads(line) for line in stdout.decode("utf-8").splitlines() if line] == events, "raw RPC event mismatch")
    compact = [e for e in events if e.get("method") == "item/completed"
               and e.get("params", {}).get("item", {}).get("type") == "contextCompaction"]
    require(len(compact) == 1 and compact[0] == rpc["compact_event"], "compaction item mismatch")
    thread = rpc["thread_id"]
    inputs = [json.loads(path.read_bytes()) for path in sorted(RUN.glob("rpc-input-*.bin"))]
    require(any(i.get("method") == "thread/compact/start" and i["params"]["threadId"] == thread for i in inputs), "no explicit native compact request")
    turns = [e["params"] for e in events if e.get("method") == "turn/completed"
             and e["params"]["turn"]["id"] in rpc["user_turn_ids"]]
    require(len(turns) == 3 and len(set(rpc["user_turn_ids"])) == 3
            and all(t["threadId"] == thread and t["turn"]["status"] == "completed" for t in turns), "user turn continuity/completion")
    items = [e["params"]["item"] for e in events if e.get("method") == "item/completed"]
    finals = [i["text"] for i in items if i.get("type") == "agentMessage"]
    require(finals == [constants["FINAL_FIRST"], constants["FINAL_SECOND"], constants["FINAL_RECOVERY"]], "final texts mismatch")
    executions = [i for i in items if i.get("type") == "commandExecution"]
    require([i["id"] for i in executions] == ["call_csr_compaction_read_01601", "call_csr_guard_denied_01601", "call_csr_reread_01601", "call_csr_guard_allowed_01601"], "execution order")
    require([i["aggregatedOutput"] for i in executions] == [text, constants["GUARD_DENY"], text, constants["GUARD_ALLOW"]], "execution exact outputs")
    require([i["exitCode"] for i in executions] == [0, 41, 0, 0], "execution exit codes")
    source = ROOT / "tools/conditional_skill_routing_responses_accounting.py"
    snapshot = BASE / "responses-accounting-source.py"
    with snapshot.open("xb") as stream:
        stream.write(source.read_bytes())
    spec = importlib.util.spec_from_file_location("accounting_snapshot", snapshot)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    account = module.ResponsesAccounting(resources={"diagnostic": text}, injections=[
        {"id": "fixture_agents", "text": constants["AGENT"], "roles": ["user", "developer"]},
        {"id": "compact_summary", "text": constants["SUMMARY"], "roles": ["user", "assistant"]}])
    callbacks = {"call_csr_compaction_read_01601": "diagnostic.callback.txt",
                 "call_csr_reread_01601": "reread.callback.txt",
                 "call_csr_guard_denied_01601": "guard-denied.callback.txt",
                 "call_csr_guard_allowed_01601": "guard-allowed.callback.txt"}
    for call_id in ("call_csr_compaction_read_01601", "call_csr_reread_01601"):
        account.register_read(call_id, "diagnostic", (RUN / callbacks[call_id]).read_bytes().decode("utf-8"))
    requests = []
    for index, path in enumerate(sorted(RUN.glob("http-???.request.bin")), 1):
        raw = path.read_bytes()
        require(b"".join(p.read_bytes() for p in sorted(RUN.glob(path.stem.replace(".request", "") + ".request.chunk-*.bin"))) == raw, "raw request chunk mismatch")
        body = json.loads(raw)
        metadata = body["client_metadata"]
        require(metadata["thread_id"] == thread and metadata["session_id"] == thread, "provider thread identity")
        request_kind = json.loads(metadata["x-codex-turn-metadata"])["request_kind"]
        require((request_kind == "compaction") == (index == 3), "compaction request metadata")
        if index == 4:
            account.invalidate("actual contextCompaction item completed; subsequent provider input lost exact diagnostic", sha(stdout))
        result = account.capture_request(raw, label=path.name)
        result["request_kind"] = request_kind
        for item in body["input"]:
            if item.get("type") == "function_call_output":
                require(item["output"] == (RUN / callbacks[item["call_id"]]).read_bytes().decode("utf-8"), "callback transport exactness")
                expected = next(i["aggregatedOutput"] for i in executions if i["id"] == item["call_id"])
                require(item["output"].endswith(expected), "stdout suffix mismatch")
        requests.append(result)
    require(len(requests) == 8, "provider request count")
    require([r["coverage"]["diagnostic"]["full"] for r in requests] == [False, True, True, False, False, False, True, True], "loss/reread exact coverage")
    require([r["generation"] for r in requests] == [0, 0, 0, 1, 1, 1, 1, 1], "coverage generation")
    require(all(any(e["type"] == "injection" and e["injection_id"] == "compact_summary" for e in r["events"]) for r in requests[3:]), "compacted summary missing")
    require(all(not any(e.get("call_id") == "call_csr_compaction_read_01601" for e in r["events"]) for r in requests[3:]), "old read retained after compaction")
    transitions = load("fictional-delivery-transitions.json")
    require([t["state"] for t in transitions] == ["invalidated", "restored_observed_provider_delivery"], "transition order")
    require([t["request"] for t in transitions] == ["http-003", "http-007"], "transition request ids")
    require(all(t["sha256"] == sha(text.encode()) and t["span_utf8"] == [0, len(text.encode())] for t in transitions), "transition span/hash")
    result = {"passed": True, "runtime_summary_sha256": sha(summary_raw),
              "accounting_source_sha256": sha(snapshot.read_bytes()), "review_source_sha256": sha(Path(__file__).read_bytes()),
              "inventory_entries_rehashed": len(summary["inventory"]), "thread_id": thread,
              "completed_user_turn_ids": rpc["user_turn_ids"], "actual_compaction_item": compact[0],
              "raw_rpc_sha256": sha(stdout), "requests": requests, "context_loss": [e for e in account.events if e["type"] == "context_loss"],
              "all_request_input_text_characters": sum(r["text_characters"] for r in requests),
              "all_request_diagnostic_characters_including_retransmission": sum(e["source_span"]["characters"] for r in requests for e in r["events"] if e["type"] == "read"),
              "limits": ["Independent runtime-source review; accounting reviewer authored accounting module",
                         "Actual CLI compaction and three user turns; no persistent process resume proof",
                         "Provider messages and usage fully simulated; internal model retention UNKNOWN, AC5 unproved",
                         "Guard mechanics fail closed only for this exact fixture; no model behavioral compliance",
                         "Coverage restored in request seven and still present in request eight",
                         "No exclusive native tool inventory or real provider/campaign readiness claimed"]}
    with (BASE / "accounting.json").open("xb") as stream:
        stream.write(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2).encode("utf-8"))
    print(json.dumps({"passed": True, "inventory": len(summary["inventory"]), "requests": len(requests),
                      "input_text_characters": result["all_request_input_text_characters"],
                      "diagnostic_characters": result["all_request_diagnostic_characters_including_retransmission"],
                      "accounting_sha256": sha((BASE / "accounting.json").read_bytes())}))


if __name__ == "__main__":
    main()
