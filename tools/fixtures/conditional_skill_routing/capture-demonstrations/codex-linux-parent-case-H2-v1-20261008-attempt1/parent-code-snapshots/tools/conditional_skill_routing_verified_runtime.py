"""Temporary official ELF, fixed public publisher URL and verified bytes only."""
import base64
from contextlib import contextmanager
import hashlib
import json
from pathlib import Path
import tarfile
import tempfile
import time
import urllib.request

URL = 'https://registry.npmjs.org/@openai/codex/-/codex-0.160.1-linux-x64.tgz'
ARCHIVE_SHA256 = 'dc9ebd133d3af19ccac4bd5515a5049005b8b05ef3bd558d257d44f32a94f758'
INTEGRITY = 'sha512-sIDhqV+bsZKKVaVFVY5iB+pAzyOz2XRm3H1KXCsSJwGj5p98qnrT0Fweo1Hfe7WnyTp8mfBNdbVzUeO+mHYugA=='
MEMBER = 'package/vendor/x86_64-unknown-linux-musl/bin/codex'
ELF_BYTES = 289166920
ELF_SHA256 = 'f34a4d2301892ae96c90097786bfe5dc269f187b6f69faf42a7b357b8c081e35'

def save(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2)

@contextmanager
def verified_runtime(output):
    output = Path(output)
    began = time.monotonic()
    folder = None
    try:
        with tempfile.TemporaryDirectory(prefix='sg-case-parent-runtime-') as temporary:
            folder = Path(temporary)
            save(output / 'temporary-runtime-created.json', {'temporary_folder': str(folder), 'installed_globally': False})
            archive = folder / 'codex.tgz'
            sha256, sha512, size = hashlib.sha256(), hashlib.sha512(), 0
            request = urllib.request.Request(URL, headers={'User-Agent':'ShipGlows-mock-proof'})
            with urllib.request.urlopen(request, timeout=30) as response, archive.open('xb') as target:
                if response.geturl() != URL:
                    raise RuntimeError('unexpected publisher redirect')
                while chunk := response.read(1024 * 1024):
                    size += len(chunk)
                    if size > 512 * 1024 * 1024 or time.monotonic() - began > 180:
                        raise RuntimeError('publisher download bound')
                    sha256.update(chunk)
                    sha512.update(chunk)
                    target.write(chunk)
            if sha256.hexdigest() != ARCHIVE_SHA256 or 'sha512-' + base64.b64encode(sha512.digest()).decode() != INTEGRITY:
                raise RuntimeError('publisher archive integrity mismatch')
            binary = folder / 'codex'
            with tarfile.open(archive, 'r:gz') as package:
                member = package.getmember(MEMBER)
                if not member.isfile() or member.size != ELF_BYTES:
                    raise RuntimeError('unexpected ELF member')
                with package.extractfile(member) as source, binary.open('xb') as target:
                    while chunk := source.read(1024 * 1024):
                        target.write(chunk)
            if hashlib.sha256(binary.read_bytes()).hexdigest() != ELF_SHA256:
                raise RuntimeError('ELF hash mismatch')
            save(output / 'download-receipt.json', {'tarball_url':URL, 'archive_sha256':ARCHIVE_SHA256,
                 'integrity':INTEGRITY, 'member':MEMBER, 'archive_bytes':size, 'elf_bytes':ELF_BYTES,
                 'elf_sha256':ELF_SHA256, 'temporary_folder':str(folder), 'reverified':True})
            yield binary, folder
    finally:
        if folder is not None:
            save(output / 'temporary-runtime-cleanup.json', {'temporary_folder':str(folder),
                 'exists_after_cleanup':folder.exists(), 'installed_globally':False})
