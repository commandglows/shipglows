Set-StrictMode -Version Latest

if (-not ('ShipGlowsNativeFile' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ShipGlowsNativeFile {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool MoveFileEx(string existingFileName, string newFileName, int flags);
}
'@
}

function Move-SgAtomicReplace([string]$SourcePath, [string]$DestinationPath) {
    if (-not [ShipGlowsNativeFile]::MoveFileEx($SourcePath,$DestinationPath,9)) {
        throw "Atomic file replacement failed with Win32 error $([Runtime.InteropServices.Marshal]::GetLastWin32Error())."
    }
}

function Get-SgTauriAndroidBaseline {
    [pscustomobject]@{
        Schema = 'shipglows.tauri-android-baseline/v1'
        ValidatedAt = '2026-08-17'
        RustToolchainVersion = '1.97.1'
        RustTargets = @('aarch64-linux-android','armv7-linux-androideabi','i686-linux-android','x86_64-linux-android')
        TauriCliVersion = '2.11.4'
        TauriApiVersion = '2.11.1'
        TauriRustVersion = '2.11.5'
        TauriBuildVersion = '2.6.3'
        AndroidApiLevel = 36
        BuildToolsVersion = '36.0.0'
        NdkVersion = '29.0.14206865'
    }
}

function Test-SgExactVersionCoordinate([string]$Value) {
    return -not [string]::IsNullOrWhiteSpace($Value) -and $Value -match '^\d+(?:[.]\d+){1,3}(?:-[0-9A-Za-z.-]+)?$'
}

function Get-SgTauriAndroidProjectState {
    param(
        [Parameter(Mandatory=$true)][string]$Workspace,
        $Baseline = (Get-SgTauriAndroidBaseline),
        [int]$MaxDirectories = 5000,
        [int]$MaxDepth = 4,
        [long]$MaxManifestBytes = 2097152
    )
    if ($MaxDirectories -lt 1 -or $MaxDepth -lt 0 -or $MaxManifestBytes -lt 1 -or $MaxManifestBytes -gt 8MB) { throw 'Invalid bounded Tauri inspection limits.' }
    $root = [IO.Path]::GetFullPath($Workspace)
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Tauri inspection root is unavailable: $root" }
    $queue = New-Object Collections.Generic.Queue[object]
    $queue.Enqueue([pscustomobject]@{ Path=$root; Depth=0 })
    $candidates = New-Object Collections.Generic.List[object]
    $visited = 0
    $limitReached = $false
    while ($queue.Count -gt 0) {
        if ($visited -ge $MaxDirectories) { $limitReached=$true; break }
        $current = $queue.Dequeue(); $visited++
        $packagePath = Join-Path $current.Path 'package.json'
        $cargoPath = Join-Path $current.Path 'src-tauri\Cargo.toml'
        $packageText = if (Test-Path -LiteralPath $packagePath -PathType Leaf) { Read-SgBoundedManifestText $packagePath $MaxManifestBytes } else { '' }
        $cargoText = if (Test-Path -LiteralPath $cargoPath -PathType Leaf) { Read-SgBoundedManifestText $cargoPath $MaxManifestBytes } else { '' }
        $packageMarker = $packageText -match '"@tauri-apps/(?:api|cli)"\s*:'
        $cargoMarker = $cargoText -match '(?m)^\s*tauri\s*='
        if ($packageMarker -or $cargoMarker -or (Test-Path -LiteralPath (Join-Path $current.Path 'src-tauri\tauri.conf.json') -PathType Leaf)) {
            $candidates.Add([pscustomobject]@{ Root=$current.Path; PackagePath=$packagePath; PackageText=$packageText; CargoPath=$cargoPath; CargoText=$cargoText })
        }
        if ($current.Depth -ge $MaxDepth) { continue }
        foreach ($directory in @(Get-ChildItem -LiteralPath $current.Path -Directory -Force -ErrorAction SilentlyContinue | Sort-Object Name)) {
            if ($directory.Name -in @('.git','node_modules','target','build','.dart_tool','.venv','.idea')) { continue }
            if (($directory.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            $queue.Enqueue([pscustomobject]@{ Path=$directory.FullName; Depth=$current.Depth + 1 })
        }
    }
    if ($candidates.Count -eq 0) {
        return [pscustomobject]@{ IsTauri=$false; Status='unknown'; ProjectRoot=''; Differences=@(); Unknown=@('tauri-project'); DirectoriesVisited=$visited; ScanLimitReached=$limitReached }
    }
    $candidate = $candidates | Sort-Object Root | Select-Object -First 1
    $observed = [ordered]@{ TauriCli=''; TauriApi=''; CargoTauri=''; CargoTauriBuild=''; RustMsrv=''; AndroidApiLevel=''; BuildToolsVersion=''; NdkVersion='' }
    $invalid = New-Object Collections.Generic.List[string]
    if ($candidate.PackageText) {
        try {
            $package = $candidate.PackageText | ConvertFrom-Json -ErrorAction Stop
            foreach ($sectionName in @('dependencies','devDependencies')) {
                $section = $package.$sectionName
                if (-not $section) { continue }
                $cli = $section.PSObject.Properties['@tauri-apps/cli']; if ($cli) { $observed.TauriCli=[string]$cli.Value }
                $api = $section.PSObject.Properties['@tauri-apps/api']; if ($api) { $observed.TauriApi=[string]$api.Value }
            }
        } catch { $invalid.Add('package.json') }
    }
    if ($candidate.CargoText) {
        $rustMatch = [regex]::Match($candidate.CargoText, '(?m)^\s*rust-version\s*=\s*"(?<value>[^"]+)"')
        if ($rustMatch.Success) { $observed.RustMsrv=$rustMatch.Groups['value'].Value }
        $tauriMatch = [regex]::Match($candidate.CargoText, '(?m)^\s*tauri\s*=\s*(?:"(?<simple>[^"]+)"|\{[^}\r\n]*version\s*=\s*"(?<table>[^"]+)")')
        if ($tauriMatch.Success) { $observed.CargoTauri=if($tauriMatch.Groups['simple'].Success){$tauriMatch.Groups['simple'].Value}else{$tauriMatch.Groups['table'].Value} }
        $tauriBuildMatch = [regex]::Match($candidate.CargoText, '(?m)^\s*tauri-build\s*=\s*(?:"(?<simple>[^"]+)"|\{[^}\r\n]*version\s*=\s*"(?<table>[^"]+)")')
        if ($tauriBuildMatch.Success) { $observed.CargoTauriBuild=if($tauriBuildMatch.Groups['simple'].Success){$tauriBuildMatch.Groups['simple'].Value}else{$tauriBuildMatch.Groups['table'].Value} }
    }
    $androidRoot = Join-Path $candidate.Root 'src-tauri\gen\android'
    if (Test-Path -LiteralPath $androidRoot -PathType Container) {
        foreach ($gradle in @(Get-ChildItem -LiteralPath $androidRoot -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '[.]gradle(?:[.]kts)?$' } | Sort-Object FullName)) {
            if (($gradle.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $gradle.Length -gt $MaxManifestBytes) { continue }
            $text = Read-SgBoundedManifestText $gradle.FullName $MaxManifestBytes
            if (-not $observed.AndroidApiLevel) { $m=[regex]::Match($text,'\bcompileSdk(?:Version)?\s*(?:=\s*)?(?<value>\d+)'); if($m.Success){$observed.AndroidApiLevel=$m.Groups['value'].Value} }
            if (-not $observed.BuildToolsVersion) { $m=[regex]::Match($text,'\bbuildToolsVersion\s*(?:=\s*)?"(?<value>[^"]+)"'); if($m.Success){$observed.BuildToolsVersion=$m.Groups['value'].Value} }
            if (-not $observed.NdkVersion) { $m=[regex]::Match($text,'\bndkVersion\s*(?:=\s*)?"(?<value>[^"]+)"'); if($m.Success){$observed.NdkVersion=$m.Groups['value'].Value} }
        }
    }
    $expected = [ordered]@{ TauriCli=[string]$Baseline.TauriCliVersion; TauriApi=[string]$Baseline.TauriApiVersion; CargoTauri=[string]$Baseline.TauriRustVersion; CargoTauriBuild=[string]$Baseline.TauriBuildVersion; AndroidApiLevel=[string]$Baseline.AndroidApiLevel; BuildToolsVersion=[string]$Baseline.BuildToolsVersion; NdkVersion=[string]$Baseline.NdkVersion }
    $differences = New-Object Collections.Generic.List[string]
    $unknown = New-Object Collections.Generic.List[string]
    foreach ($name in $expected.Keys) {
        $raw = [string]$observed[$name]
        if ([string]::IsNullOrWhiteSpace($raw)) { $differences.Add("$name`: missing -> $($expected[$name])"); continue }
        $normalized = if ($name -in @('CargoTauri','CargoTauriBuild')) { $raw.TrimStart('=') } else { $raw }
        $valid = if ($name -eq 'AndroidApiLevel') { $normalized -match '^\d+$' } else { Test-SgExactVersionCoordinate $normalized }
        if (-not $valid) { $unknown.Add($name); continue }
        if ($normalized -ne [string]$expected[$name]) { $differences.Add("$name`: $normalized -> $($expected[$name])") }
    }
    $rustMsrv = [string]$observed.RustMsrv
    if ([string]::IsNullOrWhiteSpace($rustMsrv) -or -not (Test-SgExactVersionCoordinate $rustMsrv)) { $unknown.Add('RustMsrv') }
    elseif ([version]$rustMsrv -gt [version]$Baseline.RustToolchainVersion) { $differences.Add("RustMsrv: $rustMsrv exceeds validated toolchain $($Baseline.RustToolchainVersion)") }
    foreach ($name in $invalid) { $unknown.Add($name) }
    $status = if ($invalid.Count -gt 0 -or $limitReached) { 'unknown' } elseif ($differences.Count -gt 0) { 'migration_required' } elseif ($unknown.Count -gt 0) { 'unknown' } else { 'ready' }
    [pscustomobject]@{ IsTauri=$true; Status=$status; ProjectRoot=[IO.Path]::GetFullPath($candidate.Root); Differences=@($differences | Sort-Object); Unknown=@($unknown | Sort-Object -Unique); DirectoriesVisited=$visited; ScanLimitReached=$limitReached }
}

function New-SgTauriAndroidMigrationHandoff {
    param([Parameter(Mandatory=$true)]$ProjectState, $Baseline = (Get-SgTauriAndroidBaseline))
    if (-not $ProjectState.IsTauri -or $ProjectState.Status -ne 'migration_required') { throw 'A migration handoff requires a Tauri project in migration_required state.' }
    [pscustomobject]@{
        Schema = 'shipglows.tauri-android-migration-handoff/v1'
        Action = 'offer_codex'
        ProjectRoot = [IO.Path]::GetFullPath([string]$ProjectState.ProjectRoot)
        TargetBaseline = [pscustomobject]@{ RustToolchainVersion=[string]$Baseline.RustToolchainVersion; TauriCliVersion=[string]$Baseline.TauriCliVersion; TauriApiVersion=[string]$Baseline.TauriApiVersion; TauriRustVersion=[string]$Baseline.TauriRustVersion; TauriBuildVersion=[string]$Baseline.TauriBuildVersion; AndroidApiLevel=[int]$Baseline.AndroidApiLevel; BuildToolsVersion=[string]$Baseline.BuildToolsVersion; NdkVersion=[string]$Baseline.NdkVersion }
        Differences = @($ProjectState.Differences | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        ProjectMutationAuthorized = $false
        Prompt = 'Open Codex in this project to perform and verify the migration?'
    }
}

function Get-SgTauriMiseConfig {
    param($Baseline = (Get-SgTauriAndroidBaseline))
    if (-not (Test-SgExactVersionCoordinate ([string]$Baseline.RustToolchainVersion))) { throw 'Tauri Rust toolchain baseline must be exact.' }
    $targets = @($Baseline.RustTargets)
    if ($targets.Count -ne 4 -or @($targets | Where-Object { $_ -notmatch '^[a-z0-9_]+-[a-z0-9_]+-android(?:eabi)?$' }).Count -gt 0) { throw 'Tauri Rust Android targets are invalid.' }
    $quotedTargets = @($targets | ForEach-Object { '"' + $_ + '"' }) -join ', '
    return "[tools]`nrust = { version = `"$($Baseline.RustToolchainVersion)`", profile = `"default`", targets = [$quotedTargets] }`n"
}

function Get-SgTauriAndroidHostPlan {
    param(
        [bool]$TauriDetected,
        [bool]$MiseReady,
        [bool]$RustReady,
        [bool]$NdkReady,
        [bool]$MigrationRequired = $false,
        [bool]$Interactive = $false,
        [bool]$CodexReady = $false,
        [string]$CodexChoice = '',
        $Baseline = (Get-SgTauriAndroidBaseline)
    )
    if (-not $TauriDetected) {
        return [pscustomobject]@{ Status='not_applicable'; NeedMise=$false; NeedRust=$false; NeedNdk=$false; AndroidPackages=@(); OfferCodex=$false; OpenCodex=$false; ProjectMutationAuthorized=$false }
    }
    $offerCodex = $MigrationRequired -and $Interactive -and $CodexReady
    [pscustomobject]@{
        Status = if ($MigrationRequired) { 'migration_required' } elseif ($MiseReady -and $RustReady -and $NdkReady) { 'ready' } else { 'pending' }
        NeedMise = -not $MiseReady
        NeedRust = -not $RustReady
        NeedNdk = -not $NdkReady
        AndroidPackages = @('platform-tools',"platforms;android-$($Baseline.AndroidApiLevel)","build-tools;$($Baseline.BuildToolsVersion)","ndk;$($Baseline.NdkVersion)")
        OfferCodex = $offerCodex
        OpenCodex = $offerCodex -and $CodexChoice.Trim().ToLowerInvariant() -in @('y','yes')
        ProjectMutationAuthorized = $false
    }
}

function Get-SgAndroidCoordinates {
    [pscustomobject]@{
        ApiLevel = 36
        PlatformPackage = 'platforms;android-36'
        BuildToolsVersion = '36.0.0'
        BuildToolsPackage = 'build-tools;36.0.0'
        SystemImagePackage = 'system-images;android-36;google_apis;x86_64'
        AvdName = 'ShipGlows_API_36'
    }
}

function Test-SgSupportedAndroidArchitecture {
    param([bool]$Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem, [string]$Architecture = $env:PROCESSOR_ARCHITECTURE)
    return $Is64BitOperatingSystem -and $Architecture -match '^(?i:AMD64|x86_64)$'
}

function Get-SgAndroidInstallPlan {
    param([bool]$Interactive, [bool]$EmulatorSupported, [string]$EmulatorChoice = '', [bool]$EmulatorReady = $false)
    $ask = $Interactive -and -not $EmulatorReady
    $installEmulator = $ask -and $EmulatorChoice.Trim().ToLowerInvariant() -in @('y','yes')
    [pscustomobject]@{
        AskEmulator = $ask
        InstallEmulator = $installEmulator
        EmulatorReady = $EmulatorReady
        AccelerationProven = $EmulatorSupported
        AccelerationWarning = $ask -and -not $EmulatorSupported
        PhysicalDeviceAlternative = -not $installEmulator
        LicensesPending = -not $Interactive
        LicenseCommand = 'sdkmanager --licenses'
    }
}

function Get-SgWindowsIdeInstallPlan {
    param(
        [bool]$Interactive,
        [bool]$AndroidStudioReady,
        [bool]$VisualStudioCppReady,
        [string]$Choice = ''
    )
    $missing = New-Object Collections.Generic.List[string]
    if (-not $AndroidStudioReady) { $missing.Add('Android Studio') }
    if (-not $VisualStudioCppReady) { $missing.Add('Visual Studio Community with Desktop development with C++') }
    $ask = $Interactive -and $missing.Count -gt 0
    $accepted = $ask -and $Choice.Trim().ToLowerInvariant() -in @('y','yes')
    [pscustomobject]@{
        Ask = $ask
        Missing = $missing.ToArray()
        InstallAndroidStudio = $accepted -and -not $AndroidStudioReady
        InstallVisualStudioCpp = $accepted -and -not $VisualStudioCppReady
        Status = if ($missing.Count -eq 0) { 'ready' } elseif ($accepted) { 'install' } else { 'pending' }
    }
}

function Get-SgAndroidStudioState {
    param([string[]]$CandidatePaths)
    foreach ($candidate in @($CandidatePaths | Where-Object { $_ })) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [pscustomobject]@{ Ready=$true; Path=[IO.Path]::GetFullPath($candidate) }
        }
    }
    return [pscustomobject]@{ Ready=$false; Path='' }
}

function Get-SgVisualStudioCppState {
    param([string]$VsWherePath, [scriptblock]$Runner = $null)
    if ([string]::IsNullOrWhiteSpace($VsWherePath) -or -not (Test-Path -LiteralPath $VsWherePath -PathType Leaf)) {
        return [pscustomobject]@{ Installed=$false; WorkloadReady=$false; Ready=$false; InstallationPath='' }
    }
    $baseArguments = @('-latest','-products','Microsoft.VisualStudio.Product.Community','-property','installationPath')
    $installedResult = Invoke-SgDiagnosticCommand -File $VsWherePath -Arguments $baseArguments -Runner $Runner -TimeoutSeconds 30
    $installationPath = if (-not $installedResult.TimedOut -and $installedResult.ExitCode -eq 0) { ([string]$installedResult.Output).Trim() } else { '' }
    $installed = $installationPath -and (Test-Path -LiteralPath (Join-Path $installationPath 'Common7\IDE\devenv.exe') -PathType Leaf)
    $workloadArguments = @('-latest','-products','Microsoft.VisualStudio.Product.Community','-requires','Microsoft.VisualStudio.Workload.NativeDesktop','-property','installationPath')
    $workloadResult = Invoke-SgDiagnosticCommand -File $VsWherePath -Arguments $workloadArguments -Runner $Runner -TimeoutSeconds 30
    $workloadPath = if (-not $workloadResult.TimedOut -and $workloadResult.ExitCode -eq 0) { ([string]$workloadResult.Output).Trim() } else { '' }
    $workloadReady = $workloadPath -and (Test-Path -LiteralPath (Join-Path $workloadPath 'Common7\IDE\devenv.exe') -PathType Leaf)
    [pscustomobject]@{
        Installed = [bool]$installed
        WorkloadReady = [bool]$workloadReady
        Ready = [bool]($installed -and $workloadReady)
        InstallationPath = if ($workloadReady) { [IO.Path]::GetFullPath($workloadPath) } elseif ($installed) { [IO.Path]::GetFullPath($installationPath) } else { '' }
    }
}

function Get-SgAndroidProvisionPlan {
    param(
        [bool]$Interactive,
        [bool]$JdkReady,
        [bool]$CommandLineToolsReady,
        [bool]$LicensesAccepted,
        [string]$LicenseChoice = ''
    )
    $components = New-Object Collections.Generic.List[string]
    if (-not $JdkReady) { $components.Add('jdk17') }
    if (-not $CommandLineToolsReady) { $components.Add('android-command-line-tools') }
    foreach ($component in @('platform-tools','platform','build-tools')) { $components.Add($component) }
    $acceptedNow = $LicensesAccepted -or ($Interactive -and $LicenseChoice.Trim().ToLowerInvariant() -in @('y','yes'))
    [pscustomobject]@{
        Components = $components.ToArray()
        PromptLicenses = $Interactive -and -not $LicensesAccepted
        LicensesAccepted = $acceptedNow
        Status = if ($acceptedNow) { 'ready-to-install' } else { 'pending' }
        Reason = if ($acceptedNow) { '' } else { 'Android SDK license acceptance is pending.' }
    }
}

function Test-SgAndroidLicenseResult($Result) {
    return $null -ne $Result -and -not [bool]$Result.TimedOut -and [int]$Result.ExitCode -eq 0 -and [string]$Result.Output -match '(?im)^\s*All SDK package licenses accepted[.]?\s*$'
}

function Test-SgWindowsDeveloperMode {
    try {
        $value = Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name AllowDevelopmentWithoutDevLicense -ErrorAction Stop
        return [int]$value -eq 1
    } catch { return $false }
}

function Get-SgDeveloperModeGuidancePlan {
    param([bool]$Interactive, [bool]$DeveloperModeReady, [string]$Choice = '')
    $ask = $Interactive -and -not $DeveloperModeReady
    [pscustomobject]@{
        Ask = $ask
        OpenSettings = $ask -and $Choice.Trim().ToLowerInvariant() -in @('y','yes')
        SettingsUri = 'ms-settings:developers'
        ChangeRegistry = $false
        Status = if ($DeveloperModeReady) { 'ready' } else { 'pending' }
    }
}

function Test-SgWindowsHypervisorEvidence {
    param([bool]$HypervisorPresent, [bool]$VirtualizationFirmwareEnabled, [bool]$VmMonitorModeExtensions, [bool]$SecondLevelAddressTranslationExtensions)
    return $HypervisorPresent -and $VirtualizationFirmwareEnabled -and $VmMonitorModeExtensions -and $SecondLevelAddressTranslationExtensions
}

function Test-SgAndroidAcceleration {
    param([string]$EmulatorPath, [scriptblock]$Runner = $null)
    if ([string]::IsNullOrWhiteSpace($EmulatorPath)) { return $false }
    $result = Invoke-SgDiagnosticCommand -File $EmulatorPath -Arguments @('-accel-check') -Runner $Runner -TimeoutSeconds 20
    return -not $result.TimedOut -and $result.ExitCode -eq 0 -and $result.Output -notmatch '(?i)not\s+(installed|usable|ready|supported)|unsupported|unavailable' -and $result.Output -match '(?i)(WHPX|Windows Hypervisor Platform).*(installed|usable|ready)|acceleration.*(usable|supported)'
}

function Get-SgEmulatorProvisionPlan {
    param([int]$ApiLevel = 36, [string]$Abi = 'x86_64', [string]$AvdName = 'ShipGlows_API_36')
    if ($ApiLevel -lt 21 -or $Abi -notin @('x86_64','arm64-v8a') -or $AvdName -notmatch '^[A-Za-z0-9_.-]+$') { throw 'Invalid bounded Android emulator plan.' }
    [pscustomobject]@{ Packages=@('emulator',"system-images;android-$ApiLevel;google_apis;$Abi"); AvdName=$AvdName; Device='pixel_6' }
}

function Get-SgAndroidEmulatorProvisionState {
    param(
        [Parameter(Mandatory=$true)][string]$SdkRoot,
        [Parameter(Mandatory=$true)][string]$EmulatorPath,
        [Parameter(Mandatory=$true)][string]$ImagePackage,
        [Parameter(Mandatory=$true)][string]$AvdName,
        [scriptblock]$Runner = $null
    )
    $segments = @($ImagePackage -split ';')
    $invalidSegments = @($segments | Where-Object { $_ -notmatch '^[A-Za-z0-9_.-]+$' -or $_ -in @('.','..') })
    if ($segments.Count -ne 4 -or $segments[0] -ne 'system-images' -or $invalidSegments.Count -gt 0) {
        throw 'Invalid bounded Android system-image package.'
    }
    $imagePackageXml = Join-Path $SdkRoot (Join-Path ($segments -join '\') 'package.xml')
    $emulatorInstalled = Test-Path -LiteralPath $EmulatorPath -PathType Leaf
    $imageInstalled = $false
    if (Test-Path -LiteralPath $imagePackageXml -PathType Leaf) {
        try { [void][xml][IO.File]::ReadAllText($imagePackageXml); $imageInstalled = $true } catch { $imageInstalled = $false }
    }
    $avdReady = $false
    if ($emulatorInstalled) {
        $list = Invoke-SgDiagnosticCommand -File $EmulatorPath -Arguments @('-list-avds') -Runner $Runner -TimeoutSeconds 30
        $avdReady = -not $list.TimedOut -and $list.ExitCode -eq 0 -and $list.Output -match "(?m)^$([regex]::Escape($AvdName))\r?$"
    }
    [pscustomobject]@{
        EmulatorInstalled = $emulatorInstalled
        ImageInstalled = $imageInstalled
        AvdReady = $avdReady
        Complete = $emulatorInstalled -and $imageInstalled -and $avdReady
        ImagePackagePath = $imagePackageXml
    }
}

function Get-SgFlutterInstallState {
    param([string]$FlutterRoot, [scriptblock]$Runner = $null)
    if (-not (Test-Path -LiteralPath $FlutterRoot -PathType Container)) { return [pscustomobject]@{ Status='absent'; Recovery='install'; FlutterPath=''; DartPath='' } }
    $flutter = Join-Path $FlutterRoot 'bin\flutter.bat'
    $dart = Join-Path $FlutterRoot 'bin\dart.bat'
    if (-not (Test-Path -LiteralPath $flutter -PathType Leaf) -or -not (Test-Path -LiteralPath $dart -PathType Leaf)) { return [pscustomobject]@{ Status='partial'; Recovery='quarantine'; FlutterPath=$flutter; DartPath=$dart } }
    $flutterVersion = Invoke-SgDiagnosticCommand $flutter @('--version') $Runner 600
    $dartVersion = Invoke-SgDiagnosticCommand $dart @('--version') $Runner 60
    $ready = -not $flutterVersion.TimedOut -and -not $dartVersion.TimedOut -and $flutterVersion.ExitCode -eq 0 -and $flutterVersion.Output -match '(?m)^Flutter \d+' -and $dartVersion.ExitCode -eq 0 -and $dartVersion.Output -match '(?i)Dart SDK version'
    [pscustomobject]@{ Status=if($ready){'ready'}else{'partial'}; Recovery=if($ready){'none'}else{'quarantine'}; FlutterPath=$flutter; DartPath=$dart }
}

function Read-SgBoundedManifestText([string]$Path, [long]$MaxBytes = 2097152) {
    try {
        $file = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (-not $file.PSIsContainer -and $file.Length -ge 0 -and $file.Length -le $MaxBytes) { return [IO.File]::ReadAllText($file.FullName) }
    } catch { }
    return ''
}

function Get-SgProjectServiceNeeds {
    param([Parameter(Mandatory=$true)][string]$Workspace, [int]$MaxDirectories = 5000)
    $root = [IO.Path]::GetFullPath($Workspace)
    $flutterFire = $false
    $firebase = $false
    $supabase = $false
    $convex = $false
    $vercel = $false
    $clerk = $false
    $androidNative = $false
    $queue = New-Object Collections.Generic.Queue[object]
    $queue.Enqueue([pscustomobject]@{ Path=$root; Depth=0 })
    $visited = 0
    $limitReached = $false
    while ($queue.Count -gt 0) {
        if ($visited -ge $MaxDirectories) { $limitReached = $true; break }
        $current = $queue.Dequeue()
        $visited++
        if ((Test-Path -LiteralPath (Join-Path $current.Path 'firebase.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $current.Path '.firebaserc') -PathType Leaf)) { $firebase = $true }
        if (Test-Path -LiteralPath (Join-Path $current.Path 'supabase\config.toml') -PathType Leaf) { $supabase = $true }
        if ((Test-Path -LiteralPath (Join-Path $current.Path 'convex') -PathType Container) -or (Test-Path -LiteralPath (Join-Path $current.Path 'convex.json') -PathType Leaf)) { $convex = $true }
        if ((Test-Path -LiteralPath (Join-Path $current.Path 'vercel.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $current.Path '.vercel\project.json') -PathType Leaf)) { $vercel = $true }
        if ((Test-Path -LiteralPath (Join-Path $current.Path 'CMakeLists.txt') -PathType Leaf) -and $current.Path -match '(?i)[\\/]android(?:[\\/]|$)') { $androidNative = $true }
        $packageJson = Join-Path $current.Path 'package.json'
        if (Test-Path -LiteralPath $packageJson -PathType Leaf) {
            try {
                $packageText = Read-SgBoundedManifestText $packageJson
                $convex = $convex -or $packageText -match '(?i)"convex"\s*:'
                $vercel = $vercel -or $packageText -match '(?i)"(?:vercel|@astrojs/vercel)"\s*:|"[^"\r\n]*"\s*:\s*"[^"]*\bvercel\b'
                $clerk = $clerk -or $packageText -match '(?i)"(?:clerk|@clerk/[^"/]+)"\s*:'
            } catch { }
        }
        foreach ($gradleName in @('build.gradle','build.gradle.kts')) {
            $gradle = Join-Path $current.Path $gradleName
            if (Test-Path -LiteralPath $gradle -PathType Leaf) {
                try { $androidNative = $androidNative -or (Read-SgBoundedManifestText $gradle) -match '(?i)externalNativeBuild|ndkVersion|cmake\s*\{' } catch { }
            }
        }
        $pubspec = Join-Path $current.Path 'pubspec.yaml'
        if (Test-Path -LiteralPath $pubspec -PathType Leaf) {
            $flutterFire = $flutterFire -or [regex]::IsMatch((Read-SgBoundedManifestText $pubspec), '(?m)^\s*(firebase_core|cloud_firestore|firebase_auth|firebase_[a-z0-9_]+)\s*:')
        }
        if ($current.Depth -ge 4) { continue }
        foreach ($directory in @(Get-ChildItem -LiteralPath $current.Path -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($directory.Name -in @('.git','node_modules','.dart_tool','build','.venv','.idea')) { continue }
            if (($directory.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            $queue.Enqueue([pscustomobject]@{ Path=$directory.FullName; Depth=$current.Depth + 1 })
        }
    }
    [pscustomobject]@{ Firebase=[bool]$firebase; FlutterFire=[bool]$flutterFire; Supabase=[bool]$supabase; Convex=[bool]$convex; Vercel=[bool]$vercel; Clerk=[bool]$clerk; AndroidNative=[bool]$androidNative; DirectoriesVisited=$visited; ScanLimitReached=$limitReached }
}

function Resolve-SgAndroidCommandLineToolsPackage {
    param([xml]$RepositoryXml, [string]$OfficialDownloadHtml, [string]$RepositoryBaseUrl = 'https://dl.google.com/android/repository/')
    if (-not $RepositoryBaseUrl.StartsWith('https://dl.google.com/android/repository/', [StringComparison]::OrdinalIgnoreCase)) { throw 'Android repository base URL is not official.' }
    if ([string]::IsNullOrWhiteSpace($OfficialDownloadHtml) -or $OfficialDownloadHtml.Length -gt 5MB) { throw 'Official Android SHA-256 download table is missing or unbounded.' }
    $officialSha256 = @{}
    foreach ($match in [regex]::Matches($OfficialDownloadHtml, '(?is)(?<file>commandlinetools-win-[0-9]+_latest[.]zip).{0,700}?(?<sha>[0-9a-f]{64})')) {
        $file = $match.Groups['file'].Value
        $sha = $match.Groups['sha'].Value.ToUpperInvariant()
        if ($officialSha256.ContainsKey($file) -and $officialSha256[$file] -ne $sha) { throw "Official Android SHA-256 table contains conflicting checksums for $file." }
        $officialSha256[$file] = $sha
    }
    if ($officialSha256.Count -eq 0) { throw 'Official Android SHA-256 download table contained no Windows command-line tools package.' }
    $packages = New-Object Collections.Generic.List[object]
    foreach ($package in @($RepositoryXml.SelectNodes("//*[local-name()='remotePackage']"))) {
        if ([string]$package.path -notmatch '^cmdline-tools;[0-9]+(?:[.][0-9]+)*$') { continue }
        $archive = @($package.SelectNodes(".//*[local-name()='archive']") | Where-Object { $hostNode = $_.SelectSingleNode("./*[local-name()='host-os']"); $hostNode -and [string]$hostNode.InnerText -eq 'windows' }) | Select-Object -First 1
        if (-not $archive) { continue }
        $complete = $archive.SelectSingleNode(".//*[local-name()='complete']")
        $url = [string]$complete.SelectSingleNode("./*[local-name()='url']").InnerText
        if ($url -notmatch '^commandlinetools-win-[0-9]+_latest[.]zip$' -or -not $officialSha256.ContainsKey($url)) { continue }
        $checksum = [string]$officialSha256[$url]
        $sizeBytes = 0L
        $sizeNode = $complete.SelectSingleNode("./*[local-name()='size']")
        if (-not $sizeNode -or -not [long]::TryParse([string]$sizeNode.InnerText,[ref]$sizeBytes) -or $sizeBytes -le 0) { continue }
        $revision = $package.SelectSingleNode("./*[local-name()='revision']")
        $major = [int]$revision.SelectSingleNode("./*[local-name()='major']").InnerText
        $minorNode = $revision.SelectSingleNode("./*[local-name()='minor']")
        $microNode = $revision.SelectSingleNode("./*[local-name()='micro']")
        $version = if ($minorNode -or $microNode) { "$major.$(if($minorNode){$minorNode.InnerText}else{'0'}).$(if($microNode){$microNode.InnerText}else{'0'})" } else { [string]$major }
        $packages.Add([pscustomobject]@{ SortVersion=[version]("$major.$(if($minorNode){$minorNode.InnerText}else{'0'}).$(if($microNode){$microNode.InnerText}else{'0'})"); Version=$version; Url=$RepositoryBaseUrl.TrimEnd('/') + '/' + $url; Sha256=$checksum.ToUpperInvariant(); SizeBytes=$sizeBytes })
    }
    $selected = $packages | Sort-Object SortVersion -Descending | Select-Object -First 1
    if (-not $selected) { throw 'Official Android repository metadata and SHA-256 download table contained no matching Windows command-line tools package.' }
    return [pscustomobject]@{ Version=$selected.Version; Url=$selected.Url; Sha256=$selected.Sha256; SizeBytes=$selected.SizeBytes }
}

function Resolve-SgAdoptiumJdkPackage {
    param($ApiObject)
    $url = [string]$ApiObject.binary.package.link
    $checksum = [string]$ApiObject.binary.package.checksum
    $version = [string]$ApiObject.version.semver
    if ($url -notmatch '^https://github[.]com/adoptium/temurin17-binaries/' -or $url -notmatch '[.]zip(?:\?|$)' -or $checksum -notmatch '^[0-9A-Fa-f]{64}$' -or $version -notmatch '^17[.]') { throw 'Adoptium JDK 17 metadata is incomplete or not from the official release authority.' }
    [pscustomobject]@{ Version=$version; Url=$url; Sha256=$checksum.ToUpperInvariant() }
}

function Get-SgServiceCliPlan {
    param($Needs, [hashtable]$Versions)
    $plan = New-Object Collections.Generic.List[object]
    foreach ($definition in @(
        @{ Need='Firebase'; Name='firebase'; Package='firebase-tools'; Manager='npm' },
        @{ Need='FlutterFire'; Name='flutterfire'; Package='flutterfire_cli'; Manager='dart' },
        @{ Need='Supabase'; Name='supabase'; Package='supabase'; Manager='npx' },
        @{ Need='Convex'; Name='convex'; Package='convex'; Manager='npx' },
        @{ Need='Vercel'; Name='vercel'; Package='vercel'; Manager='npm' },
        @{ Need='Clerk'; Name='clerk'; Package='clerk'; Manager='npm' }
    )) {
        $needProperty = $Needs.PSObject.Properties[$definition.Need]
        if (-not $needProperty -or -not [bool]$needProperty.Value) { continue }
        $version = [string]$Versions[$definition.Need]
        if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw "$($definition.Name) requires an exact resolved version." }
        $plan.Add([pscustomobject]@{ Name=$definition.Name; Package=$definition.Package; Manager=$definition.Manager; Version=$version })
    }
    return $plan.ToArray()
}

function Get-SgAgentInstallPlan {
    param([bool]$Interactive, [hashtable]$AgentReady, [hashtable]$AgentOutdated = @{}, [string]$Choice = '')
    $missing = New-Object Collections.Generic.List[string]
    $outdated = New-Object Collections.Generic.List[string]
    foreach ($name in @('Codex','Claude','OpenCode','Kilo','Gemini')) {
        if (-not [bool]$AgentReady[$name]) { $missing.Add($name) }
        elseif ([bool]$AgentOutdated[$name]) { $outdated.Add($name) }
    }
    $candidates = @($missing.ToArray()) + @($outdated.ToArray())
    $ask = $Interactive -and $candidates.Count -gt 0
    $accepted = $ask -and $Choice.Trim().ToLowerInvariant() -in @('y','yes')
    [pscustomobject]@{
        Ask = $ask
        Missing = $missing.ToArray()
        Outdated = $outdated.ToArray()
        Install = if ($accepted) { $candidates } else { @() }
        Status = if ($candidates.Count -eq 0) { 'ready' } elseif ($accepted) { 'install' } else { 'pending' }
    }
}

function Get-SgGeminiMcpAddArguments {
    param([Parameter(Mandatory=$true)]$Server)
    if ([string]$Server.Name -notmatch '^[a-z][a-z0-9-]*$') { throw 'Invalid Gemini MCP server name.' }
    if ([string]$Server.Type -eq 'remote') {
        if ([string]$Server.Url -notmatch '^https://[^\s]+$') { throw 'Invalid Gemini remote MCP URL.' }
        return @('mcp','add','--scope','user','--transport','http',[string]$Server.Name,[string]$Server.Url)
    }
    if ([string]::IsNullOrWhiteSpace([string]$Server.Command)) { throw 'Invalid Gemini local MCP command.' }
    return @('mcp','add','--scope','user',[string]$Server.Name,[string]$Server.Command) + @($Server.Arguments | ForEach-Object { [string]$_ })
}

function Get-SgGeminiMcpConfigState {
    param([Parameter(Mandatory=$true)][string]$SettingsPath, [Parameter(Mandatory=$true)]$Server)
    if (-not (Test-Path -LiteralPath $SettingsPath -PathType Leaf)) { return [pscustomobject]@{ Status='missing'; Reason='settings file or MCP entry is absent' } }
    try {
        $text = Read-SgBoundedManifestText -Path $SettingsPath
        if (-not $text) { throw 'settings file is empty or exceeds the size bound' }
        $settings = $text | ConvertFrom-Json -ErrorAction Stop
    } catch { return [pscustomobject]@{ Status='pending'; Reason='existing Gemini settings JSON is invalid or unbounded and was preserved' } }
    if (-not $settings.PSObject.Properties['mcpServers'] -or -not $settings.mcpServers) { return [pscustomobject]@{ Status='missing'; Reason='MCP entry is absent' } }
    $entryProperty = $settings.mcpServers.PSObject.Properties[[string]$Server.Name]
    if (-not $entryProperty) { return [pscustomobject]@{ Status='missing'; Reason='MCP entry is absent' } }
    $entry = $entryProperty.Value
    if ([string]$Server.Type -eq 'remote') {
        $documentedHttp = $entry.PSObject.Properties['httpUrl'] -and [string]$entry.httpUrl -ceq [string]$Server.Url
        $nativeHttp = $entry.PSObject.Properties['url'] -and [string]$entry.url -ceq [string]$Server.Url -and $entry.PSObject.Properties['type'] -and [string]$entry.type -ceq 'http'
        $ready = $documentedHttp -or $nativeHttp
    } else {
        $actualArguments = if ($entry.PSObject.Properties['args']) { @($entry.args | ForEach-Object { [string]$_ }) } else { @() }
        $expectedArguments = @($Server.Arguments | ForEach-Object { [string]$_ })
        $ready = $entry.PSObject.Properties['command'] -and [string]$entry.command -ceq [string]$Server.Command -and ($actualArguments -join "`0") -ceq ($expectedArguments -join "`0")
    }
    if ($ready) { return [pscustomobject]@{ Status='ready'; Reason='' } }
    return [pscustomobject]@{ Status='pending'; Reason='existing Gemini MCP entry differs and was preserved' }
}

function Get-SgStackMcpDefinitions {
    param($Needs, [hashtable]$Versions, [string]$NpxPath)
    $definitions = New-Object Collections.Generic.List[object]
    if ($Needs.PSObject.Properties['Firebase'] -and [bool]$Needs.Firebase) {
        $version = [string]$Versions.Firebase
        if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw 'Firebase MCP requires an exact firebase-tools version.' }
        $definitions.Add([pscustomobject]@{ Name='firebase'; Type='local'; Url=''; Command=$NpxPath; Arguments=@('-y','--registry=https://registry.npmjs.org/',"firebase-tools@$version",'mcp'); RequiresAuthentication=$true })
    }
    if ($Needs.PSObject.Properties['Convex'] -and [bool]$Needs.Convex) {
        $version = [string]$Versions.Convex
        if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw 'Convex MCP requires an exact Convex version.' }
        $definitions.Add([pscustomobject]@{ Name='convex'; Type='local'; Url=''; Command=$NpxPath; Arguments=@('-y','--registry=https://registry.npmjs.org/',"convex@$version",'mcp','start'); RequiresAuthentication=$true })
    }
    if ($Needs.PSObject.Properties['Clerk'] -and [bool]$Needs.Clerk) {
        $definitions.Add([pscustomobject]@{ Name='clerk'; Type='remote'; Url='https://mcp.clerk.com/mcp'; Command=''; Arguments=@(); RequiresAuthentication=$false })
    }
    $definitions.Add([pscustomobject]@{ Name='github'; Type='remote'; Url='https://api.githubcopilot.com/mcp/readonly'; Command=''; Arguments=@(); RequiresAuthentication=$true; ReadOnly=$true })
    return $definitions.ToArray()
}

function Test-SgServiceCliResult {
    param($InstallResult, $VerifyResult, [string]$ExecutablePath, [string]$ExpectedVersion)
    if ($ExpectedVersion -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { return $false }
    $pattern = [regex]::Escape($ExpectedVersion)
    return $InstallResult -and -not $InstallResult.TimedOut -and $InstallResult.ExitCode -eq 0 -and $VerifyResult -and -not $VerifyResult.TimedOut -and $VerifyResult.ExitCode -eq 0 -and (Test-Path -LiteralPath $ExecutablePath -PathType Leaf) -and $VerifyResult.Output -match $pattern
}

function Test-SgChromiumExecutableResult {
    param([string]$ExecutablePath, $Result)
    return (Test-Path -LiteralPath $ExecutablePath -PathType Leaf) -and $Result -and -not $Result.TimedOut -and $Result.ExitCode -eq 0 -and $Result.Output -match '(?i)(Chromium|Chrome).*\d+'
}

function Resolve-SgKiloCommand {
    param([string]$KiloPath, [string]$KilocodePath)
    if ($KiloPath) { return [pscustomobject]@{ Path=$KiloPath; CommandName='kilo'; Compatibility=$false } }
    if ($KilocodePath) { return [pscustomobject]@{ Path=$KilocodePath; CommandName='kilocode'; Compatibility=$true } }
    return [pscustomobject]@{ Path=''; CommandName=''; Compatibility=$false }
}

function Get-SgAgentMcpPlan {
    param(
        [ValidateSet('OpenCode','Kilo')][string]$Agent,
        [string]$CommandPath, [string]$DartPath, [string]$NpxPath,
        [string]$PlaywrightVersion, [bool]$ChromiumReady,
        [object[]]$AdditionalServers = @()
    )
    $servers = [ordered]@{
        dart = [ordered]@{ type='local'; command=@($DartPath,'mcp-server','--force-roots-fallback'); enabled=$true }
    }
    if ($ChromiumReady -and $PlaywrightVersion -match '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') {
        $servers.playwright = [ordered]@{ type='local'; command=@($NpxPath,'-y','--registry=https://registry.npmjs.org/',"@playwright/mcp@$PlaywrightVersion",'--headless','--browser','chromium'); enabled=$true }
    }
    foreach ($server in @($AdditionalServers)) {
        if (-not $server -or [string]$server.Name -notmatch '^[a-z][a-z0-9-]*$') { throw 'Invalid bounded stack MCP definition.' }
        if ([string]$server.Type -eq 'remote') {
            if ([string]$server.Url -notmatch '^https://[^\s]+$') { throw 'Invalid bounded remote MCP definition.' }
            $servers[[string]$server.Name] = [ordered]@{ type='remote'; url=[string]$server.Url; enabled=$true }
        } else {
            if ([string]::IsNullOrWhiteSpace([string]$server.Command)) { throw 'Invalid bounded local MCP definition.' }
            $servers[[string]$server.Name] = [ordered]@{ type='local'; command=@([string]$server.Command) + @($server.Arguments | ForEach-Object { [string]$_ }); enabled=$true }
        }
    }
    if ($Agent -eq 'OpenCode') {
        $config = [ordered]@{ '$schema'='https://opencode.ai/config.json'; mcp=[ordered]@{ servers=$servers } }
        return [pscustomobject]@{ Agent=$Agent; CommandPath=$CommandPath; CommandName='opencode'; McpShape='servers'; Config=$config }
    }
    $config = [ordered]@{ '$schema'='https://app.kilo.ai/config.json'; mcp=$servers }
    [pscustomobject]@{ Agent=$Agent; CommandPath=$CommandPath; CommandName=if ($CommandPath -match '(?i)kilocode') { 'kilocode' } else { 'kilo' }; McpShape='direct'; Config=$config }
}

function Get-SgAgentConfigWritePlan {
    param([string]$ConfigPath, [Collections.IDictionary]$Config)
    if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
        $existing = [IO.File]::ReadAllText($ConfigPath)
        $expected = ($Config | ConvertTo-Json -Depth 32) + [Environment]::NewLine
        if ($existing.Replace("`r`n","`n") -ceq $expected.Replace("`r`n","`n")) { return [pscustomobject]@{ Status='unchanged'; Reason=''; ConfigPath=$ConfigPath } }
        return [pscustomobject]@{ Status='pending'; Reason='existing config must be updated by a proven native CLI; bytes and secrets were preserved'; ConfigPath=$ConfigPath }
    }
    [pscustomobject]@{ Status='create'; Reason=''; ConfigPath=$ConfigPath }
}

function Resolve-SgAgentConfigPath {
    param([ValidateSet('OpenCode','Kilo')][string]$Agent, [string]$UserProfile)
    $relative = if ($Agent -eq 'OpenCode') { '.config\opencode\opencode' } else { '.config\kilo\kilo' }
    $jsonc = Join-Path $UserProfile ($relative + '.jsonc')
    $json = Join-Path $UserProfile ($relative + '.json')
    if (Test-Path -LiteralPath $jsonc -PathType Leaf) { return [pscustomobject]@{ Path=[IO.Path]::GetFullPath($jsonc); Exists=$true; IsJsonc=$true } }
    if (Test-Path -LiteralPath $json -PathType Leaf) { return [pscustomobject]@{ Path=[IO.Path]::GetFullPath($json); Exists=$true; IsJsonc=$false } }
    return [pscustomobject]@{ Path=[IO.Path]::GetFullPath($json); Exists=$false; IsJsonc=$false }
}

function Test-SgVersionCommand {
    param([string]$File, [string[]]$Arguments, [string]$Pattern, [scriptblock]$Runner = $null, [int]$TimeoutSeconds = 30)
    if ([string]::IsNullOrWhiteSpace($File) -or -not (Test-Path -LiteralPath $File -PathType Leaf)) { return $false }
    $result = Invoke-SgDiagnosticCommand $File $Arguments $Runner $TimeoutSeconds
    return -not $result.TimedOut -and $result.ExitCode -eq 0 -and $result.Output -match $Pattern
}

function Resolve-SgExistingJdk17 {
    param([string]$JavaHome = $env:JAVA_HOME, [string]$JavaCommand = '', [scriptblock]$Runner = $null)
    $candidates = New-Object Collections.Generic.List[string]
    if ($JavaHome) { $candidates.Add((Join-Path $JavaHome 'bin\java.exe')) }
    if ($JavaCommand) { $candidates.Add($JavaCommand) }
    foreach ($candidate in $candidates) {
        if (Test-SgVersionCommand $candidate @('-version') '(?i)(openjdk|java).*\b17\b' $Runner) {
            return [pscustomobject]@{ Ready=$true; JavaPath=[IO.Path]::GetFullPath($candidate); Home=Split-Path (Split-Path ([IO.Path]::GetFullPath($candidate)) -Parent) -Parent; Managed=$false }
        }
    }
    return [pscustomobject]@{ Ready=$false; JavaPath=''; Home=''; Managed=$false }
}

function Resolve-SgExistingAndroidSdk {
    param([string[]]$CandidateRoots, [string]$SdkManagerCommand = '', [scriptblock]$Runner = $null)
    if ($SdkManagerCommand -and (Test-SgVersionCommand $SdkManagerCommand @('--version') '\d+' $Runner)) {
        $bin = Split-Path ([IO.Path]::GetFullPath($SdkManagerCommand)) -Parent
        $root = Split-Path (Split-Path (Split-Path $bin -Parent) -Parent) -Parent
        return [pscustomobject]@{ Ready=$true; Root=$root; SdkManagerPath=[IO.Path]::GetFullPath($SdkManagerCommand); Managed=$false }
    }
    foreach ($root in @($CandidateRoots | Where-Object { $_ } | Select-Object -Unique)) {
        $full = [IO.Path]::GetFullPath($root)
        $sdkManager = Join-Path $full 'cmdline-tools\latest\bin\sdkmanager.bat'
        if (Test-SgVersionCommand $sdkManager @('--version') '\d+' $Runner) {
            return [pscustomobject]@{ Ready=$true; Root=$full; SdkManagerPath=$sdkManager; Managed=$false }
        }
    }
    return [pscustomobject]@{ Ready=$false; Root=''; SdkManagerPath=''; Managed=$false }
}

function Set-SgResolvedToolProcessEnvironment {
    param([string]$JdkHome = '', [string]$SdkRoot = '')
    if ($JdkHome) {
        if (-not (Test-Path -LiteralPath $JdkHome -PathType Container)) { throw "Resolved JDK home is unavailable: $JdkHome" }
        [Environment]::SetEnvironmentVariable('JAVA_HOME',[IO.Path]::GetFullPath($JdkHome),'Process')
    }
    if ($SdkRoot) {
        if (-not (Test-Path -LiteralPath $SdkRoot -PathType Container)) { throw "Resolved Android SDK root is unavailable: $SdkRoot" }
        $fullSdk = [IO.Path]::GetFullPath($SdkRoot)
        [Environment]::SetEnvironmentVariable('ANDROID_HOME',$fullSdk,'Process')
        [Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT',$fullSdk,'Process')
    }
}

function Expand-SgVerifiedZip {
    param(
        [Parameter(Mandatory=$true)][string]$ArchivePath,
        [Parameter(Mandatory=$true)][string]$DestinationPath,
        [Parameter(Mandatory=$true)][string]$ExpectedRelativePath,
        [int]$MaxEntries = 10000,
        [long]$MaxExpandedBytes = 4294967296
    )
    if ([IO.Path]::GetExtension($ArchivePath) -ine '.zip') { throw 'Verified archive must use the .zip format.' }
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        if ($archive.Entries.Count -gt $MaxEntries) { throw 'ZIP archive exceeds the bounded entry count.' }
        $destination = [IO.Path]::GetFullPath($DestinationPath).TrimEnd('\') + '\'
        $expected = $ExpectedRelativePath.Replace('\','/').TrimStart('/')
        $expanded = [long]0
        $matches = New-Object Collections.Generic.List[object]
        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName.Replace('\','/')
            $segments = @($name.Split('/') | Where-Object { $_ -ne '' })
            $attributesUnsigned = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]$entry.ExternalAttributes),0)
            $unixType = ($attributesUnsigned -shr 16) -band 0xF000
            if ([IO.Path]::IsPathRooted($name) -or $name.StartsWith('/') -or $segments -contains '..' -or $unixType -eq 0xA000 -or (($entry.ExternalAttributes -band [int][IO.FileAttributes]::ReparsePoint) -ne 0)) { throw "ZIP archive contains an unsafe entry: $name" }
            $expanded += [long]$entry.Length
            if ($expanded -gt $MaxExpandedBytes) { throw 'ZIP archive exceeds the bounded expanded size.' }
            if ($name.EndsWith('/' + $expected,[StringComparison]::OrdinalIgnoreCase) -or $name.Equals($expected,[StringComparison]::OrdinalIgnoreCase)) { $matches.Add($entry) }
            $target = [IO.Path]::GetFullPath((Join-Path $destination ($name.Replace('/','\'))))
            if (-not $target.StartsWith($destination,[StringComparison]::OrdinalIgnoreCase)) { throw "ZIP archive contains an unsafe entry: $name" }
        }
        if ($matches.Count -ne 1) { throw "ZIP archive must contain exactly one expected layout: $ExpectedRelativePath" }
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        foreach ($entry in $archive.Entries) {
            $relative = $entry.FullName.Replace('/','\')
            $target = [IO.Path]::GetFullPath((Join-Path $DestinationPath $relative))
            if ($entry.FullName.EndsWith('/')) { New-Item -ItemType Directory -Path $target -Force | Out-Null; continue }
            New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$target,$false)
        }
        $matchName = $matches[0].FullName.Replace('/','\')
        $rootRelative = $matchName.Substring(0,$matchName.Length - $ExpectedRelativePath.Length).TrimEnd('\')
        return [IO.Path]::GetFullPath((Join-Path $DestinationPath $rootRelative))
    } finally { $archive.Dispose() }
}

function Write-SgNewAgentConfig {
    param([string]$ConfigPath, [Collections.IDictionary]$Config)
    $next = ($Config | ConvertTo-Json -Depth 32) + [Environment]::NewLine
    if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
        $existing = [IO.File]::ReadAllText($ConfigPath)
        if ($existing.Replace("`r`n","`n") -ceq $next.Replace("`r`n","`n")) { return $false }
        throw "Existing agent config was preserved; use the agent native CLI or update it manually: $ConfigPath"
    }
    $directory = Split-Path -Parent $ConfigPath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $temp = "$ConfigPath.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temp, $next, [Text.UTF8Encoding]::new($false))
        Move-Item -LiteralPath $temp -Destination $ConfigPath
    } finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force } }
    return $true
}

function Stop-SgProcessTree([int]$ProcessId, [datetime]$ExpectedStartTimeUtc) {
    $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
    if (-not $process) { return }
    try { $actualStart = $process.StartTime.ToUniversalTime() } catch { return }
    if ([math]::Abs(($actualStart - $ExpectedStartTimeUtc.ToUniversalTime()).TotalSeconds) -gt 1) { return }
    foreach ($child in @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$ProcessId" -ErrorAction SilentlyContinue)) {
        $childProcess = Get-Process -Id ([int]$child.ProcessId) -ErrorAction SilentlyContinue
        if ($childProcess) { try { Stop-SgProcessTree ([int]$child.ProcessId) $childProcess.StartTime.ToUniversalTime() } catch {} }
    }
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

function ConvertTo-SgWindowsArgument([string]$Value) {
    if ($null -eq $Value) { $Value = '' }
    $builder = New-Object Text.StringBuilder
    [void]$builder.Append('"')
    $slashes = 0
    foreach ($character in $Value.ToCharArray()) {
        if ($character -eq '\') { $slashes++; continue }
        if ($character -eq '"') {
            [void]$builder.Append((('\' * (($slashes * 2) + 1)) -join ''))
            [void]$builder.Append('"')
            $slashes = 0
            continue
        }
        if ($slashes) { [void]$builder.Append((('\' * $slashes) -join '')); $slashes = 0 }
        [void]$builder.Append($character)
    }
    if ($slashes) { [void]$builder.Append((('\' * ($slashes * 2)) -join '')) }
    [void]$builder.Append('"')
    return $builder.ToString()
}

function ConvertTo-SgCmdBatchArgument([string]$Value, $EnvironmentVariables = $null, [ref]$UnicodeIndex = $null) {
    if ($null -eq $Value) { $Value = '' }
    $builder = New-Object Text.StringBuilder
    [void]$builder.Append('"')
    foreach ($character in $Value.ToCharArray()) {
        if ([int]$character -gt 127) {
            if ($null -eq $EnvironmentVariables -or $null -eq $UnicodeIndex) { throw 'Unicode batch transport requires the isolated environment channel.' }
            $name = "SG_UNICODE_$($UnicodeIndex.Value)"
            $UnicodeIndex.Value++
            $EnvironmentVariables[$name] = [string]$character
            [void]$builder.Append("%$name%")
            continue
        }
        switch ($character) {
            '%' { [void]$builder.Append('%%') }
            '^' { [void]$builder.Append('^^') }
            '"' { [void]$builder.Append('""') }
            default { [void]$builder.Append($character) }
        }
    }
    [void]$builder.Append('"')
    return $builder.ToString()
}

function Start-SgEncodedProcess {
    param([string]$File, [string[]]$Arguments, [string]$InputText = '', [switch]$Capture)
    $psi = New-Object Diagnostics.ProcessStartInfo
    $transportPath = ''
    $process = $null
    try {
        if ([IO.Path]::GetExtension($File) -in @('.cmd','.bat')) {
            foreach ($value in @($File) + @($Arguments)) { if ([string]$value -match "[`0`r`n]") { throw 'Batch transport rejected unsafe NUL/CR/LF input.' } }
            $transportPath = Join-Path ([IO.Path]::GetTempPath()) ("sg-transport-$([guid]::NewGuid().ToString('N')).cmd")
            $unicodeIndex = 0
            $target = ConvertTo-SgCmdBatchArgument ([IO.Path]::GetFullPath($File)) $psi.EnvironmentVariables ([ref]$unicodeIndex)
            $encodedArguments = @($Arguments | ForEach-Object { ConvertTo-SgCmdBatchArgument ([string]$_) $psi.EnvironmentVariables ([ref]$unicodeIndex) })
            $wrapper = "@echo off`r`n@setlocal DisableDelayedExpansion`r`n@$target $($encodedArguments -join ' ')`r`n"
            [IO.File]::WriteAllText($transportPath,$wrapper,[Text.Encoding]::ASCII)
            $psi.FileName = $env:ComSpec
            $psi.Arguments = '/d /s /c "' + (ConvertTo-SgWindowsArgument $transportPath) + '"'
        } else {
            $psi.FileName = $File
            $psi.Arguments = (@($Arguments | ForEach-Object { ConvertTo-SgWindowsArgument ([string]$_) }) -join ' ')
        }
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = [bool]$Capture
        if ($Capture) { $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true }
        if ($InputText) { $psi.RedirectStandardInput = $true }
        $process = New-Object Diagnostics.Process
        $process.StartInfo = $psi
        if (-not $process.Start()) { throw "Failed to start bounded process: $File" }
        if ($InputText) { $process.StandardInput.WriteLine($InputText); $process.StandardInput.Close() }
        $process | Add-Member -NotePropertyName SgTransportPath -NotePropertyValue $transportPath
        return $process
    } catch {
        if ($process) {
            try { if (-not $process.HasExited) { Stop-SgProcessTree $process.Id $process.StartTime.ToUniversalTime() } } catch {}
            $process.Dispose()
        }
        if ($transportPath -and (Test-Path -LiteralPath $transportPath)) { Remove-Item -LiteralPath $transportPath -Force }
        throw
    }
}

