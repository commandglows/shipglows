"""Bounded live Responses SSE validation, separate from the fixed mock protocol.

The caller must buffer the complete stream and call gate_complete_sse before
releasing any bytes. The injected function validator must be a pure check of the
case-owned tool schema, never a dispatcher. Reasoning is generated output;
encrypted generated reasoning earns no instruction-retention or cost evidence.
No credentials, filesystem, provider calls, or process execution occur here.
"""
import copy
import json
import math

BODY_LIMIT = 1024 * 1024
EVENT_LIMIT = 8192
ITEM_LIMIT = 256
RESPONSE_FIELDS = {
    "id", "object", "created_at", "completed_at", "status", "model", "output",
    "usage", "error", "incomplete_details", "background", "conversation",
    "instructions", "max_output_tokens", "max_tool_calls", "metadata",
    "parallel_tool_calls", "previous_response_id", "prompt", "prompt_cache_key",
    "prompt_cache_retention", "reasoning", "safety_identifier", "service_tier",
    "store", "stream", "temperature", "text", "tool_choice", "tools",
    "top_logprobs", "top_p", "truncation", "user", "context_management",
}
EVENT_FIELDS = {
    "response.created": ({"response"}, set()),
    "response.in_progress": ({"response"}, set()),
    "response.completed": ({"response"}, set()),
    "response.output_item.added": ({"output_index", "item"}, set()),
    "response.output_item.done": ({"output_index", "item"}, set()),
    "response.content_part.added": ({"item_id", "output_index", "content_index", "part"}, set()),
    "response.content_part.done": ({"item_id", "output_index", "content_index", "part"}, set()),
    "response.output_text.delta": ({"item_id", "output_index", "content_index", "delta"}, {"logprobs", "obfuscation"}),
    "response.output_text.done": ({"item_id", "output_index", "content_index", "text"}, {"logprobs"}),
    "response.refusal.delta": ({"item_id", "output_index", "content_index", "delta"}, {"obfuscation"}),
    "response.refusal.done": ({"item_id", "output_index", "content_index", "refusal"}, set()),
    "response.function_call_arguments.delta": ({"item_id", "output_index", "delta"}, {"obfuscation"}),
    "response.function_call_arguments.done": ({"item_id", "output_index", "arguments"}, {"name"}),
    "response.reasoning_summary_part.added": ({"item_id", "output_index", "summary_index", "part"}, set()),
    "response.reasoning_summary_part.done": ({"item_id", "output_index", "summary_index", "part"}, set()),
    "response.reasoning_summary_text.delta": ({"item_id", "output_index", "summary_index", "delta"}, {"obfuscation"}),
    "response.reasoning_summary_text.done": ({"item_id", "output_index", "summary_index", "text"}, set()),
    "response.reasoning_text.delta": ({"item_id", "output_index", "content_index", "delta"}, {"obfuscation"}),
    "response.reasoning_text.done": ({"item_id", "output_index", "content_index", "text"}, set()),
}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def _pairs(rows):
    result = {}
    for key, value in rows:
        require(key not in result, "duplicate JSON key")
        result[key] = value
    return result


def _constant(_):
    raise ValueError("nonfinite JSON number")


def _float(text):
    value = float(text)
    require(math.isfinite(value), "nonfinite JSON number")
    return value


def _json(raw):
    try:
        value = json.loads(raw, object_pairs_hook=_pairs, parse_constant=_constant, parse_float=_float)
        def utf8(item):
            if type(item) is str:
                item.encode("utf-8", errors="strict")
            elif type(item) is dict:
                for key, child in item.items():
                    utf8(key)
                    utf8(child)
            elif type(item) is list:
                for child in item:
                    utf8(child)
        utf8(value)
        return value
    except (UnicodeError, json.JSONDecodeError, RecursionError, OverflowError):
        raise ValueError("invalid UTF-8 or JSON") from None


def _string(value):
    return type(value) is str and bool(value)


def _integer(value):
    return type(value) is int and value >= 0


def _same(a, b):
    return type(a) is type(b) and json.dumps(a, sort_keys=True, ensure_ascii=False) == json.dumps(b, sort_keys=True, ensure_ascii=False)


