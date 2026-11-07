#!/usr/bin/env python3
"""Drive a real browser through agent-browser with ShipGlows safety defaults.

`shipglows-browse` forwards every argument to the `agent-browser` CLI
(`open`, `snapshot`, `click @e2`, `fill`, `screenshot`, `batch`, `a11y`, ...)
after applying defaults that suit an agent reading untrusted web pages:

- an isolated, throwaway session (`shipglows` unless --session or
  AGENT_BROWSER_SESSION names another), so no cookies leak between tasks;
- page output wrapped in content-boundary markers and capped in length;
- no attachment to a personal browser: --profile, --auto-connect, --cdp and
  --state are refused unless SHIPGLOWS_BROWSE_ALLOW_PERSONAL=1.

Extensions are not tested here: use `s extension-lab`. Passwords belong in the
agent-browser auth vault (`auth save` / `auth login`), never in a prompt.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

BINARY = "agent-browser"
DEFAULT_SESSION = "shipglows"
DEFAULT_MAX_OUTPUT = "50000"
PERSONAL_ENV = "SHIPGLOWS_BROWSE_ALLOW_PERSONAL"
PERSONAL_FLAGS = ("--profile", "--auto-connect", "--cdp", "--state")
EXIT_USAGE = 2
EXIT_MISSING = 127


def personal_flag(argv: list[str]) -> str | None:
    """The first argument that attaches to a personal browser profile or session, if any."""
    for arg in argv:
        for flag in PERSONAL_FLAGS:
            if arg == flag or arg.startswith(flag + "="):
                return flag
    return None


def build_environment(environ: dict[str, str]) -> dict[str, str]:
    env = dict(environ)
    env.setdefault("AGENT_BROWSER_SESSION", DEFAULT_SESSION)
    env.setdefault("AGENT_BROWSER_CONTENT_BOUNDARIES", "1")
    env.setdefault("AGENT_BROWSER_MAX_OUTPUT", DEFAULT_MAX_OUTPUT)
    return env


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    flag = personal_flag(argv)
    if flag and os.environ.get(PERSONAL_ENV) != "1":
        print(f"shipglows-browse: {flag} attaches to a personal browser and is refused; "
              f"set {PERSONAL_ENV}=1 for a deliberate exception.", file=sys.stderr)
        return EXIT_USAGE
    binary = shutil.which(BINARY)
    if not binary:
        print("shipglows-browse: agent-browser is not installed; run `npm i -g agent-browser && agent-browser install`.",
              file=sys.stderr)
        return EXIT_MISSING
    return subprocess.call([binary, *argv], env=build_environment(os.environ))


if __name__ == "__main__":
    raise SystemExit(main())
