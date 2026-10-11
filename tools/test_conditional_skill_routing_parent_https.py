import io
import json
import time
import unittest

from tools.conditional_skill_routing_parent_https import PreparedHTTPSCallback
from tools.conditional_skill_routing_parent_transport import TransportError, packed, sha


class FakeResponse:
    def __init__(self, body=b'{"output":[]}', status=200, headers=None):
        self.raw, self.stream, self.status = body, io.BytesIO(body), status
        self.headers = {"content-type": "application/json", "content-length": str(len(body))}
        self.headers.update(headers or {})
        self.closed = False
    def getheader(self, name, default=None):
        return self.headers.get(name.lower(), default)
    def read(self, count):
        return self.stream.read(count)
    def close(self):
        self.closed = True


class FakeConnection:
    def __init__(self, response):
        self.response, self.calls, self.closed = response, [], False
        self.sock = None
    def request(self, method, path, body, headers):
        self.calls.append({"method": method, "path": path, "body": body, "headers": headers})
    def getresponse(self):
        return self.response
    def close(self):
        self.closed = True


def body(**changes):
    return packed({"model": "named-model", "store": False, "stream": True,
                   "max_output_tokens": 32, "input": "synthetic", **changes})


def callback(response=None, **options):
    connections = []
    def factory(host, port, timeout):
        connection = FakeConnection(response or FakeResponse())
        connections.append((host, port, timeout, connection))
        return connection
    args = {"endpoint": "https://api.example.invalid/v1/responses", "model": "named-model",
            "account_label": "account-before-launch", "required_settings": {"store": False, "stream": True},
            "launch_authorized": True, "injected_credential": "SYNTHETIC_PARENT_SECRET",
            "connection_factory": factory}
    args.update(options)
    if "approved_budget" not in options:
        limits = {"max_calls": 12, "max_request_bytes": 1024 * 1024, "max_response_bytes": 1024 * 1024,
                  "total_request_bytes": 12 * 1024 * 1024, "total_response_bytes": 12 * 1024 * 1024,
                  "max_output_tokens": 512, "total_output_tokens": 6144, "request_timeout": 15.0, "session_timeout": 120.0}
        limits.update({k: options[k] for k in limits if k in options})
        args["approved_budget"] = {"review_id": "synthetic-fixture-budget-not-live-authority", **limits}
    return PreparedHTTPSCallback(**args), connections


