$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
if ($PSVersionTable.PSEdition -ne 'Core') {
    Write-Host 'Windows DevServer detached integration: skipped under bootstrap-only Windows PowerShell; managed Core entry is covered by powershell-runtime.ps1.'
    exit 0
}

$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$entrypoint=Join-Path $root 'cli\windows\shipglows-devserver.ps1'
$modulePath=Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1'
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('sg-start-detach-'+[guid]::NewGuid().ToString('N'))
$surface=Join-Path $fixture 'workspace\site'
$isolatedLocalAppData=Join-Path $fixture 'localappdata'
$hostPowerShell=(Get-Process -Id $PID -ErrorAction Stop).Path
$runtimeManifest=Get-Content -LiteralPath (Join-Path $root 'cli\windows\ShipGlows.PowerShellRuntime.json') -Raw|ConvertFrom-Json
$expectedManagedPowerShell=[IO.Path]::GetFullPath((Join-Path $env:USERPROFILE ".shipglows\toolchains\powershell\$($runtimeManifest.version)\$($runtimeManifest.platform)\pwsh.exe"))
if([IO.Path]::GetFullPath($hostPowerShell)-ine$expectedManagedPowerShell){throw "Detached integration must run under the ShipGlows-managed PowerShell host: $expectedManagedPowerShell"}
$previousManagedPowerShell=$env:SHIPGLOWS_MANAGED_PWSH
$env:SHIPGLOWS_MANAGED_PWSH=$hostPowerShell
$port=0
$startProcess=$null

function New-SgCliProcess([string]$Action,[bool]$RedirectOutput=$true) {
    $info=New-Object Diagnostics.ProcessStartInfo
    $info.FileName=$hostPowerShell
    $info.Arguments="-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$entrypoint`" $Action -ProjectPath `"$surface`" -Port $port"
    $info.WorkingDirectory=$root
    $info.UseShellExecute=$false
    $info.CreateNoWindow=$true
    $info.RedirectStandardOutput=$RedirectOutput
    $info.RedirectStandardError=$RedirectOutput
    $info.EnvironmentVariables['SHIPGLOWS_WINDOWS_WORKSPACE']=(Join-Path $fixture 'workspace')
    $info.EnvironmentVariables['LOCALAPPDATA']=$isolatedLocalAppData
    $info.EnvironmentVariables['SHIPGLOWS_MANAGED_PWSH']=$hostPowerShell
    $process=New-Object Diagnostics.Process
    $process.StartInfo=$info
    [void]$process.Start()
    return $process
}

