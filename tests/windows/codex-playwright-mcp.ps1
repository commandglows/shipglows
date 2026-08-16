$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.CodexMcp.psm1'
$parseTokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($modulePath, [ref]$parseTokens, [ref]$parseErrors)
if ($parseErrors.Count -gt 0) { throw ($parseErrors | ForEach-Object Message | Out-String) }
Import-Module $modulePath -Force -DisableNameChecking

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-codex-mcp-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $config = Join-Path $fixture 'config.toml'
    $npx = 'C:\Program Files\nodejs\npx.cmd'
    @'
model = "gpt-5"
node_repl = true

[mcp_servers.context7]
url = "https://example.invalid/mcp"
enabled = false

[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@old"]
enabled = false

[mcp_servers.github]
url = "https://github.example.invalid/mcp"
enabled = true
'@ | Set-Content -LiteralPath $config -Encoding UTF8

    $beforeForeign = @('[mcp_servers.context7]','[mcp_servers.github]','model = "gpt-5"','node_repl = true')
    $chromium = Join-Path $fixture 'chromium.exe'
    Set-Content -LiteralPath $chromium -Value 'fixture'
    $changed = Set-SgCodexPlaywrightMcpConfig -ConfigPath $config -NpxPath $npx -PlaywrightVersion '0.0.42' -ChromiumPath $chromium
    if (-not $changed) { throw 'The divergent Playwright block should be repaired.' }
    $content = [IO.File]::ReadAllText($config)
    foreach ($needle in $beforeForeign) { if (-not $content.Contains($needle)) { throw "Foreign config was not preserved: $needle" } }
    foreach ($needle in @(
        '# >>> shipglows codex playwright mcp >>>',
        '[mcp_servers.playwright]',
        'command = "C:\\Program Files\\nodejs\\npx.cmd"',
        'args = ["-y", "--registry=https://registry.npmjs.org/", "@playwright/mcp@0.0.42", "--headless", "--browser", "chromium"]',
        'enabled = true',
        '# <<< shipglows codex playwright mcp <<<'
    )) { if (-not $content.Contains($needle)) { throw "Expected Playwright config is missing: $needle" } }
    if (([regex]::Matches($content, '(?m)^\[mcp_servers\.playwright\]$')).Count -ne 1) { throw 'Playwright table must be unique.' }
    if (@(Get-ChildItem -LiteralPath $fixture -Filter '*.shipglows-backup-*').Count -ne 0) { throw 'Codex config must not duplicate potentially secret-bearing TOML into persistent backups.' }

    $hash = (Get-FileHash -LiteralPath $config -Algorithm SHA256).Hash
    $changedAgain = Set-SgCodexPlaywrightMcpConfig -ConfigPath $config -NpxPath $npx -PlaywrightVersion '0.0.42' -ChromiumPath $chromium
    if ($changedAgain) { throw 'Second configuration pass must be idempotent.' }
    if ((Get-FileHash -LiteralPath $config -Algorithm SHA256).Hash -ne $hash) { throw 'Idempotent pass changed config bytes.' }

    $playwright = Get-SgCodexPlaywrightMcpConfig -ConfigPath $config
    if ($playwright.Command -ne $npx -or -not $playwright.Enabled) { throw 'Parsed Playwright config is invalid.' }
    if (($playwright.Arguments -join '|') -ne '-y|--registry=https://registry.npmjs.org/|@playwright/mcp@0.0.42|--headless|--browser|chromium') { throw 'Parsed Playwright arguments are invalid.' }

    $missingChromiumFailed = $false
    try { [void](Set-SgCodexPlaywrightMcpConfig -ConfigPath (Join-Path $fixture 'missing.toml') -NpxPath $npx -PlaywrightVersion '0.0.42' -ChromiumPath (Join-Path $fixture 'missing.exe')) } catch { $missingChromiumFailed = $_.Exception.Message -match 'Chromium' }
    if (-not $missingChromiumFailed) { throw 'Codex Playwright MCP must reject absent Chromium.' }
    $mutableVersionFailed = $false
    try { [void](Set-SgCodexPlaywrightMcpConfig -ConfigPath (Join-Path $fixture 'latest.toml') -NpxPath $npx -PlaywrightVersion 'latest' -ChromiumPath $chromium) } catch { $mutableVersionFailed = $_.Exception.Message -match 'exact' }
    if (-not $mutableVersionFailed) { throw 'Codex Playwright MCP must reject mutable package tags.' }

    $existingCommand = Join-Path $PSHOME 'powershell.exe'
    $missingCodex = Get-SgCodexPlaywrightPrerequisiteStatus '' $existingCommand $npx
    if ($missingCodex.Ready -or $missingCodex.Message -notmatch 'Codex CLI is unavailable') { throw 'Missing Codex diagnostic is not explicit.' }
    $missingNode = Get-SgCodexPlaywrightPrerequisiteStatus $existingCommand '' $npx
    if ($missingNode.Ready -or $missingNode.Message -notmatch 'Node.js is unavailable') { throw 'Missing Node diagnostic is not explicit.' }
    $missingNpx = Get-SgCodexPlaywrightPrerequisiteStatus $existingCommand $existingCommand ''
    if ($missingNpx.Ready -or $missingNpx.Message -notmatch 'npx.cmd is unavailable') { throw 'Missing npx diagnostic is not explicit.' }

    $previousLocalAppData = $env:LOCALAPPDATA
    try {
        $env:LOCALAPPDATA = $fixture
        $exactBrowser = Join-Path $fixture 'ms-playwright\chromium-1237\chrome-win64\chrome.exe'
        $otherBrowser = Join-Path $fixture 'ms-playwright\chromium-9999\chrome-win64\chrome.exe'
        New-Item -ItemType Directory -Path (Split-Path $exactBrowser -Parent),(Split-Path $otherBrowser -Parent) -Force | Out-Null
        Set-Content -LiteralPath $exactBrowser -Value 'exact'
        Set-Content -LiteralPath $otherBrowser -Value 'other'
        $resolvedExact = Get-SgPlaywrightChromiumExecutable -Revision '1237'
        if (-not $resolvedExact -or $resolvedExact.FullName -ne $exactBrowser) { throw 'Chromium resolution must honor the exact requested Playwright revision.' }
        if (Get-SgPlaywrightChromiumExecutable -Revision '4040') { throw 'An absent exact Chromium revision must not fall back to another cached browser.' }
    } finally { $env:LOCALAPPDATA = $previousLocalAppData }

    Write-Host 'Windows Codex Playwright MCP config regression: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
