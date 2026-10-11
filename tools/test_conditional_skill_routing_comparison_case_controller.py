"""Deterministic authenticated parent/child control flow; no actual CLI/provider."""
import base64
import copy
import json
from pathlib import Path
import time
import unittest
from unittest.mock import patch
from tools import conditional_skill_routing_comparison_case_controller as module
from tools import conditional_skill_routing_cli_tuning_transport_probe as probe
from tools import conditional_skill_routing_comparison_adapter as adapter
from tools import conditional_skill_routing_runner as runner
from tools import conditional_skill_routing_parent_transport as wire
from tools.test_conditional_skill_routing_comparison_adapter import memory_worker

class FullParentCaseFlow(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        root=Path(__file__).parent/"fixtures/conditional_skill_routing"
        cls.manifest=json.loads((root/"manifest.json").read_bytes())
        cls.cases=json.loads((root/"cases.json").read_bytes())["cases"]

    def prepare(self,cid,provider_override=None):
        case=next(c for c in self.cases if c["id"]==cid)
        prepared=(runner.prepare_tuning_document_conversation(self.manifest,case) if cid.startswith("B") else runner.prepare_tuning_private_conversation(self.manifest,case) if cid.startswith("S") else runner.prepare_tuning_readonly_broker(self.manifest,case))
        state={"steps":[],"index":0,"calls":0}
        def provider(raw,deadline):
            state["calls"]+=1
            if provider_override: return provider_override(raw,deadline)
            step=state["steps"][state["index"]];state["index"]+=1
            if "message" in step:
                controller.guard.FINAL=step["message"]
                body=controller.guard.provider_sse("response-"+str(state["calls"]))
            else: body=controller.guard.provider_sse("response-"+str(state["calls"]),step["tool"],step["arguments"],"call-"+str(state["calls"]))
            return {"status":200,"headers":{"content-type":"text/event-stream"},"body":body}
        controller=module.CaseController(prepared,provider)
        state["steps"]=[step for phase in probe.plans(controller.subject,cid) for step in phase]
        channel=b"synthetic-channel-key-32-bytes!!!!"
        bridge=wire.ParentBridge("case-controller",controller.handle,channel_key=channel,receipt_key=b"synthetic-parent-receipt-key!!!!!",callback_timeout=10,session_timeout=60,max_requests=512,total_body=128*1024*1024,total_response=128*1024*1024)
        self.count=0
        def control(op,parameters=None):
            self.count+=1;rid="child-frame-"+str(self.count)
            request=wire.make_request(rid,"case-controller",wire.packed({"op":op,"parameters":parameters or {}}),channel)
            response=wire.read_response(bridge.handle(request),channel,rid)
            return wire.decoded(response["body"])
        return controller,state,control,bridge

    def model(self,controller,control,history):
        tools=[{"type":"function","name":row["name"],"parameters":row["inputSchema"]} for row in controller.tools]
        original={"model":"synthetic","input":history,"instructions":"\n".join(i["text"] for i in controller.subject.mcp.broker.bundle["injections"]),"tools":[{"type":"function","name":"exec_command","parameters":{}}]+tools}
        result=control("model_request",{"body_b64":base64.b64encode(wire.packed(original)).decode()})
        return probe.completed_response(base64.b64decode(result["body_b64"]))

    def flow(self,cid):
        controller,state,control,bridge=self.prepare(cid)
        bootstrap=control("bootstrap")
        self.assertEqual(set(bootstrap),{"tools","instructions","initial_turns","schema_sha256","model"})
        self.assertNotIn("files",json.dumps(bootstrap))
        control("bind_thread",{"thread_id":"actual-"+cid})
        history=[];turns=0
        while True:
            nxt=control("next_user_turn")["turn"]
            if nxt is None:break
            turns+=1;turn="actual-turn-"+str(turns)
            control("begin_turn",{"turn_id":turn})
            history.append({"type":"message","role":"user","content":nxt["content"]})
            while True:
                response=self.model(controller,control,history)
                for item in response["output"]:
                    if item["type"]=="message":
                        history.append({"type":"message","role":"assistant","content":item["content"]})
                    else:
                        history.append({"type":"function_call","name":item["name"],"call_id":item["call_id"],"arguments":item["arguments"]})
                        result=control("tool_callback",{"parameters":{"tool":item["name"],"callId":item["call_id"],"threadId":controller.subject.thread_id,"turnId":turn,"arguments":json.loads(item["arguments"])}})
                        history.append({"type":"function_call_output","call_id":item["call_id"],"output":result["contentItems"][0]["text"]})
                if any(i["type"]=="message" for i in response["output"]):break
        self.assertEqual(state["index"],len(state["steps"]))
        self.assertFalse(controller.retired)
        self.assertTrue(all(c["delivered"] for c in controller.subject.callbacks.values()))
        self.assertTrue(all(r["non_tools_values_unchanged"] for r in controller.responses))
        self.assertEqual(len(controller.raw_exchanges),len(controller.responses))
        for raw,hashed in zip(controller.raw_exchanges,controller.responses):
            self.assertEqual(wire.sha(raw["original_request"]),hashed["original_request_sha256"])
            self.assertEqual(wire.sha(raw["request"]),hashed["model_request_sha256"])
            self.assertEqual(wire.sha(raw["response"]),hashed["response_sha256"])
        self.assertNotIn("raw_exchanges",controller.summary())
        self.assertTrue(all(r["status"]=="forwarded" for r in bridge.receipts))
        return controller,state,bootstrap

    @patch.object(runner,"run_worker",side_effect=memory_worker)
    def test_all_eight_families_complete_authenticated_parentowned_flow(self,worker):
        for cid in [c["id"] for c in self.cases]:
            with self.subTest(case=cid):
                controller,state,bootstrap=self.flow(cid)
                self.assertEqual(len(bootstrap["tools"]),{"H1":2,"H2":2,"A1":4,"A2":3,"B1":4,"B2":7,"S1":5,"S2":5}[cid])
                if cid.startswith("S"):self.assertEqual(controller.subject.prepared.redaction.receipts[-1]["redaction"],"pass")
                if cid in ("B1","B2","S2"):self.assertEqual(len(controller.released),1)
                if len(controller.initial)==3:
                    self.assertEqual(controller.responses[0]["instruction_metric_inclusion"],"synthetic_history_priming_excluded")
                    self.assertEqual(len(controller.responses),state["calls"]+1)
                else:self.assertEqual(len(controller.responses),state["calls"])

    def test_public_diagnostic_factory_preserves_hostonly_script_and_rejects_heldout(self):
        for case in self.cases:
            c,provider=module.prepare_public_tuning_mock(self.manifest,case)
            self.assertEqual(provider.index,0)
            self.assertFalse(c.launch_authorized)
            self.assertEqual(provider.summary()["model_calls"],0)
        with self.assertRaises(module.ControllerError):
            module.prepare_public_tuning_mock(self.manifest,{"id":"H3","split":"heldout"})

    def test_mock_only_constructor_rejects_live(self):
        c=next(c for c in self.cases if c["id"]=="H1")
        p=runner.prepare_tuning_readonly_broker(self.manifest,c)
        with self.assertRaises(module.ControllerError):module.CaseController(p,lambda *a:None,provider_kind="live")

    def test_inactive_live_path_requires_exact_approved_profile_and_uses_fake_https_only(self):
        from tools.test_conditional_skill_routing_parent_https import callback, FakeResponse
        response_body=probe.profile.provider_sse("synthetic-live-path")
        callback_instance,connections=callback(response=FakeResponse(response_body,headers={"content-type":"text/event-stream"}))
        unsigned={"endpoint":callback_instance.endpoint,"model":callback_instance.model,"account_label":callback_instance.account_label,
                  "settings_sha256":wire.sha(wire.packed(callback_instance.settings)),"budget_review_id":callback_instance.approved_budget["review_id"],
                  "independent_review_id":"synthetic-offline-profile-review"}
        approved={**unsigned,"profile_sha256":wire.sha(wire.packed(unsigned))}
        case=next(c for c in self.cases if c["id"]=="H1")
        for options in ({},{"launch_authorized":True},{"launch_authorized":True,"approved_profile":{**approved,"model":"wrong"}}):
            with self.assertRaises(module.ControllerError):
                module.CaseController(runner.prepare_tuning_readonly_broker(self.manifest,case),callback_instance,provider_kind="live",**options)
        self.assertEqual(connections,[])
        c=module.CaseController(runner.prepare_tuning_readonly_broker(self.manifest,case),callback_instance,provider_kind="live",launch_authorized=True,approved_profile=approved)
        def direct(op,params=None):
            return wire.decoded(c.handle(wire.packed({"op":op,"parameters":params or {}}),time.monotonic()+5)["body"])
        bootstrap=direct("bootstrap");self.assertEqual(bootstrap["model"],"named-model")
        direct("bind_thread",{"thread_id":"synthetic-live-thread"});turn=direct("next_user_turn")["turn"];direct("begin_turn",{"turn_id":"synthetic-live-turn"})
        raw=wire.packed({"model":"named-model","store":False,"stream":True,"max_output_tokens":32,
                         "input":[{"type":"message","role":"user","content":turn["content"]}],
                         "tools":[{"type":"function","name":r["name"],"parameters":r["inputSchema"]} for r in c.tools]})
        result=direct("model_request",{"body_b64":base64.b64encode(raw).decode()})
        self.assertEqual(base64.b64decode(result["body_b64"]),response_body)
        self.assertEqual(c.summary()["live_callback_attempts"],1)
        self.assertEqual(c.summary()["model_calls"],1)
        self.assertEqual(len(connections),1)
        self.assertNotIn("SYNTHETIC_PARENT_SECRET",json.dumps(c.summary()))

    def test_live_https_subclass_override_refused_and_mime_utf8_only(self):
        from tools.conditional_skill_routing_parent_https import PreparedHTTPSCallback
        from tools.test_conditional_skill_routing_parent_https import callback
        class Override(PreparedHTTPSCallback):
            def __call__(self,*args):raise AssertionError("must not dispatch overridden HTTPS")
        cb,_=callback();cb.__class__=Override
        case=next(c for c in self.cases if c["id"]=="H1")
        with self.assertRaises(module.ControllerError):
            module.CaseController(runner.prepare_tuning_readonly_broker(self.manifest,case),cb,provider_kind="live",launch_authorized=True)
        for mime in ("text/event-stream","text/event-stream; charset=utf-8",'Text/Event-Stream; Charset="UTF-8"'):
            self.assertTrue(module.event_stream_type({"content-type":mime}))
        for mime in ("application/json","text/event-stream; charset=latin1","text/event-stream; charset=utf-8; extra=x","text/event-stream;"):
            self.assertFalse(module.event_stream_type({"content-type":mime}))

    def test_isolated_percase_gate_registry_does_not_mutate_global_frozen_profile(self):
        before=list(probe.profile.NAMES)
        a,_,_,_=self.prepare("A1");s,_,_,_=self.prepare("S1")
        self.assertIn("audit",a.guard.NAMES);self.assertNotIn("audit",s.guard.NAMES)
        self.assertEqual(probe.profile.NAMES,before)

    def test_forged_callback_without_complete_emitted_call_retires(self):
        c,_,call,_=self.prepare("H1")
        call("bootstrap");call("bind_thread",{"thread_id":"actual"})
        with self.assertRaises(Exception):call("tool_callback",{"parameters":{"tool":"exec_command","callId":"forged","arguments":{},"threadId":"actual","turnId":"forged"}})
        self.assertTrue(c.retired);self.assertTrue(c.subject.retired)

    def test_emitted_call_binding_rejects_foreign_turn_before_callback_dispatch(self):
        c,_,call,_=self.prepare("H1")
        call("bootstrap");call("bind_thread",{"thread_id":"actual"});nxt=call("next_user_turn")["turn"];call("begin_turn",{"turn_id":"actual-turn"})
        response=self.model(c,call,[{"type":"message","role":"user","content":nxt["content"]}])
        item=response["output"][0]
        with self.assertRaises(Exception):
            call("tool_callback",{"parameters":{"tool":item["name"],"callId":item["call_id"],"threadId":"actual","turnId":"foreign-turn","arguments":json.loads(item["arguments"])}})
        self.assertTrue(c.retired)
        self.assertEqual(c.subject.callbacks,{})

    def test_partial_native_wrongargs_provider_streams_emit_nothing_and_retire(self):
        for kind in ("native","partial","wrongargs"):
            with self.subTest(kind=kind):
                def provider(raw,deadline):
                    if kind=="native":body=probe.profile.provider_sse("native","exec_command",{},"native-call")
                    elif kind=="partial":body=b'event: response.created\ndata: {}\n\n'
                    else:body=probe.profile.provider_sse("bad","instruction_read",{"resource_id":"invalid","spans":False},"wrong-call")
                    return {"status":200,"headers":{"content-type":"text/event-stream"},"body":body}
                c,_,call,_=self.prepare("H1",provider)
                call("bootstrap");call("bind_thread",{"thread_id":"actual"});nxt=call("next_user_turn")["turn"];call("begin_turn",{"turn_id":"actual-turn"})
                with self.assertRaises(Exception):self.model(c,call,[{"type":"message","role":"user","content":nxt["content"]}])
                self.assertTrue(c.retired);self.assertEqual(c.responses,[])
                self.assertEqual(c.raw_exchanges,[])

    def test_missing_current_user_delivery_retires_before_provider_callback(self):
        c,state,call,_=self.prepare("H1")
        call("bootstrap");call("bind_thread",{"thread_id":"actual"});call("next_user_turn");call("begin_turn",{"turn_id":"actual-turn"})
        with self.assertRaises(Exception):self.model(c,call,[])
        self.assertEqual(state["calls"],0);self.assertTrue(c.retired)

    def test_native_compaction_notification_retires_before_postloss_callback(self):
        c,_,call,_=self.prepare("S2")
        call("bootstrap");call("bind_thread",{"thread_id":"actual"})
        event={"jsonrpc":"2.0","method":"item/started","params":{"threadId":"actual","turnId":"turn","item":{"type":"contextCompaction","id":"compaction-id"}}}
        result=call("native_context_loss",{"event":event})
        self.assertTrue(result["retired"])
        self.assertEqual(result["coverage"],"UNKNOWN")
        self.assertTrue(c.subject.retired)
        self.assertFalse(c.subject.mcp.private_gate.granted)
        self.assertEqual(c.subject.accounting.coverage,{})
        with self.assertRaises(Exception):call("tool_callback",{"parameters":{"tool":"private_status","callId":"after-loss","arguments":{},"threadId":"actual","turnId":"turn"}})
        self.assertEqual(c.subject.callbacks,{})

    def test_control_unknown_replay_or_deadline_is_failclosed(self):
        for op in ("unknown","bootstrap"):
            c,_,call,_=self.prepare("H1");call("bootstrap")
            with self.assertRaises(Exception):call(op)
            self.assertTrue(c.retired)
        c,_,_,_=self.prepare("H1")
        with self.assertRaises(module.ControllerError):c.handle(wire.packed({"op":"bootstrap","parameters":{}}),time.monotonic()-1)
        self.assertTrue(c.retired)

if __name__=="__main__":unittest.main()