def _events(raw):
    require(type(raw) is bytes and 0 < len(raw) <= BODY_LIMIT, "empty or oversized live SSE")
    try:
        text = raw.decode("utf-8", errors="strict")
    except UnicodeError:
        raise ValueError("invalid UTF-8 SSE") from None
    text = text.replace("\r\n", "\n")
    require("\r" not in text and text.endswith("\n\n"), "truncated SSE framing")
    events = []
    for block in text[:-2].split("\n\n"):
        event_name, data = None, []
        for line in block.split("\n"):
            if line.startswith(":"):
                continue  # SSE keepalive; no instruction or output semantics.
            if line.startswith("event:"):
                require(event_name is None, "duplicate SSE event field")
                event_name = line[6:].removeprefix(" ")
            elif line.startswith("data:"):
                data.append(line[5:].removeprefix(" "))
            else:
                raise ValueError("unsupported SSE framing field")
        if not data:
            require(event_name is None, "SSE event missing data")
            continue
        event = _json("\n".join(data))
        require(type(event) is dict, "SSE event is not an object")
        name = event.get("type")
        require(name in EVENT_FIELDS and (event_name is None or event_name == name), "unknown or mismatched live event")
        required, optional = EVENT_FIELDS[name]
        require(required | {"type", "sequence_number"} <= set(event)
                and set(event) <= required | optional | {"type", "sequence_number"}, "unknown or missing live event fields")
        require(type(event["sequence_number"]) is int and event["sequence_number"] == len(events), "noncontiguous event sequence")
        for key in ("output_index", "content_index", "summary_index"):
            if key in event:
                require(_integer(event[key]) and event[key] < ITEM_LIMIT, "invalid event index")
        if "obfuscation" in event:
            require(type(event["obfuscation"]) is str, "invalid event obfuscation")
        if "logprobs" in event:
            require(type(event["logprobs"]) is list, "invalid event logprobs")
        events.append(event)
        require(len(events) <= EVENT_LIMIT, "too many live SSE events")
    require(events and events[0]["type"] == "response.created"
            and events[-1]["type"] == "response.completed", "missing complete response lifecycle")
    return events


def _usage(value):
    require(type(value) is dict and set(value) == {"input_tokens", "output_tokens", "total_tokens", "input_tokens_details", "output_tokens_details"}, "unknown or missing completed usage")
    require(all(_integer(value[k]) for k in ("input_tokens", "output_tokens", "total_tokens")), "invalid usage counters")
    require(value["total_tokens"] == value["input_tokens"] + value["output_tokens"], "inconsistent total usage")
    for name, key, total in (("input_tokens_details", "cached_tokens", "input_tokens"),
                             ("output_tokens_details", "reasoning_tokens", "output_tokens")):
        detail = value[name]
        require(type(detail) is dict and set(detail) == {key} and _integer(detail[key])
                and detail[key] <= value[total], "invalid completed usage detail")