class ParentHTTPSPreparedTests(unittest.TestCase):
    def test_missing_request_cap_blocks_without_verified_ceiling_and_guard(self):
        raw=packed({"model":"named-model","store":False,"stream":True,"input":"synthetic"})
        ceiling={"model":"named-model","max_output_tokens":32,"evidence_sha256":"a"*64,"review_id":"synthetic-ceiling-review"}
        for options in ({}, {"verified_model_ceiling":ceiling},
                        {"verified_model_ceiling":ceiling,"input_cost_budget_guard":lambda *args:False}):
            transport,connections=callback(**options)
            with self.assertRaises(TransportError):transport(raw,time.monotonic()+1)
            self.assertEqual(connections,[])

    def test_reviewed_model_ceiling_reserves_without_rewriting_cli_body(self):
        raw=b'{ "model":"named-model", "store":false, "stream":true, "input":"synthetic" }'
        ceiling={"model":"named-model","max_output_tokens":32,"evidence_sha256":"b"*64,"review_id":"synthetic-ceiling-review"}
        admitted=[]
        def guard(body,deadline):
            admitted.append(body)
            return True
        transport,connections=callback(verified_model_ceiling=ceiling,input_cost_budget_guard=guard)
        transport(raw,time.monotonic()+1)
        self.assertEqual(admitted,[raw])
        self.assertEqual(connections[0][3].calls[0]["body"],raw)
        self.assertEqual(transport.output_tokens_reserved,32)
        self.assertEqual(transport.receipts[-1]["reservation_source"],"verified_model_ceiling")

    def test_default_guard_never_calls_factory_without_launch_authority(self):
        transport, connections = callback(launch_authorized=False)
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() + 1)
        self.assertEqual(connections, [])
        self.assertFalse(transport.receipts[-1]["network_started"])

    def test_missing_parent_credential_never_calls_factory(self):
        transport, connections = callback(injected_credential=None)
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() + 1)
        self.assertEqual(connections, [])

    def test_missing_named_budget_never_calls_factory(self):
        transport, connections = callback(approved_budget=None)
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() + 1)
        self.assertEqual(connections, [])

    def test_nested_settings_boolean_is_not_integer(self):
        transport, connections = callback(required_settings={"store": False, "stream": True, "reasoning": {"x": True}})
        with self.assertRaises(TransportError):
            transport(body(reasoning={"x": 1}), time.monotonic() + 1)
        self.assertEqual(connections, [])

    def test_exact_body_fixed_https_and_parent_only_auth_sanitized_receipts(self):
        transport, connections = callback(FakeResponse(headers={"set-cookie": "secret", "x-request-id": "synthetic-id"}))
        raw = b' { "model":"named-model", "store":false,"stream":true,"max_output_tokens":32,"input":"a" }\n'
        result = transport(raw, time.monotonic() + 1)
        host, port, timeout, connection = connections[0]
        self.assertEqual((host, port), ("api.example.invalid", 443))
        self.assertGreater(timeout, 0)
        self.assertEqual(connection.calls[0]["body"], raw)
        self.assertEqual((connection.calls[0]["method"], connection.calls[0]["path"]), ("POST", "/v1/responses"))
        self.assertEqual(connection.calls[0]["headers"]["Authorization"], "Bearer SYNTHETIC_PARENT_SECRET")
        self.assertNotIn("set-cookie", result["headers"])
        self.assertNotIn(b"SYNTHETIC_PARENT_SECRET", transport.durable_receipts())
        self.assertTrue(connection.closed and connection.response.closed)
        self.assertEqual(transport.receipts[-1]["request_sha256"], sha(raw))

    def test_endpoint_model_account_and_settings_are_required(self):
        for options in [{"endpoint": "http://api.example.invalid/v1/responses"},
                        {"endpoint": "https://api.example.invalid/v1/responses?key=x"},
                        {"endpoint": "https://user:pass@api.example.invalid/v1/responses"},
                        {"endpoint": "https://api.example.invalid:444/v1/responses"},
                        {"endpoint": "https://api.example.invalid/redirect"},
                        {"model": ""}, {"account_label": ""},
                        {"required_settings": {"store": True, "stream": True}},
                        {"required_settings": {"store": False, "stream": True, "unknown": "x"}}]:
            with self.assertRaises(TransportError):
                callback(**options)

    def test_wrong_model_settings_opaque_history_and_token_caps_no_network(self):
        for raw in [body(model="other"), body(store=True), body(stream=1), body(previous_response_id="opaque"),
                    body(max_output_tokens=True), body(max_output_tokens=513), body(max_output_tokens=None), b'{}']:
            transport, connections = callback()
            with self.assertRaises(TransportError):
                transport(raw, time.monotonic() + 1)
            self.assertEqual(connections, [])

    def test_redirect_compression_invalid_content_length_and_partial_response(self):
        for response in [FakeResponse(status=302, headers={"location": "https://other.invalid"}),
                         FakeResponse(headers={"content-encoding": "gzip"}),
                         FakeResponse(headers={"content-length": "-1"}),
                         FakeResponse(headers={"content-length": "99999999999"}),
                         FakeResponse(headers={"content-length": "100"}),
                         FakeResponse(headers={"content-type": "text/html"})]:
            transport, connections = callback(response)
            with self.assertRaises(TransportError):
                transport(body(), time.monotonic() + 1)
            self.assertEqual(len(connections), 1)
            self.assertTrue(connections[0][3].closed)
            self.assertFalse(transport.receipts[-1]["response_released"])

    def test_all_budget_layers(self):
        for options in [{"max_request_bytes": 1}, {"total_request_bytes": 1}, {"max_output_tokens": 1}, {"total_output_tokens": 1}]:
            transport, connections = callback(**options)
            with self.assertRaises(TransportError):
                transport(body(), time.monotonic() + 1)
            self.assertEqual(connections, [])
        for options in [{"max_response_bytes": 1}, {"total_response_bytes": 1}]:
            transport, _ = callback(**options)
            with self.assertRaises(TransportError):
                transport(body(), time.monotonic() + 1)

    def test_calls_and_token_reservations_are_not_restored_after_failure(self):
        transport, connections = callback(FakeResponse(status=302), max_calls=1, total_output_tokens=32)
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() + 1)
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() + 1)
        self.assertEqual(len(connections), 1)
        self.assertEqual(transport.output_tokens_reserved, 32)

    def test_expired_deadline_no_network_and_error_text_not_persisted(self):
        transport, connections = callback()
        with self.assertRaises(TransportError):
            transport(body(), time.monotonic() - 1)
        self.assertEqual(connections, [])
        secret = "SYNTHETIC_PROVIDER_ERROR_CONTAINING_CREDENTIAL"
        def fail(*args):
            raise RuntimeError(secret)
        transport, _ = callback(connection_factory=fail)
        with self.assertRaises(TransportError) as raised:
            transport(body(), time.monotonic() + 1)
        self.assertNotIn(secret, str(raised.exception))
        self.assertTrue(raised.exception.__suppress_context__)
        self.assertNotIn(secret.encode(), transport.durable_receipts())


if __name__ == "__main__":
    unittest.main()
