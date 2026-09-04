#!/usr/bin/env python3
"""Regression checks for the 900-shipglows-core activation contract."""

from pathlib import Path
import json
import re
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "900-shipglows-core" / "SKILL.md"
BUILD_PLAYBOOK = ROOT / "skills" / "900-shipglows-core" / "references" / "skill-maintenance-playbook.md"
DX_RUNTIME_PLAYBOOK = ROOT / "skills" / "900-shipglows-core" / "references" / "dx-runtime-maintenance.md"
SYSTEM_COHERENCE = ROOT / "skills" / "900-shipglows-core" / "references" / "system-coherence.md"
REFRESH_PLAYBOOK = ROOT / "skills" / "900-shipglows-core" / "references" / "skill-refresh-playbook.md"
PREFERRED_STACKS = ROOT / "skills" / "references" / "preferred-stacks.md"
QUESTION_CONTRACT = ROOT / "skills" / "references" / "question-contract.md"
WINDOWS_BOOTSTRAP_WORKFLOW = ROOT / "skills" / "references" / "windows-bootstrap-development-workflow.md"
READY_SKILL = ROOT / "skills" / "101-sg-ready" / "SKILL.md"
INVOCATION_REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"
MAX_ACTIVATION_LINES = 220


class ShipGlowsCoreContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text = SKILL.read_text(encoding="utf-8")
        cls.build = BUILD_PLAYBOOK.read_text(encoding="utf-8")
        cls.dx_runtime = DX_RUNTIME_PLAYBOOK.read_text(encoding="utf-8")
        cls.system_coherence = SYSTEM_COHERENCE.read_text(encoding="utf-8")
        cls.refresh = REFRESH_PLAYBOOK.read_text(encoding="utf-8")
        cls.preferred_stacks = PREFERRED_STACKS.read_text(encoding="utf-8")
        cls.question_contract = QUESTION_CONTRACT.read_text(encoding="utf-8")
        cls.windows_bootstrap_workflow = WINDOWS_BOOTSTRAP_WORKFLOW.read_text(encoding="utf-8")
        cls.ready_skill = READY_SKILL.read_text(encoding="utf-8")
        cls.invocation_registry = json.loads(INVOCATION_REGISTRY.read_text(encoding="utf-8"))

    def test_system_improvement_fields_have_one_owner_definition(self) -> None:
        for field in (
            "`Observed problem`",
            "`System cause`",
            "`Prevention rule`",
            "`Contract/tooling improvement proposal`",
        ):
            self.assertEqual(self.text.count(field), 1, field)

    def test_scope_has_no_stale_read_only_contradiction(self) -> None:
        self.assertNotIn("Default to read-only analysis", self.text)
        self.assertIn("operator critique of ShipGlows execution authorizes a bounded repair", self.text)

    def test_observed_failure_requires_focused_proof(self) -> None:
        self.assertIn("apply the shared `Followability Gate`", self.text)
        self.assertIn("A passing generic audit is not completion proof", self.text)
        self.assertIn("Require focused mechanical or pressure-scenario proof", self.text)

    def test_validation_defaults_to_focused_proof_not_global_audit(self) -> None:
        validation = self.text.split("## Validation", 1)[1]
        self.assertIn("focused contract or pressure-scenario test", validation)
        self.assertIn("global skill audit", validation)
        self.assertIn("only for explicit audit/release work", validation)
        self.assertNotIn("Run `python3 -m unittest", validation)

    def test_windows_installer_work_loads_the_canonical_handoff(self) -> None:
        self.assertIn("`${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/install-shipglows.ps1`", self.text)
        self.assertIn("`${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/windows/`", self.text)
        self.assertIn(
            "$SHIPGLOWS_ROOT/skills/references/windows-bootstrap-development-workflow.md",
            self.text,
        )
        for trigger in ("bootstrap", "runtime-path", "migration", "wrapper", "self-update"):
            self.assertIn(trigger, self.text)
        self.assertIn("# Windows Bootstrap Development Workflow", self.windows_bootstrap_workflow)

    def test_windows_handoff_distinguishes_staging_from_active_runtime(self) -> None:
        for rule in (
            "-DownloadOnly",
            r"%USERPROFILE%\.shipglows\runtime\cli\windows",
            r"%USERPROFILE%\.shipglows\runtime\bin\shipglows-devserver.ps1",
            "-InstallMode full",
            "DOWNLOAD-ONLY-NOT-ACTIVE",
            "normalizing line endings",
        ):
            self.assertIn(rule, self.windows_bootstrap_workflow)

    def test_activation_contract_is_compacted(self) -> None:
        self.assertLess(len(self.text.splitlines()), MAX_ACTIVATION_LINES)

    def test_packaging_uses_canonical_public_identity_without_exposing_core(self) -> None:
        self.assertIn("`shipglows` as the canonical public plugin", self.text)
        self.assertIn("`$shipglows` as its public entrypoint", self.text)
        self.assertIn("`shipglows` is a compatibility alias only", self.text)
        self.assertIn("`900-shipglows-core` internal and repo-synced", self.text)
        self.assertIn("deprecated historical pilot, never canonical or public", self.text)
        self.assertNotIn("Keep `shipglows` as the public user-facing plugin", self.text)
        self.assertNotIn("Keep `shipglows-core` internal and repo-synced", self.text)

    def test_mode_scenarios_cover_valid_invalid_and_retired_inputs(self) -> None:
        for mode in ("`audit`", "`build`", "`refresh`", "`packaging`", "`help`"):
            self.assertIn(mode, self.text)
        self.assertIn("Bare or invalid input", self.text)
        self.assertIn("without a target are invalid", self.text)
        self.assertIn("names as aliases", self.text)
        self.assertIn("Missing local playbook", self.text)

    def test_core_is_a_hard_shipglows_context_and_critique_is_a_bounded_repair(self) -> None:
        self.assertIn("hard ShipGlows-system context", self.text)
        self.assertIn("never to the current project", self.text)
        self.assertIn("select the narrowest internal\n`build` target", self.text)
        self.assertIn("without asking the operator to choose a mode", self.text)

    def test_core_owns_the_dx_system_without_absorbing_shipglows_app(self) -> None:
        for surface in (
            "skills and doctrine",
            "CLI/DevServer/TUI runtime",
            "local helpers",
            "environment control plane",
            "installers",
            "cross-surface coherence",
        ):
            self.assertIn(surface, self.text)
        self.assertIn("`shipglows_app` is a separate product repository", self.text)
        self.assertIn("never a Core mutation target", self.text)

    def test_core_routes_one_direct_pack_by_target_surface(self) -> None:
        self.assertIn("classify one target surface", self.text)
        self.assertIn("`skill`:", self.text)
        self.assertIn("`runtime`:", self.text)
        self.assertIn("`coherence`:", self.text)
        self.assertIn("references/dx-runtime-maintenance.md", self.text)
        self.assertIn("references/system-coherence.md", self.text)
        self.assertIn("Local packs load directly and never chain", self.text)
        self.assertIn("A missing or genuinely ambiguous surface blocks", self.text)

    def test_dx_runtime_pack_maps_runtime_owners_and_proof_boundaries(self) -> None:
        for rule in (
            "Unix CLI/DevServer",
            "Native Windows DevServer and installer",
            "Reproducible environment control plane",
            "Local DX helpers",
            "Terminal cockpit",
            "Starting a server or running an installer is never implicit proof authority",
            "Source changes are not deployed or installed behavior",
            "`shipglows_app` is never a runtime target here",
        ):
            self.assertIn(rule, self.dx_runtime)

    def test_system_coherence_contract_covers_all_pressure_scenarios(self) -> None:
        for scenario in (
            "CORE-DX-SKILL",
            "CORE-DX-RUNTIME",
            "CORE-DX-COHERENCE",
            "CORE-DX-APP-BOUNDARY",
            "CORE-DX-MISSING-PACK",
        ):
            self.assertIn(scenario, self.system_coherence)
        for plane in ("Agent behavior", "Runtime behavior", "Distribution", "Governance"):
            self.assertIn(plane, self.system_coherence)
        self.assertIn("one integration owner", self.system_coherence)

    def test_activation_registry_exposes_runtime_and_coherence_packs(self) -> None:
        gates = self.invocation_registry["activation_profiles"]["skills"]["900-shipglows-core"]["gates"]
        self.assertEqual(
            gates["dx-runtime"],
            ["skills/900-shipglows-core/references/dx-runtime-maintenance.md"],
        )
        self.assertEqual(
            gates["system-coherence"],
            ["skills/900-shipglows-core/references/system-coherence.md"],
        )

    def test_core_critique_does_not_execute_the_quoted_project_task(self) -> None:
        self.assertIn("failure evidence only", self.text)
        self.assertIn("it does not audit either repository", self.text)
        self.assertIn("repairs the core routing rule", self.text)

    def test_build_playbook_preserves_lifecycle_runtime_and_surface_guards(self) -> None:
        for rule in (
            "Search adjacent skills",
            "Blueprint extraction",
            "100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship",
            "scenario and proof path",
            "display name to equal the exact invocation key",
            "skill-context-budget",
            "fresh-docs not needed",
            "Documentation Update Plan",
            "generic third-party generation",
            "operator-partnership-contract",
            "public by default",
        ):
            self.assertIn(rule, self.build)

    def test_refresh_playbook_preserves_conservative_contract(self) -> None:
        for rule in (
            "exact existing `skills/<name>/SKILL.md`",
            "prohibited",
            "official/primary sources",
            "decision-only",
            "update strictly obsolete checks in place",
            "skills/REFRESH_LOG.md",
            "**Sources:** N URLs consulted",
            "cross-surface coherence",
            "monthly maintenance pass",
            "Never edit its frontmatter `name:`",
            "Preserve every still-valid check",
            "Prepend one most-recent-first block",
        ):
            self.assertIn(rule, self.refresh)

    def test_build_uses_refresh_only_for_high_assurance_triggers(self) -> None:
        self.assertIn("Bounded daily repairs use one focused pressure-scenario proof", self.text)
        self.assertIn("broad skill semantic, public-routing, packaging, security, audit, and release work", self.text)
        self.assertIn("broad semantic rewrites", self.build)
        self.assertIn("bounded daily contract repair", self.build)
        self.assertIn("zero or one focused scenario/contract check", self.build)
        self.assertIn("only when the changed surface", self.build)
        self.assertIn("ordinary self-refresh stays prohibited", self.build)
        self.assertIn("independent manual review", self.build)

    def test_activation_validation_is_surgical_by_default(self) -> None:
        validation = self.text.split("## Validation", 1)[1]
        self.assertIn("bounded daily repair", validation)
        self.assertIn("focused contract or pressure-scenario test", validation)
        self.assertIn("only for explicit audit/release work", validation)

    def test_preferred_stack_is_cross_platform_first_not_mobile_only(self) -> None:
        for rule in (
            "first-recommendation defaults",
            "Recommend this pair first",
            "Flutter Web, Android, iOS, Windows, macOS, and Linux from the same application codebase",
            "`PSP-005 apparently mobile-only app`",
        ):
            self.assertIn(rule, self.preferred_stacks)
        self.assertIn("question-greenfield-decisions.md", self.question_contract)
        greenfield = (QUESTION_CONTRACT.parent / "question-greenfield-decisions.md").read_text(encoding="utf-8")
        self.assertIn("one Flutter codebase for", greenfield)
        self.assertIn("Web, iOS, and Android", greenfield)
        scenarios = (QUESTION_CONTRACT.parent / "question-pressure-scenarios.md").read_text(encoding="utf-8")
        self.assertIn("`SSRP-011 cross-platform first`", scenarios)
        self.assertIn("one mobile or browser target", self.ready_skill)


if __name__ == "__main__":
    unittest.main()
