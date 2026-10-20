[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CommandArguments
)

$ErrorActionPreference = 'Stop'
$maximumTitleCharacters = 120

function Stop-SgCommand([string]$Message) {
    [Console]::Error.WriteLine("shipglows: $Message")
    exit 2
}

function Invoke-SgManagedDevServer([string[]]$Arguments) {
    # PowerShell resolves shipglows.ps1 before shipglows.cmd on PATH.
    # Use the same secure bootstrap when that script runs in a foreign host.
    $expectedHost = [IO.Path]::GetFullPath((Join-Path $env:USERPROFILE '.shipglows\toolchains\powershell\7.6.5\win-x64\pwsh.exe'))
    $currentHost = [IO.Path]::GetFullPath((Get-Process -Id $PID).Path)
    if ($currentHost -ine $expectedHost -or $env:SHIPGLOWS_MANAGED_PWSH -ine $expectedHost) {
        $bootstrap = Join-Path $PSScriptRoot 'ShipGlows.PowerShellBootstrap.ps1'
        if (-not (Test-Path -LiteralPath $bootstrap -PathType Leaf)) {
            Stop-SgCommand 'The managed PowerShell bootstrap is missing; rerun the official ShipGlows installer.'
        }
        & $bootstrap @Arguments
    } else {
        & (Join-Path $PSScriptRoot 'shipglows-devserver.ps1') @Arguments
    }
    exit $LASTEXITCODE
}

function Invoke-SgLinkedSkills([ValidateSet('check','repair')][string]$Mode) {
    # Skills follow the selected developer source; never invoke the runtime updater.
    $statePath = Join-Path $env:USERPROFILE '.shipglows\development-channel.json'
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        Stop-SgCommand 'No linked developer channel. Manage the public plugin through its plugin manager; runtime update was not started.'
    }
    try { $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json }
    catch { Stop-SgCommand 'Invalid developer-channel state; no skills were changed.' }
    if ($state.schemaVersion -ne 1 -or $state.channel -cne 'linked' -or
        [string]::IsNullOrWhiteSpace([string]$state.root) -or
        [string]$state.root -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+)') {
        Stop-SgCommand 'An explicit linked developer root is required; no channel was changed.'
    }
    $root = [IO.Path]::GetFullPath([string]$state.root)
    $helper = Join-Path $root 'tools\shipglows_sync_skills.ps1'
    $catalog = 'public'
    if ($state.PSObject.Properties['catalog']) { $catalog = [string]$state.catalog }
    if ($catalog -cnotin @('public','expert')) { Stop-SgCommand 'Invalid linked skills catalog; no skills were changed.' }
    if (-not (Test-Path -LiteralPath (Join-Path $root 'skills\000-shipglows\SKILL.md') -PathType Leaf) -or
        -not (Test-Path -LiteralPath $helper -PathType Leaf)) {
        Stop-SgCommand 'The linked checkout is incomplete; no runtime fallback or update was attempted.'
    }
    Write-Output "ShipGlows skills: channel=linked source=$root catalog=$catalog"
    $shellPath = (Get-Process -Id $PID).Path
    & $shellPath -NoLogo -NoProfile -File $helper -Mode $Mode -All -Runtime all -Catalog $catalog -CodexEntrypoint linked -TargetHome $env:USERPROFILE -ShipGlowsRoot $root
    $result = $LASTEXITCODE
    if ($result -eq 0) {
        Write-Output 'Skills use the live checkout, including uncommitted edits. Existing agent context is not reloaded; start a new session or explicitly reread the changed skill.'
    }
    exit $result
}

