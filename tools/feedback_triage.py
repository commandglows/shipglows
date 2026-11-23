#!/usr/bin/env python3
"""Per-product triage of feedback, feature requests and roadmap votes stored by
``@shipglows/feedback-convex`` in the product's own Convex deployment.

``inbox`` reads one product repository's new private feedback and pending requests,
with roadmap vote counts and suggestions (likely roadmap items, likely duplicates).
``apply`` executes an operator-validated decision file: dry run by default,
``--confirm`` to run. Roadmap items it creates go through the context-history
projection (``visibility: hidden``); public visibility stays ``context_history.py publish``.

Discovery is declarative and never guessed: the backend is the directory of a
``.shipglows.backend.json`` (``provider: convex``) whose ``convex/`` exports
``defineFeedbackFunctions``; Doppler comes from that directory's
``.shipglows.node.json`` / ``.shipglows.flutter.json`` (dev) or an ``ENVIRONMENT.md``
mention ``Doppler `<project>/prd``` (production, only with ``--env prd``). Every call is
``doppler run --project <p> --config <c> --no-fallback -- node <convex cli> run <module>:<fn> <json>``
with the product's installed Convex CLI (``npx convex run``); no secret is read or printed.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any, Iterable, Protocol
import argparse
import json
import re
import shutil
import subprocess
import sys
import unicodedata

_ch = sys.modules.get("tools.context_history") or sys.modules.get("context_history")
if _ch is None:
    try:
        from tools import context_history as _ch
    except ModuleNotFoundError:  # direct ``python tools/...`` execution
        import context_history as _ch  # type: ignore[no-redef]
_pu = sys.modules.get("tools.product_updates") or sys.modules.get("product_updates")
if _pu is None:
    try:
        from tools import product_updates as _pu
    except ModuleNotFoundError:
        import product_updates as _pu  # type: ignore[no-redef]

ContextHistoryError = _ch.ContextHistoryError

INBOX_SCHEMA = "shipglows.feedback-triage-inbox/v1"
DECISIONS_SCHEMA = "shipglows.feedback-triage-decisions/v1"
BACKEND_FILE = ".shipglows.backend.json"
BACKEND_SCHEMA = "shipglows.backend.v1"
RECIPE_FILES = (".shipglows.node.json", ".shipglows.flutter.json")
ENVIRONMENT_DOC = "ENVIRONMENT.md"
ENVS = ("dev", "prd")
PRD_CONFIGS = ("prd", "prod", "production")
SKIPPED_DIRS = {"node_modules", ".git", ".dart_tool", "build", "dist", ".vercel", ".shipglows", "tmp", "_generated"}
DISCOVERY_DEPTH = 2
MAX_DECISIONS = 100
MAX_LIMIT = 200
COUNTS_CHUNK = 200
MAX_JSON_BYTES = 256 * 1024
NOTE_MAX = 500
OPERATOR_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,39}$")
REQUEST_ID_RE = re.compile(r"^[A-Za-z0-9_-]{1,80}$")
FEEDBACK_ID_RE = re.compile(r"^[A-Za-z0-9_-]{1,80}$")
DEFINE_RE = re.compile(r"\bdefineFeedbackFunctions\s*\(")
MODULE_RE = re.compile(r"\bmodule\s*:\s*['\"]([A-Za-z0-9_/]+)['\"]")
DOPPLER_DOC_RE = re.compile(r"Doppler\s+`([a-z0-9_-]+)(?:`\s*/\s*`|\s*/\s*)([a-z0-9_-]+)`", re.IGNORECASE)
CONVEX_HOST_RE = re.compile(r"^https://([a-z0-9]+(?:-[a-z0-9]+)*)\.(?:[a-z0-9-]+\.)?convex\.cloud(?:/|$)")
DEPLOYMENT_RE = re.compile(r"^(dev|prod|preview|local):([a-z0-9]+(?:-[a-z0-9]+)*)$")
FEEDBACK_CLASSIFICATIONS = ("bug", "idea", "question", "praise", "duplicate", "other")
FEEDBACK_STATUSES = ("new", "triaged", "archived")
CREATE_STATUSES = ("considering", "planned", "in_progress")
MATCH_THRESHOLD = 0.3
DUPLICATE_THRESHOLD = 0.6
STOPWORDS = frozenset(
    "a an and are as at be but by for from has have i in is it its me my no not of on or our so "
    "that the this to was we were what when with would you your can could should please app "
    "au aux avec ce ces cette dans de des du elle en est et il je la le les leur ma mais me mes "
    "mon ne nous on ou par pas plus pour qu que qui sa se ses son sur ta te tes ton tu un une vous "
    "y ca ça".split()
)
DEPLOYMENT_PROBE = (
    "const d=(process.env.CONVEX_DEPLOYMENT||'').split('#')[0].trim();"
    "const k=(process.env.CONVEX_DEPLOY_KEY||'').split('|')[0].trim();"
    "process.stdout.write(JSON.stringify({deployment:d||k}))"
)


class TriageError(ContextHistoryError):
    """A deterministic triage failure (discovery, decision file or Convex call)."""


# --------------------------------------------------------------------------- discovery


@dataclass(frozen=True)
class Backend:
    repo_root: Path
    directory: Path
    module: str
    env: str
    doppler_project: str
    doppler_config: str
    expected_deployment: str | None
    convex_cli: Path | None
    declared_from: tuple[str, ...] = field(default_factory=tuple)

    def relative(self, path: Path) -> str:
        try:
            return path.relative_to(self.repo_root).as_posix() or "."
        except ValueError:
            return path.as_posix()

    def view(self) -> dict[str, Any]:
        return {
            "directory": self.relative(self.directory),
            "module": self.module,
            "env": self.env,
            "doppler": {"project": self.doppler_project, "config": self.doppler_config},
            "expectedDeployment": self.expected_deployment,
            "declaredFrom": list(self.declared_from),
        }


def _read_json(path: Path) -> Any:
    if path.is_symlink() or not path.is_file() or path.stat().st_size > MAX_JSON_BYTES:
        raise TriageError(f"{path.name} must be a regular JSON file under {MAX_JSON_BYTES} bytes.")
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise TriageError(f"{path.name} is unreadable JSON.") from error


def _backend_files(root: Path) -> list[Path]:
    found: list[Path] = []
    frontier = [root]
    for depth in range(DISCOVERY_DEPTH + 1):
        following: list[Path] = []
        for directory in frontier:
            candidate = directory / BACKEND_FILE
            if candidate.is_file() and not candidate.is_symlink():
                found.append(candidate)
            if depth == DISCOVERY_DEPTH:
                continue
            try:
                children = sorted(directory.iterdir())
            except OSError:
                continue
            following.extend(
                child for child in children
                if child.is_dir() and not child.is_symlink() and child.name not in SKIPPED_DIRS
                and not child.name.startswith(".")
            )
        frontier = following
    return found


def _feedback_module(directory: Path) -> str | None:
    convex = directory / "convex"
    if not convex.is_dir() or convex.is_symlink():
        return None
    for path in sorted(convex.glob("*.ts")):
        if path.is_symlink() or path.name.endswith(".d.ts") or path.stat().st_size > MAX_JSON_BYTES:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if DEFINE_RE.search(text):
            declared = MODULE_RE.search(text[DEFINE_RE.search(text).start():])
            return declared.group(1) if declared else path.stem
    return None


def _recipe_doppler(directory: Path, root: Path) -> tuple[str, str, str] | None:
    for base in (directory, root):
        for name in RECIPE_FILES:
            path = base / name
            if not path.is_file():
                continue
            recipe = _read_json(path)
            doppler = recipe.get("doppler") if isinstance(recipe, dict) else None
            if isinstance(doppler, dict) and isinstance(doppler.get("project"), str) and isinstance(doppler.get("config"), str):
                return doppler["project"], doppler["config"], path.relative_to(root).as_posix()
    return None


def _documented_doppler(directory: Path, root: Path) -> list[tuple[str, str, str]]:
    mentions: list[tuple[str, str, str]] = []
    for base in dict.fromkeys((directory, root)):
        path = base / ENVIRONMENT_DOC
        if not path.is_file() or path.is_symlink():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for project, config in DOPPLER_DOC_RE.findall(text):
            mentions.append((project.lower(), config.lower(), path.relative_to(root).as_posix()))
    return mentions


def _convex_cli(directory: Path) -> Path | None:
    package = directory / "node_modules" / "convex" / "package.json"
    if not package.is_file():
        return None
    try:
        manifest = json.loads(package.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return None
    binary = manifest.get("bin")
    relative = binary.get("convex") if isinstance(binary, dict) else binary
    if not isinstance(relative, str):
        return None
    cli = (package.parent / relative).resolve()
    return cli if cli.is_file() else None


def discover_backend(project_root: str | Path, env: str = "dev", backend_dir: str | None = None) -> Backend:
    """Resolve the product's feedback backend and its declared Doppler scope; never invent one."""
    if env not in ENVS:
        raise TriageError(f"env must be one of {', '.join(ENVS)}.")
    root = _ch.resolve_project_root(project_root)
    files = _backend_files(root)
    if backend_dir is not None:
        wanted = (root / backend_dir).resolve()
        files = [path for path in files if path.parent.resolve() == wanted]
        if not files:
            raise TriageError(f"No {BACKEND_FILE} in {backend_dir}.")
    candidates: list[tuple[Path, str, dict[str, Any]]] = []
    for path in files:
        declaration = _read_json(path)
        if not isinstance(declaration, dict) or declaration.get("schemaVersion") != BACKEND_SCHEMA:
            continue
        if declaration.get("provider") != "convex":
            continue
        module = _feedback_module(path.parent)
        if module:
            candidates.append((path.parent, module, declaration))
    if not candidates:
        raise TriageError(
            f"No {BACKEND_FILE} with provider convex next to a convex/ directory exporting "
            "defineFeedbackFunctions (@shipglows/feedback-convex is not installed in this repository)."
        )
    if len(candidates) > 1:
        listed = ", ".join(path.relative_to(root).as_posix() for path, _, _ in candidates)
        raise TriageError(f"Several feedback backends are declared ({listed}); choose one with --backend-dir.")
    directory, module, declaration = candidates[0]
    declared = [(directory / BACKEND_FILE).relative_to(root).as_posix()]
    recipe = _recipe_doppler(directory, root)
    documented = _documented_doppler(directory, root)
    if env == "dev":
        if recipe is not None:
            project, config, source = recipe
        else:
            dev = [item for item in documented if item[1] == "dev"]
            if not dev:
                raise TriageError("No declared Doppler dev configuration (recipe doppler block or ENVIRONMENT.md).")
            project, config, source = dev[0]
        url = (declaration.get("readiness") or {}).get("url") if isinstance(declaration.get("readiness"), dict) else None
        match = CONVEX_HOST_RE.match(url) if isinstance(url, str) else None
        expected = match.group(1) if match else None
    else:
        project_hint = recipe[0] if recipe else None
        prd = [
            item for item in documented
            if item[1] in PRD_CONFIGS and (project_hint is None or item[0] == project_hint.lower())
        ]
        if not prd:
            raise TriageError(
                "No declared Doppler production configuration: ENVIRONMENT.md must name `Doppler <project>/prd`."
            )
        project, config, source = prd[0]
        expected = None
    declared.append(source)
    return Backend(
        repo_root=root,
        directory=directory,
        module=module,
        env=env,
        doppler_project=project,
        doppler_config=config,
        expected_deployment=expected,
        convex_cli=_convex_cli(directory),
        declared_from=tuple(declared),
    )


