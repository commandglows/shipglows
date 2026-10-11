"""Bounded public tuning diagnostics with a parent-owned case controller.

CLI entrypoint is mock only. Raw subject/provider traces are temporary; exact
byte replay happens before cleanup. Durable artifacts contain hashes, schemas,
code snapshots and diagnostic receipts. No evaluator payload enters the child.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import threading
import time
from tools.conditional_skill_routing_comparison_case_controller import prepare_public_tuning_mock, CaseController
from tools.conditional_skill_routing_parent_transport import ParentBridge, decoded, frame, packed, read_frame, sha, verify, read_response
from tools.conditional_skill_routing_case_proof_review import review as independent_case_review
from tools.conditional_skill_routing_verified_runtime import verified_runtime, ELF_SHA256, save

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'tools/fixtures/conditional_skill_routing/capture-demonstrations'
CHILD_DEPENDENCIES = ('conditional_skill_routing_cli_broker_profile.py', 'conditional_skill_routing_parent_transport.py')
PARENT_DEPENDENCIES = ('conditional_skill_routing_comparison_case_controller.py', 'conditional_skill_routing_comparison_adapter.py',
    'conditional_skill_routing_responses_accounting.py', 'conditional_skill_routing_cli_tuning_transport_probe.py',
    'conditional_skill_routing_runner.py', 'conditional_skill_routing_eval.py', 'conditional_skill_routing_shared_campaign.py', 'skill_activation_budget.py',
    'conditional_skill_routing_parent_https.py', 'conditional_skill_routing_verified_runtime.py',
    'conditional_skill_routing_case_proof_review.py','conditional_skill_routing_real_comparison_preflight.py')

def require(ok, message):
    if not ok: raise RuntimeError(message)

def capture_inventory(workspace):
    """Hash every ephemeral capture without retaining its content."""
    workspace = Path(workspace)
    require(not workspace.is_symlink() and workspace.is_dir(), 'invalid ephemeral capture workspace')
    workspace = workspace.resolve(strict=True)
    inventory = {}
    for path in sorted(workspace.rglob('*')):
        require(not path.is_symlink(), 'symlink in ephemeral capture workspace')
        if path.is_file():
            raw = path.read_bytes()
            inventory[path.relative_to(workspace).as_posix()] = {'bytes':len(raw), 'sha256':sha(raw)}
    return inventory

def capture_inventory_sha256(inventory):
    require(type(inventory) is dict, 'invalid ephemeral capture inventory')
    return sha(packed(inventory))

def validate_evaluator_receipt(receipt, *, case_id, campaign_id, observation_manifest_sha256):
    """Validate the evaluator's hash-bound, privacy-safe result envelope."""
    required = {'schema_version', 'campaign_id', 'case_id', 'observation_manifest_sha256',
        'status', 'review_id', 'receipt_sha256'}
    require(type(receipt) is dict and set(receipt) == required, 'invalid evaluator receipt shape')
    require(type(receipt['schema_version']) is int and receipt['schema_version'] == 1, 'unsupported evaluator receipt version')
    require(type(receipt['campaign_id']) is str and receipt['campaign_id'] == campaign_id, 'evaluator campaign binding mismatch')
    require(type(receipt['case_id']) is str and receipt['case_id'] == case_id, 'evaluator case binding mismatch')
    require(type(receipt['observation_manifest_sha256']) is str
        and re.fullmatch(r'[0-9a-f]{64}', receipt['observation_manifest_sha256']) is not None
        and receipt['observation_manifest_sha256'] == observation_manifest_sha256, 'evaluator observation binding mismatch')
    require(type(receipt['status']) is str and receipt['status'] in ('PASS', 'FAIL', 'INCONCLUSIVE'), 'invalid evaluator status')
    require(type(receipt['review_id']) is str and re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._:-]{0,127}', receipt['review_id']) is not None,
        'invalid evaluator review identity')
    require(type(receipt['receipt_sha256']) is str and re.fullmatch(r'[0-9a-f]{64}', receipt['receipt_sha256']) is not None,
        'invalid evaluator receipt digest')
    unsigned = {key:value for key,value in receipt.items() if key != 'receipt_sha256'}
    require(receipt['receipt_sha256'] == sha(packed(unsigned)), 'evaluator receipt digest mismatch')
    return dict(receipt)

