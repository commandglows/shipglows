"""Regression scenarios for uncertainty, ancestry bounds and transport claims."""

import unittest
from unittest.mock import patch

from tools.agent_runtime_envelope import ProcessRecord, classify_runtime, observe_runtime


class AgentRuntimeEnvelopeTests(unittest.TestCase):
    def classify(self, records=(), environment=None, system=None, **kwargs):
        return classify_runtime(records, 50, environment or {}, "Windows", system or {}, **kwargs)

    def test_absent_evidence_does_not_infer_local_physical_or_callable(self):
        result = self.classify(environment={"CI": "false"})
        for key in ("session_location", "machine_kind", "agent_surface"):
            self.assertEqual(result[key], "unknown")
        self.assertEqual(result["native_transport"], "not-probed")

    def test_packaged_ancestor_is_hint_not_desktop_or_transport_proof(self):
        result = self.classify([
            ProcessRecord(50, 10, "python.exe"),
            ProcessRecord(10, 0, "Codex.exe", r"C:\WindowsApps\OpenAI.Codex_1\Codex.exe"),
        ])
        self.assertEqual(result["agent_process_hint"], "packaged-codex-ancestor")
        self.assertEqual(result["agent_surface"], "unknown")
        self.assertEqual(result["native_transport"], "not-probed")

    def test_unrelated_processes_do_not_classify_current_host(self):
        result = self.classify([ProcessRecord(50, 0, "python"), ProcessRecord(10, 0, "rio.exe")])
        self.assertEqual(result["terminal_host_hint"], "unknown")

    def test_cycle_terminates_and_paths_are_not_exported(self):
        result = self.classify([ProcessRecord(50, 50, "codex.exe", "/private/operator/path")])
        self.assertEqual(result["agent_process_hint"], "codex-process-ancestor")
        self.assertNotIn("/private/operator/path", str(result))

    def test_remote_and_vm_are_independent_and_container_is_injected(self):
        result = self.classify(environment={"SSH_CONNECTION": "private"}, system={"model": "Virtual Machine"})
        self.assertEqual(result["session_location"], "remote")
        self.assertEqual(result["machine_kind"], "virtual-machine")
        self.assertEqual(self.classify(container_detected=True)["machine_kind"], "container")
        self.assertEqual(self.classify()["machine_kind"], "unknown")

    def test_windows_observation_failure_is_redacted_and_not_observed(self):
        with patch("tools.agent_runtime_envelope.platform.system", return_value="Windows"), \
             patch("tools.agent_runtime_envelope._windows_observation", side_effect=ValueError("private payload")):
            result = observe_runtime()
        self.assertEqual(result["observation_state"], "failed")
        self.assertEqual(result["error_type"], "ValueError")
        self.assertNotIn("private payload", str(result))
        self.assertEqual(result["native_transport"], "not-probed")

    def test_missing_proc_evidence_remains_unavailable(self):
        with patch("tools.agent_runtime_envelope.platform.system", return_value="Darwin"), \
             patch("tools.agent_runtime_envelope._proc_observation", return_value=([], {})), \
             patch("tools.agent_runtime_envelope.os.environ", {}), \
             patch("tools.agent_runtime_envelope.Path.exists", return_value=False):
            result = observe_runtime()
        self.assertEqual(result["observation_state"], "unavailable")
        self.assertEqual(result["session_location"], "unknown")


if __name__ == "__main__":
    unittest.main()
