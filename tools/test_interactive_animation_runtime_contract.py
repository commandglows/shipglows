#!/usr/bin/env python3
"""Scenario-first regression checks for interactive animation runtimes."""

from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "skills/references/interactive-animation-runtime-contract.md"
SPEC = ROOT / "shipglows_data/workflow/specs/interactive-animation-runtime-contract.md"
PLAYBOOK = ROOT / "skills/006-sg-design/references/animation-playbook.md"
OWNERS = (
    ROOT / "skills/001-sg-build/SKILL.md",
    ROOT / "skills/006-sg-design/SKILL.md",
    ROOT / "skills/602-sg-platform-parity/SKILL.md",
)


def text(path: Path) -> str:
    return " ".join(path.read_text(encoding="utf-8").split())


class InteractiveAnimationRuntimeContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = text(CONTRACT)

    def test_conditional_owner_loaders(self) -> None:
        # Owners may name a shared contract by file name inside a shared-contract loader list.
        reference = "interactive-animation-runtime-contract.md"
        for owner in OWNERS:
            value = text(owner)
            self.assertIn(reference, value)
            self.assertTrue(" when " in value.lower() or " whenever " in value.lower())

    def test_runtime_classes_are_distinct_and_provider_neutral(self) -> None:
        for value in (
            "Native CSS, Web Animations, or project-native motion",
            "Motion is a code-driven library candidate",
            "Lottie JSON or dotLottie",
            "Rive is an authored interactive runtime candidate",
            "They are not interchangeable",
            "There is no universal winner",
        ):
            self.assertIn(value, self.contract)

    def test_application_state_remains_authoritative(self) -> None:
        for value in (
            "Application state remains authoritative",
            "authentication, authorization, purchase, entitlement, validation, persistence, navigation, or task completion",
            "runtime state machine may present or mirror consequential state",
            "never becomes the sole source of truth",
            "authoring source, exported artifact, runtime adapter, and event/input mapping",
        ):
            self.assertIn(value, self.contract)

    def test_formats_themes_assets_and_platform_support_are_explicit(self) -> None:
        for value in (
            "`.json`, `.lottie`, and `.riv` are different artifacts",
            "animations, images, fonts, themes, and state machines",
            "slot IDs",
            "exact runtime, renderer, package variant, version, and target platform",
            "Web and Flutter parity is proven feature by feature",
            "common source asset does not prove common behavior",
        ):
            self.assertIn(value, self.contract)

    def test_loading_failure_and_no_runtime_fallback_preserve_outcome(self) -> None:
        for value in (
            "loading, ready, empty, timeout, decode or parse failure, missing asset, unsupported feature, and retry",
            "without the animation runtime, JavaScript, canvas, or remote asset host",
            "Never hide essential content until runtime initialization succeeds",
            "static or semantic fallback",
        ):
            self.assertIn(value, self.contract)

    def test_reduced_motion_is_semantic_not_duration_only(self) -> None:
        for value in (
            "`prefers-reduced-motion`",
            "meaningful stable outcome",
            "Merely shortening every duration",
            "pause, stop, or hide",
            "state, feedback, reading order, focus, and task completion",
        ):
            self.assertIn(value, self.contract)

    def test_lifecycle_cleanup_and_performance_are_measured(self) -> None:
        for value in (
            "single initialization owner",
            "mount, unmount, remount, route transition, background, foreground, resize, and hot reload",
            "cleanup or dispose",
            "listeners, observers, render loops, state-machine instances, files, controllers, canvases, workers, WASM, and GPU resources",
            "runtime, WASM, animation, image, font, audio, and remote-asset bytes",
            "frame pacing, main-thread work, CPU, GPU, memory, and battery",
        ):
            self.assertIn(value, self.contract)

    def test_security_provenance_and_external_actions_are_bounded(self) -> None:
        for value in (
            "Treat animation files, archives, fonts, images, audio, scripts, and remote URLs as untrusted inputs",
            "creative-asset-provenance-contract.md",
            "allowlisted schemes and destinations",
            "explicit user activation",
            "Never place secrets, credentials, private customer data, or unnecessary PII",
        ):
            self.assertIn(value, self.contract)

    def test_rendered_cross_platform_proof_is_required(self) -> None:
        for value in (
            "A build, typecheck, source scan, editor preview, or successful first frame alone does not prove",
            "supported Web browsers and Flutter targets",
            "loading and failure states, reduced motion, keyboard and assistive semantics, responsive resizing",
            "rapid repeated input",
            "cleanup after remount or navigation",
        ):
            self.assertIn(value, self.contract)

    def test_primary_sources_and_scope_boundaries(self) -> None:
        for value in (
            "https://rive.app/docs/feature-support",
            "https://rive.app/docs/runtimes/state-machines",
            "https://rive.app/docs/runtimes/web/web-js",
            "https://rive.app/docs/runtimes/flutter/flutter",
            "https://dotlottie.io/spec/2.0/",
            "https://motion.dev/docs/react-use-reduced-motion",
            "https://www.w3.org/WAI/WCAG22/Techniques/css/C39",
            "https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html",
        ):
            self.assertIn(value, self.contract)
        self.assertIn("interactive-animation-runtime-contract.md", text(PLAYBOOK))
        if SPEC.is_file():  # the spec lives in the private data corpus
            spec = text(SPEC)
            self.assertIn("status: ready", spec)
            self.assertIn("005-sg-ship`: out of scope", spec)
            self.assertIn("No dependency, provider, package, hosted asset, or public invocation grammar is added", spec)


if __name__ == "__main__":
    unittest.main()
