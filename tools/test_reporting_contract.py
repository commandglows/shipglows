#!/usr/bin/env python3
"""Regression checks for the shared ShipGlows reporting contract."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REPORTING_CONTRACT = ROOT / "skills" / "references" / "reporting-contract.md"
REPORTING_BRANCHES = (
    ROOT / "skills" / "references" / "reporting-agent-handoff.md",
    ROOT / "skills" / "references" / "reporting-blocked-and-audit.md",
    ROOT / "skills" / "references" / "reporting-pressure-scenarios.md",
)
CHANTIER_TRACKING = ROOT / "skills" / "references" / "chantier-tracking.md"
FINAL_TIMESTAMP = ROOT / "skills" / "references" / "final-report-timestamp.md"
DOCUMENTATION_REFLECTION = ROOT / "skills" / "references" / "documentation-reflection-gate.md"
START_README = ROOT / "skills" / "102-sg-start" / "README.md"
START_WORKFLOW = ROOT / "skills" / "102-sg-start" / "references" / "execution-workflow.md"
BUILD_WORKFLOW = ROOT / "skills" / "001-sg-build" / "references" / "build-lifecycle-workflow.md"
SPEC_WORKFLOW = ROOT / "skills" / "100-sg-spec" / "references" / "spec-creation-workflow.md"
READY_WORKFLOW = ROOT / "skills" / "101-sg-ready" / "references" / "readiness-review-playbook.md"
BUG_SKILL = ROOT / "skills" / "003-sg-bug" / "SKILL.md"
DEPLOY_SKILL = ROOT / "skills" / "004-sg-deploy" / "SKILL.md"
DEPLOY_REPORTING = ROOT / "skills" / "004-sg-deploy" / "references" / "deploy-report-template.md"
DESIGN_REPORTING = ROOT / "skills" / "006-sg-design" / "references" / "design-proof-and-reporting.md"
BROWSER_SKILL = ROOT / "skills" / "108-sg-browser" / "SKILL.md"
SYNC_SKILL = ROOT / "skills" / "600-sg-local-cloud-sync" / "SKILL.md"
SHIP_SKILL = ROOT / "skills" / "005-sg-ship" / "SKILL.md"
END_SKILL = ROOT / "skills" / "104-sg-end" / "SKILL.md"
MIGRATE_SKILL = ROOT / "skills" / "010-sg-technical" / "SKILL.md"


def reporting_corpus() -> str:
    return "\n".join(
        path.read_text(encoding="utf-8")
        for path in (REPORTING_CONTRACT, *REPORTING_BRANCHES)
    )


class ReportingContractTests(unittest.TestCase):
    def test_progressive_reporting_branches_are_direct_and_unambiguous(self) -> None:
        core = REPORTING_CONTRACT.read_text(encoding="utf-8")
        for branch in REPORTING_BRANCHES:
            self.assertTrue(branch.is_file(), branch)
            self.assertIn(branch.name, core)
            leaf = branch.read_text(encoding="utf-8")
            for sibling in REPORTING_BRANCHES:
                if sibling != branch:
                    self.assertNotIn(sibling.name, leaf, f"{branch} chains to {sibling}")
        self.assertIn("In `report=agent`, load only agent-handoff", core)
        self.assertIn("structured dependencies above validate", core)

    def test_user_mode_forbids_modified_file_details(self) -> None:
        text = reporting_corpus()
        for rule in (
            "Do not include a modified-files section in `report=user`",
            "file names, paths, or counts",
            "SSRP-008 no modified-file inventory",
        ):
            self.assertIn(rule, text)

    def test_start_public_contract_does_not_promise_file_inventory(self) -> None:
        text = START_README.read_text(encoding="utf-8")
        self.assertNotIn("a concise execution report with files changed", text)

    def test_start_detailed_file_template_is_agent_only(self) -> None:
        text = START_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("For `report=agent` only", text)

    def test_migration_user_template_omits_modified_file_count(self) -> None:
        text = MIGRATE_SKILL.read_text(encoding="utf-8")
        self.assertNotIn("Files modified:   [count]", text)

    def test_user_report_opens_with_chantier_then_verdict(self) -> None:
        text = reporting_corpus()
        expected = (
            "🧱 CHANTIER (<local|spec>) : <name>\n"
            "🎯 VERDICT (HH:mm) : <verdict or status>"
        )
        self.assertIn(expected, text)
        self.assertNotIn("## Compact Chantier Block", text)

    def test_chantier_tracking_uses_opening_header_not_final_block(self) -> None:
        text = CHANTIER_TRACKING.read_text(encoding="utf-8")
        self.assertIn("🧱 CHANTIER (local) : <short work name>", text)
        self.assertIn("🧱 CHANTIER (spec) : <spec title>", text)
        self.assertNotIn("Compact user-mode block:", text)

    def test_timestamp_contract_allows_chantier_before_verdict(self) -> None:
        text = FINAL_TIMESTAMP.read_text(encoding="utf-8")
        self.assertIn("immediately after the chantier header", text)
        self.assertNotIn("Every ShipGlows final report must begin", text)

    def test_activation_contracts_do_not_request_trailing_chantier_blocks(self) -> None:
        legacy_phrases = (
            "compact chantier block",
            "compact `Chantier` block",
            "final `Chantier` block",
        )
        for skill in (ROOT / "skills").glob("*/SKILL.md"):
            if skill.parent.is_symlink():
                continue
            text = skill.read_text(encoding="utf-8")
            for phrase in legacy_phrases:
                self.assertNotIn(phrase, text, f"{skill}: {phrase}")

    def test_verdict_headers_use_time_only(self) -> None:
        for path in (ROOT / "skills").rglob("*.md"):
            if any(parent.is_symlink() for parent in path.parents):
                continue
            text = path.read_text(encoding="utf-8")
            self.assertNotIn("🎯 VERDICT (YYYY-MM-DD HH:mm)", text, str(path))

    def test_user_mode_has_compact_validation_summary(self) -> None:
        text = reporting_corpus()
        self.assertIn(
            "✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236",
            text,
        )
        self.assertIn("SSRP-010 compact validation line", text)

    def test_successful_closure_uses_visual_card_with_compact_lines(self) -> None:
        core = REPORTING_CONTRACT.read_text(encoding="utf-8")
        scenarios = REPORTING_BRANCHES[2].read_text(encoding="utf-8")
        ordered_blocks = (
            "✨ RÉSULTAT",
            "🧪 PREUVES",
            "📚 DOCUMENTATION",
            "📦 LIVRAISON",
        )
        card = core.split("For every successful closure report", 1)[1].split(
            "Translate the four labels", 1
        )[0].split("```text", 1)[1].split("```", 1)[0]
        positions = [card.index(block) for block in ordered_blocks]
        self.assertEqual(positions, sorted(positions))
        for rule in (
            "content beneath `🧪 PREUVES` on exactly one line",
            "content beneath `📚 DOCUMENTATION` on exactly one line",
            "separate proof items with ` · `",
            "`⚠️ LIMITES` and `🧭 SUITE` are conditional",
        ):
            self.assertIn(rule, core)
        self.assertIn("SSRP-019 visual closure card", scenarios)

    def test_closure_reports_make_documentation_reflection_visible(self) -> None:
        core = REPORTING_CONTRACT.read_text(encoding="utf-8")
        scenarios = REPORTING_BRANCHES[2].read_text(encoding="utf-8")
        reflection = DOCUMENTATION_REFLECTION.read_text(encoding="utf-8")
        for expected in (
            "any report that claims a work item is closed, complete, done, resolved, or shipped",
            "For every successful closure report",
            "➖ not impacted · <concrete reason>",
            "material `needs review` result forbids closure or shipping language",
        ):
            self.assertIn(expected, core)
        self.assertIn("SSRP-018 visible closure docs", scenarios)
        self.assertIn("📚 DOCUMENTATION", reflection)
        self.assertIn("use ` · ` for additional compact items", reflection)
        for scenario in (
            "DOC-CLOSE-VISIBLE",
            "DOC-CLOSE-BLOCKED",
            "DOC-CLOSE-UPDATE",
            "DOC-CLOSE-NO-FILLER",
        ):
            self.assertIn(scenario, reflection)

    def test_chantier_and_context_emoji_vocabulary(self) -> None:
        text = reporting_corpus()
        for rule in (
            "`🧱` for the normal chantier header",
            "`🚧` only when the run is blocked",
            "`📂` for a dossier or scope",
            "`🔨` for active implementation or repair",
            "`📌` for a priority, decision, or next action",
        ):
            self.assertIn(rule, text)
        self.assertNotIn("🏗️ CHANTIER", text)

    def test_unfinished_chantier_requires_plain_language_choices(self) -> None:
        text = reporting_corpus()
        for rule in (
            "## Unfinished Chantier Choice",
            "end the message\nwith a numbered, plain-language choice block",
            "strategic-choice-contract.md",
            "business direction",
            "guided follow-up",
            "must never expose skill names, slash commands, lifecycle",
            "`SSRP-012 unfinished chantier choice`",
        ):
            self.assertIn(rule, text)
        for legacy in (
            "Next step: <command or action, only if real>",
            "gives one next command",
            "<file:line or area>",
        ):
            self.assertNotIn(legacy, text)

    def test_user_mode_route_does_not_expose_internal_owners(self) -> None:
        text = reporting_corpus()
        self.assertIn("🧭 Suite : <résultat ou décision à obtenir>", text)
        self.assertIn("Never name a skill, command, lifecycle phase", text)
        timestamp = FINAL_TIMESTAMP.read_text(encoding="utf-8")
        self.assertIn("🧭 Suite : <outcome or decision>", timestamp)
        self.assertNotIn("🧭 Route: <owner>", timestamp)
        chantier = CHANTIER_TRACKING.read_text(encoding="utf-8")
        self.assertNotIn("Spec recommandee: /100-sg-spec", chantier)
        self.assertNotIn("Prochaine etape: <next ShipGlows command", chantier)

    def test_recurrence_claim_boundary_requires_scope_matched_proof(self) -> None:
        boundary = REPORTING_BRANCHES[1].read_text(encoding="utf-8").split(
            "## Recurrence-Claim Boundary", 1
        )[1]
        scenarios = REPORTING_BRANCHES[2].read_text(encoding="utf-8")

        # The local outcome, universal-claim gate, and proof limit must remain
        # linked as one contract; a bare list of prohibited words is insufficient.
        for rule in (
            "cause and context actually tested",
            "known conditions that could reintroduce it",
            "other\nprojects, configurations, or future changes",
            "unless all three conditions are present: an explicit preventive invariant,",
            "an invariant scope that covers exactly the claimed scope, and focused\nmechanical proof that was run for that invariant",
            "A generic lint, build, or\naudit never proves that operational invariant on its own.",
        ):
            self.assertIn(rule, boundary)

        case_expectations = {
            "local-repair": (
                "bounded result",
                "known recurrence conditions",
                "all projects or future changes",
            ),
            "unsupported-guarantee": (
                "preventive invariant whose scope covers the claim",
                "“pour toujours”, “garanti”, “ne se reproduira pas”",
                "semantic equivalents",
            ),
            "proofless-invariant": (
                "without focused mechanical proof",
                "does not authorize a universal non-recurrence claim",
            ),
            "covered-invariant": (
                "invariant, its scope, and its focused mechanical proof",
                "only for that covered scope",
            ),
        }
        self.assertIn("SSRP-013 recurrence-claim-boundary", scenarios)
        for case, expectations in case_expectations.items():
            scenario = scenarios.split(f"`{case}`:", 1)[1].split("\n  - `", 1)[0]
            for expectation in expectations:
                self.assertIn(expectation, scenario, f"{case}: {expectation}")

    def test_build_user_template_hides_internal_flow(self) -> None:
        text = BUILD_WORKFLOW.read_text(encoding="utf-8")
        self.assertNotIn("Flux: 100-sg-spec", text)
        self.assertNotIn("Customer suggestion: /008-sg-customer", text)
        self.assertIn("Ne jamais exposer une commande, un skill, un", text)

        user_sections = {
            SPEC_WORKFLOW: ("**Rapport final :**", "\n---"),
            READY_WORKFLOW: ("In `report=user`", "Use the detailed form"),
            BUG_SKILL: ("## Final Report", "## Rules"),
            DEPLOY_REPORTING: ("## User Report Compression", "## Maintenance Rule"),
            DESIGN_REPORTING: ("## User-Mode Report", "Agent/handoff mode"),
            BROWSER_SKILL: ("## Final Report Shape", None),
            SYNC_SKILL: ("User mode:", "Agent/handoff mode"),
            SHIP_SKILL: ("## Step 8 — One report", "## Rules"),
            END_SKILL: ("### Step 5 — Report", "### Rules"),
        }
        forbidden = (
            "Flux: 100-sg-spec",
            "Route: [",
            "Prochaine etape: /",
            "Skill courante:",
            "Spec: [path]",
            "run /005-sg-ship",
        )
        for path, (start, end) in user_sections.items():
            full_text = path.read_text(encoding="utf-8")
            section = full_text.split(start, 1)[1]
            if end is not None:
                section = section.split(end, 1)[0]
            for legacy in forbidden:
                self.assertNotIn(legacy, section, f"{path}: {legacy}")

        self.assertIn("## Report Modes", BROWSER_SKILL.read_text(encoding="utf-8"))
        self.assertIn(
            "Blocked user reports remain plain-language",
            DEPLOY_SKILL.read_text(encoding="utf-8"),
        )


if __name__ == "__main__":
    unittest.main()