def _response(value, completed):
    required = {"id", "object", "created_at", "status", "model", "output", "usage"}
    require(type(value) is dict and required <= set(value) <= RESPONSE_FIELDS, "unknown response envelope")
    require(_string(value["id"]) and value["object"] == "response" and _integer(value["created_at"])
            and _string(value["model"]) and type(value["output"]) is list, "invalid response identity")
    require(value["status"] == ("completed" if completed else "in_progress"), "failed or incomplete response status")
    require(value.get("error") is None and value.get("incomplete_details") is None, "response reports error or truncation")
    if completed:
        _usage(value["usage"])
    else:
        require(value["output"] == [], "unexpected early output snapshot")
        if value["usage"] is not None:
            _usage(value["usage"])
    for key in ("background", "parallel_tool_calls", "store", "stream"):
        if key in value:
            require(type(value[key]) is bool, "invalid response flag")
    for key in ("completed_at", "max_output_tokens", "max_tool_calls", "top_logprobs"):
        if value.get(key) is not None:
            require(_integer(value[key]), "invalid response numeric field")
    for key in ("previous_response_id", "prompt_cache_key", "prompt_cache_retention", "safety_identifier",
                "service_tier", "truncation", "user", "instructions"):
        require(value.get(key) is None or type(value[key]) is str, "invalid response string field")
    for key, maximum in (("temperature", 2), ("top_p", 1)):
        if value.get(key) is not None:
            require(type(value[key]) in (int, float) and 0 <= value[key] <= maximum, "invalid response sampling field")
    metadata = value.get("metadata")
    require(metadata is None or type(metadata) is dict and all(type(k) is str and type(v) is str
            for k, v in metadata.items()), "invalid response metadata")
    reason = value.get("reasoning")
    require(reason is None or type(reason) is dict and set(reason) <= {"effort", "summary", "generate_summary"}
            and all(v is None or type(v) is str for v in reason.values()), "invalid response reasoning config")
    text = value.get("text")
    require(text is None or type(text) is dict and set(text) <= {"format", "verbosity"}, "invalid response text config")
    if text is not None:
        require(text.get("verbosity") is None or text["verbosity"] in ("low", "medium", "high"), "invalid text verbosity")
        fmt = text.get("format")
        require(fmt is None or type(fmt) is dict and fmt.get("type") in ("text", "json_object", "json_schema")
                and set(fmt) <= {"type", "name", "description", "schema", "strict"}, "invalid response text format")
    tools = value.get("tools")
    require(tools is None or type(tools) is list, "invalid response tools")
    for tool in tools or []:
        require(type(tool) is dict and tool.get("type") == "function" and _string(tool.get("name"))
                and set(tool) <= {"type", "name", "description", "parameters", "strict", "defer_loading"}
                and type(tool.get("parameters")) is dict, "unsupported response tool declaration")
    choice = value.get("tool_choice")
    require(choice is None or type(choice) is str and choice in ("auto", "none", "required")
            or type(choice) is dict and set(choice) == {"type", "name"} and choice["type"] == "function"
            and _string(choice["name"]), "unsupported response tool choice")
    conversation = value.get("conversation")
    require(conversation is None or type(conversation) is str or type(conversation) is dict
            and set(conversation) == {"id"} and _string(conversation["id"]), "invalid response conversation")
    prompt = value.get("prompt")
    require(prompt is None or type(prompt) is dict and set(prompt) <= {"id", "version", "variables"}
            and _string(prompt.get("id")), "invalid response prompt metadata")
    require(value.get("context_management") in (None, []), "unsupported provider context management")


def _part(value, kind):
    require(type(value) is dict, "invalid content part")
    expected = {"message": {"output_text", "refusal"}, "summary": {"summary_text"}, "reasoning": {"reasoning_text"}}[kind]
    require(value.get("type") in expected, "unsupported content part type")
    field = "refusal" if value["type"] == "refusal" else "text"
    allowed = {"type", field} | ({"annotations", "logprobs"} if value["type"] == "output_text" else set())
    require({"type", field} <= set(value) <= allowed and type(value[field]) is str, "invalid content part fields")
    if "annotations" in value:
        require(type(value["annotations"]) is list and all(type(a) is dict and a.get("type") in
            {"url_citation", "file_citation", "container_file_citation", "file_path"} for a in value["annotations"]), "unsupported output annotation")
    if "logprobs" in value:
        require(type(value["logprobs"]) is list, "invalid output logprobs")
    return field


