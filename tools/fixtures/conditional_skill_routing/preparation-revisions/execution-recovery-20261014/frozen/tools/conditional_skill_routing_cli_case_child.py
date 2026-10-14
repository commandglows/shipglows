"""Generic actual Codex CLI child relay; case authority lives in Windows parent.

Imports only frozen public RPC/HTTP helpers and framing codec. No case, manifest,
resource store, runner, adapter, expected answer or credential is supplied here.
Parent validates/filter requests and complete SSE; child preserves exact HTTP
body bytes and actual RPC callback parameters. Native CLI features remain.
"""
import argparse
import base64
import json
import queue
import re
from pathlib import Path
import socketserver
import subprocess
import sys
import threading
import time


def require(ok,message):
    if not ok:raise ValueError(message)


def validate_executable(value):
    require(type(value) is dict and set(value)=={"tools","instructions","initial_turns","schema_sha256","model"},"unknown executable bootstrap")
    require(type(value["instructions"]) is str and type(value["tools"]) is list and 1<=len(value["tools"])<=24,"invalid executable instructions/tools")
    require(type(value["model"]) is str and re.fullmatch(r"[A-Za-z0-9_.:/-]{1,128}",value["model"]),"named exact parent model required")
    names=set()
    for tool in value["tools"]:
        require(type(tool) is dict and set(tool)=={"type","name","description","inputSchema"} and tool["type"]=="function"
                and type(tool["name"]) is str and tool["name"] and tool["name"] not in names
                and type(tool["description"]) is str and type(tool["inputSchema"]) is dict,"invalid registered dynamic schema")
        names.add(tool["name"])
    require(type(value["initial_turns"]) is list and 1<=len(value["initial_turns"])<=12,"invalid initial turns")
    for turn in value["initial_turns"]:
        require(type(turn) is dict and set(turn)=={"role","content"} and turn["role"] in ("user","assistant")
                and type(turn["content"]) is str and turn["content"],"unknown initial native history")
    require(type(value["schema_sha256"]) is str and len(value["schema_sha256"])==64,"schema receipt required")
    return value


def validate_user_turn(turn):
    require(type(turn) is dict and set(turn)=={"role","content"} and turn["role"]=="user"
            and type(turn["content"]) is str and turn["content"],"native user turn required; role conversion forbidden")
    return turn


class Relay:
    def __init__(self,transport,reader,writer,key,capture):
        self.transport,self.reader,self.writer,self.key,self.capture=transport,reader,writer,key,capture
        self.lock=threading.Lock();self.count=0;self.retired=False
    def call(self,op,arguments):
        with self.lock:
            require(not self.retired,"relay retired")
            self.count+=1;require(self.count<=256,"relay request count budget")
            identifier="case-child-%04d"%self.count
            body=self.transport.packed({"op":op,"parameters":arguments})
            raw=self.transport.make_request(identifier,"case-controller",body,self.key)
            self.capture.save(identifier+".request-envelope.bin",raw)
            self.writer.write(self.transport.frame(raw));self.writer.flush()
            try:
                wire=self.transport.read_frame(self.reader)
                self.capture.save(identifier+".response-envelope.bin",wire)
                response=self.transport.read_response(wire,self.key,identifier)
                require(response["status"]==200 and response["headers"].get("content-type")=="application/json","parent controller refused")
                return self.transport.decoded(response["body"])
            except Exception:
                self.retired=True
                raise


def context_loss_reason(event):
    """Pinned structural native signals; transcript strings never trigger loss."""
    if type(event) is not dict:return None
    method=event.get("method")
    params=event.get("params",{})
    if method in ("thread/compacted","thread/contextLost","thread/contextCompacted"):
        return "native_context_loss_notification"
    if type(params) is dict:
        item=params.get("item",{})
        if method in ("item/started","item/completed") and type(item) is dict and item.get("type") in ("contextCompaction","compaction"):
            return "native_context_compaction_item"
        run=params.get("run",{})
        if method in ("hook/started","hook/completed") and type(run) is dict and run.get("eventName") in ("preCompact","postCompact"):
            return "native_context_compaction_hook"
    def opaque(value):
        if type(value) is dict:
            return any((key in ("encrypted_content","encryptedContent") and child not in (None,""))
                       or opaque(child) for key,child in value.items())
        if type(value) is list:return any(opaque(child) for child in value)
        return False
    if opaque(event):return "opaque_native_context"
    return None


