#!/usr/bin/env python3
"""Deterministic contract proof for the 010-sg-technical consolidation."""

from pathlib import Path
import json
import re
import unittest

from tools.test_support import optional_public_site


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "010-sg-technical" / "SKILL.md"
ROUTER = ROOT / "skills" / "010-sg-technical" / "references" / "technical-router.md"
TRANSFER = ROOT / "skills" / "010-sg-technical" / "references" / "technical-contract-migration-evidence.md"
PLAYBOOKS = {
    "audit": ROOT / "skills" / "010-sg-technical" / "references" / "technical-audit-playbook.md",
    "deps": ROOT / "skills" / "010-sg-technical" / "references" / "dependency-audit-playbook.md",
    "performance": ROOT / "skills" / "010-sg-technical" / "references" / "performance-audit-playbook.md",
    "migrate": ROOT / "skills" / "010-sg-technical" / "references" / "migration-playbook.md",
    "github": ROOT / "skills" / "010-sg-technical" / "references" / "github-hygiene-playbook.md",
}
AUDIT_BRANCHES = {
    "protocol": ROOT / "skills" / "010-sg-technical" / "references" / "technical-audit-protocol.md",
    "file": ROOT / "skills" / "010-sg-technical" / "references" / "technical-file-audit.md",
    "project": ROOT / "skills" / "010-sg-technical" / "references" / "technical-project-audit.md",
    "global": ROOT / "skills" / "010-sg-technical" / "references" / "technical-global-audit.md",
}
PLAYBOOK_NAMES = {path.name for path in PLAYBOOKS.values()}
PREDECESSORS = (
    "401-sg-audit-code",
    "402-sg-deps",
    "403-sg-perf",
    "404-sg-migrate",
)
PUBLIC_SITE = optional_public_site(ROOT)
PUBLIC_DIR = PUBLIC_SITE / "src/content/skills" if PUBLIC_SITE else None
CODE_INDEX = ROOT / "skills" / "references" / "skill-code-index.md"
CATALOG = ROOT / "plugins" / "shipglows" / "assets" / "pack-catalog.json"
PACK_DOC = ROOT / "plugins" / "shipglows" / "skills" / "shipglows" / "references" / "pack-catalog.md"
SPECS_DIR = ROOT / "shipglows_data" / "workflow" / "specs"
MAX_ACTIVATION_LINES = 180

PREDECESSOR_PATTERN = re.compile(
    r"(?<![A-Za-z0-9-])(?:"
    r"(?:401-)?sg-audit-code|"
    r"(?:402-)?sg-deps|"
    r"(?:403-)?sg-perf|"
    r"(?:404-)?sg-migrate"
    r")(?![A-Za-z0-9-])"
)

