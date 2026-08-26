Set-StrictMode -Version Latest

$script:SgTursoCloudVersion = '1.0.32'
$script:SgUbuntuDistributionPattern = '^Ubuntu(?:[-.][A-Za-z0-9._-]+)?$'

function New-SgProcessResult([int]$ExitCode,[string]$Output,[bool]$TimedOut=$false) {
    [pscustomobject]@{ ExitCode=$ExitCode; Output=$Output; TimedOut=$TimedOut }
}

function Invoke-SgWslTursoRunner {
    param([scriptblock]$Runner,[string]$File,[string[]]$Arguments,[int]$TimeoutSeconds=30,[string]$InputText='')
    if ($Runner) { return & $Runner $File $Arguments $TimeoutSeconds $InputText }
    return Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds -InputText $InputText
}

function ConvertFrom-SgWslText([string]$Text) {
    if ($null -eq $Text) { return '' }
    return ((($Text -replace "`0", '') -replace ([string][char]0xFEFF), '') -replace "`r", '').Trim()
}

function Get-SgWslDefaultUid {
    param([string]$Distribution,[scriptblock]$RegistrationReader)
    if ($RegistrationReader) { return & $RegistrationReader $Distribution }
    $root = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'
    if (-not (Test-Path -LiteralPath $root)) { return $null }
    foreach ($key in @(Get-ChildItem -LiteralPath $root -ErrorAction SilentlyContinue)) {
        $record = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction SilentlyContinue
        if ($record -and [string]$record.DistributionName -ieq $Distribution) {
            if ($null -eq $record.DefaultUid) { return [uint32]0 }
            return [uint32]$record.DefaultUid
        }
    }
    return $null
}

