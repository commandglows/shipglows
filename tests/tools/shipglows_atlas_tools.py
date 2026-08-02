#!/usr/bin/env python3
"""Regression tests for the local-only Atlas import boundary."""

from __future__ import annotations

import hashlib
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
IMPORTER = ROOT / "tools/shipglows_atlas_import.py"
CONTEXT = ROOT / "tools/shipglows_atlas_context.py"
PREFLIGHT = ROOT / "tools/shipglows_atlas_preflight.py"
SHA = "a" * 40
FINGERPRINT = "b" * 64


def atlas() -> dict:
    return {
        "format_version": "2.0", "project": "test-atlas", "updated_at": "2026-08-02T00:00:00Z",
        "surfaces": [{"surface_id": "home.hero", "target_id": "home.hero.primary", "label": "Hero", "route_patterns": ["/"], "selectors": {"stable": "[data-sg-target=\"home.hero.primary\"]"}, "assessments": {"copy": {"quality": "unknown", "focus": False, "approval": None}, "design": {"quality": "unknown", "focus": False, "approval": None}}, "function_ids": ["ordering.start"]}],
        "functions": [{"function_id": "ordering.start", "label": "Start order", "kind": "interaction", "operator_observable": True, "surface_ids": ["home.hero"], "dependencies": {"frontend": [], "backend": ["payments.private"]}, "assessment": {"quality": "unknown", "focus": False, "approval": None}}, {"function_id": "private.score", "label": "Private", "kind": "internal", "operator_observable": False, "surface_ids": [], "dependencies": {"backend": ["private"]}, "assessment": {"quality": "unknown", "focus": False, "approval": None}}],
        "import_history": [],
    }


def annotation(quality: str = "red", *, dimension: str = "design", approval: dict | None = None) -> dict:
    change = {"dimension": dimension, "quality": quality, "focus": False, "function_id": "ordering.start" if dimension == "function" else None}
    if approval is not None:
        change["approval"] = approval
    return {"format_version": "2.0", "captured_at": "2026-08-02T00:00:00Z", "target": {"surface_id": "home.hero", "target_id": "home.hero.primary", "route": "/", "function_ids": ["ordering.start"]}, "selectors": {"stable": "[data-sg-target=\"home.hero.primary\"]"}, "annotation": change, "reference": {"commit": None, "viewport": {"width": 1440, "height": 900, "dpr": 1}, "unavailable_reason": "Browser sessions do not have Git metadata."}, "evidence": {"local_ref": None, "unavailable_reason": "No local evidence has been attached yet."}}