def evaluate_ephemeral_capture(evaluator, controller, workspace, stage_plan, case_id):
    """Run a trusted evaluator over unchanged temporary captures and bind its result."""
    require(callable(evaluator) and type(stage_plan) is dict, 'trusted evaluator and stage plan required')
    campaign_id = stage_plan.get('campaign_id')
    require(type(campaign_id) is str and campaign_id, 'campaign identity required for evaluator receipt')
    before = capture_inventory(workspace)
    observation_digest = capture_inventory_sha256(before)
    receipt = evaluator(controller, workspace, observation_digest)
    require(capture_inventory(workspace) == before, 'evaluator modified ephemeral capture workspace')
    return validate_evaluator_receipt(receipt, case_id=case_id, campaign_id=campaign_id,
        observation_manifest_sha256=observation_digest)

def semantic_evaluator_passed(mock_only, receipt):
    return mock_only or (type(receipt) is dict and receipt.get('status') == 'PASS')

def linux(path):
    return '/mnt/' + path.drive[0].lower() + path.as_posix()[2:]

def snapshot(output, names):
    inventory = {}
    for name in names:
        source = ROOT / 'tools' / name
        require(source.is_file() and not source.is_symlink(), 'invalid code source')
        raw = source.read_bytes()
        target = output / 'tools' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        inventory['tools/' + name] = {'bytes':len(raw), 'sha256':sha(raw)}
    return inventory

def assert_no_markers(raw, markers):
    """Inspect plaintext and nested framed base64 bodies before transmission."""
    budget = [0]
    def inspect(data, depth):
        budget[0] += len(data)
        require(depth <= 8 and budget[0] <= 32*1024*1024, 'marker inspection bound')
        require(all(marker not in data for marker in markers), 'parent marker in transmitted body')
        try:
            value = decoded(data)
        except (ValueError, UnicodeError):
            # Provider SSE carries JSON data records; escaped strings must be
            # checked after decoding, just like framed control JSON bodies.
            for line in data.splitlines():
                if line.startswith(b'data:'):
                    payload = line[5:].strip()
                    if payload and payload != b'[DONE]': inspect(payload, depth+1)
            return
        def walk(item):
            if isinstance(item, dict):
                for key, child in item.items():
                    if key == 'body_b64':
                        require(type(child) is str, 'invalid encoded body')
                        inspect(base64.b64decode(child, validate=True), depth+1)
                    else: walk(child)
            elif isinstance(item, list):
                for child in item: walk(child)
            elif isinstance(item, str):
                require(all(marker not in item.encode('utf-8') for marker in markers), 'parent marker in JSON string')
        walk(value)
    inspect(raw, 0)

