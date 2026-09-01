"""Bounded version evaluation for trusted environment capability evidence.

This is deliberately not a package-manager constraint engine.  It accepts only
the exact coordinates and comparator conjunctions required by the environment
contract, and returns ``unknown`` for every other grammar.
"""

from __future__ import annotations

import re
from typing import Optional, Tuple


COORDINATE = r"\d{1,18}"
VERSION = re.compile(rf"^v?({COORDINATE})\.({COORDINATE})(?:\.({COORDINATE}))?(?:\.({COORDINATE}))?$")
COMPARATOR = re.compile(rf"^(>=|>)({COORDINATE}(?:\.{COORDINATE}){{0,3}})$")
UPPER_COMPARATOR = re.compile(rf"^(<=|<)({COORDINATE}(?:\.{COORDINATE}){{0,3}})$")


def _parse_version(value: str) -> Optional[Tuple[int, int, int, int]]:
    if not isinstance(value, str):
        return None
    match = VERSION.fullmatch(value.strip())
    if not match:
        return None
    return tuple(int(part or 0) for part in match.groups())


def _parse_comparator_version(value: str) -> Optional[Tuple[int, int, int, int]]:
    if not isinstance(value, str) or not re.fullmatch(rf"{COORDINATE}(?:\.{COORDINATE}){{0,3}}", value):
        return None
    parts = [int(part) for part in value.split(".")]
    return tuple(parts + ([0] * (4 - len(parts))))


def evaluate_version_constraint(version: str, constraint: str | None) -> str:
    """Return ``ready``, ``incompatible``, or ``unknown``.

    Supported constraints are ``*``, one exact dotted version, or a
    whitespace-separated conjunction of ``>=``, ``>``, ``<=`` and ``<``
    comparators. Bare major versions, ranges with OR, caret/tilde syntax, and
    prerelease policy remain unknown instead of being guessed.
    """

    observed = _parse_version(version)
    if observed is None or not isinstance(constraint, str) or not constraint.strip():
        return "unknown"
    expression = constraint.strip()
    if expression == "*":
        return "ready"
    exact = _parse_version(expression)
    if exact is not None:
        return "ready" if observed == exact else "incompatible"

    clauses = expression.split()
    if not clauses:
        return "unknown"
    results = []
    for clause in clauses:
        match = COMPARATOR.fullmatch(clause) or UPPER_COMPARATOR.fullmatch(clause)
        if not match:
            return "unknown"
        expected = _parse_comparator_version(match.group(2))
        if expected is None:
            return "unknown"
        operator = match.group(1)
        results.append(
            observed >= expected
            if operator == ">="
            else observed > expected
            if operator == ">"
            else observed <= expected
            if operator == "<="
            else observed < expected
        )
    return "ready" if all(results) else "incompatible"
