"""Offline Linux CLI surface inspection inside the operator-approved namespace."""
import argparse
import errno
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cli', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    if os.name != 'posix' or [l.split(':')[0].strip() for l in Path('/proc/net/dev').read_text().splitlines()[2:]] != ['lo']:
        raise RuntimeError('Linux loopback-only namespace required')
    with socket.socket() as connection:
        connection.settimeout(0.2)
        if connection.connect_ex(('203.0.113.1', 9)) != errno.ENETUNREACH:
            raise RuntimeError('egress denial unproved')
    if args.cli.read_bytes()[:4] != b'\x7fELF':
        raise RuntimeError('ELF required')
    args.out.mkdir(exist_ok=False)
    home = args.out / 'home'
    home.mkdir()
    environment = {'HOME': str(home), 'CODEX_HOME': str(home / 'codex'), 'PATH': '/usr/bin:/bin', 'LANG': 'C.UTF-8'}
    records = []
    commands = [('exec-help', ['exec', '--help']), ('resume-help', ['exec', 'resume', '--help']),
                ('app-server-help', ['app-server', '--help']),
                ('schemas', ['app-server', 'generate-json-schema', '--experimental', '--out', str(args.out / 'schemas')])]
    for label, command in commands:
        process = subprocess.run([str(args.cli), *command], cwd=args.out, env=environment, capture_output=True, timeout=40)
        (args.out / (label + '.stdout.bin')).write_bytes(process.stdout)
        (args.out / (label + '.stderr.bin')).write_bytes(process.stderr)
        records.append({'label': label, 'argv': command, 'exit_code': process.returncode})
    inventory = {str(p.relative_to(args.out)): {'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                 for p in args.out.rglob('*') if p.is_file()}
    summary = {'passed': all(r['exit_code'] == 0 for r in records), 'model_calls': 0, 'records': records,
               'inventory': inventory, 'source_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    (args.out / 'summary.json').write_text(json.dumps(summary, indent=2))
    print(json.dumps({'passed': summary['passed'], 'model_calls': 0, 'schema_files': len(inventory)}))
    raise SystemExit(0 if summary['passed'] else 1)

if __name__ == '__main__':
    main()
