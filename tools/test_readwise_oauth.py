"""Real loopback OAuth callbacks, fake provider; never uses personal credentials."""

import base64
import hashlib
import importlib.util
import json
from pathlib import Path
import socket
import tempfile
import unittest
from urllib.error import HTTPError
from urllib.parse import parse_qs, urlencode, urlsplit
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("oauth", ROOT / "cli/readwise_oauth.py")
oauth = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(oauth)


class OAuthTests(unittest.TestCase):
    def run_login(self, browser_action=None, token_failure=False, initial=None, timeout=2):
        calls, messages, urls = [], [], []
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".readwise-cli.json"
            previous = initial or {"config": {"readonly": True}, "client_id": "old-6274-client", "client_secret": "old-secret", "access_token": "old-token", "tools_cache": {"tools": []}}
            config.write_text(json.dumps(previous))

            def request(url, **kwargs):
                calls.append((url, kwargs))
                if url == oauth.DISCOVERY_URL:
                    return {"authorization_endpoint": "https://readwise.io/authorize", "registration_endpoint": "https://readwise.io/register", "token_endpoint": "https://readwise.io/token"}
                if url.endswith("/register"):
                    return {"client_id": "new-client", "client_secret": "new-secret"}
                if token_failure:
                    raise oauth.OAuthError("Token exchange failed.")
                return {"access_token": "new-token", "refresh_token": "new-refresh", "expires_in": 3600}

            def send(uri, **params):
                with urlopen(uri + "?" + urlencode(params), timeout=2) as response:
                    return response.status, response.read().decode()

            def browser(url):
                urls.append(url)
                params = parse_qs(urlsplit(url).query)
                uri, state = params["redirect_uri"][0], params["state"][0]
                if browser_action:
                    return browser_action(config, send, uri, state)
                self.assertEqual(send(uri, state=state, code="fixture-code")[0], 200)
                return True

            error = None
            try:
                oauth.login(config_path=config, browser=browser, request=request, timeout=timeout, output=messages.append)
            except oauth.OAuthError as exception:
                error = str(exception)
            after = json.loads(config.read_text())
        return calls, messages, urls, previous, after, error

    def test_dynamic_bound_port_pkce_registration_and_official_session_format(self):
        calls, messages, urls, previous, after, error = self.run_login()
        self.assertIsNone(error)
        auth = parse_qs(urlsplit(urls[0]).query)
        uri = auth["redirect_uri"][0]
        self.assertEqual(urlsplit(uri).hostname, "127.0.0.1")
        self.assertNotEqual(urlsplit(uri).port, 6274)
        registered = json.loads(calls[1][1]["body"])
        exchanged = parse_qs(calls[2][1]["body"].decode())
        self.assertEqual(registered["redirect_uris"], [uri])
        self.assertEqual(exchanged["redirect_uri"], [uri])
        challenge = base64.urlsafe_b64encode(hashlib.sha256(exchanged["code_verifier"][0].encode()).digest()).decode().rstrip("=")
        self.assertEqual(auth["code_challenge"], [challenge])
        self.assertEqual(auth["code_challenge_method"], ["S256"])
        self.assertEqual(after["auth_type"], "oauth")
        self.assertEqual(after["client_id"], "new-client")
        self.assertEqual(after["access_token"], "new-token")
        self.assertTrue(after["config"]["readonly"])
        self.assertNotIn("tools_cache", after)
        self.assertGreater(after["expires_at"], 0)
        for credential in ("new-token", "new-secret", "fixture-code", auth["state"][0]):
            self.assertNotIn(credential, " ".join(messages))
        # Cleanup has actually released the callback listener.
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", urlsplit(uri).port))

    def test_wrong_state_does_not_consume_callback(self):
        def action(config, send, uri, state):
            with self.assertRaises(HTTPError) as caught:
                send(uri, state="wrong", code="invalid")
            self.assertEqual(caught.exception.code, 400)
            caught.exception.close()
            send(uri, state=state, code="valid")
            return True
        result = self.run_login(browser_action=action)
        self.assertIsNone(result[-1])
        self.assertEqual(parse_qs(result[0][2][1]["body"].decode())["code"], ["valid"])

    def test_oauth_denial_preserves_existing_credentials_and_never_echoes_error(self):
        def action(config, send, uri, state):
            status, content = send(uri, state=state, error="<script>private-provider-error</script>")
            self.assertNotIn("private-provider-error", content)
            return True
        calls, messages, urls, previous, after, error = self.run_login(browser_action=action)
        self.assertIsNotNone(error)
        self.assertEqual(previous, after)
        self.assertEqual(len(calls), 2)
        self.assertNotIn("private-provider-error", error)

    def test_exchange_failure_preserves_old_session(self):
        result = self.run_login(token_failure=True)
        self.assertIsNotNone(result[-1])
        self.assertEqual(result[3], result[4])

    def test_browser_failure_preserves_old_session(self):
        result = self.run_login(browser_action=lambda *args: False)
        self.assertIsNotNone(result[-1])
        self.assertEqual(result[3], result[4])

    def test_timeout_preserves_session_and_closes_listener(self):
        result = self.run_login(browser_action=lambda *args: True, timeout=0.01)
        self.assertIsNotNone(result[-1])
        self.assertEqual(result[3], result[4])
        uri = parse_qs(urlsplit(result[2][0]).query)["redirect_uri"][0]
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", urlsplit(uri).port))

    def test_concurrent_session_change_not_overwritten(self):
        def action(config, send, uri, state):
            current = json.loads(config.read_text())
            current["access_token"] = "another-session"
            config.write_text(json.dumps(current))
            send(uri, state=state, code="fixture")
            return True
        result = self.run_login(browser_action=action)
        self.assertIsNotNone(result[-1])
        self.assertEqual(result[4]["access_token"], "another-session")

    def test_config_setting_changed_during_browser_is_preserved(self):
        def action(config, send, uri, state):
            current = json.loads(config.read_text())
            current["config"]["readonly"] = False
            config.write_text(json.dumps(current))
            send(uri, state=state, code="fixture")
            return True
        result = self.run_login(browser_action=action)
        self.assertIsNone(result[-1])
        self.assertFalse(result[4]["config"]["readonly"])

    def test_provider_endpoints_reject_http_and_foreign_hosts(self):
        for url in ("http://readwise.io/token", "https://readwise.io.attacker.test/token", "https://readwise.io@attacker.test/token", "file:///tmp/token", "https://readwise.io:evil/token", "https://readwise.io:8080/token", "https://[broken/token"):
            with self.subTest(url=url), self.assertRaises(oauth.OAuthError):
                oauth.endpoint(url)


if __name__ == "__main__":
    unittest.main()
