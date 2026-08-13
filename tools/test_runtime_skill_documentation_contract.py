from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
README = ROOT / "README.md"
INSTALLER_SCOPE = ROOT / "shipglows_data" / "technical" / "installer-and-user-scope.md"
RUNTIME_LIFECYCLE = ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md"
POWERSHELL_SYNC = ROOT / "tools" / "shipglows_sync_skills.ps1"
BASH_SYNC = ROOT / "tools" / "shipglows_sync_skills.sh"


class RuntimeSkillDocumentationContractTests(unittest.TestCase):
    def test_active_authorities_use_current_codex_user_skill_scope(self) -> None:
        for path in (README, INSTALLER_SCOPE, RUNTIME_LIFECYCLE):
            text = path.read_text(encoding="utf-8")
            self.assertIn(".agents/skills", text, path)

        installer = INSTALLER_SCOPE.read_text(encoding="utf-8")
        self.assertIn("`~/.agents/skills` for Codex", installer)
        self.assertNotIn(
            "runtime entries under `~/.claude/skills` and `~/.codex/skills`",
            installer,
        )

    def test_sync_implementations_target_agents_skills_for_codex(self) -> None:
        powershell = POWERSHELL_SYNC.read_text(encoding="utf-8")
        bash = BASH_SYNC.read_text(encoding="utf-8")
        self.assertIn("'.agents\\skills'", powershell)
        self.assertIn(".agents/skills", bash)

    def test_windows_diagnostic_checks_before_repair_and_explains_reload(self) -> None:
        text = INSTALLER_SCOPE.read_text(encoding="utf-8")
        self.assertIn("-Mode check -All -Runtime all -Catalog public", text)
        self.assertIn("Do not run `repair` in that state", text)
        self.assertIn("open a new conversation or reload the agent process", text)
        self.assertIn("restarting Windows does not rewrite", text)


if __name__ == "__main__":
    unittest.main()
