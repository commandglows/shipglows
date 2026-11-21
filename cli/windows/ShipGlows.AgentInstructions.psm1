Set-StrictMode -Version Latest

if (-not ('ShipGlowsAgentInstructionNativeFile' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ShipGlowsAgentInstructionNativeFile {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool MoveFileEx(string existingFileName, string newFileName, int flags);
}
'@
}

function Get-SgAgentEnvironmentInstructionBlock {
    return @'
# >>> ShipGlows development environment >>>
Explicit operator rules take precedence over these defaults (including approvals, builds, tests, Git, web discovery, and response format).

- Host & tools: before local-server or tool-dependent work, read `%USERPROFILE%\.shipglows\environment.md`; for Windows CLI capabilities, read `%LOCALAPPDATA%\ShipGlows\DevServer\cli-capabilities.v1.json` (never execute the CLI to inspect it). Prefer callable purpose-built tools (direct and deferred catalogs) and use `$shipglows context` before declaring a capability absent.
- Managed sessions & config: for managed apps/servers, read the surface's `ENVIRONMENT.md`, `.shipglows.flutter.json` / `.shipglows.backend.json`, and the DevServer registry (registry status is authoritative; never invent URLs, backends, or Doppler scopes). Use managed dev sessions (never hand-run servers or `--release`).
- Auth & secrets: never bypass broken auth, infer login from build success, or reveal/download Doppler secrets (use declared `doppler run -- <command>`; production scope requires explicit approval).
- Disk footprint: reuse a running managed session instead of starting another, and stop the sessions you started when your work ends. Install dependencies only with the project's lockfile manager (never npm in a pnpm/yarn project, no global or ad-hoc installs, no deleting node_modules/.venv to "fix" an install). Never add an SDK, Gradle, Node, Python, Playwright browser or Docker image version without need. Delete what you created outside the repo (temp files, clones, downloads, raw build outputs) before handing off; `s disk` reports and cleans the machine.
- Proof & skills on demand: content-only changes (articles, docs, Markdown, copy) are never proved by builds, lint, or tests. Load the dedicated ShipGlows skill/reference on demand for specialized workflows (Flutter live/profile, Android emulator, extensions, release artifacts, web discovery, or mutation plans).
# <<< ShipGlows development environment <<<
'@
}

function Get-SgAgentInstructionTargets {
    param(
        [Parameter(Mandatory=$true)][string]$UserProfile,
        [Parameter(Mandatory=$true)][hashtable]$AgentReady
    )
    $definitions = @(
        [pscustomobject]@{ Agent='Codex'; RelativePath='.codex\AGENTS.md' },
        [pscustomobject]@{ Agent='Claude'; RelativePath='.claude\CLAUDE.md' },
        [pscustomobject]@{ Agent='OpenCode'; RelativePath='.config\opencode\AGENTS.md' },
        [pscustomobject]@{ Agent='Kilo'; RelativePath='.config\kilo\AGENTS.md' },
        [pscustomobject]@{ Agent='Gemini'; RelativePath='.gemini\GEMINI.md' }
    )
    foreach ($definition in $definitions) {
        if ($AgentReady.ContainsKey($definition.Agent) -and [bool]$AgentReady[$definition.Agent]) {
            [pscustomobject]@{
                Agent = $definition.Agent
                Path = [IO.Path]::GetFullPath((Join-Path $UserProfile $definition.RelativePath))
            }
        }
    }
}

function Set-SgAgentEnvironmentInstructions {
    param([Parameter(Mandatory=$true)][string]$Path)

    $fullPath = [IO.Path]::GetFullPath($Path)
    $directory = Split-Path -Parent $fullPath
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $encoding = [Text.UTF8Encoding]::new($false)
    $existing = ''
    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        $bytes = [IO.File]::ReadAllBytes($fullPath)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $encoding = [Text.UTF8Encoding]::new($true) }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { $encoding = [Text.UnicodeEncoding]::new($false, $true) }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { $encoding = [Text.UnicodeEncoding]::new($true, $true) }
        $existing = [IO.File]::ReadAllText($fullPath)
    }
    $startPattern = '(?m)^# >>> ShipGlows development environment >>>\r?$'
    $endPattern = '(?m)^# <<< ShipGlows development environment <<<\r?$'
    $startCount = [regex]::Matches($existing, $startPattern).Count
    $endCount = [regex]::Matches($existing, $endPattern).Count
    if ($startCount -ne $endCount -or $startCount -gt 1) {
        throw "ShipGlows managed instruction markers are malformed or unclosed: $fullPath"
    }

    $block = (Get-SgAgentEnvironmentInstructionBlock).Trim([char[]]"`r`n") + "`n"
    if ($startCount -eq 1) {
        $managedPattern = '(?ms)^# >>> ShipGlows development environment >>>\r?\n.*?^# <<< ShipGlows development environment <<<\r?(?:\n|$)'
        $match = [regex]::Match($existing, $managedPattern)
        if (-not $match.Success) { throw "ShipGlows managed instruction markers are malformed: $fullPath" }
        $next = $existing.Substring(0, $match.Index) + $block + $existing.Substring($match.Index + $match.Length)
    }
    elseif (-not $existing) { $next = $block }
    else {
        $separator = if ($existing.EndsWith("`r`n", [StringComparison]::Ordinal)) { "`r`n" } elseif ($existing.EndsWith("`n", [StringComparison]::Ordinal)) { "`n" } else { "`n`n" }
        $next = $existing + $separator + $block
    }
    if ($next -ceq $existing) { return $false }

    $temp = "$fullPath.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp, $next, $encoding)
        if (-not [ShipGlowsAgentInstructionNativeFile]::MoveFileEx($temp, $fullPath, 9)) {
            throw "Atomic agent instruction replacement failed with Win32 error $([Runtime.InteropServices.Marshal]::GetLastWin32Error()): $fullPath"
        }
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    }
    return $true
}

