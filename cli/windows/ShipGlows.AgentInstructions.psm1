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
An exact micro-request is authority for its one explicit, unambiguous, local-only, routine, readily reversible micro-mutation when the target is resolved and the action cannot overwrite, discard, delete, force, publish, deploy, message, change credentials/permissions, start a process, or affect unrelated changes; execute it without another prompt. It does not authorize a chantier. Every other intentional mutation requires approval after a one- or two-sentence `🧭 VALIDATION RAPIDE` with the exact action, target, and safety guarantee, or a `🧭 PLAN À VALIDER` containing Objective, Scope, Actions, Proofs, and contextual choices. If material scope changes, stop and obtain approval for a newly appropriate validation or replacement plan. Ordinary exact-scope local commits never need a separate prompt. `git push` always uses the full plan; force push retains stricter gates. Read-only exploration is allowed before approval.
Before local-server or tool-dependent work, read `%USERPROFILE%\.shipglows\environment.md`.
For a ShipGlows-managed project, then read `<project-root>\ENVIRONMENT.md` for its durable assigned URL and the ShipGlows DevServer registry for live status.
Prefer a purpose-built tool that is discovered and callable in the current agent when it matches the task. Installed or configured does not mean callable from every agent surface.
ChatGPT apps/connectors and coding-agent tools are different surfaces. Never assume one is callable from another. Inspect directly exposed tools and any deferred/searchable catalog provided by the current agent before declaring a configured tool unavailable; that current-turn inventory remains authoritative.
When capability state is uncertain and the ShipGlows skill is available, invoke `$shipglows context` before declaring a tool absent or proposing another installation.
When a project explicitly declares Doppler for its current development or staging scope, agents may use `doppler run -- <project-declared command>` without printing secret values. Never run commands that reveal or download Doppler secrets, retrieve or pass tokens, persist secret values, infer a project/config/environment, or use a production scope without explicit approval.
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

Export-ModuleMember -Function Get-SgAgentEnvironmentInstructionBlock,Get-SgAgentInstructionTargets,Set-SgAgentEnvironmentInstructions,Install-SgAgentEnvironmentInstructions
