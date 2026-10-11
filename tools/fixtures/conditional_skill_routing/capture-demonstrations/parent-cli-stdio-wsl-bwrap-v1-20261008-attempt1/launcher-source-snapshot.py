"""Windows parent integrated mock proof launcher; no real provider or credential.

Verified official ELF temporary only. Trusted parent callback and fake evaluator
sentinel stay outside namespace. Complete provider SSE validated before pipe
release; parent-only receipt key never crosses bootstrap. Read-only source
snapshots and bounded WSL process watchdog; proof output is sole writable mount.
"""
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import threading
import time
import urllib.request
from tools import conditional_skill_routing_cli_broker_profile as broker
from tools.conditional_skill_routing_parent_transport import ParentBridge,ToolResponsePolicy,TransportError,authenticated,decoded,frame,make_request,packed,read_frame,sha,verify
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'tools/fixtures/conditional_skill_routing/capture-demonstrations'
EXPECTED='f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35'
DEPENDENCIES=('conditional_skill_routing_cli_broker_profile.py','conditional_skill_routing_parent_transport.py')

def save(path,value):
    with path.open('xb') as f:f.write(packed(value))
def linux(path):return '/mnt/'+path.drive[0].lower()+path.as_posix()[2:]
def require(ok,message):
    if not ok:raise RuntimeError(message)