# ------------------------------------------------------------------------------ runner


class ConvexRunner(Protocol):
    def deployment(self) -> str: ...

    def run(self, function: str, args: dict[str, Any]) -> Any: ...


def _redact(text: str) -> str:
    cleaned = text
    for pattern in _ch.SECRET_PATTERNS:
        cleaned = pattern.sub("[redacted]", cleaned)
    cleaned = re.sub(r"\b(?:dev|prod|preview)[:|][A-Za-z0-9_-]+\|[A-Za-z0-9+/=_-]{16,}", "[redacted]", cleaned)
    lines = [line for line in cleaned.strip().splitlines() if line.strip()]
    return " | ".join(lines[-6:])[:600]


def _parse_output(stdout: str) -> Any:
    text = stdout.strip()
    if not text:
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    for index, char in enumerate(text):
        if char in "[{" and (index == 0 or text[index - 1] == "\n"):
            try:
                return json.loads(text[index:])
            except json.JSONDecodeError:
                continue
    raise TriageError("Convex CLI returned output that is not JSON.")


class DopplerConvexRunner:
    """Runs the product's Convex CLI under its declared Doppler scope (values never read here)."""

    def __init__(self, backend: Backend, *, doppler: str | None = None, node: str | None = None, timeout: int = 180):
        self.backend = backend
        self.doppler = doppler or shutil.which("doppler")
        self.node = node or shutil.which("node")
        self.timeout = timeout
        if not self.doppler:
            raise TriageError("The doppler CLI is not available on PATH.")
        if not self.node:
            raise TriageError("node is not available on PATH.")
        if backend.convex_cli is None:
            raise TriageError(
                f"The Convex CLI is not installed in {backend.relative(backend.directory)}; install the backend "
                "dependencies with the project's lockfile manager."
            )

    def _prefix(self) -> list[str]:
        return [
            self.doppler, "run", "--project", self.backend.doppler_project,
            "--config", self.backend.doppler_config, "--no-fallback", "--",
        ]

    def _execute(self, command: list[str], label: str) -> str:
        try:
            result = subprocess.run(
                command, cwd=self.backend.directory, capture_output=True, text=True,
                encoding="utf-8", errors="replace", timeout=self.timeout,
            )
        except (OSError, subprocess.TimeoutExpired) as error:
            raise TriageError(f"{label} could not run: {type(error).__name__}") from error
        if result.returncode != 0:
            raise TriageError(f"{label} failed (exit {result.returncode}): {_redact(result.stderr or result.stdout)}")
        return result.stdout

    def deployment(self) -> str:
        output = self._execute([*self._prefix(), self.node, "-e", DEPLOYMENT_PROBE], "deployment probe")
        try:
            value = json.loads(output.strip() or "{}").get("deployment", "")
        except json.JSONDecodeError as error:
            raise TriageError("deployment probe returned no JSON.") from error
        return value if isinstance(value, str) else ""

    def run(self, function: str, args: dict[str, Any]) -> Any:
        command = [
            *self._prefix(), self.node, str(self.backend.convex_cli), "run",
            f"{self.backend.module}:{function}", json.dumps(args, ensure_ascii=False, separators=(",", ":")),
        ]
        return _parse_output(self._execute(command, f"{self.backend.module}:{function}"))


