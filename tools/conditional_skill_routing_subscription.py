"""Trusted-parent ChatGPT subscription access. Never sends credentials to a subject.

Uses the existing Codex ChatGPT session and the documented Codex gateway route.
Does not read OPENAI_API_KEY, purchase credits, refresh/login, or generate a model
response from the CLI below. Expired sessions fail closed and need native login.
"""
import argparse
import base64
from dataclasses import dataclass
import hashlib
import http.client
import json
from pathlib import Path
import re
import threading
import time

from tools.conditional_skill_routing_parent_https import PreparedHTTPSCallback

ENDPOINT = "https://chatgpt.com/backend-api/codex/responses"
MODEL = "gpt-6-luna"


class SubscriptionAuthError(ValueError):
    pass


@dataclass(frozen=True, repr=False)
class SubscriptionCredential:
    access_token: str
    account_id: str
    expires_at: int

    def __repr__(self):
        return "<SubscriptionCredential redacted>"


def load_credential(auth_file=None, *, minimum_lifetime=330, now=None):
    """Read only the operator's existing session. Never log token/account claims."""
    try:
        path = Path(auth_file) if auth_file is not None else Path.home() / ".codex/auth.json"
        if path.is_symlink() or not path.is_file():
            raise ValueError()
        value = json.loads(path.read_bytes())
        if value.get("auth_mode") != "chatgpt":
            raise ValueError()
        tokens = value["tokens"]
        token, account = tokens["access_token"], tokens["account_id"]
        if not (type(token) is str and 0 < len(token) <= 4096
                and all(33 <= ord(c) <= 126 for c in token)
                and type(account) is str and re.fullmatch(r"[A-Za-z0-9_.:-]{1,128}", account)):
            raise ValueError()
        parts = token.split(".")
        if len(parts) != 3:
            raise ValueError()
        claims = json.loads(base64.urlsafe_b64decode(parts[1] + "=" * (-len(parts[1]) % 4)))
        expires = claims["exp"]
        if type(expires) is not int or type(minimum_lifetime) is not int or minimum_lifetime < 0:
            raise ValueError()
        # This local expiration check is conservative metadata, not JWT signature
        # verification. The authenticated Codex service verifies the actual token.
        if expires <= (time.time() if now is None else now) + minimum_lifetime:
            raise ValueError()
        binding = claims.get("https://api.openai.com/auth", {}).get("chatgpt_account_id")
        if binding is not None and binding != account:
            raise ValueError()
        return SubscriptionCredential(token, account, expires)
    except Exception:
        raise SubscriptionAuthError("Existing ChatGPT session unavailable, expired or inconsistent; use native Codex sign-in.") from None


class SubscriptionUsageGuard:
    """Observe server usage, retain overruns/UNKNOWN, then stop before another call.

    Request/count/deadline/byte bounds are hard transport limits. This guard is
    explicitly not a pre-request token cap or an estimate of remaining credits.
    """
    def __init__(self, *, max_tokens, max_calls, model=MODEL):
        if type(max_tokens) is not int or max_tokens <= 0 or type(max_calls) is not int or max_calls <= 0:
            raise ValueError("positive observed-usage and request limits required")
        self.max_tokens, self.max_calls, self.model = max_tokens, max_calls, model
        self.tokens, self.calls, self.blocked, self.pending = 0, 0, False, False
        self.usage_complete = True
        self.lock = threading.Lock()

    def __call__(self, raw, deadline):
        with self.lock:
            try:
                body = json.loads(raw)
                valid = (type(body) is dict and body.get("model") == self.model
                    and body.get("store") is False and body.get("stream") is True
                    and not body.get("previous_response_id") and time.monotonic() < deadline)
            except Exception:
                valid = False
            if not valid or self.pending or self.blocked or self.calls >= self.max_calls or self.tokens >= self.max_tokens:
                return False
            self.calls += 1
            self.pending = True
            return True

    def observe_response(self, raw):
        from tools.conditional_skill_routing_live_stream import completed_response
        with self.lock:
            self.pending = False
            try:
                usage = completed_response(raw).get("usage")
                if type(usage) is not dict or any(type(usage.get(k)) is not int or usage[k] < 0
                        for k in ("input_tokens", "output_tokens", "total_tokens")):
                    raise ValueError()
                if usage["total_tokens"] != usage["input_tokens"] + usage["output_tokens"]:
                    raise ValueError()
                self.tokens += usage["total_tokens"]
                self.blocked = self.tokens >= self.max_tokens
                return {"state": "observed", "input_tokens": usage["input_tokens"],
                    "output_tokens": usage["output_tokens"], "total_tokens": usage["total_tokens"],
                    "cumulative_observed_tokens": self.tokens, "stop_before_next_request": self.blocked,
                    "hard_pre_request_token_cap": False, "remaining_subscription_quota": "UNKNOWN"}
            except Exception:
                self.blocked, self.usage_complete = True, False
                return {"state": "UNKNOWN", "observed_tokens": None,
                    "stop_before_next_request": True, "hard_pre_request_token_cap": False}


