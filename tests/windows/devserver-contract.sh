#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODULE="$ROOT/cli/windows/ShipGlows.DevServer.psm1"
ENTRYPOINT="$ROOT/cli/windows/shipglows-devserver.ps1"
INSTALLER="$ROOT/cli/windows/install-devserver.ps1"
BOOTSTRAP="$ROOT/install-shipglows.ps1"

for file in "$MODULE" "$ENTRYPOINT" "$INSTALLER" "$BOOTSTRAP"; do
  test -f "$file"
done

! rg -n 'Invoke-Expression|GetRelativePath|Read-SgRegistry \\$Config \.projects' "$MODULE" "$ENTRYPOINT" "$INSTALLER"
rg -n "ValidateSet\\('local','full'\\)" "$BOOTSTRAP"
rg -n "cli/windows/(ShipGlows\\.DevServer\\.psm1|shipglows-devserver\\.ps1|install-devserver\\.ps1)" "$BOOTSTRAP"
rg -n '\$windowsCandidates = @\(' "$BOOTSTRAP"
! rg -n '\$windowsCandidates = @\([^)]*\) \| Where-Object' "$BOOTSTRAP"
rg -n "127\\.0\\.0\\.1|registry\\.json|registry\\.lock|commandSignature|startTimeUtc" "$MODULE"
rg -n "Test-SgGitUrl|embedded credentials|Only HTTPS and SSH" "$MODULE" "$ENTRYPOINT"

echo "Windows DevServer static contract: OK"
