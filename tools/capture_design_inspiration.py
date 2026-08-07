#!/usr/bin/env python3
"""Capture rights-aware design references into a private corpus.

Live captures use the server's shared global Playwright Node installation.
Synthetic fixture captures are strictly no-network and use a deterministic Pillow renderer so the storage,
text, image, segmentation, checksum, and index contracts remain locally
testable without fetching or committing third-party material.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import textwrap
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import SplitResult, urlsplit, urlunsplit

import yaml
from PIL import Image, ImageDraw, ImageFont, features


SCHEMA_VERSION = "1.0"
MAX_BATCH_SIZE = 50
DEFAULT_VIEWPORT_WIDTH = 1440
DEFAULT_VIEWPORT_HEIGHT = 900
DEFAULT_SEGMENT_HEIGHT = 1600
DEFAULT_SEGMENT_OVERLAP = 160
THUMBNAIL_WIDTH = 480
MAX_WEBP_DIMENSION = 16_383
CAPTURE_STATUSES = {
    "captured",
    "partial",
    "failed",
    "blocked",
    "auth_required",
    "rejected",
    "removed",
}
LIFECYCLE_STATUSES = {"candidate", "approved", "rejected", "blocked", "removed"}
PAGE_TYPES = {
    "sales-page",
    "landing-page",
    "product-page",
    "pricing-page",
    "checkout-page",
    "waitlist-page",
    "webinar-page",
    "lead-magnet",
    "other",
}
TAXONOMY_TAG_PATTERN = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
SEMANTIC_TAGS = {"h1", "h2", "h3", "h4", "h5", "h6", "p", "li", "button", "label", "a", "nav"}
IGNORED_TAGS = {"script", "style", "noscript", "template", "svg"}
VOID_TAGS = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}
BOILERPLATE_TOKENS = {"cookie", "consent", "gdpr", "cmp-banner", "privacy-banner"}
AUTH_PATH_TOKENS = {"login", "log-in", "signin", "sign-in", "auth", "account"}
AUTH_TEXT_MARKERS = (
    "sign in to continue",
    "log in to continue",
    "authentication required",
    "please sign in",
)
BLOCK_TEXT_MARKERS = (
    "verify you are human",
    "access denied",
    "bot challenge",
    "temporarily blocked",
    "too many requests",
)


class CaptureToolError(RuntimeError):
    """Expected, operator-actionable capture error."""

    def __init__(self, code: str, message: str, status: str = "failed", access_status: str = "unknown") -> None:
        super().__init__(message)
        self.code = code
        self.status = status
        self.access_status = access_status


class DuplicateError(CaptureToolError):
    def __init__(self, message: str) -> None:
        super().__init__("duplicate", message, status="failed")


@dataclass
class TextBlock:
    order: int
    tag: str
    text: str
    href: str | None = None


@dataclass
class CaptureResult:
    markdown: str | None = None
    image: Image.Image | None = None
    final_url: str | None = None
    access_status: str = "public"
    capture_status: str = "captured"
    engine: str = "none"
    reason_code: str | None = None
    reason: str | None = None
    warnings: list[str] = field(default_factory=list)
    unsupported_elements: list[str] = field(default_factory=list)


@dataclass(frozen=True)
class NodePlaywrightRuntime:
    node_path: Path
    cli_path: Path
    package_json: Path


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def private_default_root() -> Path:
    configured = os.environ.get("SHIPGLOWS_INSPIRATION_LIBRARY_DIR")
    if configured:
        return Path(configured).expanduser()
    private_root = Path(os.environ.get("SHIPGLOWS_PRIVATE_DIR", str(Path.home() / ".shipglows" / "private"))).expanduser()
    return private_root / "design-inspiration-library"


def shipglows_root() -> Path:
    return Path(os.environ.get("SHIPGLOWS_ROOT", str(Path.home() / "shipglows"))).expanduser().resolve()


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def git_ancestor(path: Path) -> Path | None:
    cursor = path if path.exists() and path.is_dir() else path.parent
    cursor = cursor.resolve()
    for candidate in (cursor, *cursor.parents):
        if (candidate / ".git").exists():
            return candidate
    return None


def public_cache_path(path: Path) -> bool:
    normalized = path.as_posix()
    markers = (
        "/.codex/plugins/cache/",
        "/.claude/plugins/",
        "/.agents/plugins/",
        "/plugins/cache/",
    )
    return any(marker in f"{normalized}/" for marker in markers)


def validate_output_root(path: Path, *, fixture_mode: bool) -> Path:
    resolved = path.expanduser().resolve()
    temp_root = Path(tempfile.gettempdir()).resolve()
    synthetic_temp = fixture_mode and is_relative_to(resolved, temp_root)
    approved_private_root = private_default_root().resolve()
    configured_private_parent = Path(
        os.environ.get("SHIPGLOWS_PRIVATE_DIR", str(Path.home() / ".shipglows" / "private"))
    ).expanduser().resolve()
    approved_private = is_relative_to(resolved, approved_private_root) and is_relative_to(
        resolved, configured_private_parent
    )

    if is_relative_to(resolved, shipglows_root()):
        raise CaptureToolError(
            "public_repo_target",
            f"refusing output under public ShipGlows root: {resolved}",
            status="rejected",
        )
    if public_cache_path(resolved):
        raise CaptureToolError(
            "public_cache_target",
            f"refusing output under public plugin/cache path: {resolved}",
            status="rejected",
        )

    repository = git_ancestor(resolved)
    if repository is not None and not synthetic_temp and not approved_private:
        raise CaptureToolError(
            "git_repo_target",
            f"refusing source-derived output inside Git working tree: {repository}",
            status="rejected",
        )
    if fixture_mode and not synthetic_temp:
        raise CaptureToolError(
            "fixture_requires_temp",
            f"synthetic fixture output must be under the system temporary directory: {temp_root}",
            status="rejected",
        )
    return resolved


def validate_url(url: str) -> str:
    value = url.strip()
    parsed = urlsplit(value)
    if parsed.scheme.lower() not in {"http", "https"} or not parsed.hostname:
        raise CaptureToolError("invalid_url", "URL must use http or https and include a host")
    if parsed.username or parsed.password:
        raise CaptureToolError("credentialed_url", "URLs containing embedded credentials are forbidden", status="rejected")
    return value


def normalize_url(url: str) -> str:
    parsed = urlsplit(validate_url(url))
    scheme = parsed.scheme.lower()
    host = (parsed.hostname or "").lower()
    port = parsed.port
    netloc = host
    if port and not ((scheme == "http" and port == 80) or (scheme == "https" and port == 443)):
        netloc = f"{host}:{port}"
    path = re.sub(r"/{2,}", "/", parsed.path or "/")
    if path != "/":
        path = path.rstrip("/")
    return urlunsplit(SplitResult(scheme, netloc, path, "", ""))


def redact_url(url: str) -> str:
    try:
        parsed = urlsplit(url)
    except ValueError:
        return "<invalid-url>"
    query = "<redacted>" if parsed.query else ""
    return urlunsplit(SplitResult(parsed.scheme, parsed.netloc, parsed.path, query, ""))


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    slug = re.sub(r"-{2,}", "-", slug)[:80].rstrip("-")
    if len(slug) < 2:
        slug = f"reference-{hashlib.sha256(value.encode('utf-8')).hexdigest()[:8]}"
    return slug


def derive_id(url: str) -> str:
    parsed = urlsplit(url)
    material = f"{parsed.hostname or 'reference'}-{parsed.path.strip('/') or 'home'}"
    return slugify(material)


def ensure_safe_id(reference_id: str) -> str:
    value = reference_id.strip()
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]{1,79}", value):
        raise CaptureToolError(
            "invalid_id",
            "reference ID must be 2-80 lowercase letters, digits, or hyphens and start with a letter or digit",
        )
    return value


class StructuredHTMLParser(HTMLParser):
    """Extract ordered, visible-enough semantic blocks without storing HTML."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.order = 0
        self.hidden_depth = 0
        self.stack: list[dict[str, Any]] = []
        self.blocks: list[TextBlock] = []

    @staticmethod
    def _attrs(attrs: list[tuple[str, str | None]]) -> dict[str, str]:
        return {key.lower(): value or "" for key, value in attrs}

    @staticmethod
    def _hidden(tag: str, attrs: dict[str, str]) -> bool:
        style = attrs.get("style", "").replace(" ", "").lower()
        tokens = f"{attrs.get('id', '')} {attrs.get('class', '')}".lower()
        obvious_cookie_boilerplate = any(token in tokens for token in BOILERPLATE_TOKENS)
        explicit_hidden_class = bool(re.search(r"(?:^|\s)(?:hidden|hidden-[a-z0-9-]+|visually-hidden|sr-only)(?:\s|$)", tokens))
        return (
            tag in IGNORED_TAGS
            or "hidden" in attrs
            or attrs.get("aria-hidden", "").lower() == "true"
            or "display:none" in style
            or "visibility:hidden" in style
            or obvious_cookie_boilerplate
            or explicit_hidden_class
        )

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.lower()
        attr_map = self._attrs(attrs)
        hidden = self._hidden(tag, attr_map)
        if tag in VOID_TAGS:
            if hidden or self.hidden_depth:
                return
            if tag == "input":
                label = attr_map.get("aria-label") or attr_map.get("placeholder") or attr_map.get("name")
                if label:
                    self.order += 1
                    self.blocks.append(TextBlock(self.order, "input", clean_text(label)))
            return
        if self.hidden_depth or hidden:
            self.hidden_depth += 1
            self.stack.append({"tag": tag, "hidden": True})
            return

        item: dict[str, Any] = {"tag": tag, "hidden": False}
        if tag in SEMANTIC_TAGS:
            self.order += 1
            item.update(
                {
                    "semantic": True,
                    "order": self.order,
                    "pieces": [],
                    "href": attr_map.get("href") if tag == "a" else None,
                }
            )
        self.stack.append(item)

        if tag in {"textarea", "select"}:
            label = attr_map.get("aria-label") or attr_map.get("placeholder") or attr_map.get("name")
            if label:
                self.order += 1
                self.blocks.append(TextBlock(self.order, "input", clean_text(label)))

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        self.handle_endtag(tag)

    def handle_data(self, data: str) -> None:
        if self.hidden_depth:
            return
        if not data.strip():
            return
        for item in self.stack:
            if item.get("semantic"):
                item["pieces"].append(data)

    def handle_endtag(self, tag: str) -> None:
        if not self.stack:
            return
        item = self.stack.pop()
        if item.get("hidden"):
            self.hidden_depth = max(0, self.hidden_depth - 1)
            return
        if item.get("semantic"):
            text = clean_text(" ".join(item.get("pieces", [])))
            if text:
                self.blocks.append(TextBlock(item["order"], item["tag"], text, item.get("href")))


