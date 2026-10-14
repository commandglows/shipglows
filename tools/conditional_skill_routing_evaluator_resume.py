"""Content-free resume hash check; run only inside evaluator-shell. No launch."""
from pathlib import Path
import hashlib
import json
import os
import re
import sys

def main():
    try:
        handle = sys.argv[1]
        if not re.fullmatch(r"csr-v5-[0-9a-f]{24}", handle):
            raise ValueError("invalid opaque resume ID")
        root = Path("/opt/evaluator/inputs")
        index = root / ".independent-resume" / (handle + ".json")
        value = json.loads(index.read_text())
        if value["resume_id"] != handle or value["collection_authorized"] is not False:
            raise ValueError("invalid resume state")
        for key in ("payload", "manifest"):
            target = Path(value[key]).resolve()
            if not target.is_relative_to(root.resolve()):
                raise ValueError("resume escape")
            if hashlib.sha256(target.read_bytes()).hexdigest() != value[key + "_sha256"]:
                raise ValueError("sealed artifact drift")
        support = Path("/opt/evaluator/support-v5")
        if not os.statvfs(support).f_flag & os.ST_RDONLY:
            raise ValueError("support must be read-only")
        sys.path.insert(0, str(support))
        from tools import conditional_skill_routing_shared_campaign as shared
        if not callable(shared.prepare_adapter):
            raise ValueError("generic adapter unavailable")
        print(json.dumps({"status": "pass_offline_only", "resume_id": handle,
            "index_sha256": hashlib.sha256(index.read_bytes()).hexdigest(),
            "sealed_hashes_match": True, "public_dependencies_readonly": True,
            "generic_adapter_available": True, "launch_performed": False}))
        return 0
    except Exception:
        print(json.dumps({"status": "fail", "private_diagnostics_suppressed": True}))
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
