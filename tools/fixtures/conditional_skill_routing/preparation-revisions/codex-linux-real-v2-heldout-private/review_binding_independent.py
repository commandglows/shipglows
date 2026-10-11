"""Distinct evaluator replay in a temporary exact-source mirror. No model calls.

Never emits private prompts, expected answers, fixtures, callback outputs or
exception text. Immutable author receipts and payload are read-only inputs.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def sha(raw):return hashlib.sha256(raw).hexdigest()
def check(ok):
    if not ok:raise ValueError("independent sealed binding check failed")

def main():
    root=Path(__file__).resolve().parents[5]
    base=root/"tools/fixtures/conditional_skill_routing"
    revisions=base/"preparation-revisions"
    private=Path(__file__).parent
    public_path=revisions/"codex-linux-real-v2-heldout-executable-baseline-binding-public.json"
    closure_path=revisions/"codex-linux-real-v2-heldout-binding-source-closure-public.json"
    output=revisions/"codex-linux-real-v2-heldout-binding-independent-review-public.json"
    check(not output.exists())
    public_raw=public_path.read_bytes();public=json.loads(public_raw)
    closure_raw=closure_path.read_bytes();closure=json.loads(closure_raw)
    payload=(private/"evaluator-cases-new-private.json").read_bytes()
    validator=(private/"validate_executable_binding.py").read_bytes()
    check(sha(payload)==public["private_payload_sha256"]==closure["private_payload_sha256"])
    check(sha(public_raw)==closure["binding_receipt_sha256"])
    check(sha(validator)==public["validation_script_sha256"]==closure["validation_script_sha256"])
    check(public["dependencies"]==closure["source_hashes"])
    hidden=json.loads(payload)["cases"]
    released=json.loads((base/"cases.json").read_bytes())["cases"]
    check(len(hidden)==8 and len({c["id"] for c in hidden})==8)
    check(all(len([s for s in released if s["family"]==c["family"] and s["posture"]==c["posture"]])==1 for c in hidden))
    check(len({(c["family"],c["posture"]) for c in hidden})==8)
    manifest=(base/"manifest.json").read_bytes()
    check(sha(manifest)==public["baseline_manifest_sha256"])
    snapshot=private/"baseline-binding-source-snapshot"
    hashes={}
    with tempfile.TemporaryDirectory(prefix="sg-distinct-heldout-evaluator-") as temporary:
        mirror=Path(temporary)
        for relative,expected in closure["source_hashes"].items():
            raw=(snapshot/relative).read_bytes();check(sha(raw)==expected)
            target=mirror/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw)
            hashes[relative]=sha(raw)
        # Broker helpers are additional frozen public transport dependency; no
        # model invocation occurs in this deterministic binding replay.
        broker=root/"tools/conditional_skill_routing_cli_broker_profile.py"
        broker_raw=broker.read_bytes()
        check(sha(broker_raw)=="7c25cf087b5a1d4e800889bb1ccd16fad8e65da2b16f3085dd6c4a4e72e07dd7")
        (mirror/"tools/conditional_skill_routing_cli_broker_profile.py").write_bytes(broker_raw)
        mirrored_private=mirror/private.relative_to(root)
        mirrored_private.mkdir(parents=True)
        (mirrored_private/"evaluator-cases-new-private.json").write_bytes(payload)
        (mirrored_private/"validate_executable_binding.py").write_bytes(validator)
        mirrored_base=mirror/base.relative_to(root)
        (mirrored_base/"manifest.json").write_bytes(manifest)
        (mirrored_base/"cases.json").write_bytes((base/"cases.json").read_bytes())
        environment={"PYTHONPATH":str(mirror),"PYTHONDONTWRITEBYTECODE":"1","SystemRoot":os.environ.get("SystemRoot","")}
        completed=subprocess.run([sys.executable,"-B",str(mirrored_private/"validate_executable_binding.py")],
                                 cwd=mirror,env=environment,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=60)
        check(completed.returncode==0)
        regenerated=json.loads((mirror/public_path.relative_to(root)).read_bytes())
        # Byte equality is stronger than aggregate callback/hash comparison.
        check((mirror/public_path.relative_to(root)).read_bytes()==public_raw)
        check(regenerated["case_receipts"]==public["case_receipts"] and regenerated["model_calls"]==0 and regenerated["campaign_runs"]==[])
        check(all(r["all_exactly_delivered"] for r in regenerated["case_receipts"]))
        mirror_path=mirror
    check(not mirror_path.exists())
    check(public_path.read_bytes()==public_raw and closure_path.read_bytes()==closure_raw and (private/"evaluator-cases-new-private.json").read_bytes()==payload)
    receipt={"schema_version":1,"status":"independently_replayed_exact_sealed_baseline_binding", "date":"2026-10-08",
             "reviewer":"compaction_probe_distinct_from_binding_author", "author_binding_receipt_sha256":sha(public_raw),
             "author_source_closure_receipt_sha256":sha(closure_raw),"private_payload_sha256":sha(payload),
             "review_source_sha256":sha(Path(__file__).read_bytes()),"dependencies_verified":hashes,
             "additional_public_broker_sha256":sha(broker_raw),"cases_checked":8,
             "all_family_posture_slots_unique":True,"exact_author_receipt_reproduced":True,
             "all_callback_outputs_exactly_delivered_in_memory":True,"private_payload_and_author_receipts_unchanged":True,
             "temporary_mirror_removed":True,"model_calls":0,"campaign_runs":[],
             "limits":["Deterministic in-memory baseline binding replay only; no held-out CLI/model launch",
                       "Independent evaluator reviewed source/schema/identity prerequisites and exact archived dependency closure",
                       "Author binding predates typed-const CLI normalization; final current transport/profile attachment remains required",
                       "No private prompts/expectations/fixture or output bytes included; candidate author remains blinded",
                       "Contractual evaluator separation; physical isolation not established"]}
    with output.open("xb") as f:f.write(json.dumps(receipt,indent=2).encode()+b"\n")
    print(json.dumps({"passed":True,"cases":8,"receipt_sha256":sha(output.read_bytes()),"model_calls":0}))

if __name__=="__main__":
    try:main()
    except Exception as error:
        print(json.dumps({"passed":False,"exception_type":type(error).__name__,"exception_sha256":sha(str(error).encode())}))
        raise SystemExit(1)
