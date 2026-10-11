"""Evaluator-only deterministic binding validation. No model or campaign launch.
Does not print private prompts, expected answers, fixture text or callback bytes.
"""
import copy
import hashlib
import json
from pathlib import Path
from unittest.mock import patch
from tools import conditional_skill_routing_shared_campaign as shared
from tools import conditional_skill_routing_comparison_adapter as bridge
from tools import conditional_skill_routing_cli_tuning_transport_probe as probe
from tools import conditional_skill_routing_runner as runner

def sha(raw): return hashlib.sha256(raw).hexdigest()
def worker(bundle, requests, **unused):
    session = runner.FixtureSession(bundle)
    results = []
    for request in requests:
        try: results.append({"ok": True, "result": session.dispatch(request)})
        except runner.RunnerError as error: results.append({"ok": False, "error": str(error)})
    return {"results": results, "receipts": session.receipts, "model_calls": 0}

def run():
    root = Path(__file__).resolve().parents[5]
    base = root / "tools/fixtures/conditional_skill_routing"
    private = Path(__file__).parent / "evaluator-cases-new-private.json"
    original = private.read_bytes()
    assert sha(original) == "127a698895e16014e437ca4744f3c7db8e77ada90c2c5ef2d5de121dc91cedf4"
    heldout = json.loads(original)["cases"]
    public = json.loads((base / "cases.json").read_bytes())["cases"]
    manifest_bytes = (base / "manifest.json").read_bytes()
    assert sha(manifest_bytes) == "320e67617d89b6f9e7e7bca5e4b619c0ba60105de60574a5b73d39b73411bb25"
    manifest = json.loads(manifest_bytes)
    for case in heldout:
        siblings = [c for c in public if c["family"] == case["family"] and c["posture"] == case["posture"]]
        assert len(siblings) == 1
        manifest["subject_resources"]["baseline"]["case_maps"][case["id"]] = copy.deepcopy(manifest["subject_resources"]["baseline"]["case_maps"][siblings[0]["id"]])
    receipts = []
    with patch.object(runner, "run_worker", side_effect=worker):
        for case in heldout:
            subject = bridge.ComparisonAdapter(shared.prepare_adapter(manifest, case, "baseline"), thread_id="offline-"+case["id"], turn_id="offline-initial")
            history = [{"type":"message", "role":t["role"], "content":t["content"]} for t in subject.mcp.broker.bundle["turns"]]
            subject.observe_request(bridge.encoded({"input":history}), label="initial")
            if case["family"] == "bounded_docs" and subject.mcp.released_actions is None:
                collector=subject.prepared.collector
                reads=[{"tool":"instruction_read","arguments":{"resource_id":rid,"spans":None}} for rid in subject.accounting.resources]
                phases=[reads+[{"tool":"fixture_read","arguments":{"target":collector.target}},{"message":collector.approval_question()}],
                        [{"tool":"simulated_replace","arguments":{"target":collector.target,"old":collector.old,"new":collector.new}},
                         {"tool":"focused_verify","arguments":{"target":collector.target}},
                         {"message":"Synthetic exact replacement verified; unrelated bytes preserved."}]]
            else:
                phases = probe.plans(subject, case["id"])
            identity_checked = mismatch_refused = preflight_delivery_checked = False
            for phase_index, phase in enumerate(phases):
                if phase_index:
                    subject.begin_turn("offline-phase-"+str(phase_index))
                    subject.observe_request(bridge.encoded({"input":history}), label="conditional")
                for step in phase:
                    if "message" in step:
                        result = subject.observe_assistant_response(bridge.encoded({"id":case["id"]+"-response-"+str(phase_index),"status":"completed","output":[{"type":"message","role":"assistant","content":[{"type":"output_text","text":step["message"]}]}]}))
                        history += [{"type":"message","role":"assistant","content":step["message"]}]
                        history += [{"type":"message","role":t["role"],"content":t["content"]} for t in result["released_turns"]]
                        continue
                    def call(name, args):
                        cid=case["id"]+"-call-"+str(len(subject.callbacks))
                        result=subject.dispatch({"arguments":args,"callId":cid,"threadId":subject.thread_id,"turnId":subject.turn_id,"tool":name})
                        history.extend([{"type":"function_call","name":name,"call_id":cid,"arguments":json.dumps(args,ensure_ascii=False)},{"type":"function_call_output","call_id":cid,"output":result["contentItems"][0]["text"]}])
                        subject.observe_request(bridge.encoded({"input":history}), label=cid)
                        return result
                    if case["id"] == "A3" and step["tool"] == "invocation_preflight":
                        contract=subject.mcp.released_actions.contracts["invocation_preflight"]
                        args=copy.deepcopy(contract["arguments"])
                        scope=args["scope"]
                        scoped=[(path,text) for path,text in case["fixture"]["files"].items() if path==scope or path.startswith(scope.rstrip("/")+"/")]
                        assert len(scoped)==1
                        path,text=scoped[0]
                        assert "sg-help" in path and "sg-help" in text
                        assert args["engine"] == "900-shipglows-core" and args["mode"] == "audit"
                        identity_checked=True
                        args["engine"]="skills/000-fictional-mismatch/SKILL.md"
                        mismatch_refused=call("invocation_preflight",args)["success"] is False
                    result=call(step["tool"],step["arguments"])
                    if case["id"] == "A3" and step["tool"] == "audit" and result["success"]:
                        preflight_delivery_checked=any(row["tool"]=="invocation_preflight" and row["success"] and row["delivered"] for row in subject.callbacks.values())
            assert not subject.retired and all(row["delivered"] for row in subject.callbacks.values())
            private_pass=subject.prepared.redaction.receipts[-1]["redaction"]=="pass" if hasattr(subject.prepared,"redaction") and subject.prepared.redaction else None
            if case["id"].startswith("S"): assert private_pass
            if case["id"]=="A3": assert identity_checked and mismatch_refused and preflight_delivery_checked
            receipts.append({"case_slot":case["id"],"schema_sha256":subject.schema_hash,"tool_names":sorted(subject.tools),"callbacks":len(subject.callbacks),"all_exactly_delivered":True,"private_redaction_pass":private_pass,"a3_identity_consistent":identity_checked if case["id"]=="A3" else None,"a3_mismatch_refused":mismatch_refused if case["id"]=="A3" else None,"a3_prerequisite_delivery_checked":preflight_delivery_checked if case["id"]=="A3" else None})
    assert private.read_bytes()==original
    dependencies={str(path.relative_to(root)):sha(path.read_bytes()) for path in [root/"tools/conditional_skill_routing_comparison_adapter.py",root/"tools/conditional_skill_routing_responses_accounting.py",root/"tools/conditional_skill_routing_shared_campaign.py",root/"tools/conditional_skill_routing_cli_tuning_transport_probe.py",root/"tools/conditional_skill_routing_runner.py",root/"tools/conditional_skill_routing_eval.py",root/"tools/skill_activation_budget.py"]}
    receipt={"schema_version":1,"status":"sealed_executable_baseline_binding_offline","heldout_cases":8,"private_payload_sha256":sha(original),"private_payload_unchanged":True,"baseline_manifest_sha256":sha(manifest_bytes),"dependencies":dependencies,"validation_script_sha256":sha(Path(__file__).read_bytes()),"executable_binding_complete":True,"final_transport_profile_attachment_pending":True,"independent_review":False,"case_receipts":receipts,"model_calls":0,"campaign_runs":[],"limits":["In-memory deterministic callback binding validation; no held-out CLI or model run", "Final provider/tool/source profile attachment and independent evaluator review pending", "Fresh source/consent reacquisition required for each actual run", "Candidate binding follows future candidate freeze; no candidate exists yet", "Contractual evaluator separation only; physical isolation proof is external"]}
    destination=base/"preparation-revisions/codex-linux-real-v2-heldout-executable-baseline-binding-public.json"
    assert not destination.exists(), "immutable new receipt already exists"
    destination.write_bytes(json.dumps(receipt,ensure_ascii=False,indent=2).encode()+b"\n")
    print(json.dumps({"passed":True,"cases":8,"receipt_sha256":sha(destination.read_bytes()),"private_payload_unchanged":True}))
if __name__=="__main__": run()
