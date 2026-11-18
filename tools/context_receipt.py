"""Validate a context capsule read receipt. The receipt is not truth."""

from __future__ import annotations

from typing import Any


VERDICTS = {"context_ready", "context_partial", "context_conflict", "context_stale"}
BLOCKING_STATES = {"unknown", "hypothesis", "conflict", "stale"}
BODY_KEYS = {"body", "text", "content", "excerpt", "source_text", "value"}
REASONS = {"selected", "not_needed", "absent", "unreadable", "stale", "private", "no_permission"}


class ReceiptError(ValueError):
    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


def validate_read_receipt(capsule: dict[str, Any]) -> None:
    receipt = capsule.get("read_receipt")
    if not isinstance(receipt, dict):
        raise ReceiptError("missing_receipt")
    if not {"served", "withheld", "verdict"} <= set(receipt):
        raise ReceiptError("missing_receipt")
    if receipt.get("verdict") not in VERDICTS:
        raise ReceiptError("invalid_verdict")
    for bucket in ("served", "withheld"):
        items = receipt.get(bucket)
        if not isinstance(items, list):
            raise ReceiptError("invalid_receipt")
        for item in items:
            if not isinstance(item, dict) or "pointer" not in item or "reason" not in item:
                raise ReceiptError("invalid_receipt")
            if item.get("reason") not in REASONS:
                raise ReceiptError("invalid_receipt")
            if BODY_KEYS & set(item):
                raise ReceiptError("receipt_contains_body")
            if not isinstance(item.get("pointer"), str) or item["pointer"] == "":
                raise ReceiptError("invalid_receipt")
    if receipt["verdict"] == "context_ready":
        claims = list(capsule.get("qualified_truth") or []) + list(capsule.get("gaps") or [])
        for claim in claims:
            if isinstance(claim, dict) and claim.get("state") in BLOCKING_STATES:
                raise ReceiptError("ready_with_unsettled_claim")