function Install-SgAgentEnvironmentInstructions {
    param(
        [Parameter(Mandatory=$true)][string]$UserProfile,
        [Parameter(Mandatory=$true)][hashtable]$AgentReady
    )
    foreach ($target in @(Get-SgAgentInstructionTargets -UserProfile $UserProfile -AgentReady $AgentReady)) {
        if (Set-SgAgentEnvironmentInstructions -Path $target.Path) { $target.Path }
    }
}

function Get-SgT3AntigravityConfigDirectories {
    param([Parameter(Mandatory=$true)][string]$UserProfile)
    $root = Join-Path $UserProfile '.t3\userdata\providers\antigravity'
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { return @() }
    foreach ($providerDir in @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)) {
        $configDir = Join-Path $providerDir.FullName 'config'
        if (Test-Path -LiteralPath $configDir -PathType Container) { $configDir }
    }
}

function Sync-SgAntigravityRules {
    param(
        [Parameter(Mandatory=$true)][string]$UserProfile,
        [switch]$EnsureCanonicalRulesDir
    )
    $canonicalRulesDir = [IO.Path]::GetFullPath((Join-Path $UserProfile '.gemini\config\rules'))
    $providerConfigs = @(Get-SgT3AntigravityConfigDirectories -UserProfile $UserProfile)
    if (-not $EnsureCanonicalRulesDir -and $providerConfigs.Count -eq 0 -and -not (Test-Path -LiteralPath $canonicalRulesDir -PathType Container)) {
        return @()
    }
    if (-not (Test-Path -LiteralPath $canonicalRulesDir -PathType Container)) {
        New-Item -ItemType Directory -Path $canonicalRulesDir -Force | Out-Null
    }
    $envRulePath = Join-Path $canonicalRulesDir '20-shipglows-environment.md'
    if (-not (Test-Path -LiteralPath $envRulePath -PathType Leaf)) {
        $header = "---`ntrigger: always_on`n---`n`n"
        [IO.File]::WriteAllText($envRulePath, $header, [Text.UTF8Encoding]::new($false))
    }
    if (Set-SgAgentEnvironmentInstructions -Path $envRulePath) { $envRulePath }

    $normalizedTarget = $canonicalRulesDir.TrimEnd('\')
    foreach ($configDir in $providerConfigs) {
        $rulesLink = Join-Path $configDir 'rules'
        if (Test-Path -LiteralPath $rulesLink) {
            $item = Get-Item -LiteralPath $rulesLink -Force
            $isConverged = $false
            if ($item.LinkType -in @('Junction','SymbolicLink') -and $item.PSObject.Properties['Target']) {
                $linkTargets = @($item.Target)
                if ($linkTargets.Count -gt 0 -and $linkTargets[0]) {
                    $isConverged = ([IO.Path]::GetFullPath([string]$linkTargets[0]).TrimEnd('\') -ieq $normalizedTarget)
                }
            }
            if (-not $isConverged) {
                throw "Refusing to overwrite existing non-converged Antigravity rules path: $rulesLink"
            }
            continue
        }
        New-Item -ItemType Junction -Path $rulesLink -Target $canonicalRulesDir | Out-Null
        $rulesLink
    }
}

Export-ModuleMember -Function Get-SgAgentEnvironmentInstructionBlock,Get-SgAgentInstructionTargets,Set-SgAgentEnvironmentInstructions,Install-SgAgentEnvironmentInstructions,Get-SgT3AntigravityConfigDirectories,Sync-SgAntigravityRules
