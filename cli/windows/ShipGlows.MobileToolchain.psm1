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
    param([bool]$Interactive, [bool]$EmulatorSupported, [string]$EmulatorChoice = '')
    $ask = $Interactive -and $EmulatorSupported
    $installEmulator = $ask -and $EmulatorChoice.Trim().ToLowerInvariant() -in @('y','yes')
    [pscustomobject]@{
        AskEmulator = $ask
        InstallEmulator = $installEmulator
        PhysicalDeviceAlternative = -not $installEmulator
        LicensesPending = -not $Interactive
        LicenseCommand = 'sdkmanager --licenses'
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

function Get-SgProjectServiceNeeds {
    param([Parameter(Mandatory=$true)][string]$Workspace, [int]$MaxDirectories = 5000)
    $root = [IO.Path]::GetFullPath($Workspace)
    $flutterFire = $false
    $firebase = $false
    $supabase = $false
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
        $pubspec = Join-Path $current.Path 'pubspec.yaml'
        if (Test-Path -LiteralPath $pubspec -PathType Leaf) {
            $flutterFire = $flutterFire -or [regex]::IsMatch([IO.File]::ReadAllText($pubspec), '(?m)^\s*(firebase_core|cloud_firestore|firebase_auth|firebase_[a-z0-9_]+)\s*:')
        }
        if ($current.Depth -ge 4) { continue }
        foreach ($directory in @(Get-ChildItem -LiteralPath $current.Path -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($directory.Name -in @('.git','node_modules','.dart_tool','build','.venv','.idea')) { continue }
            if (($directory.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            $queue.Enqueue([pscustomobject]@{ Path=$directory.FullName; Depth=$current.Depth + 1 })
        }
    }
    [pscustomobject]@{ Firebase=[bool]$firebase; FlutterFire=[bool]$flutterFire; Supabase=[bool]$supabase; DirectoriesVisited=$visited; ScanLimitReached=$limitReached }
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
        @{ Need='Supabase'; Name='supabase'; Package='supabase'; Manager='npx' }
    )) {
        if (-not [bool]$Needs.($definition.Need)) { continue }
        $version = [string]$Versions[$definition.Need]
        if ($version -notmatch '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') { throw "$($definition.Name) requires an exact resolved version." }
        $plan.Add([pscustomobject]@{ Name=$definition.Name; Package=$definition.Package; Manager=$definition.Manager; Version=$version })
    }
    return $plan.ToArray()
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
        [string]$PlaywrightVersion, [bool]$ChromiumReady
    )
    $servers = [ordered]@{
        dart = [ordered]@{ type='local'; command=@($DartPath,'mcp-server','--force-roots-fallback'); enabled=$true }
    }
    if ($ChromiumReady -and $PlaywrightVersion -match '^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$') {
        $servers.playwright = [ordered]@{ type='local'; command=@($NpxPath,'-y','--registry=https://registry.npmjs.org/',"@playwright/mcp@$PlaywrightVersion",'--headless','--browser','chromium'); enabled=$true }
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
    param([string]$File, [string[]]$Arguments, [int]$TimeoutSeconds = 60, [string]$InputText = '')
    $process = $null
    try {
        $process = Start-SgEncodedProcess -File $File -Arguments $Arguments -InputText $InputText -Capture
        $startTime = $process.StartTime.ToUniversalTime()
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            Stop-SgProcessTree $process.Id $startTime
            return [pscustomobject]@{ ExitCode=-1; Output='Command timed out and its process tree was stopped.'; TimedOut=$true }
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

Export-ModuleMember -Function Move-SgAtomicReplace,Get-SgAndroidCoordinates,Test-SgSupportedAndroidArchitecture,Get-SgAndroidInstallPlan,Get-SgAndroidProvisionPlan,Test-SgAndroidLicenseResult,Test-SgWindowsDeveloperMode,Test-SgWindowsHypervisorEvidence,Test-SgAndroidAcceleration,Get-SgEmulatorProvisionPlan,Get-SgFlutterInstallState,Get-SgProjectServiceNeeds,Resolve-SgAndroidCommandLineToolsPackage,Resolve-SgAdoptiumJdkPackage,Get-SgServiceCliPlan,Test-SgServiceCliResult,Test-SgChromiumExecutableResult,Resolve-SgKiloCommand,Get-SgAgentMcpPlan,Get-SgAgentConfigWritePlan,Resolve-SgAgentConfigPath,Write-SgNewAgentConfig,Test-SgVersionCommand,Resolve-SgExistingJdk17,Resolve-SgExistingAndroidSdk,Set-SgResolvedToolProcessEnvironment,Expand-SgVerifiedZip,Stop-SgProcessTree,Invoke-SgBoundedProcess,Invoke-SgInteractiveBoundedProcess,Get-SgFlutterAndroidDiagnostic