def check_deployment(backend: Backend, resolved: str) -> str:
    """The deployment the declared Doppler scope selects must match the requested environment."""
    match = DEPLOYMENT_RE.match(resolved or "")
    if not match:
        raise TriageError(
            f"Doppler {backend.doppler_project}/{backend.doppler_config} selects no Convex deployment "
            "(CONVEX_DEPLOYMENT or CONVEX_DEPLOY_KEY)."
        )
    kind, name = match.groups()
    if backend.env == "dev":
        if kind != "dev":
            raise TriageError(f"--env dev resolved to a {kind} deployment ({name}); refusing.")
        if backend.expected_deployment and name != backend.expected_deployment:
            raise TriageError(
                f"Doppler dev selects {name}, but {BACKEND_FILE} declares {backend.expected_deployment}; refusing."
            )
    elif kind != "prod":
        raise TriageError(f"--env prd resolved to a {kind} deployment ({name}); refusing.")
    return f"{kind}:{name}"


# ---------------------------------------------------------------------------- site items


def _sites(root: Path) -> list[Any]:
    config = _pu.load_config(root)
    if config is None:
        return []
    return [site for site in config.sites if _ch.site_declares_package(site.root, _pu.ROADMAP_PACKAGE)]


def roadmap_items(sites: Iterable[Any]) -> dict[str, dict[str, Any]]:
    items: dict[str, dict[str, Any]] = {}
    for site in sites:
        found, _ = _pu._scan_collection(site.root, _pu.ROADMAP_RELATIVE)
        for item_id, by_locale in found.items():
            entry = items.setdefault(item_id, {
                "id": item_id, "site": site.declared, "titles": {}, "summaries": {}, "locales": [],
            })
            for locale, (_, document) in sorted(by_locale.items()):
                entry["locales"].append(locale)
                entry["titles"][locale] = document.scalar("title") or ""
                entry["summaries"][locale] = document.scalar("summary") or ""
                entry.setdefault("status", document.scalar("status"))
                entry.setdefault("visibility", document.scalar("visibility"))
    return items


