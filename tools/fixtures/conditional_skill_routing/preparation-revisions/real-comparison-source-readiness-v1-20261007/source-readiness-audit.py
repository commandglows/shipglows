"""Offline source/closure inputs; no held-out content or model access."""
import base64
import hashlib
import json
from pathlib import Path
import re
import sys

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]
sys.path.insert(0, str(ROOT))
from tools.conditional_skill_routing_eval import normalize_text, frozen_sources
from tools.skill_activation_budget import audit_scenarios


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(ok, message):
    if not ok:
        raise ValueError(message)


def save(name, value):
    with (OUT / name).open("xb") as stream:
        stream.write(json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2).encode("utf-8"))


def seal():
    base = ROOT / "tools/fixtures/conditional_skill_routing/shared-host/evaluator-final96"
    receipt_path = base / "final-completion-receipt.json"
    receipt_raw = receipt_path.read_bytes()
    require(sha(receipt_raw) == "35feccbfc4d8cc62f024a2cb125bf1b626f24cb8176573d9b92fd7aa799deead", "final receipt changed")
    references = json.loads(receipt_raw)["hashes"]
    require(len(references) == 105, "unexpected reference count")
    checks = {}
    for relative, expected in references.items():
        path = (base / relative).resolve()
        require(path.is_relative_to(base.resolve()), "unconfined sealed reference")
        # Read bytes only. Never decode reviewers, held-out prompts or expectations.
        raw = path.read_bytes()
        require(sha(raw) == expected, "sealed reference changed: " + relative)
        checks[relative] = {"sha256": expected, "bytes": len(raw)}
    return {"receipt_sha256": sha(receipt_raw), "references": checks, "passed": True}


