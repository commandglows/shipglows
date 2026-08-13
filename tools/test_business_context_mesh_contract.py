#!/usr/bin/env python3
"""Contract checks for the shared business-context mesh."""

import json
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
MESH = SKILLS / "references" / "business-context-mesh.md"
AUTONOMY = SKILLS / "references" / "intent-to-outcome-autonomy.md"
PARTNERSHIP = SKILLS / "references" / "operator-partnership-contract.md"
PROFILE_CONTEXT = SKILLS / "references" / "profile-project-context.md"
REGISTRY = SKILLS / "references" / "skill-invocation-registry.json"


class BusinessContextMeshContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.mesh = MESH.read_text(encoding="utf-8")
        cls.autonomy = AUTONOMY.read_text(encoding="utf-8")
        cls.partnership = PARTNERSHIP.read_text(encoding="utf-8")
        cls.profile_context = PROFILE_CONTEXT.read_text(encoding="utf-8")
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))

    def test_all_business_source_families_are_routed(self) -> None:
        expected = (
            "business/business.md",
            "business/product.md",
            "business/gtm.md",
            "branding/branding.md",
            "business/portfolio-project-pitch-links.md",
            "business/project-competitors-and-inspirations.md",
            "business/affiliate-programs.md",
        )
        for path in expected:
            self.assertIn(path, self.mesh)

    def test_mesh_is_project_first_selective_and_quality_aware(self) -> None:
        for required in (
            "active project's governance root",
            "smallest coherent source bundle",
            "Do not read every family by default",
            "draft",
            "hypothesis",
            "unknown",
            "overdue review",
            "context_conflict",
            "guided-business-product-discovery.md",
            "product-decision-chain.md",
        ):
            self.assertIn(required, self.mesh)
        self.assertIn("never product, customer, market, or commercial truth", self.mesh)

    def test_common_business_partner_paths_load_the_mesh(self) -> None:
        self.assertIn("business-context-mesh.md", self.autonomy)
        self.assertIn("business-context-mesh.md", self.partnership)
        self.assertIn("business-context-mesh.md", self.profile_context)

    def test_material_gaps_trigger_guided_governance_refresh(self) -> None:
        for required in (
            "## Governance Refresh Loop",
            "Preserve the original outcome",
            "research agent-discoverable facts first",
            "proposed interpretation",
            "ask one high-leverage business question",
            "mutation-plan-approval.md",
            "Resume the original outcome automatically",
            "A stale review date alone does not justify interruption",
            "BUSINESS-MESH-05 ACTIVE-REFRESH",
            "BUSINESS-MESH-06 NO-QUESTION-OFFLOAD",
        ):
            self.assertIn(required, self.mesh)

    def test_every_public_owner_reaches_the_mesh_through_autonomy(self) -> None:
        catalog = self.registry["public_catalog"]
        entries = [catalog["router"]]
        entries.extend(skill for domain in catalog["domains"] for skill in domain["skills"])
        for entry in entries:
            public = (SKILLS / str(entry["public_skill"]) / "SKILL.md").read_text(encoding="utf-8")
            runtime = (SKILLS / str(entry["runtime_skill"]) / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("intent-to-outcome-autonomy.md", public, entry["public_skill"])
            self.assertIn("intent-to-outcome-autonomy.md", runtime, entry["runtime_skill"])

    def test_high_traffic_activation_profiles_expose_direct_gate(self) -> None:
        profiles = self.registry["activation_profiles"]["skills"]
        expected = ["skills/references/business-context-mesh.md"]
        for skill in ("004-sg-deploy", "010-sg-technical", "300-sg-docs"):
            self.assertEqual(expected, profiles[skill]["gates"]["business-context"], skill)


if __name__ == "__main__":
    unittest.main()
