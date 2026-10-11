import base64
import copy
import io
from contextlib import redirect_stdout
from unittest.mock import patch
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from tools import conditional_skill_routing_cli_case_launch as launcher
from tools import conditional_skill_routing_parent_transport as wire

KEY=b"synthetic-case-replay-channel-001"
TEXT="Exact fixture callback snowman \u2603; final newline\n"
CALL="case-call-one"

class LauncherProofTests(unittest.TestCase):
    def fixture(self,workspace,operations,alter_result=None,rpc_override=None):
        controller=SimpleNamespace(subject=SimpleNamespace(callbacks={CALL:{"call_id":CALL,"content":TEXT,"delivered":True}},responses=[]),responses=[])
        provider=SimpleNamespace(raw_exchanges=[])
        callback={"callId":CALL,"tool":"fixture_read","arguments":{"target":"fixture.txt"},"threadId":"thread","turnId":"turn"}
        event={"jsonrpc":"2.0","id":44,"method":"item/tool/call","params":callback}
        events=[event] if rpc_override is None else rpc_override
        run=workspace/"run";run.mkdir()
        (run/"rpc-stdout-0000.bin").write_bytes(b"".join(wire.packed(e)+b"\n" for e in events))
        (run/"rpc-events.json").write_bytes(wire.packed({"events":events}))
        frames=[];replies=[]
        for index,(op,payload) in enumerate(operations):
            if op=="tool_callback":
                params={"parameters":callback}
                result={"success":True,"contentItems":[{"type":"inputText","text":TEXT if alter_result is None else alter_result}]}
            else:
                params={"body_b64":base64.b64encode(wire.packed(payload if type(payload) is dict else {"input":payload})).decode()};result={}
            rid="replay-%d"%index
            frames.append(wire.make_request(rid,"case-controller",wire.packed({"op":op,"parameters":params}),KEY))
            raw=wire.packed(result)
            replies.append(wire.packed(wire.authenticated({"version":1,"id":rid,"status":200,"headers":{"content-type":"application/json"},
                "body_b64":base64.b64encode(raw).decode(),"body_sha256":wire.sha(raw)},KEY)))
        return frames,replies,controller,provider
    def output(self,text=TEXT):return {"type":"function_call_output","call_id":CALL,"output":text}
    def verify(self,operations,**options):
        with tempfile.TemporaryDirectory(prefix="sg-case-replay-test-") as folder:
            workspace=Path(folder);args=self.fixture(workspace,operations,**options)
            return launcher.replay(*args,KEY,workspace)
    def test_authenticated_replay_proves_immediate_and_later_exact_output(self):
        result=self.verify([("model_request",[]),("tool_callback",None),("model_request",[self.output()]),("model_request",[self.output()])])
        self.assertTrue(result["exact_authenticated_exchanges"])
        self.assertEqual(result["callbacks"],1)
        self.assertEqual(result["requests"],3)
    def test_missing_immediate_output_cannot_be_repaired_by_later_delivery(self):
        with self.assertRaises(RuntimeError):self.verify([("tool_callback",None),("model_request",[]),("model_request",[self.output()])])
    def test_duplicate_immediate_output_and_missing_followup_fail(self):
        for operations in [[("tool_callback",None),("model_request",[self.output(),self.output()])],[("tool_callback",None)]]:
            with self.assertRaises(RuntimeError):self.verify(operations)
    def test_tampered_callback_and_tampered_later_history_fail(self):
        with self.assertRaises(RuntimeError):self.verify([("tool_callback",None),("model_request",[self.output()])],alter_result="changed")
        with self.assertRaises(RuntimeError):self.verify([("tool_callback",None),("model_request",[self.output()]),("model_request",[self.output("changed")])])
    def test_raw_rpc_replay_cannot_be_replaced_by_summary_only(self):
        with self.assertRaises(RuntimeError):self.verify([("tool_callback",None),("model_request",[self.output()])],rpc_override=[])
    def test_controller_exchange_replay_includes_fixture_priming_and_model_formats(self):
        dynamic={"type":"function","name":"fixture_read","description":"bounded fixture","inputSchema":{"type":"object","properties":{}}}
        native={"type":"function","name":"exec_command","description":"native","parameters":{}}
        model={"type":"function","name":"fixture_read","description":"bounded fixture","parameters":dynamic["inputSchema"],"strict":False}
        request={"model":"synthetic","instructions":"exact instructions","input":[self.output()],"tools":[model,native]}
        for tamper in (None,"instructions","schemas"):
            with self.subTest(tamper=tamper), tempfile.TemporaryDirectory(prefix="sg-case-origin-test-") as folder:
                workspace=Path(folder)
                args=self.fixture(workspace,[("tool_callback",None),("model_request",request),("model_request",request)])
                frames,replies,controller,provider=args
                controller.tools=[dynamic]
                controller.subject.schema=[{"name":dynamic["name"],"inputSchema":dynamic["inputSchema"]}]
                controller.subject.tools={dynamic["name"]}
                controller.raw_exchanges=[];controller.responses=[]
                for i,origin in enumerate(("exact_fixture_history_replay_no_provider_call","injected_mock_provider")):
                    offered=copy.deepcopy(request);offered["tools"]=[copy.deepcopy(model)]
                    if i==1 and tamper=="instructions":offered["instructions"]="changed instructions"
                    if i==1 and tamper=="schemas":offered["tools"][0]["parameters"]={"type":"array"}
                    exchange={"original_request":wire.packed(request),"request":wire.packed(offered),"response":b"fixture-response-"+str(i).encode()}
                    controller.raw_exchanges.append(exchange)
                    controller.responses.append({"origin":origin,"original_request_sha256":wire.sha(exchange["original_request"]),
                        "model_request_sha256":wire.sha(exchange["request"]),"response_sha256":wire.sha(exchange["response"])})
                provider.raw_exchanges=[controller.raw_exchanges[1]]
                if tamper is None:
                    result=launcher.replay(frames,replies,controller,provider,KEY,workspace)
                    self.assertTrue(result["exact_callbacks_in_immediately_next_request"])
                else:
                    with self.assertRaises(RuntimeError):launcher.replay(frames,replies,controller,provider,KEY,workspace)

    def test_marker_nested_base64_and_escaped_json_refused(self):
        marker=b"SYNTHETIC_PARENT_ONLY_MARKER"
        for data in [marker,json.dumps({"x":marker.decode()}).encode(),b'{"x":"'+b"".join(('\\u%04x'%c).encode() for c in marker)+b'"}']:
            for depth in range(4):
                raw=data
                for _ in range(depth):raw=wire.packed({"body_b64":base64.b64encode(raw).decode()})
                with self.assertRaises(RuntimeError):launcher.assert_no_markers(raw,(marker,))
    def test_nested_safe_bodies_accepted_and_malformed_b64_refused(self):
        launcher.assert_no_markers(wire.packed({"body_b64":base64.b64encode(b"bounded safe\n").decode()}),(b"SYNTHETIC_PARENT_ONLY_MARKER",))
        with self.assertRaises(Exception):launcher.assert_no_markers(b'{"body_b64":"notbase64!"}',(b"SYNTHETIC_PARENT_ONLY_MARKER",))
    def test_marker_inside_escaped_sse_text_is_not_allowed(self):
        marker=b"SYNTHETIC_PARENT_ONLY_MARKER"
        escaped=b"".join(('\\u%04x'%c).encode() for c in marker)
        sse=b'data: {"type":"response.output_text.delta","delta":"'+escaped+b'"}\n\n'
        wrapped=wire.packed({"body_b64":base64.b64encode(sse).decode()})
        with self.assertRaises(RuntimeError):launcher.assert_no_markers(wrapped,(marker,))
    def test_child_dependency_allowlist_is_exact_and_excludes_case_authority(self):
        self.assertEqual(launcher.CHILD_DEPENDENCIES,("conditional_skill_routing_cli_broker_profile.py","conditional_skill_routing_parent_transport.py"))
        self.assertIn("conditional_skill_routing_shared_campaign.py",launcher.PARENT_DEPENDENCIES)