function Invoke-SgBoundedProcess {
    param([string]$File, [string[]]$Arguments, [int]$TimeoutSeconds = 60, [string]$InputText = '', [scriptblock]$ProgressCallback)
    $process = $null
    try {
        $process = Start-SgEncodedProcess -File $File -Arguments $Arguments -InputText $InputText -Capture
        $startTime = $process.StartTime.ToUniversalTime()
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $watch = [Diagnostics.Stopwatch]::StartNew()
        while (-not $process.WaitForExit(200)) {
            if ($ProgressCallback) { & $ProgressCallback ([int][Math]::Floor($watch.Elapsed.TotalSeconds)) }
            if ($watch.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
                Stop-SgProcessTree $process.Id $startTime
                return [pscustomobject]@{ ExitCode=-1; Output='Command timed out and its process tree was stopped.'; TimedOut=$true }
            }
        }
        $process.WaitForExit()
        $output = @($stdoutTask.Result,$stderrTask.Result) -join [Environment]::NewLine
        return [pscustomobject]@{ ExitCode=$process.ExitCode; Output=$output.Trim(); TimedOut=$false }
    } catch { return [pscustomobject]@{ ExitCode=-1; Output=$_.Exception.Message; TimedOut=$false } }
    finally {
        if ($process) {
            $transportPath = [string]$process.SgTransportPath
            $process.Dispose()
            if ($transportPath -and (Test-Path -LiteralPath $transportPath)) { Remove-Item -LiteralPath $transportPath -Force }
        }
    }
}