def replay(raw_frames, replies, controller, provider, channel, workspace):
    """Independent byte checks; consume ephemeral traces before deletion."""
    requests = []
    callback_count = 0
    pending = {}
    require(len(raw_frames) == len(replies), 'incomplete framed exchange')
    for raw, reply in zip(raw_frames, replies):
        envelope = verify(decoded(raw), channel)
        body = base64.b64decode(envelope['body_b64'], validate=True)
        require(sha(body) == envelope['body_sha256'], 'request body digest changed')
        value = decoded(body)
        response = read_response(reply, channel, envelope['id'])
        require(response['status'] == 200, 'control response failed')
        result = decoded(response['body'])
        if value['op'] == 'model_request':
            original = base64.b64decode(value['parameters']['body_b64'], validate=True)
            request = decoded(original)
            for cid, content in pending.items():
                matches = [item for item in request['input'] if item.get('type') == 'function_call_output' and item.get('call_id') == cid]
                require(len(matches) == 1 and matches[0].get('output') == content, 'callback missing from immediately next request')
            pending.clear()
            requests.append(request)
        elif value['op'] == 'tool_callback':
            callback_count += 1
            cid = value['parameters']['parameters']['callId']
            row = controller.subject.callbacks[cid]
            require(result['contentItems'][0]['text'] == row['content'], 'callback response bytes changed')
            require(cid not in pending, 'duplicate pending callback')
            pending[cid] = row['content']
    require(not pending, 'callback has no following model request')
    for row in controller.subject.callbacks.values():
        matches = [(index, item) for index, request in enumerate(requests) for item in request['input']
                   if item.get('type') == 'function_call_output' and item.get('call_id') == row['call_id']]
        require(bool(matches) and all(item['output'] == row['content'] for _,item in matches), 'exact callback missing from actual next requests')
        require(row['delivered'], 'callback delivery not acknowledged')
    rpc_raw = [decoded(line) for path in sorted((workspace/'run').glob('rpc-stdout-*.bin'))
               for line in path.read_bytes().splitlines() if line]
    rpc = decoded((workspace/'run/rpc-events.json').read_bytes())['events']
    require(rpc == rpc_raw, 'raw RPC replay differs')
    require(len([row for row in rpc if row.get('method') == 'item/tool/call']) == callback_count, 'actual callback count differs')
    assistant = [row['params']['item']['text'] for row in rpc if row.get('method') == 'item/completed'
                 and row.get('params',{}).get('item',{}).get('type') == 'agentMessage']
    require(assistant == [row['content'] for row in controller.subject.responses], 'native assistant messages differ from captured provider messages')
    require(not any(row.get('params',{}).get('item',{}).get('type') in ('commandExecution','fileChange','webSearch','mcpToolCall')
                    for row in rpc), 'native effect event observed')
    exchanges = getattr(controller, 'raw_exchanges', provider.raw_exchanges if hasattr(provider,'raw_exchanges') else [])
    provider_responses = controller.responses if hasattr(controller,'raw_exchanges') else [
        row for row in controller.responses if row['origin'] != 'exact_fixture_history_replay_no_provider_call']
    for exchange, response in zip(exchanges, provider_responses):
        require(sha(exchange['request']) == response['model_request_sha256'] and sha(exchange['response']) == response['response_sha256'],
                'provider exchange bytes differ')
        if 'original_request' in exchange:
            require(sha(exchange['original_request'])==response['original_request_sha256'], 'original request bytes differ')
            original, offered = decoded(exchange['original_request']), decoded(exchange['request'])
            require(packed({key:value for key,value in original.items() if key!='tools'})==packed({key:value for key,value in offered.items() if key!='tools'}),
                    'non-tools request values changed')
            selected=[]
            for registered in controller.tools:
                matches=[tool for tool in original['tools'] if tool.get('name')==registered['name']]
                require(len(matches)==1 and matches[0].get('type')=='function'
                        and packed(matches[0].get('parameters'))==packed(registered['inputSchema']), 'registered case schema differs')
                selected.append(matches[0])
            require(packed(offered['tools'])==packed(selected), 'offered case schemas differ')
    require(len(exchanges) == len(provider_responses),
            'provider exchange accounting incomplete')
    return {'exact_authenticated_exchanges':True, 'actual_rpc_replayed':True, 'callbacks':callback_count,
            'requests':len(requests), 'exact_callbacks_in_immediately_next_request':True,
            'exact_callbacks_in_subsequent_requests':True, 'native_effect_events':0,
            'native_assistant_messages_exact':True, 'assistant_messages':len(assistant)}