class AtlasImportTests(unittest.TestCase):
    def write_patch(self, folder: Path, atlas_path: Path, annotations: list[dict]) -> Path:
        path = folder / "patch.json"
        path.write_text(json.dumps({"format_version": "2.0", "kind": "atlas_annotation_patch", "project": "test-atlas", "base_atlas_digest": hashlib.sha256(atlas_path.read_bytes()).hexdigest(), "exported_at": "2026-08-02T00:00:00Z", "evidence_manifest": [], "annotations": annotations}), encoding="utf-8")
        return path

    def run_import(self, atlas_path: Path, patch_path: Path, *, approve_protected: bool = False, project_root: Path | None = None) -> subprocess.CompletedProcess[str]:
        command = ["python3", str(IMPORTER), "--atlas", str(atlas_path), "--patch", str(patch_path)]
        if approve_protected:
            command.append("--approve-protected")
            command.extend(["--project-root", str(project_root)])
        return subprocess.run(command, text=True, capture_output=True, check=False)

    def git(self, project: Path, *arguments: str) -> str:
        result = subprocess.run(["git", "-C", str(project), *arguments], text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def commit_atlas_project(self, project: Path, atlas_path: Path) -> str:
        self.git(project, "init")
        self.git(project, "config", "user.email", "atlas-tests@example.test")
        self.git(project, "config", "user.name", "Atlas Tests")
        self.git(project, "add", atlas_path.name)
        self.git(project, "commit", "-m", "Atlas baseline")
        return self.git(project, "rev-parse", "HEAD")

    def test_valid_next_cycle_annotation_is_imported(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); atlas_path = folder / "atlas.json"; atlas_path.write_text(json.dumps(atlas()), encoding="utf-8")
            result = self.run_import(atlas_path, self.write_patch(folder, atlas_path, [annotation()]))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(atlas_path.read_text())["surfaces"][0]["assessments"]["design"]["quality"], "red")

    def test_stale_or_invalid_patch_never_writes(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); atlas_path = folder / "atlas.json"; atlas_path.write_text(json.dumps(atlas()), encoding="utf-8")
            before = atlas_path.read_bytes(); patch = self.write_patch(folder, atlas_path, [annotation("gold")])
            result = self.run_import(atlas_path, patch)
            self.assertNotEqual(result.returncode, 0); self.assertIn("expected red, got gold", result.stderr); self.assertEqual(atlas_path.read_bytes(), before)
            stale = json.loads(patch.read_text()); stale["base_atlas_digest"] = "0" * 64; patch.write_text(json.dumps(stale), encoding="utf-8")
            result = self.run_import(atlas_path, patch)
            self.assertNotEqual(result.returncode, 0); self.assertIn("digest is stale", result.stderr); self.assertEqual(atlas_path.read_bytes(), before)

    def test_protected_baseline_and_redaction_are_enforced(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); atlas_path = folder / "atlas.json"; atlas_path.write_text(json.dumps(atlas()), encoding="utf-8")
            before = atlas_path.read_bytes()
            steps = [annotation("red"), annotation("bronze"), annotation("silver"), annotation("gold")]
            result = self.run_import(atlas_path, self.write_patch(folder, atlas_path, steps))
            self.assertNotEqual(result.returncode, 0); self.assertIn("require an approval baseline", result.stderr); self.assertEqual(atlas_path.read_bytes(), before)
            approval = {"commit": SHA, "context_fingerprint": FINGERPRINT, "evidence_local_ref": "evidence/home-hero.png", "operator_decision": "Approved after visual review.", "approved_at": "2026-08-02T00:00:00Z", "previous_baseline_ref": None}
            steps[-1] = annotation("gold", approval=approval)
            result = self.run_import(atlas_path, self.write_patch(folder, atlas_path, steps))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(atlas_path.read_text())["surfaces"][0]["assessments"]["design"]["approval"], approval)
            output = folder / "context.json"
            result = subprocess.run(["python3", str(CONTEXT), "--atlas", str(atlas_path), "--output", str(output)], text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            context = json.loads(output.read_text())
            self.assertNotIn("dependencies", json.dumps(context)); self.assertNotIn("private.score", json.dumps(context))

    def test_invalid_stored_protection_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); atlas_path = folder / "atlas.json"; invalid = atlas()
            invalid["surfaces"][0]["assessments"]["design"]["quality"] = "gold"
            atlas_path.write_text(json.dumps(invalid), encoding="utf-8")
            output = folder / "context.json"
            result = subprocess.run(["python3", str(CONTEXT), "--atlas", str(atlas_path), "--output", str(output)], text=True, capture_output=True, check=False)
            self.assertNotEqual(result.returncode, 0); self.assertFalse(output.exists())

    def test_explicit_clean_git_opt_in_creates_protected_baseline(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); project = folder / "project"; project.mkdir(); atlas_path = project / "atlas.json"; atlas_path.write_text(json.dumps(atlas()), encoding="utf-8")
            commit = self.commit_atlas_project(project, atlas_path)
            steps = [annotation("red"), annotation("bronze"), annotation("silver"), annotation("gold")]
            patch = self.write_patch(folder, atlas_path, steps)
            result = self.run_import(atlas_path, patch, approve_protected=True, project_root=project)
            self.assertEqual(result.returncode, 0, result.stderr)
            approval = json.loads(atlas_path.read_text())["surfaces"][0]["assessments"]["design"]["approval"]
            self.assertEqual(approval["commit"], commit)
            self.assertEqual(approval["previous_baseline_ref"], None)
            self.assertEqual(approval["evidence_local_ref"], f"shipglows_data/workflow/atlas/approved-surfaces.json#import:{hashlib.sha256(patch.read_bytes()).hexdigest()}")

    def test_explicit_protected_baseline_refuses_dirty_repository(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); project = folder / "project"; project.mkdir(); atlas_path = project / "atlas.json"; atlas_path.write_text(json.dumps(atlas()), encoding="utf-8")
            self.commit_atlas_project(project, atlas_path)
            (project / "uncommitted.txt").write_text("not committed", encoding="utf-8")
            patch = self.write_patch(folder, atlas_path, [annotation("red"), annotation("bronze"), annotation("silver"), annotation("gold")])
            before = atlas_path.read_bytes(); result = self.run_import(atlas_path, patch, approve_protected=True, project_root=project)
            self.assertNotEqual(result.returncode, 0); self.assertIn("dirty repository", result.stderr); self.assertEqual(atlas_path.read_bytes(), before)

    def test_preflight_blocks_protected_impact_and_reports_unknown_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary); atlas_path = folder / "atlas.json"; protected = atlas()
            protected["surfaces"][0]["impact_paths"] = [{"path": "site/src/components/Hero.astro", "dimensions": ["design"]}]
            protected["surfaces"][0]["assessments"]["design"]["quality"] = "gold"
            atlas_path.write_text(json.dumps(protected), encoding="utf-8")
            command = ["python3", str(PREFLIGHT), "--atlas", str(atlas_path), "--project-root", str(folder), "--changed", "site/src/components/Hero.astro"]
            result = subprocess.run(command, text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 2, result.stderr)
            report = json.loads(result.stdout); self.assertEqual(report["verdict"], "block"); self.assertEqual(report["authorization_required"], ["home.hero:design"])
            result = subprocess.run(command + ["--allow", "home.hero:design"], text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr); self.assertEqual(json.loads(result.stdout)["verdict"], "clear")
            result = subprocess.run(command[:-1] + ["site/src/unknown.ts"], text=True, capture_output=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr); self.assertEqual(json.loads(result.stdout)["verdict"], "review")


if __name__ == "__main__":
    unittest.main()
