"""Separate raw review of parent case-controller proofs before ephemeral cleanup.

Independent of launcher/controller implementation; reviewer authored child relay,
so independent child-source review remains a separate provenance requirement.
No model/provider/held-out reads. Returns hashes/counts/checks, never model text.
"""
import base64
from pathlib import Path
from tools import conditional_skill_routing_parent_transport as wire

# Captured at import, never reread during a long-running proof. Caller must
# compare against its immutable pre-execution source snapshot before accepting.
LOADED_SOURCE_SHA256=wire.sha(Path(__file__).read_bytes())

CHILD_DEPENDENCIES={"tools/conditional_skill_routing_cli_broker_profile.py","tools/conditional_skill_routing_parent_transport.py"}
EVENTS={"response.created","response.output_item.added","response.output_item.done","response.function_call_arguments.delta",
        "response.function_call_arguments.done","response.content_part.added","response.content_part.done",
        "response.output_text.delta","response.output_text.done","response.completed"}
class ReviewError(ValueError):pass

def require(ok):
    if not ok:raise ReviewError("independent raw proof association failed")
def equal(a,b):return type(a) is type(b) and wire.packed(a)==wire.packed(b)
def un64(value):
    require(type(value) is str)
    try:return base64.b64decode(value,validate=True)
    except Exception:raise ReviewError("invalid encoded raw proof body") from None

def opaque(value):
    if type(value) is dict:
        return any((key in ("encrypted_content","encryptedContent") and child not in (None,"")) or opaque(child)
                   for key,child in value.items())
    if type(value) is list:return any(opaque(child) for child in value)
    return False

def _rpc(workspace,pattern):
    result=[]
    for path in sorted((workspace/"run").glob(pattern)):
        require(path.is_file() and not path.is_symlink())
        raw=path.read_bytes();require(len(raw)<=4*1024*1024)
        for line in raw.splitlines():
            if line:result.append(wire.decoded(line))
    return result

def _completed(raw):
    require(type(raw) is bytes and 0<len(raw)<=1024*1024 and raw.endswith(b"\n\n"))
    events=[]
    for block in raw[:-2].split(b"\n\n"):
        lines=block.splitlines();data=[line[6:] for line in lines if line.startswith(b"data: ")]
        require(len(data)==1 and all(line.startswith((b"data: ",b"event: ")) for line in lines))
        event=wire.decoded(data[0]);require(type(event) is dict and event.get("type") in EVENTS and not opaque(event))
        require(all(line[7:].decode()==event["type"] for line in lines if line.startswith(b"event: ")))
        events.append(event)
    require(events[0]["type"]=="response.created" and events[-1]["type"]=="response.completed")
    terminal=[e for e in events if e["type"]=="response.completed"];require(len(terminal)==1)
    response=terminal[0]["response"];require(type(response) is dict and response.get("status")=="completed" and type(response.get("output")) is list)
    require(events[0]["response"]["id"]==response["id"])
    done=[e for e in events if e["type"]=="response.output_item.done"]
    require(len(done)==len(response["output"]))
    for index,item in enumerate(response["output"]):
        require(type(item) is dict and item.get("type") in ("function_call","message"))
        matches=[e for e in done if type(e.get("output_index")) is int and e["output_index"]==index]
        require(len(matches)==1 and equal(matches[0]["item"],item))
    return response

