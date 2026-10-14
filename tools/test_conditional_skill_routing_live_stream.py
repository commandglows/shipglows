"""Realistic synthetic Responses protocol checks; no subject, network or auth."""
import copy
import json
import unittest

from tools import conditional_skill_routing_live_stream as live


def response(output, completed=False):
    return {"id": "resp_synthetic", "object": "response", "created_at": 1791970000,
            "status": "completed" if completed else "in_progress", "model": "gpt-6-luna",
            "output": output, "usage": {"input_tokens": 100, "output_tokens": 30,
                "total_tokens": 130, "input_tokens_details": {"cached_tokens": 40},
                "output_tokens_details": {"reasoning_tokens": 20}} if completed else None,
            "background": False, "store": False, "parallel_tool_calls": True,
            "metadata": {"fixture": "public-synthetic"}, "reasoning": {"effort": "medium"},
            "max_output_tokens": None, "tools": [], "text": {"format": {"type": "text"}},
            "error": None, "incomplete_details": None, "temperature": 1.0, "top_p": 1.0}


def function(identifier="fc_one", call="call_one", name="fixture_read"):
    return {"type": "function_call", "id": identifier, "status": "completed",
            "call_id": call, "name": name, "arguments": '{"target":"evidence/étoile.txt"}'}


def message(identifier="msg_one", text="Synthèse publique."):
    return {"type": "message", "id": identifier, "role": "assistant", "status": "completed",
            "phase": "final_answer", "content": [{"type": "output_text", "text": text, "annotations": []}]}


def reasoning(identifier="rs_one", encrypted=True):
    value = {"type": "reasoning", "id": identifier, "summary": [{"type": "summary_text", "text": "Résumé synthétique."}]}
    if encrypted:
        value["encrypted_content"] = "SYNTHETIC_GENERATED_CIPHERTEXT"
    return value


def events(items=None):
    items = copy.deepcopy(items if items is not None else [reasoning(), function(), message()])
    result = [{"type": "response.created", "response": response([])},
              {"type": "response.in_progress", "response": response([])}]
    for index, done in enumerate(items):
        added = copy.deepcopy(done)
        if "status" in added:
            added["status"] = "in_progress"
        if done["type"] == "function_call":
            added["arguments"] = ""
        elif done["type"] == "message":
            added["content"] = []
        else:
            added["summary"] = []
            if "content" in added:
                added["content"] = []
            added.pop("encrypted_content", None)
        result.append({"type": "response.output_item.added", "output_index": index, "item": added})
        common = {"item_id": done["id"], "output_index": index}
        if done["type"] == "function_call":
            args = done["arguments"]
            result += [{"type": "response.function_call_arguments.delta", **common, "delta": args[:9], "obfuscation": "padding"},
                       {"type": "response.function_call_arguments.delta", **common, "delta": args[9:]},
                       {"type": "response.function_call_arguments.done", **common, "arguments": args, "name": done["name"]}]
        else:
            groups = [("content", "response.content_part", "response.output_text", "content_index")] if done["type"] == "message" else [
                ("summary", "response.reasoning_summary_part", "response.reasoning_summary_text", "summary_index"),
                ("content", "response.content_part", "response.reasoning_text", "content_index")]
            for field, part_prefix, text_prefix, index_key in groups:
                for part_index, part in enumerate(done.get(field, [])):
                    text_field = "refusal" if part["type"] == "refusal" else "text"
                    prefix = "response.refusal" if part["type"] == "refusal" else text_prefix
                    empty = {**part, text_field: ""}
                    where = {**common, index_key: part_index}
                    result += [{"type": part_prefix + ".added", **where, "part": empty},
                               {"type": prefix + ".delta", **where, "delta": part[text_field]},
                               {"type": prefix + ".done", **where, text_field: part[text_field]},
                               {"type": part_prefix + ".done", **where, "part": part}]
        result.append({"type": "response.output_item.done", "output_index": index, "item": done})
    result.append({"type": "response.completed", "response": response(items, True)})
    return result