# Exact, reviewed historical/factual lines are the only predecessor occurrences
# permitted in the active specs corpus. Any wording change or new occurrence must
# be reviewed and added explicitly instead of hiding a directory or whole spec.
SPEC_PREDECESSOR_LINE_ALLOWLIST = {
    "consolidate-technical-skills-under-sg-technical.md": frozenset(
        {
            "- skills/401-sg-audit-code/",
            "- skills/402-sg-deps/",
            "- skills/403-sg-perf/",
            "- skills/404-sg-migrate/",
            '- "Current public/runtime surface exposes 401-sg-audit-code, 402-sg-deps, 403-sg-perf, and 404-sg-migrate as separate entrypoints."',
            "- Retirement of `skills/401-sg-audit-code/`, `skills/402-sg-deps/`, `skills/403-sg-perf/`, and `skills/404-sg-migrate/` only after transfer, active-surface, catalog, runtime, and public proof passes.",
            "6. Active-surface proof: focused scans distinguish active execution/public references from historical evidence; no active occurrence of `401-sg-audit-code`, `402-sg-deps`, `403-sg-perf`, `404-sg-migrate`, or their unprefixed invocation forms remains after migration.",
            "- Files: `skills/401-sg-audit-code/**`, `skills/402-sg-deps/**`, `skills/403-sg-perf/**`, `skills/404-sg-migrate/**`, active consumers discovered by focused scans, and the new transfer matrix.",
            "- Public site: replace `sg-audit-code.md`, `sg-deps.md`, `sg-perf.md`, and `sg-migrate.md` with `sg-technical.md`; update `sg-audit.md`, `sg-check.md`, `sg-maintain.md`, `sg-github-hygiene.md`, `sg-prod.md`, `sg-seo.md`, and other inventory-confirmed related-skill metadata or prompts.",
        }
    ),
    # Closed pre-consolidation contract snapshot: these exact owner routes are
    # retained as the shipped 310 pressure-scenario record, not current guidance.
    "dependabot-queue-continuation-for-github-hygiene.md": frozenset(
        {
            '- "skills/402-sg-deps/SKILL.md"',
            '- "skills/404-sg-migrate/SKILL.md"',
            "- If one pull request requires `402-sg-deps`, `404-sg-migrate`, or `github:gh-fix-ci`, record `routed` with owner and reason, then continue unrelated eligible pull requests.",
            "- Preserve `402-sg-deps`, `404-sg-migrate`, and `github:gh-fix-ci` ownership boundaries.",
            "- [x] AC 5 — Specialist routing: Given dependency risk, a major migration, or failing CI requires specialist work, when the item is routed, then the ledger names `402-sg-deps`, `404-sg-migrate`, or `github:gh-fix-ci` and does not claim downstream success.",
            '- Focused scan: `rg -n "Dependabot|queue|merged|closed|deferred|routed|blocked|revalid|actionable|402-sg-deps|404-sg-migrate|github:gh-fix-ci" skills/010-sg-technical/references/github-hygiene-playbook.md tools/test_010_sg_technical_contract.py`.',
        }
    ),
    "devserver-ui-centralization.md": frozenset(
        {
            "| 2026-07-17 | 403-sg-perf | GPT-5 | audit | D: common startup measured via `s x` 3.45s, `s m n` 3.62s, and `s m r` 6.68s; `.flox` descent and duplicate scans confirmed | /100-sg-spec Optimize DevServer startup, caches, and shell UI |",
            "| 2026-07-17 | 403-sg-perf | GPT-5 | cache audit | D: direct PM2/environment hits 7/8ms, but production subshell calls repeat 229-248ms / 2.77-2.82s work; persistent header cache reads in 1ms | /100-sg-spec Optimize DevServer startup, caches, and shell UI |",
        }
    ),
    "shipglows-gitignore-and-repo-hygiene-hard-gates-for-agents-and-audits.md": frozenset(
        {
            '- "At spec creation on 2026-06-18, the former 401-sg-audit-code workflow checked only `.env` presence in `.gitignore`, which was too narrow for generated local-tool outputs and tracked transient artifacts."',
            "La preuve locale capturée le 2026-06-18 confirmait le problème: la worktree contenait une modification de `.gitignore` et des suppressions de fichiers `site/.playwright-mcp/*.yml`, signe qu'un outillage local avait déjà produit des artefacts suivis ou mal nettoyés. En parallèle, l'ancien `401-sg-audit-code` ne vérifiait mécaniquement que `.env` dans `.gitignore`, ce qui était trop étroit.",
        }
    ),
    "three-digit-runtime-skill-names.md": frozenset(
        {
            "ShipGlows doit migrer les skills locales de noms runtime non prefixes vers des noms `NNN-<ancien-nom>` ou `NNN` est un code a trois chiffres stable, memorisable et organise par familles. Apres migration et rechargement de Codex/Claude, l'operatrice doit voir et pouvoir invoquer des skills comme `000-shipglows`, `001-sg-build`, `100-sg-spec` et `401-sg-audit-code`; les dossiers `skills/<name>`, les champs `name:` et les liens runtime doivent etre coherents avec ces noms. En cas d'echec ou d'incoherence, les validateurs doivent bloquer la migration avant publication runtime ou signaler les liens obsoletes. Le cas facile a rater est de laisser des references internes, des symlinks Codex/Claude, des `agents/openai.yaml`, ou un index numerique qui continuent de pointer vers les anciens noms.",
            "- [x] AC 3: Given `001-sg-build`, `000-shipglows`, `100-sg-spec`, and `401-sg-audit-code`, when runtime sync runs, then Claude and Codex target links resolve to the matching prefixed source directories.",
            "| `401` | `sg-audit-code` | `401-sg-audit-code` | Audit/quality/ops |",
            "| `402` | `sg-deps` | `402-sg-deps` | Audit/quality/ops |",
            "| `403` | `sg-perf` | `403-sg-perf` | Audit/quality/ops |",
            "| `404` | `sg-migrate` | `404-sg-migrate` | Audit/quality/ops |",
            "The current two-digit index is only a discovery and routing layer. It documents labels such as `01-sg-build`, but the actual runtime skills still appear as `sg-build`, `shipglows`, `sg-audit-code`, and other names that cluster under the same `s` prefix. This does not solve the picker/filtering problem inside Codex or Claude Code. The user now wants the code to be part of the real skill name.",
        }
    ),
    # Closed pre-consolidation specs keep exact source-era inventories,
    # measurements, acceptance criteria, and run-history provenance only.
    "audit-and-compact-skill-taxonomy-descriptions.md": frozenset(
        {
            "- audit: `sg-audit*`, `sg-perf`, `sg-deps`, `sg-check`",
        }
    ),
    "compact-shipglows-skill-instructions-phase-2.md": frozenset(
        {
            '- "skills/sg-audit-code/SKILL.md"',
            '- "Remaining >500-line skills: sg-init 718 lines, sg-audit-code 653 lines, sg-audit-copywriting 641 lines, sg-help 545 lines, sg-repurpose 523 lines, sg-audit-seo 507 lines."',
            "- System effect: `sg-init`, `sg-help`, `sg-audit-code`, `sg-audit-copywriting`, `sg-audit-seo`, and `sg-repurpose` either fall below 500 lines or have documented exceptions with safe substitutions or follow-up scope.",
            "- `skills/sg-audit-code/SKILL.md`",
            "- `skills/sg-audit-code/SKILL.md`: security and architecture guardrails must remain explicit; detailed phase checklists can move to local references.",
            "- `sg-audit-code`, `sg-audit-copywriting`, and `sg-audit-seo` have similar audit skeletons but different domains. Do not over-generalize them into one shared audit mega-reference.",
            "- [x] Task 4: Compact `sg-audit-code` with audit references",
            "- File: `skills/sg-audit-code/SKILL.md`",
            "- Action: Keep source-de-chantier behavior, findings-first report mode, mode detection, fix/report contract, and security stop conditions local; move long phase checklists and detailed audit criteria into `skills/sg-audit-code/references/*.md`.",
            '- Validate with: `rg -n "Chantier Potential|Report Modes|GLOBAL MODE|FILE MODE|PROJECT MODE|security|findings" skills/sg-audit-code/SKILL.md`',
            "- [ ] CA 6: Given `sg-audit-code` can surface security and data risks, when compacted, then security, permission, architecture, reliability, and fix/report gates are still present locally or in explicitly loaded references.",
        }
    ),
    "compact-shipglows-skill-instructions.md": frozenset(
        {
            '- "Largest current skills: sg-docs 941 lines, sg-audit-design 843 lines, sg-init 718 lines, sg-audit-code 653 lines, sg-audit-copywriting 641 lines, sg-verify 571 lines, sg-help 545 lines."',
            "- If a pilot skill cannot be safely compacted, the implementation must document the reason and substitute the next highest body-size risk from `sg-init`, `sg-help`, `sg-audit-code`, or `sg-audit-copywriting`.",
            "- `skills/sg-audit-code/SKILL.md`",
            "- >500 lines: `sg-audit-code`, `sg-audit-copywriting`, `sg-audit-seo`, `sg-help`, `sg-init`, `sg-repurpose`",
            "- >~5000 tokens (remaining high-risk bodies): `sg-audit`, `sg-audit-a11y`, `sg-audit-code`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-gtm`, `sg-audit-seo`, `sg-auth-debug`, `sg-enrich`, `sg-help`, `sg-init`, `sg-market-study`, `sg-prod`, `sg-redact`, `sg-repurpose`, `sg-spec`, `sg-start`",
        }
    ),
    "installer-supply-chain-and-codebase-risk-reduction.md": frozenset(
        {
            '- "sg-audit-code 2026-04-28 found install.sh uses live remote install scripts/direct downloads and needs pinned, verified install steps and strict failure behavior."',
            '- "sg-audit-code 2026-04-28 found lib.sh is 5900+ lines and spans lifecycle, publishing, dashboard, inspector, secrets, and metadata behavior."',
            "- Master/local trackers: implementation may close the audit rows created by `sg-audit-code`, but this spec itself does not edit trackers.",
            "| 2026-04-28 20:30:00 UTC | sg-spec | GPT-5 Codex | Created spec from sg-audit-code chantier potential for installer, dependency, test, and architecture risk reduction | draft saved | /sg-ready Installer supply-chain hardening and ShipGlows codebase risk reduction |",
        }
    ),
    "public-skill-categories.md": frozenset(
        {
            '- "sg-perf advisory 2026-04-27: recategorization has no material performance impact because Astro pages remain static and unhydrated."',
            "| `Audit & Improve` | Inspecter la qualite, trouver les risques, verifier ou ameliorer un systeme existant. | `sg-audit`, `sg-audit-a11y`, `sg-audit-code`, `sg-audit-components`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-gtm`, `sg-audit-seo`, `sg-audit-translate`, `sg-deps`, `sg-perf`, `sg-verify` |",
            "| `Operate & Ship` | Garder le projet exploitable, documente, verifie, deploye et pret a etre livre. | `sg-check`, `sg-changelog`, `sg-docs`, `sg-end`, `sg-migrate`, `sg-prod`, `sg-ship`, `sg-status`, `sg-tasks` |",
            "| 2026-04-27 20:31:18 UTC | sg-perf | GPT-5 Codex | Audited performance impact of public skill category recategorization on Astro catalog pages | advisory | /sg-spec Public skill categories |",
        }
    ),
    "sg-maintain-project-maintenance-skill.md": frozenset(
        {
            '- "skills/sg-deps/SKILL.md"',
            '- "skills/sg-audit-code/SKILL.md"',
            '- "skills/sg-migrate/SKILL.md"',
            '- "User decision 2026-05-03: sg-adopt does not add enough beyond sg-init/sg-docs/sg-migrate/sg-deps."',
            '- "Existing security coverage is split between sg-deps for dependency and supply-chain risk and sg-audit-code for auth, permissions, trust boundaries, secrets, reliability, and abuse resistance."',
            "`sg-maintain` is an orchestrator, not a replacement for specialist skills. It must inspect maintenance state, classify the top maintenance needs, and route to owner skills: `sg-bug`, `sg-deps`, `sg-docs`, `sg-check`, `sg-audit-code`, `sg-audit`, `sg-migrate`, and `sg-tasks`.",
            "- `sg-deps` for vulnerability, supply-chain, license, package drift, and config posture.",
            "- `sg-audit-code` for authn/authz, tenant boundaries, secrets, trust boundaries, webhooks, destructive actions, secure failure modes, and abuse resistance.",
            "- [x] AC 2: Given the operator invokes `sg-maintain security`, then the skill routes security posture through `sg-deps` and `sg-audit-code` rather than inventing a separate security audit.",
        }
    ),
    "skill-description-budget-compliance.md": frozenset(
        {
            "- File: `skills/continue/SKILL.md`, `skills/sg-audit-components/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-design-playground/SKILL.md`, `skills/sg-auth-debug/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-audit-design-tokens/SKILL.md`, `skills/sg-resume/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-spec/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-design/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-audit-a11y/SKILL.md`, `skills/sg-context/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-skills-refresh/SKILL.md`, `skills/sg-veille/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-model/SKILL.md`",
            "- File: `skills/sg-audit-design/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-init/SKILL.md`",
        }
    ),
    "skill-taxonomy-and-chantier-sources.md": frozenset(
        {
            '- "Repo investigation 2026-04-27: sg-deps, sg-perf, sg-audit, sg-check, sg-test, sg-prod, sg-migrate, and sg-auth-debug are currently conditionnel but can originate new chantiers."',
            "Quand une skill ShipGlows termine un travail qui revele plus qu'une action immediate, elle doit determiner si son resultat est un chantier potentiel, l'indiquer explicitement dans son rapport final, et orienter vers une spec durable quand le travail necessite de la reflexion, des decisions, plusieurs etapes, ou une verification ulterieure. Si un chantier existe deja, la skill continue a tracer selon la doctrine actuelle; si aucun chantier unique n'existe mais que le rapport revele un vrai travail a suivre, elle ne doit pas ecrire au hasard dans une spec existante, mais produire un bloc `Chantier potentiel` avec titre propose, raison, severite, scope, evidence et prochaine commande `/sg-spec ...`. Le cas facile a rater est une skill `conditionnel` comme `sg-deps` ou `sg-perf`: elle ne peut pas tracer dans une spec ambigue, mais elle peut et doit recommander la creation d'un chantier quand ses findings depassent un simple fix direct.",
            "- Success proof: lancer ou relire `sg-deps`, `sg-perf`, `sg-audit`, `sg-check` ou `sg-prod` montre un format standard qui ne laisse plus les findings critiques seulement dans la conversation.",
            "- `sg-deps` trouve des vulnerabilites critiques mais deux specs actives existent: ne pas ecrire dans une spec; recommander une nouvelle spec ou demander selection explicite.",
            "- File: `skills/sg-deps/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-audit-design/SKILL.md`, `skills/sg-audit-a11y/SKILL.md`, `skills/sg-audit-components/SKILL.md`, `skills/sg-audit-seo/SKILL.md`, `skills/sg-audit-gtm/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-translate/SKILL.md`, `skills/sg-audit-design-tokens/SKILL.md`",
            '- Validate with: `rg -n "source-de-chantier|Chantier potentiel" skills/sg-deps/SKILL.md skills/sg-perf/SKILL.md skills/sg-audit*/SKILL.md`',
            "- File: `skills/sg-auth-debug/SKILL.md`, `skills/sg-browser/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-migrate/SKILL.md`, `skills/sg-fix/SKILL.md`",
            '- Validate with: `rg -n "source-de-chantier|Chantier potentiel|spec-first" skills/sg-auth-debug/SKILL.md skills/sg-browser/SKILL.md skills/sg-prod/SKILL.md skills/sg-check/SKILL.md skills/sg-test/SKILL.md skills/sg-migrate/SKILL.md skills/sg-fix/SKILL.md`',
            "- [x] AC 2: Given `sg-deps` trouve des vulnerabilites critiques sans chantier unique, when son rapport final est produit, then il ne modifie aucune spec existante et affiche `Chantier potentiel: oui` avec une commande `/sg-spec`.",
            "- [x] AC 3: Given `sg-perf` trouve seulement une optimisation mineure locale, when son rapport final est produit, then il peut afficher `Chantier potentiel: non` avec raison.",
            "- Then inspect representative sources: `skills/sg-deps/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-browser/SKILL.md`.",
            "- `source-de-chantier`: `sg-deps`, `sg-perf`, all audits, `sg-auth-debug`, `sg-browser`, `sg-prod`, `sg-check`, `sg-test`, `sg-migrate`, `sg-fix`, `sg-market-study`, `sg-veille`, maybe `sg-research` when it produces implementation decisions.",
        }
    ),
    "specs-as-chantier-registry.md": frozenset(
        {
            "- Initial observed inventory on 2026-04-27: `skills/name/SKILL.md`, `skills/sg-audit-a11y/SKILL.md`, `skills/sg-audit-code/SKILL.md`, `skills/sg-audit-components/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-design-tokens/SKILL.md`, `skills/sg-audit-design/SKILL.md`, `skills/sg-audit-gtm/SKILL.md`, `skills/sg-audit-seo/SKILL.md`, `skills/sg-audit-translate/SKILL.md`, `skills/sg-audit/SKILL.md`, `skills/sg-auth-debug/SKILL.md`, `skills/sg-backlog/SKILL.md`, `skills/sg-changelog/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-context/SKILL.md`, `skills/sg-deps/SKILL.md`, `skills/sg-design-playground/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-end/SKILL.md`, `skills/sg-enrich/SKILL.md`, `skills/sg-explore/SKILL.md`, `skills/sg-fix/SKILL.md`, `skills/sg-help/SKILL.md`, `skills/sg-init/SKILL.md`, `skills/sg-market-study/SKILL.md`, `skills/sg-migrate/SKILL.md`, `skills/sg-model/SKILL.md`, `skills/sg-perf/SKILL.md`, `skills/sg-priorities/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-ready/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-repurpose/SKILL.md`, `skills/sg-research/SKILL.md`, `skills/sg-resume/SKILL.md`, `skills/sg-review/SKILL.md`, `skills/sg-scaffold/SKILL.md`, `skills/sg-ship/SKILL.md`, `skills/sg-skills-refresh/SKILL.md`, `skills/sg-spec/SKILL.md`, `skills/sg-start/SKILL.md`, `skills/sg-status/SKILL.md`, `skills/sg-tasks/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-veille/SKILL.md`, `skills/sg-verify/SKILL.md`.",
        }
    ),
}