class ContextBoundary:
    """Permanent loss retirement; no automatic resume or stale callback release.

    An already admitted parent operation may finish; release is refused afterwards.
    Parent context-loss operation retires its own grants/spans independently.
    """
    def __init__(self,relay,transport):
        self.relay,self.transport=relay,transport
        self.retired=False;self.receipts=[];self.lock=threading.Lock()
    def ensure(self):
        with self.lock:require(not self.retired,"native context loss permanently retired child")
    def release(self,emit):
        """Linearize actual output with retirement, not merely its validation.

        An emission admitted first finishes before retirement; an emission
        ordered after retirement never starts. emit must not reenter boundary.
        """
        with self.lock:
            require(not self.retired,"native context loss permanently retired child")
            return emit()
    def call(self,op,parameters):
        self.ensure()
        result=self.relay.call(op,parameters)
        return self.release(lambda:result)
    def observe(self,event):
        reason=context_loss_reason(event)
        if reason is None:return False
        with self.lock:
            if self.retired:raise ValueError("native context already retired")
            self.retired=True
        record={"reason":reason,"event_sha256":self.transport.sha(self.transport.packed(event)),"parent_retirement_confirmed":False}
        self.receipts.append(record)
        try:
            result=self.relay.call("native_context_loss",{"event":event})
            require(type(result) is dict and set(result)=={"retired","coverage","event_sha256"} and result["retired"] is True
                    and result["coverage"]=="UNKNOWN" and result["event_sha256"]==record["event_sha256"],"parent context retirement unconfirmed")
            record["parent_retirement_confirmed"]=True
        finally:
            self.relay.retired=True
        raise ValueError("native context loss; parent and child permanently retired")


