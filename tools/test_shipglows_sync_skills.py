"""Behavioral regression tests for the Bash skill synchronizer."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools/shipglows_sync_skills.sh"
BASH = (str(Path(os.environ.get("ProgramFiles", "C:/Program Files")) / "Git/bin/bash.exe")
        if os.name == "nt" else shutil.which("bash"))


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Bash is required")
class SyncSkillsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sg sync ")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / "source"
        self.home = self.base / "home"
        self.skills = self.home / ".claude/skills"
        self.skills.mkdir(parents=True)
        for name in ("sg-development", "shipglows"):
            source = self.root / "skills" / name
            source.mkdir(parents=True)
            (source / "SKILL.md").write_text("fixture", encoding="utf-8")
            (self.skills / name).symlink_to(source, target_is_directory=True)
        registry = self.root / "skills/references/skill-invocation-registry.json"
        registry.parent.mkdir()
        registry.write_text(json.dumps({"public_catalog": {
            "domains": [{"skills": [{"id": "sg-development"}]}],
            "router": {"id": "shipglows"}}}), encoding="utf-8")

    def run_sync(self, mode="--check"):
        return subprocess.run([BASH, "--noprofile", "--norc", str(SCRIPT), mode,
            "--all", "--runtime", "claude", "--shipglows-root", str(self.root),
            "--target-home", str(self.home)], capture_output=True, text=True,
            timeout=30)

    def test_public_catalog_and_native_paths_match_links(self):
        result = self.run_sync()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("checked=2 ok=2 repaired=0", result.stdout)

    def test_catalog_protocol_is_lf_only(self):
        definitions = SCRIPT.read_text().split('while [ "$#" -gt 0 ]; do')[0]
        env = dict(os.environ, SHIPGLOWS_ROOT=str(self.root))
        result = subprocess.run([BASH, "--noprofile", "--norc", "-s"],
            input=(definitions + "\nlist_public_pairs\n").encode(),
            env=env, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout,
            b"sg-development|sg-development\nshipglows|shipglows\n")

    def test_check_preserves_owned_and_foreign_broken_links(self):
        owned = self.skills / "old-skill"
        foreign = self.skills / "personal-skill"
        owned.symlink_to(self.root / "skills/missing", target_is_directory=True)
        foreign.symlink_to(self.base / "missing-personal", target_is_directory=True)
        result = self.run_sync()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertTrue(owned.is_symlink())
        self.assertTrue(foreign.is_symlink())
        self.assertIn("repaired=0", result.stdout)

    def test_repair_only_removes_owned_broken_links(self):
        owned = self.skills / "old-skill"
        foreign = self.skills / "personal-skill"
        owned.symlink_to(self.root / "skills/missing", target_is_directory=True)
        foreign.symlink_to(self.base / "missing-personal", target_is_directory=True)
        result = self.run_sync("--repair")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(owned.is_symlink())
        self.assertTrue(foreign.is_symlink())
        self.assertIn("repaired=1", result.stdout)


if __name__ == "__main__":
    unittest.main()