# --------------------------------------------------------------------------- similarity


def _tokens(text: str) -> set[str]:
    folded = unicodedata.normalize("NFKD", text.casefold())
    folded = "".join(char for char in folded if not unicodedata.combining(char))
    return {word[:6] for word in re.findall(r"[a-z0-9]+", folded) if len(word) > 1 and word not in STOPWORDS}


def similarity(text: str, reference: str) -> float:
    """0..1: how much ``text`` (feedback, request) speaks about ``reference`` (a title)."""
    left, right = _tokens(text), _tokens(reference)
    if not left or not right:
        return 0.0
    common = len(left & right)
    dice = 2 * common / (len(left) + len(right))
    containment = common / len(right) if len(right) >= 2 else 0.0
    sequence = SequenceMatcher(None, " ".join(sorted(left)), " ".join(sorted(right))).ratio()
    return round(max(dice, 0.9 * containment, 0.85 * sequence if len(left) <= 12 else 0.0), 3)


def _item_matches(text: str, items: dict[str, dict[str, Any]], limit: int = 3) -> list[dict[str, Any]]:
    scored: list[tuple[float, str]] = []
    for item_id, item in items.items():
        references = [*item["titles"].values(), item_id.replace("-", " ")]
        score = max(similarity(text, reference) for reference in references if reference)
        if score >= MATCH_THRESHOLD:
            scored.append((score, item_id))
    scored.sort(key=lambda pair: (-pair[0], pair[1]))
    return [{"itemId": item_id, "score": score, "status": items[item_id].get("status")} for score, item_id in scored[:limit]]


def _duplicates(entries: list[dict[str, Any]], text_of: Any) -> list[dict[str, Any]]:
    pairs: list[dict[str, Any]] = []
    for index, first in enumerate(entries):
        for second in entries[index + 1:]:
            left, right = text_of(first), text_of(second)
            if not left or not right:
                continue
            score = max(similarity(left, right), similarity(right, left))
            if score >= DUPLICATE_THRESHOLD:
                pairs.append({"ids": [first["id"], second["id"]], "score": score})
    return sorted(pairs, key=lambda pair: -pair["score"])


# --------------------------------------------------------------------------------- inbox


def _feedback_view(row: dict[str, Any]) -> dict[str, Any]:
    """Drops account keys and signed audio URLs: the agent reads content, not identities."""
    context = row.get("context") if isinstance(row.get("context"), dict) else {}
    view = {
        "id": row.get("id"),
        "product": row.get("product"),
        "kind": row.get("kind"),
        "message": row.get("message"),
        "hasAudio": bool(row.get("audioUrl") or row.get("kind") == "audio"),
        "audioDurationMs": row.get("audioDurationMs"),
        "context": {key: context[key] for key in ("platform", "appVersion", "screen", "locale") if key in context},
        "status": row.get("status"),
        "classification": row.get("classification"),
        "linkedItemId": row.get("linkedItemId"),
        "linkedRequestId": row.get("linkedRequestId"),
        "duplicateOfFeedbackId": row.get("duplicateOfFeedbackId"),
        "createdAt": row.get("createdAt"),
    }
    return {key: value for key, value in view.items() if value is not None}


def _request_view(row: dict[str, Any]) -> dict[str, Any]:
    keys = ("id", "title", "description", "products", "locale", "moderation", "itemId", "possibleDuplicates", "createdAt")
    return {key: row[key] for key in keys if row.get(key) is not None}


def _as_list(value: Any, label: str) -> list[dict[str, Any]]:
    if not isinstance(value, list) or not all(isinstance(row, dict) for row in value):
        raise TriageError(f"{label} returned an unexpected shape.")
    return value


def inbox(
    backend: Backend,
    runner: ConvexRunner,
    *,
    products: Iterable[str] = (),
    limit: int = 50,
    verify_tallies: bool = False,
) -> dict[str, Any]:
    """New feedback, pending requests, vote counts and suggestions of ONE product (read-only)."""
    if not 1 <= limit <= MAX_LIMIT:
        raise TriageError(f"limit must be 1 to {MAX_LIMIT}.")
    deployment = check_deployment(backend, runner.deployment())
    sites = _sites(backend.repo_root)
    keys = list(dict.fromkeys([*products, *(key for site in sites for key in site.products)]))
    if not keys:
        raise TriageError("No product key: declare the site in .shipglows.product-updates.json or pass --product.")
    items = roadmap_items(sites)

    feedback: list[dict[str, Any]] = []
    for key in keys:
        rows = _as_list(runner.run("triageListFeedback", {"status": "new", "product": key, "limit": limit}), "triageListFeedback")
        feedback.extend(_feedback_view(row) for row in rows)
    rows = _as_list(runner.run("triageListRequests", {"moderation": "pending", "limit": limit}), "triageListRequests")
    requests = [
        _request_view(row) for row in rows
        if not isinstance(row.get("products"), list) or set(row["products"]) & set(keys)
    ]

    counts: dict[str, int] = {}
    ids = sorted(items)
    for start in range(0, len(ids), COUNTS_CHUNK):
        answer = runner.run("counts", {"itemIds": ids[start:start + COUNTS_CHUNK]})
        for item_id, value in ((answer or {}).get("counts") or {}).items():
            if isinstance(value, dict) and isinstance(value.get("voteCount"), int):
                counts[item_id] = value["voteCount"]
    roadmap = sorted(
        (
            {
                "id": item_id, "status": item.get("status"), "visibility": item.get("visibility"),
                "title": item["titles"].get("en") or next(iter(item["titles"].values()), ""),
                "votes": counts.get(item_id), "inRegistry": item_id in counts,
            }
            for item_id, item in items.items()
        ),
        key=lambda item: (-(item["votes"] or 0), item["id"]),
    )

    suggestions = {
        "feedback": [
            {"feedbackId": entry["id"], "matchingItems": matches}
            for entry in feedback
            if entry.get("message") and (matches := _item_matches(entry["message"], items))
        ],
        "requests": [
            {
                "requestId": entry["id"],
                "matchingItems": _item_matches(f"{entry.get('title', '')} {entry.get('title', '')} {entry.get('description', '')}", items),
                "declaredDuplicates": entry.get("possibleDuplicates", []),
            }
            for entry in requests
        ],
        "duplicateFeedback": _duplicates(feedback, lambda entry: entry.get("message") or ""),
        "duplicateRequests": _duplicates(requests, lambda entry: entry.get("title") or ""),
    }
    suggestions["requests"] = [entry for entry in suggestions["requests"] if entry["matchingItems"] or entry["declaredDuplicates"]]
    report: dict[str, Any] = {
        "schema": INBOX_SCHEMA,
        "env": backend.env,
        "deployment": deployment,
        "backend": backend.view(),
        "products": keys,
        "sites": [site.declared for site in sites],
        "summary": {
            "newFeedback": len(feedback),
            "pendingRequests": len(requests),
            "roadmapItems": len(roadmap),
            "votes": sum(counts.values()),
        },
        "feedback": feedback,
        "requests": requests,
        "roadmap": roadmap,
        "suggestions": suggestions,
        "nextStep": (
            "Propose decisions to the operator; after explicit validation write a "
            f"{DECISIONS_SCHEMA} file and run `apply --decisions <file>` (dry run), then `--confirm`."
        ),
    }
    if verify_tallies:
        report["tallies"] = runner.run("verifyVoteTallies", {})
    return report


