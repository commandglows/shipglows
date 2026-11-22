#!/usr/bin/env python3
"""Tests for the deterministic capability delta merge (tools/spec_delta_merge.py)."""

from __future__ import annotations

from pathlib import Path
import random
from tempfile import TemporaryDirectory
import unittest

from tools import spec_delta_merge as sdm


DATE = "2026-11-22"


def requirement(name: str, verb: str = "SHALL", detail: str = "respond") -> str:
    return (
        f"### Requirement: {name}\n\n"
        f"The system {verb} {detail}.\n\n"
        f"#### Scenario: {name} nominal\n\n"
        f"- **WHEN** the operator triggers {name}\n"
        f"- **THEN** the system does {detail}\n"
    )


def living(*names: str, capability: str = "demo") -> str:
    blocks = "\n".join(requirement(name) for name in names)
    return (
        "---\n"
        "artifact: capability_spec\n"
        'artifact_version: "1.0.0"\n'
        'updated: "2026-01-01"\n'
        "---\n\n"
        f"# Capability: {capability}\n\n"
        "## Purpose\n\nDemo capability.\n\n"
        "## Requirements\n\n"
        f"{blocks}\n"
        "## Change History\n\n"
        "| Date | Change spec | Operation | Requirement | Reason |\n"
        "|------|-------------|-----------|-------------|--------|\n"
    )


def change(added: str = "", modified: str = "", removed: str = "", capability: str = "demo") -> str:
    return (
        "---\nartifact: spec\n---\n\n# Spec: demo change\n\n"
        "## Capability Delta\n\n"
        f"- Capability: `{capability}`\n\n"
        f"## ADDED Requirements\n\n{added or 'None'}\n\n"
        f"## MODIFIED Requirements\n\n{modified or 'None'}\n\n"
        f"## REMOVED Requirements\n\n{removed or 'None'}\n\n"
        "## Acceptance Criteria\n\n- [ ] AC 1: Given x, when y, then z.\n"
    )


def removal(name: str, reason: str = "Replaced by a simpler flow.") -> str:
    return f"### Requirement: {name}\n\n**Reason**: {reason}\n"


class Workspace:
    """A temporary specs directory holding one change spec and living specs."""

    def __init__(self, test: unittest.TestCase) -> None:
        temporary = TemporaryDirectory()
        test.addCleanup(temporary.cleanup)
        self.specs = Path(temporary.name) / "specs"
        self.capabilities = self.specs / "capabilities"
        self.capabilities.mkdir(parents=True)
        self.spec = self.specs / "demo-change.md"

    def write_living(self, text: str, capability: str = "demo") -> Path:
        path = self.capabilities / f"{capability}.md"
        path.write_text(text, encoding="utf-8", newline="\n")
        return path

    def write_change(self, text: str) -> Path:
        self.spec.write_text(text, encoding="utf-8", newline="\n")
        return self.spec

    def merge(self, **options: object) -> "sdm.MergeResult":
        return sdm.merge_change_spec(self.spec, date=DATE, **options)


