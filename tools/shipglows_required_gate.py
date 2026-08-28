#!/usr/bin/env python3
"""Generate, audit, and safely reconcile the ShipGlows required CI gate."""

from __future__ import annotations

import argparse
import base64
import binascii
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path, PurePosixPath
from typing import Any, Iterable
from urllib.parse import quote


REQUIRED_CHECK = "ShipGlows required gate"
WORKFLOW_RELATIVE = Path(".github/workflows/shipglows-required-gate.yml")
CONFIG_RELATIVE = Path(".shipglows/required-gate.json")
CHECKOUT_PIN = "3d3c42e5aac5ba805825da76410c181273ba90b1"  # v7.0.1
SETUP_NODE_PIN = "49933ea5288caeca8642d1e84afbd3f7d6820020"  # v4
SETUP_PYTHON_PIN = "a26af69be951a213d495a4c3e4e4022e16d87065"  # v5
FLUTTER_PIN = "1a449444c387b1966244ae4d4f8c696479add0b2"  # v2
LANE_ID = re.compile(r"^[a-z][a-z0-9-]{0,39}$")
FORBIDDEN_COMMAND = re.compile(
    r"(?i)(^|\s)(deploy|publish|release|destroy|rm\s+-rf|git\s+push|gh\s+api|gh\s+release|doppler\s+secrets|firebase\s+deploy|vercel|wrangler\s+deploy|terraform\s+apply|kubectl\s+(apply|delete))([\s:]|$)"
)


class GateError(RuntimeError):
    """An actionable contract failure."""


@dataclass(frozen=True)
class Lane:
    id: str
    runtime: str
    root: str
    paths: tuple[str, ...]
    commands: tuple[str, ...]
    node_version: str | None = None
    flutter_version: str | None = None


@dataclass(frozen=True)
class ProjectContract:
    production_branch: str
    lanes: tuple[Lane, ...]
    source: str


def _posix(path: Path) -> str:
    value = path.as_posix().strip("/")
    return value or "."


def _load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise GateError(f"Cannot read valid JSON from {path}: {exc}") from exc


def _validate_node_version(value: str, context: str) -> str:
    version = value.strip()
    if not version or len(version) > 80 or not re.fullmatch(r"[A-Za-z0-9*./<>=~^| -]+", version):
        raise GateError(f"{context} has an invalid Node version: {value!r}")
    return version


def _validate_flutter_version(value: str, context: str) -> str:
    version = value.strip()
    if not version or len(version) > 80 or not re.fullmatch(r"[A-Za-z0-9*./<>=~^| -]+", version):
        raise GateError(f"{context} has an invalid Flutter version: {value!r}")
    return version


def _validate_lane(raw: dict[str, Any]) -> Lane:
    lane_id = str(raw.get("id", ""))
    runtime = str(raw.get("runtime", ""))
    root = str(raw.get("root", ".")).strip("/") or "."
    paths = tuple(str(item) for item in raw.get("paths", []))
    commands = tuple(str(item).strip() for item in raw.get("commands", []))
    node_version = str(raw.get("node_version", "")).strip() or None
    flutter_version = str(raw.get("flutter_version", "")).strip() or None
    if not LANE_ID.fullmatch(lane_id):
        raise GateError(f"Invalid lane id: {lane_id!r}")
    if runtime not in {"shell", "node", "flutter", "python"}:
        raise GateError(f"Unsupported runtime for lane {lane_id}: {runtime!r}")
    if (
        not re.fullmatch(r"[A-Za-z0-9._/-]+", root)
        or PurePosixPath(root).is_absolute()
        or ".." in PurePosixPath(root).parts
    ):
        raise GateError(f"Lane {lane_id} root must stay inside the project: {root!r}")
    if not paths or any(PurePosixPath(item).is_absolute() or ".." in PurePosixPath(item).parts for item in paths):
        raise GateError(f"Lane {lane_id} needs safe project-relative paths")
    if not commands:
        raise GateError(f"Lane {lane_id} needs at least one validation command")
    for command in commands:
        if not command or "\n" in command or "\r" in command or FORBIDDEN_COMMAND.search(command):
            raise GateError(f"Lane {lane_id} contains a forbidden command: {command!r}")
    if runtime == "node":
        if node_version is None:
            raise GateError(f"Node lane {lane_id} must declare node_version")
        node_version = _validate_node_version(node_version, f"Node lane {lane_id}")
    elif runtime == "flutter":
        if flutter_version is not None:
            flutter_version = _validate_flutter_version(flutter_version, f"Flutter lane {lane_id}")
        else:
            flutter_version = "stable"
    if runtime != "node" and node_version is not None:
        raise GateError(f"Non-Node lane {lane_id} cannot declare node_version")
    if runtime != "flutter" and flutter_version is not None:
        raise GateError(f"Non-Flutter lane {lane_id} cannot declare flutter_version")
    return Lane(lane_id, runtime, root, paths, commands, node_version, flutter_version)


