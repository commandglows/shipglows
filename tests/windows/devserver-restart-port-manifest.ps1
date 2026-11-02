$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Targeted regressions: (1) a restarted surface waits (bounded) for its own port to be released,
# (2) the browser-extension manifest is read with write sharing and retried while a bundler writes it.
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-restart-port-manifest-{0}" -f [guid]::NewGuid().ToString('N'))
$listeners = New-Object System.Collections.Generic.List[object]
function New-FreePort {
    $probe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0); $probe.Start()
    $port = ([Net.IPEndPoint]$probe.LocalEndpoint).Port; $probe.Stop(); return $port
}
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer

    # --- 1. Port release wait ---
    # A listener that goes away after ~1.5 s: the wait must return true, after the release and not before.
    $port = New-FreePort
    $ready = Join-Path $fixture 'holder.ready'
    $holder = Start-Job { param($p,$r) $l=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,$p); $l.Start(); Set-Content -LiteralPath $r -Value 'ready'; Start-Sleep -Milliseconds 4000; $l.Stop() } -ArgumentList $port,$ready
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while (-not (Test-Path -LiteralPath $ready)) { if ($sw.ElapsedMilliseconds -gt 30000) { throw "Holder job never took the port: $(Receive-Job $holder -ErrorAction SilentlyContinue 2>&1)" }; Start-Sleep -Milliseconds 50 }
    $sw.Restart()
    if (& $module { param($p) Test-SgPortAllocatable $p } $port) { throw 'The held port was reported allocatable.' }
    $released = & $module { param($p) Wait-SgPortReleased $p } $port
    if (-not $released) { throw 'Wait-SgPortReleased did not observe the release of a port freed after ~1.5 s.' }
    if ($sw.ElapsedMilliseconds -lt 300) { throw 'Wait-SgPortReleased returned before the port was released.' }
    $holder | Wait-Job | Remove-Job -Force

    # A port that stays held is never reported free: bounded wait, then false, and the reservation keeps its error with the holder.
    $port = New-FreePort
    $held = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port); $held.Start(); $listeners.Add($held)
    & $module { $script:SgPortReleaseTimeoutMs = 700 }
    $sw.Restart()
    $stillHeld = & $module { param($p) Wait-SgPortReleased $p } $port
    if ($stillHeld) { throw 'A port still held by a listener was reported released.' }
    if ($sw.ElapsedMilliseconds -lt 600 -or $sw.ElapsedMilliseconds -gt 4000) { throw "The port wait was not bounded by its timeout ($($sw.ElapsedMilliseconds) ms)." }

    $runtime = Join-Path $fixture 'runtime'; $one = Join-Path $fixture 'one'
    New-Item -ItemType Directory -Path $runtime,$one -Force | Out-Null
    $config = [pscustomobject]@{ RuntimeDirectory=$runtime; RegistryPath=(Join-Path $runtime 'registry.json'); LockPath=(Join-Path $runtime 'registry.lock'); PortStart=32170; PortEnd=32179 }
    [pscustomobject]@{schemaVersion=1;projects=@([pscustomobject]@{name='one';path=$one;launchPath=$one;kind='vite';port=0;status='stopped';pid=0})} | ConvertTo-Json -Depth 10 | Set-Content $config.RegistryPath -Encoding UTF8
    $message = ''
    try { Reserve-SgProjectPort $config $one $port $true | Out-Null } catch { $message = $_.Exception.Message }
    if ($message -notlike "Configured port $port is unavailable*in use by a listening process*held by*pid*") { throw "Held configured port error lost its holder: $message" }
    $held.Stop(); $listeners.Clear()
    & $module { $script:SgPortReleaseTimeoutMs = 10000 }

    # --- 2. Manifest read ---
    & $module { $script:SgManifestReadTimeoutMs = 2500 }
    $manifestPath = Join-Path $fixture 'manifest.json'
    $valid = '{"manifest_version":3,"name":"ext","version":"1.0.0"}'
    Set-Content -LiteralPath $manifestPath -Value $valid -Encoding UTF8 -NoNewline

    # Writer holding the file open for reading+writing (FileShare.ReadWrite): readable at once.
    $writer = [IO.File]::Open($manifestPath, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::ReadWrite)
    try {
        $manifest = & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath
        if ($manifest.name -ne 'ext') { throw 'A manifest opened by a writer with sharing was not read.' }
    } finally { $writer.Dispose() }

    # Exclusive lock released after ~800 ms: the read retries and succeeds.
    $locker = Start-Job { param($f) $s=[IO.File]::Open($f,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None); Start-Sleep -Milliseconds 800; $s.Dispose() } -ArgumentList $manifestPath
    Start-Sleep -Milliseconds 300
    $manifest = & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath
    $locker | Wait-Job | Remove-Job -Force
    if ($manifest.version -ne '1.0.0') { throw 'A locked manifest was not retried until released.' }

    # Empty then truncated JSON completed ~700 ms later: the read retries and succeeds.
    Set-Content -LiteralPath $manifestPath -Value '{"manifest_version":3,"na' -Encoding UTF8 -NoNewline
    $completer = Start-Job { param($f,$v) Start-Sleep -Milliseconds 700; Set-Content -LiteralPath $f -Value $v -Encoding UTF8 -NoNewline } -ArgumentList $manifestPath,$valid
    $manifest = & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath
    $completer | Wait-Job | Remove-Job -Force
    if ($manifest.name -ne 'ext') { throw 'A truncated manifest was not retried until complete.' }
    Set-Content -LiteralPath $manifestPath -Value '' -Encoding UTF8 -NoNewline
    $completer = Start-Job { param($f,$v) Start-Sleep -Milliseconds 700; Set-Content -LiteralPath $f -Value $v -Encoding UTF8 -NoNewline } -ArgumentList $manifestPath,$valid
    $manifest = & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath
    $completer | Wait-Job | Remove-Job -Force
    if ($manifest.name -ne 'ext') { throw 'An empty manifest was not retried until written.' }

    # Still invalid after the delay: reported as invalid; existing checks keep working.
    & $module { $script:SgManifestReadTimeoutMs = 400 }
    Set-Content -LiteralPath $manifestPath -Value '{"manifest_version":3,"na' -Encoding UTF8 -NoNewline
    $invalid = ''
    try { & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath | Out-Null } catch { $invalid = $_.Exception.Message }
    if ($invalid -notlike "Invalid browser extension manifest*") { throw "A permanently truncated manifest was not reported invalid: $invalid" }
    Set-Content -LiteralPath $manifestPath -Value '{"manifest_version":3,"name":"","version":"1"}' -Encoding UTF8 -NoNewline
    $nameless = ''
    try { & $module { param($f) Read-SgBrowserExtensionManifest $f } $manifestPath | Out-Null } catch { $nameless = $_.Exception.Message }
    if ($nameless -notlike '*name, version, and manifest_version*') { throw 'The name/version/manifest_version check was lost.' }

    Write-Host 'Windows DevServer restart port wait and manifest read: OK'
} finally {
    foreach ($l in $listeners) { try { $l.Stop() } catch { } }
    Get-Job -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
