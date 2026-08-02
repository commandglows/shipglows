#!/usr/bin/env python3
"""Read-only Google Search Console CLI using only the Python standard library."""

import argparse
import json
import os
import secrets
import sys
import time
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, quote, urlencode, urlparse
from urllib.request import Request, urlopen

READONLY_SCOPE = "https://www.googleapis.com/auth/webmasters.readonly"
TOKEN_URL = "https://oauth2.googleapis.com/token"
AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
WEBMASTERS_URL = "https://www.googleapis.com/webmasters/v3"
INSPECTION_URL = "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect"


class GscError(RuntimeError):
    pass


def config_dir() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "shipglows" / "gsc"


def token_path(profile: str) -> Path:
    if not profile.replace("-", "").replace("_", "").isalnum():
        raise GscError("Invalid profile name. Use letters, numbers, '-' or '_'.")
    return config_dir() / f"{profile}.json"


def write_private_json(path: Path, value: dict) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path.parent, 0o700)
    temp = path.with_suffix(".tmp")
    with os.fdopen(os.open(temp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w", encoding="utf-8") as handle:
        json.dump(value, handle)
        handle.write("\n")
    os.replace(temp, path)
    os.chmod(path, 0o600)


def read_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise GscError("No authorized profile. Run: shipglows-gsc auth login --client-secrets <file>") from error
    except json.JSONDecodeError as error:
        raise GscError("Stored GSC credentials are invalid. Run auth logout, then auth login again.") from error


def load_client(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))["installed"]
        if not value["client_id"] or not value.get("client_secret"):
            raise KeyError("client_id")
        return value
    except (FileNotFoundError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise GscError("Expected a Google OAuth Desktop client-secret JSON containing an 'installed' object.") from error


def request_json(url: str, method="GET", data=None, token=None, opener=urlopen) -> dict:
    headers = {"Accept": "application/json"}
    payload = None
    if data is not None:
        payload = json.dumps(data).encode("utf-8")
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = Request(url, data=payload, headers=headers, method=method)
    try:
        with opener(request, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except HTTPError as error:
        body = error.read().decode("utf-8", "replace")
        try:
            detail = json.loads(body).get("error", {}).get("message", "Google API request failed")
        except json.JSONDecodeError:
            detail = "Google API request failed"
        raise GscError(f"Google API error ({error.code}): {detail}") from error
    except (URLError, TimeoutError) as error:
        raise GscError("Google API request failed: network unavailable or timed out.") from error


def refresh_token(profile: str, opener=urlopen) -> str:
    credentials = read_json(token_path(profile))
    if not credentials.get("refresh_token"):
        raise GscError("Profile has no refresh token. Run auth login again.")
    form = urlencode({"client_id": credentials["client_id"], "client_secret": credentials["client_secret"], "refresh_token": credentials["refresh_token"], "grant_type": "refresh_token"}).encode()
    request = Request(TOKEN_URL, data=form, headers={"Content-Type": "application/x-www-form-urlencoded"}, method="POST")
    try:
        with opener(request, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))["access_token"]
    except (HTTPError, KeyError, json.JSONDecodeError, URLError) as error:
        raise GscError("Authorization expired or was revoked. Run auth login again.") from error


def require_date(value: str) -> str:
    if len(value) != 10 or value[4] != "-" or value[7] != "-" or not value.replace("-", "").isdigit():
        raise argparse.ArgumentTypeError("date must use YYYY-MM-DD")
    return value


def api_url(path: str) -> str:
    return f"{WEBMASTERS_URL}/sites/{quote(path, safe='') }"


def command_sites(args):
    return request_json(f"{WEBMASTERS_URL}/sites", token=refresh_token(args.profile))


def command_sitemaps(args):
    return request_json(f"{api_url(args.site)}/sitemaps", token=refresh_token(args.profile))


def command_performance(args):
    dimensions = args.dimension or ["page"]
    allowed = {"date", "query", "page", "country", "device", "searchAppearance"}
    if any(value not in allowed for value in dimensions):
        raise GscError("Unsupported dimension. Use date, query, page, country, device, or searchAppearance.")
    body = {"startDate": args.start_date, "endDate": args.end_date, "dimensions": dimensions, "type": args.search_type, "rowLimit": args.row_limit}
    return request_json(f"{api_url(args.site)}/searchAnalytics/query", method="POST", data=body, token=refresh_token(args.profile))


def command_inspect(args):
    if urlparse(args.url).scheme not in {"https", "http"}:
        raise GscError("URL inspection requires an absolute http(s) URL.")
    return request_json(INSPECTION_URL, method="POST", data={"inspectionUrl": args.url, "siteUrl": args.site}, token=refresh_token(args.profile))


def command_status(args):
    path = token_path(args.profile)
    return {"profile": args.profile, "authorized": path.exists(), "token_path": str(path) if path.exists() else None, "scope": READONLY_SCOPE}


def command_logout(args):
    path = token_path(args.profile)
    if path.exists():
        path.unlink()
    return {"profile": args.profile, "authorized": False}


def command_login(args):
    client = load_client(Path(args.client_secrets))
    state = secrets.token_urlsafe(24)
    server = HTTPServer(("127.0.0.1", 0), BaseHTTPRequestHandler)
    server.socket.settimeout(180)
    redirect_uri = f"http://127.0.0.1:{server.server_port}/callback"
    query = urlencode({"client_id": client["client_id"], "redirect_uri": redirect_uri, "response_type": "code", "scope": READONLY_SCOPE, "access_type": "offline", "prompt": "consent", "state": state})
    webbrowser.open(f"{AUTH_URL}?{query}")
    server.timeout = 180
    try:
        request = server.get_request()[0]
    except OSError as error:
        server.server_close()
        raise GscError("OAuth callback timed out or could not be received; no credentials were saved.") from error
    raw = request.recv(8192).decode("utf-8", "replace")
    request.sendall(b"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nShipGlows authorization received. You may close this tab.")
    request.close(); server.server_close()
    values = parse_qs(urlparse(raw.split(" ")[1]).query)
    if values.get("state", [""])[0] != state or not values.get("code"):
        raise GscError("OAuth callback was invalid or cancelled; no credentials were saved.")
    form = urlencode({"code": values["code"][0], "client_id": client["client_id"], "client_secret": client["client_secret"], "redirect_uri": redirect_uri, "grant_type": "authorization_code"}).encode()
    response = request_json(TOKEN_URL, method="POST", data=None, opener=lambda req, timeout: urlopen(Request(TOKEN_URL, data=form, headers={"Content-Type": "application/x-www-form-urlencoded"}, method="POST"), timeout=timeout))
    if not response.get("refresh_token"):
        raise GscError("Google did not return a refresh token. Retry auth login and approve consent.")
    write_private_json(token_path(args.profile), {"client_id": client["client_id"], "client_secret": client["client_secret"], "refresh_token": response["refresh_token"], "created_at": int(time.time()), "scope": READONLY_SCOPE})
    return {"profile": args.profile, "authorized": True, "scope": READONLY_SCOPE}


def parser():
    root = argparse.ArgumentParser(prog="shipglows-gsc", description="Read-only Google Search Console API CLI")
    root.add_argument("--profile", default="default")
    commands = root.add_subparsers(dest="command", required=True)
    auth = commands.add_parser("auth").add_subparsers(dest="auth_command", required=True)
    login = auth.add_parser("login"); login.add_argument("--client-secrets", required=True); login.set_defaults(handler=command_login)
    auth.add_parser("status").set_defaults(handler=command_status)
    auth.add_parser("logout").set_defaults(handler=command_logout)
    commands.add_parser("sites").set_defaults(handler=command_sites)
    sitemap = commands.add_parser("sitemaps"); sitemap.add_argument("--site", required=True); sitemap.set_defaults(handler=command_sitemaps)
    perf = commands.add_parser("performance"); perf.add_argument("--site", required=True); perf.add_argument("--start-date", required=True, type=require_date); perf.add_argument("--end-date", required=True, type=require_date); perf.add_argument("--dimension", action="append"); perf.add_argument("--search-type", default="web", choices=["web", "image", "video", "news", "discover", "googleNews"]); perf.add_argument("--row-limit", default=1000, type=int); perf.set_defaults(handler=command_performance)
    inspect = commands.add_parser("inspect"); inspect.add_argument("--site", required=True); inspect.add_argument("--url", required=True); inspect.set_defaults(handler=command_inspect)
    return root


def main(argv=None):
    args = parser().parse_args(argv)
    try:
        print(json.dumps(args.handler(args), indent=2, sort_keys=True))
        return 0
    except GscError as error:
        print(f"shipglows-gsc: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