def run(cli,out,dependency_root,transport,profile):
    require(dependency_root.is_absolute() and dependency_root.is_dir(),"read-only dependency root required")
    out.mkdir();capture=profile.Capture(out)
    bootstrap=transport.decoded(transport.read_frame(sys.stdin.buffer,8192))
    require(set(bootstrap)=={"channel_key","parent_probe_path"},"unknown bootstrap fields")
    key=base64.b64decode(bootstrap["channel_key"],validate=True)
    facts=profile.preflight(cli)
    facts.update(parent_sentinel_visible=Path(bootstrap["parent_probe_path"]).exists(),mnt_visible=Path("/mnt").exists(),run_visible=Path("/run").exists(),mountinfo=Path("/proc/self/mountinfo").read_text())
    require(not any(facts[k] for k in ("parent_sentinel_visible","mnt_visible","run_visible")),"parent host exposure")
    def emit(value):sys.stdout.buffer.write(transport.frame(transport.packed(value)));sys.stdout.buffer.flush()
    emit({"type":"preflight","facts":facts})
    relay=Relay(transport,sys.stdin.buffer,sys.stdout.buffer,key,capture)
    boundary=ContextBoundary(relay,transport)
    executable=validate_executable(boundary.call("bootstrap",{}));capture.document("registered-executable.json",executable)
    require(transport.sha(transport.packed(executable["tools"]))==executable["schema_sha256"],"registered schema receipt mismatch")
    # Bounded generic case profile; frozen helper source remains unchanged.
    profile.REQUEST_LIMIT=128
    profile.TOTAL_LIMIT=64*1024*1024
    turn_bound=threading.Event();bound_turn={"id":None};thread_id=None
    receipts=[];budget={"count":0,"bytes":0};callbacks=[];turn_ids=[]
    def callback(params):
        require(turn_bound.wait(5),"callback before actual turn binding")
        result=boundary.call("tool_callback",{"parameters":params})
        require(type(result) is dict and set(result)=={"success","contentItems"} and type(result["success"]) is bool and type(result["contentItems"]) is list,"unknown callback response")
        callbacks.append({"parameters":params,"result":result})
        capture.document("tool-callback-%03d.json"%len(callbacks),callbacks[-1])
        return result
    class Rpc(profile.Rpc):
        def send(self,value):
            return boundary.release(lambda:super(Rpc,self).send(value))
        def collect(self,name,stream):
            count,total=0,0
            try:
                while True:
                    raw=stream.readline(profile.BODY_LIMIT+1)
                    if not raw:break
                    self.capture.save("rpc-%s-%04d.bin"%(name,count),raw)
                    count+=1;total+=len(raw)
                    require(len(raw)<=profile.BODY_LIMIT and total<=profile.STREAM_LIMIT,"RPC admission limit")
                    if name=="stdout":
                        event=transport.decoded(raw);require(type(event) is dict,"RPC object required")
                        self.events.append(event)
                        boundary.observe(event)
                        if event.get("method")=="turn/started":
                            params=event.get("params",{});turn=params.get("turn",{})
                            require(params.get("threadId")==thread_id and type(turn.get("id")) is str,"unknown actual turn identity")
                            boundary.call("begin_turn",{"turn_id":turn["id"]})
                            bound_turn["id"]=turn["id"]
                            turn_bound.set()
                        self.queue.put(event)
            except Exception as error:
                self.errors.append({"type":type(error).__name__,"sha256":transport.sha(str(error).encode())})
                self.queue.put({"capture_failure":True})
            finally:
                if name=="stdout":self.queue.put({"eof":True})
    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            budget["count"]+=1;identifier="cli-http-%03d"%budget["count"]
            record={"id":identifier,"sse_bytes_emitted":0}
            try:
                raw,envelope=profile.read_http(self,capture,identifier,budget,"/v1/responses")
                record.update(envelope)
                require(turn_bound.wait(5),"HTTP before actual turn binding")
                result=boundary.call("model_request",{"body_b64":base64.b64encode(raw).decode()})
                require(type(result) is dict and set(result)=={"status","headers","body_b64"} and type(result["status"]) is int
                        and 100<=result["status"]<=599 and type(result["headers"]) is dict,"unknown parent model response")
                transport._headers(result["headers"],response=True)
                body=base64.b64decode(result["body_b64"],validate=True)
                content_type=result["headers"].get("content-type","")
                require(len(body)<=profile.BODY_LIMIT and content_type in ("application/json","text/event-stream"),"parent response admission")
                capture.save(identifier+".parent-response.bin",body)
                boundary.release(lambda:profile.send_http(self,result["status"],body,content_type))
                record.update(status=result["status"],sent_complete=True,response_sha256=transport.sha(body))
                if content_type=="text/event-stream":record["sse_bytes_emitted"]=len(body)
            except Exception as error:
                record.update(error_type=type(error).__name__,error_sha256=transport.sha(str(error).encode()))
                try:profile.send_http(self,502,b'{"error":"parent-controlled relay refused"}',"application/json")
                except OSError:pass
            finally:receipts.append(record)
    server=socketserver.TCPServer(("127.0.0.1",0),Handler)
    serving=threading.Thread(target=server.serve_forever,daemon=True);serving.start()
    home=out/"synthetic-home";home.mkdir();code_home=home/"codex";code_home.mkdir();project=out/"synthetic-project";project.mkdir()
    config=('tool_output_token_limit=100000\nmodel=%s\nmodel_provider="mock"\napproval_policy="never"\nsandbox_mode="danger-full-access"\n'
            '[analytics]\nenabled=false\n[model_providers.mock]\nname="Parent controlled mock"\nwire_api="responses"\n'
            'base_url="http://127.0.0.1:%d/v1"\nrequires_openai_auth=false\nrequest_max_retries=0\nstream_max_retries=0\n'%(json.dumps(executable["model"]),server.server_address[1]))
    (code_home/"config.toml").write_text(config);capture.save("config.toml",config.encode())
    environment={"HOME":str(home),"CODEX_HOME":str(code_home),"PATH":"/usr/bin:/bin","TMPDIR":str(home),"NO_COLOR":"1","LANG":"C.UTF-8"}
    rpc=None;failure=None;version_ok=False;effective_config=None
    try:
        version=subprocess.run([str(cli),"--version"],env=environment,cwd=project,capture_output=True,timeout=4)
        version_ok=version.returncode==0 and version.stdout.strip()==b"codex-cli 0.160.1"
        require(version_ok,"exact CLI version required")
        rpc=Rpc([str(cli),"app-server","--listen","stdio://"],project,environment,capture,callback)
        rpc.call(1,"initialize",{"clientInfo":{"name":"csr-parent-case","version":"1"},"capabilities":{"experimentalApi":True}})
        rpc.send({"jsonrpc":"2.0","method":"initialized","params":{}})
        effective_config=rpc.call(9000,"config/read",{"includeLayers":False})
        capture.document("effective-config-read.json",effective_config)
        require(effective_config.get("config",{}).get("tool_output_token_limit")==100000,"effective native tool output cap differs")
        require(effective_config.get("config",{}).get("model")==executable["model"],"effective native model differs from parent")
        started=rpc.call(2,"thread/start",{"cwd":str(project),"ephemeral":True,"model":executable["model"],"modelProvider":"mock","approvalPolicy":"never","sandbox":"danger-full-access","dynamicTools":executable["tools"],"baseInstructions":executable["instructions"]})
        thread_id=started["thread"]["id"];boundary.call("bind_thread",{"thread_id":thread_id})
        for index in range(12):
            # Parent releases every initial/current/conditional user turn. Its
            # synthetic prior assistant SSE primes native CLI history separately.
            reply=boundary.call("next_user_turn",{});require(type(reply) is dict and set(reply)=={"turn"},"unknown conditional turn")
            turn=reply["turn"]
            if turn is None:break
            validate_user_turn(turn);turn_bound.clear()
            started=rpc.call(3+index,"turn/start",{"threadId":thread_id,"input":[{"type":"text","text":turn["content"]}]})
            actual=started["turn"]["id"]
            require(turn_bound.wait(5) and bound_turn["id"]==actual,"turn notification/result identity differs")
            turn_ids.append(actual)
            completion=rpc.await_event(lambda e:e.get("method")=="turn/completed" and e.get("params",{}).get("turn",{}).get("id")==actual)
            require(completion["params"]["turn"]["status"]=="completed","native turn failed; conditional continuation refused")
        else:raise ValueError("user turn budget exhausted")
    except Exception as error:failure={"type":type(error).__name__,"sha256":transport.sha(str(error).encode())}
    finally:
        if rpc:rpc.close()
        server.shutdown();serving.join(timeout=2);server.server_close()
    events=rpc.events if rpc else []
    commands=[e for e in events if e.get("method")=="item/completed" and e.get("params",{}).get("item",{}).get("type") in ("commandExecution","fileChange","mcpToolCall","webSearch","collabAgentToolCall")]
    completed=[e["params"]["turn"]["status"] for e in events if e.get("method")=="turn/completed" and e.get("params",{}).get("turn",{}).get("id") in turn_ids]
    capture.document("context-loss-receipts.json",boundary.receipts)
    capture.document("rpc-events.json",{"events":events,"errors":rpc.errors if rpc else [],"failure":failure})
    capture.document("http-receipts.json",receipts);capture.document("callbacks.json",callbacks)
    checks={"version":version_ok,"process_complete":rpc is not None and rpc.process.returncode==0 and not rpc.errors and failure is None,
            "all_turns_complete":bool(turn_ids) and len(completed)==len(turn_ids) and all(s=="completed" for s in completed),"no_native_events":not commands,
            "all_http_replies_bounded":bool(receipts) and all(r.get("sent_complete") and not r.get("error_type") for r in receipts),
            "effective_native_output_cap":effective_config is not None and effective_config.get("config",{}).get("tool_output_token_limit")==100000,
            "network_unshared":facts["interfaces"]==["lo"] and facts["nonloopback_probe_errno"]==101}
    summary={"passed":all(checks.values()),"checks":checks,"failure":failure,"turn_ids":turn_ids,"turn_statuses":completed,
             "context_loss_retired":boundary.retired,"context_loss_receipts":boundary.receipts,
             "http_requests":len(receipts),"callbacks":len(callbacks),"native_events":len(commands),"inventory":capture.inventory.copy(),
             "limits":["Parent exclusively owns case broker/schema filtering/provider response validation", "Native CLI features remain enabled; provider-produced unauthorized calls require parent complete-SSE refusal", "No case/evaluator/adapter/resource files in child dependencies", "Actual model/credential/account launch absent; all configured transport loopback mock"]}
    capture.document("summary.json",summary)
    emit({"type":"complete","summary":summary,"summary_sha256":transport.sha((out/"summary.json").read_bytes())})
    return 0 if summary["passed"] else 1


def main():
    parser=argparse.ArgumentParser();parser.add_argument("--cli",required=True);parser.add_argument("--out",required=True);parser.add_argument("--dep-root",required=True);args=parser.parse_args()
    sys.path.insert(0,args.dep_root)
    from tools import conditional_skill_routing_parent_transport as transport
    from tools import conditional_skill_routing_cli_broker_profile as profile
    raise SystemExit(run(Path(args.cli),Path(args.out),Path(args.dep_root),transport,profile))
if __name__=="__main__":main()