function Invoke-SgInteractiveBoundedProcess {
    param([string]$File, [string[]]$Arguments, [int]$TimeoutSeconds)
    $process = $null
    try {
        $process = Start-SgEncodedProcess -File $File -Arguments $Arguments
        $startTime = $process.StartTime.ToUniversalTime()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) { Stop-SgProcessTree $process.Id $startTime; return $false }
        return $process.ExitCode -eq 0
    } catch { return $false }
    finally {
        if ($process) {
            $transportPath = [string]$process.SgTransportPath
            $process.Dispose()
            if ($transportPath -and (Test-Path -LiteralPath $transportPath)) { Remove-Item -LiteralPath $transportPath -Force }
        }
    }
}

function Invoke-SgDiagnosticCommand {
    param([string]$File, [string[]]$Arguments, [scriptblock]$Runner, [int]$TimeoutSeconds = 60)
    if ($Runner) { return & $Runner $File $Arguments $TimeoutSeconds }
    return Invoke-SgBoundedProcess -File $File -Arguments $Arguments -TimeoutSeconds $TimeoutSeconds
}

function Get-SgFlutterAndroidDiagnostic {
    param(
        [string]$FlutterPath, [string]$DartPath, [string]$JavaPath, [string]$SdkManagerPath, [string]$AdbPath, [string]$EmulatorPath,
        [scriptblock]$Runner = $null
    )
    if ([string]::IsNullOrWhiteSpace($FlutterPath)) {
        return [pscustomobject]@{ ToolchainReady=$false; LicensesReady=$false; DeviceReady=$false; TimedOut=$false; Reason='Flutter executable is missing.' }
    }
    $flutterVersion = Invoke-SgDiagnosticCommand $FlutterPath @('--version') $Runner 30
    $dartVersion = Invoke-SgDiagnosticCommand $DartPath @('--version') $Runner 30
    $javaVersion = Invoke-SgDiagnosticCommand $JavaPath @('-version') $Runner 30
    $sdkVersion = Invoke-SgDiagnosticCommand $SdkManagerPath @('--version') $Runner 30
    $adbVersion = Invoke-SgDiagnosticCommand $AdbPath @('version') $Runner 30
    $doctor = Invoke-SgDiagnosticCommand $FlutterPath @('doctor','-v') $Runner 90
    $devices = Invoke-SgDiagnosticCommand $FlutterPath @('devices') $Runner 45
    $timedOut = @($flutterVersion,$dartVersion,$javaVersion,$sdkVersion,$adbVersion,$doctor,$devices | Where-Object TimedOut).Count -gt 0
    $versionsReady = $flutterVersion.ExitCode -eq 0 -and $flutterVersion.Output -match '(?m)^Flutter \d+' -and $dartVersion.ExitCode -eq 0 -and $dartVersion.Output -match '(?i)Dart SDK version|Flutter \d+' -and $javaVersion.ExitCode -eq 0 -and $javaVersion.Output -match '(?i)(openjdk|java).*\b17\b' -and $sdkVersion.ExitCode -eq 0 -and $sdkVersion.Output -match '\d+' -and $adbVersion.ExitCode -eq 0 -and $adbVersion.Output -match '(?i)Android Debug Bridge'
    $successMarker = '(?:' + [regex]::Escape([string][char]0x2713) + '|' + [regex]::Escape([string][char]0x221A) + ')'
    $duration = '(?:\s+\[[0-9]+(?:[.,][0-9]+)?(?:ms|s)\])?'
    $androidDoctor = $doctor.ExitCode -eq 0 -and $doctor.Output -match "(?m)^\[$successMarker\]\s+Android toolchain - develop for Android devices(?:\s+\([^\r\n]+\))?$duration\s*$"
    $bullet = [regex]::Escape([string][char]0x2022)
    $licensesReady = $androidDoctor -and $doctor.Output -match "(?im)^\s*(?:$bullet\s+)?All Android licenses accepted[.]?\s*$"
    $deviceReady = $devices.ExitCode -eq 0 -and $devices.Output -match '(?im)\b(android|device-[0-9]+)\b' -and $devices.Output -notmatch '(?i)No devices detected|0 connected devices'
    $toolchainReady = -not $timedOut -and $versionsReady -and $androidDoctor -and $licensesReady
    $reason = if ($timedOut) { 'A bounded diagnostic timed out.' } elseif (-not $versionsReady) { 'Flutter, Dart, JDK 17, sdkmanager, or adb version evidence is missing.' } elseif (-not $androidDoctor) { 'flutter doctor did not confirm the Android toolchain.' } elseif (-not $licensesReady) { 'Android SDK licenses are pending.' } elseif (-not $deviceReady) { 'No usable Android device is connected.' } else { '' }
    [pscustomobject]@{
        ToolchainReady = $toolchainReady
        LicensesReady = $licensesReady
        DeviceReady = $deviceReady
        EmulatorInstalled = -not [string]::IsNullOrWhiteSpace($EmulatorPath)
        TimedOut = $timedOut
        Reason = $reason
        DoctorOutput = $doctor.Output
        DevicesOutput = $devices.Output
    }
}

