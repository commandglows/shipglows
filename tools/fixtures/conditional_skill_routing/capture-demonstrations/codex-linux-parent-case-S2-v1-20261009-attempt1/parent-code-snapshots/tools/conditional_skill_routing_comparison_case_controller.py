"""Trusted parent-owned case controller; live launch defaults blocked.
No launcher, credential read, authentication setup or real network operation.
The subject child receives executable turns/tools; case/expectations/resources,
provider callback, accounting and consent state remain parent-owned.
"""
import base64
import copy
import importlib.util
import json
from pathlib import Path
import threading
import time
from tools import conditional_skill_routing_comparison_adapter as integration
from tools import conditional_skill_routing_cli_tuning_transport_probe as schemas
from tools import conditional_skill_routing_parent_transport as wire
from tools.conditional_skill_routing_parent_https import PreparedHTTPSCallback

class ControllerError(ValueError): pass

def require(ok,message):
    if not ok: raise ControllerError(message)

def event_stream_type(headers):
    if type(headers) is not dict or type(headers.get("content-type")) is not str:
        return False
    parts=[part.strip().lower() for part in headers["content-type"].split(";")]
    return parts[0]=="text/event-stream" and (len(parts)==1 or len(parts)==2 and parts[1] in ("charset=utf-8", 'charset="utf-8"'))


def strict_profile():
    path=Path(schemas.profile.__file__)
    spec=importlib.util.spec_from_file_location("isolated_case_guard",path)
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