function Read-SgSharedBytes([string]$Path){
    $stream=New-Object IO.FileStream($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
    try{$memory=New-Object IO.MemoryStream;$stream.CopyTo($memory);return $memory.ToArray()}finally{$stream.Dispose();if($memory){$memory.Dispose()}}
}

try {
    New-Item -ItemType Directory -Path $surface,$isolatedLocalAppData,(Join-Path $surface 'vendor\vite') -Force|Out-Null
    Set-Content -LiteralPath (Join-Path $surface 'package.json') -Encoding UTF8 -Value '{"name":"sg-detach-fixture","version":"1.0.0","scripts":{"dev":"node server.js"},"devDependencies":{"vite":"file:vendor/vite"}}'
    Set-Content -LiteralPath (Join-Path $surface 'package-lock.json') -Encoding UTF8 -Value '{"name":"sg-detach-fixture","version":"1.0.0","lockfileVersion":3,"requires":true,"packages":{"":{"name":"sg-detach-fixture","version":"1.0.0","devDependencies":{"vite":"file:vendor/vite"}},"node_modules/vite":{"resolved":"vendor/vite","link":true},"vendor/vite":{"version":"1.0.0","dev":true}}}'
    Set-Content -LiteralPath (Join-Path $surface 'vendor\vite\package.json') -Encoding UTF8 -Value '{"name":"vite","version":"1.0.0"}'
    Set-Content -LiteralPath (Join-Path $surface 'server.js') -Encoding UTF8 -Value @'
const fs = require('fs');
const { spawn } = require('child_process');
const index = process.argv.indexOf('--port');
const port = Number(index >= 0 ? process.argv[index + 1] : process.env.PORT);
fs.writeFileSync('parent.pid', String(process.pid));
const child = spawn(process.execPath, ['child-server.js', String(port)], { detached: true, stdio: 'ignore', windowsHide: true });
child.unref();
console.error('stderr-readable-marker');
'@
    Set-Content -LiteralPath (Join-Path $surface 'child-server.js') -Encoding UTF8 -Value @'
const http = require('http');
const port = Number(process.argv[2]);
http.createServer((_request, response) => response.end('ready')).listen(port, '127.0.0.1');
'@
    $listener=[Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback,0);$listener.Start();$port=([Net.IPEndPoint]$listener.LocalEndpoint).Port;$listener.Stop()

    $clock=[Diagnostics.Stopwatch]::StartNew()
    $startProcess=New-SgCliProcess 'start'
    $stdoutTask=$startProcess.StandardOutput.ReadToEndAsync()
    $stderrTask=$startProcess.StandardError.ReadToEndAsync()
    $registryPath=Join-Path $isolatedLocalAppData 'ShipGlows\DevServer\registry.json'
    $entry=$null
    $httpReady=$false
    $wmiReturnSeconds=$null
    $childLogSeconds=$null
    $readySeconds=$null
    $readyDeadline=(Get-Date).AddSeconds(45)
    do {
        if(Test-Path -LiteralPath $registryPath -PathType Leaf){try{$entry=@((Get-Content -LiteralPath $registryPath -Raw|ConvertFrom-Json).projects)|Select-Object -First 1}catch{}}
        if($entry-and[int]$entry.pid-gt0-and$null-eq$wmiReturnSeconds){$wmiReturnSeconds=$clock.Elapsed.TotalSeconds}
        if($entry-and$entry.logPath-and$null-eq$childLogSeconds-and(Test-Path -LiteralPath $entry.logPath -PathType Leaf)){try{if((Get-Content -LiteralPath $entry.logPath -Raw)-match'sg-detach-fixture'){$childLogSeconds=$clock.Elapsed.TotalSeconds}}catch{}}
        try{$response=Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$port" -TimeoutSec 1;$httpReady=$response.StatusCode-eq200}catch{}
        if($entry-and$entry.status-eq'running'-and$httpReady){$readySeconds=$clock.Elapsed.TotalSeconds;break}
        if($startProcess.HasExited-and$startProcess.ExitCode-ne0){break}
        Start-Sleep -Milliseconds 250
    }while((Get-Date)-lt$readyDeadline)
    if(-not$entry-or$entry.status-ne'running'-or-not$httpReady){
        $setupLog=Get-ChildItem -LiteralPath (Join-Path $isolatedLocalAppData 'ShipGlows\DevServer\logs') -Filter setup.log -Recurse -ErrorAction SilentlyContinue|Select-Object -First 1
        $setupTail=if($setupLog){Get-Content -LiteralPath $setupLog.FullName -Tail 20|Out-String}else{''}
        $launchError=Get-ChildItem -LiteralPath (Join-Path $isolatedLocalAppData 'ShipGlows\DevServer\logs') -Filter stderr.log -Recurse -ErrorAction SilentlyContinue|Select-Object -First 1
        $launchTail=if($launchError){Get-Content -LiteralPath $launchError.FullName -Tail 20|Out-String}else{''}
        $cliError=if($startProcess.HasExited-and$stderrTask.IsCompleted){$stderrTask.Result}else{''}
        $cliOutput=if($startProcess.HasExited-and$stdoutTask.IsCompleted){$stdoutTask.Result}else{''}
        $exitCode=if($startProcess.HasExited){$startProcess.ExitCode}else{-1}
        $registryStatus=if($entry-and$entry.PSObject.Properties['status']){[string]$entry.status}else{'missing'}
        throw "Source CLI did not reach running/HTTP readiness (exited=$($startProcess.HasExited), exitCode=$exitCode, registryStatus=$registryStatus, setup=$setupTail, launch=$launchTail, stdout=$cliOutput, stderr=$cliError)."
    }
    $returned=$startProcess.WaitForExit(5000)
    $streamsClosed=[Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask,$stderrTask),5000)
    $clock.Stop()
    if(-not$returned-or-not$streamsClosed){
        $children=@(Get-CimInstance Win32_Process|Where-Object{$_.ParentProcessId-eq$startProcess.Id-or$_.ProcessId-eq[int]$entry.pid-or$_.ParentProcessId-eq[int]$entry.pid}|Select-Object ProcessId,ParentProcessId,Name,CommandLine)
        throw "Source CLI did not detach its capture streams after readiness (cliExited=$returned, streamsClosed=$streamsClosed, cliPid=$($startProcess.Id), registryStatus=$($entry.status), serverPid=$($entry.pid), httpReady=$httpReady, children=$($children|ConvertTo-Json -Compress))."
    }
    $stdout=$stdoutTask.Result;$stderr=$stderrTask.Result
    if($startProcess.ExitCode-ne0){throw "Source CLI start failed with $($startProcess.ExitCode): $stderr $stdout"}
    if(-not$entry-or$entry.status-ne'running'-or-not$httpReady){throw 'Source CLI did not return promptly while its npm-to-Node server remained ready.'}
    if(-not(Get-Process -Id ([int]$entry.pid) -ErrorAction SilentlyContinue)){throw 'The managed npm command process did not remain active after CLI return.'}
    $shortParentPid=[int](Get-Content -LiteralPath (Join-Path $surface 'parent.pid') -Raw)
    $parentDeadline=(Get-Date).AddSeconds(5);while((Get-Date)-lt$parentDeadline-and(Get-Process -Id $shortParentPid -ErrorAction SilentlyContinue)){Start-Sleep -Milliseconds 100}
    if(Get-Process -Id $shortParentPid -ErrorAction SilentlyContinue){throw 'The short-lived Node parent did not exit after detached spawn/unref.'}
    try{$detachedResponse=Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$port" -TimeoutSec 2}catch{throw 'The detached/unref listener did not survive its short-lived Node parent.'}
    if($detachedResponse.StatusCode-ne200){throw 'The detached/unref listener was not HTTP-ready while the wrapper remained alive.'}
    $managedProcess=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$entry.pid)"
    if(-not$managedProcess-or$managedProcess.CommandLine-notlike"*$($entry.commandSignature)*"){throw 'Detached process identity is not anchored in the durable command line.'}
    if([string]$entry.jobName-notmatch'^Local\\ShipGlows-[a-f0-9]{32}$'){throw 'Detached process did not persist its Windows Job Object identity.'}
    $stdoutBytes=Read-SgSharedBytes ([string]$entry.logPath);$stderrBytes=Read-SgSharedBytes ([string]$entry.errorLogPath)
    if($stdoutBytes-contains[byte]0-or$stderrBytes-contains[byte]0){throw "Detached logs contain UTF-16 NUL bytes (wmi=${wmiReturnSeconds}s child=${childLogSeconds}s ready=${readySeconds}s)."}
    $stdoutText=[Text.Encoding]::UTF8.GetString($stdoutBytes);$stderrText=[Text.Encoding]::UTF8.GetString($stderrBytes)
    if($stdoutText-notmatch'sg-detach-fixture'-or$stderrText-notmatch'stderr-readable-marker'){throw 'Detached stdout/stderr logs are not readable as UTF-8.'}

    Import-Module $modulePath -Force -DisableNameChecking
    $module=Get-Module ShipGlows.DevServer
    $capturedCommand=& $module {
        function script:New-CimInstance{[pscustomobject]@{ShowWindow=0}}
        function script:Invoke-CimMethod{param($ClassName,$MethodName,$Arguments)$script:detachedCommand=[string]$Arguments.CommandLine;[pscustomobject]@{ReturnValue=0;ProcessId=43210}}
        [void](Start-SgDetachedProcess 'mock.exe' @('serve') 'C:\fixture' 'C:\fixture\out.log' 'C:\fixture\err.log' @{PORT='3000';SHIPGLOWS_SUPERVISOR_TOKEN='do-not-leak-this-token'} 'C:\protected\token')
        $script:detachedCommand
    }
    $encoded=[regex]::Match($capturedCommand,'-EncodedCommand\s+([A-Za-z0-9+/=]+)').Groups[1].Value
    $decoded=if($encoded){[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encoded))}else{''}
    if($capturedCommand-match'do-not-leak-this-token'-or$decoded-match'do-not-leak-this-token'){throw 'Detached launch exposed the Flutter supervisor token in its command line payload.'}
    if($decoded-notmatch'(?i)ReadAllText.+protected.+token'){throw 'Detached launch did not source the Flutter supervisor token from its protected file.'}
    if($decoded-notmatch'CreateKillOnClose'-or$decoded-notmatch'AssignCurrent'){throw 'Detached launch did not fail closed into a KILL_ON_JOB_CLOSE Job Object before child launch.'}
    $shellResolution=& $module {
        $managed=[IO.Path]::GetFullPath($env:SHIPGLOWS_MANAGED_PWSH)
        function script:Test-Path{param($LiteralPath,$PathType) [IO.Path]::GetFullPath($LiteralPath)-eq$managed}
        $resolved=Resolve-SgPowerShellExecutable @($managed)
        $desktopRejected=$false;try{Resolve-SgPowerShellExecutable @('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe')|Out-Null}catch{$desktopRejected=$true}
        $pathRejected=$false;try{Resolve-SgPowerShellExecutable @('C:\fixture\pwsh.exe')|Out-Null}catch{$pathRejected=$true}
        [pscustomobject]@{Resolved=$resolved;Managed=$managed;DesktopRejected=$desktopRejected;PathRejected=$pathRejected}
    }
    if($shellResolution.Resolved-ne$shellResolution.Managed-or-not$shellResolution.DesktopRejected-or-not$shellResolution.PathRejected){throw "Detached shell resolution did not enforce the exact managed Core path: $($shellResolution|ConvertTo-Json -Compress)"}
    $flutterShell=& $module {
        function script:Get-SgFlutterCommandPath{'C:\fixture\flutter.bat'}
        function script:Resolve-SgPowerShellExecutable{'C:\Program Files\PowerShell\7\pwsh.exe'}
        function script:Test-Path{$true}
        (Get-SgLaunchSpec 'C:\fixture' 'flutter-web' 3000 $false 'C:\profile' 'chrome' '' 'C:\launch' 'flutter-identity').FilePath
    }
    if($flutterShell-ne'C:\Program Files\PowerShell\7\pwsh.exe'){throw 'Flutter launch did not use the PS7-aware PowerShell resolver.'}
    $stopProcess=New-SgCliProcess 'stop' $false
    if(-not$stopProcess.WaitForExit(15000)){$stopProcess.Kill();throw 'Managed stop timed out.'}
    if($stopProcess.ExitCode-ne0){throw "Managed stop failed with exit code $($stopProcess.ExitCode)."}
    $stopProcess.Dispose()
    $extinctionDeadline=(Get-Date).AddSeconds(5)
    do {
        $pidGone=-not[bool](Get-Process -Id ([int]$entry.pid) -ErrorAction SilentlyContinue)
        try{$probe=Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$port" -TimeoutSec 1;$serviceGone=$false}catch{$serviceGone=$true}
        if($pidGone-and$serviceGone){break}
        Start-Sleep -Milliseconds 100
    }while((Get-Date)-lt$extinctionDeadline)
    if(-not$pidGone-or-not$serviceGone){throw 'Managed stop returned before supervisor identity and HTTP service extinction were proven.'}
    $stoppedEntry=@((Get-Content -LiteralPath $registryPath -Raw|ConvertFrom-Json).projects)|Select-Object -First 1
    if($stoppedEntry.status-ne'stopped'-or[int]$stoppedEntry.pid-ne0){throw 'Registry was not marked stopped after proven extinction.'}
    Remove-Module ShipGlows.DevServer -Force
    Write-Host ("Windows DevServer detached npm-to-Node source CLI: OK wmi={0:N2}s child={1:N2}s ready={2:N2}s" -f $wmiReturnSeconds,$childLogSeconds,$readySeconds)
} finally {
    try {
        if($port-gt0-and(Test-Path -LiteralPath $surface -PathType Container)){
            $stopProcess=New-SgCliProcess 'stop' $false
            if(-not$stopProcess.WaitForExit(10000)){$stopProcess.Kill()}
            $stopProcess.Dispose()
        }
    } catch {}
    if($startProcess-and-not$startProcess.HasExited){$startProcess.Kill();[void]$startProcess.WaitForExit(5000)}
    if($startProcess){$startProcess.Dispose()}
    $env:SHIPGLOWS_MANAGED_PWSH=$previousManagedPowerShell
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
