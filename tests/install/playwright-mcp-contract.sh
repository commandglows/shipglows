#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALLER="$ROOT/cli/install.sh"

bash -n "$INSTALLER"
rg -n 'npx -y --package=@playwright/mcp@latest playwright install chromium' "$INSTALLER"
rg -n 'install_playwright_chromium_for_user|playwright_ready' "$INSTALLER"
rg -n 'default web-QA transport, registered enabled globally' "$INSTALLER"

playwright_body="$(sed -n '/^configure_codex_playwright_mcp()/,/^}/p' "$INSTALLER")"
grep -Fq "printf 'enabled = true\\n'" <<<"$playwright_body"
grep -Fq '/^# >>> shipglows codex playwright mcp >>>$/ { next }' <<<"$playwright_body"
grep -Fq '/^# <<< shipglows codex playwright mcp <<</ { next }' <<<"$playwright_body"

fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT

functions_file="$fixture/functions.sh"
sed -n '/^configure_codex_playwright_mcp()/,/^}/p' "$INSTALLER" > "$functions_file"

mkdir -p "$fixture/home/.codex"
cat > "$fixture/home/.codex/config.toml" <<'TOML'
approval_policy = "never"

# >>> shipglows codex playwright mcp >>>
[mcp_servers.playwright]
command = "old-npx"
enabled = false

[mcp_servers.playwright.tools]
browser_snapshot = {}

[projects."/workspace"]
trust_level = "trusted"

[marketplaces.shipglows]
source = "https://github.com/commandglows/shipglows.git"

[plugins."shipglows@shipglows"]
enabled = true
# <<< shipglows codex playwright mcp <<<
TOML

(
  source "$functions_file"
  playwright_mcp_args_json() {
    printf '%s\n' '["-y","@playwright/mcp@latest","--browser","chromium","--headless","--no-sandbox"]'
  }
  configure_codex_playwright_mcp "$fixture/home"
  configure_codex_playwright_mcp "$fixture/home"
)

python3 - "$fixture/home/.codex/config.toml" <<'PY'
import pathlib
import sys
import tomllib

config_path = pathlib.Path(sys.argv[1])
text = config_path.read_text()
config = tomllib.loads(text)

assert config["mcp_servers"]["playwright"]["enabled"] is True
assert config["mcp_servers"]["playwright"]["command"] == "npx"
assert config["projects"]["/workspace"]["trust_level"] == "trusted"
assert config["marketplaces"]["shipglows"]["source"].endswith("commandglows/shipglows.git")
assert config["plugins"]["shipglows@shipglows"]["enabled"] is True
assert text.count("# >>> shipglows codex playwright mcp >>>") == 1
assert text.count("[mcp_servers.playwright]") == 1
PY

mkdir -p "$fixture/home" "$fixture/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$fixture/bin/google-chrome"
chmod +x "$fixture/bin/google-chrome"

functions_file="$fixture/playwright-args-functions.sh"
sed -n '/^playwright_mcp_executable_path()/,/^}/p' "$INSTALLER" > "$functions_file"
sed -n '/^playwright_mcp_args_json()/,/^}/p' "$INSTALLER" >> "$functions_file"

result="$({
  source "$functions_file"
  uname() { printf 'aarch64\n'; }
  PATH="$fixture/bin:/usr/bin:/bin" playwright_mcp_args_json "$fixture/home"
})"

grep -Fq '"--browser","chromium","--headless","--no-sandbox"' <<<"$result"
if grep -Fq 'google-chrome' <<<"$result"; then
  echo 'Linux ARM64 must not select Google Chrome stable.' >&2
  exit 1
fi

echo 'Playwright MCP Linux/ARM64 contract: OK'
