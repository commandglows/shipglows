"""User-facing commands and expert grammar must agree without rejecting prose."""
import unittest
from tools.skill_invocation_check import check


class HelpInvocationParityTests(unittest.TestCase):
    def test_design_subcommands_match_public_and_expert(self):
        for prefix in ("sg-design", "006-sg-design"):
            for tail in ("audit ui", "audit tokens", "audit components", "audit a11y",
                         "animation audit", "animation design", "animation implement", "animation tune",
                         "library add https://example.com", "library retry example", "library approve example",
                         "library list", "library status"):
                self.assertEqual(check(f"{prefix} {tail}")["status"], "valid", tail)
            for tail in ("audit", "audit nonsense", "animation", "animation nonsense",
                         "library", "library remove example", "library add", "library retry", "library list extra"):
                self.assertEqual(check(f"{prefix} {tail}")["status"], "invalid", tail)

    def test_core_recent_and_since_have_same_grammar_on_both_surfaces(self):
        for prefix in ("shipglows core", "900-shipglows-core"):
            for tail in ("audit recent", "audit recent 20", "audit since abc123", "audit skills",
                         "refresh sg-design", "build loading", "help"):
                self.assertEqual(check(f"{prefix} {tail}")["status"], "valid", tail)
            for tail in ("audit recent 0", "audit recent -1", "audit recent x", "audit recent 1 extra",
                         "audit since", "audit since abc extra", "refresh", "refresh 900-shipglows-core"):
                self.assertEqual(check(f"{prefix} {tail}")["status"], "invalid", tail)

    def test_content_public_and_internal_publication_and_email(self):
        for prefix in ("sg-content", "007-sg-content"):
            for mode in ("publish", "ship", "apply", "emailing"):
                self.assertEqual(check(f"{prefix} {mode} newsletter")["status"], "valid")
        result = check("sg-content emailing newsletter")
        self.assertEqual(result["selected_internal_engine"], "202-sg-emailing")

    def test_natural_language_and_execution_tags_still_work(self):
        for command in ("sg-design améliore cette page", "shipglows explique ce projet",
                        "sg-design audit ui homepage #local", "shipglows core audit recent 2 #nolocal",
                        "sg-private data status", "sg-help mode --expert"):
            self.assertEqual(check(command)["status"], "valid", command)
        self.assertEqual(check("sg-design audit nonsense #local")["status"], "invalid")
        self.assertEqual(check("shipglows auto #local")["status"], "invalid")


if __name__ == "__main__":
    unittest.main()
