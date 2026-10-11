"""Standalone exact text accounting for captured Responses requests.

No campaign/runner integration or model retention claim. Offsets count Unicode
characters in decoded strings; request provenance hashes the original UTF8 bytes.
Callbacks must be independently observed before register_read is called. Hashes
bind supplied evidence; they do not authenticate its origin or exhaustiveness.
"""
import copy
import hashlib
import json


class AccountingError(ValueError):
    pass


def require(ok, message):
    if not ok:
        raise AccountingError(message)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def text_digest(value):
    return digest(value.encode("utf-8"))


def _pairs(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "duplicate JSON key")
        result[key] = value
    return result


def _decode(raw):
    require(type(raw) is bytes and raw, "request must be nonempty bytes")
    try:
        return json.loads(raw.decode("utf-8"), object_pairs_hook=_pairs,
                          parse_constant=lambda _: (_ for _ in ()).throw(AccountingError("nonfinite JSON")))
    except (UnicodeError, json.JSONDecodeError) as error:
        raise AccountingError("invalid UTF8/JSON request") from error


def _span(content, start, end):
    require(type(content) is str and type(start) is int and type(end) is int
            and 0 <= start < end <= len(content), "invalid nonempty character span")
    return {"start": start, "end": end, "characters": end - start,
            "sha256": text_digest(content[start:end])}


def _union(spans):
    result = []
    for start, end in sorted(spans):
        if result and start <= result[-1][1]:
            result[-1][1] = max(result[-1][1], end)
        else:
            result.append([start, end])
    return result