function Get-SgWslState {
    param(
        [string]$WslPath = 'wsl.exe',
        [scriptblock]$Runner,
        [scriptblock]$RegistrationReader
    )
    $status = Invoke-SgWslTursoRunner $Runner $WslPath @('--status') 20
    $listed = Invoke-SgWslTursoRunner $Runner $WslPath @('--list','--quiet') 20
    $combined = ConvertFrom-SgWslText (@($status.Output,$listed.Output) -join "`n")
    if ($status.TimedOut -or $listed.TimedOut) {
        return [pscustomobject]@{ Status='error'; Ready=$false; Distribution=''; Reason='WSL inspection timed out.'; NextAction='Retry the ShipGlows installer.' }
    }
    if ($combined -match '(?i)restart|reboot|red[eé]marr') {
        return [pscustomobject]@{ Status='pending_restart'; Ready=$false; Distribution=''; Reason='Windows reports that WSL needs a restart.'; NextAction='Restart Windows, then rerun ShipGlows.' }
    }
    if ($status.ExitCode -ne 0 -and $listed.ExitCode -ne 0) {
        if ($combined -match '(?i)not installed|n.?est pas install|non install|cannot find|introuvable|not recognized|pas reconnu|WSL.{0,40}install') {
            return [pscustomobject]@{ Status='absent'; Ready=$false; Distribution=''; Reason='WSL is not operational.'; NextAction='Choose the independent WSL installation when ShipGlows offers it.' }
        }
        return [pscustomobject]@{ Status='error'; Ready=$false; Distribution=''; Reason='WSL inspection failed without proving that WSL is absent.'; NextAction='Review the Windows WSL diagnostic, then retry ShipGlows.' }
    }
    $distributions = @((ConvertFrom-SgWslText $listed.Output) -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    $ubuntu = ''
    foreach ($distributionName in $distributions) {
        if ($distributionName -match '(?i)(Ubuntu(?:[-.][A-Za-z0-9._-]+)?)') { $ubuntu = [string]$Matches[1]; break }
    }
    if (-not $ubuntu) {
        return [pscustomobject]@{ Status='platform_only'; Ready=$false; Distribution=''; Reason='WSL responds, but no supported Ubuntu distribution is registered.'; NextAction='Choose the independent Ubuntu installation when ShipGlows offers it.' }
    }
    $distribution = $ubuntu
    $defaultUid = Get-SgWslDefaultUid -Distribution $distribution -RegistrationReader $RegistrationReader
    if ($null -eq $defaultUid -or [uint32]$defaultUid -eq 0) {
        return [pscustomobject]@{ Status='ubuntu_uninitialized'; Ready=$false; Distribution=$distribution; Reason='Ubuntu is installed but its non-root user is not initialized.'; NextAction="Launch $distribution once and create your Linux username and password, then rerun ShipGlows." }
    }
    return [pscustomobject]@{ Status='ready'; Ready=$true; Distribution=$distribution; Reason='WSL and the Ubuntu user are ready.'; NextAction='' }
}

function Get-SgWslInstallPlan {
    param([Parameter(Mandatory=$true)][object]$State,[bool]$Interactive,[string]$Choice='')
    if ($State.Status -in @('ready','ubuntu_uninitialized','pending_restart')) {
        return [pscustomobject]@{ Action='none'; Approved=$false; Reason=$State.Reason; Arguments=@() }
    }
    if ($State.Status -notin @('absent','platform_only')) {
        return [pscustomobject]@{ Action='none'; Approved=$false; Reason='WSL inspection did not produce an installable state.'; Arguments=@() }
    }
    $approved = $Interactive -and $Choice.Trim().ToLowerInvariant() -in @('y','yes')
    return [pscustomobject]@{
        Action = if ($approved) { 'install_wsl_ubuntu' } else { 'none' }
        Approved = $approved
        Reason = if ($approved) { 'Explicit WSL consent recorded.' } elseif (-not $Interactive) { 'Non-interactive runs never install WSL.' } else { 'WSL installation was declined.' }
        Arguments = @('--install','-d','Ubuntu','--no-launch')
    }
}

function Invoke-SgWslInstall {
    param([Parameter(Mandatory=$true)][object]$Plan,[scriptblock]$ElevatedRunner)
    if (-not $Plan.Approved -or $Plan.Action -ne 'install_wsl_ubuntu') {
        return [pscustomobject]@{ Status='not_run'; Changed=$false; Reason=$Plan.Reason; NextAction='' }
    }
    $result = if ($ElevatedRunner) {
        & $ElevatedRunner 'wsl.exe' @('--install','-d','Ubuntu','--no-launch')
    } else {
        try {
            $process = Start-Process -FilePath 'wsl.exe' -Verb RunAs -ArgumentList @('--install','-d','Ubuntu','--no-launch') -Wait -PassThru
            New-SgProcessResult ([int]$process.ExitCode) ''
        } catch { New-SgProcessResult -1 $_.Exception.Message }
    }
    if ($result.ExitCode -in @(1641,3010)) {
        return [pscustomobject]@{ Status='pending_restart'; Changed=$true; Reason='WSL requested a Windows restart.'; NextAction='Restart Windows, then rerun ShipGlows.' }
    }
    if ($result.ExitCode -ne 0) {
        return [pscustomobject]@{ Status='error'; Changed=$false; Reason="WSL installation was cancelled or failed (exit $($result.ExitCode))."; NextAction='Rerun ShipGlows when you want to retry WSL installation.' }
    }
    return [pscustomobject]@{ Status='reinspection_required'; Changed=$true; Reason='The official WSL installer completed.'; NextAction='Restart Windows if requested, then launch Ubuntu once to create your Linux username and password.' }
}

function Get-SgTursoCloudState {
    param([Parameter(Mandatory=$true)][object]$WslState,[string]$WslPath='wsl.exe',[scriptblock]$Runner)
    if (-not $WslState.Ready) {
        return [pscustomobject]@{ Status='blocked_by_wsl'; Ready=$false; Version=''; Reason="Turso waits because WSL is $($WslState.Status)."; NextAction=$WslState.NextAction }
    }
    if ([string]$WslState.Distribution -notmatch $script:SgUbuntuDistributionPattern) { throw 'Unsupported WSL distribution identity.' }
    $probe = Invoke-SgWslTursoRunner $Runner $WslPath @('-d',[string]$WslState.Distribution,'--exec','/bin/bash','-lc','if [ -x "$HOME/.local/bin/turso" ]; then "$HOME/.local/bin/turso" --version; else exit 127; fi') 30
    $output = ConvertFrom-SgWslText $probe.Output
    if ($probe.TimedOut) { return [pscustomobject]@{ Status='error'; Ready=$false; Version=''; Reason='Turso inspection timed out.'; NextAction='Retry the ShipGlows installer.' } }
    if ($probe.ExitCode -eq 127) { return [pscustomobject]@{ Status='absent'; Ready=$false; Version=''; Reason='Turso Cloud CLI is not installed in the Ubuntu user scope.'; NextAction='Choose the separate Turso installation when ShipGlows offers it.' } }
    if ($probe.ExitCode -ne 0) { return [pscustomobject]@{ Status='error'; Ready=$false; Version=''; Reason='Turso inspection failed inside Ubuntu.'; NextAction='Verify that Ubuntu launches normally, then retry.' } }
    if ($output -match "(^|[^0-9])$([regex]::Escape($script:SgTursoCloudVersion))([^0-9]|$)") {
        return [pscustomobject]@{ Status='ready'; Ready=$true; Version=$script:SgTursoCloudVersion; Reason='The pinned Turso Cloud CLI is ready.'; NextAction='' }
    }
    return [pscustomobject]@{ Status='outdated'; Ready=$false; Version=$output; Reason='A different Turso CLI version is installed.'; NextAction='Choose the separate Turso update when ShipGlows offers it.' }
}

function Get-SgTursoCloudInstallPlan {
    param([Parameter(Mandatory=$true)][object]$WslState,[Parameter(Mandatory=$true)][object]$TursoState,[bool]$Interactive,[string]$Choice='')
    if (-not $WslState.Ready) { return [pscustomobject]@{ Action='none'; Approved=$false; Reason='Turso cannot install until WSL is ready.' } }
    if ($TursoState.Ready) { return [pscustomobject]@{ Action='none'; Approved=$false; Reason='The pinned Turso Cloud CLI is already ready.' } }
    $approved = $Interactive -and $Choice.Trim().ToLowerInvariant() -in @('y','yes')
    return [pscustomobject]@{
        Action = if ($approved) { 'install_turso_cloud' } else { 'none' }
        Approved = $approved
        Reason = if ($approved) { 'Explicit Turso consent recorded.' } elseif (-not $Interactive) { 'Non-interactive runs never install Turso.' } else { 'Turso installation was declined.' }
    }
}

function Invoke-SgTursoCloudInstall {
    param(
        [Parameter(Mandatory=$true)][object]$Plan,
        [Parameter(Mandatory=$true)][object]$WslState,
        [Parameter(Mandatory=$true)][string]$InstallerPath,
        [string]$WslPath='wsl.exe',
        [scriptblock]$Runner
    )
    if (-not $Plan.Approved -or $Plan.Action -ne 'install_turso_cloud') {
        return [pscustomobject]@{ Status='not_run'; Changed=$false; Reason=$Plan.Reason }
    }
    if (-not $WslState.Ready -or [string]$WslState.Distribution -notmatch $script:SgUbuntuDistributionPattern) { throw 'Turso installation requires a ready supported Ubuntu distribution.' }
    if (-not (Test-Path -LiteralPath $InstallerPath -PathType Leaf)) { throw "Missing bundled Turso installer: $InstallerPath" }
    $scriptText = [IO.File]::ReadAllText($InstallerPath)
    if ($scriptText.Length -gt 32768) { throw 'Bundled Turso installer exceeds the allowed size.' }
    $result = Invoke-SgWslTursoRunner $Runner $WslPath @('-d',[string]$WslState.Distribution,'--exec','/bin/bash','-s','--') 300 $scriptText
    if ($result.TimedOut) { return [pscustomobject]@{ Status='error'; Changed=$false; Reason='Turso installation timed out.' } }
    if ($result.ExitCode -ne 0) { return [pscustomobject]@{ Status='error'; Changed=$false; Reason="Turso installation failed (exit $($result.ExitCode)): $($result.Output)" } }
    if ((ConvertFrom-SgWslText $result.Output) -notmatch "(^|[^0-9])$([regex]::Escape($script:SgTursoCloudVersion))([^0-9]|$)") {
        return [pscustomobject]@{ Status='error'; Changed=$false; Reason='Turso installer returned no pinned-version proof.' }
    }
    return [pscustomobject]@{ Status='ready'; Changed=$true; Reason="Turso Cloud CLI $script:SgTursoCloudVersion is ready; authentication was not started." }
}

Export-ModuleMember -Function Get-SgWslState,Get-SgWslInstallPlan,Invoke-SgWslInstall,Get-SgTursoCloudState,Get-SgTursoCloudInstallPlan,Invoke-SgTursoCloudInstall