def execute(label):
    require(os.name=='nt','Windows trusted parent required')
    require(type(label) is str and label.replace('-','').isalnum(),'invalid label')
    out=BASE/label;out.mkdir(exist_ok=False)
    save(out/'launch-authority.json',{'mock_only':True,'real_provider':False,'launch_authorized':False,'date':'2026-10-08'})
    (out/'launcher-source-snapshot.py').write_bytes(Path(__file__).read_bytes())
    source=ROOT/'tools/conditional_skill_routing_cli_parent_transport_probe.py'
    snapshot=out/'source-snapshot.py';snapshot.write_bytes(source.read_bytes())
    deps=out/'dependency-root';(deps/'tools').mkdir(parents=True)
    inventory={}
    for name in DEPENDENCIES:
        raw=(ROOT/'tools'/name).read_bytes();(deps/'tools'/name).write_bytes(raw)
        inventory[name]={'bytes':len(raw),'sha256':sha(raw)}
    save(out/'dependency-receipt.json',{'inventory':inventory,'readonly_mount':'/dependency-root'})
    workspace=out/'workspace';workspace.mkdir()
    old=json.loads((BASE/'codex-linux-cli-v1-20261007-attempt2/download-receipt.json').read_text())
    start=time.monotonic()
    process=None;timer=None;stderr_thread=None;errors=[];events=[];stderr_chunks=[]
    channel=b'synthetic-parent-cli-channel-00001'
    receipt=b'synthetic-parent-cli-receipt-00002'
    fake_credential=b'FAKE_PARENT_CREDENTIAL_NEVER_CHILD_01601'
    evaluator=b'FAKE_EVALUATOR_NEVER_CHILD_01601'
    request_count=0;callbacks={};provider_inventory=[]
    def callback(raw,deadline):
        nonlocal request_count
        require(time.monotonic()<deadline,'expired mock callback')
        request_count+=1;i=request_count-1
        require(i<5,'unexpected model request')
        request=decoded(raw)
        require(type(request) is dict and type(request.get('input')) is list,'unknown model request')
        require([t.get('name') for t in request.get('tools',[])]==broker.NAMES and all(t['parameters']==s for t,s in zip(request['tools'],broker.SCHEMAS)),'changed advertised model tools')
        outputs=[v for v in request['input'] if type(v) is dict and v.get('type')=='function_call_output']
        results={v.get('call_id'):broker.output_text(v) for v in outputs}
        require(len(results)==len(outputs) and set(results)==set(broker.CALLS[:min(i,3)]),'unknown or missing callback outputs')
        for j in range(min(i,3)):
            require(results[broker.CALLS[j]]==broker.REPLIES[j],'exact callback output changed')
            callbacks[broker.CALLS[j]]=sha(results[broker.CALLS[j]].encode())
        identifier='windows-model-%03d'%request_count
        (out/(identifier+'.request.bin')).write_bytes(raw)
        if i<3:body=broker.provider_sse(identifier,broker.NAMES[i],broker.ARGUMENTS[i],broker.CALLS[i])
        elif i==3:body=broker.provider_sse(identifier)
        else:
            require(any(broker.SECOND in v for v in broker.text_values(request)),'second turn absent')
            body=broker.provider_sse(identifier,'exec_command',{'cmd':'/usr/bin/touch NATIVE_TOOL_MUST_NOT_EXECUTE'},'call_native_parent_denied')
        (out/(identifier+'.response.bin')).write_bytes(body)
        provider_inventory.append({'id':identifier,'request_sha256':sha(raw),'response_sha256':sha(body),'callback_sha256':dict(callbacks)})
        return {'status':200,'headers':{'content-type':'text/event-stream'},'body':body}
    with tempfile.TemporaryDirectory(prefix='sg-parent-cli-mock-') as temp:
        folder=Path(temp)
        save(out/'temporary-runtime-created.json',{'temporary_folder':str(folder),'installed_globally':False})
        sentinel=folder/'parent-only-state.json';sentinel.write_bytes(packed({'credential':fake_credential.decode(),'evaluator':evaluator.decode()}))
        archive = folder / 'codex.tgz'
        sha256, sha512 = hashlib.sha256(), hashlib.sha512()
        total = 0
        request = urllib.request.Request(old['tarball_url'], headers={'User-Agent': 'ShipGlows-mock-proof'})
        with urllib.request.urlopen(request, timeout=30) as response, archive.open('xb') as target:
            if response.geturl() != old['tarball_url']:
                raise RuntimeError('unexpected redirect')
            while chunk := response.read(1024 * 1024):
                total += len(chunk)
                if total > 512 * 1024 * 1024 or time.monotonic() - start > 180:
                    raise RuntimeError('download bound')
                sha256.update(chunk)
                sha512.update(chunk)
                target.write(chunk)
        if sha256.hexdigest() != old['archive_sha256'] or 'sha512-' + base64.b64encode(sha512.digest()).decode() != old['integrity']:
            raise RuntimeError('archive integrity mismatch')
        binary = folder / 'codex'
        with tarfile.open(archive, 'r:gz') as tar:
            member = tar.getmember(old['member'])
            if not member.isfile() or member.size != old['elf_bytes']:
                raise RuntimeError('unexpected ELF member')
            with tar.extractfile(member) as inp, binary.open('xb') as target:
                while chunk := inp.read(1024 * 1024):
                    target.write(chunk)
        if hashlib.sha256(binary.read_bytes()).hexdigest() != EXPECTED:
            raise RuntimeError('ELF hash mismatch')
        save(out / 'download-receipt.json', {**old, 'temporary_folder': str(folder), 'archive_bytes': total, 'reverified': True})
        bridge=ParentBridge('responses-fixture',callback,channel_key=channel,receipt_key=receipt,
                            response_policy=ToolResponsePolicy(set(broker.NAMES)),max_requests=6,
                            max_body=broker.BODY_LIMIT,max_response=broker.BODY_LIMIT,
                            callback_timeout=5,session_timeout=170)
        command=['/usr/bin/bwrap','--unshare-all','--die-with-parent','--new-session','--clearenv']
        for system in ('/usr','/bin','/lib','/lib64'):command+=['--ro-bind',system,system]
        command+=['--proc','/proc','--dev','/dev','--tmpfs','/tmp','--bind',linux(workspace),'/work',
                  '--ro-bind',linux(deps),'/dependency-root','--ro-bind',linux(snapshot),'/probe.py',
                  '--ro-bind',linux(binary),'/codex','--chdir','/work','--setenv','HOME','/work',
                  '--setenv','PATH','/usr/bin:/bin','--setenv','LANG','C.UTF-8',
                  '/usr/bin/python3','-B','/probe.py','--cli','/codex','--out','/work/run']
        argv=['wsl','-d','Ubuntu','--','/usr/bin/env','-i','PATH=/usr/bin:/bin','/usr/bin/timeout','--signal=TERM','--kill-after=5s','150s',*command]
        save(out/'launch.json',{'argv':argv,'windows_watchdog_seconds':165,'source_sha256':sha(snapshot.read_bytes()),'parent_mock_only':True})
        try:
            process=subprocess.Popen(argv,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            timer=threading.Timer(165,process.kill);timer.start()
            def collect_stderr():
                total=0
                while raw:=process.stderr.read1(4096):
                    total+=len(raw)
                    if total>256*1024:process.kill();errors.append('stderr cap');return
                    stderr_chunks.append(raw)
            stderr_thread=threading.Thread(target=collect_stderr,daemon=True);stderr_thread.start()
            bootstrap=packed({'channel_key':base64.b64encode(channel).decode(),'parent_probe_path':linux(sentinel)})
            require(all(marker not in bootstrap for marker in (fake_credential,evaluator,receipt)),'parent marker in bootstrap')
            (out/'bootstrap-frame.bin').write_bytes(frame(bootstrap));process.stdin.write(frame(bootstrap));process.stdin.flush()
            while True:
                raw=read_frame(process.stdout,2*broker.BODY_LIMIT+4096)
                if raw is None:break
                (out/('child-frame-%03d.bin'%len(events))).write_bytes(frame(raw))
                value=decoded(raw);events.append(value)
                require(len(events)<=7,'child frame count cap')
                if value.get('type') in ('preflight','complete'):continue
                try:wire=bridge.handle(raw)
                except TransportError:
                    require(request_count==5 and bridge.receipts[-1]['status']=='refused' and bridge.receipts[-2]['status']=='response_policy_error','unexpected parent refusal')
                    signed=authenticated({'version':1,'id':value['id'],'status':502,'headers':{'content-type':'application/json'},
                        'body_b64':base64.b64encode(b'{"error":"parent refused unauthorized provider response"}').decode(),
                        'body_sha256':sha(b'{"error":"parent refused unauthorized provider response"}')},channel)
                    wire=packed(signed)
                (out/('parent-frame-%03d.bin'%request_count)).write_bytes(frame(wire))
                process.stdin.write(frame(wire));process.stdin.flush()
            process.wait(timeout=5);stderr_thread.join(timeout=5)
            require(not stderr_thread.is_alive(),'stderr reader live')
        except Exception as error:errors.append(type(error).__name__+': '+str(error))
        finally:
            if timer:timer.cancel()
            if process and process.poll() is None:process.kill();process.wait(timeout=5)
            if stderr_thread:stderr_thread.join(timeout=5)
            if process:
                for stream in (process.stdin,process.stdout,process.stderr):
                    if stream and not stream.closed:stream.close()
            (out/'namespace-stderr.bin').write_bytes(b''.join(stderr_chunks))
            (out/'parent-durable-receipts.json').write_bytes(bridge.durable_receipts())
            save(out/'provider-observations.json',provider_inventory)
            save(out/'process-receipt.json',{'exit_code':process.returncode if process else None,'errors':errors})
        require(all(verify(row,receipt) for row in bridge.receipts),'parent receipt HMAC failed')
    save(out/'temporary-runtime-cleanup.json',{'temporary_folder':str(folder),'exists_after_cleanup':folder.exists(),'installed_globally':False})
    preflight=next((v.get('facts') for v in events if v.get('type')=='preflight'),{})
    final=next((v.get('summary') for v in events if v.get('type')=='complete'),{})
    emitted=b''.join((out/name).read_bytes() for name in [p.name for p in out.glob('parent-frame-*.bin')])+b''.join((out/p.name).read_bytes() for p in out.glob('child-frame-*.bin'))+(out/'bootstrap-frame.bin').read_bytes()
    checks={'process_success':process is not None and process.returncode==0 and not errors,
            'child_integrated_checks':final.get('passed') is True,
            'parent_exact_three_callback_outputs':len(callbacks)==3 and request_count==5,
            'parent_four_streams_forwarded_fifth_refused':len([r for r in bridge.receipts if r.get('status')=='forwarded'])==4 and bridge.receipts[-1].get('status')=='refused',
            'parent_only_markers_not_transmitted':all(m not in emitted for m in (fake_credential,evaluator,receipt)),
            'network_unshared':preflight.get('interfaces')==['lo'] and preflight.get('nonloopback_probe_errno')==101,
            'parent_state_and_ELF_removed':not folder.exists(),
            'ELF_verified':preflight.get('cli_sha256')==EXPECTED}
    files={str(p.relative_to(out)).replace('\\','/'):{'bytes':p.stat().st_size,'sha256':sha(p.read_bytes())} for p in out.rglob('*') if p.is_file()}
    summary={'passed':all(checks.values()),'checks':checks,'inventory':files,'mock_only':True,
             'limits':['Current native CLI catalog remains; parent complete-SSE gate prevents unauthorized provider-produced calls',
                       'All provider responses and credentials/evaluator markers synthetic; no real launch/campaign/AC5 proof']}
    save(out/'summary.json',summary)
    print(json.dumps({'passed':summary['passed'],'summary_sha256':sha((out/'summary.json').read_bytes()),'output':str(out)}))
    return 0 if summary['passed'] else 1

def main():
    import argparse
    parser=argparse.ArgumentParser();parser.add_argument('--label',required=True);args=parser.parse_args()
    raise SystemExit(execute(args.label))
if __name__=='__main__':main()
