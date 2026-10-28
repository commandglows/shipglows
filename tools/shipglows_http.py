"""Provider-agnostic HTTP JSON transport for ShipGlows web-research CLIs.

One place owns retries, backoff, Retry-After, timeouts, response limits,
redirect refusal and secret-safe error messages. Provider modules only build
requests and phrase their own HTTP errors.
"""

from __future__ import annotations

from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from http.client import HTTPException
import json
import math
import os
import random
import time
from typing import Callable
from urllib.error import HTTPError, URLError
from urllib.request import HTTPRedirectHandler, Request, build_opener

MAX_RESPONSE_BYTES = 4 * 1024 * 1024
MAX_TIMEOUT = 600.0
MAX_ATTEMPTS = 3
RETRY_BASE_DELAY = 1.0
MAX_RETRY_AFTER = 60.0
RETRYABLE_HTTP_CODES = frozenset({429, 502, 503, 504})
GATEWAY_HTTP_CODES = frozenset({502, 503, 504})


class ProviderError(RuntimeError):
    """An actionable provider error safe to display in the terminal."""


class _NoRedirectHandler(HTTPRedirectHandler):
    """Do not forward the authenticated request to a redirect target."""

    def redirect_request(self, req, fp, code, msg, headers, new_url):
        return None


_HTTP_OPENER = build_opener(_NoRedirectHandler())
_sleep = time.sleep


def _open_once(request: Request, timeout: float):
    return _HTTP_OPENER.open(request, timeout=timeout)


def safe_message(message: object, secret: str) -> str:
    text = str(message)
    if secret:
        text = text.replace(secret, "[REDACTED]")
    return " ".join(text.split())[:300]


def resolve_timeout(value: float | None, default: float, env_name: str, error_cls=ProviderError) -> float:
    """Return the explicit value, else ``env_name`` from the environment, else ``default``."""
    if value is None:
        raw = os.environ.get(env_name, "").strip()
        if not raw:
            return default
        try:
            value = float(raw)
        except ValueError:
            raise error_cls(f"{env_name} must be a number of seconds.") from None
    if not math.isfinite(value) or not 0 < value <= MAX_TIMEOUT:
        raise error_cls(f"Timeout must be greater than 0 and at most {MAX_TIMEOUT:g} seconds.")
    return value


def parse_retry_after(value: str | None) -> float | None:
    if not value:
        return None
    value = value.strip()
    try:
        seconds = float(value)
    except ValueError:
        try:
            moment = parsedate_to_datetime(value)
        except (TypeError, ValueError, IndexError):
            return None
        if moment.tzinfo is None:
            moment = moment.replace(tzinfo=timezone.utc)
        seconds = (moment - datetime.now(timezone.utc)).total_seconds()
    return max(0.0, seconds) if math.isfinite(seconds) else None


def backoff_delay(attempt: int) -> float:
    """Exponential backoff (1 s, 2 s, 4 s...) plus up to 50 % random jitter."""
    delay = RETRY_BASE_DELAY * 2 ** (attempt - 1)
    return delay + random.uniform(0, delay / 2)


def network_error_detail(error: BaseException, secret: str) -> str:
    """Name the failure and its short reason so DNS, refusal, TLS, proxy and timeouts differ."""
    kind = type(error).__name__
    reason = error.reason if isinstance(error, URLError) else None
    if isinstance(reason, BaseException):
        kind = f"{kind}/{type(reason).__name__}"
    text = safe_message(reason if reason is not None else error, secret)[:160]
    return f"{kind}: {text}" if text else kind


def attempts_label(count: int) -> str:
    return f"{count} attempt" + ("" if count == 1 else "s")


def send_json(
    request: Request,
    *,
    provider: str,
    secret: str,
    timeout: float,
    http_error: Callable[[int, bytes], str],
    opener=None,
    retry: bool = True,
    retry_codes: frozenset[int] = RETRYABLE_HTTP_CODES,
    error_cls: type[ProviderError] = ProviderError,
    max_bytes: int = MAX_RESPONSE_BYTES,
) -> dict:
    """Send one request with bounded retries and return its JSON object.

    Network failures and ``retry_codes`` responses are retried up to
    MAX_ATTEMPTS times with exponential backoff and jitter, honouring
    Retry-After. Other HTTP errors fail at once. ``retry=False`` keeps a single
    attempt for requests that create remote resources, so a lost response never
    duplicates them. ``http_error(code, body)`` phrases the provider's error.
    ``max_bytes`` caps the body; raise it only for a trusted local service.
    """
    max_attempts = MAX_ATTEMPTS if retry else 1
    attempt = 0
    while True:
        attempt += 1
        try:
            with (opener or _open_once)(request, timeout=timeout) as response:
                body = response.read(max_bytes + 1)
            break
        except HTTPError as error:
            try:
                error_body = error.read(MAX_RESPONSE_BYTES + 1)
            finally:
                error.close()
            headers = getattr(error, "headers", None)
            retry_after = parse_retry_after(headers.get("Retry-After") if headers is not None else None)
            message = f"{http_error(error.code, error_body)} ({attempts_label(attempt)})"
            if error.code not in retry_codes or attempt >= max_attempts:
                raise error_cls(message + ".") from None
            if retry_after is not None and retry_after > MAX_RETRY_AFTER:
                raise error_cls(f"{message}; provider asked to retry after {retry_after:.0f}s.") from None
            delay = retry_after if retry_after is not None else backoff_delay(attempt)
        except (URLError, TimeoutError, OSError, HTTPException) as error:
            if attempt >= max_attempts:
                raise error_cls(
                    f"{provider} network request failed ({network_error_detail(error, secret)}) "
                    f"after {attempts_label(attempt)}; timeout {timeout:g}s per attempt."
                ) from None
            delay = backoff_delay(attempt)
        _sleep(delay)

    if len(body) > max_bytes:
        raise error_cls(f"{provider} response exceeded the {max_bytes // (1024 * 1024)} MiB safety limit.")
    try:
        data = json.loads(body.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        raise error_cls(f"{provider} returned invalid JSON.") from None
    if not isinstance(data, dict):
        raise error_cls(f"{provider} returned an unexpected response format.")
    return data
