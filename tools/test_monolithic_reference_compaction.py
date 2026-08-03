#!/usr/bin/env python3
"""Scenario-first proof for bounded reference loading."""
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    value = ROOT / path
    assert value.is_file(), f"missing: {path}"
    return value.read_text(encoding="utf-8")


def require(owner: str, *resources: str) -> None:
    text = read(owner)
    for resource in resources:
        assert resource in text, f"{owner} does not route {resource}"
        read(str(Path(owner).parent / "references" / resource))


def main() -> None:
    # Overlay: contract and framework/proof branches are independently loadable.
    require("skills/008-sg-customer/SKILL.md", "onboarding-overlay-contract.md", "onboarding-overlay-vue.md", "onboarding-overlay-flutter.md", "onboarding-overlay-proof-and-copy.md")
    assert "Completed always wins over current" in read("skills/008-sg-customer/references/onboarding-overlay-contract.md")

    # Technical target routes do not require the former multipurpose body.
    require("skills/010-sg-technical/SKILL.md", "technical-audit-protocol.md", "technical-file-audit.md", "technical-project-audit.md", "technical-global-audit.md")
    assert "read-only" in read("skills/010-sg-technical/references/technical-file-audit.md")

    # Help routes a question class rather than loading taxonomy and cycles together.
    require("skills/302-sg-help/SKILL.md", "help-skill-discovery.md", "help-workflow-recipes.md", "help-quick-answers.md")
    assert "skill-code-index.md" in read("skills/302-sg-help/references/help-skill-discovery.md")

    # Init isolates configuration mutation from the other bootstrap operations.
    require("skills/305-sg-init/SKILL.md", "bootstrap-entrypoint-and-dev-mode.md", "bootstrap-trackers-and-report.md", "bootstrap-context-contract.md", "bootstrap-mcp-setup.md", "bootstrap-governance-corpus.md")
    assert "explicit MCP/server setup request" in read("skills/305-sg-init/references/bootstrap-mcp-setup.md")

    # SEO audit stays read-only; only the explicit fix mode has mutation authority.
    require("skills/406-sg-seo/SKILL.md", "seo-audit-protocol.md", "seo-page-audit.md", "seo-project-audit.md", "seo-global-audit.md", "seo-ai-visibility-review.md")
    seo = "\n".join(read(f"skills/406-sg-seo/references/{name}") for name in ("seo-audit-workflow.md", "seo-audit-protocol.md", "seo-page-audit.md", "seo-project-audit.md", "seo-global-audit.md"))
    assert "Fix it directly" not in seo and "Fix all issues in code" not in seo
    assert "read-only" in seo

    # Design gets only the sync UI contract, not merge/queue authority.
    design = read("skills/006-sg-design/SKILL.md")
    assert "sync-guidance-overlay-ui.md" in design
    require("skills/600-sg-local-cloud-sync/SKILL.md", "sync-guidance-overlay-ui.md", "post-auth-sync-orchestration.md", "sync-queue-and-payload-safety.md", "sync-guidance-proof-and-docs.md")
    assert "different remembered account" in read("skills/600-sg-local-cloud-sync/references/post-auth-sync-orchestration.md")
    print("PASS: bounded reference-loading scenarios")


if __name__ == "__main__":
    main()
