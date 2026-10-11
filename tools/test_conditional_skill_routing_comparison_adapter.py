"""Deterministic full-family adapter checks; no provider/model/CLI launch."""
import copy
import json
from pathlib import Path
import unittest
from unittest.mock import patch

from tools import conditional_skill_routing_comparison_adapter as adapter
from tools import conditional_skill_routing_runner as runner

BASE = Path(__file__).resolve().parent / "fixtures/conditional_skill_routing"


def memory_worker(bundle, requests, **unused):
    session = runner.FixtureSession(bundle)
    results = []
    for request in requests:
        try:
            results.append({"ok": True, "result": session.dispatch(request)})
        except runner.RunnerError as error:
            results.append({"ok": False, "error": str(error)})
    return {"results": results, "receipts": session.receipts, "model_calls": 0}


class FullFamilyAdapter(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((BASE / "manifest.json").read_bytes())
        cls.cases = {case["id"]: case for case in json.loads((BASE / "cases.json").read_bytes())["cases"]}

    def setUp(self):
        worker = patch.object(runner, "run_worker", side_effect=memory_worker)
        self.worker = worker.start()
        self.addCleanup(worker.stop)

    def prepare(self, case_id):
        subject = adapter.prepare_tuning(self.manifest, self.cases[case_id], thread_id="actual-thread", turn_id="actual-turn")
        self.history = [{"type": "message", "role": turn["role"], "content": turn["content"]}
                        for turn in subject.mcp.broker.bundle["turns"]]
        subject.observe_request(adapter.encoded({"input": self.history}), label="initial")
        return subject

    def call(self, subject, name, arguments, *, deliver=True, call_id=None):
        call_id = call_id or "actual-call-" + str(len(subject.callbacks))
        parameters = {"arguments": arguments, "callId": call_id, "namespace": subject.namespace,
                      "threadId": subject.thread_id, "turnId": subject.turn_id, "tool": name}
        response = subject.dispatch(parameters)
        self.history += [{"type": "function_call", "name": name, "call_id": call_id,
                          "arguments": json.dumps(arguments, ensure_ascii=False)},
                         {"type": "function_call_output", "call_id": call_id,
                          "output": response["contentItems"][0]["text"]}]
        if deliver:
            subject.observe_request(adapter.encoded({"input": self.history}), label=call_id)
        return response, call_id

    def assistant(self, subject, text):
        if subject.turn_id in subject.assistant_turns:
            subject.begin_turn("next-turn-" + str(len(subject.turn_ids)))
            subject.observe_request(adapter.encoded({"input": self.history}))
        raw = adapter.encoded({"id": "response-" + str(len(subject.response_ids)), "status": "completed", "output": [{"type": "message", "role": "assistant",
                             "content": [{"type": "output_text", "text": text}]}]})
        result = subject.observe_assistant_response(raw)
        for turn in result["released_turns"]:
            self.history.append({"type": "message", "role": turn["role"], "content": turn["content"]})
        return result

    def test_all_eight_exact_case_schema_sets_and_no_mutation_in_readonly(self):
        expected = {"H1": 2, "H2": 2, "A1": 4, "A2": 3, "B1": 4, "B2": 7, "S1": 5, "S2": 5}
        for case_id, count in expected.items():
            subject = self.prepare(case_id)
            self.assertEqual(len(subject.tools), count)
            self.assertEqual(subject.dynamic_tools()[0]["name"], subject.schema[0]["name"])
            if case_id[0] in "HAS":
                self.assertNotIn("simulated_replace", subject.tools)
        self.worker.assert_not_called()

    def test_actual_ids_multispan_unicode_read_and_changed_output_transaction(self):
        text = "cafÃ© â˜ƒðŸ§ª: exact Unicode source; second protected span."
        bundle = {"schema_version": 1, "turns": [{"id": "U1", "role": "user", "content": "Synthetic read only"}],
            "injections": [], "instructions": {"unicode": {"path": "skills/synthetic.md", "text": text,
            "source_sha256": runner.sha(text), "text_sha256": runner.sha(text)}}, "files": {}, "grants": []}
        subject = adapter.ComparisonAdapter(runner.FixtureMcpBroker(bundle, observe=True, allow_simulated_replace=False),
                                             thread_id="actual-thread", turn_id="actual-turn")
        self.history = [{"type": "message", "role": "user", "content": "Synthetic read only"}]
        subject.observe_request(adapter.encoded({"input": self.history}))
        resource_id = "unicode"
        response, call = self.call(subject, "instruction_read", {"resource_id": resource_id,
                                  "spans": [{"start": 0, "end": 7}, {"start": 10, "end": 19}]}, deliver=False)
        self.assertIn(call, subject.mcp.broker.returned_contents)
        self.assertNotIn("mcp-2", subject.mcp.broker.returned_contents)
        self.assertFalse(subject.callbacks[call]["delivered"])
        changed = copy.deepcopy(self.history)
        changed[-1]["output"] += "changed"
        with self.assertRaises(adapter.AdapterError):
            subject.observe_request(adapter.encoded({"input": changed}))
        self.assertFalse(subject.callbacks[call]["delivered"])
        self.assertTrue(subject.retired)
        self.assertEqual(subject.accounting.coverage, {})
        with self.assertRaises(adapter.AdapterError):
            subject.observe_request(adapter.encoded({"input": self.history}))

    def test_multiple_callbacks_validate_before_any_delivery_and_replay_refused(self):
        subject = self.prepare("H1")
        resource_id = next(iter(subject.accounting.resources))
        _, first = self.call(subject, "instruction_read", {"resource_id": resource_id, "spans": None}, deliver=False)
        _, second = self.call(subject, "instruction_read", {"resource_id": resource_id, "spans": None}, deliver=False)
        changed = copy.deepcopy(self.history)
        changed[-1]["output"] = "corrupted"
        with self.assertRaises(adapter.AdapterError):
            subject.observe_request(adapter.encoded({"input": changed}))
        self.assertFalse(subject.callbacks[first]["delivered"])
        self.assertFalse(subject.callbacks[second]["delivered"])
        self.assertTrue(subject.retired)
        with self.assertRaises(adapter.AdapterError):
            self.call(subject, "instruction_read", {"resource_id": resource_id, "spans": None})
        self.assertFalse(subject.callbacks[first]["delivered"])

    def test_audit_requires_delivered_preflight_and_preserves_refusal(self):
        subject = self.prepare("A1")
        for target in subject.mcp.released_actions.contracts["audit"]["required_delivered_targets"]:
            self.call(subject, "fixture_read", {"target": target})
        args = subject.mcp.released_actions.contracts["audit"]["arguments"]
        refused, bad = self.call(subject, "audit", args)
        self.assertFalse(refused["success"])
        preflight = subject.mcp.released_actions.contracts["invocation_preflight"]["arguments"]
        self.call(subject, "invocation_preflight", preflight)
        succeeded, good = self.call(subject, "audit", args)
        self.assertTrue(succeeded["success"])
        self.assertTrue(subject.callbacks[bad]["delivered"])
        self.assertTrue(any(row["call_id"] == bad for row in subject.refusals))

    def test_b_exact_approval_after_delivered_read_then_write_and_verification(self):
        subject = self.prepare("B1")
        collector = subject.prepared.collector
        _, read = self.call(subject, "fixture_read", {"target": collector.target}, deliver=False)
        with self.assertRaises(adapter.AdapterError):
            self.assistant(subject, collector.approval_question())
        self.assertFalse(collector.released)
        self.assertTrue(subject.retired)
        subject = self.prepare("B1")
        collector = subject.prepared.collector
        self.call(subject, "fixture_read", {"target": collector.target})
        released = self.assistant(subject, collector.approval_question())
        self.assertEqual(len(released["released_turns"]), 1)
        subject.observe_request(adapter.encoded({"input": self.history}))
        written, _ = self.call(subject, "simulated_replace", {"target": collector.target, "old": collector.old, "new": collector.new})
        self.assertTrue(written["success"])
        verified, _ = self.call(subject, "focused_verify", {"target": collector.target})
        self.assertTrue(verified["success"])
        self.assertEqual(subject.mcp.broker.bundle["grants"], [])

    def test_b2_owner_preflight_and_late_evidence_require_actual_delivery(self):
        subject = self.prepare("B2")
        for name in ("invocation_preflight", "topology_preflight"):
            self.call(subject, name, subject.mcp.released_actions.contracts[name]["arguments"])
        collector = subject.prepared.collector
        self.call(subject, "fixture_read", {"target": collector.target})
        self.assistant(subject, collector.approval_question())
        subject.observe_request(adapter.encoded({"input": self.history}))
        self.call(subject, "simulated_replace", {"target": collector.target, "old": collector.old, "new": collector.new})
        target = next(iter(subject.mcp.scope_evidence_after))
        failed, _ = self.call(subject, "scope_evidence_read", {"target": target})
        self.assertFalse(failed["success"])
        self.call(subject, "focused_verify", {"target": collector.target})
        passed, _ = self.call(subject, "scope_evidence_read", {"target": target})
        self.assertTrue(passed["success"])

    def test_private_grant_status_capability_delivery_redaction_and_refusal(self):
        subject = self.prepare("S2")
        gate = subject.mcp.private_gate
        self.assistant(subject, "I probably have permission")
        self.assertFalse(gate.granted)
        self.assistant(subject, gate.grant_question())
        self.assertTrue(gate.granted)
        subject.observe_request(adapter.encoded({"input": self.history}))
        self.call(subject, "private_status", {})
        self.call(subject, "private_capability", {"namespace": gate.namespace, "operation": "read", "resource_id": gate.resource_id}, deliver=False)
        refused, _ = self.call(subject, "private_record_read", {"resource_id": gate.resource_id})
        self.assertFalse(refused["success"])
        passed, _ = self.call(subject, "private_record_read", {"resource_id": gate.resource_id})
        self.assertTrue(passed["success"])
        record = json.loads(gate.record)
        with self.assertRaises(adapter.AdapterError):
            self.assistant(subject, record["secret"])
        self.assertTrue(any(row["boundary"] == "assistant_response_capture" for row in subject.refusals))
        self.assertTrue(subject.retired)
        self.assertFalse(gate.granted)
        self.assertEqual(subject.pending_turns, {})

    def test_trusted_turn_transition_preserves_callback_identity_and_response_replay_retires(self):
        subject = self.prepare("H1")
        self.call(subject, "fixture_read", {"target": "unreleased-negative-probe"})
        self.assistant(subject, "Synthetic bounded explanation")
        previous = next(iter(subject.callbacks.values()))["turn_id"]
        subject.begin_turn("actual-next-turn")
        self.assertNotEqual(previous, subject.turn_id)
        self.assertEqual(next(iter(subject.callbacks.values()))["turn_id"], previous)
        with self.assertRaises(adapter.AdapterError):
            subject.observe_assistant_response(adapter.encoded({"id": "response-0", "status": "completed", "output": []}))
        self.assertTrue(subject.retired)

    def test_partial_semantic_delivery_failure_retires_all_authority(self):
        subject = self.prepare("H1")
        resource = next(iter(subject.accounting.resources))
        self.call(subject, "instruction_read", {"resource_id": resource, "spans": None}, deliver=False)
        self.call(subject, "instruction_read", {"resource_id": resource, "spans": None}, deliver=False)
        original = subject._deliver_callback
        count = []
        def partial(call_id):
            count.append(call_id)
            if len(count) == 2: raise runner.RunnerError("synthetic second semantic delivery failure")
            original(call_id)
        with patch.object(subject, "_deliver_callback", side_effect=partial):
            with self.assertRaises(adapter.AdapterError):
                subject.observe_request(adapter.encoded({"input": self.history}))
        self.assertTrue(subject.retired)
        self.assertEqual(subject.accounting.coverage, {})
        self.assertFalse(subject.mcp.broker.context_current)
        with self.assertRaises(adapter.AdapterError):
            self.call(subject, "fixture_read", {"target": "anything"})

    def test_partial_assistant_consent_then_invalid_block_retires_grants(self):
        subject = self.prepare("S2")
        gate = subject.mcp.private_gate
        raw = adapter.encoded({"id": "partial-response", "status": "completed", "output": [
            {"type": "message", "role": "assistant", "content": [{"type": "output_text", "text": gate.grant_question()}]},
            {"type": "message", "role": "assistant", "content": [{"type": "unknown", "text": "invalid"}]}]})
        with self.assertRaises(adapter.AdapterError): subject.observe_assistant_response(raw)
        self.assertTrue(subject.retired)
        self.assertFalse(gate.granted)
        self.assertEqual(subject.pending_turns, {})

    def test_pending_callback_missing_skipped_duplicate_tampered_next_request_retires(self):
        for kind in ("missing", "skipped", "duplicate", "tampered"):
            with self.subTest(kind=kind):
                subject=self.prepare("H1")
                resource=next(iter(subject.accounting.resources))
                self.call(subject,"instruction_read",{"resource_id":resource,"spans":None},deliver=False)
                candidate=copy.deepcopy(self.history)
                if kind=="missing": candidate=candidate[:-1]
                elif kind=="skipped": candidate=candidate[:-2]
                elif kind=="duplicate": candidate.append(copy.deepcopy(candidate[-1]))
                else:candidate[-1]["output"]+="tampered"
                with self.assertRaises(adapter.AdapterError):subject.observe_request(adapter.encoded({"input":candidate}))
                self.assertTrue(subject.retired)
                self.assertEqual(subject.accounting.coverage,{})
                self.assertFalse(any(row["delivered"] for row in subject.callbacks.values()))
                with self.assertRaises(adapter.AdapterError):subject.observe_request(adapter.encoded({"input":self.history}))

    def test_delivered_history_output_immutable_and_durable_arguments_hashonly(self):
        subject=self.prepare("H1")
        self.call(subject,"fixture_read",{"target":"unreleased-private-marker-for-test"})
        summary=subject.summary()
        self.assertNotIn("arguments",summary["callbacks"][0])
        self.assertIn("arguments_sha256",summary["callbacks"][0])
        self.assertNotIn("unreleased-private-marker-for-test",json.dumps(summary))
        changed=copy.deepcopy(self.history);changed[-1]["output"]+="changed historical result"
        with self.assertRaises(adapter.AdapterError):subject.observe_request(adapter.encoded({"input":changed}))
        self.assertTrue(subject.retired)

    def test_foreign_native_replay_and_context_loss_never_dispatch(self):
        subject = self.prepare("S1")
        parameters = {"arguments": {}, "callId": "foreign", "namespace": subject.namespace,
                      "threadId": "wrong", "turnId": subject.turn_id, "tool": "private_status"}
        with self.assertRaises(adapter.AdapterError):
            subject.dispatch(parameters)
        parameters.update(threadId=subject.thread_id, tool="exec_command")
        refused = subject.dispatch(parameters)
        self.assertFalse(refused["success"])
        self.history.extend([{ "type": "function_call", "name": "exec_command", "call_id": "foreign", "arguments": "{}"},
                             {"type": "function_call_output", "call_id": "foreign", "output": refused["contentItems"][0]["text"]}])
        subject.observe_request(adapter.encoded({"input": self.history}))
        self.call(subject, "private_status", {})
        result = subject.context_loss("simulated reset", b"actual captured reset event")
        self.assertTrue(result["retired"])
        self.assertEqual(subject.accounting.coverage, {})
        parameters.update(tool="private_status")
        with self.assertRaises(adapter.AdapterError):
            subject.dispatch(parameters)
        self.assertFalse(subject.mcp.broker.context_current)
        self.assertFalse(subject.mcp.private_gate.granted)


if __name__ == "__main__":
    unittest.main()