class ResponsesAccounting:
    """Known fixture delivery only; every capture reconstructs current coverage.

    injections: [{id, text, roles:[instructions|system|developer|user|assistant|tool]}].
    Register each real callback with its complete returned text and the exact
    source span inside it. Repeated history counts delivered text on each request
    but is not a new read invocation. A new call_id represents a reread.
    """
    def __init__(self, resources=None, injections=()):
        resources = {} if resources is None else resources
        require(type(resources) is dict and all(type(k) is str and k and type(v) is str and v
                                               for k, v in resources.items()), "invalid resources")
        self.resources = copy.deepcopy(resources)
        self.injections = []
        seen = set()
        for entry in injections:
            require(type(entry) is dict and set(entry) == {"id", "text", "roles"}
                    and type(entry["id"]) is str and entry["id"] and entry["id"] not in seen
                    and type(entry["text"]) is str and entry["text"]
                    and type(entry["roles"]) is list and entry["roles"]
                    and all(role in ("instructions", "system", "developer", "user", "assistant", "tool")
                            for role in entry["roles"]), "invalid known injection")
            seen.add(entry["id"])
            self.injections.append(copy.deepcopy(entry))
        self.reads = {}
        self.events = []
        self.receipts = []
        self.generation = 0
        self.coverage = {}
        self.delivered_calls = set()
        self.observed_calls = {}

    def register_read(self, call_id, resource_id, returned_text, *, source_start=0,
                      source_end=None, output_start=None):
        require(type(call_id) is str and call_id and call_id not in self.reads,
                "duplicate or invalid read call_id")
        require(type(resource_id) is str and resource_id in self.resources and type(returned_text) is str,
                "unknown resource or nontext callback")
        source = self.resources[resource_id]
        source_end = len(source) if source_end is None else source_end
        span = _span(source, source_start, source_end)
        fragment = source[source_start:source_end]
        if output_start is None:
            output_start = returned_text.find(fragment)
            require(output_start >= 0 and returned_text.find(fragment, output_start + 1) < 0,
                    "missing or ambiguous source span in callback")
        output_span = _span(returned_text, output_start, output_start + len(fragment))
        require(returned_text[output_span["start"]:output_span["end"]] == fragment,
                "callback span differs from source")
        self.reads[call_id] = {"resource_id": resource_id, "source_sha256": text_digest(source),
                              "source_span": span, "output_span": output_span,
                              "returned_text": returned_text, "callback_sha256": text_digest(returned_text)}
        return copy.deepcopy({k: v for k, v in self.reads[call_id].items() if k != "returned_text"})

    def invalidate(self, reason, evidence_sha256):
        require(type(reason) is str and reason and type(evidence_sha256) is str
                and len(evidence_sha256) == 64 and all(c in "0123456789abcdef" for c in evidence_sha256),
                "invalid context loss evidence")
        self.generation += 1
        self.coverage = {}
        event = {"type": "context_loss", "generation": self.generation, "reason": reason,
                 "evidence_sha256": evidence_sha256, "model_retention": "UNKNOWN"}
        self.events.append(event)
        return copy.deepcopy(event)

    def register_read_spans(self, call_id, resource_id, returned_text, fragments):
        """Bind one real callback to multiple explicitly located source fragments.

        Zero-length reads bind the callback but earn no normative coverage.
        Each fragment supplies source_start/source_end/output_start; framing
        and gaps remain counted in the full tool text, not as source delivery.
        """
        require(type(call_id) is str and call_id and call_id not in self.reads,
                "duplicate or invalid read call_id")
        require(type(resource_id) is str and resource_id in self.resources and type(returned_text) is str
                and type(fragments) is list and 0 < len(fragments) <= 64,
                "invalid multi-span read")
        source = self.resources[resource_id]
        previous_source = previous_output = 0
        verified = []
        for fragment in fragments:
            require(type(fragment) is dict and set(fragment) == {"source_start", "source_end", "output_start"},
                    "invalid fragment keys")
            start, end, output = (fragment[key] for key in ("source_start", "source_end", "output_start"))
            require(all(type(value) is int for value in (start, end, output))
                    and previous_source <= start <= end <= len(source)
                    and previous_output <= output <= output + end - start <= len(returned_text),
                    "unordered/overlapping fragment")
            require(returned_text[output:output + end - start] == source[start:end],
                    "callback fragment differs from source")
            if end > start:
                verified.append({"source_span": _span(source, start, end),
                                 "output_span": _span(returned_text, output, output + end - start)})
            previous_source, previous_output = end, output + end - start
        self.reads[call_id] = {"resource_id": resource_id, "source_sha256": text_digest(source),
                              "fragments": verified, "returned_text": returned_text,
                              "callback_sha256": text_digest(returned_text)}
        return copy.deepcopy({key: value for key, value in self.reads[call_id].items() if key != "returned_text"})

    def _parts(self, request):
        require(type(request) is dict and type(request.get("input")) in (str, list),
                "Responses input must be text or list")
        require(not request.get("previous_response_id"), "opaque previous_response_id history")
        parts, calls, outputs = [], {}, set()
        instructions = request.get("instructions")
        if instructions is not None:
            require(type(instructions) is str, "nontext instructions")
            # Top-level instructions do not carry an explicit system/developer role.
            parts.append({"path": "instructions", "role": "instructions", "text": instructions})
        inputs = request["input"]
        if type(inputs) is str:
            return parts + [{"path": "input", "role": "user", "text": inputs}], calls
        for index, item in enumerate(inputs):
            require(type(item) is dict, "nonobject Responses item")
            kind = item.get("type", "message")
            path = "input[" + str(index) + "]"
            if kind == "function_call":
                require(type(item.get("call_id")) is str and item["call_id"]
                        and item["call_id"] not in calls and type(item.get("name")) is str
                        and item["name"] and type(item.get("arguments")) is str,
                        "invalid/duplicate function call")
                arguments = _decode(item["arguments"].encode("utf-8"))
                require(type(arguments) is dict, "function arguments must be JSON object")
                calls[item["call_id"]] = {"path": path, "name": item["name"],
                                          "arguments_sha256": text_digest(item["arguments"])}
                parts.append({"kind": "function_call", "path": path, "call_id": item["call_id"],
                              "name": item["name"], "arguments_sha256": text_digest(item["arguments"])})
                continue
            if kind == "function_call_output":
                call_id = item.get("call_id")
                require(type(call_id) is str and call_id in calls and call_id not in outputs,
                        "orphan/duplicate/out-of-order function output")
                outputs.add(call_id)
                require(type(item.get("output")) is str, "nontext function output")
                parts.append({"path": path + ".output", "role": "tool", "text": item["output"],
                              "call_id": call_id})
                continue
            require(kind == "message" and item.get("role") in ("system", "developer", "user", "assistant"),
                    "unknown/nontext Responses item")
            content = item.get("content")
            if type(content) is str:
                parts.append({"path": path + ".content", "role": item["role"], "text": content})
                continue
            require(type(content) is list, "message content must be text/list")
            for block_index, block in enumerate(content):
                require(type(block) is dict and block.get("type") in ("input_text", "output_text")
                        and type(block.get("text")) is str, "unknown/nontext content block")
                parts.append({"path": path + ".content[" + str(block_index) + "].text",
                              "role": item["role"], "text": block["text"]})
        return parts, calls

    def capture_request(self, raw, *, label=""):
        """Transactional: malformed/opaque captures retain a rejection receipt only."""
        request_hash = digest(raw) if type(raw) is bytes else None
        provenance = {"request_sha256": request_hash, "request_bytes": len(raw) if type(raw) is bytes else None,
                      "label": label, "generation": self.generation,
                      "capture_authentication": "not_verified", "model_retention": "UNKNOWN"}
        try:
            request = _decode(raw)
            parts, calls = self._parts(request)
            for call_id, call in calls.items():
                signature = {key: call[key] for key in ("name", "arguments_sha256")}
                require(call_id not in self.observed_calls or self.observed_calls[call_id] == signature,
                        "historical call identity/arguments changed")
            events, coverage, delivered = [], {}, set()
            for part in parts:
                if part.get("kind") == "function_call":
                    events.append({**provenance, "type": "function_call", "path": part["path"],
                                   "call_id": part["call_id"], "name": part["name"],
                                   "arguments_sha256": part["arguments_sha256"]})
                    continue
                content = part["text"]
                base = {**provenance, "path": part["path"], "role": part["role"],
                        "characters": len(content), "text_sha256": text_digest(content)}
                events.append({**base, "type": "text"})
                for injection in self.injections:
                    offset = 0
                    while part["role"] in injection["roles"]:
                        start = content.find(injection["text"], offset)
                        if start < 0:
                            break
                        end = start + len(injection["text"])
                        events.append({**base, "type": "injection", "injection_id": injection["id"],
                                       "span": _span(content, start, end)})
                        offset = end
                call_id = part.get("call_id")
                if call_id not in self.reads:
                    continue
                read = self.reads[call_id]
                require(content == read["returned_text"], "captured output differs from actual callback")
                delivered.add(call_id)
                fragments = read.get("fragments", [{"source_span": read.get("source_span"), "output_span": read.get("output_span")}])
                if not fragments:
                    events.append({**base, "type": "read", "call_id": call_id,
                                   "resource_id": read["resource_id"], "source_sha256": read["source_sha256"],
                                   "callback_sha256": read["callback_sha256"], "extent": "empty",
                                   "first_delivery": call_id not in self.delivered_calls})
                for fragment in fragments:
                    span = fragment["source_span"]
                    coverage.setdefault(read["resource_id"], []).append((span["start"], span["end"]))
                    events.append({**base, "type": "read", "call_id": call_id,
                                   "resource_id": read["resource_id"], "source_sha256": read["source_sha256"],
                                   "source_span": copy.deepcopy(span), "output_span": copy.deepcopy(fragment["output_span"]),
                                   "callback_sha256": read["callback_sha256"],
                                   "first_delivery": call_id not in self.delivered_calls,
                                   "extent": "full" if span["start"] == 0 and span["end"] == len(self.resources[read["resource_id"]]) else "partial"})
            resource_coverage = {}
            for resource_id, source in self.resources.items():
                spans = _union(coverage.get(resource_id, []))
                count = sum(end - start for start, end in spans)
                resource_coverage[resource_id] = {"spans": [_span(source, start, end) for start, end in spans],
                                                  "characters": count, "full": count == len(source),
                                                  "model_retention": "UNKNOWN"}
            receipt = {**provenance, "status": "accounted", "complete_input_text_accounting": True,
                       "text_characters": sum(len(part.get("text", "")) for part in parts),
                       "call_count": len(calls), "read_calls_present": sorted(delivered),
                       "coverage": resource_coverage, "events": events,
                       "limits": ["Function names/arguments and JSON framing excluded from text counts",
                                  "Known injection occurrences may overlap; never add to total text twice",
                                  "Provider delivery does not prove model retention or instruction compliance"]}
            self.events.extend(events)
            self.coverage = resource_coverage
            self.delivered_calls.update(delivered)
            self.observed_calls.update({call_id: {key: call[key] for key in ("name", "arguments_sha256")}
                                        for call_id, call in calls.items()})
            self.receipts.append(receipt)
            return copy.deepcopy(receipt)
        except (AccountingError, UnicodeError) as error:
            self.coverage = {}
            receipt = {**provenance, "status": "rejected", "complete_input_text_accounting": False,
                       "error": str(error), "coverage": "UNKNOWN"}
            self.receipts.append(receipt)
            if isinstance(error, AccountingError):
                raise
            raise AccountingError("unencodable Unicode input") from error
