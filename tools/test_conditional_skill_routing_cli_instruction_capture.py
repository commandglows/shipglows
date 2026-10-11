"""Focused accounting checks; these do not prove the actual CLI transport."""
import json
import unittest

from tools import conditional_skill_routing_cli_instruction_capture as proof


class InstructionDelivery(unittest.TestCase):
    def test_partial_unicode_is_incomplete(self):
        result = proof.coverage_receipt({proof.CALLS[0]: "native wrapper\n" + proof.PARTIAL})
        self.assertFalse(result["complete"])
        self.assertEqual(result["covered_unique_normative_characters"], len(proof.PARTIAL))
        self.assertEqual(result["rereads"], 0)

    def test_reread_counts_delivery_without_increasing_unique_coverage(self):
        callbacks = {proof.CALLS[0]: proof.PARTIAL, proof.CALLS[2]: proof.FULL,
                     proof.CALLS[3]: proof.FULL}
        result = proof.coverage_receipt(callbacks)
        self.assertTrue(result["complete"])
        self.assertEqual(result["covered_unique_normative_characters"], len(proof.NORMATIVE))
        self.assertEqual(result["delivered_characters_including_rereads"],
                         len(proof.PARTIAL) + 2 * len(proof.FULL))
        self.assertEqual(result["rereads"], 1)

    def test_corruption_and_wrong_call_do_not_establish_coverage(self):
        for callbacks in [{proof.CALLS[2]: proof.FULL.replace("☃", "?")},
                          {proof.CALLS[1]: proof.FULL},
                          {proof.CALLS[2]: proof.FULL + "extra"}]:
            self.assertFalse(proof.coverage_receipt(callbacks)["complete"])

    def test_injection_detection_uses_decoded_nested_values(self):
        values = [{"output": [{"type": "input_text", "text": proof.FULL}]}]
        self.assertTrue(any(proof.LATER in value for value in proof.strings(values)))
        self.assertFalse(any(proof.LATER in value for value in proof.strings([{"text": proof.PARTIAL}])))

    def test_callback_forms_and_rejection(self):
        self.assertEqual(proof.result_text({"output": proof.FULL}), proof.FULL)
        self.assertEqual(proof.result_text({"output": [{"type": "input_text", "text": proof.FULL}]}), proof.FULL)
        with self.assertRaises(ValueError):
            proof.result_text({"output": [{"type": "unknown", "text": proof.FULL}]})

    def test_sse_exact_function_arguments(self):
        arguments = {"cmd": "fictional café ☃", "login": False}
        events = [json.loads(chunk.split(b"data: ", 1)[1])
                  for chunk in proof.function_sse("test", proof.CALLS[0], arguments)]
        item = events[-1]["response"]["output"][0]
        self.assertEqual(item["call_id"], proof.CALLS[0])
        self.assertEqual(json.loads(item["arguments"]), arguments)
        self.assertEqual([event["sequence_number"] for event in events], list(range(len(events))))


if __name__ == "__main__":
    unittest.main()