def _item(value, completed):
    require(type(value) is dict and _string(value.get("id")), "missing output item identity")
    kind = value.get("type")
    require(kind in {"message", "function_call", "reasoning"}, "native or unknown output item refused")
    status = "completed" if completed else "in_progress"
    if kind == "message":
        require({"id", "type", "role", "status", "content"} <= set(value)
                <= {"id", "type", "role", "status", "content", "phase"}, "unknown message fields")
        require(value["role"] == "assistant" and value["status"] == status and type(value["content"]) is list, "invalid message state")
        require(value.get("phase") in (None, "commentary", "final_answer"), "unknown message phase")
        for part in value["content"]:
            _part(part, "message")
    elif kind == "function_call":
        require({"id", "type", "call_id", "name", "arguments"} <= set(value)
                <= {"id", "type", "call_id", "name", "arguments", "status"}, "unknown function fields")
        require(_string(value["call_id"]) and _string(value["name"]) and type(value["arguments"]) is str
                and value.get("status", status) == status, "invalid function state")
        if completed:
            require(type(_json(value["arguments"])) is dict, "function arguments must be an object")
        else:
            require(value["arguments"] == "", "nonempty added function arguments")
    else:
        require({"id", "type", "summary"} <= set(value)
                <= {"id", "type", "summary", "content", "encrypted_content", "status"}, "unknown reasoning fields")
        require(value.get("status") in (None, status) and type(value["summary"]) is list, "invalid reasoning state")
        require(value.get("encrypted_content") is None or type(value["encrypted_content"]) is str, "invalid generated encrypted content")
        for part in value["summary"]:
            _part(part, "summary")
        require(type(value.get("content", [])) is list, "invalid reasoning content")
        for part in value.get("content", []):
            _part(part, "reasoning")
    if not completed:
        require(not value.get("content") and not value.get("summary"), "nonempty added item content")


def _validate(raw, seen_call_ids):
    events = _events(raw)
    initial = events[0]["response"]
    _response(initial, False)
    states, ids, calls, final = {}, set(), set(seen_call_ids), None
    for position, event in enumerate(events):
        name = event["type"]
        require(final is None, "event after response completion")
        if name in ("response.created", "response.in_progress", "response.completed"):
            response = event["response"]
            complete = name == "response.completed"
            _response(response, complete)
            require(all(_same(response[k], initial[k]) for k in ("id", "model", "created_at", "object")), "response identity changed")
            if name == "response.created":
                require(position == 0, "duplicate response.created")
            if name == "response.in_progress":
                require(position == 1 and not states, "duplicate or late response.in_progress")
            if complete:
                require(states and set(states) == set(range(len(states))) and all(s["done"] for s in states.values()), "incomplete output items")
                require(_same(response["output"], [states[i]["done"] for i in range(len(states))]), "completed output differs from item.done")
                final = response
            continue
        index = event["output_index"]
        if name == "response.output_item.added":
            item = event["item"]
            _item(item, False)
            require(index not in states and item["id"] not in ids, "duplicate output index or item ID")
            require(len(states) < ITEM_LIMIT, "too many output items")
            if item["type"] == "function_call":
                require(item["call_id"] not in calls, "duplicate or replayed call ID")
                calls.add(item["call_id"])
            ids.add(item["id"])
            states[index] = {"added": item, "done": None, "arguments": "", "argument_delta": False,
                             "arguments_done": False, "parts": {}}
            continue
        require(index in states and states[index]["done"] is None, "event outside active output item")
        state = states[index]
        item = state["added"]
        if name == "response.output_item.done":
            done = event["item"]
            _item(done, True)
            require(all(_same(done.get(k), item.get(k)) for k in ("type", "id", "name", "call_id", "role")), "output item identity changed")
            require("phase" not in item or done.get("phase") == item["phase"], "message phase changed")
            if item["type"] == "function_call":
                require(state["arguments_done"] and done["arguments"] == state["arguments"], "incomplete or inconsistent function arguments")
            else:
                for category, field in (("message", "content"),) if item["type"] == "message" else (("summary", "summary"), ("reasoning", "content")):
                    parts = {i: p for (c, i), p in state["parts"].items() if c == category}
                    require(set(parts) == set(range(len(parts))) and all(p["done"] for p in parts.values()), "incomplete content parts")
                    require(_same(done.get(field, []), [parts[i]["done"] for i in range(len(parts))]), "item content differs from completed parts")
            state["done"] = done
            continue
        require(event["item_id"] == item["id"], "foreign event item ID")
        if name.startswith("response.function_call_arguments."):
            require(item["type"] == "function_call" and not state["arguments_done"], "argument event outside active function")
            field = "delta" if name.endswith(".delta") else "arguments"
            require(type(event[field]) is str, "invalid argument text")
            if field == "delta":
                state["arguments"] += event[field]
                state["argument_delta"] = True
            else:
                require(not state["argument_delta"] or event[field] == state["arguments"], "argument deltas disagree with done")
                require(event.get("name", item["name"]) == item["name"], "argument done function name changed")
                state["arguments"] = event[field]
                state["arguments_done"] = True
            continue
        category = "summary" if name.startswith("response.reasoning_summary_") else "reasoning" if item["type"] == "reasoning" else "message"
        require((category == "message" and item["type"] == "message") or (category != "message" and item["type"] == "reasoning"), "content event on wrong item type")
        part_index = event["summary_index" if category == "summary" else "content_index"]
        key = (category, part_index)
        is_part = name.startswith(("response.content_part.", "response.reasoning_summary_part."))
        if is_part and name.endswith(".added"):
            part = event["part"]
            field = _part(part, category)
            require(key not in state["parts"] and part[field] == "", "duplicate or nonempty added content part")
            state["parts"][key] = {"added": part, "text": "", "delta": False, "text_done": False, "done": None}
            continue
        require(key in state["parts"] and state["parts"][key]["done"] is None, "event outside active content part")
        part = state["parts"][key]
        field = "refusal" if part["added"]["type"] == "refusal" else "text"
        if is_part:
            done = event["part"]
            _part(done, category)
            require(part["text_done"] and done["type"] == part["added"]["type"] and done[field] == part["text"], "part.done differs from text.done")
            part["done"] = done
        else:
            expected_prefix = {"output_text": "response.output_text.", "refusal": "response.refusal.",
                               "summary_text": "response.reasoning_summary_text.", "reasoning_text": "response.reasoning_text."}[part["added"]["type"]]
            require(name.startswith(expected_prefix) and not part["text_done"], "text event type changed or already done")
            value = event["delta" if name.endswith(".delta") else field]
            require(type(value) is str, "invalid generated text")
            if name.endswith(".delta"):
                part["text"] += value
                part["delta"] = True
            else:
                require(not part["delta"] or value == part["text"], "text deltas disagree with done")
                part["text"] = value
                part["text_done"] = True
    require(final is not None, "missing completed response")
    return events, final


