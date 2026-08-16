Set-StrictMode -Version Latest

if (-not ('ShipGlowsNativeFile' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ShipGlowsNativeFile {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool MoveFileEx(string existingFileName, string newFileName, int flags);
}
'@
}

function ConvertTo-SgTomlString([string]$Value) {
    return '"' + $Value.Replace('\', '\\').Replace('"', '\"') + '"'
}

function Remove-SgPlaywrightMcpBlocks([string]$Content) {
    $lines = @($Content -split '\r?\n')
    $kept = New-Object 'System.Collections.Generic.List[string]'
    $skipManaged = $false
    $skipTable = $false
    foreach ($line in $lines) {
        if ($line -match '^# >>> shipglows codex playwright mcp >>>\s*$') { $skipManaged = $true; $skipTable = $false; continue }
        if ($skipManaged) {
            if ($line -match '^# <<< shipglows codex playwright mcp <<<\s*$') { $skipManaged = $false }
            continue
        }
        if ($line -match '^\s*\[mcp_servers\.playwright(?:\.[^]]+)?\]\s*$') { $skipTable = $true; continue }
        if ($skipTable -and $line -match '^\s*\[') { $skipTable = $false }
        if (-not $skipTable) { [void]$kept.Add($line) }
    }
    return ($kept -join "`n").Trim([char[]]"`r`n")
}

function Get-SgPlaywrightMcpBlock([string]$NpxPath, [string]$PlaywrightVersion) {
    $command = ConvertTo-SgTomlString ([IO.Path]::GetFullPath($NpxPath))
    return @(
        '# >>> shipglows codex playwright mcp >>>',
        '[mcp_servers.playwright]',
        "command = $command",
        "args = [`"-y`", `"--registry=https://registry.npmjs.org/`", `"@playwright/mcp@$PlaywrightVersion`", `"--headless`", `"--browser`", `"chromium`"]",
        'enabled = true',
        '# <<< shipglows codex playwright mcp <<<'
    ) -join "`n"
}

function Set-SgCodexPlaywrightMcpConfig([string]$ConfigPath, [string]$NpxPath, [string]$PlaywrightVersion, [string]$ChromiumPath) {
    if (-not (Test-Path -LiteralPath $NpxPath -PathType Leaf)) { throw "Native npx.cmd was not found: $NpxPath" }
    if ([IO.Path]::GetExtension($NpxPath) -ine '.cmd') { throw 'Windows Playwright MCP requires a resolved npx.cmd executable.' }
    if ($PlaywrightVersion -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw 'Windows Playwright MCP requires an exact resolved package version.' }
    if (-not (Test-Path -LiteralPath $ChromiumPath -PathType Leaf)) { throw "Playwright Chromium was not proven: $ChromiumPath" }
    $directory = Split-Path -Parent $ConfigPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $existing = if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) { [IO.File]::ReadAllText($ConfigPath) } else { '' }
    $remainder = Remove-SgPlaywrightMcpBlocks $existing
    $block = Get-SgPlaywrightMcpBlock $NpxPath $PlaywrightVersion
    $next = if ($remainder) { "$remainder`n`n$block`n" } else { "$block`n" }
    if ($next.Replace("`r`n", "`n") -ceq $existing.Replace("`r`n", "`n")) { return $false }
    $temp = "$ConfigPath.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp, $next, [Text.UTF8Encoding]::new($false))
        if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
            if (-not [ShipGlowsNativeFile]::MoveFileEx($temp,$ConfigPath,9)) { throw "Atomic Codex config replacement failed with Win32 error $([Runtime.InteropServices.Marshal]::GetLastWin32Error())." }
        }
        else { Move-Item -LiteralPath $temp -Destination $ConfigPath }
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
    return $true
}

function Get-SgCodexPlaywrightMcpConfig([string]$ConfigPath) {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { return $null }
    $content = [IO.File]::ReadAllText($ConfigPath)
    $match = [regex]::Match($content, '(?ms)^\[mcp_servers\.playwright\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
    if (-not $match.Success) { return $null }
    $body = $match.Groups['body'].Value
    $commandMatch = [regex]::Match($body, '(?m)^command\s*=\s*"(?<value>(?:\\.|[^"])*)"\s*$')
    $argsMatch = [regex]::Match($body, '(?m)^args\s*=\s*\[(?<value>[^]]*)\]\s*$')
    $enabledMatch = [regex]::Match($body, '(?m)^enabled\s*=\s*(?<value>true|false)\s*$')
    if (-not $commandMatch.Success -or -not $argsMatch.Success -or -not $enabledMatch.Success) { return $null }
    $decode = { param([string]$value) $value.Replace('\\', '\').Replace('\"', '"') }
    $args = @([regex]::Matches($argsMatch.Groups['value'].Value, '"(?<value>(?:\\.|[^"])*)"') | ForEach-Object { & $decode $_.Groups['value'].Value })
    return [pscustomobject]@{
        Command = & $decode $commandMatch.Groups['value'].Value
        Arguments = $args
        Enabled = $enabledMatch.Groups['value'].Value -eq 'true'
    }
}

function Get-SgPlaywrightChromiumExecutable([string]$Revision = '') {
    $cache = Join-Path $env:LOCALAPPDATA 'ms-playwright'
    if (-not (Test-Path -LiteralPath $cache -PathType Container)) { return $null }
    $searchRoots = if ($Revision) { @((Join-Path $cache "chromium_headless_shell-$Revision"),(Join-Path $cache "chromium-$Revision")) } else { @($cache) }
    $candidates = @(
        foreach ($searchRoot in $searchRoots) {
            if (Test-Path -LiteralPath $searchRoot -PathType Container) {
                Get-ChildItem -LiteralPath $searchRoot -Recurse -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -in @('chrome-headless-shell.exe', 'headless_shell.exe', 'chrome.exe') -and $_.FullName -match 'chromium' }
            }
        }
    )
    return $candidates | Select-Object -First 1
}

function Get-SgCodexPlaywrightPrerequisiteStatus([string]$CodexPath, [string]$NodePath, [string]$NpxPath) {
    if ([string]::IsNullOrWhiteSpace($CodexPath) -or -not (Test-Path -LiteralPath $CodexPath -PathType Leaf)) { return [pscustomobject]@{ Ready=$false; Message='Playwright MCP skipped because Codex CLI is unavailable.' } }
    if ([string]::IsNullOrWhiteSpace($NodePath) -or -not (Test-Path -LiteralPath $NodePath -PathType Leaf)) { return [pscustomobject]@{ Ready=$false; Message='Playwright MCP skipped because Node.js is unavailable.' } }
    if ([string]::IsNullOrWhiteSpace($NpxPath) -or -not (Test-Path -LiteralPath $NpxPath -PathType Leaf)) { return [pscustomobject]@{ Ready=$false; Message='Playwright MCP skipped because native npx.cmd is unavailable.' } }
    if ([IO.Path]::GetExtension($NpxPath) -ine '.cmd') { return [pscustomobject]@{ Ready=$false; Message="Playwright MCP rejected non-native npx launcher: $NpxPath" } }
    return [pscustomobject]@{ Ready=$true; Message=''; CodexPath=[IO.Path]::GetFullPath($CodexPath); NodePath=[IO.Path]::GetFullPath($NodePath); NpxPath=[IO.Path]::GetFullPath($NpxPath) }
}

Export-ModuleMember -Function Set-SgCodexPlaywrightMcpConfig,Get-SgCodexPlaywrightMcpConfig,Get-SgPlaywrightChromiumExecutable,Get-SgCodexPlaywrightPrerequisiteStatus
