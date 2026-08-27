$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-Sg([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$frontendPath = Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-project-guidance-{0}" -f [guid]::NewGuid().ToString('N'))

try {
    Import-Module $modulePath -Force
    Assert-Sg ([bool](Get-Command Get-SgProjectExperience -ErrorAction SilentlyContinue)) 'The shared project experience descriptor is not exported.'
    Assert-Sg ([bool](Get-Command Format-SgProjectStatus -ErrorAction SilentlyContinue)) 'The shared project status formatter is not exported.'

    $extension = Get-SgProjectExperience 'browser-extension' 3002
    Assert-Sg ($extension.Label -eq 'Chrome extension') 'The extension label exposes an internal project kind.'
    Assert-Sg ($extension.PortLabel -eq 'HMR :3002') 'The extension port is not identified as HMR.'
    Assert-Sg ($extension.Artifact -eq 'dist\chrome') 'The extension descriptor omitted its unpacked directory.'
    Assert-Sg ($extension.StartNextAction -match 's open') 'Extension Start does not route to Open.'
    Assert-Sg ($extension.OpenNextAction -match 'Developer mode' -and $extension.OpenNextAction -match 'Load unpacked') 'Extension Open omitted the Chrome loading steps.'

    $web = Get-SgProjectExperience 'vite' 4321
    Assert-Sg ($web.Label -eq 'Web project' -and $web.PortLabel -eq 'URL :4321') 'Web project guidance drifted.'
    $app = Get-SgProjectExperience 'flutter-web' 5000
    Assert-Sg ($app.Label -eq 'Flutter app' -and $app.PortLabel -eq 'App :5000') 'Flutter app guidance drifted.'

    $summary = Format-SgProjectStatus ([pscustomobject]@{ status='running'; kind='browser-extension'; port=3002; Name='ToolGlows' })
    Assert-Sg ($summary -match 'Chrome extension' -and $summary -match 'HMR :3002' -and $summary -match 'dist\\chrome') 'Extension dashboard/status output is not user-oriented.'

    $stoppedError = ''
    try {
        Open-SgProject ([pscustomobject]@{}) ([pscustomobject]@{ name='ToolGlows'; path=$fixture; kind='browser-extension'; port=3002; status='stopped' }) | Out-Null
    } catch { $stoppedError = $_.Exception.Message }
    Assert-Sg ($stoppedError -match 'ToolGlows' -and $stoppedError -match 'stopped' -and $stoppedError -match 's start') 'Open on a stopped extension did not provide a specific recovery action.'

    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    [void](Write-SgProjectEnvironment $fixture 3002 -Kind 'browser-extension')
    $environment = [IO.File]::ReadAllText((Join-Path $fixture 'ENVIRONMENT.md'))
    foreach ($expected in @('s start','s open','Developer mode','Load unpacked','dist\chrome','s stop')) {
        Assert-Sg ($environment.Contains($expected)) "Extension environment guidance omitted: $expected"
    }

    $frontend = [IO.File]::ReadAllText($frontendPath)
    Assert-Sg ($frontend -match "'status'") 'The Windows CLI has no project status action.'
    Assert-Sg ($frontend -match 'Open / load project') 'The Windows menu still implies that every project opens as a website.'
    foreach ($expected in @('Web project','Flutter app','Chrome extension','s start -ProjectPath','s open -ProjectPath','s status -ProjectPath','s stop -ProjectPath')) {
        Assert-Sg ($frontend.Contains($expected)) "Windows help omitted: $expected"
    }

    Write-Host 'Windows guided project experience: OK'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
