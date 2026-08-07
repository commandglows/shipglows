import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class OwaspApplicationSecurityContractTest(unittest.TestCase):
    def test_reference_tracks_owasp_2025_and_asvs_5(self):
        text = (ROOT / "skills/references/owasp-application-security-awareness.md").read_text()
        for category in (
            "A01 Broken Access Control",
            "A02 Security Misconfiguration",
            "A03 Software Supply Chain Failures",
            "A04 Cryptographic Failures",
            "A05 Injection",
            "A06 Insecure Design",
            "A07 Authentication Failures",
            "A08 Software or Data Integrity Failures",
            "A09 Security Logging and Alerting Failures",
            "A10 Mishandling of Exceptional Conditions",
        ):
            self.assertIn(category, text)
        self.assertIn("OWASP ASVS v5.0.0", text)
        self.assertIn("not a claim of compliance", text)
        self.assertIn("OWASP Security Gate", text)

    def test_security_lifecycle_consumers_load_the_reference(self):
        consumers = (
            "skills/004-sg-deploy/SKILL.md",
            "skills/010-sg-technical/SKILL.md",
            "skills/100-sg-spec/SKILL.md",
            "skills/101-sg-ready/SKILL.md",
            "skills/102-sg-start/SKILL.md",
            "skills/103-sg-verify/SKILL.md",
            "skills/106-sg-fix/SKILL.md",
            "skills/400-sg-audit/SKILL.md",
        )
        for relative_path in consumers:
            with self.subTest(relative_path=relative_path):
                self.assertIn(
                    "owasp-application-security-awareness.md",
                    (ROOT / relative_path).read_text(),
                )

    def test_readiness_and_verification_require_a_gate(self):
        readiness = (ROOT / "skills/101-sg-ready/references/readiness-review-playbook.md").read_text()
        verification = (ROOT / "skills/103-sg-verify/SKILL.md").read_text()
        self.assertIn("OWASP Security Gate", readiness)
        self.assertIn("OWASP Security Gate", verification)


if __name__ == "__main__":
    unittest.main()
