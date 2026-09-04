"""Native channel inspection must recognize junctions without acquiring ownership."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("skills_status", Path(__file__).resolve().parents[1] / "cli" / "shipglows_skills.py")
skills = importlib.util.module_from_spec(spec)
spec.loader.exec_module(skills)


class WindowsSkillsStatusTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.root = self.home / "repo"
        for relative in ("skills/shipglows/SKILL.md", "skills/references/skill-invocation-registry.json"):
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("{}", encoding="utf-8")

    def native_state(self, **overrides):
        state = self.home / ".shipglows/development-channel.json"
        state.parent.mkdir(exist_ok=True)
        state.write_text(json.dumps(dict(schemaVersion=1, channel="linked", root=str(self.root), **overrides)), encoding="utf-8-sig")
        return state

    def test_native_state_read_only_fallback(self):
        self.native_state()
        with patch.object(skills.sys, "platform", "win32"):
            self.assertEqual(skills.status_root_state(self.home), (str(self.root), "public"))
        self.assertEqual(skills.linked_root_state(self.home), "")
        self.assertFalse((self.home / skills.ROOT_STATE_RELATIVE).exists())

    def test_linux_ignores_native_state(self):
        self.native_state().write_text("broken", encoding="utf-8")
        with patch.object(skills.sys, "platform", "linux"):
            self.assertEqual(skills.status_root_state(self.home), ("", ""))

    def test_invalid_native_states_fail_closed(self):
        state = self.native_state()
        for payload in ([], {}, {"schemaVersion": 1, "channel": "linked", "root": "relative"}):
            state.write_text(json.dumps(payload), encoding="utf-8")
            with self.subTest(payload=payload), patch.object(skills.sys, "platform", "win32"):
                with self.assertRaises(skills.SkillChannelError):
                    skills.status_root_state(self.home)

    def test_conflicting_roots_fail_closed(self):
        self.native_state()
        state = self.home / skills.ROOT_STATE_RELATIVE
        state.parent.mkdir(parents=True)
        state.write_text(json.dumps({"managed_by": "shipglows-skills-link", "root": str(self.home / "other")}), encoding="utf-8")
        with patch.object(skills.sys, "platform", "win32"):
            with self.assertRaises(skills.SkillChannelError):
                skills.status_root_state(self.home)

    @unittest.skipUnless(sys.platform == "win32", "requires native junctions")
    def test_native_junction_status_and_unlink_boundary(self):
        self.native_state()
        for runtime in (".agents", ".claude"):
            link = self.home / runtime / "skills/shipglows"
            link.parent.mkdir(parents=True)
            env = dict(os.environ, SG_TEST_LINK=str(link), SG_TEST_TARGET=str(self.root / "skills/shipglows"))
            subprocess.run(["powershell", "-NoProfile", "-Command", "New-Item -ItemType Junction -Path $env:SG_TEST_LINK -Target $env:SG_TEST_TARGET -ErrorAction Stop | Out-Null"], check=True, capture_output=True, env=env)
        before = (self.home / ".shipglows/development-channel.json").read_bytes()
        self.assertEqual(skills.channel_status(self.home)["state"], "linked")
        with patch.object(skills, "plugin_ids", return_value=["shipglows@shipglows"]):
            self.assertEqual(skills.channel_status(self.home)["state"], "conflict")
        with patch.object(skills, "status_root_state", return_value=(str(self.home / "other"), "public")):
            self.assertEqual(skills.channel_status(self.home)["state"], "conflict")
        self.assertEqual(skills.managed_shipglows_links(self.home), [])
        self.assertEqual(before, (self.home / ".shipglows/development-channel.json").read_bytes())
        self.assertTrue((self.root / "skills/shipglows/SKILL.md").is_file())

    def test_unrecognized_junction_target_remains_foreign(self):
        with patch.object(skills.sys, "platform", "win32"), patch.object(Path, "is_symlink", return_value=False), patch.object(Path, "is_junction", return_value=True, create=True), patch.object(skills, "root_for_skill_target", return_value=None):
            self.assertEqual(skills.link_description(self.home / "foreign")["state"], "foreign")

    def test_regular_directory_is_not_owned(self):
        self.assertEqual(skills.link_description(self.root / "skills/shipglows")["state"], "foreign")


if __name__ == "__main__":
    unittest.main()
