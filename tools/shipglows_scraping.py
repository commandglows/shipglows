#!/usr/bin/env python3
"""Install and run the local search/scraping stack (SearXNG + Crawl4AI).

`up` is the one command a new computer needs: it checks Docker, creates the
git-ignored Crawl4AI token once, starts the loopback containers and waits until
both answer. The containers restart with Docker afterwards.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys
import time
from urllib.error import URLError
from urllib.request import Request, urlopen

STACK_DIR = Path(__file__).resolve().parent.parent / "local" / "scraping"
COMPOSE_FILE = STACK_DIR / "docker-compose.yml"
ENV_FILE = STACK_DIR / ".env"
TOKEN_NAME = "CRAWL4AI_API_TOKEN"
SEARXNG_URL = os.environ.get("SHIPGLOWS_SEARXNG_URL", "http://127.0.0.1:8888").rstrip("/")
CRAWL4AI_URL = os.environ.get("SHIPGLOWS_CRAWL4AI_URL", "http://127.0.0.1:11235").rstrip("/")
READY_TIMEOUT = 120.0


class StackError(RuntimeError):
    pass


def crawl4ai_token() -> str:
    """Token from the environment, else from local/scraping/.env; empty when neither exists."""
    value = os.environ.get(TOKEN_NAME, "").strip()
    if value or not ENV_FILE.is_file():
        return value
    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        key, _, raw = line.partition("=")
        if key.strip() == TOKEN_NAME:
            return raw.strip().strip('"').strip("'")
    return ""


def ensure_token() -> bool:
    """Create the token file once; return True when it was created."""
    if crawl4ai_token():
        return False
    STACK_DIR.mkdir(parents=True, exist_ok=True)
    with ENV_FILE.open("a", encoding="utf-8", newline="\n") as handle:
        handle.write(f"{TOKEN_NAME}={secrets.token_hex(32)}\n")
    return True


def docker_ready() -> tuple[bool, str]:
    if not shutil.which("docker"):
        return False, "Docker is not installed (Windows: winget install Docker.DockerDesktop)."
    probe = subprocess.run(["docker", "info", "--format", "{{.ServerVersion}}"], capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=30)
    if probe.returncode != 0:
        return False, "The Docker daemon is not running; start Docker Desktop and retry."
    return True, probe.stdout.strip()


def compose(*args: str, capture: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(["docker", "compose", "-f", str(COMPOSE_FILE), *args],
                          capture_output=capture, text=True, encoding="utf-8", errors="replace", timeout=1800)


def probe(url: str, token: str = "") -> bool:
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    try:
        with urlopen(Request(url, headers=headers), timeout=5) as response:
            return 200 <= response.status < 300
    except (URLError, OSError, ValueError):
        return False


def health() -> dict:
    return {
        "searxng": {"url": SEARXNG_URL, "ready": probe(f"{SEARXNG_URL}/search?q=shipglows&format=json")},
        "crawl4ai": {"url": CRAWL4AI_URL, "ready": probe(f"{CRAWL4AI_URL}/health")},
    }


def wait_ready(deadline: float) -> dict:
    state = health()
    while not all(service["ready"] for service in state.values()) and time.monotonic() < deadline:
        time.sleep(2)
        state = health()
    return state


def command_up(_args) -> int:
    ok, detail = docker_ready()
    if not ok:
        raise StackError(detail)
    if ensure_token():
        print(f"shipglows-scraping: created {ENV_FILE} (git-ignored Crawl4AI token).", file=sys.stderr)
    if compose("up", "-d", "--remove-orphans").returncode != 0:
        raise StackError("docker compose up failed; see the output above.")
    state = wait_ready(time.monotonic() + READY_TIMEOUT)
    print(json.dumps(state, indent=2))
    return 0 if all(service["ready"] for service in state.values()) else 1


def command_down(_args) -> int:
    ok, detail = docker_ready()
    if not ok:
        raise StackError(detail)
    return compose("down").returncode


def command_status(_args) -> int:
    ok, detail = docker_ready()
    containers = []
    if ok:
        listing = compose("ps", "--all", "--format", "json", capture=True)
        for line in listing.stdout.splitlines():
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            for entry in item if isinstance(item, list) else [item]:
                containers.append({"service": entry.get("Service"), "state": entry.get("State"), "status": entry.get("Status")})
    state = health()
    print(json.dumps({
        "docker": {"ready": ok, "detail": detail},
        "token_file": ENV_FILE.is_file(),
        "containers": containers,
        **state,
    }, indent=2))
    return 0 if all(service["ready"] for service in state.values()) else 1


def command_logs(args) -> int:
    return compose("logs", "--tail", str(args.tail), *([args.service] if args.service else [])).returncode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="shipglows-scraping",
        description="Local search/scraping stack: SearXNG (127.0.0.1:8888) and Crawl4AI (127.0.0.1:11235).")
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("up", aliases=["install", "start"], help="create the token if needed, start and wait until ready") \
        .set_defaults(handler=command_up)
    commands.add_parser("down", aliases=["stop"], help="stop and remove the containers").set_defaults(handler=command_down)
    commands.add_parser("status", help="print Docker, container and endpoint health; exit 1 when not ready") \
        .set_defaults(handler=command_status)
    logs = commands.add_parser("logs", help="show recent container logs")
    logs.add_argument("service", nargs="?", choices=("searxng", "crawl4ai"))
    logs.add_argument("--tail", type=int, default=100)
    logs.set_defaults(handler=command_logs)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        return args.handler(args)
    except (StackError, subprocess.TimeoutExpired) as error:
        print(f"shipglows-scraping: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
