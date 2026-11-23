#!/usr/bin/env python3
"""Declarative product-site wiring for ShipGlows context events.

A product repository declares its public sites in ``.shipglows.product-updates.json``.
After ``context_history.py append`` records an event carrying a ``public`` object,
the event is projected into every declared site: draft update entries
(``@shipglows/astro-updates``) and roadmap status changes (``@shipglows/astro-roadmap``),
linked both ways when an item ships. ``pending`` and ``publish`` are the operator's
review gate: agents write drafts and hidden items, a human publishes them.

Standard library only. Frontmatter is edited line by line (top-level keys only),
never re-serialized, so human formatting and the Markdown body are preserved.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path, PurePosixPath
from typing import Any, Iterable
import json
import re
import sys

_ch = sys.modules.get("tools.context_history") or sys.modules.get("context_history")
if _ch is None:
    try:
        from tools import context_history as _ch
    except ModuleNotFoundError:  # direct ``python tools/...`` execution
        import context_history as _ch  # type: ignore[no-redef]

ContextHistoryError = _ch.ContextHistoryError

CONFIG_FILE = ".shipglows.product-updates.json"
CONFIG_SCHEMA = "shipglows.product-updates/v1"
ROADMAP_PACKAGE = "@shipglows/astro-roadmap"
ROADMAP_RELATIVE = Path("src/content/roadmap")
MAX_CONFIG_BYTES = 16 * 1024
MAX_SITES = 8
MAX_SITE_PRODUCTS = 8
MAX_SCAN_FILES = 5_000
LINKABLE_STATUSES = ("in_progress", "shipped")
TOP_KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)[ \t]*:(?:[ \t]+(.*))?$")
BARE_VALUE_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")


class UnsupportedFrontmatter(ContextHistoryError):
    """A frontmatter shape this line editor refuses to touch (reported, never forced)."""


# --------------------------------------------------------------------------- config


@dataclass(frozen=True)
class SiteTarget:
    declared: str
    root: Path
    products: tuple[str, ...]


@dataclass(frozen=True)
class ProductUpdatesConfig:
    path: Path
    sites: tuple[SiteTarget, ...]


def load_config(project_root: str | Path) -> ProductUpdatesConfig | None:
    """Read ``.shipglows.product-updates.json``; ``None`` when the repository has none."""
    root = _ch.resolve_project_root(project_root)
    path = root / CONFIG_FILE
    if not path.exists():
        return None
    if path.is_symlink() or not path.is_file() or path.stat().st_size > MAX_CONFIG_BYTES:
        raise ContextHistoryError(f"{CONFIG_FILE} must be a regular file under {MAX_CONFIG_BYTES} bytes.")
    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise ContextHistoryError(f"{CONFIG_FILE} is unreadable JSON.") from error
    if not isinstance(raw, dict) or set(raw) - {"schema", "sites"} or raw.get("schema") != CONFIG_SCHEMA:
        raise ContextHistoryError(f"{CONFIG_FILE} must be {{ \"schema\": \"{CONFIG_SCHEMA}\", \"sites\": [...] }}.")
    sites = raw.get("sites")
    if not isinstance(sites, list) or not 1 <= len(sites) <= MAX_SITES:
        raise ContextHistoryError(f"{CONFIG_FILE} sites must list 1 to {MAX_SITES} sites.")
    targets: list[SiteTarget] = []
    for site in sites:
        if not isinstance(site, dict) or set(site) != {"root", "products"}:
            raise ContextHistoryError(f"{CONFIG_FILE} sites accept exactly root and products.")
        declared = site["root"]
        if not isinstance(declared, str) or not declared or declared.startswith("~") or "\0" in declared:
            raise ContextHistoryError(f"{CONFIG_FILE} site root must be a relative path.")
        if PurePosixPath(declared.replace("\\", "/")).is_absolute() or re.match(r"^[A-Za-z]:", declared):
            raise ContextHistoryError(f"{CONFIG_FILE} site root must be relative to the repository root.")
        resolved = (root / declared).resolve()
        if not resolved.is_dir():
            raise ContextHistoryError(f"{CONFIG_FILE} site root is unavailable: {declared}")
        products = site["products"]
        if (
            not isinstance(products, list)
            or not 1 <= len(products) <= MAX_SITE_PRODUCTS
            or len(set(products)) != len(products)
            or not all(
                isinstance(key, str) and len(key) <= _ch.MAX_PRODUCT_KEY and _ch.UPDATE_SLUG_RE.fullmatch(key)
                for key in products
            )
        ):
            raise ContextHistoryError(f"{CONFIG_FILE} products must be 1 to {MAX_SITE_PRODUCTS} distinct product slugs.")
        targets.append(SiteTarget(declared, resolved, tuple(products)))
    return ProductUpdatesConfig(path, tuple(targets))


def _require_config(project_root: str | Path) -> ProductUpdatesConfig:
    config = load_config(project_root)
    if config is None:
        raise ContextHistoryError(f"No {CONFIG_FILE} in this repository; no product site is wired.")
    return config


# ---------------------------------------------------------------------- frontmatter


def _split_flow(text: str) -> list[str]:
    """Split a YAML flow collection body on top-level commas, quotes respected."""
    parts: list[str] = []
    current: list[str] = []
    depth = 0
    quote = ""
    index = 0
    while index < len(text):
        char = text[index]
        if quote:
            current.append(char)
            if quote == '"' and char == "\\" and index + 1 < len(text):
                current.append(text[index + 1])
                index += 1
            elif char == quote:
                quote = ""
        elif char in "\"'":
            quote = char
            current.append(char)
        elif char in "[{":
            depth += 1
            current.append(char)
        elif char in "]}":
            depth -= 1
            current.append(char)
        elif char == "," and depth == 0:
            parts.append("".join(current).strip())
            current = []
        else:
            current.append(char)
        index += 1
    tail = "".join(current).strip()
    if tail:
        parts.append(tail)
    return parts


def _strip_comment(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith(("'", '"')):
        return raw
    return re.split(r"\s#", raw, maxsplit=1)[0].strip()


def _unquote(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith('"'):
        match = re.match(r'"(?:[^"\\]|\\.)*"', raw)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                return match.group(0)[1:-1]
        return raw[1:]
    if raw.startswith("'"):
        match = re.match(r"'((?:[^']|'')*)'", raw)
        return match.group(1).replace("''", "'") if match else raw[1:]
    return _strip_comment(raw)


def _parse_flow_mapping(text: str) -> dict[str, str]:
    inner = text.strip()
    if not (inner.startswith("{") and inner.endswith("}")):
        raise UnsupportedFrontmatter("Expected a one-line flow mapping.")
    mapping: dict[str, str] = {}
    for part in _split_flow(inner[1:-1]):
        key, separator, value = part.partition(":")
        if not separator:
            raise UnsupportedFrontmatter("Flow mapping entry without a key.")
        mapping[key.strip()] = _unquote(value)
    return mapping


def _render_value(value: str) -> str:
    return value if BARE_VALUE_RE.fullmatch(value) else json.dumps(value, ensure_ascii=False)


class Frontmatter:
    """Line editor for the top-level keys of a Markdown file's YAML frontmatter."""

    def __init__(self, text: str, label: str = "file") -> None:
        self.bom = text.startswith("﻿")
        body = text[1:] if self.bom else text
        self.newline = "\r\n" if "\r\n" in body else "\n"
        lines = body.replace("\r\n", "\n").split("\n")
        if not lines or lines[0].rstrip() != "---":
            raise UnsupportedFrontmatter(f"{label} has no frontmatter.")
        for index in range(1, len(lines)):
            if lines[index].rstrip() == "---":
                break
        else:
            raise UnsupportedFrontmatter(f"{label} has an unterminated frontmatter.")
        self.lines = lines[1:index]
        self.tail = lines[index:]
        self.changed = False

    def render(self) -> str:
        text = self.newline.join(["---", *self.lines, *self.tail])
        return ("﻿" if self.bom else "") + text

    def _span(self, key: str) -> tuple[int, int, str] | None:
        for index, line in enumerate(self.lines):
            match = TOP_KEY_RE.match(line)
            if match and match.group(1) == key:
                end = index + 1
                while (
                    end < len(self.lines)
                    and self.lines[end][:1] in (" ", "\t", "-")
                    and not TOP_KEY_RE.match(self.lines[end])
                ):
                    end += 1
                return index, end, _strip_comment(match.group(2) or "")
        return None

    def scalar(self, key: str) -> str | None:
        span = self._span(key)
        if span is None or not span[2]:
            return None
        return _unquote(span[2])

    def _block_items(self, start: int, end: int) -> list[tuple[str, str]]:
        """Block sequence items as (indent, text after the dash)."""
        items: list[tuple[str, str]] = []
        for line in self.lines[start + 1:end]:
            stripped = line.lstrip()
            if stripped == "-" or stripped.startswith("- "):
                items.append((line[: len(line) - len(stripped)], stripped[1:].strip()))
        return items

    def list(self, key: str) -> list[str]:
        span = self._span(key)
        if span is None:
            return []
        start, end, inline = span
        if inline.startswith("[") and inline.endswith("]"):
            return [_unquote(part) for part in _split_flow(inline[1:-1]) if part]
        if not inline:
            return [_unquote(text) for _, text in self._block_items(start, end)]
        raise UnsupportedFrontmatter(f"{key} is not a list.")

    def mapping(self, key: str) -> dict[str, str]:
        span = self._span(key)
        if span is None:
            return {}
        start, end, inline = span
        if inline:
            return _parse_flow_mapping(inline)
        mapping: dict[str, str] = {}
        for line in self.lines[start + 1:end]:
            name, separator, value = line.strip().partition(":")
            if separator:
                mapping[name.strip()] = _unquote(value)
        return mapping

    def history(self, key: str = "statusHistory") -> list[dict[str, str]]:
        span = self._span(key)
        if span is None:
            return []
        start, end, inline = span
        if inline == "[]":
            return []
        if inline:
            raise UnsupportedFrontmatter(f"{key} uses an inline list this editor does not rewrite.")
        entries: list[dict[str, str]] = []
        for line in self.lines[start + 1:end]:
            stripped = line.strip()
            if not stripped:
                continue
            if stripped == "-" or stripped.startswith("- "):
                text = stripped[1:].strip()
                if text.startswith("{"):
                    entries.append(_parse_flow_mapping(text))
                    continue
                entries.append({})
                stripped = text
            if not entries:
                raise UnsupportedFrontmatter(f"{key} has content before its first item.")
            name, separator, value = stripped.partition(":")
            if separator:
                entries[-1][name.strip()] = _unquote(value)
        return entries

    def set_scalar(self, key: str, rendered: str) -> None:
        line = f"{key}: {rendered}"
        span = self._span(key)
        if span is None:
            self.lines.append(line)
        elif self.lines[span[0]:span[1]] == [line]:
            return
        else:
            self.lines[span[0]:span[1]] = [line]
        self.changed = True

    def add_list_item(self, key: str, value: str) -> bool:
        span = self._span(key)
        if span is None:
            self.lines.append(f"{key}: [{_render_value(value)}]")
            self.changed = True
            return True
        start, end, inline = span
        items = self.list(key)
        if value in items:
            return False
        if inline.startswith("["):
            rendered = ", ".join(_render_value(item) for item in [*items, value])
            self.lines[start:end] = [f"{key}: [{rendered}]"]
        else:
            block = self._block_items(start, end)
            indent = block[0][0] if block else "  "
            self.lines.insert(end, f"{indent}- {_render_value(value)}")
        self.changed = True
        return True

    def append_history(self, entry: str, key: str = "statusHistory") -> None:
        span = self._span(key)
        self.history(key)  # refuses shapes the editor does not rewrite
        if span is None:
            self.lines.extend([f"{key}:", f"  - {entry}"])
        elif span[2] == "[]":
            self.lines[span[0]:span[1]] = [f"{key}:", f"  - {entry}"]
        else:
            start, end, _ = span
            block = self._block_items(start, end)
            indent = block[0][0] if block else "  "
            self.lines.insert(end, f"{indent}- {entry}")
        self.changed = True


