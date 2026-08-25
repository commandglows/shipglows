$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$modulePath = Join-Path $root 'cli\windows\ShipGlows.MobileToolchain.psm1'
$tokens = $null
$errors = $null
[void][Management.Automation.Language.Parser]::ParseFile($modulePath, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | ForEach-Object Message | Out-String) }
Import-Module $modulePath -Force -DisableNameChecking

function Assert-Sg([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$uncertain = Get-SgAndroidInstallPlan -Interactive $true -EmulatorSupported $false -EmulatorChoice ''
Assert-Sg ($uncertain.AskEmulator) 'Interactive x64 hosts must keep the emulator choice even when acceleration is uncertain.'
Assert-Sg ($uncertain.AccelerationWarning -and $uncertain.PhysicalDeviceAlternative) 'Uncertain acceleration must be disclosed without silently choosing for the operator.'
$uncertainAccepted = Get-SgAndroidInstallPlan -Interactive $true -EmulatorSupported $false -EmulatorChoice 'yes'
Assert-Sg ($uncertainAccepted.InstallEmulator -and $uncertainAccepted.AccelerationWarning) 'Explicit emulator acceptance must survive uncertain acceleration evidence.'
$accepted = Get-SgAndroidInstallPlan -Interactive $true -EmulatorSupported $true -EmulatorChoice 'yes'
Assert-Sg ($accepted.AskEmulator -and $accepted.InstallEmulator -and -not $accepted.AccelerationWarning) 'Supported accepted emulator choice was lost.'
$refused = Get-SgAndroidInstallPlan -Interactive $true -EmulatorSupported $true -EmulatorChoice 'no'
Assert-Sg (-not $refused.InstallEmulator -and $refused.PhysicalDeviceAlternative) 'Refusal must keep the phone alternative.'
$headless = Get-SgAndroidInstallPlan -Interactive $false -EmulatorSupported $false -EmulatorChoice ''
Assert-Sg (-not $headless.AskEmulator -and -not $headless.InstallEmulator) 'Noninteractive installs must never prompt or guess emulator consent.'
Assert-Sg ($headless.LicensesPending -and $headless.LicenseCommand -eq 'sdkmanager --licenses') 'Noninteractive Android licenses need actionable pending state.'
$completePlan = Get-SgAndroidInstallPlan -Interactive $true -EmulatorSupported $false -EmulatorChoice 'yes' -EmulatorReady $true
Assert-Sg (-not $completePlan.AskEmulator -and -not $completePlan.InstallEmulator -and $completePlan.EmulatorReady) 'A complete existing emulator must skip both the question and provisioning.'
Assert-Sg (Test-SgAndroidLicenseResult ([pscustomobject]@{ ExitCode=0; Output="WARNING: sdkmanager is deprecated.`nAll SDK package licenses accepted"; TimedOut=$false })) 'Previously accepted SDK licenses must converge without another interactive prompt.'
Assert-Sg (-not (Test-SgAndroidLicenseResult ([pscustomobject]@{ ExitCode=0; Output='7 of 7 SDK package licenses not accepted.'; TimedOut=$false }))) 'Unaccepted SDK licenses must remain pending.'

$ideMissing = Get-SgWindowsIdeInstallPlan -Interactive $true -AndroidStudioReady $false -VisualStudioCppReady $false -Choice 'yes'
Assert-Sg ($ideMissing.Ask -and $ideMissing.InstallAndroidStudio -and $ideMissing.InstallVisualStudioCpp) 'Interactive acceptance must install both missing Windows IDE toolchains.'
Assert-Sg (($ideMissing.Missing -join '|') -eq 'Android Studio|Visual Studio Community with Desktop development with C++') 'The IDE proposal must name the two product outcomes clearly.'
$idePartial = Get-SgWindowsIdeInstallPlan -Interactive $true -AndroidStudioReady $true -VisualStudioCppReady $false -Choice 'yes'
Assert-Sg (-not $idePartial.InstallAndroidStudio -and $idePartial.InstallVisualStudioCpp) 'A partial host must install only the missing IDE toolchain.'
$ideRefused = Get-SgWindowsIdeInstallPlan -Interactive $true -AndroidStudioReady $false -VisualStudioCppReady $false -Choice 'no'
Assert-Sg ($ideRefused.Status -eq 'pending' -and -not $ideRefused.InstallAndroidStudio -and -not $ideRefused.InstallVisualStudioCpp) 'IDE bundle refusal must remain pending without installation.'
$ideHeadless = Get-SgWindowsIdeInstallPlan -Interactive $false -AndroidStudioReady $false -VisualStudioCppReady $false
Assert-Sg (-not $ideHeadless.Ask -and $ideHeadless.Status -eq 'pending') 'Noninteractive installs must never infer consent for multi-gigabyte IDEs.'
$ideComplete = Get-SgWindowsIdeInstallPlan -Interactive $true -AndroidStudioReady $true -VisualStudioCppReady $true -Choice 'yes'
Assert-Sg (-not $ideComplete.Ask -and $ideComplete.Status -eq 'ready') 'A complete host must skip the IDE question and installation.'

$fresh = Get-SgAndroidProvisionPlan -Interactive $true -JdkReady $false -CommandLineToolsReady $false -LicensesAccepted $false -LicenseChoice 'no'
Assert-Sg (($fresh.Components -join '|') -eq 'jdk17|android-command-line-tools|platform-tools|platform|build-tools') 'Fresh host plan must include the complete essential chain.'
Assert-Sg ($fresh.Status -eq 'pending' -and $fresh.Reason -match 'license') 'Refused licenses must remain explicitly pending.'
$freshHeadless = Get-SgAndroidProvisionPlan -Interactive $false -JdkReady $false -CommandLineToolsReady $false -LicensesAccepted $false
Assert-Sg ($freshHeadless.Status -eq 'pending' -and -not $freshHeadless.PromptLicenses) 'Noninteractive fresh host must not prompt or claim readiness.'
$existing = Get-SgAndroidProvisionPlan -Interactive $true -JdkReady $true -CommandLineToolsReady $true -LicensesAccepted $true
Assert-Sg ($existing.Status -eq 'ready-to-install' -and -not $existing.PromptLicenses) 'Existing accepted toolchain should converge without another license prompt.'

$accelGood = Test-SgAndroidAcceleration -EmulatorPath 'emulator.exe' -Runner { param($f,$a,$timeout) [pscustomobject]@{ ExitCode=0; Output='WHPX is installed and usable.'; TimedOut=$false } }
$accelBad = Test-SgAndroidAcceleration -EmulatorPath 'emulator.exe' -Runner { param($f,$a,$timeout) [pscustomobject]@{ ExitCode=0; Output='acceleration is not supported'; TimedOut=$false } }
Assert-Sg ($accelGood -and -not $accelBad) 'Emulator support must require positive accel evidence, not exit code alone.'
Assert-Sg (Test-SgWindowsHypervisorEvidence $true $true $true $true) 'Complete hypervisor evidence should support the emulator question.'
Assert-Sg (-not (Test-SgWindowsHypervisorEvidence $true $true $false $true)) 'A VM without nested monitor extensions must use the phone fallback.'
$coordinates = Get-SgAndroidCoordinates
Assert-Sg ($coordinates.ApiLevel -eq 36 -and $coordinates.BuildToolsVersion -eq '36.0.0') 'Android coordinates must be centralized on API/build-tools 36.'
$tauriBaseline = Get-SgTauriAndroidBaseline
Assert-Sg ($tauriBaseline.Schema -eq 'shipglows.tauri-android-baseline/v1') 'Tauri Android baseline must be explicitly versioned.'
Assert-Sg ($tauriBaseline.ValidatedAt -eq '2026-08-17' -and $tauriBaseline.RustToolchainVersion -eq '1.97.1' -and $tauriBaseline.TauriCliVersion -eq '2.11.4' -and $tauriBaseline.TauriApiVersion -eq '2.11.1' -and $tauriBaseline.TauriRustVersion -eq '2.11.5' -and $tauriBaseline.TauriBuildVersion -eq '2.6.3' -and $tauriBaseline.NdkVersion -eq '29.0.14206865') 'Tauri Android baseline must match the current ShipGlows-validated stable coordinates.'
foreach ($value in @($tauriBaseline.RustToolchainVersion,$tauriBaseline.TauriCliVersion,$tauriBaseline.TauriApiVersion,$tauriBaseline.TauriRustVersion,$tauriBaseline.TauriBuildVersion,$tauriBaseline.AndroidApiLevel,$tauriBaseline.BuildToolsVersion,$tauriBaseline.NdkVersion)) {
    Assert-Sg (-not [string]::IsNullOrWhiteSpace([string]$value) -and [string]$value -notmatch '(?i)latest|stable|nightly|beta|[x*^~<>]') 'Tauri Android baseline must contain exact validated coordinates only.'
}
$targetAddArguments = @(Get-SgTauriRustTargetAddArguments -Baseline $tauriBaseline)
Assert-Sg (($targetAddArguments -join "`0") -ceq ((@('exec','--','rustup','target','add') + @($tauriBaseline.RustTargets)) -join "`0")) 'Tauri Rust Android targets must use exact argv without a shell command string.'
Assert-Sg (Test-SgTauriRustTargetAddResult ([pscustomobject]@{ExitCode=0;Output='info: component rust-std is up to date';TimedOut=$false})) 'Successful bounded rustup target add must converge.'
Assert-Sg (-not (Test-SgTauriRustTargetAddResult ([pscustomobject]@{ExitCode=1;Output='target unavailable';TimedOut=$false}))) 'Failed rustup target add must remain pending.'
Assert-Sg (-not (Test-SgTauriRustTargetAddResult ([pscustomobject]@{ExitCode=0;Output='';TimedOut=$true}))) 'Timed-out rustup target add must remain pending.'
$unsafeTargetRejected = $false
try { [void](Get-SgTauriRustTargetAddArguments -Baseline ([pscustomobject]@{RustTargets=@('x86_64-linux-android & whoami')})) } catch { $unsafeTargetRejected = $true }
Assert-Sg $unsafeTargetRejected 'Tauri Rust target argv must reject shell-shaped or unvalidated target names.'
Assert-Sg (($tauriBaseline.RustTargets -join '|') -eq 'aarch64-linux-android|armv7-linux-androideabi|i686-linux-android|x86_64-linux-android') 'Tauri Android baseline must declare the complete validated Rust Android target set.'
$tauriHostPlan = Get-SgTauriAndroidHostPlan -TauriDetected $true -MiseReady $false -RustReady $false -NdkReady $false -MigrationRequired $true -Interactive $true -CodexReady $true -CodexChoice 'y'
Assert-Sg ($tauriHostPlan.NeedMise -and $tauriHostPlan.NeedRust -and $tauriHostPlan.NeedNdk) 'A missing Tauri Android host must plan mise, Rust, and the validated NDK.'
Assert-Sg (($tauriHostPlan.AndroidPackages -join '|') -eq 'platform-tools|platforms;android-36|build-tools;36.0.0|ndk;29.0.14206865') 'Tauri Android host packages must use only the validated ShipGlows baseline.'
Assert-Sg ($tauriHostPlan.OfferCodex -and $tauriHostPlan.OpenCodex -and -not $tauriHostPlan.ProjectMutationAuthorized) 'Opening Codex must remain an explicit offer and must not authorize project mutation.'
$tauriNoopPlan = Get-SgTauriAndroidHostPlan -TauriDetected $false -MiseReady $false -RustReady $false -NdkReady $false
Assert-Sg ($tauriNoopPlan.Status -eq 'not_applicable' -and -not $tauriNoopPlan.NeedMise -and @($tauriNoopPlan.AndroidPackages).Count -eq 0) 'A workspace without Tauri must not plan Tauri tooling.'
$tauriNonInteractive = Get-SgTauriAndroidHostPlan -TauriDetected $true -MiseReady $true -RustReady $true -NdkReady $true -MigrationRequired $true -Interactive $false -CodexReady $true -CodexChoice 'y'
Assert-Sg ($tauriNonInteractive.Status -eq 'migration_required' -and -not $tauriNonInteractive.OfferCodex -and -not $tauriNonInteractive.OpenCodex) 'Non-interactive installation must leave project migration as a handoff.'
$tauriMiseConfig = Get-SgTauriMiseConfig -Baseline $tauriBaseline
Assert-Sg ($tauriMiseConfig -match 'rust\s*=\s*\{\s*version\s*=\s*"1[.]97[.]1"' -and $tauriMiseConfig -match 'aarch64-linux-android' -and $tauriMiseConfig -notmatch '(?i)latest|stable|nightly|hook|task|exec') 'The managed mise config must be exact, code-free, and include the Android Rust targets.'
$emulatorPlan = Get-SgEmulatorProvisionPlan
Assert-Sg (($emulatorPlan.Packages -join '|') -eq 'emulator|system-images;android-36;google_apis;x86_64' -and $emulatorPlan.AvdName -eq 'ShipGlows_API_36') 'Emulator provisioning must include current package, system image, and AVD.'
$emulatorStateRoot = Join-Path ([IO.Path]::GetTempPath()) ('sg-emulator-state-' + [guid]::NewGuid().ToString('N'))
try {
    $emulatorExe = Join-Path $emulatorStateRoot 'emulator\emulator.exe'
    $imagePackage = Join-Path $emulatorStateRoot 'system-images\android-36\google_apis\x86_64\package.xml'
    New-Item -ItemType Directory -Path (Split-Path $emulatorExe -Parent),(Split-Path $imagePackage -Parent) -Force | Out-Null
    New-Item -ItemType File -Path $emulatorExe -Force | Out-Null
    [IO.File]::WriteAllText($imagePackage, '<localPackage path="system-images;android-36;google_apis;x86_64" />')
    $completeState = Get-SgAndroidEmulatorProvisionState -SdkRoot $emulatorStateRoot -EmulatorPath $emulatorExe -ImagePackage $emulatorPlan.Packages[1] -AvdName $emulatorPlan.AvdName -Runner { param($f,$a,$timeout) [pscustomobject]@{ ExitCode=0; Output="Other_AVD`nShipGlows_API_36"; TimedOut=$false } }
    Assert-Sg ($completeState.Complete -and $completeState.EmulatorInstalled -and $completeState.ImageInstalled -and $completeState.AvdReady) 'A complete existing emulator state must be recognized without provisioning.'
    Remove-Item -LiteralPath $imagePackage -Force
    $partialState = Get-SgAndroidEmulatorProvisionState -SdkRoot $emulatorStateRoot -EmulatorPath $emulatorExe -ImagePackage $emulatorPlan.Packages[1] -AvdName $emulatorPlan.AvdName -Runner { param($f,$a,$timeout) [pscustomobject]@{ ExitCode=0; Output='ShipGlows_API_36'; TimedOut=$false } }
    Assert-Sg (-not $partialState.Complete -and $partialState.EmulatorInstalled -and -not $partialState.ImageInstalled -and $partialState.AvdReady) 'A partial emulator state must remain repairable instead of being called complete.'
    $unsafePackageRejected = $false
    try { [void](Get-SgAndroidEmulatorProvisionState -SdkRoot $emulatorStateRoot -EmulatorPath $emulatorExe -ImagePackage 'system-images;..;google_apis;x86_64' -AvdName $emulatorPlan.AvdName) } catch { $unsafePackageRejected = $true }
    Assert-Sg $unsafePackageRejected 'Unsafe or malformed emulator package coordinates must fail before path construction.'
} finally {
    if (Test-Path -LiteralPath $emulatorStateRoot) { Remove-Item -LiteralPath $emulatorStateRoot -Recurse -Force }
}
Assert-Sg (Test-SgSupportedAndroidArchitecture -Is64BitOperatingSystem $true -Architecture 'AMD64') 'Windows x64 must be supported.'
Assert-Sg (-not (Test-SgSupportedAndroidArchitecture -Is64BitOperatingSystem $true -Architecture 'ARM64')) 'Non-x64 Windows must become pending before downloads.'

$openCode = Get-SgAgentMcpPlan -Agent OpenCode -CommandPath 'opencode.cmd' -DartPath 'dart.bat' -NpxPath 'npx.cmd' -PlaywrightVersion '0.0.42' -ChromiumReady $true
Assert-Sg ($openCode.McpShape -eq 'servers' -and $openCode.Config.mcp.servers.playwright.command[3] -eq '@playwright/mcp@0.0.42') 'OpenCode v2 must use mcp.servers and an exact Playwright version.'
$kilo = Get-SgAgentMcpPlan -Agent Kilo -CommandPath 'kilo.cmd' -DartPath 'dart.bat' -NpxPath 'npx.cmd' -PlaywrightVersion '0.0.42' -ChromiumReady $true
Assert-Sg ($kilo.CommandName -eq 'kilo' -and $kilo.McpShape -eq 'direct') 'Kilo must use the official kilo command and direct mcp shape.'
$kiloCompat = Resolve-SgKiloCommand -KiloPath '' -KilocodePath 'kilocode.cmd'
Assert-Sg ($kiloCompat.CommandName -eq 'kilocode' -and $kiloCompat.Compatibility) 'Legacy kilocode compatibility must be detected explicitly.'
$noChromium = Get-SgAgentMcpPlan -Agent Kilo -CommandPath 'kilo.cmd' -DartPath 'dart.bat' -NpxPath 'npx.cmd' -PlaywrightVersion '0.0.42' -ChromiumReady $false
Assert-Sg (-not $noChromium.Config.mcp.Contains('playwright')) 'Playwright MCP must not be configured without proven Chromium.'

$repositoryXml = [xml]@'
<sdk:sdk-repository xmlns:sdk="http://schemas.android.com/sdk/android/repo/repository2/03">
  <remotePackage path="cmdline-tools;22.0"><revision><major>22</major></revision><archives><archive><complete><size>10</size><checksum type="sha1">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB</checksum><url>commandlinetools-win-15859902_latest.zip</url></complete><host-os>windows</host-os></archive></archives></remotePackage>
</sdk:sdk-repository>
'@
$downloadPageHtml = '<table><tr><td>Windows</td><td>commandlinetools-win-15859902_latest.zip</td><td>155.7 MB</td><td>90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a</td></tr></table>'
$androidPackage = Resolve-SgAndroidCommandLineToolsPackage -RepositoryXml $repositoryXml -OfficialDownloadHtml $downloadPageHtml -RepositoryBaseUrl 'https://dl.google.com/android/repository/'
Assert-Sg ($androidPackage.Version -eq '22' -and $androidPackage.SizeBytes -eq 10 -and $androidPackage.Sha256 -eq '90AE805D20434428BFFCB699C290860F19BB5F66A67E6B330067E3DE801FB04A' -and $androidPackage.Url -match '^https://dl[.]google[.]com/') 'Android command-line tools must cross-check repository coordinates, size and the official SHA-256 download table.'
$androidMismatchRejected = $false
try { [void](Resolve-SgAndroidCommandLineToolsPackage -RepositoryXml $repositoryXml -OfficialDownloadHtml ($downloadPageHtml -replace '15859902','99999999') -RepositoryBaseUrl 'https://dl.google.com/android/repository/') } catch { $androidMismatchRejected = $_.Exception.Message -match 'SHA-256|cross-check|package' }
Assert-Sg $androidMismatchRejected 'Android package metadata and official SHA-256 download table must fail closed when filenames differ.'
$jdkPackage = Resolve-SgAdoptiumJdkPackage -ApiObject ([pscustomobject]@{ binary=[pscustomobject]@{ package=[pscustomobject]@{ link='https://github.com/adoptium/temurin17-binaries/releases/download/jdk.zip'; checksum=('B' * 64) } }; version=[pscustomobject]@{ semver='17.0.12+7' } })
Assert-Sg ($jdkPackage.Version -eq '17.0.12+7' -and $jdkPackage.Sha256.Length -eq 64) 'JDK package must carry resolved version and checksum evidence.'

$servicePlan = Get-SgServiceCliPlan -Needs ([pscustomobject]@{ Firebase=$true; FlutterFire=$true; Supabase=$true }) -Versions @{ Firebase='14.2.1'; FlutterFire='1.3.1'; Supabase='2.39.2' }
Assert-Sg (($servicePlan | ForEach-Object Version) -notcontains 'latest') 'Service CLI plan must use exact resolved versions.'
$mutableRejected = $false
try { [void](Get-SgServiceCliPlan -Needs ([pscustomobject]@{ Firebase=$true; FlutterFire=$false; Supabase=$false }) -Versions @{ Firebase='latest' }) } catch { $mutableRejected=$true }
Assert-Sg $mutableRejected 'Mutable service CLI versions must be rejected.'
$toolboxVersions = @{ Firebase='15.27.0'; Supabase='2.45.0'; Convex='1.28.0'; Vercel='59.5.0'; Clerk='3.1.0' }
$toolboxPlan = @(Get-SgMachineToolboxPlan -Versions $toolboxVersions)
Assert-Sg (($toolboxPlan.Name -join '|') -eq 'firebase|supabase|convex|vercel|clerk') 'The machine toolbox must install every approved provider CLI independently of project detection.'
$toolboxConfig = Get-SgMachineToolboxMiseConfig -Plan $toolboxPlan
foreach ($coordinate in @('npm:firebase-tools','aqua:supabase/cli','npm:convex','npm:vercel','npm:clerk')) { Assert-Sg ($toolboxConfig.Contains('"' + $coordinate + '"')) "Machine toolbox config is missing $coordinate." }
Assert-Sg ($toolboxConfig -notmatch '(?im)latest|stable|\*|\^|~') 'Machine toolbox config must contain only exact immutable versions.'
$installerSource = [IO.File]::ReadAllText((Join-Path $root 'cli\windows\install-devserver.ps1'))
$exactToolRetry = '@(''install'',"$($item.Tool)@$($item.Version)")'
Assert-Sg ($installerSource.Contains($exactToolRetry)) 'A partially installed machine toolbox must retry each missing CLI by exact mise coordinate.'
Assert-Sg ($installerSource -match [regex]::Escape('$ready = Test-SgServiceCliResult $repair $verify $wrapper $item.Version')) 'Machine-toolbox readiness must depend on each CLI verification, not the aggregate install exit code.'

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('shipglows-mobile-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $fixture | Out-Null
    $serviceExe = Join-Path $fixture 'service.cmd'; Set-Content -LiteralPath $serviceExe -Value '@echo off'
    $chromiumExe = Join-Path $fixture 'chrome.exe'; Set-Content -LiteralPath $chromiumExe -Value 'fixture'
    Assert-Sg (Test-SgChromiumExecutableResult -ExecutablePath $chromiumExe -Result ([pscustomobject]@{ExitCode=0;Output='Chromium 140.0.7339.0';TimedOut=$false})) 'Runnable Chromium version evidence should pass.'
    Assert-Sg (-not (Test-SgChromiumExecutableResult -ExecutablePath $chromiumExe -Result ([pscustomobject]@{ExitCode=0;Output='';TimedOut=$false}))) 'Chromium exit zero without version evidence must fail.'
    $okResult = [pscustomobject]@{ ExitCode=0; Output='14.2.1'; TimedOut=$false }
    $failedResult = [pscustomobject]@{ ExitCode=1; Output='failed'; TimedOut=$false }
    Assert-Sg (Test-SgServiceCliResult $okResult $okResult $serviceExe '14.2.1') 'Exact installed service CLI should verify.'
    Assert-Sg (Test-SgServiceCliResult $failedResult $okResult $serviceExe '14.2.1') 'Exact final executable evidence must win over an ambiguous installer exit code.'
    Assert-Sg (Test-SgServiceCliResult $null $okResult $serviceExe '14.2.1') 'An already exact service CLI must be reusable without reinstalling it.'
    Assert-Sg (-not (Test-SgServiceCliResult $okResult $failedResult $serviceExe '14.2.1')) 'Missing final executable evidence must fail closed.'
    Assert-Sg (Test-SgServiceCliResult $null ([pscustomobject]@{ExitCode=0;Output='Firebase CLI v14.2.1';TimedOut=$false}) $serviceExe '14.2.1') 'A labeled CLI version with a conventional v prefix should verify exactly.'
    Assert-Sg (-not (Test-SgServiceCliResult $null ([pscustomobject]@{ExitCode=0;Output='114.2.1';TimedOut=$false}) $serviceExe '14.2.1')) 'An adjacent numeric prefix must not satisfy an exact CLI version.'
    Assert-Sg (-not (Test-SgServiceCliResult $null ([pscustomobject]@{ExitCode=0;Output='14.2.1.7';TimedOut=$false}) $serviceExe '14.2.1')) 'An adjacent numeric suffix must not satisfy an exact CLI version.'

    Assert-Sg (Test-SgMiseVersionResult ([pscustomobject]@{ExitCode=0;Output="warning: cached metadata`n2026.8.2 windows-x64 (2026-08-12)";TimedOut=$false})) 'The real calendar-version-first mise output must verify despite a separate warning line.'
    Assert-Sg (Test-SgMiseVersionResult ([pscustomobject]@{ExitCode=0;Output='mise 2026.8.2';TimedOut=$false})) 'The labeled mise calendar version remains compatible.'
    foreach ($invalidMiseOutput in @('x2026.8.2 windows-x64','2026.13.2 windows-x64','2026.8.2.1 windows-x64','1.2.3 windows-x64')) {
        Assert-Sg (-not (Test-SgMiseVersionResult ([pscustomobject]@{ExitCode=0;Output=$invalidMiseOutput;TimedOut=$false}))) "Invalid or non-autonomous mise version output must fail: $invalidMiseOutput"
    }
    Assert-Sg (-not (Test-SgMiseVersionResult ([pscustomobject]@{ExitCode=1;Output='2026.8.2 windows-x64';TimedOut=$false}))) 'A nonzero mise version probe must fail closed.'

    $wrapperFixture = Join-Path $fixture 'wrapper space & caret^ percent% metachar'
    $fakeMise = Join-Path $wrapperFixture 'mise bin\mise.cmd'
    $fakeToolchain = Join-Path $wrapperFixture 'toolchain root & safe'
    $fakeResolvedBin = Join-Path $fixture 'resolved-bin'
    $fakeFirebase = Join-Path $fakeResolvedBin 'firebase.cmd'
    New-Item -ItemType Directory -Path (Split-Path $fakeMise -Parent) -Force | Out-Null
    New-Item -ItemType Directory -Path $fakeToolchain -Force | Out-Null
    New-Item -ItemType Directory -Path $fakeResolvedBin -Force | Out-Null
    Set-Content -LiteralPath $fakeMise -Encoding Ascii -Value @'
@echo off
if "%~3"=="which" if not "%~5"=="" exit /b 91
if "%~3"=="which" if "%~4"=="firebase" (
  echo __FAKE_FIREBASE__
  exit /b 0
)
set "SELF=%~f0"
set SELF
echo SAFE=%MISE_SAFE% HOOKS=%MISE_NO_HOOKS% ENV=%MISE_NO_ENV% AUTO=%MISE_AUTO_INSTALL%
set MISE_CONFIG_DIR
set MISE_CEILING_PATHS
echo ARGS=%*
exit /b 23
'@
    Set-Content -LiteralPath $fakeFirebase -Encoding Ascii -Value "@echo off`r`necho RESOLVED_FIREBASE=%~f0 ARGS=%*`r`nexit /b 23`r`n"
    (Get-Content -LiteralPath $fakeMise -Raw).Replace('__FAKE_FIREBASE__',$fakeFirebase.Substring(0,$fakeFirebase.Length - 4)) | Set-Content -LiteralPath $fakeMise -Encoding Ascii
    # Keep the wrapper itself on a plain path so this fixture exercises the
    # paths embedded by ShipGlows rather than Invoke-SgBoundedProcess's .cmd transport.
    $cargoWrapper = Join-Path $fixture 'cargo-wrapper.cmd'
    [IO.File]::WriteAllText($cargoWrapper,(Get-SgTauriRustWrapperContent -MisePath $fakeMise -ToolchainRoot $fakeToolchain -Command cargo),[Text.Encoding]::ASCII)
    $wrapperRun = Invoke-SgBoundedProcess -File $cargoWrapper -Arguments @('alpha','space value','amp&ersand') -TimeoutSeconds 20
    Assert-Sg ($wrapperRun.ExitCode -eq 23) "Tauri Rust wrapper must preserve the mise child exit code across endlocal. Actual exit=$($wrapperRun.ExitCode); output=$($wrapperRun.Output)"
    Assert-Sg ($wrapperRun.Output -match ('SELF=' + [regex]::Escape($fakeMise))) "Tauri Rust wrapper did not execute the exact mise path containing caret and percent characters. Output=$($wrapperRun.Output)"
    Assert-Sg ($wrapperRun.Output -match 'SAFE=1 HOOKS=1 ENV=1 AUTO=false') 'Tauri Rust wrapper did not reproduce the managed safe environment.'
    Assert-Sg ($wrapperRun.Output -match ('MISE_CONFIG_DIR=' + [regex]::Escape((Join-Path $fakeToolchain '.shipglows-no-user-mise-config')))) 'Tauri Rust wrapper did not isolate the mise config directory.'
    Assert-Sg ($wrapperRun.Output -match ('MISE_CEILING_PATHS=' + [regex]::Escape((Split-Path $fakeToolchain -Parent)))) 'Tauri Rust wrapper did not preserve the mise ceiling boundary.'
    Assert-Sg ($wrapperRun.Output -match 'ARGS=-C .*toolchain root & safe.* exec -- cargo "?alpha"? "space value" "amp&ersand"') 'Tauri Rust wrapper changed mise argv or forwarded argument boundaries.'
    $wrapperText = [IO.File]::ReadAllText($cargoWrapper)
    foreach ($requiredWrapperSetting in @('setlocal DisableDelayedExpansion','MISE_EXEC_AUTO_INSTALL=false','MISE_NOT_FOUND_AUTO_INSTALL=false','MISE_RUN_AUTO_INSTALL=false','MISE_OVERRIDE_CONFIG_FILENAMES=mise.toml','MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES=none','MISE_SYSTEM_DEPS=ignore','endlocal & exit /b')) {
        Assert-Sg ($wrapperText.Contains($requiredWrapperSetting)) "Tauri Rust wrapper omitted isolation or exit preservation: $requiredWrapperSetting"
    }
    $firebaseWrapper = Join-Path $fixture 'firebase-wrapper.cmd'
    [IO.File]::WriteAllText($firebaseWrapper,(Get-SgMachineToolboxWrapperContent -MisePath $fakeMise -ToolboxRoot $fakeToolchain -Command firebase),[Text.Encoding]::ASCII)
    $firebaseWrapperRun = Invoke-SgBoundedProcess -File $firebaseWrapper -Arguments @('--version') -TimeoutSeconds 20
    Assert-Sg ($firebaseWrapperRun.ExitCode -eq 23 -and $firebaseWrapperRun.Output -match 'RESOLVED_FIREBASE=.*ARGS="?--version"?') "Machine toolbox wrapper must resolve the exact mise executable and preserve its child exit code. Exit=$($firebaseWrapperRun.ExitCode); output=$($firebaseWrapperRun.Output)"
    Assert-Sg ([IO.File]::ReadAllText($firebaseWrapper).Contains('which firebase')) 'Machine toolbox wrapper must fail closed through mise which instead of falling back to PATH command resolution.'

    $codexJson = '{"name":"firebase","enabled":true,"transport":{"type":"stdio","command":"C:\\Program Files\\nodejs\\npx.cmd","args":["-y","--registry=https://registry.npmjs.org/","firebase-tools@15.27.0","mcp"]}}'
    $firebaseServer = [pscustomobject]@{ Name='firebase'; Type='local'; Url=''; Command='C:\Program Files\nodejs\npx.cmd'; Arguments=@('-y','--registry=https://registry.npmjs.org/','firebase-tools@15.27.0','mcp') }
    Assert-Sg (Test-SgCodexMcpResult -Result ([pscustomobject]@{ExitCode=0;Output=$codexJson;TimedOut=$false}) -Server $firebaseServer) 'Codex MCP JSON must compare decoded path and argument values, not serialized backslashes.'
    $wrongCodexJson = $codexJson.Replace('15.27.0','15.26.0')
    Assert-Sg (-not (Test-SgCodexMcpResult -Result ([pscustomobject]@{ExitCode=0;Output=$wrongCodexJson;TimedOut=$false}) -Server $firebaseServer)) 'Codex MCP JSON must reject an explicit version mismatch.'
    $externalJdk = Join-Path $fixture 'external-jdk'
    New-Item -ItemType Directory -Path (Join-Path $externalJdk 'bin') -Force | Out-Null
    $externalJava = Join-Path $externalJdk 'bin\java.exe'; Set-Content -LiteralPath $externalJava -Value 'fixture'
    $jdkExisting = Resolve-SgExistingJdk17 -JavaHome $externalJdk -Runner { param($f,$a,$t) [pscustomobject]@{ExitCode=0;Output='openjdk version 17.0.12';TimedOut=$false} }
    Assert-Sg ($jdkExisting.Ready -and -not $jdkExisting.Managed -and $jdkExisting.Home -eq $externalJdk) 'Valid external JDK 17 must be reused without becoming managed.'
    $externalSdk = Join-Path $fixture 'external-sdk'
    $externalSdkManager = Join-Path $externalSdk 'cmdline-tools\latest\bin\sdkmanager.bat'
    New-Item -ItemType Directory -Path (Split-Path $externalSdkManager -Parent) -Force | Out-Null; Set-Content -LiteralPath $externalSdkManager -Value '@exit /b 0'
    $sdkExisting = Resolve-SgExistingAndroidSdk -CandidateRoots @($externalSdk) -Runner { param($f,$a,$t) [pscustomobject]@{ExitCode=0;Output='19.0';TimedOut=$false} }
    Assert-Sg ($sdkExisting.Ready -and -not $sdkExisting.Managed -and $sdkExisting.Root -eq $externalSdk) 'Valid external Android SDK must be reused without becoming managed.'
    $invalidHome = Join-Path $fixture 'invalid-home'
    $sdkFromPath = Resolve-SgExistingAndroidSdk -CandidateRoots @($invalidHome) -SdkManagerCommand $externalSdkManager -Runner { param($f,$a,$t) [pscustomobject]@{ExitCode=0;Output='19.0';TimedOut=$false} }
    Assert-Sg ($sdkFromPath.Ready -and $sdkFromPath.Root -eq $externalSdk) 'A valid PATH sdkmanager must win over invalid inherited Android homes.'
    $javaFromPath = Resolve-SgExistingJdk17 -JavaHome $invalidHome -JavaCommand $externalJava -Runner { param($f,$a,$t) [pscustomobject]@{ExitCode=0;Output='openjdk version 17.0.12';TimedOut=$false} }
    Assert-Sg ($javaFromPath.Ready -and $javaFromPath.Home -eq $externalJdk) 'A valid PATH JDK 17 must win over invalid inherited JAVA_HOME.'
    $androidStudioExe = Join-Path $fixture 'Android Studio\bin\studio64.exe'
    New-Item -ItemType Directory -Path (Split-Path $androidStudioExe -Parent) -Force | Out-Null; Set-Content -LiteralPath $androidStudioExe -Value 'fixture'
    $androidStudioState = Get-SgAndroidStudioState -CandidatePaths @((Join-Path $fixture 'missing.exe'),$androidStudioExe)
    Assert-Sg ($androidStudioState.Ready -and $androidStudioState.Path -eq $androidStudioExe) 'Android Studio detection must select an existing studio64 executable.'
    $vsWhere = Join-Path $fixture 'vswhere.exe'; Set-Content -LiteralPath $vsWhere -Value 'fixture'
    $vsRoot = Join-Path $fixture 'Visual Studio\2022\Community'
    $devenv = Join-Path $vsRoot 'Common7\IDE\devenv.exe'
    New-Item -ItemType Directory -Path (Split-Path $devenv -Parent) -Force | Out-Null; Set-Content -LiteralPath $devenv -Value 'fixture'
    $vsReady = Get-SgVisualStudioCppState -VsWherePath $vsWhere -Runner { param($f,$a,$t) [pscustomobject]@{ ExitCode=0; Output=$vsRoot; TimedOut=$false } }
    Assert-Sg ($vsReady.Ready -and $vsReady.WorkloadReady -and $vsReady.InstallationPath -eq $vsRoot) 'Visual Studio detection must require the native desktop workload and a real IDE executable.'
    $vsPartial = Get-SgVisualStudioCppState -VsWherePath $vsWhere -Runner { param($f,$a,$t) if ($a -contains '-requires') { [pscustomobject]@{ ExitCode=0; Output=''; TimedOut=$false } } else { [pscustomobject]@{ ExitCode=0; Output=$vsRoot; TimedOut=$false } } }
    Assert-Sg ($vsPartial.Installed -and -not $vsPartial.WorkloadReady -and -not $vsPartial.Ready) 'Visual Studio without the native desktop workload must remain repairable.'
    $userJavaBefore = [Environment]::GetEnvironmentVariable('JAVA_HOME','User')
    $userAndroidBefore = [Environment]::GetEnvironmentVariable('ANDROID_HOME','User')
    $userSdkBefore = [Environment]::GetEnvironmentVariable('ANDROID_SDK_ROOT','User')
    $processJavaBefore = $env:JAVA_HOME; $processAndroidBefore = $env:ANDROID_HOME; $processSdkBefore = $env:ANDROID_SDK_ROOT
    try {
        $env:JAVA_HOME=$invalidHome; $env:ANDROID_HOME=$invalidHome; $env:ANDROID_SDK_ROOT=$invalidHome
        Set-SgResolvedToolProcessEnvironment -JdkHome $javaFromPath.Home -SdkRoot $sdkFromPath.Root
        Assert-Sg ($env:JAVA_HOME -eq $externalJdk -and $env:ANDROID_HOME -eq $externalSdk -and $env:ANDROID_SDK_ROOT -eq $externalSdk) 'Resolved external homes must normalize the current process for doctor/sdkmanager children.'
        Assert-Sg ([Environment]::GetEnvironmentVariable('JAVA_HOME','User') -eq $userJavaBefore) 'External JDK resolution must not persist JAVA_HOME.'
        Assert-Sg ([Environment]::GetEnvironmentVariable('ANDROID_HOME','User') -eq $userAndroidBefore -and [Environment]::GetEnvironmentVariable('ANDROID_SDK_ROOT','User') -eq $userSdkBefore) 'External SDK resolution must not persist Android homes.'
    } finally { $env:JAVA_HOME=$processJavaBefore; $env:ANDROID_HOME=$processAndroidBefore; $env:ANDROID_SDK_ROOT=$processSdkBefore }
    $partialFlutter = Join-Path $fixture 'flutter'
    New-Item -ItemType Directory -Path (Join-Path $partialFlutter 'bin') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $partialFlutter 'bin\flutter.bat') -Value '@exit /b 1'
    $partialState = Get-SgFlutterInstallState -FlutterRoot $partialFlutter -Runner { param($f,$a,$timeout) [pscustomobject]@{ ExitCode=1; Output='corrupt'; TimedOut=$false } }
    Assert-Sg ($partialState.Status -eq 'partial' -and $partialState.Recovery -eq 'quarantine') 'Managed partial Flutter clone must be quarantined before safe recovery.'
    Set-Content -LiteralPath (Join-Path $partialFlutter 'bin\dart.bat') -Value '@exit /b 0'
    $readyState = Get-SgFlutterInstallState -FlutterRoot $partialFlutter -Runner { param($f,$a,$timeout) $output=if($f -match 'dart'){'Dart SDK version: 3.9.0'}else{'Flutter 3.35.0'}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    Assert-Sg ($readyState.Status -eq 'ready' -and $readyState.Recovery -eq 'none') 'Existing Flutter must require executable version evidence.'
    $prefixedReadyState = Get-SgFlutterInstallState -FlutterRoot $partialFlutter -Runner { param($f,$a,$timeout) $output=if($f -match 'dart'){'Dart SDK version: 3.13.1'}else{$revision='6655482ec0'; $bullet=[char]0x2022; "Flutter $bullet channel [user-branch] $bullet https://github.com/flutter/flutter.git`nFramework $bullet revision $revision`nTools $bullet Dart 3.13.1 $bullet DevTools 2.60.0"}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    Assert-Sg ($prefixedReadyState.Status -eq 'ready') 'A valid detached Flutter SDK with exact framework and Dart evidence must not become a false negative.'
    $tooShortRevision = Get-SgFlutterInstallState -FlutterRoot $partialFlutter -Runner { param($f,$a,$timeout) $output=if($f -match 'dart'){'Dart SDK version: 3.13.1'}else{$bullet=[char]0x2022; "Flutter $bullet channel [user-branch]`nFramework $bullet revision abc123`nTools $bullet Dart 3.13.1"}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    Assert-Sg ($tooShortRevision.Status -eq 'partial') 'A detached Flutter checkout must retain a credible Git revision abbreviation.'
    $unprovenUserBranch = Get-SgFlutterInstallState -FlutterRoot $partialFlutter -Runner { param($f,$a,$timeout) $output=if($f -match 'dart'){'Dart SDK version: 3.13.1'}else{"Flutter $([char]0x2022) channel [user-branch]"}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    Assert-Sg ($unprovenUserBranch.Status -eq 'partial') 'A detached Flutter label without framework revision and Dart evidence must fail closed.'
    $empty = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg (-not $empty.Dart -and -not $empty.Playwright -and -not $empty.GitHub -and -not $empty.Firebase -and -not $empty.FlutterFire -and -not $empty.Supabase -and -not $empty.Convex -and -not $empty.Vercel -and -not $empty.Clerk -and -not $empty.AndroidNative) 'Zero-service workspace detected false dependencies.'
    $oneProject = Join-Path $fixture 'one\nested'
    New-Item -ItemType Directory -Path $oneProject -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $oneProject 'firebase.json') -Value '{}'
    $one = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg ($one.Firebase -and -not $one.FlutterFire -and -not $one.Supabase) 'One nested service need was not detected exactly.'
    Set-Content -LiteralPath (Join-Path $fixture 'pubspec.yaml') -Value "dependencies:`n  firebase_core: any"
    Set-Content -LiteralPath (Join-Path $fixture 'package.json') -Value '{"dependencies":{"convex":"^1.0.0","@clerk/astro":"^6.0.0"},"scripts":{"deploy":"vercel"}}'
    Set-Content -LiteralPath (Join-Path $fixture 'vercel.json') -Value '{}'
    New-Item -ItemType Directory -Path (Join-Path $fixture '.git') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fixture 'android\app') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $fixture 'android\app\CMakeLists.txt') -Value 'cmake_minimum_required(VERSION 3.22.1)'
    New-Item -ItemType Directory -Path (Join-Path $fixture 'supabase') | Out-Null
    Set-Content -LiteralPath (Join-Path $fixture 'supabase\config.toml') -Value 'project_id = "fixture"'
    $many = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg ($many.Dart -and -not $many.Playwright -and $many.GitHub -and $many.Firebase -and $many.FlutterFire -and $many.Supabase -and $many.Convex -and $many.Vercel -and $many.Clerk -and $many.AndroidNative) 'Many-service workspace detection is incomplete.'
    $bounded = Get-SgProjectServiceNeeds -Workspace $fixture -MaxDirectories 1
    Assert-Sg ($bounded.ScanLimitReached) 'Service scanning must stop at its directory bound.'

    $tauriRoot = Join-Path $fixture 'tauri-contracts'
    $readyProject = Join-Path $tauriRoot 'ready'
    New-Item -ItemType Directory -Path (Join-Path $readyProject 'src-tauri\gen\android\app') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $readyProject 'package.json') -Value ('{"devDependencies":{"@tauri-apps/cli":"' + $tauriBaseline.TauriCliVersion + '"},"dependencies":{"@tauri-apps/api":"' + $tauriBaseline.TauriApiVersion + '"}}')
    Set-Content -LiteralPath (Join-Path $readyProject 'src-tauri\Cargo.toml') -Value ("[package]`nname=`"ready`"`nrust-version=`"1.88.0`"`n[build-dependencies]`ntauri-build=`"=$($tauriBaseline.TauriBuildVersion)`"`n[dependencies]`ntauri=`"=$($tauriBaseline.TauriRustVersion)`"")
    Set-Content -LiteralPath (Join-Path $readyProject 'src-tauri\gen\android\app\build.gradle.kts') -Value ("android { compileSdk = $($tauriBaseline.AndroidApiLevel); buildToolsVersion = `"$($tauriBaseline.BuildToolsVersion)`"; ndkVersion = `"$($tauriBaseline.NdkVersion)`" }")
    $readyTauri = Get-SgTauriAndroidProjectState -Workspace $readyProject -Baseline $tauriBaseline
    Assert-Sg ($readyTauri.IsTauri -and $readyTauri.Status -eq 'ready' -and @($readyTauri.Differences).Count -eq 0) 'An exact Tauri Android baseline match must be ready.'

    Set-Content -LiteralPath (Join-Path $readyProject 'src-tauri\gen\android\app\build.gradle.kts') -Value ("android { compileSdk = $($tauriBaseline.AndroidApiLevel) }")
    $implicitHostTauri = Get-SgTauriAndroidProjectState -Workspace $readyProject -Baseline $tauriBaseline
    Assert-Sg ($implicitHostTauri.Status -eq 'ready' -and @($implicitHostTauri.Differences | Where-Object { $_ -match 'BuildToolsVersion|NdkVersion' }).Count -eq 0) 'Omitted host-owned Build Tools and NDK declarations must not force a project migration.'
    Set-Content -LiteralPath (Join-Path $readyProject 'src-tauri\gen\android\app\build.gradle.kts') -Value ("android { compileSdk = $($tauriBaseline.AndroidApiLevel); ndkVersion = `"28.0.13004108`" }")
    $explicitNdkMismatch = Get-SgTauriAndroidProjectState -Workspace $readyProject -Baseline $tauriBaseline
    Assert-Sg ($explicitNdkMismatch.Status -eq 'migration_required' -and ($explicitNdkMismatch.Differences -join '|') -match 'NdkVersion') 'An explicit project NDK mismatch must remain a migration difference.'
    Set-Content -LiteralPath (Join-Path $readyProject 'src-tauri\gen\android\app\build.gradle.kts') -Value ("android { compileSdk = $($tauriBaseline.AndroidApiLevel); buildToolsVersion = `"$($tauriBaseline.BuildToolsVersion)`"; ndkVersion = `"$($tauriBaseline.NdkVersion)`" }")

    $oldProject = Join-Path $tauriRoot 'old'
    Copy-Item -LiteralPath $readyProject -Destination $oldProject -Recurse
    Set-Content -LiteralPath (Join-Path $oldProject 'package.json') -Value '{"devDependencies":{"@tauri-apps/cli":"2.0.0"},"dependencies":{"@tauri-apps/api":"2.0.0"}}'
    $oldTauri = Get-SgTauriAndroidProjectState -Workspace $oldProject -Baseline $tauriBaseline
    Assert-Sg ($oldTauri.Status -eq 'migration_required' -and @($oldTauri.Differences).Count -ge 1) 'An older Tauri project must require migration rather than provisioning an old toolchain.'
    $handoff = New-SgTauriAndroidMigrationHandoff -ProjectState $oldTauri -Baseline $tauriBaseline
    Assert-Sg ($handoff.Schema -eq 'shipglows.tauri-android-migration-handoff/v1' -and $handoff.Action -eq 'offer_codex' -and -not $handoff.ProjectMutationAuthorized) 'Migration handoff must remain opt-in and must not authorize project mutation.'
    Assert-Sg (($handoff.Differences -join '|') -eq ((@($handoff.Differences) | Sort-Object) -join '|')) 'Migration handoff differences must be deterministic.'
    Assert-Sg (($handoff | ConvertTo-Json -Depth 8) -notmatch '(?i)token|secret|password|authorization') 'Migration handoff must not expose secret-bearing project content.'

    $unknownProject = Join-Path $tauriRoot 'unknown'
    New-Item -ItemType Directory -Path (Join-Path $unknownProject 'src-tauri') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $unknownProject 'package.json') -Value '{"dependencies":{"@tauri-apps/api":'
    Set-Content -LiteralPath (Join-Path $unknownProject 'src-tauri\Cargo.toml') -Value "[dependencies]`ntauri = `"2`""
    $unknownTauri = Get-SgTauriAndroidProjectState -Workspace $unknownProject -Baseline $tauriBaseline
    Assert-Sg ($unknownTauri.IsTauri -and $unknownTauri.Status -eq 'unknown') 'Malformed or incomplete Tauri declarations must remain unknown, never ready.'

    $negativeProject = Join-Path $tauriRoot 'negative'
    New-Item -ItemType Directory -Path $negativeProject -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $negativeProject 'package.json') -Value '{"name":"plain-web"}'
    $negativeTauri = Get-SgTauriAndroidProjectState -Workspace $negativeProject -Baseline $tauriBaseline
    Assert-Sg (-not $negativeTauri.IsTauri -and $negativeTauri.Status -eq 'unknown') 'A non-Tauri project must not become a false ready match.'

    $monorepo = Join-Path $tauriRoot 'monorepo'
    New-Item -ItemType Directory -Path (Join-Path $monorepo 'apps') -Force | Out-Null
    Copy-Item -LiteralPath $readyProject -Destination (Join-Path $monorepo 'apps\desktop') -Recurse
    $monorepoTauri = Get-SgTauriAndroidProjectState -Workspace $monorepo -Baseline $tauriBaseline
    Assert-Sg ($monorepoTauri.IsTauri -and $monorepoTauri.Status -eq 'ready' -and $monorepoTauri.ProjectRoot -eq (Join-Path $monorepo 'apps\desktop')) 'Bounded inspection must find one nested Tauri project and report its exact root.'

    $outsideProject = Join-Path $fixture 'outside-tauri'
    Copy-Item -LiteralPath $readyProject -Destination $outsideProject -Recurse
    $reparseRoot = Join-Path $tauriRoot 'reparse-only'
    New-Item -ItemType Directory -Path $reparseRoot -Force | Out-Null
    New-Item -ItemType Junction -Path (Join-Path $reparseRoot 'linked') -Target $outsideProject | Out-Null
    $reparseState = Get-SgTauriAndroidProjectState -Workspace $reparseRoot -Baseline $tauriBaseline
    Assert-Sg (-not $reparseState.IsTauri -and $reparseState.Status -eq 'unknown') 'Tauri inspection must never traverse reparse points.'

    $stackVersions = @{ Firebase='14.0.0'; FlutterFire='1.3.1'; Supabase='2.45.0'; Convex='1.28.0'; Vercel='48.0.0'; Clerk='0.4.0' }
    $stackPlan = @(Get-SgServiceCliPlan $many $stackVersions)
    Assert-Sg (($stackPlan.Name -join '|') -eq 'firebase|flutterfire|supabase|convex|vercel|clerk') 'Preferred-stack CLI plan must cover Firebase, FlutterFire, Supabase, Convex, Vercel, and Clerk.'
    Assert-Sg (@($stackPlan | Where-Object { $_.Version -notmatch '^\d+\.\d+\.\d+' }).Count -eq 0) 'Every service CLI must use an exact resolved version.'

    $agentPlan = Get-SgAgentInstallPlan -Interactive $true -Choice 'yes' -AgentReady @{ Codex=$false; Claude=$true; OpenCode=$false; Kilo=$false; Gemini=$false }
    Assert-Sg ($agentPlan.Ask -and ($agentPlan.Install -join '|') -eq 'Codex|OpenCode|Kilo|Gemini' -and -not ($agentPlan.Install -contains 'Claude')) 'Agent proposal must install only missing coding-agent CLIs, including Gemini.'
    $agentHeadless = Get-SgAgentInstallPlan -Interactive $false -Choice 'yes' -AgentReady @{ Codex=$false; Claude=$false; OpenCode=$false; Kilo=$false; Gemini=$false }
    $agentUpgrade = Get-SgAgentInstallPlan -Interactive $true -Choice 'yes' -AgentReady @{ Codex=$true; Claude=$true; OpenCode=$true; Kilo=$true; Gemini=$true } -AgentOutdated @{ Codex=$true; Claude=$false; OpenCode=$false; Kilo=$false; Gemini=$false }
    Assert-Sg ($agentUpgrade.Ask -and $agentUpgrade.Outdated -contains 'Codex' -and $agentUpgrade.Install -contains 'Codex') 'Existing outdated agent CLIs must use the grouped consent plan.'
    $agentUpgradeHeadless = Get-SgAgentInstallPlan -Interactive $false -Choice 'yes' -AgentReady @{ Codex=$true; Claude=$true; OpenCode=$true; Kilo=$true; Gemini=$true } -AgentOutdated @{ Codex=$true }
    Assert-Sg (-not $agentUpgradeHeadless.Ask -and $agentUpgradeHeadless.Status -eq 'pending' -and -not @($agentUpgradeHeadless.Install).Count) 'Non-interactive reruns must not infer consent for agent upgrades.'
    Assert-Sg (-not $agentHeadless.Ask -and @($agentHeadless.Install).Count -eq 0 -and $agentHeadless.Status -eq 'pending') 'Noninteractive installs must not infer coding-agent consent.'

    $developerModePlan = Get-SgDeveloperModeGuidancePlan -Interactive $true -DeveloperModeReady $false -Choice 'yes'
    Assert-Sg ($developerModePlan.Ask -and $developerModePlan.OpenSettings -and $developerModePlan.SettingsUri -eq 'ms-settings:developers') 'Developer Mode guidance must offer the official Windows settings surface without changing policy.'
    Assert-Sg (-not $developerModePlan.ChangeRegistry) 'Developer Mode guidance must never mutate the registry.'

    $stackMcps = @(Get-SgStackMcpDefinitions $many $stackVersions 'C:\Program Files\nodejs\npx.cmd')
    Assert-Sg (($stackMcps.Name -join '|') -eq 'firebase|convex|clerk|supabase|vercel|github') 'Detected project stacks must receive their approved MCPs and the project-local read-only GitHub MCP.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'firebase').Arguments -join ' ' -eq '-y --registry=https://registry.npmjs.org/ firebase-tools@14.0.0 mcp') 'Firebase MCP must use the exact resolved firebase-tools version.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'convex').Arguments -join ' ' -eq '-y --registry=https://registry.npmjs.org/ convex@1.28.0 mcp start') 'Convex MCP must use the official CLI entrypoint and exact version.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'clerk').Type -eq 'remote' -and ($stackMcps | Where-Object Name -eq 'clerk').Url -eq 'https://mcp.clerk.com/mcp') 'Clerk MCP must use the official remote endpoint.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'supabase').ReadOnly -and ($stackMcps | Where-Object Name -eq 'supabase').Url -match 'read_only=true') 'Supabase MCP must default to the official read-only remote endpoint.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'vercel').Url -eq 'https://mcp.vercel.com') 'Vercel MCP must use the official remote endpoint.'
    Assert-Sg (($stackMcps | Where-Object Name -eq 'github').Type -eq 'remote' -and ($stackMcps | Where-Object Name -eq 'github').Url -eq 'https://api.githubcopilot.com/mcp/readonly') 'GitHub MCP must default to the official read-only endpoint.'
    $remoteAgentPlan = Get-SgAgentMcpPlan OpenCode 'opencode.cmd' 'dart.bat' 'npx.cmd' '0.0.42' $true $stackMcps
    Assert-Sg ($remoteAgentPlan.Config.mcp.servers.clerk.type -eq 'remote' -and $remoteAgentPlan.Config.mcp.servers.github.url -match '/readonly$') 'JSON agent plans must preserve remote MCP transport and read-only GitHub scope.'
    $remoteKiloPlan = Get-SgAgentMcpPlan Kilo 'kilo.cmd' 'dart.bat' 'npx.cmd' '0.0.42' $true $stackMcps
    Assert-Sg ($remoteKiloPlan.Config.mcp.clerk.url -eq 'https://mcp.clerk.com/mcp' -and $remoteKiloPlan.Config.mcp.github.type -eq 'remote') 'Kilo plans must preserve Clerk and GitHub remote MCP definitions.'
    $globalMcps = @(Get-SgStackMcpDefinitions $empty @{} 'npx.cmd')
    Assert-Sg ($globalMcps.Count -eq 0) 'A project without Git metadata or optional stacks must not receive an MCP activation.'
    $flutterFireOnlyMcps = @(Get-SgStackMcpDefinitions ([pscustomobject]@{ Firebase=$false; FlutterFire=$true; Convex=$false; Clerk=$false; GitHub=$false }) @{ Firebase='14.0.0' } 'npx.cmd')
    Assert-Sg (($flutterFireOnlyMcps.Name -join '|') -eq 'firebase') 'FlutterFire dependency evidence must activate only the Firebase MCP without requiring firebase.json.'

    $projectMcps = @(Get-SgProjectMcpDefinitions -Needs $many -Versions $stackVersions -DartPath 'C:\Program Files\flutter\bin\dart.bat' -NpxPath 'C:\Program Files\nodejs\npx.cmd' -Playwright ([pscustomobject]@{ Ready=$true; Version='0.0.42' }))
    Assert-Sg (($projectMcps.Name -join '|') -eq 'dart|firebase|convex|clerk|supabase|vercel|github') 'Per-project MCP inventory must combine language, detected providers, and GitHub without adding Playwright to a non-web manifest.'
    foreach ($agentName in @('Codex','Claude','Gemini','OpenCode','Kilo')) {
        $projectConfig = Get-SgProjectAgentMcpConfigPlan -Agent $agentName -ProjectPath $fixture -Servers $projectMcps
        Assert-Sg ($projectConfig.ConfigPath.StartsWith([IO.Path]::GetFullPath($fixture),[StringComparison]::OrdinalIgnoreCase)) "$agentName MCP configuration must be rooted in the managed project."
        Assert-Sg (($projectConfig.ServerNames -join '|') -eq ($projectMcps.Name -join '|')) "$agentName MCP configuration lost a project server."
        if ($agentName -eq 'OpenCode') {
            $openCodeProjectConfig = $projectConfig.Content | ConvertFrom-Json
            Assert-Sg ($openCodeProjectConfig.mcp.servers.github.disabled -eq $false -and -not $openCodeProjectConfig.mcp.servers.github.PSObject.Properties['enabled']) 'OpenCode v2 project MCP must use disabled=false rather than the legacy enabled field.'
        }
    }
    $codexProjectConfig = Get-SgProjectAgentMcpConfigPlan -Agent Codex -ProjectPath $fixture -Servers $projectMcps
    Assert-Sg ($codexProjectConfig.RelativePath -eq '.codex\config.toml' -and $codexProjectConfig.Content -match '(?m)^\[mcp_servers\.dart\]$') 'Codex MCP activation must be emitted in project .codex/config.toml.'

    $managedConfig = Join-Path $fixture 'managed-config.json'
    $firstWrite = Write-SgManagedProjectConfig -ConfigPath $managedConfig -Content "one`n"
    Assert-Sg ($firstWrite.Status -eq 'create' -and [IO.File]::ReadAllText($managedConfig) -ceq "one`n") 'Missing project MCP config must be created atomically.'
    Assert-Sg ((Write-SgManagedProjectConfig -ConfigPath $managedConfig -Content "one`n").Status -eq 'unchanged') 'Converged project MCP config must remain unchanged.'
    $managedHash = $firstWrite.ExpectedHash
    [IO.File]::WriteAllText($managedConfig,"user-owned`n",[Text.UTF8Encoding]::new($false))
    $preservedWrite = Write-SgManagedProjectConfig -ConfigPath $managedConfig -Content "two`n" -RecordedHash $managedHash
    Assert-Sg ($preservedWrite.Status -eq 'pending' -and [IO.File]::ReadAllText($managedConfig) -ceq "user-owned`n") 'Divergent project MCP config must remain byte-preserved without maintainer authority.'
    [IO.File]::WriteAllText($managedConfig,"one`n",[Text.UTF8Encoding]::new($false))
    Assert-Sg ((Write-SgManagedProjectConfig -ConfigPath $managedConfig -Content "two`n" -RecordedHash $managedHash).Status -eq 'replace-managed') 'Previously recorded ShipGlows project config must be safely replaceable.'
    Assert-Sg ((Write-SgManagedProjectConfig -ConfigPath $managedConfig -Content "three`n" -ReplaceExisting).Status -eq 'replace-managed') 'Explicit maintainer replacement must converge a divergent project MCP config.'
    $mcpCatalog = [IO.File]::ReadAllText((Join-Path $root 'cli\windows\ShipGlows.McpCatalog.json')) | ConvertFrom-Json
    Assert-Sg ($mcpCatalog.schema -eq 'shipglows.mcp-catalog/v1' -and -not $mcpCatalog.policy.registryIsExecutionAuthority -and -not $mcpCatalog.policy.automaticAuthentication -and -not $mcpCatalog.policy.automaticGoogleCloudActivation) 'MCP catalog must keep discovery separate from trust, authentication, and activation.'
    Assert-Sg ((@($mcpCatalog.servers | Where-Object id -eq 'google-cloud')[0].activation) -eq 'explicit-project-choice') 'Google Cloud MCPs must remain catalog-only until explicitly selected per project.'

    $geminiLocalArguments = @(Get-SgGeminiMcpAddArguments ([pscustomobject]@{ Name='dart'; Type='local'; Command='C:\Program Files\dart.bat'; Arguments=@('mcp-server','--force-roots-fallback') }))
    Assert-Sg (($geminiLocalArguments -join '|') -eq 'mcp|add|--scope|user|dart|C:\Program Files\dart.bat|mcp-server|--force-roots-fallback') 'Gemini local MCP arguments must use the official user-scope CLI syntax.'
    $geminiRemoteArguments = @(Get-SgGeminiMcpAddArguments ([pscustomobject]@{ Name='github'; Type='remote'; Url='https://api.githubcopilot.com/mcp/readonly'; Command=''; Arguments=@() }))
    Assert-Sg (($geminiRemoteArguments -join '|') -eq 'mcp|add|--scope|user|--transport|http|github|https://api.githubcopilot.com/mcp/readonly') 'Gemini remote MCP arguments must use official Streamable HTTP user scope.'
    $geminiSettings = Join-Path $fixture '.gemini\settings.json'
    New-Item -ItemType Directory -Path (Split-Path $geminiSettings -Parent) -Force | Out-Null
    [IO.File]::WriteAllText($geminiSettings, '{"foreign":{"secret":"keep"},"mcpServers":{"github":{"httpUrl":"https://api.githubcopilot.com/mcp/readonly"}}}')
    Assert-Sg ((Get-SgGeminiMcpConfigState $geminiSettings ([pscustomobject]@{ Name='github'; Type='remote'; Url='https://api.githubcopilot.com/mcp/readonly'; Command=''; Arguments=@() })).Status -eq 'ready') 'Gemini must recognize an exact existing remote MCP without connecting.'
    $geminiHash = (Get-FileHash $geminiSettings -Algorithm SHA256).Hash
    Assert-Sg ((Get-SgGeminiMcpConfigState $geminiSettings ([pscustomobject]@{ Name='github'; Type='remote'; Url='https://different.invalid/mcp'; Command=''; Arguments=@() })).Status -eq 'pending') 'Gemini must preserve an existing non-converged MCP entry.'
    Assert-Sg ((Get-FileHash $geminiSettings -Algorithm SHA256).Hash -eq $geminiHash) 'Gemini MCP planning changed an existing secret-bearing settings file.'

    $jsoncPreferred = Join-Path $fixture '.config\opencode\opencode.jsonc'
    $jsonFallback = Join-Path $fixture '.config\opencode\opencode.json'
    New-Item -ItemType Directory -Path (Split-Path $jsoncPreferred -Parent) -Force | Out-Null
    [IO.File]::WriteAllText($jsoncPreferred, "{`n // preserve`n}`n")
    [IO.File]::WriteAllText($jsonFallback, '{}')
    $resolvedConfig = Resolve-SgAgentConfigPath -Agent OpenCode -UserProfile $fixture
    Assert-Sg ($resolvedConfig.Path -eq $jsoncPreferred -and $resolvedConfig.Exists -and $resolvedConfig.IsJsonc) 'Installer config resolution must prefer existing JSONC over JSON.'
    $resolvedPlan = Get-SgAgentConfigWritePlan -ConfigPath $resolvedConfig.Path -Config ([ordered]@{ mcp=[ordered]@{} })
    Assert-Sg ($resolvedPlan.Status -eq 'pending' -and [IO.File]::ReadAllText($jsoncPreferred).Contains('// preserve')) 'Resolved JSONC must remain byte-preserved and pending.'

    $config = Join-Path $fixture 'agent.json'
    [IO.File]::WriteAllText($config, '{"provider":{"secret":"keep-me"},"mcp":{"foreign":{"type":"remote","url":"https://example.invalid"}}}')
    $servers = [ordered]@{
        playwright = [ordered]@{ type='local'; command=@('npx.cmd','-y','--registry=https://registry.npmjs.org/','@playwright/mcp@0.0.42','--headless','--browser','chromium'); enabled=$true }
        dart = [ordered]@{ type='local'; command=@('dart.exe','mcp-server','--force-roots-fallback'); enabled=$true }
    }
    $hash = (Get-FileHash $config -Algorithm SHA256).Hash
    $existingPlan = Get-SgAgentConfigWritePlan -ConfigPath $config -Config ([ordered]@{ mcp=$servers })
    Assert-Sg ($existingPlan.Status -eq 'pending' -and $existingPlan.Reason -match 'existing') 'Existing JSON must use native CLI or remain pending.'
    Assert-Sg ((Get-FileHash $config -Algorithm SHA256).Hash -eq $hash) 'Existing config or secret changed during planning.'
    Assert-Sg (-not (Test-Path "$config.shipglows-backup-*")) 'Secret-bearing backups must not be created.'
    $maintainerPlan = Get-SgAgentConfigWritePlan -ConfigPath $config -Config ([ordered]@{ mcp=$servers }) -ReplaceExisting
    Assert-Sg ($maintainerPlan.Status -eq 'replace-existing' -and $maintainerPlan.Reason -match 'maintainer') 'Explicit maintainer planning must own a divergent JSON agent config.'
    Assert-Sg (Write-SgNewAgentConfig -ConfigPath $config -Config ([ordered]@{ mcp=$servers }) -ReplaceExisting) 'Explicit maintainer mode must replace a divergent JSON agent config atomically.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $config -Config ([ordered]@{ mcp=$servers })).Status -eq 'unchanged') 'Maintainer JSON replacement must converge idempotently.'
    Assert-Sg (-not (Test-Path "$config.shipglows-backup-*")) 'Maintainer JSON replacement must not create a secret-bearing backup.'
    $jsonc = Join-Path $fixture 'agent.jsonc'
    [IO.File]::WriteAllText($jsonc, "{`n // keep this comment`n `"provider`": { `"secret`": `"keep-me`" }`n}")
    $jsoncHash = (Get-FileHash $jsonc -Algorithm SHA256).Hash
    $jsoncPlan = Get-SgAgentConfigWritePlan -ConfigPath $jsonc -Config ([ordered]@{ mcp=$servers })
    Assert-Sg ($jsoncPlan.Status -eq 'pending' -and (Get-FileHash $jsonc -Algorithm SHA256).Hash -eq $jsoncHash) 'JSONC comments/secrets must be preserved byte-for-byte.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $jsonc -Config ([ordered]@{ mcp=$servers }) -ReplaceExisting).Status -eq 'replace-existing') 'Explicit maintainer planning must own a divergent JSONC agent config.'
    Assert-Sg (Write-SgNewAgentConfig -ConfigPath $jsonc -Config ([ordered]@{ mcp=$servers }) -ReplaceExisting) 'Explicit maintainer mode must replace a divergent JSONC agent config atomically.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $jsonc -Config ([ordered]@{ mcp=$servers })).Status -eq 'unchanged') 'Maintainer JSONC replacement must converge idempotently.'
    Assert-Sg (-not (Test-Path "$jsonc.shipglows-backup-*")) 'Maintainer JSONC replacement must not create a secret-bearing backup.'
    $skeleton = Join-Path $fixture 'kilo-skeleton.jsonc'
    $kiloConfig = [ordered]@{ '$schema'='https://app.kilo.ai/config.json'; mcp=$servers }
    [IO.File]::WriteAllText($skeleton, "{`n  `"`$schema`": `"https://app.kilo.ai/config.json`"`n}`n")
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $skeleton -Config $kiloConfig).Status -eq 'replace-skeleton') 'A schema-only Kilo skeleton should be safely replaceable.'
    Assert-Sg (Write-SgNewAgentConfig -ConfigPath $skeleton -Config $kiloConfig -ReplaceSkeleton) 'Schema-only Kilo config should be completed atomically.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $skeleton -Config $kiloConfig).Status -eq 'unchanged') 'Completed Kilo config should converge idempotently.'
    $foreignSkeleton = Join-Path $fixture 'kilo-foreign.jsonc'
    [IO.File]::WriteAllText($foreignSkeleton, "{`n  `"`$schema`": `"https://app.kilo.ai/config.json`",`n  `"theme`": `"custom`"`n}`n")
    $foreignHash = (Get-FileHash $foreignSkeleton -Algorithm SHA256).Hash
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $foreignSkeleton -Config $kiloConfig).Status -eq 'pending') 'A Kilo config with user fields must remain protected.'
    Assert-Sg ((Get-FileHash $foreignSkeleton -Algorithm SHA256).Hash -eq $foreignHash) 'Protected Kilo config changed during planning.'
    $newConfig = Join-Path $fixture 'new-agent.json'
    Assert-Sg (Write-SgNewAgentConfig -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers })) 'Absent config should be created atomically.'
    Assert-Sg (-not (Write-SgNewAgentConfig -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers }))) 'New-config rerun must converge idempotently.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers })).Status -eq 'unchanged') 'Managed new-config rerun must report converged state.'

    $calls = New-Object Collections.Generic.List[string]
    $runner = { param($File, $Arguments, $TimeoutSeconds) [void]$calls.Add("$File $($Arguments -join ' ')"); $joined=$Arguments -join ' '; if ($File -match 'dart') { $output='Dart SDK version: 3.9.0' } elseif ($joined -eq '--version') { $output='Flutter 3.35.0' } elseif ($joined -eq '-version') { $output='openjdk version 17' } elseif ($joined -eq 'doctor -v') { $check=[char]0x2713; $output="[$check] Flutter`n[$check] Android toolchain - develop for Android devices`n    All Android licenses accepted." } elseif ($joined -eq 'devices') { $output='Pixel | device-1 | android-arm64 | Android 15' } elseif ($File -match 'adb') { $output='Android Debug Bridge version 1.0.41' } else { $output='Version 1.0' }; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    $diag = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath 'emulator.exe' -Runner $runner
    Assert-Sg ($diag.ToolchainReady -and $diag.LicensesReady -and $diag.DeviceReady) 'Healthy diagnostic did not report separate readiness surfaces.'
    Assert-Sg (($calls -join '|') -match 'doctor -v' -and ($calls -join '|') -match 'devices') 'flutter doctor/devices were not executed.'
    $detachedDiagnosticRunner = { param($File,$Arguments,$TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.13.1'}elseif($joined -eq '--version' -and $File -match 'flutter'){$bullet=[char]0x2022;$output="Flutter $bullet channel [user-branch] $bullet https://github.com/flutter/flutter.git`nFramework $bullet revision 6655482ec0`nTools $bullet Dart 3.13.1 $bullet DevTools 2.60.0"}elseif($joined -eq '-version'){$output='openjdk version 17.0.20'}elseif($joined -eq 'doctor -v'){$check=[char]0x2713;$output="[$check] Android toolchain - develop for Android devices (Android SDK version 36.0.0)`n    All Android licenses accepted."}elseif($joined -eq 'devices'){$output='Pixel | device-1 | android-arm64 | Android 15'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ExitCode=0;Output=$output;TimedOut=$false} }
    $detachedDiagnostic = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.bat' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath 'emulator.exe' -Runner $detachedDiagnosticRunner
    Assert-Sg ($detachedDiagnostic.ToolchainReady -and $detachedDiagnostic.LicensesReady) 'The validated managed detached Flutter checkout must satisfy Android readiness evidence.'
    $zeroEvidence = { param($File, $Arguments, $TimeoutSeconds) [pscustomobject]@{ ExitCode=0; Output='ok'; TimedOut=$false } }
    $broken = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $zeroEvidence
    Assert-Sg (-not $broken.ToolchainReady -and -not $broken.DeviceReady) 'Exit zero alone must never establish readiness.'
    $timeoutRunner = { param($File, $Arguments, $TimeoutSeconds) [pscustomobject]@{ ExitCode=-1; Output='timed out'; TimedOut=$true } }
    $timedOut = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $timeoutRunner
    Assert-Sg ($timedOut.TimedOut -and -not $timedOut.ToolchainReady) 'Timed-out diagnostics must fail closed.'
    $zeroDeviceRunner = { param($File, $Arguments, $TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.9.0'}elseif($joined -eq '--version'){$output='Flutter 3.35.0'}elseif($joined -eq '-version'){$output='openjdk version 17'}elseif($joined -eq 'doctor -v'){$windowsCheck=[char]0x221A;$bullet=[char]0x2022;$output="[$windowsCheck] Flutter`n[$windowsCheck] Android toolchain - develop for Android devices (Android SDK version 36.0.0) [2,5s]`n    $bullet All Android licenses accepted."}elseif($joined -eq 'devices'){$output='No devices detected.'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    $zeroDevice = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $zeroDeviceRunner
    Assert-Sg ($zeroDevice.ToolchainReady -and $zeroDevice.LicensesReady -and -not $zeroDevice.DeviceReady) 'Zero-device state must remain separate from toolchain readiness.'

    $mojibakeDoctorRunner = { param($File,$Arguments,$TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.12.2'}elseif($joined -eq '--version'){$output='Flutter 3.44.9'}elseif($joined -eq '-version'){$output='openjdk version 17.0.20'}elseif($joined -eq 'doctor -v'){$marker=([char]0x00D4)+([char]0x00EA)+([char]0x00DC);$mojibakeBullet=([char]0x00D4)+([char]0x00C7)+([char]0x00B3);$output="[$marker] Android toolchain - develop for Android devices (Android SDK version 36.0.0)`n    $mojibakeBullet All Android licenses accepted.`n$mojibakeBullet No issues found!"}elseif($joined -eq 'devices'){$output='No devices detected.'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ExitCode=0;Output=$output;TimedOut=$false} }
    $mojibakeHealthy = Get-SgFlutterAndroidDiagnostic 'flutter.exe' 'dart.bat' 'java.exe' 'sdkmanager.bat' 'adb.exe' '' $mojibakeDoctorRunner
    Assert-Sg ($mojibakeHealthy.ToolchainReady -and $mojibakeHealthy.LicensesReady) 'A healthy localized/mojibake flutter doctor report must not become a false negative.'

    foreach ($marker in @('[!] Android toolchain - licenses not accepted','[X] Android toolchain - missing')) {
        $badDoctor = { param($File,$Arguments,$TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.9.0'}elseif($joined -eq '--version'){$output='Flutter 3.35.0'}elseif($joined -eq '-version'){$output='openjdk version 17'}elseif($joined -eq 'doctor -v'){$output=$marker}elseif($joined -eq 'devices'){$output='No devices detected.'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ExitCode=0;Output=$output;TimedOut=$false} }.GetNewClosure()
        $bad = Get-SgFlutterAndroidDiagnostic 'flutter.exe' 'dart.bat' 'java.exe' 'sdkmanager.bat' 'adb.exe' '' $badDoctor
        Assert-Sg (-not $bad.ToolchainReady -and -not $bad.LicensesReady) "Doctor marker $marker must fail closed."
    }

    $transportDirectory = Join-Path $fixture 'transport with spaces'
    New-Item -ItemType Directory -Path $transportDirectory | Out-Null
    $echoScript = Join-Path $transportDirectory 'echo args.ps1'
    [IO.File]::WriteAllText($echoScript, @'
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Values)
if ($Values.Count -eq 1 -and $Values[0] -eq '--fail') {
    [Console]::Out.WriteLine('stdout-proof')
    [Console]::Error.WriteLine('stderr-proof')
    exit 7
}
foreach ($value in $Values) { [Console]::Out.WriteLine([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($value))) }
'@, [Text.UTF8Encoding]::new($false))
    $unicodeArgument = 'unicod' + [char]0x00E9 + '-' + [char]0x6771 + [char]0x4EAC
    $special = @('space value',$unicodeArgument,'a"b','amp&ersand','percent%value','%PATH%','semi;colon')
    $transport = Invoke-SgBoundedProcess -File "$PSHOME\powershell.exe" -Arguments (@('-NoProfile','-ExecutionPolicy','Bypass','-File',$echoScript) + $special) -TimeoutSeconds 20
    Assert-Sg (-not $transport.TimedOut -and $transport.ExitCode -eq 0) "Executable argument transport failed: exit=$($transport.ExitCode) timeout=$($transport.TimedOut) output=$($transport.Output)"
    $transportArgs = @($transport.Output -split '\r?\n' | Where-Object { $_ -match '^[A-Za-z0-9+/]+={0,2}$' -and $_.Length % 4 -eq 0 } | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) })
    Assert-Sg (($transportArgs -join '|') -eq ($special -join '|')) "Executable argument boundaries or Unicode were changed: expected=$($special -join '|') actual=$($transportArgs -join '|') raw=$($transport.Output)"
    $failedTransport = Invoke-SgBoundedProcess -File "$PSHOME\powershell.exe" -Arguments @('-NoProfile','-ExecutionPolicy','Bypass','-File',$echoScript,'--fail') -TimeoutSeconds 20
    Assert-Sg ($failedTransport.ExitCode -eq 7 -and $failedTransport.Output -match 'stdout-proof' -and $failedTransport.Output -match 'stderr-proof') 'Transport must preserve exit code, stdout, and stderr.'
    $cmd = Join-Path $transportDirectory 'echo args.cmd'
    [IO.File]::WriteAllText($cmd, "@echo off`r`n@powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"%~dp0echo args.ps1`" %*`r`n", [Text.Encoding]::ASCII)
    # PowerShell -File has different embedded-quote semantics from a native
    # executable. The signed-host path still proves batch transport for spaces,
    # Unicode and metacharacters; the direct transport above retains quote proof.
    $cmdSpecial = @($special | Where-Object { $_ -notmatch '"' })
    $cmdTransport = Invoke-SgBoundedProcess -File $cmd -Arguments $cmdSpecial -TimeoutSeconds 20
    Assert-Sg (-not $cmdTransport.TimedOut -and $cmdTransport.ExitCode -eq 0) "CMD/BAT argument transport failed: exit=$($cmdTransport.ExitCode) output=$($cmdTransport.Output)"
    $cmdArgs = @($cmdTransport.Output -split '\r?\n' | Where-Object { $_ -match '^[A-Za-z0-9+/]+={0,2}$' -and $_.Length % 4 -eq 0 } | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) })
    Assert-Sg (($cmdArgs -join '|') -eq ($cmdSpecial -join '|')) "CMD/BAT argument boundaries were changed: expected=$($cmdSpecial -join '|') actual=$($cmdArgs -join '|') raw=$($cmdTransport.Output)"
    $transportBefore = @(Get-ChildItem -LiteralPath ([IO.Path]::GetTempPath()) -Filter 'sg-transport-*.cmd' -ErrorAction SilentlyContinue | ForEach-Object FullName)
    foreach ($unsafe in @("line`nfeed","carriage`rreturn",("nul" + [char]0 + "value"))) {
        $unsafeResult = Invoke-SgBoundedProcess -File $cmd -Arguments @($unsafe) -TimeoutSeconds 20
        Assert-Sg ($unsafeResult.ExitCode -eq -1 -and $unsafeResult.Output -match 'NUL|CR|LF|unsafe') 'Batch transport must reject NUL/CR/LF before creating a wrapper.'
    }
    $savedComSpec = $env:ComSpec
    try { $env:ComSpec = Join-Path $fixture 'missing-cmd.exe'; $missingStart = Invoke-SgBoundedProcess -File $cmd -Arguments @('safe') -TimeoutSeconds 20 }
    finally { $env:ComSpec = $savedComSpec }
    Assert-Sg ($missingStart.ExitCode -eq -1) 'A missing batch host must report a bounded start failure.'
    $transportAfter = @(Get-ChildItem -LiteralPath ([IO.Path]::GetTempPath()) -Filter 'sg-transport-*.cmd' -ErrorAction SilentlyContinue | ForEach-Object FullName)
    Assert-Sg (($transportAfter -join '|') -eq ($transportBefore -join '|')) 'Failed or rejected batch starts must leave no sg-transport wrapper.'
    $interactive = Invoke-SgInteractiveBoundedProcess -File "$PSHOME\powershell.exe" -Arguments @('-NoProfile','-Command','exit 0') -TimeoutSeconds 20
    Assert-Sg $interactive 'Interactive encoded transport failed.'
    $timeout = Invoke-SgBoundedProcess -File "$PSHOME\powershell.exe" -Arguments @('-NoProfile','-Command','Start-Sleep -Seconds 5') -TimeoutSeconds 1
    Assert-Sg ($timeout.TimedOut) 'Encoded transport timeout must stop the exact process identity.'
    $utf8Cmd = Join-Path $transportDirectory 'utf8 diagnostic.cmd'
    [IO.File]::WriteAllText($utf8Cmd, "@echo off`r`n@powershell.exe -NoProfile -Command `"[Console]::OutputEncoding=[Text.UTF8Encoding]::new(`$false);[Console]::Write([char]0x2713)`"`r`n", [Text.Encoding]::ASCII)
    $utf8Check = Invoke-SgBoundedProcess -File $utf8Cmd -Arguments @() -TimeoutSeconds 20
    Assert-Sg ($utf8Check.ExitCode -eq 0 -and $utf8Check.Output -eq [string][char]0x2713) 'Captured UTF-8 batch diagnostics must preserve the exact positive checkmark.'

    $installerPath = Join-Path $root 'cli\windows\install-devserver.ps1'
    $installerSource = Get-Content -LiteralPath $installerPath -Raw
    $installerTokens = $null; $installerErrors = $null
    $installerAst = [Management.Automation.Language.Parser]::ParseInput($installerSource,[ref]$installerTokens,[ref]$installerErrors)
    Assert-Sg ($installerErrors.Count -eq 0) 'Windows installer must parse before environment-report testing.'
    $flutterBaselineDefinition = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Get-SgFlutterBaseline' },$true))
    Assert-Sg ($flutterBaselineDefinition.Count -eq 1) 'Flutter baseline must resolve uniquely.'
    Invoke-Expression $flutterBaselineDefinition[0].Extent.Text
    $flutterBaseline = Get-SgFlutterBaseline
    Assert-Sg ($flutterBaseline.Schema -eq 'shipglows.flutter-baseline/v1' -and $flutterBaseline.ValidatedAt -eq '2026-08-23' -and $flutterBaseline.FlutterVersion -eq '3.47.1' -and $flutterBaseline.DartVersion -eq '3.13.1' -and $flutterBaseline.Commit -eq '6655482ec06e547f90abf8ae7590466f4415978d') 'Flutter baseline must use the exact validated ShipGlows coordinates.'
    foreach ($value in @($flutterBaseline.FlutterVersion,$flutterBaseline.DartVersion,$flutterBaseline.Commit)) { Assert-Sg ([string]$value -notmatch '(?i)latest|stable|nightly|beta|[x*^~<>]') 'Flutter baseline must not contain a moving version coordinate.' }
    $serviceInstaller = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Install-SgMachineToolbox' },$true))
    Assert-Sg ($serviceInstaller.Count -eq 1) 'Machine CLI toolbox installer must resolve uniquely.'
    $serviceInstallerSource = $serviceInstaller[0].Extent.Text
    Assert-Sg ($serviceInstallerSource -match 'Get-SgMachineToolboxPlan' -and $serviceInstallerSource -match "@\('install'\)" -and $serviceInstallerSource -match 'Get-SgMachineToolboxWrapperContent') 'Machine CLI toolbox must install one isolated exact mise plan and expose stable wrappers.'
    $partialToolboxConverges = & {
        $savedLocalAppData = $env:LOCALAPPDATA
        $env:LOCALAPPDATA = Join-Path $fixture 'toolbox-local'
        $script:runtimeDir = Join-Path $fixture 'toolbox-runtime'
        New-Item -ItemType Directory -Path $script:runtimeDir -Force | Out-Null
        $misePath = Join-Path $fixture 'mise.exe'; New-Item -ItemType File -Path $misePath -Force | Out-Null
        $targetedInstalls = [Collections.Generic.List[string]]::new()
        $clerkProbeCount = @{ Value = 0 }
        function Get-SgProjectServiceNeeds { [pscustomobject]@{ AndroidNative=$false } }
        function Resolve-SgTrustedMisePath { $misePath }
        function Resolve-SgNpmVersion([string]$NpmPath,[string]$PackageName) {
            return @{ 'firebase-tools'='15.28.1'; convex='1.45.0'; vercel='59.5.0'; clerk='3.2.0' }[$PackageName]
        }
        function Invoke-SgManagedTauriMise {
            param([string]$MisePath,[string]$ToolchainRoot,[string[]]$Arguments,[int]$TimeoutSeconds,[switch]$Visible,[string]$OperationId,[string]$Label)
            if ($Arguments[0] -eq 'latest') { return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output='2.115.0'} }
            if ($Arguments.Count -eq 2) { [void]$targetedInstalls.Add($Arguments[1]) }
            return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=''}
        }
        function Invoke-SgBoundedProcess([string]$File,[string[]]$Arguments,[int]$TimeoutSeconds) {
            $name = [IO.Path]::GetFileNameWithoutExtension($File)
            if ($name -eq 'clerk') {
                $clerkProbeCount.Value++
                if ($clerkProbeCount.Value -eq 1) { return [pscustomobject]@{TimedOut=$false;ExitCode=127;Output=''} }
            }
            $version = @{ firebase='15.28.1'; supabase='2.115.0'; convex='1.45.0'; vercel='59.5.0'; clerk='3.2.0' }[$name]
            return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=$version}
        }
        function Move-SgAtomicReplace([string]$Source,[string]$Destination) { Move-Item -LiteralPath $Source -Destination $Destination -Force }
        function Write-SgInstallerWarning([string]$Message) { }
        try {
            Invoke-Expression $serviceInstaller[0].Extent.Text
            $result = Install-SgMachineToolbox $fixture '' 'npm.cmd' $true
            return $result.Clerk -eq 'ready (3.2.0)' -and ($targetedInstalls -join '|') -eq 'npm:clerk@3.2.0' -and $clerkProbeCount.Value -eq 2
        } finally {
            $env:LOCALAPPDATA = $savedLocalAppData
            Remove-Variable runtimeDir -Scope Script -ErrorAction SilentlyContinue
        }
    }
    Assert-Sg $partialToolboxConverges 'A successful aggregate install with only Clerk missing must retry exactly npm:clerk@3.2.0 and become ready after re-probe.'
    Assert-Sg ($serviceInstallerSource -match 'FlutterFire is a Dart Pub tool' -and $serviceInstallerSource -match "pub','global','activate','flutterfire_cli") 'FlutterFire must remain a machine-scoped Dart Pub tool independent of project detection.'
    $playwrightInstaller = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Install-SgManagedPlaywrightRuntimes' },$true))
    Assert-Sg ($playwrightInstaller.Count -eq 1 -and $playwrightInstaller[0].Extent.Text -notmatch '@playwright/cli' -and $playwrightInstaller[0].Extent.Text -match "cli %\*") 'Playwright agent commands must use the CLI bundled with the validated Playwright package.'
    $playwrightRuntimeCall = $installerSource.IndexOf("`$playwrightRuntime = Install-SgManagedPlaywrightRuntimes",[StringComparison]::Ordinal)
    $androidToolchainCall = $installerSource.IndexOf("`$androidInfo = Install-SgAndroidToolchain",[StringComparison]::Ordinal)
    Assert-Sg ($playwrightRuntimeCall -ge 0 -and $androidToolchainCall -ge 0 -and $playwrightRuntimeCall -lt $androidToolchainCall) 'Managed Chromium must be wired before the Android Flutter doctor runs.'
    $environmentWriter = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Write-SgGlobalDevelopmentEnvironment' },$true))
    Assert-Sg ($environmentWriter.Count -eq 1) 'Environment report writer must resolve uniquely.'
    $flutterInstaller = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Install-SgFlutter' },$true))
    Assert-Sg ($flutterInstaller.Count -eq 1) 'Flutter installer must resolve uniquely.'
    $existingFlutterAddsPath = & {
        $capturedPath = [Collections.Generic.List[string]]::new()
        $stableConvergence = [Collections.Generic.List[string]]::new()
        $managedFlutterBin = Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin'
        function Get-SgToolPath([string]$Name,[string[]]$Paths) { if ($Name -eq 'flutter.bat') { return (Join-Path $env:LOCALAPPDATA 'ShipGlows\flutter\bin\flutter.bat') }; if ($Name -eq 'git.exe') { return 'C:\git.exe' }; return '' }
        function Get-SgFlutterInstallState([string]$FlutterRoot) { [pscustomobject]@{ Status='ready'; Recovery='none'; FlutterPath=(Join-Path $FlutterRoot 'bin\flutter.bat'); DartPath=(Join-Path $FlutterRoot 'bin\dart.bat') } }
        function Add-SgUserPathEntry([string]$Directory) { [void]$capturedPath.Add($Directory) }
        function Resolve-SgFlutterStableCommit([string]$GitPath) { return '6655482ec06e547f90abf8ae7590466f4415978d' }
        function Set-SgManagedFlutterStableRevision([string]$GitPath,[string]$FlutterRoot,[string]$Commit) { [void]$stableConvergence.Add($Commit); return $true }
        function Invoke-SgVisibleBoundedProcess { [pscustomobject]@{ TimedOut=$false; ExitCode=0; Output='' } }
        Invoke-Expression $flutterInstaller[0].Extent.Text
        [void](Install-SgFlutter @((Join-Path $managedFlutterBin 'flutter.bat')) @())
        return $capturedPath.Contains($managedFlutterBin) -and $stableConvergence.Contains('6655482ec06e547f90abf8ae7590466f4415978d')
    }
    Assert-Sg $existingFlutterAddsPath 'A validated existing managed Flutter SDK must converge PATH and the resolved stable revision.'
    $stableRevisionSetter = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Set-SgManagedFlutterStableRevision' },$true))
    Assert-Sg ($stableRevisionSetter.Count -eq 1) 'Managed Flutter stable revision setter must resolve uniquely.'
    $stableRollback = & {
        $savedLocalAppData = $env:LOCALAPPDATA
        $testLocalAppData = Join-Path $fixture 'stable-rollback-local'
        $managedRoot = Join-Path $testLocalAppData 'ShipGlows\flutter'
        $previousCommit = '1111111111111111111111111111111111111111'
        $stableCommit = '6655482ec06e547f90abf8ae7590466f4415978d'
        $visibleArguments = [Collections.Generic.List[string]]::new()
        $warnings = [Collections.Generic.List[string]]::new()
        $stateCounter = @{ Value = 0 }
        function Invoke-SgBoundedProcess([string]$File,[string[]]$Arguments,[int]$TimeoutSeconds) {
            $joined = $Arguments -join ' '
            if ($joined -match 'remote get-url origin$') { return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output='https://github.com/flutter/flutter.git'} }
            if ($joined -match 'status --porcelain --untracked-files=no$') { return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=''} }
            if ($joined -match 'rev-parse HEAD$') { return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=$previousCommit} }
            if ($joined -match 'rev-parse refs/remotes/origin/shipglows-stable$') { return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=$stableCommit} }
            return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=''}
        }
        function Invoke-SgVisibleBoundedProcess([string]$OperationId,[string]$Label,[string]$File,[string[]]$Arguments,[int]$TimeoutSeconds) { [void]$visibleArguments.Add(($Arguments -join ' ')); return [pscustomobject]@{TimedOut=$false;ExitCode=0;Output=''} }
        function Get-SgFlutterInstallState([string]$FlutterRoot) { $stateCounter.Value++; return [pscustomobject]@{Status=if($stateCounter.Value -eq 1){'partial'}else{'ready'}} }
        function Write-SgInstallerWarning([string]$Message) { [void]$warnings.Add($Message) }
        try {
            $env:LOCALAPPDATA = $testLocalAppData
            Invoke-Expression $stableRevisionSetter[0].Extent.Text
            $result = Set-SgManagedFlutterStableRevision 'C:\git.exe' $managedRoot $stableCommit
            return -not $result -and @($visibleArguments | Where-Object { $_ -match "checkout -B stable $stableCommit$" }).Count -eq 1 -and @($visibleArguments | Where-Object { $_ -match "checkout -B stable $previousCommit$" }).Count -eq 1 -and $warnings.Contains('Flutter stable convergence failed; restored the previous managed revision.')
        } finally { $env:LOCALAPPDATA = $savedLocalAppData }
    }
    Assert-Sg $stableRollback 'A failed Flutter stable validation must restore and revalidate the previous managed revision.'
    Invoke-Expression $environmentWriter[0].Extent.Text
    $savedUserProfile = $env:USERPROFILE
    try {
        $env:USERPROFILE = Join-Path $fixture 'environment-home'
        $agentInfo = @{
            Codex=[pscustomobject]@{Installed=$true;McpSummary='ready: dart, firebase'}
            Claude=[pscustomobject]@{Installed=$true;McpSummary='partial: ready dart; pending firebase'}
            OpenCode=[pscustomobject]@{Installed=$false;McpSummary='not applicable'}
            Kilo=[pscustomobject]@{Installed=$false;McpSummary='not applicable'}
            Gemini=[pscustomobject]@{Installed=$true;McpSummary='ready: dart, github'}
        }
        $services = [pscustomobject]@{ Firebase='ready (14.0.0)'; FlutterFire='ready (1.3.1)'; Convex='ready (1.28.0)'; Vercel='ready (48.0.0)'; Supabase='not detected'; Clerk='ready (0.4.0)'; AndroidNative='not detected' }
        $reportPath = Write-SgGlobalDevelopmentEnvironment $agentInfo ([pscustomobject]@{ Installed=$true; McpConfigured=$true; McpVerified=$true; ConfigPath='per-agent'; ChromiumPath='C:\chromium.exe' }) ([pscustomobject]@{ StableReady='yes'; StableVersion='1.62.1'; StableRevision='1234'; AgentCliReady='yes'; AgentCliVersion='0.1.0'; MotionReady='yes' }) ([pscustomobject]@{ Version='3.14.7'; Manager='uv'; Commands='python, python3' }) $true ([pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false }) ([pscustomobject]@{ AndroidStudioReady=$true; VisualStudioCppReady=$false; FirebaseDeviceStreamingReady=$false }) $services $false
        $report = [IO.File]::ReadAllText($reportPath)
        $incompleteWindowsReportPath = Write-SgGlobalDevelopmentEnvironment $agentInfo ([pscustomobject]@{ Installed=$true; McpConfigured=$true; McpVerified=$true; ConfigPath='per-agent'; ChromiumPath='C:\chromium.exe' }) ([pscustomobject]@{ StableReady='yes'; StableVersion='1.62.1'; StableRevision='1234'; AgentCliReady='yes'; AgentCliVersion='0.1.0'; MotionReady='yes' }) ([pscustomobject]@{ Version='3.14.7'; Manager='uv'; Commands='python, python3' }) $false ([pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false }) ([pscustomobject]@{ AndroidStudioReady=$true; VisualStudioCppReady=$true; FirebaseDeviceStreamingReady=$false }) $services $true
        $incompleteWindowsReport = [IO.File]::ReadAllText($incompleteWindowsReportPath)
    } finally { $env:USERPROFILE = $savedUserProfile }
    foreach ($expected in @('Flutter and Dart installed: yes','Android toolchain ready: no','Android licenses ready: no','Android device ready: no','Android Studio installed: yes','Visual Studio Desktop C++ workload ready: no','Flutter Windows desktop toolchain ready: no','Windows Developer Mode enabled: no','Firebase Android Device Streaming configured: no','Playwright MCP configured: yes','Playwright CLI installed: yes','Playwright CLI version: 1.62.1','Playwright Chromium revision: 1234','Playwright Agent CLI installed: yes','Motion runtime ready: yes','Codex MCP readiness: ready: dart, firebase','Claude MCP readiness: partial: ready dart; pending firebase','Gemini MCP readiness: ready: dart, github','Convex development tooling: ready (1.28.0)','Clerk development tooling: ready (0.4.0)','Windows-supported Flutter targets: web, Android, Windows desktop','rerun the ShipGlows full installer in an interactive PowerShell')) {
        Assert-Sg ($report.Contains($expected)) "Environment report is missing actionable mobile state: $expected"
    }
    Assert-Sg ($incompleteWindowsReport.Contains('Flutter and Dart installed: no')) 'The environment report must retain the failed Flutter prerequisite.'
    Assert-Sg ($incompleteWindowsReport.Contains('Flutter Windows desktop toolchain ready: no')) 'Visual Studio and Developer Mode must not report Windows desktop ready when Flutter is unavailable.'

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $evilZip = Join-Path $fixture 'evil.zip'
    $zip = [IO.Compression.ZipFile]::Open($evilZip,[IO.Compression.ZipArchiveMode]::Create)
    try { [void]$zip.CreateEntry('../escape.txt'); [void]$zip.CreateEntry('root/bin/java.exe') } finally { $zip.Dispose() }
    $archiveRejected = $false
    try { [void](Expand-SgVerifiedZip -ArchivePath $evilZip -DestinationPath (Join-Path $fixture 'extract') -ExpectedRelativePath 'bin\java.exe') } catch { $archiveRejected = $_.Exception.Message -match 'unsafe' }
    Assert-Sg $archiveRejected 'Traversal ZIP entries must be rejected before extraction.'
    $linkZip = Join-Path $fixture 'link.zip'
    $zip = [IO.Compression.ZipFile]::Open($linkZip,[IO.Compression.ZipArchiveMode]::Create)
    try {
        $link = $zip.CreateEntry('root/link'); $link.ExternalAttributes = [int]0xA0000000
        [void]$zip.CreateEntry('root/bin/java.exe')
    } finally { $zip.Dispose() }
    $linkRejected = $false
    try { [void](Expand-SgVerifiedZip -ArchivePath $linkZip -DestinationPath (Join-Path $fixture 'link-extract') -ExpectedRelativePath 'bin\java.exe') } catch { $linkRejected = $_.Exception.Message -match 'unsafe' }
    Assert-Sg $linkRejected 'Symlink/reparse ZIP entries must be rejected before extraction.'
} finally {
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}

Write-Host 'Windows Flutter Android toolchain regression: OK'
