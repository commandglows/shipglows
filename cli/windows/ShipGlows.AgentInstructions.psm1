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
A clear bounded request is authority for its few coherent enumerable actions and targets when the agent does not need to choose a material direction; execute it without another prompt. It can include a targeted file modification, exact-scope commit, ordinary resolved push, or small explicit sequence, and it does not authorize a chantier. Local versus remote and model reasoning effort never change this classification. Use a one- or two-sentence `🧭 VALIDATION RAPIDE` for a bounded agent-proposed action or almost-clear intent. Use `🧭 PLAN À VALIDER` containing Objective, Scope, Actions, Proofs, and contextual choices when the outcome, actions, or targets are unbounded or the agent must substantially analyze, propose, or select a direction. If material scope expands, stop and obtain approval for a newly appropriate validation or replacement plan. Force push and destructive or irreversible actions retain stricter dedicated gates. Read-only exploration is allowed before approval.
Before local-server or tool-dependent work, read `%USERPROFILE%\.shipglows\environment.md`.
When a conversation needs the capabilities actually exposed by the Windows CLI, read the bounded snapshot at `%LOCALAPPDATA%\ShipGlows\DevServer\cli-capabilities.v1.json` (or the explicit absolute `SHIPGLOWS_CLI_CAPABILITIES_FILE` override); reading it must never execute the CLI.
For a ShipGlows-managed project, select the managed surface matching the requested target. Read its launchPath\ENVIRONMENT.md when present, otherwise rootPath\ENVIRONMENT.md (registered path for legacy entries), and its matching ShipGlows DevServer registry entry. Ambiguous surface selection blocks the dependent claim. Current registry status is authoritative; retained PIDs and flutterStartupState never override stopped or error, and missing status remains unknown. Refresh that entry before a runtime-dependent verdict and after a state transition, failed probe or contradictory observation, without starting the CLI or an application. For Flutter, report the registry-backed active development target, managed session mode, run mode (`debug` by default, `profile` when the registry entry records `flutterMode: profile`), logical `flutter run [--profile] -d <device>` command, and state; keep other installed or repository targets classified as available rather than active.
For a browser extension, do not invent a localhost URL or target a personal browser profile. Inspect with `s extension-inspect -ProjectPath <path> -Json`, then use `s extension-lab -ProjectPath <path> -Headless -Json` for isolated proof when a loadable Manifest V3 artifact exists.
Extension inspection never authorizes dependency installation or repository scripts. A `build-required` result needs the repository's reviewed explicit build command before the Lab is retried.
Prefer a purpose-built tool that is discovered and callable in the current agent when it matches the task. Installed or configured does not mean callable from every agent surface.
ChatGPT apps/connectors and coding-agent tools are different surfaces. Never assume one is callable from another. Inspect directly exposed tools and any deferred/searchable catalog provided by the current agent before declaring a configured tool unavailable; that current-turn inventory remains authoritative.
When capability state is uncertain and the ShipGlows skill is available, invoke `$shipglows context` before declaring a tool absent or proposing another installation.
For web search, run `doppler run --project dotfiles --config dev -- shipglows-search "<query>"`, which tries local SearXNG, then Firecrawl, then Parallel without printing keys; read a page with `shipglows-fetch <url>` (plain HTTP, then the local Crawl4AI browser for JavaScript pages). When it exits 3, or a search connector reports exhausted credits, a rate limit or an error, switch without asking to the next provider: Firecrawl, then Parallel (CLI or connector), then the agent's native web search. A provider credit error never ends the research.
For ordinary Flutter implementation and debugging, use the managed live `flutter run` session for the selected target so logs and reload remain attached. On Android, honor an explicit connected device; otherwise reuse a ready device or start the provisioned `ShipGlows_API_36` emulator and wait for readiness. For performance measurement with Flutter attached, use the managed profile session (`s start -ProjectPath <p> -FlutterDevice <device> -FlutterMode profile`; the registry records `flutterMode`, profile sessions support neither hot reload nor hot restart, so `s restart … -FlutterMode profile` rebuilds them) instead of a hand-run `flutter run --profile` or `flutter drive --profile`; debug-mode numbers are not performance evidence and no managed session uses `--release`. Reserve standalone builds for releases or explicit package-sensitive checks such as native plugins, DLLs, installation, production-mode behavior, or startup without Flutter attached.
Short app launch/build requests include the project's declared authentication and service configuration by default. Resolve the target and dev/build mode from project evidence, use `.shipglows.flutter.json` when declared, and preserve its Doppler scope and public Dart/Gradle parameters. Never substitute a bare Flutter command, an authentication bypass, or an old artifact for the declared recipe. Revalidate a reused session's target/configuration; missing configuration blocks the requested launch instead of yielding an app without auth. Report configuration checked, app running, login verified, and protected access verified as separate evidence; never infer login from build success.
After any successful local Windows release or Android APK build, do not stop at build success. Register the validated artifact with `%USERPROFILE%\.shipglows\runtime\cli\windows\shipglows-build-artifacts.ps1 register-local`, keep Local and CI lanes distinct, and report the cached artifact path. Once that registered build has been tested, delete the raw release output left in the checkout (`build\windows\x64\runner\Release`, `build\app\outputs`); the ShipGlows cache already keeps the last two validated generations per lane. Desktop shortcuts are created only by `shipglows-dev start`, for live Tauri, web and Flutter dev servers of a main checkout. Never create, copy or edit a Desktop shortcut by hand, and never for a build artifact or a worktree.
When a project explicitly declares Doppler for its current development or staging scope, agents may use `doppler run -- <project-declared command>` without printing secret values. Never run commands that reveal or download Doppler secrets, retrieve or pass tokens, persist secret values, infer a project/config/environment, or use a production scope without explicit approval.
Managed app launch, restart, session reuse and backend-dependent tests require the selected surface's .shipglows.backend.json. Inspect existing project configuration and documentation first; if required backend facts remain missing, ambiguous or inaccessible, ask the operator only for those facts and explain why they are needed. Never request secret values or invent a provider, command, environment, readiness URL or no-backend exception. Block the dependent action before stopping an existing session; continue independent work. A genuinely backend-free project requires explicit mode none and a project-specific reason. Apply this to existing and future projects, not unrelated static checks or isolated unit tests. Write a missing manifest only within authorized project-configuration work. Revalidate backend readiness and fingerprint on reuse; backend availability is separate from login and protected API access.
Existing project authentication is mandatory for normal launches and tests. An auth-free local development run requires project evidence that authentication is not yet implemented and no protected data is exposed; state that exception explicitly. Broken or misconfigured existing auth blocks the normal launch, never authorizes a bypass. A login screen is not login proof. Requested end-to-end validation must verify login and protected access using authorized test context, or report the exact remaining proof and user-only step.
Content-only changes (articles, docs, Markdown, frontmatter, copy) are never proved by a build, type check, lint, or test run; their proof is frontmatter conformity with the declared schema, locale-peer parity, and editorial best practices. Run a build or check only when code, templates, schema, or configuration also changed, or when the operator explicitly asks.
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
