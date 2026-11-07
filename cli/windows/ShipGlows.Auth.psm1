$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-SgAuthenticationDefinitions {
    @(
        [pscustomobject]@{ Name='Codex'; Category='Agent'; Command='codex.cmd'; StatusArguments=@('login','status'); LoginArguments=@('login','--device-auth'); LogoutArguments=@('logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Claude'; Category='Agent'; Command='claude.cmd'; StatusArguments=@('auth','status'); LoginArguments=@('auth','login'); LogoutArguments=@('auth','logout'); LoginMode='command' },
        [pscustomobject]@{ Name='OpenCode'; Category='Agent'; Command='opencode.cmd'; StatusArguments=@('auth','list'); LoginArguments=@('auth','login'); LogoutArguments=@('auth','logout'); LoginMode='provider'; StatusMode='provider-list' },
        [pscustomobject]@{ Name='Kilo'; Category='Agent'; Command='kilo.cmd'; StatusArguments=@('auth','list'); LoginArguments=@('auth','login'); LogoutArguments=@('auth','logout'); LoginMode='provider'; StatusMode='provider-list' },
        [pscustomobject]@{ Name='Gemini'; Category='Agent'; Command='gemini.cmd'; StatusArguments=@(); LoginArguments=@(); LogoutArguments=@(); LoginMode='interactive-cli' },
        [pscustomobject]@{ Name='GitHub'; Category='Service'; Command='gh.exe'; StatusArguments=@('auth','status','--hostname','github.com'); LoginArguments=@('auth','login','--hostname','github.com','--git-protocol','https','--web'); LogoutArguments=@('auth','logout','--hostname','github.com'); LoginMode='command' },
        [pscustomobject]@{ Name='Firebase'; Category='Service'; Command='firebase.cmd'; StatusArguments=@('login:list'); LoginArguments=@('login'); LogoutArguments=@('logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Vercel'; Category='Service'; Command='vercel.cmd'; StatusArguments=@('whoami'); LoginArguments=@('login'); LogoutArguments=@('logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Clerk'; Category='Service'; Command='clerk.cmd'; StatusArguments=@('whoami'); LoginArguments=@('auth','login'); LogoutArguments=@('auth','logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Auth0'; Category='Service'; Command='auth0.cmd'; StatusArguments=@('tenants','list','--json-compact','--no-input'); LoginArguments=@('login'); LogoutArguments=@('logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Doppler'; Category='Service'; Command='doppler.cmd'; StatusArguments=@('me','--json','--no-check-version','--no-read-env'); LoginArguments=@('login','--no-check-version','--no-read-env'); LogoutArguments=@('logout','--no-check-version','--no-read-env'); LoginMode='command' },
        [pscustomobject]@{ Name='Supabase'; Category='Service'; Command='supabase.cmd'; StatusArguments=@('projects','list'); LoginArguments=@('login'); LogoutArguments=@('logout'); LoginMode='command' },
        [pscustomobject]@{ Name='Convex'; Category='Service'; Command='convex.cmd'; StatusArguments=@(); LoginArguments=@(); LogoutArguments=@('logout'); LoginMode='project' }
    )
}

function Get-SgAuthenticationState {
    param([Parameter(Mandatory=$true)]$Definition, [scriptblock]$Runner)
    if (-not $Definition.Command) { return [pscustomobject]@{ Name=$Definition.Name; Status=if($Definition.LoginMode -eq 'project'){'project-required'}else{'unavailable'} } }
    $resolved = Get-Command $Definition.Command -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $resolved -and -not $Runner) { return [pscustomobject]@{ Name=$Definition.Name; Status='unavailable' } }
    if ($Definition.LoginMode -eq 'project') { return [pscustomobject]@{ Name=$Definition.Name; Status='project-required' } }
    if (-not @($Definition.StatusArguments).Count) {
        $credentialEvidence = if ($Definition.Name -eq 'Gemini') { Test-Path (Join-Path $env:USERPROFILE '.gemini\oauth_creds.json') } else { $false }
        return [pscustomobject]@{ Name=$Definition.Name; Status=if($credentialEvidence){'connected'}else{'unknown'} }
    }
    if (-not $Runner) {
        $Runner = { param($File,$Arguments,$Timeout) $output=& $File @Arguments 2>&1; [pscustomobject]@{ ExitCode=$LASTEXITCODE; TimedOut=$false; Output=($output|Out-String) } }
    }
    $result = & $Runner $(if($resolved){$resolved.Source}else{$Definition.Command}) @($Definition.StatusArguments) 30
    $status = if($result.TimedOut){'unknown'}elseif($result.ExitCode -ne 0){'disconnected'}elseif($Definition.PSObject.Properties['StatusMode'] -and $Definition.StatusMode -eq 'provider-list'){'unknown'}else{'connected'}
    [pscustomobject]@{ Name=$Definition.Name; Status=$status }
}

function Get-SgPlaywrightMcpPackage {
    # The @playwright/mcp identity is catalog inventory. This module deliberately does not
    # import ShipGlows.MobileToolchain.psm1 (side effects); it reads only the Playwright
    # package field from the sibling MCP catalog and validates its package-name shape.
    $path = Join-Path $PSScriptRoot 'ShipGlows.McpCatalog.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "ShipGlows MCP catalog is missing: $path" }
    try { $catalog = [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "ShipGlows MCP catalog is malformed: $path" }
    if ($catalog.schema -cne 'shipglows.mcp-catalog/v1') { throw 'ShipGlows MCP catalog schema is unsupported.' }
    foreach ($flag in @('registryIsExecutionAuthority','automaticAuthentication','automaticGoogleCloudActivation')) {
        if ($catalog.policy.$flag -isnot [bool] -or $catalog.policy.$flag) { throw 'ShipGlows MCP catalog policy is unsupported.' }
    }
    $candidates = @($catalog.servers | Where-Object { [string]$_.id -ceq 'playwright' })
    if ($candidates.Count -ne 1) { throw 'ShipGlows MCP catalog has no unique Playwright entry.' }
    $package = [string]$candidates[0].package
    if ($package -notmatch '^@[a-z0-9][a-z0-9._-]*/[a-z0-9][a-z0-9._-]*$') { throw 'ShipGlows MCP catalog Playwright package identity is invalid.' }
    return $package
}

function Get-SgPlaywrightRuntimePlan {
    param(
        [Parameter(Mandatory=$true)][string]$StableVersion,
        [Parameter(Mandatory=$true)][string]$StableRevision,
        [Parameter(Mandatory=$true)][string]$AgentCliVersion,
        [Parameter(Mandatory=$true)][string]$McpVersion,
        [Parameter(Mandatory=$true)][string]$McpRevision,
        [Parameter(Mandatory=$true)][string]$Root
    )
    foreach($version in @($StableVersion,$AgentCliVersion,$McpVersion)){ if($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$'){throw 'Playwright packages require exact versions.'} }
    if ($AgentCliVersion -ne $StableVersion) { throw 'Playwright CLI is bundled with Playwright and must use the same exact version.' }
    foreach($revision in @($StableRevision,$McpRevision)){ if($revision -notmatch '^\d+$'){throw 'Playwright browser revisions must be numeric.'} }
    [pscustomobject]@{
        Stable=[pscustomobject]@{ CommandName='playwright'; Package='playwright'; Version=$StableVersion; Revision=$StableRevision; Root=(Join-Path $Root "playwright-$StableVersion") }
        AgentCli=[pscustomobject]@{ CommandName='playwright-cli'; Package='playwright'; Version=$StableVersion; Revision=$StableRevision; Root=(Join-Path $Root "playwright-$StableVersion"); EntryArguments=@('cli') }
        Mcp=[pscustomobject]@{ CommandName='playwright-mcp'; Package=(Get-SgPlaywrightMcpPackage); Version=$McpVersion; Revision=$McpRevision; Root=(Join-Path $Root "playwright-mcp-$McpVersion") }
    }
}

Export-ModuleMember -Function Get-SgAuthenticationDefinitions,Get-SgAuthenticationState,Get-SgPlaywrightRuntimePlan
