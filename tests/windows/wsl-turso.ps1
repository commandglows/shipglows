$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$module = Join-Path $root 'cli\windows\ShipGlows.WslTurso.psm1'
$installer = Join-Path $root 'cli\install-turso-cloud.sh'
Import-Module $module -Force -DisableNameChecking

function Assert-True([bool]$Condition,[string]$Message) {
    if (-not $Condition) { throw $Message }
}

function New-TestResult([int]$ExitCode,[string]$Output='',[bool]$TimedOut=$false) {
    [pscustomobject]@{ ExitCode=$ExitCode; Output=$Output; TimedOut=$TimedOut }
}

$absentRunner = { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 1 'WSL is not installed.' }
$absent = Get-SgWslState -Runner $absentRunner
Assert-True ($absent.Status -eq 'absent') 'An unavailable WSL command was not classified as absent.'
$errorRunner = { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 5 'Access denied by policy.' }
$inspectionError = Get-SgWslState -Runner $errorRunner
Assert-True ($inspectionError.Status -eq 'error') 'An unexplained WSL failure was incorrectly classified as absence.'

$platformRunner = {
    param($File,$Arguments,$TimeoutSeconds,$InputText)
    if (($Arguments -join ' ') -eq '--status') { return New-TestResult 0 'Default Version: 2' }
    return New-TestResult 0 ''
}
$platformOnly = Get-SgWslState -Runner $platformRunner
Assert-True ($platformOnly.Status -eq 'platform_only') 'WSL without Ubuntu was not classified as platform_only.'

$ubuntuRunner = {
    param($File,$Arguments,$TimeoutSeconds,$InputText)
    if (($Arguments -join ' ') -eq '--status') { return New-TestResult 0 'Default Version: 2' }
    return New-TestResult 0 "$([char]0xFEFF)Ubuntu`0`r`n"
}
$uninitialized = Get-SgWslState -Runner $ubuntuRunner -RegistrationReader { param($Distribution) [uint32]0 }
Assert-True ($uninitialized.Status -eq 'ubuntu_uninitialized') 'Ubuntu without a non-root default user was not classified as uninitialized.'

$ready = Get-SgWslState -Runner $ubuntuRunner -RegistrationReader { param($Distribution) [uint32]1000 }
Assert-True ($ready.Status -eq 'ready' -and $ready.Distribution -eq 'Ubuntu') 'Initialized Ubuntu was not classified as ready.'

$restartRunner = { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 1 'Restart Windows to finish installing WSL.' }
$restart = Get-SgWslState -Runner $restartRunner
Assert-True ($restart.Status -eq 'pending_restart') 'A WSL restart requirement was not preserved.'

$declined = Get-SgWslInstallPlan -State $absent -Interactive $true -Choice 'n'
Assert-True (-not $declined.Approved -and $declined.Action -eq 'none') 'WSL refusal did not remain non-mutating.'
$nonInteractive = Get-SgWslInstallPlan -State $absent -Interactive $false -Choice 'yes'
Assert-True (-not $nonInteractive.Approved) 'Non-interactive input approved a WSL installation.'
$approved = Get-SgWslInstallPlan -State $absent -Interactive $true -Choice 'yes'
Assert-True ($approved.Approved -and (($approved.Arguments -join ' ') -eq '--install -d Ubuntu --no-launch')) 'WSL approval did not produce the closed official command.'

$elevationCapture = [pscustomobject]@{ File=''; Arguments=@() }
$wslInstalled = Invoke-SgWslInstall -Plan $approved -ElevatedRunner {
    param($File,$Arguments)
    $elevationCapture.File = $File
    $elevationCapture.Arguments = @($Arguments)
    New-TestResult 0
}
Assert-True ($wslInstalled.Status -eq 'reinspection_required' -and $wslInstalled.Changed) 'A successful WSL install did not require safe reinspection.'
Assert-True ($elevationCapture.File -eq 'wsl.exe' -and (($elevationCapture.Arguments -join ' ') -eq '--install -d Ubuntu --no-launch')) 'WSL execution escaped the fixed elevated operation.'

