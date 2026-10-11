import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "cli" / "windows" / "shipglows.ps1"
PWSH = shutil.which("pwsh")
NPM = shutil.which("npm")


def node_script(code: int) -> str:
    return f'node -e "process.exit({code})"'


@unittest.skipUnless(PWSH and NPM, "pwsh and npm are required for shipglows check")
class ShipglowsCheckTests(unittest.TestCase):
    def run_check(self, files: dict[str, str]) -> subprocess.CompletedProcess:
        with tempfile.TemporaryDirectory() as directory:
            for name, content in files.items():
                (Path(directory) / name).write_text(content, encoding="utf-8")
            return subprocess.run(
                [PWSH, "-NoProfile", "-NonInteractive", "-File", str(SCRIPT), "check"],
                cwd=directory,
                capture_output=True,
                text=True,
                timeout=180,
            )

    def manifest(self, lint: str, test: str) -> str:
        return json.dumps({"scripts": {"lint": lint, "test": test}})

    def test_passing_lint_and_test_exit_zero(self):
        result = self.run_check({"package.json": self.manifest(node_script(0), node_script(0))})
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        self.assertIn("node:lint: OK", result.stdout)
        self.assertIn("shipglows check: PASSED", result.stdout)

    def test_failing_test_exits_one_and_names_the_step(self):
        result = self.run_check({"package.json": self.manifest(node_script(0), node_script(3))})
        self.assertEqual(1, result.returncode)
        self.assertIn("node:test: FAIL (exit 3)", result.stdout)
        self.assertIn("shipglows check: NOT PASSED", result.stdout)

    def test_echo_placeholder_lint_is_not_configured(self):
        result = self.run_check({"package.json": self.manifest("echo 'lint not configured yet'", node_script(0))})
        self.assertEqual(1, result.returncode)
        self.assertIn("node:lint: NOT CONFIGURED", result.stdout)

    def test_exit_zero_placeholder_lint_is_not_configured(self):
        result = self.run_check({"package.json": self.manifest("exit 0", node_script(0))})
        self.assertEqual(1, result.returncode)
        self.assertIn("node:lint: NOT CONFIGURED", result.stdout)

    def test_pubspec_is_checked_even_when_package_json_exists(self):
        result = self.run_check({
            "package.json": self.manifest(node_script(3), node_script(0)),
            "pubspec.yaml": "name: app\n",
        })
        self.assertEqual(1, result.returncode)
        self.assertIn("node:lint: FAIL", result.stdout)
        self.assertIn("flutter:lint: SKIPPED", result.stdout)
        self.assertIn("flutter:test: NOT CONFIGURED", result.stdout)

    def test_bun_lockfile_is_refused_like_the_required_gate(self):
        result = self.run_check({"package.json": self.manifest(node_script(0), node_script(0)), "bun.lock": ""})
        self.assertEqual(2, result.returncode)
        self.assertIn("Bun setup is not inferred", result.stderr)

    def test_directory_without_manifest_exits_two(self):
        result = self.run_check({"README.md": "no manifest\n"})
        self.assertEqual(2, result.returncode)
        self.assertIn("nothing to check", result.stderr)


if __name__ == "__main__":
    unittest.main()
