"""Explicitly reviewed public baseline observations through ChatGPT subscription.

No held-out, candidate authoring, extra-credit purchase or API-key fallback.
Raw observations go to the isolated evaluator; public receipts contain hashes.
"""
import argparse
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import time

from tools import conditional_skill_routing_cli_case_launch as launch
from tools.conditional_skill_routing_comparison_case_controller import CaseController, prepare_public_tuning_mock
from tools.conditional_skill_routing_real_comparison_preflight import check
from tools.conditional_skill_routing_subscription import load_credential, make_callback, SubscriptionUsageGuard, MODEL, ENDPOINT
from tools.conditional_skill_routing_parent_transport import packed, sha

ROOT = Path(__file__).resolve().parents[1]
TUNING = [family + str(index) for family in "HABS" for index in (1, 2)]
STATE = Path(r"\\wsl.localhost\Ubuntu\home\claude\.local\share\shipglows-isolated-codex-0.160.1\evaluator\subscription-observations")
ENVIRONMENT = "/home/claude/.local/share/shipglows-isolated-codex-0.160.1/environment.py"


def require(ok, reason):
    if not ok:
        raise RuntimeError(reason)


def evaluator_intake(stage, case_id, label):
    """Only the isolated evaluator reads the private copy of observed model text."""
    require(case_id in TUNING and re.fullmatch(r"[A-Za-z0-9-]{1,48}", label), "public baseline identity required")
    def collect(controller, workspace, digest):
        files = {}
        target = STATE / label
        require((target / "reserved.json").is_file(), "observation reservation required before generation")
        def spool(name, raw):
            launch.assert_no_markers(raw, markers)
            destination = target / name
            require(not destination.exists() and not destination.is_symlink(), "fresh observation spool required")
            destination.parent.mkdir(parents=True, exist_ok=True)
            with destination.open("xb") as stream:
                stream.write(raw)
            return {"body_path":name, "bytes":len(raw), "sha256":sha(raw)}
        markers = (controller.provider_callback.credential.encode(), controller.provider_callback.account_id.encode())
        for source in sorted(Path(workspace).rglob("*")):
            require(not source.is_symlink(), "unexpected observation symlink")
            if source.is_file():
                raw = source.read_bytes()
                launch.assert_no_markers(raw, markers)
                name = source.relative_to(workspace).as_posix()
                require(name != "parent-only-provider-exchanges", "reserved observation inventory name")
                files[name] = spool("workspace/" + name, raw)
        exchanges = []
        for index, row in enumerate(controller.provider_callback.raw_exchanges):
            exchanges.append({**row, "request":spool("provider/" + str(index) + "/request.bin", row["request"]),
                "response":spool("provider/" + str(index) + "/response.bin", row["response"])})
        controller_summary = controller.summary()
        controller_ref = spool("controller.json", packed(controller_summary))
        package = {"schema_version":2, "campaign_id":stage["campaign_id"], "case_id":case_id,
            "run_label":label, "variant":"baseline", "observation_manifest_sha256":digest,
            "consumer_profile_sha256":stage["consumer"]["profile_sha256"],
            "case":controller.subject.mcp.broker.bundle, "controller_ref":controller_ref,
            "workspace_files":files, "parent_provider_exchanges":exchanges}
        encoded = packed(package)
        require(len(encoded) <= 128 * 1024 * 1024, "observation intake bound")
        with (target / "observation.json").open("xb") as output:
            output.write(encoded)
        command = "python3 /opt/evaluator/subscription-support/validate_observation.py /opt/evaluator/inputs/subscription-observations/" + label + "/observation.json"
        result = subprocess.run(["wsl.exe", "-d", "Ubuntu", "-u", "claude", "--", "python3",
            ENVIRONMENT, "evaluator-shell", "-c", command], capture_output=True, timeout=90)
        require(result.returncode == 0, "isolated observation intake refused; private diagnostics suppressed")
        value = json.loads(result.stdout)
        require(value.get("inventory_verified") is True and value.get("package_sha256") == sha(encoded),
            "isolated observation intake hash mismatch")
        launch.save(launch.BASE / label / "evaluator-intake-public.json", {
            "case_id":case_id, "run_label":label, "package_sha256":sha(encoded),
            "observation_manifest_sha256":digest, "semantic_review_pending":True,
            "isolated_inventory_verified":True, "provider_model":MODEL, "api_fallback":False})
        return value["receipt"]
    return collect


