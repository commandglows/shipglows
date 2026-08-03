#!/usr/bin/env python3
"""Scenario-first regression contract for the 007 repurpose consolidation."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path

from tools.test_support import optional_public_site


ROOT = Path(__file__).resolve().parents[1]
PUBLIC_SITE = optional_public_site(ROOT)
RETIRED = re.compile(r"202-sg-repurpose|sg-repurpose|sg-repurpose|/sg-repurpose", re.IGNORECASE)
ACTIVE_SUFFIXES = {".md", ".json", ".astro", ".py", ".yaml", ".yml"}
HISTORICAL_PREFIXES = (
    "shipglows_data/workflow/archives/",
    "shipglows_data/workflow/audits/",
    "shipglows_data/workflow/reviews/",
    "shipglows_data/workflow/repurpose-packs/",
    "shipglows_data/workflow/research/",
)
HISTORICAL_FILES = {
    "skills/REFRESH_LOG.md",
    "shipglows_data/workflow/TASKS.md",  # Explicitly preserved outside this migration.
    "shipglows_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md",
    "shipglows_data/workflow/specs/audit-skill-domain-mode-taxonomy-migration.md",
    "shipglows_data/workflow/specs/compact-shipglows-skill-instructions-phase-2.md",
    "shipglows_data/workflow/specs/compact-shipglows-skill-instructions.md",
    "shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md",
    "shipglows_data/workflow/specs/consolidate-repurpose-mode-under-sg-content.md",
    "shipglows_data/workflow/specs/content-owner-skills-governance-integration.md",
    "shipglows_data/workflow/specs/emailing-sequences-audience-skill.md",
    "shipglows_data/workflow/specs/grille-notation-editoriale-projet-skills-contenu.md",
    "shipglows_data/workflow/specs/local-mcp-oauth-tunnel-login.md",
    "shipglows_data/workflow/specs/public-skill-categories.md",
    "shipglows_data/workflow/specs/sg-content-master-content-lifecycle-skill.md",
    "shipglows_data/workflow/specs/sg-repurpose-actionable-article-ideas-output.md",
    "shipglows_data/workflow/specs/sg-repurpose-existing-content-placement-opportunities.md",
    "shipglows_data/workflow/specs/sg-veille-governance-content-alignment.md",
    "shipglows_data/workflow/specs/shipglows-editorial-content-governance-layer-for-ai-agents.md",
    "shipglows_data/workflow/specs/skill-description-budget-compliance.md",
    "shipglows_data/workflow/specs/skill-taxonomy-and-chantier-sources.md",
    "shipglows_data/workflow/specs/specs-as-chantier-registry.md",
    "shipglows_data/workflow/specs/three-digit-runtime-skill-names.md",
    "tools/test_010_sg_technical_contract.py",
}


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


class RepurposeModeContractTest(unittest.TestCase):
    def test_transcript_modes_are_public_and_distinct(self) -> None:
        router = read("skills/007-sg-content/references/content-router.md")
        skill = read("skills/007-sg-content/SKILL.md")
        if PUBLIC_SITE is None:
            self.skipTest("optional shipglows-site checkout is not available")
        public = (PUBLIC_SITE / "src/content/skills/sg-content.md").read_text(encoding="utf-8")
        for mode in ("capture-full-conversation", "clean-transcript", "verbatim"):
            self.assertIn(mode, router + skill + public)
        self.assertIn("internal `800-tmux-capture-conversation`", router)
        self.assertIn("internal `801-clean-conversation-transcript`", router)
        self.assertIn("do not clean or repurpose", router)
        self.assertIn("do not capture a new pane", router)

    def test_scenario_first_mode_and_verbatim_contract(self) -> None:
        router = read("skills/007-sg-content/references/content-router.md")
        playbook = read("skills/007-sg-content/references/repurpose-playbook.md")
        self.assertIn("repurpose <source>", router)
        self.assertIn("bare `repurpose` asks for a source", router)
        self.assertIn("references/repurpose-playbook.md", router)
        for phrase in ("verbatim", "mot pour mot", "copie exacte", "chronological order", "no analysis"):
            self.assertIn(phrase, playbook)
        self.assertIn("never dispatches to a second public repurpose skill", playbook)

    def test_source_safety_storage_and_owner_boundaries(self) -> None:
        playbook = read("skills/007-sg-content/references/repurpose-playbook.md")
        for phrase in (
            "secret-bearing, private, unavailable, wrong-repository, or too-thin",
            "never use a fallback storage location",
            "Existing Content Opportunities",
            "diffusion map",
            "source-faithful-pack-contract.md",
            "content-owner-handoffs.md",
            "does not draft, apply, audit, publish, verify, or ship",
        ):
            self.assertIn(phrase, playbook)

    def test_transfer_matrix_covers_each_rule_family(self) -> None:
        matrix = read("skills/007-sg-content/references/repurpose-migration-evidence.md")
        for family in (
            "Verbatim", "Source classification", "Canonical pack order",
            "Existing-content", "Diffusion map", "Quality score", "Declared-public",
            "Durable pack", "Source safety", "Exact downstream handoffs",
        ):
            self.assertIn(family, matrix)

    def test_retired_source_and_public_identity_are_absent(self) -> None:
        self.assertFalse((ROOT / "skills/202-sg-repurpose").exists())
        if PUBLIC_SITE is not None:
            self.assertFalse((PUBLIC_SITE / "src/content/skills/sg-repurpose.md").exists())
        self.assertNotIn("202-sg-repurpose", read("skills/references/skill-code-index.md"))
        catalog = json.loads(read("plugins/shipglows/assets/pack-catalog.json"))
        self.assertNotIn("202-sg-repurpose", json.dumps(catalog))
        if PUBLIC_SITE is not None:
            self.assertNotIn(
                "sg-repurpose",
                (PUBLIC_SITE / "src/content/skills/sg-content.md").read_text(encoding="utf-8"),
            )
            self.assertNotIn(
                "sg-repurpose",
                (PUBLIC_SITE / "src/pages/skills/index.astro").read_text(encoding="utf-8"),
            )

    def test_no_retired_name_in_active_surface(self) -> None:
        violations: list[str] = []
        for path in ROOT.rglob("*"):
            if not path.is_file() or path.suffix not in ACTIVE_SUFFIXES:
                continue
            relative = path.relative_to(ROOT).as_posix()
            if relative == "tools/test_007_sg_content_repurpose_contract.py":
                continue
            if relative in HISTORICAL_FILES or relative.startswith(HISTORICAL_PREFIXES):
                continue
            if any(part in {".git", "node_modules", "dist", ".astro"} for part in path.parts):
                continue
            if RETIRED.search(path.read_text(encoding="utf-8", errors="ignore")):
                violations.append(relative)
        self.assertEqual([], violations, f"retired active identities: {violations}")


if __name__ == "__main__":
    unittest.main()
