"""Adversarial fixtures for the independent raw case replay."""
import base64
import hashlib
import json
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from tools import conditional_skill_routing_parent_transport as wire
from tools.conditional_skill_routing_case_proof_review import review, ReviewError

KEY=b"independent-case-review-channel-key"
CALL="mock-call-1"
TEXT="Exact executed fixture result\n"
ARGS={"target":"fixture"}
SCHEMA={"type":"object","properties":{"target":{"type":"string"}},"required":["target"],"additionalProperties":False}
TOOL={"type":"function","name":"fixture_read","description":"Read fixture","parameters":SCHEMA,"strict":False}
REGISTERED={"type":"function","name":"fixture_read","description":"Read fixture","inputSchema":SCHEMA}

def pack(value):return json.dumps(value,ensure_ascii=False,sort_keys=True,separators=(",",":")).encode()
def completed(identifier,item):
    events=[
        {"type":"response.created","response":{"id":identifier}},
        {"type":"response.output_item.done","output_index":0,"item":item},
        {"type":"response.completed","response":{"id":identifier,"status":"completed","output":[item]}},
    ]
    return b"".join(b"data: "+pack(event)+b"\n\n" for event in events)
def parent_reply(identifier,result):
    raw=pack(result)
    return pack(wire.authenticated({"version":1,"id":identifier,"status":200,
        "headers":{"content-type":"application/json"},"body_b64":base64.b64encode(raw).decode(),
        "body_sha256":wire.sha(raw)},KEY))

