"""Bounded verified-ELF launcher for operator-authorized mock preparation proofs only."""
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import time
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'tools/fixtures/conditional_skill_routing/capture-demonstrations'
EXPECTED = 'f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35'

def save(path, value):
    with path.open('x', encoding='utf-8') as f:
        json.dump(value, f, indent=2)

def linux(path):
    return '/mnt/' + path.drive[0].lower() + path.as_posix()[2:]

def execute():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--label', required=True)
    parser.add_argument('--source', required=True)
    parser.add_argument('--timeout', type=int, default=240)
    args = parser.parse_args()
    if not args.label.replace('-', '').isalnum():
        raise ValueError('invalid label')
    out = BASE / args.label
    out.mkdir(exist_ok=False)
    (out / 'launcher-source-snapshot.py').write_bytes(Path(__file__).read_bytes())
    if Path(args.source).name != args.source or not args.source.startswith('conditional_skill_routing_cli_') or not args.source.endswith('.py'):
        raise ValueError('invalid source filename')
    if not 90 <= args.timeout <= 300:
        raise ValueError('timeout outside bound')
    source = ROOT / 'tools' / args.source
    if not source.is_file():
        raise ValueError('source unavailable')
    old = json.loads((BASE / 'codex-linux-cli-v1-20261007-attempt2/download-receipt.json').read_text())
    start = time.monotonic()
    with tempfile.TemporaryDirectory(prefix='sg-codex-mock-preparation-') as temp:
        folder = Path(temp)
        save(out / 'temporary-runtime-created.json', {'temporary_folder': str(folder), 'installed_globally': False})
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
        command = ['/usr/bin/bwrap', '--unshare-all', '--die-with-parent', '--new-session', '--clearenv']
        for system in ['/usr', '/bin', '/lib', '/lib64']:
            command += ['--ro-bind', system, system]
        workspace = out / 'workspace'
        workspace.mkdir()
        snapshot = out / 'source-snapshot.py'
        snapshot.write_bytes(source.read_bytes())
        command += ['--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp', '--bind', linux(workspace), '/work',
                    '--ro-bind', linux(snapshot), '/probe.py', '--ro-bind', linux(binary), '/codex',
                    '--chdir', '/work', '--setenv', 'PATH', '/usr/bin:/bin', '--setenv', 'HOME', '/work',
                    '/usr/bin/python3', '-B', '/probe.py', '--cli', '/codex', '--out', '/work/run']
        save(out / 'launch.json', {'argv': command, 'timeout_seconds': args.timeout,
                                 'source_sha256': hashlib.sha256(snapshot.read_bytes()).hexdigest(),
                                 'no_host_sockets_or_interop_mounts': True})
        process = subprocess.Popen(['wsl', '-d', 'Ubuntu', '--', '/usr/bin/env', '-i', 'PATH=/usr/bin:/bin',
                                    '/usr/bin/timeout', '--signal=TERM', '--kill-after=5s', str(args.timeout - 10) + 's', *command],
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            stdout, stderr = process.communicate(timeout=args.timeout)
        except subprocess.TimeoutExpired:
            process.kill()
            stdout, stderr = process.communicate(timeout=10)
            (out / 'namespace-stdout.bin').write_bytes(stdout)
            (out / 'namespace-stderr.bin').write_bytes(stderr)
            save(out / 'namespace-receipt.json', {'exit_code': process.returncode, 'error': 'wrapper timeout',
                                                 'duration_seconds': time.monotonic() - start})
            raise RuntimeError('wrapper timeout')
        finally:
            if process.poll() is None:
                process.kill()
        (out / 'namespace-stdout.bin').write_bytes(stdout)
        (out / 'namespace-stderr.bin').write_bytes(stderr)
        save(out / 'namespace-receipt.json', {'exit_code': process.returncode, 'duration_seconds': time.monotonic() - start})
        print(json.dumps({'output': str(out), 'exit_code': process.returncode, 'stdout': stdout.decode(errors='replace')}))
    save(out / 'temporary-runtime-cleanup.json', {'temporary_folder': str(folder), 'exists_after_cleanup': folder.exists(), 'installed_globally': False})
    return 0 if process.returncode == 0 else 1

def main():
    import sys
    result = 0
    try:
        result = execute()
    except Exception as exc:
        result = 1
        if '--label' in sys.argv:
            label = sys.argv[sys.argv.index('--label') + 1]
            if label.replace('-', '').isalnum():
                out = BASE / label
                if out.is_dir() and not (out / 'launcher-error.json').exists():
                    save(out / 'launcher-error.json', {'type': type(exc).__name__, 'message': str(exc), 'passed': False})
        print(json.dumps({'passed': False, 'error_type': type(exc).__name__, 'message': str(exc)}))
    finally:
        if '--label' in sys.argv:
            label = sys.argv[sys.argv.index('--label') + 1]
            if label.replace('-', '').isalnum():
                out = BASE / label
                created = out / 'temporary-runtime-created.json'
                cleanup = out / 'temporary-runtime-cleanup.json'
                if created.exists() and not cleanup.exists():
                    folder = Path(json.loads(created.read_text())['temporary_folder'])
                    save(cleanup, {'temporary_folder': str(folder), 'exists_after_cleanup': folder.exists(),
                                   'installed_globally': False})
    raise SystemExit(result)

if __name__ == '__main__':
    main()
