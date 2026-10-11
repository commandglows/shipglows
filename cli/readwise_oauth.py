"""Readwise browser OAuth with an OS-assigned, already bound loopback callback."""

from __future__ import annotations

import base64
import hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import math
import os
from pathlib import Path
import secrets
import tempfile
import threading
import time
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener
import webbrowser

DISCOVERY_URL = "https://readwise.io/o/.well-known/oauth-authorization-server"
MAX_RESPONSE = 1024 * 1024


class OAuthError(RuntimeError):
    """Credential-free error safe for terminal output."""


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def endpoint(value: object) -> str:
    if not isinstance(value, str):
        raise OAuthError("Métadonnées OAuth Readwise invalides.")
    try:
        parsed = urlsplit(value)
        port = parsed.port
    except ValueError:
        raise OAuthError("Adresse OAuth Readwise invalide.") from None
    host = parsed.hostname or ""
    if parsed.scheme != "https" or port not in (None, 443) or not (host == "readwise.io" or host.endswith(".readwise.io")) or parsed.username or parsed.password or parsed.fragment:
        raise OAuthError("Adresse OAuth Readwise non autorisée.")
    return value


def request_json(url: str, *, body: bytes | None = None, headers: dict | None = None) -> dict:
    try:
        request = Request(endpoint(url), data=body, headers=headers or {})
        with build_opener(NoRedirect()).open(request, timeout=30) as response:
            data = response.read(MAX_RESPONSE + 1)
        if len(data) > MAX_RESPONSE:
            raise OAuthError("Réponse OAuth Readwise trop volumineuse.")
        result = json.loads(data)
        if not isinstance(result, dict):
            raise ValueError
        return result
    except HTTPError as error:
        code = error.code
        error.close()
        raise OAuthError(f"Requête OAuth Readwise refusée (HTTP {code}).") from None
    except (URLError, OSError, ValueError):
        raise OAuthError("Requête OAuth Readwise impossible ou réponse invalide.") from None


def load_config(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError
        return data
    except FileNotFoundError:
        return {}
    except (OSError, ValueError):
        raise OAuthError("Configuration Readwise illisible ; aucun changement effectué.") from None


def save_config(path: Path, config: dict) -> None:
    # Replace only after complete authentication. A failed write keeps the old file.
    temporary = None
    try:
        descriptor, temporary = tempfile.mkstemp(prefix=".readwise-oauth-", dir=path.parent)
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(config, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, 0o600)
        os.replace(temporary, path)
    except OSError:
        raise OAuthError("Connexion effectuée mais sauvegarde locale impossible.") from None
    finally:
        if temporary and os.path.exists(temporary):
            os.unlink(temporary)


def login(*, config_path: Path | None = None, browser=None, request=None, timeout: float = 120, output=print) -> None:
    config_path = config_path or Path.home() / ".readwise-cli.json"
    browser = browser or webbrowser.open
    request = request or request_json
    config = load_config(config_path)
    state = secrets.token_urlsafe(32)
    verifier = secrets.token_urlsafe(48)
    challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode("ascii")).digest()).decode("ascii").rstrip("=")
    received = threading.Event()
    callback = {}
    callback_lock = threading.Lock()

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, format, *args):
            pass  # Callback queries contain authorization codes and state.

        def do_GET(self):
            if len(self.path) > 8192:
                self.send_error(414)
                return
            parsed = urlsplit(self.path)
            params = parse_qs(parsed.query)
            if parsed.path != "/callback":
                self.send_error(404)
                return
            with callback_lock:
                if params.get("state") != [state] or received.is_set():
                    self.send_error(400, "Invalid callback")
                    return
                code = params.get("code", [])
                if "error" in params:
                    callback["error"] = True
                elif len(code) == 1 and code[0]:
                    callback["code"] = code[0]
                else:
                    self.send_error(400, "Missing code")
                    return
                received.set()
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write("Retour OAuth reçu. Vous pouvez fermer cet onglet et revenir au terminal.".encode("utf-8"))

    try:
        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    except OSError:
        raise OAuthError("Impossible de réserver un port de retour OAuth local.") from None
    server.daemon_threads = True
    worker = threading.Thread(target=server.serve_forever, daemon=True)
    worker.start()
    redirect_uri = f"http://127.0.0.1:{server.server_port}/callback"
    try:
        output(f"Retour OAuth local prêt sur le port {server.server_port}.")
        metadata = request(DISCOVERY_URL)
        authorization = endpoint(metadata.get("authorization_endpoint"))
        registration = endpoint(metadata.get("registration_endpoint"))
        token_endpoint = endpoint(metadata.get("token_endpoint"))
        # Each login registers the actual reserved URI; never reuse the old 6274 client.
        client = request(registration, body=json.dumps({
            "client_name": "shipglows-readwise",
            "redirect_uris": [redirect_uri],
            "grant_types": ["authorization_code", "refresh_token"],
            "token_endpoint_auth_method": "client_secret_basic",
        }).encode(), headers={"Content-Type": "application/json"})
        client_id, client_secret = client.get("client_id"), client.get("client_secret")
        if not isinstance(client_id, str) or not client_id or not isinstance(client_secret, str) or not client_secret:
            raise OAuthError("Enregistrement OAuth Readwise incomplet.")
        url = authorization + ("&" if "?" in authorization else "?") + urlencode({
            "response_type": "code", "client_id": client_id,
            "redirect_uri": redirect_uri, "scope": "openid read write",
            "code_challenge": challenge, "code_challenge_method": "S256", "state": state,
        })
        output("Ouverture du navigateur pour la connexion Readwise…")
        if not browser(url):
            raise OAuthError("Ouverture du navigateur impossible ; vérifiez le navigateur par défaut.")
        if not received.wait(timeout):
            raise OAuthError("Connexion annulée : aucun retour OAuth reçu dans le délai imparti.")
        if callback.get("error"):
            raise OAuthError("Connexion refusée ou annulée dans Readwise.")
        authorization_header = base64.b64encode(f"{client_id}:{client_secret}".encode()).decode("ascii")
        tokens = request(token_endpoint, body=urlencode({
            "grant_type": "authorization_code", "code": callback["code"],
            "redirect_uri": redirect_uri, "code_verifier": verifier,
        }).encode(), headers={
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": f"Basic {authorization_header}",
        })
        access, refresh, expires = tokens.get("access_token"), tokens.get("refresh_token"), tokens.get("expires_in")
        if not isinstance(access, str) or not access or not isinstance(refresh, str) or not refresh or not isinstance(expires, (int, float)) or isinstance(expires, bool) or not math.isfinite(expires) or expires <= 0:
            raise OAuthError("Réponse de connexion Readwise incomplète.")
        # Reread to preserve config updates made while the browser was open.
        latest = load_config(config_path)
        if any(latest.get(key) != config.get(key) for key in ("access_token", "refresh_token", "client_id", "client_secret")):
            raise OAuthError("La session locale a changé pendant la connexion ; relancez login.")
        latest.update(access_token=access, refresh_token=refresh, expires_at=time.time() * 1000 + expires * 1000, auth_type="oauth", client_id=client_id, client_secret=client_secret)
        latest.pop("tools_cache", None)
        save_config(config_path, latest)
        output("Connexion Readwise réussie. Session enregistrée pour le CLI officiel.")
    finally:
        server.shutdown()
        server.server_close()
        worker.join(timeout=2)
