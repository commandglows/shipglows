"""Offline trusted transport regressions; no CLI, credentials or provider."""
import copy
import json
import unittest

from tools import conditional_skill_routing_cli_broker_profile as profile


class BrokerBoundaryTests(unittest.TestCase):
    def request(self):
        tools = [{"type": "function", "name": name, "parameters": schema,
                  "description": "synthetic", "strict": False} for name, schema in zip(profile.NAMES, profile.SCHEMAS)]
        return {"model": "synthetic", "instructions": "synthetic base\n\u2603",
                "input": [{"type": "message", "role": "user", "content": [{"type": "input_text", "text": "synthetic\nexact"}]}],
                "tools": [{"type": "function", "name": "exec_command", "parameters": {}}, *tools,
                          {"type": "web_search"}], "stream": True, "store": False}

    def decode(self, raw):
        return [json.loads(block.split(b"\ndata: ", 1)[1]) for block in raw[:-2].split(b"\n\n")]

    def encode(self, events):
        return b"".join(b"event: " + event["type"].encode() + b"\ndata: " + profile.pack(event) + b"\n\n" for event in events)

    def test_filter_preserves_every_non_tools_field_and_original_input(self):
        original = self.request()
        unchanged = copy.deepcopy(original)
        forwarded = profile.filter_model_request(original)
        self.assertEqual(original, unchanged)
        self.assertEqual([tool["name"] for tool in forwarded["tools"]], profile.NAMES)
        self.assertEqual({k: v for k, v in original.items() if k != "tools"},
                         {k: v for k, v in forwarded.items() if k != "tools"})
        forwarded["input"][0]["content"][0]["text"] = "changed"
        self.assertEqual(original, unchanged)

    def test_missing_duplicate_and_drifted_registered_schemas_fail_closed(self):
        missing, duplicate, changed = self.request(), self.request(), self.request()
        missing["tools"] = [tool for tool in missing["tools"] if tool.get("name") != "fixture_read"]
        duplicate["tools"].append(copy.deepcopy(duplicate["tools"][1]))
        changed["tools"][1] = {**changed["tools"][1], "parameters": {"type": "object"}}
        for request in (missing, duplicate, changed):
            with self.subTest(request=request), self.assertRaises(ValueError):
                profile.filter_model_request(request)

    def test_valid_complete_calls_and_message_pass_full_stream_gate(self):
        for name, arguments, call_id in zip(profile.NAMES, profile.ARGUMENTS, profile.CALLS):
            raw = profile.provider_sse("fixture", name, arguments, call_id)
            receipt = profile.gate_complete_sse(raw)
            self.assertEqual(receipt["function_names"], [name])
            self.assertEqual(receipt["provider_bytes_validated_before_cli_emission"], len(raw))
        receipt = profile.gate_complete_sse(profile.provider_sse("message"))
        self.assertEqual(receipt["function_names"], [])

    def test_native_unregistered_and_unknown_output_types_are_refused(self):
        for name in ("exec_command", "apply_patch", "web_search", "functions.exec", "multi_agent_v1.spawn_agent"):
            raw = profile.provider_sse("attack", name, {"cmd": "MUST_NOT_EXECUTE"}, "attack_call")
            with self.subTest(name=name), self.assertRaisesRegex(ValueError, "unregistered or native"):
                profile.gate_complete_sse(raw)
        events = self.decode(profile.provider_sse("unknown"))
        events[1]["item"] = {"type": "compaction", "id": "unexpected"}
        with self.assertRaisesRegex(ValueError, "unknown provider item"):
            profile.gate_complete_sse(self.encode(events))

    def test_truncated_unknown_or_contradictory_streams_fail_closed(self):
        valid = profile.provider_sse("fixture", profile.NAMES[0], profile.ARGUMENTS[0], profile.CALLS[0])
        cases = [valid[:-2]]
        events = self.decode(valid)
        unknown_field = copy.deepcopy(events)
        unknown_field[2]["unexpected"] = "field"
        cases.append(self.encode(unknown_field))
        bad_delta = copy.deepcopy(events)
        bad_delta[2]["delta"] = '{"path":"unauthorized"}'
        cases.append(self.encode(bad_delta))
        boolean_sequence = copy.deepcopy(events)
        boolean_sequence[1]["sequence_number"] = True
        cases.append(self.encode(boolean_sequence))
        after_completion = copy.deepcopy(events)
        extra = copy.deepcopy(events[-1])
        extra["sequence_number"] += 1
        after_completion.append(extra)
        cases.append(self.encode(after_completion))
        for raw in cases:
            with self.subTest(raw=raw[:50]), self.assertRaises(ValueError):
                profile.gate_complete_sse(raw)

    def test_native_names_in_each_output_lifecycle_position_are_refused(self):
        valid = self.decode(profile.provider_sse("fixture", profile.NAMES[0], profile.ARGUMENTS[0], profile.CALLS[0]))
        for location in ("added", "done", "completed"):
            events = copy.deepcopy(valid)
            if location == "completed":
                events[-1]["response"]["output"][0]["name"] = "exec_command"
            else:
                kind = "response.output_item." + location
                next(event for event in events if event["type"] == kind)["item"]["name"] = "exec_command"
            with self.subTest(location=location), self.assertRaises(ValueError):
                profile.gate_complete_sse(self.encode(events))

    def test_conflicting_identity_name_arguments_and_indices_are_refused(self):
        valid = self.decode(profile.provider_sse("fixture", profile.NAMES[0], profile.ARGUMENTS[0], profile.CALLS[0]))
        cases = []
        for key, replacement in (("id", "other-item"), ("call_id", "other-call"),
                                 ("name", profile.NAMES[1]), ("arguments", '{"path":"outside-fixture"}')):
            events = copy.deepcopy(valid)
            done = next(event for event in events if event["type"] == "response.output_item.done")
            done["item"][key] = replacement
            events[-1]["response"]["output"] = [done["item"]]
            cases.append(events)
        wrong_index = copy.deepcopy(valid)
        wrong_index[2]["output_index"] = 1
        cases.append(wrong_index)
        wrong_delta_identity = copy.deepcopy(valid)
        wrong_delta_identity[2]["item_id"] = "other-item"
        cases.append(wrong_delta_identity)
        for events in cases:
            with self.subTest(events=events), self.assertRaises(ValueError):
                profile.gate_complete_sse(self.encode(events))

    def test_namespace_builtin_and_local_shell_output_shapes_are_refused(self):
        valid = self.decode(profile.provider_sse("fixture", profile.NAMES[0], profile.ARGUMENTS[0], profile.CALLS[0]))
        for shape in ("namespace", "local_shell_call", "custom_tool_call", "web_search_call", "tool_search_call", "computer_call", "compaction"):
            events = copy.deepcopy(valid)
            events[1]["item"]["type"] = shape
            with self.subTest(shape=shape), self.assertRaises(ValueError):
                profile.gate_complete_sse(self.encode(events))
        for field in ("namespace", "encrypted_function_args", "recipient"):
            events = copy.deepcopy(valid)
            events[1]["item"][field] = "unregistered"
            with self.subTest(field=field), self.assertRaises(ValueError):
                profile.gate_complete_sse(self.encode(events))

    def test_replayed_call_id_across_responses_is_refused(self):
        raw = profile.provider_sse("fixture", profile.NAMES[0], profile.ARGUMENTS[0], profile.CALLS[0])
        receipt = profile.gate_complete_sse(raw)
        with self.assertRaisesRegex(ValueError, "replayed"):
            profile.gate_complete_sse(raw, set(receipt["call_ids"]))

    def test_duplicate_call_id_in_two_distinct_completed_items_is_refused(self):
        first = self.decode(profile.provider_sse("first", profile.NAMES[0], profile.ARGUMENTS[0], "duplicate-call"))
        second = self.decode(profile.provider_sse("second", profile.NAMES[1], profile.ARGUMENTS[1], "duplicate-call"))
        for event in second[1:-1]:
            event["output_index"] = 1
        events = first[:-1] + second[1:-1] + [first[-1]]
        events[-1]["response"]["output"] = [first[-1]["response"]["output"][0], second[-1]["response"]["output"][0]]
        for index, event in enumerate(events):
            event["sequence_number"] = index
        with self.assertRaisesRegex(ValueError, "duplicate provider call id"):
            profile.gate_complete_sse(self.encode(events))

    def test_partial_contradictory_or_unknown_text_lifecycles_are_refused(self):
        valid = self.decode(profile.provider_sse("message"))
        cases = []
        for omitted in ("response.content_part.added", "response.output_text.done", "response.content_part.done"):
            events = [copy.deepcopy(event) for event in valid if event["type"] != omitted]
            for index, event in enumerate(events):
                event["sequence_number"] = index
            cases.append(events)
        bad_type = copy.deepcopy(valid)
        next(event for event in bad_type if event["type"] == "response.content_part.added")["part"]["type"] = "function_call"
        cases.append(bad_type)
        bad_delta = copy.deepcopy(valid)
        next(event for event in bad_delta if event["type"] == "response.output_text.delta")["delta"] = "different text"
        cases.append(bad_delta)
        for events in cases:
            with self.subTest(events=events), self.assertRaises(ValueError):
                profile.gate_complete_sse(self.encode(events))


if __name__ == "__main__":
    unittest.main()
