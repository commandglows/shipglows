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
! rg -n '"[^"\n]*\$[A-Za-z_][A-Za-z0-9_]*:' "$MODULE" "$ENTRYPOINT" "$INSTALLER"
! rg -n 'New-Item[^\n]*-LiteralPath' "$MODULE" "$ENTRYPOINT" "$INSTALLER"
rg -n 'Import-Module .*DisableNameChecking' "$ENTRYPOINT"
rg -n 'Export-ModuleMember -Function .*Write-SgInfo,Write-SgWarn,Write-SgError' "$MODULE"
rg -n "gumVersion = '0\.17\.0'|gumSha256 = 'B2BE80531C6BABC8D4E0E6CA95773D58118A2E1582AE006AACE08DBC55503072'" "$INSTALLER"
rg -n 'Get-FileHash .*SHA256|github\.com/charmbracelet/gum/releases/download' "$INSTALLER"
rg -n 'gum_\$\{gumVersion\}_Windows_x86_64/gum\.exe' "$INSTALLER"
rg -n 'Get-SgGumCommand|gum choose|Read-SgChoice' "$ENTRYPOINT"
rg -n "Install-SgWingetPackage 'git\.exe' 'Git\.Git'|Install-SgWingetPackage 'gh\.exe' 'GitHub\.cli'" "$INSTALLER"
rg -n 'keep this window open|WinGet can take several minutes|\| Out-Host' "$INSTALLER"
rg -n 'Install-SgCommandWrappers|Add-SgRuntimeToUserPath|shipglows-dev\.cmd|s\.cmd|Short command installed: s' "$INSTALLER"
rg -n 'ExecutionPolicy Bypass -File "%~dp0shipglows-devserver\.ps1" %\*' "$INSTALLER"
rg -n 'gh auth login --hostname github\.com --git-protocol https --web|gh repo list --limit 200|gh repo clone' "$ENTRYPOINT"
! rg -n 'gh auth token|GH_TOKEN|GITHUB_TOKEN' "$ENTRYPOINT" "$INSTALLER"
rg -n "ValidateSet\\('local','full'\\)" "$BOOTSTRAP"
for windows_file in 'ShipGlows\.DevServer\.psm1' 'shipglows-devserver\.ps1' 'install-devserver\.ps1'; do
  rg -n "$windows_file" "$BOOTSTRAP"
done
rg -n '\$windowsCandidates = @\(' "$BOOTSTRAP"
! rg -n '\$windowsCandidates = @\([^)]*\) \| Where-Object' "$BOOTSTRAP"
rg -n "127\\.0\\.0\\.1|registry\\.json|registry\\.lock|commandSignature|startTimeUtc" "$MODULE"
rg -n "Test-SgGitUrl|embedded credentials|Only HTTPS and SSH" "$MODULE" "$ENTRYPOINT"

echo "Windows DevServer static contract: OK"