def _configured_contract(project: Path, config: Path) -> ProjectContract:
    raw = _load_json(config)
    if not isinstance(raw, dict) or not isinstance(raw.get("lanes"), list):
        raise GateError(f"{config} must contain an object with a lanes array")
    branch = str(raw.get("production_branch", "main"))
    if not re.fullmatch(r"[A-Za-z0-9._/-]+", branch) or branch.startswith("/") or ".." in branch:
        raise GateError(f"Invalid production branch: {branch!r}")
    lanes = tuple(_validate_lane(item) for item in raw["lanes"] if isinstance(item, dict))
    if len(lanes) != len(raw["lanes"]) or not lanes:
        raise GateError("Every configured lane must be an object and at least one lane is required")
    if len({lane.id for lane in lanes}) != len(lanes):
        raise GateError("Configured lane ids must be unique")
    return ProjectContract(branch, lanes, str(config.relative_to(project).as_posix()))


def _declared_production_branch(project: Path) -> str:
    for name in ("CLAUDE.md", "SHIPGLOWS.md"):
        path = project / name
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        match = re.search(r"(?mi)^-\s*production_branch:\s*([^\s|]+)\s*$", text)
        if match:
            branch = match.group(1)
            if not re.fullmatch(r"[A-Za-z0-9._/-]+", branch) or branch.startswith("/") or ".." in branch:
                raise GateError(f"Invalid declared production branch in {path}: {branch!r}")
            return branch
    return "main"


def _declared_node_version(project: Path, root_path: Path, package: dict[str, Any]) -> str:
    current = root_path
    while True:
        for name in (".node-version", ".nvmrc"):
            declaration = current / name
            if declaration.is_file():
                version = declaration.read_text(encoding="utf-8").strip()
                if version:
                    return _validate_node_version(version, str(declaration))
        if current == project:
            break
        current = current.parent
    engines = package.get("engines", {})
    if isinstance(engines, dict) and isinstance(engines.get("node"), str) and engines["node"].strip():
        return _validate_node_version(engines["node"], f"{root_path / 'package.json'} engines.node")
    raise GateError(
        f"{root_path / 'package.json'}: declare Node in .node-version, .nvmrc, or package.json engines.node"
    )


def _node_lane(project: Path, manifest: Path) -> Lane | None:
    root_path = manifest.parent
    package = _load_json(manifest)
    scripts = package.get("scripts", {}) if isinstance(package, dict) else {}
    if not isinstance(scripts, dict):
        scripts = {}
    selected = [name for name in ("lint", "typecheck", "check") if isinstance(scripts.get(name), str)]
    selected.extend(sorted(name for name, value in scripts.items() if (name == "test" or name.startswith("test:")) and isinstance(value, str)))
    if isinstance(scripts.get("build"), str):
        selected.append("build")
    if not selected:
        return None
    if (root_path / "bun.lock").is_file() or (root_path / "bun.lockb").is_file():
        raise GateError(f"{manifest}: Bun setup is not inferred; declare a supported explicit CI lane")
    locks = [name for name in ("package-lock.json", "pnpm-lock.yaml", "yarn.lock") if (root_path / name).is_file()]
    if len(locks) != 1:
        raise GateError(f"{manifest}: expected exactly one package-manager lockfile, found {locks or 'none'}")
    lock = locks[0]
    if lock == "package-lock.json":
        install, run = "npm ci", lambda name: f"npm run {name}"
    elif lock == "pnpm-lock.yaml":
        install, run = "corepack enable && pnpm install --frozen-lockfile", lambda name: f"pnpm run {name}"
    elif lock == "yarn.lock":
        install, run = "corepack enable && yarn install --immutable", lambda name: f"yarn {name}"
    else:
        install, run = "corepack enable && yarn install --immutable", lambda name: f"yarn {name}"
    root = _posix(root_path.relative_to(project))
    lane_id = "node" if root == "." else re.sub(r"[^a-z0-9]+", "-", root.lower()).strip("-") + "-node"
    paths = ("**",) if root == "." else (f"{root}/**",)
    node_version = _declared_node_version(project, root_path, package)
    return Lane(lane_id[:40].rstrip("-"), "node", root, paths, tuple([install, *[run(name) for name in selected]]), node_version)


