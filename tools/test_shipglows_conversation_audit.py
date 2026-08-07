#!/usr/bin/env python3
"""Synthetic tests for conservative delegation trace verification."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.shipglows_conversation_audit import delegation_trace_analysis


def transcript(user: str, assistant: str, turn_id: str = "t1") -> str:
    return f"## Turn {turn_id}\nUser:\n{user}\nAssistant:\n{assistant}\n"


class DelegationTraceTests(unittest.TestCase):
    def analyse(self, text: str, events: list[object] | None, malformed: str | None = None):
        if events is None and malformed is None:
            return delegation_trace_analysis(text, None)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "rollout.jsonl"
            lines = [json.dumps(event) for event in events or []]
            if malformed is not None:
                lines.append(malformed)
            path.write_text("\n".join(lines) + "\n", encoding="utf-8")
            return delegation_trace_analysis(text, path)

    def test_no_trace_is_unverifiable_without_finding(self):
        result = self.analyse(transcript("Lance des agents", "Terminé. Agents: 2"), None)
        self.assertEqual(result["status"], "unverifiable")
        self.assertEqual(result["findings"], [])

    def test_successful_spawn_and_receipt_are_verified(self):
        events = [
            {"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "root", "task_name": "audit", "output_correlated": True},
            {"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"},
        ]
        result = self.analyse(transcript("Délègue à un agent", "Implémenté. Agents: 1"), events)
        self.assertEqual(result["status"], "verified")

    def test_false_receipt_requires_complete_trace(self):
        events = [{"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"}]
        result = self.analyse(transcript("Fais la tâche", "Terminé. Agents: 2"), events)
        self.assertEqual(result["status"], "finding")
        self.assertIn("false_agents_receipt", {item["category"] for item in result["findings"]})

    def test_explicit_request_missed(self):
        events = [{"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"}]
        result = self.analyse(transcript("Lance des agents en parallèle", "Implémenté et tests OK."), events)
        self.assertIn("missed_delegation", {item["category"] for item in result["findings"]})

    def test_degraded_status_exempts_missed_delegation(self):
        events = [{"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"}]
        result = self.analyse(
            transcript("Lance des agents en parallèle", "Implémenté. Delegation unavailable; mode degraded."),
            events,
        )
        self.assertEqual(result["status"], "verified")

    def test_malformed_and_incomplete_traces_are_unverifiable(self):
        malformed = self.analyse(transcript("Lance des agents", "Terminé. Agents: 3"), [], "{bad")
        self.assertEqual(malformed["status"], "unverifiable")
        self.assertEqual(malformed["findings"], [])
        incomplete = self.analyse(
            transcript("Lance des agents", "Terminé. Agents: 3"),
            [{"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "root", "task_name": "audit", "output_correlated": True}],
        )
        self.assertEqual(incomplete["status"], "unverifiable")
        self.assertEqual(incomplete["findings"], [])

    def test_receipt_counts_unique_direct_tasks_only(self):
        events = [
            {"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "root", "task_name": "audit", "output_correlated": True},
            {"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "root", "task_name": "audit", "output_correlated": True},
            {"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "child", "task_name": "nested", "output_correlated": True},
            {"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"},
        ]
        result = self.analyse(transcript("Fais la tâche", "Terminé. Agents: 1"), events)
        self.assertEqual(result["status"], "verified")

    def test_uncorrelated_spawn_output_is_unverifiable(self):
        events = [
            {"turn_id": "t1", "event": "spawn_agent", "status": "success", "parent_agent_id": "root", "task_name": "audit"},
            {"turn_id": "t1", "event": "trace_complete", "complete": True, "orchestrator_id": "root"},
        ]
        result = self.analyse(transcript("Lance des agents", "Terminé. Agents: 1"), events)
        self.assertEqual(result["status"], "unverifiable")
        self.assertEqual(result["findings"], [])


if __name__ == "__main__":
    unittest.main()
