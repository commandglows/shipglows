"""Independent in-session replay of a parent-owned Codex CLI case.

Call before the disposable WSL workspace is deleted. This checker does not
serialize prompts, outputs, arguments, fixtures, provider bodies, or credentials.
"""
import base64
import hashlib
import hmac
import json
import struct
from pathlib import Path


def need(ok, reason):
    if not ok: raise ValueError(reason)


def digest(raw): return hashlib.sha256(raw).hexdigest()


def parse(raw):
    need(type(raw) is bytes, 'expected bytes')
    def pairs(rows):
        out={}
        for key,value in rows:
            need(key not in out, 'duplicate JSON property')
            out[key]=value
        return out
    return json.loads(raw.decode('utf-8'),object_pairs_hook=pairs,
                      parse_constant=lambda _: (_ for _ in ()).throw(ValueError('nonfinite JSON')))


def canonical(value): return json.dumps(value,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode('utf-8')


def registration_schema(schema):
    if type(schema) is list: return [registration_schema(value) for value in schema]
    if type(schema) is not dict: return schema
    result={key:registration_schema(value) for key,value in schema.items() if key!='const'}
    if 'const' in schema:
        value=schema['const']
        kinds={str:'string',bool:'boolean',int:'integer',float:'number',type(None):'null'}
        need(type(value) in kinds,'unsupported immutable schema constant')
        if 'type' in result: need(result['type']==kinds[type(value)],'schema constant type conflict')
        if 'enum' in result: need(result['enum']==[value],'schema constant enum conflict')
        result.update(type=kinds[type(value)],enum=[value])
    return result


def envelope(raw,key):
    value=parse(raw)
    need(type(value) is dict and type(value.get('auth')) is str,'missing envelope authentication')
    unsigned={k:v for k,v in value.items() if k!='auth'}
    expected=hmac.new(key,canonical(unsigned),hashlib.sha256).hexdigest()
    need(hmac.compare_digest(value['auth'],expected),'bad envelope authentication')
    return unsigned


def body(value):
    raw=base64.b64decode(value['body_b64'],validate=True)
    need(digest(raw)==value['body_sha256'],'envelope body digest mismatch')
    return raw


def sse_completed(raw):
    events=[]
    for line in raw.splitlines():
        if not line.startswith(b'data:'): continue
        value=line[5:].strip()
        if not value or value==b'[DONE]': continue
        event=parse(value)
        if event.get('type')=='response.completed': events.append(event.get('response'))
    need(len(events)==1 and type(events[0]) is dict and type(events[0].get('output')) is list,
         'provider exchange lacks one completed response')
    return events[0]


def review(controller, workspace, raw_frames, replies, channel, facts, child_dependencies):
    """Reconstruct native requests, callbacks and returned text before cleanup."""
    need(type(raw_frames) is list and len(raw_frames)==len(replies)>0,'incomplete parent exchange capture')
    calls=[]; requests=[]; callbacks=[]; exchanges=[]; control_ops=[]; cli_replies=[]
    allowed={'version','id','endpoint','headers','body_b64','body_sha256'}
    for raw,reply in zip(raw_frames,replies):
        request=envelope(raw,channel)
        need(set(request)==allowed and request['version']==1 and request['endpoint']=='case-controller','invalid parent request')
        wirebody=body(request)
        operation=parse(wirebody)
        control_ops.append(operation)
        response=envelope(reply,channel)
        need(response['version']==1 and response['id']==request['id'] and response['status']==200,'invalid parent response identity/status')
        response_body=body(response)
        result=parse(response_body)
        if operation['op']=='model_request':
            original=base64.b64decode(operation['parameters']['body_b64'],validate=True)
            requests.append((original,parse(original)))
            response_bytes=base64.b64decode(result['body_b64'],validate=True)
            cli_replies.append(response_bytes)
            exchanges.append((original,response_bytes))
        elif operation['op']=='tool_callback':
            callbacks.append((operation['parameters']['parameters'],result))

    native=[]
    rpc_raw=[]
    for path in sorted((Path(workspace)/'run').glob('rpc-stdout-*.bin')):
        for line in path.read_bytes().splitlines():
            if line: rpc_raw.append(parse(line))
    events=parse((Path(workspace)/'run/rpc-events.json').read_bytes())['events']
    need(events==rpc_raw,'raw native RPC differs from event ledger')
    need(len(events)<=8192,'native event budget')
    compact=('thread/compacted','thread/contextLost','thread/contextCompacted')
    for event in events:
        if event.get('method') in compact: raise ValueError('native context loss observed')
        params=event.get('params',{})
        item=params.get('item',{}) if type(params) is dict else {}
        if event.get('method') in ('item/started','item/completed') and type(item) is dict and item.get('type') in ('contextCompaction','compaction'):
            raise ValueError('native context compaction observed')
        if event.get('method') in ('hook/started','hook/completed') and params.get('run',{}).get('eventName') in ('preCompact','postCompact'):
            raise ValueError('native compaction hook observed')
        if event.get('method')=='item/tool/call': native.append(event.get('params'))
    forbidden={'commandExecution','fileChange','webSearch','mcpToolCall','collabAgentToolCall'}
    need(not any(e.get('method') in ('item/started','item/completed') and e.get('params',{}).get('item',{}).get('type') in forbidden for e in events),
         'native effect event observed')
    need(facts.get('interfaces')==['lo'] and facts.get('nonloopback_probe_errno')==101
         and facts.get('parent_sentinel_visible') is False and facts.get('mnt_visible') is False and facts.get('run_visible') is False,
         'child namespace boundary did not pass')
    config=parse((Path(workspace)/'run/effective-config-read.json').read_bytes())
    need(config.get('config',{}).get('tool_output_token_limit')==100000 and facts.get('cli_sha256'),
         'consumer effective binary/output cap differs')
    need(set(child_dependencies)=={'tools/conditional_skill_routing_cli_broker_profile.py',
                                   'tools/conditional_skill_routing_parent_transport.py'}
         and all(type(row) is dict and type(row.get('sha256')) is str and len(row['sha256'])==64
                 and type(row.get('bytes')) is int and row['bytes']>0 for row in child_dependencies.values()),
         'child dependency allowlist changed')

    provider=list(controller.raw_exchanges)
    need(len(exchanges)==len(provider)==len(controller.responses)==len(cli_replies),'provider model-request chronology differs')
    assistant_text=[]; actual_calls=[]
    model_idx=0
    for (original,request),(captured,exchange),receipt in zip(requests,provider,controller.responses):
        need(original==exchange['original_request'] and captured==exchange['request'] and digest(exchange['response'])==receipt['response_sha256'],
             'provider bytes do not match framed CLI exchange')
        offered=parse(exchange['request'])
        need(digest(original)==receipt['original_request_sha256'] and digest(captured)==receipt['model_request_sha256'],
             'request receipt digest mismatch')
        non_tools={k:v for k,v in request.items() if k!='tools'}
        need(canonical(non_tools)==canonical({k:v for k,v in offered.items() if k!='tools'}),'input/instructions or other request value changed')
        selected=[]
        for registered in controller.tools:
            matches=[tool for tool in request['tools'] if tool.get('name')==registered['name']]
            need(len(matches)==1 and matches[0].get('type')=='function'
                 and canonical(registration_schema(matches[0].get('parameters')))==canonical(registered['inputSchema']),
                 'registered schema differs from actual CLI request')
            selected.append(matches[0])
        need(canonical(offered['tools'])==canonical(selected),'model received altered/widened tool schemas')
        need(receipt['non_tools_values_unchanged'] is True,'controller did not attest unchanged values')
        completed=sse_completed(exchange['response'])
        need(exchange['response']==cli_replies[model_idx],'complete parent response bytes differ from provider bytes')
        for item in completed['output']:
            if item.get('type')=='function_call': actual_calls.append(item)
            if item.get('type')=='message':
                for block in item.get('content',[]):
                    if block.get('type')=='output_text': assistant_text.append(block['text'])
        model_idx+=1
    need(len(actual_calls)==len(native)==len(callbacks)==len(controller.subject.callbacks),'emitted/actual/executed callback counts differ')
    callback_by_id={}
    for call,event_args,(callback,result) in zip(actual_calls,native,callbacks):
        need(event_args==callback and callback['callId']==call['call_id'] and callback['tool']==call['name'],
             'native RPC callback differs from exact emitted model call')
        need(canonical(callback['arguments'])==canonical(parse(call['arguments'].encode())),'callback arguments differ')
        row=controller.subject.callbacks[callback['callId']]
        need(row['delivered'] and row['success']==result['success'],'callback execution ledger differs')
        need(result['contentItems']==[{'type':'inputText','text':row['content']}],'executed callback return differs from parent response')
        callback_by_id[callback['callId']]=row['content']

    for callback_id,text in callback_by_id.items():
        occurrences=[]
        for idx,(_,request) in enumerate(requests):
            matched=[item for item in request.get('input',[]) if item.get('type')=='function_call_output' and item.get('call_id')==callback_id]
            occurrences.extend((idx,item) for item in matched)
        need(occurrences,'executed callback was never sent to model')
        first_callback_idx=next(i for i,op in enumerate(control_ops)
                                if op['op']=='tool_callback' and op['parameters']['parameters']['callId']==callback_id)
        next_model_idx=next((i for i in range(first_callback_idx+1,len(control_ops))
                             if control_ops[i].get('op')=='model_request'),None)
        need(next_model_idx is not None,'callback not followed by a model request')
        before=sum(1 for i in range(next_model_idx) if control_ops[i].get('op')=='model_request')
        need(len([item for idx,item in occurrences if idx==before])==1
             and [item for idx,item in occurrences if idx==before][0].get('output')==text,
             'exact callback result missing from immediately next model request')
        need(all(item.get('output')==text for _,item in occurrences),'callback history changed in later model request')
    http_receipts=parse((Path(workspace)/'run/http-receipts.json').read_bytes())
    need(len(http_receipts)==len(requests),'actual HTTP receipt count differs')
    for index,((original,_),response_bytes,http_row) in enumerate(zip(requests,cli_replies,http_receipts),1):
        request_path=Path(workspace)/('run/cli-http-%03d.request.bin'%index)
        response_path=Path(workspace)/('run/cli-http-%03d.parent-response.bin'%index)
        need(request_path.read_bytes()==original and http_row.get('body_sha256')==digest(original),
             'framed original request differs from actual HTTP bytes')
        need(response_path.read_bytes()==response_bytes and http_row.get('response_sha256')==digest(response_bytes)
             and http_row.get('sent_complete') is True,'parent response differs from bytes emitted to CLI')
    native_assistant=[e['params']['item']['text'] for e in events if e.get('method')=='item/completed'
                      and e.get('params',{}).get('item',{}).get('type')=='agentMessage']
    need(native_assistant==assistant_text==[row['content'] for row in controller.subject.responses],
         'actual assistant response differs from captured complete model output')
    return {'status':'pass','raw_parent_frames':len(raw_frames),'model_requests':len(requests),
            'executed_calls':len(callbacks),'immediate_next_result_delivery':True,'later_history_immutable':True,
            'input_and_instructions_unchanged':True,'registered_schemas_exact':True,'native_effect_events':0,
            'context_loss_events':0,'child_namespace_verified':True,'full_text_retained':False,
            'artifact_hashes':{'controller':digest(canonical(controller.summary())),
                               'workspace_rpc_ledger':digest((Path(workspace)/'run/rpc-events.json').read_bytes()),
                               'request_stream':digest(b''.join(raw_frames)),'response_stream':digest(b''.join(replies))}}