def _flutter_lane(project: Path, manifest: Path) -> Lane:
    root_path = manifest.parent
    root = _posix(root_path.relative_to(project))
    lane_id = "flutter" if root == "." else re.sub(r"[^a-z0-9]+", "-", root.lower()).strip("-") + "-flutter"
    commands = ["flutter pub get", "flutter analyze"]
    if (root_path / "test").is_dir():
        commands.append("flutter test")
    paths = ("**",) if root == "." else (f"{root}/**",)
    return Lane(lane_id[:40].rstrip("-"), "flutter", root, paths, tuple(commands), flutter_version="stable")


def _python_lane(project: Path, manifest: Path) -> Lane | None:
    root_path = manifest.parent
    if not (root_path / "tests").is_dir():
        return None
    root = _posix(root_path.relative_to(project))
    lane_id = "python" if root == "." else re.sub(r"[^a-z0-9]+", "-", root.lower()).strip("-") + "-python"
    paths = ("**",) if root == "." else (f"{root}/**",)
    return Lane(lane_id[:40].rstrip("-"), "python", root, paths, ("python -m unittest discover",))


def inspect_project(project: Path) -> ProjectContract:
    project = project.resolve()
    if not project.is_dir():
        raise GateError(f"Project directory does not exist: {project}")
    config = project / CONFIG_RELATIVE
    if config.is_file():
        return _configured_contract(project, config)

    lanes: list[Lane] = []
    ignored = {".git", ".dart_tool", ".flox", ".venv", "node_modules", "build", "dist"}
    manifests = sorted(
        path for path in project.rglob("package.json")
        if not any(part in ignored for part in path.relative_to(project).parts)
    )
    lanes.extend(lane for manifest in manifests if (lane := _node_lane(project, manifest)))
    flutter_manifests = sorted(
        path for path in project.rglob("pubspec.yaml")
        if not any(part in ignored for part in path.relative_to(project).parts)
    )
    lanes.extend(_flutter_lane(project, manifest) for manifest in flutter_manifests)
    python_manifests = sorted(
        path for name in ("pyproject.toml", "requirements.txt") for path in project.rglob(name)
        if not any(part in ignored for part in path.relative_to(project).parts)
    )
    seen_python_roots: set[Path] = set()
    for manifest in python_manifests:
        if manifest.parent in seen_python_roots:
            continue
        seen_python_roots.add(manifest.parent)
        lane = _python_lane(project, manifest)
        if lane:
            lanes.append(lane)
    if not lanes:
        raise GateError(
            "No safe conventional validation lane was detected; declare .shipglows/required-gate.json"
        )
    ids = [lane.id for lane in lanes]
    if len(ids) != len(set(ids)):
        raise GateError(f"Detected lane ids collide: {ids}; use an explicit project declaration")
    return ProjectContract(_declared_production_branch(project), tuple(lanes), "detected")


def _yaml_quote(value: str) -> str:
    return json.dumps(value)