# -------------------------------------------------------------------------------- apply


def _text(value: Any, field_name: str, maximum: int, *, pattern: re.Pattern[str] | None = None) -> str:
    if not isinstance(value, str) or not value.strip() or len(value) > maximum or "\0" in value:
        raise TriageError(f"{field_name} must be a non-empty string of at most {maximum} characters.")
    if pattern is not None and not pattern.fullmatch(value):
        raise TriageError(f"{field_name} has an invalid format.")
    return value


def _slug(value: Any, field_name: str) -> str:
    text = _text(value, field_name, _ch.MAX_ROADMAP_ID)
    if not _ch.UPDATE_SLUG_RE.fullmatch(text):
        raise TriageError(f"{field_name} must be a roadmap item id (lowercase slug).")
    return text


ACTION_FIELDS: dict[str, tuple[set[str], set[str]]] = {
    # action: (required, optional)
    "create-item": ({"id", "status", "title", "summary"}, set()),
    "approve-request": ({"requestId", "itemId"}, {"note"}),
    "merge-request": ({"requestId"}, {"itemId", "intoRequestId", "note"}),
    "reject-request": ({"requestId"}, {"note"}),
    "merge-items": ({"fromItemId", "toItemId"}, set()),
    "link-feedback": ({"feedbackId"}, {"itemId", "requestId", "classification", "status", "note"}),
    "mark-bug": ({"feedbackId"}, {"itemId", "status", "note"}),
    "mark-duplicate": ({"feedbackId", "duplicateOfFeedbackId"}, {"status", "note"}),
    "archive-feedback": ({"feedbackId"}, {"classification", "note"}),
    "verify-tallies": (set(), {"itemIds", "fix"}),
}


def _convex_call(decision: dict[str, Any], operator: str) -> tuple[str, dict[str, Any]]:
    """Map one validated decision to its internal triage function and arguments."""
    action = decision["action"]
    note = {"note": decision["note"]} if "note" in decision else {}
    if action in ("approve-request", "merge-request", "reject-request"):
        verdict = {"approve-request": "approved", "merge-request": "merged", "reject-request": "rejected"}[action]
        args = {"requestId": decision["requestId"], "decision": verdict}
        for key in ("itemId", "intoRequestId"):
            if key in decision:
                args[key] = decision[key]
        return "moderateRequest", {**args, **note, "operator": operator}
    if action == "merge-items":
        return "mergeItems", {"fromItemId": decision["fromItemId"], "toItemId": decision["toItemId"], "operator": operator}
    if action == "verify-tallies":
        return "verifyVoteTallies", {key: decision[key] for key in ("itemIds", "fix") if key in decision}
    args: dict[str, Any] = {"feedbackId": decision["feedbackId"]}
    if action == "link-feedback":
        if "itemId" in decision:
            args["linkedItemId"] = decision["itemId"]
        if "requestId" in decision:
            args["linkedRequestId"] = decision["requestId"]
        for key in ("classification", "status"):
            if key in decision:
                args[key] = decision[key]
    elif action == "mark-bug":
        args["classification"] = "bug"
        if "itemId" in decision:
            args["linkedItemId"] = decision["itemId"]
        if "status" in decision:
            args["status"] = decision["status"]
    elif action == "mark-duplicate":
        args.update(
            duplicateOfFeedbackId=decision["duplicateOfFeedbackId"], classification="duplicate",
            status=decision.get("status", "archived"),
        )
    elif action == "archive-feedback":
        args["status"] = "archived"
        if "classification" in decision:
            args["classification"] = decision["classification"]
    return "triageFeedback", {**args, **note, "operator": operator}