class CaseController:
    def __init__(self, prepared, provider_callback, *, provider_kind="mock", launch_authorized=False, approved_profile=None):
        require(provider_kind in ("mock","live") and type(launch_authorized) is bool,"invalid explicit launch posture")
        if provider_kind=="live":
            require(launch_authorized and type(provider_callback) is PreparedHTTPSCallback,"live launch requires separate approval and prepared HTTPS callback")
            require(provider_callback.launch_authorized and provider_callback.credential is not None and provider_callback.approved_budget is not None,
                    "live callback authority/credential/approved budget missing")
            keys={"endpoint","model","account_label","settings_sha256","budget_review_id","independent_review_id","profile_sha256"}
            require(type(approved_profile) is dict and set(approved_profile)==keys,"named approved live profile required")
            unsigned={k:v for k,v in approved_profile.items() if k!="profile_sha256"}
            require(approved_profile["profile_sha256"]==wire.sha(wire.packed(unsigned)) and type(approved_profile["independent_review_id"]) is str and approved_profile["independent_review_id"],"reviewed live profile hash/identity missing")
            require(approved_profile["endpoint"]==provider_callback.endpoint and approved_profile["model"]==provider_callback.model
                    and approved_profile["account_label"]==provider_callback.account_label
                    and approved_profile["settings_sha256"]==wire.sha(wire.packed(provider_callback.settings))
                    and approved_profile["budget_review_id"]==provider_callback.approved_budget["review_id"],"live callback differs from approved profile")
        else:
            require(not launch_authorized and approved_profile is None,"mock preparation cannot claim live authority")
        self.provider_kind=provider_kind
        self.launch_authorized=launch_authorized
        self.approved_profile=copy.deepcopy(approved_profile)
        self.live_attempts=0
        require(callable(provider_callback),"injected mock provider callback required")
        self.subject=integration.ComparisonAdapter(prepared,thread_id="parent-pending-thread",turn_id="parent-pending-turn")
        self.provider_callback=provider_callback
        self.guard=strict_profile()
        self.guard.NAMES=[row["name"] for row in self.subject.schema]
        self.guard.validate_function_item=self._validate_function
        self.tools=schemas.registered_tools(self.subject)
        self.tools_sha256=wire.sha(wire.packed(self.tools))
        self.initial=copy.deepcopy(self.subject.mcp.broker.bundle["turns"])
        self.initial_users=[row for row in self.initial if row["role"]=="user"]
        self.bootstrap_assistant=next((row for row in self.initial if row["role"]=="assistant"),None)
        self.bootstrap_replayed=False
        self.next_users=copy.deepcopy(self.initial_users)
        self.seen_calls=set()
        self.offered_calls={}
        self.responses=[]
        self.raw_exchanges=[]
        self.receipts=[]
        self.released=[]
        self.bootstrapped=False
        self.thread_bound=False
        self.turn_pending=None
        self.active_user=None
        self.request_count=0
        self.retired=False
        self.lock=threading.RLock()

    def _validate_function(self,item):
        require(type(item) is dict and item.get("type")=="function_call" and item.get("name") in self.subject.tools,
                "nonbroker/unknown provider function refused")
        require(set(item)<={"type","id","call_id","name","arguments","status"} and item.get("status")=="completed",
                "malformed function item")
        require(all(type(item.get(key)) is str and item[key] for key in ("id","call_id","arguments")),"missing function identity")
        args=wire.decoded(item["arguments"].encode())
        schema=next(row["inputSchema"] for row in self.subject.schema if row["name"]==item["name"])
        require(schemas.schema_accepts(args,schema),"arguments violate immutable case-owned schema")

    def _retire(self,raw,reason):
        self.retired=True
        if not self.subject.retired: self.subject.context_loss(reason,raw if raw else wire.packed({"reason":reason}))
        self.next_users.clear()
        self.released.clear()
        self.turn_pending=None

    def handle(self,raw,deadline):
        """ParentBridge callback: strict multiplexed case-control envelope."""
        with self.lock:
            label="case-event-"+str(len(self.receipts))
            began=time.monotonic_ns()
            try:
                require(not self.retired,"case controller retired")
                require(type(raw) is bytes and 0<len(raw)<=2*1024*1024 and len(self.receipts)<512,"bounded case-control admission")
                require(time.monotonic()<deadline,"controller deadline expired")
                value=wire.decoded(raw)
                require(type(value) is dict and set(value)=={"op","parameters"} and type(value["parameters"]) is dict,"unknown control envelope")
                op,params=value["op"],value["parameters"]
                result=self._operation(op,params,label,deadline)
                require(time.monotonic()<deadline,"controller deadline expired after operation")
                packed=wire.packed(result)
                self.receipts.append({"label":label,"op":op,"status":"returned","request_sha256":wire.sha(raw),"response_sha256":wire.sha(packed),"started_ns":began,"ended_ns":time.monotonic_ns()})
                return {"status":200,"headers":{"content-type":"application/json"},"body":packed}
            except Exception as error:
                self._retire(raw,"rejected parent case operation")
                self.receipts.append({"label":label,"status":"refused","request_sha256":wire.sha(raw),"error_sha256":wire.sha(str(error).encode()),"started_ns":began,"ended_ns":time.monotonic_ns()})
                raise ControllerError("parent case operation refused; details preserved hash-only") from None

    def _operation(self,op,params,label,deadline):
        if op=="bootstrap":
            require(not params and not self.bootstrapped,"bootstrap repeated/invalid")
            self.bootstrapped=True
            return {"tools":copy.deepcopy(self.tools),"instructions":"\n".join(row["text"] for row in self.subject.mcp.broker.bundle["injections"]),
                    "initial_turns":[{"role":row["role"],"content":row["content"]} for row in self.initial],"schema_sha256":self.tools_sha256,"model":self.provider_callback.model if self.provider_kind=="live" else "synthetic"}
        require(self.bootstrapped,"bootstrap required")
        if op=="bind_thread":
            require(set(params)=={"thread_id"} and not self.thread_bound,"thread binding repeated/invalid")
            self.subject.bind_thread(params["thread_id"])
            self.thread_bound=True
            return {"bound":True}
        if op=="native_context_loss":
            require(set(params)=={"event"} and type(params["event"]) is dict and type(params["event"].get("method")) is str,
                    "native context-loss evidence notification required")
            self._retire(wire.packed(params["event"]),"captured native context compaction/loss; unsupported recovery")
            return {"retired":True,"coverage":"UNKNOWN","event_sha256":wire.sha(wire.packed(params["event"]))}
        require(self.thread_bound,"actual thread binding required")
        if op=="next_user_turn":
            require(not params and self.turn_pending is None,"unconsumed pending user turn")
            require(not self.subject.receipts or self.subject.turn_id in self.subject.assistant_turns,"prior turn not complete")
            if not self.next_users:
                return {"turn":None}
            self.turn_pending=self.next_users.pop(0)
            return {"turn":{"role":"user","content":self.turn_pending["content"]}}
        if op=="begin_turn":
            require(set(params)=={"turn_id"} and self.turn_pending is not None,"turn lacks parent-released user input")
            require(all(row["callback_received"] for row in self.offered_calls.values()),"next turn precedes callback for emitted provider call")
            self.subject.begin_turn(params["turn_id"])
            self.active_user=self.turn_pending
            self.turn_pending=None
            return {"bound":True}
        if op=="tool_callback":
            require(set(params)=={"parameters"},"unknown callback envelope")
            callback=params["parameters"]
            require(type(callback) is dict,"malformed actual callback")
            cid=callback.get("callId")
            require(cid in self.offered_calls and not self.offered_calls[cid]["callback_received"],"callback lacks unique emitted provider call")
            offered=self.offered_calls[cid]
            require(callback.get("threadId")==offered["thread_id"] and callback.get("turnId")==offered["turn_id"],"callback differs from emitted call thread/turn")
            require(callback.get("tool")==offered["name"] and wire.packed(callback.get("arguments"))==wire.packed(offered["arguments"]),"callback differs from complete offered provider call")
            offered["callback_received"]=True
            return self.subject.dispatch(callback)
        if op=="model_request":
            require(set(params)=={"body_b64"} and self.turn_pending is None,"invalid model envelope or unbound turn")
            original=base64.b64decode(params["body_b64"],validate=True)
            request=wire.decoded(original)
            forwarded=schemas.filter_request(request,self.subject)
            forwarded_raw=wire.packed(forwarded)
            require(self.request_count<256,"case model request bound exceeded")
            self.request_count+=1
            model_label="model-request-"+str(self.request_count)
            accounted=self.subject.observe_request(forwarded_raw,label=model_label)
            require(self.active_user is not None and self.active_user["id"] in self.subject.delivered_turns,"current parent-released user not exactly delivered")
            if self.bootstrap_assistant is not None and not self.bootstrap_replayed:
                self.guard.FINAL=self.bootstrap_assistant["content"]
                body=self.guard.provider_sse("bootstrap-"+str(self.request_count))
                reply={"status":200,"headers":{"content-type":"text/event-stream"},"body":body}
                self.bootstrap_replayed=True
                origin="exact_fixture_history_replay_no_provider_call"
            else:
                if self.provider_kind=="live": self.live_attempts+=1
                reply=self.provider_callback(forwarded_raw,deadline)
                origin="authorized_live_provider" if self.provider_kind=="live" else "injected_mock_provider"
            require(type(reply) is dict and set(reply)=={"status","headers","body"} and type(reply["body"]) is bytes,"unknown provider reply")
            require(reply["status"]==200 and event_stream_type(reply["headers"]),"provider reply status/type refused")
            gate=self.guard.gate_complete_sse(reply["body"],self.seen_calls)
            self.seen_calls.update(gate["call_ids"])
            completed=schemas.completed_response(reply["body"])
            for item in completed["output"]:
                if item["type"]=="function_call":
                    self.offered_calls[item["call_id"]]={"name":item["name"],"arguments":wire.decoded(item["arguments"].encode()),"callback_received":False,
                                                          "thread_id":self.subject.thread_id,"turn_id":self.subject.turn_id}
            if any(item["type"]=="message" for item in completed["output"]):
                observed=self.subject.observe_assistant_response(wire.packed(completed),label=model_label)
                self.next_users.extend(copy.deepcopy(observed["released_turns"]))
                self.released.extend(copy.deepcopy(observed["released_turns"]))
            self.raw_exchanges.append({"original_request":original,"request":forwarded_raw,"response":reply["body"],"origin":origin})
            self.responses.append({"original_request_sha256":wire.sha(original),"model_request_sha256":wire.sha(forwarded_raw),
                                   "response_sha256":wire.sha(reply["body"]),"non_tools_values_unchanged":True,"origin":origin,
                                   "accounting":accounted,"gate":gate,
                                   "instruction_metric_inclusion":"synthetic_history_priming_excluded" if origin=="exact_fixture_history_replay_no_provider_call" else "subject_provider_request_mock_only"})
            return {"status":200,"headers":reply["headers"],"body_b64":base64.b64encode(reply["body"]).decode()}
        raise ControllerError("unknown case-control operation")

    def summary(self):
        return {"schema_sha256":self.tools_sha256,"retired":self.retired,"receipts":copy.deepcopy(self.receipts),
                "responses":copy.deepcopy(self.responses),"adapter":self.subject.summary(),"model_calls":self.live_attempts,"live_callback_attempts":self.live_attempts,"provider_kind":self.provider_kind,"launch_authorized":self.launch_authorized,"campaign_runs":[],
                "limits":["Live callback requires separate explicit approval, named reviewed profile, budget and parent-only credential; preparation remains mock by default", "Parent/child OS placement requires separate actual CLI proof", "Complete provider/request capture proves delivery, not hidden retention/semantic AC5"]}


