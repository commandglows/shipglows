#!/usr/bin/env python3
"""Scenario tests for deterministic ShipGlows resource discovery."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.resource_resolver import (
    DEFAULT_MAX_TOKENS,
    Resource,
    ResolverError,
    _bounded_pack,
    build_catalog,
    expand_resource,
    get_resource,
    resolve_resource_pack,
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
        self.assertLessEqual(sum(item.estimated_tokens for item in first), DEFAULT_MAX_TOKENS)

    def test_pack_respects_token_cap_and_reports_oversize_resource(self) -> None:
        pack = resolve_resource_pack(
            root=ROOT,
            skill="009-sg-marketing",
            mode="copywriting",
            intent="landing page proof objections CTA sequence",
            limit=8,
            max_tokens=5_000,
        )
        self.assertLessEqual(pack.estimated_tokens, 5_000)
        self.assertLessEqual(len(pack.resources), 8)
        self.assertTrue(pack.skipped)
        self.assertTrue(
            all(exclusion.reason == "estimated token budget exceeded" for exclusion in pack.skipped)
        )
        for exclusion in pack.skipped:
            self.assertGreater(exclusion.resource.estimated_tokens, 0)
            self.assertTrue(exclusion.resource.status)

    def test_oversize_first_candidate_does_not_block_smaller_candidate(self) -> None:
        resource = get_resource(ROOT, "shared:landing-page-copywriting-framework")
        oversized = Resource(
            **{
                **resource.__dict__,
                "resource_id": "shared:oversized",
                "estimated_tokens": 100,
                "score": 100,
            }
        )
        smaller = Resource(
            **{
                **resource.__dict__,
                "resource_id": "shared:smaller",
                "path": ROOT / "skills/references/decision-quality-contract.md",
                "estimated_tokens": 10,
                "score": 90,
            }
        )
        pack = _bounded_pack((oversized, smaller), limit=2, max_tokens=50)
        self.assertEqual([item.resource_id for item in pack.resources], ["shared:smaller"])
        self.assertEqual(pack.skipped[0].resource.resource_id, "shared:oversized")

    def test_duplicate_canonical_resource_is_selected_once_and_reported(self) -> None:
        resource = get_resource(ROOT, "shared:decision-quality-contract")
        duplicate = Resource(
            **{
                **resource.__dict__,
                "resource_id": "shared:decision-quality-contract-alias",
                "score": 90,
            }
        )
        pack = _bounded_pack((resource, duplicate), limit=2, max_tokens=50_000)
        self.assertEqual(len(pack.resources), 1)
        self.assertEqual(pack.skipped[0].reason, "duplicate canonical resource")

    def test_statuses_remain_visible_and_reviewed_is_not_rewritten(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            shared = root / "skills/references"
            shared.mkdir(parents=True)
            skill = root / "skills/009-sg-marketing"
            skill.mkdir(parents=True)
            (skill / "SKILL.md").write_text("---\nname: 009-sg-marketing\n---\n", encoding="utf-8")
            for status in ("active", "draft", "unknown", "reviewed"):
                (shared / f"{status}.md").write_text(
                    "---\nartifact: contract\n"
                    f"status: {status}\n"
                    "scope: status-check\n---\n# Status Check\nstatus terms\n",
                    encoding="utf-8",
                )
            pack = resolve_resource_pack(
                root,
                "009-sg-marketing",
                mode="status",
                intent="status check",
                limit=4,
                max_tokens=1_000,
            )
            statuses = {item.status for item in pack.resources}
            self.assertEqual(statuses, {"active", "draft", "unknown", "reviewed"})
            reasons = {item.status: item.reasons for item in pack.resources}
            self.assertIn("status: reviewed", reasons["reviewed"])
            self.assertIn("status: unknown", reasons["unknown"])

    def test_invalid_token_cap_fails_visibly(self) -> None:
        with self.assertRaisesRegex(ResolverError, "max_tokens must be at least 1"):
            resolve_resource_pack(ROOT, "009-sg-marketing", "copywriting", "landing", max_tokens=0)

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