def main():
    before = seal()
    save("sealed105-before.json", before)
    manifest_path = ROOT / "tools/fixtures/conditional_skill_routing/manifest.json"
    manifest_raw = manifest_path.read_bytes()
    manifest = json.loads(manifest_raw)
    selected = set(manifest["subject_resources"]["baseline"]["source_ids"])
    selected.update(manifest["subject_resources"]["candidate"]["source_ids"])
    directory = OUT / "current-source-snapshots"
    directory.mkdir(exist_ok=False)
    inventory = []
    source_by_id = {}
    for entry in manifest["sources"]:
        resource_id = entry["id"]
        require(re.fullmatch(r"[a-z0-9-]+", resource_id), "unsafe source id")
        path = (ROOT / entry["path"]).resolve()
        require(path.is_relative_to(ROOT.resolve()), "unconfined source")
        frozen = base64.b64decode(entry["bytes_base64"], validate=True)
        require(sha(frozen) == entry["source_sha256"], "frozen source hash mismatch")
        require(path.is_file(), "source missing: " + resource_id)
        live = path.read_bytes()
        filename = resource_id + "-" + sha(live) + ".bin"
        with (directory / filename).open("xb") as stream:
            stream.write(live)
        source_by_id[resource_id] = {"old": normalize_text(frozen), "live": normalize_text(live)}
        inventory.append({"id": resource_id, "path": entry["path"], "selected": resource_id in selected,
                          "frozen_sha256": sha(frozen), "live_sha256": sha(live), "bytes": len(live),
                          "normalized_characters": len(normalize_text(live)), "drift": live != frozen,
                          "current_snapshot": "current-source-snapshots/" + filename,
                          "normalized_text_unchanged": normalize_text(live) == normalize_text(frozen)})
    providers = []
    for provider in manifest["providers"]:
        resource_id = provider["resource_id"]
        text = source_by_id[resource_id]["old"]
        live = source_by_id[resource_id]["live"]
        span_checks = []
        for span in provider["spans"]:
            start, end = span["start"], span["end"]
            require(type(start) is int and type(end) is int and 0 <= start < end <= len(text), "invalid provider span")
            require(sha(text[start:end].encode()) == span["sha256"], "frozen provider span mismatch")
            span_checks.append({**span, "characters": end - start,
                                "unchanged_at_current_offsets": live[start:end] == text[start:end]})
        providers.append({"obligation": provider["obligation"], "resource_id": resource_id, "spans": span_checks})
    injections = []
    for injection in manifest["injections"]:
        require(sha(injection["text"].encode()) == injection["sha256"], "injection digest mismatch")
        source_id = injection["source_id"]
        text = source_by_id[source_id]["old"]
        live = source_by_id[source_id]["live"]
        spans = []
        for span in injection["source_spans"]:
            start, end = span["start"], span["end"]
            require(sha(text[start:end].encode()) == span["sha256"], "injection source span mismatch")
            spans.append({**span, "unchanged_at_current_offsets": live[start:end] == text[start:end]})
        injections.append({"id": injection["id"], "source_id": source_id,
                           "obligations": injection["obligations"], "sha256": injection["sha256"],
                           "source_spans": spans,
                           "new_consumer_applicability": "review_required_no_assumed_host_authority"})
    with frozen_sources(manifest) as frozen_root:
        static = audit_scenarios(manifest["baseline_registry"], root=frozen_root)
    require(static.get("status") != "invalid", "historical frozen static accounting invalid")
    result = {"artifact": "prospective-real-comparison-source-readiness", "status": "offline_inputs_prepared_not_activated",
              "manifest_sha256": sha(manifest_raw), "source_count": len(inventory), "selected_count": len(selected),
              "inventory": inventory, "selected_drift": [r["id"] for r in inventory if r["selected"] and r["drift"]],
              "historical_nonselected_drift": [r["id"] for r in inventory if not r["selected"] and r["drift"]],
              "provider_span_reviews": providers, "host_injection_reviews": injections,
              "obligations": manifest["obligations"],
              "historical_closure": {"status": manifest["closure"]["status"], "reviewer": manifest["closure"]["reviewer"],
                                     "authority_for_new_consumer": False},
              "frozen_static_accounting": static,
              "reviewer_gates": [
                  {"id": "current_host_authority", "status": "pending", "reason": "host-agent bytes differ; O2 anchor and host-role/injection precedence require current explicit review"},
                  {"id": "consumer_specific_closure", "status": "pending", "reason": "source byte equivalence preserves historical coverage; new consumer/protocol must independently establish applicability and complete delivered normative spans"},
                  {"id": "fresh_candidate_mappings", "status": "pending", "reason": "preserve historical candidate; review full obligations and frozen substitutions for the new comparison without treating previous grades as approvals"},
                  {"id": "fresh_independent_heldout", "status": "pending", "reason": "new prompts/expectations sealed independently; author does not read or reuse historical held-out content"},
                  {"id": "new_injection_accounting", "status": "pending", "reason": "record exact actual roles/spans and all repeated inputs, context loss invalidates retained coverage; model retention UNKNOWN"},
                  {"id": "provider_model_consumer", "status": "operator_decision_pending", "reason": "no provider/model/profile inferred; no calls or campaign launch authorized"}],
              "limits": ["No semantic approval invented; this is byte/span/static preparation",
                         "No held-out file opened or decoded; sealed reviewer references only hashed",
                         "Living spec/calibration snapshots are dated evidence and need rehash before actual freeze",
                         "No active manifest/candidate/source changed; AC5 and thresholds unchanged"],
              "model_calls": 0, "campaign_launched": False,
              "audit_source_sha256": sha(Path(__file__).read_bytes())}
    save("source-reconciliation-readiness.json", result)
    after = seal()
    require(after == before, "sealed references changed during preparation")
    require(manifest_path.read_bytes() == manifest_raw, "active manifest changed during audit")
    save("sealed105-after.json", after)
    save("completion.json", {"passed": True, "source_count": len(inventory), "selected_count": len(selected),
                              "selected_drift": result["selected_drift"], "sealed_references_unchanged": 105,
                              "readiness_sha256": sha((OUT / "source-reconciliation-readiness.json").read_bytes()),
                              "snapshots_bytes": sum(r["bytes"] for r in inventory)})
    print(json.dumps({"passed": True, "source_count": len(inventory), "selected_drift": result["selected_drift"],
                      "nonselected_drift": result["historical_nonselected_drift"], "sealed_references": 105,
                      "readiness_sha256": sha((OUT / "source-reconciliation-readiness.json").read_bytes())}))


if __name__ == "__main__":
    main()
