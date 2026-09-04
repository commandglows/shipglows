#!/usr/bin/env python3
"""Regression tests for current-agent host and transport classification."""

import unittest

from tools.agent_runtime_envelope import ProcessRecord, classify_runtime


class AgentRuntimeEnvelopeTests(unittest.TestCase):
    def test_rio_hosted_npm_codex_is_standalone_cli(self) -> None:
        records = [
            ProcessRecord(10, 0, "rio.exe", r"C:\Apps\Rio\rio.exe", "rio"),
            ProcessRecord(20, 10, "powershell.exe", r"C:\Windows\powershell.exe", "powershell"),
            ProcessRecord(30, 20, "node.exe", r"C:\Program Files\nodejs\node.exe", "codex.js"),
            ProcessRecord(40, 30, "codex.exe", r"C:\Users\Diane\AppData\Roaming\npm\node_modules\@openai\codex\codex.exe", "codex"),
            ProcessRecord(50, 40, "python.exe", r"C:\Python\python.exe", "agent_runtime_envelope.py"),
        ]

        result = classify_runtime(records, 50, {}, "Windows", {})

        self.assertEqual(result["agent_surface"], "codex-cli")
        self.assertEqual(result["terminal_host"], "rio")
        self.assertEqual(result["computer_use_native_transport"], "not-provided-by-standalone-cli")
        self.assertIn("Codex Desktop", result["computer_use_recovery"])
        self.assertIn("restarting the same standalone cli host cannot", result["computer_use_recovery"].casefold())

    def test_packaged_codex_is_desktop_hosted(self) -> None:
        records = [
            ProcessRecord(10, 0, "Codex.exe", r"C:\Program Files\WindowsApps\OpenAI.Codex_1.0\Codex.exe", "Codex"),
            ProcessRecord(20, 10, "codex.exe", r"C:\Program Files\WindowsApps\OpenAI.Codex_1.0\codex.exe", "codex"),
            ProcessRecord(30, 20, "python.exe", r"C:\Python\python.exe", "agent_runtime_envelope.py"),
        ]

        result = classify_runtime(records, 30, {}, "Windows", {})

        self.assertEqual(result["agent_surface"], "codex-desktop")
        self.assertEqual(result["computer_use_native_transport"], "expected-but-must-probe")

    def test_vm_and_remote_are_independent_dimensions(self) -> None:
        records = [ProcessRecord(10, 0, "python", "/usr/bin/python", "agent_runtime_envelope.py")]
        result = classify_runtime(
            records,
            10,
            {"SSH_CONNECTION": "redacted"},
            "Linux",
            {"manufacturer": "Microsoft Corporation", "model": "Virtual Machine"},
        )

        self.assertEqual(result["session_location"], "remote")
        self.assertEqual(result["machine_kind"], "virtual-machine")


if __name__ == "__main__":
    unittest.main()
