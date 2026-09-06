$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
Import-Module (Join-Path $root 'cli\windows\ShipGlows.DevServer.psm1') -Force -DisableNameChecking
$module=Get-Module ShipGlows.DevServer
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('sg-stop-budget-'+[guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture,(Join-Path $fixture 'responses') | Out-Null
    $tokenPath=Join-Path $fixture 'token'
    [IO.File]::WriteAllText($tokenPath,('a'*64))
    & $module {
        param($fixture,$tokenPath)
        # Exercise the real IPC polling loop with a deterministic clock and a
        # response inside the supervisor's 10-second machine-request budget.
        function Assert-SgNoReparseTree {}
        function Test-SgOwnerOnlyPath {$true}
        function Get-Date { [datetime]::new(2026,9,5).AddMilliseconds($script:elapsedMs) }
        function Start-Sleep {
            param($Milliseconds)
            $script:elapsedMs += $Milliseconds
            if($script:elapsedMs -ge 9000){
                $command=Get-ChildItem -LiteralPath (Join-Path $fixture 'commands') -Filter '*.json' | Select-Object -First 1
                if($command){
                    $payload=Get-Content -LiteralPath $command.FullName -Raw | ConvertFrom-Json
                    [IO.File]::WriteAllText((Join-Path (Join-Path $fixture 'responses') $command.Name),(@{ok=$true;method=$payload.method}|ConvertTo-Json -Compress))
                }
            }
        }
        foreach($method in @('stop','open')){
            $script:elapsedMs=0
            $result=Invoke-SgFlutterSupervisorCommand ([pscustomobject]@{flutterLaunchDirectory=$fixture;flutterTokenPath=$tokenPath}) $method 8
            if(-not$result.ok-or$result.method-ne$method-or$script:elapsedMs-lt9000){throw "Supervisor $method did not accept a response within its machine stop budget."}
        }
    } $fixture $tokenPath
    Write-Host 'Windows Flutter stop/open response budget: OK'
} finally {
    if([IO.Path]::GetFullPath($fixture).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()),[StringComparison]::OrdinalIgnoreCase)){Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue}
    Remove-Module ShipGlows.DevServer -Force
}
