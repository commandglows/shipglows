#!/usr/bin/env python3
"""Scenario-first tests for the ShipGlows skill discovery budget audit."""

from __future__ import annotations

import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools import skill_budget_audit as audit


class SkillBudgetAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.root = Path(self.temp_dir.name)

    def make_skill(
        self,
        skills_root: Path,
        name: str,
        *,
        description: str | None = None,
        implicit: bool | str | None = None,
    ) -> Path:
        skill_dir = skills_root / name
        skill_dir.mkdir(parents=True, exist_ok=True)
        skill_file = skill_dir / "SKILL.md"
        skill_file.write_text(
            "---\n"
            f"name: {name}\n"
            f"description: {description or f'Route {name} work.'}\n"
            "---\n\n"
            f"# {name}\n",
            encoding="utf-8",
        )
        if implicit is not None:
            agents_dir = skill_dir / "agents"
            agents_dir.mkdir()
            value = str(implicit).lower() if isinstance(implicit, bool) else implicit
            (agents_dir / "openai.yaml").write_text(
                "policy:\n"
                f"  allow_implicit_invocation: {value}\n",
                encoding="utf-8",
            )
        return skill_file

    def make_registry(
        self,
        skills_root: Path,
        *,
        public: tuple[str, ...] = ("sg-alpha",),
        router: str = "shipglows",
        include_all: bool = True,
    ) -> tuple[Path, dict[str, object]]:
        registry: dict[str, object] = {
            "format_version": "test",
            "public_catalog": {
                "domains": [
                    {
                        "id": "test",
                        "skills": [
                            {
                                "public_skill": name,
                                "runtime_skill": f"engine-{index}",
                                "internal_engines": [f"helper-{index}"],
                            }
                            for index, name in enumerate(public)
                        ],
                    }
                ],
                "router": {
                    "public_skill": router,
                    "runtime_skill": "000-router",
                },
            },
            "codex_expert_aliases": {
                "expert": {"runtime_engine": "alias-engine"},
            },
            "internal_catalog": {"include_all_runtime_skills": include_all},
        }
        registry_path = skills_root / "references" / "skill-invocation-registry.json"
        registry_path.parent.mkdir(parents=True, exist_ok=True)
        registry_path.write_text(json.dumps(registry), encoding="utf-8")
        return registry_path, registry

    def test_discovery_catalogs_are_derived_from_registry(self) -> None:
        available = {"sg-alpha", "shipglows", "engine-0", "helper-0", "orphan"}
        _, registry = self.make_registry(self.root / "skills")

        catalogs = audit.build_catalogs(registry, available)

        self.assertEqual(catalogs.public, frozenset({"sg-alpha", "shipglows"}))
        self.assertEqual(catalogs.expert, frozenset({"engine-0", "helper-0", "orphan"}))
        self.assertEqual(catalogs.all, frozenset(available))
        self.assertEqual(catalogs.errors, ())

    def test_declared_expert_catalog_is_used_when_include_all_is_disabled(self) -> None:
        available = {"sg-alpha", "shipglows", "engine-0", "helper-0", "alias-engine", "orphan"}
        _, registry = self.make_registry(self.root / "skills", include_all=False)

        catalogs = audit.build_catalogs(registry, available)

        self.assertEqual(
            catalogs.expert,
            frozenset({"engine-0", "helper-0", "000-router", "alias-engine"})
            & available,
        )
        self.assertNotIn("orphan", catalogs.all)

    def test_implicit_mode_filters_experts_but_installed_mode_keeps_them(self) -> None:
        skills_root = self.root / "skills"
        self.make_skill(skills_root, "sg-alpha", implicit=True)
        self.make_skill(skills_root, "shipglows")
        self.make_skill(skills_root, "engine", implicit=False)
        _, registry = self.make_registry(skills_root)
        audits = audit.audit_all(skills_root, batch_size=8)
        catalogs = audit.build_catalogs(registry, {item.name for item in audits})

        implicit = audit.select_audits(audits, catalogs, "all", "implicit")
        installed = audit.select_audits(audits, catalogs, "all", "installed")

        self.assertEqual({item.name for item in implicit}, {"sg-alpha", "shipglows"})
        self.assertEqual({item.name for item in installed}, {"sg-alpha", "shipglows", "engine"})

    def test_portable_verdict_is_clone_depth_invariant(self) -> None:
        shallow = self.root / "a" / "skills"
        deep = self.root / "a" / "much" / "deeper" / "checkout" / "skills"
        for skills_root in (shallow, deep):
            self.make_skill(skills_root, "sg-alpha")
            self.make_skill(skills_root, "shipglows")
            self.make_registry(skills_root)

        shallow_audits = audit.audit_all(shallow, 8)
        deep_audits = audit.audit_all(deep, 8)
        registry = audit.load_registry(shallow / "references" / "skill-invocation-registry.json")
        shallow_catalogs = audit.build_catalogs(registry, {item.name for item in shallow_audits})
        deep_catalogs = audit.build_catalogs(registry, {item.name for item in deep_audits})
        shallow_selected = audit.select_audits(shallow_audits, shallow_catalogs, "all", "implicit")
        deep_selected = audit.select_audits(deep_audits, deep_catalogs, "all", "implicit")

        self.assertEqual(
            audit.summary(shallow_selected)["relative_budget"],
            audit.summary(deep_selected)["relative_budget"],
        )
        self.assertNotEqual(
            audit.summary(shallow_selected)["absolute_budget"],
            audit.summary(deep_selected)["absolute_budget"],
        )
        portable = int(audit.summary(shallow_selected)["relative_budget"])
        self.assertEqual(audit.source_budget_errors(deep_selected, deep_catalogs, portable), [])
        self.assertGreater(int(audit.summary(deep_selected)["absolute_budget"]), portable)

    def test_source_absolute_overage_is_reported_as_non_blocking_diagnostic(self) -> None:
        skills_root = self.root / "very" / "deep" / "source" / "skills"
        self.make_skill(skills_root, "sg-alpha")
        self.make_skill(skills_root, "shipglows")
        _, registry = self.make_registry(skills_root)
        audits = audit.audit_all(skills_root, 8)
        catalogs = audit.build_catalogs(registry, {item.name for item in audits})
        selected = audit.select_audits(audits, catalogs, "all", "implicit")
        portable = int(audit.summary(selected)["relative_budget"])

        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            audit.print_text(audits, selected, "all", "implicit", portable, [], [])

        self.assertIn("Repo-relative estimate (portable verdict)", output.getvalue())
        self.assertIn("Absolute estimate (source diagnostic only)", output.getvalue())
        self.assertEqual(audit.source_budget_errors(selected, catalogs, portable), [])

    def test_runtime_paths_are_lexical_and_runtime_overage_blocks(self) -> None:
        runtime_root = self.root / "runtime" / "skills"
        self.make_skill(runtime_root, "sg-alpha")
        self.make_skill(runtime_root, "shipglows")
        _, registry = self.make_registry(runtime_root)

        with mock.patch.object(Path, "resolve", side_effect=AssertionError("resolve must not run")):
            report = audit.audit_runtime(runtime_root, registry, "all", "implicit", 8, budget=1)

        expected = sum(
            len(str(audit.lexical_absolute(item.path))) + len(item.name) + len(item.description)
            for item in report.selected
        )
        self.assertEqual(report.root, audit.lexical_absolute(runtime_root))
        self.assertEqual(report.lexical_budget, expected)
        self.assertTrue(any("runtime lexical aggregate estimate exceeds" in error for error in report.errors))

    def test_repeated_runtime_roots_are_preserved_by_cli_parser(self) -> None:
        args = audit.parse_args(
            [
                "--runtime-skills-root",
                "first",
                "--runtime-skills-root",
                "second",
            ]
        )
        self.assertEqual(args.runtime_skills_root, ["first", "second"])

    def test_malformed_policy_is_a_hard_diagnostic_even_outside_selected_catalog(self) -> None:
        skills_root = self.root / "skills"
        self.make_skill(skills_root, "sg-alpha")
        self.make_skill(skills_root, "shipglows")
        self.make_skill(skills_root, "engine", implicit="sometimes")
        registry_path, _ = self.make_registry(skills_root)
        args = audit.parse_args(
            [
                "--skills-root",
                str(skills_root),
                "--registry",
                str(registry_path),
                "--catalog",
                "public",
            ]
        )

        with contextlib.redirect_stdout(io.StringIO()):
            exit_code = audit.run(args)

        engine = next(item for item in audit.audit_all(skills_root, 8) if item.name == "engine")
        self.assertTrue(any("must be true or false" in error for error in engine.errors))
        self.assertEqual(exit_code, 1)

    def test_missing_and_malformed_inputs_fail_actionably(self) -> None:
        with self.assertRaisesRegex(audit.AuditInputError, "skills root not found"):
            audit.iter_skill_files(self.root / "missing")

        skills_root = self.root / "skills"
        self.make_skill(skills_root, "sg-alpha")
        with self.assertRaisesRegex(audit.AuditInputError, "registry not found"):
            audit.load_registry(skills_root / "missing.json")

        malformed = skills_root / "registry.json"
        malformed.write_text("{broken", encoding="utf-8")
        with self.assertRaisesRegex(audit.AuditInputError, "cannot read registry"):
            audit.load_registry(malformed)

    def test_invalid_budget_is_rejected(self) -> None:
        with contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as raised:
                audit.parse_args(["--budget", "0"])
        self.assertEqual(raised.exception.code, 2)

    def test_public_catalog_missing_skill_is_a_blocking_error(self) -> None:
        skills_root = self.root / "skills"
        self.make_skill(skills_root, "sg-alpha")
        _, registry = self.make_registry(skills_root)

        catalogs = audit.build_catalogs(registry, {"sg-alpha"})

        self.assertEqual(catalogs.errors, ("public catalog skill missing on disk: shipglows",))


if __name__ == "__main__":
    unittest.main()
