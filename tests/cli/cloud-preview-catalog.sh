#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWS_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_PROJECTS_DIR="$HOME/projects"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_PREVIEW_DOMAIN="preview.example.test"
mkdir -p "$SHIPGLOWS_PROJECTS_DIR/demo" "$TEST_ROOT/bin"

cat > "$TEST_ROOT/bin/tmux" <<'EOF'
#!/bin/bash
[ "${1:-}" = "has-session" ]
EOF
cat > "$TEST_ROOT/bin/caddy" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$TEST_ROOT/bin/tmux" "$TEST_ROOT/bin/caddy"
export PATH="$TEST_ROOT/bin:$PATH"

source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
pm2_fixture="demo|online|3005|$SHIPGLOWS_PROJECTS_DIR/demo"$'\n'"shipglows-runner|online||$HOME/services/runner"
flutter_fixture=""
pm2_data_load() { _shipglows_assign "$1" "$pm2_fixture"; }
flutter_web_registry_lines() { [ -n "$flutter_fixture" ] && printf '%s\n' "$flutter_fixture"; return 0; }

refresh_cli_project_catalog || fail "initial catalog"
catalog="$SHIPGLOWS_CLI_PROJECT_CATALOG_FILE"
[ -f "$catalog" ] || fail "catalog file"
capabilities="$SHIPGLOWS_CLI_CAPABILITIES_FILE"
[ -f "$capabilities" ] || fail "capability snapshot file"
node - "$catalog" <<'NODE' || exit 1
const fs = require('fs');
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (data.schemaVersion !== 'shipglows.cli-project-catalog.v1') process.exit(1);
if (data.projects.length !== 1) process.exit(1);
const p = data.projects[0];
if (!/^prj_[a-f0-9]{32}$/.test(p.id) || !/^[a-z0-9-]+$/.test(p.previewSlug)) process.exit(1);
if (p.port !== 3005 || p.status !== 'online' || p.source !== 'pm2') process.exit(1);
if (p.tmuxSession !== `sg-${p.id}`) process.exit(1);
NODE

node - "$capabilities" <<'NODE' || exit 1
const fs = require('fs');
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
if (data.schemaVersion !== 'shipglows.cli-capabilities.v1') process.exit(1);
if (!/^\d{4}-\d{2}-\d{2}T/.test(data.generatedAt) || data.capabilities.length !== 31) process.exit(1);
const byId = new Map(data.capabilities.map(item => [item.id, item]));
if (byId.get('project.catalog.read')?.state !== 'available') process.exit(1);
if (byId.get('project.create')?.state !== 'available') process.exit(1);
if (byId.get('project.runtime.restart')?.reasonCode !== 'approvalRequired') process.exit(1);
if (byId.get('credentials.manage')?.reasonCode !== 'operatorOnly') process.exit(1);
if (/command|argument|path|port|secret|credential/i.test(JSON.stringify(data).replace('credentials.manage', ''))) process.exit(1);
NODE

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) ;;
    *)
        capability_mode=$(stat -c '%a' "$capabilities")
        [ "$capability_mode" = "600" ] || fail "capability snapshot permissions"
        ;;
esac

fixture_rows="$TEST_ROOT/capability-fixture.tsv"
fixture_output="$TEST_ROOT/capability-fixture.json"
: > "$fixture_rows"
write_cli_capability_snapshot "$fixture_rows" "$fixture_output" 65536 || fail "zero capability fixture"
node -e 'const data=require(process.argv[1]); if (data.capabilities.length !== 0) process.exit(1)' "$fixture_output"

printf '%s\n' 'system.health.read|available|' > "$fixture_rows"
rm -f "$fixture_output"
write_cli_capability_snapshot "$fixture_rows" "$fixture_output" 65536 || fail "one capability fixture"
node -e 'const data=require(process.argv[1]); if (data.capabilities.length !== 1) process.exit(1)' "$fixture_output"

