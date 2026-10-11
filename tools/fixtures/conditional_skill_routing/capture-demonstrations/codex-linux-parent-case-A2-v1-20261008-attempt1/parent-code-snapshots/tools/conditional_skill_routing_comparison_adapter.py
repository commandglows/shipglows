"""Host-owned H/A/B/S adapter with exact Responses callback delivery.

No subject/model/provider launch. Existing assemblers and confined worker remain
authoritative. This adapter binds their callbacks to actual app-server IDs and
accepts delivery only from captured complete Responses request bytes. It does not
authenticate the caller's capture or establish hidden model retention/AC5.
"""
import copy
import hashlib
import json
import threading
import time

from tools import conditional_skill_routing_runner as runner
from tools.conditional_skill_routing_responses_accounting import ResponsesAccounting, AccountingError, _decode


class AdapterError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise AdapterError(message)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def encoded(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


def prepare_tuning(manifest, case, *, thread_id, turn_id, namespace=None):
    """Public tuning assemblers only; no evaluator expectations exported."""
    family = case.get("family")
    if family in ("discussion", "core_audit"):
        prepared = runner.prepare_tuning_readonly_broker(manifest, case)
    elif family == "bounded_docs":
        prepared = runner.prepare_tuning_document_conversation(manifest, case)
    elif family == "private_public":
        prepared = runner.prepare_tuning_private_conversation(manifest, case)
    else:
        raise AdapterError("unsupported family")
    return ComparisonAdapter(prepared, thread_id=thread_id, turn_id=turn_id, namespace=namespace)


class ComparisonAdapter:
    """One case/thread/turn, serialized host callbacks, conservative retirement.

    A distinct evaluator may construct a prepared held-out adapter privately and
    pass it here; this class never reads an evaluator file or expected answers.
    The host must send conditional turns and then capture their exact delivery.
    """
    def __init__(self, prepared, *, thread_id, turn_id, namespace=None):
        require(type(thread_id) is str and thread_id and type(turn_id) is str and turn_id,
                "real thread and turn IDs required")
        self.prepared = prepared
        self.mcp = prepared if isinstance(prepared, runner.FixtureMcpBroker) else prepared.mcp
        require(isinstance(self.mcp, runner.FixtureMcpBroker) and self.mcp.observation is not None,
                "observed prepared fixture broker required")
        self.thread_id, self.turn_id = thread_id, turn_id
        self.mcp.broker.thread_id, self.mcp.broker.turn_id = thread_id, turn_id
        require(namespace is None or type(namespace) is str and namespace, "invalid external namespace")
        self.namespace = namespace
        self.lock = threading.RLock()
        self.retired = False
        self.callbacks, self.receipts, self.refusals, self.responses = {}, [], [], []
        self.consent_epoch = 0
        self.turn_ids = {turn_id}
        self.response_ids, self.assistant_turns = set(), set()
        self.transitions = []
        self.pending_response_request = None
        self.pending_turns, self.delivered_turns = {}, set()
        self.schema = self.mcp.handle({"jsonrpc": "2.0", "id": "host-schema-inventory",
                                      "method": "tools/list", "params": {}})["result"]["tools"]
        self.schema_hash = digest(encoded(self.schema))
        self.tools = {row["name"] for row in self.schema}
        resources = {rid: row["text"] for rid, row in self.mcp.broker.bundle["instructions"].items()}
        injections = [{"id": row["id"], "text": row["text"],
                       "roles": ["instructions", "system", "developer", "user"]}
                      for row in self.mcp.broker.bundle["injections"]]
        self.accounting = ResponsesAccounting(resources=resources, injections=injections)
        # Existing MCP code uses local IDs internally. Translate BEFORE worker
        # dispatch, so worker observation/callback state uses actual call/thread/
        # turn IDs. Private and released-action MCP IDs are actual call IDs too.
        self._active_callback = None
        self._original_dispatch = self.mcp.observation.dispatch
        self.mcp.observation.dispatch = self._bound_dispatch

    def bind_thread(self, thread_id):
        """Host supplies the actual thread/start ID before any request/callback."""
        with self.lock:
            require(not self.retired and not self.receipts and not self.callbacks and not self.responses,
                    "thread rebinding after observation forbidden")
            require(type(thread_id) is str and thread_id, "actual thread ID required")
            self.thread_id = self.mcp.broker.thread_id = thread_id

    def begin_turn(self, turn_id):
        """Trusted host transition from actual turn/start; never reset authority."""
        with self.lock:
            require(not self.retired, "turn binding retired")
            require(type(turn_id) is str and turn_id and turn_id not in self.turn_ids,
                    "actual fresh turn ID required")
            require(not any(not row["delivered"] for row in self.callbacks.values()),
                    "next turn precedes exact pending callback delivery")
            require(not self.receipts or self.turn_id in self.assistant_turns,
                    "next turn precedes completed assistant response")
            self.transitions.append({"previous_turn_id": self.turn_id, "turn_id": turn_id,
                                     "received_ns": time.monotonic_ns()})
            self.turn_ids.add(turn_id)
            self.turn_id = self.mcp.broker.turn_id = turn_id

    def _retire_capture(self, reason, raw):
        # No recovery on the same adapter: a fresh independently prepared binder
        # must reacquire sources/consent. Preserve callbacks and refusal evidence.
        self.accounting.invalidate(reason, digest(raw) if type(raw) is bytes else digest(encoded(str(raw))))
        self.prepared.context_loss()
        self.retired = True
        self.pending_turns.clear()
        self.delivered_turns.clear()
        self.pending_response_request = None
        self.mcp.broker.bundle["grants"] = []

    def dynamic_tools(self):
        if self.namespace is None:
            return [{"type": "function", **copy.deepcopy(row)} for row in self.schema]
        return [{"type": "namespace", "name": self.namespace,
                 "description": "Case-owned synthetic fixtures only; no native tools.",
                 "tools": [{"type": "function", **copy.deepcopy(row)} for row in self.schema]}]

    def _bound_dispatch(self, parameters):
        require(self._active_callback is not None, "worker dispatch lacks actual app-server callback")
        bound = copy.deepcopy(parameters)
        bound.update(callId=self._active_callback, threadId=self.thread_id,
                     turnId=self.turn_id, namespace=runner.CODEX_NAMESPACE)
        return self._original_dispatch(bound)

    def _failure(self, boundary, error, *, raw=None, call_id=None):
        row = {"boundary": boundary, "call_id": call_id, "error": str(error),
               "error_sha256": digest(str(error).encode()), "received_ns": time.monotonic_ns(),
               "raw_sha256": digest(raw) if type(raw) is bytes else None,
               "provider_delivery": "not_verified"}
        self.refusals.append(row)
        return row

    def dispatch(self, parameters):
        """App-server item/tool/call params -> exactly one case-owned callback.

        Refusals return a captured error content item; foreign binding errors
        raise before dispatch. Every attempted ID is consumed to prevent replay.
        """
        with self.lock:
            raw = encoded(parameters)
            call_id = parameters.get("callId") if type(parameters) is dict else None
            try:
                require(not self.retired, "callback binding retired by context loss")
                allowed = {"arguments", "callId", "namespace", "threadId", "tool", "turnId"}
                require(type(parameters) is dict and allowed - {"namespace"} <= set(parameters) <= allowed,
                        "invalid dynamic callback shape")
                require(parameters["threadId"] == self.thread_id and parameters["turnId"] == self.turn_id
                        and parameters.get("namespace") == self.namespace, "foreign callback binding")
                require(type(call_id) is str and call_id and call_id not in self.callbacks, "invalid/reused callback ID")
                require(type(parameters["tool"]) is str and parameters["tool"] and type(parameters["arguments"]) is dict,
                        "invalid callback name or arguments")
            except AdapterError as error:
                self._failure("dynamic_callback_admission", error, raw=raw, call_id=call_id)
                raise
            row = {"call_id": call_id, "thread_id": self.thread_id, "turn_id": self.turn_id,
                   "tool": parameters["tool"], "arguments": copy.deepcopy(parameters["arguments"]),
                   "arguments_sha256": digest(encoded(parameters["arguments"])), "request_sha256": digest(raw),
                   "callback_ns": time.monotonic_ns(), "delivered": False, "success": False}
            row["consent_epoch"] = self.consent_epoch
            self.callbacks[call_id] = row
            self._active_callback = call_id
            try:
                require(parameters["tool"] in self.tools,
                        "nonbroker native or unknown tool refused before dispatch")
                require(all(turn["id"] in self.delivered_turns for turn in self.mcp.broker.bundle["turns"]),
                        "callback precedes exact initial/conditional turn delivery")
                if row["tool"] == "private_record_read":
                    for prerequisite in ("private_status", "private_capability"):
                        prior = [previous for previous in self.callbacks.values()
                                 if previous["tool"] == prerequisite and previous["consent_epoch"] == self.consent_epoch]
                        require(prior and prior[-1]["success"] and prior[-1]["delivered"],
                                "private read requires exact delivered current status and capability")
                request = {"jsonrpc": "2.0", "id": call_id, "method": "tools/call",
                           "params": {"name": parameters["tool"], "arguments": parameters["arguments"]}}
                response = (self.prepared.handle_tool(request) if hasattr(self.prepared, "handle_tool")
                            else self.mcp.handle(request))
                result = response["result"]
                require(type(result.get("content")) is list and len(result["content"]) == 1
                        and result["content"][0].get("type") == "text"
                        and type(result["content"][0].get("text")) is str, "unsupported callback content")
                content, success = result["content"][0]["text"], result.get("isError") is False
            except (runner.RunnerError, AdapterError, OSError) as error:
                self._failure("case_callback", error, raw=raw, call_id=call_id)
                content, success = encoded({"error": str(error)}).decode(), False
            finally:
                self._active_callback = None
            row.update(content=content, content_sha256=digest(content.encode()), success=success,
                       completed_ns=time.monotonic_ns())
            if not success and not any(item.get("call_id") == call_id for item in self.refusals):
                self._failure("worker_refusal", content, call_id=call_id)
            returned = self.mcp.broker.returned_contents.get(call_id)
            if row["tool"] == "instruction_read" and success and returned is not None:
                result = returned["worker_result"]["result"]
                spans, offset = [], len("<instruction>\n")
                for span in result["delivered_spans"]:
                    spans.append({"source_start": span["start"], "source_end": span["end"], "output_start": offset})
                    offset += span["end"] - span["start"]
                self.accounting.register_read_spans(call_id, result["resource_id"], content, spans)
            return {"success": success, "contentItems": [{"type": "inputText", "text": content}]}

    def _deliver_callback(self, call_id):
        row = self.callbacks[call_id]
        key = ("str", call_id)
        if row["success"]:
            if key in self.mcp.action_deliveries:
                self.mcp.capture_action_delivery(call_id, row["content"])
            elif key in self.mcp.private_deliveries:
                self.mcp.capture_private_delivery(call_id, row["content"])
            elif call_id in self.mcp.broker.returned_contents:
                self.mcp.observation.capture(call_id, row["content"], reason="exact captured next Responses request")
        else:
            if call_id in self.mcp.broker.returned_contents:
                self.mcp.observation.capture(call_id, row["content"], reason="exact captured refusal result")
            for refusal in self.refusals:
                if refusal.get("call_id") == call_id:
                    refusal["provider_delivery"] = "exact_captured_next_responses_request"
        row["delivered"] = True

    def observe_request(self, raw, *, label=""):
        """Validate all callback identities/bytes transactionally before delivery."""
        with self.lock:
            try:
                require(not self.retired, "request capture binding retired")
                request = _decode(raw)
                parts, calls = self.accounting._parts(request)
                pending = []
                for part in parts:
                    call_id = part.get("call_id")
                    if part.get("role") != "tool":
                        continue
                    require(call_id in self.callbacks, "function output lacks actual callback")
                    row, call = self.callbacks[call_id], calls[call_id]
                    names = (row["tool"],) if self.namespace is None else (row["tool"], self.namespace + "." + row["tool"])
                    require(call["name"] in names, "provider call tool differs from callback")
                    require(digest(encoded(_decode(next(item["arguments"] for item in request["input"]
                        if item.get("type") == "function_call" and item["call_id"] == call_id).encode()))) == row["arguments_sha256"],
                        "provider call arguments differ from callback")
                    require(part["text"] == row["content"], "complete callback output changed")
                    if not row["delivered"]:
                        pending.append(call_id)
                require(set(pending) == {cid for cid, row in self.callbacks.items() if not row["delivered"]}
                        and len(pending) == len(set(pending)),
                        "pending callback omitted or duplicated in immediately next model request")
                # Also verify each initial/conditional turn as exact text in its
                # native request role before granting the conversation delivery.
                deliveries = []
                last_position = -1
                missing_earlier_turn = False
                for turn in self.mcp.broker.bundle["turns"]:
                    if turn["id"] in self.delivered_turns:
                        continue
                    matches = [(index, part) for index, part in enumerate(parts)
                               if part.get("role") == turn["role"] and part.get("text") == turn["content"]]
                    require(len(matches) <= 1, "ambiguous duplicated fixture turn text")
                    if matches:
                        require(not missing_earlier_turn, "later fixture turn supplied before earlier turn")
                        require(matches[0][0] > last_position, "fixture turn delivery order changed")
                        last_position = matches[0][0]
                        deliveries.append(turn)
                    else:
                        missing_earlier_turn = True
                receipt = self.accounting.capture_request(raw, label=label)
                for turn in deliveries:
                    if hasattr(self.prepared, "capture_turn_delivery"):
                        self.prepared.capture_turn_delivery(turn["id"], turn["content"])
                    else:
                        self.mcp.observation.release_initial_turn(turn["id"], turn["content"])
                    self.delivered_turns.add(turn["id"])
                    self.pending_turns.pop(turn["id"], None)
                for call_id in pending:
                    self._deliver_callback(call_id)
                summary = {"label": label, "request_sha256": digest(raw), "received_ns": time.monotonic_ns(),
                           "newly_delivered_callbacks": pending, "delivered_turns": [turn["id"] for turn in deliveries],
                           "accounting": receipt, "capture_authentication": "not_verified"}
                self.receipts.append(summary)
                self.pending_response_request = {"label": label, "turn_id": self.turn_id, "request_sha256": digest(raw)}
                return copy.deepcopy(summary)
            except (AdapterError, AccountingError, runner.RunnerError, ValueError, TypeError) as error:
                self._failure("responses_request_capture", error, raw=raw)
                self._retire_capture("rejected Responses request", raw)
                raise AdapterError(str(error)) from error

    def observe_assistant_response(self, raw, *, label=""):
        """Capture a complete Responses response, then exact consent/draft routing.

        The caller retains raw SSE/transport chunks separately and supplies its
        completed response object bytes. Never infer a grant from substrings.
        """
        with self.lock:
            try:
                require(not self.retired, "assistant response binding retired")
                response = _decode(raw)
                require(type(response) is dict and response.get("status") == "completed"
                        and type(response.get("output")) is list, "completed Responses object required")
                require(self.pending_response_request is not None
                        and self.pending_response_request["turn_id"] == self.turn_id
                        and (not label or label == self.pending_response_request["label"]),
                        "assistant response lacks captured current request correlation")
                response_id = response.get("id")
                require(type(response_id) is str and response_id and response_id not in self.response_ids,
                        "missing/replayed completed response ID")
                require(self.turn_id not in self.assistant_turns, "completed assistant response replayed in current turn")
                self.response_ids.add(response_id)
                texts = []
                for item in response["output"]:
                    require(type(item) is dict, "nonobject assistant response item")
                    if item.get("type") != "message":
                        continue
                    require(item.get("role") == "assistant" and type(item.get("content")) is list, "invalid assistant response")
                    blocks = item["content"]
                    require(all(type(block) is dict and block.get("type") == "output_text" and type(block.get("text")) is str for block in blocks),
                            "nontext assistant response")
                    texts.append("".join(block["text"] for block in blocks))
                released = []
                for content in texts:
                    self.responses.append({"content": content, "content_sha256": digest(content.encode()),
                                           "raw_sha256": digest(raw), "label": label, "received_ns": time.monotonic_ns()})
                    if isinstance(self.prepared, runner.ConditionalFixtureConversation):
                        collector = self.prepared.collector
                        arguments = None
                        if content == collector.approval_question():
                            target_reads = [row for row in self.callbacks.values() if row["tool"] == "fixture_read"
                                            and row["arguments"].get("target") == collector.target and row["delivered"] and row["success"]]
                            require(bool(target_reads), "approval request precedes captured target read delivery")
                            arguments = {"target": collector.target, "old": collector.old, "new": collector.new,
                                         "proof_checks": ["Old phrase absent", "New phrase occurs once", "All unrelated bytes identical"],
                                         "request_approval": True}
                        turn = self.prepared.submit_response(content, approval_request=arguments)
                        if turn is not None:
                            self.pending_turns[turn["id"]] = turn
                            released.append(copy.deepcopy(turn))
                    elif isinstance(self.prepared, runner.PrivateFixtureConversation):
                        gate = self.mcp.private_gate
                        if content == gate.grant_question() and not gate.granted:
                            arguments = {"namespace": gate.namespace, "operation": "read", "resource_id": gate.resource_id, "request_grant": True}
                            turn = self.prepared.submit_grant_request(content, arguments)
                            self.consent_epoch += 1
                            self.pending_turns[turn["id"]] = turn
                            released.append(copy.deepcopy(turn))
                        elif gate.receipts:
                            self.prepared.submit_draft_for_check(content)
                        else:
                            self.mcp.observation.capture_response(content)
                    else:
                        self.mcp.observation.capture_response(content)
                self.assistant_turns.add(self.turn_id)
                self.pending_response_request = None
                return {"released_turns": released, "captured_messages": len(texts), "raw_sha256": digest(raw)}
            except (AdapterError, AccountingError, runner.RunnerError, ValueError, TypeError) as error:
                self._failure("assistant_response_capture", error, raw=raw)
                self._retire_capture("rejected complete assistant response", raw)
                raise AdapterError(str(error)) from error

    def context_loss(self, reason, evidence_raw):
        with self.lock:
            require(type(evidence_raw) is bytes and evidence_raw, "context loss needs actual evidence bytes")
            self._retire_capture(reason, evidence_raw)
            return {"retired": True, "coverage": "UNKNOWN", "evidence_sha256": digest(evidence_raw),
                    "pending_callbacks_preserved": len([row for row in self.callbacks.values() if not row["delivered"]])}

    def summary(self):
        return {"schema_sha256": self.schema_hash, "tool_names": sorted(self.tools),
                "thread_id": self.thread_id, "turn_id": self.turn_id, "retired": self.retired,
                "turn_transitions": copy.deepcopy(self.transitions),
                "callbacks": [{key: value for key, value in row.items() if key not in ("content", "arguments")} for row in self.callbacks.values()],
                "refusals": copy.deepcopy(self.refusals), "provider_requests": len(self.receipts),
                "model_calls": 0, "limits": ["No model launched by this adapter", "Capture caller authentication not established",
                    "Proxy closure/host-secret isolation need independent runtime proof", "Hidden retention and semantic AC5 remain UNKNOWN"]}