def _execute(label, case_id, *, trusted_controller=None, evaluator=None, stage_plan=None):
    require(os.name == 'nt', 'Windows parent required')
    require(type(label) is str and label.replace('-','').isalnum(), 'invalid proof label')
    require(case_id in ('H1','H2','A1','A2','B1','B2','S1','S2'), 'public tuning diagnostics only')
    output = BASE / label
    output.mkdir(exist_ok=False)
    (output/'launcher-source-snapshot.py').write_bytes(Path(__file__).read_bytes())
    child = output/'child-source-snapshot.py'
    child.write_bytes((ROOT/'tools/conditional_skill_routing_cli_case_child.py').read_bytes())
    dependencies = output/'child-dependencies'
    child_inventory = snapshot(dependencies, CHILD_DEPENDENCIES)
    parent_inventory = snapshot(output/'parent-code-snapshots', PARENT_DEPENDENCIES)
    require(independent_case_review.__globals__['LOADED_SOURCE_SHA256']==parent_inventory['tools/conditional_skill_routing_case_proof_review.py']['sha256'],
            'independent reviewer changed after import; refusing source drift')
    manifest_raw = (ROOT/'tools/fixtures/conditional_skill_routing/manifest.json').read_bytes()
    cases_raw = (ROOT/'tools/fixtures/conditional_skill_routing/cases.json').read_bytes()
    (output/'parent-baseline-manifest.json').write_bytes(manifest_raw)
    (output/'parent-public-tuning-cases.json').write_bytes(cases_raw)
    case = next(row for row in decoded(cases_raw)['cases'] if row['id'] == case_id)
    if trusted_controller is None:
        controller, provider = prepare_public_tuning_mock(decoded(manifest_raw), case)
    else:
        controller, provider = trusted_controller, trusted_controller.provider_callback
    mock_only = controller.provider_kind == 'mock'
    channel, receipt_key = os.urandom(32), os.urandom(32)
    bridge = ParentBridge('case-controller', controller.handle, channel_key=channel, receipt_key=receipt_key,
        max_requests=512, max_body=2*1024*1024, max_response=4*1024*1024,
        total_body=128*1024*1024, total_response=128*1024*1024, callback_timeout=30, session_timeout=290)
    save(output/'source-bindings.json', {'child_sha256':sha(child.read_bytes()), 'child_dependencies':child_inventory,
         'parent_dependencies':parent_inventory, 'baseline_manifest_sha256':sha(manifest_raw), 'public_cases_sha256':sha(cases_raw)})
    errors, events, raw_frames, replies, stderr_chunks = [], [], [], [], []
    facts, child_summary, raw_audit, independent_audit, raw_inventory = {}, {}, {}, {}, {}
    evaluation_receipt = None
    process, timer, collector = None, None, None
    fake_credential = b'FAKE_CASE_PARENT_CREDENTIAL_NOT_SENT_01601'
    fake_evaluator = b'FAKE_CASE_PARENT_EVALUATOR_NOT_SENT_01601'
    markers = (fake_credential, fake_evaluator, receipt_key) + (() if mock_only else (provider.credential.encode(),))
    transmitted_hashes = []
    with verified_runtime(output) as (binary, folder):
        workspace = folder/'subject-output'; workspace.mkdir()
        sentinel = folder/'parent-only-sentinel.json'
        sentinel.write_bytes(packed({'credential':fake_credential.decode(), 'evaluator':fake_evaluator.decode()}))
        command = ['/usr/bin/bwrap','--unshare-all','--die-with-parent','--new-session','--clearenv']
        for system in ('/usr','/bin','/lib','/lib64'): command += ['--ro-bind',system,system]
        command += ['--proc','/proc','--dev','/dev','--tmpfs','/tmp','--bind',linux(workspace),'/work',
            '--ro-bind',linux(dependencies),'/dependency-root','--ro-bind',linux(child),'/probe.py',
            '--ro-bind',linux(binary),'/codex','--chdir','/work','--setenv','HOME','/work',
            '--setenv','PATH','/usr/bin:/bin','--setenv','LANG','C.UTF-8',
            '/usr/bin/python3','-B','/probe.py','--cli','/codex','--out','/work/run','--dep-root','/dependency-root']
        require(mock_only or provider.deadline-time.monotonic()>=30, 'live provider deadline too short after verified runtime preparation')
        argv = ['wsl','-d','Ubuntu','--','/usr/bin/env','-i','PATH=/usr/bin:/bin','/usr/bin/timeout',
                '--signal=TERM','--kill-after=5s','280s',*command]
        save(output/'launch.json', {'argv':argv, 'windows_watchdog_seconds':305, 'mock_only':mock_only,
             'case_broker_and_evaluator_mounted':False, 'child_code_dependencies':list(CHILD_DEPENDENCIES),
             'raw_subject_capture_ephemeral':True})
        try:
            process = subprocess.Popen(argv,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            timer = threading.Timer(305,process.kill); timer.start()
            def collect():
                size = 0
                while raw := process.stderr.read1(4096):
                    size += len(raw)
                    if size > 256*1024:
                        errors.append({'type':'stderr_admission_limit'}); process.kill(); return
                    stderr_chunks.append(raw)
            collector = threading.Thread(target=collect,daemon=True); collector.start()
            bootstrap = packed({'channel_key':base64.b64encode(channel).decode(), 'parent_probe_path':linux(sentinel)})
            assert_no_markers(bootstrap, markers)
            process.stdin.write(frame(bootstrap)); process.stdin.flush()
            while raw := read_frame(process.stdout,8*1024*1024+4096):
                require(len(events)+len(raw_frames)<514, 'control frame count bound')
                value = decoded(raw)
                assert_no_markers(raw, markers)
                transmitted_hashes.append(sha(raw))
                if value.get('type') == 'preflight':
                    require(not facts, 'repeated child preflight'); facts = value['facts']; events.append('preflight'); continue
                if value.get('type') == 'complete':
                    require(not child_summary, 'repeated child completion'); child_summary = value['summary']; events.append('complete'); continue
                require(bool(facts) and not child_summary, 'control call outside running child')
                raw_frames.append(raw)
                wire = bridge.handle(raw)
                assert_no_markers(wire, markers)
                replies.append(wire)
                transmitted_hashes.append(sha(wire))
                process.stdin.write(frame(wire)); process.stdin.flush()
            process.wait(timeout=5)
            collector.join(timeout=5)
            require(not collector.is_alive(), 'stderr collector remains active')
            require(child_summary.get('passed') is True and process.returncode == 0, 'child case execution failed')
            raw_audit = replay(raw_frames,replies,controller,provider,channel,workspace)
            independent_audit = independent_case_review(raw_frames,replies,controller,workspace,channel,facts,
                child_dependencies=child_inventory,expected_cli_sha256=ELF_SHA256)
            if not mock_only:
                # The trusted evaluator consumes raw observations before deletion.
                # Only its hash-bound, content-free verdict becomes durable.
                evaluation_receipt = evaluate_ephemeral_capture(
                    evaluator, controller, workspace, stage_plan, case_id)
        except Exception as error:
            errors.append({'type':type(error).__name__, 'sha256':sha(str(error).encode())})
            controller.retired = True
        finally:
            if timer: timer.cancel()
            if process and process.poll() is None: process.kill(); process.wait(timeout=5)
            if collector: collector.join(timeout=5)
            if process:
                for stream in (process.stdin,process.stdout,process.stderr):
                    if stream and not stream.closed: stream.close()
            raw_inventory = capture_inventory(workspace)
            require(all(verify(row,receipt_key) for row in bridge.receipts), 'parent receipt signatures invalid')
    controller_summary = controller.summary()
    prepared = controller.subject.prepared
    redaction = (prepared.redaction.receipts[-1]['redaction'] == 'pass') if hasattr(prepared,'redaction') and prepared.redaction and prepared.redaction.receipts else None
    save(output/'controller-summary.json',controller_summary)
    provider_summary = provider.summary() if mock_only else {'model_calls':controller.live_attempts, 'receipts':provider.receipts}
    save(output/'provider-summary.json',provider_summary)
    messages = controller.subject.responses if mock_only else [
        {key:value for key,value in row.items() if key!='content'} for row in controller.subject.responses]
    save(output/'subject-output-receipts.json', {'origin':'scripted synthetic subject output, not a real model' if mock_only else 'authorized real baseline observation; content evaluator-only',
         'messages':messages, 'private_redaction_pass':redaction})
    save(output/'parent-transport-receipts.json',decoded(bridge.durable_receipts()))
    save(output/'independent-case-proof-review.json',independent_audit)
    if evaluation_receipt is not None:
        save(output/'semantic-evaluation-receipt.json',evaluation_receipt)
    save(output/'ephemeral-raw-inventory.json', {'artifacts':raw_inventory,'control_request_sha256':[sha(row) for row in raw_frames],
         'control_response_sha256':[sha(row) for row in replies],
         'raw_removed':decoded((output/'temporary-runtime-cleanup.json').read_bytes())['exists_after_cleanup'] is False, 'verification':raw_audit,
         'stderr_sha256':sha(b''.join(stderr_chunks)), 'transmitted_sha256':transmitted_hashes})
    checks = {'process_success':process is not None and process.returncode == 0 and not errors,
        'child_checks':child_summary.get('passed') is True,
        'provider_complete':provider_summary['script_complete'] if mock_only else controller.live_attempts>0,
        'all_callbacks_exactly_delivered':bool(controller.subject.callbacks) and all(row['delivered'] for row in controller.subject.callbacks.values()),
        'parent_case_not_retired':not controller.retired, 'raw_rpc_and_callback_replay':bool(raw_audit),
        'no_host_or_evaluator_mount':list(child_inventory)==['tools/'+name for name in CHILD_DEPENDENCIES],
        'loopback_only':facts.get('interfaces')==['lo'] and facts.get('nonloopback_probe_errno')==101,
        'exact_ELF':facts.get('cli_sha256')==ELF_SHA256, 'raw_and_runtime_removed':decoded((output/'temporary-runtime-cleanup.json').read_bytes())['exists_after_cleanup'] is False,
        'private_redaction':not case_id.startswith('S') or redaction is True,
        'declared_provider_posture':(controller_summary['model_calls']==0 and controller_summary['campaign_runs']==[]) if mock_only else controller.launch_authorized,
        'semantic_evaluator_pass':semantic_evaluator_passed(mock_only,evaluation_receipt)}
    inventory = {str(path.relative_to(output)).replace('\\','/'):{'bytes':path.stat().st_size,'sha256':sha(path.read_bytes())}
                 for path in output.rglob('*') if path.is_file()}
    summary = {'passed':all(checks.values()), 'checks':checks, 'case_id':case_id, 'errors':errors,
        'child_summary':{key:value for key,value in child_summary.items() if key!='inventory'}, 'parent_raw_audit':raw_audit,
        'inventory':inventory, 'mock_only':mock_only, 'model_calls':controller.live_attempts,
        'independent_case_review':independent_audit, 'semantic_evaluation':evaluation_receipt,
        'campaign_runs':[] if mock_only else [{'campaign_id':stage_plan['campaign_id'],'phase':'baseline_tuning','case_id':case_id}],
        'limits':['Scripted public tuning diagnostics, not observed baseline or model compliance' if mock_only else 'Real baseline requires distinct semantic evaluator verdict; transport pass is not case success',
                  'Raw synthetic subject/provider captures verified before ephemeral removal',
                  'Live evaluator receipt integrity binds case, campaign and ephemeral capture hashes but does not authenticate reviewer identity',
                  'No hidden retention, semantic AC5 or real-provider/account proof']}
    save(output/'summary.json',summary)
    print(json.dumps({'passed':summary['passed'], 'summary_sha256':sha((output/'summary.json').read_bytes()), 'output':str(output)}))
    return 0 if summary['passed'] else 1

def execute_prepared_controller(label, case_id, controller, approved_stage_plan, *, explicit_launch_authorized=False, evaluator=None):
    """Future single fresh baseline subject. No credential lookup or auto launch.

    The operator must supply a reviewed, launch-ready stage plan and an already
    authorized parent HTTPS controller. This callable is not exposed by the
    mock-only CLI entrypoint. The evaluator receives (controller, workspace,
    observation_manifest_sha256) and must return the strict schema-v1 receipt;
    only its content-free PASS/FAIL/INCONCLUSIVE result is retained.
    """
    from tools.conditional_skill_routing_real_comparison_preflight import check
    require(explicit_launch_authorized is True and type(controller) is CaseController
            and controller.provider_kind=='live' and controller.launch_authorized, 'explicit authorized live controller required')
    require(type(approved_stage_plan) is dict and check(approved_stage_plan)['ready_to_launch_baseline'] is True,
            'reviewed launch-ready baseline stage required')
    require(case_id in ('H1','H2','A1','A2','B1','B2','S1','S2') and callable(evaluator), 'public baseline case and trusted evaluator required')
    require(not controller.bootstrapped and not controller.thread_bound and not controller.retired and not controller.receipts
            and controller.live_attempts==0 and controller.provider_callback.calls==0, 'fresh unused subject and callback required')
    plan_provider = approved_stage_plan['provider']
    profile = controller.approved_profile
    require(profile['endpoint']==plan_provider['endpoint'] and profile['model']==plan_provider['model']
            and profile['settings_sha256']==plan_provider['settings_sha256']
            and profile['account_label']==plan_provider.get('account_label'), 'approved selected account/model/settings differ')
    require(approved_stage_plan['consumer']['binary_sha256']==ELF_SHA256 and approved_stage_plan['consumer']['version']=='0.160.1', 'pinned consumer required')
    profile_path = ROOT/'tools/fixtures/conditional_skill_routing/preparation-revisions/codex-linux-real-v3-consumer-profile.json'
    require(profile_path.is_file() and sha(profile_path.read_bytes())==approved_stage_plan['consumer']['profile_sha256'], 'exact frozen consumer profile required')
    for path,digest in decoded(profile_path.read_bytes())['code_sha256'].items():
        source=(ROOT/path).resolve()
        require(source.is_relative_to(ROOT) and sha(source.read_bytes())==digest, 'consumer source drift before launch')
    public_root=ROOT/'tools/fixtures/conditional_skill_routing'
    manifest=decoded((public_root/'manifest.json').read_bytes())
    case=next(row for row in decoded((public_root/'cases.json').read_bytes())['cases'] if row['id']==case_id)
    expected,_=prepare_public_tuning_mock(manifest,case)
    require(controller.tools_sha256==expected.tools_sha256
            and packed(controller.subject.mcp.broker.bundle)==packed(expected.subject.mcp.broker.bundle),
            'controller executable case differs from approved public baseline slot')
    budget=approved_stage_plan['budget']; callback=controller.provider_callback
    require(callback.max_calls<=budget['max_provider_requests'] and callback.total_output_limit<=budget['max_tokens']
            and callback.deadline-time.monotonic()<=budget['max_seconds'], 'callback exceeds approved stage ceilings')
    require(callable(callback.input_cost_budget_guard)
            and type(callback.verified_model_ceiling) is dict
            and callback.verified_model_ceiling.get('model')==plan_provider['model']
            and type(callback.verified_model_ceiling.get('max_output_tokens')) is int
            and callback.verified_model_ceiling['max_output_tokens']<=budget['max_tokens']
            and callback.verified_model_ceiling.get('review_id')
            and callback.approved_budget.get('review_id')==budget.get('review_id'),
            'reviewed input/cost admission and model-output ceilings must match the selected budget')
    return _execute(label,case_id,trusted_controller=controller,evaluator=evaluator,stage_plan=approved_stage_plan)

def execute(label, case_id):
    """Keep a hash-only failure receipt, including pre-launch setup failures."""
    require(type(label) is str and label.replace('-','').isalnum(), 'invalid proof label')
    output = BASE / label
    require(not output.exists(), 'proof label already exists')
    try:
        return _execute(label, case_id)
    except Exception as error:
        if output.is_dir() and not (output/'summary.json').exists():
            cleanup = output/'temporary-runtime-cleanup.json'
            removed = decoded(cleanup.read_bytes())['exists_after_cleanup'] is False if cleanup.exists() else None
            summary = {'passed':False, 'case_id':case_id, 'mock_only':True, 'model_calls':0, 'campaign_runs':[],
                       'errors':[{'type':type(error).__name__, 'sha256':sha(str(error).encode())}],
                       'raw_and_runtime_removed':removed, 'failure_phase':'setup_or_finalization'}
            save(output/'summary.json', summary)
            print(json.dumps({'passed':False, 'summary_sha256':sha((output/'summary.json').read_bytes()), 'output':str(output)}))
        return 1

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--label',required=True)
    parser.add_argument('--case',required=True,choices=['H1','H2','A1','A2','B1','B2','S1','S2'])
    args = parser.parse_args()
    raise SystemExit(execute(args.label,args.case))

if __name__ == '__main__': main()
