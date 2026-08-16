#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT
mkdir -p "$FIXTURE/project" "$FIXTURE/state"

output="$(SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env inspect --project "$FIXTURE/project")"
python3 -c 'import json,sys; value=json.load(sys.stdin); assert value["command"] == "inspect"; assert value["desired"]["management"] == "unmanaged"' <<< "$output"
[ -z "$(find "$FIXTURE/state" -mindepth 1 -print -quit)" ]

SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env verify --project "$FIXTURE/project" >/dev/null
status_output="$(SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env status --project "$FIXTURE/project")"
python3 -c 'import json,sys; value=json.load(sys.stdin); assert value["command"] == "status"; assert value["state"]["schema"] == "shipglows.environment-state/v1"' <<< "$status_output"

plan_output="$(SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env plan --project "$FIXTURE/project")"
approved_digest="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["plan"]["digest"])' <<< "$plan_output")"
printf '%s\n' '{"schema":"shipglows.environment/v1","capabilities":{"tools":[{"id":"node","constraint":"24"}]}}' > "$FIXTURE/project/shipglows.environment.json"
set +e
stale_output="$(SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env apply --project "$FIXTURE/project" --plan-digest "$approved_digest")"
stale_status=$?
set -e
[ "$stale_status" -eq 3 ]
python3 -c 'import json,sys; assert json.load(sys.stdin)["code"] == "stale_plan"' <<< "$stale_output"

set +e
SHIPGLOWS_ENVIRONMENT_STATE_ROOT="$FIXTURE/state" bash "$ROOT/cli/shipglows.sh" env apply --project "$FIXTURE/project" >/dev/null 2>&1
status=$?
set -e
[ "$status" -eq 3 ]

echo "ShipGlows Unix environment observation: OK"