def gate_complete_sse(raw, seen_call_ids, validate_function_item):
    """Pure complete-stream gate. Returns metadata only; never emits or dispatches."""
    require(callable(validate_function_item), "case-owned function validator required")
    require(type(seen_call_ids) in (set, frozenset, list, tuple) and all(_string(x) for x in seen_call_ids), "invalid previously seen call IDs")
    events, response = _validate(raw, seen_call_ids)
    functions = [x for x in response["output"] if x["type"] == "function_call"]
    # Only after the entire SSE structure/coherence succeeded; this callback
    # still MUST remain a validator, not dispatch an action.
    for item in functions:
        try:
            result = validate_function_item(copy.deepcopy(item))
            require(result is not False, "function validator refused")
        except Exception:
            raise ValueError("case-owned function validator refused completed call") from None
    reasoning = [x for x in response["output"] if x["type"] == "reasoning"]
    encrypted = any(bool(x.get("encrypted_content")) for x in reasoning)
    return {"response_id": response["id"], "events": len(events), "output_items": len(response["output"]),
            "call_ids": [x["call_id"] for x in functions], "function_names": [x["name"] for x in functions],
            "message_ids": [x["id"] for x in response["output"] if x["type"] == "message"],
            "reasoning_ids": [x["id"] for x in reasoning],
            "provider_bytes_validated_before_cli_emission": len(raw),
            "generated_encrypted_content_present": encrypted,
            "generated_reasoning_state": "UNKNOWN" if reasoning else "not_present",
            "instruction_retention": "UNKNOWN", "context_compaction_inferred": False,
            "usage": copy.deepcopy(response["usage"]), "cost": "UNKNOWN"}


def completed_response(raw):
    """Extract structurally validated response; tool authorization needs the gate.

    Call gate_complete_sse with the case validator before exposing this result
    to a dispatcher. This helper alone cannot know the permitted case tools.
    """
    _, response = _validate(raw, frozenset())
    return copy.deepcopy(response)
