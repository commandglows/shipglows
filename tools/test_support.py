"""Shared helpers for repository contract tests."""

from __future__ import annotations

import os
from pathlib import Path


def optional_public_site(repo_root: Path) -> Path | None:
    """Resolve an optional ShipGlows public-site checkout without inventing one."""

    configured = os.environ.get("SHIPGLOWS_SITE_ROOT")
    candidates = (
        Path(configured).expanduser() if configured else None,
        repo_root / "shipglows-site",
        repo_root.parent / "shipglows-site",
    )
    for candidate in candidates:
        if candidate is not None and candidate.is_dir():
            return candidate.resolve()
    return None
