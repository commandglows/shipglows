import hashlib
import json
import unittest

from tools.conditional_skill_routing_responses_accounting import AccountingError, ResponsesAccounting


def wire(items, **fields):
    return json.dumps({"input": items, **fields}, ensure_ascii=False).encode("utf-8")


def tool(call_id, output):
    return [{"type": "function_call", "call_id": call_id, "name": "exec_command", "arguments": '{"cmd":"synthetic"}'},
            {"type": "function_call_output", "call_id": call_id, "output": output}]


class ResponsesAccountingTests(unittest.TestCase):
    def test_multiple_disjoint_fragments_keep_framing_out_of_source_coverage(self):
        account = ResponsesAccounting({"guard": "abcdefghij"})
        account.register_read_spans("split", "guard", "Frame:ab|ij:End", [
            {"source_start": 0, "source_end": 2, "output_start": 6},
            {"source_start": 8, "source_end": 10, "output_start": 9}])
        receipt = account.capture_request(wire(tool("split", "Frame:ab|ij:End")))
        self.assertEqual(receipt["coverage"]["guard"]["characters"], 4)
        self.assertFalse(receipt["coverage"]["guard"]["full"])
        self.assertEqual(receipt["text_characters"], 15)

    def test_empty_and_overlapping_fragments_never_earn_complete_coverage(self):
        account = ResponsesAccounting({"guard": "abc"})
        account.register_read_spans("empty", "guard", "Frame:End", [
            {"source_start": 1, "source_end": 1, "output_start": 6}])
        receipt = account.capture_request(wire(tool("empty", "Frame:End")))
        self.assertEqual(receipt["coverage"]["guard"]["characters"], 0)
        self.assertEqual(next(e for e in receipt["events"] if e["type"] == "read")["extent"], "empty")
        with self.assertRaises(AccountingError):
            account.register_read_spans("bad", "guard", "ababc", [
                {"source_start": 0, "source_end": 2, "output_start": 0},
                {"source_start": 0, "source_end": 3, "output_start": 2}])
        self.assertNotIn("bad", account.reads)

    def test_unicode_partial_full_and_framing(self):
        source = "É😀 garde\nprotection finale."
        account = ResponsesAccounting({"guard": source})
        account.register_read("partial", "guard", "Output:\n" + source[:3], source_end=3)
        first = account.capture_request(wire(tool("partial", "Output:\n" + source[:3])))
        self.assertFalse(first["coverage"]["guard"]["full"])
        self.assertEqual(first["coverage"]["guard"]["characters"], 3)
        account.register_read("full", "guard", "Output:\n" + source)
        complete = account.capture_request(wire(tool("partial", "Output:\n" + source[:3]) + tool("full", "Output:\n" + source)))
        self.assertTrue(complete["coverage"]["guard"]["full"])
        self.assertEqual(complete["coverage"]["guard"]["characters"], len(source))
        self.assertGreater(complete["text_characters"], len(source))
        self.assertEqual([e["extent"] for e in complete["events"] if e["type"] == "read"], ["partial", "full"])
        self.assertEqual(complete["model_retention"], "UNKNOWN")

    def test_adjacent_partial_union_and_rereads(self):
        account = ResponsesAccounting({"guard": "abcde"})
        account.register_read("a", "guard", "ab", source_end=2)
        account.register_read("b", "guard", "cde", source_start=2)
        raw = wire(tool("a", "ab") + tool("b", "cde"))
        first = account.capture_request(raw)
        second = account.capture_request(raw)
        self.assertTrue(first["coverage"]["guard"]["full"])
        self.assertTrue(all(e["first_delivery"] for e in first["events"] if e["type"] == "read"))
        self.assertTrue(all(not e["first_delivery"] for e in second["events"] if e["type"] == "read"))
        account.register_read("reread", "guard", "abcde")
        third = account.capture_request(wire(tool("reread", "abcde")))
        self.assertTrue(next(e for e in third["events"] if e["type"] == "read")["first_delivery"])
        self.assertEqual(third["text_characters"], 5)

    def test_compaction_invalidates_and_reconstructs_from_actual_input(self):
        account = ResponsesAccounting({"guard": "protect"})
        account.register_read("a", "guard", "protect")
        account.capture_request(wire(tool("a", "protect")))
        account.invalidate("observed compaction", "a" * 64)
        self.assertEqual(account.coverage, {})
        absent = account.capture_request(wire("continue"))
        self.assertFalse(absent["coverage"]["guard"]["full"])
        self.assertEqual(absent["generation"], 1)
        account.register_read("fresh", "guard", "protect")
        fresh = account.capture_request(wire(tool("fresh", "protect")))
        self.assertTrue(fresh["coverage"]["guard"]["full"])
        self.assertEqual(fresh["model_retention"], "UNKNOWN")

    def test_exact_roles_and_injection_occurrences_without_double_counting(self):
        account = ResponsesAccounting(injections=[
            {"id": "common", "text": "KEEP", "roles": ["instructions", "developer"]},
            {"id": "quoted", "text": "IGNORE", "roles": ["user", "tool"]}])
        raw = wire([{"role": "developer", "content": [{"type": "input_text", "text": "KEEP KEEP"}]},
                    {"role": "user", "content": "quoted IGNORE"}, *tool("x", "untrusted IGNORE")], instructions="KEEP")
        receipt = account.capture_request(raw, label="request-1")
        self.assertEqual(receipt["request_sha256"], hashlib.sha256(raw).hexdigest())
        self.assertEqual(receipt["request_bytes"], len(raw))
        injections = [e for e in receipt["events"] if e["type"] == "injection"]
        self.assertEqual(len(injections), 5)
        self.assertEqual([e["role"] for e in injections], ["instructions", "developer", "developer", "user", "tool"])
        self.assertEqual(receipt["text_characters"], sum(map(len, ["KEEP", "KEEP KEEP", "quoted IGNORE", "untrusted IGNORE"])))

    def test_callback_mismatch_transactional_fail_closed(self):
        account = ResponsesAccounting({"guard": "abc"})
        account.register_read("x", "guard", "Output:abc")
        before = len(account.events)
        with self.assertRaises(AccountingError):
            account.capture_request(wire(tool("x", "Output:abX")))
        self.assertEqual(len(account.events), before)
        self.assertEqual(account.coverage, {})
        self.assertEqual(account.receipts[-1]["status"], "rejected")

    def test_opaque_and_unknown_nontext_rejected(self):
        for item in [{"type": "compaction", "encrypted_content": "opaque"},
                     {"type": "reasoning", "summary": []},
                     {"role": "user", "content": [{"type": "input_image", "image_url": "synthetic"}]}]:
            account = ResponsesAccounting()
            with self.assertRaises(AccountingError):
                account.capture_request(wire([item]))
            self.assertFalse(account.receipts[-1]["complete_input_text_accounting"])

    def test_malformed_json_duplicate_nonfinite_and_nonutf8_rejected(self):
        for raw in [b'{"input":"a","input":"b"}', b'{"input":"a","x":NaN}', b'\xff', b'{']:
            account = ResponsesAccounting()
            with self.assertRaises(AccountingError):
                account.capture_request(raw)
            self.assertEqual(account.receipts[-1]["request_sha256"], hashlib.sha256(raw).hexdigest())

    def test_orphan_duplicate_out_of_order_and_nontext_callback_rejected(self):
        cases = [[tool("x", "abc")[1]], tool("x", "abc") + [tool("x", "abc")[1]],
                 list(reversed(tool("x", "abc"))),
                 [tool("x", "abc")[0], {"type": "function_call_output", "call_id": "x", "output": {"text": "abc"}}]]
        for items in cases:
            with self.assertRaises(AccountingError):
                ResponsesAccounting().capture_request(wire(items))

    def test_invalid_source_and_ambiguous_callback_rejected(self):
        account = ResponsesAccounting({"guard": "abc"})
        for kwargs in [{"source_end": 0}, {"source_start": True}, {}, {"output_start": 1}]:
            with self.assertRaises(AccountingError):
                account.register_read("x", "guard", "abcabc", **kwargs)
        account.register_read("x", "guard", "abcabc", output_start=3)
        with self.assertRaises(AccountingError):
            account.register_read("x", "guard", "abc")

    def test_opaque_server_history_rejected(self):
        with self.assertRaises(AccountingError):
            ResponsesAccounting().capture_request(wire("continue", previous_response_id="opaque"))

    def test_unpaired_surrogate_rejected_with_durable_provenance(self):
        account = ResponsesAccounting()
        with self.assertRaises(AccountingError):
            account.capture_request(b'{"input":"\\ud800"}')
        self.assertEqual(account.receipts[-1]["status"], "rejected")
        self.assertEqual(account.receipts[-1]["coverage"], "UNKNOWN")

    def test_invalid_resource_container_rejected(self):
        with self.assertRaises(AccountingError):
            ResponsesAccounting(resources=[])

    def test_multispan_invalid_resource_identity_is_atomic(self):
        account = ResponsesAccounting({"guard": "abc"})
        for identity in ([], {}, None, True):
            with self.assertRaises(AccountingError):
                account.register_read_spans("x", identity, "abc", [])
            self.assertEqual(account.reads, {})

    def test_ordered_calls_and_historical_identity_change_rejected(self):
        account = ResponsesAccounting({"guard": "abc"})
        account.register_read("x", "guard", "abc")
        items = tool("x", "abc")
        receipt = account.capture_request(wire(items))
        self.assertEqual([e["type"] for e in receipt["events"]], ["function_call", "text", "read"])
        items[0]["arguments"] = '{"cmd":"changed"}'
        with self.assertRaises(AccountingError):
            account.capture_request(wire(items))
        self.assertEqual(account.coverage, {})

    def test_capture_result_does_not_expose_mutable_internal_state(self):
        account = ResponsesAccounting({"guard": "abc"})
        account.register_read("x", "guard", "abc")
        result = account.capture_request(wire(tool("x", "abc")))
        result["coverage"]["guard"]["full"] = False
        self.assertTrue(account.coverage["guard"]["full"])


if __name__ == "__main__":
    unittest.main()
