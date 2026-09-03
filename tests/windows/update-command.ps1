$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$entrypoint = Join-Path $repoRoot 'cli\windows\shipglows.ps1'
$devServer = Join-Path $repoRoot 'cli\windows\shipglows-devserver.ps1'
$runtimeStatus = Join-Path $repoRoot 'cli\windows\ShipGlows.RuntimeStatus.psm1'
$entrypointText = [IO.File]::ReadAllText($entrypoint)
$devServerText = [IO.File]::ReadAllText($devServer)
$bootstrap = Join-Path $repoRoot 'install-shipglows.ps1'
$installer = Join-Path $repoRoot 'cli\windows\install-devserver.ps1'
$bootstrapText = [IO.File]::ReadAllText($bootstrap)
$installerText = [IO.File]::ReadAllText($installer)

foreach ($path in @($entrypoint, $devServer, $bootstrap, $installer)) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
    Assert-Sg (-not $errors -or $errors.Count -eq 0) "PowerShell syntax must remain valid: $path"
}

Assert-Sg (Test-Path -LiteralPath $runtimeStatus -PathType Leaf) 'The Windows runtime-status module must be packaged with the DevServer.'

Assert-Sg ($entrypointText.Contains("CommandArguments[0] -ieq 'update'")) 'The focused Windows launcher must accept the update namespace.'
Assert-Sg ($entrypointText.Contains('choose an explicit update target:')) 'Bare shipglows update must stop with the explicit update targets.'
foreach ($target in @('runtime','skills','tools','status')) {
    Assert-Sg ($entrypointText.Contains("shipglows update $target")) "The focused Windows launcher must expose the '$target' update target."
}
foreach ($mapping in @(
    "'runtime' { & `$devServer update }",
    "'skills' { & `$devServer skills update }",
    "'tools' { & `$devServer tools update }",
    "'status' { & `$devServer update status }"
)) {
    Assert-Sg ($entrypointText.Contains($mapping)) "The focused Windows launcher is missing update mapping: $mapping"
}
Assert-Sg ((Get-Content -LiteralPath (Join-Path $repoRoot 'cli\windows\ShipGlows.CliLauncher.cs') -Raw).Contains("Run 'shipglows update runtime' in PowerShell instead")) 'Native launchers must refuse self-update and point to the non-locking runtime target.'
Assert-Sg ($entrypointText.Contains("'shipglows-devserver.ps1'")) 'shipglows update runtime must delegate to the active DevServer implementation.'
Assert-Sg ($devServerText.Contains("'skills update' = 'skills-update'")) 'DevServer must expose a skills-only update route.'
Assert-Sg ($devServerText.Contains('function Invoke-SgSkillsUpdate')) 'DevServer must implement skills-only updates separately from runtime bootstrap.'
Assert-Sg ($devServerText.Contains('& $git -C $source.Root pull --ff-only')) 'Skills-only updates must use a non-rewriting fast-forward pull.'
Assert-Sg ($devServerText.Contains('without running the installer')) 'Skills-only updates must state their narrow non-installer boundary.'
Assert-Sg ($devServerText.Contains("if (`$source.Channel -ne 'linked')")) 'Skills-only updates must fail closed outside the linked channel.'
Assert-Sg ($devServerText.Contains("'i  Update skills'")) 'The PowerShell fallback menu must expose skills-only update separately.'
Assert-Sg ($devServerText.Contains('function Get-SgUpdateSource')) 'DevServer update must resolve the active channel before mutation.'
Assert-Sg ($devServerText.Contains("Channel='linked'")) 'Linked developer channels must be represented explicitly.'
Assert-Sg ($devServerText.Contains('rev-parse --is-inside-work-tree')) 'Linked updates must accept valid Git worktrees as developer checkouts.'
Assert-Sg ($devServerText.Contains("@('-InstallMode','full','-InstallSurface','maintainer','-Branch',`$source.Branch)")) 'Linked updates must preserve the maintainer surface so live Codex skills are reconciled.'
Assert-Sg ($devServerText.Contains('uncommitted changes, so the update stopped to preserve them')) 'Linked updates must explain that dirty checkout refusal preserves local changes.'
Assert-Sg ($devServerText.Contains('status --short')) 'Dirty linked-update errors must provide a focused inspection command.'
Assert-Sg ($devServerText.Contains("then retry 'shipglows update runtime'")) 'Dirty linked-update errors must provide the explicit non-locking retry path.'
Assert-Sg ($devServerText.Contains("if (`$choice -eq 'u') { return }")) 'The interactive update action must leave the menu after success or failure instead of redrawing the project catalog.'
Assert-Sg ($devServerText.Contains("'update status' = 'update-status'")) 'DevServer must expose a read-only update-status route.'
Assert-Sg ($devServerText.Contains("if (`$Action -notin @('skills-update','update','update-status'))")) 'Update recovery routes must bypass capability-snapshot refresh in an older installed runtime.'
Assert-Sg (($devServerText.IndexOf("try { `$Action = Resolve-SgAction") -lt $devServerText.IndexOf('Write-SgCliCapabilitySnapshot $config')) -and ($devServerText.IndexOf("if (`$Action -notin @('update','update-status'))") -lt $devServerText.IndexOf('Write-SgCliCapabilitySnapshot $config'))) 'DevServer must resolve the action before capability refresh so update recovery can run.'
Assert-Sg ($devServerText.Contains("'u  Update ShipGlows'")) 'DevServer menu must retain its visible ShipGlows update entry.'
Assert-Sg ($devServerText.Contains('Start-SgBackgroundUpdateStatusRefresh')) 'DevServer must refresh ShipGlows status outside the first paint.'
Assert-Sg ($devServerText.Contains('Show-SgShipGlowsStatus')) 'DevServer dashboard must render ShipGlows version status.'