# ------------------------------------------------------------------------ roadmap


def _collection_directory(site: Path, relative: Path, locale: str) -> Path:
    directory = site / relative / locale
    for parent in (directory, *directory.parents):
        if parent == site:
            break
        if parent.is_symlink():
            raise ContextHistoryError("Content collections cannot use symbolic links.")
    return directory


def _day(value: str | None) -> str:
    return (value or "")[:10]


def _quoted(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def _history_entry(previous: str | None, status: str, day: str) -> str:
    origin = f"from: {previous}, " if previous else ""
    return f"{{ {origin}to: {status}, date: {_quoted(day)} }}"


def render_new_roadmap_item(
    change: dict[str, Any], locale: str, products: Iterable[str], day: str, event_id: str, shipped_in: str | None,
) -> str:
    """A new agent item: always ``visibility: hidden`` until a human publishes it."""
    lines = [
        "---",
        f"title: {_quoted(change['title'][locale])}",
        f"summary: {_quoted(change['summary'][locale])}",
        f"status: {change['status']}",
        f"products: [{', '.join(products)}]",
        "visibility: hidden",
        "statusHistory:",
        f"  - {_history_entry(None, change['status'], day)}",
        f"createdAt: {_quoted(day)}",
        f"updatedAt: {_quoted(day)}",
    ]
    if shipped_in:
        lines.append(f"shippedIn: [{_render_value(shipped_in)}]")
    lines.extend([f"source: {{ producer: agent, ref: {_quoted(event_id)} }}", "---", ""])
    return "\n".join(lines)


def apply_roadmap_change(
    site: Path,
    event: dict[str, Any],
    change: dict[str, Any],
    locale: str,
    products: Iterable[str],
    update_id: str | None,
    *,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Apply one ``public.roadmap`` change to one locale file of a site.

    Append-only history; ``shipped`` needs delivery proof; a newer or diverging
    history is reported (``skipped-stale``, ``skipped-inconsistent``), never rewritten.
    """
    day = event["occurredAt"][:10]
    target = change["status"]
    path = _collection_directory(site, ROADMAP_RELATIVE, locale) / f"{change['id']}.md"
    record: dict[str, Any] = {
        "eventId": event["id"],
        "id": change["id"],
        "locale": locale,
        "to": target,
        "path": path.relative_to(site).as_posix(),
        "linked": False,
    }
    if target == "shipped" and "delivery" not in event["public"]:
        record["action"] = "refused-no-proof"
        return record
    link = update_id if target == "shipped" else None
    if not path.exists():
        if "title" not in change:
            record["action"] = "missing"
            return record
        content = render_new_roadmap_item(change, locale, products, day, event["id"], link)
        if dry_run:
            record["action"] = "would-create"
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            _collection_directory(site, ROADMAP_RELATIVE, locale)
            try:
                with path.open("x", encoding="utf-8", newline="\n") as handle:
                    handle.write(content)
                record["action"] = "created"
            except FileExistsError:
                record["action"] = "skipped-concurrent"
                return record
        record["linked"] = link is not None
        return record

    try:
        document = Frontmatter(path.read_text(encoding="utf-8"), record["path"])
        current = document.scalar("status")
        history = document.history()
    except UnsupportedFrontmatter as error:
        record.update(action="skipped-unsupported-format", reason=str(error))
        return record
    if current not in _ch.ROADMAP_STATUSES:
        record["action"] = "skipped-invalid-status"
        return record
    record["from"] = current
    if current == target:
        action = "unchanged"
    elif history and history[-1].get("to") != current:
        action = "skipped-inconsistent"
    elif history and (
        _day(history[-1].get("date")) > day
        or any(item.get("to") == target and _day(item.get("date")) == day for item in history)
    ):
        action = "skipped-stale"
    else:
        try:
            document.append_history(_history_entry(current, target, day))
        except UnsupportedFrontmatter as error:
            record.update(action="skipped-unsupported-format", reason=str(error))
            return record
        document.set_scalar("status", target)
        created = _day(document.scalar("createdAt"))
        updated = _day(document.scalar("updatedAt"))
        if created <= day and updated < day:
            document.set_scalar("updatedAt", _quoted(day))
        action = "status-changed"
    final_status = target if action in ("unchanged", "status-changed") else current
    if link is not None and final_status in LINKABLE_STATUSES:
        try:
            added = document.add_list_item("shippedIn", link)
            record["linked"] = True
            if added and action == "unchanged":
                action = "linked"
        except UnsupportedFrontmatter as error:
            record["linkError"] = str(error)
    record["action"] = action
    if document.changed and not dry_run:
        _ch._write_atomic(path, document.render())
    return record


# --------------------------------------------------------------------- projection


def project_event_to_site(site: SiteTarget, event: dict[str, Any], *, dry_run: bool = False) -> dict[str, Any]:
    """Project one public event into one site: roadmap first, then the update linked to it."""
    _ch._require_updates_package(site.root)
    locales, skipped_locales = _ch._update_locales(site.root, ())
    public = event["public"]
    plans = (
        _ch.plan_update_projection(site.root, event, site.products[0], locales)
        if _ch.has_update_copy(event) else []
    )
    update_ids = {plan.locale: plan.effective_id for plan in plans}
    report: dict[str, Any] = {"updates": [], "roadmap": [], "skippedLocales": skipped_locales}
    related: dict[str, list[str]] = {}
    if "roadmap" in public:
        if not _ch.site_declares_package(site.root, ROADMAP_PACKAGE):
            report["roadmapSkipped"] = f"site does not declare {ROADMAP_PACKAGE}"
        else:
            for change in public["roadmap"]:
                for locale in locales:
                    record = apply_roadmap_change(
                        site.root, event, change, locale, site.products, update_ids.get(locale), dry_run=dry_run,
                    )
                    report["roadmap"].append(record)
                    if record["linked"]:
                        related.setdefault(locale, []).append(change["id"])
    if plans:
        report["updates"] = _ch.write_update_projection(
            site.root, event, list(site.products), plans, related_roadmap=related, dry_run=dry_run,
        )
    return report


def project_configured(
    project_root: str | Path,
    *,
    event_ids: Iterable[str] = (),
    since: str | None = None,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Project selected public events into every site declared by the repository."""
    root = _ch.resolve_project_root(project_root)
    config = load_config(root)
    if config is None:
        return {"configured": False, "configFile": CONFIG_FILE, "sites": []}
    requested = list(dict.fromkeys(event_ids))
    if not requested and since is None:
        raise ContextHistoryError("Select events with --event-id or --since.")
    if since is not None:
        try:
            date.fromisoformat(since)
        except ValueError as error:
            raise ContextHistoryError("since must be an ISO calendar date (YYYY-MM-DD).") from error
    events = _ch.load_events(root)
    by_id = {event["id"]: event for event in events}
    chosen: list[dict[str, Any]] = []
    for event_id in requested:
        if event_id not in by_id:
            raise ContextHistoryError(f"Unknown event id: {event_id}")
        chosen.append(by_id[event_id])
    if since is not None:
        chosen.extend(event for event in events if event["occurredAt"][:10] >= since and event not in chosen)
    public_events = [event for event in chosen if "public" in event]
    sites: list[dict[str, Any]] = []
    for site in config.sites:
        site_report: dict[str, Any] = {
            "root": site.declared, "products": list(site.products), "updates": [], "roadmap": [],
        }
        try:
            for event in public_events:
                result = project_event_to_site(site, event, dry_run=dry_run)
                site_report["updates"].extend(result["updates"])
                site_report["roadmap"].extend(result["roadmap"])
                for key in ("roadmapSkipped", "skippedLocales"):
                    if result.get(key):
                        site_report[key] = result[key]
        except (ContextHistoryError, OSError, UnicodeError) as error:
            site_report["error"] = str(error)
        sites.append(site_report)
    return {
        "configured": True,
        "dryRun": dry_run,
        "sites": sites,
        "notPublic": [event["id"] for event in chosen if "public" not in event],
    }


def project_after_append(project_root: str | Path, event: dict[str, Any]) -> dict[str, Any]:
    """Automatic projection run by ``append``. The event is already durable: never raise."""
    if "public" not in event:
        return {"status": "skipped", "reason": "internal event (no public object)"}
    try:
        report = project_configured(project_root, event_ids=[event["id"]])
    except (ContextHistoryError, OSError, UnicodeError) as error:
        return {"status": "error", "error": str(error)}
    if not report["configured"]:
        return {"status": "not-configured", "configFile": CONFIG_FILE}
    failed = any("error" in site for site in report["sites"])
    return {"status": "error" if failed else "ok", **report}


# ----------------------------------------------------------------- review gate


def _scan_collection(site: Path, relative: Path) -> tuple[dict[str, dict[str, tuple[Path, Frontmatter]]], list[str]]:
    """``{id: {locale: (path, frontmatter)}}`` for one collection; unreadable files are listed."""
    base = site / relative
    found: dict[str, dict[str, tuple[Path, Frontmatter]]] = {}
    unreadable: list[str] = []
    if not base.is_dir() or base.is_symlink():
        return found, unreadable
    count = 0
    for locale_dir in sorted(base.iterdir()):
        if not locale_dir.is_dir() or locale_dir.is_symlink() or locale_dir.name.startswith("_"):
            continue
        for path in sorted(locale_dir.glob("*.md")):
            if path.name.startswith("_") or path.is_symlink() or not path.is_file():
                continue
            count += 1
            if count > MAX_SCAN_FILES:
                raise ContextHistoryError(f"{relative.as_posix()} exceeds {MAX_SCAN_FILES} files.")
            try:
                document = Frontmatter(path.read_text(encoding="utf-8"), path.name)
            except (UnsupportedFrontmatter, OSError, UnicodeError):
                unreadable.append(path.relative_to(site).as_posix())
                continue
            found.setdefault(path.stem, {})[locale_dir.name] = (path, document)
    return found, unreadable


def _title(by_locale: dict[str, tuple[Path, Frontmatter]]) -> str:
    for locale in ("en", *sorted(by_locale)):
        if locale in by_locale:
            return by_locale[locale][1].scalar("title") or ""
    return ""


def _source(by_locale: dict[str, tuple[Path, Frontmatter]]) -> dict[str, str]:
    for _, document in by_locale.values():
        try:
            source = document.mapping("source")
        except UnsupportedFrontmatter:
            continue
        if source:
            return {key: source[key] for key in ("producer", "ref") if key in source}
    return {}


def _site_review(site: SiteTarget) -> dict[str, Any]:
    updates, unreadable_updates = _scan_collection(site.root, _ch.UPDATES_RELATIVE)
    roadmap, unreadable_roadmap = _scan_collection(site.root, ROADMAP_RELATIVE)
    drafts: list[dict[str, Any]] = []
    for item_id, by_locale in sorted(updates.items()):
        draft_locales = sorted(locale for locale, (_, doc) in by_locale.items() if doc.scalar("status") == "draft")
        if draft_locales:
            drafts.append({
                "id": item_id, "locales": draft_locales, "title": _title(by_locale), **_source(by_locale),
                "files": {locale: by_locale[locale][0] for locale in draft_locales},
                "relatedRoadmap": sorted({
                    related for _, doc in by_locale.values() for related in _safe_list(doc, "relatedRoadmap")
                }),
            })
    hidden: list[dict[str, Any]] = []
    awaiting: list[dict[str, str]] = []
    for item_id, by_locale in sorted(roadmap.items()):
        hidden_locales = sorted(
            locale for locale, (_, doc) in by_locale.items() if doc.scalar("visibility") == "hidden"
        )
        if hidden_locales:
            statuses = sorted({doc.scalar("status") or "" for _, doc in by_locale.values()})
            hidden.append({
                "id": item_id, "locales": hidden_locales, "status": ", ".join(statuses),
                "title": _title(by_locale), **_source(by_locale),
                "files": {locale: by_locale[locale][0] for locale in hidden_locales},
            })
        for locale, (_, doc) in sorted(by_locale.items()):
            if doc.scalar("visibility") != "public":
                continue
            for update_id in _safe_list(doc, "shippedIn"):
                update = updates.get(update_id, {}).get(locale)
                if update is None:
                    awaiting.append({"item": item_id, "locale": locale, "update": update_id, "reason": "update-missing"})
                elif update[1].scalar("status") == "draft":
                    awaiting.append({"item": item_id, "locale": locale, "update": update_id, "reason": "update-draft"})
    return {
        "root": site.declared,
        "path": site.root,
        "drafts": drafts,
        "hidden": hidden,
        "awaiting": awaiting,
        "unreadable": unreadable_updates + unreadable_roadmap,
    }


def _safe_list(document: Frontmatter, key: str) -> list[str]:
    try:
        return document.list(key)
    except UnsupportedFrontmatter:
        return []


def _public_view(review: dict[str, Any]) -> dict[str, Any]:
    def strip(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
        return [{key: value for key, value in item.items() if key != "files"} for item in items]

    return {
        "root": review["root"],
        "drafts": strip(review["drafts"]),
        "hidden": strip(review["hidden"]),
        "awaiting": review["awaiting"],
        "unreadable": review["unreadable"],
    }


def pending(project_root: str | Path) -> dict[str, Any]:
    """Drafts, hidden items and public items whose delivering update is not published, per site."""
    config = _require_config(project_root)
    sites = [_public_view(_site_review(site)) for site in config.sites]
    count = sum(len(site["drafts"]) + len(site["hidden"]) for site in sites)
    return {"pendingCount": count, "sites": sites}


def render_pending_text(report: dict[str, Any]) -> str:
    lines: list[str] = []
    for site in report["sites"]:
        lines.append(f"Site {site['root']}")
        if not (site["drafts"] or site["hidden"] or site["awaiting"]):
            lines.append("  Nothing awaits review.")
        for item in site["drafts"]:
            origin = f" ({item.get('producer', '?')}{', ' + item['ref'] if item.get('ref') else ''})"
            lines.append(f"  update  {item['id']} [{', '.join(item['locales'])}]{origin}: {item['title']}")
        for item in site["hidden"]:
            lines.append(f"  roadmap {item['id']} [{', '.join(item['locales'])}] {item['status']}: {item['title']}")
        for item in site["awaiting"]:
            lines.append(f"  waiting public item {item['item']} ({item['locale']}) -> update {item['update']}: {item['reason']}")
        for path in site["unreadable"]:
            lines.append(f"  unreadable {path}")
    lines.append(f"{report['pendingCount']} pending. Publish: context_history.py publish --id <id> | --all")
    return "\n".join(lines)


def publish(
    project_root: str | Path,
    *,
    ids: Iterable[str] = (),
    publish_all: bool = False,
    kind: str | None = None,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Flip ``status: draft`` to ``published`` and ``visibility: hidden`` to ``public`` in every locale.

    Selection is validated before any write: an unknown id publishes nothing.
    """
    requested = list(dict.fromkeys(ids))
    if bool(requested) == publish_all:
        raise ContextHistoryError("Give --id (repeatable) or --all, not both.")
    if kind not in (None, "update", "roadmap"):
        raise ContextHistoryError("kind must be update or roadmap.")
    config = _require_config(project_root)
    reviews = [_site_review(site) for site in config.sites]
    candidates: list[tuple[dict[str, Any], str, dict[str, Any]]] = []
    for review in reviews:
        if kind in (None, "update"):
            candidates.extend((review, "update", item) for item in review["drafts"])
        if kind in (None, "roadmap"):
            candidates.extend((review, "roadmap", item) for item in review["hidden"])
    if requested:
        missing = [item_id for item_id in requested if not any(c[2]["id"] == item_id for c in candidates)]
        if missing:
            raise ContextHistoryError(f"Nothing pending under: {', '.join(missing)}. Run pending to list ids.")
        candidates = [candidate for candidate in candidates if candidate[2]["id"] in requested]
    published: list[dict[str, str]] = []
    publishing_roadmap = {(review["root"], item["id"]) for review, entry_kind, item in candidates if entry_kind == "roadmap"}
    warnings: list[str] = []
    for review, entry_kind, item in candidates:
        key, before, after = (
            ("status", "draft", "published") if entry_kind == "update" else ("visibility", "hidden", "public")
        )
        for locale, path in sorted(item["files"].items()):
            document = Frontmatter(path.read_text(encoding="utf-8"), path.name)
            if document.scalar(key) != before:
                continue
            document.set_scalar(key, after)
            if not dry_run:
                _ch._write_atomic(path, document.render())
            published.append({
                "site": review["root"], "kind": entry_kind, "id": item["id"], "locale": locale,
                "action": "would-publish" if dry_run else "published",
                "path": path.relative_to(review["path"]).as_posix(),
            })
        if entry_kind == "update":
            hidden_ids = {hidden["id"] for hidden in review["hidden"]}
            for related in item.get("relatedRoadmap", []):
                if related in hidden_ids and (review["root"], related) not in publishing_roadmap:
                    warnings.append(f"update {item['id']} links hidden roadmap item {related}; publish it too.")
    return {"dryRun": dry_run, "published": published, "warnings": warnings}
