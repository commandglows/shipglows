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

    $loadedModule=Get-Module ShipGlows.MobileToolchain
    & $loadedModule { function script:Resolve-SgTrustedMisePath { 'C:\trusted\mise.exe' } }
    $previousLocalAppData=$env:LOCALAPPDATA;$previousRuntimeRoot=$env:SHIPGLOWS_ROOT
    try{
        $env:LOCALAPPDATA=$temporary;$env:SHIPGLOWS_ROOT=(Join-Path $temporary 'runtime')
        $desktopRunner={
            param($file,$arguments,$timeout)
            $command=$arguments -join '|'
            $output=if($command -eq 'exec|rust@1.97.1|--|rustc|--version'){'rustc 1.97.1 (fixture)'}elseif($command -eq 'exec|rust@1.97.1|--|cargo|--version'){'cargo 1.97.1 (fixture)'}elseif($command -eq 'exec|rust@1.97.1|--|rustup|--version'){'rustup 1.28.2 (fixture)'}else{'fixture'}
            [pscustomobject]@{ExitCode=0;Output=$output;TimedOut=$false}
        }
        $desktop=Install-SgTauriDesktopRustToolchain -Runner $desktopRunner
        if($desktop.Status -ne 'applied' -or -not (Test-Path -LiteralPath (Join-Path $env:SHIPGLOWS_ROOT 'bin\cargo.cmd') -PathType Leaf)){throw 'Desktop Rust install default runtime expression did not execute.'}
        if((@($desktop.PSObject.Properties.Name) -join '|') -cne 'status|completed|next_action'){throw 'Desktop Rust provider evidence is not canonical lower-case JSON.'}
        if(-not(Test-SgTauriDesktopRustWrappers -MisePath 'C:\trusted\mise.exe' -ToolchainRoot (Join-Path $temporary 'ShipGlows\Toolchains\tauri-windows'))){throw 'Desktop Rust readiness did not require the exact managed wrappers.'}
    }finally{
        if($null -eq $previousLocalAppData){Remove-Item Env:LOCALAPPDATA -ErrorAction SilentlyContinue}else{$env:LOCALAPPDATA=$previousLocalAppData}
        if($null -eq $previousRuntimeRoot){Remove-Item Env:SHIPGLOWS_ROOT -ErrorAction SilentlyContinue}else{$env:SHIPGLOWS_ROOT=$previousRuntimeRoot}
    }
}finally{Remove-Item -LiteralPath $temporary -Recurse -Force}
Write-Host 'Windows environment provider contract: OK'