def render_workflow(contract: ProjectContract) -> str:
    branch = contract.production_branch
    lane_map = {lane.id: list(lane.paths) for lane in contract.lanes}
    lines = [
        "# Generated by ShipGlows. Edit project manifests or .shipglows/required-gate.json, then regenerate.",
        "name: ShipGlows required CI",
        "",
        '"on":',
        "  push:",
        f"    branches: [{_yaml_quote(branch)}]",
        "  pull_request:",
        f"    branches: [{_yaml_quote(branch)}]",
        "  workflow_dispatch:",
        "",
        "permissions:",
        "  contents: read",
        "",
        "concurrency:",
        "  group: shipglows-required-${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}",
        "  cancel-in-progress: true",
        "",
        "jobs:",
        "  required:",
        f"    name: {REQUIRED_CHECK}",
        "    runs-on: ubuntu-latest",
        "    timeout-minutes: 45",
        "    steps:",
        "      - name: Check out the exact tested revision",
        f"        uses: actions/checkout@{CHECKOUT_PIN}",
        "        with:",
        "          fetch-depth: 0",
        "          persist-credentials: false",
        "          ref: ${{ github.event.pull_request.head.sha || github.sha }}",
        "",
        "      - name: Classify changed paths",
        "        id: impact",
        "        shell: bash",
        "        env:",
        "          EVENT_NAME: ${{ github.event_name }}",
        "          BASE_SHA: ${{ github.event.pull_request.base.sha || github.event.before }}",
        "          HEAD_SHA: ${{ github.event.pull_request.head.sha || github.sha }}",
        "          COMPARE_MODE: ${{ github.event_name == 'pull_request' && 'merge-base' || 'direct' }}",
        "        run: |",
        "          python - <<'PY'",
        "          import fnmatch, json, os, re, subprocess",
        f"          lanes = json.loads({json.dumps(json.dumps(lane_map, sort_keys=True))})",
        "          head = os.environ['HEAD_SHA']",
        "          base = os.environ.get('BASE_SHA', '')",
        "          event = os.environ['EVENT_NAME']",
        "          if not re.fullmatch(r'[0-9a-f]{40}', head):",
        "              raise SystemExit(f'Invalid head SHA: {head}')",
        "          actual = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()",
        "          if actual != head:",
        "              raise SystemExit(f'Checked-out SHA mismatch: expected {head}, got {actual}')",
        "          if event == 'workflow_dispatch':",
        "              changed = ['.github/workflows/shipglows-required-gate.yml']",
        "              force_all = True",
        "          elif base == '0' * 40:",
        "              changed = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', head], text=True).splitlines()",
        "              force_all = False",
        "          else:",
        "              if not re.fullmatch(r'[0-9a-f]{40}', base):",
        "                  raise SystemExit(f'Invalid base SHA: {base}')",
        "              separator = '...' if os.environ.get('COMPARE_MODE') == 'merge-base' else '..'",
        "              changed = subprocess.check_output(['git', 'diff', '--name-only', '--diff-filter=ACDMRTUXB', f'{base}{separator}{head}'], text=True).splitlines()",
        "              force_all = False",
        "          workflow_changed = '.github/workflows/shipglows-required-gate.yml' in changed",
        "          with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as output:",
        "              for lane, patterns in lanes.items():",
        "                  impacted = force_all or workflow_changed or any(fnmatch.fnmatch(path, pattern) for path in changed for pattern in patterns)",
        "                  output.write(f'{lane}={str(impacted).lower()}\\n')",
        "                  print(f'{lane}: {\"run\" if impacted else \"no impact\"}')",
        "          PY",
    ]
    for lane in contract.lanes:
        condition = f"steps.impact.outputs['{lane.id}'] == 'true'"
        if lane.runtime == "node":
            lines.extend([
                "",
                f"      - name: Set up Node for {lane.id}",
                f"        if: {condition}",
                f"        uses: actions/setup-node@{SETUP_NODE_PIN}",
                "        with:",
                f"          node-version: {_yaml_quote(lane.node_version or '')}",
            ])
        elif lane.runtime == "python":
            lines.extend([
                "",
                f"      - name: Set up Python for {lane.id}",
                f"        if: {condition}",
                f"        uses: actions/setup-python@{SETUP_PYTHON_PIN}",
                "        with:",
                "          python-version: '3.12'",
            ])
        elif lane.runtime == "flutter":
            lines.extend([
                "",
                f"      - name: Set up Flutter for {lane.id}",
                f"        if: {condition}",
                f"        uses: subosito/flutter-action@{FLUTTER_PIN}",
                "        with:",
                f"          flutter-version: {_yaml_quote(lane.flutter_version or 'stable')}",
                "          channel: stable",
                "          cache: true",
            ])
        lines.extend([
            "",
            f"      - name: Run {lane.id}",
            f"        if: {condition}",
            "        shell: bash",
            f"        working-directory: {_yaml_quote(lane.root)}",
            "        run: |",
            *[f"          {command}" for command in lane.commands],
            "",
            f"      - name: Report no impact for {lane.id}",
            f"        if: {condition.replace("'true'", "'false'")}",
            "        shell: bash",
            f"        run: echo {_yaml_quote(f'No {lane.id} impact; lane intentionally skipped.')} ",
        ])
    return "\n".join(lines).rstrip() + "\n"


def classify_changed_paths(
    contract: ProjectContract, changed_paths: Iterable[str], *, force_all: bool = False
) -> dict[str, bool]:
    """Mirror the generated workflow selector for focused local proof."""
    import fnmatch

    changed = tuple(changed_paths)
    workflow_changed = WORKFLOW_RELATIVE.as_posix() in changed
    return {
        lane.id: force_all
        or workflow_changed
        or any(fnmatch.fnmatch(path, pattern) for path in changed for pattern in lane.paths)
        for lane in contract.lanes
    }