printf '%s\n' 'system.health.read|available|' 'system.memory.read|degraded|probeUnavailable' > "$fixture_rows"
rm -f "$fixture_output"
write_cli_capability_snapshot "$fixture_rows" "$fixture_output" 65536 || fail "many capability fixture"
node -e 'const data=require(process.argv[1]); if (data.capabilities.length !== 2) process.exit(1)' "$fixture_output"

before_capability_failure=$(sha256sum "$capabilities" | cut -d' ' -f1)
SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES=8
if refresh_cli_capability_snapshot; then fail "invalid capability byte boundary rejected"; fi
after_capability_failure=$(sha256sum "$capabilities" | cut -d' ' -f1)
[ "$before_capability_failure" = "$after_capability_failure" ] || fail "failed capability snapshot preserves previous file"
SHIPGLOWS_CLI_CAPABILITIES_MAX_BYTES=65536

first_identity=$(node -e 'const p=require(process.argv[1]).projects[0]; console.log(`${p.id}|${p.previewSlug}|${p.tmuxSession}`)' "$catalog")
pm2_fixture="renamed|online|3005|$SHIPGLOWS_PROJECTS_DIR/demo"$'\n'"shipglows-runner|online||$HOME/services/runner"
refresh_cli_project_catalog || fail "stable catalog refresh"
second_identity=$(node -e 'const p=require(process.argv[1]).projects[0]; console.log(`${p.id}|${p.previewSlug}|${p.tmuxSession}`)' "$catalog")
[ "$first_identity" = "$second_identity" ] || fail "identity and slug remain stable after display rename"

before_failure=$(sha256sum "$catalog" | cut -d' ' -f1)
flutter_fixture="renamed|3010|$SHIPGLOWS_PROJECTS_DIR/demo|shipglows-flutter-demo"
if refresh_cli_project_catalog; then fail "conflicting live upstream rejected"; fi
after_failure=$(sha256sum "$catalog" | cut -d' ' -f1)
[ "$before_failure" = "$after_failure" ] || fail "failed snapshot preserves previous catalog"

flutter_fixture=""
routes=""
user_caddy_routes_load routes || fail "load exact-host routes"
[[ "$routes" =~ ^[a-z0-9-]+\.preview\.example\.test\|3005$ ]] || fail "route hostname"
write_user_caddyfile "$routes" || fail "validated Caddyfile"
grep -Eq '^\s*@preview_1 host [a-z0-9-]+\.preview\.example\.test$' "$SHIPGLOWS_USER_CADDYFILE" || fail "exact Host matcher"
grep -q 'reverse_proxy 127.0.0.1:3005' "$SHIPGLOWS_USER_CADDYFILE" || fail "loopback upstream"
grep -Eq '^\s*bind 127\.0\.0\.1$' "$SHIPGLOWS_USER_CADDYFILE" || fail "loopback listener bind"
if grep -q 'handle /' "$SHIPGLOWS_USER_CADDYFILE"; then fail "no path-prefix routing"; fi
if grep -Fq "$SHIPGLOWS_PROJECTS_DIR" "$SHIPGLOWS_USER_CADDYFILE"; then fail "no private path in proxy config"; fi

mkdir -p "$SHIPGLOWS_PROJECTS_DIR/registered"
cat > "$SHIPGLOWS_STATE_DIR/cli-project-registry.v1.json" <<EOF
{"schemaVersion":"shipglows.cli-project-registry.v1","projects":[{"id":"prj_11111111111111111111111111111111","displayName":"Registered","ownerAccountId":"usr_account_1234","repositoryId":"12345","repositoryFullName":"owner/registered","cwd":"$SHIPGLOWS_PROJECTS_DIR/registered","createdAt":"2026-09-01T00:00:00Z"}]}
EOF
refresh_cli_project_catalog || fail "registered project catalog"
node -e 'const p=require(process.argv[1]).projects.find(item => item.id === "prj_11111111111111111111111111111111"); if (!p || p.tmuxSession !== null || p.status !== "stopped" || p.port !== null) process.exit(1)' "$catalog" || fail "registered project has no fictitious runtime"

printf 'cloud preview catalog tests: ok\n'
