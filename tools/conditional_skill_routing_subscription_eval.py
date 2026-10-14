"""Isolated hash-only observation intake. Semantic judgement remains independent.

Run inside evaluator-shell only. No model, network, credentials or held-out read.
"""
import base64
import hashlib
import json
from pathlib import Path
import re
import sys


def packed(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


def sha(value):
    return hashlib.sha256(value).hexdigest()


def intake(path, *, trusted_root=Path("/opt/evaluator/inputs/subscription-observations")):
    root = Path(trusted_root).resolve()
    path = Path(path)
    if path.is_symlink() or not path.resolve().is_relative_to(root):
        raise ValueError()
    raw = path.read_bytes()
    if not 0 < len(raw) <= 128 * 1024 * 1024:
        raise ValueError()
    package = json.loads(raw)
    if package.get("schema_version") not in (1, 2) or package.get("variant") != "baseline":
        raise ValueError()
    if not re.fullmatch(r"[0-9a-f]{64}", package["consumer_profile_sha256"]):
        raise ValueError()
    case = package["case_id"]
    if case not in [family + str(index) for family in "HABS" for index in (1, 2)]:
        raise ValueError()
    if not re.fullmatch(r"[A-Za-z0-9-]{1,48}", package["run_label"]):
        raise ValueError()
    inventory = {}
    def read_spool(item):
        name = item["body_path"]
        if not isinstance(name, str) or name.startswith("/") or "\\" in name or ":" in name or ".." in Path(name).parts:
            raise ValueError()
        source = path.parent / name
        if source.is_symlink() or not source.resolve().is_relative_to(path.parent.resolve()):
            raise ValueError()
        content = source.read_bytes()
        if sha(content) != item["sha256"] or len(content) != item["bytes"]:
            raise ValueError()
        return content
    if package["schema_version"] == 2:
        read_spool(package["controller_ref"])
    for name, item in package["workspace_files"].items():
        if name == "parent-only-provider-exchanges" or name.startswith("/") or Path(name).is_absolute() or ".." in Path(name).parts or "\\" in name or ":" in name:
            raise ValueError()
        content = read_spool(item) if package["schema_version"] == 2 else base64.b64decode(item["body_b64"], validate=True)
        if sha(content) != item["sha256"] or len(content) != item["bytes"]:
            raise ValueError()
        inventory[name] = {"bytes":len(content), "sha256":sha(content)}
    exchanges = package["parent_provider_exchanges"]
    if exchanges:
        if package["schema_version"] == 2:
            exchanges = [{**row, "request":base64.b64encode(read_spool(row["request"])).decode(),
                "response":base64.b64encode(read_spool(row["response"])).decode()} for row in exchanges]
        encoded = packed(exchanges)
        inventory["parent-only-provider-exchanges"] = {"bytes":len(encoded), "sha256":sha(encoded)}
    digest = sha(packed(inventory))
    if digest != package["observation_manifest_sha256"]:
        raise ValueError()
    receipt = {"schema_version":1, "campaign_id":package["campaign_id"], "case_id":case,
        "observation_manifest_sha256":digest, "status":"INCONCLUSIVE",
        "review_id":"pending-semantic-" + sha(package["run_label"].encode())[:24]}
    receipt["receipt_sha256"] = sha(packed(receipt))
    return {"receipt":receipt, "package_sha256":sha(raw), "inventory_verified":True,
        "semantic_review_pending":True, "model_calls":0, "launch_performed":False}


def main():
    try:
        result = intake(sys.argv[1])
        print(json.dumps(result))
        return 0
    except Exception:
        print(json.dumps({"intake_verified":False, "private_diagnostics_suppressed":True}))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
