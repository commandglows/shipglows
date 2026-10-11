"""Readwise adapter behavior; no network, real credentials or library data."""

import contextlib
import importlib.util
import io
import json
import os
import sys
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("readwise", ROOT / "cli/shipglows_readwise.py")
readwise = importlib.util.module_from_spec(SPEC)
with patch.object(sys, "path", [str(ROOT / "cli")] + sys.path):
    SPEC.loader.exec_module(readwise)


class ReadwiseTests(unittest.TestCase):
    def test_local_help_needs_no_provider(self):
        with patch.object(readwise, "invoke") as invoke, contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(readwise.main(["--help"]), 0)
        invoke.assert_not_called()
        self.assertIn("reader-search-documents", out.getvalue())

    def test_forwarding_preserves_unicode_spaces_metacharacters_and_exit_code(self):
        args = ["reader-search-documents", "--query", 'énergie & livres "Windows"', "--json"]
        with patch.object(readwise, "executable", return_value=["node", "index.js"]), patch.object(readwise, "invoke", return_value=7) as invoke:
            self.assertEqual(readwise.main(args), 7)
        invoke.assert_called_once_with(["node", "index.js"] + args)

    def test_token_only_in_stdin_not_environment_or_arguments(self):
        token = "private-fixture-credential"
        with patch.dict(os.environ, {readwise.TOKEN_ENV: token}), patch.object(readwise, "executable", return_value=["readwise"]), patch.object(readwise.subprocess, "run") as run:
            run.return_value.returncode = 0
            self.assertEqual(readwise.main(["login-with-token"]), 0)
        args, kwargs = run.call_args
        self.assertEqual(args[0], ["readwise", "login-with-token"])
        self.assertEqual(kwargs["input"], token + "\n")
        self.assertNotIn(readwise.TOKEN_ENV, kwargs["env"])
        self.assertFalse(kwargs.get("shell", False))

    def test_token_arguments_rejected_even_with_global_options(self):
        for args in (["login-with-token", "fixture-token"], ["--json", "login-with-token", "fixture-token"]):
            with self.subTest(args=args), patch.object(readwise, "invoke") as invoke, contextlib.redirect_stderr(io.StringIO()) as err:
                self.assertEqual(readwise.main(args), 2)
            invoke.assert_not_called()
            self.assertNotIn("fixture-token", err.getvalue())

    def test_missing_or_multiline_token_rejected_without_process(self):
        for token in ("", "first\nsecond", "first\rsecond", "first\0second"):
            with self.subTest(token=token), patch.object(readwise.os, "environ", {readwise.TOKEN_ENV: token}), patch.object(readwise.sys.stdin, "isatty", return_value=False), patch.object(readwise, "invoke") as invoke, contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(readwise.main(["login-with-token"]), 2)
            invoke.assert_not_called()

    def test_setup_pins_package_and_enables_readonly_after_install(self):
        with patch.object(readwise, "executable", side_effect=lambda name: [name]), patch.object(readwise, "invoke", return_value=0) as invoke, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(readwise.main(["setup"]), 0)
        self.assertEqual(invoke.call_args_list[0].args[0], ["npm", "install", "--global", readwise.PACKAGE, "--ignore-scripts"])
        self.assertEqual(invoke.call_args_list[1].args[0], ["readwise", "config", "set", "readonly", "true"])

    def test_setup_install_failure_does_not_touch_config(self):
        with patch.object(readwise, "executable", return_value=["npm"]), patch.object(readwise, "invoke", return_value=9) as invoke:
            self.assertEqual(readwise.main(["setup"]), 9)
        self.assertEqual(invoke.call_count, 1)

    def test_setup_readonly_failure_not_reported_successful(self):
        with patch.object(readwise, "executable", side_effect=lambda name: [name]), patch.object(readwise, "invoke", side_effect=[0, 1]), contextlib.redirect_stdout(io.StringIO()) as out:
            self.assertEqual(readwise.main(["setup"]), 1)
        self.assertNotIn("installé en lecture seule", out.getvalue())

    def test_status_reports_presence_without_leaking_or_claiming_connection(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".readwise-cli.json").write_text(json.dumps({"access_token": "fixture-secret", "client_secret": "fixture-client", "config": {"readonly": True}}))
            with patch.object(readwise.Path, "home", return_value=home), patch.object(readwise.shutil, "which", return_value="readwise"), patch.object(readwise, "invoke") as invoke, contextlib.redirect_stdout(io.StringIO()) as out:
                self.assertEqual(readwise.main(["status"]), 0)
        invoke.assert_not_called()
        data = json.loads(out.getvalue())
        self.assertTrue(data["credentials_present"])
        self.assertTrue(data["readonly"])
        self.assertFalse(data["connection_verified"])
        self.assertNotIn("fixture-", out.getvalue())

    def test_malformed_status_config_has_safe_error(self):
        for config in ("not-json-private-fixture", "[]", '{"config":null}'):
            with self.subTest(config=config), tempfile.TemporaryDirectory() as directory:
                home = Path(directory)
                (home / ".readwise-cli.json").write_text(config)
                with patch.object(readwise.Path, "home", return_value=home), contextlib.redirect_stderr(io.StringIO()) as err:
                    self.assertEqual(readwise.main(["status"]), 2)
                self.assertNotIn(config, err.getvalue())

    def test_windows_npm_shims_resolved_without_shell(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = root / "node_modules/@readwise/cli/dist/index.js"
            entry.parent.mkdir(parents=True)
            entry.touch()
            with patch.object(readwise.shutil, "which", side_effect=lambda name: str(root / "readwise.cmd") if name == "readwise" else "node.exe"):
                self.assertEqual(readwise.executable("readwise"), ["node.exe", str(entry)])

    def test_missing_official_cli_is_actionable(self):
        with patch.object(readwise.shutil, "which", return_value=None), contextlib.redirect_stderr(io.StringIO()) as err:
            self.assertEqual(readwise.main(["--version"]), 2)
        self.assertIn("shipglows readwise setup", err.getvalue())

    def test_managed_npm_shim_can_resolve_real_installation_on_path(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = root / "real/node_modules/npm/bin/npm-cli.js"
            entry.parent.mkdir(parents=True)
            entry.touch()
            with patch.object(readwise.shutil, "which", side_effect=lambda name: str(root / "managed/npm.cmd") if name == "npm" else "node.exe"), patch.object(readwise.os, "get_exec_path", return_value=[str(root / "real")]):
                self.assertEqual(readwise.executable("npm"), ["node.exe", str(entry)])

    def test_provider_help_is_delegated(self):
        with patch.object(readwise, "executable", return_value=["readwise"]), patch.object(readwise, "invoke", return_value=0) as invoke:
            self.assertEqual(readwise.main(["help"]), 0)
        invoke.assert_called_once_with(["readwise", "--help"])

    def test_oauth_delegates_to_maintained_adapter_not_fixed_port_provider(self):
        for args in (["login"], ["--json", "login"], ["login", "--refresh"]):
            with self.subTest(args=args), patch.object(readwise, "oauth_login") as login, patch.object(readwise, "executable", return_value=["readwise"]), patch.object(readwise, "invoke") as invoke:
                self.assertEqual(readwise.main(args), 0)
            login.assert_called_once_with()
            invoke.assert_not_called()

    def test_interactive_token_login_uses_provider_hidden_prompt_without_oauth(self):
        with patch.object(readwise.os, "environ", {}), patch.object(readwise.sys.stdin, "isatty", return_value=True), patch.object(readwise, "oauth_login") as login, patch.object(readwise, "executable", return_value=["readwise"]), patch.object(readwise, "invoke", return_value=0) as invoke:
            self.assertEqual(readwise.main(["login", "--token"]), 0)
        login.assert_not_called()
        invoke.assert_called_once_with(["readwise", "login-with-token"])


if __name__ == "__main__":
    unittest.main()
