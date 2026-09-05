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

if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'skills' -and $CommandArguments[1] -ieq 'status') {
    Invoke-SgLinkedSkills -Mode check
}
if ($CommandArguments.Count -eq 2 -and $CommandArguments[0] -ieq 'update' -and $CommandArguments[1] -ieq 'skills') {
    Invoke-SgLinkedSkills -Mode repair
}

if ($CommandArguments.Count -lt 1) {
    Stop-SgCommand 'expected: shipglows update [status|skills], shipglows skills status, shipglows tools <status|update>, or shipglows rename rio <name>'
}

if ($CommandArguments[0] -ieq 'update') {
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer update command is unavailable; rerun the official ShipGlows installer.'
    }
    [string[]]$remaining = if ($CommandArguments.Count -gt 1) { @($CommandArguments[1..($CommandArguments.Count - 1)]) } else { @() }
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

if ($CommandArguments[0] -ine 'rename') {
    Stop-SgCommand "unknown command '$($CommandArguments[0])'; expected: shipglows update [status], shipglows tools <status|update>, or shipglows rename rio <name>"
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
