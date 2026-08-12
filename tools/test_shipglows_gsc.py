import json
import os
import stat
import tempfile
import unittest
from pathlib import Path
from urllib.parse import unquote

from tools import shipglows_gsc as gsc


class GscTests(unittest.TestCase):
    def test_property_url_is_encoded(self):
        self.assertIn("sc-domain%3Aexample.com", gsc.api_url("sc-domain:example.com"))
        self.assertIn("https%3A%2F%2Fexample.com%2F", gsc.api_url("https://example.com/"))

    def test_date_validation(self):
        self.assertEqual(gsc.require_date("2026-07-14"), "2026-07-14")
        with self.assertRaises(Exception): gsc.require_date("14/07/2026")

    def test_private_json_permissions(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "profile.json"
            gsc.write_private_json(path, {"refresh_token": "test"})
            if os.name == "posix":
                self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o600)
            else:
                # Windows uses ACLs; its emulated mode bits cannot prove 0600.
                self.assertTrue(path.is_file())
            self.assertEqual(json.loads(path.read_text())["refresh_token"], "test")

    def test_invalid_profile_is_rejected(self):
        with self.assertRaises(gsc.GscError): gsc.token_path("../bad")

    def test_inspect_requires_absolute_url(self):
        class Args: profile="default"; site="sc-domain:example.com"; url="/relative"
        with self.assertRaises(gsc.GscError): gsc.command_inspect(Args())


if __name__ == "__main__":
    unittest.main()
