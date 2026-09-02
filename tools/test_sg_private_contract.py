import json
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
REGISTRY = SKILLS / "references" / "skill-invocation-registry.json"


class SgPrivateContractTests(unittest.TestCase):
    def test_public_owner_exposes_private_modes(self):
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        owners = {skill["id"]: skill for domain in registry["public_catalog"]["domains"]
                  for skill in domain["skills"]}
        private = owners["sg-private"]
        self.assertEqual(private["runtime_skill"], "603-sg-private")
        self.assertEqual(private["modes"], ["memory", "data"])
        self.assertEqual(registry["rules"]["603-sg-private"]["modes"],
                         {"memory": {"min_args": 0}, "data": {"min_args": 1}})

    def test_explicit_invocation_resolves_to_private_engine(self):
        result = subprocess.run(
            [sys.executable, str(ROOT / "tools" / "skill_invocation_check.py"),
             "sg-private memory retrouve mes fichiers"],
            text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["status"], "valid")
        self.assertEqual(payload["runtime_engine"], "603-sg-private")

    def test_natural_routing_and_persistence_boundary_are_explicit(self):
        routing = (SKILLS / "references" / "entrypoint-routing.md").read_text(encoding="utf-8")
        engine = (SKILLS / "603-sg-private" / "SKILL.md").read_text(encoding="utf-8")
        operations = (SKILLS / "603-sg-private" / "references" /
                      "memory-operations.md").read_text(encoding="utf-8")
        self.assertIn("private local path, URL, alias, or Vivaldi bookmark", routing)
        self.assertIn("A supplied value is transient unless", engine)
        self.assertIn("continue the original task without writing memory", engine)
        self.assertIn("never reads or embeds target file contents", operations)
        self.assertIn("Do not copy records between backends", operations)
        self.assertIn("never silently default to the bookmark bar", operations)


if __name__ == "__main__":
    unittest.main()
