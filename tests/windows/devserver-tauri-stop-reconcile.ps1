$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$modulePath = Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('sg-tauri-stop-reconcile-' + [guid]::NewGuid().ToString('N'))
$targetDirectory = Join-Path $fixture 'src-tauri\target\debug'
try {
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    $cargoManifest = @'
[package]
name = "app"
version = "0.1.0"

[[bin]]
name = "app"
path = "src/main.rs"
'@
    Set-Content -LiteralPath (Join-Path $fixture 'src-tauri\Cargo.toml') -Value $cargoManifest -Encoding UTF8
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer

    & $module {
        param($ProjectPath,$TargetDirectory)
        $appPath = [IO.Path]::GetFullPath((Join-Path $TargetDirectory 'app.exe'))
        $otherAppPath = 'C:\OtherProject\src-tauri\target\debug\app.exe'
        $script:processes = @(
            [pscustomobject]@{ProcessId=101;ParentProcessId=10;ExecutablePath=$appPath},
            [pscustomobject]@{ProcessId=102;ParentProcessId=101;ExecutablePath='C:\Program Files\WebView2\msedgewebview2.exe'},
            [pscustomobject]@{ProcessId=201;ParentProcessId=20;ExecutablePath=$otherAppPath}
        )
        $script:stopped = @()
        function Get-CimInstance { param($ClassName,$Property,$ErrorAction) @($script:processes) }
        function Stop-Process { param($Id,[switch]$Force,$ErrorAction) $script:stopped += [int]$Id; $script:processes = @($script:processes | Where-Object { [int]$_.ProcessId -ne [int]$Id }) }
        $entry = [pscustomobject]@{kind='tauri';path=$ProjectPath;launchPath=$ProjectPath;tauriDevice='windows';port=3006;status='running';pid=4242;startTimeUtc='2026-10-30T09:00:00Z'}

        $expected = @(Get-SgTauriWindowsExecutablePaths $entry)
        if ($expected.Count -ne 1 -or $appPath -notin $expected) { throw "Cargo binary path was not resolved exactly: $($expected -join ', ')" }
        $owned = @(Get-SgOwnedTauriWindowsPids $entry)
        if ($owned.Count -ne 1 -or $owned[0] -ne 101) { throw "Tauri ownership matched a non-project executable: $($owned -join ', ')" }
        if (-not (Stop-SgOwnedTauriWindows $entry)) { throw 'The project Tauri executable was not stopped.' }
        if (101 -notin $script:stopped -or 102 -notin $script:stopped -or 201 -in $script:stopped) { throw "Tauri stop did not kill its process tree in isolation: $($script:stopped -join ', ')" }
        if (@($script:processes | Where-Object { [int]$_.ProcessId -eq 201 }).Count -ne 1) { throw 'Stopping this Tauri app changed another project app.exe.' }

        $script:processes += [pscustomobject]@{ProcessId=301;ParentProcessId=30;ExecutablePath=$appPath}
        function Test-SgProcessIdentity { param($Entry) $false }
        function Test-SgPortAvailable { param($Port) $true }
        if (Wait-SgManagedExtinction $entry 0) { throw 'Tauri extinction passed while the project app.exe remained alive.' }
        [void](Stop-SgOwnedTauriWindows $entry)
        if (-not (Wait-SgManagedExtinction $entry 0)) { throw 'Tauri extinction did not pass after its exact project app.exe stopped.' }
    } $fixture $targetDirectory

    & $module {
        param($ProjectPath)
        $script:registry = [pscustomobject]@{schemaVersion=1;projects=@([pscustomobject]@{
            name='fixture';path=$ProjectPath;launchPath=$ProjectPath;rootPath=$ProjectPath;kind='tauri';tauriDevice='windows';port=3006
            status='error';pid=4242;startTimeUtc=[DateTime]::UtcNow.AddSeconds(-20).ToString('o');lastError='Managed process is alive, but its local service port is not responding.'
        })}
        $script:httpReady = $true
        $script:httpCalls = 0
        function Read-SgRegistry { param($Config,[switch]$SkipMigration) $script:registry }
        function Invoke-SgRegistryMutation { param($Config,[scriptblock]$Mutation,[switch]$SkipProjection) if ($Mutation) { & $Mutation $script:registry }; $script:registry }
        function Get-SgProcessSnapshotMap { param($Pids,$CommandLinePids) @{} }
        function Test-SgProcessIdentity { param($Entry,$SnapshotByPid) [int]$Entry.pid -eq 4242 }
        function Get-SgListeningTcpPortSet { @{} }
        function Test-SgHttpReady { param($Port) $script:httpCalls++; return $script:httpReady }

        $reconciled = @((Reconcile-SgRegistry ([pscustomobject]@{})).projects)[0]
        if ($reconciled.status -ne 'running' -or $reconciled.lastError) { throw 'A ready HTTP endpoint did not take precedence over an absent TCP listener snapshot.' }
        if ($script:httpCalls -ne 1) { throw "HTTP readiness was not probed once per reconciliation: $($script:httpCalls)" }

        $script:registry.projects[0].status='error'
        $script:registry.projects[0].startTimeUtc=[DateTime]::UtcNow.AddSeconds(-20).ToString('o')
        $script:httpReady=$false
        [void](Reconcile-SgRegistry ([pscustomobject]@{}))
        if ($script:registry.projects[0].status -ne 'starting') { throw 'A transient startup probe error did not regain the bounded startup grace.' }

        $script:httpReady=$true
        $reconciled = @((Reconcile-SgRegistry ([pscustomobject]@{})).projects)[0]
        if ($reconciled.status -ne 'running') { throw 'A later successful HTTP probe did not recover the session from its transient error.' }

        $script:registry.projects[0].status='error'
        $script:registry.projects[0].startTimeUtc=[DateTime]::UtcNow.AddSeconds(-1900).ToString('o')
        $script:httpReady=$false
        [void](Reconcile-SgRegistry ([pscustomobject]@{}))
        if ($script:registry.projects[0].status -ne 'error') { throw 'An expired startup grace concealed an unavailable service.' }
    } $fixture

    Write-Output 'Windows Tauri process cleanup and readiness reconciliation: PASS'
} finally {
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    if ([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()), [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
    }
}
