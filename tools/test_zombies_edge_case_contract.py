import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ZombiesEdgeCaseContractTest(unittest.TestCase):
    def test_canonical_heuristic_is_complete_and_proportional(self):
        text = (ROOT / "skills/references/zombies-edge-case-heuristic.md").read_text(encoding="utf-8")
        for marker in (
            "Z — Zero",
            "O — One",
            "M — Many",
            "B — Boundary Behaviors",
            "I — Interface definition",
            "E — Exercise Exceptional behavior",
            "S — Simple Scenarios, Simple Solutions",
            "ZOMBIES: not applicable",
        ):
            self.assertIn(marker, text)

    def test_behavioral_consumers_load_the_canonical_reference(self):
        consumers = (
            "skills/100-sg-spec/SKILL.md",
            "skills/102-sg-start/SKILL.md",
            "skills/103-sg-verify/SKILL.md",
            "skills/106-sg-fix/SKILL.md",
            "skills/107-sg-test/SKILL.md",
            "skills/references/spec-driven-development-discipline.md",
        )
        for relative_path in consumers:
            with self.subTest(relative_path=relative_path):
                text = (ROOT / relative_path).read_text(encoding="utf-8")
                self.assertIn("zombies-edge-case-heuristic.md", text)

    def test_contract_prevents_test_count_ceremony(self):
        reference = (ROOT / "skills/references/zombies-edge-case-heuristic.md").read_text(encoding="utf-8")
        qa = (ROOT / "skills/107-sg-test/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("coverage matters more than test count", reference)
        self.assertIn("seven ceremonial tests", qa)


if __name__ == "__main__":
    unittest.main()
