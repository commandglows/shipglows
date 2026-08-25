$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\cli\windows\ShipGlows.DevServer.psm1'))
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("sg-dependency-setup-{0}" -f [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    $capture = Join-Path $fixture 'argv.txt'
    $fakeNpm = Join-Path $fixture 'npm.cmd'
    [IO.File]::WriteAllText($fakeNpm, "@echo off`r`n>>`"$capture`" echo %*`r`nif not exist node_modules mkdir node_modules`r`ntype nul > node_modules\.package-lock.json`r`nif not exist node_modules\vite mkdir node_modules\vite`r`nif not exist node_modules\astro mkdir node_modules\astro`r`necho {}>node_modules\vite\package.json`r`necho {}>node_modules\astro\package.json`r`nif exist fail.flag exit /b 9`r`nif exist mutate.flag echo.>>package.json`r`n", [Text.Encoding]::ASCII)
    Import-Module $modulePath -Force -DisableNameChecking
    $module = Get-Module ShipGlows.DevServer

    $locked = Join-Path $fixture 'locked'
    $config = [pscustomobject]@{RuntimeDirectory=(Join-Path $fixture 'runtime')}
    New-Item -ItemType Directory -Path $locked -Force | Out-Null
    Set-Content (Join-Path $locked 'package.json') '{}' -Encoding UTF8
    Set-Content (Join-Path $locked 'package-lock.json') '{}' -Encoding UTF8
    $installed = & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm
    if (-not $installed) { throw 'First dependency setup did not install.' }
    if ((Get-Content -Raw $capture).Trim() -ne 'ci') { throw 'npm lockfile setup did not preserve ci as one argv token.' }
    $statePath = & $module { param($Config,$Project) Get-SgDependencyStatePath $Config $Project } $config $locked
    $reused = & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm
    if ($reused -or @(Get-Content $capture).Count -ne 1) { throw 'Unchanged manifests and artifacts re-ran dependency setup.' }
    Set-Content (Join-Path $locked 'package.json') '{"changed":true}' -Encoding UTF8
    New-Item -ItemType File -Path (Join-Path $locked 'fail.flag') | Out-Null
    $failed = $false
    try { & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm | Out-Null } catch { $failed = $_.Exception.Message -like 'Dependency setup failed*' }
    if (-not $failed -or (Test-Path -LiteralPath $statePath)) { throw 'Failed dependency setup retained or advanced durable state.' }
    Remove-Item -LiteralPath (Join-Path $locked 'fail.flag')
    $changed = & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm
    if (-not $changed -or @(Get-Content $capture).Count -ne 3) { throw 'Manifest change did not invalidate dependency state.' }
    Remove-Item -LiteralPath (Join-Path $locked 'node_modules') -Recurse -Force
    $restored = & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm
    if (-not $restored -or @(Get-Content $capture).Count -ne 4) { throw 'Missing dependency artifacts did not invalidate state.' }

    New-Item -ItemType File -Path (Join-Path $locked 'mutate.flag') | Out-Null
    Set-Content (Join-Path $locked 'package.json') '{"mutating":true}' -Encoding UTF8
    $movingFailed=$false
    try { & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $locked (Join-Path $fixture 'locked.log') $fakeNpm | Out-Null } catch { $movingFailed=$_.Exception.Message -like 'Dependency inputs changed during setup*' }
    if(-not$movingFailed-or(Test-Path -LiteralPath $statePath)){throw 'A manifest changed during installation was recorded as installed.'}
    Remove-Item -LiteralPath (Join-Path $locked 'mutate.flag')

    $unlocked = Join-Path $fixture 'unlocked'
    New-Item -ItemType Directory -Path $unlocked -Force | Out-Null
    Set-Content (Join-Path $unlocked 'package.json') '{}' -Encoding UTF8
    Clear-Content $capture
    $previousPackageLockEnvironment=$env:npm_config_package_lock;$env:npm_config_package_lock='restore-me'
    & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath { $Npm }; Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $unlocked (Join-Path $fixture 'unlocked.log') $fakeNpm | Out-Null
    if ((Get-Content -Raw $capture).Trim() -ne 'install') { throw 'npm unlocked setup did not preserve install as one argv token.' }
    if($env:npm_config_package_lock-ne'restore-me'){throw 'Unlocked npm setup did not restore the caller package-lock environment.'}
    $env:npm_config_package_lock=$previousPackageLockEnvironment

    $shrinkwrapped=Join-Path $fixture 'shrinkwrapped'
    New-Item -ItemType Directory -Path $shrinkwrapped -Force|Out-Null
    Set-Content (Join-Path $shrinkwrapped 'package.json') '{}' -Encoding UTF8
    Set-Content (Join-Path $shrinkwrapped 'npm-shrinkwrap.json') '{}' -Encoding UTF8
    Clear-Content $capture
    & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath{$Npm};Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $shrinkwrapped (Join-Path $fixture 'shrinkwrapped.log') $fakeNpm|Out-Null
    if((Get-Content -Raw $capture).Trim()-ne'ci'){throw 'npm-shrinkwrap.json did not select npm ci.'}
    $strategyDigests=& $module {
        param($Project)
        $base=[pscustomobject]@{Manager='C:\tools\npm.cmd';Arguments=@('ci');BootstrapArguments=@();ArtifactStrategy='node-vite-npm'}
        $manager=[pscustomobject]@{Manager='C:\other\npm.cmd';Arguments=@('ci');BootstrapArguments=@();ArtifactStrategy='node-vite-npm'}
        $arguments=[pscustomobject]@{Manager='C:\tools\npm.cmd';Arguments=@('install');BootstrapArguments=@();ArtifactStrategy='node-vite-npm'}
        $strategy=[pscustomobject]@{Manager='C:\tools\npm.cmd';Arguments=@('ci');BootstrapArguments=@();ArtifactStrategy='node-astro-npm'}
        @((Get-SgDependencyDigest $Project 'vite' $base),(Get-SgDependencyDigest $Project 'vite' $manager),(Get-SgDependencyDigest $Project 'vite' $arguments),(Get-SgDependencyDigest $Project 'vite' $strategy))
    } $shrinkwrapped
    if(@($strategyDigests|Sort-Object -Unique).Count-ne4){throw 'Dependency digest omitted manager, arguments, or artifact strategy.'}
    $shrinkState=& $module {param($Config,$Project)Get-SgDependencyStatePath $Config $Project} $config $shrinkwrapped
    $legacyState=Get-Content -LiteralPath $shrinkState -Raw|ConvertFrom-Json;$legacyState.schemaVersion=1;$legacyState|ConvertTo-Json -Compress|Set-Content -LiteralPath $shrinkState -Encoding UTF8
    & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath{$Npm};Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $shrinkwrapped (Join-Path $fixture 'shrinkwrapped.log') $fakeNpm|Out-Null
    if(@(Get-Content $capture).Count-ne2){throw 'Unsupported dependency-state schema was reused.'}
    Remove-Item -LiteralPath (Join-Path $shrinkwrapped 'node_modules\vite\package.json')
    & $module { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath{$Npm};Invoke-SgDependencySetup $Config $Project 'vite' $Log } $config $shrinkwrapped (Join-Path $fixture 'shrinkwrapped.log') $fakeNpm|Out-Null
    if(@(Get-Content $capture).Count-ne3){throw 'Missing Vite framework artifact was reused.'}

    $concurrent = Join-Path $fixture 'concurrent'
    New-Item -ItemType Directory -Path $concurrent -Force | Out-Null
    Set-Content (Join-Path $concurrent 'package.json') '{}' -Encoding UTF8
    Set-Content (Join-Path $concurrent 'package-lock.json') '{}' -Encoding UTF8
    Clear-Content $capture
    $jobs = @(1..2 | ForEach-Object {
        Start-Job -ScriptBlock {
            param($ModulePath,$Config,$Project,$Log,$Npm)
            Import-Module $ModulePath -Force -DisableNameChecking
            $loaded=Get-Module ShipGlows.DevServer
            & $loaded { param($Config,$Project,$Log,$Npm) function Get-SgCommandPath{$Npm};Invoke-SgDependencySetup $Config $Project 'vite' $Log } $Config $Project $Log $Npm
        } -ArgumentList $modulePath,$config,$concurrent,(Join-Path $fixture 'concurrent.log'),$fakeNpm
    })
    $jobs|Wait-Job|Out-Null
    $failedJobs=@($jobs|Where-Object State -ne 'Completed')
    $results=@($jobs|Receive-Job)
    $jobs|Remove-Job -Force
    if($failedJobs.Count -ne 0 -or @($results|Where-Object{$_ -eq $true}).Count -ne 1 -or @(Get-Content $capture).Count -ne 1){throw 'Concurrent dependency setup was not serialized to one successful install.'}
    Write-Host 'Windows DevServer conditional dependency setup: OK'
} finally {
    Get-Job -ErrorAction SilentlyContinue|Remove-Job -Force -ErrorAction SilentlyContinue
    Remove-Module ShipGlows.DevServer -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue
}