function Invoke-SgCheck {
    # Runs the lint and test commands declared by every manifest in the current directory.
    # Placeholder scripts (echo, exit 0, true, :) count as not configured, never as passing.
    # Bun is refused, as in the required gate: its setup is not inferred.
    $projectRoot = (Get-Location).ProviderPath
    $steps = [System.Collections.Generic.List[object]]::new()
    $placeholder = '^\s*(echo\b|exit\s+0\s*$|true\s*$|:\s*$)'
    $manifest = Join-Path $projectRoot 'package.json'
    $pubspec = Join-Path $projectRoot 'pubspec.yaml'
    $hasManifest = $false
    if (Test-Path -LiteralPath $manifest -PathType Leaf) {
        $hasManifest = $true
        try { $scripts = (Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json).scripts }
        catch { Stop-SgCommand 'package.json is not valid JSON; nothing was run.' }
        if ((Test-Path -LiteralPath (Join-Path $projectRoot 'bun.lock') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $projectRoot 'bun.lockb') -PathType Leaf)) {
            Stop-SgCommand 'Bun setup is not inferred; run its lint and test by hand, as the required gate does.'
        }
        $runner = 'npm'
        if (Test-Path -LiteralPath (Join-Path $projectRoot 'pnpm-lock.yaml') -PathType Leaf) { $runner = 'pnpm' }
        elseif (Test-Path -LiteralPath (Join-Path $projectRoot 'yarn.lock') -PathType Leaf) { $runner = 'yarn' }
        foreach ($name in 'lint', 'test') {
            $body = if ($scripts -and $scripts.PSObject.Properties[$name]) { [string]$scripts.$name } else { '' }
            if (-not $body.Trim() -or $body -match $placeholder) {
                $steps.Add([pscustomobject]@{ Name = "node:$name"; Executable = $null; Arguments = @() })
            } else {
                $steps.Add([pscustomobject]@{ Name = "node:$name"; Executable = $runner; Arguments = @('run', $name) })
            }
        }
    }
    if (Test-Path -LiteralPath $pubspec -PathType Leaf) {
        $hasManifest = $true
        $steps.Add([pscustomobject]@{ Name = 'flutter:lint'; Executable = 'flutter'; Arguments = @('analyze') })
        if (Test-Path -LiteralPath (Join-Path $projectRoot 'test') -PathType Container) {
            $steps.Add([pscustomobject]@{ Name = 'flutter:test'; Executable = 'flutter'; Arguments = @('test') })
        } else {
            $steps.Add([pscustomobject]@{ Name = 'flutter:test'; Executable = $null; Arguments = @() })
        }
    }
    if (-not $hasManifest) {
        Stop-SgCommand 'no package.json or pubspec.yaml in this directory; nothing to check.'
    }

    Write-Output "ShipGlows check: $projectRoot"
    $problem = $false
    $stopped = $false
    foreach ($step in $steps) {
        if ($null -eq $step.Executable) {
            Write-Output "$($step.Name): NOT CONFIGURED (no real script declared)"
            $problem = $true
            continue
        }
        if ($stopped) {
            Write-Output "$($step.Name): SKIPPED (earlier failure)"
            continue
        }
        Write-Output "== $($step.Name): $($step.Executable) $($step.Arguments -join ' ')"
        if (-not (Get-Command -Name $step.Executable -CommandType Application, ExternalScript -ErrorAction SilentlyContinue)) {
            Write-Output "$($step.Name): FAIL (command not found: $($step.Executable))"
            $problem = $true
            $stopped = $true
            continue
        }
        & $step.Executable @($step.Arguments)
        if ($LASTEXITCODE -ne 0) {
            Write-Output "$($step.Name): FAIL (exit $LASTEXITCODE)"
            $problem = $true
            $stopped = $true
            continue
        }
        Write-Output "$($step.Name): OK"
    }
    if ($problem) {
        Write-Output 'shipglows check: NOT PASSED. Paste this summary in the PR.'
        exit 1
    }
    Write-Output 'shipglows check: PASSED. Paste this summary in the PR.'
    exit 0
}

if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'skills' -and $CommandArguments[1] -ieq 'status') {
    Invoke-SgLinkedSkills -Mode check
}
if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'update' -and $CommandArguments[1] -ieq 'skills') {
    Invoke-SgLinkedSkills -Mode repair
}

if ($CommandArguments.Count -lt 1) {
    Stop-SgCommand 'expected: shipglows update [status|skills], shipglows skills status, shipglows check, shipglows tools <status|update>, or shipglows rename rio <name>'
}

if ($CommandArguments[0] -ieq 'update') {
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer update command is unavailable; rerun the official ShipGlows installer.'
    }
    [string[]]$remaining = @(if ($CommandArguments.Count -gt 1) { $CommandArguments[1..($CommandArguments.Count - 1)] })
    if ($remaining.Count -eq 1 -and $remaining[0] -ieq 'runtime') { $remaining = @() }
    Invoke-SgManagedDevServer -Arguments (@('update') + $remaining)
    exit $LASTEXITCODE
}

if ($CommandArguments[0] -ieq 'tools') {
    if ($CommandArguments.Count -ne 2 -or $CommandArguments[1] -notin @('status','update')) {
        Stop-SgCommand 'expected: shipglows tools <status|update>'
    }
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer developer-tools command is unavailable; rerun the official ShipGlows installer.'
    }
    Invoke-SgManagedDevServer -Arguments @('tools', $CommandArguments[1])
    exit $LASTEXITCODE
}

if ($CommandArguments.Count -eq 1 -and $CommandArguments[0] -ieq 'check') {
    Invoke-SgCheck
}

if ($CommandArguments[0] -ine 'rename') {
    Stop-SgCommand "unknown command '$($CommandArguments[0])'; expected: shipglows update [status], shipglows check, shipglows tools <status|update>, or shipglows rename rio <name>"
}
if ($CommandArguments.Count -lt 2 -or $CommandArguments[1] -ine 'rio') {
    $target = if ($CommandArguments.Count -ge 2) { $CommandArguments[1] } else { '' }
    Stop-SgCommand "unsupported rename target '$target'; expected: shipglows rename rio <name>"
}

$title = if ($CommandArguments.Count -gt 2) {
    (($CommandArguments[2..($CommandArguments.Count - 1)] -join ' ').Trim())
} else {
    ''
}
if ([string]::IsNullOrWhiteSpace($title)) {
    Stop-SgCommand 'the Rio title must not be empty'
}
if ($title -match '[\p{Cc}]') {
    Stop-SgCommand 'the Rio title must not contain control characters'
}
$characterCount = [Globalization.StringInfo]::ParseCombiningCharacters($title).Count
if ($characterCount -gt $maximumTitleCharacters) {
    Stop-SgCommand "the Rio title must contain at most $maximumTitleCharacters characters"
}

[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
[Console]::Out.Write(([char]27) + ']0;' + $title + ([char]7))
