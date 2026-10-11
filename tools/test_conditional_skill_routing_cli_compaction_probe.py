"""Offline capture and protocol regressions; no CLI, provider or campaign."""
import io
import json
from pathlib import Path
import queue
import tempfile
import time
import unittest

from tools import conditional_skill_routing_cli_compaction_probe as probe


class CompactionCaptureRegressions(unittest.TestCase):
    def bare_rpc(self):
        rpc = probe.Rpc.__new__(probe.Rpc)
        rpc.pending, rpc.queue, rpc.errors, rpc.events = [], queue.Queue(), [], []
        rpc.end = time.monotonic() + 1
        rpc.sent_values = []
        rpc.send = rpc.sent_values.append
        return rpc

    def test_callback_preserves_unicode_newlines_and_rejects_unknown_parts(self):
        exact = 'diagnostic\n\u2603 "quoted" \\ literal\n'
        self.assertEqual(probe.output_text({"output": exact}), exact)
        self.assertEqual(probe.output_text({"output": [
            {"type": "input_text", "text": exact[:7]},
            {"type": "input_text", "text": exact[7:]}]}), exact)
        for value in (None, 0, {"text": exact}, [{"type": "output_text", "text": exact}],
                      [{"type": "input_text", "text": None}]):
            with self.subTest(value=value), self.assertRaises(ValueError):
                probe.output_text({"output": value})
        # Decoded JSON strings preserve exact newline markers; JSON serialization
        # alone would search escaped newlines and silently misreport presence.
        request = {"input": [{"output": [{"type": "input_text", "text": exact}]}]}
        self.assertIn(exact, list(probe.text_values(request)))
        self.assertNotIn(exact, json.dumps(request))

    def test_function_stream_carries_exact_call_id_and_arguments_to_completion(self):
        arguments = {"cmd": "fictional_only", "workdir": "/synthetic"}
        for call_id in [probe.CALL, *probe.RECOVERY_CALLS]:
            packets = probe.sse("mock", arguments=arguments, call_id=call_id)
            events = [json.loads(packet.split(b"\ndata: ", 1)[1].strip()) for packet in packets]
            self.assertEqual([event["sequence_number"] for event in events], list(range(len(events))))
            done = next(event["item"] for event in events if event["type"] == "response.output_item.done")
            self.assertEqual(done["call_id"], call_id)
            self.assertEqual(done["name"], "exec_command")
            self.assertEqual(json.loads(done["arguments"]), arguments)
            self.assertEqual(events[-1]["type"], "response.completed")
            self.assertEqual(events[-1]["response"]["output"], [done])

    def test_compaction_completion_before_rpc_ack_is_retained_for_next_wait(self):
        rpc = self.bare_rpc()
        compact = {"method": "item/completed", "params": {"threadId": "fixture-thread",
                   "item": {"type": "contextCompaction", "id": "fixture-compact"}}}
        rpc.queue.put(compact)
        rpc.queue.put({"id": 4, "result": {}})
        self.assertEqual(rpc.await_event(lambda event: event.get("id") == 4), {"id": 4, "result": {}})
        self.assertEqual(rpc.await_event(lambda event: event.get("params", {}).get("item", {}).get("type") == "contextCompaction"), compact)
        self.assertEqual(rpc.pending, [])

    def test_unsolicited_server_callback_and_error_stream_fail_closed(self):
        rpc = self.bare_rpc()
        rpc.queue.put({"id": "unexpected", "method": "item/tool/call", "params": {}})
        with self.assertRaisesRegex(RuntimeError, "unexpected server callback"):
            rpc.await_event(lambda event: False)
        self.assertEqual(rpc.sent_values, [{"jsonrpc": "2.0", "id": "unexpected",
                         "error": {"code": -32000, "message": "Mock probe denies unsolicited callbacks"}}])
        for event in ({"method": "error", "params": {"error": {"message": "controlled"}}},
                      {"eof": True}, {"capture_failure": True}):
            rpc = self.bare_rpc()
            rpc.queue.put(event)
            with self.subTest(event=event), self.assertRaises(RuntimeError):
                rpc.await_event(lambda value: False)

    def test_malformed_rpc_bytes_captured_before_parse_and_exclusive_blob_write(self):
        with tempfile.TemporaryDirectory(prefix="csr-compaction-offline-") as directory:
            capture = probe.Capture(Path(directory))
            rpc = self.bare_rpc()
            rpc.capture = capture
            raw = b'{"broken":\n'
            rpc.collect("stdout", io.BytesIO(raw))
            self.assertEqual((Path(directory) / "rpc-stdout-0000.bin").read_bytes(), raw)
            self.assertEqual(capture.inventory["rpc-stdout-0000.bin"]["sha256"], probe.digest(raw))
            self.assertTrue(rpc.errors)
            self.assertEqual(rpc.events, [])
            self.assertEqual(rpc.queue.get_nowait(), {"capture_failure": True})
            self.assertEqual(rpc.queue.get_nowait(), {"eof": True})
            with self.assertRaises(FileExistsError):
                capture.save("rpc-stdout-0000.bin", b"replacement")
            self.assertEqual((Path(directory) / "rpc-stdout-0000.bin").read_bytes(), raw)


if __name__ == "__main__":
    unittest.main()
