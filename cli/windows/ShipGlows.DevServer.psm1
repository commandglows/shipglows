Set-StrictMode -Version Latest

$script:RegistryVersion = 1
$script:DefaultPortStart = 3000
$script:DefaultPortEnd = 3100
$script:ProjectIndexSchemaVersion = 1
$script:ProjectScannerVersion = '1'
$script:ProjectIndexTtlMinutes = 5
$script:ProjectCatalogMemory = @{}
$script:ProjectEnvironmentSchema = 'shipglows-project-environment/v2'
$script:ProjectEnvironmentBegin = '<!-- >>> ShipGlows development environment >>> -->'
$script:ProjectEnvironmentEnd = '<!-- <<< ShipGlows development environment <<< -->'

function Write-SgInfo([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Cyan }
function Write-SgWarn([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Yellow }
function Write-SgError([string]$Message) { Write-Host "[ShipGlows] $Message" -ForegroundColor Red }

function Get-SgDevConfig {
    $workspace = if ($env:SHIPGLOWS_WINDOWS_WORKSPACE) { $env:SHIPGLOWS_WINDOWS_WORKSPACE } else { Join-Path $env:USERPROFILE 'ShipGlows' }
    $runtime = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'ShipGlows\DevServer' } else { Join-Path $env:USERPROFILE 'AppData\Local\ShipGlows\DevServer' }
    [pscustomobject]@{
        Workspace = [IO.Path]::GetFullPath($workspace)
        RuntimeDirectory = [IO.Path]::GetFullPath($runtime)
        RegistryPath = Join-Path $runtime 'registry.json'
        LockPath = Join-Path $runtime 'registry.lock'
        ProjectIndexPath = Join-Path $runtime 'project-index.json'
        LogDirectory = Join-Path $runtime 'logs'
        PortStart = $script:DefaultPortStart
        PortEnd = $script:DefaultPortEnd
    }
}

function Ensure-SgDirectory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function ConvertTo-SgCanonicalPath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Project path is required.' }
    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    $full = [IO.Path]::GetFullPath($expanded)
    if (-not (Test-Path -LiteralPath $full -PathType Container)) { throw "Project path does not exist: $full" }
    return $full.TrimEnd('\','/')
}

function Test-SgProjectPath([string]$Path, [string]$Workspace) {
    try {
        $full = ConvertTo-SgCanonicalPath $Path
        $root = ConvertTo-SgCanonicalPath $Workspace
        $rootPrefix = $root.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
        return $full.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or $full.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)
    } catch { return $false }
}

function Test-SgGitUrl([string]$Url) {
    if ([string]::IsNullOrWhiteSpace($Url)) { return $false }
    if ($Url -match '://[^/]*:') { return $false }
    return $Url -match '^(https://|ssh://|git@)[^\s]+$'
}

function Get-SgRegistryDefault {
    [pscustomobject]@{ schemaVersion = $script:RegistryVersion; projects = @() }
}

function Read-SgRegistry([object]$Config) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    if (-not (Test-Path -LiteralPath $Config.RegistryPath -PathType Leaf)) { return Get-SgRegistryDefault }
    try {
        $raw = Get-Content -LiteralPath $Config.RegistryPath -Raw -ErrorAction Stop
        $data = $raw | ConvertFrom-Json -ErrorAction Stop
        if ($data.schemaVersion -ne $script:RegistryVersion -or $null -eq $data.projects) { throw 'Unsupported registry schema.' }
        return $data
    } catch {
        $backup = "$($Config.RegistryPath).invalid"
        try { Copy-Item -LiteralPath $Config.RegistryPath -Destination $backup -Force } catch { }
        Write-SgWarn "Registry invalid; using an empty recoverable view. Backup: $backup"
        return Get-SgRegistryDefault
    }
}

function Write-SgRegistry([object]$Config, [object]$Registry) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    $temp = "$($Config.RegistryPath).$([guid]::NewGuid().ToString('N')).tmp"
    $json = $Registry | ConvertTo-Json -Depth 10
    try {
        Set-Content -LiteralPath $temp -Value $json -Encoding UTF8 -ErrorAction Stop
        $parsed = (Get-Content -LiteralPath $temp -Raw) | ConvertFrom-Json -ErrorAction Stop
        if ($parsed.schemaVersion -ne $script:RegistryVersion) { throw 'Registry validation failed.' }
        if (Test-Path -LiteralPath $Config.RegistryPath -PathType Leaf) {
            $backup = "$($Config.RegistryPath).bak"
            try { [IO.File]::Replace($temp, $Config.RegistryPath, $backup) }
            finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else {
            Move-Item -LiteralPath $temp -Destination $Config.RegistryPath -Force
        }
    } finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Invoke-SgRegistryMutation([object]$Config, [scriptblock]$Mutation) {
    Ensure-SgDirectory $Config.RuntimeDirectory
    $lock = $null
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try {
                $lock = [IO.File]::Open($Config.LockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
            } catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 25
            }
        } while (-not $lock)
        $registry = Read-SgRegistry $Config
        & $Mutation $registry
        Write-SgRegistry $Config $registry
        return $registry
    } finally {
        if ($lock) { $lock.Dispose() }
    }
}

function Get-SgCommandPath([string[]]$Names) {
    foreach ($name in $Names) {
        $command = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) { return $command.Source }
    }
    return $null
}

function Get-SgFlutterCommandPath {
    $command = Get-SgCommandPath @('flutter.cmd','flutter.bat','flutter.exe')
    if ($command) { return $command }
    $localAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [Environment]::GetFolderPath('LocalApplicationData') }
    if ([string]::IsNullOrWhiteSpace($localAppData)) { return $null }
    $managedRoot = Join-Path $localAppData 'ShipGlows\flutter'
    $flutter = Join-Path $managedRoot 'bin\flutter.bat'
    $dart = Join-Path $managedRoot 'bin\dart.bat'
    foreach ($path in @($managedRoot,$flutter,$dart)) {
        if (-not (Test-Path -LiteralPath $path)) { return $null }
        $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if (-not $item -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $null }
    }
    return [IO.Path]::GetFullPath($flutter)
}

function Read-SgNodePackage([string]$ProjectPath) {
    $path = Join-Path $ProjectPath 'package.json'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try { return [IO.File]::ReadAllText($path) | ConvertFrom-Json -ErrorAction Stop }
    catch { throw "Invalid package.json: $($_.Exception.Message)" }
}

function Get-SgNodeDependencyNames([object]$Package) {
    $names = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    if (-not $Package) { return @() }
    foreach ($sectionName in @('dependencies','devDependencies','peerDependencies')) {
        $section = $Package.PSObject.Properties[$sectionName]
        if (-not $section -or -not $section.Value) { continue }
        foreach ($dependency in @($section.Value.PSObject.Properties)) { [void]$names.Add([string]$dependency.Name) }
    }
    return @($names)
}

function Get-SgNodeScript([object]$Package, [string]$Name) {
    if (-not $Package) { return $null }
    $scripts = $Package.PSObject.Properties['scripts']
    if (-not $scripts -or -not $scripts.Value) { return $null }
    $script = $scripts.Value.PSObject.Properties[$Name]
    if (-not $script -or [string]::IsNullOrWhiteSpace([string]$script.Value)) { return $null }
    return [string]$script.Value
}

function Test-SgBrowserExtensionPackage([object]$Package) {
    if (-not (Get-SgNodeScript $Package 'dev:chrome')) { return $false }
    $dependencies = @(Get-SgNodeDependencyNames $Package)
    return $dependencies -contains '@crxjs/vite-plugin'
}

function Get-SgNodePackageManager([string]$ProjectPath) {
    $pnpmLock = Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf
    if (-not $pnpmLock) {
        $npm = Get-SgCommandPath @('npm.cmd','npm.exe')
        if (-not $npm) { throw 'npm is required but unavailable.' }
        return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($npm); PrefixArguments=@(); Name='npm'; Pinned=$false }
    }

    $package = Read-SgNodePackage $ProjectPath
    $declaration = if ($package -and $package.PSObject.Properties['packageManager']) { ([string]$package.packageManager).Trim() } else { '' }
    if ($declaration) {
        if ($declaration -notmatch '^pnpm@(?<version>[0-9]+[.][0-9]+[.][0-9]+(?:-[0-9A-Za-z.-]+)?)$') {
            throw "Unsupported packageManager declaration '$declaration'; expected an exact pnpm@x.y.z version."
        }
        $corepack = Get-SgCommandPath @('corepack.cmd','corepack.exe')
        if (-not $corepack) { throw "Corepack is required by packageManager '$declaration' but is unavailable." }
        return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($corepack); PrefixArguments=@($declaration); Name='pnpm'; Pinned=$true }
    }

    $pnpm = Get-SgCommandPath @('pnpm.cmd','pnpm.exe')
    if (-not $pnpm) { throw 'pnpm is required by pnpm-lock.yaml but is unavailable.' }
    return [pscustomobject]@{ Manager=[IO.Path]::GetFullPath($pnpm); PrefixArguments=@(); Name='pnpm'; Pinned=$false }
}

function Get-SgProjectKind([string]$ProjectPath) {
    $package = Join-Path $ProjectPath 'package.json'
    $pubspec = Join-Path $ProjectPath 'pubspec.yaml'
    if ([IO.File]::Exists($package)) {
        $json = Read-SgNodePackage $ProjectPath
        $all = @(Get-SgNodeDependencyNames $json)
        $hasDevScript = [bool](Get-SgNodeScript $json 'dev')
        if (Test-SgBrowserExtensionPackage $json) { return 'browser-extension' }
        if ($all -contains 'astro' -and $hasDevScript) { return 'astro' }
        if ($all -contains 'vite' -and $hasDevScript) { return 'vite' }
    }
    if ([IO.File]::Exists($pubspec) -and [IO.Directory]::Exists((Join-Path $ProjectPath 'web'))) {
        if ([IO.File]::ReadAllText($pubspec) -match '(?m)^\s*flutter:\s*$') { return 'flutter-web' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'pyproject.toml'))) {
        if ([IO.File]::Exists((Join-Path $ProjectPath 'uv.lock'))) { return 'python' }
        if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    }
    if ([IO.File]::Exists((Join-Path $ProjectPath 'requirements.txt'))) { return 'python' }
    throw "Unsupported or ambiguous project. Supported kinds: Astro, Vite, browser extensions with dev:chrome, Python/FastAPI with uv/requirements, Flutter Web."
}

function Get-SgProjectExperience([string]$Kind, [int]$Port = 0) {
    $portValue = if ($Port -gt 0) { ":$Port" } else { 'pending' }
    switch ($Kind) {
        'browser-extension' {
            return [pscustomobject]@{
                Label = 'Chrome extension'
                PortLabel = "HMR $portValue"
                Artifact = 'dist\chrome'
                StartOutcome = 'Manifest V3 build ready in dist\chrome'
                StartNextAction = 'Next: run s open -ProjectPath <path> to open Chrome extension tools.'
                OpenAction = 'Open chrome://extensions and the unpacked directory.'
                OpenNextAction = 'In Chrome, enable Developer mode, choose Load unpacked, and select dist\chrome.'
            }
        }
        'flutter-web' {
            return [pscustomobject]@{
                Label = 'Flutter app'
                PortLabel = "App $portValue"
                Artifact = 'managed Chrome session'
                StartOutcome = 'Managed Flutter app session ready'
                StartNextAction = 'Next: run s open -ProjectPath <path> to open or focus the managed app session.'
                OpenAction = 'Open or focus the managed Chrome app session.'
                OpenNextAction = 'Validate the app, then run s stop -ProjectPath <path> when finished.'
            }
        }
        default {
            return [pscustomobject]@{
                Label = 'Web project'
                PortLabel = "URL $portValue"
                Artifact = $(if ($Port -gt 0) { "http://127.0.0.1:$Port" } else { 'local URL pending' })
                StartOutcome = $(if ($Port -gt 0) { "Local URL ready at http://127.0.0.1:$Port" } else { 'Local URL pending first start' })
                StartNextAction = 'Next: run s open -ProjectPath <path> to open the managed local URL.'
                OpenAction = 'Open the managed local URL.'
                OpenNextAction = 'Use the local project, then run s stop -ProjectPath <path> when finished.'
            }
        }
    }
}

function Format-SgProjectStatus([object]$Entry) {
    if (-not $Entry) { return 'unknown project' }
    $kind = if ($Entry.PSObject.Properties['kind'] -and $Entry.kind) { [string]$Entry.kind } else { 'unknown' }
    $port = if ($Entry.PSObject.Properties['port']) { [int]$Entry.port } else { 0 }
    $status = if ($Entry.PSObject.Properties['status'] -and $Entry.status) { [string]$Entry.status } else { 'discovered' }
    $experience = Get-SgProjectExperience $kind $port
    $artifact = if ($kind -eq 'browser-extension') { " | $($experience.Artifact)" } else { '' }
    return "$status | $($experience.Label) | $($experience.PortLabel)$artifact"
}

function Get-SgProjectDescriptors([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $candidates = @()
    $queue = New-Object System.Collections.Generic.Queue[object]
    [void]$queue.Enqueue([pscustomobject]@{ Path = $root; Depth = 0 })
    $pruneDirs = @('.git', 'node_modules', 'venv', '.venv', '__pycache__', 'target', '.next', '.nuxt', 'dist', '.cache', '.pnpm', '.yarn')
    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        try {
            $kind = Get-SgProjectKind ([string]$item.Path)
            $candidates += [pscustomobject]@{ RootPath = $root; LaunchPath = [string]$item.Path; Kind = $kind; Depth = [int]$item.Depth }
        } catch {
            if ($_.Exception.Message -notlike 'Unsupported or ambiguous project.*') { throw }
        }
        if ([int]$item.Depth -ge 3) { continue }
        foreach ($dir in @(Get-ChildItem -LiteralPath ([string]$item.Path) -Directory -Force -ErrorAction SilentlyContinue)) {
            if ($pruneDirs -contains $dir.Name) { continue }
            if ($dir.Name -match '^\.' ) { continue }
            if ($dir.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            [void]$queue.Enqueue([pscustomobject]@{ Path = $dir.FullName; Depth = ([int]$item.Depth + 1) })
        }
    }
    $selected = @($candidates | Sort-Object -Property Depth,LaunchPath)
    if ($selected.Count -eq 0) { throw "No supported Windows launch target was detected at or below: $root" }
    return $selected
}

function Get-SgProjectDescriptor([string]$ProjectPath) {
    $descriptors = @(Get-SgProjectDescriptors $ProjectPath)
    if ($descriptors.Count -gt 1) { throw "Multiple runnable surfaces were detected. Choose one surface instead of the monorepo root: $ProjectPath" }
    return $descriptors[0]
}

function Get-SgRuntimeSettings([string]$ProjectPath) {
    $settings = [pscustomobject]@{ Port = 0; AutoRepair = $true; FlutterDevice = 'chrome'; DartDefineFile = $null }
    $file = Join-Path $ProjectPath '.shipglows.env'
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { return $settings }
    foreach ($rawLine in @(Get-Content -LiteralPath $file)) {
        $line = ([string]$rawLine).Trim()
        if (-not $line -or $line.StartsWith('#')) { continue }
        if ($line -match '^SHIPGLOWS_ENV_PORT=(.+)$') {
            $value = $Matches[1].Trim()
            if ($value -notmatch '^\d+$' -or [int]$value -lt 1024 -or [int]$value -gt 65535) { throw "Invalid SHIPGLOWS_ENV_PORT in $file; expected a port between 1024 and 65535." }
            $settings.Port = [int]$value
        } elseif ($line -match '^SHIPGLOWS_AUTO_REPAIR=(true|false)$') {
            $settings.AutoRepair = $Matches[1] -eq 'true'
        } elseif ($line -match '^SHIPGLOWS_FLUTTER_DEVICE=(chrome|web-server)$') {
            $settings.FlutterDevice = $Matches[1]
        } elseif ($line -match '^SHIPGLOWS_DART_DEFINE_FILE=(.+)$') {
            $relative = $Matches[1].Trim()
            if ([IO.Path]::IsPathRooted($relative)) { throw "SHIPGLOWS_DART_DEFINE_FILE in $file must be relative to the project." }
            $resolved = [IO.Path]::GetFullPath((Join-Path $ProjectPath $relative))
            $root = [IO.Path]::GetFullPath($ProjectPath).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
            if (-not $resolved.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "SHIPGLOWS_DART_DEFINE_FILE in $file must resolve to an existing file inside the project." }
            $settings.DartDefineFile = $resolved
        } else {
            throw "Unsupported line in ${file}: $line. Allowed keys: SHIPGLOWS_ENV_PORT, SHIPGLOWS_AUTO_REPAIR, SHIPGLOWS_FLUTTER_DEVICE, and SHIPGLOWS_DART_DEFINE_FILE."
        }
    }
    return $settings
}

function Get-SgFreePort([object]$Config, [int]$RequestedPort = 0, [string]$OwnerPath = '') {
    $reserved = @((Read-SgRegistry $Config).projects | Where-Object { $_.port -and (-not $OwnerPath -or $_.path -ne $OwnerPath) } | ForEach-Object { [int]$_.port })
    $candidates = if ($RequestedPort -gt 0) { @($RequestedPort) } else { $Config.PortStart..$Config.PortEnd }
    foreach ($port in $candidates) {
        if ($reserved -contains $port) { continue }
        $listener = $null
        if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
            $listener = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        } else {
            $tcp = New-Object Net.Sockets.TcpClient
            try { $tcp.Connect('127.0.0.1', $port); $listener = $true } catch { $listener = $null } finally { $tcp.Dispose() }
        }
        if (-not $listener) { return $port }
    }
    throw "No free localhost port is available in the requested range."
}

