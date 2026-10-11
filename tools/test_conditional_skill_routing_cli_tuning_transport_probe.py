"""Offline probe-plan/schema checks, not actual CLI integration proof."""
import copy
import json
from pathlib import Path
import unittest
from unittest.mock import patch
from tools import conditional_skill_routing_cli_tuning_transport_probe as probe
from tools import conditional_skill_routing_comparison_adapter as adapter


class TuningTransportPlan(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        base = Path(__file__).resolve().parent / "fixtures/conditional_skill_routing"
        cls.manifest = json.loads((base / "manifest.json").read_bytes())
        cls.cases = json.loads((base / "cases.json").read_bytes())["cases"]

    def test_all_eight_plans_keep_case_capabilities_and_canonical_consent(self):
        for case in self.cases:
            subject = adapter.prepare_tuning(self.manifest, case, thread_id="t", turn_id="u")
            phases = probe.plans(subject, case["id"])
            self.assertTrue(all(step["tool"] in subject.tools for phase in phases for step in phase if "tool" in step))
            if case["id"].startswith("B"):
                self.assertEqual(len(phases), 2)
                self.assertEqual(phases[0][-1]["message"], subject.prepared.collector.approval_question())
                self.assertIn("focused_verify", [step.get("tool") for step in phases[1]])
            if case["id"] == "S2":
                self.assertEqual(phases[0][-1]["message"], subject.mcp.private_gate.grant_question())
                self.assertEqual([step.get("tool") for step in phases[1]][:3], ["private_status", "private_capability", "private_record_read"])
            if case["id"] == "B2":
                self.assertIn("topology_preflight", [step.get("tool") for step in phases[0]])
                self.assertEqual([step.get("tool") for step in phases[1]].count("scope_evidence_read"), 2)

    def test_inventory_filter_preserves_every_non_tools_field(self):
        subject = adapter.prepare_tuning(self.manifest, self.cases[3], thread_id="t", turn_id="u")
        request = {"input": [{"role": "user", "content": "exact cafÃƒÆ’Ã‚Â©"}], "instructions": "exact authority",
            "tools": [{"type": "function", "name": "exec_command", "parameters": {}}] +
                     [{"type": "function", "name": row["name"], "parameters": probe.registration_schema(row["inputSchema"])} for row in subject.schema],
            "model": "synthetic", "stream": True}
        before = copy.deepcopy(request)
        filtered = probe.filter_request(request, subject)
        self.assertEqual(request, before)
        self.assertEqual({key: value for key, value in filtered.items() if key != "tools"},
                         {key: value for key, value in before.items() if key != "tools"})
        self.assertEqual({row["name"] for row in filtered["tools"]}, subject.tools)
        self.assertNotIn("exec_command", {row["name"] for row in filtered["tools"]})
        changed = copy.deepcopy(request)
        changed["tools"][-1]["parameters"] = {}
        with self.assertRaises(ValueError):
            probe.filter_request(changed, subject)

    def test_duplicate_or_missing_case_schema_fails_closed(self):
        subject = adapter.prepare_tuning(self.manifest, self.cases[0], thread_id="t", turn_id="u")
        tools = [{"type": "function", "name": row["name"], "parameters": probe.registration_schema(row["inputSchema"])} for row in subject.schema]
        for malformed in (tools[:-1], tools + [tools[0]]):
            with self.assertRaises(ValueError):
                probe.filter_request({"tools": malformed}, subject)

    def test_schema_validation_rejects_unknown_keys_bool_integer_and_wrong_null(self):
        schema = {"type": "object", "properties": {"index": {"type": "integer"}, "spans": {"type": ["array", "null"], "items": {"type": "integer"}}},
                  "required": ["index", "spans"], "additionalProperties": False}
        self.assertTrue(probe.schema_accepts({"index": 1, "spans": None}, schema))
        for value in ({"index": True, "spans": None}, {"index": 1, "spans": "null"}, {"index": 1, "spans": [1], "extra": 0}):
            self.assertFalse(probe.schema_accepts(value, schema))

    def test_typed_constant_registration_preserves_boolean_and_refuses_cli_wrong_type(self):
        declared={"type":"object","properties":{"read_only":{"const":True}},"required":["read_only"],"additionalProperties":False}
        normalized=probe.registration_schema(declared)
        self.assertEqual(normalized["properties"]["read_only"], {"enum":[True],"type":"boolean"})
        for schema in (declared, normalized):
            self.assertTrue(probe.schema_accepts({"read_only":True},schema))
            self.assertFalse(probe.schema_accepts({"read_only":1},schema))
            self.assertFalse(probe.schema_accepts({"read_only":"true"},schema))
        subject=adapter.prepare_tuning(self.manifest,next(c for c in self.cases if c["id"]=="A1"),thread_id="t",turn_id="u")
        tools=[{"type":"function","name":row["name"],"parameters":probe.registration_schema(row["inputSchema"])} for row in subject.schema]
        self.assertEqual(len(probe.filter_request({"tools":tools},subject)["tools"]),4)
        broken=copy.deepcopy(tools)
        next(row for row in broken if row["name"]=="audit")["parameters"]["properties"]["read_only"]["type"]="string"
        with self.assertRaises(ValueError): probe.filter_request({"tools":broken},subject)

    def test_complete_sse_gate_accepts_case_extra_tool_and_rejects_unknown(self):
        subject=adapter.prepare_tuning(self.manifest,next(c for c in self.cases if c["id"]=="A1"),thread_id="t",turn_id="u")
        def validate(item):
            if item.get("name") not in subject.tools: raise ValueError("unknown case tool")
            schema=next(row["inputSchema"] for row in subject.schema if row["name"]==item["name"])
            if not probe.schema_accepts(json.loads(item["arguments"]),schema): raise ValueError("wrong case args")
        args=subject.mcp.released_actions.contracts["audit"]["arguments"]
        with patch.object(probe.profile,"NAMES",list(subject.tools)), patch.object(probe.profile,"validate_function_item",side_effect=validate):
            self.assertEqual(len(probe.profile.gate_complete_sse(probe.profile.provider_sse("audit","audit",args,"actual-case-call"))["call_ids"]),1)
            with self.assertRaises(ValueError): probe.profile.gate_complete_sse(probe.profile.provider_sse("native","exec_command",{},"native-call"))
            with self.assertRaises(ValueError): probe.profile.gate_complete_sse(probe.profile.provider_sse("badargs","audit",{**args,"read_only":1},"bad-call"))

    def test_pinned_output_limit_and_native_config_read_are_in_frozen_probe_source(self):
        source=Path(probe.__file__).read_text()
        self.assertIn("tool_output_token_limit=100000",source)
        self.assertIn('"config/read", {"includeLayers": False}',source)
        self.assertIn('effective_config.get("config", {}).get("tool_output_token_limit") != 100000',source)

    def test_completed_response_extracted_only_from_completed_event(self):
        raw = probe.profile.provider_sse("offline")
        self.assertEqual(probe.completed_response(raw)["status"], "completed")
        with self.assertRaises(ValueError):
            probe.completed_response(b"event: response.created\ndata: {}\n\n")


if __name__ == "__main__": unittest.main()
