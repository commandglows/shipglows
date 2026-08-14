#!/usr/bin/env python3
"""Detect likely design-system drift from hardcoded visual values.

The check is intentionally conservative. It is strongest when used with
``--changed`` after UI edits, where new literals are usually actionable drift.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


SOURCE_DIRS = ("src", "app", "pages", "components", "lib")
DEFAULT_CONFIG = Path(".shipglows/design-system-drift.json")
EXCLUDED_PARTS = {
    ".git",
    ".next",
    ".nuxt",
    ".svelte-kit",
    ".tauri",
    ".astro",
    "build",
    "coverage",
    "dist",
    "node_modules",
    "test-results",
    "target",
}
EXTENSIONS = {
    ".astro",
    ".css",
    ".dart",
    ".html",
    ".java",
    ".jsx",
    ".kt",
    ".scss",
    ".svelte",
    ".ts",
    ".tsx",
    ".vue",
    ".xml",
}
TOKEN_SOURCE_HINTS = (
    "token",
    "theme",
    "design-token",
    "variables",
    "palette",
    "color",
    "typography",
    "spacing",
    "radius",
    "shadow",
    "motion",
)
TOKEN_USAGE_HINTS = (
    "var(--",
    "theme(",
    "tokens.",
    "token.",
    "designTokens",
    "Theme.of(",
    "context.theme",
    "ColorScheme",
    "TextTheme",
)


@dataclass(frozen=True)
class Pattern:
    name: str
    regex: re.Pattern[str]


PATTERNS = (
    Pattern(
        "hardcoded color",
        re.compile(
            r"(#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(|\boklch\(|\bColor\(0x[0-9a-fA-F]{6,8}\)|\bColors\.[A-Za-z])"
        ),
    ),
    Pattern(
        "hardcoded CSS dimension",
        re.compile(
            r"\b(font-size|line-height|letter-spacing|gap|row-gap|column-gap|padding|padding-[a-z]+|margin|margin-[a-z]+|inset|top|right|bottom|left|width|height|min-width|max-width|min-height|max-height|border-radius|z-index)\s*:\s*-?(?!0(?:[;,\s)]|px|rem|em|%))[0-9]+(?:\.[0-9]+)?(?:px|rem|em|vh|vw|dvh|svh|lvh|%)?"
        ),
    ),
    Pattern(
        "hardcoded JS/RN/Flutter style value",
        re.compile(
            r"\b(fontSize|lineHeight|letterSpacing|gap|padding|padding[A-Z][A-Za-z]*|margin|margin[A-Z][A-Za-z]*|borderRadius|elevation|shadowRadius|shadowOpacity|zIndex|height|width|top|right|bottom|left|inset)\s*[:=]\s*-?(?!0(?:[;,\s})]))[0-9]+(?:\.[0-9]+)?"
        ),
    ),
    Pattern(
        "hardcoded shadow",
        re.compile(r"\bbox-shadow\s*:\s*(?!var\()[^;]+"),
    ),
    Pattern(
        "hardcoded motion",
        re.compile(r"\b(transition|animation)(?:-[a-z-]+)?\s*:\s*(?!var\()[^;]*(?:\d+ms|\d+\.\d+s|\d+s)"),
    ),
    Pattern(
        "Tailwind arbitrary visual utility",
        re.compile(
            r"\b(?:bg|text|border|shadow|rounded|p|px|py|pt|pr|pb|pl|m|mx|my|mt|mr|mb|ml|gap|top|right|bottom|left|inset|w|h|min-w|max-w|min-h|max-h|z)-\[[^\]]+\]"
        ),
    ),
)


@dataclass
class Finding:
    path: Path
    line_no: int
    kind: str
    line: str
    classification: str = "defect"
    reason: str = ""


@dataclass(frozen=True)
class ClassificationRule:
    classification: str
    paths: tuple[str, ...]
    kinds: tuple[str, ...]
    pattern: re.Pattern[str] | None
    reason: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="Project root to scan.")
    parser.add_argument(
        "--config",
        help=(
            "Project-owned JSON classification config. Defaults to "
            ".shipglows/design-system-drift.json when that file exists."
        ),
    )
    parser.add_argument(
        "--changed",
        action="store_true",
        help="Scan git changed and untracked files only.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "markdown"),
        default="text",
        help="Output format.",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Exit 0 even when findings are reported.",
    )
    parser.add_argument(
        "--max-findings",
        type=int,
        default=120,
        help="Maximum findings to print. Defaults to 120.",
    )
    return parser.parse_args()


def load_classification_rules(root: Path, configured: str | None) -> list[ClassificationRule]:
    config_path = Path(configured) if configured else root / DEFAULT_CONFIG
    if configured and not config_path.is_absolute():
        config_path = root / config_path
    if not config_path.exists():
        if configured:
            raise ValueError(f"classification config does not exist: {config_path}")
        return []

    try:
        payload = json.loads(config_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read classification config {config_path}: {error}") from error
    if not isinstance(payload, dict) or not isinstance(payload.get("rules", []), list):
        raise ValueError("classification config must be an object with a 'rules' array")

    rules: list[ClassificationRule] = []
    for index, raw in enumerate(payload.get("rules", []), start=1):
        if not isinstance(raw, dict):
            raise ValueError(f"classification rule {index} must be an object")
        classification = raw.get("classification")
        if classification not in {"accepted-exception", "brand-data"}:
            raise ValueError(
                f"classification rule {index} must use accepted-exception or brand-data"
            )
        paths = raw.get("paths")
        reason = raw.get("reason")
        kinds = raw.get("kinds", [])
        if not isinstance(paths, list) or not paths or not all(isinstance(p, str) for p in paths):
            raise ValueError(f"classification rule {index} requires a non-empty string paths array")
        if not isinstance(kinds, list) or not all(isinstance(kind, str) for kind in kinds):
            raise ValueError(f"classification rule {index} kinds must be a string array")
        if not isinstance(reason, str) or not reason.strip():
            raise ValueError(f"classification rule {index} requires a reason")
        try:
            pattern = re.compile(raw["pattern"]) if "pattern" in raw else None
        except (TypeError, re.error) as error:
            raise ValueError(f"classification rule {index} has an invalid pattern: {error}") from error
        rules.append(
            ClassificationRule(
                classification, tuple(paths), tuple(kinds), pattern, reason.strip()
            )
        )
    return rules


def run_git(root: Path, args: list[str]) -> list[str]:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=root,
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
    except (OSError, subprocess.CalledProcessError):
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def is_excluded(path: Path) -> bool:
    return any(part in EXCLUDED_PARTS for part in path.parts)


def is_probable_token_source(path: Path) -> bool:
    lowered = str(path).lower()
    return any(hint in lowered for hint in TOKEN_SOURCE_HINTS)


def has_token_usage(line: str) -> bool:
    return any(hint in line for hint in TOKEN_USAGE_HINTS)


def candidate_files(root: Path, changed: bool) -> list[Path]:
    if changed:
        names = set(run_git(root, ["diff", "--name-only", "--diff-filter=ACMR", "HEAD"]))
        names.update(run_git(root, ["ls-files", "--others", "--exclude-standard"]))
        files = [root / name for name in sorted(names)]
    else:
        roots = [root / item for item in SOURCE_DIRS if (root / item).exists()]
        roots.extend(
            path
            for path in root.glob("*/src")
            if path.is_dir() and not is_excluded(path.relative_to(root))
        )
        roots.extend(
            path
            for path in root.rglob("src/main")
            if path.is_dir()
            and "android" in path.parts
            and not is_excluded(path.relative_to(root))
        )
        if not roots:
            roots = [root]
        files = []
        for source_root in dict.fromkeys(roots):
            files.extend(path for path in source_root.rglob("*") if path.is_file())

    return [
        path
        for path in files
        if path.exists()
        and path.is_file()
        and path.suffix in EXTENSIONS
        and not is_excluded(path.relative_to(root) if path.is_relative_to(root) else path)
    ]


def classify_finding(finding: Finding, rules: list[ClassificationRule]) -> Finding:
    path = finding.path.as_posix()
    for rule in rules:
        if not any(fnmatch.fnmatchcase(path, glob) for glob in rule.paths):
            continue
        if rule.kinds and finding.kind not in rule.kinds:
            continue
        if rule.pattern and not rule.pattern.search(finding.line):
            continue
        finding.classification = rule.classification
        finding.reason = rule.reason
        break
    return finding


def should_skip_line(path: Path, line: str) -> bool:
    stripped = line.strip()
    if not stripped or stripped.startswith(("//", "/*", "*", "<!--")):
        return True
    if stripped.startswith("--") and ":" in stripped:
        return True
    if is_probable_token_source(path):
        return True
    if has_token_usage(line):
        return True
    return False


def scan_file(root: Path, path: Path) -> list[Finding]:
    findings: list[Finding] = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        return findings

    rel = path.relative_to(root) if path.is_relative_to(root) else path
    for line_no, line in enumerate(lines, start=1):
        if should_skip_line(rel, line):
            continue
        for pattern in PATTERNS:
            if pattern.regex.search(line):
                findings.append(Finding(rel, line_no, pattern.name, line.strip()))
                break
    return findings


def render(findings: list[Finding], files: list[Path], fmt: str, max_findings: int) -> None:
    counts = {
        classification: sum(f.classification == classification for f in findings)
        for classification in ("defect", "accepted-exception", "brand-data")
    }
    if fmt == "markdown":
        print("# Design-System Drift Check")
        print()
        print(f"- Files scanned: {len(files)}")
        print(f"- Findings: {len(findings)}")
        print(f"- Defects: {counts['defect']}")
        print(f"- Accepted exceptions: {counts['accepted-exception']}")
        print(f"- Brand data: {counts['brand-data']}")
        if not findings:
            print("- Result: pass")
            return
        print("- Result: " + ("defects found" if counts["defect"] else "pass with classified findings"))
        print()
        print("| File | Line | Classification | Kind | Evidence | Reason |")
        print("| --- | ---: | --- | --- | --- | --- |")
        for finding in findings[:max_findings]:
            evidence = finding.line.replace("|", "\\|")
            reason = finding.reason.replace("|", "\\|")
            print(
                f"| `{finding.path}` | {finding.line_no} | {finding.classification} | "
                f"{finding.kind} | `{evidence}` | {reason} |"
            )
        if len(findings) > max_findings:
            print()
            print(f"Only first {max_findings} findings shown.")
        return

    print("Design-system drift check")
    print(f"Files scanned: {len(files)}")
    print(f"Findings: {len(findings)}")
    print(f"Defects: {counts['defect']}")
    print(f"Accepted exceptions: {counts['accepted-exception']}")
    print(f"Brand data: {counts['brand-data']}")
    for finding in findings[:max_findings]:
        reason = f" ({finding.reason})" if finding.reason else ""
        print(
            f"{finding.path}:{finding.line_no}: {finding.classification}: "
            f"{finding.kind}: {finding.line}{reason}"
        )
    if len(findings) > max_findings:
        print(f"Only first {max_findings} findings shown.")


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    try:
        rules = load_classification_rules(root, args.config)
    except ValueError as error:
        print(f"design-system drift config error: {error}", file=sys.stderr)
        return 2
    files = candidate_files(root, args.changed)
    findings: list[Finding] = []
    for path in files:
        findings.extend(classify_finding(finding, rules) for finding in scan_file(root, path))

    render(findings, files, args.format, args.max_findings)
    if any(finding.classification == "defect" for finding in findings) and not args.warn_only:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