function Test-SgPortAvailable([int]$Port) {
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        return -not [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1)
    }
    $tcp = New-Object Net.Sockets.TcpClient
    try {
        $tcp.Connect('127.0.0.1', $Port)
        return $false
    } catch {
        return $true
    } finally {
        $tcp.Dispose()
    }
}

function Reserve-SgProjectPort([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0, [bool]$Explicit = $false) {
    if ($RequestedPort -ne 0 -and ($RequestedPort -lt 1024 -or $RequestedPort -gt 65535)) { throw 'Requested port must be 0 or between 1024 and 65535.' }
    $token = [guid]::NewGuid().ToString('N')
    $result = Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath } | Select-Object -First 1
        if (-not $entry) { throw "Project is not registered: $ProjectPath" }

        $now = (Get-Date).ToUniversalTime()
        foreach ($item in @($data.projects)) {
            $hasReservationTime = $item.PSObject.Properties['reservationTimeUtc'] -and $item.reservationTimeUtc
            if ($item.status -in @('reserved','starting') -and $hasReservationTime) {
                $expired = $true
                try {
                    $expired = ($now - [datetime]::Parse([string]$item.reservationTimeUtc).ToUniversalTime()).TotalMinutes -ge 5
                } catch {
                    # Corrupt reservation metadata cannot retain a port lock.
                    $expired = $true
                }
                if ($expired -and -not (Test-SgProcessIdentity $item)) {
                    $item.status = 'stopped'
                    $item | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
                    $item | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
                }
            }
        }

        $otherPorts = @($data.projects | Where-Object { $_.path -ne $ProjectPath -and [int]$_.port -gt 0 } | ForEach-Object { [int]$_.port })
        $existingPort = if ($entry.PSObject.Properties['port']) { [int]$entry.port } else { 0 }
        $candidates = if ($RequestedPort -gt 0) {
            @($RequestedPort)
        } elseif ($existingPort -gt 0) {
            @($existingPort) + @($Config.PortStart..$Config.PortEnd | Where-Object { $_ -ne $existingPort })
        } else {
            @($Config.PortStart..$Config.PortEnd)
        }

        $selected = 0
        foreach ($candidate in $candidates) {
            if ($otherPorts -contains $candidate -or -not (Test-SgPortAvailable $candidate)) {
                if ($Explicit) { throw "Configured port $candidate is already occupied or reserved." }
                continue
            }
            $selected = $candidate
            break
        }
        if ($selected -le 0) { throw 'No free localhost port is available in the requested range.' }

        $entry.port = $selected
        $entry.status = 'reserved'
        $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $token -Force
        $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $now.ToString('o') -Force
    }
    $reservedEntry = $result.projects | Where-Object { $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $token } | Select-Object -First 1
    if (-not $reservedEntry) { throw "Port reservation could not be persisted for: $ProjectPath" }
    return [pscustomobject]@{ Port = [int]$reservedEntry.port; Token = $token }
}

function Set-SgReservationState([object]$Config, [string]$ProjectPath, [string]$Token, [string]$Status, [object]$EntryData = $null) {
    Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath -and $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $Token } | Select-Object -First 1
        if (-not $entry) { throw "Port reservation was lost for: $ProjectPath" }
        if ($EntryData) {
            foreach ($property in $EntryData.PSObject.Properties) {
                $entry | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value -Force
            }
        }
        $entry.status = $Status
        if ($Status -notin @('reserved','starting')) {
            $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
            $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
        }
    } | Out-Null
}

function Release-SgProjectPort([object]$Config, [string]$ProjectPath, [string]$Token, [string]$ErrorMessage = '') {
    Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { $_.path -eq $ProjectPath -and $_.PSObject.Properties['reservationToken'] -and $_.reservationToken -eq $Token } | Select-Object -First 1
        if (-not $entry) { return }
        $entry.status = 'error'
        $entry | Add-Member -NotePropertyName lastError -NotePropertyValue $ErrorMessage -Force
        $entry | Add-Member -NotePropertyName pid -NotePropertyValue 0 -Force
        $entry | Add-Member -NotePropertyName startTimeUtc -NotePropertyValue $null -Force
        $entry | Add-Member -NotePropertyName reservationToken -NotePropertyValue $null -Force
        $entry | Add-Member -NotePropertyName reservationTimeUtc -NotePropertyValue $null -Force
    } | Out-Null
}

function Get-SgProcessSnapshot([int]$Pid) {
    if ($Pid -le 0) { return $null }
    $process = Get-Process -Id $Pid -ErrorAction SilentlyContinue
    if (-not $process) { return $null }
    $cim = Get-CimInstance Win32_Process -Filter "ProcessId = $Pid" -ErrorAction SilentlyContinue
    $start = $null
    try { $start = $process.StartTime.ToUniversalTime().ToString('o') } catch { }
    [pscustomobject]@{
        Pid = $Pid
        StartTimeUtc = $start
        ExecutablePath = if ($cim) { $cim.ExecutablePath } else { $null }
        CommandLine = if ($cim) { $cim.CommandLine } else { $null }
    }
}

function Get-SgProcessSnapshotMap([int[]]$Pids) {
    $result = @{}
    $ids = @($Pids | Where-Object { $_ -gt 0 } | Sort-Object -Unique)
    if ($ids.Count -eq 0) { return $result }
    $processById = @{}
    foreach ($process in @(Get-Process -Id $ids -ErrorAction SilentlyContinue)) { $processById[[int]$process.Id] = $process }
    if ($processById.Count -eq 0) { return $result }
    $filter = (@($processById.Keys | ForEach-Object { "ProcessId = $_" }) -join ' OR ')
    $cimById = @{}
    foreach ($cim in @(Get-CimInstance Win32_Process -Filter $filter -ErrorAction SilentlyContinue)) { $cimById[[int]$cim.ProcessId] = $cim }
    foreach ($id in @($processById.Keys)) {
        $process = $processById[$id]
        $cim = if ($cimById.ContainsKey($id)) { $cimById[$id] } else { $null }
        $start = $null
        try { $start = $process.StartTime.ToUniversalTime().ToString('o') } catch { }
        $result[$id] = [pscustomobject]@{
            Pid = $id
            StartTimeUtc = $start
            ExecutablePath = if ($cim) { $cim.ExecutablePath } else { $null }
            CommandLine = if ($cim) { $cim.CommandLine } else { $null }
        }
    }
    return $result
}

function Test-SgProcessIdentity([object]$Entry, [hashtable]$SnapshotByPid = $null) {
    $pidValue = [int]$Entry.pid
    $current = if ($null -ne $SnapshotByPid) { if ($SnapshotByPid.ContainsKey($pidValue)) { $SnapshotByPid[$pidValue] } else { $null } } else { Get-SgProcessSnapshot $pidValue }
    if (-not $current) { return $false }
    if ($Entry.startTimeUtc -and $current.StartTimeUtc -ne $Entry.startTimeUtc) { return $false }
    if ($Entry.executablePath -and $current.ExecutablePath -and [IO.Path]::GetFullPath($Entry.executablePath) -ne [IO.Path]::GetFullPath($current.ExecutablePath)) { return $false }
    if ($Entry.commandSignature -and $current.CommandLine -and $current.CommandLine -notlike "*$($Entry.commandSignature)*") { return $false }
    return $true
}

function Get-SgRunnableIdentity([object]$Entry) {
    if (-not $Entry) { return $null }
    $candidate = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } elseif ($Entry.PSObject.Properties['path'] -and $Entry.path) { [string]$Entry.path } else { $null }
    if ([string]::IsNullOrWhiteSpace($candidate)) { return $null }
    return [IO.Path]::GetFullPath($candidate).TrimEnd('\','/').ToLowerInvariant()
}