Assert-Sg ($entrypointText.Contains("CommandArguments[0] -ieq 'tools'")) 'The focused Windows launcher must accept the developer-tools namespace.'
Assert-Sg ($entrypointText.Contains('shipglows tools status')) 'The focused Windows launcher must retain read-only developer-tools status.'
Assert-Sg ($devServerText.Contains("'tools status' = 'tools-status'")) 'DevServer must expose a read-only developer-tools status route.'
Assert-Sg ($devServerText.Contains("'tools update' = 'tools-update'")) 'DevServer must expose a confirmed developer-tools update route.'
Assert-Sg ($devServerText.Contains('function Show-SgDeveloperToolsStatus')) 'Developer-tool status must have a dedicated read-only implementation.'
Assert-Sg ($devServerText.Contains("@('list','--id',`$definition.PackageId,'--exact','--source','winget','--upgrade-available'")) 'Developer-tool status must inspect only exact allowlisted WinGet package IDs.'
Assert-Sg ($devServerText.Contains('function Invoke-SgDeveloperToolsUpdate')) 'Developer-tool mutation must have a dedicated implementation.'
Assert-Sg ($devServerText.Contains('Update ShipGlows')) 'ShipGlows self-update must remain visibly distinct.'
Assert-Sg ($devServerText.Contains('Update developer tools')) 'The interactive menu must expose the separate global developer-tool action.'
Assert-Sg ($devServerText.Contains('Update global developer tools now? [y/N]')) 'Developer-tool mutation must require explicit confirmation.'
Assert-Sg ($devServerText.Contains("'cli\windows\install-devserver.ps1'")) 'Developer-tool update must reuse the installed full convergence engine.'
Assert-Sg (-not $devServerText.Contains("Invoke-SgUpdate -DeveloperTools")) 'Developer-tool update must not piggyback on ShipGlows self-update.'

