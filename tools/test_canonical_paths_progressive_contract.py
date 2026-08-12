#!/usr/bin/env python3
"""Contracts for the progressive canonical-path split."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFERENCES = ROOT / "skills" / "references"
CORE = REFERENCES / "canonical-paths.md"
RUNTIME = REFERENCES / "canonical-runtime-and-private-roots.md"
PROJECT = REFERENCES / "canonical-project-governance-placement.md"


class CanonicalPathsProgressiveContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.core = CORE.read_text(encoding="utf-8")
        cls.runtime = RUNTIME.read_text(encoding="utf-8")
        cls.project = PROJECT.read_text(encoding="utf-8")

    def test_core_stays_below_activation_target(self) -> None:
        self.assertLessEqual((len(self.core) + 3) // 4, 1100)

    def test_mandatory_ownership_and_preflight_remain_in_core(self) -> None:
        for phrase in (
            "## ShipGlows-Owned Tool Preflight",
            "Resolve paths by ownership",
            "A project-local `skills/`, `tools/`, or `templates/` directory never shadows",
            "confirm the exact target tool exists and remains beneath that root",
            "Do not substitute a project copy, continue from memory",
        ):
            self.assertIn(phrase, self.core)

    def test_core_routes_two_terminal_leaves_and_existing_authorities(self) -> None:
        for filename in (
            RUNTIME.name,
            PROJECT.name,
            "monorepo-governance-topology.md",
            "resource-discovery.md",
        ):
            self.assertIn(filename, self.core)
        self.assertIn("These routes are siblings and never require one another", self.core)

    def test_sibling_leaves_never_chain(self) -> None:
        self.assertNotIn(PROJECT.name, self.runtime)
        self.assertNotIn(RUNTIME.name, self.project)

    def test_runtime_leaf_preserves_private_and_cross_platform_boundaries(self) -> None:
        for phrase in (
            "$SHIPGLOWS_RUNTIME_DIR",
            "$SHIPGLOWS_PRIVATE_DATA_DIR",
            "$SHIPGLOWS_INSPIRATION_LIBRARY_DIR",
            "$SHIPGLOWS_DATA_DIR",
            "never executable shell code",
            "not a requirement to invoke a POSIX shell on Windows",
            "Do not silently fall back to the project repository",
        ):
            self.assertIn(phrase, self.runtime)

    def test_project_leaf_preserves_governance_and_migration_boundaries(self) -> None:
        for phrase in (
            "exactly one `shipglows_data/` at the governance root",
            "documented, separately cloned and shipped standalone repository",
            "`AGENTS.md` is the compatibility symlink to `AGENT.md`",
            "Root `archive/`, `bugs/`, `docs/`, `specs/`, `research/`",
            "never governance or proof sources",
            "workflow/test-checklists/",
        ):
            self.assertIn(phrase, self.project)


if __name__ == "__main__":
    unittest.main()
