#!/usr/bin/env python3
"""Pressure scenarios for the global ShipGlows auto and nolocal modes."""

import json
from pathlib import Path
import unittest

from tools.skill_invocation_check import check


ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "skills" / "shipglows" / "SKILL.md"
ROUTER = ROOT / "skills" / "000-shipglows" / "SKILL.md"
AUTO = ROOT / "skills" / "708-sg-auto" / "SKILL.md"
AUTO_PLAYBOOK = ROOT / "skills" / "708-sg-auto" / "references" / "auto-credit-window-playbook.md"
AUTO_COORDINATION = ROOT / "skills" / "708-sg-auto" / "references" / "auto-session-coordination.md"
AUTO_POLICY = ROOT / "skills" / "708-sg-auto" / "agents" / "openai.yaml"
NOLOCAL = ROOT / "skills" / "references" / "no-local-execution-policy.md"
APPROVAL = ROOT / "skills" / "references" / "mutation-plan-approval.md"
DELEGATION = ROOT / "skills" / "references" / "master-delegation-semantics.md"
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"
INDEX = ROOT / "skills" / "references" / "skill-code-index.md"
GITIGNORE = ROOT / ".gitignore"


class ShipGlowsAutoNolocalContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.public = PUBLIC.read_text(encoding="utf-8")
        cls.router = ROUTER.read_text(encoding="utf-8")
        cls.auto = AUTO.read_text(encoding="utf-8")
        cls.playbook = AUTO_PLAYBOOK.read_text(encoding="utf-8")
        cls.coordination = AUTO_COORDINATION.read_text(encoding="utf-8")
        cls.nolocal = NOLOCAL.read_text(encoding="utf-8")
        cls.approval = APPROVAL.read_text(encoding="utf-8")
        cls.delegation = DELEGATION.read_text(encoding="utf-8")
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        cls.index = INDEX.read_text(encoding="utf-8")
        cls.public_flat = " ".join(cls.public.split())
        cls.router_flat = " ".join(cls.router.split())
        cls.auto_flat = " ".join(cls.auto.split())
        cls.playbook_flat = " ".join(cls.playbook.split())
        cls.coordination_flat = " ".join(cls.coordination.split())
        cls.nolocal_flat = " ".join(cls.nolocal.split())
        cls.approval_flat = " ".join(cls.approval.split())
        cls.delegation_flat = " ".join(cls.delegation.split())

    def test_public_modes_route_without_colliding_with_local_auto_modes(self) -> None:
        router_entry = self.registry["public_catalog"]["router"]
        self.assertIn("auto", router_entry["modes"])
        self.assertNotIn("nolocal", router_entry["modes"])
        self.assertIn("nolocal", router_entry["legacy_execution_aliases"])
        self.assertIn("708-sg-auto", router_entry["internal_engines"])
        self.assertIn("shipglows auto", self.public_flat)
        self.assertIn("`shipglows nolocal <objective>`", self.public_flat)
        self.assertIn("`708-sg-auto`", self.router_flat)

        auto = check("shipglows auto")
        self.assertEqual("valid", auto["status"])
        self.assertEqual("auto", auto["mode"])
        self.assertEqual("708-sg-auto", auto["selected_internal_engine"])
        self.assertEqual("708-sg-auto", auto["activation_profile"])
        nolocal = check("shipglows nolocal improve checkout")
        self.assertEqual("valid", nolocal["status"])
        self.assertEqual("default", nolocal["mode"])
        self.assertEqual("nolocal", nolocal["mode_alias"])
        self.assertEqual(["#nolocal"], nolocal["effective_execution_tags"])
        self.assertEqual("000-shipglows", nolocal["selected_internal_engine"])

        docs_auto = check("sg-docs auto")
        self.assertEqual("valid", docs_auto["status"])
        self.assertEqual("auto", docs_auto["mode"])

        auto_local = check("shipglows auto local")
        self.assertEqual("invalid", auto_local["status"])
        self.assertEqual("unsupported_mode_option", auto_local["error"])
        auto_tag_local = check("shipglows auto #local")
        self.assertEqual("invalid", auto_tag_local["status"])
        self.assertEqual("unsupported_execution_tag", auto_tag_local["error"])
        bare_nolocal = check("shipglows nolocal")
        self.assertEqual("invalid", bare_nolocal["status"])
        self.assertEqual("missing_argument", bare_nolocal["error"])

    def test_auto_always_composes_nolocal_and_has_no_local_override(self) -> None:
        for text in (self.router, self.auto, self.playbook):
            self.assertIn("no-local-execution-policy.md", text)
        self.assertIn("always and implicitly applies", self.auto_flat)
        self.assertIn("legacy `auto local` are invalid", self.auto_flat)
        self.assertIn("`auto nolocal`", self.auto_flat)
        self.assertIn("`auto #nolocal`", self.auto_flat)
        self.assertIn("Every delegated mission inherits the frozen root and nolocal", self.playbook_flat)

    def test_useful_value_not_credit_burn_owns_priority_and_effort(self) -> None:
        self.assertIn("safety, authority, and evidence eligibility", self.playbook_flat)
        self.assertIn("durable project value delivered per remaining wall-clock minute", self.playbook_flat)
        self.assertIn("primary ordering dimension", self.playbook_flat.lower())
        for workload in (
            "deep architecture analysis",
            "security and compliance",
            "multi-file implementation",
            "complex refactoring",
            "large-context review",
        ):
            self.assertIn(workload, self.playbook_flat)
        self.assertIn("Never invent work or produce artificial output", self.playbook_flat)
        self.assertIn("Never prefer a more expensive model or effort merely because credits expire", self.playbook_flat)
        self.assertIn("Do not ramp effort according to elapsed time", self.playbook_flat)
        self.assertIn("lowest reasoning effort that preserves the required quality", self.auto_flat)

    def test_subagents_are_authorized_recommended_and_value_gated(self) -> None:
        self.assertIn("same invocation authorizes bounded subagents", self.approval_flat)
        self.assertIn("`708-sg-auto` is the narrow exception", self.delegation_flat)
        self.assertIn("authorized and recommended", self.auto_flat)
        self.assertIn("independent useful missions", self.auto_flat)
        self.assertIn("Keep a cohesive task main-only", self.auto_flat)
        self.assertIn("never by itself for mutation", self.delegation_flat)
        self.assertIn("Every write mission requires valid mutation authority", self.delegation_flat)
        self.assertIn("Auto-session authority", self.delegation_flat)

    def test_parent_and_subagents_are_confined_to_frozen_launch_root(self) -> None:
        self.assertIn("Frozen project root", self.auto)
        self.assertIn("sole work root", self.auto_flat)
        self.assertIn("symlink whose real target leaves the frozen root", self.auto_flat)
        for boundary in ("sibling repository", "clone another repository", "another worktree"):
            self.assertIn(boundary, self.auto_flat)
        self.assertIn("every subagent must receive it explicitly", self.auto_flat)
        self.assertIn("captured_git_root", self.coordination_flat)

    def test_fast_is_observed_but_never_self_assigned(self) -> None:
        self.assertIn("Fast is a client/service-tier setting", self.auto_flat)
        self.assertIn("runtime proves it is already active", self.auto_flat)
        self.assertIn("Never claim to self-activate Fast", self.auto_flat)
        self.assertIn("`active`, `inactive`, or `unknown`", self.playbook_flat)
        self.assertIn("does not self-assign Fast", self.playbook_flat)
        self.assertIn("never inherits the parent's state", self.playbook_flat)

    def test_concurrent_sessions_use_atomic_root_local_claims(self) -> None:
        self.assertIn("tools/shipglows_auto_claim.py", self.coordination_flat)
        self.assertIn("atomic exclusive creation", self.coordination_flat)
        self.assertIn("Never reclaim, expire, delete, or replace", self.coordination_flat)
        self.assertIn("AUTO-CLAIM-RACE", self.coordination)
        self.assertIn("AUTO-CLAIM-PATH-OVERLAP", self.coordination)
        self.assertIn("/.shipglows-auto/", GITIGNORE.read_text(encoding="utf-8"))
        self.assertIn("before every mutating candidate", self.auto_flat)
        self.assertIn("Every mutation requires an atomic claim", self.auto_flat)
        self.assertIn("No auto mutation may continue", self.coordination_flat)
        gates = self.registry["activation_profiles"]["skills"]["708-sg-auto"]["gates"]
        self.assertIn("multi-session-coordination", gates)

    def test_nolocal_forbids_workload_and_external_execution(self) -> None:
        self.assertIn("Allowed operations", self.nolocal)
        self.assertIn("Forbidden operations", self.nolocal)
        for forbidden in (
            "builds",
            "tests",
            "lint",
            "typechecks",
            "dependency installation",
            "application servers",
            "browsers",
            "containers",
            "executed migrations",
            "commits",
            "pushes",
            "deployments",
        ):
            self.assertIn(forbidden, self.nolocal_flat)
        self.assertIn("implemented — unverified", self.nolocal_flat)
        self.assertIn("read-only Git status and diff inspection", self.nolocal_flat)

    def test_auto_authority_is_bounded_and_nolocal_is_not_an_authority_bypass(self) -> None:
        self.assertIn("Auto-session authority", self.approval_flat)
        self.assertIn("explicit `shipglows auto` invocation", self.approval_flat)
        self.assertIn("`#local`, `#nolocal`, and `#ci`", self.approval_flat)
        self.assertIn("grant no mutation authority", self.approval_flat)
        for forbidden in (
            "destructive",
            "credential",
            "permission",
            "billing",
            "production",
            "external",
        ):
            self.assertIn(forbidden, self.approval_flat)

    def test_auto_skips_blocked_candidates_and_never_claims_verification(self) -> None:
        self.assertIn("skip the candidate and continue", self.auto_flat)
        self.assertIn("implemented — unverified", self.auto_flat)
        for false_claim in ("fixed", "verified", "secure", "compliant", "closed", "shipped"):
            self.assertIn(f"`{false_claim}`", self.auto_flat)
        self.assertIn("deferred verification commands", self.playbook_flat)

    def test_auto_engine_is_internal_and_registered_once(self) -> None:
        self.assertIn("| `708` | `sg-auto` | `708-sg-auto` |", self.index)
        self.assertEqual(1, self.index.count("| `708` | `sg-auto` | `708-sg-auto` |"))
        self.assertEqual("policy:\n  allow_implicit_invocation: false", AUTO_POLICY.read_text(encoding="utf-8").strip())
        self.assertEqual("708-sg-auto", self.auto.split("name: ", 1)[1].splitlines()[0])


if __name__ == "__main__":
    unittest.main()