class ScriptedCaseMock:
    """Host-only deterministic scripted provider; never opens a network socket."""
    def __init__(self):
        self.guard=None
        self.steps=[]
        self.index=0
        self.raw_exchanges=[]

    def __call__(self,raw,deadline):
        require(self.guard is not None and self.index<len(self.steps),"mock plan exhausted/unbound")
        require(time.monotonic()<deadline,"mock provider deadline")
        step=self.steps[self.index]
        self.index+=1
        identifier="scripted-case-response-"+str(self.index)
        if "message" in step:
            self.guard.FINAL=step["message"]
            body=self.guard.provider_sse(identifier)
        else:
            body=self.guard.provider_sse(identifier,step["tool"],step["arguments"],"scripted-case-call-"+str(self.index))
        self.raw_exchanges.append({"request":raw,"response":body})
        return {"status":200,"headers":{"content-type":"text/event-stream"},"body":body}

    def summary(self):
        return {"scripted_requests":self.index,"script_complete":self.index==len(self.steps),"model_calls":0,
                "exchange_hashes":[{"request_sha256":wire.sha(e["request"]),"response_sha256":wire.sha(e["response"])} for e in self.raw_exchanges]}


def prepare_public_tuning_mock(manifest,case):
    """Offline diagnostic entrypoint, public tuning only; no campaign runner."""
    require(case.get("split")=="tuning" and case.get("id") in {"H1","H2","A1","A2","B1","B2","S1","S2"},"only eight public tuning diagnostic cases allowed")
    from tools import conditional_skill_routing_runner as runner
    cid=case["id"]
    prepared=(runner.prepare_tuning_document_conversation(manifest,case) if cid.startswith("B") else
              runner.prepare_tuning_private_conversation(manifest,case) if cid.startswith("S") else
              runner.prepare_tuning_readonly_broker(manifest,case))
    provider=ScriptedCaseMock()
    controller=CaseController(prepared,provider)
    provider.guard=controller.guard
    provider.steps=[step for phase in schemas.plans(controller.subject,cid) for step in phase]
    return controller,provider
