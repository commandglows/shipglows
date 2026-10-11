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

$absentProbeCount = 0
$absentRunner = {
    param($File,$Arguments,$TimeoutSeconds,$InputText)
    $script:absentProbeCount++
    if (($Arguments -join ' ') -ne '--status') { throw 'A conclusive absent status must not launch a second WSL probe.' }
    New-TestResult 1 'WSL is not installed.'
}
$absent = Get-SgWslState -Runner $absentRunner
Assert-True ($absent.Status -eq 'absent') 'An unavailable WSL command was not classified as absent.'
Assert-True ($absentProbeCount -eq 1) 'Conclusive WSL absence did not return after the bounded status probe.'
$statusTimeout = Get-SgWslState -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult -1 'timeout' $true }
Assert-True ($statusTimeout.Status -eq 'error' -and $statusTimeout.Reason -match 'status') 'A timed-out WSL status probe was not distinguished.'
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
$noDistributionRunner = {
    param($File,$Arguments,$TimeoutSeconds,$InputText)
    New-TestResult -1 "Le Sous-système Windows pour Linux n'a aucune distribution installée. Utiliser wsl.exe --install <Distro>."
}
$localizedPlatformOnly = Get-SgWslState -Runner $noDistributionRunner
Assert-True ($localizedPlatformOnly.Status -eq 'platform_only') 'Localized WSL output without a distribution was incorrectly classified as an absent platform.'

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
Assert-True ([IO.Path]::GetFullPath($elevationCapture.File) -eq [IO.Path]::GetFullPath((Join-Path ([Environment]::SystemDirectory) 'wsl.exe')) -and (($elevationCapture.Arguments -join ' ') -eq '--install -d Ubuntu --no-launch')) 'WSL execution escaped the fixed elevated system operation.'

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
Assert-True ([IO.Path]::GetFullPath($tursoCapture.File) -eq [IO.Path]::GetFullPath((Join-Path ([Environment]::SystemDirectory) 'wsl.exe')) -and (($tursoCapture.Arguments -join ' ') -eq '-d Ubuntu --exec /bin/bash -s --')) 'Turso execution escaped the fixed WSL Bash stdin boundary.'
Assert-True ($tursoCapture.Input -match 'TURSO_VERSION="1\.0\.32"') 'The bundled verified installer was not sent through bounded stdin.'
Assert-True ($tursoCapture.Input -notmatch "`r") 'The WSL Bash installer input must use Linux line endings.'
Assert-True ($tursoCapture.Input -notmatch 'turso\s+auth|turso\s+db|turso\s+shell|latest') 'The bundled installer contains an authentication, database, shell, or unpinned latest action.'

$noProof = Invoke-SgTursoCloudInstall -Plan $tursoPlan -WslState $ready -InstallerPath $installer -Runner { param($File,$Arguments,$TimeoutSeconds,$InputText) New-TestResult 0 'done' }
Assert-True ($noProof.Status -eq 'error') 'Turso installation accepted success without pinned-version proof.'

$nativeWsl = Join-Path ([Environment]::SystemDirectory) 'wsl.exe'
if (Test-Path -LiteralPath $nativeWsl -PathType Leaf) {
    $null = & $nativeWsl --status 2>&1
    $nativeStatusCode = $LASTEXITCODE
    $null = & $nativeWsl --list --quiet 2>&1
    $nativeListCode = $LASTEXITCODE
    if ($nativeStatusCode -eq 0 -and $nativeListCode -eq 0) {
        Import-Module (Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1') -Force -DisableNameChecking
        $boundedStatus = Invoke-SgBoundedProcess -File $nativeWsl -Arguments @('--status') -TimeoutSeconds 20
        $boundedList = Invoke-SgBoundedProcess -File $nativeWsl -Arguments @('--list','--quiet') -TimeoutSeconds 20
        Assert-True ($boundedStatus.ExitCode -eq 0 -and $boundedList.ExitCode -eq 0) 'The bounded process transport must preserve WSL option tokens.'
        $liveWsl = Get-SgWslState
        Assert-True ($liveWsl.Status -ne 'error') 'The WSL detector must classify a working native WSL installation.'
        if ($liveWsl.Ready) {
            $stdinProbe = Invoke-SgBoundedProcess -File $nativeWsl -Arguments @('-d',$liveWsl.Distribution,'--exec','/bin/bash','-s','--') -TimeoutSeconds 30 -InputText "set -e`nprintf 'stdin-ok'`n"
            Assert-True ($stdinProbe.ExitCode -eq 0 -and $stdinProbe.Output -match 'stdin-ok') 'WSL Bash stdin must not receive a trailing Windows carriage return.'
        }
    }
}

Write-Host 'WSL and Turso Windows contracts passed.' -ForegroundColor Green