def review(raw_frames,replies,controller,workspace,channel,childfacts,*,child_dependencies,expected_cli_sha256,expected_model=None):
    """Fail closed on missing raw associations. Call before deleting workspace."""
    workspace=Path(workspace)
    require(type(raw_frames) is list and type(replies) is list and len(raw_frames)==len(replies) and 0<len(raw_frames)<=512)
    require(type(child_dependencies) is dict and set(child_dependencies)==CHILD_DEPENDENCIES)
    require(all(type(v) is dict and set(v)=={"bytes","sha256"} and type(v["bytes"]) is int and v["bytes"]>0
                and type(v["sha256"]) is str and len(v["sha256"])==64 for v in child_dependencies.values()))
    require(childfacts.get("cli_sha256")==expected_cli_sha256 and childfacts.get("interfaces")==["lo"]
            and type(childfacts.get("nonloopback_probe_errno")) is int and childfacts["nonloopback_probe_errno"]==101)
    require(all(childfacts.get(k) is False for k in ("parent_sentinel_visible","mnt_visible","run_visible")))
    mounts={}
    for line in childfacts.get("mountinfo","").splitlines():
        fields=line.split();require(len(fields)>=7)
        mounts[fields[4]]=fields[5].split(",")
    require(all("ro" in mounts.get(p,[]) for p in ("/dependency-root","/probe.py","/codex")))
    require(not any(p=="/mnt" or p.startswith("/mnt/") or p=="/run" or p.startswith("/run/") for p in mounts))
    model=expected_model if expected_model is not None else ("synthetic" if controller.provider_kind=="mock" else controller.provider_callback.model)
    config=wire.decoded((workspace/"run/effective-config-read.json").read_bytes())
    require(type(config.get("config",{}).get("tool_output_token_limit")) is int and config["config"]["tool_output_token_limit"]==100000 and config["config"].get("model")==model)
    rpc_out=_rpc(workspace,"rpc-stdout-*.bin");rpc_in=_rpc(workspace,"rpc-input-*.bin")
    require(equal(rpc_out,wire.decoded((workspace/"run/rpc-events.json").read_bytes())["events"]))
    require(len([r for r in rpc_in if r.get("method")=="config/read" and r.get("params")=={"includeLayers":False}])==1)
    config_responses=[r for r in rpc_out if r.get("id")==9000 and "result" in r]
    require(len(config_responses)==1 and equal(config_responses[0]["result"],config))
    native={"commandExecution","fileChange","mcpToolCall","webSearch","collabAgentToolCall","contextCompaction","compaction"}
    for event in rpc_out:
        params=event.get("params",{})
        require(not opaque(event))
        require(event.get("method") not in ("thread/compacted","thread/contextLost","thread/contextCompacted"))
        if type(params) is dict:
            require(params.get("item",{}).get("type") not in native)
            require(params.get("run",{}).get("eventName") not in ("preCompact","postCompact"))
    actual_callbacks=[r for r in rpc_out if r.get("method")=="item/tool/call"]
    require(len({wire.packed(r["id"]) for r in actual_callbacks})==len(actual_callbacks))
    model_records=[];callback_records=[];frame_ids=set();known={};pending=set();model_index=0;callback_index=0
    for raw,reply in zip(raw_frames,replies):
        require(type(raw) is bytes and type(reply) is bytes and 0<len(raw)<=4*1024*1024 and 0<len(reply)<=8*1024*1024)
        envelope=wire.verify(wire.decoded(raw),channel)
        require(set(envelope)=={"version","id","endpoint","headers","body_b64","body_sha256"} and type(envelope["version"]) is int
                and envelope["version"]==1 and envelope["endpoint"]=="case-controller" and envelope["headers"]=={"content-type":"application/json"})
        require(type(envelope["id"]) is str and envelope["id"] not in frame_ids);frame_ids.add(envelope["id"])
        body=un64(envelope["body_b64"]);require(wire.sha(body)==envelope["body_sha256"])
        value=wire.decoded(body);require(type(value) is dict and set(value)=={"op","parameters"} and type(value["parameters"]) is dict)
        response=wire.read_response(reply,channel,envelope["id"])
        require(response["status"]==200 and response["headers"]=={"content-type":"application/json"})
        result=wire.decoded(response["body"]);op=value["op"];params=value["parameters"]
        if op=="tool_callback":
            require(set(params)=={"parameters"} and callback_index<len(actual_callbacks))
            event=actual_callbacks[callback_index];callback_index+=1
            require(equal(params["parameters"],event["params"]))
            cid=event["params"]["callId"];require(cid not in known and cid in controller.subject.callbacks)
            row=controller.subject.callbacks[cid]
            require(type(result) is dict and set(result)=={"success","contentItems"} and type(result["success"]) is bool and row["delivered"] is True)
            require(result["contentItems"]==[{"type":"inputText","text":row["content"]}])
            actual_replies=[r for r in rpc_in if equal(r.get("id"),event["id"]) and "result" in r]
            require(len(actual_replies)==1 and equal(actual_replies[0]["result"],result))
            known[cid]={"content":row["content"],"parameters":event["params"]};pending.add(cid)
            callback_records.append({"call_id_sha256":wire.sha(cid.encode()),"content_sha256":wire.sha(row["content"].encode()),"parameters_sha256":wire.sha(wire.packed(event["params"])),"result_sha256":wire.sha(response["body"])})
        elif op=="model_request":
            require(set(params)=={"body_b64"} and model_index<len(controller.raw_exchanges) and model_index<len(controller.responses))
            original_raw=un64(params["body_b64"]);original=wire.decoded(original_raw)
            exchange=controller.raw_exchanges[model_index];record=controller.responses[model_index];model_index+=1
            require(record["origin"]==exchange["origin"] and record["origin"] in ("exact_fixture_history_replay_no_provider_call","injected_mock_provider","authorized_live_provider"))
            require(original_raw==exchange["original_request"] and wire.sha(original_raw)==record["original_request_sha256"])
            require(wire.sha(exchange["request"])==record["model_request_sha256"] and wire.sha(exchange["response"])==record["response_sha256"])
            require(type(result) is dict and set(result)=={"status","headers","body_b64"} and result["status"]==200
                    and result["headers"].get("content-type","").split(";",1)[0]=="text/event-stream" and un64(result["body_b64"])==exchange["response"])
            offered=wire.decoded(exchange["request"])
            require(equal({k:v for k,v in original.items() if k!="tools"},{k:v for k,v in offered.items() if k!="tools"}))
            expected=[]
            for tool in controller.tools:
                matches=[t for t in original["tools"] if t.get("name")==tool["name"]]
                require(len(matches)==1);t=matches[0]
                require(set(t)=={"type","name","description","parameters","strict"} and t["type"]=="function" and type(t["strict"]) is bool and t["strict"] is False
                        and t["description"]==tool["description"] and equal(t["parameters"],tool["inputSchema"]))
                expected.append(t)
            require(equal(offered["tools"],expected))
            outputs=[t for t in original["input"] if t.get("type")=="function_call_output"]
            require({t.get("call_id") for t in outputs}==set(known) and len(outputs)==len(known))
            for cid,row in known.items():
                output=next(t for t in outputs if t["call_id"]==cid);require(output.get("output")==row["content"])
                calls=[t for t in original["input"] if t.get("type")=="function_call" and t.get("call_id")==cid]
                require(len(calls)==1 and calls[0]["name"]==row["parameters"]["tool"] and equal(wire.decoded(calls[0]["arguments"].encode()),row["parameters"]["arguments"]))
            pending.clear()
            http_id="cli-http-%03d"%model_index
            require((workspace/"run"/(http_id+".request.bin")).read_bytes()==original_raw)
            require((workspace/"run"/(http_id+".parent-response.bin")).read_bytes()==exchange["response"])
            completed=_completed(exchange["response"])
            model_records.append({"original_request_sha256":wire.sha(original_raw),"forwarded_request_sha256":wire.sha(exchange["request"]),"response_sha256":wire.sha(exchange["response"]),"completed":completed,"origin":record["origin"]})
        else:require(op in ("bootstrap","bind_thread","begin_turn","next_user_turn"))
    require(not pending and callback_index==len(actual_callbacks)==len(controller.subject.callbacks) and model_index==len(controller.raw_exchanges)==len(controller.responses))
    offered_calls={};assistant=[]
    for model_record in model_records:
        for item in model_record.pop("completed")["output"]:
            if item["type"]=="function_call":
                cid=item["call_id"];require(cid not in offered_calls and cid in known)
                params=known[cid]["parameters"]
                require(item["name"]==params["tool"] and equal(wire.decoded(item["arguments"].encode()),params["arguments"]))
                offered_calls[cid]=True
            else:
                require(item.get("role")=="assistant" and type(item.get("content")) is list)
                require(all(p.get("type")=="output_text" and type(p.get("text")) is str for p in item["content"]))
                assistant.append("".join(p["text"] for p in item["content"]))
    require(set(offered_calls)==set(known))
    observed=[e["params"]["item"]["text"] for e in rpc_out if e.get("method")=="item/completed" and e.get("params",{}).get("item",{}).get("type")=="agentMessage"]
    require(equal(observed,assistant) and equal(assistant,[r["content"] for r in controller.subject.responses]))
    require(len(list((workspace/"run").glob("cli-http-*.request.bin")))==model_index)
    receipt={"schema_version":1,"status":"independent_raw_associations_verified_before_cleanup","checks":{
        "authenticated_frames":True,"all_model_origins_associated":True,"non_tools_json_types_and_values_unchanged":True,
        "exact_registered_responses_schemas":True,"raw_rpc_callbacks_executed_and_replied":True,
        "every_callback_exact_in_immediately_next_and_later_cli_requests":True,"native_assistant_messages_exact":True,
        "no_native_effects_or_compaction":True,"effective_cap_and_model":True,"loopback_and_readonly_child_dependencies":True},
        "control_exchanges":len(raw_frames),"model_requests":model_index,"callbacks":callback_index,"assistant_messages":len(assistant),
        "model_exchange_hashes":model_records,"callback_hashes":callback_records,
        "frame_sha256":[wire.sha(r) for r in raw_frames],"reply_sha256":[wire.sha(r) for r in replies],
        "child_dependencies":child_dependencies,"effective_config_sha256":wire.sha(wire.packed(config)),"review_source_sha256":LOADED_SOURCE_SHA256,
        "limits":["Independent of parent launcher/controller; reviewer authored child relay, requiring separate child-source peer review",
                  "Raw associations establish observed transport, not semantic AC5, hidden retention or actual provider/account proof",
                  "Receipt contains hashes/counts only; raw observations must be removed by caller after review"]}
    return receipt
