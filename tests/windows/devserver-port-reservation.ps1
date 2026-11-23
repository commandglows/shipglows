$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-port-reservation-{0}" -f [guid]::NewGuid().ToString('N'))
$runtime = Join-Path $fixture 'runtime'; $one = Join-Path $fixture 'one'; $two = Join-Path $fixture 'two'
try {
    New-Item -ItemType Directory -Path $runtime,$one,$two -Force | Out-Null
    $config = [pscustomobject]@{ RuntimeDirectory=$runtime; RegistryPath=(Join-Path $runtime 'registry.json'); LockPath=(Join-Path $runtime 'registry.lock'); PortStart=32160; PortEnd=32169 }
    [pscustomobject]@{schemaVersion=1;projects=@(
        [pscustomobject]@{name='one';path=$one;launchPath=$one;kind='vite';port=0;status='stopped';pid=0},
        [pscustomobject]@{name='two';path=$two;launchPath=$two;kind='vite';port=0;status='stopped';pid=0}
    )} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    $configJson = $config | ConvertTo-Json -Compress
    $jobScript = { param($Module,$ConfigJson,$Path) Import-Module $Module -Force -DisableNameChecking; $c=$ConfigJson|ConvertFrom-Json; (Reserve-SgProjectPort $c $Path).Port }
    $jobs = @(Start-Job $jobScript -ArgumentList $modulePath,$configJson,$one; Start-Job $jobScript -ArgumentList $modulePath,$configJson,$two)
    $ports = @($jobs | Wait-Job | Receive-Job); $jobs | Remove-Job -Force
    if ($ports.Count -ne 2 -or $ports[0] -eq $ports[1]) { throw "Concurrent reservations collided: $($ports -join ',')." }

    Import-Module $modulePath -Force -DisableNameChecking
    $twoEntry = (Read-SgRegistry $config).projects | Where-Object path -eq $two | Select-Object -First 1
    $collision = $false
    try { Reserve-SgProjectPort $config $one $twoEntry.port $true | Out-Null } catch { $collision = $_.Exception.Message -like 'Configured port * is unavailable: reserved by another registered surface*' }
    if (-not $collision) { throw 'An explicit reserved-port collision did not fail.' }
    $oneEntry = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    Release-SgProjectPort $config $one $oneEntry.reservationToken 'setup failed'
    $released = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    if ($released.status -ne 'error' -or $released.reservationToken -or $released.port -ne $oneEntry.port) { throw 'Failed launch did not release its reservation while preserving the surface port.' }
    $invalidPort = $false
    try { Reserve-SgProjectPort $config $one 70000 $true | Out-Null } catch { $invalidPort = $_.Exception.Message -like 'Requested port must be*' }
    if (-not $invalidPort) { throw 'An out-of-range requested port was accepted.' }

    # Native Flutter launches reserve no HTTP port but keep the surface port for a later Web launch.
    $native = Reserve-SgProjectPort $config $one -NoPort -PreservePort
    $nativeEntry = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    if ($native.Port -ne $oneEntry.port -or $nativeEntry.port -ne $oneEntry.port -or $nativeEntry.reservationToken -ne $native.Token) { throw 'A native Flutter reservation dropped the persistent surface port.' }

    # A concurrent reconciliation clearing the token must not fail the launch that owns the live process.
    $startTime = '2026-10-14T08:00:00.0000000Z'
    $module = Get-Module ShipGlows.DevServer
    & $module { param($c,$p,$t) Invoke-SgRegistryMutation $c { param($data); $item=@($data.projects|Where-Object{$_.path-eq$p})[0]; foreach($state in @($item)+@($item.sessions)){$state.status='starting'; $state.pid=4242; $state|Add-Member -NotePropertyName startTimeUtc -NotePropertyValue $t -Force; $state.reservationToken=$null; $state.reservationTimeUtc=$null} } | Out-Null } $config $one $startTime
    Set-SgReservationState $config $one $native.Token 'running' ([pscustomobject]@{ pid=4242; startTimeUtc=$startTime })
    $committed = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    if ($committed.status -ne 'running' -or $committed.pid -ne 4242) { throw 'A launch whose token was cleared by reconciliation was not committed by process identity.' }
    $foreign = $false
    try { Set-SgReservationState $config $one $native.Token 'running' ([pscustomobject]@{ pid=4243; startTimeUtc=$startTime }) } catch { $foreign = $_.Exception.Message -like 'Port reservation was lost*' }
    if (-not $foreign) { throw 'A launch with a different process identity reclaimed a lost reservation.' }

    # Reconciliation keeps the token of a live launch that is still starting.
    & $module { param($c,$p) Invoke-SgRegistryMutation $c { param($data); $item=@($data.projects|Where-Object{$_.path-eq$p})[0]; $item.kind='flutter-web'; foreach($state in @($item)+@($item.sessions)){$state|Add-Member -NotePropertyName flutterDeviceId -NotePropertyValue 'windows' -Force; $state.status='starting'; $state.reservationToken='live-start-token'; $state.reservationTimeUtc=[DateTime]::UtcNow.AddMinutes(-20).ToString('o')} } | Out-Null } $config $one
    & $module {
        param($c)
        function Get-SgProcessSnapshotMap { @{} }
        function Test-SgProcessIdentity { param($Entry) [int]$Entry.pid -eq 4242 }
        function Get-SgFlutterSupervisorState { $null }
        Reconcile-SgRegistry $c | Out-Null
    } $config
    $reconciled = (Read-SgRegistry $config).projects | Where-Object path -eq $one | Select-Object -First 1
    if ($reconciled.status -ne 'starting' -or $reconciled.reservationToken -ne 'live-start-token') { throw 'Reconciliation cleared the reservation of a live launch that is still starting.' }
    # A Windows dynamic (ephemeral) TCP range that overlaps the managed range lets any port-0 bind
    # (Dart DDS, Flutter debug services) take a managed port; it is detected in either locale.
    $french = @('', 'Plage de ports dynamique du protocole tcp', '-----------------', "Port de d$([char]0xE9)marrage   : 1024", "Nombre de ports$([char]0xA0)    : 13977", '')
    $english = @('Protocol tcp Dynamic Port Range', '---------------------------------', 'Start Port      : 49152', 'Number of Ports : 16384')
    $frenchRange = ConvertFrom-SgDynamicPortOutput $french; $englishRange = ConvertFrom-SgDynamicPortOutput $english
    if ($frenchRange.Start -ne 1024 -or $frenchRange.End -ne 15000 -or $englishRange.Start -ne 49152 -or $englishRange.End -ne 65535 -or $null -ne (ConvertFrom-SgDynamicPortOutput @('garbage'))) { throw "The netsh dynamic port range was misread: $($frenchRange | ConvertTo-Json -Compress) $($englishRange | ConvertTo-Json -Compress)" }
    $overlap = Get-SgDynamicPortOverlap 3000 3100 $frenchRange
    if (-not $overlap -or $overlap.Start -ne 3000 -or $overlap.End -ne 3100 -or $overlap.Command -cne 'netsh int ipv4 set dynamicport tcp start=49152 num=16384; netsh int ipv6 set dynamicport tcp start=49152 num=16384' -or $null -ne (Get-SgDynamicPortOverlap 3000 3100 $englishRange) -or $null -ne (Get-SgDynamicPortOverlap 3000 3100 $null)) { throw 'The overlap between the Windows dynamic range and the managed range was not reported with the fix.' }
    $holder = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 32168); $holder.Start()
    try {
        $module = Get-Module ShipGlows.DevServer
        $dynamicMessage = & $module {
            param($c,$p)
            function Get-SgDynamicPortRange { [pscustomobject]@{ Start=1024; Count=40000; End=41023 } }
            try { Reserve-SgProjectPort $c $p 32168 $true | Out-Null; '' } catch { $_.Exception.Message }
        } $config $one
        if ($dynamicMessage -notmatch 'Configured port 32168 is unavailable: in use by a listening process' -or $dynamicMessage -notmatch 'Windows dynamic TCP port range 1024-41023' -or $dynamicMessage -notmatch [regex]::Escape('netsh int ipv4 set dynamicport tcp start=49152 num=16384; netsh int ipv6 set dynamicport tcp start=49152 num=16384')) { throw "A configured port taken inside the Windows dynamic range must name the cause and the fix: $dynamicMessage" }
        $report = & $module { param($c) function Get-SgDynamicPortRange { param([switch]$Refresh) [pscustomobject]@{ Start=1024; Count=13977; End=15000 } }; Get-SgPortExclusionReport $c } ([pscustomobject]@{ RuntimeDirectory=$runtime; RegistryPath=$config.RegistryPath; LockPath=$config.LockPath; PortStart=3000; PortEnd=3100 })
        if (-not $report.DynamicOverlap -or $report.DynamicRange.End -ne 15000) { throw 's doctor must report the dynamic range overlapping the managed range.' }
    } finally { $holder.Stop() }
    Write-Host 'Windows DevServer transactional port reservation: OK'
} finally {
    Get-Job -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
