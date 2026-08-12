#!/usr/bin/env python3
"""Scenario-first tests for explicit resource dependency truth."""

from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.resource_dependency_graph import activation_profile_roots, audit_dependency_graph


def artifact(version: str = "1.0.0", status: str = "active", depends: str = "[]") -> str:
    return (
        "---\nartifact: technical_guidelines\nmetadata_schema_version: \"1.0\"\n"
        f"artifact_version: \"{version}\"\nstatus: {status}\n"
        f"depends_on: {depends}\n---\n# Fixture\n"
    )


class ResourceDependencyGraphTests(unittest.TestCase):
    def test_repository_dependency_graph_is_valid(self) -> None:
        payload = audit_dependency_graph(roots=activation_profile_roots())
        self.assertEqual("valid", payload["status"], payload["errors"][:20])
        self.assertEqual(0, payload["cycles"])

    def test_missing_status_version_and_cycle_are_blocking(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: skills/references/b.md\n    artifact_version: \"2.0.0\"\n    required_status: active"), encoding="utf-8")
            (refs / "b.md").write_text(artifact(version="1.0.0", status="draft", depends="\n  - artifact: skills/references/a.md\n    artifact_version: \"1.0.0\"\n    required_status: active"), encoding="utf-8")
            payload = audit_dependency_graph(root)
            self.assertEqual("invalid", payload["status"])
            self.assertTrue(any(error.startswith("version:") for error in payload["errors"]))
            self.assertTrue(any(error.startswith("status:") for error in payload["errors"]))
            self.assertTrue(any(error.startswith("cycle:") for error in payload["errors"]))

    def test_missing_dependency_is_visible(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: skills/references/missing.md\n    artifact_version: \"1.0.0\"\n    required_status: active"), encoding="utf-8")
            payload = audit_dependency_graph(root)
            self.assertTrue(any(error.startswith("missing:") for error in payload["errors"]))

    def test_cross_tree_governance_resource_is_a_validated_leaf(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            docs = root / "shipglows_data" / "technical"
            refs.mkdir(parents=True)
            docs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: shipglows_data/technical/b.md\n    artifact_version: \"1.0.0\"\n    required_status: active"), encoding="utf-8")
            (docs / "b.md").write_text(artifact(depends="\n  - artifact: shipglows_data/technical/missing.md\n    artifact_version: \"1.0.0\"\n    required_status: active"), encoding="utf-8")
            payload = audit_dependency_graph(root, ["skills/references/a.md"])
            self.assertEqual(2, payload["artifacts"])
            self.assertEqual("valid", payload["status"], payload["errors"])

    def test_dependency_constraints_are_required(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: skills/references/b.md"), encoding="utf-8")
            (refs / "b.md").write_text(artifact(), encoding="utf-8")
            errors = audit_dependency_graph(root, ["skills/references/a.md"])["errors"]
            self.assertTrue(any(error.startswith("missing_required_version:") for error in errors))
            self.assertTrue(any(error.startswith("missing_required_status:") for error in errors))

    def test_workflow_spec_is_a_validated_terminal_provenance_record(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            specs = root / "shipglows_data" / "workflow" / "specs"
            refs.mkdir(parents=True)
            specs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: shipglows_data/workflow/specs/history.md\n    artifact_version: \"1.0.0\"\n    required_status: reviewed"), encoding="utf-8")
            (specs / "history.md").write_text(artifact(status="reviewed", depends="\n  - artifact: LEGACY.md\n    artifact_version: \"unknown\"\n    required_status: active"), encoding="utf-8")
            payload = audit_dependency_graph(root, ["skills/references/a.md"])
            self.assertEqual("valid", payload["status"], payload["errors"])
            self.assertEqual(2, payload["artifacts"])

    def test_selected_root_version_must_be_semver(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(version="current"), encoding="utf-8")
            errors = audit_dependency_graph(root, ["skills/references/a.md"])["errors"]
            self.assertIn("invalid_actual_version:skills/references/a.md:current", errors)

    def test_selected_root_status_must_be_activable(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(status="obsolete"), encoding="utf-8")
            errors = audit_dependency_graph(root, ["skills/references/a.md"])["errors"]
            self.assertIn("invalid_actual_status:skills/references/a.md:obsolete", errors)

    def test_full_graph_accepts_terminal_historical_artifacts(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "history.md").write_text(artifact(status="superseded"), encoding="utf-8")
            payload = audit_dependency_graph(root)
            self.assertEqual("valid", payload["status"], payload["errors"])

    def test_versioned_repository_root_dependency_is_resolved(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            refs = root / "skills" / "references"
            refs.mkdir(parents=True)
            (refs / "a.md").write_text(artifact(depends="\n  - artifact: README.md\n    artifact_version: \"1.0.0\"\n    required_status: active"), encoding="utf-8")
            (root / "README.md").write_text(artifact(), encoding="utf-8")
            payload = audit_dependency_graph(root)
            self.assertEqual("valid", payload["status"], payload["errors"])


if __name__ == "__main__":
    unittest.main()