Export-ModuleMember -Function Move-SgAtomicReplace,Get-SgTauriAndroidBaseline,Get-SgTauriAndroidProjectState,New-SgTauriAndroidMigrationHandoff,Get-SgTauriMiseConfig,Get-SgTauriAndroidHostPlan,Get-SgAndroidCoordinates,Test-SgSupportedAndroidArchitecture,Get-SgAndroidInstallPlan,Get-SgWindowsIdeInstallPlan,Get-SgAndroidStudioState,Get-SgVisualStudioCppState,Get-SgAndroidProvisionPlan,Test-SgAndroidLicenseResult,Test-SgWindowsDeveloperMode,Get-SgDeveloperModeGuidancePlan,Test-SgWindowsHypervisorEvidence,Test-SgAndroidAcceleration,Get-SgEmulatorProvisionPlan,Get-SgAndroidEmulatorProvisionState,Get-SgFlutterInstallState,Get-SgProjectServiceNeeds,Resolve-SgAndroidCommandLineToolsPackage,Resolve-SgAdoptiumJdkPackage,Get-SgServiceCliPlan,Get-SgAgentInstallPlan,Get-SgGeminiMcpAddArguments,Get-SgGeminiMcpConfigState,Get-SgStackMcpDefinitions,Test-SgServiceCliResult,Test-SgChromiumExecutableResult,Resolve-SgKiloCommand,Get-SgAgentMcpPlan,Get-SgAgentConfigWritePlan,Resolve-SgAgentConfigPath,Write-SgNewAgentConfig,Test-SgVersionCommand,Resolve-SgExistingJdk17,Resolve-SgExistingAndroidSdk,Set-SgResolvedToolProcessEnvironment,Expand-SgVerifiedZip,Stop-SgProcessTree,Invoke-SgBoundedProcess,Invoke-SgInteractiveBoundedProcess,Get-SgFlutterAndroidDiagnostic
