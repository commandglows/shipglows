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
        function Test-SgPortAvailable { $true }
        function Stop-SgOwnedFlutterListener { $false }
        function Stop-SgProcessTree { $script:entry.pid = 0 }
        function Invoke-SgRegistryMutation { param($Config,$Mutation); $registry=Read-SgRegistry; & $Mutation $registry; $registry }
        $warnings = @(); function Write-SgWarn { param($Message); $script:warnings += $Message }
        $script:entry.lastError='stale live error'
        if (Stop-SgProject $config $script:entry.path) { throw 'Stopping an already stopped entry reported a process stop.' }
        if ($script:entry.lastError) { throw 'Idempotent stop retained a stale live error.' }
        if ($warnings.Count -ne 0) { throw 'Stopping an already stopped entry emitted a warning.' }
        $script:entry.status='running'; $script:entry.pid=77
        if (-not (Stop-SgProject $config $script:entry.path)) { throw 'Running process stop was not reported.' }
    }
    & $module {
        $entry=[pscustomobject]@{name='unproved';path='C:\workspace\unproved';kind='vite';port=3000;status='running';pid=88;startTimeUtc=$null;lastError=$null}
        $config=[pscustomobject]@{}
        function ConvertTo-SgCanonicalPath{'C:\workspace\unproved'}
        function Read-SgRegistry{[pscustomobject]@{schemaVersion=1;projects=@($entry)}}
        function Test-SgProcessIdentity{$false}
        function Test-SgPortAvailable{$false}
        function Wait-SgManagedExtinction{$false}
        function Stop-SgOwnedFlutterListener{$false}
        function Stop-SgOwnedFlutterBrowser{$false}
        function Invoke-SgRegistryMutation{throw 'Registry mutation must not run before extinction proof.'}
        $failed=$false
        try{Stop-SgProject $config $entry.path|Out-Null}catch{$message=$_.Exception.Message;$failed=$message-like'*could not prove*'}
        if(-not$failed){throw "Unproved extinction did not fail closed: $message"}
        if($entry.status-ne'running'-or[int]$entry.pid-ne88){throw "Unproved extinction changed durable state: status=$($entry.status) pid=$($entry.pid)"}
    }
    $stopOrder=& $module {
        $script:stopOrder=@()
        function script:Get-CimInstance{@(
            [pscustomobject]@{ProcessId=900;ParentProcessId=500},
            [pscustomobject]@{ProcessId=100;ParentProcessId=900},
            [pscustomobject]@{ProcessId=100;ParentProcessId=900},
            [pscustomobject]@{ProcessId=500;ParentProcessId=100},
            [pscustomobject]@{ProcessId=700;ParentProcessId=666},
            [pscustomobject]@{ProcessId=800;ParentProcessId=1}
        )}
        function script:Stop-Process{param($Id,[switch]$Force,$ErrorAction)$script:stopOrder += [int]$Id}
        Stop-SgProcessTree 900
        return ,$script:stopOrder
    }
    if(($stopOrder-join',')-ne'500,100,900'){throw "Process tree stop was not child-first: $($stopOrder-join',')"}
    if(@($stopOrder|Sort-Object -Unique).Count-ne$stopOrder.Count){throw 'Process tree stop terminated a duplicated or cyclic PID more than once.'}
    if(700-in$stopOrder-or800-in$stopOrder-or666-in$stopOrder){throw 'Process tree stop overreached into an orphan, missing parent, or unrelated process.'}
    $entrypoint = Get-Content -Raw ([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\shipglows-devserver.ps1')))
    if (-not $entrypoint.Contains("'stop' { if (`$ProjectPath) { [void](Stop-SgProject `$config `$ProjectPath)")) { throw 'Direct stop does not suppress the internal Boolean result.' }
    if (-not $entrypoint.Contains('function Invoke-SgRequiredStart') -or -not $entrypoint.Contains("`$result.status -eq 'error'") -or -not $entrypoint.Contains('throw $reason')) { throw 'One-shot startup errors are not converted into a non-zero CLI failure.' }
    $tokens=$null;$errors=$null
    $ast=[Management.Automation.Language.Parser]::ParseInput($entrypoint,[ref]$tokens,[ref]$errors)
    $startFunction=$ast.Find({param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-SgRequiredStart'},$true)
    if(-not$startFunction-or$errors.Count){throw 'Could not isolate the one-shot start wrapper for behavioral proof.'}
    Invoke-Expression $startFunction.Extent.Text
    $config=[pscustomobject]@{}
    function Start-SgProject { 'setup output';'launch output';[pscustomobject]@{status='running';lastError=$null;path='C:\workspace\test'} }
    $capturedStart=@(Invoke-SgRequiredStart 'C:\workspace\test' 6>&1)
    $informationText=@($capturedStart|Where-Object{$_-is[Management.Automation.InformationRecord]}|ForEach-Object{[string]$_.MessageData})
    if('setup output'-notin$informationText-or'launch output'-notin$informationText){throw 'One-shot start did not preserve both pre-result messages on the Information stream.'}
    $startResult=@($capturedStart|Where-Object{$_-isnot[Management.Automation.InformationRecord]})|Select-Object -First 1
    if($startResult.status-ne'running'-or$startResult.path-ne'C:\workspace\test'){throw 'One-shot start did not select the final structured result after informational output.'}
    function Start-SgProject { 'setup output';[pscustomobject]@{status='error';lastError='actionable startup failure';path='C:\workspace\test'} }
    $startFailed=$false
    try{Invoke-SgRequiredStart 'C:\workspace\test'|Out-Null}catch{$startFailed=$_.Exception.Message-eq'actionable startup failure'}
    if(-not$startFailed){throw 'One-shot start did not preserve lastError as a non-zero failure after informational output.'}
    function Start-SgProject { [pscustomobject]@{status='running';lastError=$null;path='C:\workspace\test'};[pscustomobject]@{status='running';lastError=$null;path='C:\workspace\test'} }
    $ambiguousFailed=$false
    try{Invoke-SgRequiredStart 'C:\workspace\test'|Out-Null}catch{$ambiguousFailed=$_.Exception.Message-like'*one structured result*'}
    if(-not$ambiguousFailed){throw 'One-shot start accepted ambiguous structured results as success.'}
    function Start-SgProject { 'setup output only' }
    $missingFailed=$false
    try{Invoke-SgRequiredStart 'C:\workspace\test' 6>&1|Out-Null}catch{$missingFailed=$_.Exception.Message-like'*one structured result*'}
    if(-not$missingFailed){throw 'One-shot start accepted zero structured results as success.'}
    Write-Host 'Windows DevServer idempotent stop: OK'
} finally { Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue }
