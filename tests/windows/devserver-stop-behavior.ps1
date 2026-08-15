$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        $script:entry = [pscustomobject]@{name='test';path='C:\workspace\test';kind='vite';port=3000;status='stopped';pid=0;startTimeUtc=$null;lastError=$null}
        $config = [pscustomobject]@{}
        function ConvertTo-SgCanonicalPath { 'C:\workspace\test' }
        function Read-SgRegistry { [pscustomobject]@{schemaVersion=1;projects=@($script:entry)} }
        function Test-SgProcessIdentity { [int]$script:entry.pid -gt 0 }
        function Stop-SgOwnedFlutterListener { $false }
        function Stop-SgProcessTree { }
        function Invoke-SgRegistryMutation { param($Config,$Mutation); $registry=Read-SgRegistry; & $Mutation $registry; $registry }
        $warnings = @(); function Write-SgWarn { param($Message); $script:warnings += $Message }
        if (Stop-SgProject $config $script:entry.path) { throw 'Stopping an already stopped entry reported a process stop.' }
        if ($warnings.Count -ne 0) { throw 'Stopping an already stopped entry emitted a warning.' }
        $script:entry.status='running'; $script:entry.pid=77
        if (-not (Stop-SgProject $config $script:entry.path)) { throw 'Running process stop was not reported.' }
    }
    Write-Host 'Windows DevServer idempotent stop: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