MIGRATED_ACTIVE_SPEC_PROOF = {
    "agent-clarity-hardening-phase-2.md": (
        "$010-sg-technical audit <target>",
        "$010-sg-technical performance <target>",
    ),
    "audit-skill-domain-mode-taxonomy-migration.md": (
        "$010-sg-technical audit <target>",
        "skills/010-sg-technical/references/technical-audit-playbook.md",
    ),
    "shipglows-gitignore-and-repo-hygiene-hard-gates-for-agents-and-audits.md": (
        "$010-sg-technical audit <target>",
        "skills/010-sg-technical/references/technical-audit-playbook.md",
    ),
    "openpostern-security-signal-routing-for-shipglows-skills.md": (
        "$010-sg-technical deps <project>",
        "$010-sg-technical audit <target>",
        "skills/010-sg-technical/references/dependency-audit-playbook.md",
        "skills/010-sg-technical/references/technical-audit-playbook.md",
    ),
    "retire-central-shipglows-data-repository.md": (
        "skills/010-sg-technical/references/dependency-audit-playbook.md",
        "skills/010-sg-technical/references/performance-audit-playbook.md",
        "skills/010-sg-technical/references/technical-audit-playbook.md",
    ),
}


class TechnicalContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.skill = SKILL.read_text(encoding="utf-8")
        cls.router = ROUTER.read_text(encoding="utf-8")
        cls.transfer = TRANSFER.read_text(encoding="utf-8")
        cls.playbooks = {mode: path.read_text(encoding="utf-8") for mode, path in PLAYBOOKS.items()}
        cls.code_index = CODE_INDEX.read_text(encoding="utf-8")
        cls.pack_doc = PACK_DOC.read_text(encoding="utf-8")
        cls.catalog = json.loads(CATALOG.read_text(encoding="utf-8"))

    def test_tech_dispatch_01_exact_compact_grammar(self) -> None:
        self.assertLessEqual(len(self.skill.splitlines()), MAX_ACTIVATION_LINES)
        self.assertIn(
            'argument-hint: "<audit|architecture|deps|performance|migrate|github|sync|access|parity|help> [target]"',
            self.skill,
        )
        for grammar in (
            "`audit [<file|directory|diff|PR|project|global>]`",
            "`architecture [<project|surface|component>]`",
            "`deps [global]`",
            "`performance [<file|project|global>]`",
            "`migrate [package@version]`",
            "`github [audit|reconcile|clean|branches|dependabot|fix] [current repo|workspace]`",
            "`sync [target]`",
            "`access [target]`",
            "`parity [target]`",
            "`help`",
        ):
            self.assertIn(grammar, self.skill)
        for safe_input in ("Bare input", "unknown modes", "materially ambiguous intent", "Never infer from a previous task"):
            self.assertIn(safe_input, self.skill)

    def test_github_hygiene_unifies_pr_branch_and_worktree_lifecycle(self) -> None:
        github = self.playbooks["github"]
        for phrase in (
            "`git` alias",
            "`git worktree list --porcelain`",
            "worktree -> branch -> pull request",
            "`merge-ready`",
            "`reconcile`",
            "`clean`",
            "terminal cleanup disposition",
            "fresh approval",
        ):
            self.assertIn(phrase, github)

    def test_tech_lazy_02_one_playbook_per_mode(self) -> None:
        expected = {
            "audit": "technical-audit-playbook.md",
            "deps": "dependency-audit-playbook.md",
            "performance": "performance-audit-playbook.md",
            "migrate": "migration-playbook.md",
            "github": "github-hygiene-playbook.md",
        }
        for mode, name in expected.items():
            if mode == "audit":
                continue
            line = next(line for line in self.skill.splitlines() if line.startswith(f"- `{mode} "))
            selected = set(re.findall(r"[a-z-]+-playbook\.md", line))
            self.assertEqual(selected, {name}, mode)
            self.assertTrue(PLAYBOOKS[mode].is_file())
        self.assertIn("technical-audit-protocol.md", self.skill)
        for branch in AUDIT_BRANCHES.values():
            self.assertTrue(branch.is_file(), branch)
        self.assertIn("load no substantive playbook", self.skill)
        self.assertIn("exactly one playbook", self.router)
        self.assertIn("missing selected playbook is a visible blocked result", self.skill)

    def test_tech_transfer_05_source_markers_and_depth(self) -> None:
        rows = {
            "401-sg-audit-code": ("audit", "technical-audit-playbook.md"),
            "402-sg-deps": ("deps", "dependency-audit-playbook.md"),
            "403-sg-perf": ("performance", "performance-audit-playbook.md"),
            "404-sg-migrate": ("migrate", "migration-playbook.md"),
        }
        for source, (mode, playbook) in rows.items():
            self.assertRegex(
                self.transfer,
                rf"\| `{source}` \| `{mode}` \| `references/{re.escape(playbook)}` \|",
            )
        markers = {
            "audit": ("workflow integrity", "trust boundaries", "Business metadata", "traffic-first"),
            "deps": ("VULNERABILITY SCAN", "Supply chain checks", "LICENSE COMPLIANCE", "partial proof"),
            "performance": ("BUNDLE & LOADING", "CORE WEB VITALS READINESS", "DATABASE & BACKEND", "unmeasured optimization guess"),
            "migrate": ("Migration Matrix", "distinct apply approval", "Never auto-stash", "incompatible peer/dependent package"),
        }
        audit_text = "\n".join(path.read_text(encoding="utf-8") for path in AUDIT_BRANCHES.values())
        for mode, phrases in markers.items():
            for phrase in phrases:
                self.assertIn(phrase, audit_text if mode == "audit" else self.playbooks[mode], f"{mode}: {phrase}")

    def test_tech_github_09_queue_safety_transfers_from_310(self) -> None:
        github = self.playbooks["github"]
        for phrase in (
            "exactly one final disposition",
            "terminal disposition ledger",
            "item-scoped blocker",
            "continue independent eligible pull requests",
            "Only queue-wide blockers stop the full queue:",
            "until no actionable pull request remains",
            "DEPENDABOT-MIXED-QUEUE-CONTINUES",
            "Never auto-merge major dependency bumps.",
            "Never resolve merge conflicts silently.",
        ):
            self.assertIn(phrase, github)
        for owner in ("010-sg-technical deps", "010-sg-technical migrate", "github:gh-fix-ci"):
            self.assertIn(owner, github)
        for blocker in (
            "GitHub authentication",
            "repository access",
            "operator authorization",
            "reliable refreshed queue truth",
        ):
            self.assertIn(blocker, github)
        for refreshed_state in ("open PR", "check", "base state"):
            self.assertIn(refreshed_state, github)
        self.assertIn("before selecting the next action", github)

    def test_tech_boundary_03_adjacent_owners_stay_independent(self) -> None:
        boundaries = {
            "400-sg-audit": "broad cross-domain audit",
            "105-sg-check": "proportional typecheck",
            "405-sg-prod": "hosted/live deployment",
            "406-sg-seo": "SEO ranking",
            "407-sg-translate": "translation and i18n",
        }
        for owner, purpose in boundaries.items():
            self.assertIn(owner, self.skill)
            self.assertIn(purpose, self.skill)
            self.assertTrue((ROOT / "skills" / owner / "SKILL.md").is_file())
        self.assertIn("single public owner", self.skill)
        self.assertIn("sequence the required internal engines", self.skill)
        for engine in ("600-sg-local-cloud-sync", "601-sg-product-entitlements", "602-sg-platform-parity"):
            self.assertIn(engine, self.skill)

    def test_tech_safety_04_security_and_mutation_stops(self) -> None:
        for phrase in (
            "read-only by default",
            "Findings never grant fix authority",
            "category-level approval",
            "never installs audit tooling",
            "distinct apply approval",
            "Never auto-stash",
            "recoverable rollback path",
            "untrusted evidence",
            "Static or partial evidence never proves code safe",
            "registry credentials",
            "raw private logs",
        ):
            self.assertIn(phrase, self.skill)
        for phrase in ("no audit-tool install without authority", "partial scans never become security sign-off"):
            self.assertIn(phrase, self.transfer)

    def test_tech_safety_04_playbooks_follow_dispatcher_authority(self) -> None:
        audit = "\n".join(path.read_text(encoding="utf-8") for path in AUDIT_BRANCHES.values())
        migration = self.playbooks["migrate"]
        for unsafe_instruction in ("Fix it directly in the code", "Fix all issues in code"):
            self.assertNotIn(unsafe_instruction, audit)
        self.assertIn("exact fix scope is authorized", audit)
        self.assertIn("findings and the proposed remediation only", audit)
        self.assertNotIn("pip install pip-audit", self.playbooks["deps"])
        self.assertIn("report partial proof", self.playbooks["deps"])
        self.assertIn("For authorized fixes, use this priority", self.playbooks["performance"])
        self.assertNotIn("Use Context7 as primary source", migration)
        self.assertIn("discovery and corroboration only", migration)
        self.assertIn("explicitly approved apply phase", migration)

    def test_tech_public_08_single_public_page_and_related_routes(self) -> None:
        if PUBLIC_DIR is None:
            self.skipTest("optional shipglows-site checkout is not available")
        self.assertTrue((PUBLIC_DIR / "sg-technical.md").is_file())
        public = (PUBLIC_DIR / "sg-technical.md").read_text(encoding="utf-8")
        for mode in ("audit", "deps", "performance", "migrate", "github"):
            self.assertIn(f"/010-sg-technical {mode}", public)
        for retired in ("sg-audit-code.md", "sg-deps.md", "sg-perf.md", "sg-migrate.md"):
            self.assertFalse((PUBLIC_DIR / retired).exists(), retired)
        for related in ("sg-audit.md", "sg-check.md", "sg-maintain.md", "sg-github-hygiene.md", "sg-prod.md", "sg-seo.md"):
            self.assertIn("sg-technical", (PUBLIC_DIR / related).read_text(encoding="utf-8"), related)

    def test_tech_mechanical_07_code_index_and_catalog(self) -> None:
        self.assertIn("| `010` | `sg-technical` | `010-sg-technical` | Audit/technical/source |", self.code_index)
        for predecessor in PREDECESSORS:
            self.assertNotIn(f"| `{predecessor.split('-', 1)[0]}` |", self.code_index)
        quality = next(pack for pack in self.catalog["packs"] if pack["id"] == "shipglows-quality")
        self.assertEqual(quality["skills"], ["400-sg-audit", "010-sg-technical", "407-sg-translate"])
        self.assertIn("010-sg-technical", self.pack_doc)
        for predecessor in PREDECESSORS:
            self.assertNotIn(predecessor, self.pack_doc)

    def test_tech_active_06_no_predecessor_identity_on_active_surfaces(self) -> None:
        files = [
            ROOT / "cli" / "lib.sh",
            ROOT / "skills" / "002-sg-maintain" / "SKILL.md",
            ROOT / "skills" / "103-sg-verify" / "references" / "verification-gates.md",
            ROOT / "skills" / "105-sg-check" / "SKILL.md",
            ROOT / "skills" / "302-sg-help" / "references" / "help-catalog.md",
            ROOT / "skills" / "010-sg-technical" / "references" / "github-hygiene-playbook.md",
            ROOT / "skills" / "400-sg-audit" / "SKILL.md",
            ROOT / "skills" / "400-sg-audit" / "references" / "audit-master-workflow.md",
            ROOT / "shipglows_data" / "technical" / "operator-guides" / "skill-launch-cheatsheet.md",
            ROOT / "shipglows_data" / "technical" / "skill-runtime-and-lifecycle.md",
        ]
        if PUBLIC_DIR is not None:
            files.extend(path for path in PUBLIC_DIR.glob("*.md"))
        for path in files:
            text = path.read_text(encoding="utf-8")
            for predecessor in PREDECESSORS:
                self.assertNotIn(predecessor, text, f"{path}: {predecessor}")
            for public_name in ("sg-audit-code", "sg-deps", "sg-perf", "sg-migrate"):
                self.assertNotIn(public_name, text, f"{path}: {public_name}")

    def test_tech_active_06_specs_reject_unallowlisted_predecessor_instructions(self) -> None:
        spec_paths = tuple(sorted(SPECS_DIR.glob("*.md"), key=lambda path: path.name))
        self.assertTrue(spec_paths, SPECS_DIR)

        allowed_lines_seen = set()
        violations = []
        for path in spec_paths:
            allowed = SPEC_PREDECESSOR_LINE_ALLOWLIST.get(path.name, frozenset())
            for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
                if not PREDECESSOR_PATTERN.search(line):
                    continue
                normalized = line.strip()
                if normalized in allowed:
                    allowed_lines_seen.add((path.name, normalized))
                else:
                    violations.append(f"{path.relative_to(ROOT)}:{line_number}: {normalized}")

        expected_allowlist = {
            (filename, line)
            for filename, lines in SPEC_PREDECESSOR_LINE_ALLOWLIST.items()
            for line in lines
        }
        self.assertEqual(allowed_lines_seen, expected_allowlist, "stale or unreviewed spec predecessor allowlist")
        self.assertEqual(violations, [], "active predecessor instruction(s) found:\n" + "\n".join(violations))

    def test_tech_active_06_pattern_covers_numbered_and_unprefixed_variants(self) -> None:
        for predecessor in PREDECESSORS:
            public_name = predecessor.split("-", 1)[1]
            for variant in (
                predecessor,
                f"/{predecessor}",
                f"skills/{predecessor}/SKILL.md",
                f"${predecessor} global",
                public_name,
                f"/{public_name}",
                f"skills/{public_name}/SKILL.md",
                f"${public_name} global",
            ):
                with self.subTest(variant=variant):
                    self.assertIsNotNone(PREDECESSOR_PATTERN.search(variant))
        for current_name in ("010-sg-technical", "/010-sg-technical deps", "skills/010-sg-technical/SKILL.md"):
            with self.subTest(current_name=current_name):
                self.assertIsNone(PREDECESSOR_PATTERN.search(current_name))

    def test_tech_active_06_corrected_specs_use_exact_010_routes(self) -> None:
        scanned_names = {path.name for path in SPECS_DIR.glob("*.md")}
        self.assertTrue(MIGRATED_ACTIVE_SPEC_PROOF.keys() <= scanned_names)
        for filename, expected_routes in MIGRATED_ACTIVE_SPEC_PROOF.items():
            text = (SPECS_DIR / filename).read_text(encoding="utf-8")
            with self.subTest(spec=filename):
                for route in expected_routes:
                    self.assertIn(route, text)
                unexpected = [
                    f"{line_number}: {line.strip()}"
                    for line_number, line in enumerate(text.splitlines(), start=1)
                    if PREDECESSOR_PATTERN.search(line)
                    and line.strip() not in SPEC_PREDECESSOR_LINE_ALLOWLIST.get(filename, frozenset())
                ]
                self.assertEqual(unexpected, [])

    def test_tech_runtime_09_sources_and_runtime_aliases_absent(self) -> None:
        self.assertTrue((ROOT / "skills" / "010-sg-technical" / "SKILL.md").is_file())
        for predecessor in PREDECESSORS:
            source = ROOT / "skills" / predecessor
            self.assertFalse(source.exists() or source.is_symlink(), predecessor)
        # Runtime installation is optional and user-local. Sync-helper tests
        # cover it with isolated target homes; this source contract must not
        # depend on the invoking user's home state.

    def test_no_extra_substantive_playbooks(self) -> None:
        actual = {path.name for path in (SKILL.parent / "references").glob("*-playbook.md")}
        self.assertEqual(actual, PLAYBOOK_NAMES)


if __name__ == "__main__":
    unittest.main()