def audit_project(project: Path) -> dict[str, Any]:
    contract = inspect_project(project)
    workflow = project.resolve() / WORKFLOW_RELATIVE
    findings: list[str] = []
    if not workflow.is_file():
        findings.append(f"missing workflow: {WORKFLOW_RELATIVE.as_posix()}")
    else:
        current = workflow.read_text(encoding="utf-8").replace("\r\n", "\n")
        expected = render_workflow(contract)
        if current != expected:
            findings.append("workflow drift: regenerate the canonical workflow")
        if re.search(r"(?m)^\s{2}(paths|paths-ignore):", current):
            findings.append("top-level path filter can deadlock the required status")
        if f"name: {REQUIRED_CHECK}" not in current:
            findings.append(f"missing exact terminal status name: {REQUIRED_CHECK}")
    return {
        "compliant": not findings,
        "project": str(project.resolve()),
        "production_branch": contract.production_branch,
        "contract_source": contract.source,
        "lanes": [asdict(lane) for lane in contract.lanes],
        "findings": findings,
    }


def _run_json(command: list[str]) -> Any:
    result = subprocess.run(command, text=True, capture_output=True, check=False)
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip() or f"exit {result.returncode}"
        raise GateError(f"Command failed: {' '.join(command)}: {detail}")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise GateError(f"Command returned invalid JSON: {' '.join(command)}") from exc


def gh_api(repository: str, endpoint: str, *, method: str = "GET", payload: dict[str, Any] | None = None) -> Any:
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise GateError(f"Invalid GitHub repository identity: {repository!r}")
    command = ["gh", "api", f"repos/{repository}/{endpoint}", "--method", method]
    if payload is not None:
        command.extend(["--input", "-"])
        result = subprocess.run(command, input=json.dumps(payload), text=True, capture_output=True, check=False)
        if result.returncode:
            raise GateError(result.stderr.strip() or result.stdout.strip() or "GitHub API mutation failed")
        try:
            return json.loads(result.stdout) if result.stdout.strip() else {}
        except json.JSONDecodeError as exc:
            raise GateError("GitHub API mutation returned invalid JSON") from exc
    return _run_json(command)


def _required_rules(existing: list[dict[str, Any]]) -> list[dict[str, Any]]:
    rules = json.loads(json.dumps(existing))
    by_type = {rule.get("type"): rule for rule in rules}
    for simple in ("deletion", "non_fast_forward"):
        if simple not in by_type:
            rules.append({"type": simple})
    if "pull_request" not in by_type:
        rules.append({
            "type": "pull_request",
            "parameters": {
                "allowed_merge_methods": ["merge", "squash", "rebase"],
                "dismiss_stale_reviews_on_push": False,
                "require_code_owner_review": False,
                "require_last_push_approval": False,
                "required_approving_review_count": 0,
                "required_review_thread_resolution": False,
            },
        })
    status = by_type.get("required_status_checks")
    if status is None:
        status = {
            "type": "required_status_checks",
            "parameters": {"strict_required_status_checks_policy": True, "do_not_enforce_on_create": False, "required_status_checks": []},
        }
        rules.append(status)
    parameters = status.setdefault("parameters", {})
    checks = parameters.setdefault("required_status_checks", [])
    if not any(check.get("context") == REQUIRED_CHECK for check in checks):
        checks.append({"context": REQUIRED_CHECK})
    parameters["strict_required_status_checks_policy"] = True
    parameters.setdefault("do_not_enforce_on_create", False)
    return rules


def _ruleset_targets_branch(current: dict[str, Any], branch: str) -> bool:
    include = current.get("conditions", {}).get("ref_name", {}).get("include", [])
    return "~DEFAULT_BRANCH" in include or f"refs/heads/{branch}" in include