def encode(rows, *, event_lines=True, crlf=False):
    output = []
    for index, value in enumerate(rows):
        value = {"sequence_number": index, **value}
        output.append(("event: " + value["type"] + "\n" if event_lines else "") +
                      "data: " + json.dumps(value, ensure_ascii=False) + "\n\n")
    raw = "".join(output).encode()
    return raw.replace(b"\n", b"\r\n") if crlf else raw


class LiveStreamTests(unittest.TestCase):
    def setUp(self):
        self.validated = []

    def validate(self, item):
        self.validated.append(copy.deepcopy(item))
        if item["name"] != "fixture_read" or json.loads(item["arguments"]) != {"target": "evidence/étoile.txt"}:
            raise ValueError("fixture schema refusal")

    def gate(self, rows=None, seen=frozenset()):
        return live.gate_complete_sse(encode(rows if rows is not None else events()), seen, self.validate)

    def rejects(self, rows):
        with self.assertRaises(ValueError):
            self.gate(rows)

    def test_normal_subscription_usage_and_generated_reasoning_unknown(self):
        raw = encode(events())
        result = live.gate_complete_sse(raw, frozenset(), self.validate)
        self.assertEqual(result["call_ids"], ["call_one"])
        self.assertEqual(result["message_ids"], ["msg_one"])
        self.assertEqual(result["reasoning_ids"], ["rs_one"])
        self.assertEqual(result["usage"]["input_tokens_details"]["cached_tokens"], 40)
        self.assertEqual(result["usage"]["output_tokens_details"]["reasoning_tokens"], 20)
        self.assertTrue(result["generated_encrypted_content_present"])
        self.assertEqual(result["instruction_retention"], "UNKNOWN")
        self.assertEqual(result["cost"], "UNKNOWN")
        self.assertFalse(result["context_compaction_inferred"])
        self.assertEqual(live.completed_response(raw)["output"], [reasoning(), function(), message()])
        self.assertNotIn("SYNTHETIC_GENERATED_CIPHERTEXT", json.dumps(result))

    def test_message_only_data_frames_crlf_and_keepalive(self):
        raw = b": keepalive\r\n\r\n" + encode(events([message()]), event_lines=False, crlf=True)
        result = live.gate_complete_sse(raw, [], self.validate)
        self.assertEqual(result["function_names"], [])
        self.assertEqual(self.validated, [])

    def test_multiple_message_parts_reasoning_content_and_refusal(self):
        m = message(); m["content"].append({"type": "refusal", "refusal": "Refus synthétique."})
        rs = reasoning(encrypted=False); rs["content"] = [{"type": "reasoning_text", "text": "Generated text."}]
        self.assertEqual(self.gate(events([rs, m]))["output_items"], 2)

    def test_empty_reasoning_summary_is_valid_generated_state(self):
        rs = reasoning(); rs["summary"] = []
        self.assertEqual(self.gate(events([rs, function()]))["generated_reasoning_state"], "UNKNOWN")

    def test_function_without_optional_status_and_late_message_phase(self):
        f = function(); f.pop("status")
        rows = events([f, message()])
        next(x for x in rows if x["type"] == "response.output_item.added" and x["item"]["type"] == "message")["item"].pop("phase")
        self.assertEqual(self.gate(rows)["call_ids"], ["call_one"])

    def test_unknown_native_function_and_changed_arguments_refused(self):
        for f in (function(name="exec_command"), {**function(), "arguments": '{"target":"outside"}'}):
            with self.subTest(name=f["name"]):
                self.rejects(events([f]))

    def test_native_or_compaction_output_item_refused(self):
        for kind in ("web_search_call", "computer_call", "compaction", "mcp_call"):
            rows = events([message()]); rows[2]["item"]["type"] = kind
            self.rejects(rows)

    def test_callback_never_runs_until_full_stream_coherence(self):
        rows = events(); rows[-1]["response"]["output"][-1]["content"][0]["text"] = "changed"
        self.rejects(rows)
        self.assertEqual(self.validated, [])

    def test_callback_mutation_cannot_change_response_or_leak_exception(self):
        raw = encode(events([function()]))
        def mutate(item):
            item["name"] = "changed"
        self.assertEqual(live.gate_complete_sse(raw, [], mutate)["function_names"], ["fixture_read"])
        def secret_error(item):
            raise ValueError("SYNTHETIC_SECRET_IN_EXCEPTION")
        with self.assertRaises(ValueError) as error:
            live.gate_complete_sse(raw, [], secret_error)
        self.assertNotIn("SYNTHETIC_SECRET", str(error.exception))

    def test_seen_and_duplicate_call_ids(self):
        with self.assertRaises(ValueError):
            self.gate(events([function()]), {"call_one"})
        self.rejects(events([function(), function(identifier="fc_other")]))

    def test_duplicate_item_id_or_output_index(self):
        for key in ("id", "index"):
            rows = events([message(), message("msg_two")])
            added = [x for x in rows if x["type"] == "response.output_item.added"]
            if key == "id": added[1]["item"]["id"] = "msg_one"
            else: added[1]["output_index"] = 0
            self.rejects(rows)

    def test_argument_delta_done_item_and_terminal_must_agree(self):
        for event_name, field in (("response.function_call_arguments.delta", "delta"),
                                  ("response.function_call_arguments.done", "arguments"),
                                  ("response.function_call_arguments.done", "name")):
            rows = events([function()]); next(x for x in rows if x["type"] == event_name)[field] = "changed"
            self.rejects(rows)
        rows = events([function()]); next(x for x in rows if x["type"] == "response.output_item.done")["item"]["call_id"] = "foreign"
        self.rejects(rows)

    def test_text_delta_done_part_and_item_must_agree(self):
        for event_name, field in (("response.output_text.delta", "delta"), ("response.output_text.done", "text")):
            rows = events([message()]); next(x for x in rows if x["type"] == event_name)[field] = "changed"
            self.rejects(rows)
        rows = events([message()]); next(x for x in rows if x["type"] == "response.content_part.done")["part"]["text"] = "changed"
        self.rejects(rows)

    def test_foreign_ids_wrong_indexes_and_boolean_indexes(self):
        for key, value in (("item_id", "foreign"), ("output_index", 9), ("output_index", True), ("content_index", 3)):
            rows = events([message()]); next(x for x in rows if x["type"] == "response.output_text.delta")[key] = value
            self.rejects(rows)

    def test_missing_duplicate_or_late_completion_events(self):
        for event_name in ("response.function_call_arguments.done", "response.content_part.done", "response.output_item.done"):
            rows = events(); del rows[next(i for i,x in enumerate(rows) if x["type"] == event_name)]
            self.rejects(rows)
        rows = events(); rows.insert(-1, copy.deepcopy(rows[-2])); self.rejects(rows)
        rows = events(); rows.append(copy.deepcopy(rows[-1])); self.rejects(rows)

    def test_response_ids_models_status_error_and_envelope(self):
        for key, value in (("id", "foreign"), ("model", "another-model"), ("status", "incomplete"),
                           ("error", {"message": "failure"}), ("incomplete_details", {"reason": "max_output_tokens"}),
                           ("unknown_transport_field", True)):
            rows = events(); rows[-1]["response"][key] = value; self.rejects(rows)

    def test_usage_missing_boolean_negative_inconsistent_or_detail_overflow(self):
        for key, value in (("input_tokens", True), ("output_tokens", -1), ("total_tokens", 9),
                           ("input_tokens_details", {"cached_tokens": 101}),
                           ("output_tokens_details", {"reasoning_tokens": 31})):
            rows = events(); rows[-1]["response"]["usage"][key] = value; self.rejects(rows)
        rows = events(); rows[-1]["response"]["usage"] = None; self.rejects(rows)

    def test_role_and_unknown_item_fields_refused(self):
        rows = events([message()]); rows[2]["item"]["role"] = "user"; self.rejects(rows)
        rows = events([function()]); rows[2]["item"]["untrusted_extra"] = "x"; self.rejects(rows)

    def test_bad_json_duplicate_keys_nonfinite_and_invalid_utf8(self):
        raw = encode(events([message()]))
        for bad in (raw.replace(b'"type": "response.created"', b'"type": "response.created", "type": "response.created"', 1),
                    raw.replace(b'"temperature": 1.0', b'"temperature": NaN', 1),
                    raw.replace(b'"temperature": 1.0', b'"temperature": 1e999', 1), raw.replace(b'resp_synthetic', b'\xff', 1)):
            with self.assertRaises(ValueError): live.gate_complete_sse(bad, [], self.validate)

    def test_truncation_event_sequence_unknown_events_and_frame_fields(self):
        raw = encode(events([message()]))
        for bad in (raw[:-1], raw + b'\n', raw.replace(b'"sequence_number": 0', b'"sequence_number": true', 1),
                    raw.replace(b'"sequence_number": 0', b'"sequence_number": 9', 1),
                    raw.replace(b'event: response.created', b'event: response.failed', 1),
                    b'id: unsupported\n' + raw, raw + b'data: [DONE]\n\n'):
            with self.assertRaises(ValueError): live.gate_complete_sse(bad, [], self.validate)

    def test_arguments_invalid_json_object_or_duplicate_keys(self):
        for arguments in ('[]', '{"x":1,"x":2}', '{"x":NaN}', '{'):
            rows = events([{**function(), "arguments": arguments}]); self.rejects(rows)

    def test_unknown_event_fields_and_wrong_part_type(self):
        rows = events([message()]); rows[3]["extra"] = True; self.rejects(rows)
        rows = events([message()]); rows[3]["part"]["type"] = "input_text"; self.rejects(rows)

    def test_body_and_validator_bounds(self):
        for raw in (b'', b'x' * (live.BODY_LIMIT + 1), 'not-bytes'):
            with self.assertRaises(ValueError): live.gate_complete_sse(raw, [], self.validate)
        with self.assertRaises(ValueError): live.gate_complete_sse(encode(events()), [], None)

    def test_multiline_data_and_text_done_without_delta(self):
        rows = events([message()]); rows = [x for x in rows if x["type"] != "response.output_text.delta"]
        self.assertEqual(self.gate(rows)["message_ids"], ["msg_one"])
        raw = ''.join('data: ' + json.dumps({"sequence_number": i, **x}) + '\n\n' for i,x in enumerate(rows)).encode()
        self.assertEqual(live.completed_response(raw)["id"], 'resp_synthetic')

    def test_duplicate_in_progress_and_changed_known_metadata_types(self):
        rows = events(); rows.insert(2, copy.deepcopy(rows[1])); self.rejects(rows)
        for key, value in (("tools", "not-a-list"), ("instructions", {}), ("metadata", {"x": 1}),
                           ("reasoning", {"unknown": True}), ("temperature", True),
                           ("tool_choice", {"type": "web_search"}),
                           ("context_management", [{"type": "compaction"}])):
            rows = events(); rows[-1]["response"][key] = value; self.rejects(rows)

    def test_lone_unicode_surrogate_and_excessive_nesting_are_sanitized(self):
        raw = encode(events([message()]))
        for bad in (raw.replace(b'"resp_synthetic"', b'"\\ud800"', 1),
                    raw.replace(b'"metadata": {"fixture": "public-synthetic"}',
                                b'"metadata": ' + b'[' * 1200 + b'0' + b']' * 1200, 1)):
            with self.assertRaises(ValueError):
                live.gate_complete_sse(bad, [], self.validate)

    def test_known_function_declaration_and_envelope_fields(self):
        rows = events([function()])
        for row in (rows[0], rows[1], rows[-1]):
            row["response"].update(tools=[{"type": "function", "name": "fixture_read",
                "parameters": {"type": "object"}, "strict": False}], tool_choice="auto",
                conversation={"id": "conv_synthetic"}, prompt={"id": "pmpt_synthetic"},
                prompt_cache_key="synthetic", service_tier="default")
        self.assertEqual(self.gate(rows)["function_names"], ["fixture_read"])


if __name__ == "__main__":
    unittest.main()
