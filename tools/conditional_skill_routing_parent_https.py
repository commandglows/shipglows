"""Prepared fixed HTTPS callback; launch authorization defaults to false.

No environment/credential lookup. A caller injects a parent-only credential after
separate launch approval. Offline tests inject a fake connection factory. The
stdlib HTTPS implementation is reachable only behind all explicit launch gates.
No redirect, retry, decompression or mutable endpoint selection is implemented.
"""
import hashlib
import http.client
import json
import re
import ssl
import threading
import time
from urllib.parse import urlsplit

from tools.conditional_skill_routing_parent_transport import TransportError, decoded, packed, sha


def require(ok, message):
    if not ok:
        raise TransportError(message)


def _stdlib_connection(host, port, timeout):
    return http.client.HTTPSConnection(host, port=port, timeout=timeout, context=ssl.create_default_context())


class PreparedHTTPSCallback:
    """Parent-owned callable for ParentBridge(callback_kind='live').

    Exact request bytes are forwarded unchanged. Required provider settings must
    already be present; no hidden prompt/body rewriting occurs. The requested
    maximum output tokens must fit both per-call and total token ceilings.
    Token reservation is pessimistic and never restored after failures/retries.
    Monetary/provider input-token accounting requires a separate selected-profile
    budget; this component makes no cost estimate or provider-retention claim.
    """
    def __init__(self, *, endpoint, model, account_label, required_settings,
                 launch_authorized=False, injected_credential=None,
                 max_calls=12, max_request_bytes=1024 * 1024,
                 max_response_bytes=1024 * 1024, total_request_bytes=12 * 1024 * 1024,
                 total_response_bytes=12 * 1024 * 1024, max_output_tokens=512,
                 total_output_tokens=6144, request_timeout=15.0, session_timeout=120.0,
                 connection_factory=None, approved_budget=None, verified_model_ceiling=None,
                 input_cost_budget_guard=None, auth_mode="api_key", injected_account_id=None):
        require(type(launch_authorized) is bool, "invalid launch authority")
        require(type(endpoint) is str, "fixed HTTPS endpoint required")
        parsed = urlsplit(endpoint)
        require(auth_mode in ("api_key", "chatgpt_subscription"), "unsupported authentication mode")
        subscription = auth_mode == "chatgpt_subscription"
        require(parsed.scheme == "https" and parsed.hostname and parsed.username is None
                and parsed.password is None and not parsed.query and not parsed.fragment
                and parsed.port in (None, 443) and re.fullmatch(r"[a-z0-9.-]+", parsed.hostname)
                and ((subscription and endpoint == "https://chatgpt.com/backend-api/codex/responses")
                     or (not subscription and parsed.path in ("/v1/responses", "/responses"))),
                "unsupported fixed HTTPS origin/path")
        require((subscription and type(injected_account_id) is str
                 and re.fullmatch(r"[A-Za-z0-9_.:-]{1,128}", injected_account_id))
                or (not subscription and injected_account_id is None), "invalid parent subscription account binding")
        require(type(model) is str and re.fullmatch(r"[A-Za-z0-9_.:/-]{1,128}", model), "named exact model required")
        require(type(account_label) is str and re.fullmatch(r"[A-Za-z0-9_.-]{1,64}", account_label), "nonsecret account label required")
        require(type(required_settings) is dict and required_settings
                and set(required_settings) <= {"store", "stream", "reasoning", "text", "temperature", "top_p", "service_tier"}
                and required_settings.get("store") is False and type(required_settings.get("stream")) is bool,
                "explicit settings with store:false and named stream posture required")
        # Canonical serialize/decode to reject nonfinite/unserializable settings.
        required_settings = decoded(packed(required_settings))
        require(injected_credential is None or (type(injected_credential) is str and injected_credential
                and len(injected_credential) <= 4096 and all(33 <= ord(c) <= 126 for c in injected_credential)), "invalid injected credential")
        for limit in (max_calls, max_request_bytes, max_response_bytes, total_request_bytes,
                      total_response_bytes, max_output_tokens, total_output_tokens):
            require(type(limit) is int and limit > 0, "positive budget required")
        for limit in (request_timeout, session_timeout):
            require(type(limit) in (int, float) and 0 < limit <= 300, "bounded deadline required")
        self.endpoint, self.host, self.path = endpoint, parsed.hostname, parsed.path
        self.auth_mode, self.account_id = auth_mode, injected_account_id
        self.model, self.account_label = model, account_label
        self.settings = required_settings
        self.launch_authorized, self.credential = launch_authorized, injected_credential
        self.connection_factory = connection_factory or _stdlib_connection
        self.max_calls, self.max_request_bytes, self.max_response_bytes = max_calls, max_request_bytes, max_response_bytes
        self.total_request_limit, self.total_response_limit = total_request_bytes, total_response_bytes
        self.max_output_tokens, self.total_output_limit = max_output_tokens, total_output_tokens
        self.request_timeout = request_timeout
        self.deadline = time.monotonic() + session_timeout
        self.calls = self.request_bytes = self.response_bytes = self.output_tokens_reserved = 0
        self.receipts = []
        # Parent memory only. The evaluator consumes these before cleanup;
        # request auth headers/account identifiers are never stored here.
        self.raw_exchanges = []
        self.lock = threading.Lock()
        require(approved_budget is None or (type(approved_budget) is dict
                and set(approved_budget) == {"review_id", "max_calls", "max_request_bytes", "max_response_bytes",
                     "total_request_bytes", "total_response_bytes", "max_output_tokens", "total_output_tokens",
                     "request_timeout", "session_timeout"}
                and type(approved_budget["review_id"]) is str and approved_budget["review_id"]
                and all(type(approved_budget[k]) in (int, float) and type(approved_budget[k]) is not bool
                        and approved_budget[k] == v for k, v in {
                    "max_calls": max_calls, "max_request_bytes": max_request_bytes,
                    "max_response_bytes": max_response_bytes, "total_request_bytes": total_request_bytes,
                    "total_response_bytes": total_response_bytes, "max_output_tokens": max_output_tokens,
                    "total_output_tokens": total_output_tokens, "request_timeout": request_timeout,
                    "session_timeout": session_timeout}.items())), "approved budget must exactly match effective limits")
        require(verified_model_ceiling is None or (type(verified_model_ceiling) is dict
                and set(verified_model_ceiling) == {"model", "max_output_tokens", "evidence_sha256", "review_id"}
                and verified_model_ceiling["model"] == model
                and type(verified_model_ceiling["max_output_tokens"]) is int
                and 0 < verified_model_ceiling["max_output_tokens"] <= max_output_tokens
                and type(verified_model_ceiling["evidence_sha256"]) is str
                and re.fullmatch(r"[0-9a-f]{64}", verified_model_ceiling["evidence_sha256"])
                and type(verified_model_ceiling["review_id"]) is str and verified_model_ceiling["review_id"]),
                "reviewed exact model output ceiling required")
        require(input_cost_budget_guard is None or callable(input_cost_budget_guard), "trusted input/cost admission guard required")
        self.verified_model_ceiling = decoded(packed(verified_model_ceiling)) if verified_model_ceiling else None
        self.input_cost_budget_guard = input_cost_budget_guard
        self.approved_budget = json.loads(json.dumps(approved_budget)) if approved_budget is not None else None

    def __call__(self, raw, caller_deadline):
        with self.lock:
            connection, response = None, None
            chunks, captured = [], False
            record = {"endpoint": self.endpoint, "model": self.model, "account_label": self.account_label,
                      "auth_mode": self.auth_mode, "api_billing_route": self.auth_mode == "api_key",
                      "launch_authorized": self.launch_authorized, "request_sha256": sha(raw) if type(raw) is bytes else None,
                      "request_bytes": len(raw) if type(raw) is bytes else None,
                      "credential_in_receipt": False, "network_started": False, "response_released": False}
            try:
                require(self.launch_authorized, "HTTPS launch not authorized")
                require(self.credential is not None, "parent-only launch credential not injected")
                require(self.approved_budget is not None, "named approved launch budget missing")
                record["budget_review_id"] = self.approved_budget["review_id"]
                require(type(caller_deadline) in (int, float), "caller deadline required")
                deadline = min(caller_deadline, self.deadline, time.monotonic() + self.request_timeout)
                require(time.monotonic() < deadline, "HTTPS deadline expired")
                self.calls += 1
                require(self.calls <= self.max_calls, "HTTPS call budget")
                require(type(raw) is bytes and len(raw) <= self.max_request_bytes
                        and self.request_bytes + len(raw) <= self.total_request_limit, "HTTPS request body budget")
                self.request_bytes += len(raw)
                body = decoded(raw)
                require(type(body) is dict and body.get("model") == self.model, "request model differs from frozen profile")
                require(not body.get("previous_response_id"), "opaque provider history forbidden")
                for key, expected in self.settings.items():
                    require(key in body and type(body[key]) is type(expected) and packed(body[key]) == packed(expected),
                            "request setting differs from frozen profile: " + key)
                subscription_observed = self.auth_mode == "chatgpt_subscription"
                if subscription_observed:
                    require(callable(self.input_cost_budget_guard)
                            and callable(getattr(self.input_cost_budget_guard, "observe_response", None)),
                            "subscription observation/quota guard required")
                    require(self.input_cost_budget_guard(raw, deadline) is True, "subscription quota admission refused")
                tokens = body.get("max_output_tokens")
                if subscription_observed and "max_output_tokens" not in body:
                    # The subscription catalog did not expose an enforceable
                    # output cap. Do not substitute the separately billed API's
                    # model card or claim a hard token ceiling. Observe usage,
                    # preserve an overrun, and stop before another request.
                    tokens = None
                    record["reservation_source"] = "subscription_observed_usage_only"
                    record["hard_token_cap_available"] = False
                elif "max_output_tokens" not in body:
                    require(self.verified_model_ceiling is not None, "missing output cap requires separately verified model ceiling")
                    require(self.input_cost_budget_guard is not None, "missing output cap launch blocked pending reviewed input/cost enforcement")
                    # Guard owns actual tokenizer/pricing/profile ceilings; this
                    # transport neither estimates prices nor mutates the body.
                    require(self.input_cost_budget_guard(raw, deadline) is True, "reviewed input/cost admission refused")
                    tokens = self.verified_model_ceiling["max_output_tokens"]
                    record["reservation_source"] = "verified_model_ceiling"
                    record["model_ceiling_review_id"] = self.verified_model_ceiling["review_id"]
                else:
                    record["reservation_source"] = "explicit_request_cap"
                require(tokens is None and subscription_observed or type(tokens) is int and 0 < tokens <= self.max_output_tokens
                        and self.output_tokens_reserved + tokens <= self.total_output_limit,
                        "explicit max_output_tokens budget required")
                if tokens is not None:
                    self.output_tokens_reserved += tokens
                record["output_tokens_reserved"] = tokens
                remaining = deadline - time.monotonic()
                require(remaining > 0, "HTTPS deadline expired")
                # This is the only point where the real default factory could run.
                connection = self.connection_factory(self.host, 443, remaining)
                record["network_started"] = True
                headers = {"Content-Type": "application/json", "Accept-Encoding": "identity",
                           "Authorization": "Bearer " + self.credential, "Content-Length": str(len(raw))}
                if self.auth_mode == "chatgpt_subscription":
                    headers.update({"ChatGPT-Account-ID": self.account_id, "originator": "codex_cli_rs",
                                    "User-Agent": "codex_cli_rs/0.160.1"})
                connection.request("POST", self.path, body=raw, headers=headers)
                response = connection.getresponse()
                status = response.status
                require(type(status) is int and 100 <= status <= 599, "invalid HTTPS response status")
                require(not 300 <= status <= 399, "HTTPS redirect refused")
                content_length = response.getheader("Content-Length")
                if content_length is not None:
                    require(re.fullmatch(r"[0-9]{1,12}", content_length) is not None, "invalid HTTPS content length")
                    require(int(content_length) <= self.max_response_bytes
                            and self.response_bytes + int(content_length) <= self.total_response_limit,
                            "HTTPS declared response budget")
                require(response.getheader("Content-Encoding", "identity").lower() == "identity", "compressed HTTPS body refused")
                headers = {}
                for name in ("content-type", "x-request-id", "retry-after"):
                    value = response.getheader(name)
                    if value is not None:
                        require(type(value) is str and len(value) <= 256 and all(32 <= ord(c) <= 126 for c in value), "invalid sanitized HTTPS header")
                        headers[name] = value
                chunks = []
                observed = 0
                while True:
                    require(time.monotonic() < deadline, "HTTPS body deadline")
                    if getattr(connection, "sock", None) is not None:
                        connection.sock.settimeout(deadline - time.monotonic())
                    chunk = response.read(min(65536, self.max_response_bytes - observed + 1))
                    require(type(chunk) is bytes, "nonbytes HTTPS body")
                    if not chunk:
                        break
                    observed += len(chunk)
                    self.response_bytes += len(chunk)
                    record["observed_response_bytes"] = observed
                    chunks.append(chunk)
                    record["partial_response_sha256"] = sha(b"".join(chunks))
                    require(observed <= self.max_response_bytes and self.response_bytes <= self.total_response_limit, "HTTPS observed response budget")
                require(content_length is None or observed == int(content_length), "partial HTTPS body/content length mismatch")
                require(time.monotonic() <= deadline, "HTTPS response deadline")
                result = b"".join(chunks)
                self.raw_exchanges.append({"request": raw, "response": result,
                    "response_status": status, "response_complete": True})
                captured = True
                if subscription_observed:
                    record["subscription_usage"] = self.input_cost_budget_guard.observe_response(result)
                require(headers.get("content-type", "").split(";", 1)[0] in ("application/json", "text/event-stream"), "unsupported HTTPS content type")
                record.update({"status": "returned", "response_status": status, "response_bytes": len(result),
                               "response_sha256": sha(result), "sanitized_headers": headers, "response_released": True})
                self.receipts.append(record)
                return {"status": status, "headers": headers, "body": result}
            except Exception as error:
                if record["network_started"] and not captured:
                    self.raw_exchanges.append({"request": raw, "response": b"".join(chunks),
                        "response_status": response.status if response is not None else None,
                        "response_complete": False})
                # Never retain error text: TLS/provider exceptions can include auth.
                record.update({"status": "refused", "exception_type": type(error).__name__,
                               "exception_sha256": sha(str(error).encode("utf-8", errors="replace"))})
                self.receipts.append(record)
                raise TransportError("fixed HTTPS parent transport refused; details hash-only") from None
            finally:
                if response is not None:
                    try:
                        response.close()
                    except Exception as error:
                        self.receipts.append({"status": "response_close_error", "exception_type": type(error).__name__,
                                              "exception_sha256": sha(str(error).encode("utf-8", errors="replace"))})
                if connection is not None:
                    try:
                        connection.close()
                    except Exception as error:
                        self.receipts.append({"status": "connection_close_error", "exception_type": type(error).__name__,
                                              "exception_sha256": sha(str(error).encode("utf-8", errors="replace"))})

    def durable_receipts(self):
        return packed({"receipts": self.receipts, "calls": self.calls, "request_bytes": self.request_bytes,
                       "response_bytes": self.response_bytes,
                       "output_tokens_reserved": None if self.auth_mode == "chatgpt_subscription" else self.output_tokens_reserved,
                       "limits": ["No redirects/retries/decompression; fixed host/path/model/settings",
                                  "No credential lookup; injected authorization stays in parent request only",
                                  "No actual provider/model/account selection inferred or network proof from fake tests",
                                  "Output reservation is a ceiling, not actual usage/cost/model latency",
                                  "Missing request cap reserves verified model ceiling only after trusted input/cost guard admission",
                                  "No verified ceiling, tokenizer, price or input/cost guard supplied by default; live CLI launch blocked"]})
