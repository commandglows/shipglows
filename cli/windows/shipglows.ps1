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

if ($CommandArguments.Count -lt 1) {
    Stop-SgCommand 'expected: shipglows update <runtime|skills|tools|status>, shipglows tools status, or shipglows rename rio <name>'
}

if ($CommandArguments[0] -ieq 'update') {
    if ($CommandArguments.Count -eq 1) {
        Stop-SgCommand "choose an explicit update target:`n  shipglows update runtime`n  shipglows update skills`n  shipglows update tools`n  shipglows update status"
    }
    if ($CommandArguments.Count -ne 2 -or $CommandArguments[1] -notin @('runtime','skills','tools','status')) {
        Stop-SgCommand 'expected: shipglows update <runtime|skills|tools|status>'
    }
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer update command is unavailable; rerun the official ShipGlows installer.'
    }
    switch ($CommandArguments[1].ToLowerInvariant()) {
        'runtime' { & $devServer update }
        'skills' { & $devServer skills update }
        'tools' { & $devServer tools update }
        'status' { & $devServer update status }
    }
    exit $LASTEXITCODE
}

if ($CommandArguments[0] -ieq 'tools') {
    if ($CommandArguments.Count -ne 2 -or $CommandArguments[1] -ine 'status') {
        Stop-SgCommand 'expected: shipglows tools status; use shipglows update tools to update them'
    }
    $devServer = Join-Path $PSScriptRoot 'shipglows-devserver.ps1'
    if (-not (Test-Path -LiteralPath $devServer -PathType Leaf)) {
        Stop-SgCommand 'the managed DevServer developer-tools command is unavailable; rerun the official ShipGlows installer.'
    }
    & $devServer tools $CommandArguments[1]
    exit $LASTEXITCODE
}

if ($CommandArguments[0] -ine 'rename') {
    Stop-SgCommand "unknown command '$($CommandArguments[0])'; expected: shipglows update <runtime|skills|tools|status>, shipglows tools status, or shipglows rename rio <name>"
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
