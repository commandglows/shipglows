"""Additional adversarial raw association tests; no provider/heldout/runtime."""
import base64
import copy
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch
from tools import test_conditional_skill_routing_case_proof_review as fixture
from tools import conditional_skill_routing_case_proof_review as reviewer
from tools import conditional_skill_routing_parent_transport as wire

class AdversarialAssociationTests(unittest.TestCase):
    def run_fixture(self,mutator=None,**options):
        helper=fixture.CaseReviewTests()
        data=helper.fixture(**options)
        with TemporaryDirectory() as folder:
            root=Path(folder)
            def inspect(*args,**kwargs):
                if mutator:mutator(args,kwargs)
                return reviewer.review(*args,**kwargs)
            with patch.object(fixture,"review",side_effect=inspect):
                return helper.run_review(root,*data)
    def test_hash_only_receipt_and_import_bound_reviewer_digest(self):
        result=self.run_fixture()
        encoded=wire.packed(result)
        self.assertNotIn(fixture.TEXT.strip().encode(),encoded)
        self.assertNotIn(fixture.CALL.encode(),encoded)
        self.assertEqual(result["review_source_sha256"],reviewer.LOADED_SOURCE_SHA256)
        # Proof source diagnostics must remain fixed even if a filesystem read
        # would now return different bytes; no mutation of actual code occurs.
        with patch.object(reviewer.Path,"read_bytes",side_effect=AssertionError("receipt should not reload its own source")):
            self.assertEqual(reviewer.LOADED_SOURCE_SHA256,result["review_source_sha256"])
    def test_authenticated_reply_id_and_body_hash_tampering_refused(self):
        for mode in ("id","hash"):
            def mutate(args,kwargs,mode=mode):
                frames,replies=args[:2]
                value=wire.decoded(replies[0] if mode=="id" else frames[0]);value.pop("auth")
                value["id" if mode=="id" else "body_sha256"]="changed"
                (replies if mode=="id" else frames)[0]=wire.packed(wire.authenticated(value,fixture.KEY))
            with self.subTest(mode=mode),self.assertRaises(Exception):self.run_fixture(mutate)
    def test_controller_original_cannot_diverge_from_authenticated_cli_frame(self):
        def mutate(args,kwargs):
            controller=args[2]
            controller.raw_exchanges[0]["original_request"]+=b" "
            controller.responses[0]["original_request_sha256"]=wire.sha(controller.raw_exchanges[0]["original_request"])
        with self.assertRaises(Exception):self.run_fixture(mutate)
    def test_non_tools_types_schema_and_inventory_tampering_refused(self):
        for mode in ("value","type","schema","inventory"):
            def mutate(args,kwargs,mode=mode):
                controller=args[2];exchange=controller.raw_exchanges[0];offered=wire.decoded(exchange["request"])
                if mode=="value":offered["instructions"]="changed"
                elif mode=="type":offered["stream"]=1
                elif mode=="schema":offered["tools"][0]["parameters"]={"type":"array"}
                else:offered["tools"].append(copy.deepcopy(offered["tools"][0]))
                exchange["request"]=wire.packed(offered);controller.responses[0]["model_request_sha256"]=wire.sha(exchange["request"])
            with self.subTest(mode=mode),self.assertRaises(Exception):self.run_fixture(mutate)
    def test_missing_actual_rpc_reply_http_response_and_model_origin_refused(self):
        for mode in ("rpc","http","origin"):
            def mutate(args,kwargs,mode=mode):
                controller,root=args[2],args[3]
                if mode=="rpc":
                    path=root/"run/rpc-input-0000.bin"
                    rows=[wire.decoded(line) for line in path.read_bytes().splitlines()]
                    path.write_bytes(b"".join(wire.packed(r)+b"\n" for r in rows if "result" not in r))
                elif mode=="http":(root/"run/cli-http-001.parent-response.bin").write_bytes(b"changed")
                else:controller.raw_exchanges[0]["origin"]="unassociated-origin"
            with self.subTest(mode=mode),self.assertRaises(Exception):self.run_fixture(mutate)
    def test_compaction_opaque_context_extra_dependency_and_wrong_cap_refused(self):
        for mode in ("compact","opaque","deps","cap","namespace"):
            def mutate(args,kwargs,mode=mode):
                root=args[3];facts=args[5]
                if mode in ("compact","opaque"):
                    event={"method":"thread/compacted","params":{}} if mode=="compact" else {"method":"item/started","params":{"item":{"type":"reasoning","encrypted_content":"opaque"}}}
                    path=root/"run/rpc-stdout-0000.bin";rows=[wire.decoded(line) for line in path.read_bytes().splitlines()]+[event]
                    path.write_bytes(b"".join(wire.packed(r)+b"\n" for r in rows));(root/"run/rpc-events.json").write_bytes(wire.packed({"events":rows}))
                elif mode=="deps":kwargs["child_dependencies"]["tools/conditional_skill_routing_runner.py"]={"bytes":1,"sha256":"0"*64}
                elif mode=="namespace":facts["mnt_visible"]=True
                else:(root/"run/effective-config-read.json").write_bytes(wire.packed({"config":{"model":"synthetic","tool_output_token_limit":1000}}))
            with self.subTest(mode=mode),self.assertRaises(Exception):self.run_fixture(mutate)
    def test_missing_immediate_result_cannot_be_fixed_in_later_history(self):
        for options in ({"corrupt_next":True},{"later_change":True}):
            with self.subTest(options=options),self.assertRaises(Exception):self.run_fixture(**options)

if __name__=="__main__":unittest.main()
