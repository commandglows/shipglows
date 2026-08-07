#!/usr/bin/env python3
"""Classify ShipGlows conversation transcripts into deterministic audit findings."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any


UNSAFE_PATTERNS = (
    re.compile(r"\b(?:sk_live_|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9a-zA-Z-]{10,})"),
    re.compile(r"\b(?:https?://)?(?:localhost|127\.0\.0\.1)(:\d+)?\b", re.IGNORECASE),
    re.compile(r"\bpassword\s*[:=]\s*\S+", re.IGNORECASE),
    re.compile(r"/home/[^\s]+/"),
)


CATEGORY_RULES = {
    "missed_action": [
        r"\breport(?:ing)?\b.*\binstead of\b.*\bfix",
        r"\brapport(?:e|er|ing)?\b.*\bne corrige\b",
        r"\bI (?:will|would) (?:analyse|diagnose|explain|investigate)\b.*\bbut not\b",
        r"\bcannot (?:fix|patch|edit)\b",
    ],
    "over_reporting": [
        r"\btoo much details?\b",
        r"\bverbose\b",
        r"\bextensive report\b",
        r"\brapport\b.*\bd[ée]taill[ée]\b",
        r"\btant de d[ée]tails\b",
    ],
    "wrong_owner_route": [
        r"\bthis is not.*(sg-|skill)\b",
        r"\broute to\b.*\b(unsupported|wrong|wrongly)\b",
    ],
    "literalism_over_intent": [
        r"\bliteral(?:ly)?\b.*\bcommand\b",
        r"\bfollow the prompt\b",
        r"\bexactly as written\b",
        r"\bexactement comme [ée]crit\b",
    ],
    "proof_gap": [
        r"\bno evidence\b",
        r"\bcannot verify\b",
        r"\bwithout proof\b",
    ],
    "stale_skill_contract": [
        r"\balready known\b.*\blegacy\b",
        r"\boutdated\b.*\bcontract\b",
    ],
    "bad_question": [
        r"\bwhy\b.*\bso many\b",
        r"\bpourquoi\b.*\btant de\b",
        r"\bdo we?\s*$",
        r"\bshould I.*\b",
    ],
    "user_friction": [
        r"\btoo long\b.*\bresponse\b",
        r"\bagain\b.*\bignore\b",
        r"\bnot helpful\b",
        r"\bslowing down\b",
    ],
    "unsafe_ship_or_dirty_scope": [
        r"\bprivate\b.*\blogs?\b",
        r"\blogs?\b.*\bprivate\b",
        r"\braw logs\b",
    ],
    "weak_follow_through": [
        r"\blet's defer\b",
        r"\bwe'll do this later\b",
        r"\bTODO\b",
    ],
}

CATEGORY_RE = {name: re.compile("|".join(patterns), re.IGNORECASE) for name, patterns in CATEGORY_RULES.items()}

OWNER_BY_CATEGORY = {
    "missed_action": "sg-build",
    "over_reporting": "sg-build",
    "wrong_owner_route": "sg-build",
    "literalism_over_intent": "sg-build",
    "proof_gap": "sg-verify",
    "stale_skill_contract": "sg-spec",
    "bad_question": "sg-build",
    "user_friction": "sg-build",
    "unsafe_ship_or_dirty_scope": "sg-spec",
    "weak_follow_through": "sg-build",
    "false_agents_receipt": "sg-verify",
    "missed_delegation": "sg-build",
}

EXPLICIT_DELEGATION_RE = re.compile(
    r"\b(?:subagents?|sub-agents?|agents?\s+(?:en\s+)?parall[eè]le|parallel\s+agents?|"
    r"d[ée]l[ée]gu(?:e|er|ation)|delegate|fan[- ]?out)\b",
    re.IGNORECASE,
)
EXECUTABLE_RESULT_RE = re.compile(
    r"\b(?:impl[ée]ment[ée]|termin[ée]|completed?|done|tests?\s+(?:pass|ok)|"
    r"v[ée]rifi[ée]|corrig[ée]|patched?|livr[ée])\b",
    re.IGNORECASE,
)
DEGRADED_RE = re.compile(
    r"\b(?:degraded|d[ée]grad[ée]|delegation\s+(?:unavailable|impossible)|"
    r"agents?\s+(?:unavailable|indisponible))\b",
    re.IGNORECASE,
)
AGENTS_RECEIPT_RE = re.compile(r"\bAgents:\s*(\d+)\b", re.IGNORECASE)


@dataclass
class Finding:
    category: str
    match: str
    excerpt: str

    def as_dict(self) -> dict[str, str]:
        return {
            "category": self.category,
            "match": self.match,
            "excerpt": self.excerpt,
        }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="Markdown transcript path")
    parser.add_argument("--fixtures", action="store_true", help="Emit normalized fixtures for deterministic tests")
    parser.add_argument("--raw", action="store_true", help="Classify the raw transcript without terminal-noise filtering")
    parser.add_argument(
        "--trace",
        metavar="ROLLOUT_JSONL",
        help="Explicit rollout JSONL used to verify delegation receipts (never auto-discovered)",
    )
    return parser.parse_args()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def is_unsafe(text: str) -> bool:
    return any(pattern.search(text) for pattern in UNSAFE_PATTERNS)


def is_terminal_noise_line(line: str) -> bool:
    stripped = line.strip()
    if not stripped:
        return False

    # Metadata and wrappers added by tmux capture are evidence context, not
    # user/agent behavior.
    if stripped.startswith(("# ", "- Captured at:", "- tmux ", "~~~")):
        return True

    # Diff, patch, and line-numbered command output are frequent false-positive
    # sources because they include questions, TODO searches, and copied reports.
    if re.match(r"^(diff --git|index [0-9a-f]|@@\s|[+-]{3}\s|[+-]\s)", stripped):
        return True
    if re.match(r"^\d+\s+[+-]", stripped):
        return True

    # Common Codex terminal summaries: "Search TODO|...", "└ Search ...",
    # "Read ...", "List ...". These are not conversational turns.
    if re.match(r"^(└\s*)?(Search|Read|List|Bash|Grep|Glob|Edit|Patch)\b", stripped):
        return True
    if re.search(r"\bSearch\b.*(TODO|TBD|placeholder|rg|\|)", stripped):
        return True

    # JSON/tool payload lines from previous classifier runs should not become
    # evidence for the next classifier pass.
    if re.match(r'^[{}\[\],]$', stripped):
        return True
    if re.match(r'^"[A-Za-z_]+":', stripped):
        return True

    return False


def cleaned_classifier_text(text: str) -> str:
    kept: list[str] = []
    in_fence = False
    for line in text.splitlines():
        stripped = line.strip()
        if re.fullmatch(r"~{3,}", stripped):
            in_fence = not in_fence
            continue
        if is_terminal_noise_line(line):
            continue
        # Preserve actual conversation turns even when they were inside the raw
        # captured pane fence; only the obvious terminal noise is removed.
        kept.append(line)
    return "\n".join(kept).strip()


def classify(text: str) -> list[Finding]:
    findings: list[Finding] = []
    for category, regex in CATEGORY_RE.items():
        match = regex.search(text)
        if not match:
            continue
        excerpt_start = max(0, match.start() - 36)
        excerpt_end = min(len(text), match.end() + 36)
        findings.append(
            Finding(
                category=category,
                match=match.group(0),
                excerpt=text[excerpt_start:excerpt_end].replace("\n", " ").strip(),
            )
        )
    return findings


@dataclass
class ConversationTurn:
    turn_id: str
    user: str
    assistant: str


def extract_turns(text: str) -> list[ConversationTurn]:
    """Extract deliberately labelled turns; ambiguity must remain unverifiable."""
    header = re.compile(r"^##\s+Turn\s+([^\s]+)\s*$", re.IGNORECASE | re.MULTILINE)
    matches = list(header.finditer(text))
    turns: list[ConversationTurn] = []
    for index, match in enumerate(matches):
        body_end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        body = text[match.end():body_end]
        parts = re.split(r"^(User|Assistant):\s*$", body, flags=re.IGNORECASE | re.MULTILINE)
        fields: dict[str, str] = {}
        for offset in range(1, len(parts) - 1, 2):
            fields[parts[offset].lower()] = parts[offset + 1].strip()
        if "user" in fields and "assistant" in fields:
            turns.append(ConversationTurn(match.group(1), fields["user"], fields["assistant"]))
    return turns


def read_trace(path: Path) -> tuple[list[dict[str, Any]], list[str]]:
    events: list[dict[str, Any]] = []
    errors: list[str] = []
    for line_number, line in enumerate(read_text(path).splitlines(), start=1):
        if not line.strip():
            continue
        try:
            item = json.loads(line)
        except json.JSONDecodeError:
            errors.append(f"malformed-json-line:{line_number}")
            continue
        if not isinstance(item, dict):
            errors.append(f"non-object-line:{line_number}")
            continue
        events.append(item)
    return events, errors


def delegation_trace_analysis(text: str, trace_path: Path | None) -> dict[str, Any]:
    """Return a conservative tri-state result: verified, finding, or unverifiable."""
    base: dict[str, Any] = {
        "status": "unverifiable",
        "trace_supplied": trace_path is not None,
        "trace_complete": False,
        "correlated_turn_count": 0,
        "reasons": [],
        "findings": [],
    }
    if trace_path is None:
        base["reasons"] = ["no-explicit-trace"]
        return base
    if not trace_path.exists():
        base["reasons"] = ["missing-trace-path"]
        return base

    events, errors = read_trace(trace_path)
    if errors:
        base["reasons"] = errors
        return base
    completion_events = [
        event for event in events
        if event.get("trace_complete") is True
        or (event.get("event") == "trace_complete" and event.get("complete") is True)
    ]
    trace_complete = bool(completion_events)
    base["trace_complete"] = trace_complete
    if not trace_complete:
        base["reasons"] = ["incomplete-trace"]
        return base

    turns = extract_turns(text)
    trace_turn_ids = {str(event["turn_id"]) for event in events if event.get("turn_id") is not None}
    correlated = [turn for turn in turns if turn.turn_id in trace_turn_ids]
    base["correlated_turn_count"] = len(correlated)
    if not correlated:
        base["reasons"] = ["no-unambiguous-turn-correlation"]
        return base

    trace_findings: list[Finding] = []
    for turn in correlated:
        turn_events = [event for event in events if str(event.get("turn_id")) == turn.turn_id]
        turn_completion = next(
            (
                event for event in turn_events
                if event.get("trace_complete") is True
                or (event.get("event") == "trace_complete" and event.get("complete") is True)
            ),
            None,
        )
        orchestrator_id = turn_completion.get("orchestrator_id") if turn_completion else None
        if not orchestrator_id:
            base["status"] = "unverifiable"
            base["reasons"] = [f"turn-{turn.turn_id}:missing-signing-orchestrator"]
            base["findings"] = []
            return base
        direct_spawn_events = [
            event for event in turn_events
            if event.get("event") in {"spawn_agent", "agent_spawn"}
            and event.get("parent_agent_id") == orchestrator_id
        ]
        # A call without a correlated output cannot prove success or failure.
        if any(
            event.get("output_correlated") is not True or not event.get("task_name")
            for event in direct_spawn_events
        ):
            base["status"] = "unverifiable"
            base["reasons"] = [f"turn-{turn.turn_id}:uncorrelated-spawn-output"]
            base["findings"] = []
            return base
        successful_task_names = {
            str(event["task_name"])
            for event in direct_spawn_events
            if event.get("status") in {"success", "succeeded", "completed"}
            and event.get("task_name")
        }
        successful_spawns = len(successful_task_names)
        receipt = AGENTS_RECEIPT_RE.search(turn.assistant)
        if receipt and int(receipt.group(1)) != successful_spawns:
            trace_findings.append(Finding(
                "false_agents_receipt",
                receipt.group(0),
                f"turn {turn.turn_id}: receipt={receipt.group(1)}, successful_spawns={successful_spawns}",
            ))
        if (
            EXPLICIT_DELEGATION_RE.search(turn.user)
            and EXECUTABLE_RESULT_RE.search(turn.assistant)
            and successful_spawns == 0
            and not DEGRADED_RE.search(turn.assistant)
        ):
            trace_findings.append(Finding(
                "missed_delegation",
                "explicit delegation request with zero successful spawns",
                f"turn {turn.turn_id}: executable result reported without delegation or degradation",
            ))

    base["findings"] = [finding.as_dict() for finding in trace_findings]
    base["status"] = "finding" if trace_findings else "verified"
    return base


def main() -> int:
    args = parse_args()
    path = Path(args.path)
    if not path.exists():
        print(f"missing-path: {path}")
        return 2

    text = read_text(path)
    classifier_text = text if args.raw else cleaned_classifier_text(text)
    findings = classify(classifier_text)
    unsafe = is_unsafe(text)
    trace_analysis = delegation_trace_analysis(text, Path(args.trace) if args.trace else None)
    trace_findings = [Finding(**item) for item in trace_analysis["findings"]]
    findings.extend(trace_findings)

    payload: dict[str, Any] = {
        "path": str(path),
        "unsafe_detected": unsafe,
        "cleaned_input_used": not args.raw,
        "raw_line_count": len(text.splitlines()),
        "cleaned_line_count": len(classifier_text.splitlines()) if classifier_text else 0,
        "cleaned_input_empty": not bool(classifier_text),
        "finding_count": len(findings),
        "findings": [f.as_dict() for f in findings],
        "categories": sorted({f.category for f in findings}),
        "owner_routes": sorted({OWNER_BY_CATEGORY[f.category] for f in findings}) or ["sg-verify"],
        "delegation_trace": trace_analysis,
    }

    if args.fixtures:
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        if args.trace:
            reasons = ", ".join(trace_analysis["reasons"])
            suffix = f" ({reasons})" if reasons else ""
            print(f"Delegation trace: {trace_analysis['status']}{suffix}")
        if payload["unsafe_detected"]:
            print("WARNING: unsafe scope detected; review required before public publication.")
        if payload["cleaned_input_empty"]:
            print("WARNING: cleaned classifier input is empty; no clean audit can be claimed.")
        if payload["findings"]:
            print("Findings:")
            for finding in findings:
                print(f"- {finding.category}: {finding.match}")
            print("Recommended owners:", ", ".join(payload["owner_routes"]))
        else:
            print("No findings detected.")

    return 0 if (findings or unsafe or payload["cleaned_input_empty"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())
