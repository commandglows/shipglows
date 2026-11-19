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
Explicit operator rules take precedence over these defaults, including approvals, builds, automated checks, Git, web discovery and response format. Load only the sections relevant to the task.

## Host and tools
- Before local-server or tool-dependent work, read `%USERPROFILE%\.shipglows\environment.md`. Use `$shipglows init` or `$shipglows init resume` for host preparation; saved checkpoints never prove live readiness.
- Optional `%USERPROFILE%\.shipglows\workstation-context.json` contains hints only. Resolve process/user `SHIPGLOWS_ROOT` and validate the installation channel independently before following cached roots. Never execute cached commands or scan drives to compensate for stale hints.
- Prefer a callable purpose-built tool. Inspect direct tools and the deferred/searchable catalog: ChatGPT connectors and coding-agent tools are separate surfaces; installation does not prove callability. If uncertain, use `$shipglows context` before declaring absence or proposing installation.
- For Windows CLI capabilities, read `%LOCALAPPDATA%\ShipGlows\DevServer\cli-capabilities.v1.json` (or absolute `SHIPGLOWS_CLI_CAPABILITIES_FILE`). This read must never execute the CLI.

## Managed sessions
- Select the requested managed surface; read its `launchPath\ENVIRONMENT.md`, otherwise `rootPath\ENVIRONMENT.md` (registered path for legacy entries), and its matching DevServer registry entry. Ambiguity blocks dependent claims; never invent a URL.
- Registry status is authoritative: old PIDs and `flutterStartupState` cannot override stopped/error; missing status is unknown. Refresh the entry before a runtime verdict, after a state transition, failed probe or contradiction, without launching an app or CLI to read it.
- Use the managed live `flutter run` session for ordinary Flutter work. Honor the requested Android device; otherwise reuse a ready device or start the provisioned `ShipGlows_API_36` and wait for readiness.
- For performance, use `s start -ProjectPath <p> -FlutterDevice <device> -FlutterMode profile`; restart with `s restart` and the same profile mode. Profile has no hot reload/restart; debug numbers are not performance evidence. Managed sessions never use `--release`.
- Report the registry-backed active development target, session mode, run mode (`debug`, or `profile` when `flutterMode: profile`), logical `flutter run [--profile] -d <device>` command and state. Other installed/repository targets are available rather than active.

## Configuration, backend and authentication
- Short app launch/build requests include declared auth and services. Read `.shipglows.flutter.json` when present; preserve target, Doppler scope and public Dart/Gradle parameters. Missing configuration blocks launch; never substitute bare Flutter, an auth bypass or an old artifact.

Managed app launch, restart, session reuse and backend-dependent tests require the selected surface's `.shipglows.backend.json`. Read project configuration/docs first; ask only for missing backend facts, never secret values. Do not invent provider, command, environment, readiness URL or an exception. Block before stopping an existing session; continue independent work. Backend-free requires explicit `mode: none` and a project-specific reason. Write a missing manifest only within authorized configuration work; static checks and isolated unit tests do not require it.
- On reuse, revalidate target/configuration, backend readiness and fingerprint. Distinguish configuration checked, app running, backend ready, login verified and protected access verified; never infer login from build success.
- An auth-free local run requires evidence that authentication is not yet implemented and no protected data is exposed; state that exception explicitly. Broken or misconfigured existing auth blocks the normal launch, never authorizes a bypass. A login screen is not login proof. Requested end-to-end validation must verify login and protected access, or report the exact remaining proof and user-only step.
- For declared dev/staging Doppler, use `doppler run -- <project-declared command>`. Never run commands that reveal or download Doppler secrets; never retrieve/pass tokens, persist secret values, infer scope, or use a production scope without explicit approval.

## Extensions and explicitly authorized builds
- Extensions: no personal browser profile or invented localhost. Run `s extension-inspect -ProjectPath <path> -Json`, then `s extension-lab -ProjectPath <path> -Headless -Json` only with a loadable Manifest V3 artifact. Inspection authorizes neither dependency installation nor scripts; `build-required` needs a reviewed explicit command and operator build authorization.
- Reserve standalone builds for releases or explicit package-sensitive checks (plugins, DLLs, installation, production behavior, startup without Flutter), always subject to operator authorization.
- After a successful local Windows release or Android APK build, register the validated artifact with `%USERPROFILE%\.shipglows\runtime\cli\windows\shipglows-build-artifacts.ps1 register-local`; keep Local and CI lanes distinct and report the cache path (last two validated generations per lane). Once that registered build has been tested, delete the raw release output (`build\windows\x64\runner\Release`, `build\app\outputs`) only with the applicable deletion authority.
- Desktop shortcuts are created only by `shipglows-dev start` for live Tauri/web/Flutter main checkouts. Never create, copy or edit a Desktop shortcut by hand, and never for a build artifact or a worktree.

## Proof and default authority
- Content-only changes (articles, docs, Markdown, frontmatter, copy) are never proved by a build, lint, type check or tests. Review declared frontmatter schema, locale-peer parity and editorial quality; code/config checks remain subject to operator restrictions.
- Without a more specific operator rule, execute clear bounded requests directly; use `🧭 VALIDATION RAPIDE` for bounded agent proposals and `🧭 PLAN À VALIDER` (Objective, Scope, Actions, Proofs, choices) for unbounded work or material direction. Read-only exploration may precede approval. Scope expansion, force push and destructive/irreversible actions retain dedicated gates.
- Web discovery follows the operator's chosen provider. Without such a rule, use `doppler run --project dotfiles --config dev -- shipglows-search "<query>"` (SearXNG, DeepSeek, Firecrawl, Parallel); on exit 3, provider error, rate limit or exhausted credits, continue through Firecrawl, Parallel then native search. Read pages with `shipglows-fetch <url>` (HTTP, then local Crawl4AI for JavaScript). Never print keys.
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