def _validate_decision(raw: Any, index: int) -> dict[str, Any]:
    label = f"decisions[{index}]"
    if not isinstance(raw, dict) or raw.get("action") not in ACTION_FIELDS:
        raise TriageError(f"{label}.action must be one of {', '.join(ACTION_FIELDS)}.")
    action = raw["action"]
    required, optional = ACTION_FIELDS[action]
    keys = set(raw) - {"action"}
    if required - keys or keys - required - optional:
        raise TriageError(f"{label} ({action}) needs {sorted(required)} and accepts {sorted(optional)}.")
    decision: dict[str, Any] = {"action": action}
    if action == "create-item":
        if raw["status"] not in CREATE_STATUSES:
            raise TriageError(f"{label}.status must be one of {', '.join(CREATE_STATUSES)} (shipped needs proof).")
        change = _ch._validate_roadmap([{key: raw[key] for key in ("id", "status", "title", "summary")}])[0]
        if _ch._contains_secret_like_text([*change["title"].values(), *change["summary"].values()]):
            raise TriageError(f"{label} copy contains secret-like text.")
        return {"action": action, **change}
    for key in ("requestId", "intoRequestId"):
        if key in raw:
            decision[key] = _text(raw[key], f"{label}.{key}", 80, pattern=REQUEST_ID_RE)
    for key in ("feedbackId", "duplicateOfFeedbackId"):
        if key in raw:
            decision[key] = _text(raw[key], f"{label}.{key}", 80, pattern=FEEDBACK_ID_RE)
    for key in ("itemId", "fromItemId", "toItemId"):
        if key in raw:
            decision[key] = _slug(raw[key], f"{label}.{key}")
    if "note" in raw:
        decision["note"] = _text(raw["note"], f"{label}.note", NOTE_MAX)
        if _ch._contains_secret_like_text([decision["note"]]):
            raise TriageError(f"{label}.note contains secret-like text.")
    if "classification" in raw:
        if raw["classification"] not in FEEDBACK_CLASSIFICATIONS:
            raise TriageError(f"{label}.classification must be one of {', '.join(FEEDBACK_CLASSIFICATIONS)}.")
        decision["classification"] = raw["classification"]
    if "status" in raw:
        if raw["status"] not in FEEDBACK_STATUSES:
            raise TriageError(f"{label}.status must be one of {', '.join(FEEDBACK_STATUSES)}.")
        decision["status"] = raw["status"]
    if "itemIds" in raw:
        if not isinstance(raw["itemIds"], list) or not 1 <= len(raw["itemIds"]) <= 50:
            raise TriageError(f"{label}.itemIds must list 1 to 50 item ids.")
        decision["itemIds"] = [_slug(value, f"{label}.itemIds") for value in raw["itemIds"]]
    if "fix" in raw:
        if not isinstance(raw["fix"], bool):
            raise TriageError(f"{label}.fix must be a boolean.")
        decision["fix"] = raw["fix"]
    if action == "merge-request" and ("itemId" in decision) == ("intoRequestId" in decision):
        raise TriageError(f"{label} (merge-request) needs exactly one of itemId or intoRequestId.")
    if action == "merge-request" and decision.get("intoRequestId") == decision["requestId"]:
        raise TriageError(f"{label} merges a request into itself.")
    if action == "link-feedback" and not {"itemId", "requestId"} & set(decision):
        raise TriageError(f"{label} (link-feedback) needs itemId or requestId.")
    if action == "merge-items" and decision["fromItemId"] == decision["toItemId"]:
        raise TriageError(f"{label} merges an item into itself.")
    if action == "mark-duplicate" and decision["duplicateOfFeedbackId"] == decision["feedbackId"]:
        raise TriageError(f"{label} marks a feedback as its own duplicate.")
    return decision


def load_decisions(path: str | Path) -> dict[str, Any]:
    raw = _read_json(Path(path))
    allowed = {"schema", "env", "deployment", "operator", "project", "decisions"}
    if not isinstance(raw, dict) or raw.get("schema") != DECISIONS_SCHEMA or set(raw) - allowed:
        raise TriageError(f"Decision file must be {{ \"schema\": \"{DECISIONS_SCHEMA}\", ... }} with {sorted(allowed)}.")
    if raw.get("env") not in ENVS:
        raise TriageError("Decision file env must be dev or prd.")
    deployment = raw.get("deployment")
    if not isinstance(deployment, str) or not DEPLOYMENT_RE.match(deployment):
        raise TriageError("Decision file deployment must be the inbox deployment, e.g. dev:<name>.")
    operator = raw.get("operator", "agent")
    if not isinstance(operator, str) or not OPERATOR_RE.fullmatch(operator):
        raise TriageError("Decision file operator must be a short name (letters, digits, . _ -).")
    project = raw.get("project")
    if project is not None:
        project = _text(project, "project", 128)
    decisions = raw.get("decisions")
    if not isinstance(decisions, list) or not 1 <= len(decisions) <= MAX_DECISIONS:
        raise TriageError(f"Decision file must list 1 to {MAX_DECISIONS} decisions.")
    validated = [_validate_decision(item, index) for index, item in enumerate(decisions)]
    created = [item["id"] for item in validated if item["action"] == "create-item"]
    if len(set(created)) != len(created):
        raise TriageError("A roadmap item is created twice in the decision file.")
    if len(created) > _ch.MAX_ROADMAP_CHANGES:
        raise TriageError(f"At most {_ch.MAX_ROADMAP_CHANGES} roadmap items per decision file.")
    return {
        "env": raw["env"], "deployment": deployment, "operator": operator, "project": project, "decisions": validated,
    }


def _referenced_items(decision: dict[str, Any]) -> list[str]:
    if decision["action"] in ("approve-request", "merge-request", "link-feedback", "mark-bug"):
        return [decision["itemId"]] if "itemId" in decision else []
    if decision["action"] == "merge-items":
        return [decision["toItemId"]]
    return []


