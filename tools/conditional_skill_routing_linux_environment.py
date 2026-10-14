#!/usr/bin/env python3
"""Provision/access the offline WSL Linux subject and evaluator; never launch a campaign.

Run with WSL Python. Setup reads only the four named public source files.
Subsequent access uses the installed copy, without mounting the checkout.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

ROOT = Path.home() / '.local/share/shipglows-isolated-codex-0.160.1'
URL = 'https://registry.npmjs.org/@openai/codex/-/codex-0.160.1-linux-x64.tgz'
ARCHIVE_SHA = 'dc9ebd133d3af19ccac4bd5515a5049005b8b05ef3bd558d257d44f32a94f758'
INTEGRITY = 'sIDhqV+bsZKKVaVFVY5iB+pAzyOz2XRm3H1KXCsSJwGj5p98qnrT0Fweo1Hfe7WnyTp8mfBNdbVzUeO+mHYugA=='
ELF_SHA = 'f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35'
MEMBER = 'package/vendor/x86_64-unknown-linux-musl/bin/codex'
SOURCES = {
    'spec.md': 'shipglows_data/workflow/specs/conditional-skill-routing-and-minimal-context.md',
    'calibration.md': 'shipglows_data/workflow/reviews/conditional-skill-routing-calibration.md',
    'tools/conditional_skill_routing_eval.py': 'tools/conditional_skill_routing_eval.py',
    'tools/skill_activation_budget.py': 'tools/skill_activation_budget.py',
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def save(path, value):
    with path.open('x', encoding='utf-8') as target:
        json.dump(value, target, indent=2)
        target.write('\n')


def setup(source_root):
    if sys.platform != 'linux' or os.uname().machine != 'x86_64':
        raise RuntimeError('WSL Linux x86_64 is required')
    ROOT.mkdir(parents=True, exist_ok=False, mode=0o700)
    for folder in ('bin', 'subject/.codex', 'evaluator/.codex', 'public/tools', 'public/inputs'):
        (ROOT / folder).mkdir(parents=True, mode=0o700)
    hashes = {}
    for destination, relative in SOURCES.items():
        source = source_root / relative
        if source.is_symlink() or not source.is_file():
            raise RuntimeError('public source is missing or symlinked')
        data = source.read_bytes()
        (ROOT / 'public' / destination).write_bytes(data)
        hashes[relative] = digest(data)
    with tempfile.TemporaryDirectory(prefix='sg-native-codex-') as temp:
        archive = Path(temp) / 'codex.tgz'
        sha256, sha512, total = hashlib.sha256(), hashlib.sha512(), 0
        with urllib.request.urlopen(URL, timeout=30) as response, archive.open('xb') as target:
            if response.geturl() != URL:
                raise RuntimeError('unexpected download redirect')
            while chunk := response.read(1024 * 1024):
                total += len(chunk)
                if total > 200 * 1024 * 1024:
                    raise RuntimeError('archive exceeds fixed size bound')
                sha256.update(chunk)
                sha512.update(chunk)
                target.write(chunk)
        if sha256.hexdigest() != ARCHIVE_SHA or base64.b64encode(sha512.digest()).decode() != INTEGRITY:
            raise RuntimeError('archive integrity mismatch')
        with tarfile.open(archive, 'r:gz') as tar:
            member = tar.getmember(MEMBER)
            if not member.isfile() or member.size != 289166920:
                raise RuntimeError('unexpected native member')
            with tar.extractfile(member) as source, (ROOT / 'bin/codex').open('xb') as target:
                while chunk := source.read(1024 * 1024):
                    target.write(chunk)
    binary = ROOT / 'bin/codex'
    if digest(binary.read_bytes()) != ELF_SHA or binary.read_bytes()[:4] != b'\x7fELF':
        raise RuntimeError('native ELF integrity mismatch')
    binary.chmod(0o500)
    (ROOT / 'environment.py').write_bytes(Path(__file__).read_bytes())
    receipt = {
        'runtime_root': str(ROOT), 'distribution': 'Ubuntu', 'native_version': '0.160.1',
        'archive_url': URL, 'archive_sha256': ARCHIVE_SHA, 'elf_sha256': ELF_SHA,
        'public_source_sha256': hashes, 'network': 'separate empty namespace',
        'model_calls': 0, 'campaign_started': False, 'heldout_loaded': False,
        'independent_semantic_review': False, 'launch_readiness': False,
        'separation': 'disjoint bubblewrap mount, PID, IPC, user and network namespaces; same trusted WSL host',
    }
    save(ROOT / 'installation.json', receipt)
    print(json.dumps(receipt, indent=2))


def command(role, argv):
    receipt = json.loads((ROOT / 'installation.json').read_text())
    if digest((ROOT / 'bin/codex').read_bytes()) != receipt['elf_sha256']:
        raise RuntimeError('installed binary changed')
    for relative, expected in receipt['public_source_sha256'].items():
        destination = next(key for key, value in SOURCES.items() if value == relative)
        if digest((ROOT / 'public' / destination).read_bytes()) != expected:
            raise RuntimeError('frozen public source changed')
    state = ROOT / role
    if state.is_symlink() or not state.is_dir():
        raise RuntimeError('invalid role state directory')
    args = ['/usr/bin/bwrap', '--unshare-all', '--unshare-user', '--disable-userns', '--die-with-parent',
            '--new-session', '--cap-drop', 'ALL', '--clearenv']
    for system in ('/usr', '/bin', '/lib', '/lib64'):
        args += ['--ro-bind', system, system]
    args += ['--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp',
             '--bind', str(state), '/work', '--chdir', '/work',
             '--setenv', 'HOME', '/work', '--setenv', 'CODEX_HOME', '/work/.codex',
             '--setenv', 'PATH', '/opt/bin:/usr/bin:/bin',
             '--setenv', 'TERM', 'xterm-256color',
             '--setenv', 'LANG', 'C.UTF-8', '--setenv', 'PYTHONDONTWRITEBYTECODE', '1']
    if role == 'subject':
        args += ['--ro-bind', str(ROOT / 'bin/codex'), '/opt/bin/codex']
    else:
        args += ['--ro-bind', str(ROOT / 'public'), '/opt/evaluator',
                 '--bind', str(state), '/opt/evaluator/inputs']
    return args + argv


def probe():
    results = {}
    for role in ('subject', 'evaluator'):
        subprocess.run(command(role, ['/usr/bin/python3', '-I', '-B', '-c',
                       f"from pathlib import Path; Path('/work/{role}-only.txt').write_text('synthetic-only')"]),
                       timeout=15, check=True)
    for role in ('subject', 'evaluator'):
        script = '''import json, os, pathlib, socket
role = ROLE
other = 'evaluator' if role == 'subject' else 'subject'
checks = {p: not pathlib.Path(p).exists() for p in
          ('/mnt', '/home/claude', '/run', '/proc/1/root/mnt', '/work/' + other, HOST_ROOT)}
checks['environment_cleared'] = 'SG_ISOLATION_CANARY' not in os.environ
status = dict(line.split(':', 1) for line in pathlib.Path('/proc/self/status').read_text().splitlines() if ':' in line)
checks['no_effective_capabilities'] = int(status['CapEff'].strip(), 16) == 0
checks['no_new_privileges'] = status['NoNewPrivs'].strip() == '1'
checks['only_loopback_interface'] = all(line.split(':')[0].strip() == 'lo' for line in pathlib.Path('/proc/net/dev').read_text().splitlines()[2:])
checks['other_state_marker_absent'] = not pathlib.Path('/work/' + other + '-only.txt').exists()
checks['no_inet_route'] = False
s = socket.socket(); s.settimeout(1)
try: s.connect(('192.0.2.1', 443))
except OSError as exc: checks['no_inet_route'] = exc.errno in (101, 113)
finally: s.close()
checks['other_role_mount_absent'] = not pathlib.Path('/opt/evaluator' if role == 'subject' else '/opt/bin/codex').exists()
pathlib.Path('/work/own-role-probe.txt').write_text(role)
checks['own_state_writable'] = pathlib.Path('/work/own-role-probe.txt').read_text() == role
if role == 'evaluator':
    import sys
    sys.path.insert(0, '/opt/evaluator/tools')
    import conditional_skill_routing_eval as module
    checks['real_evaluator_formula'] = abs(module.family_reduction([100,1000], [60,990]) - .205) < 1e-12
    checks['canonical_input_path_accepted'] = module._cli_path(pathlib.Path('/opt/evaluator/inputs/evaluator-only.txt')).read_text() == 'synthetic-only'
    checks['outside_canonical_input_refused'] = False
    try: module._cli_path(pathlib.Path('/work/evaluator-only.txt'))
    except module.ValidationError: checks['outside_canonical_input_refused'] = True
    checks['frozen_sources_readonly'] = False
    try:
        with pathlib.Path('/opt/evaluator/spec.md').open('r+b'):
            pass
    except OSError as exc: checks['frozen_sources_readonly'] = exc.errno in (13, 30)
else:
    import subprocess
    checks['native_codex_exact_version'] = subprocess.check_output(['/opt/bin/codex', '--version'], text=True).strip() == 'codex-cli 0.160.1'
print(json.dumps({'role': role, 'checks': checks, 'passed': all(checks.values())}))
'''.replace('ROLE', repr(role)).replace('HOST_ROOT', repr(str(ROOT)))
        env = dict(os.environ, SG_ISOLATION_CANARY='synthetic-probe-only')
        result = subprocess.run(command(role, ['/usr/bin/python3', '-I', '-B', '-c', script]),
                                env=env, capture_output=True, text=True, timeout=25)
        if result.returncode:
            print(json.dumps({'role': role, 'passed': False, 'stderr': result.stderr}))
            return 1
        results[role] = json.loads(result.stdout)
    results['scope'] = 'synthetic OS boundary checks; no heldout, agent, model, provider or scoring campaign'
    results['passed'] = all(results[role]['passed'] for role in ('subject', 'evaluator'))
    print(json.dumps(results, indent=2))
    return 0 if results['passed'] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('setup', 'status', 'probe', 'subject', 'evaluator', 'subject-shell', 'evaluator-shell'))
    parser.add_argument('--source-root', type=Path)
    args, extra = parser.parse_known_args()
    if extra[:1] == ['--']:
        extra = extra[1:]
    if args.mode == 'setup':
        if not args.source_root or extra:
            parser.error('setup requires --source-root and no extra arguments')
        setup(args.source_root)
        return 0
    if args.mode == 'status':
        print((ROOT / 'installation.json').read_text())
        return 0
    if args.mode == 'probe':
        return probe()
    role = args.mode.split('-')[0]
    if args.mode.endswith('-shell'):
        argv = ['/bin/bash', '--noprofile', '--norc', *extra]
    elif role == 'subject':
        argv = ['/opt/bin/codex', *(extra or ['--version'])]
    else:
        entry = "import sys; sys.path.insert(0, '/opt/evaluator/tools'); from conditional_skill_routing_eval import main; raise SystemExit(main())"
        argv = ['/usr/bin/python3', '-I', '-B', '-c', entry, *(extra or ['--help'])]
    os.execv('/usr/bin/bwrap', command(role, argv))


if __name__ == '__main__':
    raise SystemExit(main())
