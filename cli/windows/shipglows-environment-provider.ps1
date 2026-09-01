[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-SgProviderResult($Value,[int]$ExitCode=0) {
    [Console]::Out.WriteLine(($Value | ConvertTo-Json -Depth 8 -Compress))
    exit $ExitCode
}

try {
    $raw=[Console]::In.ReadToEnd()
    if([string]::IsNullOrWhiteSpace($raw) -or $raw.Length -gt 16384){throw 'request is absent or exceeds the bound'}
    $request=$raw | ConvertFrom-Json -ErrorAction Stop
    $names=@($request.PSObject.Properties.Name)
    if(($names | Sort-Object) -join '|' -cne 'action|projectRoot|scope'){throw 'request fields are outside the closed contract'}
    $action=[string]$request.action
    if($action -notin @('observe','acquire_mise','install_rust')){throw 'action is outside the closed enum'}
    $root=[IO.Path]::GetFullPath([string]$request.projectRoot)
    if(-not (Test-Path -LiteralPath $root -PathType Container)){throw 'project root is unavailable'}
    $scope=[string]$request.scope
    if($scope -ne '.' -and ($scope -notmatch '^(?![A-Za-z]:)(?!.*(?:^|/)[.]{1,2}(?:/|$))[^/\\\x00-\x1F]+(?:/[^/\\\x00-\x1F]+)*$')){throw 'scope is not canonical'}
    $scoped=if($scope -eq '.'){$root}else{[IO.Path]::GetFullPath((Join-Path $root $scope))}
    if(-not ($scoped -eq $root -or $scoped.StartsWith($root.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase))){throw 'scope escapes project root'}

    $module=Join-Path $PSScriptRoot 'ShipGlows.MobileToolchain.psm1'
    if(-not (Test-Path -LiteralPath $module -PathType Leaf)){throw 'mobile toolchain provider module is unavailable'}
    Import-Module $module -Force -DisableNameChecking
    $runtimeRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))

    if($action -eq 'observe'){
        Write-SgProviderResult (Get-SgTauriWindowsEnvironmentObservation -ProjectRoot $root -Scope $scope -RuntimeRoot $runtimeRoot)
    }
    if($action -eq 'acquire_mise'){
        $mise=Resolve-SgTrustedMisePath
        if($mise){Write-SgProviderResult ([pscustomobject]@{status='applied';completed=@('acquire_mise');next_action='replan'})}
        $winget=Resolve-SgTrustedWingetIdentity
        if(-not $winget){Write-SgProviderResult ([pscustomobject]@{status='offline';reason='WinGet is unavailable'})}
        $result=Invoke-SgBoundedProcess -File $winget.Path -Arguments @('install','--id','jdx.mise','--exact','--source','winget','--accept-package-agreements','--accept-source-agreements','--silent','--disable-interactivity') -TimeoutSeconds 900
        if($result.TimedOut){Write-SgProviderResult ([pscustomobject]@{status='timeout';reason='mise acquisition timed out'})}
        if($result.ExitCode -ne 0){Write-SgProviderResult ([pscustomobject]@{status='partial';reason="mise acquisition exited $($result.ExitCode)"})}
        if(-not (Resolve-SgTrustedMisePath)){Write-SgProviderResult ([pscustomobject]@{status='partial';reason='mise identity was not observed after acquisition'})}
        Write-SgProviderResult ([pscustomobject]@{status='applied';completed=@('acquire_mise');next_action='replan'})
    }
    if($action -eq 'install_rust'){
        Write-SgProviderResult (Install-SgTauriDesktopRustToolchain -RuntimeRoot $runtimeRoot)
    }
} catch {
    Write-SgProviderResult ([pscustomobject]@{status='refused';reason=$_.Exception.Message}) 2
}
