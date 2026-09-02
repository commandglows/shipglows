from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = "skills/references/obsidian-plugin-workflow.md"


class ObsidianSkillIntegrationContract(unittest.TestCase):
    def test_public_owners_load_the_shared_workflow(self) -> None:
        for relative in (
            "skills/sg-development/SKILL.md",
            "skills/sg-bug/SKILL.md",
            "skills/sg-engineering/SKILL.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn(REFERENCE, text, relative)
            self.assertIn("Obsidian plugin", text, relative)

    def test_shared_workflow_preserves_safety_and_proof_boundaries(self) -> None:
        text = (ROOT / REFERENCE).read_text(encoding="utf-8")
        for marker in (
            "build-required",
            "reviewed project build command",
            "must not scan, infer, rank, create, or select a personal vault",
            "s obsidian-lab -ProjectPath <path> -Headless -Json",
            "not an OS sandbox",
            "BRAT as a later distribution channel",
            "hostLoad=passed",
            "interaction=passed",
            "diagnostics=passed",
            "cleanup=passed",
        ):
            self.assertIn(marker, text)

    def test_agent_instruction_and_guide_surfaces_are_connected(self) -> None:
        instructions = (ROOT / "cli/windows/ShipGlows.AgentInstructions.psm1").read_text(encoding="utf-8")
        guide_index = (ROOT / "shipglows_data/technical/operator-guides/README.md").read_text(encoding="utf-8")
        self.assertIn("s obsidian-lab -ProjectPath <path> -Headless -Json", instructions)
        self.assertIn("discover or select a personal vault", instructions)
        self.assertIn("not an OS sandbox", instructions)
        self.assertIn("obsidian-plugin-lab.md", guide_index)


if __name__ == "__main__":
    unittest.main()
