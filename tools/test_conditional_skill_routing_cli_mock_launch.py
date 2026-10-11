"""Offline fake-transport checks for proof-launcher integrity and confinement argv."""
import base64
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch
from tools import conditional_skill_routing_cli_mock_launch as launch

class Response(io.BytesIO):
    def geturl(self):
        return 'https://registry.npmjs.org/mock.tgz'

class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.base = self.root / 'proofs'
        old = self.base / 'codex-linux-cli-v1-20261007-attempt2'
        old.mkdir(parents=True)
        source = self.root / 'tools/conditional_skill_routing_cli_fake.py'
        source.parent.mkdir()
        source.write_text('print("fake")')
        self.elf = b'\x7fELFsynthetic-not-an-executable'
        archive = io.BytesIO()
        with tarfile.open(fileobj=archive, mode='w:gz') as tar:
            member = tarfile.TarInfo('package/vendor/bin/codex')
            member.size = len(self.elf)
            tar.addfile(member, io.BytesIO(self.elf))
        self.archive = archive.getvalue()
        self.receipt = {'tarball_url': 'https://registry.npmjs.org/mock.tgz',
                        'archive_sha256': hashlib.sha256(self.archive).hexdigest(),
                        'integrity': 'sha512-' + base64.b64encode(hashlib.sha512(self.archive).digest()).decode(),
                        'member': 'package/vendor/bin/codex', 'elf_bytes': len(self.elf)}
        (old / 'download-receipt.json').write_text(json.dumps(self.receipt))
        for name, value in [('ROOT', self.root), ('BASE', self.base),
                            ('EXPECTED', hashlib.sha256(self.elf).hexdigest())]:
            mocked = patch.object(launch, name, value)
            mocked.start()
            self.addCleanup(mocked.stop)

    def invoke(self, *extra):
        argv = ['launcher', '--label', 'test', '--source', 'conditional_skill_routing_cli_fake.py', *extra]
        with patch.object(sys, 'argv', argv):
            launch.main()

    def test_verified_archive_uses_only_workspace_writable_mount(self):
        with patch.object(launch.urllib.request, 'urlopen', return_value=Response(self.archive)), \
             patch.object(launch.subprocess, 'Popen') as popen, patch('builtins.print'):
            popen.return_value.communicate.return_value = (b'{"passed":true}', b'')
            popen.return_value.returncode = 0
            popen.return_value.poll.return_value = 0
            with self.assertRaises(SystemExit) as exit_status:
                self.invoke()
            self.assertEqual(exit_status.exception.code, 0)
        out = self.base / 'test'
        record = json.loads((out / 'launch.json').read_text())
        command = record['argv']
        self.assertEqual(command[command.index('--bind') + 1:command.index('--bind') + 3],
                         [launch.linux(out / 'workspace'), '/work'])
        self.assertIn('--unshare-all', command)
        self.assertIn('--clearenv', command)
        self.assertNotIn('/run', command)
        self.assertFalse(json.loads((out / 'temporary-runtime-cleanup.json').read_text())['exists_after_cleanup'])
        self.assertEqual((out / 'source-snapshot.py').read_text(), 'print("fake")')

    def test_integrity_failure_never_launches_and_records_cleanup(self):
        with patch.object(launch.urllib.request, 'urlopen', return_value=Response(b'bad')), \
             patch.object(launch.subprocess, 'Popen') as popen, patch('builtins.print'):
            with self.assertRaises(SystemExit) as exit_status:
                self.invoke()
            self.assertEqual(exit_status.exception.code, 1)
            popen.assert_not_called()
        out = self.base / 'test'
        self.assertEqual(json.loads((out / 'launcher-error.json').read_text())['message'], 'archive integrity mismatch')
        self.assertFalse(json.loads((out / 'temporary-runtime-cleanup.json').read_text())['exists_after_cleanup'])

    def test_failed_namespace_propagates_nonzero_exit(self):
        with patch.object(launch.urllib.request, 'urlopen', return_value=Response(self.archive)), \
             patch.object(launch.subprocess, 'Popen') as popen, patch('builtins.print'):
            popen.return_value.communicate.return_value = (b'{"passed":false}', b'failure')
            popen.return_value.returncode = 1
            popen.return_value.poll.return_value = 1
            with self.assertRaises(SystemExit) as exit_status:
                self.invoke()
            self.assertEqual(exit_status.exception.code, 1)
        record = json.loads((self.base / 'test/namespace-receipt.json').read_text())
        self.assertEqual(record['exit_code'], 1)

    def test_timeout_preserves_partial_output_and_cleanup(self):
        with patch.object(launch.urllib.request, 'urlopen', return_value=Response(self.archive)), \
             patch.object(launch.subprocess, 'Popen') as popen, patch('builtins.print'):
            process = popen.return_value
            process.communicate.side_effect = [subprocess.TimeoutExpired('fake', 240), (b'partial-out', b'partial-error')]
            process.returncode = -1
            process.poll.return_value = -1
            with self.assertRaises(SystemExit) as exit_status:
                self.invoke()
            self.assertEqual(exit_status.exception.code, 1)
            process.kill.assert_called_once()
        out = self.base / 'test'
        self.assertEqual((out / 'namespace-stdout.bin').read_bytes(), b'partial-out')
        self.assertEqual((out / 'namespace-stderr.bin').read_bytes(), b'partial-error')
        self.assertFalse(json.loads((out / 'temporary-runtime-cleanup.json').read_text())['exists_after_cleanup'])

    def test_source_traversal_rejected_before_download(self):
        with patch.object(launch.urllib.request, 'urlopen') as download, patch('builtins.print'):
            with self.assertRaises(SystemExit) as exit_status:
                self.invoke('--source', '../secret.py')
            self.assertEqual(exit_status.exception.code, 1)
            download.assert_not_called()

    def test_dependency_snapshot_is_exact_allowlist_and_immutable_copy(self):
        for relative in launch.TUNING_DEPENDENCIES:
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(relative.encode())
        private = self.root / 'tools/fixtures/conditional_skill_routing/evaluator-cases.json'
        private.write_bytes(b'never include')
        out = self.root / 'dependency-proof'
        out.mkdir()
        folder = launch.snapshot_tuning_dependencies(out)
        inventory = json.loads((out / 'dependency-snapshot-receipt.json').read_text())['inventory']
        self.assertEqual(set(inventory), set(launch.TUNING_DEPENDENCIES))
        self.assertFalse((folder / private.relative_to(self.root)).exists())
        relative = launch.TUNING_DEPENDENCIES[0]
        (self.root / relative).write_bytes(b'changed later')
        self.assertEqual((folder / relative).read_bytes(), relative.encode())
        for path, row in inventory.items():
            self.assertEqual(hashlib.sha256((folder / path).read_bytes()).hexdigest(), row['sha256'])

    def test_missing_dependency_refuses_snapshot(self):
        out = self.root / 'missing-proof'
        out.mkdir()
        with self.assertRaisesRegex(ValueError, 'dependency unavailable'):
            launch.snapshot_tuning_dependencies(out)

    def test_case_selection_rejects_unreviewed_probe_before_network(self):
        with patch.object(launch.urllib.request, 'urlopen') as network, patch('builtins.print'):
            with self.assertRaises(SystemExit) as status:
                self.invoke('--probe-case', 'H1', '--dependency-profile', 'tuning-v1')
        self.assertEqual(status.exception.code, 1)
        network.assert_not_called()

    def test_dependency_mount_is_readonly_and_case_is_explicit(self):
        name = 'conditional_skill_routing_cli_tuning_transport_probe.py'
        (self.root / 'tools' / name).write_bytes(b'print("mock")')
        for relative in launch.TUNING_DEPENDENCIES:
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(relative.encode())
        with patch.object(launch.urllib.request, 'urlopen', return_value=Response(self.archive)), \
             patch.object(launch.subprocess, 'Popen') as popen, patch('builtins.print'):
            popen.return_value.communicate.return_value = (b'{}', b'')
            popen.return_value.returncode = 0
            popen.return_value.poll.return_value = 0
            with self.assertRaises(SystemExit) as status:
                self.invoke('--source', name, '--dependency-profile', 'tuning-v1', '--probe-case', 'S2')
            self.assertEqual(status.exception.code, 0)
        argv = json.loads((self.base / 'test/launch.json').read_text())['argv']
        position = argv.index('/dependency-root')
        self.assertEqual(argv[position - 2], '--ro-bind')
        self.assertEqual(argv[-4:], ['--dependency-root', '/dependency-root', '--case', 'S2'])
        self.assertEqual(argv.count('--bind'), 1)

if __name__ == '__main__':
    unittest.main()