$wslRestart = Invoke-SgWslInstall -Plan $approved -ElevatedRunner { param($File,$Arguments) New-TestResult 3010 }
Assert-True ($wslRestart.Status -eq 'pending_restart') 'WSL exit 3010 was not classified as pending_restart.'
$wslCancelled = Invoke-SgWslInstall -Plan $approved -ElevatedRunner { param($File,$Arguments) New-TestResult -1 'cancelled' }
Assert-True ($wslCancelled.Status -eq 'error' -and -not $wslCancelled.Changed) 'UAC cancellation was not reported as a non-change.'

$blockedTurso = Get-SgTursoCloudState -WslState $absent -Runner { throw 'Turso probe must not run while WSL is absent.' }
Assert-True ($blockedTurso.Status -eq 'blocked_by_wsl') 'Turso did not remain independently gated by WSL readiness.'

$tursoAbsent = Get-SgTursoCloudState -WslState $ready -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 127 '' }
Assert-True ($tursoAbsent.Status -eq 'absent') 'Missing Turso was not classified as absent.'
$tursoReady = Get-SgTursoCloudState -WslState $ready -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 0 'turso version 1.0.32' }
Assert-True ($tursoReady.Status -eq 'ready') 'The pinned Turso version was not classified as ready.'
$tursoOutdated = Get-SgTursoCloudState -WslState $ready -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 0 'turso version 1.0.31' }
Assert-True ($tursoOutdated.Status -eq 'outdated') 'A different Turso version was accepted.'

$blockedPlan = Get-SgTursoCloudInstallPlan -WslState $absent -TursoState $blockedTurso -Interactive $true -Choice 'yes'
Assert-True (-not $blockedPlan.Approved) 'Turso installation was approved without ready WSL.'
$tursoPlan = Get-SgTursoCloudInstallPlan -WslState $ready -TursoState $tursoAbsent -Interactive $true -Choice 'yes'
Assert-True ($tursoPlan.Approved -and $tursoPlan.Action -eq 'install_turso_cloud') 'Separate Turso consent did not produce an install plan.'

$tursoCapture = [pscustomobject]@{ File=''; Arguments=@(); Input='' }
$tursoInstalled = Invoke-SgTursoCloudInstall -Plan $tursoPlan -WslState $ready -InstallerPath $installer -Runner {
    param($File,$Arguments,$TimeoutSeconds,$InputText)
    $tursoCapture.File = $File
    $tursoCapture.Arguments = @($Arguments)
    $tursoCapture.Input = $InputText
    New-TestResult 0 'Turso Cloud CLI 1.0.32 installed. Authentication was not started.'
}
Assert-True ($tursoInstalled.Status -eq 'ready') 'Verified Turso installation was not reported ready.'
Assert-True ($tursoCapture.File -eq 'wsl.exe' -and (($tursoCapture.Arguments -join ' ') -eq '-d Ubuntu --exec /bin/bash -s --')) 'Turso execution escaped the fixed WSL Bash stdin boundary.'
Assert-True ($tursoCapture.Input -match 'TURSO_VERSION="1\.0\.32"') 'The bundled verified installer was not sent through bounded stdin.'
Assert-True ($tursoCapture.Input -notmatch 'turso\s+auth|turso\s+db|turso\s+shell|latest') 'The bundled installer contains an authentication, database, shell, or unpinned latest action.'

$noProof = Invoke-SgTursoCloudInstall -Plan $tursoPlan -WslState $ready -InstallerPath $installer -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 0 'done' }
Assert-True ($noProof.Status -eq 'error') 'Turso installation accepted success without pinned-version proof.'

Write-Host 'WSL and Turso Windows contracts passed.' -ForegroundColor Green
