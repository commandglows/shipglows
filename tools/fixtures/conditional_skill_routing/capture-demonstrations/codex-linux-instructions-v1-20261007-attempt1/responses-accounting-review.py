"""Offline independent raw review; creates new evidence, never changes run files."""
import hashlib
import importlib.util
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
RUN = BASE / "workspace/run"
ROOT = BASE.parents[4]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def load(name):
    return json.loads((RUN / name).read_bytes().decode("utf-8"))


def check(condition, message):
    if not condition:
        raise ValueError(message)


def main():
    source = ROOT / "tools/conditional_skill_routing_responses_accounting.py"
    snapshot = BASE / "responses-accounting-source.py"
    with snapshot.open("xb") as stream:
        stream.write(source.read_bytes())
    spec = importlib.util.spec_from_file_location("accounting_snapshot", snapshot)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    summary_raw = (RUN / "summary.json").read_bytes()
    check(sha(summary_raw) == "2d087cae14824363a1fe6bd1e8baeba2919ee0712f23a6c537a5d32e950944c7", "unexpected summary")
    summary = json.loads(summary_raw)
    inventory_checks = {}
    for name, entry in summary["inventory"].items():
        raw = (RUN / name).read_bytes()
        inventory_checks[name] = len(raw) == entry["bytes"] and sha(raw) == entry["sha256"]
    check(all(inventory_checks.values()), "inventory mismatch")
    plan = load("fictional-tool-plan.json")
    full = (RUN / "instruction-fixture.txt").read_bytes().decode("utf-8")
    agents = (RUN / "project-AGENTS.md").read_bytes().decode("utf-8")
    check(sha(full.encode()) == plan["fixture_sha256"], "fixture mismatch")
    check(agents == plan["trusted_project_agents"], "AGENTS mismatch")
    check(plan["expected_stdout"][2] == full == plan["expected_stdout"][3], "full outputs mismatch")
    normative_end = plan["normative_span"][1]
    account = module.ResponsesAccounting(resources={"fixture": full, "normative": full[:normative_end]}, injections=[
        {"id": "common", "text": plan["common_injection"], "roles": ["user"]},
        {"id": "project_agents", "text": agents, "roles": ["user", "developer"]},
        {"id": "quoted_hostile", "text": plan["later_injection"], "roles": ["tool"]}])
    for call_id, end in [("call_partial_read", plan["partial_span"][1]),
                         ("call_full_read", len(full)), ("call_reread", len(full))]:
        output = (RUN / (call_id + ".result.txt")).read_bytes().decode("utf-8")
        account.register_read(call_id, "fixture", output, source_end=end)
    # Normative coverage is independently calculated from the source subset of
    # exact callback outputs, rather than pretending source+quoted data is normative.
    stdout = (RUN / "continuity.stdout.bin").read_bytes()
    parsed = [json.loads(line) for line in stdout.decode("utf-8").splitlines() if line]
    check(parsed == load("parsed-cli-events.json")["events"], "CLI parsed events mismatch")
    commands = [e["item"] for e in parsed if e.get("type") == "item.completed"
                and e.get("item", {}).get("type") == "command_execution"]
    check(len(commands) == len(plan["expected_stdout"]), "execution count")
    for item, expected, code in zip(commands, plan["expected_stdout"], plan["expected_exit"]):
        check(item["aggregated_output"] == expected and item["exit_code"] == code, "actual stdout/exit mismatch")
    ledger = [json.loads(line) for line in (RUN / "read-ledger.jsonl").read_bytes().decode("utf-8").splitlines()]
    receipts = []
    for path in sorted(RUN.glob("http-???.request.bin")):
        raw = path.read_bytes()
        check(b"".join(p.read_bytes() for p in sorted(RUN.glob(path.stem.replace(".request", "") + ".request.chunk-*.bin"))) == raw,
              "request chunk mismatch")
        receipt = account.capture_request(raw, label=path.name)
        inputs = json.loads(raw)["input"]
        for item in inputs:
            if item.get("type") == "function_call":
                index = plan["call_ids"].index(item["call_id"])
                check(item["name"] == "exec_command" and json.loads(item["arguments"]) == plan["arguments"][index], "call identity/arguments mismatch")
            if item.get("type") == "function_call_output":
                saved = (RUN / (item["call_id"] + ".result.txt")).read_bytes().decode("utf-8")
                check(item["output"] == saved, "raw output mismatch")
                index = plan["call_ids"].index(item["call_id"])
                if index < len(plan["expected_stdout"]):
                    check(item["output"].endswith(plan["expected_stdout"][index]), "callback stdout suffix mismatch")
        source_spans = [event["source_span"] for event in receipt["events"] if event["type"] == "read"]
        ranges = module._union([(s["start"], min(s["end"], normative_end)) for s in source_spans])
        receipt["verified_normative_coverage"] = {"source_sha256": sha(full[:normative_end].encode()),
              "required_characters": normative_end, "spans": ranges,
              "full": sum(end - start for start, end in ranges) == normative_end,
              "model_retention": "UNKNOWN"}
        receipts.append(receipt)
    check(len(receipts) == 9, "request count")
    check([r["coverage"]["fixture"]["characters"] for r in receipts] == [0, 29, 29, 29, 257, 257, 257, 257, 257], "partial/full coverage")
    check([r["verified_normative_coverage"]["full"] for r in receipts] == [False] * 4 + [True] * 5, "normative coverage")
    check(all(any(e["type"] == "injection" and e["injection_id"] == "common" for e in r["events"]) for r in receipts), "missing common injection")
    check(all(any(e["type"] == "injection" and e["injection_id"] == "project_agents" for e in r["events"]) for r in receipts), "missing AGENTS")
    check([len([e for e in r["events"] if e["type"] == "injection" and e["injection_id"] == "quoted_hostile"]) for r in receipts] == [0, 0, 0, 0, 1, 2, 2, 2, 2], "quoted hostile injection chronology")
    check((RUN / "http-002.request.bin").read_bytes() == (RUN / "http-003.request.bin").read_bytes(), "retry mismatch")
    refusal = (RUN / "call_fictional_refusal.result.txt").read_bytes().decode("utf-8")
    check("Never" in refusal and not any("fictional_refusal.py" in item["command"] for item in commands), "escalation refusal mismatch")
    check(plan["refusal_forbidden_stdout"].encode() not in stdout, "forbidden refusal stdout")
    result = {"status": "passed", "runtime_summary_sha256": sha(summary_raw),
              "accounting_source_sha256": sha(snapshot.read_bytes()),
              "review_source_sha256": sha(Path(__file__).read_bytes()),
              "inventory_entries_rehashed": len(inventory_checks), "read_ledger": ledger,
              "actual_executions": len(commands), "requests": receipts,
              "all_request_input_text_characters": sum(r["text_characters"] for r in receipts),
              "all_request_source_characters_including_rereads": sum(e["source_span"]["characters"] for r in receipts for e in r["events"] if e["type"] == "read"),
              "limits": ["Independent of runtime source author; accounting reviewer authored accounting module",
                         "All provider outputs simulated; no model retention or AC5 claim",
                         "Function arguments/schema/JSON framing excluded from input text count",
                         "One turn only; compaction and second user message not exercised here",
                         "Historical sealed reference verification belongs to separate root audit"]}
    with (BASE / "accounting.json").open("xb") as stream:
        stream.write(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2).encode())
    print(json.dumps({"passed": True, "inventory": len(inventory_checks), "requests": len(receipts),
                      "input_text_characters": result["all_request_input_text_characters"],
                      "source_characters": result["all_request_source_characters_including_rereads"],
                      "accounting_sha256": sha((BASE / "accounting.json").read_bytes())}))


if __name__ == "__main__":
    main()
