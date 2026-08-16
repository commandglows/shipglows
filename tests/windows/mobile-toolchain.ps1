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
Assert-Sg (Test-SgAndroidLicenseResult ([pscustomobject]@{ ExitCode=0; Output="WARNING: sdkmanager is deprecated.`nAll SDK package licenses accepted"; TimedOut=$false })) 'Previously accepted SDK licenses must converge without another interactive prompt.'
Assert-Sg (-not (Test-SgAndroidLicenseResult ([pscustomobject]@{ ExitCode=0; Output='7 of 7 SDK package licenses not accepted.'; TimedOut=$false }))) 'Unaccepted SDK licenses must remain pending.'

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
$emulatorPlan = Get-SgEmulatorProvisionPlan
Assert-Sg (($emulatorPlan.Packages -join '|') -eq 'emulator|system-images;android-36;google_apis;x86_64' -and $emulatorPlan.AvdName -eq 'ShipGlows_API_36') 'Emulator provisioning must include current package, system image, and AVD.'
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
    Assert-Sg (-not (Test-SgServiceCliResult $failedResult $okResult $serviceExe '14.2.1')) 'Failed service CLI install must not verify.'
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
    $empty = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg (-not $empty.Firebase -and -not $empty.FlutterFire -and -not $empty.Supabase) 'Zero-service workspace detected false dependencies.'
    $oneProject = Join-Path $fixture 'one\nested'
    New-Item -ItemType Directory -Path $oneProject -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $oneProject 'firebase.json') -Value '{}'
    $one = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg ($one.Firebase -and -not $one.FlutterFire -and -not $one.Supabase) 'One nested service need was not detected exactly.'
    Set-Content -LiteralPath (Join-Path $fixture 'pubspec.yaml') -Value "dependencies:`n  firebase_core: any"
    New-Item -ItemType Directory -Path (Join-Path $fixture 'supabase') | Out-Null
    Set-Content -LiteralPath (Join-Path $fixture 'supabase\config.toml') -Value 'project_id = "fixture"'
    $many = Get-SgProjectServiceNeeds -Workspace $fixture
    Assert-Sg ($many.Firebase -and $many.FlutterFire -and $many.Supabase) 'Many-service workspace detection is incomplete.'
    $bounded = Get-SgProjectServiceNeeds -Workspace $fixture -MaxDirectories 1
    Assert-Sg ($bounded.ScanLimitReached) 'Service scanning must stop at its directory bound.'

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
    $jsonc = Join-Path $fixture 'agent.jsonc'
    [IO.File]::WriteAllText($jsonc, "{`n // keep this comment`n `"provider`": { `"secret`": `"keep-me`" }`n}")
    $jsoncHash = (Get-FileHash $jsonc -Algorithm SHA256).Hash
    $jsoncPlan = Get-SgAgentConfigWritePlan -ConfigPath $jsonc -Config ([ordered]@{ mcp=$servers })
    Assert-Sg ($jsoncPlan.Status -eq 'pending' -and (Get-FileHash $jsonc -Algorithm SHA256).Hash -eq $jsoncHash) 'JSONC comments/secrets must be preserved byte-for-byte.'
    $newConfig = Join-Path $fixture 'new-agent.json'
    Assert-Sg (Write-SgNewAgentConfig -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers })) 'Absent config should be created atomically.'
    Assert-Sg (-not (Write-SgNewAgentConfig -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers }))) 'New-config rerun must converge idempotently.'
    Assert-Sg ((Get-SgAgentConfigWritePlan -ConfigPath $newConfig -Config ([ordered]@{ mcp=$servers })).Status -eq 'unchanged') 'Managed new-config rerun must report converged state.'

    $calls = New-Object Collections.Generic.List[string]
    $runner = { param($File, $Arguments, $TimeoutSeconds) [void]$calls.Add("$File $($Arguments -join ' ')"); $joined=$Arguments -join ' '; if ($File -match 'dart') { $output='Dart SDK version: 3.9.0' } elseif ($joined -eq '--version') { $output='Flutter 3.35.0' } elseif ($joined -eq '-version') { $output='openjdk version 17' } elseif ($joined -eq 'doctor -v') { $check=[char]0x2713; $output="[$check] Flutter`n[$check] Android toolchain - develop for Android devices`n    All Android licenses accepted." } elseif ($joined -eq 'devices') { $output='Pixel | device-1 | android-arm64 | Android 15' } elseif ($File -match 'adb') { $output='Android Debug Bridge version 1.0.41' } else { $output='Version 1.0' }; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    $diag = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath 'emulator.exe' -Runner $runner
    Assert-Sg ($diag.ToolchainReady -and $diag.LicensesReady -and $diag.DeviceReady) 'Healthy diagnostic did not report separate readiness surfaces.'
    Assert-Sg (($calls -join '|') -match 'doctor -v' -and ($calls -join '|') -match 'devices') 'flutter doctor/devices were not executed.'
    $zeroEvidence = { param($File, $Arguments, $TimeoutSeconds) [pscustomobject]@{ ExitCode=0; Output='ok'; TimedOut=$false } }
    $broken = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $zeroEvidence
    Assert-Sg (-not $broken.ToolchainReady -and -not $broken.DeviceReady) 'Exit zero alone must never establish readiness.'
    $timeoutRunner = { param($File, $Arguments, $TimeoutSeconds) [pscustomobject]@{ ExitCode=-1; Output='timed out'; TimedOut=$true } }
    $timedOut = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $timeoutRunner
    Assert-Sg ($timedOut.TimedOut -and -not $timedOut.ToolchainReady) 'Timed-out diagnostics must fail closed.'
    $zeroDeviceRunner = { param($File, $Arguments, $TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.9.0'}elseif($joined -eq '--version'){$output='Flutter 3.35.0'}elseif($joined -eq '-version'){$output='openjdk version 17'}elseif($joined -eq 'doctor -v'){$windowsCheck=[char]0x221A;$bullet=[char]0x2022;$output="[$windowsCheck] Flutter`n[$windowsCheck] Android toolchain - develop for Android devices (Android SDK version 36.0.0) [2,5s]`n    $bullet All Android licenses accepted."}elseif($joined -eq 'devices'){$output='No devices detected.'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ ExitCode=0; Output=$output; TimedOut=$false } }
    $zeroDevice = Get-SgFlutterAndroidDiagnostic -FlutterPath 'flutter.exe' -DartPath 'dart.bat' -JavaPath 'java.exe' -SdkManagerPath 'sdkmanager.bat' -AdbPath 'adb.exe' -EmulatorPath '' -Runner $zeroDeviceRunner
    Assert-Sg ($zeroDevice.ToolchainReady -and $zeroDevice.LicensesReady -and -not $zeroDevice.DeviceReady) 'Zero-device state must remain separate from toolchain readiness.'

    foreach ($marker in @('[!] Android toolchain - licenses not accepted','[X] Android toolchain - missing')) {
        $badDoctor = { param($File,$Arguments,$TimeoutSeconds) $joined=$Arguments -join ' '; if($File -match 'dart'){$output='Dart SDK version: 3.9.0'}elseif($joined -eq '--version'){$output='Flutter 3.35.0'}elseif($joined -eq '-version'){$output='openjdk version 17'}elseif($joined -eq 'doctor -v'){$output=$marker}elseif($joined -eq 'devices'){$output='No devices detected.'}elseif($File -match 'adb'){$output='Android Debug Bridge version 1.0.41'}else{$output='Version 1.0'}; [pscustomobject]@{ExitCode=0;Output=$output;TimedOut=$false} }.GetNewClosure()
        $bad = Get-SgFlutterAndroidDiagnostic 'flutter.exe' 'dart.bat' 'java.exe' 'sdkmanager.bat' 'adb.exe' '' $badDoctor
        Assert-Sg (-not $bad.ToolchainReady -and -not $bad.LicensesReady) "Doctor marker $marker must fail closed."
    }

    $transportDirectory = Join-Path $fixture 'transport with spaces'
    New-Item -ItemType Directory -Path $transportDirectory | Out-Null
    $echoExe = Join-Path $transportDirectory 'echo args.exe'
    Add-Type -TypeDefinition @'
using System;
using System.Text;
public static class EchoArgs {
    public static int Main(string[] args) {
        if (args.Length == 1 && args[0] == "--fail") { Console.Out.WriteLine("stdout-proof"); Console.Error.WriteLine("stderr-proof"); return 7; }
        foreach (string arg in args) Console.WriteLine(Convert.ToBase64String(Encoding.UTF8.GetBytes(arg)));
        return 0;
    }
}
'@ -OutputAssembly $echoExe -OutputType ConsoleApplication
    $unicodeArgument = 'unicod' + [char]0x00E9 + '-' + [char]0x6771 + [char]0x4EAC
    $special = @('space value',$unicodeArgument,'a"b','amp&ersand','percent%value','%PATH%','semi;colon')
    $transport = Invoke-SgBoundedProcess -File $echoExe -Arguments $special -TimeoutSeconds 20
    Assert-Sg (-not $transport.TimedOut -and $transport.ExitCode -eq 0) 'Executable argument transport failed.'
    $transportArgs = @($transport.Output -split '\r?\n' | Where-Object { $_ -match '^[A-Za-z0-9+/]+={0,2}$' -and $_.Length % 4 -eq 0 } | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) })
    Assert-Sg (($transportArgs -join '|') -eq ($special -join '|')) "Executable argument boundaries or Unicode were changed: expected=$($special -join '|') actual=$($transportArgs -join '|') raw=$($transport.Output)"
    $failedTransport = Invoke-SgBoundedProcess -File $echoExe -Arguments @('--fail') -TimeoutSeconds 20
    Assert-Sg ($failedTransport.ExitCode -eq 7 -and $failedTransport.Output -match 'stdout-proof' -and $failedTransport.Output -match 'stderr-proof') 'Transport must preserve exit code, stdout, and stderr.'
    $cmd = Join-Path $transportDirectory 'echo args.cmd'
    [IO.File]::WriteAllText($cmd, "@echo off`r`n@`"%~dp0echo args.exe`" %*`r`n", [Text.Encoding]::ASCII)
    $cmdTransport = Invoke-SgBoundedProcess -File $cmd -Arguments $special -TimeoutSeconds 20
    Assert-Sg (-not $cmdTransport.TimedOut -and $cmdTransport.ExitCode -eq 0) "CMD/BAT argument transport failed: exit=$($cmdTransport.ExitCode) output=$($cmdTransport.Output)"
    $cmdArgs = @($cmdTransport.Output -split '\r?\n' | Where-Object { $_ -match '^[A-Za-z0-9+/]+={0,2}$' -and $_.Length % 4 -eq 0 } | ForEach-Object { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) })
    Assert-Sg (($cmdArgs -join '|') -eq ($special -join '|')) "CMD/BAT argument boundaries were changed: expected=$($special -join '|') actual=$($cmdArgs -join '|') raw=$($cmdTransport.Output)"
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
    $environmentWriter = @($installerAst.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Write-SgGlobalDevelopmentEnvironment' },$true))
    Assert-Sg ($environmentWriter.Count -eq 1) 'Environment report writer must resolve uniquely.'
    Invoke-Expression $environmentWriter[0].Extent.Text
    $savedUserProfile = $env:USERPROFILE
    try {
        $env:USERPROFILE = Join-Path $fixture 'environment-home'
        $reportPath = Write-SgGlobalDevelopmentEnvironment $true ([pscustomobject]@{ Installed=$false; McpConfigured=$false; McpVerified=$false; ConfigPath='pending'; ChromiumPath='' }) ([pscustomobject]@{ Version='3.14.7'; Manager='uv'; Commands='python, python3' }) $true ([pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false })
        $report = [IO.File]::ReadAllText($reportPath)
    } finally { $env:USERPROFILE = $savedUserProfile }
    foreach ($expected in @('Flutter and Dart installed: yes','Android toolchain ready: no','Android licenses ready: no','Android device ready: no','rerun the ShipGlows full installer in an interactive PowerShell')) {
        Assert-Sg ($report.Contains($expected)) "Environment report is missing actionable mobile state: $expected"
    }

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