class CaseReviewTests(unittest.TestCase):
    def fixture(self, *, corrupt_next=False, later_change=False):
        arguments=pack(ARGS).decode()
        call={"type":"function_call","id":"item-1","call_id":CALL,"name":"fixture_read","arguments":arguments,"status":"completed"}
        message={"type":"message","id":"item-2","role":"assistant","content":[{"type":"output_text","text":"done"}],"status":"completed"}
        response1=completed("response-1",call);response2=completed("response-2",message)
        first={"input":[{"type":"message","role":"user","content":"start"}],"tools":[TOOL],
               "instructions":"same typed input","stream":True}
        output=TEXT if not later_change else "changed\n"
        second={"input":[{"type":"function_call","call_id":CALL,"name":"fixture_read","arguments":arguments},
                         {"type":"function_call_output","call_id":CALL,"output":output}],"tools":[TOOL],
                "instructions":"same typed input","stream":True}
        if corrupt_next:second["input"]=[second["input"][0]]
        raw1,raw2=pack(first),pack(second)
        forwarded1={**first,"tools":[TOOL]};forwarded2={**second,"tools":[TOOL]}
        fwd1,fwd2=pack(forwarded1),pack(forwarded2)
        controller=SimpleNamespace(
            provider_kind="mock",provider_callback=SimpleNamespace(model="synthetic"),
            tools=[REGISTERED],
            raw_exchanges=[{"original_request":raw1,"request":fwd1,"response":response1,"origin":"injected_mock_provider"},
                           {"original_request":raw2,"request":fwd2,"response":response2,"origin":"injected_mock_provider"}],
            responses=[{"original_request_sha256":wire.sha(raw1),"model_request_sha256":wire.sha(fwd1),
                        "response_sha256":wire.sha(response1),"non_tools_values_unchanged":True,"origin":"injected_mock_provider"},
                       {"original_request_sha256":wire.sha(raw2),"model_request_sha256":wire.sha(fwd2),
                        "response_sha256":wire.sha(response2),"non_tools_values_unchanged":True,"origin":"injected_mock_provider"}],
            subject=SimpleNamespace(callbacks={CALL:{"call_id":CALL,"content":TEXT,"delivered":True,"success":True}},
                                    responses=[{"content":"done"}],summary=lambda:{"mock":True}))
        callback={"callId":CALL,"tool":"fixture_read","arguments":ARGS,"threadId":"thread-1","turnId":"turn-1"}
        operations=[
            ("model_request",{"body_b64":base64.b64encode(raw1).decode()},
             {"status":200,"headers":{"content-type":"text/event-stream"},"body_b64":base64.b64encode(response1).decode()}),
            ("tool_callback",{"parameters":callback},{"success":True,"contentItems":[{"type":"inputText","text":TEXT}]}),
            ("model_request",{"body_b64":base64.b64encode(raw2).decode()},
             {"status":200,"headers":{"content-type":"text/event-stream"},"body_b64":base64.b64encode(response2).decode()}),
        ]
        frames=[];replies=[]
        for idx,(op,params,result) in enumerate(operations):
            identifier="review-%d"%idx
            frames.append(wire.make_request(identifier,"case-controller",pack({"op":op,"parameters":params}),KEY))
            replies.append(parent_reply(identifier,result))
        return controller,frames,replies,callback,call,message

    def run_review(self,root,controller,frames,replies,callback,call,message):
        run=root/"run";run.mkdir()
        (run/"synthetic-project").mkdir()
        config={"config":{"tool_output_token_limit":100000,"model":"synthetic"}}
        events=[{"jsonrpc":"2.0","id":44,"method":"item/tool/call","params":callback},
                {"method":"item/completed","params":{"item":{"type":"agentMessage","text":"done"}}}]
        incoming=[{"jsonrpc":"2.0","method":"config/read","id":9000,"params":{"includeLayers":False}},
                  {"jsonrpc":"2.0","method":"item/tool/call","id":44,"params":{},"result":
                   {"success":True,"contentItems":[{"type":"inputText","text":TEXT}]}}]
        events.insert(0,{"jsonrpc":"2.0","id":9000,"result":config})
        (run/"rpc-stdout-0000.bin").write_bytes(b"".join(pack(row)+b"\n" for row in events))
        (run/"rpc-input-0000.bin").write_bytes(b"".join(pack(row)+b"\n" for row in incoming))
        (run/"rpc-events.json").write_bytes(pack({"events":events}))
        (run/"rpc-events.json").write_bytes(pack({"events":events}))
        (run/"effective-config-read.json").write_bytes(pack(config))
        http=[{"body_sha256":wire.sha(ex["original_request"])} for ex in controller.raw_exchanges]
        for idx,exchange in enumerate(controller.raw_exchanges,1):
            (run/("cli-http-%03d.request.bin"%idx)).write_bytes(exchange["original_request"])
            (run/("cli-http-%03d.parent-response.bin"%idx)).write_bytes(exchange["response"])
            http[idx-1].update(response_sha256=wire.sha(exchange["response"]),sent_complete=True)
        (run/"http-receipts.json").write_bytes(pack(http))
        facts={"cli_sha256":"a"*64,"interfaces":["lo"],"nonloopback_probe_errno":101,
               "parent_sentinel_visible":False,"mnt_visible":False,"run_visible":False,
               "mountinfo":"36 25 0:32 / /dependency-root ro - tmpfs tmpfs rw\n"+
                           "37 25 0:32 / /probe.py ro - tmpfs tmpfs rw\n"+
                           "38 25 0:32 / /codex ro - tmpfs tmpfs rw\n"}
        deps={"tools/conditional_skill_routing_cli_broker_profile.py":{"bytes":99,"sha256":"b"*64},
              "tools/conditional_skill_routing_parent_transport.py":{"bytes":101,"sha256":"c"*64}}
        return review(frames,replies,controller,root,KEY,facts,child_dependencies=deps,expected_cli_sha256="a"*64)

    def test_exact_immediate_and_later_result_passes(self):
        controller,frames,replies,callback,call,message=self.fixture()
        with TemporaryDirectory() as folder:
            receipt=self.run_review(Path(folder),controller,frames,replies,callback,call,message)
        self.assertEqual(receipt["status"],"independent_raw_associations_verified_before_cleanup")
        self.assertTrue(receipt["checks"]["every_callback_exact_in_immediately_next_and_later_cli_requests"])
        self.assertNotIn(TEXT,json.dumps(receipt))

    def test_skipped_or_changed_next_result_fails_closed(self):
        for options in ({"corrupt_next":True},{"later_change":True}):
            controller,frames,replies,callback,call,message=self.fixture(**options)
            with TemporaryDirectory() as folder:
                with self.assertRaises(ReviewError):
                    self.run_review(Path(folder),controller,frames,replies,callback,call,message)

if __name__=="__main__":unittest.main()
