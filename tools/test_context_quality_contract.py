#!/usr/bin/env python3
"""Pressure contracts for shared context quality and portable priming."""

from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/context-quality-contract.md"
ROUTER = ROOT / "skills/000-shipglows/SKILL.md"
CONTEXT = ROOT / "skills/301-sg-context/SKILL.md"
READY = ROOT / "skills/101-sg-ready/SKILL.md"
EXECUTION = ROOT / "skills/102-sg-start/references/execution-contract.md"
VERIFY = ROOT / "skills/103-sg-verify/references/verification-baseline.md"
HANDOFF = ROOT / "skills/references/reporting-agent-handoff.md"
CONTINUITY = ROOT / "skills/references/conversation-continuity-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/context-quality-contract.md"


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split()).casefold()


class ContextQualityContractTests(unittest.TestCase):
    def test_capsule_and_verdicts_are_explicit(self) -> None:
        doctrine = text(CONTRACT)
        for marker in (
            "context capsule",
            "project -> business/brand/product -> outcome -> surface -> work item",
            "accepted outcome",
            "context_ready",
            "context_partial",
            "context_conflict",
            "context_stale",
        ):
            self.assertIn(marker, doctrine)

    def test_evidence_states_do_not_silently_upgrade(self) -> None:
        doctrine = text(CONTRACT)
        for state in ("confirmed", "evidence_backed", "hypothesis", "unknown", "stale", "conflict"):
            self.assertIn(f"`{state}`", doctrine)
        self.assertIn("never upgrade", doctrine)

    def test_authority_and_memory_boundaries_fail_closed(self) -> None:
        doctrine = text(CONTRACT)
        self.assertIn("canonical project truth", doctrine)
        self.assertIn("observed repository and runtime state", doctrine)
        self.assertIn("current official documentation", doctrine)
        self.assertIn("memory and cache", doctrine)
        self.assertIn("never becomes a source of truth", doctrine)
        self.assertIn("conflict", doctrine)

    def test_invalidation_is_targeted_not_exhaustive(self) -> None:
        doctrine = text(CONTRACT)
        for marker in ("head", "spec", "dependency", "environment", "product decision", "external source"):
            self.assertIn(marker, doctrine)
        self.assertIn("revalidate only dependent claims", doctrine)
        self.assertIn("do not reload the whole repository", doctrine)

    def test_lifecycle_boundaries_load_the_shared_contract(self) -> None:
        path = "context-quality-contract.md"
        for consumer in (ROUTER, READY, EXECUTION, VERIFY, HANDOFF):
            with self.subTest(consumer=consumer):
                self.assertIn(path, text(consumer))

    def test_context_skill_has_truthful_mcp_and_native_paths(self) -> None:
        skill = text(CONTEXT)
        for marker in (
            "when callable",
            "context_continue",
            "context_retrieve",
            "context_read",
            "portable native fallback",
            "rg",
            "git",
            "directly exposed tools",
            "deferred/searchable tool catalog",
            "absence from the first visible list",
            "do not claim",
        ):
            self.assertIn(marker, skill)
        self.assertNotIn("do not do glob/grep before", skill)
        self.assertIn("## report modes", skill)

    def test_partial_or_incomplete_mcp_path_falls_back_before_claiming_ready(self) -> None:
        skill = text(CONTEXT)
        self.assertIn("when any required contextual mcp operation is not callable", skill)
        self.assertIn("portable native fallback", skill)
        self.assertIn("do not claim mcp retrieval", skill)

    def test_context_skill_does_not_gate_execution_on_a_generic_question(self) -> None:
        skill = text(CONTEXT)
        self.assertNotIn("le contexte est prêt. on fait quoi ?", skill)
        self.assertIn("handoff directly", skill)

    def test_wrong_target_and_wrong_outcome_fail(self) -> None:
        doctrine = text(CONTRACT)
        verify = text(VERIFY)
        self.assertIn("unresolved target", doctrine)
        self.assertIn("blocks dependent mutation", doctrine)
        self.assertIn("wrong accepted outcome", verify)

    def test_partial_context_blocks_dependent_execution(self) -> None:
        execution = text(EXECUTION)
        self.assertRegex(
            execution,
            r"stop dependent mutation[^.]*`context_partial`[^.]*`context_conflict`[^.]*`context_stale`",
        )

    def test_verification_dependency_is_versioned_and_active(self) -> None:
        raw = VERIFY.read_text(encoding="utf-8")
        self.assertRegex(
            raw,
            re.compile(
                r"depends_on:\s+- artifact: skills/references/context-quality-contract\.md\s+"
                r"artifact_version: \"1\.0\.0\"\s+required_status: active",
                re.MULTILINE,
            ),
        )

    def test_handoff_preserves_states_and_compaction_does_not_reinterpret(self) -> None:
        doctrine = text(CONTRACT)
        handoff = text(HANDOFF)
        self.assertIn("compaction preserves evidence states and source pointers", doctrine)
        self.assertIn("preserve evidence states and source pointers without reinterpretation", handoff)

    def test_spec_preserves_non_registry_and_stage_fit_boundaries(self) -> None:
        spec = text(SPEC)
        self.assertIn("not a new durable truth registry", spec)
        self.assertIn("explicit prototype", spec)
        self.assertIn("stage-appropriate context", spec)

    def test_conversation_length_alone_never_forces_restart(self) -> None:
        doctrine = text(CONTINUITY)
        self.assertIn("length alone", doctrine)
        self.assertIn("compaction", doctrine)
        self.assertIn("continue the current conversation", doctrine)

    def test_restart_signals_are_quality_and_outcome_based(self) -> None:
        doctrine = text(CONTINUITY)
        for marker in (
            "mixed targets",
            "contradictory decisions",
            "repeated reconstruction",
            "stale source",
            "repository confusion",
        ):
            self.assertIn(marker, doctrine)
        self.assertIn("independent outcome alone", doctrine)
        self.assertIn("never sufficient", doctrine)
        self.assertIn("useful context", doctrine)
        self.assertIn("insufficiently reliable", doctrine)

    def test_restart_is_user_started_after_stabilization(self) -> None:
        doctrine = text(CONTINUITY)
        self.assertIn("cannot restart", doctrine)
        self.assertIn("operator starts", doctrine)
        self.assertIn("stabilization gate", doctrine)
        for marker in ("commit", "push", "durable", "incomplete"):
            self.assertIn(marker, doctrine)

    def test_restart_prompt_is_self_contained_and_redacted(self) -> None:
        doctrine = text(CONTINUITY)
        for marker in (
            "copyable restart prompt",
            "accepted outcome",
            "source pointers",
            "last delivered commit",
            "evidence states",
            "unresolved work",
            "first verification action",
            "secrets",
            "hidden reasoning",
        ):
            self.assertIn(marker, doctrine)

    def test_context_and_handoff_contracts_route_to_conversation_continuity(self) -> None:
        path = "conversation-continuity-contract.md"
        self.assertIn(path, text(CONTRACT))
        self.assertIn(path, text(HANDOFF))

    def test_conversation_continuity_stays_compact_without_losing_scenarios(self) -> None:
        raw = CONTINUITY.read_text(encoding="utf-8")
        self.assertLessEqual(len(raw.split()), 800)
        for number in range(1, 10):
            self.assertIn(f"CCR-{number:03d}", raw)

    def test_context_health_check_is_proportional_and_signal_driven(self) -> None:
        doctrine = text(CONTINUITY)
        for marker in (
            "lightweight transition check",
            "no full conversation reread",
            "signal-driven refresh",
            "only the affected sources",
            "end of a chantier",
            "major subject change",
            "compaction",
        ):
            self.assertIn(marker, doctrine)
        self.assertIn("does not trigger a handoff", doctrine)


if __name__ == "__main__":
    unittest.main()