class MissingTargetRefusalTests(unittest.TestCase):
    """Critical rule: a MODIFIED or REMOVED delta without a matching requirement is refused."""

    def test_modified_without_matching_requirement_is_refused(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        before = target.read_bytes()
        ws.write_change(change(modified=requirement("Logout", detail="end the session")))
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn("MODIFIED", str(caught.exception))
        self.assertIn("Logout", str(caught.exception))
        self.assertEqual(before, target.read_bytes())

    def test_removed_without_matching_requirement_is_refused(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        before = target.read_bytes()
        ws.write_change(change(removed=removal("Logout")))
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn("REMOVED", str(caught.exception))
        self.assertIn("Logout", str(caught.exception))
        self.assertEqual(before, target.read_bytes())

    def test_modified_or_removed_against_missing_capability_file_is_refused(self) -> None:
        for delta in (change(modified=requirement("Login")), change(removed=removal("Login"))):
            ws = Workspace(self)
            ws.write_change(delta)
            with self.assertRaises(sdm.DeltaError):
                ws.merge(create=True)
            self.assertEqual([], list(ws.capabilities.iterdir()))

    def test_one_missing_target_blocks_the_whole_merge(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login", "Export"))
        before = target.read_bytes()
        ws.write_change(change(
            added=requirement("Import"),
            modified=requirement("Login", detail="require a second factor"),
            removed=removal("Ghost"),
        ))
        with self.assertRaises(sdm.DeltaError):
            ws.merge()
        self.assertEqual(before, target.read_bytes())

    def test_cli_exits_nonzero_and_leaves_living_spec_untouched(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        before = target.read_bytes()
        ws.write_change(change(removed=removal("Ghost")))
        self.assertEqual(1, sdm.main([str(ws.spec), "--date", DATE]))
        self.assertEqual(before, target.read_bytes())

    def test_property_any_unmatched_modified_or_removed_is_refused(self) -> None:
        rng = random.Random(20261122)
        pool = [f"Req {index}" for index in range(12)]
        for _ in range(200):
            existing = rng.sample(pool, rng.randint(0, 6))
            absent = [name for name in pool if name not in existing]
            ghost = rng.choice(absent)
            operation = rng.choice(("modified", "removed"))
            valid_modified = rng.sample(existing, rng.randint(0, len(existing)))
            valid_removed = [name for name in existing if name not in valid_modified and rng.random() < 0.5]
            added = [name for name in absent if name != ghost and rng.random() < 0.3]
            modified_names = valid_modified + ([ghost] if operation == "modified" else [])
            removed_names = valid_removed + ([ghost] if operation == "removed" else [])
            rng.shuffle(modified_names)
            rng.shuffle(removed_names)
            ws = Workspace(self)
            target = ws.write_living(living(*existing))
            before = target.read_bytes()
            ws.write_change(change(
                added="\n".join(requirement(name) for name in added),
                modified="\n".join(requirement(name, detail="change") for name in modified_names),
                removed="\n".join(removal(name) for name in removed_names),
            ))
            with self.assertRaises(sdm.DeltaError, msg=f"{operation} {ghost} over {existing}") as caught:
                ws.merge()
            self.assertIn(ghost, str(caught.exception))
            self.assertEqual(before, target.read_bytes())


class MergeBehaviourTests(unittest.TestCase):
    def test_added_appends_modified_replaces_removed_deletes(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login", "Export", "Legacy sync"))
        ws.write_change(change(
            added=requirement("Import", verb="MUST", detail="accept CSV"),
            modified=requirement("Login", detail="require a second factor"),
            removed=removal("Legacy sync", reason="Superseded by Import."),
        ))
        result = ws.merge()
        merged = target.read_text(encoding="utf-8")
        document = sdm.parse_capability(merged)
        self.assertEqual(["Login", "Export", "Import"], [item.name for item in document.requirements])
        self.assertIn("require a second factor", merged)
        self.assertNotIn("The system SHALL respond.\n\n#### Scenario: Login nominal", merged)
        self.assertNotIn("### Requirement: Legacy sync", merged)
        self.assertIn("| 2026-11-22 | demo-change | REMOVED | Legacy sync | Superseded by Import. |", merged)
        self.assertIn("| 2026-11-22 | demo-change | MODIFIED | Login |", merged)
        self.assertIn("| 2026-11-22 | demo-change | ADDED | Import |", merged)
        self.assertIn('updated: "2026-11-22"', merged)
        self.assertEqual([target], result.written)
        self.assertEqual([], sdm.validate_capability_text(merged))

    def test_merge_is_deterministic(self) -> None:
        outputs = []
        for _ in range(2):
            ws = Workspace(self)
            target = ws.write_living(living("Login", "Export"))
            ws.write_change(change(added=requirement("Import"), modified=requirement("Export", detail="stream")))
            ws.merge()
            outputs.append(target.read_bytes())
        self.assertEqual(outputs[0], outputs[1])

    def test_second_merge_of_same_change_is_refused(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        ws.write_change(change(modified=requirement("Login", detail="require a second factor")))
        ws.merge()
        after_first = target.read_bytes()
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn("already merged", str(caught.exception))
        self.assertEqual(after_first, target.read_bytes())

    def test_check_mode_validates_without_writing(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        before = target.read_bytes()
        ws.write_change(change(added=requirement("Import")))
        result = ws.merge(check=True)
        self.assertEqual(before, target.read_bytes())
        self.assertEqual([], result.written)
        self.assertEqual([("demo", "ADDED", "Import")], result.operations)

    def test_added_existing_requirement_is_refused(self) -> None:
        ws = Workspace(self)
        ws.write_living(living("Login"))
        ws.write_change(change(added=requirement("login")))
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn("ADDED", str(caught.exception))

    def test_new_capability_requires_create_flag(self) -> None:
        ws = Workspace(self)
        ws.write_change(change(added=requirement("Import"), capability="imports"))
        with self.assertRaises(sdm.DeltaError):
            ws.merge()
        result = ws.merge(create=True)
        created = ws.capabilities / "imports.md"
        self.assertEqual([created], result.written)
        text = created.read_text(encoding="utf-8")
        self.assertIn("# Capability: imports", text)
        self.assertEqual([], sdm.validate_capability_text(text))

    def test_two_capabilities_merge_atomically(self) -> None:
        ws = Workspace(self)
        first = ws.write_living(living("Login"), "auth")
        second = ws.write_living(living("Export", capability="exports"), "exports")
        before = (first.read_bytes(), second.read_bytes())
        spec = (
            "# Spec: two\n\n"
            "## Capability Delta\n\n- Capability: `auth`\n\n"
            f"## ADDED Requirements\n\n{requirement('Logout')}\n"
            "## Capability Delta\n\n- Capability: `exports`\n\n"
            f"## REMOVED Requirements\n\n{removal('Ghost')}\n"
        )
        ws.write_change(spec)
        with self.assertRaises(sdm.DeltaError):
            ws.merge()
        self.assertEqual(before, (first.read_bytes(), second.read_bytes()))
        ws.write_change(spec.replace("Ghost", "Export"))
        result = ws.merge()
        self.assertEqual({first, second}, set(result.written))
        self.assertIn("### Requirement: Logout", first.read_text(encoding="utf-8"))
        self.assertNotIn("### Requirement: Export", second.read_text(encoding="utf-8"))

    def test_spec_without_delta_is_a_clean_no_op(self) -> None:
        ws = Workspace(self)
        ws.write_change("# Spec: docs only\n\n## Capability Delta\n\n- Capability: none, because docs only.\n\n"
                        "## ADDED Requirements\n\nNone\n")
        result = ws.merge()
        self.assertEqual([], result.operations)
        self.assertEqual(0, sdm.main([str(ws.spec), "--date", DATE]))

    def test_delta_without_capability_is_refused(self) -> None:
        ws = Workspace(self)
        ws.write_change(f"# Spec\n\n## ADDED Requirements\n\n{requirement('Import')}")
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn("Capability", str(caught.exception))

    def test_unsafe_capability_name_is_refused(self) -> None:
        ws = Workspace(self)
        ws.write_change(change(added=requirement("Import"), capability="../escape"))
        with self.assertRaises(sdm.DeltaError):
            ws.merge(create=True)
        self.assertFalse((ws.specs / "escape.md").exists())

    def test_headings_inside_code_fences_are_ignored(self) -> None:
        ws = Workspace(self)
        target = ws.write_living(living("Login"))
        fenced = "```markdown\n## REMOVED Requirements\n\n### Requirement: Ghost\n```\n"
        ws.write_change(change(added=requirement("Import")) + "\n## Notes\n\n" + fenced)
        ws.merge()
        self.assertIn("### Requirement: Import", target.read_text(encoding="utf-8"))


class RequirementShapeTests(unittest.TestCase):
    def assert_refused(self, spec: str, needle: str) -> None:
        ws = Workspace(self)
        ws.write_living(living("Login"))
        ws.write_change(spec)
        with self.assertRaises(sdm.DeltaError) as caught:
            ws.merge()
        self.assertIn(needle, str(caught.exception))

    def test_requirement_needs_shall_or_must(self) -> None:
        weak = requirement("Import").replace("SHALL", "should")
        self.assert_refused(change(added=weak), "SHALL or MUST")

    def test_requirement_needs_a_scenario(self) -> None:
        self.assert_refused(change(added="### Requirement: Import\n\nThe system SHALL import.\n"), "Scenario")

    def test_scenario_needs_when_and_then(self) -> None:
        no_then = requirement("Import").replace("- **THEN** the system does respond\n", "")
        self.assert_refused(change(added=no_then), "THEN")
        no_when = requirement("Import").replace("- **WHEN** the operator triggers Import\n", "")
        self.assert_refused(change(added=no_when), "WHEN")

    def test_removed_needs_a_reason(self) -> None:
        self.assert_refused(change(removed="### Requirement: Login\n"), "Reason")

    def test_same_requirement_in_two_operations_is_refused(self) -> None:
        self.assert_refused(
            change(modified=requirement("Login", detail="change"), removed=removal("Login")),
            "more than one",
        )

    def test_validate_capability_reports_structural_errors(self) -> None:
        duplicated = living("Login", "Login")
        errors = sdm.validate_capability_text(duplicated)
        self.assertTrue(any("duplicate" in error for error in errors))
        missing_section = "# Capability: demo\n\nNo requirements section.\n"
        self.assertTrue(sdm.validate_capability_text(missing_section))

    def test_cli_validate_mode(self) -> None:
        ws = Workspace(self)
        good = ws.write_living(living("Login"))
        self.assertEqual(0, sdm.main(["--validate", str(good)]))
        bad = ws.write_living(living("Login").replace("SHALL", "may"), "bad")
        self.assertEqual(1, sdm.main(["--validate", str(bad)]))


if __name__ == "__main__":
    unittest.main()
