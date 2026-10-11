import base64
import hashlib
import io
import json
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest.mock import patch
from tools import conditional_skill_routing_verified_runtime as runtime

class Response(io.BytesIO):
    def geturl(self): return runtime.URL

class RuntimeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.out = Path(temporary.name)
        self.elf = b'\x7fELFfake-verified-test'
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode='w:gz') as archive:
            member = tarfile.TarInfo(runtime.MEMBER)
            member.size = len(self.elf)
            archive.addfile(member, io.BytesIO(self.elf))
        self.archive = stream.getvalue()
        for name, value in {'ARCHIVE_SHA256':hashlib.sha256(self.archive).hexdigest(),
                            'INTEGRITY':'sha512-'+base64.b64encode(hashlib.sha512(self.archive).digest()).decode(),
                            'ELF_BYTES':len(self.elf), 'ELF_SHA256':hashlib.sha256(self.elf).hexdigest()}.items():
            target = patch.object(runtime, name, value)
            target.start()
            self.addCleanup(target.stop)
    def cleaned(self):
        return json.loads((self.out/'temporary-runtime-cleanup.json').read_text())['exists_after_cleanup'] is False
    def test_verified_bytes_and_cleanup(self):
        with patch.object(runtime.urllib.request,'urlopen',return_value=Response(self.archive)):
            with runtime.verified_runtime(self.out) as (binary, folder):
                self.assertEqual(binary.read_bytes(), self.elf)
                self.assertTrue(folder.is_dir())
            self.assertFalse(binary.exists())
        self.assertTrue(self.cleaned())
    def test_archive_integrity_failure_cleans_temporary_state(self):
        with patch.object(runtime.urllib.request,'urlopen',return_value=Response(b'bad')):
            with self.assertRaisesRegex(RuntimeError,'archive integrity'):
                with runtime.verified_runtime(self.out): self.fail('yielded bad archive')
        self.assertTrue(self.cleaned())
    def test_elf_integrity_failure_never_yields(self):
        with patch.object(runtime.urllib.request,'urlopen',return_value=Response(self.archive)), patch.object(runtime,'ELF_SHA256','0'*64):
            with self.assertRaisesRegex(RuntimeError,'ELF hash'):
                with runtime.verified_runtime(self.out): self.fail('yielded bad ELF')
        self.assertTrue(self.cleaned())
    def test_consumer_exception_still_removes_runtime(self):
        with patch.object(runtime.urllib.request,'urlopen',return_value=Response(self.archive)):
            with self.assertRaisesRegex(ValueError,'consumer error'):
                with runtime.verified_runtime(self.out): raise ValueError('consumer error')
        self.assertTrue(self.cleaned())

if __name__ == '__main__': unittest.main()
