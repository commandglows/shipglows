$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$provider=Join-Path $root 'cli\windows\shipglows-environment-provider.ps1'
$module=Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1'
$installer=Join-Path $root 'cli\windows\install-devserver.ps1'

foreach($path in @($provider,$module,$installer)){
    $tokens=$null;$errors=$null;[void][Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
    if($errors.Count){throw "PowerShell syntax failed: $path"}
}
$providerText=[IO.File]::ReadAllText($provider)
if($providerText -notmatch "@\('observe','acquire_mise','install_rust'\)" -or $providerText -match 'request[.](?:argv|arguments|command|executable)'){throw 'Provider action grammar is not closed.'}
if($providerText -notmatch 'Resolve-SgTrustedWingetIdentity' -or $providerText -match 'Get-Command winget[.]exe'){throw 'Provider does not use the canonical hashed WinGet resolver.'}
$installerText=[IO.File]::ReadAllText($installer)
if($installerText -match 'function Resolve-SgTrustedMisePath' -or $installerText -notmatch 'Invoke-SgIsolatedTauriMise'){throw 'Full installer still duplicates isolated mise ownership.'}

Import-Module $module -Force -DisableNameChecking
if(-not (Get-Command Resolve-SgTrustedWingetIdentity -ErrorAction SilentlyContinue)){throw 'Canonical WinGet resolver is not exported.'}
$config=Get-SgTauriDesktopMiseConfig
if($config -notmatch '1[.]97[.]1' -or $config -match '(?i)android|targets|ndk'){throw 'Desktop Rust config contains mobile components.'}
$temporary=Join-Path ([IO.Path]::GetTempPath()) ('sg-provider-contract-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
try{
    $script:captured=$null
    $runner={param($file,$arguments,$timeout)$script:captured=[pscustomobject]@{File=$file;Arguments=@($arguments);Timeout=$timeout;Safe=$env:MISE_SAFE;Config=$env:MISE_OVERRIDE_CONFIG_FILENAMES};[pscustomobject]@{ExitCode=0;Output='fixture';TimedOut=$false}}
    $previous=[Environment]::GetEnvironmentVariable('MISE_SAFE','Process')
    [void](Invoke-SgIsolatedTauriMise -MisePath 'C:\trusted\mise.exe' -ToolchainRoot $temporary -Arguments @('install','rust') -Runner $runner)
    if(($script:captured.Arguments -join '|') -ne 'install|rust' -or $script:captured.Safe -ne '1' -or $script:captured.Config -ne 'mise.toml'){throw 'Isolated mise primitive changed fixed semantics.'}
    if(-not [object]::Equals([Environment]::GetEnvironmentVariable('MISE_SAFE','Process'),$previous)){throw 'Isolated mise primitive leaked process environment.'}
}finally{Remove-Item -LiteralPath $temporary -Recurse -Force}
Write-Host 'Windows environment provider contract: OK'