class EvaluatorReceiptTests(unittest.TestCase):
    def receipt(self, observation_digest, *, case_id="H1", campaign_id="conditional-skill-routing-test-v1", status="PASS"):
        unsigned={"schema_version":1,"campaign_id":campaign_id,"case_id":case_id,
            "observation_manifest_sha256":observation_digest,"status":status,"review_id":"review-20261010"}
        return {**unsigned,"receipt_sha256":wire.sha(wire.packed(unsigned))}
    def test_hash_bound_receipt_requires_matching_campaign_case_capture_and_digest(self):
        digest="a"*64
        accepted=launcher.validate_evaluator_receipt(self.receipt(digest),case_id="H1",
            campaign_id="conditional-skill-routing-test-v1",observation_manifest_sha256=digest)
        self.assertEqual(accepted["status"],"PASS")
        cases=(("H2","conditional-skill-routing-test-v1",digest),
            ("H1","different-campaign",digest),("H1","conditional-skill-routing-test-v1","b"*64))
        for expected_case,expected_campaign,expected_digest in cases:
            with self.subTest(case=expected_case,campaign=expected_campaign,digest=expected_digest), self.assertRaises(RuntimeError):
                launcher.validate_evaluator_receipt(self.receipt(digest),case_id=expected_case,
                    campaign_id=expected_campaign,observation_manifest_sha256=expected_digest)
    def test_nonpass_is_valid_evidence_but_never_a_successful_live_baseline(self):
        digest="c"*64
        for status in ("FAIL","INCONCLUSIVE"):
            receipt=launcher.validate_evaluator_receipt(self.receipt(digest,status=status),case_id="H1",
                campaign_id="conditional-skill-routing-test-v1",observation_manifest_sha256=digest)
            self.assertFalse(launcher.semantic_evaluator_passed(False,receipt))
        passing=launcher.validate_evaluator_receipt(self.receipt(digest),case_id="H1",
            campaign_id="conditional-skill-routing-test-v1",observation_manifest_sha256=digest)
        self.assertTrue(launcher.semantic_evaluator_passed(False,passing))
        self.assertFalse(launcher.semantic_evaluator_passed(False,None))
        self.assertTrue(launcher.semantic_evaluator_passed(True,None))
    def test_missing_extra_unknown_status_and_tampered_digest_are_rejected(self):
        digest="d"*64
        for mutate in (
            lambda row: row.pop("review_id"),
            lambda row: row.update({"unexpected":"value"}),
            lambda row: row.update({"status":"pass"}),
            lambda row: row.update({"status":False}),
            lambda row: row.update({"status":["PASS"]}),
            lambda row: row.update({"receipt_sha256":"0"*64}),
        ):
            receipt=self.receipt(digest);mutate(receipt)
            with self.subTest(receipt=receipt), self.assertRaises(RuntimeError):
                launcher.validate_evaluator_receipt(receipt,case_id="H1",
                    campaign_id="conditional-skill-routing-test-v1",observation_manifest_sha256=digest)
    def test_evaluator_receipt_binds_exact_unchanged_ephemeral_inventory(self):
        with tempfile.TemporaryDirectory(prefix="sg-case-evaluator-test-") as folder:
            workspace=Path(folder);(workspace/"run").mkdir();(workspace/"run/capture.bin").write_bytes(b"synthetic raw capture")
            stage={"campaign_id":"conditional-skill-routing-test-v1"}
            def evaluator(controller,path,digest):
                return self.receipt(digest)
            result=launcher.evaluate_ephemeral_capture(evaluator,object(),workspace,stage,"H1")
            expected=launcher.capture_inventory_sha256(launcher.capture_inventory(workspace))
            self.assertEqual(result["observation_manifest_sha256"],expected)
            def modifies_workspace(controller,path,digest):
                (path/"evaluator-write.json").write_text("must be rejected")
                return self.receipt(digest)
            with self.assertRaisesRegex(RuntimeError,"modified ephemeral capture"):
                launcher.evaluate_ephemeral_capture(modifies_workspace,object(),workspace,stage,"H1")
    def test_empty_or_unbound_evaluator_cannot_be_counted_as_a_verdict(self):
        with tempfile.TemporaryDirectory(prefix="sg-case-evaluator-test-") as folder:
            workspace=Path(folder);(workspace/"capture.bin").write_bytes(b"synthetic raw capture")
            stage={"campaign_id":"conditional-skill-routing-test-v1"}
            for value in (None,{},self.receipt("f"*64,case_id="H2")):
                with self.subTest(value_type=type(value).__name__),self.assertRaises(RuntimeError):
                    launcher.evaluate_ephemeral_capture(lambda *args:value,object(),workspace,stage,"H1")

    def test_capture_inventory_refuses_symlink_workspace_and_entries(self):
        with tempfile.TemporaryDirectory(prefix="sg-case-symlink-test-") as folder:
            workspace=Path(folder)/"workspace";workspace.mkdir()
            capture=workspace/"capture.bin";capture.write_bytes(b"synthetic raw capture")
            with patch.object(Path,"is_symlink",autospec=True,side_effect=lambda path:path==workspace):
                with self.assertRaisesRegex(RuntimeError,"invalid ephemeral capture workspace"):
                    launcher.capture_inventory(workspace)
            with patch.object(Path,"is_symlink",autospec=True,side_effect=lambda path:path==capture):
                with self.assertRaisesRegex(RuntimeError,"symlink in ephemeral capture workspace"):
                    launcher.capture_inventory(workspace)