def live_profile(stage):
    require(check(stage)["ready_to_launch_baseline"] is True, "independently reviewed launch-ready stage required")
    require(stage["provider"]["endpoint"] == ENDPOINT and stage["provider"]["model"] == MODEL,
        "operator-approved subscription model/route required")
    live = stage["live_profile"]
    profile_path = (ROOT / live["path"]).resolve()
    require(profile_path.is_relative_to(ROOT) and sha(profile_path.read_bytes()) == live["sha256"], "exact live profile required")
    profile = json.loads(profile_path.read_bytes())
    require(profile["approved_profile"]["profile_sha256"] == sha(packed({key:value for key,value in
        profile["approved_profile"].items() if key != "profile_sha256"})), "live profile digest mismatch")
    credential = load_credential()
    require(sha(credential.account_id.encode()) == profile["account_binding_sha256"], "reviewed subscription account changed")
    return profile, credential


def run_case(stage, case_id, label, guard, campaign_deadline):
    require(case_id in TUNING and re.fullmatch(r"[A-Za-z0-9-]{1,48}", label), "bounded public case required")
    require(not (launch.BASE / label).exists() and (STATE / label / "reserved.json").is_file(),
        "fresh pre-reserved observation required")
    profile, credential = live_profile(stage)
    callback = make_callback(credential, model=MODEL, settings=profile["required_settings"],
        approved_budget=profile["effective_case_budget"], input_guard=guard)
    callback.deadline = min(callback.deadline, campaign_deadline)
    manifest = json.loads((ROOT / "tools/fixtures/conditional_skill_routing/manifest.json").read_bytes())
    cases = json.loads((ROOT / "tools/fixtures/conditional_skill_routing/cases.json").read_bytes())["cases"]
    case = next(row for row in cases if row["id"] == case_id)
    prepared, _ = prepare_public_tuning_mock(manifest, case)
    controller = CaseController(prepared.subject.prepared, callback, provider_kind="live",
        launch_authorized=True, approved_profile=profile["approved_profile"])
    launch.BASE.mkdir(parents=True, exist_ok=True)
    return launch.execute_prepared_controller(label, case_id, controller, stage,
        explicit_launch_authorized=True, evaluator=evaluator_intake(stage, case_id, label))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", type=Path, required=True)
    parser.add_argument("--baseline-eight", action="store_true", required=True)
    parser.add_argument("--label-prefix", required=True)
    args = parser.parse_args()
    require(re.fullmatch(r"[A-Za-z0-9-]{1,40}", args.label_prefix), "bounded public observation label required")
    stage = json.loads(args.stage.read_bytes())
    live_profile(stage)
    labels = [args.label_prefix + "-" + case for case in TUNING]
    require(all(not (launch.BASE / label).exists() and not (STATE / label).exists() for label in labels),
        "all eight observations must be fresh")
    # A campaign-wide exclusive durable claim prevents parallel batches or a
    # fresh process from resetting the shared observed-usage/request budget.
    state = Path(os.environ["LOCALAPPDATA"]) / "ShipGlows/conditional-skill-routing"
    state.mkdir(parents=True, exist_ok=True)
    ledger = state / (sha(stage["campaign_id"].encode())[:24] + "-baseline-eight.json")
    record = {"schema_version":1, "campaign_id":stage["campaign_id"],
        "consumer_profile_sha256":stage["consumer"]["profile_sha256"],
        "labels":labels, "phase":"reserved", "provider_requests":0,
        "observed_tokens":None, "usage_complete":False, "observations":[]}
    with ledger.open("xb") as stream:
        stream.write(packed(record))
    for label in labels:
        target = STATE / label
        target.mkdir(parents=True, exist_ok=False)
        (target / "reserved.json").write_bytes(packed({"campaign_id":stage["campaign_id"],
            "run_label":label, "consumer_profile_sha256":stage["consumer"]["profile_sha256"]}))
    guard = SubscriptionUsageGuard(max_tokens=stage["budget"]["max_tokens"],
        max_calls=stage["budget"]["max_provider_requests"])
    deadline = time.monotonic() + stage["budget"]["max_seconds"]
    try:
        for case, label in zip(TUNING, labels):
            require(time.monotonic() < deadline and not guard.blocked and not guard.pending,
                "subscription campaign admission stopped; preserve all observations")
            result = run_case(stage, case, label, guard, deadline)
            require((launch.BASE / label / "evaluator-intake-public.json").is_file(),
                "observation intake missing; preserve attempt and stop")
            record["observations"].append({"case_id":case, "run_label":label, "launcher_exit_code":result})
            record.update(phase="collected_pending_independent_review", provider_requests=guard.calls,
                observed_tokens=guard.tokens if guard.usage_complete and not guard.pending else None,
                usage_complete=guard.usage_complete and not guard.pending)
            ledger.write_bytes(packed(record))
        return 0
    finally:
        record.update(provider_requests=guard.calls,
            observed_tokens=guard.tokens if guard.usage_complete and not guard.pending else None,
            usage_complete=guard.usage_complete and not guard.pending,
            stopped=guard.blocked or guard.pending)
        ledger.write_bytes(packed(record))
        print(json.dumps({**record, "api_fallback":False, "semantic_review_pending":True}))


if __name__ == "__main__":
    raise SystemExit(main())
