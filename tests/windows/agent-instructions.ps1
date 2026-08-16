$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.AgentInstructions.psm1'
if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) { throw "Missing Windows agent instructions helper: $modulePath" }
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseFile($modulePath, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | ForEach-Object Message | Out-String) }
Import-Module $modulePath -Force -DisableNameChecking

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$sandbox = Join-Path ([IO.Path]::GetTempPath()) ('sg-agent-instructions-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $sandbox | Out-Null
    $targets = @(Get-SgAgentInstructionTargets -UserProfile $sandbox -AgentReady @{ Codex=$true; Claude=$true; OpenCode=$true; Kilo=$true })
    Assert-Sg ($targets.Count -eq 4) 'The instruction target plan must contain all four supported agents.'
    $sandboxPrefix = [IO.Path]::GetFullPath($sandbox).TrimEnd('\') + '\'
    Assert-Sg (($targets.Path | ForEach-Object { $_.Substring($sandboxPrefix.Length) }) -join '|' -eq '.codex\AGENTS.md|.claude\CLAUDE.md|.config\opencode\AGENTS.md|.config\kilo\AGENTS.md') 'Native instruction paths drifted.'

    $codexPath = Join-Path $sandbox '.codex\AGENTS.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $codexPath) -Force | Out-Null
    $foreignPrefix = "# Règle étrangère`r`nConserver Ω et les fins CRLF.`r`n`r`n"
    [IO.File]::WriteAllText($codexPath, $foreignPrefix, [Text.UTF8Encoding]::new($false))

    $claudePath = Join-Path $sandbox '.claude\CLAUDE.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $claudePath) -Force | Out-Null
    $oldBlock = "# >>> ShipGlows development environment >>>`nancienne règle`n# <<< ShipGlows development environment <<<`n"
    [IO.File]::WriteAllText($claudePath, "avant`n$oldBlock`naprès`n", [Text.UTF8Encoding]::new($false))

    $kiloPath = Join-Path $sandbox '.config\kilo\AGENTS.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $kiloPath) -Force | Out-Null
    [IO.File]::WriteAllText($kiloPath, "instruction Kilo Ω`n", [Text.UTF8Encoding]::new($true))

    $changed = @(Install-SgAgentEnvironmentInstructions -UserProfile $sandbox -AgentReady @{ Codex=$true; Claude=$true; OpenCode=$false; Kilo=$true })
    Assert-Sg ($changed.Count -eq 3) 'Only detected agents must receive the managed instruction block.'
    Assert-Sg (-not (Test-Path -LiteralPath (Join-Path $sandbox '.config\opencode'))) 'An unavailable agent must not receive files or directories.'
    foreach ($path in @($codexPath, $claudePath, $kiloPath)) {
        $content = [IO.File]::ReadAllText($path)
        Assert-Sg (([regex]::Matches($content, '(?m)^# >>> ShipGlows development environment >>>\r?$')).Count -eq 1) "Managed block duplication in $path"
        Assert-Sg ($content -match 'purpose-built tool') "Purpose-built tool guidance missing in $path"
        Assert-Sg ($content -match 'deferred/searchable catalog') "Deferred tool catalog guidance missing in $path"
        Assert-Sg ($content -match '\$shipglows context') "ShipGlows context recovery guidance missing in $path"
        Assert-Sg ($content -match '%USERPROFILE%\\\.shipglows\\environment\.md') "Dynamic environment pointer missing in $path"
    }
    $codexAfter = [IO.File]::ReadAllText($codexPath)
    Assert-Sg ($codexAfter.StartsWith($foreignPrefix, [StringComparison]::Ordinal)) 'Foreign CRLF/Unicode content was not preserved byte-for-byte.'
    $claudeAfter = [IO.File]::ReadAllText($claudePath)
    Assert-Sg ($claudeAfter.StartsWith("avant`n", [StringComparison]::Ordinal) -and $claudeAfter.EndsWith("`naprès`n", [StringComparison]::Ordinal)) 'Foreign content around a replaced block was changed.'
    Assert-Sg ($claudeAfter -notmatch 'ancienne règle') 'The obsolete managed block was not replaced.'
    $kiloBytes = [IO.File]::ReadAllBytes($kiloPath)
    Assert-Sg ($kiloBytes.Length -ge 3 -and $kiloBytes[0] -eq 0xEF -and $kiloBytes[1] -eq 0xBB -and $kiloBytes[2] -eq 0xBF) 'An existing UTF-8 BOM was not preserved.'

    $before = @{}
    foreach ($path in @($codexPath, $claudePath, $kiloPath)) { $before[$path] = [IO.File]::ReadAllBytes($path) }
    $second = @(Install-SgAgentEnvironmentInstructions -UserProfile $sandbox -AgentReady @{ Codex=$true; Claude=$true; OpenCode=$false; Kilo=$true })
    Assert-Sg ($second.Count -eq 0) 'A converged rerun must report no changed files.'
    foreach ($path in $before.Keys) {
        $afterBytes = [IO.File]::ReadAllBytes($path)
        Assert-Sg ([Convert]::ToBase64String($afterBytes) -ceq [Convert]::ToBase64String($before[$path])) "Rerun was not byte-idempotent for $path"
    }

    $brokenPath = Join-Path $sandbox '.config\opencode\AGENTS.md'
    New-Item -ItemType Directory -Path (Split-Path -Parent $brokenPath) -Force | Out-Null
    $broken = "foreign`n# >>> ShipGlows development environment >>>`nunclosed`n"
    [IO.File]::WriteAllText($brokenPath, $broken, [Text.UTF8Encoding]::new($false))
    $failedClosed = $false
    try { [void](Set-SgAgentEnvironmentInstructions -Path $brokenPath) } catch { $failedClosed = $_.Exception.Message -match 'unclosed|malformed' }
    Assert-Sg $failedClosed 'An unclosed managed block must fail closed.'
    Assert-Sg ([IO.File]::ReadAllText($brokenPath) -ceq $broken) 'Fail-closed handling overwrote the foreign file.'
    Assert-Sg (@(Get-ChildItem -LiteralPath $sandbox -Recurse -File -Filter '*.tmp').Count -eq 0) 'Atomic instruction temp files were left behind.'
}
finally {
    if (Test-Path -LiteralPath $sandbox) { Remove-Item -LiteralPath $sandbox -Recurse -Force }
}

Write-Host 'Windows agent instructions regression: OK'
