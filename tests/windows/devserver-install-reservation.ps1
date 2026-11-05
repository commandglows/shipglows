$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-install-reservation-' + [guid]::NewGuid().ToString('N'))
$job = $null
try {
    $runtime = Join-Path $fixture 'runtime'; $project = Join-Path $fixture 'app'
    New-Item -ItemType Directory -Path $runtime,$project -Force | Out-Null
    $config = [pscustomobject]@{ RuntimeDirectory=$runtime; RegistryPath=(Join-Path $runtime 'registry.json'); LockPath=(Join-Path $runtime 'registry.lock'); PortStart=32260; PortEnd=32269 }
    [pscustomobject]@{schemaVersion=1;projects=@([pscustomobject]@{name='app';path=$project;launchPath=$project;kind='vite';port=0;status='stopped';pid=0})} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer
    $ready = Join-Path $fixture 'ready'; $resume = Join-Path $fixture 'resume'
    # Another CLI holds the reservation while dependency setup blocks, before a server PID exists.
    # Backdate the reservation instead of making the regression wait five real minutes.
    $job = Start-Job {
        param($ModulePath,$Config,$Project,$Ready,$Resume)
        $ErrorActionPreference = 'Stop'
        Import-Module $ModulePath -Force -DisableNameChecking
        $reservation = Reserve-SgProjectPort $Config $Project -Target 'web-server'
        & (Get-Module ShipGlows.DevServer) {
            param($c,$p)
            Invoke-SgRegistryMutation $c {
                param($data)
                $entry = @($data.projects | Where-Object path -eq $p)[0]
                foreach ($state in @($entry)+@($entry.sessions)) { $state.reservationTimeUtc = [DateTime]::UtcNow.AddMinutes(-20).ToString('o') }
            } | Out-Null
        } $Config $Project
        Set-Content -LiteralPath $Ready -Value $reservation.Token
        $deadline = [DateTime]::UtcNow.AddSeconds(45)
        while (-not (Test-Path -LiteralPath $Resume)) {
            if ([DateTime]::UtcNow -gt $deadline) { throw 'Fixture setup wait timed out.' }
            Start-Sleep -Milliseconds 100
        }
        Set-SgReservationState $Config $Project $reservation.Token 'starting'
    } -ArgumentList $modulePath,$config,$project,$ready,$resume
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    while (-not (Test-Path -LiteralPath $ready)) {
        if ($job.State -eq 'Failed') { Receive-Job $job -ErrorAction Stop }
        if ([DateTime]::UtcNow -gt $deadline) { throw 'Fixture reservation was not ready.' }
        Start-Sleep -Milliseconds 100
    }
    $token = (Get-Content -LiteralPath $ready -Raw).Trim()
    $entry = @((Reconcile-SgRegistry $config).projects)[0]
    if ($entry.status -ne 'reserved' -or $entry.reservationToken -ne $token) { throw 'Status erased the reservation while dependency setup was still active.' }
    # The same freshness decision must protect a target from a sibling's reservation cleanup.
    Reserve-SgProjectPort $config $project -NoPort -Target 'windows' | Out-Null
    $session = Get-SgEntrySession @((Read-SgRegistry $config).projects)[0] 'web-server'
    if ($session.reservationToken -ne $token) { throw 'Another target erased the active installation reservation.' }
    Set-Content -LiteralPath $resume -Value 'continue'
    $job | Wait-Job -Timeout 15 | Out-Null
    if ($job.State -ne 'Completed') { Receive-Job $job -ErrorAction Stop; throw 'Installation could not commit its reservation.' }
    Receive-Job $job -ErrorAction Stop
    # With the owner gone, the expired reservation becomes reclaimable.
    $entry = @((Reconcile-SgRegistry $config).projects)[0]
    $session = Get-SgEntrySession $entry 'web-server'
    if ($session.status -ne 'stopped' -or $session.reservationToken -or $session.reservationOwner) { throw 'An abandoned expired installation kept its reservation.' }
    & $module {
        param($c,$p)
        # A reused PID with a different start time cannot preserve an expired lease.
        $reservation = Reserve-SgProjectPort $c $p -NoPort -Target 'web-server'
        Invoke-SgRegistryMutation $c {
            param($data)
            $entry = @($data.projects)[0]
            $session = Get-SgEntrySession $entry 'web-server'
            $session.reservationTimeUtc = [DateTime]::UtcNow.AddMinutes(-20).ToString('o')
            $session.reservationOwner.startTimeUtc = [DateTime]::UtcNow.AddDays(-1).ToString('o')
        } | Out-Null
        $entry = @((Reconcile-SgRegistry $c).projects)[0]
        $session = Get-SgEntrySession $entry 'web-server'
        if ($session.status -ne 'stopped' -or $session.reservationToken) { throw 'A reused PID preserved an expired reservation.' }

        # Older registries without an owner retain the existing bounded grace period.
        $reservation = Reserve-SgProjectPort $c $p -NoPort -Target 'web-server'
        Invoke-SgRegistryMutation $c {
            param($data)
            $session = Get-SgEntrySession @($data.projects)[0] 'web-server'
            $session.reservationOwner = $null
        } | Out-Null
        $entry = @((Reconcile-SgRegistry $c).projects)[0]
        $session = Get-SgEntrySession $entry 'web-server'
        if ($session.status -ne 'reserved' -or $session.reservationToken -ne $reservation.Token) { throw 'A fresh legacy reservation lost its grace period.' }
        Invoke-SgRegistryMutation $c {
            param($data)
            $session = Get-SgEntrySession @($data.projects)[0] 'web-server'
            $session.reservationTimeUtc = [DateTime]::UtcNow.AddMinutes(-20).ToString('o')
        } | Out-Null
        $session = Get-SgEntrySession @((Reconcile-SgRegistry $c).projects)[0] 'web-server'
        if ($session.status -ne 'stopped' -or $session.reservationToken) { throw 'An expired legacy reservation was not released.' }

        $reservation = Reserve-SgProjectPort $c $p -NoPort -Target 'web-server'
        Release-SgProjectPort $c $p $reservation.Token 'fixture setup failed'
        $session = Get-SgEntrySession @((Read-SgRegistry $c).projects)[0] 'web-server'
        if ($session.status -ne 'error' -or $session.reservationOwner -or $session.reservationToken) { throw 'Setup failure did not release its owner and token.' }

        $reservation = Reserve-SgProjectPort $c $p -NoPort -Target 'web-server'
        Set-SgReservationState $c $p $reservation.Token 'running'
        $session = Get-SgEntrySession @((Read-SgRegistry $c).projects)[0] 'web-server'
        if ($session.reservationOwner -or $session.reservationToken) { throw 'A completed launch retained its reservation owner.' }
    } $config $project
    Write-Host 'Windows DevServer installation reservation across concurrent status: OK'
} finally {
    if ($job) { $job | Stop-Job -ErrorAction SilentlyContinue; $job | Remove-Job -Force -ErrorAction SilentlyContinue }
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
