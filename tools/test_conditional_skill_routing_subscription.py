import base64
import json
from pathlib import Path
import tempfile
import time
import unittest

from tools import conditional_skill_routing_subscription as subscription
from tools.test_conditional_skill_routing_parent_https import callback, body
from tools.conditional_skill_routing_parent_transport import TransportError
from tools.conditional_skill_routing_responses_accounting import ResponsesAccounting, AccountingError
from tools.test_conditional_skill_routing_live_stream import events, encode


class SubscriptionAccess(unittest.TestCase):
    def auth(self, directory, *, mode="chatgpt", expiry=1000, account="test-account", claim="test-account"):
        claims = {"exp": expiry, "https://api.openai.com/auth": {"chatgpt_account_id": claim}}
        token = "header." + base64.urlsafe_b64encode(json.dumps(claims).encode()).decode().rstrip("=") + ".signature"
        path = Path(directory) / "auth.json"
        path.write_text(json.dumps({"auth_mode": mode, "tokens": {"access_token": token, "account_id": account}}))
        return path

    def test_parent_session_is_redacted_and_mismatched_or_expiring_sessions_refused(self):
        with tempfile.TemporaryDirectory() as folder:
            path = self.auth(folder)
            value = subscription.load_credential(path, now=0)
            self.assertNotIn(value.access_token, repr(value))
            self.assertNotIn(value.account_id, repr(value))
            for options in ({"mode": "apikey"}, {"expiry": 10}, {"claim": "other"}):
                with self.subTest(options=options):
                    path = self.auth(folder, **options)
                    with self.assertRaises(subscription.SubscriptionAuthError) as error:
                        subscription.load_credential(path, now=0)
                    self.assertNotIn("signature", str(error.exception))

    def test_subscription_headers_only_reach_fixed_upstream_parent_request(self):
        parent, connections = callback(endpoint=subscription.ENDPOINT,
            auth_mode="chatgpt_subscription", injected_account_id="test-account",
            input_cost_budget_guard=subscription.SubscriptionUsageGuard(max_tokens=1000,max_calls=4,model="named-model"))
        raw = body()
        parent(raw, parent.deadline)
        request = connections[0][3].calls[0]
        self.assertEqual(connections[0][0], "chatgpt.com")
        self.assertEqual(request["path"], "/backend-api/codex/responses")
        self.assertEqual(request["body"], raw)
        self.assertEqual(request["headers"]["ChatGPT-Account-ID"], "test-account")
        receipt = parent.durable_receipts().decode()
        self.assertNotIn("test-account", receipt)
        self.assertNotIn("SYNTHETIC_PARENT_SECRET", receipt)
        self.assertIn('"api_billing_route":false', receipt)

    def test_subscription_cannot_select_api_or_redirect_origin(self):
        for endpoint in ("https://api.openai.com/v1/responses", "https://chatgpt.com.evil.invalid/backend-api/codex/responses",
                         subscription.ENDPOINT + "?redirect=x"):
            with self.subTest(endpoint=endpoint), self.assertRaises(TransportError):
                callback(endpoint=endpoint, auth_mode="chatgpt_subscription", injected_account_id="test-account")
        with self.assertRaises(TransportError):
            callback(endpoint=subscription.ENDPOINT, auth_mode="chatgpt_subscription")

    def test_generated_reasoning_is_opt_in_unknown_and_never_instruction_coverage(self):
        item={"type":"reasoning","id":"reasoning-1","summary":[],"encrypted_content":"synthetic-ciphertext"}
        raw=json.dumps({"instructions":"Exact visible instructions", "input":[item]}).encode()
        with self.assertRaises(AccountingError):
            ResponsesAccounting().capture_request(raw)
        accounting=ResponsesAccounting(allow_generated_reasoning=True)
        receipt=accounting.capture_request(raw)
        self.assertFalse(receipt["complete_input_text_accounting"])
        self.assertEqual(receipt["decoded_generated_reasoning_measurement"],"UNKNOWN")
        self.assertEqual(receipt["coverage"],{})
        item["instructions"]="Not an allowed reasoning field"
        with self.assertRaises(AccountingError):
            accounting.capture_request(json.dumps({"input":[item]}).encode())

    def test_pending_request_cannot_reenter_quota_guard(self):
        guard=subscription.SubscriptionUsageGuard(max_tokens=1000,max_calls=4)
        raw=json.dumps({"model":subscription.MODEL,"store":False,"stream":True,"input":[]}).encode()
        self.assertTrue(guard(raw,time.monotonic()+5))
        self.assertFalse(guard(raw,time.monotonic()+5))
        self.assertEqual(guard.calls,1)
        usage=guard.observe_response(encode(events()))
        self.assertEqual(usage["total_tokens"],130)
        self.assertTrue(guard(raw,time.monotonic()+5))

    def test_observed_overrun_is_kept_and_next_request_stops(self):
        guard=subscription.SubscriptionUsageGuard(max_tokens=100,max_calls=4)
        raw=json.dumps({"model":subscription.MODEL,"store":False,"stream":True,"input":[]}).encode()
        self.assertTrue(guard(raw,time.monotonic()+5))
        receipt=guard.observe_response(encode(events()))
        self.assertEqual(receipt["total_tokens"],130)
        self.assertTrue(receipt["stop_before_next_request"])
        self.assertFalse(receipt["hard_pre_request_token_cap"])
        self.assertFalse(guard(raw,time.monotonic()+5))

    def test_unknown_usage_is_not_zero_and_blocks_next_request(self):
        guard=subscription.SubscriptionUsageGuard(max_tokens=1000,max_calls=4)
        raw=json.dumps({"model":subscription.MODEL,"store":False,"stream":True,"input":[]}).encode()
        self.assertTrue(guard(raw,time.monotonic()+5))
        receipt=guard.observe_response(b'data: incomplete\n\n')
        self.assertEqual(receipt["state"],"UNKNOWN")
        self.assertIsNone(receipt["observed_tokens"])
        self.assertFalse(guard(raw,time.monotonic()+5))


if __name__ == "__main__":
    unittest.main()
