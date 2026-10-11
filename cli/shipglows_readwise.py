#!/usr/bin/env python3
"""ShipGlows entry point for the official Readwise CLI; no custom API client."""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from readwise_oauth import OAuthError, login as oauth_login

PACKAGE = "@readwise/cli@0.5.10"
TOKEN_ENV = "READWISE_ACCESS_TOKEN"
HELP = """Readwise / Reader — votre bibliothèque personnelle dans ShipGlows

Usage : shipglows readwise <commande> [options]
        shipglows-readwise <commande> [options]

  setup                    Installer @readwise/cli et activer la lecture seule
  status                   État local, sans requête ni affichage des secrets
  login                    Connexion OAuth dans le navigateur
  login --token            Connexion sans OAuth, saisie masquée dans le terminal
  login-with-token         Connexion via READWISE_ACCESS_TOKEN (environnement)
  help                     Aide du CLI officiel et commandes disponibles
  --version                Version du CLI officiel

Toutes les autres commandes et options sont transmises au CLI officiel :
  reader-list-documents --location new
  reader-search-documents --query "architecture"
  reader-get-document-details --document-id <id>
  readwise-search-highlights --vector-search-term "architecture"
  config get readonly

setup et login-with-token conservent la configuration/session officielle dans
~/.readwise-cli.json. Ne placez pas ce fichier dans un dépôt. Le mode readonly
est celui du fournisseur, pas une restriction OAuth imposée par ShipGlows.
Documentation : https://docs.readwise.io/tools/cli
"""


class ReadwiseError(RuntimeError):
    """A local diagnostic containing no credentials."""


def executable(name: str) -> list[str]:
    """Run npm's Windows shims through Node, avoiding cmd.exe interpolation."""
    found = shutil.which(name)
    if not found:
        hint = "Installez Node.js/npm." if name == "npm" else "Lancez shipglows readwise setup."
        raise ReadwiseError(f"{name} introuvable. {hint}")
    path = Path(found)
    if path.suffix.lower() in (".cmd", ".bat", ".ps1"):
        node = shutil.which("node")
        relative = Path("node_modules") / (
            "npm/bin/npm-cli.js" if name == "npm" else "@readwise/cli/dist/index.js"
        )
        # ShipGlows can put its own npm shim first on PATH. Find the official
        # Node entry without executing or parsing a batch-file command string.
        directories = [path.parent] + [Path(item) for item in os.get_exec_path() if item]
        if node and name == "npm":
            directories.append(Path(node).parent)
        entry = next((directory / relative for directory in directories if (directory / relative).is_file()), None)
        if not node or entry is None:
            raise ReadwiseError(f"Installation {name} incomplète : réinstallez le paquet officiel.")
        return [node, str(entry)]
    return [found]


def invoke(command: list[str], *, token: str | None = None) -> int:
    # Do not pass Doppler's token to the child environment or process arguments.
    environment = os.environ.copy()
    environment.pop(TOKEN_ENV, None)
    kwargs = {"env": environment, "check": False}
    if token is not None:
        kwargs.update(input=token + "\n", text=True)
    return subprocess.run(command, **kwargs).returncode


def status() -> int:
    config_path = Path.home() / ".readwise-cli.json"
    config = {}
    if config_path.exists():
        try:
            config = json.loads(config_path.read_text(encoding="utf-8"))
            if not isinstance(config, dict) or not isinstance(config.get("config", {}), dict):
                raise ValueError
        except (OSError, ValueError):
            raise ReadwiseError("Configuration Readwise illisible ; aucun secret affiché.") from None
    installed = shutil.which("readwise") is not None
    next_command = "shipglows readwise setup" if not installed else "shipglows readwise help"
    if installed and not config.get("access_token"):
        next_command = "shipglows readwise login"
    print(json.dumps({
        "provider": "readwise",
        "installed": installed,
        "credentials_present": bool(config.get("access_token")),
        "readonly": config.get("config", {}).get("readonly", False) is True,
        "environment_token_present": bool(os.environ.get(TOKEN_ENV)),
        "connection_verified": False,
        "next_command": next_command,
    }, ensure_ascii=False, indent=2))
    return 0


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    try:
        if not args or args in (["--help"], ["-h"]):
            print(HELP)
            return 0
        # Never let login with official global flags fall back to its fixed port.
        auth_args = args[:]
        while auth_args and auth_args[0] in ("--json", "--refresh"):
            auth_args.pop(0)
        if auth_args and auth_args[0] == "login":
            if any(value not in ("login", "--token", "--json", "--refresh", "--help", "-h") for value in auth_args):
                raise ReadwiseError("Usage : shipglows readwise login [--token]")
            if "--help" in auth_args or "-h" in auth_args:
                print(HELP)
                return 0
            args = ["login", "--token"] if "--token" in auth_args else ["login"]
        if "login-with-token" in args and args != ["login-with-token"]:
            raise ReadwiseError("login-with-token n'accepte aucun argument. Utilisez READWISE_ACCESS_TOKEN dans l'environnement.")
        if args[0] in ("setup", "status") and len(args) != 1:
            raise ReadwiseError(f"{args[0]} n'accepte aucun argument. Aucun token ne doit figurer dans la commande.")
        if args == ["status"]:
            return status()
        if args == ["setup"]:
            code = invoke(executable("npm") + ["install", "--global", PACKAGE, "--ignore-scripts"])
            if code:
                return code
            code = invoke(executable("readwise") + ["config", "set", "readonly", "true"])
            if code == 0:
                print("Readwise installé en lecture seule. Suite : shipglows readwise login")
            return code
        if args == ["login"]:
            executable("readwise")  # The session consumer must be installed.
            oauth_login()
            return 0
        if args in (["login-with-token"], ["login", "--token"]):
            token = os.environ.get(TOKEN_ENV, "")
            if not token and sys.stdin.isatty():
                return invoke(executable("readwise") + ["login-with-token"])
            if not token or any(char in token for char in "\r\n\0"):
                raise ReadwiseError(f"{TOKEN_ENV} absent ou invalide. Fournissez-le via votre environnement local, ou lancez login --token dans un terminal interactif.")
            return invoke(executable("readwise") + ["login-with-token"], token=token)
        if args == ["help"]:
            args = ["--help"]
        return invoke(executable("readwise") + args)
    except (ReadwiseError, OAuthError) as error:
        print(f"shipglows-readwise: {error}", file=sys.stderr)
        return 2
    except OSError:
        print("shipglows-readwise: lancement impossible ; vérifiez l'installation Node.js/Readwise.", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    # Native Windows pipes otherwise use a legacy code page and corrupt accents.
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", line_buffering=True)
    raise SystemExit(main())