class LauncherSetupTests(unittest.TestCase):
    def test_setup_failure_has_hash_only_receipt_and_truthful_cleanup_status(self):
        for exists in (None,False,True):
            with self.subTest(exists=exists), tempfile.TemporaryDirectory(prefix="sg-case-setup-test-") as folder:
                base=Path(folder)
                def fail(label,case):
                    output=base/label;output.mkdir()
                    if exists is not None:(output/"temporary-runtime-cleanup.json").write_bytes(wire.packed({"exists_after_cleanup":exists}))
                    raise RuntimeError("SYNTHETIC_PROVIDER_SECRET_MUST_NOT_BE_RECORDED")
                with patch.object(launcher,"BASE",base),patch.object(launcher,"_execute",side_effect=fail),redirect_stdout(io.StringIO()) as stdout:
                    self.assertEqual(launcher.execute("setup-failure","H1"),1)
                raw=(base/"setup-failure/summary.json").read_bytes();summary=wire.decoded(raw)
                self.assertNotIn(b"SYNTHETIC_PROVIDER_SECRET_MUST_NOT_BE_RECORDED",raw)
                self.assertNotIn("SYNTHETIC_PROVIDER_SECRET_MUST_NOT_BE_RECORDED",stdout.getvalue())
                self.assertFalse(summary["passed"])
                self.assertEqual(summary["raw_and_runtime_removed"],None if exists is None else not exists)
                self.assertEqual(summary["model_calls"],0)
    def test_existing_proof_label_is_refused_without_touching_artifacts(self):
        with tempfile.TemporaryDirectory(prefix="sg-case-existing-test-") as folder:
            base=Path(folder);output=base/"sealed-proof";output.mkdir()
            proof=b"sealed immutable previous receipt"
            (output/"summary.json").write_bytes(proof)
            with patch.object(launcher,"BASE",base),patch.object(launcher,"_execute") as implementation:
                with self.assertRaisesRegex(RuntimeError,"already exists"):launcher.execute("sealed-proof","H1")
            implementation.assert_not_called()
            self.assertEqual((output/"summary.json").read_bytes(),proof)
            self.assertEqual([p.name for p in output.iterdir()],["summary.json"])

