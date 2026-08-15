$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
Import-Module $modulePath -Force -DisableNameChecking
try {
    $module = Get-Module ShipGlows.DevServer
    & $module {
        function Get-SgCommandPath { 'C:\flutter\bin\flutter.bat' }
        $spec = Get-SgLaunchSpec 'C:\workspace\app' 'flutter-web' 3010
        if ($spec.Interactive) { throw 'Flutter Web launch must be managed in the background.' }
        if (($spec.Arguments -join ' ') -notmatch 'flutter.*run.*web-server.*3010') { throw 'Flutter Web launch arguments changed unexpectedly.' }
    }
    $source = Get-Content -LiteralPath $modulePath -Raw
    if ($source -notmatch [regex]::Escape('-RedirectStandardOutput $out -RedirectStandardError $err -PassThru -WindowStyle Hidden')) { throw 'Managed launches must redirect logs and hide the process window.' }
    Write-Host 'Windows DevServer Flutter background launch: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