def clean_text(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def markdown_for_blocks(blocks: Iterable[TextBlock], source_url: str) -> str:
    lines = ["# Captured page structure", "", f"Source: {source_url}", ""]
    previous: tuple[str, str, str | None] | None = None
    for block in sorted(blocks, key=lambda item: item.order):
        signature = (block.tag, block.text, block.href)
        if signature == previous:
            continue
        previous = signature
        if block.tag.startswith("h") and block.tag[1:].isdigit():
            level = min(6, max(1, int(block.tag[1:])))
            rendered = f"{'#' * level} {block.text}"
        elif block.tag == "li":
            rendered = f"- {block.text}"
        elif block.tag == "button":
            rendered = f"**Button:** {block.text}"
        elif block.tag == "label":
            rendered = f"**Label:** {block.text}"
        elif block.tag == "input":
            rendered = f"**Field:** {block.text}"
        elif block.tag == "nav":
            rendered = f"**Navigation:** {block.text}"
        elif block.tag == "a":
            href = block.href or ""
            if href.lower().startswith(("javascript:", "data:")):
                rendered = block.text
            elif href:
                rendered = f"[{block.text}]({href})"
            else:
                rendered = block.text
        else:
            rendered = block.text
        lines.extend((rendered, ""))
    return "\n".join(lines).rstrip() + "\n"


def extract_fixture_markdown(html: str, source_url: str) -> tuple[str, list[TextBlock]]:
    parser = StructuredHTMLParser()
    parser.feed(html)
    parser.close()
    if not parser.blocks:
        raise CaptureToolError("empty_visible_text", "fixture did not contain extractable visible semantic text")
    return markdown_for_blocks(parser.blocks, source_url), sorted(parser.blocks, key=lambda item: item.order)


def load_font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    names = ["DejaVuSans-Bold.ttf", "DejaVuSans.ttf"] if bold else ["DejaVuSans.ttf"]
    for name in names:
        try:
            return ImageFont.truetype(name, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def render_synthetic_fixture(blocks: list[TextBlock]) -> Image.Image:
    """Render synthetic fixture semantics deterministically without a browser/network."""

    width = DEFAULT_VIEWPORT_WIDTH
    body_font = load_font(28)
    label_font = load_font(22, bold=True)
    heading_fonts = {level: load_font(max(34, 70 - (level - 1) * 8), bold=True) for level in range(1, 7)}
    prepared: list[tuple[TextBlock, list[str], int]] = []
    total_height = 180
    for block in blocks:
        if block.tag.startswith("h") and block.tag[1:].isdigit():
            font = heading_fonts[min(6, int(block.tag[1:]))]
            wrap_at = 40
            spacing = 44
        elif block.tag in {"button", "label", "input", "nav"}:
            font = label_font
            wrap_at = 76
            spacing = 34
        else:
            font = body_font
            wrap_at = 82
            spacing = 38
        lines = textwrap.wrap(block.text, width=wrap_at) or [block.text]
        block_height = max(110, len(lines) * spacing + 58)
        prepared.append((block, lines, block_height))
        total_height += block_height
    height = max(2200, min(total_height + 180, 14000))
    image = Image.new("RGB", (width, height), "#f7f4ee")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, width, 110), fill="#111827")
    draw.text((72, 34), "Synthetic Design Inspiration Fixture", font=load_font(34, bold=True), fill="#ffffff")

    y = 150
    palette = ["#fffdf8", "#edf5f1", "#f2effa", "#f8eee9"]
    for index, (block, lines, block_height) in enumerate(prepared):
        if y + block_height > height - 40:
            break
        background = palette[(index // 3) % len(palette)]
        draw.rounded_rectangle((48, y, width - 48, y + block_height - 18), radius=24, fill=background, outline="#d1d5db")
        if block.tag.startswith("h") and block.tag[1:].isdigit():
            font = heading_fonts[min(6, int(block.tag[1:]))]
            fill = "#111827"
            line_spacing = 44
        elif block.tag in {"button", "label", "input", "nav"}:
            font = label_font
            fill = "#243b53"
            line_spacing = 34
        else:
            font = body_font
            fill = "#374151"
            line_spacing = 38
        text_y = y + 26
        for line in lines:
            draw.text((82, text_y), line, font=font, fill=fill)
            text_y += line_spacing
        y += block_height
    return image


def markdown_from_browser_entries(entries: list[dict[str, Any]], source_url: str) -> str:
    blocks = [TextBlock(int(item["order"]), str(item["tag"]), str(item["text"]), item.get("href")) for item in entries]
    if not blocks:
        raise CaptureToolError("empty_visible_text", "page did not expose visible semantic text")
    return markdown_for_blocks(blocks, source_url)


def discover_node_playwright_runtime() -> NodePlaywrightRuntime:
    cli = shutil.which("playwright")
    if not cli:
        raise CaptureToolError(
            "playwright_cli_unavailable",
            "Shared Playwright CLI was not found in PATH. Install Playwright once in the server's global Node prefix and expose its playwright binary in PATH.",
        )
    node = shutil.which("node")
    if not node:
        raise CaptureToolError(
            "node_unavailable",
            "Node.js was not found in PATH. Expose the server's shared Node binary before using live capture.",
        )

    resolver = (
        "const fs=require('node:fs');const {createRequire}=require('node:module');"
        "const cli=fs.realpathSync(process.argv[1]);"
        "const text=fs.readFileSync(cli,'utf8');"
        "const target=(text.match(/^# cmd-shim-target=(.+)$/m)||[])[1]||cli;"
        "const requireFromCli=createRequire(target);"
        "for(const candidate of ['playwright/package.json','@playwright/test/package.json'])"
        "{try{process.stdout.write(requireFromCli.resolve(candidate));process.exit(0)}catch(_error){}}"
        "process.exit(1);"
    )
    try:
        completed = subprocess.run(
            [node, "-e", resolver, cli],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise CaptureToolError(
            "playwright_package_unavailable",
            "The shared Playwright package could not be resolved from the global CLI. Repair the global Node installation; do not install it in this project.",
        ) from exc
    package_json = Path(completed.stdout.strip()) if completed.returncode == 0 and completed.stdout.strip() else None
    if package_json is None or not package_json.is_file():
        raise CaptureToolError(
            "playwright_package_unavailable",
            "The playwright CLI exists, but its Node package is missing or not resolvable. Repair the shared global Playwright installation; do not install it in this project.",
        )
    return NodePlaywrightRuntime(Path(node).resolve(), Path(cli).resolve(), package_json.resolve())


def run_node_capture(runtime: NodePlaywrightRuntime, url: str, png_path: Path) -> dict[str, Any]:
    helper = Path(__file__).with_name("capture_design_inspiration_playwright.js").resolve()
    if not helper.is_file():
        raise CaptureToolError("playwright_bridge_missing", f"Playwright bridge helper is missing: {helper}")
    command = [
        str(runtime.node_path),
        str(helper),
        str(runtime.package_json),
        str(png_path),
        str(DEFAULT_VIEWPORT_WIDTH),
        str(DEFAULT_VIEWPORT_HEIGHT),
    ]
    try:
        completed = subprocess.run(
            command,
            input=json.dumps({"url": url}),
            check=False,
            capture_output=True,
            text=True,
            timeout=110,
        )
    except subprocess.TimeoutExpired as exc:
        raise CaptureToolError("network_timeout", "browser bridge timed out before capture completed") from exc
    except OSError as exc:
        raise CaptureToolError("browser_error", "shared Playwright browser bridge could not be started") from exc

    try:
        payload = json.loads(completed.stdout)
    except (json.JSONDecodeError, TypeError) as exc:
        raise CaptureToolError(
            "playwright_bridge_error",
            "Playwright bridge returned no valid structured result. Verify that the shared CLI/package versions are consistent.",
        ) from exc
    if not isinstance(payload, dict):
        raise CaptureToolError("playwright_bridge_error", "Playwright bridge returned an invalid structured result")
    if completed.returncode != 0 or not payload.get("ok"):
        code = str(payload.get("code", "browser_error"))
        messages = {
            "playwright_browser_unavailable": (
                "The shared Playwright package is available, but its Chromium browser is missing from the shared cache. "
                "Install Chromium once for the server-wide Playwright installation, then retry."
            ),
            "network_timeout": "page load timed out after 45 seconds",
            "playwright_package_unavailable": (
                "The shared Playwright package could not be loaded by Node. Repair the global installation; do not install it in this project."
            ),
            "browser_error": "shared Playwright browser capture failed; inspect the server-wide Playwright installation and browser runtime libraries",
        }
        raise CaptureToolError(code if code in messages else "browser_error", messages.get(code, messages["browser_error"]))
    return payload


def detect_access_state(url: str, title: str, visible_text: str, status_code: int | None) -> tuple[str, str | None]:
    lower_url = url.lower()
    lower_text = f"{title}\n{visible_text[:5000]}".lower()
    path_tokens = {token for token in re.split(r"[^a-z0-9]+", urlsplit(lower_url).path) if token}
    if status_code == 401 or path_tokens.intersection(AUTH_PATH_TOKENS) or any(marker in lower_text for marker in AUTH_TEXT_MARKERS):
        return "auth_required", "authentication wall detected; authenticated capture is not authorized"
    if status_code in {403, 429} or any(marker in lower_text for marker in BLOCK_TEXT_MARKERS):
        return "blocked", "automation/access block detected; bypass is not authorized"
    return "captured", None


def capture_live(url: str) -> CaptureResult:
    runtime = discover_node_playwright_runtime()
    result = CaptureResult(final_url=url, engine="playwright")
    with tempfile.TemporaryDirectory(prefix="shipglows-inspiration-browser-") as temporary:
        png_path = Path(temporary) / "full-page.png"
        payload = run_node_capture(runtime, url, png_path)
        result.final_url = str(payload.get("finalUrl") or url)
        state, reason = detect_access_state(
            result.final_url,
            str(payload.get("title", "")),
            str(payload.get("visibleText", "")),
            int(payload["statusCode"]) if payload.get("statusCode") is not None else None,
        )
        if state != "captured":
            result.capture_status = state
            result.access_status = "authenticated" if state == "auth_required" else "blocked"
            result.reason_code = state
            result.reason = reason
            return result
        entries = payload.get("entries")
        if not isinstance(entries, list):
            raise CaptureToolError("playwright_bridge_error", "Playwright bridge omitted structured DOM entries")
        result.markdown = markdown_from_browser_entries(entries, url)
        unsupported = payload.get("unsupported", [])
        result.unsupported_elements = [str(item) for item in unsupported] if isinstance(unsupported, list) else []
        if payload.get("screenshotFailed") or not png_path.is_file():
            result.capture_status = "partial"
            result.reason_code = "screenshot_failed"
            result.reason = "visible text was extracted, but the full-page screenshot failed"
        else:
            try:
                with Image.open(png_path) as opened:
                    result.image = opened.convert("RGB").copy()
            except OSError as exc:
                result.capture_status = "partial"
                result.reason_code = "screenshot_failed"
                result.reason = f"visible text was extracted, but the temporary PNG was invalid: {type(exc).__name__}"
    return result


def capture_fixture(path: Path, source_url: str) -> CaptureResult:
    if not path.is_file():
        raise CaptureToolError("fixture_missing", f"fixture file does not exist: {path}")
    if urlsplit(source_url).hostname != "example.invalid":
        raise CaptureToolError(
            "fixture_source_not_synthetic",
            "fixture mode requires a synthetic source URL under https://example.invalid/",
            status="rejected",
        )
    html = path.read_text(encoding="utf-8")
    markdown, blocks = extract_fixture_markdown(html, source_url)
    image = render_synthetic_fixture(blocks)
    unsupported = []
    if re.search(r"<(video|canvas)\b", html, flags=re.IGNORECASE):
        unsupported.append("synthetic-fixture-interactive-element")
    return CaptureResult(
        markdown=markdown,
        image=image,
        final_url=source_url,
        access_status="public",
        capture_status="captured",
        engine="synthetic_fixture",
        unsupported_elements=unsupported,
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def bundle_checksum(files: dict[str, str]) -> str | None:
    if not files:
        return None
    material = "\n".join(f"{name}:{files[name]}" for name in sorted(files))
    return hashlib.sha256(material.encode("utf-8")).hexdigest()


def save_webp(image: Image.Image, path: Path, *, quality: int = 84) -> bool:
    if not features.check("webp"):
        raise CaptureToolError(
            "webp_unavailable",
            "Pillow was built without WebP support; install a Pillow build with WebP support and retry",
        )
    prepared = image.convert("RGB")
    resized = max(prepared.width, prepared.height) > MAX_WEBP_DIMENSION
    if resized:
        scale = MAX_WEBP_DIMENSION / max(prepared.width, prepared.height)
        prepared = prepared.resize(
            (max(1, round(prepared.width * scale)), max(1, round(prepared.height * scale))),
            Image.Resampling.LANCZOS,
        )
    prepared.save(path, format="WEBP", quality=quality, method=6)
    return resized


def create_image_artifacts(image: Image.Image, staging: Path) -> tuple[list[str], list[str]]:
    if image.width <= 0 or image.height <= 0:
        raise CaptureToolError("invalid_image", "captured image has invalid dimensions")
    full_page = staging / "full-page.webp"
    thumbnail = staging / "thumbnail.webp"
    segments_dir = staging / "segments"
    segments_dir.mkdir(parents=True, exist_ok=False)
    warnings: list[str] = []
    if save_webp(image, full_page):
        warnings.append(
            f"full-page.webp was proportionally downscaled to the WebP maximum dimension of {MAX_WEBP_DIMENSION}px; segments retain the capture scale"
        )

    thumb = image.copy()
    thumb.thumbnail((THUMBNAIL_WIDTH, 1200), Image.Resampling.LANCZOS)
    save_webp(thumb, thumbnail, quality=80)

    names: list[str] = []
    step = DEFAULT_SEGMENT_HEIGHT - DEFAULT_SEGMENT_OVERLAP
    start = 0
    index = 1
    while start < image.height:
        end = min(start + DEFAULT_SEGMENT_HEIGHT, image.height)
        segment = image.crop((0, start, image.width, end))
        relative = f"segments/{index:03d}.webp"
        save_webp(segment, staging / relative)
        names.append(relative)
        if end >= image.height:
            break
        start += step
        index += 1
    return names, warnings


def initial_index() -> dict[str, Any]:
    return {"schema_version": SCHEMA_VERSION, "updated_at": utc_now(), "entries": [], "duplicate_events": []}


def load_index(root: Path) -> dict[str, Any]:
    path = root / "index.yaml"
    if not path.exists():
        return initial_index()
    loaded = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(loaded, dict) or loaded.get("schema_version") != SCHEMA_VERSION:
        raise CaptureToolError("invalid_index", f"unsupported or malformed private index: {path}")
    if not isinstance(loaded.get("entries"), list) or not isinstance(loaded.get("duplicate_events"), list):
        raise CaptureToolError("invalid_index", f"private index entries/events must be lists: {path}")
    return loaded


def atomic_yaml_write(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = yaml.safe_dump(value, sort_keys=False, allow_unicode=True, width=120)
    temporary = path.with_name(f".{path.name}.{uuid.uuid4().hex}.tmp")
    temporary.write_text(payload, encoding="utf-8")
    os.replace(temporary, path)


def bootstrap_corpus(root: Path) -> dict[str, Any]:
    root.mkdir(parents=True, exist_ok=True)
    if not os.access(root, os.W_OK):
        raise CaptureToolError("root_not_writable", f"corpus root is not writable: {root}")
    (root / "references").mkdir(parents=True, exist_ok=True)
    index = load_index(root)
    if not (root / "index.yaml").exists():
        atomic_yaml_write(root / "index.yaml", index)
    return index


def duplicate_match(index: dict[str, Any], reference_id: str, normalized_url: str) -> tuple[dict[str, Any] | None, str | None]:
    for entry in index["entries"]:
        if entry.get("id") == reference_id:
            return entry, "duplicate_id"
        if entry.get("normalized_url") == normalized_url:
            return entry, "duplicate_url"
    return None, None


def record_duplicate(index: dict[str, Any], root: Path, *, requested_id: str, existing_id: str, normalized_url: str, reason: str) -> None:
    index["duplicate_events"].append(
        {
            "attempted_at": utc_now(),
            "requested_id": requested_id,
            "existing_id": existing_id,
            "normalized_url": normalized_url,
            "reason": reason,
        }
    )
    index["updated_at"] = utc_now()
    atomic_yaml_write(root / "index.yaml", index)


def artifact_paths(staging: Path, segments: list[str]) -> dict[str, Any]:
    return {
        "page_markdown": "page.md" if (staging / "page.md").exists() else None,
        "full_page_image": "full-page.webp" if (staging / "full-page.webp").exists() else None,
        "thumbnail_image": "thumbnail.webp" if (staging / "thumbnail.webp").exists() else None,
        "segments": segments,
    }


def artifact_checksums(staging: Path, artifacts: dict[str, Any]) -> dict[str, str]:
    names: list[str] = []
    for key in ("page_markdown", "full_page_image", "thumbnail_image"):
        value = artifacts[key]
        if value:
            names.append(value)
    names.extend(artifacts["segments"])
    return {name: sha256_file(staging / name) for name in names}


def make_record(
    *,
    reference_id: str,
    url: str,
    normalized_url: str,
    result: CaptureResult,
    artifacts: dict[str, Any],
    checksums: dict[str, str],
    created_at: str,
    wayback_url: str | None = None,
) -> dict[str, Any]:
    complete = bool(
        artifacts["page_markdown"]
        and artifacts["full_page_image"]
        and artifacts["thumbnail_image"]
        and artifacts["segments"]
    )
    has_artifact = bool(checksums)
    status = result.capture_status
    if complete and status not in {"blocked", "auth_required", "rejected", "removed"}:
        status = "captured"
    elif has_artifact and not complete:
        status = "partial"
    elif status == "captured" and not has_artifact:
        status = "failed"
    if status not in CAPTURE_STATUSES:
        status = "failed"

    lifecycle = "blocked" if status in {"blocked", "auth_required"} else "candidate"
    now = utc_now()
    return {
        "schema_version": SCHEMA_VERSION,
        "id": reference_id,
        "lifecycle_status": lifecycle,
        "capture_status": status,
        "source": {
            "url": url,
            "normalized_url": normalized_url,
            "final_url": result.final_url,
            "captured_at": now,
            "wayback_url": wayback_url,
            "access_status": result.access_status,
        },
        "capture": {
            "engine": result.engine,
            "viewport": {
                "width": DEFAULT_VIEWPORT_WIDTH,
                "height": DEFAULT_VIEWPORT_HEIGHT,
                "device_scale_factor": 1,
            },
            "full_page": bool(artifacts["full_page_image"]),
            "segment_height": DEFAULT_SEGMENT_HEIGHT,
            "segment_overlap": DEFAULT_SEGMENT_OVERLAP,
            "reason_code": result.reason_code,
            "reason": result.reason,
            "unsupported_elements": result.unsupported_elements,
        },
        "taxonomy": {
            "page_type": "sales-page",
            "audience": [],
            "styles": [],
            "sections": [],
            "copy_patterns": [],
            "conversion_goals": [],
        },
        "curation": {"summary": None, "what_to_borrow": [], "what_not_to_copy": []},
        "rights": {
            "use": "private_research_reference" if result.engine != "synthetic_fixture" else "synthetic_test_fixture",
            "attribution_required": result.engine != "synthetic_fixture",
            "redistribution": "prohibited" if result.engine != "synthetic_fixture" else "synthetic_only",
            "long_verbatim_reuse": "prohibited" if result.engine != "synthetic_fixture" else "synthetic_only",
            "takedown": "remove_source_derived_artifacts" if result.engine != "synthetic_fixture" else "not_applicable",
            "notes": "Review source terms and rights before approval." if result.engine != "synthetic_fixture" else "Synthetic fixture only; no third-party content.",
        },
        "artifacts": artifacts,
        "checksums": {"algorithm": "sha256", "files": checksums, "bundle": bundle_checksum(checksums)},
        "warnings": result.warnings,
        "created_at": created_at,
        "updated_at": now,
    }


def validate_record(record: dict[str, Any]) -> None:
    required = {
        "schema_version",
        "id",
        "lifecycle_status",
        "capture_status",
        "source",
        "capture",
        "taxonomy",
        "curation",
        "rights",
        "artifacts",
        "checksums",
        "warnings",
        "created_at",
        "updated_at",
    }
    missing = sorted(required.difference(record))
    if missing:
        raise CaptureToolError("invalid_record", f"record missing required fields: {', '.join(missing)}")
    ensure_safe_id(str(record["id"]))
    if record["capture_status"] not in CAPTURE_STATUSES:
        raise CaptureToolError("invalid_record", f"unknown capture_status: {record['capture_status']}")
    if record["lifecycle_status"] not in LIFECYCLE_STATUSES:
        raise CaptureToolError("invalid_record", f"unknown lifecycle_status: {record['lifecycle_status']}")
    files = record["checksums"].get("files", {})
    if record["capture_status"] in {"failed", "blocked", "auth_required", "rejected", "removed"} and not files:
        artifacts = record["artifacts"]
        if any((artifacts.get("page_markdown"), artifacts.get("full_page_image"), artifacts.get("thumbnail_image"), artifacts.get("segments"))):
            raise CaptureToolError("invalid_record", "failure record declares artifacts without checksums")


def index_entry(record: dict[str, Any]) -> dict[str, Any]:
    taxonomy = record["taxonomy"]
    return {
        "id": record["id"],
        "url": record["source"]["url"],
        "normalized_url": record["source"]["normalized_url"],
        "lifecycle_status": record["lifecycle_status"],
        "capture_status": record["capture_status"],
        "page_type": taxonomy["page_type"],
        "audience": taxonomy["audience"],
        "styles": taxonomy["styles"],
        "sections": taxonomy["sections"],
        "copy_patterns": taxonomy["copy_patterns"],
        "conversion_goals": taxonomy["conversion_goals"],
        "captured_at": record["source"]["captured_at"],
        "bundle_checksum": record["checksums"]["bundle"],
        "full_page_checksum": record["checksums"]["files"].get("full-page.webp"),
    }


def replace_index_entry(index: dict[str, Any], record: dict[str, Any]) -> None:
    """Synchronize the bounded index from its source-of-truth record."""
    reference_id = record["id"]
    for position, entry in enumerate(index["entries"]):
        if entry.get("id") == reference_id:
            index["entries"][position] = index_entry(record)
            index["entries"].sort(key=lambda item: str(item.get("id", "")))
            index["updated_at"] = utc_now()
            return
    raise CaptureToolError("reference_not_indexed", f"reference is missing from private index: {reference_id}")


def taxonomy_tags(values: list[str], field: str) -> list[str]:
    """Validate bounded lower-case taxonomy slugs without silently altering meaning."""
    cleaned: list[str] = []
    for value in values:
        tag = clean_text(value).lower()
        if not tag:
            continue
        if not TAXONOMY_TAG_PATTERN.fullmatch(tag):
            raise CaptureToolError("taxonomy_tag_invalid", f"{field} must use lower-case kebab-case tags: {value!r}")
        if tag not in cleaned:
            cleaned.append(tag)
    return cleaned


def approve_reference(
    *,
    root: Path,
    index: dict[str, Any],
    reference_id: str,
    summary: str,
    what_to_borrow: list[str],
    what_not_to_copy: list[str],
    page_type: str,
    audience: list[str],
    styles: list[str],
    sections: list[str],
    copy_patterns: list[str],
    conversion_goals: list[str],
) -> dict[str, Any]:
    """Promote a reviewed, usable candidate and atomically refresh index.yaml."""
    reference_id = ensure_safe_id(reference_id)
    record_path = root / "references" / reference_id / "record.yaml"
    if not record_path.is_file():
        raise CaptureToolError("reference_missing", f"candidate record does not exist: {reference_id}")
    loaded = yaml.safe_load(record_path.read_text(encoding="utf-8"))
    if not isinstance(loaded, dict):
        raise CaptureToolError("invalid_record", f"candidate record is malformed: {reference_id}")
    validate_record(loaded)
    if loaded["lifecycle_status"] != "candidate":
        raise CaptureToolError(
            "approval_status_invalid",
            f"only candidate references can be approved; {reference_id} is {loaded['lifecycle_status']}",
        )
    if loaded["capture_status"] not in {"captured", "partial"}:
        raise CaptureToolError(
            "approval_capture_invalid",
            f"only captured or partial candidates can be approved; {reference_id} is {loaded['capture_status']}",
        )
    cleaned_summary = clean_text(summary)
    borrowed = [clean_text(value) for value in what_to_borrow if clean_text(value)]
    not_copied = [clean_text(value) for value in what_not_to_copy if clean_text(value)]
    if not cleaned_summary or not borrowed or not not_copied:
        raise CaptureToolError(
            "approval_review_missing",
            "approval requires --summary, at least one --what-to-borrow, and at least one --what-not-to-copy",
        )
    normalized_page_type = clean_text(page_type).lower()
    if normalized_page_type not in PAGE_TYPES:
        raise CaptureToolError("taxonomy_page_type_invalid", f"--page-type must be one of: {', '.join(sorted(PAGE_TYPES))}")
    taxonomy = {
        "page_type": normalized_page_type,
        "audience": taxonomy_tags(audience, "--audience"),
        "styles": taxonomy_tags(styles, "--style"),
        "sections": taxonomy_tags(sections, "--section"),
        "copy_patterns": taxonomy_tags(copy_patterns, "--copy-pattern"),
        "conversion_goals": taxonomy_tags(conversion_goals, "--conversion-goal"),
    }
    required_taxonomy = ("styles", "sections", "copy_patterns", "conversion_goals")
    if any(not taxonomy[field] for field in required_taxonomy):
        raise CaptureToolError(
            "approval_taxonomy_missing",
            "approval requires --page-type plus at least one --style, --section, --copy-pattern, and --conversion-goal",
        )

    loaded["lifecycle_status"] = "approved"
    loaded["taxonomy"] = taxonomy
    loaded["curation"] = {
        "summary": cleaned_summary,
        "what_to_borrow": borrowed,
        "what_not_to_copy": not_copied,
    }
    loaded["updated_at"] = utc_now()
    validate_record(loaded)
    replace_index_entry(index, loaded)
    atomic_yaml_write(record_path, loaded)
    atomic_yaml_write(root / "index.yaml", index)
    return loaded


def capture_one(
    *,
    root: Path,
    index: dict[str, Any],
    url: str,
    reference_id: str,
    fixture: Path | None,
    wayback_url: str | None = None,
) -> tuple[dict[str, Any] | None, str]:
    normalized = normalize_url(url)
    existing, reason = duplicate_match(index, reference_id, normalized)
    if existing is not None and reason is not None:
        record_duplicate(
            index,
            root,
            requested_id=reference_id,
            existing_id=str(existing.get("id")),
            normalized_url=normalized,
            reason=reason,
        )
        return None, reason

    references = root / "references"
    final_dir = references / reference_id
    if final_dir.exists():
        raise DuplicateError(f"reference directory already exists and will not be overwritten: {final_dir}")
    staging = references / f".{reference_id}.{uuid.uuid4().hex}.staging"
    staging.mkdir(parents=False, exist_ok=False)
    created_at = utc_now()
    segments: list[str] = []
    result = CaptureResult(final_url=url)
    try:
        try:
            result = capture_fixture(fixture, url) if fixture else capture_live(url)
        except CaptureToolError as exc:
            result = CaptureResult(
                final_url=url,
                access_status=exc.access_status,
                capture_status=exc.status,
                engine="synthetic_fixture" if fixture else "none",
                reason_code=exc.code,
                reason=str(exc),
            )

        if result.markdown is not None:
            (staging / "page.md").write_text(result.markdown, encoding="utf-8")
        if result.image is not None:
            try:
                segments, image_warnings = create_image_artifacts(result.image, staging)
                result.warnings.extend(image_warnings)
            except (CaptureToolError, OSError) as exc:
                result.capture_status = "partial" if result.markdown else "failed"
                result.reason_code = exc.code if isinstance(exc, CaptureToolError) else "image_conversion_failed"
                result.reason = str(exc)
                for candidate in (staging / "full-page.webp", staging / "thumbnail.webp"):
                    candidate.unlink(missing_ok=True)
                shutil.rmtree(staging / "segments", ignore_errors=True)
                segments = []

        artifacts = artifact_paths(staging, segments)
        checksums = artifact_checksums(staging, artifacts)
        record = make_record(
            reference_id=reference_id,
            url=url,
            normalized_url=normalized,
            result=result,
            artifacts=artifacts,
            checksums=checksums,
            created_at=created_at,
            wayback_url=wayback_url,
        )
        validate_record(record)

        checksum = record["checksums"]["bundle"]
        full_page_checksum = record["checksums"]["files"].get("full-page.webp")
        if checksum or full_page_checksum:
            for entry in index["entries"]:
                same_bundle = bool(checksum and entry.get("bundle_checksum") == checksum)
                same_visual = bool(full_page_checksum and entry.get("full_page_checksum") == full_page_checksum)
                if same_bundle or same_visual:
                    record_duplicate(
                        index,
                        root,
                        requested_id=reference_id,
                        existing_id=str(entry.get("id")),
                        normalized_url=normalized,
                        reason="duplicate_checksum",
                    )
                    return None, "duplicate_checksum"

        atomic_yaml_write(staging / "record.yaml", record)
        os.replace(staging, final_dir)
        index["entries"].append(index_entry(record))
        index["entries"].sort(key=lambda item: str(item.get("id", "")))
        index["updated_at"] = utc_now()
        atomic_yaml_write(root / "index.yaml", index)
        return record, record["capture_status"]
    finally:
        if staging.exists():
            shutil.rmtree(staging, ignore_errors=True)


def retry_failed_reference(*, root: Path, index: dict[str, Any], reference_id: str) -> tuple[dict[str, Any] | None, str]:
    """Explicitly replace one failed candidate after a capture-runtime repair.

    This is deliberately not part of ordinary capture deduplication: a retry is
    named by the operator and only applies to a candidate without artifacts.
    """
    reference_id = ensure_safe_id(reference_id)
    reference_dir = root / "references" / reference_id
    record_path = reference_dir / "record.yaml"
    if not record_path.is_file():
        raise CaptureToolError("reference_missing", f"candidate record does not exist: {reference_id}")
    old_record = yaml.safe_load(record_path.read_text(encoding="utf-8"))
    if not isinstance(old_record, dict):
        raise CaptureToolError("invalid_record", f"candidate record is malformed: {reference_id}")
    validate_record(old_record)
    if old_record["lifecycle_status"] != "candidate" or old_record["capture_status"] not in {"failed", "blocked", "auth_required"}:
        raise CaptureToolError("retry_status_invalid", "--retry accepts only failed, blocked, or auth-required candidate references")
    if old_record["checksums"].get("files"):
        raise CaptureToolError("retry_artifacts_present", "--retry refuses to replace a candidate that already has captured artifacts")

    original_entries = index["entries"]
    index["entries"] = [entry for entry in original_entries if entry.get("id") != reference_id]
    backup_dir = root / "references" / f".{reference_id}.{uuid.uuid4().hex}.retry-backup"
    os.replace(reference_dir, backup_dir)
    try:
        record, status = capture_one(
            root=root,
            index=index,
            url=str(old_record["source"]["url"]),
            reference_id=reference_id,
            fixture=None,
            wayback_url=old_record["source"].get("wayback_url"),
        )
        if record is None:
            raise CaptureToolError("retry_duplicate", f"retry could not replace candidate: {status}")
        record["capture"]["retry_of"] = {
            "captured_at": old_record["source"]["captured_at"],
            "capture_status": old_record["capture_status"],
            "reason_code": old_record["capture"].get("reason_code"),
        }
        record["updated_at"] = utc_now()
        validate_record(record)
        atomic_yaml_write(root / "references" / reference_id / "record.yaml", record)
        replace_index_entry(index, record)
        atomic_yaml_write(root / "index.yaml", index)
        shutil.rmtree(backup_dir)
        return record, status
    except Exception:
        if (root / "references" / reference_id).exists():
            shutil.rmtree(root / "references" / reference_id)
        os.replace(backup_dir, reference_dir)
        index["entries"] = original_entries
        atomic_yaml_write(root / "index.yaml", index)
        raise


def read_input_urls(path: Path) -> list[str]:
    if not path.is_file():
        raise CaptureToolError("input_missing", f"input URL file does not exist: {path}")
    urls = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip() and not line.lstrip().startswith("#")]
    if len(urls) > MAX_BATCH_SIZE:
        raise CaptureToolError("batch_too_large", f"input contains {len(urls)} URLs; maximum per run is {MAX_BATCH_SIZE}")
    return urls


def collect_urls(args: argparse.Namespace) -> list[str]:
    urls: list[str] = list(args.url or [])
    if args.input:
        urls.extend(read_input_urls(Path(args.input).expanduser()))
    if args.fixture and not urls:
        candidate_id = args.reference_id or slugify(Path(args.fixture).stem)
        urls.append(f"https://example.invalid/{candidate_id}")
    if not urls and not args.status_only:
        raise CaptureToolError("missing_source", "provide --url, --input, or --fixture")
    if len(urls) > MAX_BATCH_SIZE:
        raise CaptureToolError("batch_too_large", f"run contains {len(urls)} URLs; maximum is {MAX_BATCH_SIZE}")
    return [validate_url(url) for url in urls]


def status_report(root: Path) -> int:
    if not (root / "index.yaml").exists():
        print(json.dumps({"root": str(root), "entries": 0, "capture_statuses": {}, "lifecycle_statuses": {}}, sort_keys=True))
        return 0
    index = load_index(root)
    capture_statuses: dict[str, int] = {}
    lifecycle_statuses: dict[str, int] = {}
    for entry in index["entries"]:
        capture_status = str(entry.get("capture_status", "unknown"))
        lifecycle_status = str(entry.get("lifecycle_status", "unknown"))
        capture_statuses[capture_status] = capture_statuses.get(capture_status, 0) + 1
        lifecycle_statuses[lifecycle_status] = lifecycle_statuses.get(lifecycle_status, 0) + 1
    print(
        json.dumps(
            {
                "root": str(root),
                "entries": len(index["entries"]),
                "capture_statuses": capture_statuses,
                "lifecycle_statuses": lifecycle_statuses,
            },
            sort_keys=True,
        )
    )
    return 0


def list_report(root: Path) -> int:
    if not (root / "index.yaml").exists():
        print(json.dumps({"root": str(root), "entries": []}, sort_keys=True))
        return 0
    index = load_index(root)
    entries = [
        {
            "id": entry.get("id"),
            "source": redact_url(str(entry.get("url", ""))),
            "lifecycle_status": entry.get("lifecycle_status"),
            "capture_status": entry.get("capture_status"),
            "page_type": entry.get("page_type"),
            "audience": entry.get("audience", []),
            "styles": entry.get("styles", []),
            "sections": entry.get("sections", []),
            "copy_patterns": entry.get("copy_patterns", []),
            "conversion_goals": entry.get("conversion_goals", []),
        }
        for entry in index["entries"]
    ]
    print(json.dumps({"root": str(root), "entries": entries}, sort_keys=True))
    return 0


def remote_fingerprint(remote_url: str) -> str:
    return hashlib.sha256(remote_url.encode("utf-8")).hexdigest()


def sync_private_corpus(root: Path, changed_paths: list[Path], operation: str) -> str:
    """Commit and push only the just-written private corpus paths.

    A capture remains valid on disk when Git, LFS, or the remote is unavailable.
    The caller receives a safe status instead of an exception so it can report a
    pending synchronization without losing the local evidence bundle.
    """

    repository = git_ancestor(root)
    if repository is None or repository != root.resolve():
        return "pending reason=private_git_repository_missing"
    if not (root / ".gitattributes").is_file():
        return "pending reason=lfs_attributes_missing"
    if shutil.which("git") is None:
        return "pending reason=git_unavailable"

    lfs = subprocess.run(
        ["git", "-C", str(root), "lfs", "version"],
        capture_output=True,
        text=True,
        check=False,
    )
    if lfs.returncode != 0:
        return "pending reason=git_lfs_unavailable"

    remote = subprocess.run(
        ["git", "-C", str(root), "remote", "get-url", "origin"],
        capture_output=True,
        text=True,
        check=False,
    )
    if remote.returncode != 0 or not remote.stdout.strip():
        return "pending reason=private_remote_missing"
    expected_fingerprint = subprocess.run(
        ["git", "-C", str(root), "config", "--get", "shipglows.inspirationOriginFingerprint"],
        capture_output=True,
        text=True,
        check=False,
    )
    if expected_fingerprint.returncode != 0 or expected_fingerprint.stdout.strip() != remote_fingerprint(remote.stdout.strip()):
        return "pending reason=private_remote_unverified"

    relative_paths: list[str] = []
    for path in changed_paths:
        try:
            relative_paths.append(str(path.resolve().relative_to(root.resolve())))
        except ValueError:
            return "pending reason=sync_path_outside_corpus"

    visual_paths: list[str] = []
    for path in changed_paths:
        if path.is_file() and path.suffix.lower() == ".webp":
            visual_paths.append(str(path.resolve().relative_to(root.resolve())))
        elif path.is_dir():
            visual_paths.extend(str(image.relative_to(root.resolve())) for image in path.rglob("*.webp"))
    if visual_paths:
        attributes = subprocess.run(
            ["git", "-C", str(root), "check-attr", "filter", "--", *visual_paths],
            capture_output=True,
            text=True,
            check=False,
        )
        expected_attributes = {f"{path}: filter: lfs" for path in visual_paths}
        if attributes.returncode != 0 or not expected_attributes.issubset(set(attributes.stdout.splitlines())):
            return "pending reason=lfs_tracking_missing"

    add = subprocess.run(
        ["git", "-C", str(root), "add", "--", *relative_paths],
        capture_output=True,
        text=True,
        check=False,
    )
    if add.returncode != 0:
        return "pending reason=git_add_failed"

    staged = subprocess.run(
        ["git", "-C", str(root), "diff", "--cached", "--quiet"],
        capture_output=True,
        text=True,
        check=False,
    )
    if staged.returncode == 0:
        return "synced status=already_current"
    if staged.returncode != 1:
        return "pending reason=git_status_failed"

    commit = subprocess.run(
        ["git", "-C", str(root), "commit", "-m", f"inspiration: {operation}"],
        capture_output=True,
        text=True,
        check=False,
    )
    if commit.returncode != 0:
        return "pending reason=git_commit_failed"

    push = subprocess.run(
        ["git", "-C", str(root), "push", "origin", "HEAD"],
        capture_output=True,
        text=True,
        check=False,
    )
    if push.returncode != 0:
        return "pending reason=git_push_failed"
    return "synced status=pushed"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Capture public design/copy references into a private rights-aware corpus.",
        epilog="Live capture uses the server's shared global Playwright Node CLI/package and Chromium cache. Synthetic proof uses --fixture --no-network with an output under the system temp directory.",
    )
    parser.add_argument("--url", action="append", help="Public http(s) URL to capture; repeat for a bounded batch.")
    parser.add_argument("--input", help=f"Newline-delimited URL file (maximum {MAX_BATCH_SIZE} non-comment lines).")
    parser.add_argument("--id", dest="reference_id", help="Explicit reference ID; valid only when exactly one source is supplied.")
    parser.add_argument("--output", help="Private corpus root. Defaults to SHIPGLOWS_INSPIRATION_LIBRARY_DIR or the canonical private path.")
    parser.add_argument("--status-only", action="store_true", help="Read the private index and print capture-status counts without capturing.")
    parser.add_argument("--list", action="store_true", help="Read the private index and print bounded reference summaries without loading bundles.")
    parser.add_argument("--approve", metavar="REFERENCE_ID", help="Promote one reviewed candidate and synchronize index.yaml.")
    parser.add_argument("--retry", metavar="REFERENCE_ID", help="Explicitly retry one failed candidate with no captured artifacts.")
    parser.add_argument("--summary", help="Required review summary for --approve.")
    parser.add_argument("--what-to-borrow", action="append", default=[], help="Transferable pattern for --approve; repeat as needed.")
    parser.add_argument("--what-not-to-copy", action="append", default=[], help="Anti-copy constraint for --approve; repeat as needed.")
    parser.add_argument("--page-type", help="Required approved-reference page type.")
    parser.add_argument("--audience", action="append", default=[], help="Optional audience tag for --approve; use lower-case kebab-case and repeat as needed.")
    parser.add_argument("--style", action="append", default=[], help="Required visual style tag for --approve; use lower-case kebab-case and repeat as needed.")
    parser.add_argument("--section", action="append", default=[], help="Required structural-section tag for --approve; use lower-case kebab-case and repeat as needed.")
    parser.add_argument("--copy-pattern", action="append", default=[], help="Required copy pattern tag for --approve; use lower-case kebab-case and repeat as needed.")
    parser.add_argument("--conversion-goal", action="append", default=[], help="Required conversion-goal tag for --approve; use lower-case kebab-case and repeat as needed.")
    parser.add_argument("--wayback-url", help="Optional existing Wayback URL for one capture; never fetched or created automatically.")
    parser.add_argument("--sync", action="store_true", help="Commit and push just-written private corpus files when Git LFS and a private origin are configured; local capture remains valid if sync is pending.")
    parser.add_argument("--no-network", action="store_true", help="Forbid network access; required with --fixture and invalid for live URLs.")
    parser.add_argument("--fixture", help="Synthetic local HTML fixture. Requires --no-network and temporary --output.")
    return parser


def run(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        fixture = Path(args.fixture).expanduser().resolve() if args.fixture else None
        if fixture and not args.no_network:
            raise CaptureToolError("fixture_requires_no_network", "--fixture requires --no-network")
        if args.no_network and not fixture:
            raise CaptureToolError("no_network_requires_fixture", "--no-network requires --fixture; live capture cannot run without network")
        read_mode = bool(args.status_only or args.list)
        curation_mode = bool(args.approve)
        retry_mode = bool(args.retry)
        if args.status_only and args.list:
            raise CaptureToolError("read_mode_conflict", "--status-only and --list cannot be combined")
        taxonomy_arguments = (args.page_type, args.audience, args.style, args.section, args.copy_pattern, args.conversion_goal)
        if read_mode and any((args.url, args.input, args.fixture, args.reference_id, args.wayback_url, args.approve, args.retry, args.summary, args.what_to_borrow, args.what_not_to_copy, args.sync, *taxonomy_arguments)):
            raise CaptureToolError("read_mode_conflict", "--status-only and --list cannot be combined with capture or curation arguments")
        if curation_mode and any((args.url, args.input, args.fixture, args.reference_id, args.wayback_url)):
            raise CaptureToolError("approval_conflict", "--approve cannot be combined with capture arguments")
        if retry_mode and any((args.url, args.input, args.fixture, args.reference_id, args.wayback_url, args.approve, args.summary, args.what_to_borrow, args.what_not_to_copy, *taxonomy_arguments)):
            raise CaptureToolError("retry_conflict", "--retry cannot be combined with capture, approval, review, or taxonomy arguments")
        if not curation_mode and any((args.summary, args.what_to_borrow, args.what_not_to_copy, *taxonomy_arguments)):
            raise CaptureToolError("approval_arguments_without_approve", "review and taxonomy fields require --approve")
        if args.wayback_url:
            validate_url(args.wayback_url)

        output = Path(args.output).expanduser() if args.output else private_default_root()
        root = validate_output_root(output, fixture_mode=bool(fixture and args.no_network))
        if args.status_only:
            return status_report(root)
        if args.list:
            return list_report(root)
        if args.approve:
            index = bootstrap_corpus(root)
            record = approve_reference(
                root=root,
                index=index,
                reference_id=args.approve,
                summary=args.summary or "",
                what_to_borrow=args.what_to_borrow,
                what_not_to_copy=args.what_not_to_copy,
                page_type=args.page_type or "",
                audience=args.audience,
                styles=args.style,
                sections=args.section,
                copy_patterns=args.copy_pattern,
                conversion_goals=args.conversion_goal,
            )
            print(f"id={record['id']} lifecycle_status=approved capture_status={record['capture_status']} record={root / 'references' / record['id'] / 'record.yaml'}")
            if args.sync:
                operation = f"approve {record['id']}"
                print(f"sync={sync_private_corpus(root, [root / 'index.yaml', root / 'references' / record['id']], operation)}")
            return 0

        if args.retry:
            index = bootstrap_corpus(root)
            record, status = retry_failed_reference(root=root, index=index, reference_id=args.retry)
            print(f"id={record['id']} status={status} lifecycle_status={record['lifecycle_status']} record={root / 'references' / record['id'] / 'record.yaml'}")
            if args.sync:
                operation = f"retry {record['id']}"
                print(f"sync={sync_private_corpus(root, [root / 'index.yaml', root / 'references' / record['id']], operation)}")
            return 0 if status in {"captured", "partial"} else 1

        urls = collect_urls(args)
        if args.reference_id and len(urls) != 1:
            raise CaptureToolError("id_batch_conflict", "--id is valid only with exactly one URL or fixture")
        if args.wayback_url and len(urls) != 1:
            raise CaptureToolError("wayback_batch_conflict", "--wayback-url is valid only with exactly one URL or fixture")
        index = bootstrap_corpus(root)
        failed = 0
        duplicates = 0
        captured = 0
        changed_paths: list[Path] = [root / "index.yaml"]
        for url in urls:
            reference_id = ensure_safe_id(args.reference_id) if args.reference_id else derive_id(url)
            record, status = capture_one(
                root=root,
                index=index,
                url=url,
                reference_id=reference_id,
                fixture=fixture,
                wayback_url=args.wayback_url,
            )
            if record is None:
                duplicates += 1
                print(f"id={reference_id} status={status} source={redact_url(url)}")
                continue
            changed_paths.append(root / "references" / reference_id)
            print(f"id={reference_id} status={status} source={redact_url(url)} record={root / 'references' / reference_id / 'record.yaml'}")
            if status == "captured":
                captured += 1
            else:
                failed += 1
        print(f"summary captured={captured} failed_or_partial={failed} duplicates={duplicates} root={root}")
        if args.sync:
            print(f"sync={sync_private_corpus(root, changed_paths, f'capture {len(changed_paths) - 1} reference(s)')}")
        if failed:
            return 1
        if duplicates:
            return 3
        return 0
    except CaptureToolError as exc:
        print(f"error={exc.code} message={exc}", file=sys.stderr)
        return 2
    except (OSError, yaml.YAMLError) as exc:
        print(f"error=filesystem_or_yaml message={type(exc).__name__}: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(run())
