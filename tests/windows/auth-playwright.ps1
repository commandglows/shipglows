$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$module = Join-Path $root 'cli\windows\ShipGlows.Auth.psm1'
if (-not (Test-Path -LiteralPath $module)) { throw 'ShipGlows.Auth.psm1 is missing.' }
Import-Module $module -Force -DisableNameChecking

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$definitions = @(Get-SgAuthenticationDefinitions)
$names = @($definitions.Name)
foreach ($required in @('Codex','Claude','OpenCode','Kilo','Gemini','GitHub','Firebase','Vercel','Clerk','Supabase','Convex')) {
    Assert-Sg ($names -contains $required) "Missing authentication definition: $required"
}
Assert-Sg ((@($definitions | Where-Object Name -eq 'Gemini')[0]).LoginMode -eq 'interactive-cli') 'Gemini must use its native interactive CLI.'
Assert-Sg ((@($definitions | Where-Object Name -eq 'Convex')[0]).LoginMode -eq 'project') 'Convex authentication must remain project-scoped.'
Assert-Sg (-not (@($definitions.StatusArguments + $definitions.LoginArguments + $definitions.LogoutArguments) -match '(token|api-key|access-key|secret)')) 'Authentication commands must not request or print secrets.'

$loggedIn = Get-SgAuthenticationState -Definition ([pscustomobject]@{ Name='Fixture'; Command='fixture.cmd'; StatusArguments=@('status'); LoginMode='command' }) -Runner { [pscustomobject]@{ ExitCode=0; TimedOut=$false; Output='private account data' } }
Assert-Sg ($loggedIn.Status -eq 'connected' -and -not $loggedIn.PSObject.Properties['Output']) 'Status must use exit code without returning provider output.'
$loggedOut = Get-SgAuthenticationState -Definition ([pscustomobject]@{ Name='Fixture'; Command='fixture.cmd'; StatusArguments=@('status'); LoginMode='command' }) -Runner { [pscustomobject]@{ ExitCode=1; TimedOut=$false; Output='private account data' } }
Assert-Sg ($loggedOut.Status -eq 'disconnected') 'Non-zero status must remain disconnected.'
$unknown = Get-SgAuthenticationState -Definition ([pscustomobject]@{ Name='Fixture'; Command=''; StatusArguments=@(); LoginMode='project' }) -Runner { throw 'must not run' }
Assert-Sg ($unknown.Status -eq 'project-required') 'Project-scoped authentication state is incorrect.'

$geminiNative = [pscustomobject]@{ Name='github'; Type='remote'; Url='https://example.com/mcp'; Command=''; Arguments=@() }
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-gemini-native-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $settings = Join-Path $fixture 'settings.json'
    [IO.File]::WriteAllText($settings, '{"mcpServers":{"github":{"url":"https://example.com/mcp","type":"http"}}}')
    Import-Module (Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1') -Force -DisableNameChecking
    Assert-Sg ((Get-SgGeminiMcpConfigState $settings $geminiNative).Status -eq 'ready') 'Gemini native url/type HTTP schema must be ready.'
} finally { if (Test-Path $fixture) { Remove-Item $fixture -Recurse -Force } }

$runtime = Get-SgPlaywrightRuntimePlan -StableVersion '1.62.1' -StableRevision '1234' -AgentCliVersion '0.1.0' -McpVersion '0.0.79' -McpRevision '1237' -Root 'C:\Tools\ShipGlows'
Assert-Sg ($runtime.Stable.CommandName -eq 'playwright' -and $runtime.Stable.Revision -eq '1234') 'Stable Playwright plan is invalid.'
Assert-Sg ($runtime.AgentCli.CommandName -eq 'playwright-cli') 'Agent Playwright CLI plan is invalid.'
Assert-Sg ($runtime.Mcp.Revision -eq '1237' -and $runtime.Mcp.Version -eq '0.0.79') 'MCP Playwright plan is invalid.'
Assert-Sg ($runtime.Stable.Root -ne $runtime.Mcp.Root -and $runtime.AgentCli.Root -ne $runtime.Mcp.Root) 'Playwright runtimes must remain isolated.'
Assert-Sg ($runtime.Stable.Root -ne $runtime.Mcp.Root) 'Stable and MCP runtimes must not share package ownership.'

Write-Host 'Windows authentication and Playwright runtime regression: OK'
