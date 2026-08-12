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
    $changed = Set-SgCodexPlaywrightMcpConfig -ConfigPath $config -NpxPath $npx
    if (-not $changed) { throw 'The divergent Playwright block should be repaired.' }
    $content = [IO.File]::ReadAllText($config)
    foreach ($needle in $beforeForeign) { if (-not $content.Contains($needle)) { throw "Foreign config was not preserved: $needle" } }
    foreach ($needle in @(
        '# >>> shipglows codex playwright mcp >>>',
        '[mcp_servers.playwright]',
        'command = "C:\\Program Files\\nodejs\\npx.cmd"',
        'args = ["-y", "@playwright/mcp@latest", "--headless", "--browser", "chromium"]',
        'enabled = true',
        '# <<< shipglows codex playwright mcp <<<'
    )) { if (-not $content.Contains($needle)) { throw "Expected Playwright config is missing: $needle" } }
    if (([regex]::Matches($content, '(?m)^\[mcp_servers\.playwright\]$')).Count -ne 1) { throw 'Playwright table must be unique.' }

    $hash = (Get-FileHash -LiteralPath $config -Algorithm SHA256).Hash
    $changedAgain = Set-SgCodexPlaywrightMcpConfig -ConfigPath $config -NpxPath $npx
    if ($changedAgain) { throw 'Second configuration pass must be idempotent.' }
    if ((Get-FileHash -LiteralPath $config -Algorithm SHA256).Hash -ne $hash) { throw 'Idempotent pass changed config bytes.' }

    $playwright = Get-SgCodexPlaywrightMcpConfig -ConfigPath $config
    if ($playwright.Command -ne $npx -or -not $playwright.Enabled) { throw 'Parsed Playwright config is invalid.' }
    if (($playwright.Arguments -join '|') -ne '-y|@playwright/mcp@latest|--headless|--browser|chromium') { throw 'Parsed Playwright arguments are invalid.' }

    $existingCommand = Join-Path $PSHOME 'powershell.exe'
    $missingCodex = Get-SgCodexPlaywrightPrerequisiteStatus '' $existingCommand $npx
    if ($missingCodex.Ready -or $missingCodex.Message -notmatch 'Codex CLI is unavailable') { throw 'Missing Codex diagnostic is not explicit.' }
    $missingNode = Get-SgCodexPlaywrightPrerequisiteStatus $existingCommand '' $npx
    if ($missingNode.Ready -or $missingNode.Message -notmatch 'Node.js is unavailable') { throw 'Missing Node diagnostic is not explicit.' }
    $missingNpx = Get-SgCodexPlaywrightPrerequisiteStatus $existingCommand $existingCommand ''
    if ($missingNpx.Ready -or $missingNpx.Message -notmatch 'npx.cmd is unavailable') { throw 'Missing npx diagnostic is not explicit.' }

    Write-Host 'Windows Codex Playwright MCP config regression: OK'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
