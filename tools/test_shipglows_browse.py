from __future__ import annotations

import io
import os
import unittest
from contextlib import redirect_stderr
from unittest.mock import patch

import tools.shipglows_browse as browse  # noqa: E402  (adds tools/ to sys.path)


class BrowseGuardTests(unittest.TestCase):
    def test_personal_browser_flags_are_detected(self):
        for argv in (["--profile", "Default", "open", "x"], ["--auto-connect", "snapshot"], ["--cdp=9222", "open", "x"],
                     ["--state", "auth.json", "open", "x"]):
            self.assertIsNotNone(browse.personal_flag(argv), argv)
        self.assertIsNone(browse.personal_flag(["open", "https://example.com", "--session", "work"]))

    def test_personal_flag_is_refused_without_opt_in(self):
        with patch.dict(os.environ, {browse.PERSONAL_ENV: ""}), patch.object(browse.subprocess, "call") as call, \
                redirect_stderr(io.StringIO()):
            self.assertEqual(browse.main(["--auto-connect", "snapshot"]), browse.EXIT_USAGE)
        call.assert_not_called()

    def test_safe_defaults_never_override_the_caller(self):
        env = browse.build_environment({"AGENT_BROWSER_SESSION": "mine", "AGENT_BROWSER_MAX_OUTPUT": "10"})
        self.assertEqual(env["AGENT_BROWSER_SESSION"], "mine")
        self.assertEqual(env["AGENT_BROWSER_MAX_OUTPUT"], "10")
        self.assertEqual(env["AGENT_BROWSER_CONTENT_BOUNDARIES"], "1")
        self.assertEqual(browse.build_environment({})["AGENT_BROWSER_SESSION"], browse.DEFAULT_SESSION)

    def test_missing_cli_reports_install_command(self):
        err = io.StringIO()
        with patch.object(browse.shutil, "which", return_value=None), redirect_stderr(err):
            self.assertEqual(browse.main(["snapshot"]), browse.EXIT_MISSING)
        self.assertIn("npm i -g agent-browser", err.getvalue())

    def test_forwards_arguments_with_defaults(self):
        with patch.object(browse.shutil, "which", return_value="/bin/agent-browser"), \
                patch.object(browse.subprocess, "call", return_value=0) as call:
            self.assertEqual(browse.main(["open", "https://example.com"]), 0)
        self.assertEqual(call.call_args.args[0], ["/bin/agent-browser", "open", "https://example.com"])
        self.assertEqual(call.call_args.kwargs["env"]["AGENT_BROWSER_CONTENT_BOUNDARIES"], "1")


if __name__ == "__main__":
    unittest.main()