function Get-SgCanonicalSurfaceName([string]$RootPath, [string]$LaunchPath) {
    $root = [IO.Path]::GetFullPath($RootPath).TrimEnd('\','/')
    $launch = [IO.Path]::GetFullPath($LaunchPath).TrimEnd('\','/')
    $rootName = Split-Path $root -Leaf
    if ($launch.Equals($root, [StringComparison]::OrdinalIgnoreCase)) { return $rootName }
    $prefix = $root + [IO.Path]::DirectorySeparatorChar
    if (-not $launch.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Launch path is outside its project root: $launch" }
    return "$rootName-$($launch.Substring($prefix.Length) -replace '[\\/]', '-')"
}

function Get-SgDisplayName([object]$Entry, [string]$Workspace = '') {
    $fallback = if ($Entry.PSObject.Properties['name'] -and $Entry.name) { [string]$Entry.name } else { 'unknown' }
    if ($Workspace) {
        try {
            $workspacePath = [IO.Path]::GetFullPath($Workspace).TrimEnd('\','/')
            $launchPath = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [IO.Path]::GetFullPath([string]$Entry.launchPath).TrimEnd('\','/') } else { [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/') }
            if ($launchPath.Equals($workspacePath, [StringComparison]::OrdinalIgnoreCase)) { return '.' }
            $workspacePrefix = $workspacePath + [IO.Path]::DirectorySeparatorChar
            if ($launchPath.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase)) {
                return $launchPath.Substring($workspacePrefix.Length).Replace('\','/')
            }
            return $launchPath
        } catch { return $fallback }
    }
    if (-not ($Entry.PSObject.Properties['rootPath'] -and $Entry.rootPath)) { return $fallback }
    try {
        $root = [IO.Path]::GetFullPath([string]$Entry.rootPath).TrimEnd('\','/')
        $launch = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [IO.Path]::GetFullPath([string]$Entry.launchPath).TrimEnd('\','/') } else { [IO.Path]::GetFullPath([string]$Entry.path).TrimEnd('\','/') }
        return Get-SgCanonicalSurfaceName $root $launch
    } catch {
        return $fallback
    }
}

function Add-SgDiscoveredMetadata([object]$RegisteredEntry, [object]$Candidate) {
    if (-not $RegisteredEntry -or -not $Candidate) { return $RegisteredEntry }
    if ($Candidate.PSObject.Properties['rootPath'] -and $Candidate.rootPath) {
        $RegisteredEntry | Add-Member -NotePropertyName rootPath -NotePropertyValue ([string]$Candidate.rootPath) -Force
    }
    if ($Candidate.PSObject.Properties['launchPath'] -and $Candidate.launchPath) {
        $RegisteredEntry | Add-Member -NotePropertyName launchPath -NotePropertyValue ([string]$Candidate.launchPath) -Force
    }
    return $RegisteredEntry
}

function ConvertTo-SgGitHubRepositoryIdentity([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    $candidate = $Value.Trim()
    $repositoryPath = $null

    if ($candidate -match '^(?<owner>[A-Za-z0-9](?:[A-Za-z0-9-]{0,38}))/(?<repository>[A-Za-z0-9._-]+?)(?:[.]git)?$') {
        $repositoryPath = "$($Matches.owner)/$($Matches.repository)"
    } elseif ($candidate -match '^(?i)git@github[.]com:(?<path>[^?#]+)$') {
        $repositoryPath = [string]$Matches.path
    } else {
        $uri = $null
        if (-not [uri]::TryCreate($candidate, [UriKind]::Absolute, [ref]$uri)) { return $null }
        if (-not $uri.Host.Equals('github.com', [StringComparison]::OrdinalIgnoreCase)) { return $null }
        if ($uri.Scheme -notin @('https','ssh')) { return $null }
        if ($uri.Query -or $uri.Fragment) { return $null }
        $repositoryPath = $uri.AbsolutePath.Trim('/')
    }

    $repositoryPath = $repositoryPath -replace '[.]git$',''
    if ($repositoryPath -notmatch '^(?<owner>[A-Za-z0-9](?:[A-Za-z0-9-]{0,38}))/(?<repository>[A-Za-z0-9._-]+)$') { return $null }
    return "$($Matches.owner)/$($Matches.repository)".ToLowerInvariant()
}

function Get-SgInstalledGitHubRepositoryIdentities([object]$Config, [string]$GitPath = '') {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    if ([string]::IsNullOrWhiteSpace($GitPath)) {
        $gitCommand = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $gitCommand) { return @() }
        $GitPath = [string]$gitCommand.Source
    }
    if (-not (Test-Path -LiteralPath $GitPath -PathType Leaf)) { return @() }

    $candidatePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    try {
        foreach ($directory in @(Get-ChildItem -LiteralPath $workspace -Directory -Force -ErrorAction Stop)) {
            if ($directory.Name.StartsWith('.') -or ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint)) { continue }
            [void]$candidatePaths.Add([IO.Path]::GetFullPath($directory.FullName).TrimEnd('\','/'))
        }
    } catch [UnauthorizedAccessException] { }
    foreach ($entry in @(Get-SgProjectCatalog $Config)) {
        $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } elseif ($entry.PSObject.Properties['path']) { [string]$entry.path } else { '' }
        if ($rootPath) {
            try { [void]$candidatePaths.Add([IO.Path]::GetFullPath($rootPath).TrimEnd('\','/')) } catch { }
        }
    }

    $workspacePrefix = $workspace.TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    $repositoryRoots = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $identities = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        foreach ($candidatePath in $candidatePaths) {
            $repositoryRootOutput = @(& $GitPath -C $candidatePath rev-parse --show-toplevel 2>$null)
            $repositoryRootExitCode = $LASTEXITCODE
            $repositoryRoot = $repositoryRootOutput | Select-Object -First 1
            if ($repositoryRootExitCode -ne 0 -or [string]::IsNullOrWhiteSpace([string]$repositoryRoot)) { continue }
            try { $repositoryRoot = [IO.Path]::GetFullPath([string]$repositoryRoot).TrimEnd('\','/') } catch { continue }
            if (-not ($repositoryRoot.Equals($workspace, [StringComparison]::OrdinalIgnoreCase) -or $repositoryRoot.StartsWith($workspacePrefix, [StringComparison]::OrdinalIgnoreCase))) { continue }
            if (-not $repositoryRoots.Add($repositoryRoot)) { continue }
            $originOutput = @(& $GitPath -C $repositoryRoot remote get-url origin 2>$null)
            $originExitCode = $LASTEXITCODE
            $origin = $originOutput | Select-Object -First 1
            if ($originExitCode -ne 0) { continue }
            $identity = ConvertTo-SgGitHubRepositoryIdentity ([string]$origin)
            if ($identity) { [void]$identities.Add($identity) }
        }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    return @($identities | Sort-Object)
}

function Select-SgGitHubCloneCandidates([object[]]$Repositories, [string[]]$InstalledRepositoryIdentities = @()) {
    $installed = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($identity in @($InstalledRepositoryIdentities)) {
        $normalized = ConvertTo-SgGitHubRepositoryIdentity ([string]$identity)
        if ($normalized) { [void]$installed.Add($normalized) }
    }
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $available = New-Object 'System.Collections.Generic.List[object]'
    foreach ($repository in @($Repositories)) {
        if (-not $repository) { continue }
        $value = if ($repository.PSObject.Properties['nameWithOwner']) { [string]$repository.nameWithOwner } elseif ($repository.PSObject.Properties['url']) { [string]$repository.url } else { '' }
        $identity = ConvertTo-SgGitHubRepositoryIdentity $value
        if (-not $identity -or $installed.Contains($identity) -or -not $seen.Add($identity)) { continue }
        [void]$available.Add($repository)
    }
    return @($available.ToArray())
}

function Get-SgProjectIndexPath([object]$Config) {
    if ($Config.PSObject.Properties['ProjectIndexPath'] -and $Config.ProjectIndexPath) {
        return [IO.Path]::GetFullPath([string]$Config.ProjectIndexPath)
    }
    return Join-Path ([IO.Path]::GetFullPath([string]$Config.RuntimeDirectory)) 'project-index.json'
}

function Get-SgProjectCatalogCacheKey([object]$Config) {
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/').ToLowerInvariant()
    return "$workspace|$((Get-SgProjectIndexPath $Config).ToLowerInvariant())"
}

function ConvertFrom-SgRoundTripTimestamp([object]$Value) {
    if ($Value -is [DateTimeOffset]) { return ([DateTimeOffset]$Value).ToUniversalTime() }
    if ($Value -is [DateTime]) { return ([DateTimeOffset]([DateTime]$Value)).ToUniversalTime() }
    $parsed = [DateTimeOffset]::MinValue
    $text = [Convert]::ToString($Value, [Globalization.CultureInfo]::InvariantCulture)
    if (-not [DateTimeOffset]::TryParseExact($text, 'o', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind, [ref]$parsed)) {
        throw 'Timestamp is not an invariant round-trip value.'
    }
    return $parsed.ToUniversalTime()
}

function Test-SgProjectIndex([object]$Config, [object]$Index, [switch]$AllowStale) {
    if (-not $Index -or $Index.schemaVersion -ne $script:ProjectIndexSchemaVersion -or [string]$Index.scannerVersion -ne $script:ProjectScannerVersion -or $null -eq $Index.projects) { return $false }
    $workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
    $indexedWorkspace = try { [IO.Path]::GetFullPath([string]$Index.workspace).TrimEnd('\','/') } catch { return $false }
    if (-not $workspace.Equals($indexedWorkspace, [StringComparison]::OrdinalIgnoreCase)) { return $false }
    try { $generatedAt = ConvertFrom-SgRoundTripTimestamp $Index.generatedAt } catch { return $false }
    $age = ([DateTimeOffset]::UtcNow - $generatedAt).TotalMinutes
    return $age -ge 0 -and ($AllowStale -or $age -lt $script:ProjectIndexTtlMinutes)
}

function Get-SgProjectIndexStalePath([object]$Config) {
    return "$(Get-SgProjectIndexPath $Config).stale"
}

function Read-SgProjectIndex([object]$Config, [switch]$AllowStale) {
    $path = Get-SgProjectIndexPath $Config
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    try {
        $index = (Get-Content -LiteralPath $path -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (Test-SgProjectIndex $Config $index -AllowStale:$AllowStale) { return $index }
    } catch { }
    return $null
}

function Write-SgProjectIndex([object]$Config, [object[]]$Projects) {
    $path = Get-SgProjectIndexPath $Config
    $directory = Split-Path -Parent $path
    Ensure-SgDirectory $directory
    $lockPath = "$path.lock"
    $lock = $null
    $temp = "$path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try { $lock = [IO.File]::Open($lockPath, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 20
            }
        } while (-not $lock)
        $index = [pscustomobject]@{
            schemaVersion = $script:ProjectIndexSchemaVersion
            workspace = [IO.Path]::GetFullPath([string]$Config.Workspace).TrimEnd('\','/')
            scannerVersion = $script:ProjectScannerVersion
            generatedAt = [DateTimeOffset]::UtcNow.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            projects = @($Projects)
        }
        $index | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $temp -Encoding UTF8 -ErrorAction Stop
        $parsed = (Get-Content -LiteralPath $temp -Raw -ErrorAction Stop) | ConvertFrom-Json -ErrorAction Stop
        if (-not (Test-SgProjectIndex $Config $parsed)) { throw 'Project index validation failed.' }
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $backup = "$path.bak"
            try { [IO.File]::Replace($temp, $path, $backup) }
            finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else {
            Move-Item -LiteralPath $temp -Destination $path -Force
        }
        Remove-Item -LiteralPath (Get-SgProjectIndexStalePath $Config) -Force -ErrorAction SilentlyContinue
        return $index
    } finally {
        if ($lock) { $lock.Dispose() }
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

function Clear-SgProjectCatalogCache([object]$Config) {
    $key = Get-SgProjectCatalogCacheKey $Config
    [void]$script:ProjectCatalogMemory.Remove($key)
    $path = Get-SgProjectIndexPath $Config
    $directory = Split-Path -Parent $path
    Ensure-SgDirectory $directory
    $lock = $null
    try {
        $deadline = (Get-Date).AddSeconds(15)
        do {
            try { $lock = [IO.File]::Open("$path.lock", [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] {
                if ((Get-Date) -ge $deadline) { throw }
                Start-Sleep -Milliseconds 20
            }
        } while (-not $lock)
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            [IO.File]::WriteAllText((Get-SgProjectIndexStalePath $Config), 'stale', [Text.UTF8Encoding]::new($false))
        }
    } finally {
        if ($lock) { $lock.Dispose() }
    }
}

function Clear-SgProjectCatalogMemoryCache([object]$Config) {
    [void]$script:ProjectCatalogMemory.Remove((Get-SgProjectCatalogCacheKey $Config))
}

function Test-SgProjectCatalogRefreshRequired([object]$Config, [switch]$DiskOnly) {
    if (Test-Path -LiteralPath (Get-SgProjectIndexStalePath $Config) -PathType Leaf) { return $true }
    $key = Get-SgProjectCatalogCacheKey $Config
    if (-not $DiskOnly -and $script:ProjectCatalogMemory.ContainsKey($key)) {
        return -not (Test-SgProjectIndex $Config $script:ProjectCatalogMemory[$key])
    }
    return -not [bool](Read-SgProjectIndex $Config)
}

function Find-SgWorkspaceProjectCandidates([object]$Config) {
    $workspace = ConvertTo-SgCanonicalPath ([string]$Config.Workspace)
    $manifests = @{'package.json'=$true;'pyproject.toml'=$true;'requirements.txt'=$true;'pubspec.yaml'=$true}
    $pruneDirs = @{'.git'=$true;'node_modules'=$true;'venv'=$true;'.venv'=$true;'__pycache__'=$true;'target'=$true;'.next'=$true;'.nuxt'=$true;'dist'=$true;'.cache'=$true;'.pnpm'=$true;'.yarn'=$true}
    $paths = New-Object 'System.Collections.Generic.Queue[string]'
    $depths = New-Object 'System.Collections.Generic.Queue[int]'
    $roots = New-Object 'System.Collections.Generic.Queue[string]'
    $boundaryDepths = New-Object 'System.Collections.Generic.Queue[int]'
    $paths.Enqueue($workspace); $depths.Enqueue(0); $roots.Enqueue(''); $boundaryDepths.Enqueue(-1)
    $seen = @{}
    $projects = New-Object 'System.Collections.Generic.List[object]'
    while ($paths.Count -gt 0) {
        $path = $paths.Dequeue()
        $depth = $depths.Dequeue()
        $rootPath = $roots.Dequeue()
        $boundaryDepth = $boundaryDepths.Dequeue()
        if (-not [IO.Directory]::Exists($path)) { continue }
        $hasManifest = $false
        try {
            foreach ($filePath in [IO.Directory]::EnumerateFiles($path)) {
                if ($manifests.ContainsKey([IO.Path]::GetFileName($filePath))) { $hasManifest = $true; break }
            }
        } catch [UnauthorizedAccessException] {
            continue
        }
        $isRepositoryRoot = [IO.Directory]::Exists([IO.Path]::Combine($path, '.git'))
        if (-not $rootPath -and ($isRepositoryRoot -or $hasManifest)) { $rootPath = $path; $boundaryDepth = $depth }

        if ($hasManifest) {
            try {
                $kind = Get-SgProjectKind $path
                $identity = $path.ToLowerInvariant()
                if (-not $seen.ContainsKey($identity)) {
                    $seen[$identity] = $true
                    [void]$projects.Add([pscustomobject]@{
                        name = Get-SgCanonicalSurfaceName $(if ($rootPath) { $rootPath } else { $path }) $path
                        path = $path
                        rootPath = $(if ($rootPath) { $rootPath } else { $path })
                        launchPath = $path
                        kind = $kind
                        status = 'discovered'
                        port = 0
                        logPath = $null
                        errorLogPath = $null
                    })
                }
            } catch {
                if ($_.Exception.Message -notlike 'Unsupported or ambiguous project.*') { throw }
            }
        }

        $canDescend = if ($rootPath) { ($depth - $boundaryDepth) -lt 3 } else { $depth -lt 4 }
        if (-not $canDescend) { continue }
        try { $directories = [IO.Directory]::EnumerateDirectories($path) } catch [UnauthorizedAccessException] { continue }
        foreach ($directoryPath in $directories) {
            $directoryName = [IO.Path]::GetFileName($directoryPath)
            if ($directoryName.StartsWith('.') -or $pruneDirs.ContainsKey($directoryName)) { continue }
            try { $attributes = [IO.File]::GetAttributes($directoryPath) } catch { continue }
            if ($attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
            $paths.Enqueue($directoryPath); $depths.Enqueue($depth + 1); $roots.Enqueue($rootPath); $boundaryDepths.Enqueue($boundaryDepth)
        }
    }
    return @($projects.ToArray() | Sort-Object -Property path)
}

function Get-SgWorkspaceProjectCandidates([object]$Config, [switch]$ForceRefresh) {
    $key = Get-SgProjectCatalogCacheKey $Config
    if (-not $ForceRefresh -and $script:ProjectCatalogMemory.ContainsKey($key)) {
        $memoryIndex = $script:ProjectCatalogMemory[$key]
        if (Test-SgProjectIndex $Config $memoryIndex -AllowStale) { return @($memoryIndex.projects) }
        [void]$script:ProjectCatalogMemory.Remove($key)
    }
    if (-not $ForceRefresh) {
        $persisted = Read-SgProjectIndex $Config -AllowStale
        if ($persisted) { $script:ProjectCatalogMemory[$key] = $persisted; return @($persisted.projects) }
    }
    $projects = @(Find-SgWorkspaceProjectCandidates $Config)
    $index = Write-SgProjectIndex $Config $projects
    $script:ProjectCatalogMemory[$key] = $index
    return $projects
}

function Get-SgProjectCatalog([object]$Config, [switch]$ForceRefresh, [switch]$SkipProcessReconciliation) {
    $registry = if ($SkipProcessReconciliation) { Read-SgRegistry $Config } else { Reconcile-SgRegistry $Config }
    $registeredByIdentity = @{}
    $items = New-Object 'System.Collections.Generic.List[object]'
    foreach ($entry in @($registry.projects)) {
        $identity = Get-SgRunnableIdentity $entry
        if (-not $identity -or $registeredByIdentity.ContainsKey($identity)) { continue }
        $registeredByIdentity[$identity] = $entry
        $entry | Add-Member -NotePropertyName Id -NotePropertyValue $identity -Force
        $entry | Add-Member -NotePropertyName IsRegistered -NotePropertyValue $true -Force
        $entry | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $entry $Config.Workspace) -Force
        [void]$items.Add($entry)
    }
    foreach ($candidate in @(Get-SgWorkspaceProjectCandidates $Config -ForceRefresh:$ForceRefresh)) {
        $identity = Get-SgRunnableIdentity $candidate
        if (-not $identity) { continue }
        if ($registeredByIdentity.ContainsKey($identity)) {
            Add-SgDiscoveredMetadata $registeredByIdentity[$identity] $candidate | Out-Null
            $registeredByIdentity[$identity] | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $candidate $Config.Workspace) -Force
            continue
        }
        $candidate | Add-Member -NotePropertyName Id -NotePropertyValue $identity -Force
        $candidate | Add-Member -NotePropertyName IsRegistered -NotePropertyValue $false -Force
        $candidate | Add-Member -NotePropertyName Name -NotePropertyValue (Get-SgDisplayName $candidate $Config.Workspace) -Force
        [void]$items.Add($candidate)
    }
    return @($items.ToArray() | Sort-Object -Property Name,Id)
}

function New-SgProjectChoiceMap([object[]]$Items) {
    $map = @{}
    foreach ($item in @($Items)) {
        $label = [string]$item.Name
        $identity = Get-SgRunnableIdentity $item
        if (-not $label -or -not $identity) { throw 'Every project choice requires a display name and runnable identity.' }
        if ($map.ContainsKey($label)) { throw "Duplicate project choice label: $label" }
        $map[$label] = $identity
    }
    return $map
}

function Test-SgProjectCatalogEntry([object]$Entry) {
    if (-not $Entry) { return $false }
    $path = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path }
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { return $false }
    try { return (Get-SgProjectKind $path) -eq [string]$Entry.kind } catch { return $false }
}

function Resolve-SgProjectCatalogEntry([object]$Config, [string]$Identity, [switch]$RequireRegistered) {
    if ([string]::IsNullOrWhiteSpace($Identity)) { throw 'Project identity is required.' }
    $entry = @(Get-SgProjectCatalog $Config | Where-Object { $_.Id -eq $Identity }) | Select-Object -First 1
    if ($entry -and (Test-SgProjectCatalogEntry $entry)) {
        if ($RequireRegistered -and -not $entry.IsRegistered) { throw "Project is not registered: $($entry.path)" }
        return $entry
    }
    Clear-SgProjectCatalogCache $Config
    $entry = @(Get-SgProjectCatalog $Config -ForceRefresh | Where-Object { $_.Id -eq $Identity }) | Select-Object -First 1
    if (-not $entry -or -not (Test-SgProjectCatalogEntry $entry)) { throw "Project surface is no longer available: $Identity" }
    if ($RequireRegistered -and -not $entry.IsRegistered) { throw "Project is not registered: $($entry.path)" }
    return $entry
}

function Sync-SgDiscoveredProjectMetadata([object]$Config, [object]$Candidate) {
    $identity = Get-SgRunnableIdentity $Candidate
    if (-not $identity -or -not ($Candidate.PSObject.Properties['rootPath'] -and $Candidate.rootPath)) { return $null }
    $rootPath = [IO.Path]::GetFullPath([string]$Candidate.rootPath).TrimEnd('\','/')
    $launchPath = [IO.Path]::GetFullPath([string]$Candidate.launchPath).TrimEnd('\','/')
    $name = Get-SgCanonicalSurfaceName $rootPath $launchPath
    $result = Invoke-SgRegistryMutation $Config {
        param($data)
        $entry = $data.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $identity } | Select-Object -First 1
        if ($entry) {
            $entry | Add-Member -NotePropertyName rootPath -NotePropertyValue $rootPath -Force
            $entry | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
            $entry | Add-Member -NotePropertyName name -NotePropertyValue $name -Force
        }
    }
    return $result.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $identity } | Select-Object -First 1
}

function Get-SgCommandSignature([string]$ProjectPath, [string]$Kind, [int]$Port) {
    return "ShipGlows:${Kind}:${Port}:$([IO.Path]::GetFullPath($ProjectPath))"
}

function Get-SgDependencyInputs([string]$ProjectPath, [string]$Kind) {
    $names = if ($Kind -in @('astro','vite','browser-extension')) {
        @('package.json','pnpm-lock.yaml','package-lock.json','npm-shrinkwrap.json')
    } elseif ($Kind -eq 'python') {
        @('pyproject.toml','uv.lock','requirements.txt')
    } else {
        @('pubspec.yaml','pubspec.lock')
    }
    return @($names | ForEach-Object { Join-Path $ProjectPath $_ } | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
}

function New-SgDependencyPlan([string]$ProjectPath, [string]$Kind) {
    if ($Kind -in @('astro','vite','browser-extension')) {
        $pnpmLock=Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf
        $npmLock=(Test-Path -LiteralPath (Join-Path $ProjectPath 'package-lock.json') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $ProjectPath 'npm-shrinkwrap.json') -PathType Leaf)
        $packageManager=Get-SgNodePackageManager $ProjectPath
        [string[]]$arguments=if($pnpmLock){@($packageManager.PrefixArguments)+@('install','--frozen-lockfile')}elseif($npmLock){@('ci')}else{@('install')}
        $managerLabel=if($packageManager.Pinned){'corepack-pnpm'}else{$packageManager.Name}
        return [pscustomobject]@{Manager=$packageManager.Manager;Arguments=$arguments;BootstrapArguments=@();ArtifactStrategy="node-$Kind-$managerLabel";SuppressNpmLock=(-not$pnpmLock-and-not$npmLock)}
    }
    if($Kind-eq'python'){
        $manager=Get-SgCommandPath @('uv.exe','uv.cmd','uv');if(-not$manager){throw 'uv is required for Python projects. Install uv, then retry.'}
        $venv=Join-Path $ProjectPath '.venv';$python=Join-Path $venv 'Scripts\python.exe'
        if(Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock') -PathType Leaf){$arguments=@('sync','--locked');$bootstrap=@();$artifact='python-uv-lock'}
        elseif(Test-Path -LiteralPath (Join-Path $ProjectPath 'requirements.txt') -PathType Leaf){$arguments=@('pip','install','--python',$python,'-r',(Join-Path $ProjectPath 'requirements.txt'));$bootstrap=@('venv',$venv);$artifact='python-requirements-venv'}
        else{throw 'Python project requires uv.lock or requirements.txt in V1.'}
        return [pscustomobject]@{Manager=[IO.Path]::GetFullPath($manager);Arguments=[string[]]$arguments;BootstrapArguments=[string[]]$bootstrap;ArtifactStrategy=$artifact;SuppressNpmLock=$false}
    }
    $manager=Get-SgFlutterCommandPath;if(-not$manager){throw 'Flutter SDK is not available on PATH.'}
    return [pscustomobject]@{Manager=[IO.Path]::GetFullPath($manager);Arguments=[string[]]@('pub','get');BootstrapArguments=@();ArtifactStrategy='flutter-package-config';SuppressNpmLock=$false}
}

function Get-SgDependencyDigest([string]$ProjectPath, [string]$Kind, [object]$Plan) {
    $inputs = @(Get-SgDependencyInputs $ProjectPath $Kind)
    if ($inputs.Count -eq 0) { throw "No dependency manifest found for $Kind." }
    $builder = New-Object Text.StringBuilder
    [void]$builder.AppendLine('schemaVersion=2')
    [void]$builder.AppendLine("kind=$Kind")
    [void]$builder.AppendLine("manager=$([string]$Plan.Manager)")
    [void]$builder.AppendLine("arguments=$(@($Plan.Arguments)|ConvertTo-Json -Compress)")
    [void]$builder.AppendLine("bootstrapArguments=$(@($Plan.BootstrapArguments)|ConvertTo-Json -Compress)")
    [void]$builder.AppendLine("artifactStrategy=$([string]$Plan.ArtifactStrategy)")
    foreach ($path in @($inputs | Sort-Object)) {
        $relative = $path.Substring($ProjectPath.TrimEnd('\','/').Length).TrimStart('\','/').ToLowerInvariant()
        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256 -ErrorAction Stop).Hash.ToLowerInvariant()
        [void]$builder.AppendLine("$relative=$hash")
    }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($builder.ToString())))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Test-SgDependencyArtifacts([string]$ProjectPath, [string]$Kind) {
    if ($Kind -in @('astro','vite','browser-extension')) {
        $nodeModules = Join-Path $ProjectPath 'node_modules'
        if (-not (Test-Path -LiteralPath $nodeModules -PathType Container)) { return $false }
        $managerArtifact=if(Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml') -PathType Leaf){Test-Path -LiteralPath (Join-Path $nodeModules '.modules.yaml') -PathType Leaf}else{Test-Path -LiteralPath (Join-Path $nodeModules '.package-lock.json') -PathType Leaf}
        if($Kind-eq'browser-extension'){
            $frameworkArtifact=Test-Path -LiteralPath (Join-Path (Join-Path $nodeModules '@crxjs\vite-plugin') 'package.json') -PathType Leaf
        }else{$frameworkArtifact=Test-Path -LiteralPath (Join-Path (Join-Path $nodeModules $Kind) 'package.json') -PathType Leaf}
        return $managerArtifact -and $frameworkArtifact
    }
    if ($Kind -eq 'python') { return Test-Path -LiteralPath (Join-Path $ProjectPath '.venv\Scripts\python.exe') -PathType Leaf }
    return Test-Path -LiteralPath (Join-Path $ProjectPath '.dart_tool\package_config.json') -PathType Leaf
}

function Get-SgDependencyStatePath([object]$Config, [string]$ProjectPath) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $identity = ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(([IO.Path]::GetFullPath($ProjectPath).ToLowerInvariant()))))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
    return Join-Path (Join-Path ([IO.Path]::GetFullPath([string]$Config.RuntimeDirectory)) 'dependency-state') "$identity.json"
}

function Test-SgDependencyState([string]$StatePath, [string]$Digest, [string]$ProjectPath, [string]$Kind) {
    if (-not (Test-SgDependencyArtifacts $ProjectPath $Kind) -or -not (Test-Path -LiteralPath $StatePath -PathType Leaf)) { return $false }
    try {
        $state = Get-Content -LiteralPath $StatePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        return [int]$state.schemaVersion -eq 2 -and [string]$state.digest -ceq $Digest -and [string]$state.kind -ceq $Kind -and [string]$state.projectPath -ceq ([IO.Path]::GetFullPath($ProjectPath))
    } catch { return $false }
}

function Write-SgDependencyState([string]$StatePath, [string]$Digest, [string]$ProjectPath, [string]$Kind) {
    $temp = "$StatePath.$([guid]::NewGuid().ToString('N')).tmp"
    $state = [ordered]@{ schemaVersion=2; projectPath=[IO.Path]::GetFullPath($ProjectPath); kind=$Kind; digest=$Digest; completedAt=[DateTimeOffset]::UtcNow.ToString('o',[Globalization.CultureInfo]::InvariantCulture) }
    try {
        [IO.File]::WriteAllText($temp, ($state | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $StatePath -PathType Leaf) {
            $backup = "$StatePath.bak"
            try { [IO.File]::Replace($temp, $StatePath, $backup) } finally { Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue }
        } else { Move-Item -LiteralPath $temp -Destination $StatePath -Force }
    } finally { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
}

function Write-SgDependencyLogRecord([IO.TextWriter]$Writer, [object]$Record) {
    $Writer.WriteLine([string]$Record)
    Write-Output $Record
}

function Invoke-SgDependencySetup([object]$Config, [string]$ProjectPath, [string]$Kind, [string]$LogPath) {
    $statePath = Get-SgDependencyStatePath $Config $ProjectPath
    Ensure-SgDirectory (Split-Path -Parent $statePath)
    $lock = $null
    $logWriter = $null
    $suppressNpmLock = $false
    try {
        $deadline = (Get-Date).AddSeconds(30)
        do {
            try { $lock = [IO.File]::Open("$statePath.lock", [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None) }
            catch [IO.IOException] { if ((Get-Date) -ge $deadline) { throw 'Dependency setup lock timed out.' }; Start-Sleep -Milliseconds 50 }
        } while (-not $lock)
        $plan = New-SgDependencyPlan $ProjectPath $Kind
        $digest = Get-SgDependencyDigest $ProjectPath $Kind $plan
        if (Test-SgDependencyState $statePath $digest $ProjectPath $Kind) { Write-SgInfo "Dependencies unchanged: $ProjectPath"; return $false }
        # From this point onward the previous success record no longer
        # describes a safely reusable installation. Keep failures fail-closed.
        Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue
        Ensure-SgDirectory (Split-Path -Parent $LogPath)
        # setup.log describes the current dependency attempt. Start it with one
        # deterministic encoding instead of appending PS 5.1 UTF-16 to history.
        $logWriter = New-Object IO.StreamWriter($LogPath, $false, (New-Object Text.UTF8Encoding($false)))
        $logWriter.AutoFlush = $true
        $pm=[string]$plan.Manager
        [string[]]$setupArguments=@($plan.Arguments)
        $suppressNpmLock=[bool]$plan.SuppressNpmLock
        if(@($plan.BootstrapArguments).Count-gt0-and-not(Test-Path -LiteralPath (Join-Path $ProjectPath '.venv\Scripts\python.exe') -PathType Leaf)){
            $previousErrorActionPreference=$ErrorActionPreference
            try{$ErrorActionPreference='Continue';& $pm @($plan.BootstrapArguments) 2>&1|ForEach-Object{Write-SgDependencyLogRecord $logWriter $_};if($LASTEXITCODE-ne0){throw 'uv venv failed.'}}
            finally{$ErrorActionPreference=$previousErrorActionPreference}
        }
        Push-Location $ProjectPath
        $previousErrorActionPreference = $ErrorActionPreference
        $previousNpmPackageLock = $env:npm_config_package_lock
        try {
            # Package managers may report normal progress on stderr; use their
            # exit code so this is stable with $ErrorActionPreference = 'Stop'.
            $ErrorActionPreference = 'Continue'
            if ($suppressNpmLock) { $env:npm_config_package_lock = 'false' }
            & $pm @setupArguments 2>&1 | ForEach-Object { Write-SgDependencyLogRecord $logWriter $_ }
            if ($LASTEXITCODE -ne 0) { throw "Dependency setup failed for $Kind." }
        }
        finally { $env:npm_config_package_lock = $previousNpmPackageLock; $ErrorActionPreference = $previousErrorActionPreference; Pop-Location }
        if (-not (Test-SgDependencyArtifacts $ProjectPath $Kind)) { throw "Dependency setup completed without the expected $Kind artifacts." }
        $completedPlan = New-SgDependencyPlan $ProjectPath $Kind
        $completedDigest = Get-SgDependencyDigest $ProjectPath $Kind $completedPlan
        if ($completedDigest -cne $digest) { throw 'Dependency inputs changed during setup; durable state was not recorded. Retry with stable manifests and lockfiles.' }
        Write-SgDependencyState $statePath $completedDigest $ProjectPath $Kind
        return $true
    } finally { if ($logWriter) { $logWriter.Dispose() }; if ($lock) { $lock.Dispose() } }
}

function Rotate-SgLogFile([string]$Path, [long]$MaxBytes = 5242880) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    $file = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($file.Length -le $MaxBytes) { return }
    $rotated = "$Path.previous"
    Move-Item -LiteralPath $Path -Destination $rotated -Force
}

function Get-SgLaunchSpec([string]$ProjectPath, [string]$Kind, [int]$Port, [bool]$FlutterVisible = $false, [string]$FlutterProfilePath = '', [string]$FlutterDevice = 'chrome', [string]$DartDefineFile = '', [string]$FlutterLaunchDirectory = '', [string]$FlutterLaunchIdentity = '') {
    $signature = Get-SgCommandSignature $ProjectPath $Kind $Port
    if ($Kind -eq 'astro') {
        $pnpm = Test-Path -LiteralPath (Join-Path $ProjectPath 'pnpm-lock.yaml')
        if ($pnpm) {
            $packageManager = Get-SgCommandPath @('pnpm.cmd','pnpm.exe')
            if (-not $packageManager) { throw 'pnpm is required by pnpm-lock.yaml but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" exec astro dev --host 127.0.0.1 --port $Port & rem $signature"
            $args = @('/d','/s','/c',"`"$command`"")
        } else {
            $packageManager = Get-SgCommandPath @('npm.cmd','npm.exe')
            if (-not $packageManager) { throw 'npm is required but is unavailable.' }
            $file = $env:ComSpec
            $command = "call `"$packageManager`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
            $args = @('/d','/s','/c',"`"$command`"")
        }
    } elseif ($Kind -in @('vite','browser-extension')) {
        $packageManager = Get-SgNodePackageManager $ProjectPath
        $file = $env:ComSpec
        $prefix = if (@($packageManager.PrefixArguments).Count -gt 0) { ' ' + (@($packageManager.PrefixArguments) -join ' ') } else { '' }
        if ($Kind -eq 'browser-extension') {
            $optionSeparator = if ($packageManager.Name -eq 'pnpm') { '' } else { ' --' }
            $command = "call `"$($packageManager.Manager)`"$prefix run dev:chrome$optionSeparator --host 127.0.0.1 --port $Port & rem $signature"
        } elseif ($packageManager.Name -eq 'pnpm') {
            $command = "call `"$($packageManager.Manager)`"$prefix exec vite --host 127.0.0.1 --port $Port & rem $signature"
        } else {
            $command = "call `"$($packageManager.Manager)`" run dev -- --host 127.0.0.1 --port $Port & rem $signature"
        }
        $args = @('/d','/s','/c',"`"$command`"")
    } elseif ($Kind -eq 'python') {
        $target = if (Test-Path -LiteralPath (Join-Path $ProjectPath 'app\main.py')) { 'app.main:app' } elseif (Test-Path -LiteralPath (Join-Path $ProjectPath 'main.py')) { 'main:app' } else { throw 'FastAPI entrypoint not found. V1 supports app/main.py or main.py with app.' }
        $file = $env:ComSpec
        if (Test-Path -LiteralPath (Join-Path $ProjectPath 'uv.lock') -PathType Leaf) {
            $uv = Get-SgCommandPath @('uv.exe','uv.cmd','uv'); if (-not $uv) { throw 'uv is required for Python launch.' }
            $command = "call `"$uv`" run --locked uvicorn $target --host 127.0.0.1 --port $Port & rem $signature"
        } else {
            $python = Join-Path $ProjectPath '.venv\Scripts\python.exe'
            if (-not (Test-Path -LiteralPath $python -PathType Leaf)) { throw 'Python virtual environment not found. Dependency setup must create .venv before launch.' }
            $command = "call `"$python`" -m uvicorn $target --host 127.0.0.1 --port $Port & rem $signature"
        }
        $args = @('/d','/s','/c',"`"$command`"")
    } else {
        $flutter = Get-SgFlutterCommandPath; if (-not $flutter) { throw 'Flutter SDK is unavailable on PATH and at the ShipGlows-managed location.' }
        $supervisor = Join-Path $PSScriptRoot 'ShipGlows.FlutterSupervisor.ps1'
        if (-not (Test-Path -LiteralPath $supervisor -PathType Leaf)) { throw 'ShipGlows Flutter supervisor is missing.' }
        if ([string]::IsNullOrWhiteSpace($FlutterLaunchDirectory) -or [string]::IsNullOrWhiteSpace($FlutterLaunchIdentity)) { throw 'Managed Flutter launch identity is required.' }
        $file = Resolve-SgPowerShellExecutable
        $args = @('-NoLogo','-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',"`"$supervisor`"",'-LaunchDirectory',"`"$FlutterLaunchDirectory`"",'-ProjectPath',"`"$ProjectPath`"",'-FlutterPath',"`"$flutter`"",'-Port',[string]$Port,'-Device',$FlutterDevice,'-LaunchIdentity',$FlutterLaunchIdentity)
        if ($FlutterDevice -eq 'chrome') { $args += @('-ProfilePath',"`"$FlutterProfilePath`""); if ($FlutterVisible) { $args += '-Visible' } }
        if ($DartDefineFile) { $args += @('-DartDefineFile',"`"$DartDefineFile`"") }
        $signature = $FlutterLaunchIdentity
    }
    if (-not $file) { throw "Launch tool missing for $Kind." }
    [pscustomobject]@{ FilePath = $file; Arguments = $args; Signature = $signature; Interactive = $false; FlutterSdkRoot=$(if($Kind-eq'flutter-web'){Split-Path (Split-Path $flutter -Parent) -Parent}else{$null}) }
}

function ConvertTo-SgPowerShellLiteral([string]$Value) {
    return "'$(if($null-eq$Value){''}else{$Value.Replace("'","''")})'"
}

function Resolve-SgPowerShellExecutable([string[]]$KnownCandidates=@()) {
    $candidates=New-Object 'System.Collections.Generic.List[string]'
    if(@($KnownCandidates).Count-gt0){foreach($candidate in @($KnownCandidates)){if($candidate){[void]$candidates.Add([string]$candidate)}}}
    elseif($env:SHIPGLOWS_MANAGED_PWSH){[void]$candidates.Add($env:SHIPGLOWS_MANAGED_PWSH)}
    foreach($candidate in $candidates){
        if([string]::IsNullOrWhiteSpace($candidate)-or-not[IO.Path]::IsPathRooted($candidate)){continue}
        try{$resolved=[IO.Path]::GetFullPath($candidate)}catch{continue}
        if([IO.Path]::GetFileName($resolved)-ne'pwsh.exe'){continue}
        if(-not $env:SHIPGLOWS_MANAGED_PWSH -or $resolved-ne[IO.Path]::GetFullPath($env:SHIPGLOWS_MANAGED_PWSH)){continue}
        if(Test-Path -LiteralPath $resolved -PathType Leaf){return $resolved}
    }
    throw 'The ShipGlows-managed PowerShell runtime could not be resolved for detached process launch.'
}

function Get-SgJobNativeSource {
    return @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class ShipGlowsJobNative {
    [StructLayout(LayoutKind.Sequential)] public struct BasicAccounting { public long TotalUserTime; public long TotalKernelTime; public long ThisPeriodTotalUserTime; public long ThisPeriodTotalKernelTime; public uint TotalPageFaultCount; public uint TotalProcesses; public uint ActiveProcesses; public uint TotalTerminatedProcesses; }
    [StructLayout(LayoutKind.Sequential)] public struct BasicLimits { public long PerProcessUserTimeLimit; public long PerJobUserTimeLimit; public uint LimitFlags; public UIntPtr MinimumWorkingSetSize; public UIntPtr MaximumWorkingSetSize; public uint ActiveProcessLimit; public UIntPtr Affinity; public uint PriorityClass; public uint SchedulingClass; }
    [StructLayout(LayoutKind.Sequential)] public struct IoCounters { public ulong ReadOperationCount; public ulong WriteOperationCount; public ulong OtherOperationCount; public ulong ReadTransferCount; public ulong WriteTransferCount; public ulong OtherTransferCount; }
    [StructLayout(LayoutKind.Sequential)] public struct ExtendedLimits { public BasicLimits BasicLimitInformation; public IoCounters IoInfo; public UIntPtr ProcessMemoryLimit; public UIntPtr JobMemoryLimit; public UIntPtr PeakProcessMemoryUsed; public UIntPtr PeakJobMemoryUsed; }
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr attributes, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job, int infoClass, ref ExtendedLimits info, uint length);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool QueryInformationJobObject(IntPtr job, int infoClass, ref BasicAccounting info, uint length, IntPtr returnLength);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr OpenJobObject(uint access, bool inherit, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool TerminateJobObject(IntPtr job, uint exitCode);
    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr handle);
    public static IntPtr CreateKillOnClose(string name) {
        IntPtr job=CreateJobObject(IntPtr.Zero,name); if(job==IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(),"CreateJobObject failed");
        ExtendedLimits info=new ExtendedLimits(); info.BasicLimitInformation.LimitFlags=0x00002000;
        if(!SetInformationJobObject(job,9,ref info,(uint)Marshal.SizeOf(typeof(ExtendedLimits)))) { int error=Marshal.GetLastWin32Error(); CloseHandle(job); throw new Win32Exception(error,"SetInformationJobObject failed"); }
        return job;
    }
    public static void AssignCurrent(IntPtr job) { if(!AssignProcessToJobObject(job,GetCurrentProcess())) throw new Win32Exception(Marshal.GetLastWin32Error(),"AssignProcessToJobObject failed"); }
    public static uint ActiveProcessCount(IntPtr job) { BasicAccounting info=new BasicAccounting(); if(!QueryInformationJobObject(job,1,ref info,(uint)Marshal.SizeOf(typeof(BasicAccounting)),IntPtr.Zero)) throw new Win32Exception(Marshal.GetLastWin32Error(),"QueryInformationJobObject failed"); return info.ActiveProcesses; }
    public static bool Terminate(string name) { IntPtr job=OpenJobObject(0x0008,false,name); if(job==IntPtr.Zero) return false; try { if(!TerminateJobObject(job,1)) throw new Win32Exception(Marshal.GetLastWin32Error(),"TerminateJobObject failed"); return true; } finally { CloseHandle(job); } }
}
'@
}

function Initialize-SgJobNativeApi {
    if (-not ('ShipGlowsJobNative' -as [type])) { Add-Type -TypeDefinition (Get-SgJobNativeSource) -Language CSharp -ErrorAction Stop }
}

function Stop-SgManagedJob([object]$Entry) {
    if (-not $Entry.PSObject.Properties['jobName'] -or [string]::IsNullOrWhiteSpace([string]$Entry.jobName)) { return $false }
    if ([string]$Entry.jobName -notmatch '^Local\\ShipGlows-[a-f0-9]{32}$') { throw 'Managed job identity is invalid.' }
    Initialize-SgJobNativeApi
    return [ShipGlowsJobNative]::Terminate([string]$Entry.jobName)
}

function Start-SgDetachedProcess([string]$FilePath,[string[]]$ArgumentList,[string]$WorkingDirectory,[string]$RedirectStandardOutput,[string]$RedirectStandardError,[hashtable]$EnvironmentVariables,[string]$SecretTokenPath='') {
    $argumentLiterals=@($ArgumentList|ForEach-Object{ConvertTo-SgPowerShellLiteral ([string]$_)})-join','
    $lines=New-Object 'System.Collections.Generic.List[string]'
    [void]$lines.Add("`$ErrorActionPreference='Stop'")
    $jobName = "Local\ShipGlows-$([guid]::NewGuid().ToString('N'))"
    [void]$lines.Add("if(-not('ShipGlowsJobNative' -as [type])){Add-Type -TypeDefinition $(ConvertTo-SgPowerShellLiteral (Get-SgJobNativeSource)) -Language CSharp -ErrorAction Stop}")
    [void]$lines.Add("`$job=[ShipGlowsJobNative]::CreateKillOnClose($(ConvertTo-SgPowerShellLiteral $jobName))")
    [void]$lines.Add('try {')
    [void]$lines.Add('[ShipGlowsJobNative]::AssignCurrent($job)')
    [void]$lines.Add("Set-Location -LiteralPath $(ConvertTo-SgPowerShellLiteral $WorkingDirectory)")
    foreach($name in @($EnvironmentVariables.Keys|Sort-Object)){
        if($name-eq'SHIPGLOWS_SUPERVISOR_TOKEN'){
            if([string]::IsNullOrWhiteSpace($SecretTokenPath)){throw 'Detached Flutter launch requires its protected token path.'}
            [void]$lines.Add("[Environment]::SetEnvironmentVariable('SHIPGLOWS_SUPERVISOR_TOKEN',[IO.File]::ReadAllText($(ConvertTo-SgPowerShellLiteral $SecretTokenPath)),'Process')")
        }else{
            [void]$lines.Add("[Environment]::SetEnvironmentVariable($(ConvertTo-SgPowerShellLiteral $name),$(ConvertTo-SgPowerShellLiteral ([string]$EnvironmentVariables[$name])),'Process')")
        }
    }
    [void]$lines.Add("[string[]]`$launchArguments=@($argumentLiterals)")
    [void]$lines.Add("`$managedProcess=Start-Process -FilePath $(ConvertTo-SgPowerShellLiteral $FilePath) -ArgumentList `$launchArguments -WorkingDirectory $(ConvertTo-SgPowerShellLiteral $WorkingDirectory) -RedirectStandardOutput $(ConvertTo-SgPowerShellLiteral $RedirectStandardOutput) -RedirectStandardError $(ConvertTo-SgPowerShellLiteral $RedirectStandardError) -PassThru -Wait -WindowStyle Hidden")
    [void]$lines.Add("`$managedExitCode=`$managedProcess.ExitCode;`$managedProcess.Dispose();while([ShipGlowsJobNative]::ActiveProcessCount(`$job)-gt1){Start-Sleep -Milliseconds 200};exit `$managedExitCode")
    [void]$lines.Add("} catch { [IO.File]::AppendAllText($(ConvertTo-SgPowerShellLiteral $RedirectStandardError),(`$_.Exception.Message+[Environment]::NewLine)); exit 1 } finally { if(`$job-ne[IntPtr]::Zero){[void][ShipGlowsJobNative]::CloseHandle(`$job)} }")
    $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(($lines-join[Environment]::NewLine)))
    $powershell=Resolve-SgPowerShellExecutable
    $commandLine="`"$powershell`" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encoded"
    $startup=New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ShowWindow=[uint16]0}
    $creation=Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine=$commandLine;CurrentDirectory=$WorkingDirectory;ProcessStartupInformation=$startup}
    if(-not$creation-or[int]$creation.ReturnValue-ne0-or[int]$creation.ProcessId-le0){$code=if($creation){[int]$creation.ReturnValue}else{-1};throw "Detached process creation failed with Win32 code $code."}
    $identityLength=[Math]::Min(96,$encoded.Length)
    return [pscustomobject]@{Id=[int]$creation.ProcessId;CommandSignature=$encoded.Substring($encoded.Length-$identityLength);JobName=$jobName}
}

function Test-SgHttpReady([int]$Port) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$Port" -TimeoutSec 2 -ErrorAction Stop | Out-Null
        return $true
    } catch {
        $tcp = New-Object Net.Sockets.TcpClient
        try {
            $tcp.Connect('127.0.0.1', $Port)
            return $tcp.Connected
        } catch {
            return $false
        } finally {
            $tcp.Dispose()
        }
    }
}

function Wait-SgHttpReady([int]$Port, [int]$TimeoutSeconds = 60) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-SgHttpReady $Port) { return $true }
        Start-Sleep -Milliseconds 500
    }
    return $false
}

function Protect-SgOwnerOnlyPath([string]$Path) {
    $item=Get-Item -LiteralPath $Path -Force -ErrorAction Stop;if($item.Attributes -band [IO.FileAttributes]::ReparsePoint){throw "Managed runtime path must not be a reparse point: $Path"}
    $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User;$acl=Get-Acl -LiteralPath $Path;$acl.SetAccessRuleProtection($true,$false);foreach($rule in @($acl.Access)){$acl.RemoveAccessRuleAll($rule)}
    $inheritance=if($item.PSIsContainer){[Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'}else{[Security.AccessControl.InheritanceFlags]::None};$access=New-Object Security.AccessControl.FileSystemAccessRule($sid,[Security.AccessControl.FileSystemRights]::FullControl,$inheritance,[Security.AccessControl.PropagationFlags]::None,[Security.AccessControl.AccessControlType]::Allow);$acl.AddAccessRule($access);Set-Acl -LiteralPath $Path -AclObject $acl
}
function Test-SgOwnerOnlyPath([string]$Path) { try{$acl=Get-Acl -LiteralPath $Path;$sid=[Security.Principal.WindowsIdentity]::GetCurrent().User.Value;$allowed=@($acl.Access|Where-Object{$_.AccessControlType -eq 'Allow'});return [bool]($acl.AreAccessRulesProtected -and $allowed.Count -eq 1 -and $allowed[0].IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid)}catch{return $false} }
function Assert-SgNoReparseTree([string]$Path) { $root=Get-Item -LiteralPath $Path -Force -ErrorAction Stop;if($root.Attributes-band[IO.FileAttributes]::ReparsePoint){throw 'Managed Flutter IPC path is a reparse point.'};foreach($item in @(Get-ChildItem -LiteralPath $Path -Force -Recurse -ErrorAction Stop)){if($item.Attributes-band[IO.FileAttributes]::ReparsePoint){throw 'Managed Flutter IPC tree contains a reparse point.'}} }

function Get-SgFlutterMachineState([string]$LogPath) {
    $appIds = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::Ordinal)
    $started = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::Ordinal)
    $stopped = @{}
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) {
        foreach ($line in @(Get-Content -LiteralPath $LogPath -ErrorAction SilentlyContinue)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try { $messages = @(([string]$line | ConvertFrom-Json -ErrorAction Stop)) } catch { continue }
            foreach ($message in $messages) {
                if (-not $message -or -not $message.event -or -not $message.params) { continue }
                $appId = [string]$message.params.appId
                if ([string]::IsNullOrWhiteSpace($appId)) { continue }
                switch ([string]$message.event) {
                    'app.start' { [void]$appIds.Add($appId) }
                    'app.started' { [void]$started.Add($appId) }
                    'app.stop' { $stopped[$appId] = if ($message.params.error) { [string]$message.params.error } else { 'Flutter stopped before startup completed.' } }
                }
            }
        }
    }
    foreach ($appId in $appIds) {
        if ($stopped.ContainsKey($appId)) { return [pscustomobject]@{ Ready=$false; AppId=$appId; Error=[string]$stopped[$appId] } }
        if ($started.Contains($appId)) { return [pscustomobject]@{ Ready=$true; AppId=$appId; Error=$null } }
    }
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error=$null }
}

function Wait-SgFlutterReady([string]$LogPath, [int]$TimeoutSeconds = 90) {
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    do {
        $state = Get-SgFlutterMachineState $LogPath
        if ($state.Ready -or $state.Error) { return $state }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error='Flutter application startup timed out before app.started.' }
}

function Protect-SgDiagnosticText([string]$Text) {
    if ($null -eq $Text) { return '' }
    $result = [string]$Text
    $quotedOrAtom = '(?:"[^"\r\n]*"|''[^''\r\n]*''|[^\s,;]+)'
    $result = [regex]::Replace($result, '(?i)\b(authorization)(\s*(?::|=)?\s*)(bearer|basic)(\s+)'+$quotedOrAtom, '$1$2$3$4[REDACTED]')
    $result = [regex]::Replace($result, '(?i)\b(bearer)(\s+)'+$quotedOrAtom, '$1$2[REDACTED]')
    $key = '(?i)\b(token|secret|password|api[-_]?key|dart-define)\b'
    $result = [regex]::Replace($result, $key+'(\s*(?::|=)\s*)'+$quotedOrAtom, '$1$2[REDACTED]')
    $result = [regex]::Replace($result, $key+'(\s+)(?:"[^"\r\n]*"|''[^''\r\n]*'')', '$1$2[REDACTED]')
    $result = [regex]::Replace($result, $key+'(\s+)(?!(?:is|was|missing|invalid|validation|required|failed|not|unset|empty)\b)[^\s,;]+', '$1$2[REDACTED]')
    return $result
}

function Get-SgStartupFailure([string]$ErrorLogPath, [string]$Fallback = 'Process exited during startup.') {
    if ([string]::IsNullOrWhiteSpace($ErrorLogPath) -or -not (Test-Path -LiteralPath $ErrorLogPath -PathType Leaf)) { return $Fallback }
    try {
        $tail = (Get-SgBoundedFileTail $ErrorLogPath 8192).Trim()
        $tail = Protect-SgDiagnosticText $tail
        if ($tail.Length -gt 1200) { $tail = $tail.Substring($tail.Length - 1200) }
        if ($tail) { return "Process exited during startup: $tail" }
    } catch { }
    return $Fallback
}

function Wait-SgProjectReady([string]$Kind, [int]$Port, [string]$LogPath, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [string]$ErrorLogPath = '') {
    if ($Kind -eq 'flutter-web') { return Wait-SgFlutterReady $LogPath $TimeoutSeconds }
    $deadline = (Get-Date).AddSeconds([Math]::Min([Math]::Max(0, $TimeoutSeconds), 60))
    do {
        if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
            return [pscustomobject]@{ Ready=$false; AppId=$null; Error=(Get-SgStartupFailure $ErrorLogPath) }
        }
        if ((Test-SgHttpReady $Port) -and (-not $ProcessEntry -or (Test-SgProcessIdentity $ProcessEntry))) { return [pscustomobject]@{ Ready=$true; AppId=$null; Error=$null } }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; Error='Application readiness timed out.' }
}

function Get-SgBrowserExtensionManifestPaths([string]$ProjectPath) {
    return @((Join-Path $ProjectPath 'dist\chrome\manifest.json'))
}

function Test-SgBrowserExtensionManifest([string]$Path, [DateTime]$FreshSinceUtc) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    try {
        $item = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $item.Length -gt 1048576 -or $item.LastWriteTimeUtc -lt $FreshSinceUtc) { return $false }
        $manifest = [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop
        return [int]$manifest.manifest_version -eq 3 -and -not [string]::IsNullOrWhiteSpace([string]$manifest.name) -and -not [string]::IsNullOrWhiteSpace([string]$manifest.version)
    } catch { return $false }
}

function Wait-SgBrowserExtensionReady([string]$ProjectPath, [int]$Port, [int]$TimeoutSeconds = 90, [object]$ProcessEntry = $null, [string]$ErrorLogPath = '') {
    $freshSince = [DateTime]::UtcNow.AddSeconds(-2)
    if ($ProcessEntry -and $ProcessEntry.PSObject.Properties['startTimeUtc'] -and $ProcessEntry.startTimeUtc) {
        try { $freshSince = ([DateTimeOffset]::Parse([string]$ProcessEntry.startTimeUtc, [Globalization.CultureInfo]::InvariantCulture)).UtcDateTime.AddSeconds(-2) } catch { }
    }
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    do {
        if ($ProcessEntry -and -not (Test-SgProcessIdentity $ProcessEntry)) {
            return [pscustomobject]@{ Ready=$false; AppId=$null; ManifestPath=$null; Error=(Get-SgStartupFailure $ErrorLogPath) }
        }
        if (-not (Test-SgPortAvailable $Port)) {
            foreach ($manifestPath in @(Get-SgBrowserExtensionManifestPaths $ProjectPath)) {
                if (Test-SgBrowserExtensionManifest $manifestPath $freshSince) {
                    return [pscustomobject]@{ Ready=$true; AppId=$null; ManifestPath=$manifestPath; Error=$null }
                }
            }
        }
        if ((Get-Date) -ge $deadline) { break }
        Start-Sleep -Milliseconds 250
    } while ($true)
    return [pscustomobject]@{ Ready=$false; AppId=$null; ManifestPath=$null; Error='Browser extension readiness timed out before a fresh Manifest V3 package and HMR listener were available.' }
}

function Wait-SgFlutterSupervisorReady([string]$StatePath, [int]$TimeoutSeconds = 90) {
    $deadline=(Get-Date).AddSeconds([Math]::Max(0,$TimeoutSeconds))
    do {
        if(Test-Path -LiteralPath $StatePath -PathType Leaf){try{$state=Get-Content -LiteralPath $StatePath -Raw|ConvertFrom-Json -ErrorAction Stop;if($state.status -eq 'running' -and $state.appId){return [pscustomobject]@{Ready=$true;AppId=[string]$state.appId;Error=$null;DaemonPid=[int]$state.daemonPid}};if($state.status -eq 'error'){return [pscustomobject]@{Ready=$false;AppId=$null;Error=$(if($state.lastError){Protect-SgDiagnosticText ([string]$state.lastError)}else{'Flutter supervisor failed.'});DaemonPid=[int]$state.daemonPid}}}catch{}}
        if((Get-Date)-ge $deadline){break};Start-Sleep -Milliseconds 250
    }while($true)
    [pscustomobject]@{Ready=$false;AppId=$null;Error='Flutter supervisor timed out before app.started.';DaemonPid=0}
}

function Invoke-SgFlutterSupervisorCommand([object]$Entry,[ValidateSet('reload','stop','open')][string]$Method,[int]$TimeoutSeconds=10) {
    if(-not $Entry.PSObject.Properties['flutterLaunchDirectory'] -or -not $Entry.PSObject.Properties['flutterTokenPath']){throw 'Flutter supervisor identity is unavailable.'}
    $launch=[IO.Path]::GetFullPath([string]$Entry.flutterLaunchDirectory);$tokenPath=[IO.Path]::GetFullPath([string]$Entry.flutterTokenPath)
    if(-not $tokenPath.StartsWith($launch.TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or -not(Test-Path -LiteralPath $tokenPath -PathType Leaf)){throw 'Flutter supervisor token identity is invalid.'};Assert-SgNoReparseTree $launch;if(-not(Test-SgOwnerOnlyPath $launch)-or-not(Test-SgOwnerOnlyPath $tokenPath)){throw 'Flutter supervisor IPC ACL is not owner-only.'}
    $token=[IO.File]::ReadAllText($tokenPath).Trim();if($token -notmatch '^[a-f0-9]{64}$'){throw 'Flutter supervisor token is invalid.'}
    $id=[guid]::NewGuid().ToString('N');$commandDir=Join-Path $launch 'commands';$response=Join-Path (Join-Path $launch 'responses') "$id.json";Ensure-SgDirectory $commandDir
    $target=Join-Path $commandDir "$id.json";$temp="$target.tmp";$json=[ordered]@{token=$token;id=$id;method=$Method}|ConvertTo-Json -Compress;[IO.File]::WriteAllText($temp,$json,(New-Object Text.UTF8Encoding($false)));Move-Item -LiteralPath $temp -Destination $target -Force
    try{$deadline=(Get-Date).AddSeconds($TimeoutSeconds);while((Get-Date)-lt $deadline){if(Test-Path -LiteralPath $response -PathType Leaf){$info=Get-Item -LiteralPath $response;if($info.Length-gt65536){throw 'Flutter supervisor response exceeds 64 KiB.'};try{$result=Get-Content -LiteralPath $response -Raw|ConvertFrom-Json -ErrorAction Stop}finally{Remove-Item -LiteralPath $response -Force -ErrorAction SilentlyContinue};$names=@($result.PSObject.Properties.Name);if($result -is[array]-or-not($result.PSObject.Properties['ok'])-or$result.ok-isnot[bool]){throw 'Malformed Flutter supervisor response.'};if($result.ok){if(($names|Sort-Object)-join',' -ne 'method,ok'-or[string]$result.method-cne$Method){throw 'Mismatched Flutter supervisor response.'};return $result}else{if(($names|Sort-Object)-join',' -ne 'error,ok'){throw 'Malformed Flutter supervisor response.'};throw 'Flutter supervisor command failed.'}};Start-Sleep -Milliseconds 100};throw "Flutter supervisor $Method command timed out."}finally{if(Test-Path -LiteralPath $target -PathType Leaf){Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue};if(Test-Path -LiteralPath $temp -PathType Leaf){Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue}}
}

function Get-SgBoundedFileTail([string]$Path,[int]$MaxBytes=262144) {
    $stream=[IO.File]::Open($Path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite);try{$count=[int][Math]::Min([int64][Math]::Max(0,$MaxBytes),$stream.Length);[void]$stream.Seek(-$count,[IO.SeekOrigin]::End);$buffer=New-Object byte[] $count;$read=0;while($read-lt$count){$n=$stream.Read($buffer,$read,$count-$read);if($n-le0){break};$read+=$n};[Text.Encoding]::UTF8.GetString($buffer,0,$read)}finally{$stream.Dispose()}
}

function Copy-SgFlutterDiagnostics([object]$Entry,[string]$DurableOut,[string]$DurableErr) {
    if(-not$Entry-or-not$Entry.PSObject.Properties['flutterLaunchDirectory']){return}
    $launch=[string]$Entry.flutterLaunchDirectory;if(-not(Test-Path -LiteralPath $launch -PathType Container)){return};Assert-SgNoReparseTree $launch
    foreach($pair in @(@('flutter.stdout.log',$DurableOut),@('flutter.stderr.log',$DurableErr))){$source=Join-Path $launch $pair[0];if(Test-Path -LiteralPath $source -PathType Leaf){$text=Protect-SgDiagnosticText (Get-SgBoundedFileTail $source 262144);Add-Content -LiteralPath $pair[1] -Value $text}}
    $statePath=Join-Path $launch 'state.json';if(Test-Path -LiteralPath $statePath -PathType Leaf){try{if((Get-Item -LiteralPath $statePath).Length-gt262144){throw 'Oversized Flutter supervisor state.'};$state=(Get-SgBoundedFileTail $statePath 262144)|ConvertFrom-Json -ErrorAction Stop;$lastError=Protect-SgDiagnosticText ([string]$state.lastError);$summary=[ordered]@{status=[string]$state.status;lastError=$lastError;appId=[string]$state.appId;daemonPid=[int]$state.daemonPid}|ConvertTo-Json -Compress;Add-Content -LiteralPath $DurableOut -Value $summary}catch{Add-Content -LiteralPath $DurableErr -Value 'Flutter supervisor state could not be preserved.'}}
}

function Wait-SgFlutterOwnedExtinction([object]$Entry,[int]$TimeoutSeconds=8) {
    $deadline=(Get-Date).AddSeconds([Math]::Max(0,$TimeoutSeconds))
    do{if(-not(Test-SgProcessIdentity $Entry)-and@(Get-SgOwnedFlutterBrowserPids $Entry).Count-eq0-and@(Get-SgOwnedFlutterListenerPids $Entry).Count-eq0){return $true};if((Get-Date)-ge$deadline){return $false};Start-Sleep -Milliseconds 100}while($true)
}

function Remove-SgFlutterLaunchArtifacts([object]$Config,[object]$Entry) {
    if(-not$Entry-or-not$Entry.PSObject.Properties['flutterLaunchDirectory']-or-not$Entry.flutterLaunchDirectory){return $true};$launch=[IO.Path]::GetFullPath([string]$Entry.flutterLaunchDirectory);$base=[IO.Path]::GetFullPath((Join-Path $Config.RuntimeDirectory 'flutter-launch')).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
    if(-not$launch.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)-or(Split-Path $launch -Leaf)-notmatch'^[a-f0-9]{32}$'){throw 'Refusing Flutter launch cleanup outside the managed runtime identity.'};if(-not(Test-Path -LiteralPath $launch)){return $true};Assert-SgNoReparseTree $launch
    if(Test-SgProcessIdentity $Entry -or @(Get-SgOwnedFlutterBrowserPids $Entry).Count -gt 0 -or @(Get-SgOwnedFlutterListenerPids $Entry).Count -gt 0){throw 'Refusing Flutter launch cleanup while owned processes remain.'};Remove-Item -LiteralPath $launch -Recurse -Force;return -not(Test-Path -LiteralPath $launch)
}

function Reconcile-SgRegistry([object]$Config) {
    return Invoke-SgRegistryMutation $Config {
        param($registry)
        $processSnapshots = Get-SgProcessSnapshotMap @($registry.projects | ForEach-Object { [int]$_.pid })
        $byIdentity = @{}
        $normalized = New-Object 'System.Collections.Generic.List[object]'
        foreach ($entry in @($registry.projects)) {
            $identity = Get-SgRunnableIdentity $entry
            if (-not $identity) { continue }

            $launchPath = [IO.Path]::GetFullPath($(if ($entry.PSObject.Properties['launchPath'] -and $entry.launchPath) { [string]$entry.launchPath } else { [string]$entry.path })).TrimEnd('\','/')
            $oldPath = [IO.Path]::GetFullPath([string]$entry.path).TrimEnd('\','/')
            $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) {
                [IO.Path]::GetFullPath([string]$entry.rootPath).TrimEnd('\','/')
            } elseif (-not $oldPath.Equals($launchPath, [StringComparison]::OrdinalIgnoreCase)) {
                $oldPath
            } else {
                $oldPath
            }
            $entry | Add-Member -NotePropertyName rootPath -NotePropertyValue $rootPath -Force
            $entry | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
            $entry.path = $launchPath

            $live = Test-SgProcessIdentity $entry $processSnapshots
            $freshReservation = $false
            if (-not $live -and $entry.status -in @('reserved','starting') -and $entry.PSObject.Properties['reservationTimeUtc'] -and $entry.reservationTimeUtc) {
                try {
                    $freshReservation = (((Get-Date).ToUniversalTime() - [datetime]::Parse([string]$entry.reservationTimeUtc).ToUniversalTime()).TotalMinutes -lt 5)
                } catch {
                    $freshReservation = $false
                }
            }
            if ($live) {
                $entry.status = 'running'
                if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
            } elseif (-not $freshReservation) {
                $entry.status = 'stopped'
                if ($entry.PSObject.Properties['reservationToken']) { $entry.reservationToken = $null }
                if ($entry.PSObject.Properties['reservationTimeUtc']) { $entry.reservationTimeUtc = $null }
            }

            if (-not $byIdentity.ContainsKey($identity)) {
                $byIdentity[$identity] = [pscustomobject]@{ Entry = $entry; Live = $live }
                [void]$normalized.Add($entry)
                continue
            }

            $kept = $byIdentity[$identity]
            $mergeSource = $entry
            if ($live -and -not $kept.Live) {
                $mergeSource = $kept.Entry
                [void]$normalized.Remove($kept.Entry)
                [void]$normalized.Add($entry)
                $byIdentity[$identity] = [pscustomobject]@{ Entry = $entry; Live = $true }
                $kept = $byIdentity[$identity]
            }
            $winner = $kept.Entry
            foreach ($property in @('name','kind','port','pid','startTimeUtc','executablePath','commandSignature','jobName','logPath','errorLogPath','lastError','reservationToken','reservationTimeUtc')) {
                $winnerValue = if ($winner.PSObject.Properties[$property]) { $winner.$property } else { $null }
                $candidateValue = if ($mergeSource.PSObject.Properties[$property]) { $mergeSource.$property } else { $null }
                $winnerMissing = $null -eq $winnerValue -or $winnerValue -eq '' -or (($property -in @('port','pid')) -and [int]$winnerValue -eq 0)
                if ($winnerMissing -and $null -ne $candidateValue -and $candidateValue -ne '') {
                    $winner | Add-Member -NotePropertyName $property -NotePropertyValue $candidateValue -Force
                }
            }
        }
        $registry.projects = $normalized.ToArray()
    }
}

function Get-SgProjectEnvironmentPath([string]$ProjectPath) {
    return Join-Path (ConvertTo-SgCanonicalPath $ProjectPath) 'ENVIRONMENT.md'
}

function Get-SgProjectEnvironmentBlock([string]$Content) {
    $text = if ($null -eq $Content) { '' } else { [string]$Content }
    $beginCount = [regex]::Matches($text, [regex]::Escape($script:ProjectEnvironmentBegin)).Count
    $endCount = [regex]::Matches($text, [regex]::Escape($script:ProjectEnvironmentEnd)).Count
    if ($beginCount -eq 0 -and $endCount -eq 0) { return [pscustomobject]@{ Exists=$false; Schema=$null; Match=$null } }
    if ($beginCount -ne 1 -or $endCount -ne 1) { throw 'ShipGlows project environment markers are incomplete or duplicated; the file was preserved.' }
    $pattern = '(?ms)^' + [regex]::Escape($script:ProjectEnvironmentBegin) + '\r?\n.*?^' + [regex]::Escape($script:ProjectEnvironmentEnd) + '\r?\n?'
    $blocks = [regex]::Matches($text, $pattern)
    if ($blocks.Count -ne 1) { throw 'ShipGlows project environment markers are incomplete or duplicated; the file was preserved.' }
    $schemaPattern = '(?m)^- Environment schema: `([^`]+)`\r?$'
    $schemas = [regex]::Matches($blocks[0].Value, $schemaPattern)
    if ($schemas.Count -gt 1) { throw 'ShipGlows project environment schema is duplicated; the file was preserved.' }
    $schema = if ($schemas.Count -eq 0) { 'legacy/v0' } else { [string]$schemas[0].Groups[1].Value }
    if ($schema -notin @('legacy/v0','shipglows-project-environment/v1',$script:ProjectEnvironmentSchema)) { throw "Unsupported ShipGlows project environment schema '$schema'; the file was preserved." }
    return [pscustomobject]@{ Exists=$true; Schema=$schema; Match=$blocks[0] }
}

function Remove-SgLegacyProjectServerState([string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    $legacyPath = Join-Path (Join-Path $root '.shipglows') 'server.env'
    $legacyFileIsUserOwned = $false
    if (Test-Path -LiteralPath $legacyPath -PathType Leaf) {
        $legacyContent = [IO.File]::ReadAllText($legacyPath)
        if ($legacyContent -match '(?m)^# ShipGlows CLI managed\. Do not edit\.\r?$' -and
            $legacyContent -match '(?m)^SHIPGLOWS_SERVER_MANAGER=shipglows-devserver\r?$') {
            Remove-Item -LiteralPath $legacyPath -Force
            $legacyDirectory = Split-Path -Parent $legacyPath
            if ((Test-Path -LiteralPath $legacyDirectory -PathType Container) -and
                @(Get-ChildItem -LiteralPath $legacyDirectory -Force).Count -eq 0) {
                Remove-Item -LiteralPath $legacyDirectory -Force
            }
        } else {
            $legacyFileIsUserOwned = $true
        }
    }

    if ($legacyFileIsUserOwned) { return }

    $git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $git) { return }
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $gitPath = (& $git.Source -C $root rev-parse --git-path info/exclude 2>$null | Select-Object -First 1)
        $repositoryRoot = (& $git.Source -C $root rev-parse --show-toplevel 2>$null | Select-Object -First 1)
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ([string]::IsNullOrWhiteSpace($gitPath) -or [string]::IsNullOrWhiteSpace($repositoryRoot)) { return }
    $excludePath = [string]$gitPath
    if (-not [IO.Path]::IsPathRooted($excludePath)) { $excludePath = Join-Path $root $excludePath }
    if (-not (Test-Path -LiteralPath $excludePath -PathType Leaf)) { return }
    $canonicalRoot = [IO.Path]::GetFullPath($root).TrimEnd('\','/')
    $canonicalRepository = [IO.Path]::GetFullPath([string]$repositoryRoot).TrimEnd('\','/')
    $prefix = if ($canonicalRoot.Length -gt $canonicalRepository.Length) { $canonicalRoot.Substring($canonicalRepository.Length).Trim('\','/').Replace('\','/') + '/' } else { '' }
    $legacyEntry = '/' + $prefix + '.shipglows/server.env'
    $lines = @(Get-Content -LiteralPath $excludePath)
    $next = New-Object System.Collections.Generic.List[string]
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -eq $legacyEntry) {
            if ($next.Count -gt 0 -and $next[$next.Count - 1] -eq '# ShipGlows local runtime') { $next.RemoveAt($next.Count - 1) }
            continue
        }
        $next.Add([string]$lines[$index])
    }
    if (($next -join "`n") -cne ($lines -join "`n")) {
        [IO.File]::WriteAllLines($excludePath, @($next), [Text.UTF8Encoding]::new($false))
    }
}

function Write-SgProjectEnvironment([string]$ProjectPath, [int]$Port = 0, [string]$Kind = '', [switch]$ReplaceDurablePort) {
    if ($Port -ne 0 -and ($Port -lt 1024 -or $Port -gt 65535)) { throw 'ShipGlows project port must be 0 or between 1024 and 65535.' }
    $path = Get-SgProjectEnvironmentPath $ProjectPath
    $existing = if (Test-Path -LiteralPath $path -PathType Leaf) { [IO.File]::ReadAllText($path) } else { '' }
    $managed = Get-SgProjectEnvironmentBlock $existing
    $effectivePort = $Port
    if (-not $ReplaceDurablePort -and $effectivePort -eq 0 -and $managed.Exists -and $managed.Match.Value -match '(?m)^- Assigned port: `(\d+)`\r?$') {
        $durablePort = [int]$Matches[1]
        if ($durablePort -lt 1024 -or $durablePort -gt 65535) { throw "Invalid assigned port in $path." }
        $effectivePort = $durablePort
    }
    $portValue = if ($effectivePort -gt 0) { [string]$effectivePort } else { 'pending first ShipGlows start' }
    if ([string]::IsNullOrWhiteSpace($Kind)) { try { $Kind = Get-SgProjectKind $ProjectPath } catch { $Kind = 'unknown' } }
    $urlValue = if ($Kind -eq 'browser-extension') { 'not applicable (browser extension)' } elseif ($effectivePort -gt 0) { "http://127.0.0.1:$effectivePort" } else { 'pending first ShipGlows start' }
    $extensionGuidance = if ($Kind -eq 'browser-extension') {
(@"
- Browser target: ``Chrome``
- Unpacked Chrome directory: ``dist/chrome``
- Extension workflow: ``s start -ProjectPath .`` -> ``s open -ProjectPath .`` -> Chrome Developer mode -> Load unpacked -> ``dist\chrome`` -> ``s stop -ProjectPath .``
- Chrome profile boundary: ShipGlows opens the extension manager and generated directory but never installs the extension automatically in a personal profile.
"@).TrimEnd() + "`n"
    } else { '' }
    $block = @'
<!-- >>> ShipGlows development environment >>> -->
## ShipGlows development environment

- Environment schema: `{2}`
- Server manager: `shipglows-devserver`
- Project kind: `{3}`
- Assigned port: `{0}`
- Canonical local URL: `{1}`
{4}- Live status authority: Windows ShipGlows DevServer registry

Use the assigned URL for ordinary web projects. Browser extensions use their generated unpacked directory and browser extension manager instead of a normal page URL. Do not substitute framework defaults such as Astro/Vite `4321` or a port from another project. Read the ShipGlows registry for `running` or `stopped`; this durable document is not rewritten on start or stop.
<!-- <<< ShipGlows development environment <<< -->
'@ -f $portValue,$urlValue,$script:ProjectEnvironmentSchema,$Kind,$extensionGuidance
    $remainderText = if ($managed.Exists) { $existing.Remove($managed.Match.Index, $managed.Match.Length) } else { $existing }
    $remainder = $remainderText.Trim([char[]]"`r`n")
    $next = if ($remainder) { "$remainder`n`n$($block.Trim())`n" } else { "$($block.Trim())`n" }
    if ($next.Replace("`r`n","`n") -cne $existing.Replace("`r`n","`n")) {
        [IO.File]::WriteAllText($path, $next, [Text.UTF8Encoding]::new($false))
    }
    Remove-SgLegacyProjectServerState $ProjectPath
    return $path
}

function Get-SgProjectEnvironment([string]$ProjectPath) {
    $path = Get-SgProjectEnvironmentPath $ProjectPath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    $content = [IO.File]::ReadAllText($path)
    $managed = Get-SgProjectEnvironmentBlock $content
    if (-not $managed.Exists -or $managed.Match.Value -notmatch '(?m)^- Server manager: `shipglows-devserver`\r?$') { return $null }
    $port = 0
    if ($managed.Match.Value -match '(?m)^- Assigned port: `(\d+)`\r?$') { $port = [int]$Matches[1] }
    if ($port -ne 0 -and ($port -lt 1024 -or $port -gt 65535)) { throw "Invalid assigned port in $path." }
    $kind = if ($managed.Match.Value -match '(?m)^- Project kind: `([^`]+)`\r?$') { [string]$Matches[1] } else { '' }
    $url = if ($kind -ne 'browser-extension' -and $port -gt 0) { "http://127.0.0.1:$port" } else { '' }
    [pscustomobject]@{ Path=$path; Port=$port; Url=$url; Kind=$kind; Manager='shipglows-devserver'; Schema=$managed.Schema }
}

function Register-SgProject([object]$Config, [string]$ProjectPath) {
    $root = ConvertTo-SgCanonicalPath $ProjectPath
    if (-not (Test-SgProjectPath $root $Config.Workspace)) { throw "Project must be inside the ShipGlows workspace: $($Config.Workspace)" }
    [void](Reconcile-SgRegistry $Config)
    $descriptors = @(Get-SgProjectDescriptors $root)
    $registry = Invoke-SgRegistryMutation $Config {
        param($data)
        foreach ($descriptor in $descriptors) {
            $launchPath = [IO.Path]::GetFullPath([string]$descriptor.LaunchPath).TrimEnd('\','/')
            $durableEnvironment = Get-SgProjectEnvironment $launchPath
            $durablePort = if ($durableEnvironment -and $durableEnvironment.Port -gt 0) { [int]$durableEnvironment.Port } else { 0 }
            $existing = @($data.projects | Where-Object { (Get-SgRunnableIdentity $_) -eq $launchPath.ToLowerInvariant() })
            $portInUse = $durablePort -gt 0 -and @($data.projects | Where-Object { (Get-SgRunnableIdentity $_) -ne $launchPath.ToLowerInvariant() -and [int]$_.port -eq $durablePort }).Count -gt 0
            $initialPort = if ($portInUse) { 0 } else { $durablePort }
            $name = Get-SgCanonicalSurfaceName $root $launchPath
            if ($existing.Count -eq 0) {
                $data.projects += [pscustomobject]@{
                    name = $name; path = $launchPath; rootPath = $root; launchPath = $launchPath; kind = $descriptor.Kind
                    port = $initialPort; status = 'stopped'; pid = 0; startTimeUtc = $null; executablePath = $null
                    commandSignature = $null; logPath = $null; errorLogPath = $null; lastError = $null
                    reservationToken = $null; reservationTimeUtc = $null
                }
            } else {
                $existing[0] | Add-Member -NotePropertyName rootPath -NotePropertyValue $root -Force
                $existing[0] | Add-Member -NotePropertyName launchPath -NotePropertyValue $launchPath -Force
                $existing[0] | Add-Member -NotePropertyName name -NotePropertyValue $name -Force
                $existing[0].path = $launchPath
                $existing[0].kind = $descriptor.Kind
                if ([int]$existing[0].port -le 0 -and $initialPort -gt 0) { $existing[0].port = $initialPort }
            }
        }
    }
    Clear-SgProjectCatalogCache $Config
    $launchPaths = @($descriptors | ForEach-Object { [IO.Path]::GetFullPath([string]$_.LaunchPath).TrimEnd('\','/') })
    $registered = @($registry.projects | Where-Object { $_.path -in $launchPaths })
    foreach ($entry in $registered) {
        $durable = Get-SgProjectEnvironment $entry.path
        $durableCollision = [int]$entry.port -le 0 -and $durable -and $durable.Port -gt 0 -and @($registry.projects | Where-Object { $_.path -ne $entry.path -and [int]$_.port -eq [int]$durable.Port }).Count -gt 0
        [void](Write-SgProjectEnvironment $entry.path ([int]$entry.port) ([string]$entry.kind) -ReplaceDurablePort:$durableCollision)
    }
    return $registered
}

function Sync-SgRegisteredProjectEnvironments([object]$Config) {
    $roots = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $paths = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in @((Read-SgRegistry $Config).projects)) {
        $candidate = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } else { [string]$entry.path }
        if ([string]::IsNullOrWhiteSpace($candidate) -or -not (Test-Path -LiteralPath $candidate -PathType Container)) { continue }
        $root = [IO.Path]::GetFullPath($candidate).TrimEnd('\','/')
        if (-not $roots.Add($root)) { continue }
        foreach ($registered in @(Register-SgProject $Config $root)) { [void]$paths.Add([IO.Path]::GetFullPath([string]$registered.path)) }
    }
    return @($paths)
}

function Start-SgProject([object]$Config, [string]$ProjectPath, [int]$RequestedPort = 0, [switch]$FlutterVisible) {
    $requestedPath = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Reconcile-SgRegistry $Config).projects | Where-Object { $_.path -eq $requestedPath }) | Select-Object -First 1
    if (-not $entry) {
        $registered = @(Register-SgProject $Config $requestedPath)
        $entry = $registered | Where-Object { $_.path -eq $requestedPath } | Select-Object -First 1
        if (-not $entry -and $registered.Count -gt 1) {
            throw "This monorepo has $($registered.Count) runnable surfaces. Choose a surface from the menu instead of starting its root path."
        }
        if (-not $entry) { $entry = $registered | Select-Object -First 1 }
    }
    if (-not $entry) { throw "No runnable surface could be registered for: $requestedPath" }
    if (-not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $($entry.path)" }
    if (Test-SgProcessIdentity $entry) { Write-SgInfo "Already running: $($entry.name) on $($entry.port)"; return $entry }
    $settings = Get-SgRuntimeSettings $entry.path
    $configuredPort = $RequestedPort
    if ($configuredPort -le 0 -and $env:SHIPGLOWS_ENV_PORT) {
        if ($env:SHIPGLOWS_ENV_PORT -notmatch '^\d+$' -or [int]$env:SHIPGLOWS_ENV_PORT -lt 1024 -or [int]$env:SHIPGLOWS_ENV_PORT -gt 65535) { throw 'SHIPGLOWS_ENV_PORT must be a port between 1024 and 65535.' }
        $configuredPort = [int]$env:SHIPGLOWS_ENV_PORT
    }
    if ($configuredPort -le 0 -and $settings.Port -gt 0) { $configuredPort = [int]$settings.Port }
    if ($configuredPort -le 0) {
        $projectEnvironment = Get-SgProjectEnvironment $entry.path
        if ($projectEnvironment -and $projectEnvironment.Port -gt 0) { $configuredPort = [int]$projectEnvironment.Port }
    }
    $explicitPort = $configuredPort -gt 0
    $previousPort = [int]$entry.port
    $reservation = Reserve-SgProjectPort $Config $entry.path $configuredPort $explicitPort
    $port = $reservation.Port
    $reservationToken = $reservation.Token
    if ($explicitPort) { Write-SgInfo "Using configured port: $port" }
    elseif ($previousPort -gt 0 -and $previousPort -eq $port) { Write-SgInfo "Reusing persistent port: $port" }
    else { Write-SgInfo "Assigned port: $port" }
    $logDir = Join-Path $Config.LogDirectory $entry.name
    Ensure-SgDirectory $logDir
    $out = Join-Path $logDir 'stdout.log'; $err = Join-Path $logDir 'stderr.log'
    $setupLog = Join-Path $logDir 'setup.log'
    foreach ($logPath in @($out,$err,$setupLog)) { Rotate-SgLogFile $logPath }
    $launchPath = if ($entry.PSObject.Properties['launchPath'] -and $entry.launchPath) { [string]$entry.launchPath } else { [string]$entry.path }
    $kind = [string]$entry.kind
    $flutterProfilePath = $null
    $flutterLaunchDirectory = $null
    $flutterTokenPath = $null
    $flutterLaunchIdentity = $null
    if ($kind -eq 'flutter-web' -and $settings.FlutterDevice -eq 'chrome') {
        $flutterLaunchDirectory = Join-Path $Config.RuntimeDirectory ("flutter-launch\{0}" -f $reservationToken)
        $flutterProfilePath = Join-Path $flutterLaunchDirectory 'chrome-profile'
        Ensure-SgDirectory $flutterProfilePath
    } elseif ($kind -eq 'flutter-web') {
        $flutterLaunchDirectory = Join-Path $Config.RuntimeDirectory ("flutter-launch\{0}" -f $reservationToken)
        Ensure-SgDirectory $flutterLaunchDirectory
    }
    if ($kind -eq 'flutter-web') {
        Protect-SgOwnerOnlyPath $flutterLaunchDirectory
        $bytes=New-Object byte[] 32;[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes);$flutterToken=([BitConverter]::ToString($bytes)).Replace('-','').ToLowerInvariant()
        $flutterTokenPath=Join-Path $flutterLaunchDirectory 'token';[IO.File]::WriteAllText($flutterTokenPath,$flutterToken,(New-Object Text.UTF8Encoding($false)));Protect-SgOwnerOnlyPath $flutterTokenPath
        $flutterLaunchIdentity="ShipGlowsFlutter-$reservationToken"
    }
    try {
        Invoke-SgDependencySetup $Config $launchPath $kind $setupLog | Out-Null
        $launch = Get-SgLaunchSpec $launchPath $kind $port ([bool]$FlutterVisible) $flutterProfilePath $settings.FlutterDevice $settings.DartDefineFile $flutterLaunchDirectory $flutterLaunchIdentity
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    }
    $launchEnvironment = @{}
    $launchEnvironment['PORT'] = [string]$port
    if ($kind -eq 'flutter-web') { $launchEnvironment['SHIPGLOWS_SUPERVISOR_TOKEN'] = $flutterToken }
    if ($kind -eq 'astro') { $launchEnvironment['ASTRO_DEV_BACKGROUND'] = '0' }
    try {
        Set-SgReservationState $Config $entry.path $reservationToken 'starting'
        $process = Start-SgDetachedProcess $launch.FilePath $launch.Arguments $launchPath $out $err $launchEnvironment $flutterTokenPath
        Start-Sleep -Milliseconds 350
        $snapshot = Get-SgProcessSnapshot $process.Id
        if (-not $snapshot) { throw "Process exited before it could be recorded. See $err" }
    } catch {
        Release-SgProjectPort $Config $entry.path $reservationToken $_.Exception.Message
        throw
    }
    $rootPath = if ($entry.PSObject.Properties['rootPath'] -and $entry.rootPath) { [string]$entry.rootPath } else { [string]$entry.path }
    $entryData = [pscustomobject]@{ name = $entry.name; path = $entry.path; rootPath = $rootPath; launchPath = $launchPath; kind = $kind; port = $port; status = 'starting'; pid = $snapshot.Pid; startTimeUtc = $snapshot.StartTimeUtc; executablePath = $snapshot.ExecutablePath; commandSignature = $process.CommandSignature; jobName = $(if ($process.PSObject.Properties['JobName']) { $process.JobName } else { $null }); logPath = $out; errorLogPath = $err; lastError = $null; flutterAppId = $null; flutterDaemonPid = 0; flutterHeadless = ($kind -eq 'flutter-web' -and $settings.FlutterDevice -eq 'chrome' -and -not [bool]$FlutterVisible); flutterDevice = $(if ($kind -eq 'flutter-web') { $settings.FlutterDevice } else { $null }); browserProfilePath = $flutterProfilePath; flutterLaunchDirectory=$flutterLaunchDirectory; flutterTokenPath=$flutterTokenPath }
    if($kind-eq'flutter-web'){$sdkRoot=if($launch.PSObject.Properties['FlutterSdkRoot']){$launch.FlutterSdkRoot}else{$null};$entryData|Add-Member -NotePropertyName flutterSdkRoot -NotePropertyValue $sdkRoot -Force}
    Set-SgReservationState $Config $entry.path $reservationToken 'starting' $entryData
    if (-not (Test-SgProcessIdentity $entryData)) {
        if($kind-eq'flutter-web'){
            Copy-SgFlutterDiagnostics $entryData $out $err
            if(Wait-SgFlutterOwnedExtinction $entryData 2){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entryData)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}
        }
        Write-SgWarn "Process exited during startup. See $err"
        $entryData.status = 'error'
        $entryData.lastError = Get-SgStartupFailure $err
        $entryData.pid = 0
        $entryData.startTimeUtc = $null
        Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError
        return $entryData
    }
    [void](Write-SgProjectEnvironment $entry.path $port $kind)
    $readiness = if($kind -eq 'flutter-web'){Wait-SgFlutterSupervisorReady (Join-Path $flutterLaunchDirectory 'state.json')}elseif($kind-eq'browser-extension'){Wait-SgBrowserExtensionReady $launchPath $port 90 $entryData $err}else{Wait-SgProjectReady $kind $port $out 90 $entryData $err}
    if ($readiness.Ready) {
        $entryData.status = 'running'
        $entryData.flutterAppId = $readiness.AppId
        if($readiness.PSObject.Properties['DaemonPid']){$entryData.flutterDaemonPid=[int]$readiness.DaemonPid}
        Set-SgReservationState $Config $entry.path $reservationToken 'running' $entryData
    } else {
        $entryData.status = 'error'
        $entryData.lastError = if ($readiness.Error) { [string]$readiness.Error } else { 'Application readiness failed.' }
        if ($entryData.jobName) { [void](Stop-SgManagedJob $entryData) }
        elseif (Test-SgProcessIdentity $entryData) { Stop-SgProcessTree ([int]$entryData.pid) }
        if($kind-eq'flutter-web'){
            [void](Stop-SgOwnedFlutterBrowser $entryData)
            Copy-SgFlutterDiagnostics $entryData $out $err
            if(Wait-SgFlutterOwnedExtinction $entryData 8){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entryData)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}else{Write-SgWarn 'Flutter processes did not prove extinction; launch diagnostics were preserved.'}
        }
        if (-not (Wait-SgManagedExtinction $entryData 8)) { throw 'Application readiness failed and managed process extinction could not be proved.' }
        $entryData.pid = 0
        $entryData.startTimeUtc = $null
        Release-SgProjectPort $Config $entry.path $reservationToken $entryData.lastError
    }
    if($kind-eq'browser-extension'){
        Write-SgInfo "$($entry.name) $($entryData.status): Manifest V3 build ready in dist\chrome"
        Write-SgInfo "Next: run s open -ProjectPath `"$($entry.path)`" to open Chrome extension tools."
    }else{Write-SgInfo "$($entry.name) $($entryData.status): http://127.0.0.1:$port"}
    return $entryData
}

function Stop-SgProcessTree([int]$RootPid) {
    $all = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $ids = New-Object System.Collections.Generic.List[int]
    $visited = New-Object 'System.Collections.Generic.HashSet[int]'
    function Add-ProcessPostOrder([int]$Parent) {
        if(-not$visited.Add($Parent)){return}
        foreach($child in @($all|Where-Object{$_.ParentProcessId-eq$Parent})){Add-ProcessPostOrder ([int]$child.ProcessId)}
        [void]$ids.Add($Parent)
    }
    Add-ProcessPostOrder $RootPid
    foreach ($pid in @($ids)) { Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue }
}

function Get-SgOwnedFlutterListenerPids([object]$Entry) {
    if (-not $Entry -or $Entry.kind -ne 'flutter-web' -or [int]$Entry.port -le 0) { return @() }
    $listeners = @(Get-NetTCPConnection -LocalPort ([int]$Entry.port) -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return @() }

    $projectPath = [IO.Path]::GetFullPath($(if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path })).TrimEnd('\','/').ToLowerInvariant()
    $projectPattern = [regex]::Escape($projectPath) + '(?:[\\/"''\s]|$)'
    $signature = if ($Entry.PSObject.Properties['commandSignature']) { ([string]$Entry.commandSignature).ToLowerInvariant() } else { '' }
    $managedPaths=@();foreach($property in @('browserProfilePath','flutterLaunchDirectory')){if($Entry.PSObject.Properties[$property]-and$Entry.$property){$managedPaths+=[IO.Path]::GetFullPath([string]$Entry.$property).TrimEnd('\','/').ToLowerInvariant()}}
    $managedPatterns=@($managedPaths|ForEach-Object{'(?i)(?:^|[\s"''])'+[regex]::Escape($_)+'(?:[\s"'']|$)'})
    $processes = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $byId = @{}
    foreach ($process in $processes) { $byId[[int]$process.ProcessId] = $process }

    $owned = @()
    foreach ($listener in $listeners) {
        $listenerPid = [int]$listener.OwningProcess
        if(-not$byId.ContainsKey($listenerPid)-or-not$Entry.PSObject.Properties['flutterSdkRoot']-or-not$Entry.flutterSdkRoot-or$managedPatterns.Count-eq0){continue}
        $process=$byId[$listenerPid]
        try{$executable=[IO.Path]::GetFullPath([string]$process.ExecutablePath);$sdkDartRoot=[IO.Path]::GetFullPath((Join-Path ([string]$Entry.flutterSdkRoot) 'bin\cache\dart-sdk\bin'));$allowedExecutables=@([IO.Path]::GetFullPath((Join-Path $sdkDartRoot 'dart.exe')),[IO.Path]::GetFullPath((Join-Path $sdkDartRoot 'dartvm.exe')))}catch{continue}
        $executableAllowed=@($allowedExecutables|Where-Object{$executable.Equals($_,[StringComparison]::OrdinalIgnoreCase)}).Count-eq 1
        if(-not$executableAllowed){continue}
        $commandLine=[string]$process.CommandLine;$managedEvidence=$false;foreach($managedPattern in $managedPatterns){if($commandLine-match$managedPattern){$managedEvidence=$true;break}}
        if($managedEvidence){$owned+=$listenerPid}
    }
    return @($owned | Sort-Object -Unique)
}

function Stop-SgOwnedFlutterListener([object]$Entry) {
    $ownedPids = @(Get-SgOwnedFlutterListenerPids $Entry)
    foreach ($ownedPid in $ownedPids) { Stop-SgProcessTree $ownedPid }
    return $ownedPids.Count -gt 0
}

function Get-SgOwnedFlutterBrowserPids([object]$Entry) {
    if (-not $Entry -or $Entry.kind -ne 'flutter-web' -or -not $Entry.PSObject.Properties['browserProfilePath'] -or [string]::IsNullOrWhiteSpace([string]$Entry.browserProfilePath)) { return @() }
    $profile = [IO.Path]::GetFullPath([string]$Entry.browserProfilePath).TrimEnd('\','/')
    $profilePattern = '(?i)(?:^|\s)--user-data-dir=(?:"' + [regex]::Escape($profile) + '"|' + [regex]::Escape($profile) + ')(?:\s|$)'
    $owned = @()
    foreach ($process in @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)) {
        $executable = [string]$process.ExecutablePath
        $commandLine = [string]$process.CommandLine
        if ($executable -notmatch '(?i)(?:chrome|msedge)\.exe$') { continue }
        if ($commandLine -match $profilePattern) { $owned += [int]$process.ProcessId }
    }
    return @($owned | Sort-Object -Unique)
}

function Stop-SgOwnedFlutterBrowser([object]$Entry) {
    $ownedPids = @(Get-SgOwnedFlutterBrowserPids $Entry)
    foreach ($ownedPid in $ownedPids) { Stop-SgProcessTree $ownedPid }
    return $ownedPids.Count -gt 0
}

function Wait-SgManagedExtinction([object]$Entry, [int]$TimeoutSeconds = 8) {
    $deadline = (Get-Date).AddSeconds([Math]::Max(0, $TimeoutSeconds))
    $entryPort = if ($Entry.PSObject.Properties['port']) { [int]$Entry.port } else { 0 }
    do {
        $identityGone = -not (Test-SgProcessIdentity $Entry)
        $serviceGone = $entryPort -le 0 -or (Test-SgPortAvailable $entryPort)
        if ($identityGone -and $serviceGone) { return $true }
        if ((Get-Date) -ge $deadline) { return $false }
        Start-Sleep -Milliseconds 100
    } while ($true)
}

function Stop-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { return $false }
    $entryPort = if ($entry.PSObject.Properties['port']) { [int]$entry.port } else { 0 }
    $alreadyStopped = $entry.status -eq 'stopped' -and [int]$entry.pid -le 0
    $cleanedFlutterArtifacts=$false
    if($entry.kind -eq 'flutter-web' -and $alreadyStopped){try{$cleanedFlutterArtifacts=[bool](Remove-SgFlutterLaunchArtifacts $Config $entry)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}
    $stoppedBySupervisor=$false
    if($entry.kind -eq 'flutter-web' -and $entry.PSObject.Properties['flutterLaunchDirectory'] -and (Test-SgProcessIdentity $entry)){try{[void](Invoke-SgFlutterSupervisorCommand $entry 'stop' 8);$stoppedBySupervisor=$true}catch{Write-SgWarn "Flutter supervisor stop fallback: $($_.Exception.Message)"}}
    $stoppedFlutterListener = Stop-SgOwnedFlutterListener $entry
    $stoppedFlutterBrowser = Stop-SgOwnedFlutterBrowser $entry
    $noRuntimeWork = $alreadyStopped -and -not $cleanedFlutterArtifacts -and -not $stoppedBySupervisor -and -not $stoppedFlutterListener -and -not $stoppedFlutterBrowser
    if ((Test-Path -LiteralPath $path -PathType Container) -and -not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $path" }
    $stopped = $cleanedFlutterArtifacts -or $stoppedBySupervisor -or $stoppedFlutterListener -or $stoppedFlutterBrowser
    $identityLive = Test-SgProcessIdentity $entry
    $serviceLive = $entryPort -gt 0 -and -not (Test-SgPortAvailable $entryPort)
    if (($identityLive -or $serviceLive) -and $entry.PSObject.Properties['jobName'] -and $entry.jobName) {
        if (-not (Stop-SgManagedJob $entry)) { throw "Managed process job is unavailable for $($entry.name); refusing an unverified stop." }
        $stopped = $true
    } elseif ($identityLive) {
        Stop-SgProcessTree ([int]$entry.pid)
        $stopped = $true
    } elseif (-not $stoppedBySupervisor -and -not $stoppedFlutterListener -and -not $stoppedFlutterBrowser -and [int]$entry.pid -gt 0) {
        Write-SgWarn "Stale or unverified process for $($entry.name); no process was terminated."
    }
    if (-not (Wait-SgManagedExtinction $entry 8)) { throw "Could not prove process and service extinction for $($entry.name); registry state was preserved." }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $found = @($data.projects | Where-Object { $_.path -eq $path })[0]
        if ($found) {
            $found.status = 'stopped'; $found.pid = 0; $found.startTimeUtc = $null; $found.lastError = $null
            if ($found.PSObject.Properties['reservationToken']) { $found.reservationToken = $null }
            if ($found.PSObject.Properties['reservationTimeUtc']) { $found.reservationTimeUtc = $null }
        }
    } | Out-Null
    if ($noRuntimeWork) { return $false }
    if($entry.kind -eq 'flutter-web'){try{[void](Remove-SgFlutterLaunchArtifacts $Config $entry)}catch{Write-SgWarn "Flutter launch cleanup pending: $($_.Exception.Message)"}}
    return $stopped
}

function Open-SgProject([object]$Config, [object]$Entry) {
    if (-not $Entry) { throw 'No registered project was selected.' }
    if ($Entry.status -notin @('starting','running') -or [int]$Entry.port -le 0) {
        $name = if ($Entry.PSObject.Properties['name'] -and $Entry.name) { [string]$Entry.name } else { 'This project' }
        $path = if ($Entry.PSObject.Properties['path'] -and $Entry.path) { [string]$Entry.path } else { '<path>' }
        $experience = Get-SgProjectExperience ([string]$Entry.kind) ([int]$Entry.port)
        throw "$name is $($Entry.status) ($($experience.Label)). Run s start -ProjectPath `"$path`" before Open / load project."
    }
    if ($Entry.kind -eq 'browser-extension') {
        $projectPath = if ($Entry.PSObject.Properties['launchPath'] -and $Entry.launchPath) { [string]$Entry.launchPath } else { [string]$Entry.path }
        $output = @(Get-SgBrowserExtensionManifestPaths $projectPath | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | ForEach-Object { Split-Path -Parent $_ }) | Select-Object -First 1
        if (-not $output) { throw 'The browser extension has no generated unpacked directory. Wait for the Chrome development build to finish.' }
        Start-Process 'chrome://extensions/'
        Start-Process $output
        Write-SgInfo "Chrome extension tools opened: chrome://extensions and $output"
        Write-SgInfo '1. Enable Developer mode in Chrome.'
        Write-SgInfo '2. Choose Load unpacked.'
        Write-SgInfo "3. Select $output. ShipGlows never installs the extension automatically in your personal Chrome profile."
        return $Entry
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterHeadless'] -and [bool]$Entry.flutterHeadless) {
        $port = [int]$Entry.port
        [void](Invoke-SgFlutterSupervisorCommand $Entry 'open' 8)
        $deadline=(Get-Date).AddSeconds(8);while((Get-Date)-lt $deadline -and (Test-SgProcessIdentity $Entry)){Start-Sleep -Milliseconds 200}
        if(Test-SgProcessIdentity $Entry){throw 'Flutter supervisor did not stop after open; visible relaunch was refused.'}
        [void](Stop-SgOwnedFlutterListener $Entry);[void](Stop-SgOwnedFlutterBrowser $Entry)
        if(-not(Wait-SgFlutterOwnedExtinction $Entry 8)){throw 'Owned Flutter processes remain after open; visible relaunch was refused.'}
        [void](Remove-SgFlutterLaunchArtifacts $Config $Entry)
        return Start-SgProject $Config ([string]$Entry.path) $port -FlutterVisible
    }
    if ($Entry.kind -eq 'flutter-web' -and $Entry.PSObject.Properties['flutterDevice'] -and $Entry.flutterDevice -eq 'chrome') {
        Write-SgInfo 'Flutter is already running in its managed visible Chrome session.'
        return $Entry
    }
    Start-Process "http://127.0.0.1:$([int]$Entry.port)"
    return $Entry
}

function Unregister-SgProject([object]$Config, [string]$ProjectPath) {
    $path = ConvertTo-SgCanonicalPath $ProjectPath
    $entry = @((Read-SgRegistry $Config).projects | Where-Object { $_.path -eq $path })[0]
    if (-not $entry) { throw "Project is not registered: $path" }
    if (-not (Test-SgProjectCatalogEntry $entry)) { Clear-SgProjectCatalogCache $Config; throw "Project surface no longer matches its registered manifest: $path" }
    if (Test-SgProcessIdentity $entry) { throw "Project is still running: $($entry.name). Stop it before unregistering." }
    Invoke-SgRegistryMutation $Config {
        param($data)
        $data.projects = @($data.projects | Where-Object { $_.path -ne $path })
    } | Out-Null
    Clear-SgProjectCatalogCache $Config
    Write-SgInfo "Unregistered project without deleting its files: $path"
}

function Show-SgDashboard([object]$Config) {
    $registry = Reconcile-SgRegistry $Config
    Write-Host ''; Write-Host 'ShipGlows DevServer Windows' -ForegroundColor Yellow; Write-Host '============================' -ForegroundColor Yellow
    $items = @($registry.projects)
    if ($items.Count -eq 0) { Write-Host 'No registered projects.'; return }
    $index = 1
    foreach ($entry in $items) { Write-Host ("[{0}] {1}  {2}  {3}  {4}" -f $index,$entry.status,$entry.kind,$entry.port,$entry.path); $index++ }
}

Export-ModuleMember -Function Write-SgInfo,Write-SgWarn,Write-SgError,Ensure-SgDirectory,ConvertTo-SgCanonicalPath,Get-SgDevConfig,Get-SgProjectKind,Get-SgProjectExperience,Format-SgProjectStatus,Get-SgProjectDescriptor,Get-SgProjectDescriptors,Get-SgRuntimeSettings,Read-SgRegistry,Reconcile-SgRegistry,Register-SgProject,Sync-SgRegisteredProjectEnvironments,Start-SgProject,Stop-SgProject,Open-SgProject,Invoke-SgFlutterSupervisorCommand,Unregister-SgProject,Show-SgDashboard,Test-SgGitUrl,Test-SgProjectPath,ConvertTo-SgGitHubRepositoryIdentity,Get-SgInstalledGitHubRepositoryIdentities,Select-SgGitHubCloneCandidates,Get-SgFreePort,Test-SgPortAvailable,Reserve-SgProjectPort,Set-SgReservationState,Release-SgProjectPort,Get-SgRunnableIdentity,Get-SgCanonicalSurfaceName,Get-SgDisplayName,Add-SgDiscoveredMetadata,Sync-SgDiscoveredProjectMetadata,Get-SgOwnedFlutterListenerPids,Stop-SgOwnedFlutterListener,Get-SgOwnedFlutterBrowserPids,Stop-SgOwnedFlutterBrowser,Rotate-SgLogFile,Get-SgProjectEnvironmentPath,Write-SgProjectEnvironment,Get-SgProjectEnvironment,Remove-SgLegacyProjectServerState,Get-SgWorkspaceProjectCandidates,Get-SgProjectCatalog,Clear-SgProjectCatalogCache,Resolve-SgProjectCatalogEntry,New-SgProjectChoiceMap
Export-ModuleMember -Function Clear-SgProjectCatalogMemoryCache,Test-SgProjectCatalogRefreshRequired
