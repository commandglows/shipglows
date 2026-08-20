#!/usr/bin/env python3
"""Manage the single public ShipGlows skill entrypoint for Codex developers."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile
import tomllib
from typing import Any


MARKETPLACE = "shipglows"
PLUGIN_ID = "shipglows@shipglows"
MARKETPLACE_SOURCE = "commandglows/shipglows"
SPARSE_PATHS = (".agents/plugins", "plugins/shipglows")
ROOT_STATE_RELATIVE = Path(".config/shipglows/linked-skill-root.json")
SHELL_BLOCK_START = "# >>> ShipGlows linked skill root >>>"
SHELL_BLOCK_END = "# <<< ShipGlows linked skill root <<<"


class SkillChannelError(RuntimeError):
    pass


def ensure_parent_within_home(path: Path, target_home: Path, label: str) -> None:
    try:
        path.parent.resolve().relative_to(target_home.resolve())
    except (OSError, ValueError) as exc:
        raise SkillChannelError(
            f"{label} sort du home ciblé via un lien ou un chemin non sûr : {path}"
        ) from exc


def ensure_parent_writable(path: Path, target_home: Path, label: str) -> None:
    parent = path.parent
    while not parent.exists() and parent != target_home:
        parent = parent.parent
    if not parent.is_dir() or not os.access(parent, os.W_OK | os.X_OK):
        raise SkillChannelError(
            f"{label} n'est pas modifiable par l'utilisateur courant : {parent}. "
            "Corrigez uniquement le propriétaire de ce dossier avant de relancer."
        )


def preflight_mutation_paths(target_home: Path) -> None:
    targets = (
        (target_home / ROOT_STATE_RELATIVE, "L'état de racine développeur"),
        (target_home / ".agents" / "skills" / "shipglows", "Le catalogue Codex"),
        (target_home / ".claude" / "skills" / "shipglows", "Le catalogue Claude"),
        (target_home / ".local" / "bin" / "shipglows", "Le launcher ShipGlows"),
    )
    for path, label in targets:
        ensure_parent_within_home(path, target_home, label)
        ensure_parent_writable(path, target_home, label)


def command_env(target_home: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["HOME"] = str(target_home)
    return env


def run(
    command: list[str],
    *,
    target_home: Path,
    capture: bool = False,
) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            command,
            check=True,
            text=True,
            capture_output=capture,
            env=command_env(target_home),
        )
    except FileNotFoundError as exc:
        raise SkillChannelError(f"Commande introuvable : {command[0]}") from exc
    except subprocess.CalledProcessError as exc:
        detail = (exc.stderr or exc.stdout or "").strip()
        suffix = f" : {detail}" if detail else ""
        raise SkillChannelError(
            f"Échec de la commande {' '.join(command)}{suffix}"
        ) from exc


def codex_bin() -> str:
    return os.environ.get("SHIPGLOWS_CODEX_BIN", "codex")


def plugin_ids(target_home: Path) -> list[str]:
    config = target_home / ".codex" / "config.toml"
    if not config.exists():
        return []
    try:
        with config.open("rb") as handle:
            data = tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise SkillChannelError(f"Configuration Codex illisible : {config}") from exc

    plugins = data.get("plugins", {})
    if not isinstance(plugins, dict):
        return []
    return sorted(
        name
        for name, settings in plugins.items()
        if name.startswith("shipglows@")
        and isinstance(settings, dict)
        and settings.get("enabled") is True
    )


def load_registry(root: Path) -> dict[str, str]:
    registry = root / "skills" / "references" / "skill-invocation-registry.json"
    try:
        data = json.loads(registry.read_text(encoding="utf-8"))
        catalog = data["public_catalog"]
        pairs: dict[str, str] = {}
        for domain in catalog["domains"]:
            for skill in domain["skills"]:
                pairs[skill["id"]] = skill.get("public_skill", skill["id"])
        router = catalog["router"]
        pairs[router["id"]] = router.get("public_skill", router["id"])
        return pairs
    except (OSError, KeyError, TypeError, json.JSONDecodeError) as exc:
        raise SkillChannelError(
            f"Registre public ShipGlows invalide : {registry}"
        ) from exc


def validate_shipglows_root(candidate: Path) -> Path:
    try:
        result = subprocess.run(
            ["git", "-C", str(candidate), "rev-parse", "--show-toplevel"],
            check=True,
            text=True,
            capture_output=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        raise SkillChannelError(
            "`shipglows skills link` doit être lancé depuis un clone Git ShipGlows."
        ) from exc

    root = Path(result.stdout.strip()).resolve()
    required = (
        root / "skills" / "shipglows" / "SKILL.md",
        root / "skills" / "references" / "skill-invocation-registry.json",
        root / "tools" / "shipglows_sync_skills.sh",
        root / "plugins" / "shipglows" / ".codex-plugin" / "plugin.json",
    )
    missing = [path for path in required if not path.is_file()]
    if missing:
        raise SkillChannelError(
            "Le dépôt Git courant n'est pas un clone ShipGlows complet : "
            + ", ".join(str(path.relative_to(root)) for path in missing)
        )
    load_registry(root)
    return root


def root_for_skill_target(target: Path) -> Path | None:
    try:
        resolved = target.resolve(strict=True)
    except (OSError, RuntimeError):
        return None
    if resolved.parent.name != "skills":
        return None
    root = resolved.parent.parent
    required = (
        resolved / "SKILL.md",
        root / "skills" / "references" / "skill-invocation-registry.json",
        root / "skills" / "shipglows" / "SKILL.md",
    )
    return root if all(path.is_file() for path in required) else None


def root_for_cli_target(target: Path) -> Path | None:
    try:
        resolved = target.resolve(strict=True)
    except (OSError, RuntimeError):
        return None
    if resolved.name != "shipglows.sh" or resolved.parent.name != "cli":
        return None
    root = resolved.parent.parent
    required = (
        root / "cli" / "shipglows.sh",
        root / "skills" / "shipglows" / "SKILL.md",
        root / "skills" / "references" / "skill-invocation-registry.json",
    )
    return root if all(path.is_file() for path in required) else None


def wrapper_cli_target(path: Path) -> Path | None:
    if path.is_symlink():
        return path
    if not path.is_file():
        return None
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError:
        return None
    exec_lines = [line.strip() for line in lines if line.strip().startswith("exec ")]
    if len(exec_lines) != 1:
        return None
    try:
        tokens = shlex.split(exec_lines[0])
    except ValueError:
        return None
    if len(tokens) != 3 or tokens[0] != "exec" or tokens[2] != "$@":
        return None
    return Path(tokens[1])


def launcher_paths(target_home: Path) -> list[Path]:
    bin_dir = target_home / ".local" / "bin"
    if bin_dir.exists() and (bin_dir.is_symlink() or not bin_dir.is_dir()):
        return []
    return [bin_dir / "shipglows", bin_dir / "sg"]


def configure_launchers(target_home: Path, root: Path) -> list[Path]:
    target = root / "cli" / "shipglows.sh"
    skipped: list[Path] = []
    for launcher in launcher_paths(target_home):
        if launcher.exists() or launcher.is_symlink():
            current_target = wrapper_cli_target(launcher)
            if current_target is None or root_for_cli_target(current_target) is None:
                skipped.append(launcher)
                continue
        launcher.parent.mkdir(parents=True, exist_ok=True)
        temporary = launcher.parent / f".{launcher.name}.shipglows-link-{os.getpid()}"
        if temporary.exists() or temporary.is_symlink():
            temporary.unlink()
        try:
            temporary.symlink_to(target)
            os.replace(temporary, launcher)
        finally:
            if temporary.exists() or temporary.is_symlink():
                temporary.unlink()
    return skipped


def clear_launchers(target_home: Path) -> list[Path]:
    default_root = (target_home / ".shipglows" / "runtime").resolve()
    default_target = default_root / "cli" / "shipglows.sh"
    skipped: list[Path] = []
    for launcher in launcher_paths(target_home):
        if not launcher.exists() and not launcher.is_symlink():
            continue
        current_target = wrapper_cli_target(launcher)
        current_root = root_for_cli_target(current_target) if current_target else None
        if current_root is None:
            skipped.append(launcher)
            continue
        if current_root == default_root:
            continue
        if root_for_cli_target(default_target) is not None:
            temporary = launcher.parent / f".{launcher.name}.shipglows-link-{os.getpid()}"
            if temporary.exists() or temporary.is_symlink():
                temporary.unlink()
            try:
                temporary.symlink_to(default_target)
                os.replace(temporary, launcher)
            finally:
                if temporary.exists() or temporary.is_symlink():
                    temporary.unlink()
        elif launcher.is_symlink():
            launcher.unlink()
        else:
            skipped.append(launcher)
    return skipped


def link_description(path: Path) -> dict[str, str]:
    if path.is_symlink():
        root = root_for_skill_target(path)
        if root is not None:
            return {"state": "managed", "root": str(root)}
        return {"state": "foreign", "root": ""}
    if path.exists():
        return {"state": "foreign", "root": ""}
    return {"state": "absent", "root": ""}


def linked_root_state(target_home: Path) -> str:
    state_file = target_home / ROOT_STATE_RELATIVE
    if not state_file.exists():
        return ""
    try:
        payload = json.loads(state_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SkillChannelError(f"État de racine développeur illisible : {state_file}") from exc
    if payload.get("managed_by") != "shipglows-skills-link":
        raise SkillChannelError(f"État de racine développeur non géré : {state_file}")
    root = payload.get("root")
    if not isinstance(root, str) or not root:
        raise SkillChannelError(f"Racine développeur invalide : {state_file}")
    return str(Path(root).expanduser().resolve())


def strip_shell_block(content: str) -> str:
    lines = content.splitlines(keepends=True)
    output: list[str] = []
    inside = False
    found_end = False
    block_count = 0
    for line in lines:
        marker = line.rstrip("\r\n")
        if marker == SHELL_BLOCK_START:
            block_count += 1
            if inside or block_count > 1:
                raise SkillChannelError("Bloc shell ShipGlows dupliqué ou imbriqué.")
            inside = True
            continue
        if marker == SHELL_BLOCK_END:
            if not inside:
                raise SkillChannelError("Fin de bloc shell ShipGlows sans début.")
            inside = False
            found_end = True
            continue
        if not inside:
            output.append(line)
    if inside:
        raise SkillChannelError("Bloc shell ShipGlows incomplet.")
    if found_end:
        while output and not output[-1].strip():
            output.pop()
        if output:
            output[-1] = output[-1].rstrip("\r\n") + "\n"
    return "".join(output)


def shell_files(target_home: Path) -> list[Path]:
    return [path for path in (target_home / ".bashrc", target_home / ".zshrc") if path.exists()]


def preflight_shell_files(target_home: Path) -> None:
    for path in shell_files(target_home):
        if path.is_symlink() or not path.is_file():
            raise SkillChannelError(
                f"Le fichier shell {path} n'est pas un fichier régulier gérable."
            )
        if not os.access(path, os.W_OK):
            raise SkillChannelError(f"Le fichier shell {path} n'est pas modifiable.")
        strip_shell_block(path.read_text(encoding="utf-8"))


def atomic_write(path: Path, content: str, mode: int | None = None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        if mode is not None:
            os.chmod(temporary, mode)
        elif path.exists():
            os.chmod(temporary, path.stat().st_mode & 0o777)
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def configure_linked_root(target_home: Path, root: Path) -> None:
    state_file = target_home / ROOT_STATE_RELATIVE
    payload = json.dumps(
        {"managed_by": "shipglows-skills-link", "root": str(root)},
        ensure_ascii=False,
        indent=2,
        sort_keys=True,
    ) + "\n"
    atomic_write(state_file, payload, 0o600)

    block = (
        f"\n{SHELL_BLOCK_START}\n"
        f"export SHIPGLOWS_ROOT={shlex.quote(str(root))}\n"
        f"{SHELL_BLOCK_END}\n"
    )
    for path in shell_files(target_home):
        original = path.read_text(encoding="utf-8")
        cleaned = strip_shell_block(original).rstrip("\r\n") + "\n"
        atomic_write(path, cleaned + block)


def clear_linked_root(target_home: Path) -> None:
    state_file = target_home / ROOT_STATE_RELATIVE
    if state_file.exists():
        linked_root_state(target_home)
        state_file.unlink()
    for path in shell_files(target_home):
        original = path.read_text(encoding="utf-8")
        cleaned = strip_shell_block(original)
        if cleaned != original:
            atomic_write(path, cleaned.rstrip("\r\n") + "\n")


def channel_status(target_home: Path) -> dict[str, Any]:
    plugins = plugin_ids(target_home)
    codex_router = link_description(target_home / ".agents" / "skills" / "shipglows")
    claude_router = link_description(target_home / ".claude" / "skills" / "shipglows")

    configured_root = linked_root_state(target_home)
    default_root = str((target_home / ".shipglows" / "runtime").resolve())
    root_mismatch = False
    if codex_router["state"] == "managed":
        root_mismatch = bool(
            (configured_root and configured_root != codex_router["root"])
            or (not configured_root and codex_router["root"] != default_root)
        )
    elif configured_root:
        root_mismatch = True

    if codex_router["state"] == "foreign" or root_mismatch:
        state = "conflict"
    elif plugins and codex_router["state"] == "managed":
        state = "conflict"
    elif codex_router["state"] == "managed":
        state = "linked"
    elif plugins:
        state = "plugin"
    else:
        state = "none"
    return {
        "state": state,
        "plugin_ids": plugins,
        "codex_router": codex_router,
        "claude_router": claude_router,
        "configured_root": configured_root,
    }


def print_status(status: dict[str, Any], as_json: bool) -> None:
    if as_json:
        print(json.dumps(status, ensure_ascii=False, sort_keys=True))
        return
    print(f"Canal Codex ShipGlows : {status['state']}")
    if status["plugin_ids"]:
        print("Plugin actif : " + ", ".join(status["plugin_ids"]))
    for runtime, field in (("Codex", "codex_router"), ("Claude", "claude_router")):
        link = status[field]
        if link["state"] == "managed":
            print(f"Liens {runtime} : {link['root']}")
        elif link["state"] == "foreign":
            print(f"Liens {runtime} : conflit non géré")
    if status["configured_root"]:
        print(f"Racine développeur : {status['configured_root']}")


def confirm(message: str, assume_yes: bool) -> None:
    if assume_yes:
        return
    if not sys.stdin.isatty():
        raise SkillChannelError(f"Confirmation requise : {message} Relancez avec --yes.")
    answer = input(f"{message} [y/N] ").strip().lower()
    if answer not in {"y", "yes", "o", "oui"}:
        raise SkillChannelError("Action annulée.")


def remove_plugins(target_home: Path, assume_yes: bool) -> None:
    selectors = plugin_ids(target_home)
    if not selectors:
        return
    confirm(
        "Retirer le plugin Codex ShipGlows pour activer les liens de développement ?",
        assume_yes,
    )
    for selector in selectors:
        run(
            [codex_bin(), "plugin", "remove", selector, "--json"],
            target_home=target_home,
        )
    if plugin_ids(target_home):
        raise SkillChannelError("Le plugin ShipGlows est encore actif après son retrait.")


def marketplace_exists(target_home: Path) -> bool:
    result = run(
        [codex_bin(), "plugin", "marketplace", "list", "--json"],
        target_home=target_home,
        capture=True,
    )
    try:
        payload = json.loads(result.stdout)
        matches = [
            item
            for item in payload.get("marketplaces", [])
            if isinstance(item, dict) and item.get("name") == MARKETPLACE
        ]
        if not matches:
            return False
        source = matches[0].get("marketplaceSource", {}).get("source", "")
        accepted = {
            MARKETPLACE_SOURCE,
            f"https://github.com/{MARKETPLACE_SOURCE}",
            f"https://github.com/{MARKETPLACE_SOURCE}.git",
        }
        if source not in accepted:
            raise SkillChannelError(
                "Une marketplace nommée shipglows existe mais ne pointe pas vers "
                "le dépôt officiel commandglows/shipglows."
            )
        return True
    except (AttributeError, json.JSONDecodeError) as exc:
        raise SkillChannelError("Réponse marketplace Codex invalide.") from exc


def install_plugin(target_home: Path, assume_yes: bool) -> None:
    codex_router = target_home / ".agents" / "skills" / "shipglows"
    if codex_router.exists() or codex_router.is_symlink():
        raise SkillChannelError(
            "Des liens développeur occupent `$shipglows`. Lancez d'abord "
            "`shipglows skills unlink`."
        )
    active_plugins = plugin_ids(target_home)
    if active_plugins == [PLUGIN_ID]:
        print("Plugin Codex ShipGlows déjà actif.")
        return
    if active_plugins:
        raise SkillChannelError(
            "Un plugin ShipGlows provenant d'une autre marketplace est actif : "
            + ", ".join(active_plugins)
        )
    confirm("Installer le plugin Codex ShipGlows officiel ?", assume_yes)
    if not marketplace_exists(target_home):
        command = [
            codex_bin(),
            "plugin",
            "marketplace",
            "add",
            MARKETPLACE_SOURCE,
            "--ref",
            "main",
        ]
        for sparse_path in SPARSE_PATHS:
            command.extend(("--sparse", sparse_path))
        command.append("--json")
        run(command, target_home=target_home)
    run(
        [codex_bin(), "plugin", "add", PLUGIN_ID, "--json"],
        target_home=target_home,
    )
    if not plugin_ids(target_home):
        raise SkillChannelError("Codex n'a pas confirmé l'activation du plugin ShipGlows.")
    print("Plugin Codex ShipGlows installé. Ouvrez une nouvelle conversation Codex.")


def preflight_links(root: Path, target_home: Path) -> None:
    pairs = load_registry(root)
    for runtime_dir in (
        target_home / ".agents" / "skills",
        target_home / ".claude" / "skills",
    ):
        for public_name, source_name in pairs.items():
            target = runtime_dir / public_name
            if not target.exists() and not target.is_symlink():
                continue
            expected = (root / "skills" / source_name).resolve()
            if target.is_symlink():
                try:
                    actual = target.resolve(strict=True)
                except (OSError, RuntimeError):
                    actual = None
                if actual == expected:
                    continue
                other_root = root_for_skill_target(target)
                if other_root is not None:
                    raise SkillChannelError(
                        f"{target} pointe vers un autre clone ShipGlows ({other_root}). "
                        "Lancez `shipglows skills unlink` avant de changer de clone."
                    )
            raise SkillChannelError(
                f"{target} existe mais n'est pas un lien ShipGlows compatible ; "
                "aucun fichier utilisateur n'a été remplacé."
            )


def link_skills(args: argparse.Namespace, target_home: Path) -> None:
    root = validate_shipglows_root(Path(args.root or Path.cwd()))
    preflight_mutation_paths(target_home)
    preflight_links(root, target_home)
    preflight_shell_files(target_home)
    remove_plugins(target_home, args.yes)
    helper = root / "tools" / "shipglows_sync_skills.sh"
    base = [
        "bash",
        str(helper),
        "--all",
        "--runtime",
        "all",
        "--catalog",
        "public",
        "--target-home",
        str(target_home),
        "--shipglows-root",
        str(root),
        "--codex-entrypoint",
        "linked",
    ]
    run(base[:2] + ["--repair"] + base[2:], target_home=target_home)
    run(base[:2] + ["--check"] + base[2:], target_home=target_home)
    configure_linked_root(target_home, root)
    skipped_launchers = configure_launchers(target_home, root)
    status = channel_status(target_home)
    if status["state"] != "linked":
        raise SkillChannelError("Les liens ont été créés mais le canal Codex reste incohérent.")
    print(f"Skills ShipGlows liés au clone : {root}")
    for launcher in skipped_launchers:
        print(f"Avertissement : launcher personnel non géré préservé : {launcher}")
    print("Redémarrez Codex ou Claude depuis un nouveau shell pour charger la racine et le catalogue.")


def managed_public_links(target_home: Path) -> list[tuple[Path, int, int, str]]:
    found: list[tuple[Path, int, int, str]] = []
    for runtime_dir in (
        target_home / ".agents" / "skills",
        target_home / ".claude" / "skills",
    ):
        if not runtime_dir.is_dir():
            continue
        for target in runtime_dir.iterdir():
            if not target.is_symlink():
                continue
            root = root_for_skill_target(target)
            if root is None:
                continue
            try:
                pairs = load_registry(root)
                source_name = pairs.get(target.name)
                resolved = target.resolve(strict=True)
            except (SkillChannelError, OSError, RuntimeError):
                continue
            if source_name and resolved == (root / "skills" / source_name).resolve():
                stat = target.lstat()
                found.append((target, stat.st_dev, stat.st_ino, os.readlink(target)))
    return found


def unlink_skills(args: argparse.Namespace, target_home: Path) -> None:
    preflight_mutation_paths(target_home)
    links = managed_public_links(target_home)
    preflight_shell_files(target_home)
    if links:
        confirm(
            f"Retirer {len(links)} lien(s) public(s) ShipGlows géré(s) ?",
            args.yes,
        )
        for link, expected_dev, expected_ino, expected_target in links:
            try:
                current = link.lstat()
                current_target = os.readlink(link)
            except OSError as exc:
                raise SkillChannelError(
                    f"Le lien a changé avant son retrait : {link}"
                ) from exc
            if (
                current.st_dev != expected_dev
                or current.st_ino != expected_ino
                or current_target != expected_target
            ):
                raise SkillChannelError(
                    f"Le lien a changé avant son retrait : {link}"
                )
            link.unlink()
        print(f"{len(links)} lien(s) ShipGlows retiré(s).")
    else:
        print("Aucun lien public ShipGlows géré n'est installé.")
    clear_linked_root(target_home)
    skipped_launchers = clear_launchers(target_home)
    for launcher in skipped_launchers:
        print(f"Avertissement : launcher personnel non géré préservé : {launcher}")

    if args.install_plugin:
        install_plugin(target_home, True)
    elif sys.stdin.isatty() and not plugin_ids(target_home):
        answer = input("Installer maintenant le plugin Codex officiel ? [y/N] ").strip().lower()
        if answer in {"y", "yes", "o", "oui"}:
            install_plugin(target_home, True)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        prog="shipglows skills",
        description="Choisir entre le plugin public Codex et les skills live d'un clone ShipGlows.",
    )
    result.add_argument(
        "--target-home",
        default=os.environ.get("SHIPGLOWS_TARGET_HOME", str(Path.home())),
        help=argparse.SUPPRESS,
    )
    commands = result.add_subparsers(dest="command", required=True)

    status_parser = commands.add_parser("status", help="Afficher le canal ShipGlows actif")
    status_parser.add_argument("--json", action="store_true")

    link_parser = commands.add_parser("link", help="Lier un clone Git ShipGlows aux agents locaux")
    link_parser.add_argument("--root", help="Clone ShipGlows à utiliser (défaut : dépôt courant)")
    link_parser.add_argument("--yes", action="store_true", help="Confirmer les actions prévues")

    unlink_parser = commands.add_parser("unlink", help="Retirer uniquement les liens ShipGlows gérés")
    unlink_parser.add_argument("--yes", action="store_true", help="Confirmer le retrait des liens")
    unlink_parser.add_argument(
        "--install-plugin",
        action="store_true",
        help="Installer ensuite le plugin Codex officiel",
    )

    install_parser = commands.add_parser(
        "plugin-install", help="Installer ou réactiver le plugin Codex officiel"
    )
    install_parser.add_argument("--yes", action="store_true")

    remove_parser = commands.add_parser(
        "plugin-remove", help="Retirer le plugin Codex ShipGlows actif"
    )
    remove_parser.add_argument("--yes", action="store_true")
    return result


def main() -> int:
    args = parser().parse_args()
    target_home = Path(args.target_home).expanduser().resolve()
    try:
        if args.command == "status":
            print_status(channel_status(target_home), args.json)
        elif args.command == "link":
            link_skills(args, target_home)
        elif args.command == "unlink":
            unlink_skills(args, target_home)
        elif args.command == "plugin-install":
            install_plugin(target_home, args.yes)
        elif args.command == "plugin-remove":
            remove_plugins(target_home, args.yes)
        return 0
    except SkillChannelError as exc:
        print(f"Erreur : {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