Assert-Sg ($bootstrapText.Contains('[switch]$UpdateDeveloperTools')) 'The bootstrap must accept explicit developer-tool update intent.'
Assert-Sg ($bootstrapText.Contains("`$actionGeneratedRelativePaths = @('bin/shipglows-dev.exe','bin/sg.exe','bin/s.exe')")) 'The bootstrap must classify native launchers as action-generated managed files.'
Assert-Sg ($bootstrapText.Contains('-ActionGeneratedRelativePaths $actionGeneratedRelativePaths')) 'Runtime classification and activation must receive the action-generated launcher contract.'
Assert-Sg ($bootstrapText.Contains('Action-generated runtime file is missing:')) 'The runtime transaction must verify action-generated outputs before committing its manifest.'
Assert-Sg ($bootstrapText.Contains("if (`$UpdateDeveloperTools) { `$devServerArguments += '-UpdateDeveloperTools' }")) 'The bootstrap must forward developer-tool intent to the full installer.'
Assert-Sg ($bootstrapText.Contains("UpdateDeveloperTools requires InstallMode full")) 'Developer-tool update intent must be rejected outside full mode.'
Assert-Sg ($bootstrapText.Contains('UpdateDeveloperTools cannot be combined with DownloadOnly')) 'Developer-tool update intent must reject a misleading download-only no-op.'
Assert-Sg ($installerText.Contains('[switch]$UpdateDeveloperTools')) 'The full installer must receive developer-tool update intent.'
Assert-Sg ($installerText.Contains('function Invoke-SgManagedDeveloperToolUpdates')) 'The full installer must own the allowlisted update preparation.'
foreach ($packageId in @('Git.Git','GitHub.cli','OpenJS.NodeJS.LTS','jdx.mise','Google.CloudSDK','Doppler.Doppler','astral-sh.uv')) {
    Assert-Sg ($installerText.Contains("PackageId='$packageId'")) "Developer-tool allowlist must contain exact WinGet package ID $packageId."
}
Assert-Sg ($installerText.Contains("@('upgrade','--id',`$Definition.PackageId,'--exact','--source','winget'")) 'WinGet updates must use exact allowlisted IDs as discrete arguments.'
Assert-Sg (-not $installerText.Contains("'upgrade','--all'")) 'ShipGlows must never run a broad WinGet upgrade-all operation.'
Assert-Sg ($installerText.Contains("Resolve-SgNpmVersion `$NpmPath 'npm@latest'")) 'npm update must resolve an exact registry version before mutation.'
Assert-Sg ($installerText.Contains("Resolve-SgNpmVersion `$NpmPath 'pnpm@latest'")) 'pnpm update must resolve an exact registry version before mutation.'
Assert-Sg ($installerText.Contains('@($result.Output | ConvertFrom-Json)')) 'Exact npm-registry version resolution must accept npm 12 singleton-array JSON output.'
Assert-Sg ($installerText.Contains("`$resolved.Count -eq 1")) 'Exact npm-registry version resolution must reject ambiguous multi-version output.'
Assert-Sg ($installerText.Contains("`$pnpmUpdated = (Get-SgInstalledCommandVersion 'pnpm.cmd' `$PnpmPaths) -eq `$pnpmVersion")) 'Corepack success must be confirmed through the pnpm shim ShipGlows actually exposes before skipping the exact npm fallback.'
Assert-Sg ($installerText.Contains("PostInstall='install.cjs'")) 'Claude updates must recover the package-declared native postinstall when npm leaves its executable stub active.'
Assert-Sg ($installerText.Contains("PostInstall='postinstall.mjs'")) 'OpenCode updates must recover the package-declared native postinstall when npm leaves its executable stub active.'
Assert-Sg ($installerText.Contains('failed final executable verification')) 'Confirmed agent updates must stop rather than report success when the final executable is unusable.'
Assert-Sg ($installerText.Contains("Resolve-SgNpmVersion `$NpmPath '@playwright/mcp'")) 'Playwright MCP resolution must share npm 12 singleton-array handling.'
Assert-Sg ($installerText.Contains('developer-tool updates do not run SDK, licence, emulator, or IDE convergence')) 'Developer-tool updates must preserve recorded mobile state instead of mutating SDKs, licences, emulators, or IDEs.'
Assert-Sg ($installerText.Contains("`$tauriState = [pscustomobject]@{ IsTauri=`$false; Status='preserved'")) 'Developer-tool updates must initialize a non-mutating Tauri handoff state under strict mode.'
Assert-Sg ($installerText.Contains('Developer tool updates completed; normal ShipGlows convergence will now verify managed wrappers and CLIs.')) 'The installer must separate package preparation from normal final convergence.'
Assert-Sg ($installerText.Contains('-UpdateApproved:$UpdateDeveloperTools')) 'The single developer-tool confirmation must cover only already-installed outdated coding agents.'
Assert-Sg ($installerText.Contains('Install=@($initial.Outdated)')) 'Developer-tool updates must not silently install missing coding agents.'
Assert-Sg (-not $installerText.Contains("npm update -g")) 'The managed updater must not update arbitrary global npm packages.'
Assert-Sg (-not $installerText.Contains("pnpm update -g")) 'The managed updater must not update arbitrary global pnpm packages.'

Write-Output 'Windows ShipGlows update-command tests passed.'