def _creation_event(changes: list[dict[str, Any]], day: str) -> dict[str, Any]:
    """Synthetic event used only for the dry-run projection (never written)."""
    return {"id": "evt_" + "0" * 32, "occurredAt": f"{day}T00:00:00Z", "public": {"roadmap": changes}}


def apply(
    backend: Backend,
    decisions_file: dict[str, Any],
    runner: ConvexRunner | None,
    *,
    confirm: bool = False,
    today: str | None = None,
) -> dict[str, Any]:
    """Validate everything first, then (with ``confirm``) create hidden items and run Convex triage."""
    if decisions_file["env"] != backend.env:
        raise TriageError(f"Decision file targets {decisions_file['env']} but --env is {backend.env}.")
    kind, name = DEPLOYMENT_RE.match(decisions_file["deployment"]).groups()  # type: ignore[union-attr]
    if backend.env == "dev" and (kind != "dev" or (backend.expected_deployment and name != backend.expected_deployment)):
        raise TriageError(f"Decision file deployment {decisions_file['deployment']} is not this repository's dev deployment.")
    if backend.env == "prd" and kind != "prod":
        raise TriageError("A prd decision file must name a prod: deployment.")
    root = backend.repo_root
    sites = _sites(root)
    items = roadmap_items(sites)
    decisions = decisions_file["decisions"]
    creations = [item for item in decisions if item["action"] == "create-item"]
    created_ids = {item["id"] for item in creations}
    warnings: list[str] = []
    if creations and not sites:
        raise TriageError("create-item needs a site declaring @shipglows/astro-roadmap in .shipglows.product-updates.json.")
    for item in creations:
        if item["id"] in items:
            raise TriageError(f"create-item {item['id']}: the roadmap item already exists; reference it instead.")
    for index, decision in enumerate(decisions):
        for item_id in _referenced_items(decision):
            if item_id in items or item_id in created_ids:
                continue
            if sites:
                raise TriageError(f"decisions[{index}] references {item_id}, neither a roadmap item of the site nor created here.")
            warnings.append(f"decisions[{index}] references {item_id}; no site is declared to check it.")
        if decision["action"] == "merge-items" and decision["fromItemId"] not in items:
            warnings.append(f"decisions[{index}] merges {decision['fromItemId']}, absent from the site content.")

    operator = decisions_file["operator"]
    plan: list[dict[str, Any]] = []
    for index, decision in enumerate(decisions):
        if decision["action"] == "create-item":
            plan.append({"index": index, "action": "create-item", "itemId": decision["id"], "status": decision["status"]})
        else:
            function, args = _convex_call(decision, operator)
            plan.append({"index": index, "action": decision["action"], "function": f"{backend.module}:{function}", "args": args})

    report: dict[str, Any] = {
        "dryRun": not confirm,
        "env": backend.env,
        "deployment": decisions_file["deployment"],
        "backend": backend.view(),
        "plan": plan,
        "warnings": warnings,
    }
    changes = [{key: item[key] for key in ("id", "status", "title", "summary")} for item in creations]
    day = today or _ch._utc_timestamp()[:10]
    if not confirm:
        if changes:
            event = _creation_event(changes, day)
            report["projection"] = [
                {"root": site.declared, **_pu.project_event_to_site(site, event, dry_run=True)} for site in sites
            ]
        report["status"] = "planned"
        report["summary"] = _summary(plan, [])
        report["nextStep"] = "Show this plan to the operator; rerun with --confirm only after explicit validation."
        return report

    if runner is None:
        raise TriageError("--confirm needs a Convex runner.")
    resolved = check_deployment(backend, runner.deployment())
    if resolved != decisions_file["deployment"]:
        raise TriageError(f"Doppler selects {resolved}, the decision file was written for {decisions_file['deployment']}.")
    results: list[dict[str, Any]] = []
    if changes:
        ids = ", ".join(change["id"] for change in changes)
        path = _ch.append_event(
            root, decisions_file["project"] or root.name, "CONTEXT_DECISION",
            f"Feedback triage: roadmap item(s) created hidden for review: {ids}"[:500],
            public={"roadmap": changes},
        )
        event = _ch._read_event_file(path)
        projection = _pu.project_after_append(root, event)
        report["event"] = {"id": event["id"], "path": path.relative_to(root).as_posix()}
        report["projection"] = projection
        for entry in plan:
            if entry["action"] == "create-item":
                results.append({"index": entry["index"], "status": "ok" if projection.get("status") == "ok" else "error"})
        if projection.get("status") != "ok":
            report.update(status="error", results=results, summary=_summary(plan, results))
            report["error"] = "Roadmap projection failed; no Convex triage call was made."
            return report
    failed = False
    for entry in plan:
        if entry["action"] == "create-item":
            continue
        if failed:
            results.append({"index": entry["index"], "status": "not-run"})
            continue
        try:
            output = runner.run(entry["function"].split(":", 1)[1], entry["args"])
            results.append({"index": entry["index"], "status": "ok", "result": _result_view(output)})
        except TriageError as error:
            failed = True
            results.append({"index": entry["index"], "status": "error", "error": str(error)})
    results.sort(key=lambda result: result["index"])
    report.update(status="error" if failed or any(r["status"] == "error" for r in results) else "ok", results=results)
    report["summary"] = _summary(plan, results)
    report["nextStep"] = (
        "Hidden items and status changes reach the site after `context_history.py pending` review, "
        "`publish --id <item>`, commit and deploy; the backend learns new items from the registry sync."
        if changes else "Triage recorded in the product's Convex audit log (triageLog)."
    )
    return report


