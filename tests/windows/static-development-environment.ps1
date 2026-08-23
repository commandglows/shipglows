$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseFile($modulePath, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw ($errors | ForEach-Object Message | Out-String) }
Import-Module $modulePath -Force -DisableNameChecking

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-static-environment-' + [guid]::NewGuid().ToString('N'))
try {
    $project = Join-Path $fixture 'project'
    New-Item -ItemType Directory -Path $project -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $project 'package.json') -Value '{"dependencies":{"astro":"latest"}}' -Encoding UTF8
    & git init --quiet $project
    if ($LASTEXITCODE -ne 0) { throw 'Git fixture initialization failed.' }

    $environmentPath = Join-Path $project 'ENVIRONMENT.md'
    Set-Content -LiteralPath $environmentPath -Value "# Existing project notes`n`nPreserve this paragraph." -Encoding UTF8
    $legacyDirectory = Join-Path $project '.shipglows'
    New-Item -ItemType Directory -Path $legacyDirectory -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $legacyDirectory 'server.env') -Value "# ShipGlows CLI managed. Do not edit.`nSHIPGLOWS_SERVER_URL=http://127.0.0.1:3002`nSHIPGLOWS_SERVER_STATUS=running`nSHIPGLOWS_SERVER_MANAGER=shipglows-devserver" -Encoding UTF8
    $excludePath = & git -C $project rev-parse --git-path info/exclude
    if (-not [IO.Path]::IsPathRooted($excludePath)) { $excludePath = Join-Path $project $excludePath }
    Add-Content -LiteralPath $excludePath -Value "# ShipGlows local runtime`n/.shipglows/server.env"

    $writtenPath = Write-SgProjectEnvironment $project 0
    $registered = Get-SgProjectEnvironment $project
    if ($registered.Port -ne 0 -or $registered.Url) { throw 'Pending project environment is invalid.' }
    $content = Get-Content -LiteralPath $writtenPath -Raw
    if ($content -notmatch 'Preserve this paragraph\.' -or $content -notmatch 'pending first ShipGlows start') { throw 'Existing content or pending assignment was not preserved.' }
    if (Test-Path -LiteralPath (Join-Path $legacyDirectory 'server.env')) { throw 'Managed legacy server.env was not removed.' }
    $excludeText = Get-Content -LiteralPath $excludePath -Raw
    if ($excludeText -match '(?m)^/\.shipglows/server\.env\r?$' -or $excludeText -match '(?m)^# ShipGlows local runtime\r?$') { throw 'Managed legacy Git exclude entry was not removed.' }

    [void](Write-SgProjectEnvironment $project 3002)
    $assigned = Get-SgProjectEnvironment $project
    if ($assigned.Url -ne 'http://127.0.0.1:3002' -or $assigned.Manager -ne 'shipglows-devserver') { throw 'Assigned project environment is invalid.' }
    $assignedContent = Get-Content -LiteralPath $writtenPath -Raw
    if ($assignedContent -match 'SHIPGLOWS_SERVER_STATUS|(?m)^- Live server status:') { throw 'Project environment contains live server state.' }

    $firstHash = (Get-FileHash -LiteralPath $writtenPath -Algorithm SHA256).Hash
    [void](Write-SgProjectEnvironment $project 3002)
    if ((Get-FileHash -LiteralPath $writtenPath -Algorithm SHA256).Hash -ne $firstHash) { throw 'Project environment write is not idempotent.' }

    $approvalContract = Get-Content -LiteralPath (Join-Path $root 'skills\references\mutation-plan-approval.md') -Raw
    foreach ($required in @('🧭 PLAN À VALIDER','🧭 VALIDATION RAPIDE','Objectif','Périmètre','Actions','Preuves','one or two sentences','exact action','exact target','main safety guarantee','initial imperative request does not count as approval','material change','MAP-FAST-SWITCH','MAP-FAST-WORKTREE','MAP-FAST-INELIGIBLE','MAP-FAST-REPLACEMENT','MAP-REMOTE-PUSH','`git push` always requires the full plan')) {
        if ($approvalContract -notmatch [regex]::Escape($required)) { throw "Mutation approval contract is missing: $required" }
    }
    foreach ($required in @('exact existing local branch','cannot overwrite, discard, or relocate current changes','exact branch availability','exact path availability','resolved base','current worktree remains untouched','any fast criterion is missing, uncertain, or false','new target, effect, or risk','prior approval is invalid','every `git push` uses the full','force push also retains all stricter','MAP-SMALL-CHANGE','only when every fast-path criterion is established','otherwise it uses the full')) {
        if ($approvalContract -notmatch [regex]::Escape($required)) { throw "Mutation approval scenario semantics are missing: $required" }
    }

    $installerSource = Get-Content -LiteralPath (Join-Path $root 'cli\windows\install-devserver.ps1') -Raw
    $installerTokens = $null
    $installerErrors = $null
    $installerAst = [Management.Automation.Language.Parser]::ParseInput($installerSource, [ref]$installerTokens, [ref]$installerErrors)
    if ($installerErrors.Count -gt 0) { throw ($installerErrors | ForEach-Object Message | Out-String) }
    $codexMcpSource = Get-Content -LiteralPath (Join-Path $root 'cli\windows\ShipGlows.CodexMcp.psm1') -Raw
    $agentInstructionsSource = Get-Content -LiteralPath (Join-Path $root 'cli\windows\ShipGlows.AgentInstructions.psm1') -Raw
    $codexMcpAst = [Management.Automation.Language.Parser]::ParseInput($codexMcpSource, [ref]$null, [ref]$null)
    $agentInstructionsAst = [Management.Automation.Language.Parser]::ParseInput($agentInstructionsSource, [ref]$null, [ref]$null)
    $playwrightFunction = @($codexMcpAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Set-SgCodexPlaywrightMcpConfig' }, $true))
    $instructionsFunction = @($agentInstructionsAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Set-SgAgentEnvironmentInstructions' }, $true))
    if ($playwrightFunction.Count -ne 1 -or $instructionsFunction.Count -ne 1) { throw 'Windows capability helper functions could not be resolved uniquely.' }
    if ($playwrightFunction[0].Extent.Text -match 'AgentEnvironmentInstructions' -or $instructionsFunction[0].Extent.Text -match '\$(configPath|chromium)\b') {
        throw 'Agent instructions and Playwright MCP configuration must remain separate capability helpers.'
    }
    foreach ($required in @('Set-SgCodexPlaywrightMcpConfig $configPath $NpxPath $Playwright.Version $Playwright.ChromiumPath','Install-SgAgentEnvironmentInstructions -UserProfile $env:USERPROFILE','McpConfigured=$playwrightConfigured','McpVerified=$playwrightConfigured -and -not $playwrightPending','ChromiumPath=$playwright.ChromiumPath')) {
        if ($installerSource -notmatch [regex]::Escape($required)) { throw "Windows installer capability aggregation is missing: $required" }
    }
    foreach ($required in @('🧭 VALIDATION RAPIDE','one- or two-sentence','exact action','exact target','main safety guarantee','local-only','readily reversible','cannot overwrite, discard, delete, force, publish, deploy, message, change credentials/permissions, or affect unrelated changes','`git push` always uses the full plan')) {
        if ($agentInstructionsSource -notmatch [regex]::Escape($required)) { throw "Windows installed agent instructions are missing: $required" }
    }
    foreach ($required in @('function Install-SgDefaultPython','python install --default','import ssl, sqlite3','Python: $($PythonInfo.Version)','Python manager: $($PythonInfo.Manager)','Python commands: $($PythonInfo.Commands)','Playwright Chromium installed: $playwrightInstalled','Playwright MCP configured: $playwrightConfigured','Playwright MCP verified: $playwrightVerified','Playwright MCP config: $playwrightConfigPath','Playwright Chromium path: $chromiumPath','Install-SgDefaultPython $uvPaths $pythonPaths','Write-SgGlobalDevelopmentEnvironment $agentInfo $playwrightInfo $playwrightRuntime $pythonInfo')) {
        if ($installerSource -notmatch [regex]::Escape($required)) { throw "Windows runtime capability contract is missing: $required" }
    }
    if ($installerSource -match '(?m)^- Python: Python \d+\.\d+\.\d+\s*$') { throw 'Windows environment report hardcodes a Python version.' }
    if ($installerSource -notmatch "throw 'ShipGlows requires uv to provide a functional default Python runtime\.'") { throw 'Windows installer can continue without its required Python manager.' }

    $runtimeContract = Get-Content -LiteralPath (Join-Path $root 'skills\references\agent-runtime-awareness.md') -Raw
    foreach ($required in @('ENVIRONMENT.md','DevServer registry','4321','Python as available through `uv`','deferred or searchable tool catalog','ALL_TOOLS','mcp__playwright__*','Playwright configuré, outil non exposé dans ce tour','Absence from the first visible tool list')) {
        if ($runtimeContract -notmatch [regex]::Escape($required)) { throw "Runtime awareness contract is missing: $required" }
    }
    foreach ($required in @('Inspect directly exposed tools and any deferred/searchable catalog','before declaring a configured tool unavailable')) {
        if ($agentInstructionsSource -notmatch [regex]::Escape($required)) { throw "Windows installed agent capability discovery is missing: $required" }
    }

    $userOwnedProject = Join-Path $fixture 'user-owned-legacy'
    New-Item -ItemType Directory -Path (Join-Path $userOwnedProject '.shipglows') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $userOwnedProject '.shipglows\server.env') -Value 'USER_DEFINED=true' -Encoding UTF8
    [void](Write-SgProjectEnvironment $userOwnedProject 3003)
    if (-not (Test-Path -LiteralPath (Join-Path $userOwnedProject '.shipglows\server.env'))) { throw 'Unrecognized user-owned legacy file was removed.' }

    $monorepo = Join-Path $fixture 'monorepo-without-environment-manager'
    $nestedApp = Join-Path $monorepo 'apps\site'
    New-Item -ItemType Directory -Path $nestedApp -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $nestedApp 'package.json') -Value '{"dependencies":{"astro":"latest"},"scripts":{"dev":"astro dev"}}' -Encoding UTF8
    $descriptor = Get-SgProjectDescriptor $monorepo
    if ($descriptor.RootPath -ne $monorepo -or $descriptor.LaunchPath -ne $nestedApp -or $descriptor.Kind -ne 'astro') { throw 'Native nested application discovery is invalid.' }

    $windowsModule = Get-Content -LiteralPath $modulePath -Raw
    $windowsLauncher = Get-Content -LiteralPath (Join-Path $root 'cli\windows\shipglows-devserver.ps1') -Raw
    if (($windowsModule + $windowsLauncher) -match '(?i)flox|\.flox|Get-SgFloxVariables|UsesFloxManifest|InsideFloxProject') { throw 'Windows backend still contains Flox-specific behavior.' }

    Write-Host 'Static Windows development environment regression: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