class PreparedLiveGuardTests(unittest.TestCase):
    def live_fixture(self):
        from tools.conditional_skill_routing_comparison_case_controller import CaseController
        from tools.conditional_skill_routing_parent_https import PreparedHTTPSCallback
        public=launcher.ROOT/"tools/fixtures/conditional_skill_routing"
        manifest=wire.decoded((public/"manifest.json").read_bytes())
        case=next(c for c in wire.decoded((public/"cases.json").read_bytes())["cases"] if c["id"]=="H1")
        from tools import conditional_skill_routing_runner as runner
        prepared=runner.prepare_tuning_readonly_broker(manifest,case)
        limits={"max_calls":12,"max_request_bytes":1024*1024,"max_response_bytes":1024*1024,
                "total_request_bytes":12*1024*1024,"total_response_bytes":12*1024*1024,
                "max_output_tokens":512,"total_output_tokens":6144,"request_timeout":15.0,"session_timeout":120.0}
        budget={"review_id":"synthetic-offline-budget-not-operator-authority",**limits}
        def factory(*args):raise AssertionError("network factory must remain unreachable in guard tests")
        provider=PreparedHTTPSCallback(endpoint="https://api.example.invalid/v1/responses",model="synthetic",account_label="synthetic-test-account",
                required_settings={"store":False,"stream":True},launch_authorized=True,injected_credential="SYNTHETIC_DO_NOT_LAUNCH",
                approved_budget=budget,connection_factory=factory)
        unsigned={"endpoint":provider.endpoint,"model":provider.model,"account_label":provider.account_label,
                  "settings_sha256":wire.sha(wire.packed(provider.settings)),"budget_review_id":budget["review_id"],
                  "independent_review_id":"synthetic-test-profile-review"}
        profile={**unsigned,"profile_sha256":wire.sha(wire.packed(unsigned))}
        controller=CaseController(prepared,provider,provider_kind="live",launch_authorized=True,approved_profile=profile)
        stage={"provider":{key:profile[key] for key in ("endpoint","model","account_label","settings_sha256")},
               "consumer":{"binary_sha256":launcher.ELF_SHA256,"version":"0.160.1","profile_sha256":"0"*64},
               "budget":{"max_provider_requests":12,"max_tokens":6144,"max_seconds":120}}
        return controller,stage
    def test_live_entrypoint_default_blocks_before_preflight_or_runtime(self):
        with patch.object(launcher,"_execute") as run:
            with self.assertRaisesRegex(RuntimeError,"explicit authorized"):
                launcher.execute_prepared_controller("blocked","H1",object(),{},evaluator=lambda *args:None)
        run.assert_not_called()
    def test_preflight_not_ready_and_account_mismatch_block_before_runtime(self):
        from tools import conditional_skill_routing_real_comparison_preflight as preflight
        for readiness,mutate in [(False,False),(True,True)]:
            controller,stage=self.live_fixture()
            if mutate:stage["provider"]["account_label"]="different-account"
            with patch.object(preflight,"check",return_value={"ready_to_launch_baseline":readiness}),patch.object(launcher,"_execute") as run:
                with self.assertRaises(RuntimeError):launcher.execute_prepared_controller("blocked","H1",controller,stage,explicit_launch_authorized=True,evaluator=lambda *args:None)
            run.assert_not_called()
            self.assertEqual(controller.provider_callback.calls,0)
    def test_reused_controller_and_missing_frozen_source_profile_block(self):
        from tools import conditional_skill_routing_real_comparison_preflight as preflight
        for reused in (True,False):
            controller,stage=self.live_fixture()
            if reused:controller.bootstrapped=True
            with patch.object(preflight,"check",return_value={"ready_to_launch_baseline":True}),patch.object(launcher,"_execute") as run:
                with self.assertRaises(RuntimeError):launcher.execute_prepared_controller("blocked","H1",controller,stage,explicit_launch_authorized=True,evaluator=lambda *args:None)
            run.assert_not_called()
            self.assertEqual(controller.provider_callback.calls,0)

if __name__=="__main__":unittest.main()