def _result_view(output: Any) -> Any:
    if isinstance(output, dict):
        return {key: value for key, value in output.items() if key not in ("authorId", "userId", "description")}
    return output


def _summary(plan: list[dict[str, Any]], results: list[dict[str, Any]]) -> dict[str, Any]:
    by_action: dict[str, int] = {}
    for entry in plan:
        by_action[entry["action"]] = by_action.get(entry["action"], 0) + 1
    states: dict[str, int] = {}
    for result in results:
        states[result["status"]] = states.get(result["status"], 0) + 1
    return {"decisions": len(plan), "byAction": by_action, **({"results": states} if results else {})}


# ---------------------------------------------------------------------------------- text


def render_inbox_text(report: dict[str, Any]) -> str:
    summary = report["summary"]
    lines = [
        f"{report['deployment']} ({report['backend']['directory']}, module {report['backend']['module']}) "
        f"products {', '.join(report['products'])}",
        f"{summary['newFeedback']} new feedback, {summary['pendingRequests']} pending requests, "
        f"{summary['roadmapItems']} roadmap items, {summary['votes']} votes",
    ]
    matches = {entry["feedbackId"]: entry["matchingItems"] for entry in report["suggestions"]["feedback"]}
    for entry in report["feedback"]:
        hint = ", ".join(f"{match['itemId']} ({match['score']})" for match in matches.get(entry["id"], []))
        text = (entry.get("message") or "[audio]").replace("\n", " ")[:160]
        lines.append(f"- feedback {entry['id']} [{entry.get('context', {}).get('platform', '?')}] {text}" + (f" -> {hint}" if hint else ""))
    request_matches = {entry["requestId"]: entry["matchingItems"] for entry in report["suggestions"]["requests"]}
    for entry in report["requests"]:
        hint = ", ".join(f"{match['itemId']} ({match['score']})" for match in request_matches.get(entry["id"], []))
        lines.append(f"- request {entry['id']} {entry.get('title', '')}" + (f" -> {hint}" if hint else ""))
    for pair in report["suggestions"]["duplicateFeedback"] + report["suggestions"]["duplicateRequests"]:
        lines.append(f"- likely duplicates {' / '.join(pair['ids'])} ({pair['score']})")
    voted = [item for item in report["roadmap"] if item.get("votes")]
    if voted:
        lines.append("Votes: " + ", ".join(f"{item['id']} {item['votes']}" for item in voted[:10]))
    return "\n".join(lines)


def render_apply_text(report: dict[str, Any]) -> str:
    lines = [f"{'DRY RUN' if report['dryRun'] else 'APPLIED'} on {report['deployment']}: {report['status']}"]
    results = {result["index"]: result for result in report.get("results", [])}
    for entry in report["plan"]:
        target = entry.get("itemId") or entry.get("args", {}).get("requestId") or entry.get("args", {}).get("feedbackId") or ""
        state = results.get(entry["index"], {}).get("status", "planned")
        lines.append(f"- [{state}] {entry['action']} {target}".rstrip())
    lines.extend(f"! {warning}" for warning in report.get("warnings", []))
    if report.get("error"):
        lines.append(f"! {report['error']}")
    if report.get("nextStep"):
        lines.append(report["nextStep"])
    return "\n".join(lines)


# ----------------------------------------------------------------------------------- cli


def main(argv: list[str] | None = None, *, runner_factory: Any = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--project-root", default=".")
    commands = parser.add_subparsers(dest="command", required=True)
    for name, help_text in (
        ("discover", "Show the declared backend and Doppler scope; calls nothing."),
        ("inbox", "Read new feedback, pending requests, votes and suggestions (read-only)."),
        ("apply", "Execute an operator-validated decision file (dry run unless --confirm)."),
    ):
        command = commands.add_parser(name, help=help_text)
        command.add_argument("--env", choices=ENVS, default="dev", help="prd only on an explicit operator decision.")
        command.add_argument("--backend-dir", help="Backend directory relative to the repository root, when several exist.")
        command.add_argument("--format", choices=("json", "text"), default="json")
        if name == "inbox":
            command.add_argument("--product", action="append", default=[], help="Product key (default: the site's keys).")
            command.add_argument("--limit", type=int, default=50)
            command.add_argument("--verify-tallies", action="store_true", help="Also run verifyVoteTallies without fix.")
        if name == "apply":
            command.add_argument("--decisions", required=True)
            command.add_argument("--confirm", action="store_true")
    args = parser.parse_args(argv)
    make_runner = runner_factory or DopplerConvexRunner
    try:
        backend = discover_backend(args.project_root, args.env, args.backend_dir)
        if args.command == "discover":
            output: dict[str, Any] = {
                "status": "ok", **backend.view(), "convexCli": backend.convex_cli is not None,
                "sites": [site.declared for site in _sites(backend.repo_root)],
            }
        elif args.command == "inbox":
            output = {"status": "ok", **inbox(
                backend, make_runner(backend), products=args.product, limit=args.limit,
                verify_tallies=args.verify_tallies,
            )}
            if args.format == "text":
                print(render_inbox_text(output))
                return 0
        else:
            decisions = load_decisions(args.decisions)
            output = apply(backend, decisions, make_runner(backend) if args.confirm else None, confirm=args.confirm)
            if args.format == "text":
                print(render_apply_text(output))
                return 0 if output["status"] != "error" else 1
    except (ContextHistoryError, OSError, UnicodeError) as error:
        print(json.dumps({"status": "error", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 2
    print(json.dumps(output, ensure_ascii=False, indent=2, default=str))
    return 1 if output.get("status") == "error" else 0


if __name__ == "__main__":
    sys.modules.setdefault("feedback_triage", sys.modules[__name__])
    raise SystemExit(main())
