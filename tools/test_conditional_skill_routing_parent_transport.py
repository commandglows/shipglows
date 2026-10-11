import base64
import hashlib
import hmac
import io
import json
from pathlib import Path
import subprocess
import sys
import threading
import time
import unittest

from tools.conditional_skill_routing_parent_transport import (
    ParentBridge, ToolResponsePolicy, TransportError, authenticated, decoded,
    frame, make_request, packed, read_frame, read_response, sha, verify)


CHANNEL = b"synthetic-relay-channel-key-000001"
PARENT = b"synthetic-parent-proof-key-000002"


def echo(body, deadline):
    return {"status": 200, "headers": {"content-type": "application/json"}, "body": body}


def bridge(callback=echo, **kw):
    return ParentBridge("responses-fixture", callback, channel_key=CHANNEL, receipt_key=PARENT, **kw)


def request(body=b'{"input":"synthetic"}', request_id="one"):
    return make_request(request_id, "responses-fixture", body, CHANNEL)


class ParentTransportTests(unittest.TestCase):
    def test_exact_noncanonical_unicode_body_and_separate_receipt_auth(self):
        body = ' { "input" : "café U0001f9ea" }\n'.encode()
        parent = bridge()
        response = read_response(parent.handle(request(body)), CHANNEL, "one")
        self.assertEqual(response["body"], body)
        receipt = verify(parent.receipts[0], PARENT)
        self.assertEqual(receipt["body_sha256"], hashlib.sha256(body).hexdigest())
        self.assertTrue(receipt["response_released"])
        with self.assertRaises(TransportError):
            verify(parent.receipts[0], CHANNEL)

    def test_launch_default_blocks_live_callback_without_invocation(self):
        called = []
        with self.assertRaises(TransportError):
            bridge(lambda *args: called.append(args), callback_kind="live")
        self.assertEqual(called, [])
        parent = bridge(callback_kind="mock")
        self.assertFalse(parent.launch_authorized)

    def test_bad_auth_endpoint_unknown_fields_and_types_fail_closed(self):
        for mutate in [lambda d: d.update(endpoint="other"), lambda d: d.update(version=True),
                       lambda d: d.update(headers={"authorization": "synthetic-secret"}),
                       lambda d: d.update(extra="unknown"), lambda d: d.update(id=7),
                       lambda d: d.update(body_sha256="0" * 64)]:
            calls = []
            parent = bridge(lambda *args: calls.append(args))
            value = verify(decoded(request()), CHANNEL)
            mutate(value)
            raw = packed(authenticated(value, CHANNEL))
            with self.assertRaises(TransportError):
                parent.handle(raw)
            self.assertEqual(calls, [])
            self.assertEqual(parent.receipts[-1]["status"], "refused")
        with self.assertRaises(TransportError):
            bridge().handle(request().replace(b'"auth":"', b'"auth":"bad'))

    def test_replay_refused_even_when_original_endpoint_was_denied(self):
        parent = bridge()
        parent.handle(request())
        with self.assertRaisesRegex(TransportError, "replayed"):
            parent.handle(request())
        self.assertEqual(parent.attempts, 2)

    def test_request_body_count_and_total_limits(self):
        for options, messages in [({"max_body": 3}, [(b"four", "a")]),
                                  ({"max_requests": 1}, [(b"a", "a"), (b"b", "b")]),
                                  ({"total_body": 3}, [(b"ab", "a"), (b"cd", "b")])]:
            parent = bridge(**options)
            for index, (body, name) in enumerate(messages):
                if index == len(messages) - 1:
                    with self.assertRaises(TransportError):
                        parent.handle(request(body, name))
                else:
                    parent.handle(request(body, name))

    def test_response_budgets_and_unknown_callback_fields(self):
        for callback, options in [(echo, {"max_response": 1}),
                                  (lambda b, d: {**echo(b, d), "extra": 1}, {}),
                                  (lambda b, d: {"status": True, "headers": {}, "body": b"x"}, {}),
                                  (lambda b, d: {"status": 200, "headers": {"set-cookie": "no"}, "body": b"x"}, {})]:
            parent = bridge(callback, **options)
            with self.assertRaises(TransportError):
                parent.handle(request(b"xx"))
            self.assertFalse(parent.receipts[-1]["response_released"])

    def test_timeout_refuses_release_and_discloses_unproved_cancellation(self):
        release = threading.Event()
        calls = []
        def slow(body, deadline):
            calls.append(body)
            release.wait(0.3)
            return echo(body, deadline)
        parent = bridge(slow, callback_timeout=0.01)
        try:
            with self.assertRaisesRegex(TransportError, "cancellation unproved"):
                parent.handle(request())
        finally:
            release.set()
        self.assertFalse(parent.receipts[-1]["response_released"])
        with self.assertRaisesRegex(TransportError, "permanently retired"):
            parent.handle(request())
        self.assertEqual(len(calls), 1)

    def test_expired_session_does_not_call_parent(self):
        calls = []
        parent = bridge(lambda *args: calls.append(args))
        parent.deadline = time.monotonic() - 1
        with self.assertRaisesRegex(TransportError, "session deadline"):
            parent.handle(request())
        self.assertEqual(calls, [])

    def test_exception_diagnostics_are_hash_only_and_receipts_chain(self):
        secret = "HOST_PARENT_SYNTHETIC_PRIVATE_MARKER"
        def fail(body, deadline):
            raise RuntimeError(secret)
        parent = bridge(fail)
        with self.assertRaises(TransportError):
            parent.handle(request())
        durable = parent.durable_receipts()
        self.assertNotIn(secret.encode(), durable)
        self.assertEqual(len(parent.receipts), 2)
        self.assertEqual(parent.receipts[1]["previous_receipt_sha256"], sha(packed(parent.receipts[0])))
        self.assertTrue(all(verify(row, PARENT) for row in parent.receipts))

    def test_partial_frame_header_body_and_size_are_rejected(self):
        for raw in [b"\0", b"\0\0\0\x03a", b"\0\0\0\0", b"\0\0\0\x07abcdefg"]:
            with self.assertRaises(TransportError):
                read_frame(io.BytesIO(raw), maximum=6)
        self.assertIsNone(read_frame(io.BytesIO(b"")))
        self.assertEqual(read_frame(io.BytesIO(frame(b"abc"))), b"abc")

    def test_serve_stream_records_partial_failure_without_losing_prior_reply(self):
        parent = bridge()
        writer = io.BytesIO()
        with self.assertRaises(TransportError):
            parent.serve_stream(io.BytesIO(frame(request()) + b"\0\0"), writer)
        self.assertEqual(read_response(read_frame(io.BytesIO(writer.getvalue())), CHANNEL, "one")["body"], b'{"input":"synthetic"}')
        self.assertEqual(parent.receipts[-1]["status"], "stream_error")

    def test_broken_pipe_retains_unknown_partial_delivery(self):
        class BrokenWriter:
            def write(self, raw):
                raise BrokenPipeError("synthetic broken pipe")
            def flush(self):
                pass
        parent = bridge()
        with self.assertRaisesRegex(TransportError, "partial delivery UNKNOWN"):
            parent.serve_stream(io.BytesIO(frame(request())), BrokenWriter())
        self.assertEqual(parent.receipts[-1]["status"], "stream_io_error")
        self.assertEqual(parent.receipts[-1]["partial_stdio_delivery"], "UNKNOWN")

    def test_policy_complete_sse_only_and_replays(self):
        from tools.conditional_skill_routing_cli_broker_profile import provider_sse, NAMES, ARGUMENTS, CALLS
        policy = ToolResponsePolicy(set(NAMES))
        valid = provider_sse("parent-test", NAMES[0], ARGUMENTS[0], CALLS[0])
        response = lambda raw: {"status": 200, "headers": {"content-type": "text/event-stream"}, "body": raw}
        for raw in [valid.replace(b'"type":"response.created"', b'"type":"response.created","type":"response.created"'),valid[:-1], b'data: {}\n\n', b'data: {"type":"unregistered_tool_event","name":"exec_command"}\n\ndata: [DONE]\n\n',
                    b'data: {"type":"response.output_item.added","item":{"type":"function_call","name":"fixture_read","call_id":"x"}}\n\ndata: [DONE]\n\n',
                    provider_sse("native", "exec_command", {"cmd":"fake"}, "native")]:
            with self.assertRaises(TransportError):
                policy(response(raw))
        self.assertEqual(policy(response(valid))["tool_calls"], {CALLS[0]:NAMES[0]})
        with self.assertRaises(TransportError):
            policy(response(valid))
        with self.assertRaises(TransportError):
            policy({"status":200,"headers":{"content-type":"application/json"},"body":b'{"output":[]}'})

    def test_response_policy_refusal_is_durable_and_not_released(self):
        def callback(body, deadline):
            return {"status": 200, "headers": {"content-type": "application/json"}, "body": packed({"output": [{"type": "function_call", "name": "exec_command", "call_id": "x"}]})}
        parent = bridge(callback, response_policy=ToolResponsePolicy({"fixture_read"}))
        with self.assertRaises(TransportError):
            parent.handle(request())
        self.assertFalse(parent.receipts[-1]["response_released"])
        self.assertEqual(parent.receipts[-2]["status"], "response_policy_error")

    def test_separate_process_relay_exact_bytes_without_parent_credentials(self):
        # The child receives only module path, synthetic channel key and exact
        # body fixture. Its environment is explicitly empty of host credentials.
        # This is a process/protocol test, not a bwrap isolation proof.
        child_code = '''
import base64,importlib.util,json,sys
path=sys.argv[1]
spec=importlib.util.spec_from_file_location("bridge",path)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
bootstrap=m.decoded(m.read_frame(sys.stdin.buffer))
assert set(bootstrap)=={"channel_key","body_b64"}
key=base64.b64decode(bootstrap["channel_key"])
body=base64.b64decode(bootstrap["body_b64"])
sys.stdout.buffer.write(m.frame(m.make_request("child-one","responses-fixture",body,key)));sys.stdout.buffer.flush()
raw=m.read_frame(sys.stdin.buffer)
result=m.read_response(raw,key,"child-one")
assert result["body"]==body
sys.stdout.buffer.write(m.frame(m.packed({"exact":True,"body_sha256":m.sha(body),"environment_keys":sorted(__import__("os").environ)})));sys.stdout.buffer.flush()
'''
        path = Path(__file__).with_name("conditional_skill_routing_parent_transport.py").resolve()
        body = b'{ "input" : "synthetic-child" }\n'
        parent_marker = b"HOST_CREDENTIAL_SYNTHETIC_NEVER_INJECT"
        observed = []
        def callback(raw, deadline):
            observed.append((raw, parent_marker))
            return echo(raw, deadline)
        parent = bridge(callback)
        process = subprocess.Popen([sys.executable, "-B", "-I", "-c", child_code, str(path)], stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE, env={"PYTHONIOENCODING": "utf-8"})
        # External timer supervises the otherwise blocking framed pipe reads.
        watchdog = threading.Timer(5, process.kill)
        watchdog.start()
        try:
            bootstrap = packed({"channel_key": base64.b64encode(CHANNEL).decode(), "body_b64": base64.b64encode(body).decode()})
            process.stdin.write(frame(bootstrap)); process.stdin.flush()
            outgoing = read_frame(process.stdout)
            self.assertNotIn(parent_marker, outgoing)
            self.assertNotIn(PARENT, outgoing)
            response = parent.handle(outgoing)
            process.stdin.write(frame(response)); process.stdin.flush()
            child_receipt = decoded(read_frame(process.stdout))
            process.stdin.close()
            process.wait(timeout=5)
            stderr = process.stderr.read()
            self.assertEqual(process.returncode, 0, stderr)
            self.assertTrue(child_receipt["exact"])
            self.assertEqual(child_receipt["body_sha256"], sha(body))
            self.assertEqual(observed, [(body, parent_marker)])
            self.assertNotIn(parent_marker, response + stderr + packed(child_receipt))
            self.assertNotIn(PARENT, response + stderr + packed(child_receipt))
            self.assertTrue(set(child_receipt["environment_keys"]) <= {"PYTHONIOENCODING", "LC_CTYPE"})
        finally:
            watchdog.cancel()
            if process.poll() is None:
                process.kill()
            process.wait(timeout=5)
            for stream in (process.stdin, process.stdout, process.stderr):
                if stream and not stream.closed:
                    stream.close()


if __name__ == "__main__":
    unittest.main()
