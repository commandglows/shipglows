import base64
import io
import unittest
from tools import conditional_skill_routing_cli_case_child as child
from tools import conditional_skill_routing_parent_transport as wire

KEY=b"synthetic-child-test-key-00000001"
class Capture:
    def __init__(self):self.saved={}
    def save(self,name,raw):self.saved[name]=raw

def executable():
    tools=[{"type":"function","name":"fixture_read","description":"fixture only","inputSchema":{"type":"object"}}]
    return {"model":"synthetic","tools":tools,"instructions":"exact parent instructions", "schema_sha256":wire.sha(wire.packed(tools)),
            "initial_turns":[{"role":"user","content":"prior"},{"role":"assistant","content":"prior native assistant"},{"role":"user","content":"current"}]}

class ChildContractTests(unittest.TestCase):
    def test_exact_executable_and_native_history_not_rewritten(self):
        value=executable()
        self.assertIs(child.validate_executable(value),value)
        self.assertEqual(value["initial_turns"][1]["role"],"assistant")
        for turn in value["initial_turns"]:
            if turn["role"]=="assistant":
                with self.assertRaises(ValueError):child.validate_user_turn(turn)
            else:self.assertIs(child.validate_user_turn(turn),turn)
    def test_unknown_executable_fields_duplicate_tools_and_bad_roles_refused(self):
        for mutate in [lambda v:v.update(extra="hidden case"),lambda v:v.update(model='bad"\nbase_url="external"'),lambda v:v["tools"].append(v["tools"][0]),
                       lambda v:v["tools"][0].update(type="namespace"),lambda v:v["initial_turns"][0].update(role="system")]:
            value=executable();mutate(value)
            with self.assertRaises(ValueError):child.validate_executable(value)
    def test_relay_exact_binary_body_and_authenticated_response(self):
        result={"status":200,"headers":{"content-type":"text/event-stream"},"body_b64":base64.b64encode(b"exact\n\n").decode()}
        payload=wire.packed(result)
        response=wire.packed(wire.authenticated({"version":1,"id":"case-child-0001","status":200,"headers":{"content-type":"application/json"},"body_b64":base64.b64encode(payload).decode(),"body_sha256":wire.sha(payload)},KEY))
        writer=io.BytesIO();capture=Capture()
        relay=child.Relay(wire,io.BytesIO(wire.frame(response)),writer,KEY,capture)
        exact=br'{ "input":"snowman \u2603", "tools":[] }'
        args={"body_b64":base64.b64encode(exact).decode()}
        self.assertEqual(relay.call("model_request",args),result)
        sent=wire.verify(wire.decoded(wire.read_frame(io.BytesIO(writer.getvalue()))),KEY)
        request=wire.decoded(base64.b64decode(sent["body_b64"]))
        self.assertEqual(sent["endpoint"],"case-controller")
        self.assertEqual(request,{"op":"model_request","parameters":args})
        self.assertEqual(base64.b64decode(request["parameters"]["body_b64"]),exact)
    def test_relay_bad_auth_permanently_retires_before_second_write(self):
        writer=io.BytesIO();relay=child.Relay(wire,io.BytesIO(wire.frame(b'{"auth":"invalid"}')),writer,KEY,Capture())
        with self.assertRaises(Exception):relay.call("bootstrap",{})
        before=writer.getvalue()
        with self.assertRaisesRegex(ValueError,"retired"):relay.call("bootstrap",{})
        self.assertEqual(writer.getvalue(),before)

class ContextBoundaryTests(unittest.TestCase):
    def test_pinned_structural_loss_signals_and_transcript_inertness(self):
        for event in [{"method":"thread/compacted","params":{}},
                      {"method":"item/started","params":{"item":{"type":"contextCompaction","id":"compact"}}},
                      {"method":"item/completed","params":{"item":{"type":"contextCompaction","id":"compact"}}},
                      {"method":"hook/started","params":{"run":{"eventName":"preCompact"}}},
                      {"method":"item/completed","params":{"item":{"type":"reasoning","encrypted_content":"opaque"}}}]:
            self.assertIsNotNone(child.context_loss_reason(event))
        for event in [{"method":"item/completed","params":{"item":{"type":"agentMessage","text":"contextCompaction thread/compacted encrypted_content"}}},
                      {"method":"item/completed","params":{"item":{"type":"reasoning","summary":[],"encrypted_content":None}}}]:
            self.assertIsNone(child.context_loss_reason(event))
    def test_loss_retires_before_any_following_model_or_tool_invocation(self):
        calls=[]
        class Relay:
            retired=False
            def call(self,op,args):calls.append((op,args));return {"retired":True,"coverage":"UNKNOWN","event_sha256":wire.sha(wire.packed(args["event"]))}
        relay=Relay();boundary=child.ContextBoundary(relay,wire)
        event={"method":"item/started","params":{"item":{"type":"contextCompaction","id":"compact"}}}
        with self.assertRaises(ValueError):boundary.observe(event)
        for op in ("model_request","tool_callback","next_user_turn","begin_turn"):
            with self.assertRaises(ValueError):boundary.call(op,{})
        self.assertEqual(calls,[("native_context_loss",{"event":event})])
        self.assertTrue(boundary.retired and relay.retired)
        self.assertTrue(boundary.receipts[0]["parent_retirement_confirmed"])
    def test_parent_loss_refusal_still_retires_child(self):
        class Relay:
            retired=False
            def call(self,*args):raise RuntimeError("parent refused")
        relay=Relay();boundary=child.ContextBoundary(relay,wire)
        with self.assertRaises(RuntimeError):boundary.observe({"method":"thread/compacted","params":{}})
        self.assertTrue(boundary.retired and relay.retired)
        self.assertFalse(boundary.receipts[0]["parent_retirement_confirmed"])

    def test_inflight_parent_response_cannot_be_released_after_loss(self):
        class Relay:
            retired=False
            def call(self,op,args):
                if op=="native_context_loss":return {"retired":True,"coverage":"UNKNOWN","event_sha256":wire.sha(wire.packed(args["event"]))}
                try:boundary.observe({"method":"thread/compacted","params":{}})
                except ValueError:pass
                return {"stale_response":"must not reach CLI"}
        boundary=child.ContextBoundary(Relay(),wire)
        with self.assertRaisesRegex(ValueError,"permanently retired"):
            boundary.call("model_request",{})
        self.assertTrue(boundary.retired)

if __name__=="__main__":unittest.main()