def build_ruleset_plan(project: Path, repository: str, ruleset_id: int) -> dict[str, Any]:
    audit = audit_project(project)
    if not audit["compliant"]:
        raise GateError("Local workflow is not compliant: " + "; ".join(audit["findings"]))
    branch = audit["production_branch"]
    encoded_branch = quote(branch, safe="")
    remote_workflow = gh_api(repository, f"contents/{WORKFLOW_RELATIVE.as_posix()}?ref={encoded_branch}")
    if remote_workflow.get("encoding") != "base64" or not isinstance(remote_workflow.get("content"), str):
        raise GateError("Production-branch workflow content is unavailable for exact comparison")
    try:
        encoded = "".join(remote_workflow["content"].split())
        remote_text = base64.b64decode(encoded, validate=True).decode("utf-8").replace("\r\n", "\n")
    except (binascii.Error, UnicodeDecodeError) as exc:
        raise GateError("Production-branch workflow content is not valid base64 UTF-8") from exc
    expected = render_workflow(inspect_project(project))
    if remote_text != expected:
        raise GateError("Production-branch workflow does not match the locally audited canonical workflow")
    checks = gh_api(repository, f"commits/{encoded_branch}/check-runs?filter=latest&per_page=100")
    check_runs = checks.get("check_runs", [])
    if not isinstance(check_runs, list):
        raise GateError("GitHub check-run response has no usable check_runs array")
    successful = any(
        item.get("name") == REQUIRED_CHECK and item.get("conclusion") == "success"
        for item in check_runs
        if isinstance(item, dict)
    )
    if not successful:
        raise GateError(f"No successful {REQUIRED_CHECK!r} check is proven on {repository}:{branch}")
    current = gh_api(repository, f"rulesets/{ruleset_id}")
    if current.get("target") != "branch":
        raise GateError(f"Ruleset {ruleset_id} does not target branches")
    if not _ruleset_targets_branch(current, branch):
        raise GateError(f"Ruleset {ruleset_id} does not target production branch {branch!r}")
    if not isinstance(current.get("name"), str) or not current["name"]:
        raise GateError(f"Ruleset {ruleset_id} has no usable name")
    existing_rules = current.get("rules", [])
    if not isinstance(existing_rules, list) or not all(isinstance(rule, dict) for rule in existing_rules):
        raise GateError(f"Ruleset {ruleset_id} has no usable rules array")
    payload = {
        "name": current["name"],
        "target": "branch",
        "enforcement": "active",
        "conditions": current.get("conditions", {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}}),
        "rules": _required_rules(existing_rules),
    }
    if "bypass_actors" in current:
        payload["bypass_actors"] = current["bypass_actors"]
    return {"repository": repository, "ruleset_id": ruleset_id, "branch": branch, "payload": payload}


def _print_result(result: dict[str, Any], output_format: str) -> None:
    if output_format == "json":
        print(json.dumps(result, indent=2, sort_keys=True))
        return
    if "compliant" in result:
        print(f"required-gate: {'compliant' if result['compliant'] else 'non-compliant'}")
        print(f"project: {result['project']}")
        print(f"branch: {result['production_branch']}")
        print("lanes: " + ", ".join(lane["id"] for lane in result["lanes"]))
        for finding in result["findings"]:
            print(f"- {finding}")
    else:
        print(json.dumps(result, indent=2, sort_keys=True))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    for name in ("audit", "generate"):
        command = subparsers.add_parser(name)
        command.add_argument("--project", type=Path, required=True)
        command.add_argument("--format", choices=("text", "json"), default="text")
        if name == "generate":
            command.add_argument("--output", type=Path)
    for name in ("ruleset-plan", "ruleset-apply"):
        command = subparsers.add_parser(name)
        command.add_argument("--project", type=Path, required=True)
        command.add_argument("--repository", required=True)
        command.add_argument("--ruleset-id", type=int, required=True)
        command.add_argument("--format", choices=("text", "json"), default="text")
        if name == "ruleset-apply":
            command.add_argument("--confirm", required=True, help="Must equal APPLY_SHIPGLOWS_REQUIRED_GATE")
    return parser


def main(argv: Iterable[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "audit":
            result = audit_project(args.project)
            _print_result(result, args.format)
            return 0 if result["compliant"] else 1
        if args.command == "generate":
            contract = inspect_project(args.project)
            output = args.output or (args.project / WORKFLOW_RELATIVE)
            output = output.resolve()
            project = args.project.resolve()
            if project not in output.parents:
                raise GateError(f"Output must stay inside the project: {output}")
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(render_workflow(contract), encoding="utf-8", newline="\n")
            _print_result(audit_project(project), args.format)
            return 0
        plan = build_ruleset_plan(args.project, args.repository, args.ruleset_id)
        if args.command == "ruleset-apply":
            if args.confirm != "APPLY_SHIPGLOWS_REQUIRED_GATE":
                raise GateError("Refusing provider mutation without --confirm APPLY_SHIPGLOWS_REQUIRED_GATE")
            response = gh_api(args.repository, f"rulesets/{args.ruleset_id}", method="PUT", payload=plan["payload"])
            plan["applied"] = True
            plan["response_id"] = response.get("id")
        _print_result(plan, args.format)
        return 0
    except GateError as exc:
        print(f"required-gate error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
