#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALLER="$ROOT/cli/install.sh"

bash -n "$INSTALLER"
rg -n 'npx -y --package=@playwright/mcp@latest playwright install chromium' "$INSTALLER"
rg -n 'install_playwright_chromium_for_user|playwright_ready' "$INSTALLER"

playwright_body="$(sed -n '/^configure_codex_playwright_mcp()/,/^}/p' "$INSTALLER")"
grep -Fq "printf 'enabled = true\\n'" <<<"$playwright_body"

fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/home" "$fixture/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$fixture/bin/google-chrome"
chmod +x "$fixture/bin/google-chrome"

functions_file="$fixture/functions.sh"
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
