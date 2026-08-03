#!/usr/bin/env python3
"""Scenario tests for deterministic ShipGlows resource discovery."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.resource_resolver import (
    ResolverError,
    build_catalog,
    expand_resource,
    get_resource,
    resolve_resources,
)


ROOT = Path(__file__).resolve().parents[1]


class ResourceResolverTests(unittest.TestCase):
    def test_landing_copywriting_intent_returns_shared_framework_and_local_playbook(self) -> None:
        results = resolve_resources(
            root=ROOT,
            skill="009-sg-marketing",
            mode="copywriting",
            intent="improve a landing page section flow and remove repetition",
            limit=8,
        )
        ids = [item.resource_id for item in results]
        self.assertIn("shared:landing-page-copywriting-framework", ids)
        self.assertIn("009-sg-marketing:copywriting-audit-playbook", ids)
        self.assertEqual(
            set(ids[:2]),
            {
                "shared:landing-page-copywriting-framework",
                "009-sg-marketing:copywriting-audit-playbook",
            },
        )
        for item in results:
            self.assertTrue(item.reasons)
            self.assertTrue(item.path.is_absolute())

    def test_unrelated_technical_intent_does_not_surface_landing_framework(self) -> None:
        results = resolve_resources(
            root=ROOT,
            skill="010-sg-technical",
            mode="deps",
            intent="audit dependency supply chain and outdated packages",
            limit=5,
        )
        self.assertNotIn(
            "shared:landing-page-copywriting-framework",
            [item.resource_id for item in results],
        )

    def test_expand_landing_framework_returns_declared_neighbors(self) -> None:
        results = expand_resource(
            root=ROOT,
            resource_id="shared:landing-page-copywriting-framework",
            limit=10,
        )
        ids = [item.resource_id for item in results]
        self.assertIn("009-sg-marketing:copywriting-audit-playbook", ids)
        self.assertIn("shared:decision-quality-contract", ids)

    def test_stable_id_resolves_one_exact_resource_path(self) -> None:
        resource = get_resource(ROOT, "shared:decision-quality-contract")
        self.assertEqual(resource.resource_id, "shared:decision-quality-contract")
        self.assertEqual(resource.relative_path, "skills/references/decision-quality-contract.md")

    def test_semantic_discovery_id_used_by_help_and_core_resolves(self) -> None:
        resource = get_resource(ROOT, "shared:resource-discovery")
        self.assertEqual(resource.status, "active")
        for skill in ("302-sg-help", "900-shipglows-core"):
            contract = (ROOT / "skills" / skill / "SKILL.md").read_text(encoding="utf-8")
            self.assertIn("shared:resource-discovery", contract)

    def test_results_are_deterministic_and_bounded(self) -> None:
        kwargs = {
            "root": ROOT,
            "skill": "009-sg-marketing",
            "mode": "copywriting",
            "intent": "landing page proof objections CTA sequence",
            "limit": 4,
        }
        first = resolve_resources(**kwargs)
        second = resolve_resources(**kwargs)
        self.assertEqual(
            [(item.resource_id, item.score) for item in first],
            [(item.resource_id, item.score) for item in second],
        )
        self.assertLessEqual(len(first), 4)

    def test_unknown_skill_and_resource_fail_without_guessing(self) -> None:
        with self.assertRaises(ResolverError):
            resolve_resources(ROOT, "999-sg-imaginary", "audit", "anything", 5)
        with self.assertRaises(ResolverError):
            expand_resource(ROOT, "shared:not-a-real-resource", 5)

    def test_inactive_resources_are_excluded_by_default(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            shared = root / "skills/references"
            shared.mkdir(parents=True)
            (root / "skills/009-sg-marketing").mkdir(parents=True)
            (root / "skills/009-sg-marketing/SKILL.md").write_text("---\nname: 009-sg-marketing\n---\n", encoding="utf-8")
            (shared / "active.md").write_text(
                "---\nartifact: contract\nstatus: active\nscope: landing-copy\n---\n# Landing Copy\n",
                encoding="utf-8",
            )
            (shared / "retired.md").write_text(
                "---\nartifact: contract\nstatus: retired\nscope: landing-copy\n---\n# Landing Copy\n",
                encoding="utf-8",
            )
            catalog = build_catalog(root)
            self.assertIn("shared:active", catalog)
            self.assertNotIn("shared:retired", catalog)


if __name__ == "__main__":
    unittest.main()
