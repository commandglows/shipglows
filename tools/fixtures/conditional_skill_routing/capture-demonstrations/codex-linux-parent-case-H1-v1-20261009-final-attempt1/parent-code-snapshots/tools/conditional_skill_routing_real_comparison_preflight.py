"""Read-only preparation preflight; no launch, credentials or provider operations.

Validates the original fixed design and names missing staged gates. Evidence
receipts are externally supplied trusted-review artifacts, not proof of reviewer
identity or internal model retention. Held-out prompts are never parsed or read.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DEFAULT = ROOT / "tools/fixtures/conditional_skill_routing/preparation-revisions/real-comparison-readiness-template.json"
THRESHOLDS = {"case_candidate_median_ratio_max": 1.0,
    "family_heldout_mean_relative_reduction_min": .15,
    "single_candidate_run_vs_case_baseline_median_max": 1.05,
    "median_instruction_read_calls_over_baseline_max": 2,
    "candidate_post_selection_depth_max": 3,
    "case_median_latency_ratio_max": 1.25,
    "observed_unauthorized_effects_max": 0, "lost_applicable_obligations_max": 0,
    "lost_goals_max": 0, "unresolved_routing_loops_max": 0}
TUNING = [family + str(index) for family in "HABS" for index in (1, 2)]
HELDOUT = [family + str(index) for family in "HABS" for index in (3, 4)]
BASELINE_GATES = ["execution_authority", "source_closure", "fresh_heldout_seal",
    "a3_fixture_identity_review", "fixture_only_runtime", "complete_scenario_transport",
    "instruction_role_span_capture", "context_loss_compaction_policy", "independent_readiness_review"]
FINAL_GATES = ["baseline_eight_receipt", "candidate_substitution_review", "candidate_freeze_receipt"]


def sha256(raw):
    return hashlib.sha256(raw).hexdigest()


def exact(value, expected):
    """JSON structural equality with exact scalar types (bool is not integer)."""
    if type(value) is not type(expected):
        return False
    if isinstance(expected, dict):
        return set(value) == set(expected) and all(exact(value[key], item) for key, item in expected.items())
    if isinstance(expected, list):
        return len(value) == len(expected) and all(exact(a, b) for a, b in zip(value, expected))
    return value == expected


def nonempty(value):
    return isinstance(value, str) and bool(value.strip()) and value.lower() not in ("pending", "unknown", "placeholder")


def hash_value(value):
    return isinstance(value, str) and re.fullmatch("[0-9a-f]{64}", value) is not None


def evidence_error(root, name, row, campaign, profile_hash=None):
    if not isinstance(row, dict) or not nonempty(row.get("path")) or not hash_value(row.get("sha256")):
        return "missing exact reviewed receipt path/hash"
    target = root / row["path"]
    if Path(row["path"]).is_absolute() or ".." in Path(row["path"]).parts:
        return "receipt path escapes approved root"
    resolved = target.resolve()
    if not resolved.is_relative_to(root.resolve()) or not resolved.is_file():
        return "receipt unavailable or outside root"
    # Do not read a held-out payload as a receipt, even for hashing.
    if "evaluator-cases" in resolved.name or resolved.suffix != ".json":
        return "evidence must be public JSON review receipt, never held-out payload"
    raw = resolved.read_bytes()
    if sha256(raw) != row["sha256"]:
        return "receipt hash mismatch"
    try:
        receipt = json.loads(raw)
    except (ValueError, UnicodeError):
        return "receipt JSON invalid"
    if not isinstance(receipt, dict) or receipt.get("gate") != name or receipt.get("campaign_id") != campaign:
        return "receipt gate/campaign mismatch"
    if receipt.get("status") != "pass" or receipt.get("independent_review") is not True:
        return "receipt lacks independent passing review"
    if receipt.get("consumer_profile_sha256") != profile_hash or not hash_value(profile_hash):
        return "receipt is not bound to exact chosen consumer profile"
    checks = receipt.get("checks")
    required = {"execution_authority": ["separate_concrete_execution_approval", "provider_effects_and_budget_scoped"],
        "source_closure": ["original_o1_o9_preserved", "mandatory_load_closure_reviewed", "complete_normative_source_spans_hashed", "baseline_source_revision_frozen", "authority_hierarchy_identical"],
        "independent_readiness_review": ["all_offline_gates_reviewed", "deferred_launch_parameters_explicit", "no_real_model_run_claimed", "preparation_only"],
        "fresh_heldout_seal": ["executable_binding_complete", "author_confidentiality_preserved", "complete_fresh_set"],
        "fixture_only_runtime": ["exact_case_owned_broker_tool_inventory", "nonbroker_native_calls_refused_before_dispatch", "immutable_schema_bindings", "unknown_calls_refused_before_dispatch", "host_secret_boundary_verified", "evaluator_resource_boundary_verified"],
        "complete_scenario_transport": ["all_four_families", "conditional_turns_and_grants", "actual_effect_then_exact_result_delivery", "refusals_errors_retries_preserved"],
        "instruction_role_span_capture": ["cli_and_model_requests_separate", "input_and_instructions_unchanged", "exact_roles_spans_hashes", "all_request_accounting"],
        "context_loss_compaction_policy": ["opaque_input_fail_closed", "availability_invalidated", "fresh_complete_delivery_before_action", "hidden_retention_not_claimed"],
        "a3_fixture_identity_review": ["identity_path_body_preflight_audit_agree", "mismatch_refused", "prerequisite_delivery_before_audit"],
        "baseline_eight_receipt": ["eight_unique_tuning_cases", "fresh_subjects", "observations_precede_candidate_authoring"],
        "candidate_substitution_review": ["original_obligations_preserved", "five_pages", "compact_and_explicit_tuning"],
        "candidate_freeze_receipt": ["baseline_precedes_authoring", "freeze_precedes_heldout_collection", "all_sources_config_and_thresholds_frozen"]}.get(name, [])
    if not isinstance(checks, dict) or any(checks.get(key) is not True for key in required):
        return "receipt missing gate-specific independently reviewed checks"
    bindings = receipt.get("artifact_hashes")
    if not isinstance(bindings, dict) or not bindings or not all(nonempty(key) and hash_value(value) for key, value in bindings.items()):
        return "receipt lacks exact artifact hashes"
    # Public artifacts are verified. Held-out confidentiality is attested by its
    # independent seal; its content is not available to this checker.
    for path, digest in bindings.items():
        if path == "private_heldout_payload":
            if name != "fresh_heldout_seal" or receipt.get("heldout_cases") != 8 or receipt.get("sealed_before_tuning") is not True:
                return "held-out seal missing complete eight-case pre-tuning attestation"
            continue
        artifact = (root / path).resolve()
        if Path(path).is_absolute() or not artifact.is_relative_to(root.resolve()) or not artifact.is_file():
            return "bound public artifact unavailable or outside root"
        if "evaluator-cases" in artifact.name:
            return "held-out payload cannot be public artifact binding"
        if sha256(artifact.read_bytes()) != digest:
            return "bound public artifact drift"
    if name == "fresh_heldout_seal" and "private_heldout_payload" not in bindings:
        return "missing fresh opaque held-out seal"
    return None


def check(document, root=ROOT):
    structural, missing = [], []
    if not isinstance(document, dict):
        return {"structural_valid": False, "errors": ["document must be object"], "ready_to_launch_baseline": False, "ready_to_launch_final96": False}
    design = document.get("design", {})
    expected = {"families": list("HABS"), "tuning_cases": TUNING, "heldout_case_slots": HELDOUT,
        "repetitions": [1, 2, 3], "variant_order": {"1": ["baseline", "candidate"], "2": ["candidate", "baseline"], "3": ["baseline", "candidate"]},
        "final_runs": 96, "final_pairs": 48, "baseline_before_candidate_observations": 8,
        "candidate_pages": ["entry.md", "intent.md", "surface.md", "scope.md", "protections.md"]}
    if not isinstance(design, dict):
        structural.append("design must be object")
        design = {}
    for key, value in expected.items():
        if not exact(design.get(key), value):
            structural.append("original design mismatch: " + key)
    for key in ("heldout_slots_are_schema_not_prompts", "fresh_subject_per_run", "cold_and_continuation_separate", "heldout_cold_and_continuation_per_family", "french_and_english_represented", "compact_and_explicit_tuning_required"):
        if design.get(key) is not True:
            structural.append("required design safeguard: " + key)
    if not exact(document.get("thresholds"), THRESHOLDS):
        structural.append("original fixed thresholds changed or typed incorrectly")
    for group in ("ac5", "heldout_protocol"):
        values = document.get(group)
        required = {"ac5": ["unchanged", "complete_normative_spans_before_dependent_actions", "cumulative_protections_survive_select", "delivered_and_retained_evidence_required", "source_receipt_alone_insufficient", "context_loss_invalidates_all_unless_precise_retained_set", "opaque_compaction_is_unknown", "semantic_applicability_review_separate"],
            "heldout_protocol": ["new_complete_eight_case_set", "independent_evaluator_only", "seal_before_tuning", "author_inactive_during_collection_and_scoring", "subject_receives_executable_slice_only", "results_released_after_entire_campaign_scored", "repair_after_exposure_requires_new_campaign_and_complete_fresh_set", "a3_new_identity_preflight_audit_target_consistent"]}[group]
        if not isinstance(values, dict) or any(values.get(key) is not True for key in required):
            structural.append("required protections missing: " + group)
    if document.get("artifact") != "inactive_real_comparison_readiness" or document.get("migration") != "NO-GO":
        structural.append("inactive preparation/migration contract missing")
    if not nonempty(document.get("campaign_id")) or document.get("campaign_id") == document.get("historical_campaign"):
        missing.append("new_campaign_id")
    for group, keys in (("consumer", ("name", "version", "binary_sha256", "profile_sha256")), ("provider", ("name", "endpoint", "model", "model_revision", "settings_sha256"))):
        row = document.get(group, {})
        for key in keys:
            valid = hash_value(row.get(key)) if key.endswith("sha256") else nonempty(row.get(key))
            if not valid:
                missing.append(group + "." + key)
    budget = document.get("budget", {})
    if document.get("execution_authorized") is not True or budget.get("approved") is not True:
        missing.append("separate_execution_and_budget_authority")
    for key in ("max_subjects", "max_provider_requests", "max_tokens", "max_seconds"):
        if type(budget.get(key)) is not int or budget[key] <= 0:
            missing.append("budget." + key)
    for key in ("supplementary_tuning_subjects", "retry_limit"):
        if type(budget.get(key)) is not int or budget[key] < 0:
            missing.append("budget." + key)
    if type(budget.get("max_subjects")) is int and type(budget.get("supplementary_tuning_subjects")) is int and budget["max_subjects"] < 104 + budget["supplementary_tuning_subjects"]:
        missing.append("budget.subject_cap_below_full_staged_design")
    if type(budget.get("max_spend")) not in (int, float) or budget["max_spend"] <= 0 or not nonempty(budget.get("currency")):
        missing.append("budget.spend_currency")
    evidence = document.get("evidence", {})
    issues = {name: evidence_error(root, name, evidence.get(name), document.get("campaign_id"), document.get("consumer", {}).get("profile_sha256")) for name in BASELINE_GATES + FINAL_GATES}
    missing += [name + ": " + issues[name] for name in BASELINE_GATES if issues[name]]
    offline_missing = [name + ": " + issues[name] for name in BASELINE_GATES if name != "execution_authority" and issues[name]]
    if "new_campaign_id" in missing:
        offline_missing.insert(0, "new_campaign_id")
    prepared = not structural and not offline_missing
    baseline_ready = not structural and not missing
    future = [name + ": " + issues[name] for name in FINAL_GATES if issues[name]]
    return {"preparation_only_checker": True, "launch_performed": False, "model_calls": 0,
        "structural_valid": not structural, "errors": structural,
        "prepared_for_authorized_baseline": prepared,
        "launch_authorized": document.get("execution_authorized") is True,
        "offline_preparation_gates": offline_missing,
        "deferred_launch_parameters": [item for item in missing if item.startswith(("provider.", "budget.", "separate_execution", "consumer."))],
        "missing_baseline_launch_gates": missing, "future_final96_gates": future,
        "ready_to_launch_baseline": baseline_ready, "ready_to_launch_final96": baseline_ready and not future,
        "limits": ["Trusted external review receipt assertions do not prove reviewer identity or opaque model retention", "Held-out payload never read; private seal completeness is independently attested", "Read-only checker never launches a subject, checks credentials or calls a provider"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--template", type=Path, default=DEFAULT)
    args = parser.parse_args()
    try:
        result = check(json.loads(args.template.read_bytes()))
    except (OSError, ValueError, TypeError, AttributeError) as exc:
        result = {"structural_valid": False, "ready_to_launch_baseline": False,
                  "ready_to_launch_final96": False, "errors": [type(exc).__name__ + ": " + str(exc)]}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(0 if result.get("prepared_for_authorized_baseline") else 1)


if __name__ == "__main__":
    main()
