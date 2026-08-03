#!/usr/bin/env python3
"""Scenario-first contract proof for the compact 407 translation dispatcher."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tools.skill_invocation_check import check as check_invocation


SKILL = ROOT / "skills" / "407-sg-translate" / "SKILL.md"
REFERENCES = {
    "audit": ROOT / "skills" / "407-sg-translate" / "references" / "audit-playbook.md",
    "sync": ROOT / "skills" / "407-sg-translate" / "references" / "sync-playbook.md",
    "quality": ROOT / "skills" / "407-sg-translate" / "references" / "translation-quality-reference.md",
}
OLD_SOURCE = ROOT / "skills" / "407-sg-audit-translate"
CODE_INDEX = ROOT / "skills" / "references" / "skill-code-index.md"
HELP = ROOT / "skills" / "302-sg-help" / "references" / "help-catalog.md"
AUDIT_MASTER = ROOT / "skills" / "400-sg-audit" / "references" / "audit-master-workflow.md"
TECHNICAL = ROOT / "skills" / "010-sg-technical" / "SKILL.md"
TECHNICAL_ROUTER = ROOT / "skills" / "010-sg-technical" / "references" / "technical-router.md"
CATALOG = ROOT / "plugins" / "shipglows" / "assets" / "pack-catalog.json"
PACK_DOC = ROOT / "plugins" / "shipglows" / "skills" / "shipglows" / "references" / "pack-catalog.md"
CLAUDE_GUIDE = ROOT / "shipglows_data" / "CLAUDE.md"
CHEATSHEET = ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md"
SPEC = ROOT / "shipglows_data" / "workflow" / "specs" / "consolidate-translation-skill-under-sg-translate.md"
MAX_ACTIVATION_LINES = 180

configured_site = os.environ.get("SHIPGLOWS_SITE_ROOT")
site_candidates = (
    Path(configured_site).expanduser() if configured_site else None,
    ROOT.parent / "shipglows_app" / "site",
    ROOT.parent / "shipglows-site",
)
PUBLIC_SITE = next((path.resolve() for path in site_candidates if path and path.is_dir()), None)
PUBLIC_DIR = PUBLIC_SITE / "src" / "content" / "skills" if PUBLIC_SITE else None

OLD_PATTERN = re.compile(r"(?<![A-Za-z0-9-])(?:407-sg-audit-translate|sg-audit-translate)(?![A-Za-z0-9-])")
HISTORICAL_OLD_NAME_FILES = {
    "shipglows_data/workflow/audits/skill-taxonomy-description-audit-2026-05-17.md",
    "shipglows_data/workflow/reviews/skill-system-hardening-register.md",
    "shipglows_data/workflow/specs/audit-skill-domain-mode-taxonomy-migration.md",
    "shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md",
    "shipglows_data/workflow/specs/consolidate-technical-skills-under-sg-technical.md",
    "shipglows_data/workflow/specs/consolidate-translation-skill-under-sg-translate.md",
    "shipglows_data/workflow/specs/public-skill-categories.md",
    "shipglows_data/workflow/specs/shipglows-pack-portability-hardening.md",
    "shipglows_data/workflow/specs/skill-taxonomy-and-chantier-sources.md",
    "shipglows_data/workflow/specs/specs-as-chantier-registry.md",
    "shipglows_data/workflow/specs/three-digit-runtime-skill-names.md",
}


class TranslateContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.refs = {name: path.read_text(encoding="utf-8") for name, path in REFERENCES.items()}

    def test_tr_audit_bare_path_and_global_routes(self) -> None:
        self.assertLessEqual(len(self.skill.splitlines()), MAX_ACTIVATION_LINES)
        self.assertIn('argument-hint:', self.skill)
        for phrase in (
            "bare invocation -> `audit`",
            "`audit [<path|scope|global>]`",
            "`global` -> normalize to `audit global`",
            "valid existing path",
            "never infer `sync` from a path alone",
        ):
            self.assertIn(phrase, self.skill)
        self.assertIn("TR-AUDIT-BARE", self.refs["audit"])
        self.assertIn("TR-AUDIT-PATH", self.refs["audit"])
        self.assertIn("TR-AUDIT-GLOBAL", self.refs["audit"])
        self.assertIn("Product files remain read-only", self.refs["audit"])

    def test_tr_sync_safe_and_apply_is_one_alias(self) -> None:
        self.assertIn("Canonical public modes are exactly `audit` and `sync`", self.skill)
        self.assertIn("`apply [<path|scope>]` -> normalize to the exact `sync` route", self.skill)
        self.assertIn("never a third mode or implementation path", self.skill)
        self.assertIn("TR-SYNC-SAFE", self.refs["sync"])
        self.assertIn("TR-APPLY-ALIAS", self.refs["sync"])
        self.assertNotRegex(self.skill, r"(?m)^- `apply` (?:mode|-> load only a third)")

    def test_tr_invalid_and_help_have_no_execution_path(self) -> None:
        for phrase in (
            "`help` -> list the grammar",
            "load no execution playbook",
            "make no file mutation",
            "If input does not match these routes safely",
        ):
            self.assertIn(phrase, self.skill)
        self.assertIn("TR-INVALID", self.refs["audit"])
        self.assertIn("TR-INVALID", self.refs["sync"])

    def test_tr_sync_ambiguous_preserves_entries_and_structure(self) -> None:
        for phrase in (
            "never replace a non-empty translation",
            "Ambiguous, business-sensitive, terminology-conflicting, placeholder-unsafe",
            "remain unchanged",
            "before/after",
            "list every touched file",
        ):
            self.assertIn(phrase, self.refs["sync"])
        for phrase in (
            "ICU plural/select fragments",
            "Markdown links",
            "HTML/XML tags",
            "component placeholders",
            "French Quality",
            "All required accents and ligatures are mandatory",
        ):
            self.assertIn(phrase, self.refs["quality"])
        self.assertIn("TR-SYNC-AMBIGUOUS", self.refs["sync"])

    def test_tr_boundary_keeps_adjacent_owners(self) -> None:
        boundaries = (
            "009-sg-marketing",
            "406-sg-seo",
            "007-sg-content",
            "200-sg-redact",
            "300-sg-docs",
            "400-sg-audit",
        )
        for owner in boundaries:
            self.assertIn(owner, self.skill)
        self.assertIn("TR-BOUNDARY", self.refs["quality"])

    def test_rule_transfer_covers_former_contract(self) -> None:
        combined = "\n".join((self.skill, *self.refs.values())).lower()
        source_rule_markers = (
            "file-based locale routes",
            "bilingual fields",
            "completeness matrix",
            "hardcoded strings",
            "technical i18n",
            "preference persistence",
            "x-default",
            "source-to-target matrix",
            "highest-coverage locale",
            "two clearly labeled options",
            "traffic-first",
            "canonical project-local",
            "french quality",
            "native speaker",
            "placeholder",
            "brand/product names",
        )
        for marker in source_rule_markers:
            self.assertIn(marker.lower(), combined, marker)
        self.assertEqual(set(REFERENCES), {"audit", "sync", "quality"})

    def test_tr_active_surfaces_use_new_identity(self) -> None:
        active_paths = (
            SKILL,
            ROOT / "skills" / "407-sg-translate" / "README.md",
            *REFERENCES.values(),
            CODE_INDEX,
            HELP,
            AUDIT_MASTER,
            TECHNICAL,
            TECHNICAL_ROUTER,
            PACK_DOC,
            CLAUDE_GUIDE,
            CHEATSHEET,
        )
        for path in active_paths:
            text = path.read_text(encoding="utf-8")
            self.assertIsNone(OLD_PATTERN.search(text), str(path))
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        quality = next(pack for pack in catalog["packs"] if pack["id"] == "shipglows-quality")
        self.assertIn("407-sg-translate", quality["skills"])
        self.assertNotIn("407-sg-audit-translate", quality["skills"])

    def test_tr_public_surface_is_renamed(self) -> None:
        if PUBLIC_DIR is None:
            self.skipTest("optional ShipGlows public-site checkout is unavailable")
        current = PUBLIC_DIR / "sg-translate.md"
        self.assertTrue(current.is_file())
        text = current.read_text(encoding="utf-8")
        self.assertIn('slug: "sg-translate"', text)
        for route in ("/sg-translate audit", "/sg-translate sync", "/sg-translate apply"):
            self.assertIn(route, text)
        self.assertFalse((PUBLIC_DIR / "sg-audit-translate.md").exists())
        for page in PUBLIC_DIR.glob("*.md"):
            self.assertIsNone(OLD_PATTERN.search(page.read_text(encoding="utf-8")), str(page))

    def test_tr_history_is_explicitly_allowlisted(self) -> None:
        scanned_roots = (
            ROOT / "shipglows_data" / "workflow" / "specs",
            ROOT / "shipglows_data" / "workflow" / "audits",
            ROOT / "shipglows_data" / "workflow" / "reviews",
            ROOT / "shipglows_data" / "workflow" / "archives",
        )
        found = {
            str(path.relative_to(ROOT))
            for base in scanned_roots
            for path in base.rglob("*.md")
            if OLD_PATTERN.search(path.read_text(encoding="utf-8"))
        }
        self.assertEqual(found, HISTORICAL_OLD_NAME_FILES)
        self.assertIn("TR-HISTORY", self.refs["quality"])
        self.assertIn("407-sg-audit-translate", SPEC.read_text(encoding="utf-8"))

    def test_tr_source_and_runtime_retirement(self) -> None:
        self.assertFalse(OLD_SOURCE.exists())
        for runtime in (Path.home() / ".claude" / "skills", Path.home() / ".codex" / "skills"):
            if not runtime.is_dir():
                continue
            current = runtime / "407-sg-translate"
            retired = runtime / "407-sg-audit-translate"
            self.assertTrue(current.is_symlink(), str(current))
            self.assertEqual(current.resolve(), (ROOT / "skills" / "407-sg-translate").resolve())
            self.assertFalse(retired.exists() or retired.is_symlink(), str(retired))

    def test_tr_invocation_registry_accepts_current_identity_only(self) -> None:
        for invocation in (
            "407-sg-translate",
            "407-sg-translate audit",
            "407-sg-translate sync src/i18n",
            "407-sg-translate apply src/i18n",
            "407-sg-translate global",
        ):
            payload = check_invocation(invocation)
            self.assertEqual(payload["status"], "valid", payload)
            self.assertEqual(payload["resolved_skill"], "407-sg-translate")
        retired = check_invocation("407-sg-audit-translate audit")
        self.assertEqual(retired["status"], "invalid")
        self.assertEqual(retired["error"], "unknown_skill")


if __name__ == "__main__":
    unittest.main()
