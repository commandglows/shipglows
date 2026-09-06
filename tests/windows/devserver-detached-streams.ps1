$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if($PSVersionTable.PSEdition-ne'Core'){
    Write-Host 'Windows detached live streams: skipped under bootstrap-only Windows PowerShell; run with the managed Core host.'
    exit 0
}
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Import-Module (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
$module=Get-Module ShipGlows.DevServer
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('sg-detached-streams-'+[guid]::NewGuid().ToString('N'))
$previousHost=$env:SHIPGLOWS_MANAGED_PWSH
$env:SHIPGLOWS_MANAGED_PWSH=(Get-Process -Id $PID).Path
$entry=$null
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $scriptPath=Join-Path $fixture 'server.js'
    [IO.File]::WriteAllText((Join-Path $fixture 'child.js'),"setInterval(() => {}, 1000);")
    [IO.File]::WriteAllText($scriptPath,"const c = require('child_process').spawn(process.execPath, ['child.js'], { detached: true, stdio: 'ignore', windowsHide: true }); c.unref(); console.log('stdout-live-marker'); console.error('stderr-live-marker');")
    $stdout=Join-Path $fixture 'stdout.log';$stderr=Join-Path $fixture 'stderr.log'
    $node=(Get-Command node.exe).Source
    $entry=& $module {param($node,$scriptPath,$fixture,$stdout,$stderr) Start-SgDetachedProcess $node @(('"'+$scriptPath+'"')) $fixture $stdout $stderr @{}} $node $scriptPath $fixture $stdout $stderr
    $deadline=(Get-Date).AddSeconds(20)
    do {
        $outText=if(Test-Path $stdout){& $module {param($p) Get-SgBoundedFileTail $p} $stdout}else{''}
        $errText=if(Test-Path $stderr){& $module {param($p) Get-SgBoundedFileTail $p} $stderr}else{''}
        if($outText-match'stdout-live-marker'-and$errText-match'stderr-live-marker'){break}
        Start-Sleep -Milliseconds 100
    }while((Get-Date)-lt$deadline)
    if($outText-notmatch'stdout-live-marker'-or$errText-notmatch'stderr-live-marker'){throw 'Detached stdout/stderr must be readable while the child is still running.'}
    if(-not(Get-Process -Id $entry.Id -ErrorAction SilentlyContinue)){throw 'Detached wrapper exited while its service was live.'}
    if($outText.Contains([string][char]0)-or$errText.Contains([string][char]0)){throw 'Detached UTF-8 logs contain NUL bytes.'}
    Write-Host 'Windows detached live stdout/stderr: OK'
} finally {
    if($entry){& $module {param($e) [void](Stop-SgManagedJob $e)} $entry;Wait-Process -Id $entry.Id -Timeout 5 -ErrorAction SilentlyContinue}
    $env:SHIPGLOWS_MANAGED_PWSH=$previousHost
    if([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()),[StringComparison]::OrdinalIgnoreCase)){Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue}
    Remove-Module ShipGlows.DevServer -Force
}
