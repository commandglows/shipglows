from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


class MobileToolchainSkillConsumersContractTests(unittest.TestCase):
    def test_environment_producer_exposes_every_consumed_field(self) -> None:
        installer = read("cli/windows/install-devserver.ps1")
        for marker in (
            "Flutter and Dart installed: $flutterInstalled",
            "Android toolchain ready: $androidToolchainReady",
            "Android licenses ready: $androidLicensesReady",
            "Android device ready: $androidDeviceReady",
            "Android emulator installed: $androidEmulatorInstalled",
            "Android virtual device ready: $androidAvdReady",
            "Android emulator acceleration ready: $androidEmulatorAccelerationReady",
            "Android next action: $androidNextAction",
            "Android Studio installed: $androidStudioReady",
            "Visual Studio Desktop C++ workload ready: $visualStudioCppReady",
            "Flutter Windows desktop toolchain ready: $windowsDesktopReady",
            "Firebase Android Device Streaming configured: $firebaseDeviceStreamingReady",
            "Firebase Android Device Streaming next action: $firebaseDeviceStreamingNextAction",
        ):
            self.assertIn(marker, installer)

    def test_shared_runtime_state_and_decision_contract(self) -> None:
        runtime = read("skills/references/agent-runtime-awareness.md")
        for marker in (
            "MOBILE-RUNTIME-CONTEXT",
            "FLUTTER-WINDOWS-CONSUMER",
            "ANDROID-DEVICE-DECISION",
            "FIREBASE-DEVICE-STREAMING-BOUNDARY",
            "Android Studio installed",
            "Flutter Windows desktop toolchain ready",
            "Android device ready",
            "Android emulator acceleration ready",
            "Android virtual device (AVD)",
            "Firebase Android Device Streaming configured",
            "Exact next action",
        ):
            self.assertIn(marker, runtime)

        self.assertIn(
            "An installed AVD without acceleration and without a ready device is not a runnable Android target.",
            runtime,
        )
        self.assertIn(
            "Firebase Device Streaming authentication, project selection, billing, and device reservation remain user-owned",
            runtime,
        )
        self.assertIn("transient cache replacement", runtime)

    def test_context_consumers_report_mobile_and_desktop_state(self) -> None:
        for relative_path in (
            "skills/shipglows/SKILL.md",
            "skills/000-shipglows/SKILL.md",
            "skills/301-sg-context/SKILL.md",
        ):
            content = read(relative_path)
            with self.subTest(path=relative_path):
                self.assertIn("agent-runtime-awareness.md", content)
                self.assertIn("mobile and Windows toolchain", content)
                self.assertIn("exact next action", content)

    def test_development_and_engineering_activate_runtime_awareness(self) -> None:
        for relative_path in (
            "skills/sg-development/SKILL.md",
            "skills/001-sg-build/SKILL.md",
            "skills/sg-engineering/SKILL.md",
            "skills/010-sg-technical/SKILL.md",
        ):
            content = read(relative_path)
            with self.subTest(path=relative_path):
                self.assertIn("agent-runtime-awareness.md", content)
                self.assertIn("Flutter, Android, Windows desktop, or Firebase Device Streaming", content)

    def test_public_plugin_context_matches_runtime_contract(self) -> None:
        plugin = read("plugins/shipglows/skills/shipglows/SKILL.md")
        help_catalog = read(
            "plugins/shipglows/skills/shipglows/references/public-help-catalog.md"
        )
        for content in (plugin, help_catalog):
            self.assertIn("mobile and Windows toolchain", content)
            self.assertIn("Firebase Device Streaming", content)
            self.assertIn("exact next action", content)

    def test_public_contract_does_not_automate_user_owned_firebase_actions(self) -> None:
        plugin = read("plugins/shipglows/skills/shipglows/SKILL.md")
        self.assertIn(
            "Never authenticate, select a Firebase project, enable billing, or reserve a streamed device for the user.",
            plugin,
        )


if __name__ == "__main__":
    unittest.main()
