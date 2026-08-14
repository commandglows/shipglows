import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


TOOLS = Path(__file__).resolve().parent
SCRIPT = TOOLS / "design_system_drift_check.py"
SPEC = importlib.util.spec_from_file_location("design_system_drift_check", SCRIPT)
drift = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
sys.modules[SPEC.name] = drift
SPEC.loader.exec_module(drift)


class DesignSystemDriftCheckTests(unittest.TestCase):
    def test_discovers_root_nested_site_and_authored_android_sources(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            expected = {
                root / "src" / "app.css",
                root / "site" / "src" / "page.astro",
                root / "plugin" / "android" / "src" / "main" / "java" / "Ui.kt",
            }
            ignored = {
                root / "site" / "dist" / "output.css",
                root / "plugin" / "android" / ".tauri" / "src" / "main" / "java" / "Generated.kt",
                root / "plugin" / "android" / "build" / "generated" / "Ui.kt",
            }
            for path in expected | ignored:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("color: #123456;", encoding="utf-8")

            self.assertEqual(set(drift.candidate_files(root, False)), expected)

    def test_project_rules_classify_findings_and_only_defects_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "src" / "catalog.ts"
            source.parent.mkdir(parents=True)
            source.write_text(
                "const brand = '#123456';\nconst protocol = { width: 600 };\n",
                encoding="utf-8",
            )
            config = root / ".shipglows" / "design-system-drift.json"
            config.parent.mkdir()
            config.write_text(
                json.dumps(
                    {
                        "rules": [
                            {
                                "classification": "brand-data",
                                "paths": ["src/catalog.ts"],
                                "kinds": ["hardcoded color"],
                                "pattern": "#123456",
                                "reason": "Third-party catalogue identity.",
                            },
                            {
                                "classification": "accepted-exception",
                                "paths": ["src/catalog.ts"],
                                "pattern": "width: 600",
                                "reason": "Browser protocol contract.",
                            },
                        ]
                    }
                ),
                encoding="utf-8",
            )

            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--root", str(root), "--format", "markdown"],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("- Defects: 0", result.stdout)
            self.assertIn("- Accepted exceptions: 1", result.stdout)
            self.assertIn("- Brand data: 1", result.stdout)
            self.assertIn("pass with classified findings", result.stdout)

    def test_unclassified_finding_fails_and_invalid_config_is_usage_error(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "src" / "app.css"
            source.parent.mkdir(parents=True)
            source.write_text("main { color: #123456; }", encoding="utf-8")

            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--root", str(root)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn("Defects: 1", result.stdout)

            bad = root / "bad.json"
            bad.write_text('{"rules": [{"classification": "ignored"}]}', encoding="utf-8")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--root", str(root), "--config", str(bad)],
                text=True,
                capture_output=True,
                check=False,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("config error", result.stderr)


if __name__ == "__main__":
    unittest.main()
