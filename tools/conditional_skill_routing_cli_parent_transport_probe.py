"""Actual CLI child: loopback broker proxy -> framed stdio -> trusted parent.

No credential or evaluator input. Frozen broker fixture source remains unchanged.
Its unused local mock server receives zero requests; selected integrated checks
replace its local-only model receipt expectations, explicitly recorded as such.
"""
import argparse
import base64
import io
import json
from pathlib import Path
import sys
import threading
sys.path.insert(0, "/dependency-root")
from tools import conditional_skill_routing_cli_broker_profile as profile
from tools import conditional_skill_routing_parent_transport as transport


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--cli",required=True)
    parser.add_argument("--out",required=True)
    args=parser.parse_args()
    bootstrap=transport.decoded(transport.read_frame(sys.stdin.buffer,8192))
    transport.require(set(bootstrap)=={"channel_key","parent_probe_path"},"invalid bootstrap")
    key=base64.b64decode(bootstrap["channel_key"],validate=True)
    facts=profile.preflight(Path(args.cli))
    facts.update(parent_sentinel_visible=Path(bootstrap["parent_probe_path"]).exists(),
                 host_mnt_visible=Path("/mnt").exists(),host_run_visible=Path("/run").exists(),
                 mountinfo=Path("/proc/self/mountinfo").read_text())
    transport.require(not facts["parent_sentinel_visible"] and not facts["host_mnt_visible"] and not facts["host_run_visible"],"parent path exposed")
    def emit(value):
        sys.stdout.buffer.write(transport.frame(transport.packed(value)))
        sys.stdout.buffer.flush()
    emit({"type":"preflight","facts":facts})
    lock=threading.Lock()
    count=0
    observations=[]
    class RelayResponse:
        def __init__(self,value):
            self.status=value["status"]
            self.headers=value["headers"]
            self.body=value["body"]
        def getheader(self,name,default=None):
            if name.lower()=="content-length":return str(len(self.body))
            return self.headers.get(name.lower(),default)
        def read(self,count):return self.body[:count]
    class RelayConnection:
        def __init__(self,host,port,timeout):
            transport.require(host=="127.0.0.1" and 0<timeout<=3,"unexpected relay host/deadline")
            self.raw=None
        def request(self,method,path,body,headers):
            transport.require(method=="POST" and path=="/mock/responses" and headers=={"Content-Type":"application/json"},"unexpected transport request")
            self.raw=body
        def getresponse(self):
            nonlocal count
            with lock:
                count+=1
                identifier="parent-request-%03d"%count
                request=transport.make_request(identifier,"responses-fixture",self.raw,key)
                sys.stdout.buffer.write(transport.frame(request));sys.stdout.buffer.flush()
                response=transport.read_response(transport.read_frame(sys.stdin.buffer),key,identifier)
                observations.append({"id":identifier,"request_sha256":transport.sha(self.raw),"response_sha256":transport.sha(response["body"]),"status":response["status"]})
                return RelayResponse(response)
        def close(self):pass
    profile.http.client.HTTPConnection=RelayConnection
    out=Path(args.out);out.mkdir()
    original=profile.run(Path(args.cli),out,facts)
    original_summary=json.loads((out/"summary.json").read_bytes())
    receipts=json.loads((out/"proxy-receipts.json").read_bytes())
    callbacks=json.loads((out/"broker-callbacks.json").read_bytes())
    selected=["cli_version_01601","capture_and_process_complete","fixture_mutation_only_simulated",
              "two_user_turns_success_then_failed_by_gate","no_native_command_event_or_sideeffect","exact_first_final_only","all_blob_hashes"]
    checks={k:original_summary["checks"][k] for k in selected}
    checks.update(five_parent_exchanges=count==5,
                  three_actual_registered_callbacks=len(callbacks)==3,
                  first_four_complete_streams_emitted=len(receipts)==5 and all(r.get("gate_status")=="accepted_complete_stream" for r in receipts[:4]),
                  fifth_response_zero_sse_bytes=len(receipts)==5 and receipts[-1]["provider_sse_bytes_emitted_to_cli"]==0,
                  local_mock_unused=json.loads((out/"model-receipts.json").read_bytes())==[],
                  no_parent_paths=not any(facts[k] for k in ("parent_sentinel_visible","host_mnt_visible","host_run_visible")))
    summary={"passed":all(checks.values()),"checks":checks,"parent_exchanges":observations,
             "original_local_only_summary_passed":original["passed"],
             "limits":["Local broker mock receipt checks intentionally replaced: provider is Windows parent mock", "Native CLI features remain; complete SSE guard blocks unauthorized provider calls", "No real provider/account/evaluator data or model retention proof"]}
    (out/"integrated-summary.json").write_bytes(transport.packed(summary))
    emit({"type":"complete","summary":summary,"summary_sha256":transport.sha((out/"integrated-summary.json").read_bytes())})
    return 0 if summary["passed"] else 1

if __name__=="__main__":
    raise SystemExit(main())