def make_callback(credential, *, model, settings, approved_budget,
                  input_guard, verified_model_ceiling=None, connection_factory=None):
    """Explicit subscription-only factory; no alternative endpoint/auth fallback."""
    if type(credential) is not SubscriptionCredential or model != MODEL:
        raise SubscriptionAuthError("Exact operator-approved subscription model/session required.")
    if credential.expires_at <= time.time() + approved_budget["session_timeout"] + 15:
        raise SubscriptionAuthError("ChatGPT session expires before the bounded observation.")
    limits = {key: value for key, value in approved_budget.items() if key != "review_id"}
    return PreparedHTTPSCallback(endpoint=ENDPOINT, model=model,
        account_label="operator-chatgpt-subscription", required_settings=settings,
        auth_mode="chatgpt_subscription", injected_account_id=credential.account_id,
        injected_credential=credential.access_token, launch_authorized=True,
        approved_budget=approved_budget, verified_model_ceiling=verified_model_ceiling,
        input_cost_budget_guard=input_guard, connection_factory=connection_factory, **limits)


def catalog_metadata(credential):
    """Read the selected model's subscription catalog metadata; no generation."""
    connection = None
    try:
        connection = http.client.HTTPSConnection("chatgpt.com", timeout=25)
        connection.request("GET", "/backend-api/codex/models?client_version=0.160.1", headers={
            "Authorization": "Bearer " + credential.access_token,
            "ChatGPT-Account-ID": credential.account_id, "originator": "codex_cli_rs",
            "User-Agent": "codex_cli_rs/0.160.1", "Accept-Encoding": "identity"})
        response = connection.getresponse()
        raw = response.read(2 * 1024 * 1024 + 1)
        if len(raw) > 2 * 1024 * 1024:
            raise ValueError()
        result = {"http_status": response.status, "model_calls": 0,
                  "response_sha256": hashlib.sha256(raw).hexdigest(), "api_fallback": False}
        if response.status == 200:
            values = json.loads(raw).get("models", [])
            selected = [v for v in values if v.get("slug", v.get("id")) == MODEL]
            result["selected_model_available"] = len(selected) == 1
            if selected:
                result["model"] = {key: selected[0].get(key) for key in
                    ("slug", "context_window", "max_output_tokens", "default_reasoning_level")}
        return result
    except Exception:
        raise SubscriptionAuthError("Subscription catalog check failed; private diagnostics suppressed.") from None
    finally:
        if connection is not None:
            connection.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", action="store_true")
    args = parser.parse_args()
    try:
        credential = load_credential()
        result = {"auth_mode": "chatgpt_subscription", "session_valid": True,
                  "credentials_in_output": False, "model_calls": 0}
        if args.catalog:
            result["catalog"] = catalog_metadata(credential)
        print(json.dumps(result))
        return 0
    except SubscriptionAuthError:
        print(json.dumps({"session_valid": False, "private_diagnostics_suppressed": True, "model_calls": 0}))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
